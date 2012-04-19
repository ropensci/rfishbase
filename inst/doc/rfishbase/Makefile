all: 

github:
	./knit github
	pandoc -s -S --biblio rfishbase.bib rfishbase.md -o rfishbase_github.md

md:
	pandoc -s -S --biblio rfishbase.bib rfishbase.md -o rfishbase.md

odt:
	./knit docx
	pandoc -s -S --biblio rfishbase.bib rfishbase.md --reference-odt=reference.odt -o rfishbase.odt


docx:
	./knit docx
	pandoc -s -S --biblio rfishbase.bib rfishbase.md --reference-docx=reference.docx -o rfishbase.docx


pdf:
	./knit pdf
	pandoc -s -S --biblio rfishbase.bib rfishbase.md --template=elsarticle.latex --latex-engine=xelatex -o rfishbase.tex
	xelatex rfishbase.tex
	xelatex rfishbase.tex
	xelatex rfishbase.tex

epub:
	./knit epub
	pandoc -s -S --biblio rfishbase.bib rfishbase.md -o rfishbase.epub

bib:
	bibtool -s -d -x citations.aux ~/Documents/Mendeley/bib/*.bib > rfishbase.bib


clean:
	rm -rf *.log *.bbl *.blg *.out *.spl
