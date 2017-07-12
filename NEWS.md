NEWS
====

For more fine-grained list of changes or to report a bug, consult 

* [The issues log](https://github.com/ropensci/rfishbase/issues)
* [The commit log](https://github.com/ropensci/rfishbase/commits/master)

Versioning
----------

Releases will be numbered with the following semantic versioning format:

<major>.<minor>.<patch>

And constructed with the following guidelines:

* Breaking backward compatibility bumps the major (and resets the minor 
  and patch)
* New additions without breaking backward compatibility bumps the minor 
  (and resets the patch)
* Bug fixes and misc changes bumps the patch
* Following the RStudio convention, a .99 is appended after the patch
  number to indicate the development version on Github.  Any version
  Coming from Github will now use the .99 extension, which will never
  appear in a version number for the package on CRAN. 

For more information on SemVer, please visit http://semver.org/.

v2.2.0 (upcoming release)
-------
* bugfix for `validate_names()` ([#121](https://github.com/ropensci/rfishbase/issues/121))
* bugfix for `faoareas()` ([#123](https://github.com/ropensci/rfishbase/issues/123))
* add `genetics()` endpoint ([#122](https://github.com/ropensci/rfishbase/issues/122))
* add `taxonomy()` endpoint ([#126](https://github.com/ropensci/rfishbase/issues/126))

v2.1.2   (2017-04-19)
------

* bugfix avoid spurious warning when using http instead of https API
* bugfix to for taxa table as used on sealifebase


v2.1.1
-------


* bugfix for endpoints with inconsistent spelling of SpecCode column 
(e.g. maturity, diet, ecosystem, morphology, morphometrics, popchar, poplf).
* Now properly queries by input species list
* Minor bug fixes for issues #77 #82 #83 #89 #93 #94 #95 #97 #99 #100 (see https://github.com/ropensci/rfishbase/issues)

v2.1.0
------

* improve sealifebase operations
* Updates for optimized version of fishbaseapi
* More stable tests

v2.0.3
------

* Use `dontrun` instead of `\donttest` in the documentation.  Apparently CRAN has decided to run donttest blocks in the examples, which can fail on their test servers when transferring data files over a network connection (which is why they were marked `donttest` in the first place.)

v2.0.2
------

* bugfix for package unit tests on some platforms

v2.0.1
------

First official release of the new rfishbase package, a non-backwards
compatible replacement to all earlier versions of FishBase. See the
package vignette for a more detailed overview and introduction.
