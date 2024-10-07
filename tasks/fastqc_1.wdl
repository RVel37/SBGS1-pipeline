version 1.0

task fastqc_task {
    input {
        File fastq_file
    }

    command <<<
        # check if dir_fastqc already exists by setting a conditional?
        mkdir dir_fastqc
        fastqc -o dir_fastqc --noextract ~{fastq_file}
    >>>

    output {
        Array[File] fastqc_output = glob("dir_fastqc/*.{zip,html}")
    }

    runtime {
        docker: "staphb/fastqc:0.12.1"
    }
} 
  
