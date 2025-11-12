# checkpdf: Check, validate, and report PDF accessibility

> \[!WARNING\]  
> work in progress

[checkpdf](https://rfortherestofus.github.io/checkpdf/) is an R package
that aims to make super simple to verify PDF files accessibility. It’s
built on top of [verapdf](https://github.com/veraPDF/veraPDF-library)
(which does all the hard work under the hood) and leverages it to give
detailed reports about what’s wrong with your PDFs.

  

## Installation

``` r
# install.packages("pak")
pak::pkg_install("rfortherestofus/checkpdf")
```

  

## Usage

``` r
library(checkpdf)
```

- Check that a PDF is PDF/UA-1 compliant (gold standard):

``` r
is_pdf_compliant("report.pdf")
```
