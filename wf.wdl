version 1.0

#import "tasks/indexReference_0.wdl" as indexTask
import "tasks/bcl2fastq_1.wdl" as bcl2fastqTask
#import "tasks/fastqc_2.wdl" as fastqcTask
#import "tasks/aligning_3.wdl" as alignmentTask

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

    # # optional: checks if genome has been indexed + indexes if not
    # if (glob("~{ref_genome}/*.fa.*").length == 0) {
    #     call indexTask {
    #         input:
    #             ref_genome = ref_genome
    #     }
    # }

    # # glob all indexed ref genome files
    # Array[File] ref_indexed = glob("~{ref_genome}/*.fa*")

    # call alignmentTask.generate_sam {
    #     input:
    #         resources_dir = resources_dir,
    #         output_dir = output_dir,
    #         ref_indexed = ref_indexed,
    #         ref_genome = ref_genome_fa
    # }

    # scatter (f in bcl2fastq.fastq_files) {
    #     call alignmentTask.generate_bam {
    #         input:
    #             sam_file = f
    #     }
    # }


########### OUTPUTS #####################

     output {
       Array[File] fastq_files = bcl2fastq.fastq_files
    #     # flatten nested array
    #     Array[File] fastqc_output = flatten(fastqc.fastq_outputs),
    #     Array[File] sam_files,
    #     Array[File] bam_files
     }

}
