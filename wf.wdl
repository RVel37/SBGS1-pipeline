version 1.0

import "tasks/indexReference_0.wdl" as indexTask
import "tasks/bcl2fastq_1.wdl" as bcl2fastqTask
#import "tasks/fastqc_2.wdl" as fastqcTask
import "tasks/aligning_3.wdl" as alignmentTask
import "tasks/variantCalling_4.wdl" as variantCallingTask

workflow main {
    # workflow input
    input {
        String runfolder_dir
        String output_dir
        String ref_genome
        File ref_genome_fa
    }

############ TASKS ######################

    call bcl2fastqTask.bcl2fastq {
        input:
        runfolder_dir = runfolder_dir,
        output_dir = output_dir
    }

    # scatter (f in bcl2fastq.fastq_files) {
    #     call fastqcTask.fastqc {
    #         input:
    #             fastq_file = f
    #     }
    # }

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

    # glob all indexed ref genome files
    call alignmentTask.concat_refs {
        input:
        ref_genome = ref_genome
    }

    # can't scatter - need R1+R2 pairs
    call alignmentTask.generate_sam {
        input:
            ref_indexed = concat_refs.ref_indexed,
            fastq_files = fastq_files,
            ref_genome_fa = ref_genome_fa
    }

    scatter (f in generate_sam.sam_files) {
        call alignmentTask.generate_bam {
            input:
                sam_file = f
        }
        call variantCallingTask.octopus_caller {
            input:
                ref_genome_fa = ref_genome_fa,
                bam_file = alignmentTask.generate_bam.bam_file
        }
    }



########### OUTPUTS #####################

     output {
        Array[File] fastq_files = bcl2fastq.fastq_files
       # Array[File] fastqc_output = flatten(fastqc.fastqc_output) # flatten nested array
        Array[File] sam_files = generate_sam.sam_files
        Array[File] bam_files = generate_bam.bam_file
     }

}
