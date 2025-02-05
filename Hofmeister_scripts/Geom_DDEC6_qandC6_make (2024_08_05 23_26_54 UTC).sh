for solvent in EDC TOL MeNO2 MeCN ACE PC water MeOH DEE 2PrOH FA NMA DMSO HMPT NH3 Py EtOH PrOH hexane DMA NMF
do
	if [ ! $solvent = 'HMPT' ]
	then
		basis=aug-cc-pvtz
	else
		basis=aug-cc-pvdz
	fi
	#geom
	cp $solvent/"$solvent"_mp2_"$basis".xyz DDEC6_geoms_q_C6_Chapter6/.
	#charges
	cp $solvent/DDEC6_mp2_"$basis"/DDEC6_even_tempered_net_atomic_charges.xyz DDEC6_geoms_q_C6_Chapter6/"$solvent"_even_tempered_net_atomic_charges.xyz
	#C6
	cp $solvent/DDEC6_mp2_"$basis"/MCLF/MCLF_unscreened_C6_dispersion_coefficients.xyz DDEC6_geoms_q_C6_Chapter6/"$solvent"_MCLF_unscreened_C6_dispersion_coefficients.xyz
done

cd DDEC6_geoms_q_C6_Chapter6
zip -ru DDEC_geoms_chargesANDcoefficients.zip *.*
cd ..

