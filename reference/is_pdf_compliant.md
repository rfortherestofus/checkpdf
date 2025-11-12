# Does this PDF comply with accessibility standards?

Check whether a given PDF file is compliant to PDF/UA-1 (default).

## Usage

``` r
is_pdf_compliant(file, profile = "ua1")
```

## Arguments

- file:

  PDF file to check.

- profile:

  The validation profile to use. Default to `"ua1"` (recommended).

## Value

A logical

## Examples

``` r
if (FALSE) { # \dontrun{
is_pdf_compliant("report.pdf")
is_pdf_compliant("report.pdf", profile="ua2")
} # }
```
