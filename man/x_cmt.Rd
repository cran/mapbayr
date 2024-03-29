% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_mrgsolve_model.R
\name{x_cmt}
\alias{x_cmt}
\alias{adm_cmt}
\alias{obs_cmt}
\title{Read compartment options in a model}
\usage{
adm_cmt(x)

obs_cmt(x)
}
\arguments{
\item{x}{model object}
}
\value{
a vector of compartment identified as default "administration" or "observation" compartments.
}
\description{
Read compartment options in a model
}
\details{
In a mrgsolve model, it is possible to specify options in \verb{$CMT}. If \verb{[ADM]} or \verb{[OBS]} are set, mapbayr will interpret these as defaults administration and observation compartments, respectively.
}
\examples{
#Administration:  Both 1st and 0- order
model <- exmodel(6, compile = FALSE)
mrgsolve::see(model)
adm_cmt(model)

#Observation: Both parent drug and metabolite
model <- exmodel(401, compile = FALSE)
mrgsolve::see(model)
obs_cmt(model)
}
