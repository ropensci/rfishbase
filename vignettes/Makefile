
# Copy the markdown version as the README
# This README is for automated use by R package manager only.  
../README.md: README.Rmd
	$(R_HOME)/bin/Rscript -e 'library(methods); rmarkdown::render("README.Rmd", "md_document")'
	mv README.md ../README.md

