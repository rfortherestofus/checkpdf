#' @title PDF accessibility summary
#'
#' @description
#' Generates a simple summary of accessibility
#' issues for a given PDF.
#'
#' @param file PDF file to check.
#' @param profile The validation profile to use. Default to `"ua1"` (recommended).
#'
#' @export
accessibility_summary <- function(file, profile = "ua1") {
  json <- verapdf(file = file, profile = profile)
  verapdf_version <- json$report$buildInformation$releaseDetails$version[[1]]
  is_compliant <- is_pdf_compliant(json, from_json = TRUE)
  results <- json$report$jobs$validationResult[[1]]
  n_passed_rules <- results$details$passedRules
  n_passed_checks <- results$details$passedChecks
  n_failed_rules <- results$details$failedRules
  n_failed_checks <- results$details$failedChecks
  failed_rules <- results$details$ruleSummaries

  cat("PDF Accessibility Summary\n")
  cat("=========================\n")
  cat("Verapdf version: ", verapdf_version, "\n")
  cat("Compliant: ", ifelse(is_compliant, "Yes", "No"), "\n")
  cat("Profile: ", profile, "\n\n")
  cat("Passed Rules:  ", n_passed_rules, "\n")
  cat("Passed Checks: ", n_passed_checks, "\n")
  cat("Failed Rules:  ", n_failed_rules, "\n")
  cat("Failed Checks: ", n_failed_checks, "\n")
}
