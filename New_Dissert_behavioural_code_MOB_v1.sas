/* proc import  */
/* 		datafile='/home/u63249191/Dissertation project/Data/sample.xlsx'  */
/* 		out=sam1 dbms=xlsx; */
/* run; */

/* proc import  */
/* 		datafile='/home/u63249191/Dissertation project/Data/Data_behav/Data_Prep_MoB.xlsx'  */
/* 		out=sam1 dbms=xlsx; */
/* run; */

/* ----------------------- EDA --------------------------------- */
/* monthly income ratio */
/* debttoincome ratio */
/* Delinquency using SAS */
data sam1;
set MYDATA.Final_MoB_data;
run;

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

proc print data=nodup_emptable (obs=5);
run;

/* Summary Statistics*/
ods graphics on;
ods noproctitle;
title "Summary Statistics";

proc means data=nodup_emptable mean median std min max n;
	var snapshotdt term app_score beh_score  woff_mth 
woff_year woff_amount;
run;
title;

ods graphics / reset width=5.4in height=3.8in imagemap;
/* Observing Unique values*/
Title1 "Observing Unique values";

proc freq data=nodup_emptable;
	table status Employmnt_Status overdue capbal gross_income age_range loan category payment_plan;
	label status="Number of Defaults" Employmnt_Status="Distribution of Employmnt_Status" 
		overdue="Distribution of overdue" capbal="Distribution of Account Balance" 
		gross_income="Distribution of Gross_Income" 
		age_range="Distribution of Age Range"
		loan="Distribution of loan" category="Distribution of Delienquency Period" 
		payment_plan= "Distribution of Payment Plan";
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
set Goo_bad_only (keep=snapshotdt key term loan capbal overdue gross_income payment_plan age_range employmnt_status MoB max_arrears_status new_default_status);
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

ods graphics / reset width=4.4in height=3.8 in imagemap;
/* status Employmnt_Status overdue capbal gross_income age_range loan category */
/*Univaraite Analysis for Numerical data */

/* Explain using the table it is actually normally distributed */
proc univariate data=nodup_emptable; * will use new variable for EDA;
	var snapshotdt key term app_score beh_score opendt_mth opendt_year woff_mth 
woff_year woff_amount;
	hist;
run;

/*Univaraite Analysis for Categorical data */
proc freq data=nodup_emptable;
	tables status Employmnt_Status overdue capbal gross_income age_range loan category / 
		plots=(freqplot);
run;

/* Only for EDA  */
DATA No_cloe_EDA;
   SET nodup_emptable;
   IF status = 'C' THEN Delete;
RUN;

/*Bivaraite Analysis for Numerical data */
proc univariate data=No_cloe_EDA;
	var snapshotdt term app_score woff_amount;
	class status;
	hist;
run;


/*Bivaraite Analysis for Categorical data */

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
/* proc freq data=cate_check;  */
/* 	table category * category/missing nopercent nocol norow plots=(freqplot); */
/* run; */
/*  */
/* proc freq data=cate_check;  */
/* 	table status * status/missing nopercent nocol norow plots=(freqplot); */
/* run; */


/* Data Description for the new sample */
proc freq data=First_obs_with_max_arrears;
	table max_arrears_status last_status_good_or_bad last_category;
run;

/* proc freq data=First_obs_with_max_arrears; */
/* 	table max_arrears_status * last_status_good_or_bad/missing nocol nopercent norow; */
/* run; */
/*  */
/* proc freq data=cate_check; * why should we remove closed accounts; */
/* 	table category * status/missing nopercent nocol norow; */
/* run; */
/*  */
/* proc freq data=New_def_status; */
/* 	table loan*new_default_status; */
/* run; */

proc freq data=New_def_status;
	table new_default_status;
run;


/*  */
/* data train test; */
/*    set accepts_split; */
/*    if Selected = 1 then output train; */
/*    else output test; */
/* run; */

