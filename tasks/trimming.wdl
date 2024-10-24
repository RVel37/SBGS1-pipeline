version 1.0

task trim_fastqs_task {
    input {
        Array[File] fastq_files
        File adapter_file
    }

    command <<<
        # Create directories for the trimmed files
        mkdir -p trimmed_fastqs

        # Loop through paired-end FASTQ files and run Trimmomatic
        for R1 in ~{sep=" " fastq_files}; do

            CHECKREAD=$(basename $R1 | cut -d'_' -f5)
            if [ $CHECKREAD = "R1" ] ; then
                R2=${R1/_R1_001.fastq.gz/_R2_001.fastq.gz}    
                BASE=$(basename $R1 | cut -d'_' -f1-4)
            
                # Define output file names for trimmed paired and unpaired reads
                PAIRED_R1_OUT=trimmed_fastqs/${BASE}_R1_001_paired.fastq.gz
                UNPAIRED_R1_OUT=trimmed_fastqs/${BASE}_R1_001_unpaired.fastq.gz
                PAIRED_R2_OUT=trimmed_fastqs/${BASE}_R2_001_paired.fastq.gz
                UNPAIRED_R2_OUT=trimmed_fastqs/${BASE}_R2_001_unpaired.fastq.gz

                # Run Trimmomatic for paired-end trimming
                TrimmomaticPE \
                    -phred33 \
                    $R1 $R2 \
                    $PAIRED_R1_OUT $UNPAIRED_R1_OUT \
                    $PAIRED_R2_OUT $UNPAIRED_R2_OUT \
                    ILLUMINACLIP:~{adapter_file}:2:30:10 \
                    LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
            fi
        done
    >>>

    output {
        # Output only the paired trimmed files
        Array[File] paired_trimmed_files = glob("trimmed_fastqs/*_paired.fastq.gz")
    }

    runtime {
        docker: "biocontainers/trimmomatic:v0.38dfsg-1-deb_cv1"
    }
}
