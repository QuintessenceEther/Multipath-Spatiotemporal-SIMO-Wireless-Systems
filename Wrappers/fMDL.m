% Kai Yan, CSP MSc, 2021, Imperial College.
% 23/12/2021

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Estimate the number of sources by MDL criterion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% Rxx (NxN Complex) = The covariance matrix of the signal
% N = The number of arrays
% L = Length of the symbols
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% m = The number of sources
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function m = fMDL(Rxx,N,L)

d = sort(real(eig(Rxx)), 'descend');
MDL = zeros(1,N);
for i = 0:N-1
    a = prod(d(i+1:N) .^(1/(N-i)));
    b = (1/(N-i)) * sum(d(i+1:N));
    MDL(i+1) = -1 * log((a / b).^((N-i)*L)) + 1/2 * i*(2*N-i) * log(L);
end


[~,m] = min(MDL);

m = m - 1;

end