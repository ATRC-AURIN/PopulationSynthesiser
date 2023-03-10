% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/morph.R
\name{recode_cvista_anzsco1}
\alias{recode_cvista_anzsco1}
\alias{recode_cvista_anzsco1.csf2016}
\alias{recode_cvista_anzsco1.vista1218}
\title{Create CVISTA occupation field}
\usage{
recode_cvista_anzsco1(x, ...)

\method{recode_cvista_anzsco1}{csf2016}(x, remove_cols = FALSE, ...)

\method{recode_cvista_anzsco1}{vista1218}(x, remove_cols = FALSE, ...)
}
\arguments{
\item{x}{a \code{csf2016} data.table or a \code{vista1218} data.table.}

\item{...}{dots}

\item{remove_cols}{remove the recoding columns}
}
\description{
CSF2016's OCCP variable can be directly converted to
VISTA1218's ANZSCO1.
}
