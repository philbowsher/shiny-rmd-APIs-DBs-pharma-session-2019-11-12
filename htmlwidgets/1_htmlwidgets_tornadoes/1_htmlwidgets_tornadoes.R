# data are from 

# library("rgdal")

# Torn = readOGR(dsn = ".", layer = "torn")

# Torn$Year = as.integer(Torn$yr)
# Torn = subset(Torn, Year > 2010)

# View(Torn)

#Torn1 <- as_tibble(Torn)
#Torn1 %>% write_csv('Torn.csv')

library(tidyverse)

Torn <- read_csv("~/shiny-rmd-APIs-DBs-pharma-session-2019-11-12/Data/Torn/Torn3.csv")

Torn1 <- Torn[ which((Torn$st=='PA' | Torn$st=='NY') & Torn$yr== 2017), ]

View(Torn1)

library("leaflet") 

leaflet() %>% addTiles() %>% setView(-75.283043, 40.215179, zoom = 12) %>% 
  
  addMarkers(data = Torn1, lat = ~ slat, lng = ~ slon, popup = Torn1$date)

# Torn2 <- as_tibble(Torn1)

# Torn2 %>% write_csv('Torn2.csv')
