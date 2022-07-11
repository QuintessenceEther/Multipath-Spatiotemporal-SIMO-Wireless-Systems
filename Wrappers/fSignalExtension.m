% Kai Yan, CSP MSc, 2021, Imperial College.
% 23/12/2021

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extend the array received signal to a discretised signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% symbolsIn (NxL Complex) = N channel symbol chips received
% Nc = Length of the gold sequence
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% symbolsExtended ((2*Nc*N)x(L/Nc) Complex) = Extended discretised symbols
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [symbolsExtended] = fSignalExtension(symbolsIn,Nc)
N_ext = 2 * Nc;
symbolsExtended = [];
condition = 0;
j = 1;
N = size(symbolsIn,1);
while ~condition
    a = 1+(j-1)*Nc;
    b = N_ext+(j-1)*Nc;
    if b <= size(symbolsIn,2)
        temp = reshape(symbolsIn(:,a:b).',[N*N_ext,1]);
        symbolsExtended = [symbolsExtended temp];
    else
        temp = zeros(N,b-a+1);
        temp(:,1:size(symbolsIn,2)-a+1) = symbolsIn(:,a:end);
        symbolsExtended = [symbolsExtended reshape(temp.',[N*N_ext,1]);];
        condition = 1;
    end
    j = j+1;
end

end