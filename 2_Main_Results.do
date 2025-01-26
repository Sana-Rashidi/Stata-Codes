	
	/*--------------------------------------------------------------------------------
							Replication of Main Results
	--------------------------------------------------------------------------------*/	
	

	/*--------------------------------------------------------------------------------
								Macros
	--------------------------------------------------------------------------------*/
	* main specification
	gl main_specification 	sp   eb 							///
						    jt   jt2    jt3 	 				///
							mw   mw2    mw3     				///
						    sp_jt_diff sp_jt_diff2 sp_jt_diff3 	///
						    eb_mw_diff eb_mw_diff2 eb_mw_diff3	

	* covariates
	gl indep_vars_1 	   i.female    i.married  i.austrian  i.bluecollar age age2 ///
						   log_wage0   log_wage02 i.end_year  i.end_month  
						   
						   
	gl indep_vars_2       i.last_recall i.region     i.industry  i.last_job  last_duration     dg_size  ///
	                      last_breaks   i.education  tot_exper   tot_exper2  last_noneduration i.last_nonedur_dumm


{   // TABLE II 
	gen failure = censored_1!=1 & censored_yrs_2!=1
	stset noneduration, failure(failure==1)

	stcox ${main_specification}, nohr
	eststo tab2_col1
	stcox ${main_specification} ${indep_vars_1}, nohr
	eststo tab2_col2
	stcox ${main_specification} ${indep_vars_1} ${indep_vars_2}, nohr
	eststo tab2_col3
	stcox ${main_specification} ${indep_vars_1} if fired_num>=4, nohr
	eststo tab2_col4	
	local out_name = "Table_2"
	#d;
	esttab  tab2_col1 tab2_col2 tab2_col3 tab2_col4  
	     using ${Output_Table}/`out_name'.tex, style(tex)     
		 ${tab_fmt_1} nodep nonumbers  label  												
		 coeflabels(sp "Severance pay" eb "Extended benefits") 
		 mtitles("\shortstack{\\No\\controls\\(1)}" "\shortstack{\\Basic\\controls\\(2)}" 
		     	"\shortstack{\\Full\\controls\\(3)}" "\shortstack{\\$\geq 4$ layoffs\\by firm\\(4)}") 
		 keep(sp eb) collabels(none)
		 stats(N,fmt(%20.0g) labels("Sample Size"))
		 replace;
	#d cr 
	drop failure
	estimates drop _all
}	

{   // TABLE III
	gen in_sample = ne_start<15887
	gen wage_g = log(ne_wage0)-log(wage0) if in_sample==1
	
	reg wage_g ${main_specification}, cluster(penr)
	eststo tab3_col1
	reg wage_g ${main_specification} ${indep_vars_1} ${indep_vars_2}, cluster(penr)
	eststo tab3_col2
	
	gen failure_3 = censored_yrs_5!=1 & censored_2!=1
	gen next_dur = ne_duration
	replace next_dur = 5*365 if ne_duration>5*365
	stset next_dur , failure(failure_3==1)

	stcox ${main_specification}, nohr
	eststo tab3_col3
	stcox ${main_specification} ${indep_vars_1} ${indep_vars_2}, nohr
	eststo tab3_col4
	local out_name = "Table_3"
	#d;
	esttab  tab3_col1 tab3_col2 tab3_col3 tab3_col4   
	     using ${Output_Table}/`out_name'.tex,    style(tex)      
		 cells(b(star fmt(%6.3f)) se(par fmt(%6.3f)))		
		 stats(N,fmt(%20.0g) labels("Sample Size"))
		 coeflabels(sp "Severance pay" eb "Extended benefits") 
		 mgroups("\shortstack{\\ Dep. variable: change\\in log wage}" 
				 "\shortstack{\\ Dep. variable: duration\\of next job}", 
				 pattern(1 0 1 0) ${mgroup})
		 mtitles("\shortstack{No controls\\(1)}" "\shortstack{Full controls\\(2)}" 
				 "\shortstack{No controls\\(3)}" "\shortstack{Full controls\\(4)}") 
		 keep(sp eb)  collabels(none)
		 nodep nonumbers  label 
		 replace;
	#d cr
	drop wage_g in_sample failure_3 next_dur
	estimates drop _all
}	
	
