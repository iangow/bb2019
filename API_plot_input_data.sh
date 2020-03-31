#	./API_plot_input_data.sh
#	chmod +x ./API_plot_input_data.sh
#	./API_plot_input_data.sh > ./API_plot_input_data.cmd
#	chmod +x ./API_plot_input_data.cmd
#	./API_plot_input_data.cmd

#	Country list Australia (AUS), Canada (CAN), PRC, Germany (DEU),
#		France (FRA), UK (GBR), Hong Kong (HKG), Indonesia (IDN), Japan (JPN),
#		South Korea (KOR), Malaysia (MYS), New Zealand (NZL), Philippines (PHL), 
#		Singapore (SGP), Thailand (THA), Taiwan (TWN)

	for country in  AUS CAN CHN DEU FRA GBR HKG IDN JPN KOR MYS NZL PHL SGP THA TWN

do

		echo "echo \"\$(date) Starting to generate API plot input data for" $country"\""
		echo "sort -k1,6 -k7g ./Country_Results/$country/APIs_IBES_std_output_$country.txt | gawk 'BEGIN{FS=OFS=\"\t\";print \"Day\tAPI_Good_News\tCount_Good_News\tAPI_Bad_News\tCount_Bad_News\"};{if(!(\$2==\"eps\")||!(\$3==\"pr_fyr_prev\")||!(\$4==\"sign\")||(\$5==\"NA\")||!(\$6==\"adjror\")){next};count[\$1 \"\t\" \$5]=\$9;sum_apis_all_fyrs[\$5 \"\t\" \$7]+=\$8};END{count_all_G=count_all_B=0;for(fyr=1989;fyr<=2017;fyr++){count_all_G+=count[fyr \"\tG\"];count_all_B+=count[fyr \"\tB\"]};for(nd=1;nd<=540;nd++){print nd-360,sum_apis_all_fyrs[\"G\t\" nd]/count_all_G,count_all_G,sum_apis_all_fyrs[\"B\t\" nd]/count_all_B,count_all_B}}' > ./Country_Results/$country/APIs_IBES_to_plot_$country.txt"

	done

exit
