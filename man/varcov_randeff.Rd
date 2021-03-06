% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/varcov_randeff.r
\name{varcov_randeff}
\alias{varcov_randeff}
\title{Function to create random effect variance-covariance matrices}
\usage{
varcov_randeff(random_var, cor_re)
}
\arguments{
\item{random_var}{Variance of random effects.}

\item{cor_re}{Correlation between random effects, currently only a 
constant supported.}
}
\description{
Input variances of random effects and correlation between random effects,
returns variance-covariance matrix of random effects.
}
