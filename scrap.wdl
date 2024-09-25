version 1.0

import "tasks/findFiles_0.wdl" as findFilesTask
import "tasks/bcl2fastq_1.wdl" as bcl2fastqTask
import "tasks/fastqc_2.wdl" as fastqcTask

workflow main {
    # workflow input
    input {
        String resources_dir
        String runfolder_dir
        String output_dir
        String ref_genome
        File sampleSheet
    }

############ TASKS ######################

    call bcl2fastqTask.bcl2fastq {
        input:
        runfolder_dir = runfolder_dir,
        output_dir = output_dir
    }

    # scatter (f in bcl2fastq.fastq_files) {
    #     call fastqcTask.fastqc {
    #     input:
    #         fastq_files = [f],
    #         output_dir = output_dir
    #     }
    # }

#######################################

}
