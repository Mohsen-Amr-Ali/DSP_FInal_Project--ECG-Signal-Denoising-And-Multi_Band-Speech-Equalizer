function analyze_filter(b, a, Fs, filter_name)
% ===================================================
% FILTER ANALYSIS TOOL
% Generates the 4 required mathematical proofs of the filter's 
% characteristics: Frequency Response, Impulse, Step, and Pole-Zero.
% ===================================================

    % Create a new figure window with the filter's name
    figure('Name', filter_name, 'NumberTitle', 'off', 'Position', [100, 100, 900, 700]);
    
    % ---------------------------------------------------
    % Plot 1: Frequency Response (Magnitude and Phase)
    % ---------------------------------------------------
    % Calculate the frequency response using freqz (1024 evaluation points)
    [h, f] = freqz(b, a, 1024, Fs);
    
    % Span the top half of the figure
    subplot(3, 2, [1, 2]); 
    
    % Plot Magnitude (dB) on the Left Y-Axis
    yyaxis left;
    plot(f, 20*log10(abs(h)), 'LineWidth', 1.5, 'Color', '#0072BD');
    ylabel('Magnitude (dB)');
    ylim([-100 5]); % Lock the view so we can easily compare filters
    
    % Plot Phase (unwrapped radians) on the Right Y-Axis
    yyaxis right;
    plot(f, unwrap(angle(h)), 'LineWidth', 1.5, 'Color', '#D95319');
    ylabel('Phase (rad)');
    
    title([filter_name, ' - Frequency Response']);
    xlabel('Frequency (Hz)');
    grid on;

    % ---------------------------------------------------
    % Dynamic Sample Calculation for Time-Domain Plots
    % ---------------------------------------------------
    % If it's an FIR filter, length(b) is huge. We want to see the whole thing.
    % If it's an IIR filter, length(b) is tiny, so we default to 100 samples to see the fade.
    if length(a) == 1 && a == 1
        num_samples = length(b) + 50; % FIR: Show full window + 50 padding
    else
        num_samples = 150; % IIR: 150 samples is enough to see the feedback die out
    end

    % ---------------------------------------------------
    % Plot 2: Impulse Response
    % ---------------------------------------------------
    subplot(3, 2, 3);
    impz(b, a, num_samples, Fs);
    title('Impulse Response');
    grid on;

    % ---------------------------------------------------
    % Plot 3: Step Response
    % ---------------------------------------------------
    subplot(3, 2, 4);
    stepz(b, a, num_samples, Fs);
    title('Step Response');
    grid on;

    % ---------------------------------------------------
    % Plot 4: Pole-Zero Plot
    % ---------------------------------------------------
    % Span the bottom half of the figure
    subplot(3, 2, [5, 6]);
    zplane(b, a);
    title('Pole-Zero Plot');
    grid on;
    
    % Add a super title for the whole figure
    sgtitle(['Full Analysis: ', filter_name]);
end