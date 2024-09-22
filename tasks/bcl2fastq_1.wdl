version 1.0

task bcl2fastq {

### INPUTS -- paths to relevant directories
    input {
        String runfolder_dir 
        String output_dir 
    }

    command <<<
        # create dir for FASTQs if nonexistent
        mkdir -p ~{output_dir}fastq_output
        
        bcl2fastq --runfolder-dir ~{runfolder_dir} --output-dir ~{output_dir}fastq_output --sample-sheet ~{runfolder_dir}SampleSheet.csv 
    >>>

    output {
        # glob = collect files (THESE ARE GZIPPED)
        Array[File] fastq_files = glob("~{output_dir}fastq_output/*.fastq.gz")
    }

    runtime {
        docker: "swglh/bcl2fastq2:2.20"
    }
}