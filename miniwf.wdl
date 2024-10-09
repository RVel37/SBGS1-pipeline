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
    }
    
# java.io.FileNotFoundException: Could not process output, file not found: /mnt/data1/working_directory/ray/SBGS1-pipeline/cromwell-executions/main/46253d8f-4901-48a5-b842-3ac455c2075d/call-generate_bam/shard-9/execution/bam_aligned/*_sorted.bam

    scatter (f in generate_bam.bam_file) {
        call variantCallingTask.octopus_caller {
            input:
                ref_genome_fa = ref_genome_fa,
                bam_file = f
        }
    }


########### OUTPUTS #####################

#  output {
#     Array[File] bam_files = generate_bam.bam_file
#     Array[File] vcf_files = octopus_caller.vcf_file
#  }

}
