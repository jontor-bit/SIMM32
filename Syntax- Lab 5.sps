* Encoding: UTF-8.

DATASET ACTIVATE DataSet1.
AUTORECODE VARIABLES=sex 
  /INTO Sex_Num
  /PRINT.

RECODE Sex_Num (1=1) (2=0) (ELSE=Copy) INTO Sex_dum.
EXECUTE.

FREQUENCIES VARIABLES=sex Sex_dum
  /ORDER=ANALYSIS.

FREQUENCIES VARIABLES=pain1 pain2 pain3 pain4 Sex_dum age STAI_trait pain_cat cortisol_serum 
    mindfulness
  /STATISTICS=STDDEV VARIANCE RANGE MINIMUM MAXIMUM SEMEAN MEAN SUM
  /ORDER=ANALYSIS.

DESCRIPTIVES VARIABLES=pain1 pain2 pain3 pain4 Sex_dum age STAI_trait pain_cat cortisol_serum 
    mindfulness
  /STATISTICS=MEAN STDDEV VARIANCE RANGE MIN MAX SEMEAN.

CORRELATIONS
  /VARIABLES=pain1 pain2 pain3 pain4
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.

------------ Restructured the data from wide format to long format----------------

MIXED Pain_measurement WITH Sex_dum age STAI_trait pain_cat cortisol_serum mindfulness Time
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=Sex_dum age STAI_trait pain_cat cortisol_serum mindfulness Time | SSTYPE(3)
  /METHOD=REML
  /PRINT=SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(ID) COVTYPE(VC)
  /SAVE=PRED.

MIXED Pain_measurement WITH Sex_dum age STAI_trait pain_cat cortisol_serum mindfulness Time
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=Sex_dum age STAI_trait pain_cat cortisol_serum mindfulness Time | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB SOLUTION
  /RANDOM=INTERCEPT Time | SUBJECT(ID) COVTYPE(UN)
  /SAVE=PRED.

-----------------------Restructured the data for visualization -----------------------------------------

