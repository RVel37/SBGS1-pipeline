version 1.0

task check_index {
    input{
        String ref_genome
    }

    command <<< 
        # check whether ref_genome.fa.* files exist (i.e. genome is indexed)

        if [ "$(ls ~{ref_genome}/*.fa.* 2>/dev/null | wc -l)" -gt 0 ]; then
            echo "true" > is_indexed.txt
        else 
            echo "false" > is_indexed.txt
        fi
    >>>

    output {
        Boolean is_indexed = read_string("is_indexed.txt") == "true"
    }
}


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