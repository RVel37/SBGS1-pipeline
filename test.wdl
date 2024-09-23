task hello_world {
    String name 
    File test_file

    command <<<
    echo 'Hello, ${name}'
    cat ${test_file} 
    >>>
    
    output {
        File out = stdout()
    }
    runtime {
        docker: 'ubuntu:latest'
    }
}

workflow hello {
    String name  
    File test_file

    call hello_world {

        input: 
        name = name,
        test_file = test_file
    }
}