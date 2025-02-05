#!/bin/bash

ion=$1

#sort
sort e_density_"$ion".dat >  e_density_"$ion"_sorted.dat 
#dyunno?
awk '{arr[$1]+=$3} END {for (i in arr) {print i,arr[i]}}' e_density_"$ion"_sorted.dat > e_density_"$ion"_sorted.dat.tmp
#sort again
sort e_density_"$ion"_sorted.dat.tmp > e_density_"$ion"_sorted.dat.tmp.dat
#cumulative sum?
awk '{total += $2; $2 = total}1' e_density_"$ion"_sorted.dat.tmp.dat > e_density_"$ion"_sorted_sum.dat
#gradient
awk 'BEGIN{OFS="\t"}NR==1{print $1,$2,0}NR>2{print a,b,($2-b)/($1-a)}{a=$1;b=$2}' e_density_"$ion"_sorted_sum.dat > e_density_"$ion"_sorted_grad.dat

simple_moving_average.py e_density_"$ion"_sorted_grad.dat
