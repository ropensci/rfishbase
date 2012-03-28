all: 

odt:
	pandoc -s -S --biblio rfishbase.bib rfishbase.md -o rfishbase.odt

pdf:
	pandoc -s -S --biblio rfishbase.bib rfishbase.md -o rfishbase.pdf

bibtool:
	bibtool -s -d -x *.aux ~/Documents/Mendeley/bib/*.bib > rfishbase.bib

