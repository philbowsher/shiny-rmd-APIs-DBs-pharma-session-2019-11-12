#
# This is a Plumber API. You can run the API by clicking
# the 'Run API' button above.
#
# Find out more about building APIs with Plumber here:
#
#    https://www.rplumber.io/
#

library(plumber)
library(dplyr)
library(tidyquant)

#* @apiTitle Stock Volatility

#* Return the stock volatiltiy for the input stock ticker
#* @param ticker The stock ticker
#* @get /volatiltiy
function(ticker = 'GOOG') {
  stop("TODO Implement this function!")
}
