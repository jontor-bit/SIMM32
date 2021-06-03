* Encoding: UTF-8.

FREQUENCIES VARIABLES=Survived Pclass Sex Age SibSp Parch Fare Embarked
  /STATISTICS=STDDEV VARIANCE RANGE MINIMUM MAXIMUM SEMEAN MEAN SUM
  /ORDER=ANALYSIS.

AUTORECODE VARIABLES=Sex 
  /INTO Sex_num
  /PRINT.

RECODE Sex_num (1=1) (2=0) (ELSE=Copy) INTO Sex_dum.
EXECUTE.

FREQUENCIES VARIABLES=Sex_num Sex_dum
  /ORDER=ANALYSIS.

CROSSTABS
  /TABLES=Survived BY Sex_dum
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT ROW TOTAL 
  /COUNT ROUND CELL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Sex_dum COUNT()[name="COUNT"] Survived 
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Sex_dum=col(source(s), name("Sex_dum"), unit.category())
  DATA: COUNT=col(source(s), name("COUNT"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  GUIDE: axis(dim(1), label("Sex_dum"))
  GUIDE: axis(dim(2), label("Count"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Survived"))
  GUIDE: text.title(label("Stacked Bar Count of Sex_dum by Survived"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: interval.stack(position(Sex_dum*COUNT), color.interior(Survived), 
    shape.interior(shape.square))
END GPL.

CROSSTABS
  /TABLES=Survived BY SibSp
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT ROW TOTAL 
  /COUNT ROUND CELL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=SibSp COUNT()[name="COUNT"] Survived MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: SibSp=col(source(s), name("SibSp"), unit.category())
  DATA: COUNT=col(source(s), name("COUNT"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  GUIDE: axis(dim(1), label("SibSp"))
  GUIDE: axis(dim(2), label("Count"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Survived"))
  GUIDE: text.title(label("Stacked Bar Count of SibSp by Survived"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: interval.stack(position(SibSp*COUNT), color.interior(Survived), 
    shape.interior(shape.square))
END GPL.

CROSSTABS
  /TABLES=Survived BY Parch
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT ROW TOTAL 
  /COUNT ROUND CELL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Parch COUNT()[name="COUNT"] Survived MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Parch=col(source(s), name("Parch"), unit.category())
  DATA: COUNT=col(source(s), name("COUNT"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  GUIDE: axis(dim(1), label("Parch"))
  GUIDE: axis(dim(2), label("Count"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Survived"))
  GUIDE: text.title(label("Stacked Bar Count of Parch by Survived"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: interval.stack(position(Parch*COUNT), color.interior(Survived), 
    shape.interior(shape.square))
END GPL.

CROSSTABS
  /TABLES=Survived BY Pclass
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT ROW TOTAL 
  /COUNT ROUND CELL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Pclass COUNT()[name="COUNT"] Survived 
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Pclass=col(source(s), name("Pclass"), unit.category())
  DATA: COUNT=col(source(s), name("COUNT"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  GUIDE: axis(dim(1), label("Pclass"))
  GUIDE: axis(dim(2), label("Count"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Survived"))
  GUIDE: text.title(label("Stacked Bar Count of Pclass by Survived"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: interval.stack(position(Pclass*COUNT), color.interior(Survived), 
    shape.interior(shape.square))
END GPL.

DESCRIPTIVES VARIABLES=Survived Sex_dum Age Pclass SibSp Parch
  /STATISTICS=MEAN STDDEV MIN MAX.

EXAMINE VARIABLES=Survived BY Age
  /PLOT NONE
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Survived Age MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  DATA: Age=col(source(s), name("Age"))
  DATA: id=col(source(s), name("$CASENUM"), unit.category())
  GUIDE: axis(dim(1), label("Survived"))
  GUIDE: axis(dim(2), label("Age"))
  GUIDE: text.title(label("Simple Boxplot of Age by Survived"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: schema(position(bin.quantile.letter(Survived*Age)), label(id))
END GPL.

RECODE Pclass (3=1) (2=0) (1=0) (ELSE=Copy) INTO Dum_3rdclass.
EXECUTE.

RECODE Pclass (1=0) (2=1) (3=0) (ELSE=Copy) INTO Dum_2ndclass.
EXECUTE.

LOGISTIC REGRESSION VARIABLES Survived
  /METHOD=ENTER Sex_dum Age SibSp Parch Dum_3rdclass Dum_2ndclass 
  /PRINT=CI(95)
  /CRITERIA=PIN(0.05) POUT(0.10) ITERATE(20) CUT(0.5).

NOMREG Survived (BASE=FIRST ORDER=ASCENDING) WITH Sex_dum Age SibSp Parch Dum_3rdclass Dum_2ndclass
  /CRITERIA CIN(95) DELTA(0) MXITER(100) MXSTEP(5) CHKSEP(20) LCONVERGE(0) PCONVERGE(0.000001) 
    SINGULAR(0.00000001)
  /MODEL
  /STEPWISE=PIN(.05) POUT(0.1) MINEFFECT(0) RULE(SINGLE) ENTRYMETHOD(LR) REMOVALMETHOD(LR)
  /INTERCEPT=INCLUDE
  /PRINT=CLASSTABLE PARAMETER SUMMARY LRT CPS STEP MFI IC.
