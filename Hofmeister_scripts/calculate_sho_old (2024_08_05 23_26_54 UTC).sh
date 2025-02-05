#!/bin/bash

if [ $# -ne 3 ]
then
 echo "Usage: $0 ion functional basis_set"
 exit
fi


ion=$1
functional=$2
basisset=$3

natom=`head -n1 $ion/$ion.xyz`
number=`expr $natom + 1`
atomicnetcharges=`grep -A $number 'The following XYZ coordinates are in angstroms. The' $ion/DDEC6_"$functional"_"$basisset"/DDEC6_even_tempered_net_atomic_charges.xyz | tail -n $natom | awk '{print $2,$6}'`
printf "Net Atomic Charges are: \n$atomicnetcharges \n"
atomicvolumes=`grep -A $natom 'Nonperiodic system' $ion/DDEC6_"$functional"_"$basisset"/DDEC_atomic_Rcubed_moments.xyz | tail -n $natom | awk '{print $1, $5}'`
printf "Atomic Rcubedmoments (Bohr) are: \n$atomicvolumes \n"

TOTALVOL=0
TOTALCHARGE=0
TOTALsho=0
TOTALRAD=0
echo "SHO"
for i in `seq 1 $natom`
do
Element=`echo "$atomicnetcharges" | awk '{print $1}' | head -n$i | tail -n1`
number=`expr $natom-$i`
AC2=`echo "$atomicnetcharges" | awk '{print $2}' | head -n$i | tail -n1`
AV2=`echo "$atomicvolumes" | awk '{print $2}'| head -n$i | tail -n1`
AR=`echo "scale=6; e(l($AV2)/3)" | bc -l`
#echo $AR
sho=`echo "scale=6; $AR/$AC2" | bc`
TOTALVOL=`echo "$TOTALVOL + $AV2" | bc`
TOTALRAD=`echo "scale=6; e(l($TOTALVOL)/3)" | bc -l`
#TOTALRAD=`echo "$TOTALRAD + $AR" | bc`
TOTALCHARGE=`echo "$TOTALCHARGE + $AC2" | bc`
#TOTALsho=`echo "$TOTALsho + $sho" | bc`
echo $Element $sho $TOTALVOL $TOTALRAD
done
TOTALsho=`echo "scale=6; $TOTALRAD/$TOTALCHARGE" | bc`
echo "Total molecule volume = $TOTALVOL; Total molecule radius = $TOTALRAD; Total molecular charge = $TOTALCHARGE; TOTAL SHO = $TOTALsho (Think these Total sho calcs through...)"
