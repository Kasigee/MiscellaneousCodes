awk '{print $4, $6,$7, $8, $1}'  md_opt.xyz | sed "/MD/d" | sed "/   $(head -n1 md_opt.xyz | tr -d '\n' | tr -d '[:blank:]')/d" > velocities_Every_step_wAtoms.dat
#grep -w $(awk '{print $4}' velocities_Every_step_wAtoms.dat) ~/bin/atomic_weights.dat | awk '{print $4}'

#sed -i "s/$(awk '{print $1}' velocities_Every_step_wAtoms.dat)/$(grep -w $(awk '{print $1}' velocities_Every_step_wAtoms.dat) ~/bin/atomic_weights.dat | awk '{print $4}')/g" velocities_Every_step_wAtoms.dat

for element in `awk '{print $5}' velocities_Every_step_wAtoms.dat | sort | uniq`
do
	atomic_weight=`grep -w $element ~/bin/atomic_weights.dat | awk '{print $4}'`
	echo $element $atomic_weight
	sed -i 's/'$element'/'$atomic_weight'/g' velocities_Every_step_wAtoms.dat
done

temperature_analysis
