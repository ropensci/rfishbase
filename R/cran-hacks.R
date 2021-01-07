
#' @importFrom progress progress_bar
#' @importFrom dbplyr translate_sql
dummy <- function(){
  # dbplyr is required for the database backend, but is only suggested by dplyr
  # Consequently, functions use dplyr
  x <- 2
  dbplyr::translate_sql(x + 1)
  progress::progress_bar$new(total = 100)
  NULL
}