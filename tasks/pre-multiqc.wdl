version 1.0

task multiqc {
    input {
        Array[File] fastqc_outputs
        Int random_number
    }

    command <<<
        mkdir runnumber_~{random_number}
        mkdir runnumber_~{random_number}/dir_multiqc
        multiqc ~{sep= ' ' fastqc_outputs} -o runnumber_~{random_number}/dir_multiqc
    >>>

    output {
        File multiqc_report = "runnumber_~{random_number}/dir_multiqc/multiqc_report.html"
        File multiqc_data = "runnumber_~{random_number}/dir_multiqc/multiqc_data"
    }

    runtime {
        docker: "multiqc/multiqc:v1.25.1"
    }
}
