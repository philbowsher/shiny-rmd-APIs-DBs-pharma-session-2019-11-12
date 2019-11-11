library(plumber)
p <- plumber::plumb(file = "plumber.R")
rstudioapi::viewer("http://charleston.rstudio.com:8000/__swagger__/")
p$run(port = 8000, host  = "0.0.0.0")

# http://charleston.rstudio.com:8000/outcomes?drug=FUROSEMIDE


