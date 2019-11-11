# Intro-Shiny-RMD-Research-Drug-Development in Pennsylvania by Phil Bowsher on Nov 12, 2019

Live Presentation is here:

https://colorado.rstudio.com/rsc/content/3437/

Other apps and reports are here:

IMMUNOGENICITY App:

https://beta.rstudioconnect.com/content/2769/

IMMUNOGENICITY website:

https://beta.rstudioconnect.com/content/2770/

IMMUNOGENICITY Distill website:

https://beta.rstudioconnect.com/content/5200/

IMMUNOGENICITY HTML Template:

https://beta.rstudioconnect.com/content/2771/

IMMUNOGENICITY Book Tech Document:

https://beta.rstudioconnect.com/content/2899/

IMMUNOGENICITY Blog blogdown website:

https://beta.rstudioconnect.com/content/2972/

Live Plumber API for the OpenFDA API:

https://beta.rstudioconnect.com/content/2975/outcomes?drug=FUROSEMIDE
*Try PREDNISONE at the end of the link

https://beta.rstudioconnect.com/content/2975/__swagger__/

Click GET, Try it Out, then enter PREDNISONE and then hit Execute. Details show top 10 adverse events in the Response body blow.

Starbucks:

https://beta.rstudioconnect.com/content/2760/viewer-rpubs-774073c8e465.html

Basic Shiny:

https://beta.rstudioconnect.com/content/2761/

Interactive Plot:

https://beta.rstudioconnect.com/content/2763/

Flex ToothGrowth:

https://beta.rstudioconnect.com/content/2765/Flex_No_Shiny_ToothGrowth.html

Shiny Plots ToothGrowth:

https://beta.rstudioconnect.com/content/2766/

Flex Shiny:

https://beta.rstudioconnect.com/content/2767/

Crosstalk:

https://beta.rstudioconnect.com/content/2768/crosstalk_toothgrowth.html

Presentations and code from workshop.

Requires the following packages from CRAN:

```r
install.packages(c("leaflet", "shiny", "shinydashboard", "rmarkdown", "flexdashboard", "ggplot2", "plotly", "tidyverse"))
``` 

To access to the OpenFDA API from R, which uses the jsonlite and magrittr packages, you'll need the devtools package to install it as the library has not yet been added to CRAN, so follow these steps:

```r
install.packages("devtools")
```

Once devtools is installed, you can grab this package:

```r
library("devtools")
devtools::install_github("ropenhealth/openfda")
```
Load it in like any other package:

```r
library("openfda")
```

An up-to-date version of RStudio is also recommended.

R 3.4.4 used for examples.

Links/examples reviewed in the following order:

## **Shiny**

http://shiny.rstudio.com/

    A web application framework for R.

## **R Markdown**

http://rmarkdown.rstudio.com/
  
    R Markdown provides an authoring framework for data science and documents are fully reproducible and support dozens of static and dynamic output formats.

## **HTML Widgets**

http://www.htmlwidgets.org/

    R bindings to JavaScript libraries.
    
## **Applications in Drug Development**

    Live apps, analysis, tools and research.