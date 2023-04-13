#!/bin/bash

module load vmd
wd=$PWD

if [ $# -lt 5 ]
then
        echo $0 radius ion temperature tot_lambdas forwards/backwards plot_only?true/false
        exit 0
fi



radius=$1
ion=$2
temperature=$3
tot_lambdas=$4
forback=$5
plotonly=$6

if [ $plotonly == 'True' ] || [ $plotonly == 'true' ] || [ $plotonly == 'TRUE' ]
then
#       plot_dist_NAMD.py $(ls -v $wd/radius_"$radius"/"$ion"/"$temperature"/0.5/"$tot2""$forback"/gr_*.dat | sort -g -t _ -k 3 )
        exit 0
else
if [ "$tot_lambdas" -ne 20 ]
then
        tot2="$tot_lambdas"/
else
        tot2=''
fi

if grep 'End of program' $wd/radius_$radius/$ion/$temperature/0.5"$tot2"/"$forback"/fep_dir_0.0/fep.log
then
        echo $wd/radius_$radius/$ion/$temperature/0.5"$tot2"/"$forback"/fep_dir_0.0/fep.log exits. CONTINUING.
else
        echo "Doesn't seem like this exists in a finished form: $wd/radius_$radius/$ion/$temperature/0.5"$tot2"/"$forback"/fep_dir_0.0/fep.log"
        exit 0
fi


declare -A ion_data
ion_data=( [Li]=LIT [Na]=SOD [K]=POT [Rb]=RUB [Cs]=CES [F]=FLU [Cl]=CLA [Br]=BRO [I]=IOD [Mg]=MAG [SS]=SFS [LS]=LFS [SE]=SES [LE]=LES [Ca]=CAL )
ion_name=${ion_data[$ion]}
declare -A water_name
water_data=( [Li]=OH2 [Na]=OH2 [K]=OH2 [Rb]=OH2 [Cs]=OH2 [F]='H1 and name H2' [Cl]='H1 and name H2' [Br]='H1 and name H2' [I]='H1 and name H2' [Mg]=OH2 [SS]=OH2 [LS]=OH2 [SE]=OH2 [LE]=OH2 [Ca]=OH2 )
water_name=${water_data[$ion]}
declare -A cutoffs_data
cutoffs_data=( [Li]=2 [Na]=2.5 [K]=3 [Rb]=3.2 [Cs]=3.3 [F]=2 [Cl]=2.5 [Br]=2.8 [I]=3.2 [Mg]=2 [SS]=2.5 [LS]=2.5 [SE]=2.5 [LE]=2.5 [Ca]=2.5 )
cutoff=${cutoffs_data[$ion]}



#seq 0 $(echo "scale=2; 1/20" | bc) 1
#fraction_lambda=`echo "scale=2; 1 / $tot_lambdas" | bc`
echo $fraction_lambda

cd $wd/radius_$radius/$ion/$temperature/0.5"$tot2"/"$forback"/
echo $PWD

#if [ $ion = ['F'|'Cl'|'Br'|'I'] ]
if [[ $ion =~ ^(F|Cl|Br|I)$ ]]
then
# do something if $ion is a halogen element
        cp $wd/namd_dist_template.anions.tcl namd_dist_template.tcl
else
cp $wd/namd_dist_template.tcl .
fi
#for lambda in `seq 0.0 $(echo "scale=2; 1 / $tot_lambdas" | bc) $(echo "scale=2; 1.0 - (1 / $tot_lambdas)" | bc)`
#do
lambda=0.00
        echo $lambda
        lambda=${lambda%0}
        echo $lambda
        sed -i 's/LAMBDA/'$lambda'/g' namd_dist_template.tcl
        sed -i 's/TEMPERATURE/'$temperature'/g' namd_dist_template.tcl
        sed -i 's/RADIUS/'$radius'/g' namd_dist_template.tcl
        sed -i 's/SOD/'$ion_name'/g' namd_dist_template.tcl
        sed -i 's/OH2/'$water_name'/g' namd_dist_template.tcl
        vmd -e namd_dist_template.tcl -dispdev text
        cp $wd/namd_dist_template.tcl .
        #-dispdev text
#done
fi
#plot_dist_NAMD.py $(ls -v $wd/radius_"$radius"/"$ion"/"$temperature"/0.5/"$forback"/gr_*.dat | sort -g -t _ -k 3 )
#grep -E '^[^[:blank:]]+[[:blank:]]+[^[:blank:]]+[[:blank:]]+((3(\.[0-4]*)?)|([0-2](\.[0-9]*)?))$' distances.dat > distances_less3.dat
awk '$3 < '$cutoff'' distances.dat  > distances_less"$cutoff".dat

count=1

#for i in `awk '{print $1}' /scratch/g15/kpg575/NAMD/radius_30/Na/300/0.5/forwards/distances_less3.dat | uniq`
#do
#               
#done
#awk 'NR==1{print; next} $1$2!=p{if (NR!=2) {print p, max} max=0} {max=$3>max?$3:max} {p=$1$2} END{print p, max}' distances_less3.dat > distances_less3_counts.dat
#awk '{if ($1$2 == last) {count++} else {if (last != "") {print last, count} count=1} last=$1$2} END {print last, count}' distances_less3.dat | sort -k1n

awk '
NR == 1 {count = 1; last_col1 = $1; last_col2 = $2}
NR > 1 {
    if ($1 == last_col1 && $2 == last_col2 + 1) {
        count++;
    } else {
        print last_col1, count;
        count = 1;
    }
    last_col1 = $1;
    last_col2 = $2;
}
END {
    print last_col1, count;
}' distances_less"$cutoff".dat > distances_less"$cutoff"_counts.dat

AvgCount=`awk '{ sum += $2 } END { print sum / NR }' distances_less"$cutoff"_counts.dat`

MRT=$(echo "$AvgCount * 20" | bc -l)  #NOTE this is based of 20ps between each frame
echo MRT= "$MRT" ps
echo 'ion temp(K) cutoff(A) MRT(ps)' > MRT.dat
echo $ion $temperature $cutoff $MRT >> MRT.dat


cd $wd
