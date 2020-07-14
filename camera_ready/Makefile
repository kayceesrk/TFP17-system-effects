TEXC=pdflatex
CFLAGS=-interaction=nonstopmode -halt-on-error -file-line-error
BIBC=bibtex
PAPER=paper
BIBLIO=$(PAPER)
EXAMPLES=

all: dolan_system_effects.tex
	$(TEXC) $(CFLAGS) dolan_system_effects
	$(TEXC) $(CFLAGS) dolan_system_effects

clean:
	rm -f *.log *.aux *.toc *.out
	rm -f *.bbl *.blg *.fls *.xml
	rm -f *.fdb_latexmk *.vtc *.cut
	rm -f $(PAPER).pdf
	rm -rf snippets
	rm -f *.o *.cmx *.cmo *~
