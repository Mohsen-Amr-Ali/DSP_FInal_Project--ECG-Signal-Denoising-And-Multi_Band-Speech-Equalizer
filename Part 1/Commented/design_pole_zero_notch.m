function [b_notch, a_notch] = design_pole_zero_notch(Fs, Notch_F0, r)
% ===================================================
% MANUAL POLE-ZERO NOTCH FILTER DESIGN
% Designs a pure IIR notch filter from scratch by manually placing 
% complex conjugate zeros on the unit circle and poles slightly inside it.
% ===================================================
    
    % Ensure the radius (r) is provided, otherwise default to 0.99
    % The closer 'r' is to 1, the tighter and sharper the notch.
    if nargin < 3
        r = 0.99; 
    end

    % Step 1: Calculate the exact angle (theta) for 50 Hz on the Z-plane.
    % Formula: (Target Frequency / Sampling Frequency) * 2 * pi
    theta = (Notch_F0 / Fs) * 2 * pi;

    % Step 2: Calculate the 'b' coefficients (The Zeros)
    % A pair of complex conjugate zeros on the unit circle expands algebraically to:
    % (z - e^(j*theta)) * (z - e^(-j*theta)) = z^2 - 2*cos(theta)*z + 1
    % The coefficients are just the multipliers of z: [1, -2*cos(theta), 1]
    
    b0 = 1;
    b1 = -2 * cos(theta);
    b2 = 1;
    b_notch = [b0, b1, b2];

    % Step 3: Calculate the 'a' coefficients (The Poles)
    % A pair of complex conjugate poles at radius 'r' expands algebraically to:
    % (z - r*e^(j*theta)) * (z - r*e^(-j*theta)) = z^2 - 2*r*cos(theta)*z + r^2
    % The coefficients are: [1, -2*r*cos(theta), r^2]
    
    a0 = 1;
    a1 = -2 * r * cos(theta);
    a2 = r^2;
    a_notch = [a0, a1, a2];

    % Display success message
    disp(['-> Manual Pole-Zero Notch Coefficients Computed (r = ', num2str(r), ').']);
end