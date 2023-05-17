PROC EXPORT DATA= CDP.EXPERTDAG_WIDE 
            OUTFILE= "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGope
dia\CDP_DAG_Julia\Stata data\ExpertDAG_wide.dta" 
            DBMS=STATA REPLACE;
RUN;


PROC EXPORT DATA= CDP.EXPERTDAG_WIDE_ORIG 
            OUTFILE= "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGope
dia\CDP_DAG_Julia\Stata data\ExpertDAG_wide_orig.dta" 
            DBMS=STATA REPLACE;
RUN;


PROC EXPORT DATA= CDP.EXPERTDAG_WIDE_SUBSET 
            OUTFILE= "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGope
dia\CDP_DAG_Julia\Stata data\ExpertDAG_wide_subset.dta" 
            DBMS=STATA REPLACE;
RUN;


PROC EXPORT DATA= CDP.EXPERTDAG_AG_NEW
            OUTFILE= "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGope
dia\CDP_DAG_Julia\Stata data\ExpertDAG_ag_new.dta" 
            DBMS=STATA REPLACE;
RUN;


PROC EXPORT DATA= CDP.EXPERTDAG_AG_ORIG
            OUTFILE= "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGope
dia\CDP_DAG_Julia\Stata data\ExpertDAG_ag_orig.dta" 
            DBMS=STATA REPLACE;
RUN;



PROC EXPORT DATA= CDP.EXPERTDAG_AG_SUBSET
            OUTFILE= "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGope
dia\CDP_DAG_Julia\Stata data\ExpertDAG_ag_subset.dta" 
            DBMS=STATA REPLACE;
RUN;



PROC EXPORT DATA= CDP.EXPERTDAG_AG_NEW2
            OUTFILE= "C:\Users\ejmurray\Dropbox\ProjectManagement\DAGope
dia\CDP_DAG_Julia\Stata data\ExpertDAG_ag_new2.dta" 
            DBMS=STATA REPLACE;
RUN;
