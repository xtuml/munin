#!/bin/bash
XTUML2MASL=xtuml2masl
which $XTUML2MASL &>/dev/null
if [[ $? == 1 ]]; then
	XTUML2MASL="docker run -v /${PWD}:/root levistarrett/xtuml2masl"
fi
set -e
$XTUML2MASL -i AEOrdering -o AEOrdering/masl -d AEOrdering
$XTUML2MASL -i AEReception -o AEReception/masl -d AEReception
$XTUML2MASL -i FileReception -o FileReception/masl -d FReception
$XTUML2MASL -i InvariantStore -o InvariantStore/masl -d IStore
$XTUML2MASL -i SequenceVerificationDataCentric -o SequenceVerificationDataCentric/masl -d AESequenceDC
