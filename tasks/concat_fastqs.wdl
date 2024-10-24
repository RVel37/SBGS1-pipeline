version 1.0

task concat_fastqs_task {
    
    input {
        String fastq_dir
    }

    command <<<
        mkdir fastq_dir 
        cp ~{fastq_dir}/* fastq_dir 
    >>>

    output {
        Array[File] fastq_files = glob("~{fastq_dir}/*")
        Array[File] forward_read = glob("~{fastq_dir}/*_R1_001.fastq.gz")
        Array[File] reverse_read = glob("~{fastq_dir}/*_R2_001.fastq.gz")
    }
}
