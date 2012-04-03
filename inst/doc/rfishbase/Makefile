all: 

github:
	./knit github
	pandoc -s -S --biblio rfishbase.bib rfishbase.md -o rfishbase_github.md

md:
	pandoc -s -S --biblio rfishbase.bib rfishbase.md -o rfishbase.md

docx:
	./knit docx
	pandoc -s -S --biblio rfishbase.bib rfishbase.md -o rfishbase.docx

tex:
	./knit tex
	pandoc -s -S --biblio rfishbase.bib --template=elsarticle.latex --latex-engine=xelatex rfishbase.md -o rfishbase.tex

odt:
	./knit odt
	pandoc -s -S --biblio rfishbase.bib rfishbase.md -o rfishbase.odt

pdf:
	./knit pdf
	pandoc -s -S --biblio rfishbase.bib rfishbase.md --template=elsarticle.latex --latex-engine=xelatex -o rfishbase.pdf

bib:
	bibtool -s -d -x *.aux ~/Documents/Mendeley/bib/*.bib > rfishbase.bib

epub:
	./knit epub
	pandoc -s -S --biblio rfishbase.bib rfishbase.md -o rfishbase.epub


elsarticle:
	pandoc -s -S --biblio rfishbase.bib rfishbase.md --template=elsarticle.latex --latex-engine=xelatex -o rfishbase.pdf

