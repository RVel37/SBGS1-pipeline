version 1.0

task bcl2fastq {

### INPUTS -- paths to relevant directories
    input {
        String runfolder_dir 
        String output_dir 
    }

    command <<<
        # create dir for FASTQs if nonexistent
        mkdir -p ~{output_dir}/fastq_output

        cd ~{runfolder_dir}
        
        bcl2fastq --runfolder-dir . --output-dir /outputs/fastq_output --sample-sheet SampleSheet.csv  
    >>>

    output {
        # glob = collect files 
        Array[File] fastq_files = glob("{output_dir}/fastq_output/*.fastq.gz")
    }

    runtime {
        docker: "swglh/bcl2fastq2:2.20"
    }
}