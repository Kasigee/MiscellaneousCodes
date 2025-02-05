#!/bin/bash


if [ $# -ne 2 ]
then
 echo "Usage: $0 xyzfile density"
 exit 1
fi

filename=$1
density=$2

Weight=`calculate_MW_xyz.sh $filename | grep "Molar mass of Box" | awk -F'=' '{print $2}'`

echo "Weight of Box = $Weight"
millilitres=`echo "scale=40; $Weight/$density" | bc -l`  #mL (g/(g/mL)
Vol=`echo "scale=40; $millilitres*(10^24) " | bc -l` #Ang^3
echo "$Vol"
Box_width=`echo "scale=5; e(l($Vol)/3)" | bc -l` #Ang
Box_width2=`echo "$Box_width - 2" | bc`
centre=`echo "$Box_width/2" | bc`
countfrom=`echo "$nsteps - 400" | bc`
echo "$Box_width Angstrom"
