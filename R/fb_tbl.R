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
fb_tbl <- function(
  tbl,
  server = c("fishbase", "sealifebase"),
  version = "latest",
  db = NULL,
  collect = TRUE
) {
  urls <- fb_urls(server, version)
  names(urls) <- tbl_name(urls)

  duckdbfs::duckdb_config(enable_object_cache = 'true')
  out <- duckdbfs::open_dataset(urls[tbl])

  if (collect) {
    out <- dplyr::collect(out)
  }

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
fb_tables <- function(
  server = c("fishbase", "sealifebase"),
  version = "latest"
) {
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
  bucket <- "us-west-2.opendata.source.coop"
  prefix <- glue::glue("cboettig/fishbase/{sv}/")

  # S3 List Objects API endpoint
  s3_endpoint <- glue::glue(
    "https://s3.us-west-2.amazonaws.com/{bucket}?list-type=2&prefix={prefix}&delimiter=/"
  )

  # Parse XML response to get common prefixes (subdirectories)
  response <- xml2::read_xml(s3_endpoint)

  # Extract version directories from CommonPrefixes
  prefixes <- xml2::xml_find_all(
    response,
    ".//d1:CommonPrefixes/d1:Prefix",
    xml2::xml_ns(response)
  )
  prefix_paths <- xml2::xml_text(prefixes)

  # Extract version numbers (e.g., v24.07)
  versions <- prefix_paths |>
    stringr::str_extract("v(\\d{2}\\.\\d{2})", 1)

  versions[!is.na(versions)]
}


get_latest_release <- function() "latest"


s3_urls <- function(
  path = "cboettig/fishbase/fb/v24.07/parquet",
  bucket = "us-west-2.opendata.source.coop"
) {
  # S3 List Objects API endpoint
  s3_endpoint <- glue::glue(
    "https://s3.us-west-2.amazonaws.com/{bucket}?list-type=2&prefix={path}/"
  )

  # Parse XML response to get objects
  response <- xml2::read_xml(s3_endpoint)

  # Extract object keys
  keys <- xml2::xml_find_all(
    response,
    ".//d1:Contents/d1:Key",
    xml2::xml_ns(response)
  )
  object_keys <- xml2::xml_text(keys)

  # Filter out invalid/empty parquet files (e.g., ".parquet" with no table name)
  object_keys <- object_keys[!grepl("/\\.parquet$", object_keys)]

  # Build full S3 URLs
  glue::glue(
    "https://data.source.coop/{key}",
    key = object_keys
  )
}


fb_urls <- function(server = c("fishbase", "sealifebase"), version = "latest") {
  releases <- available_releases(server)
  if (version == "latest") {
    version <- max(releases)
  }
  if (!(version %in% releases)) {
    stop(
      glue::glue(
        "version {version} not in ",
        glue::glue_collapse(
          glue::glue("{releases}"),
          ", ",
          last = " or "
        )
      )
    )
  }

  sv <- server_code(server)
  path <- glue::glue("cboettig/fishbase/{sv}/v{version}/parquet")
  s3_urls(path)
}

server_code <- function(server = c("fishbase", "sealifebase")) {
  server <- match.arg(server)
  switch(server, "fishbase" = "fb", "sealifebase" = "slb")
}


tbl_name <- function(urls) {
  stringr::str_remove(basename(urls), ".parquet")
}
