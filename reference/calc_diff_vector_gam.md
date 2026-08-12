# Estimate of differences

**\[experimental\]**

Calculate the variance between a baseline prediction and subsequent
predictions in a gam model

## Usage

``` r
calc_diff_vector_gam(
  m,
  newdata,
  ci = 0.95,
  use_relative_diff = FALSE,
  method = "delta",
  nrep = 1000
)
```

## Arguments

- m:

  model object

- newdata:

  data.frame nrow \>= 2 defining points to compare to the first row in
  the data frame

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

  number of samples used for posterior sampling. Only used if `use_post`
  is `TRUE`

## Value

list
