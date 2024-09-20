version 1.0

task fastqc {

### INPUTS -- paths to relevant directories
# note: didn't include fastqs as input - we navigate to the directory in docker run command

    input {
        String output_dir # fastqc output directory
    }

    command <<<
        # create dir for FASTQC if nonexistent
        mkdir -p ~{output_dir}/fastqc_output

        # pull fastqc docker image
        docker pull staphb/fastqc:0.12.1

        # run
        docker run --rm \
            -v ~{output_dir}/fastq_output:/fastq_files \
            -v ~{output_dir}/fastqc_output:/fastqc_output \
                staphb/fastqc:0.12.1 bash -c "
                cd /fastq_files
                fastqc -o /outputs/fastqc_output --noextract *.fastq.gz
            "
    >>>

   # OUTPUT not needed as there's no more fastqc-related tasks.
}