version 1.0

task mark_duplicates {
    input {
        File bam_file
    }

    command <<<
        mkdir marked_duplicates
        mkdir metrics

        BASE=$(basename ~{bam_file} .bam) # extract base name of bam file
        OUTPUT_BAM=marked_duplicates/${BASE}_dedup.bam # output bam file for deduplicated data
        METRICS_FILE=metrics/${BASE}_dedup_metrics.txt # metrics file for duplication info
        
        # Mark duplicates using Picard
        java -jar /usr/picard/picard.jar MarkDuplicates \
            I=~{bam_file} \ # input bam
            O=$OUTPUT_BAM \ # output deduplicated file
            M=$METRICS_FILE \ # metrics file path
            REMOVE_DUPLICATES=false \ # keep duplicates
            CREATE_INDEX=true 
    >>>

    output {
        # deduplicated bam
        File dedup_bam = "marked_duplicates/${basename(bam_file, '.bam')}_dedup.bam"
        # corresponding index file 
        File dedup_bai = "marked_duplicates/${basename(bam_file, '.bam')}_dedup.bai"
        # pair these
        Pair[File, File] dedup_bam_bai_pair = (dedup_bam, dedup_bai) # concat pairs
        # collect metrics files
        Array[File] duplication_metrics = glob("metrics/*")
    }

    runtime {
        docker: "broadinstitute/picard:latest"
    }
}
