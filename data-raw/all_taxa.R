library("rfishbase")


## See: https://t.co/DZP2GQ6f83 for a better alternative
## Function to strip ascii characters
find_non_ascii <- function(string){
  grep("I_WAS_NOT_ASCII", 
       iconv(string, "latin1", "ASCII", sub="I_WAS_NOT_ASCII"))

}
replace_non_ascii <-function(string){
    i <- find_non_ascii(string)
    non_ascii <- "áéíóúÁÉÍÓÚñÑüÜ’åôö"
    ascii <- "aeiouAEIOUnNuU'aoo"
    translated <- sapply(string[i], function(x) 
                         chartr(non_ascii, ascii, x))
    string[i] <- unname(translated)
    string
}


## This is much more comprehensive and offers improved mapping, but is _very slow_
#devtools::install_github('rich-iannone/UnidecodeR')
#library("UnidecodeR")


use_ascii <- function(df){
  for(i in 1:length(df)){
    df[[i]] <- replace_non_ascii(df[[i]])
    #df[[i]] <- unidecode(df[[i]], "all")
  }
}


fishbase <- load_taxa(update = TRUE)
fishbase$FBname <- replace_non_ascii(fishbase$FBname)
save("fishbase", file = "data/fishbase.rda", compress = "xz")

sealifebase <- load_taxa(update = TRUE, server = "http://fishbase.ropensci.org/sealifebase", limit=200000L)
sealifebase <- use_ascii(sealifebase)
save("sealifebase", file = "data/sealifebase.rda", compress = "xz")
  
