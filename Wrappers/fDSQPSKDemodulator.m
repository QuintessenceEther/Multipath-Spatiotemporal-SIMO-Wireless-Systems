% Kai Yan, CSP MSc, 2021, Imperial College.
% 23/12/2021

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Perform direct-sequence despread and demodulation of the received data using 
% RAKE receivers and STAR receivers If the delays and betas 
% are not input, only the demodulation will be performed.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% symbolsIn (Lx1 Integers) = L channel symbol chips received
% goldseq (Wx1 Integers) = W bits of 1's and 0's representing the gold
% sequence of the desired signal to be used in the demodulation process
% phi (Integer) = Angle index in degrees of the QPSK constellation points
% delay (Cx1 Integers) = Estimated delay for each path in the system 
% starting with source 1
% beta (Cx1 Integers) = Fading Coefficient for each path in the system
% starting with source 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% bitsOut (Px1 Integers) = P demodulated bits of 1's and 0's
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [bitsOut]=fDSQPSKDemodulator(symbolsIn,GoldSeq,phi,delays,betas)
%% Despread
GoldSeq = 1-2*GoldSeq;  % Transfer Gold Sequence from 0/1 to 1/-1
if nargin > 3
L = length(symbolsIn);  % Length of the symbols
m = length(GoldSeq);    % Length of the gold sequence
n = floor(L/m);         % Length of the symbols without delays
k = length(delays);     % Number of delays
symbolsDespread = [];
for i = 1:k
    symbols = [];
    symbols = symbolsIn(delays(:,i)+1:delays(:,i)+m*n);
    symbols = reshape(symbols,m,n);
    symbolsDespread = [symbolsDespread;GoldSeq' * symbols];
end
% Max Ratio Combining
symbolsDespread = conj(betas.')*symbolsDespread;
else
symbolsDespread = symbolsIn;
end
%% QPSK Demodulation
bitsOut = [];
for i = 1:length(symbolsDespread)
    distance(1) = abs(symbolsDespread(i)-sqrt(2)*(cos(phi)+1i*sin(phi)));                  % 00
    distance(2) = abs(symbolsDespread(i)-sqrt(2)*(cos(phi+pi/2)+1i*sin(phi+pi/2)));        % 01
    distance(3) = abs(symbolsDespread(i)-sqrt(2)*(cos(phi+pi)+1i*sin(phi+pi)));            % 11
    distance(4) = abs(symbolsDespread(i)-sqrt(2)*(cos(phi+3*pi/2)+1i*sin(phi+3*pi/2)));    % 10
    [~,num] = mink(distance,1);                                                            % Find the index of minimum distance
    num = num2str(num);
    switch num
        case '1'                                                                           % 00
            bitsOut = [bitsOut;0;0];
        case '2'                                                                           % 01
            bitsOut = [bitsOut;0;1];
        case '3'                                                                           % 11
            bitsOut = [bitsOut;1;1];
        case '4'                                                                           % 10
            bitsOut = [bitsOut;1;0];
    end
end
end
