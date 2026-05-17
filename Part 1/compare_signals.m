function snr_improvement = compare_signals(raw_sig, clean_sig, Fs, pipeline_name)

    % ==========================================
    % QUANTITATIVE INDICATOR: SNR IMPROVEMENT
    % ==========================================
    power_initial_noise = var(raw_sig); 
    power_signal = var(clean_sig);

    noise_removed = raw_sig - clean_sig;
    power_noise_removed = var(noise_removed);

    snr_initial = 10 * log10(power_signal / power_initial_noise);
    snr_final = 10 * log10(power_signal / power_noise_removed);
    snr_improvement = snr_final - snr_initial;

    % Create a single, nicely sized figure window for comparison
    fig = figure('Name', ['Comparison: ', pipeline_name], 'NumberTitle', 'off', 'Position', [150, 150, 1000, 700]);
    
    % Create the Tab Group
    tg = uitabgroup(fig);

    % ==========================================
    % TAB 1: TIME DOMAIN
    % ==========================================
    tab1 = uitab(tg, 'Title', 'Time Domain');
    ax1 = axes('Parent', tab1); % Target the tab
    
    t = (0:length(raw_sig)-1) / Fs; 

    plot(ax1, t, raw_sig, 'r', 'LineWidth', 1);
    hold(ax1, 'on');
    plot(ax1, t, clean_sig, 'b', 'LineWidth', 1.5);
    hold(ax1, 'off');

    title(ax1, [pipeline_name, ' - Time Domain Comparison'], 'FontWeight', 'bold', 'FontSize', 12);
    xlabel(ax1, 'Time (seconds)');
    ylabel(ax1, 'Amplitude (mV)');
    legend(ax1, 'Raw Noisy Signal', 'Clean Filtered Signal');
    grid(ax1, 'on');

    % ==========================================
    % TAB 2: POWER SPECTRAL DENSITY (PSD)
    % ==========================================
    tab2 = uitab(tg, 'Title', 'PSD');
    ax2 = axes('Parent', tab2);

    window_size = round(2 * Fs); 
    overlap = round(window_size / 2); % standard for Welch

    [P_raw, F_raw] = pwelch(raw_sig, hamming(window_size), overlap, window_size, Fs);
    [P_clean, F_clean] = pwelch(clean_sig, hamming(window_size), overlap, window_size, Fs);

    plot(ax2, F_raw, 10*log10(P_raw), 'r', 'LineWidth', 1);
    hold(ax2, 'on');
    plot(ax2, F_clean, 10*log10(P_clean), 'b', 'LineWidth', 1.5);
    hold(ax2, 'off');

    title(ax2, [pipeline_name, ' - Power Spectral Density (Welch Method)'], 'FontWeight', 'bold', 'FontSize', 12);
    xlabel(ax2, 'Frequency (Hz)');
    ylabel(ax2, 'Power/Frequency (dB/Hz)');
    legend(ax2, 'Raw Signal', 'Filtered Signal');
    xlim(ax2, [0 Fs/2]); 
    grid(ax2, 'on');

    % ==========================================
    % TAB 3: SPECTROGRAMS
    % ==========================================
    tab2 = uitab(tg, 'Title', 'Spectrograms');
    t3 = tiledlayout(tab2, 2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(t3, [pipeline_name, ' - Spectrograms'], 'FontWeight', 'bold', 'FontSize', 12);

    % Top: Raw Signal Spectrogram
    ax3_top = nexttile(t3);
    spectrogram(raw_sig, hamming(window_size), overlap, window_size, Fs, 'yaxis');
    title(ax3_top, 'Raw Signal Spectrogram');
    caxis(ax3_top, [-140 -20]); 

    % Bottom: Clean Signal Spectrogram
    ax3_bottom = nexttile(t3);
    spectrogram(clean_sig, hamming(window_size), overlap, window_size, Fs, 'yaxis');
    title(ax3_bottom, 'Clean Signal Spectrogram');
    caxis(ax3_bottom, [-140 -20]);

    % Apply colormap to the figure
    colormap(fig, 'parula');
end