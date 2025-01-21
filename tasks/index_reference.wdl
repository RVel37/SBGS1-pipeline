version 1.0

task check_index {
    input{
        String ref_genome
    }

    command <<< 
        # check whether ref_genome.fa.* files exist (i.e. genome is indexed)
        if [ "$(ls ~{ref_genome}/*.fa.* 2>/dev/null | wc -l)" -gt 0 ]; then

            echo "true" > is_indexed.txt # write 'true' to text file is_indexed.txt
        else 
            echo "false" > is_indexed.txt # otherwise write 'false'
        fi
    >>>

    output {
        # see whether the text within 'is_indexed.txt' reads true or false
        Boolean is_indexed = read_string("is_indexed.txt") == "true"
    }
}


task index_ref {

    input {
        String ref_genome
    }

    command <<<
        # must pull the docker image within bash command for this task -
        # can't use "runtime" as usual due to limitations with mounting directories

        docker pull biocontainers/bwa:v0.7.17_cv1

        docker run --rm \ # remove docker container after task completion
        -v ~{ref_genome}:/ref_genome \ # mount reference genome directory

        # run bwa index on our ref genome
        biocontainers/bwa:v0.7.17_cv1 bash -c "
            bwa index /ref_genome/GRCh38_masked_v2_decoy_excludes_GPRIN2_DUSP22_FANCD2.fa
        "
    >>>

}
