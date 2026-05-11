function [b_base, a_base, b_notch, a_notch, b_muscle, a_muscle] = design_fir_filters(Fs, HPF_Fstop, HPF_Fpass, Notch_F0, Notch_BW, LPF_Fpass, LPF_Fstop)
% ===================================================
% FIR FILTER DESIGN (WINDOW-BASED)
% Uses the Hamming window method to calculate precise filter orders 
% based on defined transition bandwidths.
% ===================================================

    % 1. Nyquist Frequency (The maximum limit)
    Fn = Fs / 2; 

    % ---------------------------------------------------
    % Filter 1: High-Pass Filter (Baseline Wander)
    % ---------------------------------------------------
    % Calculate Transition Bandwidth (Hz)
    delta_f_base = HPF_Fpass - HPF_Fstop; 
    
    % Calculate minimum required order for Hamming Window
    N_base = round(3.3 * (Fs / delta_f_base)); 
    
    % FIR High-pass rule: The order must be an EVEN number. 
    % If odd, the response drops to 0 at the Nyquist frequency, ruining the filter.
    if mod(N_base, 2) ~= 0
        N_base = N_base + 1; 
    end
    
    % Normalized Cutoff Frequency (Scale of 0 to 1)
    Wn_base = HPF_Fpass / Fn; 
    
    % Generate Coefficients (fir1 defaults to Hamming window if not specified, 
    % but we explicitly declare it for academic clarity)
    b_base = fir1(N_base, Wn_base, 'high', hamming(N_base + 1));
    a_base = 1; % FIR has no feedback loop

    % ---------------------------------------------------
    % Filter 2: Notch Filter (Power-line 50 Hz)
    % ---------------------------------------------------
    % A Notch is a Band-Stop filter. Define the upper and lower bounds.
    f_notch_lower = Notch_F0 - (Notch_BW / 2);
    f_notch_upper = Notch_F0 + (Notch_BW / 2);
    
    % For a notch, the transition band is roughly the bandwidth itself
    delta_f_notch = Notch_BW; 
    N_notch = round(3.3 * (Fs / delta_f_notch));
    
    % Normalized cutoffs as a 2-element array [lower, upper]
    Wn_notch = [f_notch_lower/Fn, f_notch_upper/Fn];
    
    % Generate Band-Stop coefficients
    b_notch = fir1(N_notch, Wn_notch, 'stop', hamming(N_notch + 1));
    a_notch = 1;

    % ---------------------------------------------------
    % Filter 3: Low-Pass Filter (Muscle Noise)
    % ---------------------------------------------------
    % Calculate Transition Bandwidth
    delta_f_muscle = LPF_Fstop - LPF_Fpass;
    
    % Calculate Order
    N_muscle = round(3.3 * (Fs / delta_f_muscle));
    
    % Normalized cutoff
    Wn_muscle = LPF_Fpass / Fn;
    
    % Generate Low-Pass coefficients
    b_muscle = fir1(N_muscle, Wn_muscle, 'low', hamming(N_muscle + 1));
    a_muscle = 1;

    disp('-> FIR Coefficients Computed Successfully.');
end