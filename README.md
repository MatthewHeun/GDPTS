
<!-- README.md is generated from README.Rmd. Please edit README.Rmd -->

# GDPTS

<!-- badges: start -->

[![R-CMD-check](https://github.com/MatthewHeun/GDPTS/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/MatthewHeun/GDPTS/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/MatthewHeun/GDPTS/graph/badge.svg)](https://app.codecov.io/gh/MatthewHeun/GDPTS)
<!-- badges: end -->

The goal of GDPTS is to develop a harmonized time series of country and
world GDP, starting from the Penn World Tables. See
<https://www.rug.nl/ggdc/productivity/pwt/> and [Feenstra et al.
(2015)](https://doi.org/10.1257/aer.20130954).

## Statement of need

There are many occasions when harmonized GDP time series are helpful for
analyses. This package builds that time series and makes it available
via an R package. In addition, a population time series is available in
this package.

## Installation

You can install the development version of GDPTS from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("MatthewHeun/GDPTS")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(GDPTS)
## basic example code
```

## More Information

Find more information, including vignettes and function documentation,
at <https://MatthewHeun.github.io/GDPTS/>.

## References

<div id="refs" class="references csl-bib-body hanging-indent"
entry-spacing="0">

<div id="ref-Feenstra:2015aa" class="csl-entry">

Feenstra, Robert C., Robert Inklaar, and Marcel P. Timmer. 2015. “The
Next Generation of the Penn World Table.” *American Economic Review* 105
(10): 3150–82. <https://doi.org/10.1257/aer.20130954>.

</div>

</div>
