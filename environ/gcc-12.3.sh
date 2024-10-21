# These commands define a compilation environment for MOM6.
# The "gnu" regression results" correspond to this environment.

module unload darshan-runtime intel PrgEnv-intel
module load PrgEnv-gnu/8.5.0 cray-hdf5 cray-netcdf
module switch gcc-native/12.3
#module unload darshan-runtime
