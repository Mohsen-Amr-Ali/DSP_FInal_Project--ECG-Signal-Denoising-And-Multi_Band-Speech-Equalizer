function analyze_filter(b, a, Fs, filter_name)

    figure('Name', filter_name, 'NumberTitle', 'off', 'Position', [100, 100, 900, 700]);

    [h, f] = freqz(b, a, 1024, Fs);

    subplot(3, 2, [1, 2]); 

    yyaxis left;
    plot(f, 20*log10(abs(h)), 'LineWidth', 1.5, 'Color', '#0072BD');
    ylabel('Magnitude (dB)');
    ylim([-100 5]); 

    yyaxis right;
    plot(f, unwrap(angle(h)), 'LineWidth', 1.5, 'Color', '#D95319');
    ylabel('Phase (rad)');

    title([filter_name, ' - Frequency Response']);
    xlabel('Frequency (Hz)');
    grid on;

    if length(a) == 1 && a == 1
        num_samples = length(b) + 50; 

    else
        num_samples = 150; 

    end

    subplot(3, 2, 3);
    impz(b, a, num_samples, Fs);
    title('Impulse Response');
    grid on;

    subplot(3, 2, 4);
    stepz(b, a, num_samples, Fs);
    title('Step Response');
    grid on;

    subplot(3, 2, [5, 6]);
    zplane(b, a);
    title('Pole-Zero Plot');
    grid on;

    sgtitle(['Full Analysis: ', filter_name]);
end