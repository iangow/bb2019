#	resample_subperiod_APIs_IBES.awk: reformat sub-period measures and undertake resampling
#	gawk -v niter=3 -v country="AUS" -f ./resample_subperiod_APIs_IBES.awk
#		./Country_Results/AUS/API_sub_periods_20200322_overlap=YES_censor=NO_AUS.txt >
#		./Country_Results/AUS/resample_subperiod_APIs_IBES_output_AUS.txt

#	modified 20181211 to ensure same seed for random numbers and to use the 40-field
#		input file (an additional fyr field, $11, was added in yyyymmdd format)


BEGIN{
	FS = OFS = "\t"

#	seed random number generator
	srand(20181210)

}

{

#	store data by fyr-stub-subperiod-action (see bottom of this file for
#		list of input file's fields
	fyr = $3
	fyr_seen[fyr] = 1
#	stub: eps measure_deflator_portfolio formation rule
#       13      eps     eps     eps     eps     eps     eps
#       14      pr_Dec31_prev   pr_Dec31_prev   pr_Dec31_prev   pr_fyr_prev     pr_fyr_prev     pr_fyr_prev
#       15      sign    medn    Q1Q4    sign    medn    Q1Q4
	stub = ($13 "_" $14 "_" $15)
#################################################### temporary limit to base case #####################################
	if(!(stub==("eps_pr_fyr_prev_sign"))){next}
#######################################################################################################################
	stub_seen[stub] = 1
#	action = G or B news signal
	action = $16

	count[fyr "\t" stub "\t" action]++
	count["AllYrs\t" stub "\t" action]++

	combined_seen[fyr "\t" stub "\t" action] = 1
#	if(NR<5){print "1:",NR,$1,fyr,stub,action,ncase}
#################################################### temporary limit to "AllYrs" ######################################
	skip_separate_yrs = "YES"
#######################################################################################################################
	if(!(skip_separate_yrs=="YES")){
	#	Fyrs separately
		ncase = count[fyr "\t" stub "\t" action]
		API_results[fyr "\t" stub "\t" action "\tpre_event_RI\t" ncase] = $18
		API_results[fyr "\t" stub "\t" action "\tpre_event_RI_adj\t" ncase] = $24
		API_results[fyr "\t" stub "\t" action "\tevent_RI\t" ncase] = $20
		API_results[fyr "\t" stub "\t" action "\tevent_RI_adj\t" ncase] = $26
		API_results[fyr "\t" stub "\t" action "\tpost_event_RI\t" ncase] = $22
		API_results[fyr "\t" stub "\t" action "\tpost_event_RI_adj\t" ncase] = $28
	
		API_results[fyr "\t" stub "\t" action "\tpre_event_cum_ror\t" ncase] = $30
		API_results[fyr "\t" stub "\t" action "\tpre_event_cum_ror_adj\t" ncase] = $36
		API_results[fyr "\t" stub "\t" action "\tevent_cum_ror\t" ncase] = $32
		API_results[fyr "\t" stub "\t" action "\tevent_cum_ror_adj\t" ncase] = $38
		API_results[fyr "\t" stub "\t" action "\tpost_event_cum_ror\t" ncase] = $34
		API_results[fyr "\t" stub "\t" action "\tpost_event_cum_ror_adj\t" ncase] = $40
	}
#	AllYrs
	ncase = count["AllYrs\t" stub "\t" action]
	API_results["AllYrs\t" stub "\t" action "\tpre_event_RI\t" ncase] = $18
	API_results["AllYrs\t" stub "\t" action "\tpre_event_RI_adj\t" ncase] = $24
	API_results["AllYrs\t" stub "\t" action "\tevent_RI\t" ncase] = $20
	API_results["AllYrs\t" stub "\t" action "\tevent_RI_adj\t" ncase] = $26
	API_results["AllYrs\t" stub "\t" action "\tpost_event_RI\t" ncase] = $22
	API_results["AllYrs\t" stub "\t" action "\tpost_event_RI_adj\t" ncase] = $28

	API_results["AllYrs\t" stub "\t" action "\tpre_event_cum_ror\t" ncase] = $30
	API_results["AllYrs\t" stub "\t" action "\tpre_event_cum_ror_adj\t" ncase] = $36
	API_results["AllYrs\t" stub "\t" action "\tevent_cum_ror\t" ncase] = $32
	API_results["AllYrs\t" stub "\t" action "\tevent_cum_ror_adj\t" ncase] = $38
	API_results["AllYrs\t" stub "\t" action "\tpost_event_cum_ror\t" ncase] = $34
	API_results["AllYrs\t" stub "\t" action "\tpost_event_cum_ror_adj\t" ncase] = $40

#	if(NR<5){
#		print NR
#		for(jj in API_results){print "2:",NR,jj,API_results[jj]}
#	}

}

