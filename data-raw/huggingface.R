hf <- "https://huggingface.co"


hf_urls <- function(path  = "data/fb/v24.07/parquet", 
                    repo = "datasets/cboettig/fishbase",
                    branch = "main"
                   ) { 

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
  
  versions <-
    glue::glue("{hf}/api/{repo}/tree/{branch}/{path}") |>
    jsonlite::read_json() |> 
    purrr::map_chr('path') |>
    stringr::str_extract("\\/v(\\d{2}\\.\\d{2})", 1)
  
  versions
  
}
# "23.05" "23.01" "21.06" "19.04"
#url |> duckdbfs::open_dataset()

fb_urls <- function(server = c("fishbase", "sealifebase"), 
                      version = "latest") {
    
    if(version == "latest") {
      version <- max(available_releases(server))
    }
    
    sv <- server_code(server)
    
    path  <- glue::glue("data/{sv}/v{version}/parquet")
    hf_urls(path)
    
}

fb_tables <- function(server = c("fishbase", "sealifebase"), 
                      version = "latest") {
  fb_urls(server, version) |>
    basename() |>
    stringr::str_remove(".parquet")
}

fb_table <- function(tbl, 
                     server = c("fishbase", "sealifebase"), 
                     version = "latest",
                     collect = TRUE) {
  urls <- fb_urls(server, version)
  tbl_names <- urls |> basename() |> stringr::str_remove(".parquet")
  names(urls) <- tbl_names
  url <- urls[tbl]
  
  out <- duckdbfs::open_dataset(url)
  if(collect)
    out <- dplyr::collect(out)
  
  out  
}

