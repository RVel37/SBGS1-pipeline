version 1.0

import "tasks/bcl2fastq_1.wdl" as bcl2fastqTask
import "tasks/fastqc_2.wdl" as fastqcTask
import "tasks/aligning_3.wdl" as alignmentTask

workflow main {
    input {
        String resources_dir
        String runfolder_dir
        String output_dir
        String ref_genome
    }

    call bcl2fastqTask.bcl2fastq {
        input {
            runfolder_dir = runfolder_dir, 
            output_dir = output_dir
        }
        output {
            Array[File] fastq_files
        }  
    }


    call fastqcTask.fastqc {
        input:
            fastq_files = bcl2fastqTask.bcl2fastq.fastq_files,
            output_dir = output_dir
    }
        output: {
            Array[File] fastq_files
        }

    call alignmentTask.generate_sam {
        input:
            resources_dir = resources_dir,
            output_dir = output_dir,
            ref_genome = ref_genome
    }

    call alignmentTask.generate_bam {
        input:
            sam_files = alignmentTask.generate_sam.sam_files, 
            output_dir = output_dir
    }
}
