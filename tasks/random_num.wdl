version 1.0

task generate_random_number {
    command <<<
        # Using $RANDOM in bash to generate a random number
        echo $((RANDOM))
    >>>
    
    output {
        Int random_number = read_int(stdout())
    }
}
