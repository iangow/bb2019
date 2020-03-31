#	./APIs.sh
#	chmod +x ./APIs.sh
#	./APIs.sh > ./APIs.cmd
#	chmod +x ./APIs.cmd
#	./APIs.cmd

#	Country list Australia (AUS), Canada (CAN), PRC, Germany (DEU),
#		France (FRA), UK (GBR), Hong Kong (HKG), Indonesia (IDN), Japan (JPN),
#		South Korea (KOR), Malaysia (MYS), New Zealand (NZL), Philippines (PHL), 
#		Singapore (SGP), Thailand (THA), Taiwan (TWN)

	for country in  AUS CAN CHN DEU FRA GBR HKG IDN JPN KOR MYS NZL PHL SGP THA TWN

do

#		APIs_IBES_20200311.awk
		echo "echo \"\$(date) Starting API estimation for" $country"\""
		echo "gawk -vcountry=\""$country"\" -voverlap=\"YES\" -vcensor=\"NO\" -f ./APIs_IBES.awk ./Country_Data/"$country"/RI_"$country".txt > ./Country_Results/"$country"/APIs_IBES_std_output_"$country".txt"

	done

exit
