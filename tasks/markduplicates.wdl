version 1.0

task mark_duplicates {
    input {
        File bam_file
    }

    command <<<
        mkdir marked_duplicates
        mkdir METRICS_DIR

        BASE=$(basename ~{bam_file} .bam)
        OUTPUT_BAM=marked_duplicates/${BASE}_dedup.bam
        METRICS_FILE=METRICS_DIR/${BASE}_dedup_metrics.txt
        
        # Mark duplicates using Picard
        java -jar /usr/picard/picard.jar MarkDuplicates \
            I=~{bam_file} \
            O=$OUTPUT_BAM \
            M=$METRICS_FILE \
            REMOVE_DUPLICATES=false \
            CREATE_INDEX=true
    >>>

    output {
        File dedup_bam = "marked_duplicates/${basename(bam_file, '.bam')}_dedup.bam"
        File dedup_bai = "marked_duplicates/${basename(bam_file, '.bam')}_dedup.bai"
        Pair[File, File] dedup_bam_bai_pair = (dedup_bam, dedup_bai) # concat pairs
        Array[File] duplication_metrics = glob("METRICS_DIR/*")
    }

    runtime {
        docker: "broadinstitute/picard:latest"
    }
}
