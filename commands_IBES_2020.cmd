#	./commands_IBES_2020.cmd For BB2019's 16 IBES countries, this command file when executed will generate F3, T3, T4, T5, and T6.

#	to execute this command file, type the following command: "nohup ./commands_IBES_2020.cmd > ./commands_messages.txt &" (and press return); any progress reports 
#		will appear in the messages file <./commands_messages.txt>. Use nohup to ensure this command file will continue to run while you "do other things".
#		The "&" (appended at the end of the command) instructs the O/S to run <./commands_IBES_2020.cmd> in the background.
#nohup ./commands_IBES_2020.cmd > ./commands_messages.txt &

########	<./commands_IBES_2020.cmd> commences to execute here. It will look for various program files in the current directory and for data files in <./Country_Data/[country]/>

#	if any of the 16 sub-directories for results <./Country_Results/[country]/> do not yet exist, <./make_results_directories.cmd> will make them. Messages will have flagged
#		any pre-existing sub-directories for results
chmod +x ./make_results_directories.sh
./make_results_directories.sh > ./make_results_directories.cmd
chmod +x ./make_results_directories.cmd
./make_results_directories.cmd

#	APIs
#	-- .sh + .cmd files to run API awk code for each country. A number of output files are generated in order to plot APIs and to construct T3, T4, T5, and T6. They will mostly
#		appear in the sub-directories for results <./Country_Results/[country]/>
chmod +x ./APIs.sh
./APIs.sh > ./APIs.cmd
chmod +x ./APIs.cmd
echo "$(date) Starting API estimation"
./APIs.cmd

#	-- plot APIs as in F3
#		-- input data files: chmod supplied file <./API_plot_input_data.sh>, run .sh file to create the .cmd file, then chmod and run the .cmd file
chmod +x ./API_plot_input_data.sh
./API_plot_input_data.sh > ./API_plot_input_data.cmd
chmod +x ./API_plot_input_data.cmd
echo "$(date) Starting API plots"
./API_plot_input_data.cmd
#		-- shell + .cmd file to plot APIs using R. If R is not installed on the Linux box being used, then dusable the R command and plot the data (time-series of
#			APIs) using an alternative approach. Read ./API_R_Plots_IBES.cmd to see what's involved.
chmod +x ./API_R_Plots_IBES.sh
./API_R_Plots_IBES.sh > ./API_R_Plots_IBES.cmd
chmod +x ./API_R_Plots_IBES.cmd
R --no-restore --no-save < ./API_R_Plots_IBES.cmd > /dev/null
#		-- zip archive of API plots (16 IBES countries)
echo "$(date) Creating zip archive of API plots"
zip -j API_R_Plots_IBES.zip ./Country_Results/*/F3_API_plot_base_case_*.pdf
#		-- cleanup Results directories by deleting the pdfs for F3
rm ./Country_Results/*/F3_API_plot_base_case_*.pdf

#	-- T3
echo "$(date) Starting T3"
#		-- this code reproduces T3
gawk 'BEGIN{FS=",";first_day=(mktime("1970 01 01 08 00 00")/86400);last_day=(mktime("2019 12 31 08 00 00")/86400);for(nd=first_day;nd<=last_day;nd++){split(strftime("%u %A %B %Y%m%d",(nd*86400)),bits," ");date_of_day[nd]=bits[4]};FS=OFS="\t"};{this_country=substr(FILENAME,length(FILENAME)-6,3);print this_country,$1,$3,$6,date_of_day[$6],$7,date_of_day[$7]}' ./Country_Results/*/API_sub_periods_overlap=YES_censor=NO_*.txt | sort -u | gawk 'BEGIN{FS=OFS="\t"};{country=$1;country_seen[country]=1;count[country "\t" $3]++};END{ncs=asorti(country_seen);printf("Fyr");for(nc=1;nc<=ncs;nc++){printf("\t%s",country_seen[nc])};printf("\n");for(fyr=1989;fyr<=2017;fyr++){printf("%s",fyr);for(nc=1;nc<=ncs;nc++){printf("\t%s",count[country_seen[nc] "\t" fyr])};printf("\n")}}' > T3.txt
#		-- this code excludes cases where the eps change was zero, so the signal is NA. Enable it to reconcile the country totals in T3 with those in T5
#gawk 'BEGIN{FS=",";first_day=(mktime("1970 01 01 08 00 00")/86400);last_day=(mktime("2019 12 31 08 00 00")/86400);for(nd=first_day;nd<=last_day;nd++){split(strftime("%u %A %B %Y%m%d",(nd*86400)),bits," ");date_of_day[nd]=bits[4]};FS=OFS="\t"};{this_country=substr(FILENAME,length(FILENAME)-6,3);if(($16=="G")||($16=="B")){print this_country,$1,$3,$6,date_of_day[$6],$7,date_of_day[$7]}}' ./Country_Results/*/API_sub_periods_overlap=YES_censor=NO_*.txt | sort -u | gawk 'BEGIN{FS=OFS="\t"};{country=$1;country_seen[country]=1;count[country "\t" $3]++};END{ncs=asorti(country_seen);printf("Fyr");for(nc=1;nc<=ncs;nc++){printf("\t%s",country_seen[nc])};printf("\n");for(fyr=1989;fyr<=2017;fyr++){printf("%s",fyr);for(nc=1;nc<=ncs;nc++){printf("\t%s",count[country_seen[nc] "\t" fyr])};printf("\n")}}' > T3_excl_NA.txt

