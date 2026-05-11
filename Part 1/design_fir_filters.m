function [b_base, a_base, b_notch, a_notch, b_muscle, a_muscle] = design_fir_filters(Fs, HPF_Fstop, HPF_Fpass, Notch_F0, Notch_BW, LPF_Fpass, LPF_Fstop)

    Fn = Fs / 2; 

    delta_f_base = HPF_Fpass - HPF_Fstop; 

    N_base = round(3.3 * (Fs / delta_f_base)); 

    if mod(N_base, 2) ~= 0
        N_base = N_base + 1; 
    end

    Wn_base = HPF_Fpass / Fn; 

    b_base = fir1(N_base, Wn_base, 'high', hamming(N_base + 1));
    a_base = 1; 

    f_notch_lower = Notch_F0 - (Notch_BW / 2);
    f_notch_upper = Notch_F0 + (Notch_BW / 2);

    delta_f_notch = Notch_BW; 
    N_notch = round(3.3 * (Fs / delta_f_notch));

    Wn_notch = [f_notch_lower/Fn, f_notch_upper/Fn];

    b_notch = fir1(N_notch, Wn_notch, 'stop', hamming(N_notch + 1));
    a_notch = 1;

    delta_f_muscle = LPF_Fstop - LPF_Fpass;

    N_muscle = round(3.3 * (Fs / delta_f_muscle));

    Wn_muscle = LPF_Fpass / Fn;

    b_muscle = fir1(N_muscle, Wn_muscle, 'low', hamming(N_muscle + 1));
    a_muscle = 1;

    disp('-> FIR Coefficients Computed Successfully.');
end