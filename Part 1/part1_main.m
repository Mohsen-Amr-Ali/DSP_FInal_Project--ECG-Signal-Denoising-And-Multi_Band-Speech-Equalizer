% ===================================================
% DIGITAL SIGNAL PROCESSING FINAL PROJECT - PART I
% ECG Signal Denoising for Telemedicine Applications
% ===================================================
clear; clc; close all; 

%% 1. GLOBAL SIGNAL CHARACTERISTICS
% The sampling frequency is given by the MIT-BIH database specifications.
Fs = 360;               % Sampling frequency in Hz
Fn = Fs / 2;            % Nyquist frequency (maximum representable frequency)

%% 2. FILTER SPECIFICATIONS
% Here we define the "rules" for our three filters based on the theory.

% ---------------------------------------------------
% Filter 1: High-Pass Filter (To remove < 0.5 Hz Baseline Wander)
% ---------------------------------------------------
HPF_Fstop = 0.1;        % Frequency where we strictly stop the noise (Hz)
HPF_Fpass = 0.5;        % Frequency where we start letting the ECG through (Hz)
HPF_Astop = 40;         % How hard we crush the noise in the stopband (dB)
HPF_Apass = 1;          % Maximum allowed wobble in the good signal (dB)

% ---------------------------------------------------
% Filter 2: Notch Filter (To remove 50 Hz Power-line Interference)
% ---------------------------------------------------
Notch_F0 = 50;          % The exact center frequency we want to kill (Hz)
Notch_BW = 2;           % Bandwidth of the notch (Hz). Cuts from 49 to 51 Hz.
Notch_Astop = 40;       % Attenuation exactly at 50 Hz (dB)

% ---------------------------------------------------
% Filter 3: Low-Pass Filter (To remove high-frequency EMG muscle noise)
% ---------------------------------------------------
% Note: Useful ECG goes up to 100Hz, but most critical diagnostic info 
% (QRS complex) is below 40Hz. EMG noise starts at 20Hz. We will set a 
% cutoff around 40Hz to aggressively clean the signal for basic monitoring.
LPF_Fpass = 40;         % The highest frequency we want to keep perfectly (Hz)
LPF_Fstop = 45;         % The frequency where we want everything blocked (Hz)
LPF_Apass = 1;          % Maximum allowed wobble in the passband (dB)
LPF_Astop = 50;         % How hard we crush the muscle noise (dB)

%% 3. DATA ACQUISITION
% Load the raw signal from the MIT-BIH database into memory.
try
    load('100.mat'); % Make sure 100.mat is in your MATLAB Current Folder
    raw_ecg = double(val(1, :)); % Extract Lead I and convert to high-precision decimal
    
    N = length(raw_ecg);         % Total number of data points
    t = (0:N-1) / Fs;            % Generate the time axis in seconds
    
    disp('Part 1 Specifications and ECG Data Loaded Successfully.');
catch
    disp('Error: Could not load 100.mat. Please check your folder path.');
end