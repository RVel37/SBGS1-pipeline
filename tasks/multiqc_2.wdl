version 1.0

task multiqc_task {
    input {
        Array[File] fastqc_outputs
    }

    command <<<
        mkdir dir_multiqc
        multiqc ~{sep= ' ' fastqc_outputs} -o dir_multiqc
    >>>

    output {
        File multiqc_report = "dir_multiqc/multiqc_report.html"
        File multiqc_data = "dir_multiqc/multiqc_data"
    }

    runtime {
        docker: "multiqc/multiqc:latest"
    }
}