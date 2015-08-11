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


fishbase <- load_taxa(update = TRUE)
fishbase$FBname <- replace_non_ascii(fishbase$FBname)
save("fishbase", file = "data/fishbase.rda", compress = "xz")

sealifebase <- load_taxa(update = TRUE, server = "http://fishbase.ropensci.org/sealifebase", limit=200000L)
sealifebase$FBname <- replace_non_ascii(sealifebase$FBname)
save("sealifebase", file = "data/sealifebase.rda", compress = "xz")

