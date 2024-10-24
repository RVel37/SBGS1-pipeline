version 1.0

########### MAKE REF GENOME DIR ##############

task concat_refs {
    input {
        String ref_genome
    }
    command <<< 

    mkdir refs 
    cp ~{ref_genome}/* refs

    >>>

    output {
        Array[File] ref_indexed = glob("~{ref_genome}/*")
    }
}


############### MAKE SAMS ####################

task generate_sam {
    input {
        Array[File] ref_indexed
        File forward_read
        File reverse_read
        File ref_genome_fa
    }

    command <<<

        mkdir aligned GRCh38

        # move reference files to temp dir
        mv ~{sep=' ' ref_indexed} GRCh38

        # define naming convention for SAM files
        BASE=$(basename ~{forward_read} _R1_001.fastq.gz)

        # define output SAM file
        OUTPUT_SAM=aligned/${BASE}.sam
        echo "Output SAM: $OUTPUT_SAM"

        # run bwa mem 2 using original FASTQ paths
        bwa-mem2 mem -R "@RG\tID:${BASE}\tSM:${BASE}\tPL:ILLUMINA" GRCh38/~{basename(ref_genome_fa)} ~{forward_read} ~{reverse_read} > $OUTPUT_SAM 

    >>>

    output {
        Array[File] sam_files = glob("aligned/*.sam")
    }

    runtime {
        docker: "swglh/bwamem2:v2.2.1"
    }
}



############### MAKE BAMS ####################

task generate_bam {

    input {
        File sam_file
    }

    command <<<

        mkdir bam_aligned

        BASE=$(basename ~{sam_file} .sam)
        OUTPUT_BAM=bam_aligned/${BASE}_sorted.bam
        samtools view -bS ~{sam_file} | samtools sort -o $OUTPUT_BAM # create sorted BAM
        samtools index $OUTPUT_BAM # create corresponding BAI (index file)
    >>>

    output {
        File bam_file = "bam_aligned/${basename(sam_file, '.sam')}_sorted.bam"
        File bai_file = "bam_aligned/${basename(sam_file, '.sam')}_sorted.bam.bai"
        Pair[File, File] bam_bai_pair = (bam_file, bai_file) # concat pairs
    }

    runtime {
        docker: "swglh/samtools:1.18"
    }
}
