#!/bin/bash

wd=$PWD

for i in `ls -d */ | awk -F/ '{print $1}'`
do
echo $i
     if [ ! -n "`grep -i 'Normal termination' "$i"_mp2_mkcharge.out`" ]
cd $wd/$i
cp "$i"_m062x.com "$i"_mp2_mkcharge.com
sed -i 's/m062x.chk/mp2_mkcharge.chk/g' "$i"_mp2_mkcharge.com
sed -i '/opt /c\# mp2/aug-cc-pvtz Opt=Z-Matrix Charge NoSymm scf=tight pop=mk polar Density=current' "$i"_mp2_mkcharge.com
qsubg09 "$i"_mp2_mkcharge 24:00:00 
fi
done
