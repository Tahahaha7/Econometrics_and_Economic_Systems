/* Importing the data from a sharable link */
import delimited "C:\Users\Taha\Desktop\Carbon Tax\Carbon Tax Synth.csv", clear
xtset stateid year


/* Data cleaning*/
destring gdpmillions, replace ignore(,)
gen gdpb = gdpmillions / 1000
gen gdppc = gdpmillions * 1000000 / population


/* Summaries & descriptions */
tsline co2total if stateid == 5
xtline gdppc, overlay

/* Difference in differences model */
/* test the parallel trend */

	/* with Ontario 9 [not good enough]*/
	
	/* with Alberta 6 [meduim]*/
	
	/* with Quebec 10 [not good enough]*/
	
	/* with Saskatchewan 7 [good parallel trend]*/ 
	
	/* with Nova Scotia 12 [not that good]*/

/* Synthetic Control Medthod */


drop if stateid == 1
drop if stateid == 2
drop if stateid == 3
drop if stateid == 4
drop if stateid == 7
drop if stateid == 13
drop if stateid == 14

drop if year == 1999




#delimit;

synth 	co2total
		gdpb
		netsalesofgasoline
		cpi
		population
		unemp_rate
		vehiclessalesyearlyth
		,		
		trunit(5) trperiod(2008) unitnames(state) 
		mspeperiod(2000(1)2008) resultsperiod(2000(1)2017)
		save(../data/synth/synth_ca.dta) replace fig;

	   	mat list e(V_matrix);

#delimit cr

/* Not working*/
use "../data/synth/synth_ca.dta", clear
keep _Y_treated _Y_synthetic _time
drop if _time==.
rename _time year
rename _Y_treated  treat
rename _Y_synthetic counterfact
gen gap48=treat-counterfact
sort year 
twoway (line gap48 year,lp(solid)lw(vthin)lcolor(black)), yline(0, lpattern(shortdash) lcolor(black)) xline(1993, lpattern(shortdash) lcolor(black)) xtitle("",si(medsmall)) xlabel(#10) ytitle("Gap in black male prisoner prediction error", size(medsmall)) legend(off)
save (../data/synth/synth_5.dta), replace

/* */

* Inference 1 placebo test
#delimit;
set more off;
import delimited "C:\Users\Taha\Desktop\Carbon Tax\Carbon Tax Synth.csv", clear


egen statelist 5 7 6 8 9 10 11 12 13 14;

foreach i of local statelist {;

synth 	gdppc
		netsalesofgasoline
		cpi
		,		
			trunit(5) trperiod(2008) unitnames(state) 
			mspeperiod(2000(1)2008) resultsperiod(2000(1)2017)
			keep(../data/synth/synth_ca_`i'.dta) replace;
			matrix state`i' = e(RMSPE);
			};


 foreach i of local statelist {;
 matrix rownames state`i'=`i';
 matlist state`i', names(rows);
 };


 #delimit cr
egen statelist 5 7 6 8 9 10 11 12 13 14;
 foreach i of local statelist {
 	use ../data/synth/synth_ca_`i' ,clear
 	keep _Y_treated _Y_synthetic _time
 	drop if _time==.
	rename _time year
 	rename _Y_treated  treat`i'
 	rename _Y_synthetic counterfact`i'
 	gen gap`i'=treat`i'-counterfact`i'
 	sort year 
 	save ../data/synth/synth_gap_ca`i', replace
}

use ../data/synth/synth_gap_ca.dta, clear
sort year
save ../data/synth/placebo_ca.dta, replace

foreach i of local statelist {
		
		merge year using ../data/synth/synth_gap_ca`i'
		drop _merge
		sort year
		
	save ../data/synth/placebo_bmprate.dta, replace
}


