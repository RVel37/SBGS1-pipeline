version 1.0

task concat_fastqs {
    
    input {
        String fastq_dir
    }

    command <<<
        mkdir temp_fastq_dir # temporary dir that is in cromwell sub_dir
        cp ~{fastq_dir}/* temp_fastq_dir 
    >>>

    output {
        Array[File] fastq_files = glob("~{fastq_dir}/*")
    }
}
