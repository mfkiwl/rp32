GIT_TOPLEVEL=`git rev-parse --show-toplevel`
export PATH=$GIT_TOPLEVEL/submodules/verilator/bin/:$PATH
export VERILATOR_ROOT=$GIT_TOPLEVEL/submodules/verilator
#export LD_LIBRARY_PATH=/opt/systemc-2.3.3/lib-linux64/
#export SYSTEMC_LIBDIR=/opt/systemc-2.3.3/lib-linux64/
#export SYSTEMC_INCLUDE=/opt/systemc-2.3.3/include/
