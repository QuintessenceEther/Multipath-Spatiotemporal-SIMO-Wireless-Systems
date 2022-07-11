% Kai Yan, CSP MSc, 2021, Imperial College.
% 23/12/2021

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Perform DS-QPSK Modulation on a vector of bits using a gold sequence
% with channel symbols set by a phase phi
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% bitsIn (Px1 Integers) = P bits of 1's and 0's to be modulated
% goldseq (Wx1 Integers) = W bits of 1's and 0's representing the gold
% sequence to be used in the modulation process
% phi (Integer) = Angle index in degrees of the QPSK constellation points
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% symbolsOut (Rx1 Complex) = R channel symbol chips after DS-QPSK Modulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [symbolsOut]=fDSQPSKModulator(bitsIn,goldseq,phi)
%% QPSK Modulation
symbols = [];
Nc = length(bitsIn)/2;  %Length of the transmitted symbols
for m = 1:Nc
    bits = [num2str(bitsIn(2*m-1)),num2str(bitsIn(2*m))];
    switch bits
        case '00'
            symbols(m) = sqrt(2)*(cos(phi)+1i*sin(phi));
        case '01'
            symbols(m) = sqrt(2)*(cos(phi+pi/2)+1i*sin(phi+pi/2));
        case '11'
            symbols(m) = sqrt(2)*(cos(phi+pi)+1i*sin(phi+pi));
        case '10'
            symbols(m) = sqrt(2)*(cos(phi+3*pi/2)+1i*sin(phi+3*pi/2));
    end
end
%% DSSS
goldseq = 1-2*goldseq;          % Transfer Gold Sequence from 0/1 to 1/-1
symbolsOut = goldseq * symbols;
symbolsOut = symbolsOut(:);

