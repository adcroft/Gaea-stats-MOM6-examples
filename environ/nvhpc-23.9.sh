# These commands define a compilation environment for MOM6.
# The "pgi" regression results" correspond to this environment.

module unload intel PrgEnv-intel
module load PrgEnv-nvidia/8.5.0 cray-hdf5 cray-netcdf cray-mpich

module load python

export CC=cc
export MPICC=cc
export FC=ftn
export MPIFC=ftn
export LD=ftn
export FCFLAGS='-g -Mdwarf3 -traceback -i4 -r8 -byteswapio -Mcray=pointer -Mflushz -Mnofma -Mdaz -D_F2000 -O0'
export LAUNCHER=srun
export LAUNCHER_FLAGS='-mblock --exclusive'
export LAUNCHER_NP_FLAG=-n
export FI_VERBS_PREFER_XRC=0
