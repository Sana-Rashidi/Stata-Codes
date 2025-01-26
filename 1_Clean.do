	
	/*--------------------------------------------------------------------------------
							Data Cleaning and Preperation
	--------------------------------------------------------------------------------*/
	clear all
	/*--------------------------------------------------------------------------------
								Macros
	--------------------------------------------------------------------------------*/
	gl sev_thr = 3*365
	gl month_thr = 36
	gl month_length = 31
	gl month_thr = 36
	// lower and upper bound for tenure and work experience in the data for rd
	gl emp_low = 365
	gl emp_high = 5*365
	// nonduration treshhold
	gl none_emp_tr = 2*365
	// censore limit for hazard
	gl none_emp_bound = 20*7
	gl yr_low = 1980
	gl yr_high = 2002
	gl sev_xline = 35.5
	
	gl sev_month_xline   	"xline(${sev_xline}, lwidth(0.3) lcolor(gs4) lp(dash))"
	gl sev_day_xline   		"xline(${sev_thr},   lwidth(0.3) lcolor(gs4) lp(dash))"
	gl connected_graph_1 	"sort mcolor(black) msize(medsmall)  m(O)  lcolor(black) lp(solid)"
	gl connected_graph_2 	"sort mcolor(gs8)   msize(medsmall)  m(D)  lcolor(gs8) lp(dash)"
	gl connected_graph_3 	"sort mcolor(black) msize(small)  m(O) lcolor(gs8) lp(solid)"	
	gl graph_style_1     	"xlabel(12(6)60) graphregion(color(white))" 
	gl graph_color     	    "graphregion(fcolor(white))" 
	gl tenure_range_graph 	"tenure_month>=13 & tenure_month<=59"
	gl graph_size_1 		"xsize(15) ysize(8)"
	gl graph_size_2 		"xsize(10) ysize(15)"
	gl fit_gr 		        "sort color(gs7) lwidth(0.2)"
	gl yangle				"angle(horizental)"
	gl out_fmt              "pdf"
	gl leg_pos				"position(6)"   
	gl tab_fmt_1 			"cells(b(star fmt(%6.3f)) se(par fmt(%6.3f))) star(* 0.1 ** 0.05 *** 0.01)"
	gl tab_fmt_2 			"collabels(none) nogap unstack noobs onecell"
	gl table_format_1 	 	"${tab_fmt_1} ${tab_fmt_2}"
	gl table_format_2 		"onecell nonumber noobs nogap label nodepvars nomtitles"
	gl mgroup 				"prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})"
	
	// graph scheme
	set scheme cleanplots, perm
	
	/*--------------------------------------------------------------------------------
								merge datasets
	---------------------------------------------------------------------------------*/
	cd  ${Project_Folder}
	use "${Data}/sample_75_02.dta"
	merge 1:1 penr file using "${Data}/work_history.dta"
	drop _merge

	/*--------------------------------------------------------------------------------
						keep observations for the analysis
	---------------------------------------------------------------------------------*/
{	// cleaning the data
	gen 	tenure = end-start+1
	gen 	end_yr=year(end)
	// drop individuals who quit voluntarily and who got back to their previous jobs
	gen 	to_drop = 1 if volquit==1
	replace to_drop = 1 if recall==1
	// we want filing years in 1981-2001
	replace to_drop = 1 if end_yr<=${yr_low} | end_yr>=${yr_high}
	// tenure and employment experience in last 5 years between 1 and 5 years
	replace to_drop = 1 if !inrange(tenure,${emp_low},${emp_high}-1) | !inrange(dempl5,${emp_low},${emp_high}-1)
	drop if to_drop==1
	drop 	tenure end_yr
}
	
	/*--------------------------------------------------------------------------------
					generate variables for cox and rd regressions
	---------------------------------------------------------------------------------*/	
	
{	// generating variables
	// tenure
	gen 	tenure 		= end-start+1	
	gen	    tenure_cat  = ${month_thr}+int((tenure-${sev_thr})/${month_length})     if tenure>=${sev_thr}
	replace tenure_cat  = ${month_thr}-1+int((tenure-${sev_thr}+1)/${month_length}) if tenure<${sev_thr}
	replace tenure_cat  = . if tenure_cat<13 | tenure_cat>58
	
	// month employed
	gen     month_emp_cat  = ${month_thr}+int((dempl5-${sev_thr})/${month_length})     if dempl5>=${sev_thr}
	replace month_emp_cat  = ${month_thr}-1+int((dempl5-${sev_thr}+1)/${month_length}) if dempl5<${sev_thr}
	replace month_emp_cat  = . if month_emp_cat<13 | month_emp_cat>58
	* main variables in regression
	gen 	sp = tenure>=${sev_thr}
	gen 	eb = dempl5>=${sev_thr}	
	// mw: months of worked
	gen 	mw       = (dempl5/365)*12
	gen		mw2		 = mw^2
	gen		mw3		 = mw^3	
	gen		mw4		 = mw^4	
	// jt: job tenure
	gen 	jt       = (tenure/365)*12
	gen 	jt2      = jt^2
	gen 	jt3      = jt^3	
	gen 	jt4      = jt^4		
	* interactions
	// interaction of job-tenure and severance payment
	gen 	sp_jt_diff  = sp*(jt-${month_thr})
	gen 	sp_jt_diff2 = sp*(jt-${month_thr})^2
	gen 	sp_jt_diff3 = sp*(jt-${month_thr})^3
	gen 	sp_jt_diff4 = sp*(jt-${month_thr})^4
	// interaction of month-worked and extended-benefit
	gen 	eb_mw_diff  = eb*(mw-${month_thr})
	gen 	eb_mw_diff2 = eb*(mw-${month_thr})^2
	gen 	eb_mw_diff3 = eb*(mw-${month_thr})^3	
	gen 	eb_mw_diff4 = eb*(mw-${month_thr})^4
	* covariates to controls
	gen 	age2       = age^2
	gen 	log_wage0  = log(wage0)
	gen 	log_wage02 = log_wage0^2
	gen 	end_month  = month(end)
	gen 	end_year   = year(end)
	// experience is up to the job just lost, tenure is the experience from the job just lost
	gen 	tot_exper  = (experience+tenure)/365
	gen 	tot_exper2 = tot_exper^2
	gen 	last_blue  = last_etyp==2
	gen 	last_nonedur_dumm = last_noneduration!=0
	// for weekly hazards
	// round upward, to be "in" the week of job search 
	gen     week_nondur = ceil((noneduration)/7)
	// there is a mass here at ne_start==15887
	gen 	censored_1  = ne_start==15887
	// end date for next employment spell
	gen 	censored_2  = (ne_start+ne_duration)>=15887
	// upper limit at 140 weeks
	gen 	censored_yrs_2 = inrange(noneduration,${none_emp_bound},.)
	gen 	censored_yrs_5 = inrange(ne_duration,5*365,.)
	// number of fires in each month-year for each firm
	bys benr end_year end_month: gen fired_num = _N
}



