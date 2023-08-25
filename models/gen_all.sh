#!/bin/bash
XTUML2MASL=xtuml2masl
which $XTUML2MASL &>/dev/null
if [[ $? == 1 ]]; then
	XTUML2MASL="docker run -v /${PWD}:/root levistarrett/xtuml2masl"
fi
set -e
$XTUML2MASL -xf -i AEOrdering -o AEOrdering/masl -d AEOrdering
$XTUML2MASL -xf -i AEReception -o AEReception/masl -d AEReception
$XTUML2MASL -xf -i InvariantStore -o InvariantStore/masl -d IStore
$XTUML2MASL -xf -i SequenceVerificationDataCentric -o SequenceVerificationDataCentric/masl -d AESequenceDC
