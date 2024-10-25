version 1.0

task VEP_annotation {
    input {
        File vcf
        File vep_cache
        File REVEL_tsv
        File REVEL_tbi
    }

    command <<<
    
    mkdir annotation # Ouput DIR for annotated VCF's
    mkdir /opt/vep/src/ensembl-vep/cache_out #Output dir for Tar'd VEP cache & plugin files 
    
    mv ~{REVEL_tbi} ~{REVEL_tsv} /opt/vep/src/ensembl-vep/cache_out/ # Move REVEL cache files into within docker cache location 

    
    
    BASE_VCF=$(basename ~{vcf} _sorted_dedup.vcf)_annotated.vcf # Set naming convention for file output


    tar -xf ~{vep_cache} -C /opt/vep/src/ensembl-vep/cache_out/ #Tar vep cache - output files to cache_out 
   
    vep \
    -i ~{vcf} \
    -o annotation/$BASE_VCF \
    --dir_cache /opt/vep/src/ensembl-vep/cache_out \
    --assembly GRCh38 \
    --cache \
    --offline \
    --plugin REVEL,file=/opt/vep/src/ensembl-vep/cache_out/new_tabbed_revel_grch38.tsv.gz \
    --pick \
    --af_gnomade
    

    >>>

    output {
        File annotation_output = "annotation/~{basename(vcf, '_sorted_dedup.vcf')}_annotated.vcf" # Files should be name <sanmpleName>_<sampleNumber>_<LaneNumber>_annotated.vcf
    }

    runtime {
        docker: "ensemblorg/ensembl-vep:release_112.0"
        }

}
