
#' fb_tables
#' list tables
#' @inheritParams fb_import
#' @export
fb_tables <- function(server = c("fishbase", "sealifebase"),
                      version = "latest"){
  
  prov_document <- read_prov(server)
  meta_df <- parse_prov(prov_document, version = version)
  meta_df$name
}


parse_prov_ <- 
  function(prov = read_prov(), version = "latest") {
  who <- names(prov)
  if ("@graph" %in% who) {
    prov <- prov[["@graph"]]
  } else {
    prov <- list(prov)
  }
  avail_versions <-  map_chr(prov, "version")
  if (version == "latest") {
    version <- max(avail_versions)
  }
  i <- which(version == avail_versions)
  dataset <- prov[[i]]
  
  meta <- dataset$distribution
  meta_df <- tibble::tibble(
    name = purrr::map(meta, "name", .default=NA) %>% 
      purrr::map_chr(getElement,1) %>% tools::file_path_sans_ext(),
    id =  purrr::map_chr(meta, "id", .default=NA),
    description = purrr::map_chr(meta, "description", .default=NA),
    format = purrr::map_chr(meta, "encodingFormat", .default=NA),
    type =  purrr::map_chr(meta, "type", .default=NA),
    url =   purrr::map_chr(meta, "contentUrl", .default=NA)
  )
  meta_df[meta_df$type == "DataDownload",]
}
parse_prov <- memoise::memoise(parse_prov_)

dummy_memoise <- function(f, ...) {
  memoise::memoise(f, ...)
}


create_view <- function(parquets,
                         tblnames,
                         conn = DBI::dbConnect(drv = duckdb::duckdb())) {
  purrr::walk2(parquets, tblnames, create_view, conn)
  conn
}

read_prov_ <-function(server = c("fishbase", "sealifebase"),
                                       local=getOption("rfishbase_local_prov", 
                                                       FALSE)) {
  server <- match.arg(server)
  prov_latest <-
    switch(server,
           fishbase = "https://github.com/ropensci/rfishbase/raw/master/inst/prov/fb.prov",
           sealifebase = "https://github.com/ropensci/rfishbase/raw/master/prov/slb.prov")
  
  prov_local <-
    switch(
      server,
      fishbase = system.file("prov", "fb.prov", package = "rfishbase"),
      sealifebase = system.file("prov", "slb.prov", package = "rfishbase")
    )
  
  if(local) return(jsonlite::read_json(prov_local))
  
  
  prov <- purrr::possibly(jsonlite::read_json,
                          otherwise = jsonlite::read_json(prov_local))
  suppressWarnings({
    out <- prov(prov_latest)
  })
  out
}
read_prov <- memoise::memoise(read_prov_)


resolve_ids_ <- function(ids) {
  suppressMessages({
    purrr::map_chr(ids,
                   contentid::resolve,
                   store = TRUE,
                   dir = db_dir())
  })
}
resolve_ids <- memoise::memoise(resolve_ids_)
