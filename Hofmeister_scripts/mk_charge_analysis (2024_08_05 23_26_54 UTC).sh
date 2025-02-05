#!/bin/bash

wd=$PWD

for i in `ls -d */ | awk -F/ '{print $1}'`
do
echo $i
cd $wd/$i
cp "$i"_m062x.com "$i"_m062x_mkcharge.com
sed -i 's/m062x.chk/m062x_mkcharge.chk/g' "$i"_m062x_mkcharge.com
sed -i '/opt /c\# m062x/aug-cc-pvdz Opt=Z-Matrix Charge NoSymm scf=tight pop=mk' "$i"_m062x_mkcharge.com
qsubg09 "$i"_m062x_mkcharge 75:00:00 
done


