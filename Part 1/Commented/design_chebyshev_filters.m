function [b_base, a_base, b_notch, a_notch, b_muscle, a_muscle] = design_chebyshev_filters(Fs, HPF_Fstop, HPF_Fpass, HPF_Astop, HPF_Apass, Notch_F0, Notch_BW, Notch_Astop, LPF_Fpass, LPF_Fstop, LPF_Apass, LPF_Astop)
% ===================================================
% IIR CHEBYSHEV (TYPE I) FILTER DESIGN
% Utilizes 'cheb1ord' to calculate the minimum filter order. 
% Trades a perfectly flat passband (allows ripple) for a much 
% steeper transition into the stopband compared to Butterworth.
% ===================================================

    % 1. Nyquist Frequency
    Fn = Fs / 2; 

    % ---------------------------------------------------
    % Filter 1: High-Pass Filter (Baseline Wander)
    % ---------------------------------------------------
    % Normalize frequencies
    Wp_base = HPF_Fpass / Fn; 
    Ws_base = HPF_Fstop / Fn; 
    
    % Calculate minimum order (N) and optimal cutoff (Wp) for Chebyshev
    [N_base, Wp_opt_base] = cheb1ord(Wp_base, Ws_base, HPF_Apass, HPF_Astop);
    
    % Generate coefficients. 
    % cheby1 requires the allowable Passband Ripple (HPF_Apass) as a direct input.
    [b_base, a_base] = cheby1(N_base, HPF_Apass, Wp_opt_base, 'high');

    % ---------------------------------------------------
    % Filter 2: Notch Filter (Power-line 50 Hz)
    % ---------------------------------------------------
    % Define the strict Stopband (49 to 51 Hz)
    Ws_notch = [(Notch_F0 - Notch_BW/2)/Fn, (Notch_F0 + Notch_BW/2)/Fn];
    
    % Define the Passband (48 to 52 Hz)
    Wp_notch = [(Notch_F0 - Notch_BW)/Fn, (Notch_F0 + Notch_BW)/Fn];
    
    % Assume 1 dB passband ripple for the calculation
    Notch_Apass = 1; 
    
    % Calculate exact minimum order
    [N_notch, Wp_opt_notch] = cheb1ord(Wp_notch, Ws_notch, Notch_Apass, Notch_Astop);
    
    % Generate Notch (Band-Stop) coefficients
    [b_notch, a_notch] = cheby1(N_notch, Notch_Apass, Wp_opt_notch, 'stop');

    % ---------------------------------------------------
    % Filter 3: Low-Pass Filter (Muscle Noise)
    % ---------------------------------------------------
    % Normalize frequencies
    Wp_muscle = LPF_Fpass / Fn;
    Ws_muscle = LPF_Fstop / Fn;
    
    % Calculate minimum order
    [N_muscle, Wp_opt_muscle] = cheb1ord(Wp_muscle, Ws_muscle, LPF_Apass, LPF_Astop);
    
    % Generate Low-Pass coefficients
    [b_muscle, a_muscle] = cheby1(N_muscle, LPF_Apass, Wp_opt_muscle, 'low');

    % Display success message to console
    disp('-> IIR Chebyshev Type I Coefficients Computed Successfully.');
end