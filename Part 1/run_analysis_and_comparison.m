% ===================================================
% DIGITAL SIGNAL PROCESSING FINAL PROJECT - PART I
% Master Execution Script for ECG Denoising
% ===================================================
clear; clc; close all; 

%% 1. GLOBAL SETUP & SPECIFICATIONS
Fs = 360; 
Filter_Order = 4; % Hardcoded order for stable IIR filters

% Baseline Wander (High-Pass)
HPF_Fstop = 0.1;   HPF_Fpass = 0.5;   
HPF_Apass = 1;

% Power-line Noise (Notch)
Notch_F0 = 50;     Notch_BW = 2;      

% EMG / Muscle Noise (Low-Pass) - Adjusted to 100Hz per requirements
LPF_Fpass = 100;   LPF_Fstop = 105;    
LPF_Apass = 1;     

records_to_test = {'100', '106'};

%% 2. GENERATE AND ANALYZE THE FILTERS
disp('--- Generating Filters ---');

% Generate FIR Pipeline
[b_fir_hp, a_fir_hp, b_fir_notch, a_fir_notch, b_fir_lp, a_fir_lp] = ...
    design_fir_filters(Fs, HPF_Fstop, HPF_Fpass, Notch_F0, Notch_BW, LPF_Fpass, LPF_Fstop);

% Generate Butterworth Pipeline
[b_butt_hp, a_butt_hp, b_butt_notch, a_butt_notch, b_butt_lp, a_butt_lp] = ...
    design_butterworth_filters(Fs, Filter_Order, HPF_Fpass, Notch_F0, Notch_BW, LPF_Fpass);

% Generate Chebyshev (Type I) Pipeline
[b_cheb_hp, a_cheb_hp, b_cheb_notch, a_cheb_notch, b_cheb_lp, a_cheb_lp] = ...
    design_chebyshev_filters(Fs, Filter_Order, HPF_Fpass, HPF_Apass, Notch_F0, Notch_BW, LPF_Fpass, LPF_Apass);

% Generate Manual Pole-Zero Notch Filter (Radius = 0.99)
[b_manual_notch, a_manual_notch] = design_pole_zero_notch(Fs, Notch_F0, 0.99);

%% 2.5 PRINT COEFFICIENTS FOR REPORT
disp(' ');
disp('===================================================');
disp('   FILTER COEFFICIENTS FOR REPORT (COPY-PASTE)     ');
disp('===================================================');

disp('--- 1. Butterworth Pipeline ---');
fprintf('HPF (Baseline)   [b]: %s\n', mat2str(b_butt_hp, 4));
fprintf('HPF (Baseline)   [a]: %s\n', mat2str(a_butt_hp, 4));
fprintf('Notch (50Hz)     [b]: %s\n', mat2str(b_butt_notch, 4));
fprintf('Notch (50Hz)     [a]: %s\n', mat2str(a_butt_notch, 4));
fprintf('LPF (Muscle)     [b]: %s\n', mat2str(b_butt_lp, 4));
fprintf('LPF (Muscle)     [a]: %s\n', mat2str(a_butt_lp, 4));
disp(' ');

disp('--- 2. Chebyshev Pipeline ---');
fprintf('HPF (Baseline)   [b]: %s\n', mat2str(b_cheb_hp, 4));
fprintf('HPF (Baseline)   [a]: %s\n', mat2str(a_cheb_hp, 4));
fprintf('Notch (50Hz)     [b]: %s\n', mat2str(b_cheb_notch, 4));
fprintf('Notch (50Hz)     [a]: %s\n', mat2str(a_cheb_notch, 4));
fprintf('LPF (Muscle)     [b]: %s\n', mat2str(b_cheb_lp, 4));
fprintf('LPF (Muscle)     [a]: %s\n', mat2str(a_cheb_lp, 4));
disp(' ');

disp('--- 3. Manual Pole-Zero Notch ---');
fprintf('Notch (50Hz)     [b]: %s\n', mat2str(b_manual_notch, 4));
fprintf('Notch (50Hz)     [a]: %s\n', mat2str(a_manual_notch, 4));
disp('===================================================');
disp(' ');

disp('--- Plotting Filter Analysis (This will open 10 windows) ---');
analyze_filter(b_fir_hp, a_fir_hp, Fs, 'FIR High-Pass Filter');
analyze_filter(b_fir_notch, a_fir_notch, Fs, 'FIR Notch Filter');
analyze_filter(b_fir_lp, a_fir_lp, Fs, 'FIR Low-Pass Filter');

analyze_filter(b_butt_hp, a_butt_hp, Fs, 'Butterworth High-Pass Filter');
analyze_filter(b_butt_notch, a_butt_notch, Fs, 'Butterworth Notch Filter');
analyze_filter(b_butt_lp, a_butt_lp, Fs, 'Butterworth Low-Pass Filter');

analyze_filter(b_cheb_hp, a_cheb_hp, Fs, 'Chebyshev High-Pass Filter');
analyze_filter(b_cheb_notch, a_cheb_notch, Fs, 'Chebyshev Notch Filter');
analyze_filter(b_cheb_lp, a_cheb_lp, Fs, 'Chebyshev Low-Pass Filter');

analyze_filter(b_manual_notch, a_manual_notch, Fs, 'Manual Pole-Zero Notch Filter');

