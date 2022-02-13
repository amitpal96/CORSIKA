###########################################################################
# Makefile template
# $Id: Makefile.am 24309 2020-02-25 13:22:35Z pierog $
###########################################################################

srcdir = @srcdir@
VPATH = @srcdir@

TOOLS = coreas_to_hdf5_README.txt coreas_to_hdf5.py

AM_CXXFLAGS = 
nobase_dist_include_HEADERS = 
EXTRA_DIST = doc *.h $(TOOLS)



###########################################################################
# globals
###########################################################################

AM_CXXFLAGS += -I$(top_builddir)/coast/CorsikaIntern \
               -I$(top_builddir)/coast/CorsikaFileIO \
               -I$(top_builddir)/coast/CorsikaInterface

AM_CXXFLAGS += -O3

###########################################################################
# CoREAS
###########################################################################

if USE_PARALLELIB
bin_PROGRAMS = sumparallelresults
endif

lib_LIBRARIES = libCoREAS.a 

sumparallelresults_SOURCES = sumparallelresults.cpp threevector.cpp

libCoREAS_a_SOURCES = TCorsika.cc THRadioInterface.cc TPlotter.cc antennaposition.cpp datapoint.cpp grid.cpp groundarea.cpp groundelement.cpp ResponseTable.cpp scenarioparams.cpp threevector.cpp

#libCoREAS_a_CPPFLAGS = -fPIC 
#libCoREAS_a_LDFLAGS = -fPIC --shared

EXAMPLES = RUN000001.inp  SIM000001.list  SIM000001.reas SIM000001.gnu
EXDIR = doc/examples/

RUN%:
	@if [ ! -e $(bindir)/$@ ] ; then  \
	echo "==CoREAS==> copy $(EXDIR)$@ to run/  " ; \
	cp  $(abs_srcdir)/$(EXDIR)/$@ $(bindir)/ ;   \
	fi

SIM%:
	@if [ ! -e $(bindir)/$@ ] ; then  \
	echo "==CoREAS==> copy $(EXDIR)$@ to run/  " ; \
	cp  $(abs_srcdir)/$(EXDIR)/$@ $(bindir)/ ;   \
	fi

coreas%:
	@if [ ! -e $(bindir)/$@ ] ; then  \
	echo "==CoREAS==> copy $@ to run/  " ; \
	cp  $(abs_srcdir)/$@ $(bindir)/ ;   \
	fi

radio-tools:
	@if [ ! -e $(bindir)/coreas_to_hdf5.py ] ; then  \
	echo "==CoREAS==> copy $(TOOLS)  to run/  " ; \
	cp -f $(abs_srcdir)/coreas_to_hdf5.py $(bindir)/ ;   \
	cp -f $(abs_srcdir)/coreas_to_hdf5_README.txt $(bindir)/ ;   \
	fi

coreas-manual.pdf:
	@if [ ! -e $(abs_top_srcdir)/doc/$@ ] ; then  \
	echo "==CoREAS==> copy CoREAS/doc/$@ to doc/  " ; \
	cp  $(abs_srcdir)/doc/$@ $(abs_top_srcdir)/doc/ ;   \
	fi

install-exec-hook: $(EXAMPLES) coreas-manual.pdf radio-tools


#EXTRA_DIST += radiotools  coreas_to_hdf5_README.txt coreas_to_hdf5.py

#clean-local: rootout-clean
#install : $(BUILT_SOURCES) install-am
#nobase_dist_include_HEADERS += $(addprefix rootout/, $(notdir $(rootout_Headers)))
#EXTRA_DIST += $(rootout_Headers)
