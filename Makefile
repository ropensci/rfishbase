all:

test: 
	r -e "devtools::check();"
	r -e "covr::coveralls()"
