#	./APIs_IBES.awk

#	gawk -vcountry="AUS" -voverlap="YES" -vcensor="NO" -f ./APIs_IBES.awk 
#		./Country_Data/AUS/RI_AUS.txt > ./Country_Results/AUS/APIs_IBES_output_AUS.txt

#	program structure:
#		BEGIN read mkt index + eps codings;
#		MAIN read stock returns, process
#		PROCESS loop 1 is by announcement for this stock (N is variable); loop2 is by RI_ewmkt, 
#			RI_nomkt, (log)ror_ewmkt and ror_nomkt (N=4); loop3 is by eps signal (N=18). Write
#			the sub-period stats for each coy-FYR to the file for sub-period results,
#			<APIs_sub_periods_AUS_(date-time).txt> (see below for the layout of records in 
#			this file; each record has 290 columns, so it should be written after the day-by-day
#			results are calculated). loop3 has 18=(EPS/GPS/CPS)x(pfyr/pDec)x(sign/median/Q1Q4).
#			Then there are 4 investment performance criteria x Good/Bad news x 3 sub-periods.
#		END process last stock; calculate all averages and write them to the 4 output files

#	overlap="NO" sets stock and market RIs (cumprels) =1 so that investment performance is measured no
#		earlier than the day after last FYR's bumped announcement date (where last FYR is in the sample).
#		overlap="YES" retains the original model, ie it does not check for any overlap. Note that any PEAD
#		last FYR is ignored still.

#	options: N(options) = 64 [= 18 x 4, where 4 = 2 mkt-adj/not mkt-adj x 2 performance measures (RI/log ror)]
#	mkt adj: see below.
#	we also have max 48 fyrs = 47 for 1971-2017, + All Yrs
#	handle output by writing it to 4 separate files: RI_ewmkt, RI_nomkt, ror_ewmkt, ror_nomkt
#	output comprises, a hdr record followed by 541 days [-360: +180] followed by the 3 sub-periods, 
#		for each of the 18 eps signals, the avge portfolio return for each year + AllYrs (where
#		AllYrs is the unwgtd avge of each yr). The sub-period performance measure for each coy-FYR 
#		is written to a separate file, the fields being Coy-Id, FYR, the portfolio formation rule 
#		combined with the performance measure combined with the sub-period. This separate file 
#		contains 2 + (18 x 4 x 3) = 218 columns. The 3 sub-periods are the pre-event, event and 
#		post-event periods.

