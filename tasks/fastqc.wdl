version 1.0

task fastqc {

    input {
        File fastq_file
    }

    command <<<

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
