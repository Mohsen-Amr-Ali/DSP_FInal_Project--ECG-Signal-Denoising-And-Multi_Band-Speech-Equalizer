function snr_improvement = compare_signals(raw_sig, clean_sig, Fs, pipeline_name)
% ===================================================
% SIGNAL VALIDATION & COMPARISON TOOL
% Evaluates filter performance by plotting the Time-Domain, 
% Power Spectral Density (Welch), and Spectrograms. 
% Calculates and returns the estimated SNR improvement.
% ===================================================

    % ---------------------------------------------------
    % Step 1: Calculate Signal-to-Noise Ratio (SNR) Improvement
    % ---------------------------------------------------
    % We use variance (var) to calculate the AC power of the signals.
    
    % Power of the original noisy signal
    power_initial_noise = var(raw_sig); 
    
    % Assume the filtered signal represents the "true" clean heartbeat
    power_signal = var(clean_sig);
    
    % The noise we successfully removed is the difference between raw and clean
    noise_removed = raw_sig - clean_sig;
    power_noise_removed = var(noise_removed);
    
    % Calculate SNR before filtering (Estimate)
    snr_initial = 10 * log10(power_signal / power_initial_noise);
    
    % Calculate SNR after filtering
    snr_final = 10 * log10(power_signal / power_noise_removed);
    
    % Total Improvement
    snr_improvement = snr_final - snr_initial;

    % ---------------------------------------------------
    % Step 2: Time-Domain Plot
    % ---------------------------------------------------
    figure('Name', [pipeline_name, ' - Time Domain'], 'NumberTitle', 'off', 'Position', [150, 150, 900, 400]);
    t = (0:length(raw_sig)-1) / Fs; % Generate time axis in seconds
    
    % Plot raw (red) and clean (blue) overlapping for direct comparison
    plot(t, raw_sig, 'r', 'LineWidth', 1);
    hold on;
    plot(t, clean_sig, 'b', 'LineWidth', 1.5);
    hold off;
    
    title([pipeline_name, ' - Time Domain Comparison']);
    xlabel('Time (seconds)');
    ylabel('Amplitude (mV)');
    legend('Raw Noisy Signal', 'Clean Filtered Signal');
    grid on;

    % ---------------------------------------------------
    % Step 3: Power Spectral Density (Welch's Method)
    % ---------------------------------------------------
    figure('Name', [pipeline_name, ' - PSD'], 'NumberTitle', 'off', 'Position', [200, 200, 900, 400]);
    
    % We define a Hamming window of roughly 2 seconds to smooth the Welch estimate
    window_size = round(2 * Fs); 
    overlap = round(window_size / 2); % 50% overlap is standard for Welch
    
    % Calculate PSD
    [P_raw, F_raw] = pwelch(raw_sig, hamming(window_size), overlap, window_size, Fs);
    [P_clean, F_clean] = pwelch(clean_sig, hamming(window_size), overlap, window_size, Fs);
    
    % Plot PSD in Decibels (10*log10)
    plot(F_raw, 10*log10(P_raw), 'r', 'LineWidth', 1);
    hold on;
    plot(F_clean, 10*log10(P_clean), 'b', 'LineWidth', 1.5);
    hold off;
    
    title([pipeline_name, ' - Power Spectral Density (Welch Method)']);
    xlabel('Frequency (Hz)');
    ylabel('Power/Frequency (dB/Hz)');
    legend('Raw Signal', 'Filtered Signal');
    xlim([0 Fs/2]); % Only show up to Nyquist
    grid on;

    % ---------------------------------------------------
    % Step 4: Spectrogram (Time-Frequency Heatmap)
    % ---------------------------------------------------
    figure('Name', [pipeline_name, ' - Spectrograms'], 'NumberTitle', 'off', 'Position', [250, 250, 900, 600]);
    
    % Spectrogram for Raw Signal
    subplot(2, 1, 1);
    spectrogram(raw_sig, hamming(window_size), overlap, window_size, Fs, 'yaxis');
    title(['Raw Signal Spectrogram - ', pipeline_name]);
    caxis([-140 -20]); % Lock the color scale so before/after colors match exactly
    
    % Spectrogram for Clean Signal
    subplot(2, 1, 2);
    spectrogram(clean_sig, hamming(window_size), overlap, window_size, Fs, 'yaxis');
    title(['Clean Signal Spectrogram - ', pipeline_name]);
    caxis([-140 -20]);
    
    % Ensure colorbars match visually
    colormap('parula');
end