BEGIN{

#	debug_switch ON will help to mdebug this program if you have trouble with it
#	debug_switch = "ON"
	debug_switch = "OFF"

#	outfilename for subperiod results
	outfile_subperiods = ("./Country_Results/" country "/API_sub_periods_overlap=" overlap)
	outfile_subperiods = (outfile_subperiods "_censor=" censor "_" country ".txt")
	outfile_debug = ("./Country_Results/" country "/APIs_IBES_debug_" country ".txt")
	if(debug_switch=="ON"){print "outfilename for subperiod results" outfile_subperiods > outfile_debug}

#	calendar of dates and corresponding dow (name) and day number, 197101 to 20181231 (PB's time zone is GMT+8)
	split("Sun,Mon,Tue,Wed,Thu,Fri,Sat",dayname,",")
	first_day = (mktime("1970 01 01 08 00 00")/86400)
	last_day = (mktime("2019 12 31 08 00 00")/86400)
	for(nd=first_day;nd<=last_day;nd++){
		split(strftime("%u %A %B %Y%m%d",(nd*86400)),bits," ")
		this_date = bits[4]
		this_dow = substr(bits[2],1,3)
		this_day = nd
		day_of_date[this_date] = this_day
		dow_of_date[this_date] = dayname[this_dow]
		dow_of_day[this_day] = dayname[this_dow]
		date_of_day[this_day] = this_date
	}

	FS = OFS = "\t"

#	new mkt avges generated 20181203-04: DS_pseudo mkt (within sample) avges of Datastream daily RIs
#	see top of file for further description of new indexes 20181204-5
#	transposed first 5 records in sample file <./Country_Data/AUS/distn_RIs_IBES_AUS.txt>
#	1       country AUS     AUS     AUS     AUS     AUS
#	2       date    19860102        19860103        19860104        19860105        19860106
#	3       N       212     213     213     213     213
#	4       avge    1.0036  1.00546 1       1       1.00432
#	5       median  1.00014 1.00012 1       1       1.00015
#	6       min     0.853034        0.896662        1       1       0.755556
#	7       p01     0.888546        0.942857        1       1       0.909107
#	8       p02     0.924138        0.956688        1       1       0.954486
#	9       p10     0.989103        0.986234        1       1       0.992525
#	10      Q1      1       1       1       1       1
#	11      Q3      1.00701 1.00477 1       1       1.01129
#	12      p90     1.02414 1.02858 1       1       1.0295
#	13      p98     1.08334 1.0756  1       1       1.07683
#	14      p99     1.1     1.09893 1       1       1.12543
#	15      max     1.16667 1.25    1       1       1.16665
#	16      N_trimmed       204     205     205     205     205
#	17      avge_ret_trimmed        0.00364373      0.00390168      0       0       0.00462102
#	18      avge_logror_trimmed     0.00348432      0.00376207      0       0       0.00448453
#	19      avge_ret_untrimmed      0.00359784      0.00546485      0       0       0.00432346
#	20      avge_logror_untrimmed   0.00316149      0.00503594      0       0       0.003763
	infile = ("./Country_Data/" country "/distn_RIs_IBES_" country ".txt")
	if(debug_switch=="ON"){print "pseudo-market infile", infile > outfile_debug}
	mkt_cum_prel = 1
	mkt_cum_logror = 0
	while((a=getline<infile)>0){
		if(!($1=="Date")){
			this_day = day_of_date[$2]
			if(first_mkt_day==""){first_mkt_day = this_day}
			last_mkt_day = this_day
#			if mkt avges not to exclude tails (ie, be censored), set $17=$19 and $18=$20
			if(censor=="NO"){$17 = $19; $18 = $20}
			mkt_avge_ret[this_day] = $17
			mkt_avge_logror[this_day] = $18
			mkt_cum_prel = mkt_cum_prel * (1 + $17)
			mkt_cum_logror+= $18
			mkt_cum_avge_prel[this_day] = mkt_cum_prel
			mkt_cum_avge_log_ror[this_day] = mkt_cum_logror
			nr++
			if((debug_switch=="ON") && (nr<=10)){
				print "within sample avge RI [" nr "]",country,$2,"day: " this_day, \
					"mkt ret: " $17,"mkt cum_prel: ",mkt_cum_prel,"mkt logror: ", \
					$18,"mkt cum_logror: " mkt_cum_logror > outfile_debug
			}
		}
	}
	close(infile)
	if(debug_switch=="ON"){print  "read mkt index" > outfile_debug}

#	NB:	event day 0 = Tdg_window_closes day; ie day number of bumped announcement date
#		first day in cumulative time-series = -360 (RI=1, cumror=0)
#		last day in cumulative time-series = +180
#		pre-event period: [-360: Tdg_window_opens day]
#		event period: (Tdg_window_opens day: Tdg_window_closes day]
#		post-event period: (Tdg_window_closes day: +180]
#		eg: sub-period	cum_log_ror for the sub-period
#			pre-event	[cum log ror(Tdg_window_opens) - cum log ror(-360)]
#			event		[cum log ror(Tdg_window_closes) - cum log ror(Tdg_window_opens)]
#			post-event	[cum log ror(+180) - cum log ror(Tdg_window_closes)]
#			total period	[cum log ror(+180) - cum log ror(-360)]
#			for cumprels, it's eg [cumprel(Tdg_window_opens) / cumprel(-360)]

#	tdg calendar
#		(dates at start are determined by Datastream's RI time-series and may not be used in this program)
	infile = ("./Country_Data/" country "/tdg_calndr_" country ".txt")
	if(debug_switch=="ON"){print "tdg_calndr",infile > outfile_debug}
#	first 4 records of <./Country_Data/AUS/tdg_calndr_AUS.txt>
#	Calndr_date  N(RIs_1   Tdg_window_closes  N(RIs_2)  Tdg_window_opens   N(RIs_3)
#	19601107     90        19730101           161
#	19601108               19730101           161       19601107           90
#	19601109               19730101           161       19601107           90
	nr = 0
	while((a=getline<infile)>0){
		if(!($1=="Calndr_date")){
			nr++
			tdg_day_b4_this_date[$1] = day_of_date[$5]
			tdg_date_b4_this_date[$1] = $5
			tdg_day_after_this_date[$1] = day_of_date[$3]
			tdg_date_after_this_date[$1] = $3

			if((debug_switch=="ON") && (nr<11)){print infile, "tdg calndr: " nr, $0 \
				> outfile_debug}
		}
	}
	close(infile)
	if(debug_switch=="ON"){print "read tdg_calndr",infile > outfile_debug}

#	there are 18 portfolio formation rules:
#		3 acctg measures (eps, gps, cps) x 
#		2 price deflators (previous fyr-end, previous calndr yr-end) x 
#		3 news measures (sign of delta-earnings measure, delta above/below median, delta in top/bottom quartile) 
	guff = "eps_pfyr_sign,eps_pfyr_medn,eps_pfyr_Q1Q4,eps_Dc31_sign,eps_Dc31_medn,eps_Dc31_Q1Q4,gps_pfyr_sign,gps_pfyr_medn,"
	guff = (guff "gps_pfyr_Q1Q4,gps_Dc31_sign,gps_Dc31_medn,gps_Dc31_Q1Q4,cps_pfyr_sign,cps_pfyr_medn,cps_pfyr_Q1Q4,")
	guff = (guff "cps_Dc31_sign,cps_Dc31_medn,cps_Dc31_Q1Q4")
	nports = split(guff,ports,",")
	if(debug_switch=="ON"){
		print nports "portfolios","port[1]: " ports[1],"port[" nports "]: " ports[nports] > outfile_debug
	}

#	(this_yr)-(this_eps)-(this_deflator)-(this_formation)-(this_news)-(this_stat)-(this_mkt)
	n_eps = split("eps,gps,cps",eps,",")
	n_deflator = split("pf,pD",deflator,",")
	n_formation = split("sign,medn,Q1Q4",formation,",")

	n_news = split("G,B",news,",")
	n_stat = split("av,N",stat,",")
	n_mkt = split("mktadj,unadj",mkt,",")
	API_hdr = "Day"
	ncols = 1

#	earnings signals
#	transposed first 6 records of <./Country_Data/AUS/code_IBES_eps_signals_output_20181020_AUS.txt>
#	1       country AUS     AUS     AUS     AUS     AUS
#	2       DScode  745287  755840  901839  901843  901847
#	3       fyr     19891231        19891231        19890630        19890630        19890630
#	4       announced       19900326        19900326        19891113        19891025        19891009
#	5       eps_measure     EPS     EPS     EPS     EPS     EPS
#	6       base    pr_Dec31        pr_Dec31        pr_Dec31        pr_Dec31        pr_Dec31
#	7       N       75      75      75      75      75
#	8       seq     1       2       3       4       5
#	9       stat    -0.0215333      -0.00782609     0.0631579       -0.000785597    0.0167485
#	10      news_sign       B       B       G       B       G
#	11      news_medn       B       B       G       B       G
#	12      news_Q1Q4       B       NA      G       NA      NA
        infile = ("./Country_Data/" country "/code_IBES_eps_signals_output_20181020_" country ".txt")
	if(debug_switch=="ON"){print "reading news signals from",infile > outfile_debug}
	nr = 0
	while((a=getline<infile)>0){
		if(!($1=="country")&&(country==$1)){
			nr++
			this_DScode = $2
			this_fyr = substr($3,1,4)
			this_rdq = $4
			this_eps_measure = tolower($5)
			this_base_price =($6 "_prev")
			this_stat = $9		# this_stat = eps_measure/base_price (aspreviously calculated)
			this_news_sign = $10
			this_news_median = $11
			this_news_Q1Q4 = $12
			this_event_window_opens_day = tdg_day_b4_this_date[this_rdq]
			this_event_window_closes_day = tdg_day_after_this_date[this_rdq]
			count_releases[this_DScode]++
			this_releases_info = (this_fyr "\t" this_eps_measure "\t" this_base_price)
			this_releases_info = (this_releases_info "\t" this_event_window_opens_day)
			this_releases_info = (this_releases_info "\t" this_event_window_closes_day)
			this_releases_info = (this_releases_info "\t" this_news_sign)
			this_releases_info = (this_releases_info "\t" this_news_median "\t" this_news_Q1Q4)
			this_releases_info = (this_releases_info "\t" $3)
			releases_info[this_DScode "\t" count_releases[this_DScode]] = this_releases_info
#			keep track by DScode-month_number of bumped announcement day for all eps releases by this coy
			month_number = this_fyr*12 + substr($3,5,2)
			bumped_release_day[this_DScode "\t" month_number] = this_event_window_closes_day

#			here's where we store info when we want to exclude any overlap period from the complete event window.
#			overlap="NO" sets stock and market RIs (cumprels) =1 so that investment performance is measured no
#				earlier than the day after last FYR's bumped announcement date (where last FYR is in the sample).
#			overlap="YES" retains the original model, ie it does not check for any overlap. Note that any PEAD
#				last FYR is ignored still.
			lookagain = (this_DScode "\t" (month_number - 12))
			if((lookagain in bumped_release_day) && (overlap=="NO")){
				delta_bumped_day = this_event_window_closes_day - bumped_release_day[lookagain]
				if(delta_bumped_day<360){
					complete_window_opening_day[this_DScode "\t" month_number] = \
						(this_event_window_closes_day - delta_bumped_day)
					print country,this_DScode,$3,date_of_day[this_event_window_closes_day], \
						date_of_day[bumped_release_day[lookagain]],this_event_window_closes_day, \
						bumped_release_day[lookagain],delta_bumped_day >> \
						"./cases_with_window_overlaps_IBES_AllCountries_AllYrs_2020.txt"
				}
			}
		}
	}
	close(infile)
	if(debug_switch=="ON"){print "read eps signals" > outfile_debug}

#	API hdr
	for(fyr=1971;fyr<=2018;fyr++){
		this_fyr = fyr
		if(fyr==2018){this_fyr = "AllYrs"}
		for(i_eps=1;i_eps<=n_eps;i_eps++){
			this_eps = eps[i_eps]
			for(i_deflator=1;i_deflator<=n_deflator;i_deflator++){
				this_deflator = deflator[i_deflator]
				for(i_formation=1;i_formation<=n_formation;i_formation++){
					this_formation = formation[i_formation]
					for(i_mkt=1;i_mkt<=n_mkt;i_mkt++){
						this_mkt = mkt[i_mkt]
						for(i_news=1;i_news<=n_news;i_news++){
							this_news = news[i_news]
							for(i_stat=1;i_stat<=n_stat;i_stat++){
								this_stat = stat[i_stat]
								ncols++
								this_field_hdr[ncols] = (this_fyr "_" this_eps "_" this_deflator "_" this_formation "_")
								this_field_hdr[ncols] = (this_field_hdr[ncols] this_news "_" this_mkt "_" this_stat)
								API_hdr = (API_hdr "\t" this_field_hdr[ncols])
							}
						}
					}
				}
			}
		}
	}

}

