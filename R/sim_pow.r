#' Master power simulation function.
#' 
#' Input simulation conditions, returns power for term.
#' 
#' This function is a wrapper that replicates the simulation functions for simple regression
#' and the linear mixed model power functions.  This function replicates the power call a 
#' specified number of times and prints outs a matrix with the results.
#' 
#' @param fixed One sided formula for fixed effects in the simulation.  To suppress intercept add -1 to formula.
#' @param random One sided formula for random effects in the simulation. Must be a subset of fixed.
#' @param random3 One sided formula for random effects at third level in the simulation. Must be a subset of fixed
#'  (and likely of random).
#' @param fixed_param Fixed effect parameter values (i.e. beta weights).  Must be same length as fixed.
#' @param random_param A list of named elements that must contain: 
#'             random_var = variance of random parameters,
#'             rand_gen = Name of simulation function for random effects.
#'          Optional elements are:
#'             ther: Theorectial mean and variance from rand_gen,
#'             ther_sim: Simulate mean/variance for standardization purposes,
#'             cor_vars: Correlation between random effects,
#'             ...: Additional parameters needed for rand_gen function.
#' @param random_param3 A list of named elements that must contain: 
#'             random_var = variance of random parameters,
#'             rand_gen = Name of simulation function for random effects.
#'          Optional elements are:
#'             ther: Theorectial mean and variance from rand_gen,
#'             ther_sim: Simulate mean/variance for standardization purposes,
#'             cor_vars: Correlation between random effects,
#'             ...: Additional parameters needed for rand_gen function.
#' @param cov_param List of mean and variance for fixed effects. Does not include intercept, time, or 
#' interactions. Must be same order as fixed formula above.
#' @param k Number of third level clusters.
#' @param n Cluster sample size.
#' @param p Within cluster sample size.
#' @param error_var Scalar of error variance.
#' @param with_err_gen Distribution function to pass on to the level one
#'                  simulation of errors.
#' @param arima TRUE/FALSE flag indicating whether residuals should 
#'             be correlated. If TRUE, must specify a valid model to pass to 
#'             arima.sim. See \code{\link{arima.sim}} for examples.
#' @param data_str Type of data. Must be "cross", "long", or "single".
#' @param cor_vars A vector of correlations between variables.
#' @param fact_vars A nested list of factor, categorical, or ordinal variable specification, 
#'      each list must include numlevels and var_type (must be "lvl1" or "lvl2");
#'      optional specifications are: replace, prob, value.labels.
#' @param unbal A vector of sample sizes for the number of observations for each level 2
#'  cluster. Must have same length as level two sample size n. Alternative specification
#'  can be TRUE, which uses additional argument, unbalCont.
#' @param unbal3 A vector of sample sizes for the number of observations for each level 3
#'  cluster. Must have same length as level two sample size k. Alternative specification
#'  can be TRUE, which uses additional argument, unbalCont3.
#' @param unbalCont When unbal = TRUE, this specifies the minimum and maximum level one size,
#'  will be drawn from a random uniform distribution with min and max specified.
#' @param unbalCont3 When unbal3 = TRUE, this specifies the minimum and maximum level two size,
#'  will be drawn from a random uniform distribution with min and max specified.
#' @param lvl1_err_params Additional parameters passed as a list on to the level one error generating function
#' @param arima_mod A list indicating the ARIMA model to pass to arima.sim. 
#'             See \code{\link{arima.sim}} for examples.
#' @param missing TRUE/FALSE flag indicating whether missing data should be simulated.
#' @param missing_args Additional missing arguments to pass to the missing_data function. 
#'           See \code{\link{missing_data}} for examples.
#' @param pow_param Number of parameter to calculate power includes intercept where applicable.
#' @param alpha What should the per test alpha rate be used for the hypothesis testing.
#' @param pow_dist Which distribution should be used when testing hypothesis test, z or t?
#' @param pow_tail One-tailed or two-tailed test?
#' @param replicates How many replications should be done (i.e. the denominator in power calculation).
#' @param ... Additional parameters passed on to the level one error generating function
#' @importFrom dplyr group_by
#' @importFrom dplyr summarise
#' @importFrom dplyr '%>%'
#' @export 
sim_pow <- function(fixed, random, random3, fixed_param, 
                    random_param = list(), random_param3 = list(), cov_param, k, n, p, 
                    error_var, with_err_gen, arima = FALSE,
                    data_str, cor_vars = NULL, fact_vars = list(NULL), unbal = FALSE, unbal3 = FALSE, 
                    unbalCont = NULL, unbalCont3 = NULL,
                    lvl1_err_params = NULL, arima_mod = list(NULL),
                    missing = FALSE, missing_args = list(NULL),
                    pow_param, alpha, pow_dist = c("z", "t"), pow_tail = c(1, 2), 
                    replicates, ...) {
  
  if(data_str == "single"){
    temp_pow <- do.call("rbind", lapply(1:replicates, function(xx) sim_pow_single(fixed, fixed_param, 
                                                    cov_param, n, error_var, with_err_gen, arima, data_str, 
                                                    cor_vars, fact_vars, lvl1_err_params, arima_mod, 
                                                    missing, missing_args,
                                                    pow_param, alpha, pow_dist, pow_tail, ...)))
    
    #nbatch <- 3
    #system.time(temp.pow <- foreach(i = 1:(9999/nbatch), .combine = "c", .packages = "simReg") %dopar% {
     # replicate(nbatch, sim.pow.single(fixed, fixed_param, cov_param, n, error_var,
      #               with_err_gen, pow_param, alpha, pow_dist, pow_tail))
    #})
  } else {
    if(is.null(k)) {
      temp_pow <- do.call('rbind', lapply(1:replicates, function(xx) 
        sim_pow_nested(fixed, random, fixed_param, random_param, cov_param, n, p, 
                       error_var, with_err_gen, arima, data_str, cor_vars, fact_vars, 
                       unbal, unbalCont, lvl1_err_params, arima_mod, 
                       missing, missing_args, pow_param, alpha, pow_dist, pow_tail, ...)))
    } else {
      temp_pow <- do.call('rbind', lapply(1:replicates, function(xx) 
        sim_pow_nested3(fixed, random, random3, fixed_param, random_param, random_param3, 
                        cov_param, k, n, p, 
                       error_var, with_err_gen, arima, data_str, cor_vars, fact_vars, 
                       unbal, unbal3, unbalCont, unbalCont3, lvl1_err_params, arima_mod, 
                       missing, missing_args, pow_param, alpha, pow_dist, pow_tail, ...)))
    }
  }
  
  power <- temp_pow %>%
    dplyr::group_by_('var') %>%
    dplyr::summarise(avg_test_stat = mean(test_stat),
              sd_test_stat = sd(test_stat),
              power = mean(reject),
              num_reject = sum(reject),
              num_repl = replicates)

  # power <- dplyr::summarise(dplyr::group_by(temp_pow, var), avg_test_stat = mean(test_stat),
  #                                       sd_test_stat = sd(test_stat),
  #                                       power = mean(reject),
  #                                       num_reject = sum(reject),
  #                                       num_repl = replicates)
  
  return(power)
}

