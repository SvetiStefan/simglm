% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/missing_data.r
\name{mar_missing}
\alias{mar_missing}
\title{Missing at Random}
\usage{
mar_missing(sim_data, resp_var, miss_cov, miss_prop)
}
\arguments{
\item{sim_data}{Simulated data frame}

\item{resp_var}{Response variable to add missing data to}

\item{miss_cov}{Covariate that the missing values are based on.}

\item{miss_prop}{A vector the same length as the number of unique values 
from miss_cov variable.}
}
\description{
This type of missing data structure will be simulated based on values of a 
third variable. For example, the likelihood of a missing value is a function 
of gender, socioeconomic status, or age. Note, this function is similar to 
dropout missing data, but instead of missing due to time, this is missing
due to another covariate.
}
