#!/bin/bash

if [ $# -ne 4 ]
then
echo Usage:$0 molecule1 molecule2 functional basis_set
exit 0
fi

molecule1=$1
molecule2=$2
functional=$3
basis_set=$4


if [ $(ls -d ../cation_files/$molecule1/DDEC6_"$functional"_"$basis_set"/DDEC6_even_tempered_net_atomic_charges.xyz | wc -l) -ge 1 ]
then
        basefolder1=~/hofmeister/cation_files
elif [ $(ls -d $molecule1/DDEC6_"$functional"_"$basis_set"/DDEC6_even_tempered_net_atomic_charges.xyz | wc -l) -ge 1 ]
then
	basefolder1=$PWD
else
	echo $molecule1 not calculated via DDEC6 etc yet. Adding placeholder to TotalUE.dat.
	echo -e ""$molecule1"-"$molecule2" $functional $basis_set U_E\t =\t #NA (kJ/mol)" >> TotalUE.dat
	exit 0
fi

if [ $(ls -d ../cation_files/$molecule2/DDEC6_"$functional"_"$basis_set"/DDEC6_even_tempered_net_atomic_charges.xyz | wc -l) -ge 1 ]
then
        basefolder2=~/hofmeister/cation_files
elif [ $(ls -d $molecule2/DDEC6_"$functional"_"$basis_set"/DDEC6_even_tempered_net_atomic_charges.xyz | wc -l) -ge 1 ]
then
        basefolder2=$PWD
else
        echo $molecule2 not calculated via DDEC6 etc yet. Adding placeholder to TotalUE.dat.
	echo -e ""$molecule1"-"$molecule2" $functional $basis_set U_E\t =\t #NA (kJ/mol)" >> TotalUE.dat
        exit 0
fi
echo $basefolder1
echo $basefolder2


natoms1=$(cat $basefolder1/$molecule1/$molecule1.xyz | head -n1 | awk '{print $1}')
natoms2=$(cat $basefolder2/$molecule2/$molecule2.xyz | head -n1 | awk '{print $1}')
#listofatoms1=`cat $molecule1/$molecule1.xyz | tail -n+3 | awk '{print $1}'`
#echo $natoms1
#echo $natoms2
#for listof atoms in molecule
#charges1=$(cat $basefolder1/$molecule1/DDEC6_"$functional"_"$basis_set"/DDEC6_even_tempered_net_atomic_charges.xyz | awk '/The following XYZ/,/The spherically/' | head -n-2 | tail -n+3 | awk '{print $6}')
#charges2=$(cat $basefolder2/$molecule2/DDEC6_"$functional"_"$basis_set"/DDEC6_even_tempered_net_atomic_charges.xyz | awk '/The following XYZ/,/The spherically/' | head -n-2 | tail -n+3 | awk '{print $6}')
charges1=$(cat $molecule1$molecule2/DDEC6_"$functional"_"$basis_set"/DDEC6_even_tempered_net_atomic_charges.xyz | awk '/The following XYZ/,/The spherically/' | head -n-2 | tail -n+3 | awk '{print $6}' | head -n$natoms1)
charges2=$(cat $molecule1$molecule2/DDEC6_"$functional"_"$basis_set"/DDEC6_even_tempered_net_atomic_charges.xyz | awk '/The following XYZ/,/The spherically/' | head -n-2 | tail -n+3 | awk '{print $6}' | tail -n$natoms2)

Element1=$(cat $molecule1$molecule2/DDEC6_"$functional"_"$basis_set"/DDEC6_even_tempered_net_atomic_charges.xyz | awk '/The following XYZ/,/The spherically/' | head -n-2 | tail -n+3 | awk '{print $2}' | head -n$natoms1)
Element2=$(cat $molecule1$molecule2/DDEC6_"$functional"_"$basis_set"/DDEC6_even_tempered_net_atomic_charges.xyz | awk '/The following XYZ/,/The spherically/' | head -n-2 | tail -n+3 | awk '{print $2}' | tail -n$natoms2)
r31=$(cat $molecule1$molecule2/DDEC6_"$functional"_"$basis_set"/DDEC_atomic_Rcubed_moments.xyz | tail -n$natoms1 | awk '{print $6^(1/3)}')
r32=$(cat $molecule1$molecule2/DDEC6_"$functional"_"$basis_set"/DDEC_atomic_Rcubed_moments.xyz | tail -n$natoms2 | awk '{print $6^(1/3)}')
#cat $molecule1/DDEC6_"$functional"_"$basis_set"/DDEC_atomic_Rcubed_moments.xyz | tail -n$natoms1 | awk '{print $6}'
#r11=$(echo "$r31^(1/3)" | bc -l)

#echo r11 $r11
#echo r22 $r22


echo q1 $charges1
echo q2 $charges2
echo r31 $r31

#LowestE=`grep 'E(RM062X)' ../ion_int/$molecule1/$molecule2/"$molecule1""$molecule2"_m062x_aug-cc-pvdz_*.out  | awk '{print $6}' | N=1 awk -v N=$N 'NR == 1 { min = max = $N } { if ($N > max) max = $N; else if ($N < min) min = $N } END     { print max }' | awk -F'-' '{print $2}'`

if [ ! -f $molecule1$molecule2/DDEC6_"$functional"_"$basis_set"/DDEC6_even_tempered_net_atomic_charges.xyz ]
then
	echo No "$molecule1"-"$molecule2" SAPT calc to find lowest energy geom. Exiting. Adding placeholder to TotalUE.dat.
	echo -e ""$molecule1"-"$molecule2" $functional $basis_set U_E\t =\t #NA (kJ/mol)" >> TotalUE.dat
	exit 1
else
#LowestE=$(grep -a -m1 'Total SAPT2+3' ../ion_int/$molecule1/$molecule2/"$molecule1""$molecule2"_SAPT_aug-cc-pvdz* | awk '{print $8}' | N=1 awk -v N=$N 'NR == 1 { min = max = $N } { if ($N > max) max = $N; else if ($N < min) min = $N } END     { print  min }'  | awk -F'-' '{print $2}')
#echo LowestE = $LowestE
##echo $LowestE
##LowestEGeom=$(grep $LowestE ../ion_int/$molecule1/$molecule2/"$molecule1""$molecule2"_m062x_aug-cc-pvdz_*.out | awk -F':' '{print $1}')
#LowestESAPT=$(grep -a $LowestE ../ion_int/$molecule1/$molecule2/"$molecule1""$molecule2"_SAPT_aug-cc-pvdz* | awk -F':' '{print $1}')
#LowestESAPT_num=$(echo $LowestESAPT | awk -F'_' '{print $NF}' | awk -F. '{print $1}')
##echo $LowestESAPT_num
#LowestEGeom="../ion_int/$molecule1/$molecule2/"$molecule1""$molecule2"_m062x_aug-cc-pvdz_"$LowestESAPT_num".out"

LowestEGeom=$molecule1$molecule2/DDEC6_"$functional"_"$basis_set"/"$molecule1""$molecule2"_"$functional"_"$basis_set"_DDEC6.out

#echo LOWESTEGEOM=$LowestESAPT
TOTALUE=0
count=1
for i in $(seq 1  $natoms1)
do
	Divisibility=$(echo "5 * $count + 1" | bc )
	#echo Divisibility= $Divisibility
#	i2=$(expr $i + 2)
	if ! (( $i % $Divisibility ))
        then
		#i2=$(echo "$i2 - ( $count - 1) * 5)" | bc)
                count=$(expr $count + 1)
                #echo $count
        fi
        i2=$(echo "($i + 2) - (( $count - 1) * 5)" | bc)
	#echo i2=$i2
	for j in $(seq 1 $natoms2)
	do
		#echo $i $j
		k=$(expr $j + $natoms1)
		AtomA=$(echo $Element1 | awk '{print $'$i'}')
		AtomB=$(echo $Element2 | awk '{print $'$j'}')
		q1=$(echo $charges1 | awk '{print $'$i'}')
		q2=$(echo $charges2 | awk '{print $'$j'}')
		r1a=$(echo $r31 | awk '{print $'$i'}')
		r2a=$(echo $r32 | awk '{print $'$j'}')
		#r1=$(echo "$r1a**(1/3)" | bc -l)
		#r2=$(echo "$r2a**(1/3)" | bc -l)
#		UE=$(echo "($q1 * $q2 / ( $r1a + $r2a ) ) * 1420.788951" | bc -l)
#		echo "$molecule1($AtomA)-$molecule2($AtomB) U_E = $UE (kJ/mol)"
#		TOTALUE=$(echo "$TOTALUE + $UE" | bc -l)
#		grep "R($i,$k)" ../ion_int/$molecule1/$molecule2/"$molecule1""$molecule2"_m062x_aug-cc-pvdz_10.out
		#i2=$(expr $i + 2)
		#if ! (( $i % 5 ))
		#then
	#		count=$(expr $count + 1)
	#		echo $count
	#	fi
			R=`awk '/Stationary point found./,/Stoichiometry/' $LowestEGeom | awk '/Distance matrix/,/Stoichiometry/' | head -n-1 | tail -n+2 | grep "$k  $AtomB" | awk '{print $'$i2'}' | head -n$count | tail -n1`
		#else
		#	R=`awk '/Stationary point found./,/Stoichiometry/' ../ion_int/$molecule1/$molecule2/"$molecule1""$molecule2"_m062x_aug-cc-pvdz_10.out | awk '/Distance matrix/,/Stoichiometry/' | head -n-1 | tail -n+2 | grep "$k  $AtomB" | awk '{print $'$i2'}' | tail -n1`
		#fi
		echo $R $k $AtomB $q1 $q2
		UE=$(echo "($q1 * $q2 / ( $R ) ) * 1420.788951" | bc -l)
                echo "$molecule1($AtomA)-$molecule2($AtomB) U_E = $UE (kJ/mol)"
                TOTALUE=$(echo "$TOTALUE + $UE" | bc -l)

	done
done
echo ""$molecule1"-"$molecule2" U_E = $TOTALUE (kJ/mol)"
echo -e ""$molecule1"-"$molecule2" $functional $basis_set U_E\t =\t $TOTALUE (kJ/mol)" >> TotalUE.dat

#echo "Now need to make this for actual geometries - currently only uses shortest distances based on R - DONE."
#echo "Now need to fix the bug (arising from lazyness) for finding the correct distance from the matrix (and I suppose ideally using the minimum geometry energy too. - DONE"
#echo "also need to fix so that it'll read cation files too. - DONE"

exit 0
n=0
#echo ${!n}
for charge in $charges1
do
#	echo ${!n}
	n=$(expr $n + 1)
#	echo ${!n}
	echo r= ${r31[1]}
	echo $charge
	for charge2 in $charges2
		do
			#printf '%02d\n' "$((10#$charge*10#$charge2))"
			echo "$charge * $charge2" | bc -l
		done
#	n=$n+1
#	r=$(echo $r3_1 | awk '{print $'$n'}')
#	echo $r
done
fi
