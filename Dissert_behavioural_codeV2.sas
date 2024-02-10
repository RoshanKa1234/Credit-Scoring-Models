proc import 
		datafile='/home/u63249191/Dissertation project/Data/sample.xlsx' 
		out=sam1 dbms=xlsx;
run;

/* ----------------------- EDA --------------------------------- */

/* Removing Duplicates*/
proc sort data=sam1 out=nodup_emptable nodupkey 
		dupout=duplicate_table;
	by _all_;
run;

/* Missing Values*/
ods graphics on;
ods noproctitle;
title "Missing Values";

proc means data=nodup_emptable n nmiss missing;
	var snapshotdt key term app_score beh_score opendt_mth opendt_year woff_mth 
woff_year woff_amount gross_income;
class status;
run; 

proc means data=nodup_emptable n nmiss missing;
	class capbal;
run;

proc means data=nodup_emptable n nmiss missing;
	class overdue;
run;

proc means data=nodup_emptable n nmiss missing;
	class Employmnt_Status;
run;

proc means data=nodup_emptable n nmiss missing;
	class gross_income;
run;

proc means data=nodup_emptable n nmiss missing;
	class age_range;
run;

proc means data=nodup_emptable n nmiss missing;
	class loan;
run;

proc means data=nodup_emptable n nmiss missing;
	class category;
run;

proc means data=nodup_emptable n nmiss missing;
	class woff_amount;
run;

proc print data=nodup_emptable (obs=5);
run;

/* Summary Statistics*/
ods graphics on;
ods noproctitle;
title "Summary Statistics";

proc means data=nodup_emptable mean median std min max n;
	var snapshotdt term app_score beh_score opendt_mth opendt_year woff_mth 
woff_year woff_amount;
run;
title;

/* Observing Unique values*/
Title1 "Observing Unique values";

proc freq data=nodup_emptable;
	table status Employmnt_Status overdue capbal gross_income age_range loan category;
	label status="Number of Defaults" Employmnt_Status="Distribution of Employmnt_Status" 
		overdue="Distribution of overdue" capbal="Distribution of Account Balance" 
		gross_income="Distribution of Gross_Income" 
		age_range="Distribution of Age Range"
		loan="Distribution of loan" category="Distribution of Delienquency Period";
run;

Title;

/*  Outliers in Numerical Values */
ods graphics / reset width=5.4in height=3.8in imagemap;

%macro var_boxplot(data=, var=);
	proc sgplot data=&data;
		vbox &var / whiskerextent=1.5 outlierattrs=(symbol=CircleFilled size=10);
		yaxis grid;
		ods output outlier=extremes;
	run;

%mend;

%var_boxplot(data=nodup_emptable, var=term);
%var_boxplot(data=nodup_emptable, var=app_score);
%var_boxplot(data=nodup_emptable, var=beh_score);

/*  Count of snapshot for each key*/
proc sort data=nodup_emptable;
	by snapshotdt key;
run;

/* Look for some pattern in bad records */
data bads;
set nodup_emptable;
if status = 'B' then output;
run;

/* ----------------------- Data Transformation --------------------------------- */

/* Converting Category variable into numeric format */
/* After below step num_category becomes my main delienquency stage variable */
data cate_check;
set nodup_emptable;
if category = "Current" then category_2="0";
    else if category = "6+" then category_2="7";
    else if category = "Closed" then category_2= "";
         else category_2 =category;
num_category = input(category_2,2.);
run;

/*This is the last status - This will give you the "G" or "B" status*/
proc sql;
create table key_counts as
select key, count(snapshotdt) as SnapshotCount
from cate_check
group by key;
quit;

/* They have to have atleast 6 month of observation */
data keys_with_6_or_more;
set key_counts;
where SnapshotCount >= 6;
run;

/* Merge SnapshotCount column with the cate_check for counting total number of snaps in each key */
proc sql;
create table merged_data as
select a.*, b.SnapshotCount
from cate_check as a
right join keys_with_6_or_more as b
on a.key = b.key;
quit;

/* The 6 months of observation has to be between 34 to 40 */
DATA Between_34_to_40;
   SET merged_data;
   if 34 <= snapshotdt <= 40; * 6 months of obs;
RUN;

proc sort data=Between_34_to_40  out=Last_6_obs;
by key snapshotdt;
run;

data last_obs;
set Last_6_obs;
by key;
if last.key then output;
run;

