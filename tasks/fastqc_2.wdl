version 1.0

task fastqc {

### INPUTS -- paths to relevant directories
# note: didn't include fastqs as input - we navigate to the directory in docker run command

    input {
        Array[File] fastq_files
        String output_dir # fastq output directory
    }

    command <<<
        # create dir for FASTQC if nonexistent
        mkdir -p ~{output_dir}/fastqc_output

        cd /fastq_files
        fastqc -o ~{output_dir}/fastqc_output --noextract ~{sep(",") fastq_files}
    >>>

    # ommitted output - not needed

    runtime{
        docker: "staphb/fastqc:0.12.1"
    }

}