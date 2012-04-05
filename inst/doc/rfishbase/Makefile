all: 

github:
	./knit github
	pandoc -s -S --biblio rfishbase.bib rfishbase.md -o rfishbase_github.md

md:
	pandoc -s -S --biblio rfishbase.bib rfishbase.md -o rfishbase.md

docx:
	./knit docx
	pandoc -s -S --biblio rfishbase.bib rfishbase.md -o rfishbase.docx


pdf:
	./knit pdf
	pandoc -s -S --biblio rfishbase.bib rfishbase.md --template=elsarticle.latex --latex-engine=xelatex -o rfishbase.pdf

epub:
	./knit epub
	pandoc -s -S --biblio rfishbase.bib rfishbase.md -o rfishbase.epub

bib:
	bibtool -s -d -x citations.aux ~/Documents/Mendeley/bib/*.bib > rfishbase.bib


