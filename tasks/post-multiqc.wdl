version 1.0

task multiqc_postprocessing {
    input {
        Array[File] bam_stats_files
        Array[File] duplication_metrics_files
        Int random_number
    }

    command <<<
        mkdir -p runnumber_~{random_number} # make directory matching the run number
        mkdir runnumber_~{random_number}/post_multiqc_dir # make subdir for multiqc

        # run multiQC
        multiqc ~{sep= ' ' bam_stats_files} ~{sep= ' ' duplication_metrics_files} \
        -o runnumber_~{random_number}/post_multiqc_dir
    >>>

    output {
        File postprocessing_multiqc_report = "runnumber_~{random_number}/post_multiqc_dir/multiqc_report.html"
        File postprocessing_multiqc_data = "runnumber_~{random_number}/post_multiqc_dir/multiqc_data"
    }

    runtime {
        docker: "multiqc/multiqc:v1.25.1"
    }
}
