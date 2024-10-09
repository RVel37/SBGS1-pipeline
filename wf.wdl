version 1.0

# snake_case for filenames, camelCase for tasknames

import "tasks/concat_fastqs.wdl" as concatFastqsTask
import "tasks/fastqc.wdl" as fastqcTask
import "tasks/multiqc.wdl" as multiqcTask
import "tasks/index_reference.wdl" as indexTask
import "tasks/fastqc.wdl" as fastqcTask
import "tasks/aligning.wdl" as alignmentTask
import "tasks/variant_calling.wdl" as variantCallingTask

workflow main {

############# INPUTS #####################

    input {
        String fastq_dir
        String output_dir
        String ref_genome
        File ref_genome_fa
    }

############ TASKS ######################

# pull fastqs from input dir -> array[file] in cromwell
    call concatFastqsTask.concat_fastqs {
        input:
            fastq_dir = fastq_dir
    }

# fastQC reports
    scatter (f in concat_fastqs.fastq_files) {
        call fastqcTask.fastqc {
            input:
                 fastq_file = f
        }
    }

# multiQC report
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
            fastq_files = concat_fastqs.fastq_files,
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

########### OUTPUTS #####################

     output {
        File multiqc_report = multiqc.multiqc_report
        File multiqc_data = multiqc.multiqc_data
        Array[File] vcf_files = octopus_caller.vcf_file
     }

}
