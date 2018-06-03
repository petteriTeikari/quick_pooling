function TRY_melatonin_models_for_CUSTOM_data() 

    % Petteri Teikari, 2018
    close all    
    scrsz = get(0,'ScreenSize'); % get screen size for plotting
    
    % Fix the paths
    fileName = mfilename; 
    fullPath = mfilename('fullpath');
    path_Code = strrep(fullPath, fileName, '');
    path_Data = fullfile(path_Code, '..', 'data');
    
    % add subfunctions
    addpath(fullfile(path_Code, 'pooling_model'))
    addpath(fullfile(path_Code, 'pooling_model', 'nomogram'))
    addpath(fullfile(path_Code, 'pooling_model', 'templates'))
    addpath(fullfile(path_Code, 'pooling_model', 'ocularmedia'))


    
%% IMPORT THE DATA
    
    % also some custom data
    % i.e. Brainard et al. 2001, Thapan et al. 2001, or whatever you might
    % have
    [CUSTOM, CUSTOM_HEADERS, CUSTOM_META] = import_custom_data(path_Data);    
    
    
%% Normalize the data going through all the time points

    % Parameters
    normalize_method = {'nonneg_maxnorm'}; % raw
    model_strings = {'simple'; 'opponent_(L-M)'; 'opponent_(M+L)-S'; 'opponent_(+L-M)-S'}; % {'opponent_(+L-M)-S'};
    error_for_fit_string = 'variance_relative'; % 'variance_relative'; % ; % 'variance_relative';
    fit_domain = 'lin';    
    
    plot_ON_fit = 0;
        
    for norm = 1 : length(normalize_method)
        for model = 1 : length(model_strings)            
            
            for dataset = 1 : length(CUSTOM_META.strNames)
                
                [norm model dataset]
                
                % NORMALIZE, always the same independent of the model type                
                [CUSTOM_norm{dataset}{norm}, CUSTOM_stats{dataset}{norm}{model}] = ...
                    normalize_time_point_CUSTOM(CUSTOM{dataset}, normalize_method);

                % FIT            
                fit_out = fit_model_to_melatonin_wrapper(CUSTOM_norm{dataset}{norm}, ...
                                            CUSTOM_stats{dataset}{norm}{model}, CUSTOM_stats{dataset}{norm}{model}.(error_for_fit_string), ...
                                            fit_domain, model_strings{model}, 'CUSTOM', plot_ON_fit, ...
                                            CUSTOM_META.strNames{dataset}, scrsz, path_Code);

                CUSTOM_FIT{dataset}{norm}{model} = fit_out;
                
            end 
            
            disp(model_strings{model})
            visualize_pooling_models_for_CUSTOM(CUSTOM_FIT, CUSTOM_stats, ...
                                            model_strings{model}, normalize_method{norm}, ... 
                                            dataset, norm, model, error_for_fit_string, ...
                                            CUSTOM_META.strNames, scrsz)            
        end
    end
    
   


    
    
