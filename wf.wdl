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
import "tasks/annotating.wdl" as annotationTask



### MAIN WORKFLOW ###

workflow main {
    input {
        String fastq_dir    # fastq input directory
        File adapter_file   # adapters for trimming step
        String ref_genome   # reference genome directory
        File ref_genome_fa  # reference genome fasta file
        File vep_cache      # vep cache (for offline use)
        File REVEL_tsv      # revel files
        File REVEL_tbi
    }

    #Generate a random number for the run 
    call randomnumTask.generate_random_number 

    #Concat_fastQs into forward & reverse read Arrays
    call concat_fastqsTask.concat_fastqs_task {
        input:
            fastq_dir = fastq_dir
    }

    # Trimming (remove adapters to improve quality)
    scatter (i in range(length(concat_fastqs_task.forward_read))) {
    call trimmingTask.trim_fastqs_task {
        input:
            forward_read = concat_fastqs_task.forward_read[i],
            reverse_read = concat_fastqs_task.reverse_read[i],
            adapter_file = adapter_file
        }
    }

    Array[File] trimmed_R1_dir = flatten(trim_fastqs_task.forward_trimmed) # Flatten scattered R1 & R2 trimmed fastqs into a single dir
    Array[File] trimmed_R2_dir = flatten(trim_fastqs_task.reverse_trimmed)
    Array[File] paired_trimmed_fastqs = flatten(trim_fastqs_task.paired_trimmed_files)
    #FastQC 
    scatter (f in paired_trimmed_fastqs) {
        call fastqcTask.fastqc {
            input:
                 fastq_file = f
        }
    }

    # MultiQC
    call premultiqcTask.multiqc {
        input:
            fastqc_outputs = flatten(fastqc.fastqc_output),
            random_number = generate_random_number.random_number
    }

    # Check whether genome has been indexed; index if not
    call indexTask.check_index {    # checks whether genome was indexed
        input:
            ref_genome = ref_genome
    }

    if (!check_index.is_indexed) {  # if genome hasn't been indexed
        call indexTask.index_ref {  # run indexing task
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
    scatter (i in range(length(concat_fastqs_task.forward_read))) {
        call alignmentTask.generate_sam {
            input:
                ref_indexed = concat_refs.ref_indexed,
                forward_read = trimmed_R1_dir[i],
                reverse_read = trimmed_R2_dir[i],  # Pass the corresponding reverse read
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

    # Annotation (VEP)
    scatter (vcf in vcf_files) {
        call annotationTask.VEP_annotation {
            input: 
                vcf = vcf,
                vep_cache = vep_cache,
                REVEL_tbi = REVEL_tbi,
                REVEL_tsv = REVEL_tsv

        }
    }

    output {
        File multiqc_report = multiqc.multiqc_report
        File multiqc_data = multiqc.multiqc_data
        File postprocessing_multiqc_report = multiqc_postprocessing.postprocessing_multiqc_report
        File postprocessing_multiqc_data = multiqc_postprocessing.postprocessing_multiqc_data
        Array[File] vcf_files = octopus_caller.vcf_file
        Array[File] annotated_vcfs = VEP_annotation.annotation_output
    }
}
