#!/bin/bash
set -e
xtuml2masl -xf -i AEOrdering -o AEOrdering/masl -d AEOrdering
xtuml2masl -xf -i AEReception -o AEReception/masl -d AEReception
xtuml2masl -xf -i AESimulator -o AESimulator/masl -d AESimulator
xtuml2masl -xf -i InvariantStore -o InvariantStore/masl -d IStore
xtuml2masl -xf -i SequenceVerificationDataCentric -o SequenceVerificationDataCentric/masl -d AESequenceDC