%% 3. PROCESS THE PATIENT DATA
for i = 1:length(records_to_test)
    record_name = records_to_test{i};
    disp(['=== Processing MIT-BIH Record: ', record_name, ' ===']);
    
    try
        [signalData, ~] = rdsamp(record_name, 1);
        raw_ecg = signalData'; 
        raw_ecg = raw_ecg(1 : 30*Fs);
        
   catch ME
        fprintf('Error loading %s. The actual MATLAB error is:\n', record_name);
        disp(ME.message); 
        continue; 
   end
   
    disp(['Applying FIR Pipeline to Record ', record_name, '...']);
    ecg_fir = filtfilt(b_fir_hp, a_fir_hp, raw_ecg);
    ecg_fir = filtfilt(b_fir_notch, a_fir_notch, ecg_fir);
    ecg_fir = filtfilt(b_fir_lp, a_fir_lp, ecg_fir);
    snr_fir = compare_signals(raw_ecg, ecg_fir, Fs, ['FIR Pipeline - Record ', record_name]);
    disp(['-> FIR SNR Improvement: ', num2str(snr_fir), ' dB']);

    disp(['Applying Butterworth Pipeline to Record ', record_name, '...']);
    ecg_butt = filtfilt(b_butt_hp, a_butt_hp, raw_ecg);
    ecg_butt = filtfilt(b_butt_notch, a_butt_notch, ecg_butt);
    ecg_butt = filtfilt(b_butt_lp, a_butt_lp, ecg_butt);
    snr_butt = compare_signals(raw_ecg, ecg_butt, Fs, ['Butterworth Pipeline - Record ', record_name]);
    disp(['-> Butterworth SNR Improvement: ', num2str(snr_butt), ' dB']);
    
    disp(['Applying Chebyshev Pipeline to Record ', record_name, '...']);
    ecg_cheb = filtfilt(b_cheb_hp, a_cheb_hp, raw_ecg);
    ecg_cheb = filtfilt(b_cheb_notch, a_cheb_notch, ecg_cheb);
    ecg_cheb = filtfilt(b_cheb_lp, a_cheb_lp, ecg_cheb);
    snr_cheb = compare_signals(raw_ecg, ecg_cheb, Fs, ['Chebyshev Pipeline - Record ', record_name]);
    disp(['-> Chebyshev SNR Improvement: ', num2str(snr_cheb), ' dB']);

    disp(['Applying Hybrid Pipeline (Manual Notch) to Record ', record_name, '...']);
    ecg_hybrid = filtfilt(b_butt_hp, a_butt_hp, raw_ecg);
    ecg_hybrid = filtfilt(b_manual_notch, a_manual_notch, ecg_hybrid);
    ecg_hybrid = filtfilt(b_butt_lp, a_butt_lp, ecg_hybrid);
    snr_hybrid = compare_signals(raw_ecg, ecg_hybrid, Fs, ['Hybrid Pipeline - Record ', record_name]);
    disp(['-> Hybrid (Manual Notch) SNR Improvement: ', num2str(snr_hybrid), ' dB']);
    
    disp('---------------------------------------------------');
end

%% 4. SAVE GENERATED FIGURES (Iterating through all Tabs)
disp('--- Saving Figures & Tabs ---');

base_img_dir = 'Images';
if ~exist(base_img_dir, 'dir')
    mkdir(base_img_dir);
end

% Get all open figures
all_figs = findall(0, 'Type', 'figure');

for f = 1:length(all_figs)
    fig = all_figs(f);
    fig_name = fig.Name;
    
    if isempty(fig_name)
        continue;
    end
    
    % Determine the correct subfolder based on figure name
    if contains(fig_name, 'FIR')
        target_folder = 'FIR';
    elseif contains(fig_name, 'Butterworth')
        target_folder = 'Butterworth';
    elseif contains(fig_name, 'Chebyshev')
        target_folder = 'Chebyshev';
    elseif contains(fig_name, 'Hybrid')
        target_folder = 'Hybrid';
    elseif contains(fig_name, 'Manual')
        target_folder = 'Manual_Notch';
    else
        target_folder = 'Other';
    end
    
    % Create subfolder if it doesn't exist
    full_target_dir = fullfile(base_img_dir, target_folder);
    if ~exist(full_target_dir, 'dir')
        mkdir(full_target_dir);
    end
    
    % Clean up the figure name to make it a valid filename base
    safe_fig_name = regexprep(fig_name, '[^\w\-]', '_');
    
    % Check if the figure has a tab group
    tab_group = findall(fig, 'Type', 'uitabgroup');
    
    if ~isempty(tab_group)
        % Get all tabs in this tab group
        tabs = findall(tab_group(1), 'Type', 'uitab');
        
        % MATLAB returns children in reverse order sometimes, so we loop through them
        for t = 1:length(tabs)
            current_tab = tabs(t);
            tab_title = current_tab.Title;
            
            % Bring this specific tab to the front
            tab_group(1).SelectedTab = current_tab;
            drawnow; % Force MATLAB to render the UI change before saving
            
            safe_tab_name = regexprep(tab_title, '[^\w\-]', '_');
            final_filename = sprintf('%s_%s.png', safe_fig_name, safe_tab_name);
            save_path = fullfile(full_target_dir, final_filename);
            
            % Extract the actual inner graphics container (axes or tiledlayout)
            % This avoids the "UI Container" error and gives a clean plot without gray UI borders
            inner_graphics = current_tab.Children;
            
            try
                if ~isempty(inner_graphics)
                    exportgraphics(inner_graphics(end), save_path, 'Resolution', 300);
                else
                    exportapp(fig, save_path);
                end
            catch
                % Fallback as specifically recommended by MATLAB's error output
                exportapp(fig, save_path);
            end
        end
    else
        % If there are no tabs, just save the figure
        save_path = fullfile(full_target_dir, [safe_fig_name, '.png']);
        
        try
            exportgraphics(fig, save_path, 'Resolution', 300);
        catch
            exportapp(fig, save_path);
        end
    end
end

disp('Part 1 Execution and Image Saving Complete.');