{
#	head ./Country_Data/AUS/RI_AUS.txt
#	130063  19940223        100
#	130063  19940224        94.44
#	130063  19940225        94.44
#	130063  19940226        94.44
#	130063  19940227        94.44
#	130063  19940228        94.44
#	130063  19940301        88.89
#	130063  19940302        88.89
#	130063  19940303        88.89
#	130063  19940304        88.89
	DScode = $1
	if(!(DScode in count_releases)){
		next
	}
	if(debug_switch=="ON"){
		nfound++
		if(nfound<11){print "found RI for wanted DScode: " nfound,$0 > outfile_debug}
	}
	this_date = $2
	this_day = day_of_date[this_date]
#	make sure this day is within the date range of the pseudo-mkt avges (it should be)
	if((this_day<first_mkt_day) || (this_day>last_mkt_day)){next}
	this_RI = $3
	if(!(this_RI>0)){next}
	if(old_coy==""){
		old_coy = $1
		first_day_seen = last_day_seen = this_day
		RI[this_day] = this_RI
		next
	}
	new_coy = $1
	if(new_coy==old_coy){
		RI[this_day] = this_RI
		last_day_seen = this_day
		next
	}

#	new company so process old
	if(debug_switch=="ON"){print "about to process",old_coy > outfile_debug}
	process_old_coy(old_coy,first_day_seen,last_day_seen,RI)
	delete RI
	old_coy = DScode
	first_day_seen = last_day_seen = this_day
	RI[this_day] = this_RI
}

