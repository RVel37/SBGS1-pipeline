## Variant calling pipeline in WDL
This pipeline was written as a training component for the diagnostic sequencing module of the bioinformatics NHS STP. It runs on [WDL 1.0](https://github.com/openwdl/wdl/blob/main/versions/1.0/SPEC.md) and [Cromwell 87](https://github.com/broadinstitute/cromwell/releases). 

Our pipeline takes a directory of paired-end FASTQ files as inputs and outputs annotated VCF files as well as intermediates. 

### Usage
Pull all docker dependencies locally: `docker-compose up`

Run pipeline: `java -jar /path/to/cromwell-xy.jar run wf.wdl -i inputs.json -o options.json`

### Inputs and outputs
Outputs can be set to a permanent directory using `options.json`. Alternatively, ommitting `-o options.json` sends outputs to the cromwell executions directory. 

The paths in `inputs.json` should be set to the right directories. 

Required inputs include;
- Directory of FASTQ files
- Indexed GRCh38 reference files
- Base VEP cache (https://ftp.ensembl.org/pub/release-112/variation/indexed_vep_cache/homo_sapiens_merged_vep_112_GRCh38.tar.gz)
- Revel cache data (tsv) and index file (tbi)
- Adapter sequence fasta

### Note on FASTQ file names
FASTQs were created using Bcl2Fastq and follow a specific naming convention. 
FASTQ file names must end in `_R1_001.fastq.gz` and `_R2_001.fastq.gz` for the pipeline to execute correctly. 

### Bcl2Fastq
The branch `Bcl2Fastq` contains this additional step for those starting from BCL files. It is designed to work with the BCL file directory structure produced by Illumina sequencing systems. 
