/* mock stand-in for the original: proc import datafile='.../sample.xlsx' out=sam1 dbms=xlsx; */
data sam1;
  infile datalines dsd truncover;
  input snapshotdt key term app_score beh_score opendt_mth opendt_year woff_mth woff_year woff_amount gross_income status :$1. capbal overdue Employmnt_Status :$12. age_range :$6. loan category :$8. payment_plan MoB;
datalines;
34,1001,36,513,417,2,2019,,,0,20500,B,300,50,Self-employed,26-35,5400,5,1,24
35,1001,36,513,417,2,2019,,,0,20500,B,300,50,Self-employed,26-35,5400,6+,1,25
36,1001,36,513,417,2,2019,,,0,20500,C,300,50,Self-employed,26-35,5400,Closed,1,26
37,1001,36,513,417,2,2019,,,0,20500,G,300,50,Self-employed,26-35,5400,Current,1,27
38,1001,36,513,417,2,2019,,,0,20500,G,300,50,Self-employed,26-35,5400,1,1,28
39,1001,36,513,417,2,2019,,,0,20500,G,300,50,Self-employed,26-35,5400,2,1,29
40,1001,36,513,417,2,2019,,,0,20500,B,300,50,Self-employed,26-35,5400,3,1,30
34,1002,48,526,434,3,2020,,,0,23000,G,600,100,Retired,36-45,5800,1,0,24
35,1002,48,526,434,3,2020,,,0,23000,G,600,100,Retired,36-45,5800,Current,0,25
36,1002,48,526,434,3,2020,,,0,23000,G,600,100,Retired,36-45,5800,1,0,26
37,1002,48,526,434,3,2020,,,0,23000,G,600,100,Retired,36-45,5800,Current,0,27
38,1002,48,526,434,3,2020,,,0,23000,G,600,100,Retired,36-45,5800,1,0,28
39,1002,48,526,434,3,2020,,,0,23000,G,600,100,Retired,36-45,5800,Current,0,29
40,1002,48,526,434,3,2020,,,0,23000,G,600,100,Retired,36-45,5800,1,0,30
34,1003,24,539,451,4,2021,,,0,25500,G,900,0,Unemployed,46-60,6200,Current,1,24
35,1003,24,539,451,4,2021,,,0,25500,G,900,0,Unemployed,46-60,6200,Current,1,25
36,1003,24,539,451,4,2021,,,0,25500,G,900,0,Unemployed,46-60,6200,2,1,26
37,1003,24,539,451,4,2021,,,0,25500,G,900,0,Unemployed,46-60,6200,Current,1,27
38,1003,24,539,451,4,2021,,,0,25500,G,900,0,Unemployed,46-60,6200,Current,1,28
39,1003,24,539,451,4,2021,,,0,25500,G,900,0,Unemployed,46-60,6200,2,1,29
40,1003,24,539,451,4,2021,,,0,25500,G,900,0,Unemployed,46-60,6200,Current,1,30
34,1004,36,552,468,5,2018,,,0,28000,G,1200,50,Employed,60+,0,1,0,24
35,1004,36,552,468,5,2018,,,0,28000,G,1200,50,Employed,60+,0,Current,0,25
36,1004,36,552,468,5,2018,,,0,28000,G,1200,50,Employed,60+,0,1,0,26
37,1004,36,552,468,5,2018,,,0,28000,G,1200,50,Employed,60+,0,Current,0,27
38,1004,36,552,468,5,2018,,,0,28000,G,1200,50,Employed,60+,0,1,0,28
39,1004,36,552,468,5,2018,,,0,28000,G,1200,50,Employed,60+,0,Current,0,29
40,1004,36,552,468,5,2018,,,0,28000,G,1200,50,Employed,60+,0,1,0,30
34,1005,48,565,485,6,2019,,,0,30500,G,1500,100,Self-employed,18-25,7000,1,1,24
35,1005,48,565,485,6,2019,,,0,30500,G,1500,100,Self-employed,18-25,7000,2,1,25
36,1005,48,565,485,6,2019,,,0,30500,B,1500,100,Self-employed,18-25,7000,3,1,26
37,1005,48,565,485,6,2019,,,0,30500,B,1500,100,Self-employed,18-25,7000,4,1,27
38,1005,48,565,485,6,2019,,,0,30500,B,1500,100,Self-employed,18-25,7000,6+,1,28
39,1005,48,565,485,6,2019,,,0,30500,B,1500,100,Self-employed,18-25,7000,6+,1,29
40,1005,48,565,485,6,2019,,,0,30500,B,1500,100,Self-employed,18-25,7000,6+,1,30
34,1006,24,578,502,7,2020,,,0,33000,G,1800,0,Retired,26-35,7400,1,0,24
35,1006,24,578,502,7,2020,,,0,33000,G,1800,0,Retired,26-35,7400,Current,0,25
36,1006,24,578,502,7,2020,,,0,33000,G,1800,0,Retired,26-35,7400,1,0,26
37,1006,24,578,502,7,2020,,,0,33000,G,1800,0,Retired,26-35,7400,Current,0,27
38,1006,24,578,502,7,2020,,,0,33000,G,1800,0,Retired,26-35,7400,1,0,28
39,1006,24,578,502,7,2020,,,0,33000,G,1800,0,Retired,26-35,7400,Current,0,29
40,1006,24,578,502,7,2020,,,0,33000,G,1800,0,Retired,26-35,7400,1,0,30
34,1007,36,591,519,8,2021,,,0,35500,B,2100,50,Unemployed,36-45,7800,3,1,24
35,1007,36,591,519,8,2021,,,0,35500,B,2100,50,Unemployed,36-45,7800,6+,1,25
36,1007,36,591,519,8,2021,,,0,35500,G,2100,50,Unemployed,36-45,7800,1,1,26
37,1007,36,591,519,8,2021,,,0,35500,B,2100,50,Unemployed,36-45,7800,4,1,27
38,1007,36,591,519,8,2021,,,0,35500,C,2100,50,Unemployed,36-45,7800,Closed,1,28
39,1007,36,591,519,8,2021,,,0,35500,G,2100,50,Unemployed,36-45,7800,2,1,29
40,1007,36,591,519,8,2021,,,0,35500,B,2100,50,Unemployed,36-45,7800,5,1,30
34,1008,48,604,536,9,2018,,,0,38000,G,2400,100,Employed,46-60,0,1,0,24
35,1008,48,604,536,9,2018,,,0,38000,G,2400,100,Employed,46-60,0,Current,0,25
36,1008,48,604,536,9,2018,,,0,38000,G,2400,100,Employed,46-60,0,1,0,26
37,1008,48,604,536,9,2018,,,0,38000,G,2400,100,Employed,46-60,0,Current,0,27
38,1008,48,604,536,9,2018,,,0,38000,G,2400,100,Employed,46-60,0,1,0,28
39,1008,48,604,536,9,2018,,,0,38000,G,2400,100,Employed,46-60,0,Current,0,29
40,1008,48,604,536,9,2018,,,0,38000,G,2400,100,Employed,46-60,0,1,0,30
34,1009,24,617,553,10,2019,,,0,40500,G,2700,0,Self-employed,60+,8600,Current,1,24
35,1009,24,617,553,10,2019,,,0,40500,G,2700,0,Self-employed,60+,8600,Current,1,25
36,1009,24,617,553,10,2019,,,0,40500,G,2700,0,Self-employed,60+,8600,2,1,26
37,1009,24,617,553,10,2019,,,0,40500,G,2700,0,Self-employed,60+,8600,Current,1,27
38,1009,24,617,553,10,2019,,,0,40500,G,2700,0,Self-employed,60+,8600,Current,1,28
39,1009,24,617,553,10,2019,,,0,40500,G,2700,0,Self-employed,60+,8600,2,1,29
40,1009,24,617,553,10,2019,,,0,40500,G,2700,0,Self-employed,60+,8600,Current,1,30
34,1010,36,630,570,11,2020,,,0,43000,G,3000,50,Retired,18-25,9000,1,0,24
35,1010,36,630,570,11,2020,,,0,43000,G,3000,50,Retired,18-25,9000,Current,0,25
36,1010,36,630,570,11,2020,,,0,43000,G,3000,50,Retired,18-25,9000,1,0,26
37,1010,36,630,570,11,2020,,,0,43000,G,3000,50,Retired,18-25,9000,Current,0,27
38,1010,36,630,570,11,2020,,,0,43000,G,3000,50,Retired,18-25,9000,1,0,28
39,1010,36,630,570,11,2020,,,0,43000,G,3000,50,Retired,18-25,9000,Current,0,29
40,1010,36,630,570,11,2020,,,0,43000,G,3000,50,Retired,18-25,9000,1,0,30
34,1011,48,643,587,12,2021,,,0,45500,C,3300,100,Unemployed,26-35,9400,Closed,1,24
35,1011,48,643,587,12,2021,,,0,45500,G,3300,100,Unemployed,26-35,9400,2,1,25
36,1011,48,643,587,12,2021,,,0,45500,B,3300,100,Unemployed,26-35,9400,5,1,26
37,1011,48,643,587,12,2021,,,0,45500,G,3300,100,Unemployed,26-35,9400,Current,1,27
38,1011,48,643,587,12,2021,,,0,45500,B,3300,100,Unemployed,26-35,9400,3,1,28
39,1011,48,643,587,12,2021,,,0,45500,B,3300,100,Unemployed,26-35,9400,6+,1,29
40,1011,48,643,587,12,2021,,,0,45500,G,3300,100,Unemployed,26-35,9400,1,1,30
34,1012,24,656,604,1,2018,,,0,48000,B,3600,0,Employed,36-45,0,4,0,24
35,1012,24,656,604,1,2018,,,0,48000,B,3600,0,Employed,36-45,0,4,0,25
36,1012,24,656,604,1,2018,,,0,48000,B,3600,0,Employed,36-45,0,4,0,26
37,1012,24,656,604,1,2018,,,0,48000,B,3600,0,Employed,36-45,0,4,0,27
38,1012,24,656,604,1,2018,,,0,48000,B,3600,0,Employed,36-45,0,4,0,28
39,1012,24,656,604,1,2018,,,0,48000,B,3600,0,Employed,36-45,0,4,0,29
40,1012,24,656,604,1,2018,,,0,48000,C,3600,0,Employed,36-45,0,Closed,0,30
;
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