/* You may want to exclude num_category ="2" as these are neither good nor bad, 
they are indeterminates (grey) */
/* neither black or white */


/*  Capbal taken from old one*/
/* IF capbal IN ('1-500') then WoE_capbal=0.363889277644613;Else */
/* IF capbal IN ('501-1000') then WoE_capbal=0.363889277644613;Else */
/* IF capbal IN ('1001-1500') then WoE_capbal=0.363889277644613;Else */
/* IF capbal IN ('1501-2000') then WoE_capbal=-0.23571038846107;Else */
/* IF capbal IN ('2001-2500') then WoE_capbal=-0.23571038846107;Else */
/* IF capbal IN ('>2501') then WoE_capbal=-0.23571038846107; */
/*  */
/* IF loan IN ('1-250') then WoE_loan =0.690196080028514;Else */
/* IF loan IN ('251-500') then WoE_loan =0.690196080028514;Else */
/* IF loan IN ('501-750') then WoE_loan =0.0757207139381183;Else */
/* IF loan IN ('751-1000') then WoE_loan =0.0757207139381183;Else */
/* IF loan IN ('>1000') then WoE_loan =-0.116338564846382; */
/*  */
/* IF payment_plan IN ('1 to 25') then WoE_payment_plan=-0.0561457157068355;Else */
/* IF payment_plan IN ('26-50') then WoE_payment_plan=-0.0561457157068355;Else */
/* IF payment_plan IN ('51-75') then WoE_payment_plan=-0.0561457157068355;Else */
/* IF payment_plan IN ('76-100') then WoE_payment_plan=-0.0561457157068355;Else */
/* IF payment_plan IN ('>100') then WoE_payment_plan=1.79239168949825; */
/*  */
/* IF gross_income IN ('2500') then WoE_gross_income=-0.421852166077449;Else */
/* IF gross_income IN ('6250') then WoE_gross_income=-0.421852166077449;Else */
/* IF gross_income IN ('8750') then WoE_gross_income=-0.421852166077449;Else */
/* IF gross_income IN ('14000') then WoE_gross_income=-0.421852166077449;Else */
/* IF gross_income IN ('22500') then WoE_gross_income=-0.244676279530792;Else */
/* IF gross_income IN ('27500') then WoE_gross_income=-0.244676279530792;Else */
/* IF gross_income IN ('35000') then WoE_gross_income=0.91315131299984;Else */
/* IF gross_income IN ('45000') then WoE_gross_income=0.91315131299984;Else */
/* IF gross_income IN ('60000') then WoE_gross_income=0.91315131299984;Else */
/* IF gross_income IN ('85000') then WoE_gross_income=0.91315131299984; */
/*  */
/* IF age_range IN ('18 to 20') then WoE_age_range=-0.66343167895703;Else */
/* IF age_range IN ('21 to 23') then WoE_age_range=-0.66343167895703;Else */
/* IF age_range IN ('24 to 30') then WoE_age_range=0.103575684992774;Else */
/* IF age_range IN ('31 to 35') then WoE_age_range=0.103575684992774;Else */
/* IF age_range IN ('36 to 40') then WoE_age_range=0.103575684992774;Else */
/* IF age_range IN ('41 to 50') then WoE_age_range=0.103575684992774;Else */
/* IF age_range IN ('51 to 60') then WoE_age_range=0.103575684992774;Else */
/* IF age_range IN ('61 to 70') then WoE_age_range=0.103575684992774;Else */
/* IF age_range IN ('71 to 80') then WoE_age_range=0.103575684992774;Else */
/* IF age_range IN ('Over 100') then WoE_age_range=0.103575684992774; */


