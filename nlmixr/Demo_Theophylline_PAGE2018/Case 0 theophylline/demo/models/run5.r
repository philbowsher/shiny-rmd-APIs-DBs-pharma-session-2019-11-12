run5 <- function() {
  data = "theo_sd"
  desc = "same as run1 but IIV on CL  only"
  ref = "run1"
  imp = 1
  est  = "nlme"
  control<-list()
  ini({
    tka <- .5
    tcl <- -3.2
    tv <- -1
    eta.cl ~ 2
    add.err <- 0.1
  })
  model({
    ka <- exp(tka)
    cl <- exp(tcl + eta.cl)
    v <- exp(tv)
    linCmt() ~ add(add.err)
  })
}
