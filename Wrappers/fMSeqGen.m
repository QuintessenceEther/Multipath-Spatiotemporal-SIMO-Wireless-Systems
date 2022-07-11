% Kai Yan, CSP MSc, 2021, Imperial College.
% 23/12/2021

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Takes polynomial weights and produces an M-Sequence
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% coeffs (Px1 Integers) = Polynomial coefficients. For example, if the
% polynomial is D^5+D^3+D^1+1 then the coeffs vector will be [1;0;1;0;1;1]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% MSeq (Wx1 Integers) = W bits of 1's and 0's
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [MSeq]=fMSeqGen(coeffs)

%% Initialization
m = size(coeffs,1) - 1;     % number of shift register
Nc = 2.^m - 1;              % maximum period of the shift register
registers = ones(1,m);      % Initial condition of the register
seq = zeros(1,Nc);

%% main 
for i = 1:Nc
    feedback = mod(sum(registers * coeffs(2:end)),2);
    registers(2:end) = registers(1:end-1);
    registers(1) = feedback;
    seq(i) = registers(end); 
end
MSeq = seq';



end