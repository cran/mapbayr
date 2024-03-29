% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/vs_nonmem.R
\name{vs_nonmem}
\alias{vs_nonmem}
\alias{read_nmphi}
\alias{merge_phi}
\alias{plot_phi}
\alias{summarise_phi}
\alias{bar_phi}
\title{Compare results to NONMEM .phi}
\usage{
read_nmphi(x)

merge_phi(mapbayr_phi, nonmem_phi)

plot_phi(merged_phi, only_ETA = TRUE)

summarise_phi(
  merged_phi,
  group,
  only_ETA = TRUE,
  levels = c(Excellent = 0, Acceptable = 0.001, Discordant = 0.1)
)

bar_phi(summarised_phi, xaxis = NULL, facet = NULL)
}
\arguments{
\item{x}{full path to a .phi file generated by NONMEM}

\item{mapbayr_phi}{results of mapbayr estimations, in the form of a tibble data.frame, typically obtained from \code{get_phi()}}

\item{nonmem_phi}{results of NONMEM estimations, in the form of a tibble data.frame, typically obtained from \code{read_nmphi()}}

\item{merged_phi}{merged results of estimations, typically obtained from \code{merge_phi()}}

\item{only_ETA}{filter the data with \code{type=="ETA"} (a logical, default is \code{TRUE})}

\item{group}{one or multiple variables to \code{group_by()}}

\item{levels}{a named vector of length 3 in order to classify the absolute differences. Default cut-offs are 0.1\% and 10\% in the parameters space.}

\item{summarised_phi}{summarized results of estimations, typically obtained from \code{summarise_phi()}}

\item{xaxis}{optional. A character value, that correspond to a variable in data, passed to the x-axis to plot multiple bars side-by-side.}

\item{facet}{a formula, that will be passed to \code{ggplot2::facet_wrap()}}
}
\value{
\itemize{
\item read_nmphi: a tibble data.frame with a format close to the original .phi file
\item merge_phi: a long-form tibble data.frame with results of mapbayr and NONMEM
\item summarise_phi: a summarized tibble data.frame classifying the performance of mapbayr and NONMEM
\item plot_phi, bar_phi: a \code{ggplot2} object
}
}
\description{
Compare results to NONMEM .phi
}
\details{
These functions were made to easily compare the results of mapbayr to NONMEM. For instance, it could be useful in the case of the transposition of a pre-existing NONMEM model into mapbayr. For this, you need to code your model in both mapbayr and NONMEM, and perform the MAP-Bayesian estimation on the \strong{same dataset}. Ideally, the latter contains a substantial number of patients. NONMEM returns the estimations results into a .phi file.

Use \code{read_nmphi()} to parse the NONMEM .phi file into a convenient tibble data.frame with the columns:
\itemize{
\item \code{SUBJECT_NO}, \code{ID}: Subject identification.
\item \code{ETA1}, \code{ETA2}, ..., \code{ETAn}: Point estimates of eta.
\item \code{ETC1_1}, \code{ETC2_1}, \code{ETC2_2}, ...,  \code{ETCn_n}: Variance-covariance matrix of estimation.
\item \code{OBJ}: objective function value
}

Use \code{get_phi()} to access to the estimations of mapbayr with the same "phi" format.

Use \code{merge_phi()} to combine mapbayr and NONMEM "phi files" into a single long-form data.frame with the columns:
\itemize{
\item \code{SUBJECT_NO}, \code{ID}: Subject identification.
\item \code{variable} name and its \code{type}: ETA (point estimate), VARIANCE (on-diagonal element of the matrix), COVARIANCE (off-diagonal), and OBJ.
\item \code{mapbayr} and \code{nonmem}: corresponding values
\item \code{adiff}: absolute difference between \code{mapbayr} and \code{nonmem} values.
}

Use \code{plot_phi()} to graphically represent \code{adiff} \emph{vs} \code{variable}. Alternatively, the table returned by \code{merge_phi()} is easy to play with in order to derive performance statistics or the graphical plot of your choice.

Use \code{summarise_phi()} to classify the estimation as "Excellent", "Acceptable" or "Discordant", over the whole dataset or by \code{group}.

Use \code{bar_phi()} to graphically represent the proportion of the aforementioned classification as bar plot.
}
\examples{
library(mapbayr)
nmphi <- read_nmphi(system.file("nm001", "run001.phi", package = "mapbayr"))
mapbayrphi <- get_phi(est001)

merged <- merge_phi(mapbayrphi, nmphi)
plot_phi(merged)

summarised <- summarise_phi(merged)
bar_phi(summarised)


# Analyse the results of multiple runs simultaneously

#Example dataset that represents 3 runs
merge3 <- dplyr::bind_rows(merged, merged, merged, .id = "RUN")
merge3$adiff <- 10 ^ runif(nrow(merge3), -8, 0)

summarised3 <- summarise_phi(merge3, group = RUN)
bar_phi(summarised3, xaxis = "RUN")

}
