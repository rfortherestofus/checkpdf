#' @title Accessibility report
#'
#' @description
#' Generates an HTML report on accessibility for a given PDF.
#'
#' @param file PDF file to check.
#' @param profile The validation profile to use. Default to `"ua1"`.
#' @param output_file Path for the HTML report. If `NULL`, creates a temp file.
#' @param open Whether to automatically open the report in browser. Default `TRUE`.
#'
#' @return Path to the generated HTML report (invisibly)
#'
#' @import glue utils dplyr htmltools htmlwidgets
#'
#' @export
accessibility_report <- function(
  file,
  profile = "ua1",
  output_file = tempfile(fileext = ".html"),
  open = TRUE
) {
  json <- verapdf(file = file, profile = profile)
  verapdf_version <- get_verapdf_version(json)
  is_compliant <- is_pdf_compliant(json, from_json = TRUE)
  results <- json$report$jobs$validationResult[[1]]
  n_passed_rules <- results$details$passedRules
  n_passed_checks <- results$details$passedChecks
  n_failed_rules <- results$details$failedRules
  n_failed_check <- results$details$failedChecks
  failed_rules <- results$details$ruleSummaries

  # Load user-friendly explanations
  explanations_file <- system.file(
    "extdata",
    "vera_explanations.csv",
    package = "pdfcheck",
    mustWork = TRUE
  )
  explanations <- read.csv(explanations_file, stringsAsFactors = FALSE)

  status_class <- if (is_compliant) "compliant" else "non-compliant"

  failed_rules_df <- tibble::tibble()

  if (length(failed_rules) > 0) {
    # Aggregate failed rules to avoid duplicates
    # Group by spec, clause, testNumber and sum failedChecks
    aggregated_rules <- list()

    for (i in seq_along(failed_rules)) {
      fr <- failed_rules[[i]]

      # Each element in failed_rules can contain vectors
      # We need to iterate over all elements in those vectors
      n_checks <- length(fr$failedChecks)

      for (j in seq_len(n_checks)) {
        # Extract j-th element from each field
        spec <- fr$specification[j]
        clause <- fr$clause[j]
        test_num <- fr$testNumber[j]
        desc <- fr$description[j]

        rule_key <- paste0(spec, "|", clause, "|", test_num)

        if (is.null(aggregated_rules[[rule_key]])) {
          aggregated_rules[[rule_key]] <- list(
            specification = spec,
            clause = clause,
            testNumber = test_num,
            description = desc
          )
        }
      }
    }

    # Now create rows from aggregated data
    for (rule_key in names(aggregated_rules)) {
      fr <- aggregated_rules[[rule_key]]

      spec <- fr$specification
      clause <- fr$clause
      test_num <- fr$testNumber

      # Convert specification format from "ISO 14289-1:2014" to "ISO_14289_1"
      spec_normalized <- gsub(":.*", "", spec) # Remove version part first
      spec_normalized <- gsub("[ -]", "_", spec_normalized) # Replace spaces and dashes with underscores

      # Construct rule_id to match against CSV
      # Format: ISO_14289_1-7.1.3
      rule_id <- paste0(spec_normalized, "-", clause, ".", test_num)

      # Find matching user-friendly explanation by rule_id
      explanation_idx <- which(explanations$rule_id == rule_id)

      user_message <- if (length(explanation_idx) > 0) {
        explanations$user_friendly_message[explanation_idx[1]]
      } else {
        "No user-friendly explanation available."
      }

      failed_rules_df <- failed_rules_df |>
        bind_rows(data.frame(
          rule_id = c(rule_id),
          spec = c(spec),
          clause = c(clause),
          description = c(fr$description),
          user_message = c(user_message)
        ))
    }
  }

  if (nrow(failed_rules_df) > 0) {
    react_table <- reactable::reactable(
      failed_rules_df,
      defaultColDef = reactable::colDef(show = FALSE),
      columns = list(
        user_message = reactable::colDef(
          name = "Issue description",
          show = TRUE
        ),
        rule_id = reactable::colDef(name = "Rule ID", width = 250, show = TRUE)
      ),
      rowStyle = list(cursor = "pointer"),
      searchable = TRUE,
      striped = TRUE,
      highlight = TRUE,
      theme = reactable::reactableTheme(
        borderColor = "#dfe2e5",
        stripedColor = "#f6f8fa",
        cellPadding = "8px 12px",
        style = list(
          fontFamily = "Inter, Roboto, -apple-system, BlinkMacSystemFont, Segoe UI, Helvetica, Arial, sans-serif"
        ),
        searchInputStyle = list(width = "40%")
      ),
      onClick = JS(
        "function(rowInfo, column) {
    // Extract data from the row
    const data = rowInfo.values;
    const rawData = rowInfo.row; // Access hidden columns
    
    // Build the modal content
    const content = `
      <div id='custom-modal' style='position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:9999; display:flex; align-items:center; justify-content:center;'>
        <div style='background:white; padding:30px; border-radius:8px; max-width:600px; width:90%; box-shadow: 0 4px 15px rgba(0,0,0,0.2); position:relative; font-family: sans-serif;'>
          <span id='close-modal' style='position:absolute; top:10px; right:15px; cursor:pointer; font-size:24px; color:#aaa;'>&times;</span>
          <h2 style='margin-top:0; color:#2c3e50;'>Rule Details</h2>
          <hr style='border:0; border-top:1px solid #eee; margin:15px 0;'>
          <p><strong>Rule ID:</strong> ${rawData.rule_id}</p>
          <p><strong>Explanation:</strong> ${rawData.user_message}</p>
          <p><strong>ISO:</strong> ${rawData.spec.replace('ISO ', '')}</p>
          <p><strong>Clause:</strong> ${rawData.clause}</p>
          <p><strong>veraPDF Issue:</strong> ${rawData.description}</p>
        </div>
      </div>
    `;
    
    // Inject modal into body
    document.body.insertAdjacentHTML('beforeend', content);
    
    // Close logic
    const modal = document.getElementById('custom-modal');
    modal.onclick = function(e) {
      if (e.target.id === 'custom-modal' || e.target.id === 'close-modal') {
        modal.remove();
      }
    };
  }"
      )
    )
    table_file <- tempfile(fileext = ".html")
    htmlwidgets::saveWidget(react_table, table_file)
    table_html <- readLines(table_file) |> paste0(collapse = "\n")
  } else {
    table_html <- ""
  }

  css <- system.file("report", "style.css", package = "pdfcheck") |>
    readLines() |>
    paste0(collapse = "\n")

  if (!is_compliant) {
    issue_section <- '<br><h2 class="section-title">Issues requiring attention</h2>'
  } else {
    issue_section <- ""
  }

  html_content <- glue(
    '<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>pdfcheck | PDF Accessibility Report</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:ital,opsz,wght@0,14..32,100..900;1,14..32,100..900&display=swap" rel="stylesheet">
    <style>{css}</style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>PDF accessibility report</h1>
            <div class="filename">{basename(file)}</div>
        </div>
        
        <div class="content">
            <div class="status-banner {status_class}">
                {status_class}
            </div>
            
            <div class="meta-info">
                <strong>Validation profile:</strong> {toupper(profile)} | 
                <strong>VeraPDF version:</strong> {verapdf_version} | 
                <strong>Report generated:</strong> {format(Sys.time(), "%Y-%m-%d %H:%M:%S")}
            </div>
            
            <div class="stats-grid">
                <div class="stat-card passed">
                    <div class="stat-number">{n_passed_rules}</div>
                    <div class="stat-label">Passed Rules</div>
                </div>
                <div class="stat-card failed">
                    <div class="stat-number">{n_failed_rules}</div>
                    <div class="stat-label">Failed Rules</div>
                </div>
            </div>
            
            {issue_section}
            {table_html}
        </div>
        
        <div class="footer">
            Generated by <a href="https://pdfcheck.org" target="_blank"><code>pdfcheck</code></a> | <a href="https://rfortherestofus.com/" target="_blank">R for the Rest of Us</a>
        </div>
    </div>
</body>
</html>'
  )

  writeLines(html_content, output_file)

  if (open) {
    browseURL(output_file)
  }

  invisible(output_file)
}
