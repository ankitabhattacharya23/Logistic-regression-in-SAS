libname log_reg '/folders/myfolders/BI/Logistic';

/*IMPORTING DATA*/
proc import datafile='/folders/myfolders/BI/Logistic/Dataset.csv'
out=log_reg.logistic dbms=csv replace;
getnames=yes; guessingrows=300;
run;

proc contents data=log_reg.cluster;run;

/* MISSING VALUE IMPUTAION */
proc means data=log_reg.logistic nmiss min p5 p95 max maxdec=2;
run;

/*outlier capping*/
data log_reg .cluster;
set log_reg.logistic;
if REVENUE>137.29 then REVENUE=137.29;			
if MOU>1585.5 then MOU=1585.5;			
if RECCHRGE>87.49 then RECCHRGE=87.49;			
if DIRECTAS>4.21 then DIRECTAS=4.21;			
if OVERAGE>187.25 then OVERAGE=187.25;			
if ROAM>4.77 then ROAM=4.77;			
if CHANGEM>327.5 then CHANGEM=327.5;			
if CHANGER>40.62 then CHANGER=40.62;			
if DROPVCE>21.33 then DROPVCE=21.33;			
if BLCKVCE>16.67 then BLCKVCE=16.67;			
if UNANSVCE>93.67 then UNANSVCE=93.67;			
if CUSTCARE>8 then CUSTCARE=8;			
if THREEWAY>1.33 then THREEWAY=1.33;			
if MOUREC>445.64 then MOUREC=445.64;			
if OUTCALLS>92.67 then OUTCALLS=92.67;			
if INCALLS>35.67 then INCALLS=35.67;			
if PEAKVCE>297 then PEAKVCE=297;			
if OPEAKVCE>236.67 then OPEAKVCE=236.67;			
if DROPBLK>33.67 then DROPBLK=33.67;			
if CALLFWDV>0 then CALLFWDV=0;			
if CALLWAIT>8.67 then CALLWAIT=8.67;			
if MONTHS>39 then MONTHS=39;			
if UNIQSUBS>3 then UNIQSUBS=3;			
if ACTVSUBS>3 then ACTVSUBS=3;			
if PHONES>5 then PHONES=5;			
if MODELS>4 then MODELS=4;			
if EQPDAYS>886 then EQPDAYS=886;			
if AGE1>62 then AGE1=62;			
if AGE2>62 then AGE2=62;			
if OCCSTUD>0 then OCCSTUD=0;			
if OCCHMKR>0 then OCCHMKR=0;				
if RETCALLS>0 then RETCALLS=0;			
if RETACCPT>0 then RETACCPT=0;			
if REFER>0 then REFER=0;			
if INCOME>9 then INCOME=9;						
if CREDITAD>1 then CREDITAD=1;			
if SETPRC>149.99 then SETPRC=149.99;
if REVENUE<17.15 then REVENUE=17.15;
if MOU<23.25 then MOU=23.25;
if RECCHRGE<10 then RECCHRGE=10;
if DIRECTAS<0 then DIRECTAS=0;
if OVERAGE<0 then OVERAGE=0;
if ROAM<0 then ROAM=0;
if CHANGEM<-320.5 then CHANGEM=-320.5;
if CHANGER<-45.26 then CHANGER=-45.26;
if MONTHS<11 then MONTHS=11;
if ACTVSUBS<1 then ACTVSUBS=1;
if EQPDAYS<35 then EQPDAYS=35;			
run;

/* missing replacement*/
data log_reg.cluster;
set log_reg.cluster;
if age1=  . then age1=31;
/* if age1 = 0 then age1 =31; */
if age2= . then age2=21;
if REVENUE= .  then REVENUE=58;
if MOU=. then MOU=525;
if RECCHRGE= . then RECCHRGE=48;
if DIRECTAS= . then DIRECTAS=0.89;
if OVERAGE= . then OVERAGE=40;
if ROAM= . then ROAM=1.22;
run;

proc means data= log_reg.cluster n nmiss max;
run;

data log_reg.cluster;
set log_reg.cluster;
if roam not eq 0 then
lnROAM = log(ROAM);
else lnROAM = log(ROAM + 1);
lnCUSTCARE = sqrt(CUSTCARE);
if PEAKVCE not eq 0 then
lnPEAKVCE = log(PEAKVCE);
else lnPEAKVCE = log(PEAKVCE + 1);
if UNANSVCE not eq 0 then
lnUNANSVCE = log(UNANSVCE);
else lnUNANSVCE = log(UNANSVCE + 1);
lnmonths = log(months);
lneqpdays = exp(log(log(eqpdays)));
lnRevenue = log(revenue);
lnmou = log(mou);
lnRECCHRGE = log(RECCHRGE);
lnOVERAGE = sqrt(OVERAGE);
run;

