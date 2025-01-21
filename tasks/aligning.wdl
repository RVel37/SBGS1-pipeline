version 1.0

########### MAKE REF GENOME DIR ##############

task concat_refs {

    input {
        String ref_genome
    }


    command <<< 

    mkdir refs 
    # copy all reference genome files, with their various extensions
    cp ~{ref_genome}/* refs

    >>>

    output {
        # array of all the reference genome files
        Array[File] ref_indexed = glob("~{ref_genome}/*")
    }
}

############### MAKE SAMS ####################

task generate_sam {

    input {
        Array[File] ref_indexed
        Array[File] trimmed_fastq_files
        File ref_genome_fa
    }

    command <<<

        mkdir aligned; mkdir GRCh38

        # move to same dir
        mv ~{sep=' ' ref_indexed} GRCh38


        # run bwa mem (requires indexed genome)
        ## note: only works for this fastq naming convention

        # run for read 1 (R1) in every read pair
        for R1 in ~{sep=" " trimmed_fastq_files}; do
            
            # Extract 5th field from basename of read 1, using '_' as the delimiter
            CHECKREAD=$(basename $R1 | cut -d '_' -f5)
            # check if extracted field is R1
            if [ $CHECKREAD = "R1" ] ; then
                # Replace '_R1_001_paired.fastq.gz' with '_R2_001_paired.fastq.gz' to get corresponding R2
                R2=${R1/_R1_001_paired.fastq.gz/_R2_001_paired.fastq.gz} 
                # Extract first 4 fields from basename of R1, using '_' as the delimiter
                BASE=$(basename $R1 | cut -d'_' -f1-4)         
                # Set output SAM file path
                OUTPUT_SAM = aligned/${BASE}.sam

                # run bwa mem 
                bwa-mem2 mem -R "@RG\tID:${BASE}\tSM:${BASE}\tPL:ILLUMINA" GRCh38/~{basename(ref_genome_fa)} $R1 $R2 > $OUTPUT_SAM 
            fi
        done
    >>>

    output {
        Array[File] sam_files = glob("aligned/*[!gz].sam")
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