END{
	guff = "pre_event_RI,pre_event_RI_adj,event_RI,event_RI_adj,post_event_RI,post_event_RI_adj,"
	guff = (guff "pre_event_cum_ror,pre_event_cum_ror_adj,event_cum_ror,event_cum_ror_adj,")
	guff = (guff "post_event_cum_ror,post_event_cum_ror_adj")
	n_stat_labels = split(guff,stat_labels,",")
#	print "3:","stat_labels",n_stat_labels,stat_labels[1],stat_labels[n_stat_labels]
	fyr_seen["AllYrs"] = 1
	nfyrs = asorti(fyr_seen)
	nstubs = asorti(stub_seen)
#################################################### temporary limit to "AllYrs" ######################################
	nfyrs = 1
	fyr_seen[1] = "AllYrs"
	for(nfyr=1;nfyr<=nfyrs;nfyr++){
		if(nfyr==nfyrs){this_fyr = "AllYrs"}
#######################################################################################################################
#	for(fyr=fyr_seen[1];fyr<=fyr_seen[nfyrs];fyr++){
#		this_fyr = fyr
#		print "4:","processing " this_fyr
		for(ns=1;ns<=nstubs;ns++){
			this_stub = stub_seen[ns]
			lookfor1 = (this_fyr "\t" this_stub "\tG")
			lookfor2 = (this_fyr "\t" this_stub "\tB")
#			if(ns<3){print "5:","lookfor1",lookfor1,"lookfor2",lookfor2}
#			5:      lookfor1        1971    epsfi_pr_Dec31_prev_medn        G       lookfor2        1971    epsfi_pr_Dec31_prev_medn        B
#			count[fyr "\t" stub "\t" action]++
#			if(!(lookfor1 in count) && (lookfor2 in count)){
#				print "6:","lookfor1 or lookfor2 not in count"
#			}
			if((lookfor1 in count) && (lookfor2 in count)){
#				print "7:","lookfor1 and lookfor2 both in count"
				N1 = count[lookfor1]
				N2 = count[lookfor2]
				for(j=1;j<=n_stat_labels;j++){
					this_stat_label = stat_labels[j]
					delete xG
					delete xB
					delete xBoth
					sumG = sumB = 0
					for(n1=1;n1<=N1;n1++){
#						API_results[fyr "\t" stub "\t" action "\tpre_event_RI\t" ncase] = $17
#							stub: eps measure_deflator_portfolio formation rule
#							stub = ($12 "_" $13 "_" $14)
#							stub_seen[stub] = 1
#						7a:     1971    epsfi_pr_Dec31_prev_Q1Q4        Gpre_event_RI   1       IS NOT in API_results
#						7a:     1971    epsfi_pr_Dec31_prev_Q1Q4        Gpre_event_RI   2       IS NOT in API_results

						this_wanted = (this_fyr "\t" this_stub "\tG\t" this_stat_label "\t" n1)
#						if(!(this_wanted in API_results)){print "7a:",this_wanted,"IS NOT in API_results"}
#						if(this_wanted in API_results){print "7a:",this_wanted,"IS in API_results"}
						this_metric = API_results[this_fyr "\t" this_stub "\tG\t" this_stat_label "\t" n1]
						xG[n1]=  this_metric
						sumG+= this_metric
						xBoth[n1] = this_metric
#						if(n1<3){print "8:",this_fyr,this_stub,"G",this_stat_label,n1,this_metric}
#						8:      1971    epsfi_pr_Dec31_prev_medn        G       pre_event_RI_adj        2

					}
					for(n2=1;n2<=N2;n2++){
						this_metric = API_results[this_fyr "\t" this_stub "\tB\t" this_stat_label "\t" n2]
						xB[n2] = this_metric
						sumB+= this_metric
						xBoth[N1+n2] = this_metric
#						if(n2<3){print "9:",this_fyr,this_stub,"B",this_stat_label,n2,this_metric}
#						9:      1971    epsfi_pr_Dec31_prev_medn        B       pre_event_RI_adj        1
					}
					meanG = sumG / N1
					meanB = sumB / N2
					diff_in_means = meanG - meanB
					this_result = resample(meanG,N1,meanB,N2,xBoth)
#					print "resampling result:",this_fyr,this_stub,this_stat_label,this_result
#					return(NcontrolLTexptl "\t" NcontrolEQexptl "\t" NcontrolGTexptl)
					resampling_tests_stats[this_fyr "\t" this_stub "\t" this_stat_label] = \
						(meanG "\t" N1 "\t" meanB "\t" N2 "\t" this_result)
				}
			}
		}
	}
	print "Fyr\tPortfolios\tStatistic\tG_Mean\tG_N\tB_Mean\tB_N\tCntrl(GlessB)_lt_Exptl(GlessB)\t" \
		"Cntrl(GlessB)_eq_Exptl(GlessB)\tCntrl(GlessB)_gt_Exptl(GlessB)"
	for(k in resampling_tests_stats){print k,resampling_tests_stats[k]}
}

