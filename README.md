## Variant calling pipeline in WDL
This pipeline was written as a training component for the diagnostic sequencing module of the bioinformatics NHS STP. 

Our pipeline takes a directory of paired-end FASTQ files as inputs and outputs annotated VCF files as well as intermediates. 

### Usage
To install all docker dependencies locally: `docker-compose up`
To run pipeline: `java -jar /path/to/cromwell-xy.jar run wf.wdl -i inputs.json -o options.json`

### Inputs and outputs
Outputs can be set to a permanent directory using `options.json`. 
When working with this pipeline, the paths in `inputs.json` should be set to the right directories. 

### Note on FASTQ file names
FASTQs were created using Bcl2Fastq and follow a specific naming convention. 
FASTQ file names must end in `_R1_001.fastq.gz` and `_R2_001.fastq.gz` for the pipeline to execute correctly. 

### Bcl2Fastq
The branch `Bcl2Fastq` contains this additional step for those starting from BCL files. It is designed to work with the BCL file directory structure produced by Illumina sequencing systems. 