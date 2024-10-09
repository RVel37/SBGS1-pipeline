version 1.0

task concat_sams {
    input {
        String aligned
    }
    command <<<
        mkdir sam_dir # cant leave empty but not really necessary
    >>>
    output {
        Array[File] sam_files = glob("~{aligned}/*")
    }
}