function resample(meanG,N1,meanB,N2,combined){

#	print "10:","in resample:","meanG",meanG,"NG",N1,"meanB",meanB,"NB",N2

#	initialise counters
	NcontrolLTexptl = NcontrolEQexptl = NcontrolGTexptl = 0
					
	N = N1 + N2

#	iterations of resampled portfolios begin here
	for(ntrial=1;ntrial<=niter;ntrial++){
#		print "Beginning trial " ntrial
#		new segment of code to speed things up...
		delete wanted_seq; delete np
#		set up the array of subsripts which will be shuffled
		for(i=1;i<=N;i++){wanted_seq[i] = i}
#		maxN is used to restrict the range of the randomly-generated elements
		maxN = N
#		counter keeps track of how many elements have been sampled	
		counter = 0
		while(counter<N1){
#			find which element and store (we're using the rectangular
#				distribution so that all remaining elements are
#				equally likely to be selected)
			nsub = int(rand() * maxN) + 1
			np[wanted_seq[nsub]] = 1
			counter++
#			check whether element just selected is last in array of wanted elements;
#				if it's not, then replace element just selected with last in array
                	if(!(nsub==maxN)){wanted_seq[nsub] = wanted_seq[maxN]}
#              		repeat the procedure, looking within the first maxN-1 elements
			maxN--
        	}

#		construct the 2nd pseudo portfolio
		for(nm=1;nm<=N;nm++){if(np[nm]==""){np[nm] = 2}}

#		result for this resampling trial
		pseudo1 = pseudo2 = 0
		for(nm=1;nm<=N;nm++){
			if(np[nm]==1){pseudo1+= combined[nm]}
			if(np[nm]==2){pseudo2+= combined[nm]}
		}
		control_diff = (pseudo1/N1 - pseudo2/N2)
		exptl_diff = meanG - meanB

		if(control_diff<exptl_diff){NcontrolLTexptl++}
		if(control_diff==exptl_diff){NcontrolEQexptl++}
		if(control_diff>exptl_diff){NcontrolGTexptl++}
	}
	return(NcontrolLTexptl "\t" NcontrolEQexptl "\t" NcontrolGTexptl)
}
#	1       130280  130280  130280  130280  130280  130280
#	2       1       1       1       2       2       2
#	3       1998    1998    1998    1998    1998    1998
#	4       eps     eps     eps     eps     eps     eps
#	5       pr_Dec31_prev   pr_Dec31_prev   pr_Dec31_prev   pr_fyr_prev     pr_fyr_prev     pr_fyr_prev
#	6       10459   10459   10459   10459   10459   10459
#	7       10463   10463   10463   10463   10463   10463
#	8       G       G       G       G       G       G
#	9       G       G       G       G       G       G
#	10      G       G       G       G       G       G
#	11      19980630        19980630        19980630        19980630        19980630        19980630
#	12      1998    1998    1998    1998    1998    1998
#	13      eps     eps     eps     eps     eps     eps
#	14      pr_Dec31_prev   pr_Dec31_prev   pr_Dec31_prev   pr_fyr_prev     pr_fyr_prev     pr_fyr_prev
#	15      sign    medn    Q1Q4    sign    medn    Q1Q4
#	16      G       G       G       G       G       G
#	17      pre_event_RI    pre_event_RI    pre_event_RI    pre_event_RI    pre_event_RI    pre_event_RI
#	18      0.575165        0.575165        0.575165        0.575165        0.575165        0.575165
#	19      event_RI        event_RI        event_RI        event_RI        event_RI        event_RI
#	20      0.984221        0.984221        0.984221        0.984221        0.984221        0.984221
#	21      post_event_RI   post_event_RI   post_event_RI   post_event_RI   post_event_RI   post_event_RI
#	22      1.33874 1.33874 1.33874 1.33874 1.33874 1.33874
#	23      pre_event_RI_adj        pre_event_RI_adj        pre_event_RI_adj        pre_event_RI_adj        pre_event_RI_adj        pre_event_RI_adj
#	24      0.565531        0.565531        0.565531        0.565531        0.565531        0.565531
#	25      event_RI_adj    event_RI_adj    event_RI_adj    event_RI_adj    event_RI_adj    event_RI_adj
#	26      0.98955 0.98955 0.98955 0.98955 0.98955 0.98955
#	27      post_event_RI_adj       post_event_RI_adj       post_event_RI_adj       post_event_RI_adj       post_event_RI_adj       post_event_RI_adj
#	28      1.04995 1.04995 1.04995 1.04995 1.04995 1.04995
#	29      pre_event_cum_ror       pre_event_cum_ror       pre_event_cum_ror       pre_event_cum_ror       pre_event_cum_ror       pre_event_cum_ror
#	30      -0.553097       -0.553097       -0.553097       -0.553097       -0.553097       -0.553097
#	31      event_cum_ror   event_cum_ror   event_cum_ror   event_cum_ror   event_cum_ror   event_cum_ror
#	32      -0.0159045      -0.0159045      -0.0159045      -0.0159045      -0.0159045      -0.0159045
#	33      post_event_cum_ror      post_event_cum_ror      post_event_cum_ror      post_event_cum_ror      post_event_cum_ror      post_event_cum_ror
#	34      0.291729        0.291729        0.291729        0.291729        0.291729        0.291729
#	35      pre_event_cum_ror_adj   pre_event_cum_ror_adj   pre_event_cum_ror_adj   pre_event_cum_ror_adj   pre_event_cum_ror_adj   pre_event_cum_ror_adj
#	36      -0.212383       -0.212383       -0.212383       -0.212383       -0.212383       -0.212383
#	37      event_cum_ror_adj       event_cum_ror_adj       event_cum_ror_adj       event_cum_ror_adj       event_cum_ror_adj       event_cum_ror_adj
#	38      -0.00830955     -0.00830955     -0.00830955     -0.00830955     -0.00830955     -0.00830955
#	39      post_event_cum_ror_adj  post_event_cum_ror_adj  post_event_cum_ror_adj  post_event_cum_ror_adj  post_event_cum_ror_adj  post_event_cum_ror_adj
#	40      0.24558 0.24558 0.24558 0.24558 0.24558 0.24558