{	// Figure II
	bys tenure_cat: gen layoff_count = _N
	bys tenure_cat: gen obs_num = _n
	#d;
	twoway (connected layoff_count tenure_cat if obs_num==1, ${connected_graph_1}),
	${sev_month_xline}
	${graph_style_1}
	ylabel(0(10000)40000)
	xtitle("Previous Job Tenure (Months)") 
	ytitle("Number of Layoffs") ;
	#d cr
	drop obs_num layoff_count 
	local out_name = "Fig_II"		
	gr export "${Output_Graph}/`out_name'.${out_fmt}", replace
}
	
{	// FIGURE IIIa
	// average number of jobs (defined as the number of continuous employment spells since the start of the data)
	gen emp_num = last_breaks
	bys tenure_cat: egen jobs_num_mean = mean(emp_num)
	bys tenure_cat: gen obs_num = _n 
	#d;
	twoway (scatter jobs_num_mean tenure_cat if obs_num==1, ${connected_graph_1})
		   (lfit 	jobs_num_mean tenure_cat if obs_num==1 & tenure>=${sev_thr}, ${fit_gr})
		   (lfit 	jobs_num_mean tenure_cat if obs_num==1 & tenure<${sev_thr},  ${fit_gr}),
	${sev_month_xline}
	${graph_style_1}
	legend(off)
	xtitle("Previous Job Tenure (Months)") 
	ytitle("Mean Number of Jobs");
	#d cr
	drop obs_num jobs_num_mean emp_num
	local out_name = "Fig_IIIa"		
	gr export "${Output_Graph}/`out_name'.${out_fmt}", replace
}				
	
{	// FIGURE IIIb
	// annual wage = monthly wage * 12
	gen annual_wage = (wage0*12)/1000
	bys tenure_cat: egen annual_wage_mean = mean(annual_wage) 
	bys tenure_cat: gen obs_num = _n if wage0!=.	
	#d;
	twoway (scatter annual_wage_mean tenure_cat if obs_num==1, ${connected_graph_1})
		   (lfit 	annual_wage_mean tenure_cat if obs_num==1 & tenure>=${sev_thr}, ${fit_gr})
		   (lfit 	annual_wage_mean tenure_cat if obs_num==1 & tenure<${sev_thr},  ${fit_gr}),
	${sev_month_xline}
	${graph_style_1}
	legend(off)
	xtitle("Previous Job Tenure (Months)") 
	ytitle("Mean Annual Wage (Euro × 1000)");
	#d cr
	drop obs_num annual_wage annual_wage_mean
	local out_name = "Fig_IIIb"		
	gr export "${Output_Graph}/`out_name'.${out_fmt}", replace
		
}	
	
{	// FIGURE V
	gen in_graph = noneduration<=${none_emp_tr}
    bys tenure_cat: egen nonduration_mean = mean(noneduration) if in_graph==1
	bys tenure_cat in_graph: gen obs_num = _n 
	gen show = in_graph==1 & obs_num==1
	
	
	#d;
	twoway (scatter nonduration_mean tenure_cat if show==1, ${connected_graph_1})
		   (qfit 	nonduration_mean tenure_cat if show==1 & tenure>=${sev_thr}, ${fit_gr})
		   (qfit 	nonduration_mean tenure_cat if show==1 & tenure<${sev_thr},  ${fit_gr}),
	${sev_month_xline}
	${graph_style_1}
	legend(off)
	xtitle("Previous Job Tenure (Months)") 
	ytitle("Mean Nonemployment Duration (days)");
	#d cr
	drop in_graph obs_num show nonduration_mean
	local out_name = "Fig_V"		
	gr export "${Output_Graph}/`out_name'.${out_fmt}", replace
					
}	
	
