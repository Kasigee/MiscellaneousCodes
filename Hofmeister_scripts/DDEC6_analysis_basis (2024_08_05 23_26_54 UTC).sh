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
if [[ $ion =~ 'I' ]] || [[ $ion =~ 'At' ]] || [[ $ion =~ 'iodobenzene' ]] || [[ $ion =~ 'At' ]] || [[ $ion =~ 'Te' ]] || [[ $ion =~ 'Po' ]] || [[ $ion =~ 'Sb' ]] || [[ $ion =~ 'Bi' ]] ||  [[ $ion =~ 'Xe' ]] || [[ $ion =~ 'Rn' ]] || [[ $ion =~ 'Ag' ]] || [[ $ion =~ Cd ]] || [[ $ion =~ Hg ]] || [[ $ion =~ Pb ]]  && [[ $basis_set =~ aug-cc* ]] && [[ $basis_set != aug-cc-*-p* ]] 
then
basis_set="$basis_set"-pp
elif [[ $ion = 'Kr' ]] && [[ ! $ion =~ 'KKr' ]]
then
	basis_set="$basis_set"
elif [[ $ion = 'K' ]] || [[ $ion =~ 'Rb' ]] || [[ $ion =~ 'Cs' ]] || [[ $ion =~ 'Ca' ]] || [[ $ion =~ 'Sr' ]] || [[ $ion =~ 'Ba' ]] && [[ $basis_set =~ aug-cc* ]] && [[ $basis_set != aug-cc*-x2c ]]
then
        basis_set="$basis_set"-x2c
fi

case "$basis_set" in
        Def2QZVPP)
                basis_set=def2-qzvpp
                ;;
        Def2SV)
               basis_set=def2-sv
               ;;
       Def2TZVP)
                basis_set=def2-tzvp
                ;;
esac

basis_set_file=`ls ~/bin/basis_set_bundle-gaussian94-bib3/$basis_set.*gbs | tail -n1`
if echo $basis_set | grep 'pp-x2c'
then
	base=`echo $basis_set | awk -F'-pp' '{print $1}'`
	base="$base"-x2c
	echo $base
	basis_set_file=`ls ~/bin/basis_set_bundle-gaussian94-bib3/$base.*gbs | tail -n1`
fi


if echo $basis_set | grep 'pp'
then
	base=`echo $basis_set | awk -F'-pp' '{print $1}'`
	base_basis_set_file=`ls ~/bin/basis_set_bundle-gaussian94-bib3/"$base".*gbs | tail -n1`
fi
if echo $basis_set | grep 'x2c'
then
	base=`echo $basis_set | awk -F'-x2c' '{print $1}'`
        base_basis_set_file2=`ls ~/bin/basis_set_bundle-gaussian94-bib3/"$base".*gbs | tail -n1`
fi
#basis_set=$3
echo $basis_set_file $base_basis_set_file $base_basis_set_file2

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



#if [ -f "$ion"_"$functional"_"$basis_set".out ]
if grep -rl "Normal termination" "$ion"_"$functional"_"$basis_set".out
then
	echo "Normally terminated "$ion"_"$functional"_"$basis_set".out exists"
	out-xyz "$ion"_"$functional"_"$basis_set".out
	cp "$ion"_"$functional"_"$basis_set".xyz $ion.xyz
elif grep -rl "Normal termination" "$ion"_"$functional"_aug-cc-pvdz.out
then
	out-xyz "$ion"_"$functional"_aug-cc-pvdz.out
	cp "$ion"_"$functional"_aug-cc-pvdz.xyz $ion.xyz
fi

if [ ! -d DDEC6_"$functional"_"$basis_set" ]
then
mkdir DDEC6_"$functional"_"$basis_set"
fi
cd DDEC6_"$functional"_"$basis_set"
#cp ../"$ion"_"$functional"_"$basis_set".xyz .
#cp "$ion"_"$functional"_"$basis_set".xyz $ion.xyz
cp ../"$ion".xyz .

#if [ ! -f "$ion"_"$functional"_"$basis_set"_DDEC6.chk ] || ! grep -rl "Normal termination" "$ion"_"$functional"_"$basis_set"_DDEC6.out 
if ! grep -rl "Normal termination" "$ion"_"$functional"_"$basis_set"_DDEC6.out
then
echo "Optimising Structure"
 cat <<END > $ion\_$functional\_$basis_set\_DDEC6.com
%nproc=$n_proc
%mem=$mem
%chk="$ion"_"$functional"_"$basis_set"_DDEC6.chk
#P $functional/gen opt guess=mix
# scf=(fermi,maxcycle=400,tight) density=current output=wfx pop=NOAB

