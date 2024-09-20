version 1.0

task bcl2fastq {

### INPUTS -- paths to relevant directories
    input {
        String runfolder_dir # $(pwd)/resources/240719_M00132_0419_000000000-GM5FH_COPY/
        String output_dir # $(pwd)/resources/outputs/
    }

    command <<<
        # create dir for FASTQs if nonexistent
        mkdir -p ~{output_dir}/fastq_output

        # pull bcl2fastq docker image
        docker pull swglh/bcl2fastq2:2.20

        # run docker image. -c "..." allows multiple commands to be run
        docker run --rm \
            -v ~{runfolder_dir}:/resources/240719_M00132_0419_000000000-GM5FH_COPY \
            -v ~{output_dir}:/outputs \
            swglh/bcl2fastq2:2.20 bash -c "
        cd resources/240719_M00132_0419_000000000-GM5FH_COPY
        
        bcl2fastq --runfolder-dir . --output-dir /outputs/fastq_output --sample-sheet SampleSheet.csv 
        "    
    >>>

    output {
        # glob = collect files 
        Array[File] fastq_files = glob(output_dir + "/fastq_output/*.fastq.gz")
    }
}