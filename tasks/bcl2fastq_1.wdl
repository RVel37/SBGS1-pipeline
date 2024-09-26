version 1.0

task bcl2fastq {
    input {
        String runfolder_dir
        String output_dir
    }

    command <<<

    mkdir dir_fastq
    mkdir -p ~{output_dir}/fastq_output # permanently store fastqs here
    
    # check runfolder was correctly assigned
    if [ -z "~{runfolder_dir}" ]; then
        echo "runfolder_dir was not assigned, ending task. "
        exit 1
    fi 

    # for this task, docker is run within the command, NOT in runtime (otherwise can't access runfolder - there is no 'directories' input option in WDL 1.0)

    docker pull swglh/bcl2fastq2:2.20
    docker run --rm -v ~{runfolder_dir}:/runfolder/ -v ~{output_dir}/fastq_output:/outputs swglh/bcl2fastq2:2.20 bash -c "
        cd runfolder
        bcl2fastq --runfolder-dir . --output-dir /outputs --sample-sheet SampleSheet.csv
    "
    >>>

    output {
        Array[File] fastq_files = glob("~{output_dir}/*fastq.gz")
    }
}