/* Model 2 */
/* IF overdue IN ('0') then WoE_overdue=0.246723125047417;Else */
/* IF overdue IN ('1 to 25') then WoE_overdue=0.246723125047417;Else */
/* IF overdue IN ('26-50') then WoE_overdue=-2.34044411484012;Else */
/* IF overdue IN ('>100') then WoE_overdue=-2.34044411484012; */
/*  */
/* IF employmnt_status IN ('Full Time') then WoE_employmnt_status=0.0118721146275662;Else */
/* IF employmnt_status IN ('Homemaker') then WoE_employmnt_status=0.0118721146275662;Else */
/* IF employmnt_status IN ('Other') then WoE_employmnt_status=0.0118721146275662;Else */
/* IF employmnt_status IN ('Retired') then WoE_employmnt_status=-0.0804063370769311;Else */
/* IF employmnt_status IN ('Self Employed') then WoE_employmnt_status=-0.0804063370769311; */
/*  */
/* IF term <31 then WoE_term =0.382851337877814;Else */
/* IF term >=31 then WoE_term=-0.0581259678032846; */

/* Using New variables & New dataset */

Data Behav_training_WOE;
	Set New_def_status;
	
IF term <23 then WoE_term =-0.311014216570582;Else
IF term >=23 AND term  <46 then WoE_term =-0.0722482336531702;Else
IF term >=46 then WoE_term =0.157802473343372;

IF Monthly_income <1824.25006 then WoE_Monthly_income=-0.449683006372723;Else
IF Monthly_income >=1824.25006 AND Monthly_income  <2758.234721 then WoE_Monthly_income =-0.228097698893358;Else
IF Monthly_income >=2758.234721 then WoE_Monthly_income =0.717519207239748;

IF MoB <10 then WoE_MoB=0.605920412141201;Else
IF MoB >=10 AND MoB  <29 then WoE_MoB =0.0631413371825595;Else
IF MoB >=29 then WoE_MoB =-0.299316800219861;


IF capbal IN ('1-500') then WoE_capbal=0.0210523192606008;Else
IF capbal IN ('501-1000') then WoE_capbal=0.0210523192606008;Else
IF capbal IN ('1001-1500') then WoE_capbal=0.0210523192606008;Else
IF capbal IN ('1501-2000') then WoE_capbal=-0.0279086034274675;Else
IF capbal IN ('2001-2500') then WoE_capbal=-0.0279086034274675;Else
IF capbal IN ('>2501') then WoE_capbal=-0.0279086034274675;

IF loan IN ('1-250') then WoE_loan =-0.0500182975093999;Else
IF loan IN ('251-500') then WoE_loan =-0.0500182975093999;Else
IF loan IN ('501-750') then WoE_loan =0.255272505103306;Else
IF loan IN ('751-1000') then WoE_loan =0.255272505103306;Else
IF loan IN ('>1000') then WoE_loan =0.255272505103306;

IF overdue IN ('0') then WoE_overdue=0.301029995663981;Else
IF overdue IN ('1 to 25') then WoE_overdue=-2.4345689040342;Else
IF overdue IN ('26-50') then WoE_overdue=-2.4345689040342;Else
IF overdue IN ('>100') then WoE_overdue=-2.4345689040342;

IF payment_plan IN ('1 to 25') then WoE_payment_plan=-0.0656133698483868;Else
IF payment_plan IN ('26-50') then WoE_payment_plan=-0.0656133698483868;Else
IF payment_plan IN ('51-75') then WoE_payment_plan=-0.0656133698483868;Else
IF payment_plan IN ('76-100') then WoE_payment_plan=-0.0656133698483868;Else
IF payment_plan IN ('>100') then WoE_payment_plan=1.88649072517248;

IF employmnt_status IN ('Full Time') then WoE_employmnt_status=0.0045381236533386;Else
IF employmnt_status IN ('Homemaker') then WoE_employmnt_status=0.0045381236533386;Else
IF employmnt_status IN ('Other') then WoE_employmnt_status=0.0045381236533386;Else
IF employmnt_status IN ('Retired') then WoE_employmnt_status=-0.0336831132025726;Else
IF employmnt_status IN ('Self Employed') then WoE_employmnt_status=-0.0336831132025726;

