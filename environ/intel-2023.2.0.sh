# These commands define a compilation environment for MOM6.
# The "intel" regression results" correspond to this environment.

module unload intel cray-libsci cray-mpich PrgEnv-intel
module load PrgEnv-intel intel/2023.2.0 cray-hdf5 cray-netcdf cray-mpich

module load python

export CC=cc
export MPICC=cc
export FC=ftn
export MPIFC=ftn
export LD=ftn
export CFLAGS='-sox -traceback -O2 -debug minimal -march=core-avx-i -qno-opt-dynamic-align'
export FCFLAGS='-fpp -Wp,-w   -g -traceback -fno-alias -auto -safe-cray-ptr -ftz -assume byterecl -i4 -r8 -nowarn -sox -traceback -O2 -debug minimal -fp-model source -march=core-avx-i -qno-opt-dynamic-align'
export LAUNCHER=srun
export LAUNCHER_FLAGS='-mblock --exclusive'
export LAUNCHER_NP_FLAG=-n
export FI_VERBS_PREFER_XRC=0
