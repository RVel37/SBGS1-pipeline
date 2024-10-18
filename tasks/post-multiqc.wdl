version 1.0

task multiqc_postprocessing {
    input {
        Array[File] bam_stats_files
        Array[File] duplication_metrics_files
    }

    command <<<
        mkdir post_multiqc_dir 
        multiqc ~{sep= ' ' bam_stats_files} ~{sep= ' ' duplication_metrics_files} -o post_multiqc_dir
    >>>

    output {
        File postprocessing_multiqc_report = "post_multiqc_dir/multiqc_report.html"
        File postprocessing_multiqc_data = "post_multiqc_dir/multiqc_data"
    }

    runtime {
        docker: "multiqc/multiqc:v1.25.1"
    }
}
