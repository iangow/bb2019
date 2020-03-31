#	./make_results_directories.sh. if any of the 16 sub-directories for results
#		<./Country_Results/[country]/> do not yet exist, 
#		<./make_results_directories.cmd> will make them
#	chmod +x ./make_results_directories.sh
#	./make_results_directories.sh > ./make_results_directories.cmd
#	chmod +x ./make_results_directories.cmd
#	./make_results_directories.cmd

#	Countries Australia (AUS), Canada (CAN), PRC, Germany (DEU),
#		France (FRA), UK (GBR), Hong Kong (HKG), Indonesia (IDN), Japan (JPN),
#		South Korea (KOR), Malaysia (MYS), New Zealand (NZL), Philippines (PHL), 
#		Singapore (SGP), Thailand (THA), Taiwan (TWN)

echo "mkdir ./Country_Results/"

	for country in  AUS CAN CHN DEU FRA GBR HKG IDN JPN KOR MYS NZL PHL SGP THA TWN

do

		echo "mkdir ./Country_Results/$country/"

	done

exit
