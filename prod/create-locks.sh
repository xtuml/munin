#!/bin/bash
set -e
export MUNIN_VERSION=$(git describe --tags)
cd aeo_svdc_proc && docker run --rm -v conan-cache:/conan-cache -v ${PWD}:/work levistarrett/masl-dev:latest conan lock create . --version=${MUNIN_VERSION}
cd ../istore_proc && docker run --rm -v conan-cache:/conan-cache -v ${PWD}:/work levistarrett/masl-dev:latest conan lock create . --version=${MUNIN_VERSION}
cd ../jm_proc && docker run --rm -v conan-cache:/conan-cache -v ${PWD}:/work levistarrett/masl-dev:latest conan lock create . --version=${MUNIN_VERSION}
cd ../pv_proc && docker run --rm -v conan-cache:/conan-cache -v ${PWD}:/work levistarrett/masl-dev:latest conan lock create . --version=${MUNIN_VERSION}
