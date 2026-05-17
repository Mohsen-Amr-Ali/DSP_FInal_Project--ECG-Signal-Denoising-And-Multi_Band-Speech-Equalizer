% ===================================================
% DIGITAL SIGNAL PROCESSING FINAL PROJECT - PART I
% Final Execution Script (Mixed Pipeline)
% ===================================================
clear; clc; close all; 

%% 1. GLOBAL SETUP
Fs = 360; 
records_to_test = {'100', '106'};

%% 2. PROCESS PATIENT DATA WITH FINAL PIPELINE
disp('--- Running Final Mixed Pipeline ---');

for i = 1:length(records_to_test)
    record_name = records_to_test{i};
    disp(['=== Processing MIT-BIH Record: ', record_name, ' ===']);
    
    try
        % Load MIT-BIH Data
        [signalData, ~] = rdsamp(record_name, 1);
        raw_ecg = signalData'; 
        
        % Slice to 30 seconds for clean visual analysis
        raw_ecg = raw_ecg(1 : 30*Fs);
        
   catch ME
        fprintf('Error loading %s. The actual MATLAB error is:\n', record_name);
        disp(ME.message); 
        continue; 
   end
   
    % Apply the optimized Final Mixed Filter!
    % Explicitly passing 60 Hz as the target notch based on our analysis
    disp(['Applying Final ECG Filter to Record ', record_name, '...']);
    clean_ecg = final_ecg_filter(raw_ecg, Fs, 60); 
    
    % Compare signals and generate UI Tab graphs
    snr_final = compare_signals(raw_ecg, clean_ecg, Fs, ['Final Mixed Pipeline - Record ', record_name]);
    disp(['-> Final Pipeline SNR Improvement: ', num2str(snr_final), ' dB']);
    
    disp('---------------------------------------------------');
end

%% 3. SAVE GENERATED FIGURES (Iterating through all Tabs)
disp('--- Saving Final Figures & Tabs ---');

base_img_dir = 'Images';
target_folder = 'Final_Mixed_Pipeline';
full_target_dir = fullfile(base_img_dir, target_folder);

% Create directories if they do not exist
if ~exist(full_target_dir, 'dir')
    mkdir(full_target_dir);
end

% Get all open figures
all_figs = findall(0, 'Type', 'figure');

for f = 1:length(all_figs)
    fig = all_figs(f);
    fig_name = fig.Name;
    
    if isempty(fig_name)
        continue;
    end
    
    % Clean up the figure name to make it a valid filename base
    safe_fig_name = regexprep(fig_name, '[^\w\-]', '_');
    
    % Check if the figure has a tab group
    tab_group = findall(fig, 'Type', 'uitabgroup');
    
    if ~isempty(tab_group)
        % Get all tabs in this tab group
        tabs = findall(tab_group(1), 'Type', 'uitab');
        
        for t = 1:length(tabs)
            current_tab = tabs(t);
            tab_title = current_tab.Title;
            
            % Bring this specific tab to the front
            tab_group(1).SelectedTab = current_tab;
            drawnow; % Force MATLAB to render UI change
            
            safe_tab_name = regexprep(tab_title, '[^\w\-]', '_');
            final_filename = sprintf('%s_%s.png', safe_fig_name, safe_tab_name);
            save_path = fullfile(full_target_dir, final_filename);
            
            % Extract inner graphics to avoid grey UI borders
            inner_graphics = current_tab.Children;
            
            try
                if ~isempty(inner_graphics)
                    exportgraphics(inner_graphics(end), save_path, 'Resolution', 300);
                else
                    exportapp(fig, save_path);
                end
            catch
                exportapp(fig, save_path);
            end
        end
    else
        % Save standalone figure if no tabs exist
        save_path = fullfile(full_target_dir, [safe_fig_name, '.png']);
        try
            exportgraphics(fig, save_path, 'Resolution', 300);
        catch
            exportapp(fig, save_path);
        end
    end
end

disp('Final Part 1 Execution and Image Saving Complete.');