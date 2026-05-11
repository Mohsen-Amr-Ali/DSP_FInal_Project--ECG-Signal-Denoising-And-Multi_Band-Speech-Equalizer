function snr_improvement = compare_signals(raw_sig, clean_sig, Fs, pipeline_name)

    power_initial_noise = var(raw_sig); 

    power_signal = var(clean_sig);

    noise_removed = raw_sig - clean_sig;
    power_noise_removed = var(noise_removed);

    snr_initial = 10 * log10(power_signal / power_initial_noise);

    snr_final = 10 * log10(power_signal / power_noise_removed);

    snr_improvement = snr_final - snr_initial;

    figure('Name', [pipeline_name, ' - Time Domain'], 'NumberTitle', 'off', 'Position', [150, 150, 900, 400]);
    t = (0:length(raw_sig)-1) / Fs; 

    plot(t, raw_sig, 'r', 'LineWidth', 1);
    hold on;
    plot(t, clean_sig, 'b', 'LineWidth', 1.5);
    hold off;

    title([pipeline_name, ' - Time Domain Comparison']);
    xlabel('Time (seconds)');
    ylabel('Amplitude (mV)');
    legend('Raw Noisy Signal', 'Clean Filtered Signal');
    grid on;

    figure('Name', [pipeline_name, ' - PSD'], 'NumberTitle', 'off', 'Position', [200, 200, 900, 400]);

    window_size = round(2 * Fs); 
    overlap = round(window_size / 2); 
% overlap is standard for Welch

    [P_raw, F_raw] = pwelch(raw_sig, hamming(window_size), overlap, window_size, Fs);
    [P_clean, F_clean] = pwelch(clean_sig, hamming(window_size), overlap, window_size, Fs);

    plot(F_raw, 10*log10(P_raw), 'r', 'LineWidth', 1);
    hold on;
    plot(F_clean, 10*log10(P_clean), 'b', 'LineWidth', 1.5);
    hold off;

    title([pipeline_name, ' - Power Spectral Density (Welch Method)']);
    xlabel('Frequency (Hz)');
    ylabel('Power/Frequency (dB/Hz)');
    legend('Raw Signal', 'Filtered Signal');
    xlim([0 Fs/2]); 

    grid on;

    figure('Name', [pipeline_name, ' - Spectrograms'], 'NumberTitle', 'off', 'Position', [250, 250, 900, 600]);

    subplot(2, 1, 1);
    spectrogram(raw_sig, hamming(window_size), overlap, window_size, Fs, 'yaxis');
    title(['Raw Signal Spectrogram - ', pipeline_name]);
    caxis([-140 -20]); 

    subplot(2, 1, 2);
    spectrogram(clean_sig, hamming(window_size), overlap, window_size, Fs, 'yaxis');
    title(['Clean Signal Spectrogram - ', pipeline_name]);
    caxis([-140 -20]);

    colormap('parula');
end