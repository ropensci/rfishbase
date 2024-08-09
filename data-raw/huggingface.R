

fb_tbl <- function(tbl, 
                   server = c("fishbase", "sealifebase"), 
                   version = "latest",
                   collect = TRUE) {
  urls <- fb_urls(server, version)
  names(urls) <- tbl_name(urls)
  
  url <- urls[tbl]
  out <- duckdbfs::open_dataset(url)
  if(collect)
    out <- dplyr::collect(out)
  
  out  
}


hf_urls <- function(path  = "data/fb/v24.07/parquet", 
                    repo = "datasets/cboettig/fishbase",
                    branch = "main"
                   ) { 

  hf <- "https://huggingface.co"
  paths <-
    glue::glue("{hf}/api/{repo}/tree/{branch}/{path}") |>
    jsonlite::read_json() |> 
    purrr::map_chr('path')

  glue::glue("{hf}/{repo}/resolve/{branch}/{path}", path=paths)
}


server_code <- function(server = c("fishbase", "sealifebase")) {
  server <- match.arg(server)
  switch(server, 
         "fishbase" = "fb",
         "sealifebase" = "slb")
}

available_releases <- function(server = c("fishbase", "sealifebase")) {

  sv <- server_code(server)
  repo <- "datasets/cboettig/fishbase"
  path <- glue::glue("data/{sv}")
  hf <- "https://huggingface.co"
  
  versions <-
    glue::glue("{hf}/api/{repo}/tree/{branch}/{path}") |>
    jsonlite::read_json() |> 
    purrr::map_chr('path') |>
    stringr::str_extract("\\/v(\\d{2}\\.\\d{2})", 1)
  
  versions
  
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

fb_tables <- function(server = c("fishbase", "sealifebase"), 
                      version = "latest") {
  fb_urls(server, version) |> tbl_name()
   
}

tbl_name <- function(urls) {
  stringr::str_remove(basename(urls), ".parquet")
}