proc freq data=log_reg.cluster;
table CHILDREN
CREDITA
CREDITAA
CREDITB
CREDITC
CREDITDE
CREDITGY
CREDITZ
PRIZMRUR
PRIZMUB
PRIZMTWN
REFURB
WEBCAP
TRUCK
RV
OCCPROF
OCCCLER
OCCCRFT
OCCSTUD
OCCHMKR
OCCRET
OCCSELF
OWNRENT
MARRYUN
MARRYYES
MARRYNO
MAILORD
MAILRES
MAILFLAG
TRAVEL
PCOWN
CREDITCD
NEWCELLY
NEWCELLN
INCMISS
MCYCLE
SETPRCM / chisq;
run;

/*logistic regression*/
proc logistic data = log_reg.cluster descending; /*by default it models for zero (ascending option)*/ 
model churn = TRAVEL
PCOWN
NEWCELLN
CHILDREN
RV
TRUCK
MARRYYES
CREDITA
CREDITAA
CREDITB
CREDITC
CREDITDE
PRIZMUB
PRIZMTWN
REFURB
WEBCAP
OCCPROF
OWNRENT
MARRYUN
MARRYNO
MAILORD
MAILRES
CREDITCD
NEWCELLY
INCMISS
SETPRCM

lneqpdays
lnRevenue
lnmou
lnRECCHRGE
lnOVERAGE
DIRECTAS
ROAM
CHANGEM
CHANGER
UNANSVCE
CUSTCARE
THREEWAY
OUTCALLS
INCALLS
PEAKVCE
OPEAKVCE
DROPBLK
CALLFWDV
CALLWAIT
MONTHS
ACTVSUBS
PHONES
AGE1
AGE2
REFER
INCOME
CREDITAD / selection=stepwise slentry=0.1 slstay=0.1 stb lackfit;
output out= log_reg.tmp;
run;

/*dividing data into development and validation*/ 
data log_reg.dev log_reg.val;
set log_reg.cluster;
if churndep = . then output log_reg.val;
else output log_reg.dev;
run;

/* ############################################################################## */

proc logistic data = log_reg.dev /*by default it models for zero (ascending option)*/ 
outest=log_reg.model;
model Churn = NEWCELLN
CHILDREN
TRUCK
CREDITA
CREDITAA
CREDITB
CREDITC
CREDITDE
PRIZMUB
REFURB
WEBCAP
MARRYUN
MAILRES
CREDITCD
SETPRCM
lneqpdays
lnRevenue
lnmou
lnRECCHRGE
lnOVERAGE
ROAM
CHANGEM
CHANGER
UNANSVCE
CUSTCARE
THREEWAY
INCALLS
PEAKVCE
OPEAKVCE
DROPBLK
MONTHS
PHONES
AGE1
CREDITAD / selection=stepwise stb lackfit;
output out= log_reg.dev1 p=newpred;
run;

/*To create deciles on development sample*/

proc sort data=log_reg.dev1;
by descending newpred;
run;

proc rank data =log_reg.dev1 groups=10 out=log_reg.dev2 descending;
var newpred;
ranks probrank;
run;

proc sql;
select probrank, count(probrank) as cnt, sum(Churn) as chrun_cnt,(count(probrank)-sum(CHURN)) as Non_default_Count,
min(newpred) as p_min, max(newpred) as p_max from log_reg.dev2 group by probrank order by probrank desc;
quit;


/* APPLYING THE MODEL ON VALIDATION */

data log_reg.val;
set log_reg.val;
Odds_ratio=EXP(1.2948+(CHILDREN*-0.1067)+
(CREDITC*0.1845)+
(CREDITDE*0.3891)+
(PRIZMUB*0.0502)+
(REFURB*-0.2291)+
(WEBCAP*0.275)+
(MAILRES*0.1312)+
(SETPRCM*0.1393)+
(lneqpdays*-0.4237)+
(lnRevenue*-0.249)+
(lnmou*0.2085)+
(lnRECCHRGE*0.1671)+
(lnOVERAGE*-0.0347)+
(ROAM*-0.0348)+
(CHANGEM*0.00083)+
(CHANGER*-0.00177)+
(UNANSVCE*-0.00138)+
(THREEWAY*0.1192)+
(INCALLS*0.0042)+
(PEAKVCE*0.00102)+
(DROPBLK*-0.0117)+
(MONTHS*0.0204)+
(PHONES*-0.106)+
(AGE1*0.00456)+
(CREDITAD*0.1339));
newpred=(Odds_ratio/(1+Odds_ratio));
run;

/*To create deciles on development sample*/
proc sort data=log_reg.val;
by descending newpred;
run;

proc rank data=log_reg.val group =10 out= log_reg.val1 descending;
var newpred;
ranks probrank;
run;

proc sql;
select probrank, count(probrank) as cnt, sum(churn) as churn2_cnt,(count(probrank)-sum(CHURN)) as Non_default_Count, 
min(newpred) as p_min,
max(newpred) as p_max from log_reg.val1 group by probrank order by probrank desc;
quit;

data log_reg.dev2;
set log_reg.dev1;
if newpred>0.49 then default_dec3=1; else default_dec3=0;
if newpred>0.52 then default_dec4=1; else default_dec4=0;
run;

proc freq data=log_reg.dev2;
table churn*default_dec3 churn*default_dec4/ nopercent nocol norow;
run;