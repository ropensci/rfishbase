all:

test: 
	r -e "library('devtools'); install(); build_vignettes(); test();"
	r -e "covr::coveralls()"