#	-- T4
echo "$(date) Starting T4"
#		-- IBES 16 countries: consolidated tdg calendar for dates 19790101 and later; outfile $1 is the calendar date, $2-$17 are the next tdg date for the 16 countries.
gawk 'BEGIN{FS=OFS="\t"};{if($1=="Calndr_date"){next};if($1<19790101){next};country=substr(FILENAME,length(FILENAME)-6,3);country_seen[country]=1;if((day_num($3)-day_num($1))<=30){bumped_date[country "\t" $1]=$3;date_seen[$1]=1}};END{ncs=asorti(country_seen);ndates=asorti(date_seen);printf("Date");for(nc=1;nc<=ncs;nc++){printf("\t%s",country_seen[nc])};printf("\n");for(nd=1;nd<=ndates;nd++){printf("%s",date_seen[nd]);for(nc=1;nc<=ncs;nc++){lookfor=(country_seen[nc] "\t" date_seen[nd]);this_date="";if(lookfor in bumped_date){this_date=bumped_date[lookfor]};printf("\t%s",this_date)};printf("\n")}};function day_num(this_date){dummy=(substr(this_date,1,4) " " substr(this_date,5,2) " " substr(this_date,7,2) " 08 00 00");return (mktime(dummy)/86400)}' ./Country_Data/*/tdg_calndr_*.txt > ./tdg_calndr_16_IBES_countries.txt
#		-- code to generate T4: confine medians to base case (EPS-pr_fyr) and 0<lag<181 days; earnings signal not tested for "NA", which is not done in T3 either (see above)
gawk 'BEGIN{FS=OFS="\t";infile="./tdg_calndr_16_IBES_countries.txt";while((a=getline<infile)>0){if($1=="Date"){for(nf=2;nf<=NF;nf++){countries[nf-1]=$(nf)};ncs=NF-1};if(!($1=="Date")){for(nf=2;nf<=NF;nf++){country=countries[nf-1];bumped_date[country "\t" $1]=$(nf)}}};close(infile)};{if($1=="country"){next};fyr=substr($3,1,4);if((fyr<1989)||(fyr>2017)){next};if(!(($5=="EPS")&&($6=="pr_fyr"))){next};country=$1;country_seen[country]=1;lag=day_num(bumped_date[country "\t" $4])-day_num($3);if((lag<1)||(lag>180)){next};fyr_seen[fyr]=1;count[country "\t" fyr]++;guff[country "\t" fyr "\t" count[country "\t" fyr]]=lag};END{ncs=asorti(country_seen);printf("Fyr");for(nc=1;nc<=ncs;nc++){printf("\t%s",country_seen[nc])};printf("\n");nyrs=asorti(fyr_seen);for(nyr=1;nyr<=nyrs;nyr++){fyr=fyr_seen[nyr];printf("%s",fyr);for(nc=1;nc<=ncs;nc++){country=country_seen[nc];delete zzzz;nlags=count[country "\t" fyr];if(nlags>0){for(nlag=1;nlag<=nlags;nlag++){zzzz[nlag]=guff[country "\t" fyr "\t" nlag]+1000};ncases=asort(zzzz);printf("\t%.0f",median(ncases,zzzz)-1000)};if(nlags<1){printf("\t")}};printf("\n")}};function day_num(this_date){dummy=(substr(this_date,1,4) " " substr(this_date,5,2) " " substr(this_date,7,2) " 08 00 00");return (mktime(dummy)/86400)};function median(ncases,zzzzzz){nvalues=ncases;median_zzzzzz=((nvalues%2==0)?((zzzzzz[int(nvalues/2)]+zzzzzz[int(nvalues/2)+1])/2):zzzzzz[int(nvalues/2)+1]);return(median_zzzzzz)}' ./Country_Data/*/code_IBES_eps_signals_output_20181020_*.txt > T4.txt

