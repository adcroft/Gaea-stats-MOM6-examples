# These commands define a compilation environment for MOM6.
# The "intel" regression results" correspond to this environment.

module unload darshan-runtime
module unload intel cray-libsci cray-mpich PrgEnv-intel
module load PrgEnv-intel intel/2023.2.0 cray-hdf5 cray-netcdf cray-mpich
