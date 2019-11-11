models <- c('run1')
# Script to create combined results
library(xpose.nlmixr)
library(shinyMixR)
lapply(models,function(x){
  res      <- readRDS(paste0("./shinyMixR/",x,".res.rds"))
  ress     <- readRDS(paste0("./shinyMixR/",x,".ressum.rds"))
  xpdb     <- xpose_data_nlmixr(res)
  dir.create(paste0("./analysis/",x),showWarnings=FALSE)

  ptbl    <- data.frame(Parameter = row.names(ress$partbl),
                        Estimate  = sigdigs(ress$partbl$Estimate),
                        SE        = sigdigs(ress$partbl$SE),
                        CV        = sigdigs(ress$partbl$CV),
                        BTCI      = paste0(sigdigs(ress$partbl$Untransformed)," (",sigdigs(ress$partbl$Lower.ci),", ",sigdigs(ress$partbl$Upper.ci),")"),
                        BSV       = ress$partbl$BSV.cv.sd,
                        Shrink    = gsub("<|>|=","",ress$partbl$`Shrink(SD)%`)
                        )

  R3port::html_list(ptbl,porder=FALSE,title="Parameter table",out=paste0("./analysis/",x,"/01partable.html"),show=FALSE)
  gof_plot(res, outnm=paste0("./analysis/",x,"/02gofall.html"),mdlnm=x,show=FALSE)
  fit_plot(res, outnm=paste0("./analysis/",x,"/03indfit.html"),mdlnm=x,show=FALSE)
  pl1 <- try(prm_vs_iteration(xpdb))
  pl2 <- absval_res_vs_idv(xpdb, res = 'IWRES')
  pl3 <- absval_res_vs_pred(xpdb, res = 'IWRES')
  pl4 <- res_distrib(xpdb)
  pll <- if(class(pl1)=="try-error") list(pl2,pl3,pl4) else list(pl1,pl2,pl3,pl4)
  R3port::html_plot(pll,out=paste0("./analysis/",x,"/04other.html"),show=FALSE,title="other plots")
  R3port::html_combine(combine=paste0("./analysis/",x),out="report.html",show=TRUE,
                       template=paste0(system.file(package="R3port"),"/bootstrap.html"),toctheme=TRUE)
})
