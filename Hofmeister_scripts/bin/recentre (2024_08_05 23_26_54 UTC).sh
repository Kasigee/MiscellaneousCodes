#!/bin/bash


if [ $# -ne 1 ]
then
 echo "Usage: $0 xyzfile"
 exit 1
fi

file=$1
natoms=`head -n1 $file  | tr '\r' ' ' |  tr -d '[:blank:]'`

#translate
X=`head -n3 $file | tail -n1 | awk '{print $2}'`
Y=`head -n3 $file | tail -n1 | awk '{print $3}'`
Z=`head -n3 $file | tail -n1 | awk '{print $4}'`

echo $X 
head -n2 $file > tmp2.xyz
tail -n$natoms $file | awk '{$2-='$X'}2' > tmp1.xyz
tail -n$natoms tmp1.xyz | awk '{$3-='$Y'}3' > tmp3.xyz
tail -n$natoms tmp3.xyz | awk '{$4-='$Z'}4' > tmp4.xyz
cat tmp4.xyz >> tmp2.xyz
cat tmp2.xyz > "$file".translated
rm tmp1.xyz tmp2.xyz tmp3.xyz tmp4.xyz

#ROTATE
#Vector length
X2=`head -n4 "$file".translated | tail -n1 | awk '{print $2}'`
Y2=`head -n4 "$file".translated | tail -n1 | awk '{print $3}'`
Z2=`head -n4 "$file".translated | tail -n1 | awk '{print $4}'`
dist=`echo "scale=10; sqrt($X2^2+$Y2^2+$Z2^2)" | bc`
echo $dist

#CoordMatrix=`tail -n5 "$file".translated | awk '{print "[", $2",", $3",", $4, "],"}'`
#echo $CoordMatrix | sed 's/,$//' > tmpCoordsMatrix.dat
tail -n5 "$file".translated | awk '{print $2, $3, $4}' > tmpCoordsMatrix2.dat
SecondLine=`head -n2 tmpCoordsMatrix2.dat | tail -n1`
#echo $SecondLine
#head -n2 $file > NewCoordsMat.dat
echo '' > NewCoordsMat.dat
echo '' >> NewCoordsMat.dat
recentre.py $SecondLine | sed 's/\[//g' | sed 's/\]//g' >> NewCoordsMat.dat
cat $file | awk '{print $1}' > col1.dat
#coords=`cat NewCoordsMat.dat`
#echo $col1
paste col1.dat NewCoordsMat.dat > "$file".repostioned
prefix=`echo $file | awk -F. '{print $1}'`
mv "$file".repostioned "$prefix"_repos.xyz

rm tmpCoordsMatrix2.dat col1.dat NewCoordsMat.dat "$file".translated
