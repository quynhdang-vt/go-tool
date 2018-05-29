package main

import (
        "fmt"
        "runtime"
)

func main() {
        fmt.Printf("Number of GOMAXPROCS=%v\n", runtime.GOMAXPROCS(0))
        fmt.Printf("Number of runtime.NumCPU=%v\n", runtime.NumCPU())
}
