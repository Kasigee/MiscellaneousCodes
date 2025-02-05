echo SOLVENT ANALYSIS
for solvent in EDC TOL MeNO2 MeCN ACE PC water MeOH DEE 2PrOH FA NMA DMSO HMPT NH3 Py EtOH PrOH hexane glycerol nipam NMF
do
        for cation in Li Na NH4 guanidinium NCH3_4 NC2H5_4 Be Mg Ca Al
        do
        ./calculate_UE.sh $cation $solvent mp2 aug-cc-pvdz
	done
        for anion in F Cl Br SCN NO3 acetate BH4 BCH3_4 BC2H5_4 SO4 CO3 HPO4 S2O3 PO4 citrate
        do
        ./calculate_UE.sh $solvent $anion mp2 aug-cc-pvdz
	done
        for inert in He Ne Ar Kr CH4 CCH3_4 CC2H5_4 CC3H7_4 CC4H9_4
        do
        ./calculate_UE.sh $solvent $inert mp2 aug-cc-pvdz
	done
./calculate_UE.sh $solvent $solvent mp2 aug-cc-pvdz        
done

exit 0

echo Counterion ANALYSIS
for cation in Li Na NH4 guanidinium NCH3_4 N2CH5_4 Be Mg Ca Al
        do
        for anion in F Cl Br SCN NO3 acetate BH4 BCH3_4 B2CH5_4 SO4 CO3 HPO4 S2O3 PO4 citrate
        do
        ./calculate_UE.sh $cation $anion mp2 aug-cc-pvdz
	done
        for inert in He Ne Ar Kr CH4 CCH3_4 CC2H5_4 CC3H7_4 CC4H9_4
        do
         ./calculate_UE.sh $cation $inert mp2 aug-cc-pvdz
	done
done

