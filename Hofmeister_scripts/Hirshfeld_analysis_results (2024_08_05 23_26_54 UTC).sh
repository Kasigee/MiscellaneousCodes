#!/bin/bash

wd=$PWD

if [ $# -ne 3 ]
then
 echo "Usage: $0 ion functional basis_set"
 exit
fi

ion=$1
functional=$2
basis_set=$3

cd $ion
file="$ion"_"$functional"_"$basis_set".out
natoms=`head -n1 $ion.xyz | tr '\r' ' '`
length=`expr $natoms + 2`
awk '/ Largest concise Abelian subgroup/,/[^2]Basis read from chk:/' $file > coords_tmp.dat
sed -i '/Rotational constants/d' coords_tmp.dat
sed -i '/Leave Link/d' coords_tmp.dat
sed -i '/Enter/d' coords_tmp.dat

tail -n$length coords_tmp.dat | head -$natoms > Hirsh_tmp_coords.dat
awk  '{$4=sprintf("%.8f",$4*1.88973)}1' Hirsh_tmp_coords.dat > Hirsh_tmp_coords2.dat
awk  '{$5=sprintf("%.8f",$5*1.88973)}1' Hirsh_tmp_coords2.dat > Hirsh_tmp_coords3.dat
awk  '{$6=sprintf("%.8f",$6*1.88973)}1' Hirsh_tmp_coords3.dat > Hirsh_tmp_coords.dat
rm Hirsh_tmp_coords2.dat Hirsh_tmp_coords3.dat
#rm coords_tmp.dat
awk '/ Hirshfeld charges, spin densities,/,/[^2]Hirshfeld charges with hydrogens/' $file > Hirsh_tmp.dat
sed -i '/Hirshfeld/d' Hirsh_tmp.dat
sed -i '/Q-H/d' Hirsh_tmp.dat
sed -i '/Tot/d' Hirsh_tmp.dat
echo "Element		axx(ang)		ayy(ang)		azz(ang)		Average(Angstrom)	 Average(bohr)"
sum1=0
sum2=0
sum3=0
sum4=0
sum5=0
for i in `seq 1 $natoms`
do
element=`awk '$1=='$i'' Hirsh_tmp.dat | head -n1 | awk '{print $2}'`
q1=`awk '$1=='$i'' Hirsh_tmp.dat | head -n1 | awk '{print $8}'`
q2=`awk '$1=='$i'' Hirsh_tmp.dat | head -n2 | tail -n1 | awk '{print $8}'`
q3=`awk '$1=='$i'' Hirsh_tmp.dat | head -n3 | tail -n1 | awk '{print $8}'`
q4=`awk '$1=='$i'' Hirsh_tmp.dat | head -n4 | tail -n1 | awk '{print $8}'`
dx1=`awk '$1=='$i'' Hirsh_tmp.dat | head -n1 | awk '{print $5}'`
dy1=`awk '$1=='$i'' Hirsh_tmp.dat | head -n1 | awk '{print $6}'`
dz1=`awk '$1=='$i'' Hirsh_tmp.dat | head -n1 | awk '{print $7}'`
dx2=`awk '$1=='$i'' Hirsh_tmp.dat | head -n2 | tail -n1 |  awk '{print $5}'`
dy2=`awk '$1=='$i'' Hirsh_tmp.dat | head -n2 | tail -n1 |  awk '{print $6}'`
dz2=`awk '$1=='$i'' Hirsh_tmp.dat | head -n2 | tail -n1 |  awk '{print $7}'`
dx3=`awk '$1=='$i'' Hirsh_tmp.dat | head -n3 | tail -n1 |  awk '{print $5}'`
dy3=`awk '$1=='$i'' Hirsh_tmp.dat | head -n3 | tail -n1 |  awk '{print $6}'`
dz3=`awk '$1=='$i'' Hirsh_tmp.dat | head -n3 | tail -n1 |  awk '{print $7}'`
dx4=`awk '$1=='$i'' Hirsh_tmp.dat | head -n4 | tail -n1 |  awk '{print $5}'`
dy4=`awk '$1=='$i'' Hirsh_tmp.dat | head -n4 | tail -n1 |  awk '{print $6}'`
dz4=`awk '$1=='$i'' Hirsh_tmp.dat | head -n4 | tail -n1 |  awk '{print $7}'`
x=`awk '$1=='$i'' Hirsh_tmp_coords.dat | awk '{print $4}'`
y=`awk '$1=='$i'' Hirsh_tmp_coords.dat | awk '{print $5}'`
z=`awk '$1=='$i'' Hirsh_tmp_coords.dat | awk '{print $6}'`

uxa=`echo "scale=10; $q1 * $x + $dx1" | bc -l`
uya=`echo "scale=10; $q1 * $y + $dy1" | bc -l`
uza=`echo "scale=10; $q1 * $z + $dz1" | bc -l`
#echo uza=$uza q1=$q1 z=$z dz1=$dz1
uxb=`echo "$q2 * $x + $dx2" | bc`
uyb=`echo "$q2 * $y + $dy2" | bc`
uzb=`echo "$q2 * $z + $dz2" | bc`
uxc=`echo "$q3 * $x + $dx3" | bc`
uyc=`echo "$q3 * $y + $dy3" | bc`
uzc=`echo "$q3 * $z + $dz3" | bc`
uxd=`echo "$q4 * $x + $dx4" | bc`
uyd=`echo "$q4 * $y + $dy4" | bc`
uzd=`echo "$q4 * $z + $dz4" | bc`
#echo a=$uxa b=$uxb c=$uxc d=$uxd e=$uya f=$uyb g=$uyc h=$uyd i=$uza j=$uzb k=$uzc l=$uzd

axx=`echo "scale=3; ($uxb - $uxa)/(-0.001)" | bc -l`
axy=`echo "scale=3; ($uyb - $uya)/(-0.001)" | bc -l`
axz=`echo "scale=3; ($uzb - $uza)/(-0.001)" | bc -l`
ayx=`echo "scale=3; ($uxc - $uxa)/(-0.001)" | bc -l`
ayy=`echo "scale=3; ($uyc - $uya)/(-0.001)" | bc -l`
ayz=`echo "scale=3; ($uzc - $uza)/(-0.001)" | bc -l`
azx=`echo "scale=3; ($uxd - $uxa)/(-0.001)" | bc -l`
azy=`echo "scale=3; ($uyd - $uya)/(-0.001)" | bc -l`
azz=`echo "scale=3; ($uzd - $uza)/(-0.001)" | bc -l`

average=`echo "scale=3; ($axx + $ayy + $azz)/3" | bc -l`
average_angstrom=`echo "scale=3; $average*(0.529177^3)" | bc -l`
axx_angstrom=`echo "scale=3; $axx*(0.529177^3)" | bc -q `
ayy_angstrom=`echo "scale=3; $ayy*(0.529177^3)" | bc -q`
azz_angstrom=`echo "scale=3; $azz*(0.529177^3)" | bc -q`
if (( $(echo "$axx_angstrom < 1" | bc -l) ))
then
axx_angstrom=`echo 0"$axx_angstrom"`
fi
if (( $(echo "$ayy_angstrom < 1" | bc -l) ))
then
ayy_angstrom=`echo 0"$ayy_angstrom"`
fi
if (( $(echo "$azz_angstrom < 1" | bc -l) ))
then
azz_angstrom=`echo 0"$azz_angstrom"`
fi
if (( $(echo "$average_angstrom < 1" | bc -l) ))
then
average_angstrom=`echo 0"$average_angstrom"`
fi

echo "$element		$axx_angstrom		$ayy_angstrom		$azz_angstrom		$average_angstrom		$average"
#echo q1=$q1
#echo q2=$q2
#echo q3=$q3
#echo q4=$q4
sum1=`echo "$sum1 + $axx_angstrom" | bc`
sum2=`echo "$sum2 + $ayy_angstrom" | bc`
sum3=`echo "$sum3 + $azz_angstrom" | bc`
sum4=`echo "$sum4 + $average_angstrom" | bc`
sum5=`echo "$sum5 + $average" | bc`
done

if (( $(echo "$sum1 < 1" | bc -l) ))
then
sum1=`echo 0$sum1`
fi
if (( $(echo "$sum2 < 1" | bc -l) ))
then
sum2=`echo 0$sum2`
fi
if (( $(echo "$sum3 < 1" | bc -l) ))
then
sum3=`echo 0$sum3`
fi
if (( $(echo "$sum4 < 1" | bc -l) ))
then
sum4=`echo 0$sum4`
fi
if (( $(echo "$sum5 < 1" | bc -l) ))
then
sum5=`echo 0$sum5`
fi


echo "Total		$sum1		$sum2		$sum3		$sum4		$sum5"
