# Benchmarking with http/af

## Setting up http/af + effects

    opam remote add multicore https://github.com/ocamllabs/multicore-opam.git
    opam switch 4.02.2+multicore
    opam pin add -k git -n aeio https://github.com/kayceesrk/ocaml-aeio
    opam pin add -k git -n angstrom https://github.com/inhabitedtype/angstrom#z
    opam pin add -k git -n faraday https://github.com/inhabitedtype/faraday
    opam install conf-libev lwt.2.5.1 aeio angstrom faraday
    git clone https://github.com/kayceesrk/httpaf -b effects
    cd httpaf
    make

## Setting up Go benchmark

The Go webserver is in file `code/httpserv.go`. To compile it, `go build
httserv`.

## Setting up http/af + async

    opam switch 4.03.0
    opam pin add -k git -n angstrom https://github.com/inhabitedtype/angstrom#z
    opam pin add -k git -n faraday https://github.com/inhabitedtype/faraday
    opam install conf-libev async angstrom faraday
    git clone https://github.com/kayceesrk/httpaf httpaf-async
    cd httpaf-async
    oasis setup
    ./configure --enable-async
    make

## Running the benchmark

Get wrk2 from https://github.com/giltene/wrk2, build it. Start the web server:

    ./wrk_effects_benchmark.native

Start the workload generator:

    ./wrk -d30 -c1k -R10k -t2 -L http://127.0.0.1:8080

## Producing the graphs

The `*.dat` filenames are self-explanatory. To generate the graphs, run
    
    python ./hdr_histogram_1.py
    python ./hdr_histogram_2.py
