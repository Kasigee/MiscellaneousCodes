#!/bin/bash

if [ $# -ne 4 ]
then
 echo "Usage: $0 solvent substrate cation anion"
 exit 1
fi


solvent=$1
substrate=$2
cation=$3
anion=$4

#for i in `ls ~/kas/$solvent/$substrate/$cation/$anion/*/eda/*.out`
# do
# ~/kas/PCMtoGKSconv $i 
#done
wd=$PWD

for k in `seq 1 20`
do
cd $wd/$solvent/$substrate/$cation/$anion/$k/eda
if [ $wd/$solvent/$substrate/$cation/$anion/$k/eda = $PWD ]
then
for l in `ls *.out`
do
~/kas/PCMtoGKSconv $l
#qsubpcmgks $1 01:00:00
done
fi
done
