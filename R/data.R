#' A data set of harmonized PWT data
#'
#' A data frame containing harmonized PWT data.
#'
#' @format A tibble with `r nrow(pwt_harmonized)` rows and `r ncol(pwt_harmonized)` columns.
#' \describe{
#' \item{Country}{A column of strings identifying countries by ISO3c codes.}
#' \item{Year}{A column of integer years.}
#' \item{pop}{A double-precision column of population in persons.}
#' \item{rgdpe}{A double-precision column of GDP in constant 2017$.}
#' }
#'
#' @examples
#' pwt_harmonized
"pwt_harmonized"
