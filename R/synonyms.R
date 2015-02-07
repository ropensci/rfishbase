

## Note: Any synonym must be resolved manually, since there may be many synonyms. 

# synonyms("Labroides bicolour")
# synonyms("Labroides dimidatus")
# http://www.fishbase.org/manual/english/fishbasethe_synonyms_table.htm
synonyms <- function(species, verbose = TRUE, limit = 50, server = SERVER){
  s <- parse_name(species)
  resp <- GET(paste0(server, "/synonyms"), 
              query = list(SynSpecies = s$species, 
                           SynGenus = s$genus, 
                           limit = limit))
  check_and_parse(resp, verbose = verbose)
}


## Synonyms have SpecCodes.. do they inhabit the taxa table?
#  resp <- GET(paste0(server, "/synonyms"), query = list(valid = '0', limit = 90000))
#  syns <- check_and_parse(resp, verbose = verbose)
#  resp <- GET(paste0(server, "/synonyms"), query = list(valid = '-1', limit = 90000))
#  valids <- check_and_parse(resp, verbose = verbose)
