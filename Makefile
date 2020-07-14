TEXC=pdflatex
CFLAGS=-interaction=nonstopmode -halt-on-error -file-line-error
BIBC=bibtex
PAPER=paper
BIBLIO=$(PAPER)
EXAMPLES=

all: $(PAPER).pdf

snippets: $(EXAMPLES)
	mkdir -p snippets
	bash mksnippets.sh $(EXAMPLES) snippets

$(PAPER).aux: $(PAPER).tex
	$(TEXC) $(CFLAGS) $(PAPER)

$(BIBLIO).bbl: $(PAPER).aux $(BIBLIO).bib
	$(BIBC) $(PAPER)

$(PAPER).pdf: $(PAPER).aux $(BIBLIO).bbl
	$(TEXC) $(CFLAGS) $(PAPER)
	$(TEXC) $(CFLAGS) $(PAPER)

clean:
	rm -f *.log *.aux *.toc *.out
	rm -f *.bbl *.blg *.fls *.xml
	rm -f *.fdb_latexmk *.vtc *.cut
	rm -f $(PAPER).pdf
	rm -rf snippets
	rm -f *.o *.cmx *.cmo *~
