version 1.0

task index_ref {

    input {
        String ref_genome
    }

    command <<<

    docker pull biocontainers/bwa:v0.7.17_cv1

    docker run --rm \
    -v ~{ref_genome}:/ref_genome \
    biocontainers/bwa:v0.7.17_cv1 bash -c "
        bwa index /ref_genome/GRCh38_masked_v2_decoy_excludes_GPRIN2_DUSP22_FANCD2.fa
    "
    >>>

    # can't use "runtime" here due to limitations with mounting directories
}