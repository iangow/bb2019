#	./resample_subperiod_diffs.sh
#	chmod +x ./resample_subperiod_diffs.sh
#	./resample_subperiod_diffs.sh > ./resample_subperiod_diffs.cmd
#	chmod +x ./resample_subperiod_diffs.cmd
#	./resample_subperiod_diffs.cmd

#	Country list Australia (AUS), Canada (CAN), PRC, Germany (DEU),
#		France (FRA), UK (GBR), Hong Kong (HKG), Indonesia (IDN), Japan (JPN),
#		South Korea (KOR), Malaysia (MYS), New Zealand (NZL), Philippines (PHL), 
#		Singapore (SGP), Thailand (THA), Taiwan (TWN)

	for country in  AUS CAN CHN DEU FRA GBR HKG IDN JPN KOR MYS NZL PHL SGP THA TWN

do

#		re-sample
		echo "echo \"\$(date) Starting resampling sig test for sub-period diffs, Good less Bad news, for" $country"\""
		echo "gawk -v niter=1000 -v country=\"$country\" -f ./resample_subperiod_APIs_IBES.awk ./Country_Results/$country/API_sub_periods_overlap=YES_censor=NO_$country.txt > ./Country_Results/$country/resample_subperiod_APIs_IBES_output_$country.txt"

	done

exit
