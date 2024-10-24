version 1.0

import "tasks/random_num.wdl" as randomnumTask
import "tasks/concat_fastqs.wdl" as concat_fastqsTask
import "tasks/trimming.wdl" as trimmingTask
import "tasks/fastqc.wdl" as fastqcTask
import "tasks/pre-multiqc.wdl" as premultiqcTask
import "tasks/index_reference.wdl" as indexTask
import "tasks/aligning.wdl" as alignmentTask
import "tasks/markduplicates.wdl" as markDuplicatesTask
import "tasks/samtools_stats.wdl" as samtoolsStatsTask
import "tasks/post-multiqc.wdl" as postmultiqcTask
import "tasks/variant_calling.wdl" as variantCallingTask


workflow main {
    input {
        String fastq_dir
        File adapter_file
        String ref_genome
        File ref_genome_fa
    }

    #Generate a random number for the run 
    call randomnumTask.generate_random_number 

    #Concat_fastQs into an Array[File]
    call concat_fastqsTask.concat_fastqs_task {
        input:
            fastq_dir = fastq_dir
    }

    #Trimming 
    call trimmingTask.trim_fastqs_task {
        input:
            fastq_files = concat_fastqs_task.fastq_array,
            adapter_file = adapter_file
    }

    #FastQC
    scatter (f in trim_fastqs_task.paired_trimmed_files) {
        call fastqcTask.fastqc {
            input:
                 fastq_file = f
        }
    }

    #MultiQC
    call premultiqcTask.multiqc {
        input:
            fastqc_outputs = flatten(fastqc.fastqc_output),
            random_number = generate_random_number.random_number
    }

    # Check whether genome has been indexed; index if not
    call indexTask.check_index {
        input:
            ref_genome = ref_genome
    }

    if (!check_index.is_indexed) {
        call indexTask.index_ref {
            input:
                ref_genome = ref_genome
        }
    }

    # concatenate indexed ref genome files 
    call alignmentTask.concat_refs {
        input:
        ref_genome = ref_genome
    }

# convert to SAM 
    scatter (i in range(length(concat_fastqs.forward_read))) {
        call alignmentTask.generate_sam {
            input:
                ref_indexed = concat_refs.ref_indexed,
                forward_read = concat_fastqs.forward_read[i],
                reverse_read = concat_fastqs.reverse_read[i],  # Pass the corresponding reverse read
                ref_genome_fa = ref_genome_fa
        } 
    }

Array[File] sam_array = flatten(generate_sam.sam_files)

# SAM to BAM
    scatter (f in sam_array) {
        call alignmentTask.generate_bam {
            input:
                sam_file = f
        }
    }

    # Mark duplicates in BAM files
    scatter (f in generate_bam.bam_file) {
        call markDuplicatesTask.mark_duplicates {
            input:
                bam_file = f
        }
    }

    # Generate BAM statistics (Samtools stats) for each BAM file
    scatter (f in mark_duplicates.dedup_bam) {
        call samtoolsStatsTask.samtools_stats {
            input:
                bam_file = f
        }
    }

    # New MultiQC for post-processing
    call postmultiqcTask.multiqc_postprocessing {
        input:
            bam_stats_files = flatten(samtools_stats.stats_files),
            duplication_metrics_files = flatten(mark_duplicates.duplication_metrics),
            random_number = generate_random_number.random_number
    }

    # Variant calling (octopus) on deduplicated BAMs
    scatter (pair in mark_duplicates.dedup_bam_bai_pair) {
        call variantCallingTask.octopus_caller {
            input:
                ref_indexed = concat_refs.ref_indexed,
                ref_genome_fa = ref_genome_fa,
                bam_file = pair.left,
                bai_file = pair.right,
                random_number = generate_random_number.random_number
        }
    }


    output {
        File multiqc_report = multiqc.multiqc_report
        File multiqc_data = multiqc.multiqc_data
        File postprocessing_multiqc_report = multiqc_postprocessing.postprocessing_multiqc_report
        File postprocessing_multiqc_data = multiqc_postprocessing.postprocessing_multiqc_data
        Array[File] vcf_files = octopus_caller.vcf_file
    }
}
