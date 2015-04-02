library("rfishbase")

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


all_taxa <- load_taxa(update = TRUE)
all_taxa$FBname <- replace_non_ascii(all_taxa$FBname)

save("all_taxa", file = "data/all_taxa.rda", compress = "xz")

