function [b_base, a_base, b_notch, a_notch, b_muscle, a_muscle] = design_butterworth_filters(Fs, HPF_Fstop, HPF_Fpass, HPF_Astop, HPF_Apass, Notch_F0, Notch_BW, Notch_Astop, LPF_Fpass, LPF_Fstop, LPF_Apass, LPF_Astop)

    Fn = Fs / 2; 

    Wp_base = HPF_Fpass / Fn; 

    Ws_base = HPF_Fstop / Fn; 

    [N_base, Wn_base] = buttord(Wp_base, Ws_base, HPF_Apass, HPF_Astop);

    [b_base, a_base] = butter(N_base, Wn_base, 'high');

    Ws_notch = [(Notch_F0 - Notch_BW/2)/Fn, (Notch_F0 + Notch_BW/2)/Fn];

    Wp_notch = [(Notch_F0 - Notch_BW)/Fn, (Notch_F0 + Notch_BW)/Fn];

    Notch_Apass = 1; 

    [N_notch, Wn_notch] = buttord(Wp_notch, Ws_notch, Notch_Apass, Notch_Astop);

    [b_notch, a_notch] = butter(N_notch, Wn_notch, 'stop');

    Wp_muscle = LPF_Fpass / Fn;
    Ws_muscle = LPF_Fstop / Fn;

    [N_muscle, Wn_muscle] = buttord(Wp_muscle, Ws_muscle, LPF_Apass, LPF_Astop);

    [b_muscle, a_muscle] = butter(N_muscle, Wn_muscle, 'low');

    disp('-> IIR Butterworth Coefficients Computed Successfully.');
end