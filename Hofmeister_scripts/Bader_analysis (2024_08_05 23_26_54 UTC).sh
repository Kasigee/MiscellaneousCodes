#!/bin/bash

if [ $# -ne 7 ]
then
 echo "Usage: $0 ion functional basis_set pop_technique charge n_proc mem(gb)"
 exit
fi

ion=$1
functional=$2
basis_set=$3
pop=$4
charge=$5
n_proc=$6
mem=$7

if [[ $ion =~ 'I' ]] && [[ $basisset =~ aug-cc* ]]
then
basis_set="$basisset"-pp
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

wd=$PWD

cd $1

if [ -f "$ion"_mp2_aug-cc-pvqz.out ]
then
	out-xyz "$ion"_mp2_aug-cc-pvqz.out
	mv "$ion"_mp2_aug-cc-pvqz.xyz $ion.xyz
fi

if [ ! -f "$ion"_"$functional"_"$basis_set"_"$pop".chk ]
then
echo "Optimising Structure"
 cat <<END > $ion\_$functional\_$basis_set\_"$pop".com
%nproc=$n_proc
%mem=$mem
%chk="$ion"_"$functional"_"$basis_set"_"$pop".chk
# $functional/gen Opt=Z-Matrix Charge NoSymm scf=tight pop=$pop output=wfn

$ion ion; "$pop" charge analysis for bader charge analysis.

$charge 1
END
n_atom=`head -n1 $ion.xyz | tr '\r' ' '`
tail -n $n_atom "$ion".xyz >> "$ion"_"$functional"_"$basis_set"_"$pop".com
echo "" >> "$ion"_"$functional"_"$basis_set"_"$pop".com
echo '@'$basis_set_file'' >> "$ion"_"$functional"_"$basis_set"_"$pop".com
echo "" >> "$ion"_"$functional"_"$basis_set"_"$pop".com
echo ""$ion"_"$functional"_"$basis_set"_"$pop".wfn" >> "$ion"_"$functional"_"$basis_set"_"$pop".com
echo "" >> "$ion"_"$functional"_"$basis_set"_"$pop".com
echo "" >> "$ion"_"$functional"_"$basis_set"_"$pop".com
if grep -q 'ECP' "$basis_set_file"
then
        echo "This basis set contains ECP. Changing from basis set from gen to genecp."
        sed -i 's/'$functional'\/gen/'$functional'\/genecp/g' "$ion"_"$functional"_"$basis_set"_"$pop".com
fi
qsubg "$ion"_"$functional"_"$basis_set"_"$pop" 100:00:00 
exit 1
else
echo "Optimised structure exists"
fi

if [ $pop == 'nbo' ]
then
if [ ! -d Bader_"$functional"_"$basis_set"_"$pop" ]
then
mkdir Bader_"$functional"_"$basis_set"_"$pop"
fi
cp "$ion"_"$functional"_"$basis_set"_"$pop".chk Bader_"$functional"_"$basis_set"_"$pop"/.
cd Bader_"$functional"_"$basis_set"_"$pop"

#if [ ! -f ACF.dat ]
#then
if [ ! -f "$ion"_"$functional"_"$basis_set"_"$pop".fchk ]
then
	echo "Creating "$ion"_"$functional"_"$basis_set"_"$pop".fchk file"
	formchk "$ion"_"$functional"_"$basis_set"_"$pop".chk
fi
if [ ! -f "$ion"_"$functional"_"$basis_set"_"$pop".cube ]
then
	echo "Making "$ion"_"$functional"_"$basis_set"_"$pop".cube file"
	cubegen $n_proc Density=scf "$ion"_"$functional"_"$basis_set"_"$pop".fchk "$ion"_"$functional"_"$basis_set"_"$pop".cube -4
	echo "Bader Charge analysis step"
fi
if [ ! -f ACF.dat ]
then
	#~/hofmeister/anion_files/bader "$ion"_"$functional"_"$basis_set"_"$pop".cube
	qbader "$ion"_"$functional"_"$basis_set"_"$pop".cube 1 1gb 10:00:00
fi
#else
cat ACF.dat
n_atom=`head -n1 ../$ion.xyz | tr '\r' ' '`
lines=`echo "$n_atom + 2" | bc`
Volume=`head -n $lines ACF.dat | tail -n "$n_atom" | awk '{s+=$7}END{print s}'`
n_electrons=`grep 'NUMBER OF ELECTRONS' ACF.dat | awk '{print $4}'` 
echo $n_electrons
electron_density=`echo "$Volume/$n_electrons" | bc`
echo "Total Volume = $Volume; Electron Density = $electron_density vol/elec"
#fi
fi
