version 1.0

import "tasks/bcl2fastq_1.wdl" as bcl2fastqTask
import "tasks/fastqc_2.wdl" as fastqcTask
import "tasks/indexing_3.wdl" as indexingTask

workflow main {
    input {
        String resources_dir
        String runfolder_dir
        String output_dir
        String ref_genome
    }

    call bcl2fastqTask.bcl2fastq {
        input:
            runfolder_dir = runfolder_dir, #pass workflow input to the task
            output_dir = output_dir
    }

    call fastqcTask.fastqc {
        input:
            fastq_files = bcl2fastqTask.bcl2fastq.fastq_files,
            output_dir = output_dir
    }

    call indexingTask.generate_sam {
        input:
            resources_dir = resources_dir,
            output_dir = output_dir,
            ref_genome = ref_genome
    }

    call indexingTask.generate_bam {
        input:
            sam_files = indexingTask.generate_sam.sam_files, 
            output_dir = output_dir
    }
}
