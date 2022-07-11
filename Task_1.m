% Kai Yan, MSc, 2021, Imperial College.
% 23/12/2021

clc 
clear all
close all
%% Initialization

addpath('Photos')
addpath('Wrappers')
%Load Images and obtain the bits will be transmitted.
disp('Initializaiton...');
Image1 = imread('pic1.jpg');
Image2 = imread('pic2.jpg');
Image3 = imread('pic3.jpg');
figure;
subplot(1,3,1);
imshow(Image1);
title('Original desired Image');
subplot(1,3,2);
imshow(Image2);
title('Original interference Image')
subplot(1,3,3);
imshow(Image3);
title('Original interference Image')
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
%% Task-1a (SNR = 0 dB)
%  Channel Paramater
delays = [5;7;12];
betas = [.4 ; .7 ; .2];
DOAs = [30 0;90 0;150 0];
paths = [1,1,1];
array = [0,0,0];
SNR = 0;
disp('%%%%%%%%%%%%%%% Channel Parameters %%%%%%%%%%%%%%%');
disp(['SNR = ',num2str(SNR)]);
disp(['Delay = ',num2str(delays')]);
disp(['Beta = ',num2str(betas')]);
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp('Transmit the signal through channel...');
symbolsOut = fChannel(paths,symbolsIn,delays,betas,DOAs,SNR,array);
%% Task-1b
%  RAKE Receiver
disp('Channel Estimation...');
delay_estimate = fChannelEstimation(symbolsOut,goldSeq1,paths(1));
disp(['The estimated delays are : ',num2str(delay_estimate)])
disp('DSSS-QPSK Demodulation...');
bits_0db = fDSQPSKDemodulator(symbolsOut,goldSeq1,phi,delay_estimate,betas(1));
[~,BER_0db] = biterr(bits_0db,bitsImg1);
disp(['Bit error rate = ',num2str(BER_0db)]);
%% Task-1 (SNR = 40 dB)
SNR = 40;
disp('%%%%%%%%%%%%%%% Channel Parameters %%%%%%%%%%%%%%%');
disp(['SNR = ',num2str(SNR)]);
disp(['Delay = ',num2str(delays')]);
disp(['Beta = ',num2str(betas')]);
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp('Transmit the signal through the channel...');
disp('Channel Estimation...');
symbolsOut = fChannel(paths,symbolsIn,delays,betas,DOAs,SNR,array);
delay_estimate = fChannelEstimation(symbolsOut,goldSeq1,paths(1));
disp(['The estimated delays are : ',num2str(delay_estimate)])
disp('DSSS-QPSK Demodulation...');
bits_40db = fDSQPSKDemodulator(symbolsOut,goldSeq1,phi,delay_estimate,betas(1));
[~,BER_40db] = biterr(bits_40db,bitsImg1);
disp(['Bit error rate = ',num2str(BER_40db)]);
%% Result analysis
%   Image comparison
figure;
subplot(1,2,1);
fImageSink(bits_0db,Q1,x1,y1);
title({'Received Image ';['SNR = 0 dB , ','BER = ',num2str(BER_0db)]});
subplot(1,2,2);
fImageSink(bits_40db,Q1,x1,y1);
title({'Received Image ';['SNR = 40 dB , ','BER = ',num2str(BER_40db)]});