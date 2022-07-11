% Kai Yan, CSP MSc, 2021, Imperial College.
% 23/12/2021

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Models the channel effects in the system
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% paths (Mx1 Integers) = Number of paths for each source in the system.
% For example, if 3 sources with 1, 3 and 2 paths respectively then
% paths=[1;3;2]
% symbolsIn (MxR Complex) = Signals being transmitted in the channel
% delay (Cx1 Integers) = Delay for each path in the system starting with
% source 1
% beta (Cx1 Integers) = Fading Coefficient for each path in the system
% starting with source 1
% DOA = Direction of Arrival for each source in the system in the form
% [Azimuth, Elevation]
% SNR = Signal to Noise Ratio in dB
% array = Array locations in half unit wavelength. If no array then should
% be [0,0,0]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% symbolsOut (FxN Complex) = F channel symbol chips received from each antenna
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [symbolsOut]=fChannel(paths,symbolsIn,delay,beta,DOA,SNR,array)
%% Parameters
l = size(symbolsIn,1);  % Length of the symbols
m = size(symbolsIn,2);  % Number of transmitters
n = size(array,1);      % Number of antennas
L = l+max(delay);       % Length of the symbolsOut
symbolsOut = zeros(n,L);% Initialization
k = 1;
%% Add delays and fading coefficients
for i = 1:m                                                      
    for j = 1:paths(i)
        symbols = zeros(L,1);
        sp = spv(array,DOA(k,:));                                % Manifold vector
        symbols(1+delay(k):l+delay(k)) = symbolsIn(:,i);         % Add delay
        symbols = sp * symbols.' * beta(i);                      % Add fading coefficients
        symbolsOut = symbolsOut+symbols;
        k = k+1;
    end
end
%% Add AWGN
symbolsIn = repmat(symbolsIn(:,1),1,paths(1));
sigPower = sum(abs(beta(1:paths(1))'*symbolsIn.').^2)/length(symbolsIn(:,1));       % Obatin power of the desired signal
noisePower = sigPower/10^(SNR/10);                                                  % Obtain power of noise
noise = sqrt(noisePower/2)*(randn(size(symbolsOut))+1i*randn(size(symbolsOut)));    % Obatin the AWGN
symbolsOut = symbolsOut + noise;                                                    % Add noise
symbolsOut = symbolsOut.';
end

