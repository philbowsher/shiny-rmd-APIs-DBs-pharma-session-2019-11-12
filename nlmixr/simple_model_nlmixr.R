library(nlmixr)
# define the model
m1 <- function() {
  ini({
    tka <- .5
    tcl <- -3.2
    tv <- -1
    eta.ka ~ 1
    eta.cl ~ 2
    eta.v ~ 1
    add.err <- 0.1
  })
  model({
    ka <- exp(tka + eta.ka)
    cl <- exp(tcl + eta.cl)
    v <- exp(tv + eta.v)
    linCmt() ~ add(add.err)
  })
}
# run nlmixr with previously defined model (data is present in package)
fit <- nlmixr(m1, theo_sd, est="saem", table=tableControl(cwres=TRUE, npde=TRUE))
