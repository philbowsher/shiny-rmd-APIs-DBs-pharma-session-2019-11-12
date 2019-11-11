# devtools::install_github("rstudio/bookdown")
library(bookdown)

bookdown::render_book("index.Rmd", "bookdown::gitbook")
