function clean_ecg = final_ecg_filter(raw_ecg, Fs, Notch_F0)
% =========================================================================
% FINAL OPTIMIZED "MIXED" ECG FILTER PIPELINE
% =========================================================================
% This function applies the optimal filter combination for preserving QRS 
% morphology while eliminating baseline wander, power-line interference, 
% and high-frequency muscle noise.
%
% PIPELINE STAGES:
% 1. 4th-Order Butterworth High-Pass (0.5 Hz)  -> Baseline Wander
% 2. Manual Pole-Zero Notch Filter (Default 60 Hz) -> Power-line Noise
% 3. 4th-Order Butterworth Low-Pass (100 Hz)   -> Muscle (EMG) Noise
%
% USAGE:
%   clean_ecg = final_ecg_filter(raw_ecg);
%   clean_ecg = final_ecg_filter(raw_ecg, 360, 50); % For 50Hz environments
% =========================================================================

    % Set default parameters if not provided
    if nargin < 3
        % DEFAULT TO 60 HZ: Optimized for the US-based MIT-BIH Database
        Notch_F0 = 60; 
    end
    if nargin < 2
        Fs = 360; 
    end

    Fn = Fs / 2; % Nyquist Frequency

    % ---------------------------------------------------
    % 1. DESIGN THE FILTERS
    % ---------------------------------------------------
    
    % Stage 1: High-Pass Butterworth (Order 4, Cutoff 0.5 Hz)
    [b_hp, a_hp] = butter(4, 0.5 / Fn, 'high');

    % Stage 2: Manual Pole-Zero Notch (Target Frequency, Radius 0.99)
    theta = (Notch_F0 / Fs) * 2 * pi;
    r = 0.99;
    b_notch = [1, -2*cos(theta), 1];
    a_notch = [1, -2*r*cos(theta), r^2];
    
    % Normalize DC Gain to 1.0
    dc_gain = sum(b_notch) / sum(a_notch);
    b_notch = b_notch / dc_gain;

    % Stage 3: Low-Pass Butterworth (Order 4, Cutoff 100 Hz)
    [b_lp, a_lp] = butter(4, 100 / Fn, 'low');

    % ---------------------------------------------------
    % 2. APPLY THE FILTERS (Using filtfilt for zero phase distortion)
    % ---------------------------------------------------
    
    ecg_stage1 = filtfilt(b_hp, a_hp, raw_ecg);
    ecg_stage2 = filtfilt(b_notch, a_notch, ecg_stage1);
    clean_ecg  = filtfilt(b_lp, a_lp, ecg_stage2);

end