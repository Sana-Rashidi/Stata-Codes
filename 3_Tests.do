	
	/*--------------------------------------------------------------------------------
							Further Tests for Regression Discontinuity
	--------------------------------------------------------------------------------*/		

	/*--------------------------------------------------------------------------------
	*				checking for discontinuity in baseline covariates
	--------------------------------------------------------------------------------*/

{	// firm size, baseline covariate 
	// firms by size
	local firm_size_1 "Firm Size 5"
	local firm_size_2 "Firm Size 15"
	local firm_size_3 "Firm Size 50"
	local firm_size_4 "Firm Size 200"
	local firm_size_5 "Firm Size 500"
	local firm_size_6 "Firm Size 1000"
	forvalues i=1(1)6{
		bys tenure_cat: egen firm_size_`i'_count = total(firms`i')
		bys tenure_cat: gen obs_num = _n 
		#d;
		twoway (connected firm_size_`i'_count tenure_cat if obs_num==1, ${connected_graph_3}),
		${sev_month_xline}
		${graph_style_1}
		legend(off)
		xtitle("Previous Job Tenure (Months)") 
		ytitle("Number of Layoffs")
		subtitle("`firm_size_`i''")
		name(Firm_Size_`i', replace);
		#d cr
		drop obs_num firm_size_`i'_count
		local out_name = "Firm_size_`i'"		
		gr export "${Output_Graph}/`out_name'.${out_fmt}", replace
	}
	#d;
	gr combine Firm_Size_1 Firm_Size_2 Firm_Size_3 
			   Firm_Size_4 Firm_Size_5 Firm_Size_6,
			   col(3) ${graph_color} ${graph_size_1};
	#d cr
	local out_name = "Firm_size"		
	gr export "${Output_Graph}/`out_name'.${out_fmt}", replace	
}		

{	// industry, baseline covariate 
	// industry
	local industry_1 "Agriculture and Mining"
	local industry_2 "Manufacture"
	local industry_3 "Sales"
	local industry_4 "Hotel"
	local industry_5 "Transport"
	local industry_6 "Service"
	
	// generate variable for each industry
	tab industry, gen(industry)
	forvalues i=1(1)6{
		bys tenure_cat: egen industry_`i'_count = total(industry`i')
		bys tenure_cat: gen obs_num = _n 
		#d;
		twoway (connected industry_`i'_count tenure_cat if obs_num==1, ${connected_graph_3}),
		${sev_month_xline}
		${graph_style_1}
		legend(off)
		xtitle("Previous Job Tenure (Months)") 
		ytitle("Number of Layoffs")
		subtitle("`industry_`i''")
		name(industry_`i', replace);
		#d cr
		drop obs_num industry`i' industry_`i'_count 
		local out_name = "Industry_`i'"		
		gr export "${Output_Graph}/`out_name'.${out_fmt}", replace
	}
	#d;
	gr combine industry_1 industry_2 industry_3 
			   industry_4 industry_5 industry_6,
			   col(3) ${graph_color} ${graph_size_1};
	#d cr
	local out_name = "Industry"		
	gr export "${Output_Graph}/`out_name'.${out_fmt}", replace	
}		

{	// education, baseline covariate 
	local education_1 "Compulsory or Less"
	local education_2 "Apprenticeship"
	local education_3 "Middle School"
	local education_4 "High School"
	local education_5 "Vocational High School"
	local education_6 "University"
	
	// generate variable for each education
	tab education, gen(education)
	forvalues i=1(1)6{
		bys tenure_cat: egen education`i'_count = total(education`i')
		bys tenure_cat: gen obs_num = _n 
		#d;
		twoway (connected education`i'_count tenure_cat if obs_num==1, ${connected_graph_3}),
		${sev_month_xline}
		${graph_style_1}
		legend(off)
		xtitle("Previous Job Tenure (Months)") 
		ytitle("Number of Layoffs")
		subtitle("`education_`i''")
		name(education_`i', replace);
		#d cr
		drop obs_num education`i' education`i'_count
		local out_name = "Educ_`i'"		
		gr export "${Output_Graph}/`out_name'.${out_fmt}", replace
	}
	#d;
	gr combine education_1 education_2 education_3 
			   education_4 education_5 education_6,
			   col(3) ${graph_color} ${graph_size_1};	   
	#d cr		   
	local out_name = "Education"		
	gr export "${Output_Graph}/`out_name'.${out_fmt}", replace
		
}		

{ 	// previous nonemployment, baseline covariate 
	bys tenure_cat: egen last_noneduration_mean = mean(last_noneduration) if last_noneduration<=${none_emp_tr}
	bys tenure_cat: gen obs_num = _n if last_noneduration<=${none_emp_tr}
	#d;
	twoway (scatter last_noneduration_mean tenure_cat if obs_num==1, ${connected_graph_1})
		   (qfit 	last_noneduration_mean tenure_cat if last_noneduration<=${none_emp_tr} & tenure>${sev_thr}, ${fit_gr})
		   (qfit 	last_noneduration_mean tenure_cat if last_noneduration<=${none_emp_tr} & tenure<${sev_thr}, ${fit_gr}),
	${sev_month_xline} 
	${graph_style_1}
	legend(off)
	xtitle("Previous Job Tenure (Months)") 
	ytitle("Mean of Last Nonemployment Duration (days)");
	#d cr
	drop obs_num last_noneduration_mean
	local out_name = "Last_Nondur"		
	gr export "${Output_Graph}/`out_name'.${out_fmt}", replace
}

{ 	// age, baseline covariate 
	bys tenure_cat: egen age_mean = mean(age)
	gen tenure_m = tenure/31
	bys tenure_cat: gen obs_num = _n 
	#d;
	twoway (scatter age_mean tenure_cat if obs_num==1, ${connected_graph_1})
		   (qfit 	age tenure_m if tenure>${sev_thr}, ${fit_gr})
		   (qfit 	age tenure_m if tenure<${sev_thr}, ${fit_gr}),
	${sev_month_xline} 
	${graph_style_1}
	legend(off)
	xtitle("Previous Job Tenure (Months)") 
	ytitle("Mean Age (years)");
	#d cr
	drop obs_num tenure_m age_mean
	local out_name = "Age"		
	gr export "${Output_Graph}/`out_name'.${out_fmt}", replace
}
	
{ 	// previous tenure, baseline covariate 
	bys tenure_cat: egen last_tenure_mean = mean(last_duration)
	bys tenure_cat: gen obs_num = _n 
	#d;
	twoway (scatter last_tenure_mean tenure_cat if obs_num==1, ${connected_graph_1})
		   (qfit 	last_tenure_mean tenure_cat if tenure>${sev_thr}, ${fit_gr})
		   (qfit 	last_tenure_mean tenure_cat if tenure<${sev_thr}, ${fit_gr}),
	${sev_month_xline} 
	${graph_style_1}
	legend(off)
	xtitle("Previous Job Tenure (Months)") 
	ytitle("Mean of Last Job Tenure (days)");
	#d cr
	drop obs_num last_tenure_mean
	local out_name = "Last_Tenure"		
	gr export "${Output_Graph}/`out_name'.${out_fmt}", replace
}

{	// data visualization and bin sizes
	// days for bin widths
	local days_bin = "20 15 10"
	local size_20 = "Bin Size 20"
	local size_15 = "Bin Size 15"	
	local size_5 = "Bin Size 5"		
	gen tot_obs = _N
	foreach size of local days_bin{
		gen	    tenure_bin  = int((tenure-1095)/`size')      if tenure>=${sev_thr}
		replace tenure_bin  = int((tenure-1095+1)/`size')-1  if tenure<${sev_thr}
		bys tenure_bin: gen layoff_count = _N
		bys tenure_bin: gen obs_num = _n
		replace layoff_count =  layoff_count/tot_obs
		gen show = obs_num==1 & tenure_cat>=13 & tenure_cat<=58
		//local xline = ${sev_thr}-`size'/2
		#d;
		twoway (connected layoff_count  tenure if show==1, ${connected_graph_1})
			   (qfit      layoff_count  tenure if show==1 & tenure>${sev_thr}, ${fit_gr})
		       (qfit      layoff_count  tenure if show==1 & tenure<${sev_thr}, ${fit_gr}),
		${sev_day_xline}
		xlabel(365 "12" 547 "18" 730 "24" 912 "30" 1095 "36" 1277 "42" 1460 "48" 1642 "54" 1825 "60")
		xtitle("Previous Job Tenure (Months)") 
		ytitle("Density of Layoffs") 
		subtitle("`size_`i''") 
		legend(off)
		name(Bin_Size_`size', replace);
		#d cr
		drop tenure_bin obs_num layoff_count show
		local out_name = "Bin_Size_`size'"	
		gr export "${Output_Graph}/`out_name'.${out_fmt}", replace
	}
	drop tot_obs
	#d;
	gr combine Bin_Size_20 Bin_Size_15 Bin_Size_10, 
			   col(1) ${graph_color} ${graph_size_2};  
	#d cr		   
	local out_name = "Bin_Size"		
	gr export "${Output_Graph}/`out_name'.${out_fmt}", replace	
}


	/*--------------------------------------------------------------------------------
						different bandwidth and polynomials
	--------------------------------------------------------------------------------*/

{	// different polynomials
	gl poly1              jt   mw   sp_jt_diff   eb_mw_diff
	gl poly2 	${poly1}  jt2  mw2  sp_jt_diff2  eb_mw_diff2
	gl poly3 	${poly2}  jt3  mw3  sp_jt_diff3  eb_mw_diff3
	gl poly4 	${poly3}  jt4  mw4  sp_jt_diff4  eb_mw_diff4 

	gen failure = censored_1!=1
	stset noneduration, failure(failure==1)

	local count = 1
	local polynomial "1 2 3 4"
	local bandwidth "20 16 12 8 4"
	foreach degree of local polynomial{
	    eststo clear
		foreach width of local bandwidth{
			scalar p_`degree'_`width' = r(p)
			stcox sp eb ${poly`degree'} if abs(jt-${month_thr})<=`width'
			eststo hz_`degree'_`width'
		}
		#d;
		esttab  hz_`degree'_* using ${Output_Table}/Panel`count'.tex, style(tex)
		${tab_fmt_1}
		obslast unstack onecell nogap label collabels(none) nonumber legend
		keep(sp eb) coeflabels(sp "Severance pay" eb "Extended benefits")
		mtitles("Bandwidth 20" "Bandwidth 16" "Bandwidth 12" "Bandwidth 8" "Bandwidth 4")
		stats(N,fmt(%20.0g) labels("Sample Size"))
		replace;
		#d cr
		local ++count
	}
	
	include "https://raw.githubusercontent.com/steveofconnell/PanelCombine/master/PanelCombine.do"
	cd ${Output_Table}	
	local out_name = "Hazard_Poly_Width"	
	#d;
	panelcombine, use(Panel1.tex Panel2.tex Panel3.tex Panel4.tex) 
	columncount(1) 
	paneltitles( "Polynomial 1"  "Polynomial 2" "Polynomial 3" "Polynomial 4") 
	save("`out_name'.tex") cleanup;
	#d cr
	drop failure
}

{	// With MSE, using new package
	local methods "uniform triangular"
	forvalues p=1(1)3{
	    eststo clear
	    foreach method of local methods{
			* mserd
			rdrobust noneduration tenure, c(1095) kernel(`method') p(`p') bwselect(mserd) masspoints(off)
			eststo `method'
			local bw_mserd = e(h_l)
			* cerrd
			rdrobust noneduration tenure, c(1095) kernel(`method') p(`p') bwselect(cerrd) masspoints(off)
			local bw_cerrd = e(h_l)	
			* mse 			
			altrdbwselect noneduration tenure, c(1095) kernel(`method') p(`p') bwselect(CCT)
			local bw_cct = r(h_CCT)
			local bw_b = r(b_CCT)
			rdmse noneduration tenure, c(1095) kernel(`method') p(`p') b(`bw_b') h(`bw_cct') 
			local mse= r(amse_cl)	
						
			estimates restore `method'
			mat define m_`method'_`p'=(`bw_mserd', `bw_cerrd', `bw_cct', `mse')
			mat colnames m_`method'_`p'= mserd cerrd CCT MSE
			estadd matrix m_`method'_`p'=m_`method'_`p'
			eststo `method'_`p'		
		}
		#d;
		esttab uniform_`p' triangular_`p'  using Panel`p'.tex , style(tex) 
		cells("m_uniform_`p'(pattern(1 0) fmt(2)) m_triangular_`p'(pattern(0 1) fmt(2))") 
		collabels("Uniform" "Triangular")
		${table_format_2} replace;
		#d cr
	}
	include "https://raw.githubusercontent.com/steveofconnell/PanelCombine/master/PanelCombine.do"
	cd ${Output_Table}
	#d;
	panelcombine, use(Panel1.tex Panel2.tex Panel3.tex) columncount(1) 
	paneltitles( "P 1" "P 2" "P 3" "P 4")
	save("MSE.tex") cleanup;
	#d cr
}

{	// Placebo Test, other covariates at the month_thr, no rdrobust
	gl polynom1  sp           jt    sp_jt_diff
	gl polynom2  ${polynom1}  jt2   sp_jt_diff2
	gl polynom3  ${polynom2}  jt3   sp_jt_diff3
	gl polynom4  ${polynom3}  jt4   sp_jt_diff4 

    local count = 1
	local polynomial ="1 2 3"
	local controls = "i.married i.austrian i.last_recall i.region i.industry i.education last_breaks tot_exper tot_exper2"
	eststo clear
	gen l_n = last_noneduration
	gen l_d = last_duration
	gen wage_g_previous = log(wage0)-log(wage1)
	foreach covar of varlist age female bluecollar dg_size wage_g_previous l_n l_d{
		foreach p of local polynomial{
			reg `covar' ${polynom`p'}
			eststo `covar'_`p'
			reg `covar' ${polynom`p'} `controls'
			eststo `covar'_`p'_full
			}
		#d;
		esttab  `covar'_1 `covar'_1_full  `covar'_2 `covar'_2_full  `covar'_3 `covar'_3_full
		using ${Output_Table}/Panel`count'.tex, style(tex)
		mgroups("Polynomial 1" "Polynomial 2" "Polynomial 3", 
				pattern(1 0 1 0 1 0) ${mgroup})
		mtitles("No control" "With control"
				"No control" "With control"
				"No control" "With control") 
		keep(sp) coeflabels(sp  " ")
		${table_format_1} replace;
		#d cr
		local ++count
		}
	drop l_n l_d wage_g_previous
	include "https://raw.githubusercontent.com/steveofconnell/PanelCombine/master/PanelCombine.do"
	#d;
	panelcombine, use(Panel1.tex  Panel2.tex Panel3.tex Panel4.tex Panel5.tex Panel6.tex Panel7.tex) columncount(1) 
	paneltitles( "Age"  "Gender" "Blue Collar" "Firm Size" "Last Wage Growth" "Last Nonemployment" "Last Tenure")
	save("Placebo_Covar.tex") cleanup;
	#d cr
}

