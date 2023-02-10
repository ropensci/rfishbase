

# 
duckdb_import <- function(urls,
                          tablenames = basename(urls),
                          conn = fb_conn(),
                          local = getOption("rfishbase_local_db", FALSE)) {
  
  
  DBI::dbExecute(conn, "INSTALL 'httpfs';") # import from HTTP
  DBI::dbExecute(conn, "LOAD 'httpfs';")
  
  current_tbls <- DBI::dbListTables(conn)
  remote_tbls <- tools::file_path_sans_ext(basename(urls))
  
  if(all(remote_tbls %in% current_tbls)) return(conn)
  urls <- urls[!(remote_tbls %in% current_tbls)]
  
  # use CREATE TABLE for persistent local copy
  # use CREATE VIEW for remote parquet connection instead
  CMD <- "CREATE TABLE"
  if(!local) CMD <- "CREATE VIEW"
  
  send_query <- purrr::possibly(DBI::dbSendQuery, otherwise=NULL)
  
  for(i in seq_along(urls)){
    url <- urls[[i]]
    tblname <- tools::file_path_sans_ext(tablenames[[i]])
    view_query <- glue::glue(CMD, " '{tblname}' ",
                             "AS SELECT * FROM parquet_scan('{url}');")
    send_query(conn, view_query)
  }
  invisible(conn)
}
