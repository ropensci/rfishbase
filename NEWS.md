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

For more information on SemVer, please visit http://semver.org/.

v 5.0.1
-------
Fix the issue faced by users in China who can't access the URL https://huggingface.co directly. When the user's ip address is detected to be in China, it will be automatically switched to the mirror URL https://hf-mirror.com

v 5.0.0
-------

Another streamlined re-design following new abilities for data hosting and access.
This release relies on a HuggingFace datasets hosting for data and metadata hosting
in parquet and schema.org.  

Data access is simplified to use the simple HuggingFace datasets API instead
of the previous contentid-based resolution. This allows metadata to be defined
with directly alongside the data platform independent of the R package.  

A simplified access protocol relies on `duckdbfs` for direct reads of tables.
Several functions previously used only to manage connections are now deprecated
or removed, along with a significant number of dependencies.

Core use still centers around the same package API using the `fb_tbl()` function,
with legacy helper functions for common tables like `species()` are still accessible and
can still optionally filter by species name where appropriate.  As before, loading the
full tables and sub-setting manually is still recommended.

Historic helper  functions like `load_taxa()` (combining the taxonomic classification from Species,
Genus, Family and Order tables), `validate_names()`, and `common_to_sci()` and 
`sci_to_common()` should be in working order, all using table-based outputs.


v 4.1.1
-------

* hotfix for bug in 4.1.0 on Windows -- `duckdb` `httpfs` on windows created `segfault`

v 4.1.0
--------

* New data release, v23.01 (fishbase & sealifebase)
* direct URL-based import supported, `contentid` now a fallback method.
* set option "rfishbase_local_db" = TRUE to create a local copy, otherwise will use a remote copy.
  Local copy will get better performance after initial import, but may experience conflicts when
  `duckdb` is upgraded or when multiple sessions attempt to access the directory.  Remove the default
  storage directory (given by `db_dir()`) after upgrading duckdb if using a local copy.  

Note that with `hash-archive.org` resolver is down, and software-heritage API has strict rate limits,
so direct URL access is preferable.  

v 4.0.0
--------

* Major upgrade that introduces content-identifier based downloads and parquet-backed database interface.
  Provides improved access to all tables and improved performance.
* See README or details

v 3.1.9
-------

* avoid GitHub API calls to determine versions.

v 3.1.8
-------

use `collect()` on taxa_tbl()

v 3.1.7
-------

- Avoid needless warning about `arrange()`

v 3.1.6
-------

- ensure any test needing internet connection is "fails gracefully" with
  no warnings or errors whenever tests are run without internet or the 
  CRAN test environment where internet connectivity may be unreliable.

v 3.1.5
-------

- replace rappdirs with base R tools

v 3.1.4
-------

- Uses `arkdb` with `duckdb` as database backend
- resolve compatibility issues

v 3.0.5
--------

- `validate_names()` has been rewritten [#170]

v 3.0.4
--------

- use latest version by default [#164]

v 3.0.3
------

- fix bug in sealifebase name resolution [#154]

v 3.0.2
--------

- fix missing function endpoint for `diet_items()` [#158]


v 3.0.1
--------

- patch for upcoming R release with staged installs
- patch common_names to allow omitting species_list for full table (#156)

v 3.0.0
------

v 3.0.0 accesses a new static API for `fishbase` with in-memory
memoization that significantly improves performance, particularly
for large queries.  

- Functions no longer have default limits on returns, so pagination
  is never involved -- all functions now return full set of available
  results.  
- Almost all functions can be called without arguments (e.g. without
  a species list) to return the complete record of the requested table.
- Various minor issues in some functions have been resolved, see 
  <https://github.com/ropensci/rfishbase/issues/> for details.


v2.2.0 
-------

(not released to CRAN, rolled into 3.0 release)

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
