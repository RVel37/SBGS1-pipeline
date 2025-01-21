version 1.0

task octopus_caller {
    input {
        File bam_file
        File bai_file
        File ref_genome_fa 
        Array[File] ref_indexed
        Int random_number
    }

    command <<<
    mkdir -p runnumber_~{random_number}
    mkdir runnumber_~{random_number}/vcf_output
    mkdir GRCh38
    mv ~{sep=' ' ref_indexed} GRCh38
    
    # basename for output vcf
    BASE=$(basename ~{bam_file} .bam).vcf
    
    # run octopus
    octopus \
    --reference GRCh38/~{basename(ref_genome_fa)} \         # reference genome
    --reads ~{bam_file} \                                   # input bam
    --output runnumber_~{random_number}/vcf_output/$BASE    # store output 

    >>>

    output {
        File vcf_file = "runnumber_~{random_number}/vcf_output/~{basename(bam_file, '.bam')}.vcf"
    }

    runtime {
        docker: "dancooke/octopus:invitae--eae1ab48_0"
    }
}
