


data(fishbase)
sex_swap <- which_fish("change sex", using="lifecycle", fish.data)
africa <- which_fish("Africa", using="distribution", fish.data)
names <- fish_names(fish.data[africa & sex_swap])

getPictures(names[[1]])
