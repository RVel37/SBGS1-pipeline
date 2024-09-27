version 1.0

task vep_annotation {
    input {
        File vcf_file
        File ref_genome_fa
    }

    command <<<

    mkdir annot

    vep --json --no_stats \
    -i ~{vcf_file} \
    -o annot/output.json \
    --assembly GRCh38 \
    --fasta ~{ref_genome_fa} \
    --cache


    >>>

    output {
        File annotated = "annot/output.json"
    }
    runtime {
        docker: "ensembl-vep:release_88.14"
    }
}