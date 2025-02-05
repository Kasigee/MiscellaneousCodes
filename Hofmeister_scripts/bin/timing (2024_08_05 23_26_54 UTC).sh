#!/bin/bash

functional=$1

echo "ANALYTICAL frequencies:"
#for i in `ls */analytical/*.out`
for i in `ls */analytical/*$functional*cc-pvdz.out`
do
molecule=`echo $i | awk -F'/' '{print $3}'`
CPUtiming=`grep 'Job cpu time:' $i | tail -n1`
#TOTALtiming=`grep 'Elapsed time'  $i | tail -n1`
timing=`grep 'Elapsed time'  $i | tail -n1`
#echo $molecule
#echo "$CPUtiming"
days=`echo $timing | awk '{print $3}'`
days_sec=`echo "$days * 24 * 60 * 60" | bc`
hrs=`echo $timing | awk '{print $5}'`
hrs_sec=`echo "$hrs * 60 * 60" | bc`
min=`echo $timing | awk '{print $7}'`
min_sec=`echo "$min * 60" | bc`
sec=`echo $timing | awk '{print $9}'`
total_sec=`echo "$days_sec + $hrs_sec + $min_sec + $sec" | bc`
#echo "$molecule $TOTALtiming"
echo "$molecule $total_sec"
done

echo""
echo""
echo""

echo "NUMERICAL frequencies:"
#for i in `ls */numerical/*.out`
for i in `ls */numerical/*$functional*cc-pvdz.out`
do
molecule=`echo $i | awk -F'/' '{print $3}'`
CPUtiming=`grep 'Job cpu time:' $i | tail -n1`
#TOTALtiming=`grep 'Elapsed time'  $i | tail -n1`
timing=`grep 'Elapsed time'  $i | tail -n1`
#echo $molecule
#echo "$CPUtiming"
days=`echo $timing | awk '{print $3}'`
days_sec=`echo "$days * 24 * 60 * 60" | bc`
hrs=`echo $timing | awk '{print $5}'`
hrs_sec=`echo "$hrs * 60 * 60" | bc`
min=`echo $timing | awk '{print $7}'`
min_sec=`echo "$min * 60" | bc`
sec=`echo $timing | awk '{print $9}'`
total_sec=`echo "$days_sec + $hrs_sec + $min_sec + $sec" | bc`
#echo "$molecule $TOTALtiming"
echo "$molecule $total_sec"
done

echo "EPHI frequencies:"
for cores in 1 2 4
do
echo "$cores CORES"
for i in `ls -d */$functional/ephi_"$cores"`
#for i in `ls */$functional/ephi_"$cores"`
do
#max_value=0
#echo $i
natoms=`head -n1 "$i"/*.xyz`
njobs=`echo "($natoms * 3) + 1" | bc`
timing=`grep 'Elapsed time' $i/0/0.out`
#echo $timing
days=`echo $timing | awk '{print $3}'`
days_sec=`echo "$days * 24 * 60 * 60" | bc`
hrs=`echo $timing | awk '{print $5}'`
hrs_sec=`echo "$hrs * 60 * 60" | bc`
min=`echo $timing | awk '{print $7}'`
min_sec=`echo "$min * 60" | bc`
sec=`echo $timing | awk '{print $9}'`
total_sec=`echo "$days_sec + $hrs_sec + $min_sec + $sec" | bc`
#echo $total_sec
max_value=$total_sec
for x in `ls $i/*-/*-.out`
do
timing=`grep 'Elapsed time' $x`
#echo $timing
days=`echo $timing | awk '{print $3}'`
days_sec=`echo "$days * 24 * 60 * 60" | bc`
hrs=`echo $timing | awk '{print $5}'`
hrs_sec=`echo "$hrs * 60 * 60" | bc`
min=`echo $timing | awk '{print $7}'`
min_sec=`echo "$min * 60" | bc`
sec=`echo $timing | awk '{print $9}'`
total_sec=`echo "$days_sec + $hrs_sec + $min_sec + $sec" | bc`
#echo $max_value $total_sec
if (( $(echo "$max_value < $total_sec" | bc -l) ))
then
max_value=$total_sec
#echo $total_sec
fi
done
Upperthreshold=`echo "$max_value*$njobs" | bc`
ncore=`echo "$cores*$njobs" | bc`
#echo "Max time for single job: $max_value (ie. Min time if $ncore cores available)
#Number of jobs: $njobs
#Upper threshold total CPU time: $Upperthreshold"
echo $i $max_value $Upperthreshold
done
done
