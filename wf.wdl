version 1.0

import "tasks/concat_fastqs.wdl" as concat_fastqsTask
import "tasks/trimming.wdl" as trimmingTask
import "tasks/fastqc.wdl" as fastqcTask
import "tasks/multiqc.wdl" as multiqcTask
import "tasks/index_reference.wdl" as indexTask
import "tasks/aligning.wdl" as alignmentTask
import "tasks/variant_calling.wdl" as variantCallingTask

workflow main {
    input {
        String fastq_dir
        File adapter_file
        String ref_genome
        File ref_genome_fa
    }

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
    call multiqcTask.multiqc {
        input:
            fastqc_outputs = flatten(fastqc.fastqc_output)
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
    call alignmentTask.generate_sam {
        input:
            ref_indexed = concat_refs.ref_indexed,
            trimmed_fastq_files = trim_fastqs_task.paired_trimmed_files,
            ref_genome_fa = ref_genome_fa
    }

    # SAM to BAM
    scatter (f in generate_sam.sam_files) {
        call alignmentTask.generate_bam {
            input:
                sam_file = f
        }
    }

    # variant calling (octopus)
    scatter (pair in generate_bam.bam_bai_pair) {
        call variantCallingTask.octopus_caller {
            input:
                ref_indexed = concat_refs.ref_indexed,
                ref_genome_fa = ref_genome_fa,
                bam_file = pair.left,
                bai_file = pair.right
        }
    }


    output {
        File multiqc_report = multiqc.multiqc_report
        File multiqc_data = multiqc.multiqc_data
        Array[File] vcf_files = octopus_caller.vcf_file
    }
}
