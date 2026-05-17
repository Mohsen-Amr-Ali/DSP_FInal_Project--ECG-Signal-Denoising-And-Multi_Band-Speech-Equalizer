function [b_notch, a_notch] = design_pole_zero_notch(Fs, Notch_F0, r)

    if nargin < 3
        r = 0.99; 
    end

    theta = (Notch_F0 / Fs) * 2 * pi;

    b0 = 1;
    b1 = -2 * cos(theta);
    b2 = 1;
    b_notch = [b0, b1, b2];

    a0 = 1;
    a1 = -2 * r * cos(theta);
    a2 = r^2;
    a_notch = [a0, a1, a2];

    % Normalize DC gain to 1.0 (0 dB) to prevent DC shifts in output
    dc_gain = sum(b_notch) / sum(a_notch);
    b_notch = b_notch / dc_gain;

    disp(['-> Manual Pole-Zero Notch Coefficients Computed (r = ', num2str(r), ').']);
end