{	// FIGURE VI
	gen 	failure = censored_yrs_2!=1 & censored_1!=1
	gen 	n_d_censored = noneduration
	replace n_d_censored = 140 if noneduration>=140
	
	stset   n_d_censored, failure(failure==1)
	
	stcox ib35.tenure_cat eb mw mw2 mw3 eb_mw_diff eb_mw_diff2 eb_mw_diff3

	// predict hazard_fig6_eq_13
	gen jt_coeffs = .
	forvalues i=13(1)58{
		replace jt_coeffs = e(b)[1,"`i'.tenure_cat"] if tenure_cat==`i'
	}
	
	bys tenure_cat: gen obs_num = _n 
	#d;
	twoway (scatter jt_coeffs tenure_cat if obs_num==1, ${connected_graph_1})
		   (qfit 	jt_coeffs tenure_cat if obs_num==1 & tenure>=${sev_thr}, ${fit_gr}) 
		   (qfit 	jt_coeffs tenure_cat if obs_num==1 & tenure<${sev_thr},  ${fit_gr}), 
	${sev_month_xline}
	${graph_style_1}
	legend(off)
	xtitle("Previous Job Tenure (Months)") 
	ytitle("Average Daily Job Finding Hazard in First 20 Weeks"); 
	#d cr
	drop obs_num jt_coeffs failure n_d_censored
	local out_name = "Fig_VI"		
	gr export "${Output_Graph}/`out_name'.${out_fmt}", replace
			
}	
		   
{	// Figure VII
	gen 	restr_sample = dempl5-tenure>=${month_length}
	gen 	sev_receiver = 1 if inrange(tenure_cat,33,35) & restr_sample==1
	replace sev_receiver = 0 if inrange(tenure_cat,36,38) & restr_sample==1
	gen     failure = censored_1!=1
    stset week_nondur if(restr_sample==1), failure(failure==1)
	sts gen haz_sev_1 = h if sev_receiv==1
	sts gen haz_sev_0 = h if sev_receiv==0
	* graph
	bys week_nondur sev_receiver: gen obs_num = _n if restr_sample!=0
	gen show = restr_sample==1 & obs_num==1	
	#d;
	twoway (connected haz_sev_1 week_nondur if show==1 & week_nondur<=30, ${connected_graph_1})
		   (connected haz_sev_0 week_nondur if show==1 & week_nondur<=30, ${connected_graph_2}),
	xline(20.5)
	${graph_style_1}
	xlabel(0(10)30)
	legend(on order(2 "No Severance" 1 "Severance") col(2) ${leg_pos})
	xtitle("Weeks Elapsed since Job Loss") 
	ytitle("Weekly Job Finding Hazard");
	#d cr
	drop obs_num haz_sev_1 haz_sev_0 restr_sample sev_receiver failure show
	local out_name = "Fig_VII"		
	gr export "${Output_Graph}/`out_name'.${out_fmt}", replace
			
}

{	// Figure VIIIa
	gen in_graph = noneduration<=${none_emp_tr}
    bys month_emp_cat: egen nonduration_mean = mean(noneduration) if in_graph==1
	bys month_emp_cat in_graph: gen obs_num = _n 
	gen show = in_graph==1 & obs_num==1
	#d;
	twoway (scatter nonduration_mean month_emp_cat if show==1, ${connected_graph_1})
		   (qfit 	nonduration_mean month_emp_cat if show==1 & dempl5>=${sev_thr}, ${fit_gr})
		   (qfit 	nonduration_mean month_emp_cat if show==1 & dempl5<${sev_thr},  ${fit_gr}),
	${sev_month_xline}
	${graph_style_1}
	legend(off)
	xtitle("Months Employed in Past Five Years") 
	ytitle("Mean Nonemployment Duration (days)"); 
	#d cr
	drop in_graph obs_num show nonduration_mean
	local out_name = "Fig_VIIIa"		
	gr export "${Output_Graph}/`out_name'.${out_fmt}", replace		
}
		
{	// Figure VIIIb
	gen failure = censored_1!=1 & censored_yrs_2!=1
    stset noneduration, failure(failure==1)
	// base group is tenure of 35 months
	stcox sp ib35.month_emp_cat jt jt2 jt3 sp_jt_diff sp_jt_diff2 sp_jt_diff3
	//predict hazard_fig6_eq_13
	gen mw_coeffs = .
	forvalues i=15(1)57{
		replace mw_coeffs = e(b)[1,"`i'.month_emp_cat"] if month_emp_cat==`i'
	}
	bys month_emp_cat: gen obs_num = _n 
	#d;
	twoway (scatter mw_coeffs month_emp_cat if obs_num==1, ${connected_graph_1})
		   (qfit 	mw_coeffs month_emp_cat if obs_num==1 & dempl5>=${sev_thr}, ${fit_gr})
		   (qfit 	mw_coeffs month_emp_cat if obs_num==1 & dempl5<${sev_thr},  ${fit_gr}),
	${sev_month_xline}
	${graph_style_1}
	legend(off)
	xtitle("Months Employed in Past Five Years") 
	ytitle("Average Daily Job Finding Hazard in First 20 Weeks"); 
	#d cr
	drop obs_num mw_coeffs failure
	local out_name = "Fig_VIIIb"		
	gr export "${Output_Graph}/`out_name'.${out_fmt}", replace	
}

{	// Figure IX
	* hazard
	gen 	restr_sample = dempl5-tenure>=${month_length}
	gen 	UI_receiver = 1 if inrange(month_emp_cat,33,35) & restr_sample==1
	replace UI_receiver = 0 if inrange(month_emp_cat,36,38) & restr_sample==1
	gen failure = censored_1!=1 
    stset week_nondur, failure(failure==1)
	sts gen haz_sev_1 = h if UI_receiver==1
	sts gen haz_sev_0 = h if UI_receiver==0
	* graph
	bys week_nondur UI_receiver restr_sample: gen obs_num = _n 
	gen show = restr_sample==1 & obs_num==1
	#d;
	twoway (connected haz_sev_1 week_nondur if show==1 & week_nondur<=30, ${connected_graph_1})
		   (connected haz_sev_0 week_nondur if show==1 & week_nondur<=30, ${connected_graph_2}),
	xline(20.5)
	xlabel(0(10)30)
	//legend(col(2) ${leg_pos})
	legend(on order(2 "20 Weeks of UI" 1 "30 Weeks of UI") col(2) ${leg_pos})
	xtitle("Weeks Elapsed since Job Loss")  
	ytitle("Weekly Job Finding Hazard");

	#d cr
	drop obs_num haz_sev_1 haz_sev_0 restr_sample UI_receiver show failure  
	local out_name = "Fig_IX"		
	gr export "${Output_Graph}/`out_name'.${out_fmt}", replace
		
}

{	// Figure Xa
	gen in_graph = indnempl==1
	bys tenure_cat: egen wage_g = mean(log(ne_wage0)-log(wage0)) if in_graph==1
	bys tenure_cat in_graph: gen obs_num = _n 
	gen show = in_graph==1 & obs_num==1
	#d;
	twoway (scatter wage_g tenure_cat if show==1, ${connected_graph_1})
		   (lfit 	wage_g tenure_cat if show==1 & tenure>=${sev_thr}, ${fit_gr})
		   (lfit 	wage_g tenure_cat if show==1 & tenure<${sev_thr},  ${fit_gr}),
	${sev_month_xline}
	${graph_style_1}
	legend(off)
	xtitle("Previous Job Tenure (Months)") 
	ytitle("Wage Growth"); 
	#d cr
	drop in_graph show obs_num wage_g	
	local out_name = "Fig_Xa"		
	gr export "${Output_Graph}/`out_name'.${out_fmt}", replace
}

{	// FIGURE Xb
	gen in_graph = indnempl==1
	gen ne_dur_cat = int(ne_duration/${month_length})
	gen failure = censored_2!=1
	stset ne_duration if(in_graph==1) , failure(failure==1)
	stcox ib35.tenure_cat 
	//predict hazard_fig6_eq_13
	gen jt_coeffs = .
	forvalues i=13(1)58{
		replace jt_coeffs = e(b)[1,"`i'.tenure_cat"] if tenure_cat==`i'
	}
	bys tenure_cat: gen obs_num = _n 
	#d;
	twoway (scatter jt_coeffs tenure_cat if obs_num==1, ${connected_graph_1})
		   (qfit 	jt_coeffs tenure_cat if obs_num==1 & tenure>=${sev_thr}, ${fit_gr})
		   (qfit 	jt_coeffs tenure_cat if obs_num==1 & tenure<${sev_thr},  ${fit_gr}),
	${sev_month_xline}
	${graph_style_1}
	legend(off)
	xtitle("Months Employed in Past Five Years") 
	ytitle("Average Daily Job Finding Hazard in First 20 Weeks"); 
	#d cr
	drop obs_num jt_coeffs in_graph ne_dur_cat failure
	local out_name = "Fig_Xb"		
	gr export "${Output_Graph}/`out_name'.${out_fmt}", replace
}




