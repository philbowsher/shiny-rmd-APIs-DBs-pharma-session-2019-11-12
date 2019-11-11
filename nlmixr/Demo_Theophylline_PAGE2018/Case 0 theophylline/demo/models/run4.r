run4 <- function() {
  data = "theo_sd"
  desc = "same as run1 but IIV on CL and V only"
  ref = "run1"
  imp = 1
  est  = "nlme"
  control<-list()
  ini({
    tka <- .5
    tcl <- -3.2
    tv <- -1
    eta.cl ~ 2
    eta.v ~ 1
    add.err <- 0.1
  })
  model({
    ka <- exp(tka)
    cl <- exp(tcl + eta.cl)
    v <- exp(tv + eta.v)
    linCmt() ~ add(add.err)
  })
}
