# nlmixr course PAGE2108
# Case example 0: Demo 
# Author: Teun Post, Richard Hooijmaijers
# This script shows how nlmixr can be used and to demo the shinyMixR interface

# PART 1. RUNNING THE MODEL

# ------------------------
# 1. Using nlmixr directly
library(nlmixr)

# define the model
basemod <- function() {
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

# run nlmixr with previously defined model (data is present in package!)
fit <- nlmixr(basemod,theo_sd,est="saem")

# -----------------------------------------
# 1. Using shinyMixR in interactive session
library(shinyMixR)

# the model is defined in a separate file. information regarding models and data is
# maintained in a project object which is automatically loaded when a model is submitted
# models are submitted by default in a separate R session
run_nmx("run1")

# Progress can be read from external file
cat(readLines("shinyMixR/temp/run1.prog.txt"),sep="\n")

# the interface can be opened and model(s) can be submitted in run model widget
# Within this widget also the progress can be assessed
# -- Be aware that the same model is not already running interactively --
# run_shinymixr()
# Show later on

# PART 2. ANALYSING THE RESULTS
fit
str(fit)
plot(fit)
library(xpose.nlmixr)

# ------------------------------
# 1. Using xpose.nlmixr directly
xpdb <- xpose_data_nlmixr(fit)

dv_vs_pred(xpdb)
dv_vs_ipred(xpdb)
res_vs_pred(xpdb)
res_vs_idv(xpdb)
prm_vs_iteration(xpdb)
absval_res_vs_idv(xpdb, res = 'IWRES')
absval_res_vs_pred(xpdb, res = 'IWRES')
ind_plots(xpdb, nrow=3, ncol=4)
res_distrib(xpdb)
nlmixr::vpc(fit,nsim=500, show=list(obs_dv=T))

# Results can be exported by using for example pdf(file="results.pdf") ... dev.off()

# ------------------------------------------------------
# 1. Using xpose.nlmixr/shinyMixr in interactive session
res      <- readRDS("shinyMixR/run1.res.rds")
xpdb2    <- xpose_data_nlmixr(res)

gof_plot(res)             # combine multiple GOF at once
res_vs_pred(xpdb2)        # xpose.nlmixr functions can be used directly
fit_plot(res,type="user") # "default ggplot" output can be created

# Results can be exported by the function, using the R3port package or with pdf() function e.g.
# gof_plot(res,outnm="gofplot.tex",mdlnm="run1")
# pl <- prm_vs_iteration(xpdb2); R3port::ltx_plot(pl,out="plot.tex")
# pdf("results.pdf"); fit_plot(res); dev.off()

# -----------------------------------------
# 2. Using xpose.nlmixr/shinyMixr interface
# There are widgets for a few default plots, user scripts are possible in the script widget
# plots are by default saved in the analyis folder and made available in the interface
run_shinymixr()

