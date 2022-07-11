% Kai Yan, CSP MSc, 2021, Imperial College.
% 23/12/2021

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Performs channel estimation for the desired source using the received
% signal. If the array is not input, only delay will be estimated using
% correlators. If the array is in input, the spatiotemporal channel
% estimation will be performed, both the delay and DOA will be estimated.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% symbolsIn (Fx1 Complex) = R channel symbol chips received
% goldseq (Wx1 Integers) = W bits of 1's and 0's representing the gold
% sequence of the desired source used in the modulation process
% pathnum (nx1 Intergers) = The number of path of desired signal
% array = Array locations in half unit wavelength. If no array, the
% parameter should not be input.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% delay_estimate = Vector of estimates of the delays of each path of the
% desired signal
% DOA_estimate = Estimates of the azimuth and elevation of each path of the
% desired signal. If no array, this will not be produced.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [delay_estimate,DOA_estimate]=fChannelEstimation(symbolsIn,goldseq,pathnum,arrays)
goldseq = 1-2*goldseq;
if nargin <= 3              % No array
%% Channel estimation for no arrays
% Initialization
L = size(symbolsIn,1);      % Length of the symbols
m = length(goldseq);        % Length of the gold sequence
n = floor(L/m);             % Length of the original signal
k = L-n*m;                  % Length of the maximum delay
% Correlators (based on maximum power)
for i = 1:k
    a = i;
    b = n*m+i-1;
    symbols = reshape(symbolsIn(a:b),m,n);
    powers(i) = mean(abs(goldseq'*symbols));
end
[~,delays] = maxk(powers,pathnum);
delay_estimate=sort(delays-1);
else                        % Array is input
%% Channel estimation for spatiotemporal receiver
% Initialization
N = size(symbolsIn,1);
L = size(symbolsIn,2);      % Length of the symbols
N_c = length(goldseq);  
N_ext = 2 * N_c;
J = [zeros(1,N_ext-1),0;eye(N_ext-1),zeros(N_ext-1,1)]; % Shifting matrix
c = [goldseq;zeros(N_c,1)];
Rxx = symbolsIn*symbolsIn'/L;
m = fMDL(Rxx,N,L);
% MUSIC algorithm
[eigenVector,eigenValue] = eig(Rxx);
eigenValue = diag(eigenValue);
[~,I] = sort(eigenValue,'descend');
eigenVector = eigenVector(:,I);
En = eigenVector(:,m+1:end);
Pn = fpo(En);
Z = zeros(181,N_c);         % Cost functions
for az = 0:180
    for l = 0:N_c-1
        sp = spv(arrays,[az 0]);
        h = kron(sp,J^l*c);
        Z(az+1,l+1) = h'*Pn*h;
    end
end

Z = -10*log10(Z);
mesh(0:N_c-1,0:180,real(Z));    % Plot the cost function;
title('The cost function of MuSIC algorithm');
xlabel('Delay');
ylabel('Azimuth Angle');
zlabel('dB');
%   Find the delay and DOA according to the peak of the cost function
[maxValue,~] = maxk(max(real(Z)),pathnum);
index = [];
for i = 1:pathnum
    index = [index find(maxValue(i) == real(Z))];
end
delay_estimate = floor(index/181);
DOA_estimate = [(index - delay_estimate*181 - 1).' zeros(pathnum,1)];




end

end
