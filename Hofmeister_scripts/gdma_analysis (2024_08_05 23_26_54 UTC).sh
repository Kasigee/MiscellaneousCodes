
if [ $# -ne 3 ]
then
   echo "Usage: $0 ion functional basisset"
   exit 1
fi

wd=$PWD

ion=$1
functional=$2
basisset=$3



cd $ion

if grep 'Job abandoned' GDMA_"$functional"_"$basisset"/out
then
	rm GDMA_"$functional"_"$basisset"/out
fi


if [ -f DDEC6_"$functional"_"$basisset"/"$ion"_"$functional"_"$basisset"_DDEC6.chk ] && [ ! -f GDMA_"$functional"_"$basisset"/out ]
then
	mkdir GDMA_"$functional"_"$basisset"
	cd GDMA_"$functional"_"$basisset"
	cp ../DDEC6_"$functional"_"$basisset"/"$ion"_"$functional"_"$basisset"_DDEC6.chk .
	formchk "$ion"_"$functional"_"$basisset"_DDEC6.chk
	mv "$ion"_"$functional"_"$basisset"_DDEC6.fchk $ion.fchk
 cat <<END > data
Title "$ion $functional  $basisset  Gaussian16  optimized"
File $ion.fchk

Angstrom
Multipoles
  switch 4
  Limit 4
END
if grep H ../$ion.xyz
then
	echo "  Limit 1 H" >> data
	echo "  Radius H 0.325" >> data
fi
cat <<END >> data

  Punch $ion.punch
Start

Finish
END
	cd ..
	gdma_run.py GDMA_"$functional"_"$basisset"
#	qaimall "$ion"_"$functional"_"$basisset"_DDEC6.wfx 1 1gb 72:00:00
elif [ -f GDMA_"$functional"_"$basisset"/out ]
then
	echo "GDMA_"$functional"_"$basisset" complete"
	cd GDMA_"$functional"_"$basisset"
	#awk '/0.002 IsoDensity Surface/ {p=1} p {print} p && /Total/ {exit}' "$ion"_"$functional"_"$basisset"_DDEC6.sum > tmpanalysis.dat
	#Total=`grep Total tmpanalysis.dat | awk '{print $2}'`
	#Total_num=`sed -E 's/([+-]?[0-9.]+)[eE]\+?(-?)([0-9]+)/(\1*10^\2\3)/g' <<<"$Total"`
	#head -n -2 tmpanalysis.dat | tail -n +5 | awk '{print $1}' > atomlist.dat
	#areas=`head -n -2 tmpanalysis.dat | tail -n +5 | awk '{print $2}'`
	#count=0
	#for i in $areas
	#do
	#	count=`expr $count + 1`
	#	i_num=`sed -E 's/([+-]?[0-9.]+)[eE]\+?(-?)([0-9]+)/(\1*10^\2\3)/g' <<<"$i"`
	#	percentSA=`echo "scale=4; "$i_num" / "$Total_num" *100" | bc -l`
	#	atom=`head -n $count atomlist.dat | tail -n1`
	#	echo $ion $atom $percentSA"%"
	#done
	#echo "$ion Total Surface Area = $Total_num"
fi



