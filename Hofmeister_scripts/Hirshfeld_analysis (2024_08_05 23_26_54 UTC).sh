#!/bin/bash

if [ $# -ne 8 ]
then
 echo "Usage: $0 ion functional basis_set n_proc mem(w.gb) charge walltime multiplicity"
 exit
fi

wd=$PWD

ion=$1
functional=$2
basis_set=$3
n_proc=$4
mem=$5
charge=$6
walltime=$7
multiplicity=$8
cd $wd/$ion
n_atom=`head -n1 $ion.xyz | tr '\r' ' ' | tr -d '\n' | tr -d '[:blank:]'`
if [[ $ion =~ 'I' ]] || [[ $ion =~ 'At' ]] || [[ $ion =~ 'SbCl5' ]] && [[ $basis_set =~ aug-cc* ]] && [[ $basis_set != aug-cc*-pp ]]
then
basis_set="$basis_set"-pp
elif [[ $ion = 'K' ]] || [[ $ion =~ 'Rb' ]] || [[ $ion =~ 'Cs' ]] || [[ $ion =~ 'Ca' ]] || [[ $ion =~ 'Sr' ]] || [[ $ion =~ 'Ba' ]] && [[ $basis_set =~ aug-cc* ]] && [[ $basis_set != aug-cc*-x2c ]]
then
	basis_set="$basis_set"-x2c
	echo Updating to X2C basis: $basis_set
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
basis_set=$3
echo "BASIS_SET_FILE=$basis_set_file; BASIS_SET_NAME=$basis_set"

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

#check=`tail -n"$n_atom" $ion.xyz | grep I | wc -l`
#if [ $check -ge 1 ]
#then
#echo "Iodine in this, using lanl2dz basis set #CHECK TO SEE IF MANUALLY DONE WITH A LARGER BASIS SET - I.E. aug-cc-pVQZ-PP"
#basis_set=lanl2dz
#fi



opt=$functional
if [ $functional == hf ]
then
opt=mp2
fi



if grep -rl "Normal termination" "$ion"_"$functional"_"$basis_set".out
then
echo $ion finished
else
echo "Optimising Structure"
 cat <<END > $ion\_$functional\_$basis_set.com
%nproc=$n_proc
%mem=$mem
%chk="$ion"_"$functional"_"$basis_set".chk
# $opt/gen opt integral=ultrafine scf=tight

$ion ion; Optimisation calculation for Polarisabilty partitioning.

$charge $multiplicity
END
if grep 'Normal termination' $wd/"$ion"/DDEC6_"$functional"_"$basis_set"/"$ion"_"$functional"_"$basis_set"_DDEC6.out
then
cd $wd/"$ion"/DDEC6_"$functional"_"$basis_set"
out-xyz "$ion"_"$functional"_"$basis_set"_DDEC6.out
cp "$ion"_"$functional"_"$basis_set"_DDEC6.xyz ../.
cd ..
tail -n $n_atom "$ion"_"$functional"_"$basis_set"_DDEC6.xyz | awk '{print $1,$2,$3,$4}' >> "$ion"_"$functional"_"$basis_set".com
else
tail -n $n_atom "$ion".xyz | awk '{print $1,$2,$3,$4}' >> "$ion"_"$functional"_"$basis_set".com
fi
echo "" >> "$ion"_"$functional"_"$basis_set".com
if echo $basis_set | grep 'pp'
then
        echo '@'$base_basis_set_file'' >> "$ion"_"$functional"_"$basis_set".com
fi
if echo $basis_set | grep 'x2c'
then
        echo '@'$base_basis_set_file2'' >> "$ion"_"$functional"_"$basis_set".com
fi
echo '@'$basis_set_file'' >> "$ion"_"$functional"_"$basis_set".com

cat <<END >> $ion\_$functional\_$basis_set.com


--link1--
%nproc=$n_proc
%mem=$mem
%chk="$ion"_"$functional"_"$basis_set".chk
# $functional chkbasis geom=check guess=check scf=tight integral=ultrafine Pop=Hirshfeld

$ion ion; calculation 1: Fx=Fy=Fz=0 a.u

$charge $multiplicity

--link1--
%nproc=$n_proc
%mem=$mem
%chk="$ion"_"$functional"_"$basis_set".chk
# $functional chkbasis geom=check guess=check scf=tight integral=ultrafine Field=X+10 Pop=Hirshfeld

$ion ion; calculation 2: Fx=-0.0001 a.u

$charge $multiplicity

--link1--
%nproc=$n_proc
%mem=$mem
%chk="$ion"_"$functional"_"$basis_set".chk
# $functional chkbasis geom=check guess=check scf=tight integral=ultrafine Field=Y+10 Pop=Hirshfeld

$ion ion; calculation 3: Fy=-0.0001 a.u

$charge $multiplicity

--link1--
%nproc=$n_proc
%mem=$mem
%chk="$ion"_"$functional"_"$basis_set".chk
# $functional chkbasis geom=check guess=check scf=tight integral=ultrafine Field=Z+10 Pop=Hirshfeld

$ion ion; calculation 4: Fz=-0.0001 a.u

$charge $multiplicity

--link1--
%nproc=$n_proc
%mem=$mem
%chk="$ion"_"$functional"_"$basis_set".chk
# $functional chkbasis geom=check guess=check scf=tight integral=ultrafine polar

$ion ion; Standard Polar Calc

$charge $multiplicity

END

echo "" >> "$ion"_"$functional"_"$basis_set".com
echo "" >> "$ion"_"$functional"_"$basis_set".com
echo "" >> "$ion"_"$functional"_"$basis_set".com

qued=`qstat -f | grep "$ion"_"$functional"_"$basis_set". | wc -l`
if [ $qued -ge 1 ]
then
echo qued
else
if grep -q 'ECP' "$basis_set_file"
then
        echo "This basis set contains ECP. Changing from basis set from gen to genecp."
        sed -i 's/'$functional'\/gen/'$functional'\/genecp/g' "$ion"_"$functional"_"$basis_set"_DDEC6.com
	sed -i 's/'$functional'\/gen/'$functional'\/genecp/g' "$ion"_"$functional"_"$basis_set".com
fi	
	qsubg "$ion"_"$functional"_"$basis_set" $walltime
fi
fi

POL=`grep 'Exact polarizability:' "$ion"_"$functional"_"$basis_set".out`
echo $ion $POL

count=`grep "Normal termination" "$ion"_"$functional"_"$basis_set".out | wc -l`
if [ $count -ge 5 ]
then
cd $wd
~/hofmeister/anion_files/Hirshfeld_analysis_results.sh $ion $functional $basis_set
fi

exit 1
