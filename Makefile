# The sub-repository corresponding to regressions (change only trying to mix and match versions)
CONFIG_DIR ?= MOM6-examples
# List of compilers to cycle through
COMPILERS ?= gnu intel pgi
# List of experiment groups within the sub-repository (unique to MOM6-examples)
EXPT_GROUPS ?= ocean_only ice_ocean_SIS2 coupled_AM2_LM3_SIS2
# Which version of FMS to use (relative to ocean_only/Makefile, ice_ocean_SIS2/Makefile)
FMS_CODE ?= FMS1
# Are we at GFDL? Change to "all" if outside of the GFDL firewall, or using FMS2
GFDL_OR_ALL ?= gfdl
# Directory structure that contains object files is
#   $(CONFIG_DIR)/$(BUILD)/<compiler>/<components>
# e.g.  MOM6-examples/build/gnu/{fms,ocean_only}/*.o
BUILD ?= build_fms1
# The run directories are $(RUNROOT)/<compiler>/<experiment group>/<experiment name>
# e.g.  MOM6-examples/scratch/gnu/ocean_only/double_gyre/
RUNROOT ?= scratch

# Create lists of all stats files and experiments (by group)
ALL_STATS_FILES = $(shell git ls-files regressions)
ALL_EXPTS = $(patsubst regressions/%/ocean.stats.gnu,%,$(filter %/ocean.stats.gnu,$(ALL_STATS_FILES)))
OCEAN_ONLY_EXPTS = $(subst ocean_only/,,$(filter ocean_only/%,$(ALL_EXPTS)))
ICE_OCEAN_SIS2_EXPTS = $(subst ice_ocean_SIS2/,,$(filter ice_ocean_SIS2/%,$(ALL_EXPTS)))
COUPLED_EXPTS = $(subst coupled_AM2_LM3_SIS2/,,$(filter coupled_AM2_LM3_SIS2/%,$(ALL_EXPTS)))

# These are the tests (that the regressions directory is intact)
.PHONY: all
all: test.all
test.all: $(ALL_STATS_FILES)
	git status regressions
.PHONY: gnu
gnu: test.gnu
test.gnu: $(filter %.gnu,$(ALL_STATS_FILES))
	git status regressions
.PHONY: intel
intel: test.intel
test.intel: $(filter %.intel,$(ALL_STATS_FILES))
	git status regressions
.PHONY: pgi
pgi: test.pgi
test.pgi: $(filter %.pgi,$(ALL_STATS_FILES))
	git status regressions


debug:
	@echo ALL_EXPTS = $(ALL_EXPTS)
	@echo OCEAN_ONLY_EXPTS = $(OCEAN_ONLY_EXPTS)
	@echo ICE_OCEAN_SIS2_EXPTS = $(ICE_OCEAN_SIS2_EXPTS)
	@echo oceCOUPLED_EXPTS = $(oceCOUPLED_EXPTS)
	@echo Gnu stats files: $(filter %.gnu,$(ALL_STATS_FILES))

# These are the targets to compile (build) with the compiler matching the % pattern
# e.g.  make build.gnu
build.%:
	@echo make[$(MAKELEVEL)] Building target \"build.$(GFDL_OR_ALL)\" with $(CONFIG_DIR)/Makefile using environ/$*.env ...
	. environ/$*.env && $(MAKE) -C $(CONFIG_DIR) FMS_CODEBASE=src/$(FMS_CODE) BUILD=$(BUILD)/$* build.$(GFDL_OR_ALL)
	@echo make[$(MAKELEVEL)] ... done building target \"build.$(GFDL_OR_ALL)\" with $(CONFIG_DIR)/Makefile using environ/$*.env

# build.all will build each compiler
build.all: $(foreach compiler,$(COMPILERS),build.$(compiler))

# This catches the situation where the executables have not been compiled
$(CONFIG_DIR)/$(BUILD)/%/ocean_only/MOM6 $(CONFIG_DIR)/$(BUILD)/%/ice_ocean_SIS2/coupler_main $(CONFIG_DIR)/$(BUILD)/%/coupled_AM2_LM3_SIS2/coupler_main:
	@echo "ERROR: Executables do not exist"
	@echo "Compile executables (before running) using"
	@echo "    make build.$*"
	@exit 1

# These are the targets to run the experiment suite with the compiler matching the % pattern
# e.g.  make run.gnu
run.%: $(CONFIG_DIR)/$(BUILD)/%/ocean_only/MOM6 $(CONFIG_DIR)/$(BUILD)/%/ice_ocean_SIS2/coupler_main $(CONFIG_DIR)/$(BUILD)/%/coupled_AM2_LM3_SIS2/coupler_main
	@echo make[$(MAKELEVEL)] Running target \"run.$(GFDL_OR_ALL)\" with $(CONFIG_DIR)/Makefile using environ/$*.env ...
	. environ/$*.env && $(MAKE) -C $(CONFIG_DIR) BUILD=$(BUILD)/$* TESTDIR=$(RUNROOT)/$* run.$(GFDL_OR_ALL)
	@echo make[$(MAKELEVEL)] ... done running target \"run.$(GFDL_OR_ALL)\" with $(CONFIG_DIR)/Makefile using environ/$*.env
# run.all will run the suite with each compiler
.PHONY: run.all
run.all: $(foreach compiler,$(COMPILERS),run.$(compiler))


# `$(call stats_rule,ocean_only,gnu)` creates the pattern rule:
#   regressions/ocean_only/%/ocean.stats.gnu: $(CONFIG_DIR)/ocean_only/$(RUNROOT)/gnu/%/ocean.stats
# Arguments:
#   $(1) is experiment class, e.g. ocean_only
#   $(2) is executable vendor, e.g. gnu
define stats_rule 
regressions/$(1)/%/seaice.stats.$(2): $(CONFIG_DIR)/$(1)/$(RUNROOT)/$(2)/%/seaice.stats
	cp $$< $$@
	git status --porcelain $$@
regressions/$(1)/%/ocean.stats.$(2): $(CONFIG_DIR)/$(1)/$(RUNROOT)/$(2)/%/ocean.stats
	cp $$< $$@
	git status --porcelain $$@
endef
$(foreach compiler,$(COMPILERS),$(foreach expt_group,$(EXPT_GROUPS),$(eval $(call stats_rule,$(expt_group),$(compiler)))))

# Deletes the executables for the compiler match the % pattern
rm.exec.%:
	rm -f $(foreach suite,ocean_only/MOM6 ice_ocean_SIS2/coupler_main coupled_AM2_LM3_SIS2/coupler_main,$(CONFIG_DIR)/$(BUILD)/$*/$(suite))
touch.exec.%:
	touch $(foreach suite,ocean_only/MOM6 ice_ocean_SIS2/coupler_main coupled_AM2_LM3_SIS2/coupler_main,$(CONFIG_DIR)/$(BUILD)/$*/$(suite))
clean.stats.%:
	find regressions/ -name "*.stats.$*" -delete
.PHONY: clean.stats
clean.stats: $(foreach compiler,$(COMPILERS),clean.stats.$(compiler))
clean.exec.%:
	$(MAKE) -C $(CONFIG_DIR) BUILD=$(BUILD)/$* clean
