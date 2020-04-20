%Computing differential probability for SPECK32 (1 round)
function var 0..1: myxor(var 0..1 :x, var 0..1 :y) = ((x+y)=1);
function var int: XOR(var 0..1 :x, var 0..1 :y, var 0..1 :z) = (x+y+z) mod 2;
function var bool: AND(var int:x, var int:y) = (x==y) /\ (x!=0) ;

%this is the function that will be use to compute the objective function                               
function var int:neq(var int:x,var int:y, var int:z) =
                          if x==y /\ y==z /\ x== z then 0 else 1 endif ;
function var int:eq(var int:x,var int:y, var int:z) =
                          if x==y /\ y==z /\ x== z then 1 else 0 endif ;
                                    
%First we initialize the variables that we will use
int:n; %number of rounds
array[0..n,0..15] of var 0..1: LD; %this is the left delta
array[0..n-1,0..15] of var 0..1: LDR; %this is the left delta after rotation
array[0..n,0..15] of var 0..1: RD; %this is the right delta
array[0..n-1,0..15] of var 0..1: RDR; %this is the right delta after rotation (except the first row)
array[0..n-1,0..15] of var 0..1: MA; %this is the result of modular addition
array[0..n-1,0..15] of var 0..1: RXOR; %right delta after rotation and xored with MA
var int: DP; %Differential Probability
array[0..15] of int: mask = array1d(0..15,[0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]);
array[0..n-1,0..15] of var 0..1: result; %result for the MA constraint
%non-zero
constraint sum([RD[0,j]|j in 0 ..15]) > 0 \/ sum([LD[0,j]|j in 0 ..15]) > 0;

%rotation
constraint forall(r in 0..n-1)(forall(i in 0..15)(LDR[r,(i+7) mod 16] = LD[r,i]));
constraint forall(r in 0..n-1)(forall(i in 0..15)(RDR[r,i] = RD[r,((i+2) mod 16)]));

constraint forall(r in 0..n-1)(forall(i in 0..15)(MA[r,i] = LD[r+1,i] ));
constraint forall(r in 0..n-1)(forall(i in 0..15)(RD[r+1,i] = RXOR[r,i]));

%xor
constraint forall(r in 0..n-1)(forall(i in 0..15)(RXOR[r,i] = myxor(RDR[r,i],MA[r,i]) ));

%modular addition

constraint forall(r in 0..n-1)(forall(i in 0..15)(AND((eq( AND(MA[r,(i+1) mod 16],mask[15-i]) , AND(LDR[r,(i+1) mod 16],mask[15-i]), AND( RD[r,(i+1) mod 16],mask[15-i]))) , (myxor( XOR(MA[r,i],LDR[r,i],RD[r,i]) , AND((RD[r,(i+1) mod 16]),mask[15-i])))) == 0 ));

constraint forall(r in 0..n-1)(forall(i in 0..15)(result[r,i] = (AND((eq( AND(MA[r,(i+1) mod 16],mask[15-i]) , AND(LDR[r,(i+1) mod 16],mask[15-i]), AND( RD[r,(i+1) mod 16],mask[15-i]))) , (myxor( XOR(MA[r,i],LDR[r,i],RD[r,i]) , AND((RD[r,(i+1) mod 16]),mask[15-i])))) == 0 ))); % this will show the result of modular addition as "res"

constraint DP = sum(r in 0..n-1,i in 0 .. 15)( AND(neq(MA[r,i],LDR[r,i],RD[r,i]), mask[i] ));
array[0..7] of int: bound = array1d(0..7,[0,1,3,5,9,13,18,24]); % known best lower bounds for r rounds
int:estimate; %estimator for r+1 rounds
constraint forall(i in 0..n-2)(bound[n-i-2]+DP<=estimate);

solve minimize DP;

output [
        "Round "++show(r+1) ++"\n"++  
        "LD : " ++ show([LD[r,i] | i in 0..15]) ++ " \n"++
        "LDR : " ++ show([LDR[r,i] | i in 0..15]) ++ " \n"++
        "RD : " ++ show([RD[r,i] | i in 0..15]) ++ " \n"++
        "RDR : " ++ show([RDR[r,i] | i in 0..15]) ++ " \n"++
        "MA : " ++ show([MA[r,i] | i in 0..15]) ++ " \n"++
        "RXOR : " ++ show([RXOR[r,i] | i in 0..15]) ++ " \n"++
        "Res : " ++ show([result[r,i] | i in 0..15]) ++" \n"| r in 0..n-1]++ [show(DP)];