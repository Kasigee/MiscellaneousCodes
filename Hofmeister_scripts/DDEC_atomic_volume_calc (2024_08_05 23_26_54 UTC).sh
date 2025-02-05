#!/bin/bash

if [ $# -ne 3 ]
then
echo $0 molecule functional basisset
exit 1
fi

molecule=$1
functional=$2
basisset=$3


echo $molecule $(tail -n$(head -n1 $molecule/DDEC6_"$functional"_"$basisset"/DDEC_atom_volumes.xyz) $molecule/DDEC6_"$functional"_"$basisset"/DDEC_atom_volumes.xyz | awk '{sum += $6} END {print sum}')
