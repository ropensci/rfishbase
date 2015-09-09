#' popchar
#' 
#' Table of maximum length (Lmax), weight (Wmax) and age (tmax)
#' 
#' @details See references for official documentation.  From FishBase.org:
#' This table presents information on maximum length (Lmax), 
#' weight (Wmax) and age (tmax) from various localities where a species
#' occurs. The largest values from this table are also entered in the
#' SPECIES table. The POPCHAR table also indicates whether the Lmax,
#' Wmax and tmax values or various combinations thereof refer to the
#' same individual fish.
#' @references http://www.fishbase.org/manual/english/fishbasethe_popchar_table.htm
#' @inheritParams species
#' @export
#' @examples \dontrun{
#' popchar("Oreochromis niloticus")
#' }
popchar <- endpoint("popchar")



#' popgrowth
#' 
#' This table contains information on growth, natural mortality and length
#' at first maturity, which serve as inputs to many fish stock assessment
#' models. The data can also be used to generate empirical relationships
#' between growth parameters or natural mortality estimates, and their
#' correlates (e.g., body shape, temperature, etc.), a line of research
#' that is useful both for stock assessment and for increasing understanding
#' of the evolution of life-history strategies
#' 
#' @inheritParams species
#' @return a table of population growth information by species; see details
#' @export
#' @references http://www.fishbase.org/manual/english/fishbasethe_popgrowth_table.htm
#' @examples \dontrun{
#' popgrowth("Oreochromis niloticus")
#' }
popgrowth <- endpoint("popgrowth")



#' length_freq
#' 
#' return a table of species fooditems
#' @references http://www.fishbase.org/manual/english/lengthfrequency.htm
#' @inheritParams species
#' @export length_freq poplf
#' @aliases length_freq poplf
#' @return a table of length_freq information by species; see details
#' @examples \dontrun{
#' length_freq("Oreochromis niloticus")
#' }
length_freq <- endpoint("poplf")

poplf <- length_freq

#' length_length
#' 
#' return a table of lengths
#' 
#' @details This table contains relationships for the conversion of one length type to another for over 8,000
#' species of fish, derived from different publications, e.g. Moutopoulos and Stergiou (2002) and
#' Gaygusuz et al (2006), or from fish pictures, e.g. Collette and Nauen (1983), Compagno (1984)
#' and Randall (1997). The relationships, which always refer to centimeters, may consist either of a
#' regression linking two length types, of the form:
#'  Length type (2) = a + b x Length type (1)
#' Length type (2) = b' x Length type (1)
#' The available length types are, as elsewhere in FishBase,
#' TL = total length;
#' FL = fork length;
#' SL = standard length;
#' WD = width (in rays);
#' OT = other type (to be specified in the Comment field).
#' When a version of equation (1) is presented, the length range, the number of fish used in the regression,
#' the sex and the correlation coefficient are presented, if available.
#' When a version of equation (2) is presented, the range and the correlation coefficient are omitted,
#' as the ratio in (2) will usually be estimated from a single specimen, or a few fish covering a narrow
#' range of lengths. 
#' @references http://www.fishbase.org/manual/english/PDF/FB_Book_CBinohlan_Length-Length_RF_JG.pdf
#' @inheritParams species
#' @return a table of lengths
#' @export popll length_length
#' @aliases popll length_length
#' @examples \dontrun{
#' length_length("Oreochromis niloticus")
#' }
length_length <- endpoint("popll")

popll <- length_length


#' length_weight
#' 
#' The LENGTH-WEIGHT table presents the a and b values of over 5,000
#' length-weight relationships of the form W = a x Lb, pertaining to about over 2,000 fish species.
#' 
#' @details See references for official documentation.  From FishBase.org:
#' Length-weight relationships are important in fisheries science, 
#' notably to raise length-frequency samples to total catch, or to
#' estimate biomass from underwater length observations. 
#' The units of length and weight in FishBase are centimeter and gram, respectively. 
#' Thus when length-weight relationships are not in cm-g, the intercept 'a' 
#' is transformed as follows:
#' 
#' a'(cm, g) = a (mm, g)*10^b
#' a'(cm, g) = a (cm, kg)*1000
#' a'(cm, g) = a (mm, mg)*10^b/1000
#' a'(cm, g) = a (mm, kg)*10^b*1000
#' 
#' However, published length-weight relationships are sometimes difficult to use,
#' as they may be based on a length measurement type (e.g., fork length) different
#' from ones length measurements (expressed e.g., as total length).
#' Therefore, to facilitate conversion between length types, an additional
#' LENGTH-LENGTH table, #' presented below, was devised which presents linear
#' regressions or ratios linking length types (e.g., FL vs. TL). 
#' We included a calculated field with the weight of a 10 cm fish (which
#' should be in the order of 10 g for normal, fusiform shaped fish),
#' to allow identification of gross errors, given knowledge of the body
#' form of a species. 
#'  
#' @references http://www.fishbase.org/manual/english/fishbasethe_length_weight_table.htm
#' @return a table of length_weight information by species; see details
#' @inheritParams species
#' @export length_weight poplw
#' @aliases length_weight poplw
#' @examples \dontrun{
#' length_weight("Oreochromis niloticus")
#' }
length_weight <- endpoint("poplw")

poplw <- length_weight