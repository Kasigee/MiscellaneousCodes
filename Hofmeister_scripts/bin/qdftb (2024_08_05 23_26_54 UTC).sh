#!/bin/bash

wd=$PWD


echo "process "
for i in `ls -1 *.xyz`
do
 cd $wd
 d=`basename $i .xyz`
 echo -n "$d "
 mkdir "$wd"/$d
 mv $i "$wd"/$d 
 cd "$wd"/$d #; cp $wd/freq/charges.bin .
 xyz-gen.nopbc $i >> /dev/null
 ln -s $d.gen in.gen
 cp "$wd"/dftb_in.hsd . 
 #~/bin/qdftb+ $d 1 00:20:00 
 export OMP_NUM_THREADS=1
 dftb+
 # qdftb+7 $d 1 00:10:00
done

exit 0
