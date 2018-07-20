library(fs)
library(purrr)
library(readr)

## 
count <-
  dir_ls("inst/extdata/", glob="*.csv") %>% 
  map_int(function(x){
    length(read_csv(x))
  })

docs <- 
  names(which(count == 5))  %>%
  map_dfr(read_csv, col_types="ccccc")
#############


### basically same thing, but frm the API
old_docs <- jsonlite::read_json("https://fishbase.ropensci.org/docs/") 
null_to_empty <- function(x) if(is.null(x)) "no description" else x
api_docs <- map_dfr(old_docs$data, function(x) data_frame(table = x$table, description = null_to_empty(x$description)))

tbl_docs <-  
  paste0("https://fishbase.ropensci.org/docs/" , api_docs$table[-c(1:2, 16, 20, 38)]) %>% 
  map(function(x) jsonlite::read_json(x, simplifyVector = TRUE)$data)

tbls <- map_chr(tbl_docs, ~ .x$table_name[[1]])
names(tmp_docs) <- tbls


