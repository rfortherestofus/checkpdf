#' @title Call verapdf CLI
#'
#' @description
#' Utility to call verapdf command line interface.
#'
#' @param file PDF file to check.
#'
#' @returns output from the CLI
#'
#' @export
verapdf <- function(file) {
  cmd <- "verapdf"
  args <- c("--format", "json", file)

  out <- system2(cmd, args, stdout = TRUE)
  json_out <- jsonlite::fromJSON(paste(out, collapse = "\n"))

  return(json_out)
}
