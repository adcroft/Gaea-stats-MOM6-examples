# These commands define a compilation environment for MOM6.
# The "gnu" regression results" correspond to this environment.

module unload intel PrgEnv-intel
module load PrgEnv-gnu/8.5.0 cray-hdf5 cray-netcdf
module switch gcc-native/12.3

module load python

export CC=cc
export MPICC=cc
export FC=ftn
export MPIFC=ftn
export LD=ftn
export FCFLAGS='-g -fbacktrace -fcray-pointer -fdefault-real-8 -fdefault-double-8 -Waliasing -ffree-line-length-none -fno-range-check -fallow-argument-mismatch -fallow-invalid-boz'
export LAUNCHER=srun
export LAUNCHER_FLAGS='-mblock --exclusive'
export LAUNCHER_NP_FLAG=-n

# Needed for MPI finalize on gaea
export FI_VERBS_PREFER_XRC=0
