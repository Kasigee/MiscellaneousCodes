#!/bin/bash

if [ $# -ne 3 ]
then
	echo $0 molecule functional basisset
	exit 1
fi

molecule=$1
functional=$2
basisset=$3

#grep 'eigen' MeNaph/MeNaph_m062x_aug-cc-pvdz.out | awk -v prefix="MeNapH" '/Alpha/{if(prev && prev != $2 && $2 == "virt."){print prefix; "HOMO"; line; "LUMO, print $0; exit}}{prev=$1; line=$0}'
grep 'eigen' $molecule/"$molecule"_"$functional"_"$basisset".out | awk -v prefix="$molecule" '/Alpha/{if(prev && prev != $2 && $2 == "virt."){print prefix, "HOMO", prev_val, "LUMO", $5; exit}}{prev=$1; prev_val=$(NF); line=$0}'
