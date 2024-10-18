version 1.0

task samtools_stats {
    input {
        File bam_file
    }

    command <<<
        mkdir bam_stats_output
        BASE=$(basename ~{bam_file} .bam)
        samtools stats ~{bam_file} > bam_stats_output/${BASE}_stats.txt
    >>>

    output {
        Array[File] stats_files = glob("bam_stats_output/*")
    }

    runtime {
        docker: "swglh/samtools:1.18"
    }
}

