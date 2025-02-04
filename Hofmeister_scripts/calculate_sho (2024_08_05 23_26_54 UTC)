#!/bin/bash

if [ $# -ne 5 ]
then
 echo "Usage: $0 ion functional basis_set n_proc mem"
 exit
fi


ion=$1
functional=$2
basisset=$3
n_proc=$4
mem=$5

if [[ $ion =~ 'I' ]] || [[ $ion =~ 'At' ]] || [[ $ion =~ 'iodobenzene' ]] || [[ $ion =~ 'At' ]] || [[ $ion =~ Ag ]] || [[ $ion =~ Cd ]] || [[ $ion =~ Hg ]] || [[ $ion =~ Pb ]]   && [[ $basisset =~ aug-cc* ]] && [[ $basisset != aug-cc-*-p* ]]
then
basisset="$basisset"-pp
elif [[ $ion = 'K' ]] || [[ $ion =~ 'Rb' ]] || [[ $ion =~ 'Cs' ]]|| [[ $ion =~ 'Ca' ]] || [[ $ion =~ 'Sr' ]] || [[ $ion =~ 'Ba' ]] && [[ $basisset =~ aug-cc* ]] && [[ $basisset != aug-cc*-x2c ]]
then
        basisset="$basisset"-x2c
fi

if [[ $ion =~ 'SbCl5' ]] && [[ $basisset =~ aug-cc* ]] && [[ $basisset != aug-cc*-pp ]]
then
basisset="$basisset"-pp
fi


if [ ! -f $ion/DDEC6_"$functional"_"$basisset"/DDEC6_even_tempered_net_atomic_charges.xyz ] && [[ $ion != Kr ]]
	then
		exit 1
fi
charge=`grep Charge $ion/DDEC6_"$functional"_"$basisset"/"$ion"_"$functional"_"$basisset"_DDEC6.out | head -n1 | awk '{print $3}'`
multiplicity=`grep Multiplicity $ion/DDEC6_"$functional"_"$basisset"/"$ion"_"$functional"_"$basisset"_DDEC6.out | head -n1 | awk '{print $6}'`
if [[ $ion = 'Kr' ]] || [[ $ion = 'Ar' ]] || [[ $ion = 'Ne' ]] || [[ $ion = 'He' ]]
then
charge=0
multiplicity=1
fi

echo charge=$charge
echo multiplicity=$multiplicity


~/hofmeister/anion_files/Hirshfeld_analysis_results.sh $ion $functional $basisset > tmp.dat
~/hofmeister/anion_files/Hirshfeld_analysis.sh $ion $functional $basisset $n_proc $mem $charge 100:00:00 $multiplicity

POL=`tail -n1 tmp.dat | awk '{print $5}'`
rm tmp.dat

natom=`head -n1 $ion/$ion.xyz`
number=`expr $natom + 1`
atomicnetcharges=`grep -A $number 'The following XYZ coordinates are in angstroms. The' $ion/DDEC6_"$functional"_"$basisset"/DDEC6_even_tempered_net_atomic_charges.xyz | tail -n $natom | awk '{print $2,$6}'`
printf "Net Atomic Charges are: \n$atomicnetcharges \n"
#printf "Net Atomic Charges are: \n$atomicnetcharges \n" > tmpANC.dat
atomicvolumes=`grep -A $natom 'Nonperiodic system' $ion/DDEC6_"$functional"_"$basisset"/DDEC_atomic_Rcubed_moments.xyz | tail -n $natom | awk '{print $1, $5}'`
printf "Atomic Rcubedmoments (Bohr) are: \n$atomicvolumes \n"
#printf "Atomic Rcubedmoments (Bohr) are: \n$atomicvolumes \n" > tmpAV.dat

TOTALVOL=0
TOTALCHARGE=0
TOTALsho=0
TOTALRAD=0
echo "SHO" > $ion/DDEC6_"$functional"_"$basisset"/sho_data.dat
echo "Ion(Element) (POL_to_be_added_here) r_cubed_moment r_moment_bohr r_moment_A r_moment_m q(e-) E? MetricSho(x10-10C.m^-1)" >> $ion/DDEC6_"$functional"_"$basisset"/sho_data.dat
echo "SHO"
echo "Ion(Element) (POL_to_be_added_here) r_cubed_moment r_moment_bohr r_moment_A r_moment_m q(e-) E? MetricSho(x10-10C.m^-1)"
for i in `seq 1 $natom`
do
Element=`echo "$atomicnetcharges" | awk '{print $1}' | head -n$i | tail -n1`
number=`expr $natom-$i`
AC2=`echo "$atomicnetcharges" | awk '{print $2}' | head -n$i | tail -n1`
AV2=`echo "$atomicvolumes" | awk '{print $2}'| head -n$i | tail -n1`
AR=`echo "scale=6; e(l($AV2)/3)" | bc -l`
#echo $AR
#sho=`echo "scale=6; $AR/$AC2" | bc`

AR_ang=`echo "scale=6; $AR*0.52918" | bc -l`
AR_m=`echo "scale=20; "$AR_ang"*(10^(-10))" | bc -l`

ES_E=`echo "scale=32; 8990000000*(1.602176634*(10^(-19)))*($AC2*1.602176634*(10^(-19)))/$AR_m/1000*6.022*(10^23)" | bc`
ES_E_lessDP=`echo "scale=4; $ES_E" | bc -l`
#='Energy theory'!$Q$2*('Energy theory'!$O$3*(-H16*'Energy theory'!$O$4))/G16/1000*6.022E+23

metricsho=`echo "scale=32; $AC2*(1.602176634*(10^(-19)))/("$AR_ang"*0.0000000001)*10000000000" | bc -l`

TOTALVOL=`echo "$TOTALVOL + $AV2" | bc`
TOTALRAD=`echo "scale=6; e(l($TOTALVOL)/3)" | bc -l`
TOTALRAD_ang=`echo "scale=6; $TOTALRAD*0.52918" | bc -l`
#TOTALRAD=`echo "$TOTALRAD + $AR" | bc`
TOTALCHARGE=`echo "$TOTALCHARGE + $AC2" | bc`
echo "$ion($Element) $POL $AV2 $AR $AR_ang $AR_m $AC2 "$ES_E_lessDP" $metricsho"
echo "$ion($Element) $POL $AV2 $AR $AR_ang $AR_m $AC2 "$ES_E_lessDP" $metricsho" >> $ion/DDEC6_"$functional"_"$basisset"/sho_data.dat
echo "$ion($Element) $functional $basisset $AR_ang $AC2 $metricsho" >> $ion/DDEC6_"$functional"_"$basisset"/sho_data2.dat
done

TOTAL_AR=`echo "scale=6; e(l($TOTALVOL)/3)" | bc -l`
TOTAL_AR_m=`echo "scale=20; "$TOTALRAD_ang"*(10^(-10))" | bc -l`
TOTAL_ES_E=`echo "scale=32; 8990000000*(1.602176634*(10^(-19)))*($TOTALCHARGE*1.602176634*(10^(-19)))/$TOTAL_AR_m/1000*6.022*(10^23)" | bc`
TOTAL_ES_E_lessDP=`echo "scale=4; $TOTAL_ES_E" | bc -l`

TOTALsho=`echo "scale=32; $TOTALCHARGE*(1.602176634*(10^(-19)))/("$TOTALRAD_ang"*0.0000000001)*10000000000" | bc -l`
echo "$ion""(Total)" $POL $TOTALVOL $TOTAL_AR $TOTALRAD_ang $TOTAL_AR_m $TOTALCHARGE $TOTAL_ES_E_lessDP "$TOTALsho"
echo "$ion""(Total)" $POL $TOTALVOL $TOTAL_AR $TOTALRAD_ang $TOTAL_AR_m $TOTALCHARGE $TOTAL_ES_E_lessDP "$TOTALsho" >> $ion/DDEC6_"$functional"_"$basisset"/sho_data.dat

echo "Total molecule volume = $TOTALVOL; Total molecule radius(A) = $TOTALRAD_ang; Total molecular charge = $TOTALCHARGE; TOTAL SHO = $TOTALsho (Think these Total sho calcs through...)"
echo "Total molecule volume = $TOTALVOL; Total molecule radius(A) = $TOTALRAD_ang; Total molecular charge = $TOTALCHARGE; TOTAL SHO = $TOTALsho (Think these Total sho calcs through...)" >> $ion/DDEC6_"$functional"_"$basisset"/sho_data.dat
