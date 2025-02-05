#!/bin/bash

if [ $# -ne 7 ]
then
 echo "Usage: $0 ion functional basis_set n_proc mem(w.gb) charge walltime"
 exit
fi


ion=$1
functional=$2
basis_set=$3
n_proc=$4
mem=$5
charge=$6
walltime=$7


wd=$PWD

cd $wd/$ion

if [ ! -f "$ion"_"$functional"_"$basis_set"_nbo.out ]
then
echo "Optimising Structure"
 cat <<END > "$ion"_"$functional"_"$basis_set"_nbo.com
%nproc=$n_proc
%mem=$mem
%chk="$ion"_"$functional"_"$basis_set"_nbo.chk
# $functional/$basis_set opt integral=ultrafine scf=tight

$ion ion; Optimisation calculation for Polarisabilty partitioning.

$charge 1
END
n_atom=`head -n1 $ion.xyz | tr '\r' ' '`
tail -n $n_atom "$ion".xyz >> "$ion"_"$functional"_"$basis_set"_nbo.com
cat <<END >> "$ion"_"$functional"_"$basis_set"_nbo.com

--link1--
%chk="$ion"_"$functional"_"$basis_set"_nbo.chk
# $functional chkbasis geom=check guess=check scf=tight integral=ultrafine Pop=nbo

$ion ion; calculation 1: Fx=Fy=Fz=0 a.u

$charge 1

--link1--
%chk="$ion"_"$functional"_"$basis_set"_nbo.chk
# $functional chkbasis geom=check guess=check scf=tight integral=ultrafine Field=X+10 Pop=nbo

$ion ion; calculation 2: Fx=-0.0001 a.u

$charge 1

--link1--
%chk="$ion"_"$functional"_"$basis_set"_nbo.chk
# $functional chkbasis geom=check guess=check scf=tight integral=ultrafine Field=Y+10 Pop=nbo

$ion ion; calculation 3: Fy=-0.0001 a.u

$charge 1

--link1--
%chk="$ion"_"$functional"_"$basis_set"_nbo.chk
# $functional chkbasis geom=check guess=check scf=tight integral=ultrafine Field=Z+10 Pop=nbo

$ion ion; calculation 4: Fz=-0.0001 a.u

$charge 1

--link1--
%chk="$ion"_"$functional"_"$basis_set"_nbo.chk
# $functional chkbasis geom=check guess=check scf=tight integral=ultrafine polar

$ion ion; Standard Polar Calc

$charge 1

END

echo "" >> "$ion"_"$functional"_"$basis_set"_nbo.com
echo "" >> "$ion"_"$functional"_"$basis_set"_nbo.com
echo "" >> "$ion"_"$functional"_"$basis_set"_nbo.com

qsubg "$ion"_"$functional"_"$basis_set"_nbo $walltime

fi

POL=`grep 'Exact polarizability:' "$ion"_"$functional"_"$basis_set"_nbo.out`
echo $ion $POL


exit 1
