version 1.0

task VEP_annotation {
    input {
        File vcf
        File vep_cache
    }

    command <<<
    
    mkdir annotation # Ouput DIR for annotated VCF's
    mkdir /opt/vep/src/ensembl-vep/cache_out #Output dir for Tar'd VEP cache

    BASE_VCF=$(basename ~{vcf} _sorted.vcf)_annotated.vcf # Var for naming output


    tar -zxvf ~{vep_cache} -C /opt/vep/src/ensembl-vep/cache_out/ #Tar vep cache - output files to cache_out 
   
   
    vep -i ~{vcf} -o annotation/$BASE_VCF --dir_cache /opt/vep/src/ensembl-vep/cache_out --cache --offline
    
    >>>

    output {
        File annotation_output = "annotation/~{basename(vcf, '_sorted.vcf')}_annotated.vcf" # Files should be name <sanmpleName>_<sampleNumber>_<LaneNumber>_annotated.vcf
    }

    runtime {
        docker: "ensemblorg/ensembl-vep:release_112.0"
        }

}
