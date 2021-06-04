* Encoding: UTF-8.

DATASET ACTIVATE DataSet1.
FREQUENCIES VARIABLES=sex
  /ORDER=ANALYSIS.

AUTORECODE VARIABLES=sex 
  /INTO Sex_num
  /PRINT.

RECODE Sex_num (1=1) (2=0) (3=0) (ELSE=Copy) INTO Sex_dum.
EXECUTE.

FREQUENCIES VARIABLES=sex Sex_num Sex_dum
  /ORDER=ANALYSIS.

FREQUENCIES VARIABLES=pain age STAI_trait pain_cat cortisol_serum mindfulness hospital
  /ORDER=ANALYSIS.

AUTORECODE VARIABLES=hospital 
  /INTO Hospital_numeric
  /PRINT.

RECODE Hospital_numeric (1=1) (2=10) (3=2) (4=3) (5=4) (6=5) (7=6) (8=7) (9=8) (10=9) (ELSE=Copy) 
    INTO Hospital_variable.
EXECUTE.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=pain_cat pain Hospital_variable MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO SUBGROUP=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: pain_cat=col(source(s), name("pain_cat"))
  DATA: pain=col(source(s), name("pain"))
  DATA: Hospital_variable=col(source(s), name("Hospital_variable"), unit.category())
  GUIDE: axis(dim(1), label("pain_cat"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Hospital_variable"))
  GUIDE: text.title(label("Grouped Scatter of pain by pain_cat by Hospital_variable"))
  ELEMENT: point(position(pain_cat*pain), color.interior(Hospital_variable))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=pain_cat pain Hospital_variable MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO SUBGROUP=YES.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: pain_cat=col(source(s), name("pain_cat"))
  DATA: pain=col(source(s), name("pain"))
  DATA: Hospital_variable=col(source(s), name("Hospital_variable"), unit.category())
  GUIDE: axis(dim(1), label("pain_cat"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Hospital_variable"))
  GUIDE: text.title(label("Grouped Scatter of pain by pain_cat by Hospital_variable"))
  ELEMENT: point(position(pain_cat*pain), color.interior(Hospital_variable))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=cortisol_serum pain Hospital_variable 
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO SUBGROUP=YES.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: cortisol_serum=col(source(s), name("cortisol_serum"))
  DATA: pain=col(source(s), name("pain"))
  DATA: Hospital_variable=col(source(s), name("Hospital_variable"), unit.category())
  GUIDE: axis(dim(1), label("cortisol_serum"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Hospital_variable"))
  GUIDE: text.title(label("Grouped Scatter of pain by cortisol_serum by Hospital_variable"))
  ELEMENT: point(position(cortisol_serum*pain), color.interior(Hospital_variable))
END GPL.

MIXED pain WITH Sex_dum age STAI_trait pain_cat cortisol_serum mindfulness
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=Sex_dum age STAI_trait pain_cat cortisol_serum mindfulness | SSTYPE(3)
  /METHOD=REML
  /PRINT=SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(hospital) COVTYPE(VC).

DESCRIPTIVES VARIABLES=FXPRED_1
  /STATISTICS=MEAN STDDEV VARIANCE RANGE MIN MAX.

---------------------------------------------------------------------------------------------------------------
DATASET B

DATASET ACTIVATE DataSet2.
AUTORECODE VARIABLES=sex 
  /INTO Sex_num
  /PRINT.

RECODE Sex_num (1=1) (2=0) (ELSE=Copy) INTO Sex_dum.
EXECUTE.

FREQUENCIES VARIABLES=sex Sex_dum
  /ORDER=ANALYSIS.

FREQUENCIES VARIABLES=pain age Sex_dum STAI_trait pain_cat cortisol_serum mindfulness hospital
  /STATISTICS=STDDEV VARIANCE RANGE MINIMUM MAXIMUM MEAN
  /ORDER=ANALYSIS.


AUTORECODE VARIABLES=hospital 
  /INTO Hospital_num
  /PRINT.

RECODE Hospital_num (1=11) (2=12) (3=13) (4=14) (5=15) (6=16) (7=17) (8=18) (9=19) (10=20) 
    (ELSE=Copy) INTO Hospital_variable.
EXECUTE.

FREQUENCIES VARIABLES=hospital Hospital_num Hospital_variable
  /ORDER=ANALYSIS.

COMPUTE Predicted_pain_by_DataA=2.76+ - 0.20 * Sex_dum+ - 0.02 * age +  - 0.05 * STAI_trait + 0.08 
    * pain_cat + 0.63 * cortisol_serum +  - 0.18 * mindfulness.
EXECUTE.

FREQUENCIES VARIABLES=Predicted_pain_by_DataA
  /ORDER=ANALYSIS.

COMPUTE Residuals=pain - Predicted_pain_by_DataA.
EXECUTE.

COMPUTE RSS=Residuals * Residuals.
EXECUTE.

DESCRIPTIVES VARIABLES=RSS
  /STATISTICS=MEAN SUM STDDEV VARIANCE RANGE MIN MAX SEMEAN.

DESCRIPTIVES VARIABLES=pain
  /STATISTICS=MEAN SUM STDDEV VARIANCE RANGE MIN MAX SEMEAN.

COMPUTE prediction_mean=4.85.
EXECUTE.

COMPUTE TS_residual_mean=pain - prediction_mean.
EXECUTE.

COMPUTE TSS=TS_residual_mean * TS_residual_mean.
EXECUTE.

DESCRIPTIVES VARIABLES=TSS
  /STATISTICS=MEAN SUM STDDEV VARIANCE RANGE MIN MAX SEMEAN.
