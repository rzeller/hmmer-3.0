# Top level Makefile for HMMER
# 
# On most Unices, you can build the package without modifying anything 
#   by just typing "./configure; make".
#
# Post-configuration, you may still want to modify the following make variables:
#   BINDIR  - where the executables will be installed by a 'make install'
#   MANDIR  - where the man pages will be installed by a 'make install'
#   CC      - which compiler to use
#   CFLAGS  - compiler flags to use
#
# We generally follow GNU coding standards. ${prefix} might be
# /usr/local.  ${exec_prefix} gives you some flexibility for
# installing architecture dependent files (e.g. the programs): an
# example ${exec_prefix} might be /nfs/share/irix64/
#
# You can also provide DESTDIR from the commandline, for installation
# in a buildroot; for example:
#     make DESTDIR=~/rpm/tmp/buildroot install
# By default, DESTDIR is null.
#
# SVN $Id: Makefile.in 3159 2010-02-10 16:10:21Z eddys $


# VPATH and shell configuration
top_srcdir     = .
srcdir         = .


SHELL          = /bin/sh
SUFFIXES       = 
SUFFIXES       = .c .o

# Installation targets
#
prefix      = /usr/local
exec_prefix = ${prefix}
datarootdir = ${prefix}/share
bindir      = ${exec_prefix}/bin
mandir      = ${datarootdir}/man
man1dir     = ${mandir}/man1
manext      = .1

# Compiler configuration
#
CC        = gcc -std=gnu99
CFLAGS    = -O3 -fomit-frame-pointer -malign-double -fstrict-aliasing
LDFLAGS   = -static 
SIMDFLAGS = -msse2
CPPFLAGS  = 

# Other tools
#
INSTMAN   = cp
AR        = /usr/bin/ar rcv
LN        = ln
RANLIB    = ranlib
COMPRESS  = gzip

#######################################################################
## You should not need to modify below this line.
## Much of it is concerned with maintenance of the development version
## and building the release (indeed, several commands will only work at
## Janelia)
#######
PACKAGE     = HMMER
BASENAME    = hmmer
RELEASE     = 3.0
RELEASEDATE = "March 2010"
COPYRIGHT   = "Copyright (C) 2010 Howard Hughes Medical Institute."
LICENSELINE = "Freely distributed under the GNU General Public License (GPLv3)."
LICENSETAG  = gnu
REPOSITORY  = https://svn.janelia.org/eddylab/eddys/src/

ESLDIR      = easel
SRCDIR      = src
TESTDIR     = testsuite
PMARKDIR    = profmark
IMPLDIR     = ${SRCDIR}/impl_sse

# The program lists below for HMMER are not necessarily
# a complete manifest. They are the list of stable programs that the
# package will install. Eventually there will be a man page for each one of them
# in the appropriate places (documentation/man for HMMER)
#
PROGS = \
	hmmalign\
	hmmbuild\
	hmmconvert\
	hmmemit\
	hmmfetch\
	hmmpress\
	hmmscan\
	hmmsearch\
	hmmsim\
	hmmstat\
	jackhmmer\
	phmmer

# all: Compile all documented executables.
#      (Excludes test programs.)
#
all: libraries programs

# check: Run test suites.
check:
			${MAKE} all
			${MAKE} utests
			${MAKE} itests
			${MAKE} testsuite
	cd ${ESLDIR};   ${MAKE} run_sqc
	cd ${TESTDIR};  ${MAKE} run_sqc

# dev: compile all executables, including drivers.
dev: libraries programs utests itests misc


# rules to build the libraries
libraries: easel_lib impl_lib hmmer_lib

easel_lib:
	cd ${ESLDIR};  ${MAKE} libeasel.a

impl_lib:
	cd ${IMPLDIR}; ${MAKE} libhmmerimpl.a

hmmer_lib:
	cd ${SRCDIR};  ${MAKE} libhmmer.a

# rules to build the programs
programs: easel_progs hmmer_progs profmark_progs

easel_progs: libraries
	cd ${ESLDIR};   ${MAKE} easel_progs

hmmer_progs: libraries
	cd ${SRCDIR};   ${MAKE} hmmer_progs	

profmark_progs: libraries
	cd ${PMARKDIR}; ${MAKE} profmark_progs

# rules to build the unit tests
utests: easel_utests hmmer_utests

itests:              hmmer_itests

easel_utests: libraries
	cd ${ESLDIR};   ${MAKE} easel_utests

hmmer_utests: libraries
	cd ${SRCDIR};   ${MAKE} hmmer_utests

hmmer_itests: libraries
	cd ${SRCDIR};   ${MAKE} hmmer_itests

# rules to build the miscellaneous programs
misc: hmmer_stats hmmer_benchmarks hmmer_benchmarks hmmer_examples testsuite

hmmer_stats: libraries
	cd ${SRCDIR};   ${MAKE} hmmer_stats

hmmer_benchmarks: libraries
	cd ${SRCDIR};   ${MAKE} hmmer_benchmarks

hmmer_examples: libraries
	cd ${SRCDIR};   ${MAKE} hmmer_examples

testsuite: libraries
	cd ${TESTDIR};  ${MAKE} testsuite_progs


