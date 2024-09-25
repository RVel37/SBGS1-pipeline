version 1.0

task find_files {
    input {
        String resources_dir
        String output_dir
    }

    command <<<

    mkdir dir_fastq
    
    # check resources_dir was correctly assigned
    if [ -z "~{resources_dir}" ]; then
        echo "resources_dir was not assigned, ending task. "
        exit 1
    fi 

    # for this task, run docker INSIDE the command, NOT in runtime (otherwise can't access runfolder - there is no 'directories' input option in WDL 1.0)

    docker pull swglh/bcl2fastq2:2.20
    docker run --rm -v ~{resources_dir}:/resources/ -v ~{output_dir/fastq_output}:/outputs swglh/bcl2fastq2:2.20 bash -c "
    cd resources

    bcl2fastq --runfolder-dir . --output-dir /outputs --sample-sheet SampleSheet.csv
    "
    >>>

    output {
        Array[File] fastq_files = glob("~{output_dir}/*fastq.gz")
    }

}