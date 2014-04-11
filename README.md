[![Build Status](https://travis-ci.org/ropensci/rfishbase.svg)](https://travis-ci.org/ropensci/rfishbase)


rfishbase
=========

 _Accessing data from FishBase using R_

`rfishbase` is a package for interfacing with the [fishbase.org](http://fishbase.org) database. It provides code to download and parse a local copy of fishbase, which can be used for rapid access for a variety of analysis functions.

- [Published copy in Journal of Fish Biology](http://dx.doi.org/10.1111/j.1095-8649.2012.03464.x)
- [Development version source code on github](https://github.com/ropensci/rfishbase)
- [HTML package documentation](http://ropensci.github.com/rfishbase/)
- [Report issues, bugs or feature requests](https://github.com/ropensci/rfishbase/issues)

Installation
------------

`rfishbase` is available [on CRAN](http://cran.r-project.org/web/packages/rfishbase/) and can be installed through the R package manager (see `install.packages`).  The latest (development) version is hosted here on github, and can be installed using the [devtools](https://github.com/hadley/devtools) package:

```r
library(devtools)
install_github("rfishbase", "ropensci")
```

Getting started
---------------

- Read our [tutorial](https://github.com/ropensci/rfishbase/blob/master/inst/doc/rfishbase/rfishbase_github.md)
- Browse the examples in the [documentation](http://ropensci.github.com/rfishbase/)


`rfishbase` is developed by [Carl Boettiger](https://github.com/cboettig) in collaboration with [Duncan Temple Lang](https://github.com/duncantl) and Peter Wainwright, and is part of the [rOpenSci project](http://github.com/ropensci).  This software, examples, and documentation are freely provided under the [CC0 license](http://creativecommons.org/publicdomain/zero/1.0/).

A [preprint](https://github.com/ropensci/rfishbase/blob/master/inst/doc/rfishbase/rfishbase_github.md) of our manuscript introducing the package can be found in the [inst/doc](https://github.com/ropensci/rfishbase/tree/master/inst/doc) directory.


Feature Requests
----------------

See something on FishBase that you cannot access using `rfishbase`?  Please request the feature using the [Issues Tracker](https://github.com/ropensci/rfishbase/issues) (or email me if you cannot be persuaded to create a Github account).  At this time, additional features must be added by [HTML Scraping]() because the FishBase team has not yet made the data available in a more machine-readable format.  This has several disadvantages, please see the section below.

HTML Scraping
-------------

The `rfishbase` package originally only parsed the summaryXML forms provided (a detailed description of this approach can be found [in my notes](http://carlboettiger.info/2011/08/26/fishbase-from-r-some-xml-parsing.html)), and only these functions are covered in the publication in Journal of Fish Biology.  Since then, users frequently [request](https://github.com/ropensci/rfishbase/issues) support for additional fields found on the HTML pages of FishBase that are not available in XML pages.  To provide this access, I have had to resort to HTML scraping.  This has several disadvantages:

- HTML scraping is slow to implement, since I must eyeball several examples of the relevant HTML source-code to determine the correct parsing strategy to extract the data.  (XML provides a consistent description of its format).

- HTML scraping is slow to run.  rfishbase can quickly query the XML database (since issue [#7](https://github.com/ropensci/rfishbase/issues/7) was resolved) and cache the XML data locally for almost instant access.  HTML scraping requires individual queries against each page, which can be particularly slow for requests including many species or on slow internet connections.


- HTML scraping is taxing on the fishbase servers.  In writing programmatic queries it can be easy to send a large number of requests to the FishBase servers that could cause them to run more slowly or even fail.  While `rfishbase` functions try to be maximally polite, using enforced pauses to prevent flooding the servers, this is harder to enforce in scraping, which is much more intense to begin with (some functions must navigate several link menus just to reliably reach the content requested).

- HTML scraping is error-prone.  It is much harder to guarentee that the data field we access is what we think it is, and not some other number or text that happens to be near by.  Differences in the HTML structure of different pages, or changes to the FishBase website might break these functions entirely.

Keep these caveats in mind when requesting or using one of the scraping functions.


A Better Solution?
-----------------

All these potential problems could be avoided, and much more data accessed more easily and reliably, if the FishBase repository provided an Application Programming Interface (API) allowing a machine to query the back-end databases more directly (such as through a RESTful interface), rather than requesting the HTML pages and parsing them.  There is interest among the FishBase team for this feature, but not the resources available to do so at this time.  For more information, see issue [#8](https://github.com/ropensci/rfishbase/issues/8).


Contributing
------------

Suggestions, bug reports, forks and pull requests are appreciated.  Get in touch.


References
----------

* Froese, R. and D. Pauly. Editors. 2011. FishBase. World Wide Web electronic publication. www.fishbase.org, version (08/2011).
* Carl Boettiger, Duncan Temple Lang, Peter Wainwright (2012). rfishbase: exploring, manipulating and visualizing FishBase data from R, 2030–2039. Journal of Fish Biology. 81 (6). doi:10.1111/j.1095-8649.2012.03464.x
