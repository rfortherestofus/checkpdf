#' @title Retrieve specific accessibility info
#'
#' @description
#' Utility functions to retrieve specific informations
#' about PDF accessibility.
#'
#' @param x Output from `verapdf()`
#'
#' @name info
#'
#' @examples
#' pdf_file <- system.file("pdf", "not-compliant-1.pdf", package = "checkpdf")
#'
#' verapdf(pdf_file) |>
#'   get_total_failed_checks()
#'
#' verapdf(pdf_file) |>
#'   get_total_failed_rules()
#'
#' verapdf(pdf_file) |>
#'   get_verapdf_version()
NULL

#' @rdname info
#' @export
get_total_failed_checks <- function(x) {
  x$report$jobs$validationResult[[1]]$details$failedChecks
}

#' @rdname info
#' @export
get_total_failed_rules <- function(x) {
  x$report$jobs$validationResult[[1]]$details$failedRules
}

#' @rdname info
#' @export
get_verapdf_version <- function(x) {
  x$report$buildInformation$releaseDetails$version[[1]]
}
