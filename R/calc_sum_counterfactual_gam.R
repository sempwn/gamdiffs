#' Estimation of sum of model output
#' @description
#' `r lifecycle::badge("experimental")`
#' Calculate the variance between a baseline sum of predictions
#' against a counterfactual sum of predictions in a [gam]
#' based on modified code from gam predict function help
#' @param m model object
#' @param baseline_data data.frame of baseline predictors
#' @param counter_data data.frame of counterfactual predictors. `counter_data`
#' cannot be `NULL`
#' @param ci range of confidence interval
#' @param use_relative_diff provide estimates as a relative difference, otherwise
#' presented as an absolute difference
#' @param method Selects which method is used to estimate confidence intervals
#' and expectation. Can be one of the following:
#' \itemize{
#'  \item{"delta"}{Implements delta approximation.}
#'  \item{"posterior"}{Implements posterior sampling. Use `nrep` to specify number of bootstrap samples}
#'  \item{"bootstrap"}{Implements simple bootstrap. Use `nrep` to specify number of bootstrap samples}
#'  \item{"efron bootstrap"}{Implements Efron bootstrap. Use `nrep` to specify number of bootstrap samples}
#' }
#' @param nrep number of samples used for posterior sampling. Only used if using
#' `posterior` or `bootstrap` methods
#'  is `TRUE`
#' @return list
#' @export
calc_sum_counterfactual_gam <- function(m, baseline_data,
                                        counter_data = NULL,
                                        ci = 0.95,
                                        use_relative_diff = FALSE,
                                        method = "delta",
                                        nrep = 1000) {
  n_baseline <- nrow(baseline_data)
  total_rows <- n_baseline
  newdata <- baseline_data

  error_no_counter_data_if_using_relative(counter_data, use_relative_diff)

  if(!method %in% get_method_names()){
    stop(glue::glue("method {method} is not one of {get_method_names()}"))
  }

  if (is.null(counter_data)) {
    U <- rep(1, total_rows)
    # compare to 0
    U <- c(U, rep(0, total_rows))
  } else {
    if (!dataframes_have_same_columns(baseline_data, counter_data)) {
      stop("baseline_data and counter_data need same column names")
    }

    n_counter <- nrow(counter_data)
    total_rows <- total_rows + n_counter
    U <- c(rep(1, n_baseline), rep(0, n_counter))
    U <- c(U, rep(0, n_baseline), rep(1, n_counter))

    newdata <- dplyr::bind_rows(newdata, counter_data)
  }

  # Create the difference matrix
  U <- matrix(U, nrow = total_rows, ncol = 2)

  if(method == "posterior"){
    res <- calc_generic_vector_from_post(m, newdata,
      U = U,
      ci = ci,
      use_relative_diff = use_relative_diff,
      nrep = nrep
    )
  }else if(method == "bootstrap"){
    res <- calc_generic_vector_from_bootstrap(m,
      newdata,
      U = U,
      ci = ci,
      use_relative_diff = use_relative_diff,
      nrep = nrep
    )
  }else if(method == "delta"){
    res <- calc_generic_vector_gam(m, newdata,
      U = U,
      ci = ci,
      use_relative_diff = use_relative_diff
    )
  }else if(method == "efron bootstrap"){
    res <- calc_generic_vector_from_efron_bootstrap(m,
      newdata,
      U = U,
      ci = ci,
      use_relative_diff = use_relative_diff,
      nrep = nrep
    )
  }else{
    stop(glue::glue("{method} not implemented."))
  }


  return(res)
}

#' Check both dataframes have same columns
#' @param dataframe1 First dataframe
#' @param dataframe2 Second dataframe
#' @noRd
dataframes_have_same_columns <- function(dataframe1, dataframe2) {
  column_names1 <- colnames(dataframe1)
  column_names2 <- colnames(dataframe2)
  length_intersection <- length(intersect(column_names1, column_names2))


  predicate <- length_intersection == length(column_names1)
  predicate <- predicate && (length_intersection == length(column_names1))

  return(predicate)
}

#' error if counter data null and using relative diff
#' @param counter_data data.frame of counterfactual predictors.
#' @param use_relative_diff provide estimates as a relative difference, otherwise
#' presented as an absolute difference
#' @noRd
error_no_counter_data_if_using_relative <- function(counter_data,
                                                    use_relative_diff) {
  if (is.null(counter_data) && use_relative_diff) {
    stop("`use_relative_diff` can't be TRUE if counter_data is given.")
  }
}
