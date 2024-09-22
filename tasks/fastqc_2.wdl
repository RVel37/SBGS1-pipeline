version 1.0

task fastqc {

    input {
        Array[File] fastq_files
        String output_dir 
    }

    command <<<
        # create dir for FASTQC if nonexistent
        mkdir -p ~{output_dir}fastqc_output

        for FASTQ in ~{fastq_files}; do
            fastqc -o ~{output_dir}fastqc_output --noextract $FASTQ
        done
    >>>

    # ommitted output - not needed

    runtime{
        docker: "staphb/fastqc:0.12.1"
    }
}