#	-- T5 resampling tests
echo "$(date) Starting T5 resampling tests"
./resample_subperiod_diffs.sh > ./resample_subperiod_diffs.cmd
chmod +x ./resample_subperiod_diffs.cmd
./resample_subperiod_diffs.cmd
#		-- tabulation for T5 resampling results, columns (1) - (9). NB these results match those in BB2019 T5 columns (1) - (9), except that the resampling tests for the event and
#			post-event sub-periods can differ in the 3rd decimal because BB2019's data analysis did not use a fixed seed for the computer system's random number generator.
#			Also note that the resampling results in the last row (ie, for USA) are generated by a separate command in the USA command file.
gawk 'BEGIN{FS=OFS="\t";print "Country\tFyr\tN(Good)\tN(Bad)\tPre-event\tRel. freq.\tEvent\tRel. freq.\tPost-event\tRel. freq.";printf("(1)\t");for(nc=2;nc<=9;nc++){printf("\t(%s)",nc)};printf("\n")};{if(($0==Fyr)||!(substr($3,length($3)-10,11)=="cum_ror_adj")){next};country=substr(FILENAME,length(FILENAME)-6,3);country_fyr_seen[country "\t" $1]=1;split($3,bits,"_");NG[country "\t" $1]=$5;NB[country "\t" $1]=$7;G_less_B[country "\t" $1 "\t" bits[1]]=($4-$6);sampling_freq[country "\t" $1 "\t" bits[1]]=($8/($8+$9+$10))};END{n=asorti(country_fyr_seen);for(ii=1;ii<=n;ii++){i=country=country_fyr_seen[ii];printf("%s\t%s\t%s\t%.4f\t%.3f\t%.4f\t%.3f\t%.4f\t%.3f\n",i,NG[i],NB[i],G_less_B[i "\tpre"],sampling_freq[i "\tpre"],G_less_B[i "\tevent"],sampling_freq[i "\tevent"],G_less_B[i "\tpost"],sampling_freq[i "\tpost"])}}' ./Country_Results/*/resample_subperiod_APIs_IBES_output_*.txt | sed s/1.000/1/g | cut -f1,3- > T5_columns_1_to_9.txt
#		-- see below T6 tabulation for T5 time-series regressions, in columns (10)-(13) of T5. T5 time-series regressions require AI/NI data generated by T6.awk

#	-- T6
echo "$(date) Starting T6"
#		-- T6 AI and NI are complicated. AI is wgtd avge investment performance of G and B news portfolios (less the within-sample avge of inv perf of G/B news portfolios),
#			where nG and nB are implicitly the wgts
#			-- build, for each country and the base case, the within-sample avge roradj by fyr and write to a single file
#				<avge_by_fyr_roradj_overlap=YES_censor=NO_all_countries.txt>
gawk 'BEGIN{FS=OFS="\t"};{if(!($13=="eps")||!($14=="pr_fyr_prev")||!($15=="sign")||!(($16=="G")||($16=="B"))){next};country=substr(FILENAME,length(FILENAME)-6,3);country_seen[country]=1;cnt[country "\t" $3]++;cnt[country "\tAllYrs"]++;roradj=$36+$38;mktroradj[country "\t" $3]+=roradj;mktroradj[country "\tAllYrs"]+=roradj};END{ncountries=asorti(country_seen);printf("Fyr");for(nc=1;nc<=ncountries;nc++){printf("\t%s_N\t%s_avgeroradj",country_seen[nc],country_seen[nc])};printf("\n");for(nyr=1989;nyr<=2018;nyr++){fyr=nyr;if(fyr==2018){fyr="AllYrs"};printf("%s",fyr);for(nc=1;nc<=ncountries;nc++){ratio="";country=country_seen[nc];if(cnt[country "\t" fyr]>0){ratio=mktroradj[country "\t" fyr]/cnt[country "\t" fyr]};printf("\t%s\t%s",cnt[country "\t" fyr],ratio)};printf("\n")}}' ./Country_Results/*/API_sub_periods_overlap=YES_censor=NO_*.txt > ./avge_by_fyr_roradj_overlap=YES_censor=NO_all_countries.txt
#			-- run T6.awk. It reads, for each country, the within-sample avge roradj by fyr in BEGIN and subtracts the within-sample avge roradj in MAIN;
#				stdout is cut to match T6
gawk -f T6.awk ./Country_Results/*/API_sub_periods_overlap=YES_censor=NO_*.txt | cut -f1,7,14,21,28,35,42,49,56,63,70,77,84,91,98,105,112 | sed 's/\///g' | sed 's/_AINI//g' | grep -v '^All' > T6.txt

#	-- T5 time-series regressions, which are contained in columns (10)-(13) of T5; input data are generated by T6.awk
echo "$(date) Starting T5 time-series regressions"
#		-- build regression input file (columns 8, 15, ... of this file contain the AI/NI ratio to greater precision than the values shown in T6)
gawk -f T6.awk ./Country_Results/*/API_sub_periods_overlap=YES_censor=NO_*.txt | cut -f1,8,15,22,29,36,43,50,57,64,71,78,85,92,99,106,113 | sed 's/\///g' | sed 's/_AINI//g' | sed 's/_T5//g' | grep -v '^All' > T5_time_series_regn_input.txt
#		-- estimate regressions; constant term has been affected by rounding for some countries -- for details see annotations to T5 in <Ball+Brown[PBFJ,2019]_annotated.pdf>.
gawk 'BEGIN{FS=OFS="\t"};{if(NR==1){for(nf=2;nf<=NF;nf++){country[nf-1]=$(nf)};next};fyrs[NR-1]=$1-2000;for(nf=2;nf<=NF;nf++){ratio[NR-1 "\t" nf-1]=$(nf)}};END{for(nc=1;nc<=16;nc++){this_country=country[nc];delete x;delete y;n=0;for(nyr=1;nyr<=29;nyr++){this_ratio=ratio[nyr "\t" nc];if(!(this_ratio=="")){n++;x[n]=fyrs[nyr];y[n]=this_ratio}};stats=regn_correln(x,y,n);print this_country,stats,n}};function regn_correln(xxxx,yyyy,ncases){number_of_cases=ncases;alpha=beta=correlation="NA";if(ncases>1){sumx=sumy=sumxy=sumxx=sumyy=volatility_x=volatility_y=0};for(i9=1;i9<=number_of_cases;i9++){sumx+=xxxx[i9];sumy+=yyyy[i9];sumxy+=xxxx[i9]*yyyy[i9];sumxx+=xxxx[i9]*xxxx[i9];sumyy+=yyyy[i9]*yyyy[i9]};covarxy=(sumxy-(sumx*sumy)/number_of_cases)/(number_of_cases-1);varx=(sumxx-(sumx*sumx)/number_of_cases)/(number_of_cases-1);vary=(sumyy-(sumy*sumy)/number_of_cases)/(number_of_cases-1);if(varx>0){volatility_x=sqrt(varx)};beta=covarxy/varx;if(vary>0){correlation=covarxy/(sqrt(varx*vary));volatility_y=sqrt(vary)};ybar=sumy/number_of_cases;xbar=sumx/number_of_cases;alpha=ybar-beta*xbar;alpha=sprintf("%.1f",alpha);beta=sprintf("%.3f",beta);correlation=sprintf("%.3f",correlation);return(alpha"\t"beta"\t"correlation)}' T5_time_series_regn_input.txt > T5_columns_10_to_13.txt

echo "$(date) Completed F3 + T3, T4, T5 for IBES countries, and T6"

#	archive: <./my_reproduce_IBES_results_in_BB2019.tar> to include this command file, all shell files, all awk files, all data files, and all  results files
echo "$(date) Building tar archive <my_reproduce_IBES_results_in_BB2019.tar> which includes all needed input files + the results"
touch ./my_reproduce_IBES_results_in_BB2019.tar
rm ./my_reproduce_IBES_results_in_BB2019.tar
tar -zcvf ./my_reproduce_IBES_results_in_BB2019.tar commands_IBES_2020.cmd *.sh *.awk T3.txt T4.txt T5*.txt T6*.txt avge*txt tdg*txt ./Country_Data/*/* ./Country_Results/*/*
