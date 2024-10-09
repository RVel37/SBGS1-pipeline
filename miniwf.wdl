version 1.0

import "tasks/concat_sams.wdl" as concatSamsTask
import "tasks/aligning.wdl" as alignmentTask
import "tasks/variantCalling.wdl" as variantCallingTask

workflow main {
    # workflow input
    input {
        String output_dir
        String ref_genome
        File ref_genome_fa
        String aligned
    }

############ TASKS ######################

    call concatSamsTask.concat_sams {
        input:
            aligned = aligned
    }

    # convert to BAM -> run variant caller

    scatter (f in concat_sams.sam_files) {
        call alignmentTask.generate_bam {
            input:
                sam_file = f
        }
        call variantCallingTask.octopus_caller {
            input:
                ref_genome_fa = ref_genome_fa,
                bam_file = generate_bam.bam_file
        }
    }


########### OUTPUTS #####################

     output {
        Array[File] bam_files = generate_bam.bam_file
        Array[File] vcf_files = octopus_caller.vcf_file
     }

}
