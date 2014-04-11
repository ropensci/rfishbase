context("fao area")

data(fishbase)
out <- getFaoArea(fish.data[1:3])

# or using species names:
ids <- findSpecies(c("Coris_pictoides", "Labropsis_australis"))
out <- getFaoArea(fish.data[ids])

