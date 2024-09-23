version 1.0

task fastqc {

    input {
        Array[File] fastq_files
        String output_dir 
    }

    command <<<
  
        mkdir dir_fastqc

        for i in  ~{sep=" " fastq_files}; do
            fastqc -o dir_fastqc --noextract $i
        done
    >>>

    runtime{
        docker: "staphb/fastqc:0.12.1"
    }
}