/*this is to enable to take the first and last observations per account(key)*/
proc sort data=Between_34_to_40 out=sample_sorted; 
by key snapshotdt;
run;

/*This will give all the variables when the loan was written (booked) 
 at the point of the origination --- Compare category stage between firt_obs with last_obs*/
data first_obs;
set sample_sorted;
by key;
if first.key then output;
run;

proc freq data= last_obs;
table status;
run;

/*This will give you the worst arrears status by key (account)*/
/* proc freq data=last_obs;  */
/* 	table category * status/missing nopercent nocol norow; */
/* run; */

proc sort data=cate_check  out=arrears_sorted;
by key num_category;
run;

/*This will give you the last observation per account (key_id) as it is sorted 
in order of arrears (num_category)
*/
data max_arrears;
set arrears_sorted;
by key;
if last.key then output;
run;

/*This gives 1 observation (row) per account (key)
Most of the information is from the first observation
We also have new columns taken from 2 different dateset these include
Max ever arrears And the last status. If it ever defaulted then it will capture the "B" here.*/

proc sql;
create table First_obs_with_max_arrears as
select a. *
         , b. category as last_category
         , b. status as last_status_good_or_bad
         , c. num_category as max_arrears_status
 
/*This is now my base data. 1 observation per account (key)*/
from first_obs   as a
 
left join last_obs as b
on a. key = b. key
 
left join max_arrears as c
on a. key = c. key
;
quit;

proc freq data= First_obs_with_max_arrears;
table last_status_good_or_bad;
run;

/* Sample specific for Sampling & NOT for EDA */
/* Removing all closed accounts and Loan = 0 */
DATA No_closedacc;
   SET First_obs_with_max_arrears;
   IF last_status_good_or_bad = 'C' THEN Delete;
   else if loan = 0 then delete;
RUN;

data Goo_bad_only;
set No_closedacc;
/* Set the new default status based on the last status */
IF last_status_good_or_bad = "G" Then new_default_status = 0;
else if last_status_good_or_bad = "B" then new_default_status = 1;
run;

/* Instead of default we have to say 60 days past due */
data New_def_status;
/* This data step calculates the new default status */
set Goo_bad_only (keep=snapshotdt key term loan capbal overdue payment_plan gross_income age_range employmnt_status MoB max_arrears_status new_default_status);
/* Set the new default status based on the maximum arrears status and the last status */
IF max_arrears_status > 2 THEN new_default_status = 1; * 60 days past due;
else if max_arrears_status = 2 THEN delete;
else if max_arrears_status <= 1 THEN new_default_status = 0;
Monthly_income = gross_income/12;
run;

proc freq data= New_def_status;
table new_default_status;
run;

/* ----------------------- Data visualisation --------------------------------- */
ods graphics / reset width=4.4in height=4.4in imagemap;

/*Univaraite Analysis for Numerical data */
/* Explain using the table it is actually normally distributed */
proc univariate data=nodup_emptable; * will use new variable for EDA;
	var snapshotdt key term app_score beh_score opendt_mth opendt_year woff_mth 
woff_year woff_amount;
	hist;
run;

proc freq data=nodup_emptable;
	tables status Employmnt_Status overdue capbal gross_income age_range loan category / 
		plots=(freqplot);
run;


/*Bivaraite Analysis for Numerical data -- Wonderfull Histograms */
/* Variables like category, status, dates and writeoff amount use excel (pivot)*/
proc univariate data=nodup_emptable;
	var snapshotdt key term app_score beh_score opendt_mth opendt_year woff_amount;
	class status;
	hist;
run;

ods graphics / reset width=4.4in height=5.4in imagemap;
/* status Employmnt_Status overdue capbal gross_income age_range loan category */
/* Observe table only - It shows base pattern */
/* Employmnt_Status */
proc freq data=cate_check; 
	table Employmnt_Status * category/missing nopercent nocol norow plots=(freqplot);
run;

proc freq data=New_def_status;
	tables Employmnt_Status overdue capbal gross_income age_range loan term/ 
		plots=(freqplot);
run;

proc freq data=cate_check; 
	table Employmnt_Status * status/missing nopercent nocol norow plots=(freqplot);
run;

/* overdue */
proc freq data=cate_check; 
	table overdue * category/missing nopercent nocol norow plots=(freqplot);
run;

proc freq data=cate_check; 
	table overdue * status/missing nopercent nocol norow plots=(freqplot);
run;

/* Account Balance */
proc freq data=cate_check; 
	table capbal * category/missing nopercent nocol norow plots=(freqplot);
