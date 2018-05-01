This is useful to run automated tests on models (e.g. in CI).

It can:

1. Run TLC models.
2. Check TLAPS proofs.
3. Generate PDFs.

Example `Makefile`:


```
WORKERS := 4

.PHONY: all check tlaps pdfs

all: check pdf

check:
       docker run --rm -it --workdir /mnt -v ${PWD}:/mnt talex5/tla tlc -workers ${WORKERS} Spec.tla

tlaps:
       docker run --rm -it --workdir /mnt -v ${PWD}:/mnt talex5/tla tlapm -I /usr/local/lib/tlaps Spec.tla

%.pdf: %.tla
       [ -d metadir ] || mkdir metadir
       docker run --rm -it --workdir /mnt -v ${PWD}:/mnt talex5/tla java tla2tex.TLA -shade -latexCommand pdflatex -latexOutputExt pdf -metadir metadir $<

pdfs: Spec.pdf
```

The `tlc` command runs `java tlc2.TLC` and then greps the results for the string `Model checking completed. No error has been found.`,
returning a non-zero exit status if it is not found.

The installation is probably not quite right. I tried to follow the instructions
at https://tla.msr-inria.inria.fr/tlaps/content/Download/Source.html and fix up any problems as they turned up.
