% Kai Yan, CSP MSc, 2021, Imperial College.
% 23/12/2021

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Spatiotemporal Beamformers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% symbolsIn (2*Nc*N x L Complex) = extended symbols
% array = Array locations in half unit wavelength.
% goldseq (Wx1 Integers) = W bits of 1's and 0's representing the gold
% sequence of the desired source
% pathnum (nx1 Intergers) = The number of path of desired signal
% delay (Cx1 Integers) = Delay for each path in the system starting with
% source 1
% beta (Cx1 Integers) = Fading Coefficient for each path in the system
% starting with source 1
% DOA = Direction of Arrival for each source in the system in the form
% [Azimuth, Elevation]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% symbolsOut(Rx1) = R symbol chips after beamforming 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [symbolsOut] = spatiotemporalBeamformer(symbolsIn,arrays,goldSeq,delays,betas,DOAs)
    N_c = length(goldSeq);
    goldSeq = 1 - 2 * goldSeq;
    N_ext = N_c * 2;
    J = [zeros(1,N_ext-1),0;eye(N_ext-1),zeros(N_ext-1,1)]; % Shifting matrix
    c = [goldSeq;zeros(N_c,1)];
    H = [];
    for i = 1:length(delays)
        sd = spv(arrays,DOAs(i,:));
        h = kron(sd,J^delays(i)*c);
        H = [H h];
    end
    w = H * betas;
    symbolsOut = w' * symbolsIn;
end