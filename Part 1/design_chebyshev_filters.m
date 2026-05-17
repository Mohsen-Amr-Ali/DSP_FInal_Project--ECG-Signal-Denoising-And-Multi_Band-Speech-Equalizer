function [b_base, a_base, b_notch, a_notch, b_muscle, a_muscle] = design_chebyshev_filters(Fs, Filter_Order, HPF_Fpass, HPF_Apass, Notch_F0, Notch_BW, LPF_Fpass, LPF_Apass)

    Fn = Fs / 2; % Nyquist frequency

    % 1. High-pass Filter (Baseline Wander Removal)
    Wp_base = HPF_Fpass / Fn; 
    [b_base, a_base] = cheby1(Filter_Order, HPF_Apass, Wp_base, 'high');

    % 2. Notch Filter (Power-line Noise Removal)
    Notch_Apass = 1; % Default passband ripple for the notch
    Wn_notch = [(Notch_F0 - Notch_BW/2)/Fn, (Notch_F0 + Notch_BW/2)/Fn];
    [b_notch, a_notch] = cheby1(Filter_Order, Notch_Apass, Wn_notch, 'stop');
    
    % Normalize DC gain to 1.0 (0 dB) to prevent step response offset
    dc_gain = sum(b_notch) / sum(a_notch);
    b_notch = b_notch / dc_gain;

    % 3. Low-pass Filter (Muscle Noise / EMG Removal)
    Wp_muscle = LPF_Fpass / Fn;
    [b_muscle, a_muscle] = cheby1(Filter_Order, LPF_Apass, Wp_muscle, 'low');

    disp('-> IIR Chebyshev Type I Coefficients Computed Successfully.');
end