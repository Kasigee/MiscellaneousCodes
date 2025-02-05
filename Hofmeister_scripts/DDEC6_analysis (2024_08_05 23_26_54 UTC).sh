#!/bin/bash

if [ $# -ne 7 ]
then
 echo "Usage: $0 ion functional basis_set charge multiplicity n_proc mem(gb)"
 exit
fi

wd=$PWD
ion=$1
functional=$2
basis_set=$3
charge=$4
multiplicity=$5
n_proc=$6
mem=$7
cd $ion
n_atom=`head -n1 $ion.xyz | tr '\r' ' '`


#check=`tail -n"$n_atom" $ion.xyz | grep I | wc -l`
#if [ $check -ge 1 ]
#then
#echo "Iodine in this, using lanl2dz basis set"
#basis_set=lanl2dz
#fi


qued=`qstat -f | grep "$ion"_"$functional"_"$basis_set"_DDEC6 | wc -l`
if [ $qued -ge 1 ]
then
echo ""$ion"_"$functional"_"$basis_set"_DDEC6 already qued"
exit 1
else
echo continue
#exit 1
fi



if [ -f "$ion"_"$functional"_"$basis_set".out ]
then
out-xyz "$ion"_"$functional"_"$basis_set".out
cp "$ion"_"$functional"_"$basis_set".xyz $ion.xyz
fi

if [ ! -d DDEC6_"$functional"_"$basis_set" ]
then
mkdir DDEC6_"$functional"_"$basis_set"
fi
cd DDEC6_"$functional"_"$basis_set"
#cp ../"$ion"_"$functional"_"$basis_set".xyz .
#cp "$ion"_"$functional"_"$basis_set".xyz $ion.xyz
cp ../"$ion".xyz .

if [ ! -f "$ion"_"$functional"_"$basis_set"_DDEC6.chk ] && ! grep -rl "Normal termination" "$ion"_"$functional"_"$basis_set"_DDEC6.out 
then
echo "Optimising Structure"
 cat <<END > $ion\_$functional\_$basis_set\_DDEC6.com
%nproc=$n_proc
%mem=$mem
%chk="$ion"_"$functional"_"$basis_set"_DDEC6.chk
#P $functional/$basis_set opt guess=mix
# scf=(fermi,maxcycle=400,tight) density=current output=wfx pop=NOAB

$ion ion; DDEC6 charge analysis.

$charge $multiplicity
END
n_atom=`head -n1 $ion.xyz | tr '\r' ' '`
tail -n $n_atom "$ion".xyz >> "$ion"_"$functional"_"$basis_set"_DDEC6.com
echo "" >> "$ion"_"$functional"_"$basis_set"_DDEC6.com
echo ""$ion"_"$functional"_"$basis_set"_DDEC6.wfx" >> "$ion"_"$functional"_"$basis_set"_DDEC6.com
echo "" >> "$ion"_"$functional"_"$basis_set"_DDEC6.com
echo "" >> "$ion"_"$functional"_"$basis_set"_DDEC6.com
if grep 'Error termination request processed by link 9999' "$ion"_"$functional"_"$basis_set"_DDEC6.out
then
	sed -i "s/opt/opt=(maxcycles=100,maxstep=50,restart)" "$ion"_"$functional"_"$basis_set"_DDEC6.com
	direct=$PWD
	sed -i "s/chk="$ion"/$PWD/g" "$ion"_"$functional"_"$basis_set"_DDEC6.com
fi
exit 1
qsubg "$ion"_"$functional"_"$basis_set"_DDEC6 80:00:00
exit 1
else
echo "Optimised structure exists"
fi

cp ~/bin/job_control.txt .
sed -i 's/XXXXXXXX/'$ion'_'$functional'_'$basis_set'_DDEC6/g' job_control.txt


#if  [ ! -f "$ion"_"$functional"_"$basis_set"_DDEC6.output ]
#if [ ! -f DDEC6_even_tempered_net_atomic_charges.xyz ]
if [ ! -f DDEC_weighted_Rfourth_moments.xyz ]
then
#Chargemol_09_26_2017_linux_parallel
#qsubddec6 "$ion"_"$functional"_"$basis_set"_DDEC6 10:00:00
/home/ajp/qsubddec6 "$ion"_"$functional"_"$basis_set"_DDEC6 $n_proc $mem 10:00:00
else
echo "Chargemol completed." 

#linenumber=`grep -n 'Net atomic charges for the current iteration' "$ion"_"$functional"_"$basis_set"_DDEC6.output | awk -F: '{print $1}' | tail -n1`
#linenumber2=`expr $linenumber + 1`
#Charges=`sed ''$linenumber2'q;d' "$ion"_"$functional"_"$basis_set"_DDEC6.output`
#echo "Charges are: $Charges ?"
cd ~/hofmeister/anion_files
./calculate_sho.sh $ion $functional $basis_set $n_proc $mem
fi
