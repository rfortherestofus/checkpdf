#' @title Call verapdf CLI
#'
#' @description
#' Utility to call verapdf command line interface.
#'
#' @param ... Additional params passed to the CLI
#'
#' @returns output from the CLI
#'
#' @export
verapdf <- function(...) {
  system2("verapdf", ...)
}
