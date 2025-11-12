# Call verapdf CLI

Utility to call verapdf command line interface. It requires the
`verapdf` CLI to be on PATH.

## Usage

``` r
verapdf(
  file,
  write_to = NULL,
  format = c("json", "xml"),
  profile = c("ua1", "ua2", "1a", "1b", "2a", "2b", "2u", "3a", "3b", "3u", "4", "4f",
    "4e")
)
```

## Arguments

- file:

  PDF file to check.

- write_to:

  Path to output file. If `NULL`, does not write.

- format:

  Output format. Default to `"json"`.

- profile:

  The validation profile to use. Default to `"ua1"` (recommended).

## Value

output from the CLI
