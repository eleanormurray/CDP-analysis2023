PROC EXPORT DATA= CDP.EXPERTDAG_WIDE 
            OUTFILE= "<path>\Stata data\ExpertDAG_wide.dta" 
            DBMS=STATA REPLACE;
RUN;


PROC EXPORT DATA= CDP.EXPERTDAG_WIDE_ORIG 
            OUTFILE= "<path>\Stata data\ExpertDAG_wide_orig.dta" 
            DBMS=STATA REPLACE;
RUN;


PROC EXPORT DATA= CDP.EXPERTDAG_WIDE_SUBSET 
            OUTFILE= "<path>\Stata data\ExpertDAG_wide_subset.dta" 
            DBMS=STATA REPLACE;
RUN;


PROC EXPORT DATA= CDP.EXPERTDAG_AG_NEW
            OUTFILE= "<path>\Stata data\ExpertDAG_ag_new.dta" 
            DBMS=STATA REPLACE;
RUN;


PROC EXPORT DATA= CDP.EXPERTDAG_AG_ORIG
            OUTFILE= "<path>\ExpertDAG_ag_orig.dta" 
            DBMS=STATA REPLACE;
RUN;



PROC EXPORT DATA= CDP.EXPERTDAG_AG_SUBSET
            OUTFILE= "<path>\ExpertDAG_ag_subset.dta" 
            DBMS=STATA REPLACE;
RUN;



PROC EXPORT DATA= CDP.EXPERTDAG_AG_NEW2
            OUTFILE= "<path>\ExpertDAG_ag_new2.dta" 
            DBMS=STATA REPLACE;
RUN;
