ssc install outreg2

/* HOMEWORK III*/

/* Q1: Redbook Survey */
import delimited "C:\Users\Taha\Desktop\Assignments Spring 2019\Econometrics\TableF17-2.csv"
label var yrb "Constructed measure of time spent in extramarital affairs"
label var v1 "Rating of the marriage"
label var v2 "Age in years aggregated"
label var v3 "Number of years married"
label var v5 "Religiosity" 
label var v6 "Education"
label var v7 "Occupation" /* codes details */
label var v8 "Husband's occupation" /* codes details */

gen A = 0
replace A = 1 if yrb > 0
gen Children = 0
replace Children = 1 if v4 > 0

rename v1 Marriage_rating
rename v2 Age
rename v3 Years_married
rename v5 Religiosity
rename v6 Education



	/* a: build a binary choice model (probit and logit)*/

probit A i.Marriage_rating Age Years_married Children i.Religiosity Education
outreg2 using probit_logit, append tex dec(3)

margins, dydx(*) post
outreg2 using model_eff, append tex dec(3)

logit A i.Marriage_rating Age Years_married Children i.Religiosity Education
outreg2 using probit_logit, append tex dec(3)

/* Consider this shortcut: margins, dydx(_all)*/
margins, dydx(*) post
outreg2 using model_eff, append tex dec(3)


	/* b: ordered probit model */
oprobit Marriage_rating Age Years_married Children i.Religiosity Education
outreg2 using oprobit_results, append tex dec(3)

margins, dydx(*) atmeans



/* Q2: German Healthcare data */
import delimited "C:\Users\Taha\Desktop\Assignments Spring 2019\Econometrics\rwm.data.csv"

	/* Label the data */
label var id "person - identification number"
label var female "sex"
label var year "calendar year of the observation"
label var age "age in years"
label var hsat "health satisfaction"

label var handdum "handicapped"
label var handper "degree of handicap"
label var hhninc "household nominal monthly net income in German marks / 1000"
label var hhkids "children under age 16 in the household"
label var educ "years of schooling"

label var married "married"
label var haupts "highest schooling degree is Hauptschul degree"
label var reals "highest schooling degree is Realschul degree"
label var fachhs "highest schooling degree is Polytechnical degree"
label var abitur "highest schooling degree is Abitur"

label var univ "highest schooling degree is university degree"
label var working "employed"
label var bluec "blue collar employee"
label var whitec "white collar employee"
label var self "self employed"

label var beamt "civil servant"
label var docvis "number of doctor visits in last three months"
label var hospvis "number of hospital visits in last calendar year"
label var public "insured in public health insurance"
label var addon "insured by add-on insurance"

	/* a: Fitting a Poisson model */

sort hsat
drop in 10671/10710

poisson hospvis age female handdum hsat hhninc educ public
outreg2 using p2_result, append tex dec(4)

/* Marginal effect */
margins, dydx(_all) post 
outreg2 using mar_eff, append tex dec(4)

	/* b: Using OLS model */

/* maybe add age^2*/
regress hospvis age female handdum hsat hhninc educ public, vce(robust)
outreg2 using p2_result, append tex dec(4)

/* Marginal effect */
margins, dydx(_all) post
outreg2 using mar_eff, append tex dec(4)

	/* c: Test for overdispersion*/
nbreg hospvis age female handdum hsat hhninc educ public
outreg2 using nbregress, append tex dec(4)
