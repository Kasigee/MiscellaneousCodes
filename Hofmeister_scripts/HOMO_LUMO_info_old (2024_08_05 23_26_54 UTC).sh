ion=$1
functional=$2
basisset=$3

file="$ion"/"$ion"_"$functional"_"$basisset".out
linenumberOfFirstOpt=`grep -n 'Normal termination' $file | head -n1 | awk -F: '{print $1}'`
HOMO=`head -n"$linenumberOfFirstOpt" $file | grep 'Alpha  occ. eigenvalues'  | tail -n1 | awk '{print $NF}'`
LUMO=`head -n"$linenumberOfFirstOpt" $file | grep 'Alpha virt. eigenvalues'  | head -n1 | awk '{print $5}'`
echo $ion $functional $basisset $HOMO $LUMO 
