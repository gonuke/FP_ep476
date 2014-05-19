#-----------------------------------------------------------------------
# This is the makefile for the aphi_comp program.  
#
# Possible targets for this descriptor file are aph_exec (the
# default optimized executable), aph_dbg (a debugging version),
# clean (to remove *.o), and realclean to also remove the executables.
#-----------------------------------------------------------------------
# =================================================
# TO CHANGE: 
# replace OBJS with cheb_coll cheb_eval cheb_fit
# no MODS
# change executable names to match OBJ files
# add library paths/directories
# list of dependencies at bottom of page
# ================================================

# The following are considered macros.  We'll use them
# to specify a shell and the compiler and loader programs.

SHELL = /bin/sh
FCOMP = gfortran
CPPCOMP = g++
FLDR = gfortran

# Compiler and loader-option flags are typically listed in
# separate macros.  The macro with -O3 specifies optimization,
# while the macro with -g -fbounds-check is used for debugging and
# runtime checks of array bounds.

FFLAGS = -O3
FFLAGS_DBG = -g -fbounds-check
LDRFLAGS = 

# External library paths and libraries can be listed here.

# LIBDIR1 = $(HOME)/Documents/ep476/FinalProject/FP_ep476 
LIBDIR1 = $(HOME)/tmp/FP_ep476
LIB1 = tree

# MOABDIR = /filespace/groups/cnerg/opt/MOAB/shared-cubit-c12/lib/
MOABDIR = /home/wilsonp/.local/moab/4.6.2_nocgm/lib
# MOABINC = /filespace/groups/cnerg/opt/MOAB/shared-cubit-c12/include/
MOABINC = /home/wilsonp/.local/moab/4.6.2_nocgm/include
MOABLIB = MOAB 
DAGLIB = dagmc

#-----------------------------------------------------------------------

# The following macro lists all of the object files that are
# needed to build the executable.  The "\" signifies
# that the line is continued.
OBJS = tree_data_mod.o volume_data_mod.o \
       volume_functions_mod.o  \
       #print_tree.o #write_tree.o #insert_in_tree.o  
CPP_OBJS = idagmc
DRIVERS = tree_driver

# This is a module-list macro.

MODS = tree_data_mod.mod  

PNGS = tree_0.png tree_1.png tree_2.png tree_3.png tree_4.png tree_5.png \
       tree_6.png tree_7.png
JPGS = tree_0.jpg tree_1.jpg tree_2.jpg tree_3.jpg tree_4.jpg tree_5.jpg \
       tree_6.jpg tree_7.jpg

#-----------------------------------------------------------------------
all : clean tree_driver

# The first dependency list is the default, so it should be
# used for the final executable.  Other dependencies may get
# invoked in the process of creating the final executable.
# Note that $(macro) evaluates a macro or an environment variable,
# and the list of commands or rules follow the dependency.

tree_driver : library
	@echo "Creating "$@" in directory "$(PWD)"."
	$(FLDR) $(FFLAGS_DBG) -o $@ $(DRIVERS).f90 $(OBJS) $(CPP_OBJS).cpp -L$(LIBDIR1) -l$(LIB1) \
      -L$(MOABDIR) -l$(MOABLIB) -l$(DAGLIB) -I$(MOABINC) -lstdc++


library : $(MODS) $(OBJS) 
	ar -r lib$(LIB1).a $(OBJS)
	ranlib lib$(LIB1).a


pngs : $(PNGS)

jpgs : $(JPGS)

agif : $(PNGS)
	convert -delay 100 -loop 1 $(PNGS) animated.gif

# The following dependency is similar, but it conditionally
# replaces the value of FFLAGS with FFLAGS_DBG when
# processing the rules for the target aph_dbg.

# aph_dbg : FFLAGS = $(FFLAGS_DBG)
# cheb_eval :  $(OBJS)
#	@echo "Creating "$@" in directory "$(PWD)"."
#	$(FLDR) -o $@ $(LDRFLAGS) $(OBJS) $(LIBDIR) $(LIBS)

#-----------------------------------------------------------------------

# The following is a static pattern rule that provides
# instructions for creating object files from the fortran
# source files.  The older suffix rule would have been ".f.o:"

# The symbol at the end is a macro for the current source file.

%.png : %.dot
	dot -Tpng -o $@ $<

%.jpg : %.dot
	dot -Tjpg -o $@ $<

$(OBJS) : %.o : %.f90
	$(FCOMP) $(FFLAGS_DBG) -c $<

%.o : %.cpp
	$(CPPCOMP) $(CPPFLAGS_DBG) -c $<

$(MODS) : %.mod : %.f90
	$(FCOMP) $(FFLAGS_DBG) -c $<

#$(MODS) : %.mod : %.f90
#	$(FCOMP) $(FFLAGS) -c $<

# A list of module dependencies ensures that module information
# specific to a particular source is available.

#-----------------------------------------------------------------------

# Specifying 'clean' dependencies is also handy.  With no
# listed dependencies, clean is considered a 'phony' target.
# The dash in front of a command means to continue even if that
# command returns a nonzero error code.

clean:
	-rm *.o
	@echo "Cleaned object and mod files from "$(PWD)"."

realclean: clean
	-rm chdriver
	@echo "Cleaned executables from "$(PWD)"."

