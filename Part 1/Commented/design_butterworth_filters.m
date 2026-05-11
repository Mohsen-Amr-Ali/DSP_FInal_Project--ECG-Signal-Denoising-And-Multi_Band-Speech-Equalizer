function [b_base, a_base, b_notch, a_notch, b_muscle, a_muscle] = design_butterworth_filters(Fs, HPF_Fstop, HPF_Fpass, HPF_Astop, HPF_Apass, Notch_F0, Notch_BW, Notch_Astop, LPF_Fpass, LPF_Fstop, LPF_Apass, LPF_Astop)
% ===================================================
% IIR BUTTERWORTH FILTER DESIGN
% Utilizes 'buttord' to mathematically calculate the exact minimum 
% filter order required to meet strict passband and stopband specifications,
% ensuring a maximally flat passband (no ripples) for the ECG.
% ===================================================

    % 1. Nyquist Frequency
    Fn = Fs / 2; 

    % ---------------------------------------------------
    % Filter 1: High-Pass Filter (Baseline Wander)
    % ---------------------------------------------------
    % Normalize frequencies
    Wp_base = HPF_Fpass / Fn; % Passband boundary
    Ws_base = HPF_Fstop / Fn; % Stopband boundary
    
    % buttord calculates the minimum order (N) and the exact cutoff frequency (Wn) 
    % needed to meet our decibel (dB) specifications.
    [N_base, Wn_base] = buttord(Wp_base, Ws_base, HPF_Apass, HPF_Astop);
    
    % Generate the feedback (a) and feedforward (b) coefficients
    [b_base, a_base] = butter(N_base, Wn_base, 'high');

    % ---------------------------------------------------
    % Filter 2: Notch Filter (Power-line 50 Hz)
    % ---------------------------------------------------
    % A Notch is a Band-Stop filter. 
    % Stopband: The strict 2Hz zone we want to crush (49 to 51 Hz)
    Ws_notch = [(Notch_F0 - Notch_BW/2)/Fn, (Notch_F0 + Notch_BW/2)/Fn];
    
    % Passband: We need to define where the signal is allowed to pass freely again.
    % We will set the passband to be 1 Hz wider on each side (48 to 52 Hz)
    Wp_notch = [(Notch_F0 - Notch_BW)/Fn, (Notch_F0 + Notch_BW)/Fn];
    
    % Assume 1 dB passband ripple for the notch computation
    Notch_Apass = 1; 
    
    % Calculate minimum order
    [N_notch, Wn_notch] = buttord(Wp_notch, Ws_notch, Notch_Apass, Notch_Astop);
    
    % Generate coefficients
    [b_notch, a_notch] = butter(N_notch, Wn_notch, 'stop');

    % ---------------------------------------------------
    % Filter 3: Low-Pass Filter (Muscle Noise)
    % ---------------------------------------------------
    % Normalize frequencies
    Wp_muscle = LPF_Fpass / Fn;
    Ws_muscle = LPF_Fstop / Fn;
    
    % Calculate exact minimum order
    [N_muscle, Wn_muscle] = buttord(Wp_muscle, Ws_muscle, LPF_Apass, LPF_Astop);
    
    % Generate Low-Pass coefficients
    [b_muscle, a_muscle] = butter(N_muscle, Wn_muscle, 'low');

    % Display success message to console
    disp('-> IIR Butterworth Coefficients Computed Successfully.');
end