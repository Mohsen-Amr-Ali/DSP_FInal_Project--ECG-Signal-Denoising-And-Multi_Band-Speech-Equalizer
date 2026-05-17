function [b_base, a_base, b_notch, a_notch, b_muscle, a_muscle] = design_butterworth_filters(Fs, Filter_Order, HPF_Fpass, Notch_F0, Notch_BW, LPF_Fpass)

    Fn = Fs / 2; % Nyquist frequency

    % 1. High-pass Filter (Baseline Wander Removal)
    Wn_base = HPF_Fpass / Fn; 
    [b_base, a_base] = butter(Filter_Order, Wn_base, 'high');

    % 2. Notch Filter (Power-line Noise Removal)
    % Calculate the lower and upper bounds of the notch bandwidth
    Wn_notch = [(Notch_F0 - Notch_BW/2)/Fn, (Notch_F0 + Notch_BW/2)/Fn];
    [b_notch, a_notch] = butter(Filter_Order, Wn_notch, 'stop');

    % 3. Low-pass Filter (Muscle Noise / EMG Removal)
    Wn_muscle = LPF_Fpass / Fn;
    [b_muscle, a_muscle] = butter(Filter_Order, Wn_muscle, 'low');

    disp('-> IIR Butterworth Coefficients Computed Successfully (Hardcoded Order).');
end