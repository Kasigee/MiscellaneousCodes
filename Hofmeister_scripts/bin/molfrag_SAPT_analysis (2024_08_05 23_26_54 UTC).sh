#!/bin/bash

wd=$PWD

if [ $# -ne 2 ]
then
 echo "Usage:$0 cation anion"
 exit 1
fi

cation=$1
anion=$2

if [ $anion = NCS ]
then
anion_atom=S
elif [ $anion = water ] || [ $anion = MeOH ] || [ $anion = DMSO ]
then
anion_atom=O
elif [ $anion = MeCN ]
then
anion_atom=N
else
anion_atom=$anion
fi

if [ $cation = water ] || [ $cation = MeOH ] || [ $cation = DMSO ] || [ $cation = MeCN ]
then
cation_atom=H
elif [ $cation = NH4 ]
then
cation_atom=N
else
cation_atom=$cation
fi

if [ $anion = F ]
then
anion_threshold=2
elif [ $anion = Cl ]
then
anion_threshold=2.5
elif [ $anion = NCS ]
then
anion_threshold=3
fi

echo "cation("$cation_threshold") anion("$anion_threshold") k CN" > $wd/ion_int/$cation/$anion/"$cation""$anion"CN.dat


cd $wd/ion_int/$cation/$anion/
for file in `ls $wd/ion_int/$cation/$anion/*m062x*.xyz | awk -F'/' '{print $NF}'`
do
#rm "$cation""$anion"CN.dat 
echo $file
cp ~/bin/molfrag.in .
sed -i "s/opt.xyz/$file/g" molfrag.in
molfrag
grep "$cation_atom" molfrag.out >> "$cation""$anion"CN.dat
echo "anion_atom="$anion_atom" anion_threshold="$anion_threshold""
grep "$anion_atom" molfrag.out >> "$anion"_CN.dat
cat "$anion"_CN.dat
bdatom=`awk '{print $8}' "$anion"_CN.dat |  awk -F, '{print $2}'`
anbddist=`awk '{print $5}' "$anion"_CN.dat |  awk -F, '{print $1}'`
 for i in $anbddist
 do
  if [[ $i > "$anion_threshold" ]]
  then
  sed -i '/'$i'/d' "$anion"_CN.dat
  fi
 done
 for x in $bdatom
 do
 if [ ! $x = O ] && [ ! $x = $anion_atom ]
then
sed -i '/'$x' /d' "$anion"_CN.dat
fi
 if [ ! $x = O ] 
  then
  sed -i "/theta=(O/d" "$anion"_CN.dat
  fi
 done
CN_cations=`wc -l "$cation"_CN.dat | awk '{print $1}'`
CN_anions=`wc -l "$anion"_CN.dat | awk '{print $1}'`
if [ $CN_anions = 0 ]
then
molfrag
fi
echo "$cation $anion $k $CN_anions" >> $wd/ion_int/$cation/$anion/"$anion"CN.dat
done