DATASET ACTIVATE DataSet1.
SORT CASES  BY ID.
SPLIT FILE SEPARATE BY ID.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Time MEAN(Pain_measure)[name="MEAN_Pain_measure"] 
    Obs_or_Pred MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Time=col(source(s), name("Time"), unit.category())
  DATA: MEAN_Pain_measure=col(source(s), name("MEAN_Pain_measure"))
  DATA: Obs_or_Pred=col(source(s), name("Obs_or_Pred"), unit.category())
  GUIDE: axis(dim(1), label("Time"))
  GUIDE: axis(dim(2), label("Mean Pain_measure"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Obs_or_Pred"))
  GUIDE: text.title(label("Multiple Line Mean of Pain_measure by Time by Obs_or_Pred"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: line(position(Time*MEAN_Pain_measure), color.interior(Obs_or_Pred), missing.wings())
END GPL.

----------------Reverted back to the second restructured data of models----------------

DATASET ACTIVATE DataSet1.
DESCRIPTIVES VARIABLES=Time
  /STATISTICS=MEAN STDDEV VARIANCE RANGE MIN MAX SEMEAN.

COMPUTE time_centered=Time - 2.50.
EXECUTE.

DATASET ACTIVATE DataSet1.
COMPUTE time_centered_squared=time_centered * time_centered.
EXECUTE.

DATASET ACTIVATE DataSet1.
MIXED Pain_measurement WITH Sex_dum age STAI_trait pain_cat cortisol_serum mindfulness 
    time_centered time_centered_squared
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=Sex_dum age STAI_trait pain_cat cortisol_serum mindfulness time_centered 
    time_centered_squared | SSTYPE(3)
  /METHOD=REML
  /PRINT=SOLUTION
  /RANDOM=INTERCEPT time_centered time_centered_squared | SUBJECT(ID) COVTYPE(UN)
  /SAVE=PRED.

-----------------Restructured the data for visualization for models+the quadratic term----------------

SORT CASES  BY ID.
SPLIT FILE SEPARATE BY ID.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Time 
    MEAN(Pain_measurement)[name="MEAN_Pain_measurement"] Obs_or_pred MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Time=col(source(s), name("Time"), unit.category())
  DATA: MEAN_Pain_measurement=col(source(s), name("MEAN_Pain_measurement"))
  DATA: Obs_or_pred=col(source(s), name("Obs_or_pred"), unit.category())
  GUIDE: axis(dim(1), label("Time"))
  GUIDE: axis(dim(2), label("Mean Pain_measurement"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Obs_or_pred"))
  GUIDE: text.title(label("Multiple Line Mean of Pain_measurement by Time by Obs_or_pred"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: line(position(Time*MEAN_Pain_measurement), color.interior(Obs_or_pred), missing.wings())
END GPL.

----------------Reverted back to previous dataset to conduct model diagnostics----------------

DATASET ACTIVATE DataSet1.
MIXED Pain_measurement WITH Sex_dum age STAI_trait pain_cat cortisol_serum mindfulness 
    time_centered time_centered_squared
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=Sex_dum age STAI_trait pain_cat cortisol_serum mindfulness time_centered 
    time_centered_squared | SSTYPE(3)
  /METHOD=REML
  /PRINT=SOLUTION
  /RANDOM=INTERCEPT time_centered time_centered_squared | SUBJECT(ID) COVTYPE(UN)
  /SAVE=PRED RESID.

EXAMINE VARIABLES=Pain_measurement
  /PLOT BOXPLOT STEMLEAF HISTOGRAM NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

EXAMINE VARIABLES=Pain_measurement BY ID
  /PLOT BOXPLOT STEMLEAF HISTOGRAM NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

EXAMINE VARIABLES=RESID_1 BY ID
  /PLOT BOXPLOT STEMLEAF HISTOGRAM NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Time 
    MEAN(Pain_measurement)[name="MEAN_Pain_measurement"] ID MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Time=col(source(s), name("Time"), unit.category())
  DATA: MEAN_Pain_measurement=col(source(s), name("MEAN_Pain_measurement"))
  DATA: ID=col(source(s), name("ID"), unit.category())
  GUIDE: axis(dim(1), label("Time"))
  GUIDE: axis(dim(2), label("Mean Pain_measurement"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("ID"))
  GUIDE: text.title(label("Multiple Line Mean of Pain_measurement by Time by ID"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: line(position(Time*MEAN_Pain_measurement), color.interior(ID), missing.wings())
END GPL.

EXAMINE VARIABLES=RESID_1
  /PLOT BOXPLOT STEMLEAF HISTOGRAM NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.


EXAMINE VARIABLES=RESID_1 BY ID
  /PLOT BOXPLOT STEMLEAF HISTOGRAM NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=PRED_1 RESID_1 MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: PRED_1=col(source(s), name("PRED_1"))
  DATA: RESID_1=col(source(s), name("RESID_1"))
  GUIDE: axis(dim(1), label("Predicted Values"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by Predicted Values"))
  ELEMENT: point(position(PRED_1*RESID_1))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=age RESID_1 MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: age=col(source(s), name("age"))
  DATA: RESID_1=col(source(s), name("RESID_1"))
  GUIDE: axis(dim(1), label("age"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by age"))
  ELEMENT: point(position(age*RESID_1))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=STAI_trait RESID_1 MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: STAI_trait=col(source(s), name("STAI_trait"))
  DATA: RESID_1=col(source(s), name("RESID_1"))
  GUIDE: axis(dim(1), label("STAI_trait"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by STAI_trait"))
  ELEMENT: point(position(STAI_trait*RESID_1))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=pain_cat RESID_1 MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: pain_cat=col(source(s), name("pain_cat"))
  DATA: RESID_1=col(source(s), name("RESID_1"))
  GUIDE: axis(dim(1), label("pain_cat"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by pain_cat"))
  ELEMENT: point(position(pain_cat*RESID_1))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=cortisol_serum RESID_1 MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: cortisol_serum=col(source(s), name("cortisol_serum"))
  DATA: RESID_1=col(source(s), name("RESID_1"))
  GUIDE: axis(dim(1), label("cortisol_serum"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by cortisol_serum"))
  ELEMENT: point(position(cortisol_serum*RESID_1))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=mindfulness RESID_1 MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: mindfulness=col(source(s), name("mindfulness"))
  DATA: RESID_1=col(source(s), name("RESID_1"))
  GUIDE: axis(dim(1), label("mindfulness"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by mindfulness"))
  ELEMENT: point(position(mindfulness*RESID_1))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=time_centered RESID_1 MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: time_centered=col(source(s), name("time_centered"))
  DATA: RESID_1=col(source(s), name("RESID_1"))
  GUIDE: axis(dim(1), label("time_centered"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by time_centered"))
  ELEMENT: point(position(time_centered*RESID_1))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=time_centered_squared RESID_1 MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: time_centered_squared=col(source(s), name("time_centered_squared"))
  DATA: RESID_1=col(source(s), name("RESID_1"))
  GUIDE: axis(dim(1), label("time_centered_squared"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by time_centered_squared"))
  ELEMENT: point(position(time_centered_squared*RESID_1))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=PRED_1 RESID_1 MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: PRED_1=col(source(s), name("PRED_1"))
  DATA: RESID_1=col(source(s), name("RESID_1"))
  GUIDE: axis(dim(1), label("Predicted Values"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by Predicted Values"))
  ELEMENT: point(position(PRED_1*RESID_1))
END GPL.

CORRELATIONS
  /VARIABLES=Sex_dum age STAI_trait pain_cat cortisol_serum mindfulness time_centered 
    time_centered_squared
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.

SPSSINC CREATE DUMMIES VARIABLE=ID 
ROOTNAME1=ID_dummy 
/OPTIONS ORDER=A USEVALUELABELS=YES USEML=YES OMITFIRST=NO.

COMPUTE Residual_sq=RESID_1 * RESID_1.
EXECUTE.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT Residual_sq
  /METHOD=ENTER ID_dummy_2 ID_dummy_3 ID_dummy_4 ID_dummy_5 ID_dummy_6 ID_dummy_7 ID_dummy_8 
    ID_dummy_9 ID_dummy_10 ID_dummy_11 ID_dummy_12 ID_dummy_13 ID_dummy_14 ID_dummy_15 ID_dummy_16 
    ID_dummy_17 ID_dummy_18 ID_dummy_19 ID_dummy_20.

MIXED Pain_measurement WITH Sex_dum age STAI_trait pain_cat cortisol_serum mindfulness 
    time_centered time_centered_squared
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=Sex_dum age STAI_trait pain_cat cortisol_serum mindfulness time_centered 
    time_centered_squared | SSTYPE(3)
  /METHOD=REML
  /PRINT=SOLUTION
  /RANDOM=INTERCEPT time_centered time_centered_squared | SUBJECT(ID) COVTYPE(UN) SOLUTION.

DATASET ACTIVATE DataSet2.
EXAMINE VARIABLES=VAR00001
  /PLOT BOXPLOT STEMLEAF HISTOGRAM NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.


MIXED Pain_measurement WITH Sex_dum age STAI_trait pain_cat cortisol_serum mindfulness 
    time_centered time_centered_squared
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=Sex_dum age STAI_trait pain_cat cortisol_serum mindfulness time_centered 
    time_centered_squared | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT time_centered time_centered_squared | SUBJECT(ID) COVTYPE(UN).
