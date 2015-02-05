buildserver-scripts
===================

To be of any real use in a production environment any Linux distribution must be capable of being installed in a repeatable and reliable manner. In this regard Gentoo Linux is no different however, as it is not distributed as binary packages, it is impossible to deploy "as-is" because, due to differences in configuration between machines, what works on the test system may not be exactly what is produced when the build is performed on the production system. It is also extremely hard to be sure that the exact same versions of the packages tested are deployed when building from source as minor fixes are often deployed without a corresponding revision bump of the ebuild or distributed files.

These "shortcomings" of Gentoo Linux can be turned to an advantage by running an in-house "build server" to produce binary packages which can be tested and later deployed as if a "normal" binary distribution was being used. This task is daunting to the average system administrator however as a great many files need to be kept synchronised to ensure that the binary packages produced on the build-server and tested using an appropriate test framework are actually those which are deployed. This task can be made even more complex as Gentoo Linux uses a variety of configuration files which alter the visibility of packages to the package management system in ways which are not immediately obvious to system administrators new to this distribution.

The utilities provided in this package aim to assist the deployment of such a build-server in a production environment by providing a means to ensure that the portage tree, overlays, configuration files and the all important binary packages are kept synchronised. There are also safeguards to ensure that failed updates of the build-spaces do not accidentally result in defective packages being deployed. The utilities in this package are designed to work in concert with those provided in the buildspace-scripts package. 

More information may be found at:

http://www.mad-hacking.net/software/linux/gentoo/buildserver-scripts/index.xml

http://www.mad-hacking.net/documentation/linux/deployment/buildserver/index.xml