END{

#	first, process the last company in the RI input file
	process_old_coy(old_coy,first_day_seen,last_day_seen,RI)
	if(debug_switch=="ON"){print "Processed last company; about to print avges" > outfile_debug}
	n = asorti(port_avge,d)
	if(debug_switch=="ON"){print "Number of chunks to print: " n > outfile_debug}
	for(i=1;i<=n;i++){print d[i],port_avge[d[i]],port_cnt[d[i]]}

}

function process_old_coy(old_coy,first_day_seen,last_day_seen,RI){
#	PROCESS loop 1 is by announcement for this stock (N is variable); loop2 is by RI_ewmkt, 
#		RI_nomkt, ror_ewmkt and ror_nomkt (N=4); loop3 is by eps signal (N=3x2x3=18).
#		Write the sub-period stats for each coy-FYR to the file for sub-period results,
#		<APIs_sub_periods_(country)_(date-time).txt> (see below for the layout of records
#		in this file; each record has 290 ??? fields, so it should be written after the
#		day-by-day results are calculated).
#	END process last stock; calculate all averages and write them to the 4 investment
#		performance output files (as specified in loop2)

#	company data have been indexed this way:
#	(this_yr)-(this_eps)-(this_deflator)-(this_formation)-(this_news)-(this_stat)-(this_mkt)

#	loop2 is RI_mktadj, RI_unadj, ror_mktadj and rorunadj
#				n_mkt = split("mktadj,unadj",mkt,",")
#				[country "\t" day number]
#				mkt_cum_avge_prel[$1 "\t" nd] = cum_avge_prel
#				mkt_cum_avge_log_ror[$1 "\t" nd] = log(cum_avge_prel)
	this_DScode = old_coy
	nannoun_stop = count_releases[this_DScode]
	if(!(nannoun_stop>0)){return}
#	outermost loop is for number of announcements
	for(nannoun=1;nannoun<=nannoun_stop;nannoun++){
		if(debug_switch=="ON"){
			print "02: processing " this_DScode,"no announcements: " nannoun_stop,"Seq: " nannoun, \
				releases_info[this_DScode "\t" nannoun],"first date", date_of_day[first_day_seen], \
				"last date", date_of_day[last_day_seen] > outfile_debug
		}
		split(releases_info[this_DScode "\t" nannoun],release_info_bits,"\t")
		this_fyr = release_info_bits[1]
		this_eps_measure = release_info_bits[2]
		this_base_price = release_info_bits[3]
		this_news_sign = release_info_bits[6]
		this_news_median = release_info_bits[7]
		this_news_Q1Q4 = release_info_bits[8]
		this_fyr_end_yyyymmdd = release_info_bits[9]
#		establish window opening and closing days, generate RI and cum log return time series with and
#			without mkt adjustment
		this_event_window_opens_day = release_info_bits[4]
		this_event_window_closes_day = release_info_bits[5]
#		full period window: starts day -360 for cum returns, day -360 for RIs; ends day +180 for both returns and RIs
		this_full_window_opens_day = this_event_window_closes_day - 360
		this_full_window_closes_day = this_event_window_closes_day + 180
		days_overlap = 0
#		overlap = "NO" means we set all non-zero returns to zero in the overlap period. Identify the overlap
#			period by comparing the reporting lag this year and that last year
		if(overlap=="NO"){
			month_number = substr(this_fyr_end_yyyymmdd,1,4)*12 + substr(this_fyr_end_yyyymmdd,5,2)
			lookfor = (this_DScode "\t" month_number)
			lookagain = (this_DScode "\t" (month_number - 12))
			if(lookagain in bumped_release_day){
#			if needed, check whether we're setting RIs=1 during any overlap between this and last FYR
#				bumped_release_day[this_DScode "\t" month_number] = this_event_window_closes_day
				days_overlap = bumped_release_day[lookagain] - this_full_window_opens_day
				if(days_overlap<0){days_overlap = 0}
			}
			if((debug_switch=="ON") && (days_overlap>0)){
				print "02c: FOUND Overlap -- " this_DScode,this_fyr,"days_overlap = " days_overlap \
					> outfile_debug
			}
		}
#		establish that both this_full_window_opens_day and this_full_window_closes_day are in both stock and mkt rets
		if(debug_switch=="ON"){
			print "03: " this_DScode,this_fyr,nannoun,"event window opens: " this_event_window_opens_day, \
				date_of_day[this_event_window_opens_day],"event window closes: " \
				this_event_window_closes_day,date_of_day[this_event_window_closes_day], \
				"first day/date seen: " first_day_seen,date_of_day[first_day_seen], \
				"last day/date seen: " last_day_seen,date_of_day[last_day_seen], \
				"date full window opens/closes: " date_of_day[this_full_window_opens_day], \
				date_of_day[this_full_window_closes_day] > outfile_debug
		}
		if((this_full_window_opens_day in RI) && (this_full_window_closes_day in RI) && \
			(this_full_window_opens_day in mkt_cum_avge_prel) && \
			(this_full_window_closes_day in mkt_cum_avge_prel)){
			lookfor_returns = (this_DScode "\t" this_event_window_closes_day)
			if(!(lookfor_returns==lookfor_returns_prev)){
				lookfor_returns_prev = lookfor_returns
				delete these_cum_log_rors
				delete these_cum_log_rors_mkt_adj
				delete these_RIs
				delete these_mkt_RIs
				delete these_RIs_mkt_adj
				exclude_this_announ = "NO"
				day_number = 0
				stub_this_case = (this_fyr "\t" this_eps_measure "\t" this_base_price)
#				stub = (stub "\t" this_news_sign "\t" this_news_median "\t" this_news_Q1Q4)
				for(nd=this_full_window_opens_day;nd<=this_full_window_closes_day;nd++){
					day_number++
					this_RI = RI[nd]
					RI_prev = RI[nd-1]
#					here's where we ensure no overlap; if day_number<days_overlap, then we
#						want to re-set the base_RI and ensure RIs=1 and rors=0
					if((day_number==1) || (day_number<=days_overlap)){
						cum_log_ror = cum_log_ror_mkt_adj = 0
						base_RI = RI[nd]
						base_mkt_RI = mkt_cum_avge_prel[nd]
						base_mkt_cum_avge_log_ror = mkt_cum_avge_log_ror[nd]
						if((debug_switch=="ON") && (days_overlap>0)){
							print "10: " this_DScode,this_fyr,"overlap = " \
								days_overlap,"day number = " day_number, \
								"base_RI = " base_RI,"base_mkt_RI = " base_mkt_RI \
								> outfile_debug
						}
						these_cum_log_rors[day_number] = 0
						these_cum_log_rors_mkt_adj[day_number] = 0
						these_RIs[day_number] = 1
						these_mkt_RIs[day_number] = 1
						these_RIs_mkt_adj[day_number] = 1
					}
					if((day_number>1) && (day_number>days_overlap)){
						if(this_RI=="Drop"){
							print "excluding " this_DScode " stub_this_case; check ret on " \
								date_of_day[nd] > ("./exclusions_within_API_awk_code_" country ".txt")
							exclude_this_announ = "YES"
						}
						these_RIs[day_number] = (RI[nd]/base_RI)
						these_RIs_mkt_adj[day_number] = these_RIs[day_number] /  \
							(mkt_cum_avge_prel[nd] / base_mkt_RI)
						these_cum_log_rors[day_number] = log(these_RIs[day_number])
						these_cum_log_rors_mkt_adj[day_number] = these_cum_log_rors[day_number] -  \
							(mkt_cum_avge_log_ror[nd] - base_mkt_cum_avge_log_ror)
						if((debug_switch=="ON") && (days_overlap>0)){
							print "07: " this_DScode,this_fyr,"overlap = " days_overlap, \
								"day number = " day_number,"RI = " RI[nd], \
								"these_RIs[day_number] = " these_RIs[day_number], \
								"mkt_cum_avge_prel = " mkt_cum_avge_prel[nd], \
								"base_mkt_RI = " base_mkt_RI,"these_RIs_mkt_adj[day_number] = " \
								these_RIs_mkt_adj[day_number],"base_mkt_cum_avge_log_ror = " \
								base_mkt_cum_avge_log_ror,"these_cum_log_rors = " \
								these_cum_log_rors[day_number],"cum_log_rors_mkt_adj = " \
								these_cum_log_rors_mkt_adj[day_number] > outfile_debug
						}
					}
					if(nd==(this_event_window_opens_day)){sub_period_1_ends_day = day_number}
					if(nd==this_event_window_closes_day){sub_period_2_ends_day = day_number}
				}
			}


			if(exclude_this_announ=="NO"){

#			loop through each of the 3 portfolio formation rules
			for(portfolio_rule=1;portfolio_rule<=3;portfolio_rule++){
				rule = "sign"; action = this_news_sign
				if(portfolio_rule==2){rule = "medn"; action = this_news_median}
				if(portfolio_rule==3){rule = "Q1Q4"; action = this_news_Q1Q4}
#				options: N(options) = 72 [= 18 x 4, where 4 = 2 mkt-adj/not mkt-adj x 2 performance measures (RI/log ror)]
#				stub_this_case = (this_fyr "\t" this_eps_measure "\t" this_base_price "\t" 
#					this_news_sign "\t" this_news_median "\t" this_news_Q1Q4)
#				lookfor = (stub_this_case "\t" rule "\t" action)
				lookfor = (this_fyr "\t" this_eps_measure "\t" this_base_price "\t" rule "\t" action)
				if(debug_switch=="ON"){print "05: " DScode,lookfor > outfile_debug}
				for(nd=1;nd<=541;nd++){
					if(nd==1){
						port_avge[lookfor "\tRI\t" nd]+= these_RIs[1]
						port_cnt[lookfor "\tRI\t" nd]++
						port_avge[lookfor "\tadjRI\t" nd]+= these_RIs_mkt_adj[1]
						port_cnt[lookfor "\tadjRI\t" nd]++
					}
					if(nd>1){
						port_avge[lookfor "\tror\t" nd]+= these_cum_log_rors[nd]
						port_cnt[lookfor "\tror\t" nd]++
						port_avge[lookfor "\tadjror\t" nd]+= these_cum_log_rors_mkt_adj[nd]
						port_cnt[lookfor "\tadjror\t" nd]++
						port_avge[lookfor "\tRI\t" nd]+= these_RIs[nd]
						port_cnt[lookfor "\tRI\t" nd]++
						port_avge[lookfor "\tadjRI\t" nd]+= these_RIs_mkt_adj[nd]
						port_cnt[lookfor "\tadjRI\t" nd]++
					}
				}
				sub1_opens_RI = these_RIs[1]
				sub1_closes_RI = these_RIs[sub_period_1_ends_day]
				sub2_opens_RI = these_RIs[sub_period_1_ends_day]
				sub2_closes_RI = these_RIs[sub_period_2_ends_day]
				sub3_opens_RI = these_RIs[sub_period_2_ends_day]
				sub3_closes_RI = these_RIs[541]
				pre_event_RI = sub1_closes_RI/sub1_opens_RI
				event_RI =  sub2_closes_RI/sub2_opens_RI
				post_event_RI = sub3_closes_RI/sub3_opens_RI

				sub1_opens_RI_adj = these_RIs_mkt_adj[1]
				sub1_closes_RI_adj = these_RIs_mkt_adj[sub_period_1_ends_day]
				sub2_opens_RI_adj = these_RIs_mkt_adj[sub_period_1_ends_day]
				sub2_closes_RI_adj = these_RIs_mkt_adj[sub_period_2_ends_day]
				sub3_opens_RI_adj = these_RIs_mkt_adj[sub_period_2_ends_day]
				sub3_closes_RI_adj = these_RIs_mkt_adj[541]
				pre_event_RI_adj = sub1_closes_RI_adj/sub1_opens_RI_adj
				event_RI_adj = sub2_closes_RI_adj/sub2_opens_RI_adj
				post_event_RI_adj = sub3_closes_RI_adj/sub3_opens_RI_adj

				sub1_opens_cum_ror = these_cum_log_rors[1]
				sub1_closes_cum_ror = these_cum_log_rors[sub_period_1_ends_day]
				sub2_opens_cum_ror = these_cum_log_rors[sub_period_1_ends_day]
				sub2_closes_cum_ror = these_cum_log_rors[sub_period_2_ends_day]
				sub3_opens_cum_ror = these_cum_log_rors[sub_period_2_ends_day]
				sub3_closes_cum_ror = these_cum_log_rors[541]
				pre_event_cum_ror = sub1_closes_cum_ror - sub1_opens_cum_ror
				event_cum_ror = sub2_closes_cum_ror - sub2_opens_cum_ror
				post_event_cum_ror = sub3_closes_cum_ror - sub3_opens_cum_ror

				sub1_opens_cum_ror_adj = these_cum_log_rors_mkt_adj[1]
				sub1_closes_cum_ror_adj = these_cum_log_rors_mkt_adj[sub_period_1_ends_day]
				sub2_opens_cum_ror_adj = these_cum_log_rors_mkt_adj[sub_period_1_ends_day]
				sub2_closes_cum_ror_adj = these_cum_log_rors_mkt_adj[sub_period_2_ends_day]
				sub3_opens_cum_ror_adj = these_cum_log_rors_mkt_adj[sub_period_2_ends_day]
				sub3_closes_cum_ror_adj = these_cum_log_rors_mkt_adj[541]
				pre_event_cum_ror_adj = sub1_closes_cum_ror_adj - sub1_opens_cum_ror_adj
				event_cum_ror_adj = sub2_closes_cum_ror_adj - sub2_opens_cum_ror_adj
				post_event_cum_ror_adj = sub3_closes_cum_ror_adj - sub3_opens_cum_ror_adj
				if(debug_switch=="ON"){
					print this_DScode,nannoun,releases_info[this_DScode "\t" nannoun],lookfor, \
						"pre_event_RI",pre_event_RI,"event_RI",event_RI,"post_event_RI",post_event_RI, \
						"pre_event_RI_adj",pre_event_RI_adj,"event_RI_adj",event_RI_adj, \
						"post_event_RI_adj",post_event_RI_adj,"pre_event_cum_ror",pre_event_cum_ror, \
						"event_cum_ror",event_cum_ror,"post_event_cum_ror",post_event_cum_ror, \
						"pre_event_cum_ror_adj",pre_event_cum_ror_adj,"event_cum_ror_adj", \
						event_cum_ror_adj,"post_event_cum_ror_adj",post_event_cum_ror_adj \
						> outfile_debug
				}
				print this_DScode,nannoun,releases_info[this_DScode "\t" nannoun],lookfor, \
					"pre_event_RI",pre_event_RI,"event_RI",event_RI,"post_event_RI",post_event_RI, \
					"pre_event_RI_adj",pre_event_RI_adj,"event_RI_adj",event_RI_adj, \
					"post_event_RI_adj",post_event_RI_adj,"pre_event_cum_ror",pre_event_cum_ror, \
					"event_cum_ror",event_cum_ror,"post_event_cum_ror",post_event_cum_ror, \
					"pre_event_cum_ror_adj",pre_event_cum_ror_adj,"event_cum_ror_adj", \
					event_cum_ror_adj,"post_event_cum_ror_adj",post_event_cum_ror_adj > outfile_subperiods
			}
			}
		}
	}
}
