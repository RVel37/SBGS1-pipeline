version 1.0

import "tasks/concat_fastqs_0.wdl" as concat_fastqsTask
import "tasks/fastqc_1.wdl" as fastqcTask
import "tasks/multiqc_2.wdl" as multiqctask

workflow main {
    input {
        String fastq_dir
    }

    call concat_fastqsTask.concat_fastqs_task {
        input:
            fastq_dir = fastq_dir
    }

    scatter (f in concat_fastqs_task.fastq_array) {
        call fastqcTask.fastqc_task {
            input:
                 fastq_file = f
        }
    }

    call multiqctask.multiqc_task {
        input:
            fastqc_outputs= flatten(fastqc_task.fastqc_output)
    }

    output {
        Array[File] fastq_output = concat_fastqs_task.fastq_array
        Array[File] fastqc_output = flatten(fastqc_task.fastqc_output)
        File multiqc_report = multiqc_task.multiqc_report
        File multiqc_data = multiqc_task.multiqc_data
    }
}