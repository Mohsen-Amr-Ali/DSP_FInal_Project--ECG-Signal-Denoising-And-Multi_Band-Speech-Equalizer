% ===================================================
% DIGITAL SIGNAL PROCESSING FINAL PROJECT - PART I
% Master Execution Script for ECG Denoising
% ===================================================
clear; clc; close all; 

%% 1. GLOBAL SETUP & SPECIFICATIONS
Fs = 360; 

% Baseline Wander (High-Pass)
HPF_Fstop = 0.1;   HPF_Fpass = 0.5;   
HPF_Astop = 40;    HPF_Apass = 1;

% Power-line Noise (Notch)
Notch_F0 = 50;     Notch_BW = 2;      
Notch_Astop = 40;

% EMG / Muscle Noise (Low-Pass)
LPF_Fpass = 40;    LPF_Fstop = 45;    
LPF_Apass = 1;     LPF_Astop = 50;

records_to_test = {'100', '106'};

%% 2. GENERATE AND ANALYZE THE FILTERS
disp('--- Generating Filters ---');

% Generate FIR Pipeline
[b_fir_hp, a_fir_hp, b_fir_notch, a_fir_notch, b_fir_lp, a_fir_lp] = ...
    design_fir_filters(Fs, HPF_Fstop, HPF_Fpass, Notch_F0, Notch_BW, LPF_Fpass, LPF_Fstop);

% Generate Butterworth Pipeline
[b_butt_hp, a_butt_hp, b_butt_notch, a_butt_notch, b_butt_lp, a_butt_lp] = ...
    design_butterworth_filters(Fs, HPF_Fstop, HPF_Fpass, HPF_Astop, HPF_Apass, ...
                               Notch_F0, Notch_BW, Notch_Astop, LPF_Fpass, LPF_Fstop, LPF_Apass, LPF_Astop);

% Generate Chebyshev (Type I) Pipeline
[b_cheb_hp, a_cheb_hp, b_cheb_notch, a_cheb_notch, b_cheb_lp, a_cheb_lp] = ...
    design_chebyshev_filters(Fs, HPF_Fstop, HPF_Fpass, HPF_Astop, HPF_Apass, ...
                             Notch_F0, Notch_BW, Notch_Astop, LPF_Fpass, LPF_Fstop, LPF_Apass, LPF_Astop);

% Generate Manual Pole-Zero Notch Filter (Radius = 0.99)
[b_manual_notch, a_manual_notch] = design_pole_zero_notch(Fs, Notch_F0, 0.99);

% Analyze the Filters to prove they work mathematically
% (Plotting the Low-Pass filters to compare their slopes, and the Manual Notch to show the poles/zeros)
analyze_filter(b_fir_lp, a_fir_lp, Fs, 'FIR Low-Pass Filter');
analyze_filter(b_butt_lp, a_butt_lp, Fs, 'Butterworth Low-Pass Filter');
analyze_filter(b_cheb_lp, a_cheb_lp, Fs, 'Chebyshev Low-Pass Filter');
analyze_filter(b_manual_notch, a_manual_notch, Fs, 'Manual Pole-Zero Notch Filter');

%% 3. PROCESS THE PATIENT DATA
for i = 1:length(records_to_test)
    record_name = records_to_test{i};
    disp(['=== Processing MIT-BIH Record: ', record_name, ' ===']);
    
    % ---------------------------------------------------
    % DATA LOADING HANDLING (WFDB TOOLBOX)
    % ---------------------------------------------------
    try
        % rdsamp automatically reads the .dat and .hea files.
        % The '1' explicitly requests only the first signal (Lead I).
        % We use '~' to ignore the Fs output since we already defined it globally.
        [signalData, ~] = rdsamp(record_name, 1);
        
        % rdsamp returns data as a vertical column.
        % We transpose it (') into a horizontal row vector for our filters.
        raw_ecg = signalData'; 
        
    catch
        disp(['Error loading ', record_name, '. Ensure the WFDB toolbox is installed and in your MATLAB path.']);
        continue; 
    end
    
    % ---------------------------------------------------
    % PIPELINE 1: APPLY FIR FILTERS
    % ---------------------------------------------------
    disp(['Applying FIR Pipeline to Record ', record_name, '...']);
    ecg_fir = filtfilt(b_fir_hp, a_fir_hp, raw_ecg);
    ecg_fir = filtfilt(b_fir_notch, a_fir_notch, ecg_fir);
    ecg_fir = filtfilt(b_fir_lp, a_fir_lp, ecg_fir);
    
    snr_fir = compare_signals(raw_ecg, ecg_fir, Fs, ['FIR Pipeline - Record ', record_name]);
    disp(['-> FIR SNR Improvement: ', num2str(snr_fir), ' dB']);

    % ---------------------------------------------------
    % PIPELINE 2: APPLY BUTTERWORTH FILTERS
    % ---------------------------------------------------
    disp(['Applying Butterworth Pipeline to Record ', record_name, '...']);
    ecg_butt = filtfilt(b_butt_hp, a_butt_hp, raw_ecg);
    ecg_butt = filtfilt(b_butt_notch, a_butt_notch, ecg_butt);
    ecg_butt = filtfilt(b_butt_lp, a_butt_lp, ecg_butt);
    
    snr_butt = compare_signals(raw_ecg, ecg_butt, Fs, ['Butterworth Pipeline - Record ', record_name]);
    disp(['-> Butterworth SNR Improvement: ', num2str(snr_butt), ' dB']);
    
    % ---------------------------------------------------
    % PIPELINE 3: APPLY CHEBYSHEV FILTERS
    % ---------------------------------------------------
    disp(['Applying Chebyshev Pipeline to Record ', record_name, '...']);
    ecg_cheb = filtfilt(b_cheb_hp, a_cheb_hp, raw_ecg);
    ecg_cheb = filtfilt(b_cheb_notch, a_cheb_notch, ecg_cheb);
    ecg_cheb = filtfilt(b_cheb_lp, a_cheb_lp, ecg_cheb);
    
    snr_cheb = compare_signals(raw_ecg, ecg_cheb, Fs, ['Chebyshev Pipeline - Record ', record_name]);
    disp(['-> Chebyshev SNR Improvement: ', num2str(snr_cheb), ' dB']);

    % ---------------------------------------------------
    % PIPELINE 4: HYBRID (Butterworth HP/LP + Manual Notch)
    % ---------------------------------------------------
    disp(['Applying Hybrid Pipeline (Manual Notch) to Record ', record_name, '...']);
    ecg_hybrid = filtfilt(b_butt_hp, a_butt_hp, raw_ecg);
    % Swap in our custom Z-Plane math for the notch!
    ecg_hybrid = filtfilt(b_manual_notch, a_manual_notch, ecg_hybrid);
    ecg_hybrid = filtfilt(b_butt_lp, a_butt_lp, ecg_hybrid);
    
    snr_hybrid = compare_signals(raw_ecg, ecg_hybrid, Fs, ['Hybrid Pipeline - Record ', record_name]);
    disp(['-> Hybrid (Manual Notch) SNR Improvement: ', num2str(snr_hybrid), ' dB']);
    
    disp('---------------------------------------------------');
end

disp('Part 1 Execution Complete.');