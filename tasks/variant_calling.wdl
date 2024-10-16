version 1.0

task octopus_caller {
    input {
        File bam_file
        File bai_file
        File ref_genome_fa 
        Array[File] ref_indexed
    }

    command <<<

    mkdir vc_output; mkdir GRCh38
    mv ~{sep=' ' ref_indexed} GRCh38

    octopus \
    --reference GRCh38/~{basename(ref_genome_fa)} \
    --reads ~{bam_file} \
    --output vc_output/${basename(bam_file, '.bam')}.vcf

    >>>

    output {
        File vcf_file = "vc_output/${basename(bam_file, '.bam')}.vcf"
    }

    runtime {
        docker: "dancooke/octopus:invitae--eae1ab48_0"
    }
}
