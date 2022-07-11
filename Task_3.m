% Kai Yan, MSc, 2021, Imperial College.
% 23/12/2021

clc 
clear all
close all
%% Initialization
disp('Initializaiton...');
addpath('Photos')
addpath('Wrappers')
%Load Images and obtain the bits will be transmitted.
Image1 = imread('pic1.jpg');
Image2 = imread('pic2.jpg');
Image3 = imread('pic3.jpg');
[x1,y1,~] = size(Image1);
[x2,y2,~] = size(Image2);
[x3,y3,~] = size(Image3);
Q1 = x1*y1*3*8;
Q2 = x2*y2*3*8;
Q3 = x3*y3*3*8;
P = max([Q1,Q2,Q3]);

bitsImg1 = fImageSource('pic1.jpg',P);
bitsImg2 = fImageSource('pic2.jpg',P);
bitsImg3 = fImageSource('pic3.jpg',P);

%% DSSS-QPSK Modulation
disp('DSSS-QPSK Modulation...');
X = 25; %alphabetical order of the 1st letter(Y) of my surname
Y = 11; %alphabetical order of the 1st letter(K) of my formal firstname.
phi = (X+2*Y) * pi/180;
coeff1 = [1 0 0 1 1]';
coeff2 = [1 1 0 0 1]';
mSeq1 = fMSeqGen(coeff1);
mSeq2 = fMSeqGen(coeff2);
m = size(coeff1,1) - 1;
Nc = 2^m - 1;
% Find all the Gold Sequence
b = [];
for i = 1:Nc
    b = [b fGoldSeq(mSeq1,mSeq2,i)];
end
b = [b mSeq1 mSeq2];
b_trans = 1-2.*b;
% Find Balanced Gold Sequence which satisfies the condition
balancedGoldSeq = [];
for i = 1:Nc+2
    if sum(b_trans(:,i)) == -1 && i>= 1+mod(X+Y,12)
        balancedGoldSeq = [balancedGoldSeq b_trans(:,i)];
        d = i;
        break
    end
end
goldSeq1 = b(:,d);
goldSeq2 = b(:,d+1);
goldSeq3 = b(:,d+2);
% Obtain the symbols
symbolsImg1 = fDSQPSKModulator(bitsImg1,goldSeq1,phi);
symbolsImg2 = fDSQPSKModulator(bitsImg2,goldSeq2,phi);
symbolsImg3 = fDSQPSKModulator(bitsImg3,goldSeq3,phi);
symbolsIn = [symbolsImg1,symbolsImg2,symbolsImg3];
%% Task-3
disp('Construct uniform circular array...');
%   Construct uniform circular array
angleDifference = 2*pi/5;
r = 1/(2*sin(angleDifference/2));    % Radius of the UCA
initAngle = 30/180*pi;
num = 0:4;
angles = initAngle + num*angleDifference;
arrayPolor = r*exp(1i*angles);
arrays(:,1) = real(arrayPolor);
arrays(:,2) = imag(arrayPolor);
arrays(:,3) = 0;
figure(1);
plot(arrays(:,1),arrays(:,2),'or',...
     'MarkerSize',10,...
     'LineWidth',2,...
     'MarkerFaceColor','r');
legend('Antenna')
xlabel('X');ylabel('Y');
axis([-1 1 -1 1]);
title('The distribution of UCA')
%   Channel Paramaters
delays = [5;7;12];
betas = [.4 ; .7 ; .2];
DOAs = [30 0; 45 0; 20 0; 80 0; 150 0;];
paths = [1,1,1];
SNR = 40;
disp('%%%%%%%%%%%%%%% Channel Parameters %%%%%%%%%%%%%%%');
disp(['SNR = ',num2str(SNR)]);
disp(['Delay = ',num2str(delays')]);
disp(['Beta = ',num2str(betas')]);
disp(['DOAs = ',num2str(reshape(DOAs',1,numel(DOAs)))]);
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp('Transmit the signal through the channel...');
symbolsOut = fChannel(paths,symbolsIn,delays,betas,DOAs,SNR,arrays); 

%   Channel estimation

N = size(arrays,1);
N_ext = 2 * Nc;
disp('Extend the signal...');
symbolsExtended = fSignalExtension(symbolsOut.',Nc);
figure(2);
[delay_estimate,DOA_estimate] = fChannelEstimation(symbolsExtended,goldSeq1,paths(1),arrays);
disp('Channel Estimation...');
disp(['The estimated delays are : ',num2str(delay_estimate)]);
disp(['The estimated DOAs are : ',num2str(reshape(DOA_estimate',1,numel(DOA_estimate)))]);
%% STAR Beamforming
disp('STAR Beamforming...');
symbols = spatiotemporalBeamformer(symbolsExtended,arrays,goldSeq1,delay_estimate,betas(1:paths(1)),DOA_estimate);
%% QPSK Demodulation
disp('QPSK Demodulation...');
bitsOut = fDSQPSKDemodulator(symbols.',goldSeq1,phi);
[~,BER] = biterr(bitsOut,bitsImg1);
disp(['Bit error rate = ',num2str(BER)]);
figure(3);
fImageSink(bitsOut,Q1,x1,y1);
title({'Received Image ';['SNR = ',num2str(SNR),' dB , ','BER = ',num2str(BER)]});