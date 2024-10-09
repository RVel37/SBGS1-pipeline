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
        String aligned  ### temp dir for testing
    }

############ TASKS ######################

    # glob all indexed ref genome files
    call alignmentTask.concat_refs {
        input:
        ref_genome = ref_genome
    }


    call concatSamsTask.concat_sams {
        input:
            aligned = aligned
    }

    scatter (f in concat_sams.sam_files) {
        call alignmentTask.generate_bam {
            input:
                sam_file = f
        }
    }

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

#  output {
#     Array[File] bam_files = generate_bam.bam_file
#     Array[File] vcf_files = octopus_caller.vcf_file
#  }

}