run;

proc freq data=cate_check; 
	table capbal * status/missing nopercent nocol norow plots=(freqplot);
run;

/* Gross Income */
proc freq data=cate_check; 
	table gross_income * category/missing nopercent nocol norow plots=(freqplot);
run;

proc freq data=cate_check; 
	table gross_income * status/missing nopercent nocol norow plots=(freqplot);
run;

/* Age Range */
proc freq data=cate_check; 
	table age_range * category/missing nopercent nocol norow plots=(freqplot);
run;

proc freq data=cate_check; 
	table age_range * status/missing nopercent nocol norow plots=(freqplot);
run;

/* loan */
proc freq data=cate_check; 
	table loan * category/missing nopercent nocol norow plots=(freqplot);
run;

proc freq data=cate_check; 
	table loan * status/missing nopercent nocol norow plots=(freqplot);
run;

/* Comment On each stage of category */
proc freq data=cate_check; 
	table category * category/missing nopercent nocol norow plots=(freqplot);
run;

proc freq data=cate_check; 
	table status * status/missing nopercent nocol norow plots=(freqplot);
run;


/* Data Description for the new sample */
proc freq data=First_obs_with_max_arrears;
	table max_arrears_status last_status_good_or_bad last_category;
run;

proc freq data=First_obs_with_max_arrears;
	table max_arrears_status * last_status_good_or_bad/missing nocol nopercent norow;
run;

proc freq data=cate_check; * why should we remove closed accounts;
	table category * status/missing nopercent nocol norow;
run;

proc freq data=New_def_status;
	table loan*new_default_status;
run;

proc freq data=New_def_status;
	table new_default_status;
run;

/* proc surveyselect data = New_def_status method = srs noprint  */
/*                   out=accepts_split seed=12345 samprate=0.75 outall;  */
/* run; */
/*  */
/* data train test; */
/*    set accepts_split; */
/*    if Selected = 1 then output train; */
/*    else output test; */
/* run; */

/* You may want to exclude num_category ="2" as these are neither good nor bad, 
they are indeterminates (grey) */
/* neither black or white */

Data Behav_training_WOE;
	Set New_def_status;

Run;

/********************************************WOE Break*************************************/
TITLE;
TITLE1 "Correlation Analysis";
FOOTNOTE;
FOOTNOTE1;

PROC CORR DATA=Behav_training_WOE PLOTS=NONE PEARSON OUTP=Corr_logit VARDEF=DF;
	VAR WoE_capbal WoE_loan WoE_overdue WoE_payment_plan WoE_gross_income WoE_employmnt_status
		 WoE_term WoE_age_range;
RUN;

/*  WoE_age_range WoE_loan*/

/********************************************Correlation Analysis Break*************************************/
ODS GRAPHICS ON;
TITLE;
TITLE1 "Logistic Regression";
FOOTNOTE;
FOOTNOTE1 "scoring models";

/* WoE_capbal WoE_loan WoE_overdue WoE_payment_plan WoE_gross_income WoE_employmnt_status */
/* 		 WoE_term WoE_age_range */

PROC LOGISTIC DATA=Behav_training_WOE descending PLOTS(ONLY)=ALL;
	MODEL new_default_status = WoE_capbal WoE_loan WoE_overdue WoE_payment_plan WoE_gross_income 
		   WoE_term WoE_age_range/ OUTROC=ROC SELECTION=STEPWISE SLE=0.1 SLS=0.1
		INCLUDE=0 CORRB CTABLE PPROB=(0.9) Scale=pearson RSQUARE LACKFIT LINK=LOGIT 
		CLPARM=WALD CLODDS=WALD ALPHA=0.7;
/* 	ODS OUTPUT ParameterEstimates=Beta; */
/* 	ODS OUTPUT ASSOCIATION=STAT_TABLE; */
/* 	OUTPUT OUT=PREDICTED PREDPROB=(INDIVIDUAL) DFBETAS=_ALL_ XBETA=xbeta__Target  */
/* 		RESCHI=reschi__Target RESDEV=resdev__Target DIFCHISQ=difchisq__Target  */
/* 		DIFDEV=difdev__Target; */
RUN;

QUIT;
TITLE;
FOOTNOTE;
ODS GRAPHICS OFF;


proc export data=New_def_status 
		outfile='/home/u63249191/Practice_sas/Dataset/EDA_data.csv' dbms=csv replace;
run;
