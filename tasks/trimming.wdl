version 1.0

task trim_fastqs_task {
    input {
        File forward_read
        File reverse_read
        File adapter_file
    }

    command <<<
        # Create directories for the trimmed files
        mkdir -p trimmed_fastqs

        # Loop through paired-end FASTQ files and run Trimmomatic
           
        BASE=$(basename ~{forward_read} _R1_001.fastq.gz)
            
        # Define output file names for trimmed paired and unpaired reads
        PAIRED_R1_OUT=trimmed_fastqs/${BASE}_R1_001_paired.fastq.gz
        UNPAIRED_R1_OUT=trimmed_fastqs/${BASE}_R1_001_unpaired.fastq.gz
        PAIRED_R2_OUT=trimmed_fastqs/${BASE}_R2_001_paired.fastq.gz
        UNPAIRED_R2_OUT=trimmed_fastqs/${BASE}_R2_001_unpaired.fastq.gz

        # Run Trimmomatic for paired-end trimming
        TrimmomaticPE \
            -phred33 \
            ~{forward_read} ~{reverse_read} \
            $PAIRED_R1_OUT $UNPAIRED_R1_OUT \
            $PAIRED_R2_OUT $UNPAIRED_R2_OUT \
            ILLUMINACLIP:~{adapter_file}:2:30:10 \
            LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

    >>>

    output {
        # Output only the paired trimmed files
        Array[File] paired_trimmed_files = glob("trimmed_fastqs/*_paired.fastq.gz")
        Array[File] forward_trimmed = glob("trimmed_fastqs/*R1_001_paired.fastq.gz")
        Array[File] reverse_trimmed = glob("trimmed_fastqs/*R2_001_paired.fastq.gz")
    }

    runtime {
        docker: "biocontainers/trimmomatic:v0.38dfsg-1-deb_cv1"
    }
}
