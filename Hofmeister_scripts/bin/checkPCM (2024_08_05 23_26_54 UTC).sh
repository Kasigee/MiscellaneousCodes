for i in `ls *eda*out`
 do
 echo $i
 grep '$pcmcav' $i
 grep '$tescav' $i
 grep "ELECTROSTATIC FREE ENERGY" $i | tail -n1 | awk '{print $4,$6}'
 grep "EXCHANGE FREE ENERGY" $i | tail -n1 | awk '{print $4,$6}'
 grep "REPULSION FREE ENERGY" $i | tail -n1 | awk '{print $4,$6}'
 grep "POLARIZATION FREE ENERGY" $i | tail -n1 | awk '{print $4,$6}'
 grep "DESOLVATION FREE ENERGY" $i | tail -n1 | awk '{print $4,$6}'
 grep "DISPERSION ENERGY" $i | tail -n1 | awk '{print $4,$6}'
 grep "TOTAL INTERACTION ENERGY" $i | tail -n2 | head -n1 | awk '{print $5,$7}'
done
