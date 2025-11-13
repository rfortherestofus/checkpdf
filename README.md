<br>

> [!WARNING]  
> work in progress

# checkpdf: Check, validate, and report PDF accessibility

`{checkpdf}` is an R package that aims to make checking the accessibility of PDF files as easy as possible. It relies on [verapdf](https://github.com/veraPDF/veraPDF-library) (which does all the hard work in the background) and uses it to provide detailed reports on issues found in your PDF files.

<br>

## Installation

```r
# install.packages("pak")
pak::pkg_install("rfortherestofus/checkpdf")
```

<br>

## Usage

```r
library(checkpdf)
```

- Check that a PDF is PDF/UA-1 compliant:

```r
is_pdf_compliant("report.pdf")
```

- Generate an HTML accessibility report:

```r
accessibility_report("report.pdf")
```
