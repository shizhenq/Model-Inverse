SETS
$include SetStatements.txt
;

PARAMETERS
mx(m) Mean of X
/
$include MX.txt
/
sx(m) StdDev of X
/
$include SX.txt
/
my(n) Mean of Y
/
$include MY.txt
/
sy(n) StdDev of Y
/
$include SY.txt
/
R2YPV(n) Captured Var per variable for Y
/
$include R2YPV.txt
/
VART(a) Variance of the scores
/
$include VAR_T.txt
/
YEQ(n) Equality constratints for y
/
$include YEQ.txt
/
YEQ_WEIGHTS(n) Weights for equality constratints in Y
/
$include YEQ_WEIGHTS.txt
/
;
TABLE
WS(m,a) X Loadings from PLS model
$include WS.txt
;
TABLE
P(m,a) X Loadings from PLS model
$include P.txt
;
TABLE
Q(n,a) Y Loadings from PLS model
$include Q.txt
;

VARIABLES
t(a)               Score for the optimal scenario
xnew(m)            Process and Ideal weighted blend properties
spex               Sq. Pred. Error for X-Space
hott2              Hott2 of the solution
y(n)               Predicted Y for each blend
OBJ                Value of the objective function

SCALARS

$include SPEXLim99.txt
$include HOT2Xlim99.txt
;

EQUATIONS
*const_spe_x    Constratint on the SPE for X
*const_hott2_up    Constraints on the Hotelling's T2
*cont_hott2_lo   Constraints on the Hotelling's T2
Calc_t(a)      Calculation of the score value
Calc_spe       Calculation of the SPE
calc_hott2     Calculation of the Hotelling's T2
Calc_y(n)      Calculate the prediction of Y
OBJECTIVE      Objective function to minimize
;

*const_spe_x..   spex =l= SPEXlim99 ;
*const_hott2_up..   hott2 =l= HOT2Xlim99;
*const_hott2_lo..   hott2 =g= 0.8*HOT2Xlim99;
Calc_hott2..                   hott2   =e= sum(a,(sqr(t(a))/VarT(a)));
Calc_spe..                      spex   =e= sum(m, sqr( sum(a,t(a)*P(m,a)) - ((xnew(m)-mx(m))/sx(m)) )  );
Calc_t(a)..                      t(a)  =e= sum(m,((xnew(m)-mx(m))/sx(m))*WS(m,a));
Calc_y(n)..                      y(n)  =e= (sum(a,t(a)*Q(n,a))*sy(n)) + my(n);
OBJECTIVE..                        OBJ  =e= sum(n, SQR(YEQ(n)-y(n))*YEQ_WEIGHTS(n)*R2YPV(n))+hott2*0.00001;

MODEL LVMinversion Inversion of a Latent Variable Regression Model /ALL /;
Solve LVMinversion  minimizing OBJ using MINLP;
display xnew.l,y.l,t.l;

*file OptXnew /MYGAMSoutput_xnew.txt/;
*put OptXnew;
*loop(m,put xnew.l(m):18:15 /);

file Opty /MYGAMSoutput_y.txt/;
put Opty;
loop(n,put y.l(n):18:15 /);

file Optt /MYGAMSoutput_t.txt/;
put Optt;
loop(a,put t.l(a):18:15 /);

file Optspe /MYGAMSoutput_spex.txt/;
put Optspe;
put spex.l:18:15/;


file OptHott2 /MYGAMSoutput_hott2.txt/;
put OptHott2;
put hott2.l:18:15/

file modelst /MYGAMSoutput_minlp_status.txt/ ;
put modelst ;
put LVMinversion.modelstat /;
putclose modelst ;
