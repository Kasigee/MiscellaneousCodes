#!/bin/bash


if [ $# -ne 1 ]
then
 echo "Usage: $0 xyzfile"
 exit 1
fi

filename=$1

natoms=`head -n1 $filename  | tr '\r' ' ' |  tr -d '[:blank:]'`
echo $natoms
SUM=0

for i in `tail -n"$natoms" $filename | awk '{print $1}'`
do
        atomicMW=`grep -r "\b$i\b" ~/bin/atomic_weights.dat | awk '{print $4}'`
        SUM=`echo "scale=30; $SUM + $atomicMW" | bc -l`
done

echo "Molar mass of Box = $SUM" #g/mol
Weight=`echo "scale=40; $SUM/(6.02214076*10^23) " | bc -l`  #g ((g/mol)/("molecules"/mol))
echo "Weight of Box = $Weight"
