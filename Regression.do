/* HOMEWORK II */

/* Question 01 */
import delimited "C:\Users\Taha\Desktop\Assignments Spring 2019\Econometrics\Koop-Tobias.csv"

/* a: Extracting the first obs of the first 15 units */

egen OK = anymatch(personid), values (1 2 3 4 5 6 7 8 9 10 11 12 13 14 15)
keep if OK /* keeps the 15 first units */
drop OK

gen OK = 0
bysort personid (personid): replace OK = 1 if _n == 1
keep if OK == 1 /* keeps the first obs of each unit */
drop OK


global x1 potexper educ ability 
global x2 mothered fathered siblings
global y logwage

regress $y $x1
/* b: The regresison with x1 and x2 omitting the constant */
regress $y $x1 $x2, noconstant

/* c: Computing R squared */
	/* Omitted constant*/
quietly regress $y $x1 $x2, noconstant
di e(mss) /(e(rss)+e(mss)) 
di 1 - e(rss)/(e(rss)+e(mss))
di e(r2) /* Compare with the results from the regression table */

	/* Without omitting constant*/
quietly regress $y $x1 $x2
di e(mss) /(e(rss)+e(mss)) 
di 1 - e(rss)/(e(rss)+e(mss))
di e(r2) /* Compare with the results from the resression table */

/* d: Computing adjusted R squared */
quietly regress $y $x1 $x2
di 1 - (e(rss)/(e(N)-(6)-1))/((e(rss)+e(mss))/(e(N)-1))
di e(r2_a)

/* e: Gauss-Markov assumptions*/
quietly regress $y $x1 $x2
	/* MR1 */

	/* MR2 */

	/* MR5 */
corr $x1
corr $x1 $x2

	/* MR6 */
quietly regress $y $x1
predict r, resid
hist r, freq normal

quietly regress $y $x1 $x2
predict r2, resid
hist r2, freq normal
	

/* Question 02 */
import delimited "C:\Users\Taha\Desktop\Assignments Spring 2019\Econometrics\TableF2-2.csv"


/* a: Regression*/
gen pc_quan = (gasexp*10^9) / (gasp * pop*10^3) /* reconsider the units */
regress pc_quan income gasp pnc puc ppt pd pn ps year


/* b: Hypothesis testing --> Revise again */
test _b[pnc] == _b[puc]


/* c: Elasticities at 2004 --> Revise the elasticity for log-linear models */
* demand *
margins, eyex(gasp) at (year = 2004)

* income *
margins, eyex(income) at (year = 2004)

* cross-price*
margins, eyex(ppt) at (year = 2004)

/* d: Log regression */
gen lpc_quan = log(pc_quan)
gen lgasp = log(gasp)
gen lincome = log(income)
gen lpnc = log(pnc)
gen lpuc = log(puc)
gen lppt = log(ppt)
gen lpd = log(pd)
gen lpn = log(pn)
gen lps = log(ps)

regress lpc_quan lincome lgasp lpnc lpuc lppt lpd lpn lps year
ovtest

quietly regress pc_quan income gasp pnc puc ppt pd pn ps year
ovtest 

/* e: Multicollinearity of the price variables */
regress lpc_quan lincome lgasp lpnc lpuc lppt lpd lpn lps year
vif

quietly regress pc_quan income gasp pnc puc ppt pd pn ps year
vif 



/* f: Normalization at 2004 fro all prices */
gen gasp_nor = (gasp * 100) / gasp[52]
gen pnc_nor = (pnc * 100) / pnc[52]
gen puc_nor = (puc * 100) / puc[52]
gen ppt_nor = (ppt * 100) / ppt[52]
gen pd_nor = (pd * 100) / pd[52]
gen pn_nor = (pn * 100) / pn[52]
gen ps_nor = (ps * 100) / ps[52]

	/* Compared to regression from part a*/
regress pc_quan income gasp_nor pnc_nor puc_nor ppt_nor pd_nor pn_nor ps_nor year

	/* Compared to regression from part d*/
gen lgasp_nor = log(gasp_nor)
gen lpnc_nor = log(pnc_nor)
gen lpuc_nor = log(puc_nor)
gen lppt_nor = log(ppt_nor)
gen lpd_nor = log(pd_nor)
gen lpn_nor = log(pn_nor)
gen lps_nor = log(ps_nor)

regress lpc_quan lincome lgasp_nor lpnc_nor lpuc_nor lppt_nor lpd_nor lpn_nor lps_nor year
