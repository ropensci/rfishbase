
#' Open database connection pane in RStudio
#'
#' This function launches the RStudio "Connection" pane to interactively
#' explore the database.
#'
#' @return NULL
#' @export
#'
#' @examples
#' if (!is.null(getOption("connectionObserver"))) neon_pane()
fishbase_pane <- function() {
  observer <- getOption("connectionObserver")
  if (!is.null(observer) && interactive()) {
    observer$connectionOpened(
      type = "fishbase",
      host = "rfishbase",
      displayName = "FishBase Tables",
      icon = system.file("img", "logo.png", package = "rfishbase"),
      connectCode = "rfishbase::fishbase_pane()",
      disconnect = db_disconnect,
      listObjectTypes = function() {
        list(
          table = list(contains = "data")
        )
      },
      listObjects = function(type = "datasets") {
        tbls <- DBI::dbListTables(fish_db())
        data.frame(
          name = tbls,
          type = rep("table", length(tbls)),
          stringsAsFactors = FALSE
        )
      },
      listColumns = function(table) {
        res <- DBI::dbGetQuery(fish_db(),
                               paste0("SELECT * FROM \"", table, "\" LIMIT 10"))
        data.frame(
          name = names(res), 
          type = vapply(res, function(x) class(x)[1], character(1)),
          stringsAsFactors = FALSE
        )
      },
      previewObject = function(rowLimit, table) {  #nolint
        DBI::dbGetQuery(fish_db(),
                        paste0("SELECT * FROM \"", table, "\" LIMIT ", rowLimit))
      },
      actions = list(
        Status = list(
          icon = system.file("img", "logo.png", package = "rfishbase"),
          callback = fish_db_status
        ),
        SQL = list(
          icon = system.file("img", "edit-sql.png", package = "rfishbase"),
          callback = sql_action
        )
      ),
      connectionObject = fish_db()
    )
  }
}

update_neon_pane <- function() {
  observer <- getOption("connectionObserver")
  if (!is.null(observer)) {
    observer$connectionUpdated("FishBase", "neonstore", "")
  }
}

sql_action <- function() {
  if (requireNamespace("rstudioapi", quietly = TRUE) &&
      exists("documentNew", asNamespace("rstudioapi"))) {
    contents <- paste(
      "-- !preview conn=neonstore::fish_db()",
      "",
      "SELECT * FROM provenance LIMIT 10",
      "",
      sep = "\n"
    )
    
    rstudioapi::documentNew(
      text = contents, type = "sql",
      position = rstudioapi::document_position(2, 40),
      execute = FALSE
    )
  }
}

fish_db_status <- function () {
  con <- fish_db()
  inherits(con, "DBIConnection")
}


## Do not open the pane onAttach, wait for user to call neon_pane()
#.onAttach <- function(libname, pkgname) {  #nolint
#  if (interactive() && Sys.getenv("RSTUDIO") == "1"  && !in_chk()) {
#    tryCatch({neon_pane()}, error = function(e) NULL, finally = NULL)
#  }
#  if (interactive()) 
#    tryCatch(fish_db_status(),  error = function(e) NULL, finally = NULL)
#}


in_chk <- function() {
  any(
    grepl("check",
          sapply(sys.calls(), 
                 function(a) paste(deparse(a), collapse = "\n"))
    )
  )
}

## Shouldn't be required globally, but seems that RStudio panel
## now tries to automate creation of the connections pane but doesn't do it correctly,
## or else duckdb implementation is missing some feature. 
options(rstudio.connectionObserver.errorsSuppressed = TRUE)