IF age_range IN ('18 to 20') then WoE_age_range=-0.629118224061998;Else
IF age_range IN ('21 to 23') then WoE_age_range=-0.629118224061998;Else
IF age_range IN ('24 to 30') then WoE_age_range=0.110367490458345;Else
IF age_range IN ('31 to 35') then WoE_age_range=0.110367490458345;Else
IF age_range IN ('36 to 40') then WoE_age_range=0.110367490458345;Else
IF age_range IN ('41 to 50') then WoE_age_range=0.110367490458345;Else
IF age_range IN ('51 to 60') then WoE_age_range=0.110367490458345;Else
IF age_range IN ('61 to 70') then WoE_age_range=0.110367490458345;Else
IF age_range IN ('71 to 80') then WoE_age_range=0.110367490458345;Else
IF age_range IN ('Over 100') then WoE_age_range=0.110367490458345;

Run;

/********************************************WOE Break*************************************/
TITLE;
TITLE1 "Correlation Analysis";
FOOTNOTE;
FOOTNOTE1;

PROC CORR DATA=Behav_training_WOE PLOTS=NONE PEARSON OUTP=Corr_logit VARDEF=DF;
	VAR WoE_capbal WoE_loan WoE_payment_plan WoE_Monthly_income WoE_age_range WoE_overdue WoE_employmnt_status WoE_MoB
		  ;
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
/*  */
PROC LOGISTIC DATA=Behav_training_WOE descending PLOTS(ONLY)=ALL;
	MODEL new_default_status = WoE_capbal WoE_loan WoE_payment_plan WoE_gross_income 
	WoE_age_range  WoE_overdue WoE_employmnt_status WoE_term
	/ OUTROC=ROC SELECTION=stepwise SLE=0.1 SLS=0.1
		INCLUDE=0 CORRB CTABLE PPROB=(0.5) Scale=pearson RSQUARE LACKFIT LINK=LOGIT 
		CLPARM=WALD CLODDS=WALD ALPHA=0.1 ;
RUN;

PROC LOGISTIC DATA=Behav_training_WOE descending PLOTS(ONLY)=ALL;
	MODEL new_default_status = WoE_age_range WoE_gross_income WoE_capbal WoE_loan WoE_term
	/ OUTROC=ROC SELECTION=backward SLE=0.1 SLS=0.1
		INCLUDE=0 CORRB CTABLE PPROB=(0.5) Scale=pearson RSQUARE LACKFIT LINK=LOGIT 
		CLPARM=WALD CLODDS=WALD ALPHA=0.1 ;
RUN;

PROC LOGISTIC DATA=Behav_training_WOE descending PLOTS(ONLY)=ALL;
	MODEL new_default_status = WoE_age_range WoE_gross_income WoE_loan 
	/ OUTROC=ROC SELECTION=backward SLE=0.1 SLS=0.1
		INCLUDE=0 CORRB CTABLE PPROB=(0.5) Scale=pearson RSQUARE LACKFIT LINK=LOGIT 
		CLPARM=WALD CLODDS=WALD ALPHA=0.05 ;
RUN;


PROC LOGISTIC DATA=Behav_training_WOE descending PLOTS(ONLY)=ALL;
	MODEL new_default_status = WoE_capbal WoE_loan WoE_payment_plan 
	WoE_age_range WoE_employmnt_status WoE_term WoE_MoB WoE_Monthly_income
	/ OUTROC=ROC SELECTION=backward SLE=0.1 SLS=0.1
		INCLUDE=0 CORRB CTABLE PPROB=(0.5) Scale=pearson RSQUARE LACKFIT LINK=LOGIT 
		CLPARM=WALD CLODDS=WALD ALPHA=0.1 ;
RUN;

QUIT;
TITLE;
FOOTNOTE;
ODS GRAPHICS OFF;


proc export data=New_def_status 
		outfile='/home/u63249191/Practice_sas/Dataset/EDA_data.csv' dbms=csv replace;
run;
