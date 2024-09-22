version 1.0

import "tasks/bcl2fastq_1.wdl" as bcl2fastqTask

workflow main {

    input {
        String resources_dir
        String runfolder_dir
        String output_dir
        String ref_genome
    }

    call bcl2fastqTask.bcl2fastq {

        input:
            runfolder_dir = runfolder_dir, 
            output_dir = output_dir
}
