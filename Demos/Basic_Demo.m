%	OVERVIEW:
%       This basic demo will allow you to load an ECG file in matlab 
%       compatible wfdb format, detect the locations of the R peaks,
%       perform signal quality (SQI) analysis and plot the results.
%
%   OUTPUT:
%       A figure with the loaded ECG signal and detected peaks will be
%       generated
%
%   DEPENDENCIES & LIBRARIES:
%       https://github.com/cliffordlab/PhysioNet-Cardiovascular-Signal-Toolbox
%   REFERENCE: 
%       Vest et al. "An Open Source Benchmarked HRV Toolbox for Cardiovascular 
%       Waveform and Interval Analysis" Physiological Measurement (In Press), 2018. 
%	REPO:       
%       https://github.com/cliffordlab/PhysioNet-Cardiovascular-Signal-Toolbox
%   ORIGINAL SOURCE AND AUTHORS:     
%       Giulia Da Poian   
%	COPYRIGHT (C) 2018 
%   LICENSE:    
%       This software is offered freely and without warranty under 
%       the GNU (v3 or later) public license. See license file for
%       more information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
clc

% Where are the data, in this demo they are located in a subfolder
InputFolder = [pwd filesep 'TestData']; % path to the folder where you data are located
SigName = 'TestRawECG.mat';

% load the ecg using rdmat
load([InputFolder filesep SigName]);
% the signal has two channels, from now on we will use just one 
ecg = signal(:,1);

% plot the signal
figure(1)
plot(ecg);
xlabel('[s]');
ylabel('[mV]')


% Detection of the R-peaks using the jqrs.m function included in the
% toolbox, requires to set initialization parameters calling the
% InitializeHRVparams.m function

HRVparams = InitializeHRVparams('Demo');
% set the exact sampling frequency usign the one from the loaded signal
HRVparams.Fs = 125; % Changed from 360 based on my observations of the time array
% call the function that perform peak detection
r_peaks = jqrs(ecg,HRVparams);

% plot the detected r_peaks on the top of the ecg signal
figure(1)
hold on;
plot(r_peaks, ecg(r_peaks),'o');
legend('ecg signal', 'detected R peaks')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% From this point onwards code was added by Andre Holder on 09/12/2018 as
% part of the lab work for BMI500.
% The purpose of the code below is to extract heart rates (in beats per 
% minute) from the R-R intervals, and determine what percentage of consecutive heart beats are
% irregular (defined below as a HR difference > 1). This is then plotted in
% a pie chart at the end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get HR measurements (in secs) for every R-R (r_peak) interval
hr=zeros(length(r_peaks)-1,1); %Create a new vector for HR measurements from r_peaks
for i=1:length(hr)
    %Convert R-R interval in sec to HR (beats/min), assuming ECG sample frequency of 256 Hz
    hr(i)=(1/((r_peaks(i+1)-r_peaks(i))/HRVparams.Fs))*60;
end

% Detect irregular dysrhythmias (variability in consecutive HRs > 8)
irreg = zeros(length(hr)-1,1); %Create a new vector for HR measurements from r_peaks
irreg=irreg+9; %irreg set to dummy values as it will be changed to boolean values
for i = 1:length(irreg)
    %Identify variation in consecutive HRs (change in HR>1) 
    if abs(hr(i+1)-hr(i))>1, irreg(i)=1; else irreg(i)=0; 
    end
end

%See distribution of heart rates that vary by more than 1
tallies=[0 0]; %Create a variable to tally 0s and 1s from irreg to use in pie chart
for i = 1:length(irreg)
    if irreg(i)==0 %If HR<=1
        tallies(1)=tallies(1)+1;
    elseif irreg(i)==1 %If HR>1
        tallies(2)=tallies(2)+1;
    end
end

%Get percentages of each category
distrib=[0 0];
distrib(1)=tallies(1)/length(irreg);
distrib(2)=tallies(2)/length(irreg);

%Create a pie chart
figure(2)
pie(distrib)
title('Frequency of irregular consecutive rhythms')
legend('Regular', 'Irregular')
