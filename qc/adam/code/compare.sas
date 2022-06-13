/*****************************************************************************\
*        O                                                                      
*       /                                                                       
*  O---O     _  _ _  _ _  _  _|                                                 
*       \ \/(/_| (_|| | |(/_(_|                                                 
*        O                                                                      
* ____________________________________________________________________________
* Sponsor              : Domino
* Study                : H2QMCLZZT
* Program              : compare.SAS
* Purpose              : To compare all adam datasets
* ____________________________________________________________________________
* DESCRIPTION                                                    
*                                                                   
* Input files:  ADAM ADAMQC
*              
* Output files: compare.pdf, adsl.sas7bdat
*               
* Macros:       s_compare
*         
* Assumptions: 
*
* ____________________________________________________________________________
* PROGRAM HISTORY                                                         
*  08JUN2022   | Jake Tombeur   | Original version
\*****************************************************************************/

%let _STUDYID = H2QMCLZZT;

*********;
** Setup environment including libraries for this reporting effort;
%include "!DOMINO_WORKING_DIR/config/domino.sas";
*********;

%xpt2loc(filespec='/mnt/data/ADAM/adsl.xpt');

data adam.adsl;
	set adsl;
run;
/* Compare all */
%s_compare(base = ADAM._ALL_,
		   comp = ADAMQC._ALL_,
		   comprpt = '/mnt/artifacts/compare.pdf',
		   prefix =,
		   tidyup = N);

/* json file from results */
proc sql;
	create table diags1 as	
	select count(distinct base) as N_dset
	from ___LIBALLCOMP;

	create table diags2 as	
	select  count(*) as N_allissues, count(distinct base) as N_dissues 
	from ___LIBALLCOMP (where = (compstatus = 'Issues'));

	create table diags3 as	
	select count(distinct base) as N_dclean
	from ___LIBALLCOMP (where = (compstatus = 'Clean'));
quit;

data diags;
	merge diags1-diags3;
run;

proc json out = "&__WORKING_DIR/dominostats.json" pretty;
	export diags / nosastags;
run;

/* Output results dataset */
libname compare '/mnt/data/COMPARE';
data compare.summary;
	set ___LIBALLCOMP;
run;















