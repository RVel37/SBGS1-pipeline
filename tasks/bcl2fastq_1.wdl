version 1.0

task bcl2fastq {

    input {
        Array[File] bcl_files
        String output_dir
    }

    command <<<

        mkdir dir_fastq; 
        
        # copy the "found" fastq files to new directory
        for i in ~{sep=" " bcl_files}; do 
            cp $i dir_fastq/
        done
        
        >>>

    ### ACTUAL BCL command ###
    # bcl2fastq --runfolder-dir ~{runfolder_dir} --output-dir ~{output_dir}fastq_output --sample-sheet ~{runfolder_dir}SampleSheet.csv 
    # >>>

    output {
        # collect the gzipped FASTQ files
        Array[File] fastq_files = glob("dir_fastq/*.fastq.gz")
    }

    runtime {
        docker: "swglh/bcl2fastq2:2.20"
    }
}