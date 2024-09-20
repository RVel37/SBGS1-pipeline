version 1.0

import "tasks/bcl2fastq_1.wdl" as bcl2fastqTask

workflow main {
    call bcl2fastqTask.bcl2fastq
}
