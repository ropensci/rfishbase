tbls <- readLines("data-raw/rfishbase_tables.txt")
devtools::load_all()

library(purrr)
all_tbls <- lapply(tbls, purrr::safely(fb_tbl))


keep <- purrr::map_lgl(all_tbls, function(x) is.null(x$error))
good <- map(all_tbls[keep], "result")
names(good) <- tbls[keep]
field_list <- purrr::map_dfr(good, function(x)
  tibble::data_frame(columns = names(x)), .id = "table") 

devtools::use_data(field_list, internal = TRUE)
