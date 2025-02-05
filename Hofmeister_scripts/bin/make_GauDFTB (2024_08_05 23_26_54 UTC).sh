#!/bin/bash


xyz-com $1.xyz
cp $1.com $1.com.orig
awk '{print $1, $2, $3, $4}' $1.com.orig > $1.com
rm $1.com.orig

line1=`grep '%k' $1.com | head -n1`
line2=`grep '#p' $1.com | head -n1 | awk -F'#' '{print $2}'`

sed -i "s/$line1/%nproc=16 \n%mem=4gb/g" $1.com
sed -i "s/$line2/opt external='\/usr\/local\/bin\/GauDFTB3-D'/g" $1.com

#cat << END > $1.job
#!/bin/bash
#PBS -N $1
#PBS -l select=1:ncpus=16:mem=4gb
#PBS -l walltime=24:00:00
#PBS -k eo


#g09 < $1.com > opt.out
#END

## Now submit it.
#qsub $1.job
#rm -f $1.job
#exit 0
