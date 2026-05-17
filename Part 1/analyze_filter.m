function analyze_filter(b, a, Fs, filter_name)

    % Create a single, nicely sized figure window
    fig = figure('Name', filter_name, 'NumberTitle', 'off', 'Position', [100, 100, 1000, 700]);
    
    % Create the Tab Group
    tg = uitabgroup(fig);

    % ==========================================
    % TAB 1: FREQUENCY RESPONSE (Stacked Bode)
    % ==========================================
    tab1 = uitab(tg, 'Title', 'Frequency Response');
    t1 = tiledlayout(tab1, 2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(t1, ['Frequency Response: ', filter_name], 'FontWeight', 'bold', 'FontSize', 14);

    % Use 4096 points for high resolution (ensures tight notches are captured)
    [h, f] = freqz(b, a, 4096, Fs);

    % --- Magnitude Response (Top) ---
    ax_mag = nexttile(t1); 
    mag_db = 20*log10(abs(h));
    plot(ax_mag, f, mag_db, 'LineWidth', 1.5, 'Color', '#0072BD');
    title(ax_mag, 'Magnitude Response');
    ylabel(ax_mag, 'Magnitude (dB)');
    xlabel(ax_mag, 'Frequency (Hz)');
    ylim(ax_mag, [-100, max(mag_db) + 5]); 
    grid(ax_mag, 'on');

    % --- Phase Response (Bottom) ---
    % Use standard wrapped phase in degrees (fixes unreadable manual unwrapping)
    ax_phase = nexttile(t1); 
    phase_deg = angle(h) * (180 / pi); 
    plot(ax_phase, f, phase_deg, 'LineWidth', 1.5, 'Color', '#D95319');
    title(ax_phase, 'Phase Response');
    ylabel(ax_phase, 'Phase (degrees)');
    xlabel(ax_phase, 'Frequency (Hz)');
    grid(ax_phase, 'on');

    % ==========================================
    % TAB 2: TIME & Z-DOMAIN
    % ==========================================
    tab2 = uitab(tg, 'Title', 'Time & Z-Domain');
    t2 = tiledlayout(tab2, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(t2, ['Time & Z-Domain: ', filter_name], 'FontWeight', 'bold', 'FontSize', 14);

    % Forced 2048 samples per the TA's model answer
    num_samples = 2048; 

    % --- Impulse Response (Top Left) ---
    ax_imp = nexttile(t2, 1);
    [h_imp, t_imp] = impz(b, a, num_samples, Fs);
    
    if length(h_imp) > 200
        stem(ax_imp, t_imp, h_imp, 'Marker', 'none', 'Color', '#0072BD');
    else
        stem(ax_imp, t_imp, h_imp, 'filled', 'MarkerSize', 4, 'Color', '#0072BD');
    end
    
    title(ax_imp, 'Impulse Response');
    grid(ax_imp, 'on');
    xlabel(ax_imp, 'Time (s)');
    ylabel(ax_imp, 'Amplitude');

    % --- Step Response (Top Right) ---
    ax_step = nexttile(t2, 2);
    [s_step, t_step] = stepz(b, a, num_samples, Fs);
    
    stairs(ax_step, t_step, s_step, 'LineWidth', 1.5, 'Color', '#D95319');
    title(ax_step, 'Step Response');
    grid(ax_step, 'on');
    xlabel(ax_step, 'Time (s)');
    ylabel(ax_step, 'Amplitude');

    % --- Pole-Zero Plot (Bottom Row) ---
    ax_pz = nexttile(t2, 3, [1 2]); 
    
    % Fix instability artifact for high-order FIRs
    if length(b) > 100 || length(a) > 100
        text(ax_pz, 0, 0, 'Filter order too high for stable Pole-Zero visualization.', ...
            'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 11);
        axis(ax_pz, [-1 1 -1 1]);
        set(ax_pz, 'XTick', [], 'YTick', []); % Hide axes for the message
        title(ax_pz, 'Pole-Zero Plot (Omitted)');
    else
        [z, p, ~] = tf2zpk(b, a);
        
        theta = linspace(0, 2*pi, 100);
        plot(ax_pz, cos(theta), sin(theta), 'k--', 'LineWidth', 1);
        hold(ax_pz, 'on');
        xline(ax_pz, 0, 'k:');
        yline(ax_pz, 0, 'k:');
        
        if ~isempty(p)
            plot(ax_pz, real(p), imag(p), 'bx', 'MarkerSize', 8, 'LineWidth', 1.5);
        end
        if ~isempty(z)
            plot(ax_pz, real(z), imag(z), 'ro', 'MarkerSize', 8, 'LineWidth', 1.5);
        end
        hold(ax_pz, 'off');
        
        title(ax_pz, 'Pole-Zero Plot');
        xlabel(ax_pz, 'Real Part');
        ylabel(ax_pz, 'Imaginary Part');
        grid(ax_pz, 'on');
        
        % Dynamic bounds to ensure no poles/zeros are missed
        max_val = max([1; abs(z); abs(p)]) * 1.1;
        axis(ax_pz, 'equal'); 
        xlim(ax_pz, [-max_val max_val]);
        ylim(ax_pz, [-max_val max_val]);
    end
end