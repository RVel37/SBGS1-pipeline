version 1.0

task generate_sam {

### INPUTS
    input {
        String resources_dir
        String output_dir
        String ref_genome
    }

    command <<<

        mkdir -p ~{output_dir}/aligned

        # run bwa mem -- MAKE SURE GENOME IS INDEXED!
        for R1 in ~{output_dir}/fastq_output/*_R1_001.fastq.gz; do
            R2=${R1/_R1_001.fastq.gz/_R2_001.fastq.gz}
            BASE=$(basename $R1 _R1_001.fastq.gz) 
            OUTPUT_SAM=~{output_dir}/aligned/${BASE}.sam 
            echo "Aligning $BASE..." 
            bwa mem ~{ref_genome} $R1 $R2 > $OUTPUT_SAM 
        done
    >>>
    
    output {
        Array[File] sam_files = glob("~{output_dir}/aligned/*.sam")
    }

    runtime {
        docker: "quay.io/biocontainers/bwa:v0.7.17_cv1"
    }
}

task generate_bam {
    input {
        Array [File] sam_files
        String output_dir
    }

    command <<<
        for SAM in ~{sam_files}; do 
            BASE=$(basename $SAM .sam) 
            OUTPUT_BAM=~{output_dir}/${BASE}_sorted.bam 
            echo "Processing $BASE..." 
            samtools view -bS $SAM | samtools sort -o $OUTPUT_BAM
            samtools index $OUTPUT_BAM 
        done
    >>>

    output {
        Array[File] bam_files = glob("~{output_dir}/aligned/*_sorted.bam")
    }

    runtime {
        docker: "quay.io/biocontainers/samtools:1.10"
    }
}