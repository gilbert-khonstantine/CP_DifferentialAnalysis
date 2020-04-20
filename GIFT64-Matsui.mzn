include "globals.mzn";
%DDT Table from GIFT Paper
array[0..99,0..7] of 0..1: DDT = array2d(0..99,0..7,[|0,0,0,0,0,0,0,0|0,0,0,1,0,1,0,1|0,0,0,1,0,1,1,0|0,0,0,1,1,0,0,0|0,0,0,1,1,0,0,1|0,0,0,1,1,0,1,0|0,0,0,1,1,0,1,1|0,0,0,1,1,1,0,0|0,0,0,1,1,1,1,1|0,0,1,0,0,1,0,1|0,0,1,0,0,1,1,0|0,0,1,0,1,0,0,1|0,0,1,0,1,0,1,0|0,0,1,0,1,1,0,1|0,0,1,0,1,1,1,0|0,0,1,1,0,1,0,1|0,0,1,1,0,1,1,0|0,0,1,1,1,0,0,0|0,0,1,1,1,0,1,1|0,0,1,1,1,1,0,0|0,0,1,1,1,1,0,1|0,0,1,1,1,1,1,0|0,0,1,1,1,1,1,1|0,1,0,0,0,1,1,1|0,1,0,0,0,1,0,1|0,1,0,0,0,0,1,1|0,1,0,0,1,0,0,1|0,1,0,0,1,1,0,1|0,1,0,1,1,1,1,1|0,1,0,1,0,0,1,0|0,1,0,1,0,1,0,1|0,1,0,1,1,0,0,0|0,1,0,1,1,1,0,0|0,1,0,1,1,1,0,1|0,1,0,1,1,1,1,0|0,1,1,0,0,0,1,1|0,1,1,0,0,0,1,0|0,1,1,0,0,1,1,1|0,1,1,0,1,0,1,0|0,1,1,0,1,1,1,0|0,1,1,1,1,0,1,1|0,1,1,1,0,0,1,0|0,1,1,1,0,1,0,1|0,1,1,1,1,0,0,0|0,1,1,1,1,0,0,1|0,1,1,1,1,0,1,0|0,1,1,1,1,1,0,0|1,0,0,0,0,0,1,1|1,0,0,0,0,1,1,1|1,0,0,0,1,0,1,0|1,0,0,0,1,1,1,1|1,0,0,1,0,0,0,1|1,0,0,1,0,0,1,1|1,0,0,1,0,1,1,0|1,0,0,1,0,1,1,1|1,0,0,1,1,0,0,0|1,0,0,1,1,0,1,0|1,0,0,1,1,1,0,0|1,0,0,1,1,1,0,1|1,0,1,0,0,0,0,1|1,0,1,0,0,1,1,0|1,0,1,0,1,0,0,1|1,0,1,0,1,0,1,0|1,0,1,0,1,1,0,1|1,0,1,0,1,1,1,0|1,0,1,1,0,0,0,1|1,0,1,1,0,0,1,1|1,0,1,1,0,1,1,0|1,0,1,1,0,1,1,1|1,0,1,1,1,0,0,0|1,0,1,1,1,0,0,1|1,0,1,1,1,1,0,0|1,0,1,1,1,1,1,0|1,1,0,0,0,0,1,0|1,1,0,0,0,1,0,0|1,1,0,0,1,0,0,0|1,1,0,0,1,0,0,1|1,1,0,0,1,0,1,0|1,1,0,0,1,1,0,0|1,1,0,0,1,1,1,0|1,1,0,1,0,1,0,0|1,1,0,1,0,0,0,1|1,1,0,1,0,0,1,0|1,1,0,1,1,0,1,0|1,1,0,1,1,0,1,1|1,1,0,1,1,1,0,1|1,1,0,1,1,1,1,1|1,1,1,0,0,0,0,1|1,1,1,0,0,1,0,0|1,1,1,0,1,0,0,0|1,1,1,0,1,0,0,1|1,1,1,0,1,1,0,0|1,1,1,0,1,1,0,1|1,1,1,1,0,0,1,0|1,1,1,1,0,0,0,1|1,1,1,1,0,0,1,0|1,1,1,1,1,0,0,1|1,1,1,1,1,0,1,1|1,1,1,1,1,1,1,0|1,1,1,1,1,1,1,1|]);

int:n; %n many round of GIFT          
array[0..n,0..63] of var 0..1 : delta; %initial differential
array[0..n-1,0..63] of var 0..1 : DSB; %after Sbox
array[0..n-1,0..63] of var 0..1 : DX; %after permutation

set of int: SboxRange = 0..15; %partition into 16 different sboxes
array[0..n-1] of var int: sbox_counter;

array[0..63] of int: perm = array1d(0..63,[0,17,34,51,48,1,18,35,32,49,2,19,16,33,50,3,4,21,38,55,52,5,22,39,36,53,6,23,20,37,54,7,8,25,42,59,56,9,26,43,40,57, 10,27,24,41,58,11,12,29,46,63,60,13,30,47,44,61,14,31,28,45,62,15]);
                                 
%we want to make sure the initial difference is not zero
constraint sum([delta[0,j]|j in 0 ..63]) > 0;

%Sbox
%table is used to constraint the output to be the same as the one inside DDT Table.
constraint forall(r in 0..n-1)(
            forall(i in SboxRange)(
              table(array1d(0..7,[delta[r,4*i+3],delta[r,4*i+2],delta[r,4*i+1],delta[r,4*i],DSB[r,4*i+3],DSB[r,4*i+2],DSB[r,4*i+1],DSB[r,4*i]]),DDT)));

%permutation (bit permutation same as the table in GIFT paper)        
constraint forall(r in 0..n-1)(forall(i in 0..63)(
                    DX[r,perm[i]]=DSB[r,i]));
                    
constraint forall(r in 0..n-1)(forall(i in 0..63)(
                    DX[r,i]=delta[r+1,i]));

%the objective function is to minimize the sum of all active sboxes in n rounds of GIFT, n is a positive integer
constraint forall(j in 0..n-1)(sbox_counter[j] = sum(r in 0..j, i in SboxRange)(DSB[r,4*i+3]+DSB[r,4*i+2]+DSB[r,4*i+1] + DSB[r,4*i] > 0));
constraint forall(i in 0..n-2)(sbox_counter[i]<sbox_counter[i+1]);

%matsui constraint
array[0..19] of int: bound = array1d(0..19,[1,2,3,5,7,10,13,16,18,20,22,24,26,28,30,32,34,36,38,40]); % known best lower bounds for r rounds
int:estimate; %estimator for r+1 rounds
constraint forall(i in 0..n-2)(sbox_counter[i] + bound[n-i-2]<= estimate);

%our objective is to calculate the minimum number of active sboxes
solve minimize sbox_counter[n-1];


output [
        "Round "++show(r+1) ++"\n"++
        "Delta : " ++ show([delta[r,i] | i in 0..63]) ++ " \n"++
           "DX : " ++ show([DX[r,i] | i in 0..63]) ++ " \n"++
 if r<n then "DSB : " ++ show([DSB[r,i] | i in 0..63]) ++ " \n" else "" endif  | r in 0..n-1]++[show(sbox_counter[n-1])];