.PHONY: all build test clean repl fmt deps

all: build doc

build:
	dune build

test:
	dune runtest --no-buffer -j 1

doc:
	dune build @doc

clean:
	dune clean

repl: all
	dune utop

fmt:
	dune build @fmt --auto-promote

deps:
	dune external-lib-deps --missing @@default

install: all
	dune install
