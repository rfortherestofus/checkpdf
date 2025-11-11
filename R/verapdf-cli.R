#' @title Call verapdf CLI
#'
#' @description
#' Utility to call verapdf command line interface.
#'
#' @param file PDF file to check.
#' @param write_to Path to output JSON file. If `NULL`, not written.
#'
#' @returns output from the CLI
#'
#' @export
verapdf <- function(file, write_to = NULL) {
  cmd <- "verapdf"
  args <- c("--format", "json", file)

  out <- suppressWarnings(system2(cmd, args, stdout = TRUE))
  json_out <- jsonlite::fromJSON(paste(out, collapse = "\n"))

  if (!is.null(write_to)) {
    jsonlite::write_json(json_out, write_to, auto_unbox = TRUE, pretty = TRUE)
  }

  return(json_out)
}
