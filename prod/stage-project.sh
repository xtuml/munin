#!/bin/bash
docker run --rm -v conan-cache:/conan-cache -v ${PWD}:/work levistarrett/masl-dev:latest conan install . --deployer-folder=staging --deployer-package=* --version=${MUNIN_VERSION} --lockfile-partial
