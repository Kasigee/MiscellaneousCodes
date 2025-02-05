
if [ $# -ne 4 ]
then
echo file ChoseAtomNum1 ChoseAtomNum2 ChoseAtomNum3
exit 0
fi

rm TMP.Ele.xyz TMP.X.xyz TMP.Y.xyz TMP.Z.xyz

file=$1
ChosenAtomNum=$2
ChosenAtom2=$3
ChosenAtom3=$4
filetype=$( echo $file | awk -F'.' '{print $2}')

echo $filetype

natoms=`grep HETATM $file | tail -n1 | awk '{print $2}'` 
echo $natoms

if [ $filetype == 'pdb' ]
then
baseAtom=`tail -n+$(expr $ChosenAtomNum + 2 ) $file | head -n1 | awk '{print $3}'`
basecoordsX=`tail -n+$(expr $ChosenAtomNum + 2 ) $file | head -n1 | awk '{print $6}'`
basecoordsY=`tail -n+$(expr $ChosenAtomNum + 2 ) $file | head -n1 | awk '{print $7}'`
basecoordsZ=`tail -n+$(expr $ChosenAtomNum + 2 ) $file | head -n1 | awk '{print $8}'`
echo $baseAtom $basecoordsX  $basecoordsY  $basecoordsZ

#for Elements in `tail -n+3 $file | awk '{print $2}' | head -n$natoms`
#do
#        echo $Elements >> TMP.Ele.xyz
#done
tail -n+3 $file | awk '{print $3}' | head -n$natoms > TMP.Ele.xyz
for xcoords in `tail -n+3 $file | awk '{print $6}' | head -n$natoms`
do
	echo $xcoords - $basecoordsX | bc -l >> TMP.X.xyz
done
for ycoords in `tail -n+3 $file | awk '{print $7}' | head -n$natoms`
do
        echo $ycoords - $basecoordsY | bc -l >> TMP.Y.xyz
done
for zcoords in `tail -n+3 $file | awk '{print $8}' | head -n$natoms`
do
        echo $zcoords - $basecoordsZ | bc -l >> TMP.Z.xyz
done
#cat TMP.X.xyz
#cat TMP.Y.xyz
#cat TMP.Z.xyz
echo $natoms > "$file"_translated.xyz
echo "Translated $file about $baseAtom" >> "$file"_translated.xyz
paste TMP.Ele.xyz TMP.X.xyz TMP.Y.xyz TMP.Z.xyz >> "$file"_translated.xyz
#echo $allcoords
#tail -n+2 $file | echo "$(awk '{print $6,$7,$8}') - $basecoords" | bc

baseAtom2=`tail -n+$(expr $ChosenAtom2 + 2 ) $file | head -n1 | awk '{print $3}'`
rm  TMP.X.xyz TMP.Y.xyz
file2="$file"_translated.xyz
X2=`tail -n+$(expr $ChosenAtom2 + 2 ) $file2 | head -n1 | awk '{print $2}'`
Y2=`tail -n+$(expr $ChosenAtom2 + 2 ) $file2 | head -n1 | awk '{print $3}'`
pi=3.1415926535
AngleXY=`echo "a($Y2/$X2)" | bc -l`
#pi=3.1415926535
#AngleXY=`echo "$pi + $AngleXY" | bc -l`
#for xcoords in `tail -n+3 $file2 | awk '{print $2}' | head -n$natoms`
#do
echo $baseAtom2 $X2 $Y2
for line in `seq 1 $natoms`
do
	xcoords=`tail -n+$(expr $line + 2 ) $file2 | awk '{print $2}' | head -n1`
#	ycoord=`grep "$xcoords" $file2 | awk '{print $3}' | head -n$natoms`
	ycoords=`tail -n+$(expr $line + 2 ) $file2 | awk '{print $3}' | head -n1`
	echo $xcoords $ycoords $AngleXY

	#echo "$xcoords * c($AngleXY) - $ycoords * s($AngleXY)"
	echo "$xcoords * c($AngleXY) + $ycoords * s($AngleXY)" | bc -l >> TMP.X.xyz
	echo "$xcoords * s($AngleXY) - $ycoords * c($AngleXY)" | bc -l >> TMP.Y.xyz
done
echo "Chosen atom2 X coords: $(tail -n+$(expr $ChosenAtom2) TMP.X.xyz | head -n1 | awk '{print $1}')"
NegativityX=$(tail -n+$(expr $ChosenAtom2) TMP.X.xyz | head -n1 | awk '{print $1}')
echo $NegativityX
if (( $(bc <<<  "$NegativityX < 0" ) ))
then
	echo x less than 0
	awk '{printf "%14.16f  \n", $1*-1}' TMP.X.xyz >> TMP.X.xyz.2
        mv TMP.X.xyz.2 TMP.X.xyz
else
	echo x greater than 0
fi
paste TMP.X.xyz TMP.Y.xyz

echo $natoms > "$file"_translated_rotY.xyz
echo "Translated $file about $baseAtom and rotated about $baseAtom2" >> "$file"_translated_rotY.xyz
paste TMP.Ele.xyz TMP.X.xyz TMP.Y.xyz TMP.Z.xyz >> "$file"_translated_rotY.xyz

#AngleXY=
rm TMP.X.xyz TMP.Y.xyz TMP.Z.xyz

file2="$file"_translated_rotY.xyz
X2=`tail -n+$(expr $ChosenAtom2 + 2 ) $file2 | head -n1 | awk '{print $2}'`
Z2=`tail -n+$(expr $ChosenAtom2 + 2 ) $file2 | head -n1 | awk '{print $4}'`
#pi=3.1415926535
AngleXZ=`echo "a($Z2/$X2)" | bc -l`
#pi=3.1415926535
#AngleXY=`echo "$pi + $AngleXY" | bc -l`
#for xcoords in `tail -n+3 $file2 | awk '{print $2}' | head -n$natoms`
#do
echo $baseAtom2 $X2 $Y2
for line in `seq 1 $natoms`
do
        xcoords=`tail -n+$(expr $line + 2 ) $file2 | awk '{print $2}' | head -n1`
        ycoords=`tail -n+$(expr $line + 2 ) $file2 | awk '{print $3}' | head -n1`
	zcoords=`tail -n+$(expr $line + 2 ) $file2 | awk '{print $4}' | head -n1`
        echo $xcoords $zcoords $AngleXZ

        #echo "$xcoords * c($AngleXY) - $ycoords * s($AngleXY)"
        echo "$xcoords * c($AngleXZ) + $zcoords * s($AngleXZ)" | bc -l >> TMP.X.xyz
	echo "$ycoords" >> TMP.Y.xyz
        echo "$xcoords * s($AngleXZ) - $zcoords * c($AngleXZ)" | bc -l >> TMP.Z.xyz
done
paste TMP.X.xyz TMP.Y.xyz TMP.Z.xyz

echo $natoms > "$file"_translated_rotZ.xyz
echo "Translated $file about $baseAtom and rotated about $baseAtom2" >> "$file"_translated_rotZ.xyz
paste TMP.Ele.xyz TMP.X.xyz TMP.Y.xyz TMP.Z.xyz >> "$file"_translated_rotZ.xyz

baseAtom3=`tail -n+$(expr $ChosenAtom3 + 2 ) $file | head -n1 | awk '{print $3}'`
rm  TMP.X.xyz TMP.Y.xyz TMP.Z.xyz
file2="$file"_translated_rotZ.xyz
Y3=`tail -n+$(expr $ChosenAtom3 + 2 ) $file2 | head -n1 | awk '{print $3}'`
Z3=`tail -n+$(expr $ChosenAtom3 + 2 ) $file2 | head -n1 | awk '{print $4}'`
AngleYZ=`echo "a($Z3/$Y3)" | bc -l`
#pi=3.1415926535
#AngleXY=`echo "$pi + $AngleXY" | bc -l`
#for xcoords in `tail -n+3 $file2 | awk '{print $2}' | head -n$natoms`
#do
echo $baseAtom3 $X3 $Y3
for line in `seq 1 $natoms`
do
        xcoords=`tail -n+$(expr $line + 2 ) $file2 | awk '{print $2}' | head -n1`
	ycoords=`tail -n+$(expr $line + 2 ) $file2 | awk '{print $3}' | head -n1`
	zcoords=`tail -n+$(expr $line + 2 ) $file2 | awk '{print $4}' | head -n1`
        echo $xcoords $ycoords $AngleXY

        #echo "$xcoords * c($AngleXY) - $ycoords * s($AngleXY)"
       # echo "$xcoords"  >> TMP.X.xyz
	#echo "$ycoords *c($AngleYZ) + $zcoords * s($AngleYZ)" | bc -l >> TMP.Y.xyz
	echo "$xcoords"  >> TMP.X.xyz
        echo "$ycoords * c($AngleYZ) + $zcoords * s($AngleYZ)" | bc -l  >> TMP.Y.xyz
        echo "$ycoords * s($AngleYZ) - $zcoords * c($AngleYZ)" | bc -l >> TMP.Z.xyz
done
NegativityY=$(tail -n+$(expr $ChosenAtom3) TMP.Y.xyz | head -n1 | awk '{print $1}')
echo $NegativityY
if (( $(bc <<<  "$NegativityY < 0" ) ))
then
        echo y less than 0
	awk '{printf "%14.16f  \n", $1*-1}' TMP.Y.xyz >> TMP.Y.xyz.2
	mv TMP.Y.xyz.2 TMP.Y.xyz
else
        echo y greater than 0
fi
paste TMP.X.xyz TMP.Y.xyz TMP.Z.xyz

echo $natoms > "$file"_translated_rot_FIN.xyz
echo "Translated $file about $baseAtom and rotated about $baseAtom3" >> "$file"_translated_rot_FIN.xyz
paste TMP.Ele.xyz TMP.X.xyz TMP.Y.xyz TMP.Z.xyz >> "$file"_translated_rot_FIN.xyz

rm TMP.*.xyz
rm  "$file"_translated_rotZ.xyz "$file"_translated_rotY.xyz "$file"_translated.xyz
fi
