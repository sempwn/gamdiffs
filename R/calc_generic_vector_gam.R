#' Calculate the variance between a baseline prediction
#' and subsequent predictions in a gam model
#' based on modified code from gam predict function help
#' @param m model object
#' @param newdata data.frame nrow >= 2 defining points to compare to the first
#' row in the data frame
#' @param U difference matrix. defines the vector of differences being computed
#' @param ci range of confidence interval
#' @return list
#' @noRd
calc_generic_vector_gam <- function(m, newdata, U = NULL,
                                    ci = 0.95, delta = TRUE) {
  npreds <- nrow(newdata)

  if (npreds < 2) {
    stop("newdata needs two rows or more.")
  }

  # check that U has right dimensions
  if (!(nrow(U) == npreds)) {
    stop(glue::glue("U must have rows of length {npreds}"))
  }

  # calculate quantile for % ci
  p <- 1 - (1 - ci) / 2
  z <- qnorm(p)

  # linear predictor matrix
  Xp <- predict(m, newdata = newdata, type = "lpmatrix")
  # variance covariance of predicted values
  points_vcov <- Xp %*% vcov(m) %*% t(Xp)

  # predicted difference
  preds <- Xp %*% coef(m)



  # calculate the variance using the delta method
  grad_g <- array(exp(preds), c(length(preds), length(coef(m)))) * Xp
  points_vcov <- grad_g %*% vcov(m) %*% t(grad_g)

  preds <- exp(preds)


  # Calculate the variance vector

  pred_var <- diag(t(U) %*% points_vcov %*% U)
  se <- sqrt(pred_var)

  diffs <- t(U) %*% preds
  lc <- diffs - z * se
  uc <- diffs + z * se

  return(list(m = diffs, lc = lc, uc = uc))
}