% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data_helpers.R
\name{parse_datehour}
\alias{parse_datehour}
\title{Parse value to "POSIXct"}
\usage{
parse_datehour(
  x,
  orders = getOption("mapbayr.datehour", default = c("Ymd HMS", "Ymd HM", "dmY HMS",
    "dmY HM"))
)
}
\arguments{
\item{x}{a numeric or a character.}

\item{orders}{format specification for x, passed to \code{\link[lubridate:parse_date_time]{lubridate::parse_date_time()}}}
}
\value{
a POSIXct
}
\description{
A wrapper around functions of \code{lubridate}, mainly in order to transform characters into a date-time ("POSIXct") format.
}
\examples{
# POSITct are returned as is.
parse_datehour(x = as.POSIXct("2022-02-02 22:22:22", tz = "UTC"))

# Numerics are passed to `lubridate::as_datetime()`.
parse_datehour(1643840542)

# Characters are passed to `lubridate::parse_date_time()`.
# The format used will be the one defined in `orders`
parse_datehour(x = "2022-02-02 22:22:22", orders = "Ymd HMS")
parse_datehour(x = "02-02-2022 22:22", orders = "dmY HM")

# By default, the following formats will be subsequently tried:
# "Ymd HMS", "Ymd HM", "dmY HMS", "dmY HM"

# Alternatively, set a format through `options(mapbayr.datehour)`.
# Convenient for the use `.datehour` in  `adm_rows()` and `obs_rows()`.

# Following format will return NA:
adm_rows(.datehour = "22:22 02-02-2022", amt = 100, cmt = 1)

options(mapbayr.datehour = "HM dmY")
adm_rows(.datehour = "22:22 02-02-2022", amt = 100, cmt = 1)
options(mapbayr.datehour = NULL)

}
