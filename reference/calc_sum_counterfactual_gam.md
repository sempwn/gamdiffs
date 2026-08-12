# Estimation of sum of model output

**\[experimental\]** Calculate the variance between a baseline sum of
predictions against a counterfactual sum of predictions in a
[gam](https://rdrr.io/pkg/mgcv/man/gam.html) based on modified code from
gam predict function help

## Usage

``` r
calc_sum_counterfactual_gam(
  m,
  baseline_data,
  counter_data = NULL,
  ci = 0.95,
  use_relative_diff = FALSE,
  method = "delta",
  nrep = 1000
)
```

## Arguments

- m:

  model object

- baseline_data:

  data.frame of baseline predictors

- counter_data:

  data.frame of counterfactual predictors. Optional can be `NULL` which
  would then just calculate variance of baseline sum.

- ci:

  range of confidence interval

- use_relative_diff:

  provide estimates as a relative difference, otherwise presented as an
  absolute difference

- method:

  Selects which method is used to estimate confidence intervals and
  expectation. Can be one of the following:

  - "delta"Implements delta approximation.

  - "posterior"Implements posterior sampling. Use `nrep` to specify
    number of bootstrap samples

  - "bootstrap"Implements simple bootstrap. Use `nrep` to specify number
    of bootstrap samples

  - "efron bootstrap"Implements Efron bootstrap. Use `nrep` to specify
    number of bootstrap samples

- nrep:

  number of samples used for posterior sampling. Only used if using
  `posterior` or `bootstrap` methods is `TRUE`

## Value

list
