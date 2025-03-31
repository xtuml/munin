#!/bin/bash
source /work/build/linux-armv8-gcc-14/Release/generators/conanrun.sh
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/work/build/linux-armv8-gcc-14/Release/lib
export PATH=${PATH}:/work/build/linux-armv8-gcc-14/Release/bin
exec $@
