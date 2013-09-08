
require(fishbase)
data(fishbase)

ids <- getIds(fish.data[1:10])

sapply(ids, getTrophicLevel)
