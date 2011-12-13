## Makefile to use knitr in the vignette
RSCRIPT = Rscript

all: rfishbase.pdf

rfishbase.pdf: rfishbase/rfishbase.Rnw
	cp -f rfishbase/rfishbase.Rnw .
	$(RSCRIPT) --vanilla -e "require(knitr); knit( 'rfishbase.Rnw');"
	#Compile in latex, but keep aux file till we make bibliography
	$(RSCRIPT) -e "tools::texi2dvi( 'rfishbase.tex', pdf = TRUE, clean = FALSE )" 
	bibtex rfishbase # make the bibliography 
	$(RSCRIPT) -e "tools::texi2dvi( 'rfishbase.tex', pdf = TRUE, clean = TRUE )" # compile and cleanup
#	cp rfishbase/rfishbase-fake.Rnw rfishbase.Rnw

pdfclean:
	rm -f *.pdf

clean:
	rm -f index.html
	rm -f *.tex *.bbl *.blg *.aux *.out *.log *.spl


