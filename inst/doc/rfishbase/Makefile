all: 

odt:
	pandoc -s -S --biblio rfishbase.bib rfishbase.md -o rfishbase.odt

pdf:
	./knit pdf
	pandoc -s -S --biblio rfishbase.bib rfishbase.md --template=default.latex --latex-engine=xelatex -o rfishbase.pdf

bibtool:
	bibtool -s -d -x *.aux ~/Documents/Mendeley/bib/*.bib > rfishbase.bib

