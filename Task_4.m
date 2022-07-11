% Kai Yan, MSc, 2021, Imperial College.
% 23/12/2021

clc 
clear
close all
%% Initialization
load ky421_fastfading.mat
addpath('Wrappers')
coeff1 = [1 0 0 1 0 1]';
coeff2 = [1 0 1 1 1 1]';
mSeq1 = fMSeqGen(coeff1);
mSeq2 = fMSeqGen(coeff2);
goldseq = fGoldSeq(mSeq1,mSeq2,phase_shift);
%% Task-4
%   Construct uniform circular array
disp('Construct uniform circular array...');
angleDifference = 2*pi/5;
r = 1/(2*sin(angleDifference/2));    % Radius of the UCA
initAngle = 30/180*pi;
num = 0:4;
angles = initAngle + num*angleDifference;
arrayPolor = r*exp(1i*angles);
arrays(:,1) = real(arrayPolor);
arrays(:,2) = imag(arrayPolor);
arrays(:,3) = 0;
%   Channel estimation
Nc = length(goldseq);
N = size(arrays,1);
N_ext = 2 * Nc;
disp('Extend the signal...');
symbolsExtended = fSignalExtension(Xmatrix,Nc);
[delay_estimate,DOA_estimate] = fChannelEstimation(symbolsExtended,goldseq,3,arrays);
disp('Channel Estimation...');
disp(['The estimated delays are : ',num2str(delay_estimate)]);
disp(['The estimated DOAs are : ',num2str(reshape(DOA_estimate',1,numel(DOA_estimate)))]);
disp('STAR Beamforming...');
symbols = spatiotemporalBeamformer(symbolsExtended,arrays,goldseq,delay_estimate,Beta_1,DOA_estimate);
disp('QPSK Demodulation...');
bitsOut = fDSQPSKDemodulator(symbols.',goldseq,phi_mod);
%%  Display the text
str = bin2str(bitsOut);
disp('The received text is :');
disp(str);
