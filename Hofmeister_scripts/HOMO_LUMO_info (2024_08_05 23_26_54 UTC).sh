functional=$1
basisset=$2

for file in `ls */*_"$functional"_"$basisset".out`
do
	if grep -q 'Normal termination' $file
	then
	ion=`echo $file | awk -F/ '{print $2}' | awk -F_ '{print $1}'`
	linenumberOfFirstOpt=`grep -n 'Normal termination' $file | head -n1 | awk -F: '{print $1}'`
	HOMO=`head -n"$linenumberOfFirstOpt" $file | grep 'Alpha  occ. eigenvalues'  | tail -n1 | awk '{print $NF}'`
	LUMO=`head -n"$linenumberOfFirstOpt" $file | grep 'Alpha virt. eigenvalues'  | head -n1 | awk '{print $5}'`
	echo $ion $functional $basisset $HOMO $LUMO 
fi
done
