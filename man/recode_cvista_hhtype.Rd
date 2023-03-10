% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/morph.R
\name{recode_cvista_hhtype}
\alias{recode_cvista_hhtype}
\alias{recode_cvista_hhtype.csf2016}
\alias{recode_cvista_hhtype.vista1218}
\title{Create CVISTA household type (hhtype_c)}
\usage{
recode_cvista_hhtype(x, ...)

\method{recode_cvista_hhtype}{csf2016}(x, remove_cols = FALSE, ...)

\method{recode_cvista_hhtype}{vista1218}(x, remove_cols = FALSE, ...)
}
\arguments{
\item{x}{a \code{csf2016} data.table or a \code{vista1218} data.table.}

\item{...}{dots}

\item{remove_cols}{remove the recoding columns}
}
\description{
A simplified household type can be created with VISTA1218's \code{RELATIONSHIP}
variable or "Relationship to Person 1" and CSF2016's \code{rlhp} (Relatioship in household)
and \code{rpip} (Family/Household Reference Person Indicator).
}
