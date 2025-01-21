version 1.0

task concat_fastqs_task {
    
    input {
        String fastq_dir
    }

    command <<<
        # move FASTQs in temporary dir that makes them accessible to cromwell
        mkdir temp_fastq_dir 
        cp ~{fastq_dir}/* temp_fastq_dir 
    >>>

    output {
        # Directories can be stored as arrays of files
        Array[File] fastq_array = glob("~{fastq_dir}/*")
    }
}
