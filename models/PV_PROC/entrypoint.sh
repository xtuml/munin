#!/bin/sh
. /work/build/Release/generators/conanrun.sh
export PATH=$PATH:/work/build/Release/bin
exec $@
