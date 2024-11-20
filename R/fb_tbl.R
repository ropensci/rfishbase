#' Access a fishbase or sealifebase table
#' 
#' 
#' Please note that rfishbase accesses static snapshots of the raw database
#' tables used by FishBase and Sealifebase websites. Because these are static
#' snapshots, they may lag behind the latest available information on the web
#' interface, but should provide stable results.  
#' 
#' Please also note that the website pages are not organized precisely along
#' the lines of these tables.  A given page for a species may draw on data from
#' multiple tables, and sometimes presents the data in a processed or summarized
#' form.  Following RDB design, it is often
#' necessary to join multiple tables.  Other data cleaning steps are sometimes
#' necessary as well.  
#' @param tbl table name, as it appears in the database. See [fb_tables()]
#' for a list.
#' @param server Access data from fishbase or sealifebase?
#' @param version Version, see [available_releases()]
#' @param db database connection, deprecated
#' @param collect should we return an in-memory table? Generally best to leave
#' as TRUE unless RAM is too limited.  A remote table can be used with most
#' dplyr functions (filter, select, joins, etc) to further refine.
#' @export
#' @examplesIf interactive()
#' fb_tbl("species")
fb_tbl <- function(tbl, 
                   server = c("fishbase", "sealifebase"), 
                   version = "latest",
                   db = NULL,
                   collect = TRUE) {
  urls <- fb_urls(server, version)
  names(urls) <- tbl_name(urls)
  out <- duckdbfs::open_dataset(urls[tbl])
  
  if(collect) out <- dplyr::collect(out)
  
  out  
}

#' List the tables available on fishbase/sealifebase
#' 
#' These table names can be used to access each of the corresponding tables
#' using `[fb_tbl()]`.  Please note that following RDB design, it is often
#' necessary to join multiple tables.  Other data cleaning steps are sometimes
#' necessary as well.  
#' @inheritParams fb_tbl
#' @export
#' @examplesIf interactive()
#' fb_tables()
fb_tables <- function(server = c("fishbase", "sealifebase"), 
                      version = "latest") {
  fb_urls(server, version) |> tbl_name()
  
}

#' List available releases
#' 
#' @param server fishbase or sealifebase
#' @export
#' @examplesIf interactive()
#' available_releases()
available_releases <- function(server = c("fishbase", "sealifebase")) {
  
  sv <- server_code(server)
  repo <- "datasets/cboettig/fishbase"
  path <- glue::glue("data/{sv}")
is_user_in_china <- function() {
  response <- httr::GET("https://ipinfo.io")
  if (httr::status_code(response) == 200) {
    data <- jsonlite::fromJSON(httr::content(response, as = "text"))
    country <- data$country
    return(country == "CN")  
  } else FALSE
}

if (is_user_in_china()) {
  hf <- "https://hf-mirror.com"
} else {
  hf <- "https://huggingface.co"
}
  branch <- "main"
  versions <-
    glue::glue("{hf}/api/{repo}/tree/{branch}/{path}") |>
    jsonlite::read_json() |> 
    purrr::map_chr('path') |>
    stringr::str_extract("\\/v(\\d{2}\\.\\d{2})", 1)
  
  versions
  
}


get_latest_release <- function() "latest"


hf_urls <- function(path  = "data/fb/v24.07/parquet", 
                    repo = "datasets/cboettig/fishbase",
                    branch = "main"
) { 
  
is_user_in_china <- function() {
  response <- httr::GET("https://ipinfo.io")
  if (httr::status_code(response) == 200) {
    data <- jsonlite::fromJSON(httr::content(response, as = "text"))
    country <- data$country
    return(country == "CN")  
  } else FALSE
}

if (is_user_in_china()) {
  hf <- "https://hf-mirror.com"
} else {
  hf <- "https://huggingface.co"
}
  paths <-
    glue::glue("{hf}/api/{repo}/tree/{branch}/{path}") |>
    jsonlite::read_json() |> 
    purrr::map_chr('path')
  
  glue::glue("{hf}/{repo}/resolve/{branch}/{path}", path=paths)
}



fb_urls <- function(server = c("fishbase", "sealifebase"), 
                    version = "latest") {
  
  releases <- available_releases(server)
  if (version == "latest") {
    version <- max(releases)
  }
  if ( !(version %in% releases) ) {
    stop(
      glue::glue("version {version} not in ",
                 glue::glue_collapse(
                   glue::glue("{releases}"), ", ", last = " or "))
    )
  }
  
  sv <- server_code(server)
  path  <- glue::glue("data/{sv}/v{version}/parquet")
  hf_urls(path)
}

server_code <- function(server = c("fishbase", "sealifebase")) {
  server <- match.arg(server)
  switch(server, 
         "fishbase" = "fb",
         "sealifebase" = "slb")
}


tbl_name <- function(urls) {
  stringr::str_remove(basename(urls), ".parquet")
}
