# Shiny Day - Nov 2018

http://colorado.rstudio.com:3939/content/1607/

The material in the repo supports a presentation given in November 2018.
All materials are available at 

https://github.com/philbowsher/Shiny-Day-2018-Adverse-Events-Visualization-Shiny-Workshop

https://github.com/slopp/2018-shiny-day.


## Part 1: Introduction to Shiny

To begin, we'll work with the openFDA API to explore adverse event data.

`02_GGplot2_adverse_events_plots` - This file includes our code to query the API and generate a few static plots.

`04_RMD_adverse_events` - This file takes the same code snippets, but incorporates them into a HTML dashboard using the [flexdashboard](https://rstudio.github.io/flexdashboard) package. Markdown syntax is used to layout the plots into a dashboard. The R Markdown document includes a parameter, `params$drug`, so that different versions of the dashboard can easily be created for different drugs.

`05_Shiny_adverse_events` - This file builds off the flexdashboard and adds `runtime:shiny` to turn the static HTML file into an intereactive Shiny application. The shiny application makes it easy to explore the affect of age on the distribution of adverse events. Notice the minimal code changes required to turn the document into an app!

## Part 2: Advanced Shiny

First, we'll take a brief look at a version of the adverse events report that can be scheduled and emails out a PPT presentation. See https://github.com/sol-eng/adverse-events to view the full code. This type of scheduled report helps after stakeholders have played with a Shiny app and ask for "regular updates".

`04-crosstalk.R` - Next, we'll take a brief detour to explore crosstalk and we'll go from regular ggplot2 charts to interactive, linked charts. 

Finally, we'll take a look at a more complex shiny app that makes use of [bookmarking](https://shiny.rstudio.com/articles/bookmarking-state.html) and [modules](https://shiny.rstudio.com/articles/modules.html). We'll also look at the new [shinyreactlog](https://github.com/rstudio/shinyreactlog). 

The code for this application is available [here](https://github.com/jcheng5/rpharma-demo).

