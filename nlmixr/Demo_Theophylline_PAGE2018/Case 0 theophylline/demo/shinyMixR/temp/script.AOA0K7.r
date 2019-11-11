library(nlmixr)
options(keep.source = TRUE)
if(!exists("theo_sd", envir=.GlobalEnv)) {
  if(file.exists("./data/theo_sd.rds")){
    data_nlm <- readRDS("./data/theo_sd.rds")
  }else if(file.exists("./data/theo_sd.csv")){
    data_nlm <- read.csv("./data/theo_sd.csv")
  }
}else{
  data_nlm <- theo_sd
}
source("/home/rstudio/docs/Rpackages/shinyMixR/Case0.PageDemo/demo/models/run1.r")
setwd("shinyMixR/temp")
modres <- try(nlmixr(run1, data=data_nlm, est="saem",control=list()))

if(length(class(modres))>1 && class(modres)!="try-error"){
  saveRDS(modres,file="../run1.res.rds")
  saveRDS(list(OBJF=modres$objective,partbl=modres$par.fixed,omega=modres$omega,
               tottime=rowSums(modres$time)),file="../run1.ressum.rds")
}