$ion ion; DDEC6 charge analysis.

$charge $multiplicity
END
n_atom=`head -n1 $ion.xyz | tr '\r' ' '`
tail -n $n_atom "$ion".xyz | awk '{print $1,$2,$3,$4}' >> "$ion"_"$functional"_"$basis_set"_DDEC6.com
echo "" >> "$ion"_"$functional"_"$basis_set"_DDEC6.com
#if echo $basis_set | grep 'pp' && ! echo $basis_set | grep 'x2c' 
if echo $basis_set | grep 'pp'
then
	echo '@'$base_basis_set_file'' >> "$ion"_"$functional"_"$basis_set"_DDEC6.com
fi
if echo $basis_set | grep 'x2c'
then
        echo '@'$base_basis_set_file2'' >> "$ion"_"$functional"_"$basis_set"_DDEC6.com
fi
echo '@'$basis_set_file'' >> "$ion"_"$functional"_"$basis_set"_DDEC6.com
echo "" >> "$ion"_"$functional"_"$basis_set"_DDEC6.com
echo ""$ion"_"$functional"_"$basis_set"_DDEC6.wfx" >> "$ion"_"$functional"_"$basis_set"_DDEC6.com
echo "" >> "$ion"_"$functional"_"$basis_set"_DDEC6.com
echo "" >> "$ion"_"$functional"_"$basis_set"_DDEC6.com
echo TESTLINE $basis_set_file
if grep -q 'ECP' "$basis_set_file" || grep -q 'ECP' "$base_basis_set_file" || grep -q 'ECP' "$base_basis_set_file2"
then
        echo "This basis set contains ECP. Changing from basis set from gen to genecp."
        sed -i 's/'$functional'\/gen/'$functional'\/genecp/g' "$ion"_"$functional"_"$basis_set"_DDEC6.com
fi
if grep 'Error termination request processed by link 9999' "$ion"_"$functional"_"$basis_set"_DDEC6.out
then
        sed -i 's/opt /opt=(maxcycles=100,maxstep=50,restart) /g' "$ion"_"$functional"_"$basis_set"_DDEC6.com
        sed -i 's/chk="'$ion'"/chk=\/home\/kpg600\/hofmeister\/inert\/'$ion'\/DDEC6_'$functional'_'$basis_set'\/"'$ion'"/g' "$ion"_"$functional"_"$basis_set"_DDEC6.com
fi
qsubg "$ion"_"$functional"_"$basis_set"_DDEC6 300:00:00
exit 1
else
echo "Optimised structure exists"
fi

cp ~/bin/job_control.txt .
sed -i 's/XXXXXXXX/'$ion'_'$functional'_'$basis_set'_DDEC6/g' job_control.txt



#echo $basis_set
#if [ "$basis_set" == Def2QZVPP ]
#then
#	echo $basis_set is Def2QZVPP --> not using gen...?
#	sed -i 's/'$functional/'gen/'$functional/'Def2QZVPP/g' "$ion"_"$functional"_"$basis_set"_DDEC6.com
#	linenumber=`grep -n '@'  "$ion"_"$functional"_"$basis_set"_DDEC6.com | cut -d : -f 1`
#	sed -i ''$linenumber'd' "$ion"_"$functional"_"$basis_set"_DDEC6.com
#	sed -i ''$linenumber'd' "$ion"_"$functional"_"$basis_set"_DDEC6.com
#fi


#if  [ ! -f "$ion"_"$functional"_"$basis_set"_DDEC6.output ]
#if [ ! -f DDEC6_even_tempered_net_atomic_charges.xyz ]
if [ ! -f DDEC_weighted_Rfourth_moments.xyz ]
then
#Chargemol_09_26_2017_linux_parallel
#qsubddec6 "$ion"_"$functional"_"$basis_set"_DDEC6 10:00:00
#/home/ajp/qsubddec6 "$ion"_"$functional"_"$basis_set"_DDEC6 $n_proc $mem 10:00:00 allq
/drives/d/RCG/bin/MCLF/Chargemol_08_22_2019/sourcecode_08_22_2019_backup/Chargemol_08_22_2019_linux_serial
else
echo "Chargemol completed." 

#linenumber=`grep -n 'Net atomic charges for the current iteration' "$ion"_"$functional"_"$basis_set"_DDEC6.output | awk -F: '{print $1}' | tail -n1`
#linenumber2=`expr $linenumber + 1`
#Charges=`sed ''$linenumber2'q;d' "$ion"_"$functional"_"$basis_set"_DDEC6.output`
#echo "Charges are: $Charges ?"
cd $wd
~/hofmeister/anion_files/calculate_sho.sh $ion $functional $basis_set $n_proc $mem
fi
