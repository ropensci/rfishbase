#!/usr/bin/Rscript
library(knitr)
## Formatting for printed numbers
render_markdown()
knit_hooks$set(inline = function(x) {
  if(is.numeric(x))
   I(prettyNum(round(x,2), big.mark=","))
})
pdf.options(pointsize = 10)  # smaller pointsize for recording plots

opts_chunk$set(cache=TRUE, fig.path='figure/', dev='Cairo_png',
  fig.width=5, fig.height=5, cache.path = 'cache-local/', par=TRUE)

opts_chunk$set(warning=FALSE, message=FALSE, comment=NA, tidy=FALSE, verbose=TRUE)

knit_hooks$set(par=function(before, options, envir){
  if (before && options$fig.show!='none') 
    par(mar=c(4,4,.1,.1), cex.lab=.95, cex.axis=.9, mgp=c(2,.7,0), tcl=-.3)
})

options(xtable.type = 'html')
# surpress interactive plots
options(device = function(width=5, height=5){ pdf(NULL, width=width, height=height) })


opts_knit$set(upload.fun = socialR::flickr.url)
opts_chunk$set(cache.path = 'cache-upload/')
knit("rfishbase.Rmd")
