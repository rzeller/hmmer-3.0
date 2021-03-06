# HMMER SSE optimized implementation
#
# SRE, Wed Jul 30 10:49:13 2008 [Janelia]
# SVN $Id: Makefile.in 3179 2010-02-19 19:58:34Z farrarm $

top_srcdir = ../..
srcdir     = .
VPATH      =  ../../src

CC             = gcc -std=gnu99
CFLAGS         = -O3 -fomit-frame-pointer -malign-double -fstrict-aliasing -pthread
SIMDFLAGS      = -msse2
CPPFLAGS       = 
LDFLAGS        = 
DEFS           = -DHAVE_CONFIG_H
LIBS           = -Wl,--start-group -lhmmer -lhmmerimpl -Wl,--end-group -leasel  -lm
AR             = /usr/bin/ar rcv
RANLIB         = ranlib

ESLDIR         = ../../easel

SHELL          = /bin/sh
MYLIBDIRS      = -L${ESLDIR} -L.. -L.
MYINCDIRS      = -I${ESLDIR} \
		 -I${top_srcdir}/easel \
		 -I. \
		 -I.. \
		 -I${srcdir} \
		 -I${top_srcdir}/src

LIBDEP = ../libhmmer.a ./libhmmerimpl.a ${ESLDIR}/libeasel.a

OBJS =  decoding.o\
	fwdback.o\
	io.o\
	msvfilter.o\
	null2.o\
	optacc.o\
	stotrace.o\
	vitfilter.o\
	p7_omx.o\
	p7_oprofile.o\
	mpi.o

HDRS =  impl_sse.h

UTESTS = \
	decoding_utest\
	fwdback_utest\
	io_utest\
	msvfilter_utest\
	null2_utest\
	optacc_utest\
	stotrace_utest\
	vitfilter_utest

BENCHMARKS = \
	decoding_benchmark\
	fwdback_benchmark\
	msvfilter_benchmark\
	null2_benchmark\
	optacc_benchmark\
	stotrace_benchmark\
	vitfilter_benchmark

EXAMPLES =\
	fwdback_example\
	io_example\
	msvfilter_example\
	optacc_example\
	p7_oprofile_example\
	stotrace_example\
	vitfilter_example

all: impl_lib

check:
			${MAKE} libraries
			${MAKE} impl_utests

dev: libraries utests misc

libraries: easel_lib impl_lib hmmer_lib

easel_lib:
	cd ${ESLDIR}; ${MAKE} libeasel.a

hmmer_lib:
	cd ..; ${MAKE} hmmer_lib

impl_lib: libhmmerimpl.a

utests: libraries ${UTESTS}

misc: libraries ${BENCHMARKS} ${EXAMPLES}

impl_utests:      ${UTESTS}
impl_benchmarks:  ${BENCHMARKS}
impl_examples:    ${EXAMPLES}

libhmmerimpl.a: ${OBJS}
	$(AR) libhmmerimpl.a $?
	$(RANLIB) libhmmerimpl.a
	chmod 644 libhmmerimpl.a	

${OBJS}:   ${HDRS} ../hmmer.h

.c.o:  
	${CC} ${CFLAGS} ${SIMDFLAGS} ${CPPFLAGS} ${DEFS} ${PTHREAD_CFLAGS} ${MYINCDIRS} -o $@ -c $<

${UTESTS}: ${LIBDEP}
	@BASENAME=`echo $@ | sed -e 's/_utest//'| sed -e 's/^p7_//'` ;\
	DFLAG=`echo $${BASENAME} | sed -e 'y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/'`;\
	DFLAG=p7$${DFLAG}_TESTDRIVE ;\
	if test -e ${srcdir}/p7_$${BASENAME}.c; then \
           DFILE=${srcdir}/p7_$${BASENAME}.c ;\
        else \
           DFILE=${srcdir}/$${BASENAME}.c ;\
	fi;\
	echo ${CC} ${CFLAGS} ${SIMDFLAGS} ${CPPFLAGS} ${LDFLAGS} ${DEFS} ${MYLIBDIRS} ${MYINCDIRS} -D$${DFLAG} -o $@ $${DFILE} ${LIBS};\
	${CC} ${CFLAGS} ${SIMDFLAGS} ${CPPFLAGS} ${LDFLAGS} ${DEFS} ${MYLIBDIRS} ${MYINCDIRS} -D$${DFLAG} -o $@ $${DFILE} ${LIBS}

${BENCHMARKS}: ${LIBDEP}
	@BASENAME=`echo $@ | sed -e 's/_benchmark//' | sed -e 's/^p7_//'`;\
	DFLAG=`echo $${BASENAME} | sed -e 'y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/'`;\
	DFLAG=p7$${DFLAG}_BENCHMARK ;\
	if test -e ${srcdir}/p7_$${BASENAME}.c; then \
           DFILE=${srcdir}/p7_$${BASENAME}.c ;\
        else \
           DFILE=${srcdir}/$${BASENAME}.c ;\
	fi;\
	echo ${CC} ${CFLAGS} ${SIMDFLAGS} ${CPPFLAGS} ${LDFLAGS} ${DEFS} ${MYLIBDIRS} ${MYINCDIRS} -D$${DFLAG} -o $@ $${DFILE} ${LIBS};\
	${CC} ${CFLAGS} ${SIMDFLAGS} ${CPPFLAGS} ${LDFLAGS} ${DEFS} ${MYLIBDIRS} ${MYINCDIRS} -D$${DFLAG} -o $@ $${DFILE} ${LIBS}

${EXAMPLES}: ${LIBDEP}
	@BASENAME=`echo $@ | sed -e 's/_example//'| sed -e 's/^p7_//'` ;\
	DFLAG=`echo $${BASENAME} | sed -e 'y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/'`;\
	DFLAG=p7$${DFLAG}_EXAMPLE ;\
	if test -e ${srcdir}/p7_$${BASENAME}.c; then \
           DFILE=${srcdir}/p7_$${BASENAME}.c ;\
        else \
           DFILE=${srcdir}/$${BASENAME}.c ;\
	fi;\
	echo ${CC} ${CFLAGS} ${SIMDFLAGS} ${CPPFLAGS} ${LDFLAGS} ${DEFS} ${MYLIBDIRS} ${MYINCDIRS} -D$${DFLAG} -o $@ $${DFILE} ${LIBS};\
	${CC} ${CFLAGS} ${SIMDFLAGS} ${CPPFLAGS} ${LDFLAGS} ${DEFS} ${MYLIBDIRS} ${MYINCDIRS} -D$${DFLAG} -o $@ $${DFILE} ${LIBS}

distclean:
	${MAKE} clean
	-rm -f Makefile 

clean:
	-rm -f ${UTESTS}
	-rm -f ${BENCHMARKS}
	-rm -f ${EXAMPLES}
	-rm -f libhmmerimpl.a
	-rm -f *.o *~ Makefile.bak core TAGS gmon.out 
	-rm -f *.gcno

binclean:
	-rm -f *.o *~ Makefile.bak core TAGS gmon.out 

tags:
	etags  *.c *.h Makefile.in

###########
# HMMER - Biological sequence analysis with profile HMMs
# Version 3.0; March 2010
# Copyright (C) 2010 Howard Hughes Medical Institute.
# Other copyrights also apply. See the COPYRIGHT file for a full list.
# 
# HMMER is distributed under the terms of the GNU General Public License
# (GPLv3). See the LICENSE file for details.
###########
