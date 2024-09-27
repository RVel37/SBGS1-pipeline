version 1.0

task octopus_caller {
    input {
        File bam_file
        File ref_genome_fa
    }

    command <<<

    mkdir vc_output

    octopus \
    --reference ~{ref_genome_fa} \
    --reads ~{bam_file} \
    --output vc_output/output.vcf

    >>>

    output {
        File vcf = "vc_output/output.vcf"
    }

    runtime {
        docker: dancooke/octopus:invitae--eae1ab48_0
    }
}