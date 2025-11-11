#' @title Is PDF/A compliant?
#'
#' @description
#' Check whether a given PDF file is PDF/A compliant.
#'
#' @param file PDF file to check.
#'
#' @return A logical
#'
#' @export
is_pdfa_compliant <- function(file) {
  json <- verapdf(file = file)

  failed_rules <- json$report$jobs$validationResult[[1]]$details$failedRules

  return(failed_rules == 0)
}
