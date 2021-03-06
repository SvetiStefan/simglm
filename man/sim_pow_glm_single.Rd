% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pow_sim_glm.r
\name{sim_pow_glm_single}
\alias{sim_pow_glm_single}
\title{Function to simulate power.}
\usage{
sim_pow_glm_single(fixed, fixed_param, cov_param, n, data_str,
  cor_vars = NULL, fact_vars = list(NULL), outcome_type, missing = FALSE,
  missing_args = list(NULL), pow_param = NULL, alpha, pow_dist = c("z",
  "t"), pow_tail = c(1, 2), glm_fit_mod = NULL, glm_fit_family, ...)
}
\arguments{
\item{fixed}{One sided formula for fixed effects in the simulation. 
To suppress intercept add -1 to formula.}

\item{fixed_param}{Fixed effect parameter values (i.e. beta weights). 
Must be same length as fixed.}

\item{cov_param}{List of arguments to pass to the continuous generating 
function, must be the same order as the variables specified in fixed. 
This list does not include intercept, time, factors, or 
interactions. Required arguments include:
\itemize{
  \item dist_fun: This is a quoted R distribution function.
  \item var_type: This is the level of variable to generate. Must be 
    'single'. 
    Must be same order as fixed formula above.
}
Optional arguments to the distribution functions are in a nested list,
 see the examples or vignettes for example code.}

\item{n}{Cluster sample size.}

\item{data_str}{Type of data. Must be "cross", "long", or "single".}

\item{cor_vars}{A vector of correlations between variables.}

\item{fact_vars}{A nested list of factor, categorical, or ordinal variable 
   specification, each list must include:
\itemize{
     \item numlevels: Number of levels for ordinal or factor variables.
     \item var_type: Must be 'single'.
 }
 Optional arguments include:
 \itemize{
     \item replace
     \item prob
     \item value.labels
 }
  See also \code{\link{sample}} for use of these optional arguments.}

\item{outcome_type}{A vector specifying the type of outcome, must be either
logistic or poisson. Logitstic outcome will be 0/1 and poisson outcome will
be counts.}

\item{missing}{TRUE/FALSE flag indicating whether missing data should be 
simulated.}

\item{missing_args}{Additional missing arguments to pass to the missing_data 
function. See \code{\link{missing_data}} for examples.}

\item{pow_param}{Name of variable to calculate power for, must be a name 
from fixed.}

\item{alpha}{What should the per test alpha rate be used for the hypothesis 
testing.}

\item{pow_dist}{Which distribution should be used when testing hypothesis 
test, z or t?}

\item{pow_tail}{One-tailed or two-tailed test?}

\item{glm_fit_mod}{Valid glm syntax to be used for model fitting.}

\item{glm_fit_family}{Valid family syntax to pass to the glm function.}

\item{...}{Additional specification needed to pass to the random generating 
function defined by with_err_gen.}
}
\description{
Input simulation conditions and which term to compute power for, export 
reported power.
}
\details{
Power function to compute power for a regression term for simple generalized 
regression models. This function would need to be replicated to make any 
statement about power.  Use \code{\link{sim_pow_glm}} as a convenient wrapper
for this.
}
\seealso{
\code{\link{sim_pow_glm}} for a wrapper to replicate.
}
