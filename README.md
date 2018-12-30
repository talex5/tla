This is useful to run automated tests on models (e.g. in CI).

It can:

1. Run TLC models.
2. Check TLAPS proofs.
3. Generate PDFs.

Example `Makefile`:


```
WORKERS := 4

TLA := docker run --rm -it --workdir /mnt -v ${PWD}:/mnt talex5/tla

.PHONY: all check tlaps pdfs

all: check tlaps pdf

check:
       ${TLA} tlc -workers ${WORKERS} Spec.tla

tlaps:
       ${TLA} tlapm -I /usr/local/lib/tlaps Spec.tla

%.pdf: %.tla
       [ -d metadir ] || mkdir metadir
       ${TLA} java tla2tex.TLA -shade -latexCommand pdflatex -latexOutputExt pdf -metadir metadir $<

pdfs: Spec.pdf
```

The `tlc` command runs `java tlc2.TLC` and then greps the results for the string `Model checking completed. No error has been found.`,
returning a non-zero exit status if it is not found.

I tried to follow the instructions
at https://tla.msr-inria.inria.fr/tlaps/content/Download/Source.html and fix up any problems as they turned up.

To use this with the toolbox for interactive proof checking, I put this file in my PATH:

```bash
#!/bin/bash
docker run --rm -i -v ${PWD}:${PWD} --entrypoint tlapm talex5/tla "$@"
```