# install: installs the binaries in ${bindir}/
#          When man pages are done, will install man pages in MANDIR/man1/  (e.g. if MANSUFFIX is 1)
#          Creates these directories if they don't exist.
#          Prefix those paths with ${DESTDIR} (rarely used, usually null;
#          may be set on a make command line when building contrib RPMs).
install: libraries programs
	cd ${PMARKDIR}; ${MAKE} profmark_progs
	-mkdir -p ${DESTDIR}${bindir}
	for file in $(PROGS); do\
	   cp ${SRCDIR}/$$file ${DESTDIR}${bindir}/;\
	done
#	-mkdir -p ${DESTDIR}/${MANDIR}/man${MANSUFFIX}
#	-for file in hmmer $(PROGS); do\
#	   $(INSTMAN) documentation/man/$$file.man ${DESTDIR}$(MANDIR)/man$(MANSUFFIX)/$$file.$(MANSUFFIX);\
#	done

# uninstall: Reverses the steps of "make install".
#
uninstall: 
	for file in $(PROGS); do\
	   rm ${DESTDIR}${bindir}/$$file;\
	done
#	for file in hmmer $(PROGS); do\
#	   rm $(MANDIR)/man$(MANSUFFIX)/$$file.$(MANSUFFIX);\
#	done


# "make clean" removes almost everything except configuration files.
#
clean:
	if test -d src;       then (cd src;       ${MAKE} clean); fi
	if test -d easel;     then (cd easel;     ${MAKE} clean); fi
	if test -d profmark;  then (cd profmark;  ${MAKE} clean); fi
	if test -d testsuite; then (cd testsuite; ${MAKE} clean); fi
	if test -d documentation/userguide; then (cd documentation/userguide; ${MAKE} clean); fi
	-rm -f *.o *~ Makefile.bak core TAGS gmon.out

# "make distclean" leaves a pristine source distribution.
#
distclean:
#	-rm -rf binaries
	-rm config.log config.status
	-rm -rf autom4te.cache
	-rm -f *.o *~ Makefile.bak core TAGS gmon.out
	-rm -f cscope.po.out cscope.out cscope.in.out cscope.files
	if test -d src;           then (cd src;       ${MAKE} distclean); fi
	if test -d easel;         then (cd easel;     ${MAKE} distclean); fi
	if test -d profmark;      then (cd profmark;  ${MAKE} distclean); fi
	if test -d testsuite;     then (cd testsuite; ${MAKE} distclean); fi
	if test -d documentation/userguide; then (cd documentation/userguide; ${MAKE} distclean); fi
	-rm Makefile

# "make binclean" is special: it cleans up and leaves only a binary
#       distribution behind, including configured Makefiles.
#
#	(cd src;       make binclean)
# binclean:
# 	if test -d src;       then (cd src;       make binclean); fi
# 	if test -d easel;     then (cd easel;     make binclean); fi
# 	if test -d profmark;  then (cd profmark;  make binclean); fi
# 	if test -d testsuite; then (cd testsuite; make binclean); fi
# 	-rm -f *.o *~ Makefile.bak core TAGS gmon.out
# 	-rm config.log config.status
#	-rm -rf autom4te.cache

# doc:  build the Userguide and on-line manual
#
#doc:
#	(cd documentation/userguide; make)


# make optcheck:
#    Check that all program options are documented in man pages,
#    and tested in sqc scripts, by running ssdk's checkoptions.pl 
#    script on each program. 
#    
# optcheck:
# 	@echo Checking options for consistency and documentation...
# 	@for prog in $(PROGS); do\
# 	   ssdk/checkoptions.pl src/$$prog documentation/man/$$prog.man testsuite/exercises.sqc testsuite/exercises-threaded.sqc testsuite/exercises-pvm.sqc;\
# 	done


TAGS:
	etags ${SRCDIR}/*.c ${SRCDIR}/*.h ${SRCDIR}/p7_config.h.in Makefile.in 
	etags -a profmark/*.c profmark/Makefile.in 
	etags -a documentation/userguide/*.tex documentation/userguide/Makefile.in
	etags -a documentation/man/*.man 
#	etags -a documentation/devguide/*.tex 
	etags -a ${SRCDIR}/impl_sse/*.c   ${SRCDIR}/impl_sse/*.h   ${SRCDIR}/impl_sse/Makefile.in 
	etags -a ${SRCDIR}/impl_vmx/*.c   ${SRCDIR}/impl_vmx/*.h   ${SRCDIR}/impl_vmx/Makefile.in 
	etags -a ${SRCDIR}/impl_dummy/*.c ${SRCDIR}/impl_dummy/*.h ${SRCDIR}/impl_dummy/Makefile.in 
	(cd easel; etags -a -o ../TAGS *.c *.h *.tex documentation/*.tex miniapps/*.c miniapps/*.man Makefile.in)


###########
# HMMER - Biological sequence analysis with profile HMMs
# Version 3.0; March 2010
# Copyright (C) 2010 Howard Hughes Medical Institute.
# Other copyrights also apply. See the COPYRIGHT file for a full list.
# 
# HMMER is distributed under the terms of the GNU General Public License
# (GPLv3). See the LICENSE file for details.
###########
