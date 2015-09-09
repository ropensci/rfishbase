Dear CRAN Maintainers,

This release fixes the issues you highlighted that arise when running those examples that have been marked `donttest`.  Those examples are now marked `dontrun`, and should not be run regularly on CRAN architecture, since these tests involve data transfer over the network and it appears that the CRAN servers were occassionally failing to run these tests due to curl transferring only a partial file.  These tests are run nightly on our own travis-based continuous integration system anyway, so testing should not suffer by this change.

Thank you for your diligence in bringing this to our attention and for your patience while we addressed this issue, as well as all you do for the R community.

Sincerely,

Carl Boettiger