#' Master power simulation function for glm models.
#' 
#' Input simulation conditions, returns power for term.
#' 
#' This function is a wrapper that replicates the simulation functions for simple generalized regression
#' and the generalized linear mixed model power functions.  This function replicates the power call a 
#' specified number of times and prints outs a matrix with the results.
#' 
#' @param fixed One sided formula for fixed effects in the simulation.  To suppress intercept add -1 to formula.
#' @param random One sided formula for random effects in the simulation. Must be a subset of fixed.
#' @param random3 One sided formula for random effects at third level in the simulation. Must be a subset of fixed
#'  (and likely of random).
#' @param fixed_param Fixed effect parameter values (i.e. beta weights).  Must be same length as fixed.
#' @param random_param A list of named elements that must contain: 
#'             random_var = variance of random parameters,
#'             rand_gen = Name of simulation function for random effects.
#'          Optional elements are:
#'             ther: Theorectial mean and variance from rand_gen,
#'             ther_sim: Simulate mean/variance for standardization purposes,
#'             cor_vars: Correlation between random effects,
#'             ...: Additional parameters needed for rand_gen function.
#' @param random_param3 A list of named elements that must contain: 
#'             random_var = variance of random parameters,
#'             rand_gen = Name of simulation function for random effects.
#'          Optional elements are:
#'             ther: Theorectial mean and variance from rand_gen,
#'             ther_sim: Simulate mean/variance for standardization purposes,
#'             cor_vars: Correlation between random effects,
#'             ...: Additional parameters needed for rand_gen function.
#' @param cov_param List of mean and variance for fixed effects. Does not include intercept, time, or 
#' interactions. Must be same order as fixed formula above.
#' @param k Number of third level clusters.
#' @param n Cluster sample size.
#' @param p Within cluster sample size.
#' @param data_str Type of data. Must be "cross", "long", or "single".
#' @param cor_vars A vector of correlations between variables.
#' @param fact_vars A nested list of factor, categorical, or ordinal variable specification, 
#'      each list must include numlevels and var_type (must be "lvl1" or "lvl2");
#'      optional specifications are: replace, prob, value.labels.
#' @param unbal A vector of sample sizes for the number of observations for each level 2
#'  cluster. Must have same length as level two sample size n. Alternative specification
#'  can be TRUE, which uses additional argument, unbalCont.
#' @param unbal3 A vector of sample sizes for the number of observations for each level 3
#'  cluster. Must have same length as level two sample size k. Alternative specification
#'  can be TRUE, which uses additional argument, unbalCont3.
#' @param unbalCont When unbal = TRUE, this specifies the minimum and maximum level one size,
#'  will be drawn from a random uniform distribution with min and max specified.
#' @param unbalCont3 When unbal3 = TRUE, this specifies the minimum and maximum level two size,
#'  will be drawn from a random uniform distribution with min and max specified.
#' @param missing TRUE/FALSE flag indicating whether missing data should be simulated.
#' @param missing_args Additional missing arguments to pass to the missing_data function. 
#'           See \code{\link{missing_data}} for examples.
#' @param pow_param Number of parameter to calculate power includes intercept where applicable.
#' @param alpha What should the per test alpha rate be used for the hypothesis testing.
#' @param pow_dist Which distribution should be used when testing hypothesis test, z or t?
#' @param pow_tail One-tailed or two-tailed test?
#' @param replicates How many replications should be done (i.e. the denominator in power calculation).
#' @param ... Additional parameters passed on to the level one error generating function
#' @importFrom dplyr group_by
#' @importFrom dplyr summarise
#' @importFrom dplyr '%>%'
#' @export 
sim_pow_glm <- function(fixed, random, random3, fixed_param, 
                    random_param = list(), random_param3 = list(), cov_param, k, n, p, 
                    data_str, cor_vars = NULL, fact_vars = list(NULL), unbal = FALSE, unbal3 = FALSE, 
                    unbalCont = NULL, unbalCont3 = NULL,
                    missing = FALSE, missing_args = list(NULL),
                    pow_param, alpha, pow_dist = c("z", "t"), pow_tail = c(1, 2), 
                    replicates, ...) {
  
  if(data_str == "single"){
    temp_pow <- do.call("rbind", lapply(1:replicates, function(xx) 
      sim_pow_glm_single(fixed, fixed_param, cov_param, n, data_str, 
                         cor_vars, fact_vars, missing, missing_args,
                         pow_param, alpha, pow_dist, pow_tail, ...)))
    
    #nbatch <- 3
    #system.time(temp.pow <- foreach(i = 1:(9999/nbatch), .combine = "c", .packages = "simReg") %dopar% {
    # replicate(nbatch, sim.pow.single(fixed, fixed_param, cov_param, n, error_var,
    #               with_err_gen, pow_param, alpha, pow_dist, pow_tail))
    #})
  } else {
    if(is.null(k)) {
      temp_pow <- do.call('rbind', lapply(1:replicates, function(xx) 
        sim_pow_glm_nested(fixed, random, fixed_param, random_param, cov_param, n, p, 
                       data_str, cor_vars, fact_vars, 
                       unbal, unbalCont, 
                       missing, missing_args, pow_param, alpha, pow_dist, pow_tail, ...)))
    } else {
      temp_pow <- do.call('rbind', lapply(1:replicates, function(xx) 
        sim_pow_glm_nested3(fixed, random, random3, fixed_param, random_param, random_param3, 
                        cov_param, k, n, p, 
                        data_str, cor_vars, fact_vars, 
                        unbal, unbal3, unbalCont, unbalCont3, 
                        missing, missing_args, pow_param, alpha, pow_dist, pow_tail, ...)))
    }
  }
  
  power <- temp_pow %>%
    dplyr::group_by_('var') %>%
    dplyr::summarise(avg_test_stat = mean(test_stat),
                     sd_test_stat = sd(test_stat),
                     power = mean(reject),
                     num_reject = sum(reject),
                     num_repl = replicates)
  
  # power <- dplyr::summarise(dplyr::group_by(temp_pow, var), avg_test_stat = mean(test_stat),
  #                                       sd_test_stat = sd(test_stat),
  #                                       power = mean(reject),
  #                                       num_reject = sum(reject),
  #                                       num_repl = replicates)
  
  return(power)
}
