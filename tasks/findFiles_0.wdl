version 1.0

task find_files {
    input {
        String runfolder_dir
    }

    command <<<
    mkdir dir_collect
    echo "Fastq files being moved from runfolder to Cromwell executions folder"
    >>>

    output {
        Array[File] found_files = glob("~{runfolder_dir}*.fastq.gz")
    }
}