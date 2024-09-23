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
    }

############ TASKS ######################

    call findFilesTask.find_files {
        input:
        runfolder_dir = runfolder_dir
    }

    call bcl2fastqTask.bcl2fastq {
        input:
            bcl_files = find_files.found_files, 
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
