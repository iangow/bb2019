#	T6.awk: tabulate the AI/NI ratio by fyr and country; ie, reproduce BB2019 Table 6.
#		Also, generate input data for T5 time-series regression

#	gawk -f T6.awk ./Country_Results/*/API_sub_periods_overlap=YES_censor=NO_*.txt
#	 | cut ... (see commands_IBES_2020.cmd)

BEGIN{
	FS = OFS = "\t"
#	first year tabulated in T6, by country
	yr1["AUS"] = yr1["CAN"] = yr1["DEU"] = yr1["FRA"] = yr1["GBR"] = yr1["HKG"] = yr1["JPN"] = \
		yr1["MYS"] = yr1["SGP"] = 1989
	yr1["CHN"] = 1995;yr1["IDN"] = 1992;yr1["KOR"] = yr1["NZL"] = yr1["PHL"] = yr1["THA"] = 1990
	yr1["TWN"] = 1992
#	average is needed to correct for the bias in avge adj cumror
#	it's calculated in the command file before invoking gawk -f T6.awk ...
	infile = "./avge_by_fyr_roradj_overlap=YES_censor=NO_all_countries.txt"
	while((a=getline<infile)>0){
		if($1=="Fyr"){
			for(nf=3;nf<=NF;nf+=2){
				country = substr($(nf),1,3)
				country_seen[nf] = country
				countries[country] = 1
			}
		}
		if(!($1=="Fyr")){
			for(nf=3;nf<=NF;nf+=2){
				country = country_seen[nf]
				sample_avge_roradj[country "\t" $1] = $(nf)
			}
		}
	}
}

{
#	we only want data for the base case
	if(!($13=="eps")||!($14=="pr_fyr_prev")||!($15=="sign")||!(($16=="G")||($16=="B"))){next}
#	capture country from the input FILENAME
	country = substr(FILENAME,length(FILENAME)-6,3)
#	store various stuff by country-fyr
	cnt[country "\t" $3 "\t" $16]++
	cnt[country "\tAllYrs\t" $16]++
	airoradj = absroradj = roradj = ($36+$38) - sample_avge_roradj[country "\t" $3]
	if(absroradj<0){absroradj = -absroradj}
	if($16=="B"){airoradj = -airoradj}
	n[country "\t" $3]++
	n[country "\tAllYrs"]++
	ai[country "\t" $3]+= airoradj
	ai[country "\tAllYrs"]+= airoradj
	ni[country "\t" $3]+= absroradj
	ni[country "\tAllYrs"]+= absroradj
}

END{
#	sort country names
	ncountries = asorti(countries)
#	hdr for T6
	printf("Fyr")
	for(nc=1;nc<=ncountries;nc++){
		country = countries[nc]
		printf("\t%s_N(G)\t%s_N(B)\t%s_N\t%s_AI\t%s_NI\t%s_T6_AI/NI\t%s_T5_AI/NI", \
			country,country,country,country,country,country,country)
	}
	printf("\n")
#	fyr-by-fyr rows of averages; info for T6 is in 2nd last col for each country, and for T5
#		time-series regression it's in the last columnwhich can be condensed using cut command
#	eg (stdout) | cut -f1,7,14,21,28,35,42,49,56,63,70,77,84,91,98,105,112 (T6, for N=16 countries)
#	eg (stdout) | cut -f1,8,15,22,29,36,43,50,57,64,71,78,85,92,99,106,113 (T5, for N=16 countries)
	for(nyr=1989;nyr<=2018;nyr++){
		fyr = nyr
		if(fyr==2018){fyr="AllYrs"}
		printf("%s",fyr)
		for(nc=1;nc<=ncountries;nc++){
			country = countries[nc]
			AI = NI = ratio = ratio_for_T5 = ""
			if((fyr>=yr1[country]) && (ni[country "\t" fyr]>0)){
				AI = 100 * ai[country "\t" fyr]/n[country "\t" fyr]
				NI = 100 * ni[country "\t" fyr]/n[country "\t" fyr]
				ratio = int((100*(AI/NI))+0.5)
				ratio_for_T5 = 100*(AI/NI)
			}	
			printf("\t%s\t%s\t%s\t%s\t%s\t%s\t%s",cnt[country "\t" fyr "\tG"],cnt[country "\t" fyr "\tB"], \
				n[country "\t" fyr],AI,NI,ratio,ratio_for_T5)
		}
		printf("\n")
	}
}
