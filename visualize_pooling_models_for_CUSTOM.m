function visualize_pooling_models_for_CUSTOM(CUSTOM_FIT, CUSTOM_stats, ...
                                     model_string, normalize_method, ...
                                     dataset_ind, norm_ind, model_ind, error_for_fit_string, ...
                                     dataset_strings, scrsz)
    
    save('visual_var.mat')
    % load('visual_var.mat')
    % close all
   
    plotStyle.xLims = [400 640];
   
    filename_core = ['melfit___', model_string, '___'];
               
    % CUSTOM
    model_ind
    group_plot(CUSTOM_FIT, CUSTOM_stats, 'CUSTOM',...
                 model_string, normalize_method, filename_core, ...
                 dataset_ind, norm_ind, model_ind, error_for_fit_string, ...
                 dataset_strings, scrsz, plotStyle)
             
    
    
%% SUBFUNCTIONS 

function group_plot(FIT, STATS, group, ...
                 model_string, normalize_method, filename_core, ...
                 tp_ind, norm_ind, model_ind, error_for_fit_string, ...
                 timepoints_strings, scrsz, plotStyle)

    % Subplot layout 
    fig = figure('Color', 'w',... 
                 'Position', [0.05*scrsz(3) 0.325*scrsz(4) 0.92*scrsz(3) 0.55*scrsz(4)]);
        
    no_of_timepoints = length(timepoints_strings);
    rows = 4; % young, old
    cols = no_of_timepoints;
    
    for tp = 1 : no_of_timepoints
        
        filename_tp = [filename_core, group, '___',  timepoints_strings{tp}];
    
        %{
        sp(1,tp) = subplot(rows, cols, tp);
            weights_plot(STATS{tp}{norm_ind}, error_for_fit_string, filename_tp, ...
                              normalize_method, model_string, group, ...
                              tp, timepoints_strings{tp})
        %}
 
        % [tp norm_ind model_ind]
        % STATS
        
        sp(1,tp) = subplot(rows, cols, [tp tp+(1*cols)]);
            plot_each_subplot(FIT{tp}{norm_ind}{model_ind}, STATS{tp}{norm_ind}{model_ind}, filename_tp, ...
                              normalize_method, model_string, group, ...
                              tp, timepoints_strings{tp})
       
        sp(2,tp) = subplot(rows, cols, tp+(2*cols));
            residual_plot(FIT{tp}{norm_ind}{model_ind}, STATS{tp}{norm_ind}{model_ind}, error_for_fit_string, filename_tp, ...
                              normalize_method, model_string, group, ...
                              tp, timepoints_strings{tp})
                          
        % sp(4,tp) = subplot(rows, cols, [tp+(4*cols) tp+(5*cols)]);
        %{
            spectral_fit(FIT{tp}{norm_ind}{model_ind}, STATS{tp}{norm_ind}, filename_tp,  ...
                              normalize_method, model_string, group, ...
                              tp, timepoints_strings{tp})        
        %}
    end
    
    set(sp, 'XLim', plotStyle.xLims)

    % Export matlab plot 
    filename_out = [filename_core, '_', group, '.png'];
    % saveas(gcf, filename_out)
    
%% "2nd LEVEL"
%% i.e. that the 1st level ones call, "private functions" for these
function spectral_fit(fit_per_tp, stat_per_tp, filename_tp, ...
                          normalize_method, model_string, group, ...
                          tp, tp_string, plotStyle)   
      
      % TODO! If you want Melanopic here instead of the Gov. Nomogram
      if strcmp(model_string, 'simple') 
        header_names = {'OPN4 R', 'Vl', 'RODS'};
        multiplier_indices = [1 2 3]; % i.e. m0, c0, r0      
        output_names = {'Melanopsin', 'Vlambda', 'Rod'};
        sum_cols = [1 2 3];
        
      elseif strcmp(model_string, 'opponent_(L-M)') 
        header_names = {'OPN4 R', 'Vl', 'RODS', 'MWS', 'LWS'};
        multiplier_indices = [1 2 3 9 8]; % i.e. m0, c0, r0      
        output_names = {'Melanopsin', 'Vlambda', 'Rod', 'L', 'LM'};
        sum_cols = [1 2 3 5];
              
      elseif strcmp(model_string, 'opponent_(M+L)-S') 
        header_names = {'OPN4 R', 'Vl', 'RODS', 'MWS', 'LWS', 'SWS'};
        multiplier_indices = [1 2 3 9 7 8]; % i.e. m0, c0, r0      
        output_names = {'Melanopsin', 'Vlambda', 'Rod', 'ML', 'S', 'MLS'};
        sum_cols = [1 2 3 6];
          
      elseif strcmp(model_string, 'opponent_(+L-M)-S') 
        header_names = {'OPN4 R', 'Vl', 'RODS', 'MWS', 'LWS', 'SWS'};
        multiplier_indices = [1 2 3 6 9 7 8]; % i.e. m0, c0, r0      
        output_names = {'Melanopsin', 'Vlambda', 'Rod', 'M', 'L', 'S', 'LMS'};
        sum_cols = [1 2 3 7];
                  
      end 
          
      % Spectra contains each photoreceptor contribution, i.e.
      % the ocular media corrected spectra with the contribution weight
      spectra = populate_spectra(fit_per_tp.x0_names, ...
                                 fit_per_tp.final_x, ...
                                 fit_per_tp.actSpectra, ...
                                 header_names, ...
                                 multiplier_indices, ...
                                 output_names);                                 
          
      plot_usedSpectra(spectra, tp, sum_cols)

      
function plot_usedSpectra(spectra, tp, sum_cols)
      
    spectraUsed_names = fieldnames(spectra);
    no_of_spectra = length(spectraUsed_names);

    lambda = (380:1:780)'; % TODO HARD-CODED NOW!
    
    spectra_mat_raw = zeros(length(lambda), no_of_spectra+1);
    spectra_mat = spectra_mat_raw;
    
    for i = 1 : no_of_spectra          
      spectra_mat_raw(:,i) = spectra.(spectraUsed_names{i}).spec;
      spectra_mat(:,i) = spectra_mat_raw(:,i) .* spectra.(spectraUsed_names{i}).multiplier;
    end
    
    % Calculate the sums
    prev_columns_raw = spectra_mat_raw(:,1:i);
    sum_of_prev_raw = sum(prev_columns_raw(:,sum_cols),2);       
    spectra_mat_raw(:,i+1) = sum_of_prev_raw;
    
    prev_columns = spectra_mat(:,1:i);
    sum_of_prev = sum(prev_columns(:,sum_cols),2);
    spectra_mat(:,i+1) = sum_of_prev;
    
    % Normalize
    max_value = max(spectra_mat(:));
    spectra_mat = spectra_mat / max_value;
    
    % Plot
    p = plot(lambda, spectra_mat);
    set(p(end), 'LineStyle', '--', 'LineWidth', 2, 'Color', 'k')
    set(p(sum_cols), 'LineWidth', 2)
    
    style = setDefaultFigureStyling();   
    set(gca, 'FontSize',8, 'FontName', style.fontName,'FontWeight','normal')
      
    if tp == 1
        ylabel('Response Norm.','FontWeight','bold','FontSize',9,...
                     'FontName','Futura Book');        
    end
    
    xlabel('Wavelength [nm]','FontWeight','bold','FontSize',9,...
                     'FontName','Futura Book');
    
      
function spectra_out = populate_spectra(names, x, actSpectra, ...
                        header_names, multiplier_indices, output_names)

    for i = 1 : length(actSpectra)
        header_names_actSpectra{i} = actSpectra{i}.header;
    end

    % find corresponding spectra from actSpectra to desired "header_names"
    for j = 1 : length(header_names)       
       
       IndexC = strfind(header_names_actSpectra, header_names{j});
       Index = find(not(cellfun('isempty', IndexC)));
       
       % If found, add to output structure
       if isempty(Index) == 0          
           
          % todo! ADD THE EXPONENTS!
          % NOW JUST LINEAR SUM
           
          spectra_out.(output_names{j}).spec = ...
              actSpectra{Index}.spectrum;
          
          spectra_out.(output_names{j}).multiplier = ...
              x(multiplier_indices(j));
          
       end
    end
          
    
function residual_plot(fit_per_tp, stat_per_tp, error_for_fit_string, filename_tp, ...
                              normalize_method, model_string, group, ...
                              tp, tp_string, plotStyle)    
      
      residual = abs(fit_per_tp.points - stat_per_tp.y);      
      s = stem(stat_per_tp.x, residual, 'k', 'filled');
      
      % output path
      fileName = mfilename; 
      fullPath = mfilename('fullpath');
      path_Code = strrep(fullPath, fileName, '');
      path_Data = fullfile(path_Code, '..', 'data_out_from_matlab', 'custom');           
         
      % write to disk
      % https://www.mathworks.com/matlabcentral/answers/246922-how-to-add-headers-to-a-data-matrix
      weights = 1 ./ stat_per_tp.(error_for_fit_string);
      weights_norm = weights ./ max(weights);
      
      % the fit as points
      filename_out = [filename_tp, '___', 'fit_points.csv'];      
      full_path = fullfile(path_Data, filename_out);
      
      header = {'Wavelength', 'Melatonin CA%', 'Standard Deviation', 'Fit', 'Residual', 'Residual ABS' 'Variance in', 'Weights normalized'};      
      mat_out = [stat_per_tp.x stat_per_tp.y stat_per_tp.stdev fit_per_tp.points (fit_per_tp.points - stat_per_tp.y) residual stat_per_tp.(error_for_fit_string) weights_norm];      
      output = [header; num2cell(mat_out)];
      output_table = cell2table(output);      
      writetable(output_table, full_path, 'WriteVariableNames', false)
      
      
      % stats
      filename_out = [filename_tp, '___', 'fit_stats.csv'];      
      full_path = fullfile(path_Data, filename_out); 
      struct2csv(fit_per_tp.fit_stats, full_path)

      
      % photoreceptor contributions (optimizations coefficients for fmincon)
      filename_out = [filename_tp, '___', 'fit_contributions.csv'];      
      full_path = fullfile(path_Data, filename_out); 
      header = fit_per_tp.x0_names';
      mat_out = fit_per_tp.final_x';
      output = [header; num2cell(mat_out)];
      output_table = cell2table(output);
      disp(['Saving ', full_path])
      writetable(output_table, filename_out, 'WriteVariableNames', false)
      
      % set(s, 'XLim', plotStyle.xLims)
      if tp == 1
        ylabel('Residuals','FontWeight','bold','FontSize',9,...
                     'FontName','Futura Book');
      end
    
    style = setDefaultFigureStyling();   
    set(gca, 'FontSize',8, 'FontName', style.fontName,'FontWeight','normal')
      
    if tp == 1
        ylabel('Residuals','FontWeight','bold','FontSize',9,...
                     'FontName','Futura Book');
    end
    
function weights_plot(stat_per_tp, error_for_fit_string, filename_tp, ...
                              normalize_method, model_string, group, ...
                              tp, tp_string)
           
    
    % stat_per_tp{1}
    weights = 1 ./ stat_per_tp.(error_for_fit_string);
    weights_norm = weights ./ max(weights);
    
    s = stem(stat_per_tp.x, weights_norm, 'b', 'filled');       
    
    style = setDefaultFigureStyling();   
    set(gca, 'FontSize',8, 'FontName', style.fontName,'FontWeight','normal')
    
    if tp == 1
        ylabel('Weights Norm.','FontWeight','bold','FontSize',9,...
                     'FontName','Futura Book');
    end
    
    titleString = ['norm(1 / ', error_for_fit_string, ')'];
    tit = title(titleString,'FontWeight','bold','FontSize',8,...
                'FontName','Futura Book','interpreter','none');
    
    
    
      
function plot_each_subplot(fit, stats, filename_tp, ...
                              normalize_method, model_string, group, ...
                              tp, tp_string)
                              
    % Easier and more intuitive names for plotting
    x = stats.x;
    y = stats.y;
    err = stats.stdev;
    lambda = fit.actSpectra{1}.lambda;
    spectrumFit = fit.spec;
    
    % set default style
    style = setDefaultFigureStyling();         
    
    % normalize
    %{
    y_max = max(y);
    y = y / y_max;
    multip = max(y) / y_max;
    err = err .* multip;
    %}
    
    hold on
    e(1) = errorbar(x, y, err, 'ko', 'MarkerFaceColor', [0 0.447 0.74], 'Color', [.3 .3 .3]);
    e(2) = plot(lambda, spectrumFit, 'LineWidth',2, 'Color',[1 0 0.6]);    
    hold off

    titleString = [group, ': ', tp_string, ' (', model_string, ')'];
    set(gca, 'FontName', style.fontName, 'FontSize', style.fontBaseSize)  
    
    tit = title(titleString,'FontWeight','bold','FontSize',11,...
                'FontName','Futura Book');
            
    
    lab(1) = xlabel('','FontWeight','bold','FontSize',9,...
                    'FontName','Futura Book');
    
    lab(2) = ylabel('CA%','FontWeight','bold','FontSize',9,...
                     'FontName','Futura Book');
                 
    % leg = legend('Original Data', 'Fit');
    %        legend('boxoff')

    set(gca, 'XLim', [400 640])        
    set(gca, 'YLim', [-0.4 1.2])        
        %set(lab, 'FontName', style.fontName, 'FontSize', style.fontBaseSize, 'FontWeight', 'bold')    
        %set(tit, 'FontName', style.fontName, 'FontSize', style.fontBaseSize+1, 'FontWeight', 'bold')            
        % set(leg, 'FontSize', style.fontBaseSize-1, 'FontName', style.fontName)

    drawnow
    
    filename_out = [filename_tp, '___', 'fit_spectrum.csv'];
      
    fileName = mfilename; 
    fullPath = mfilename('fullpath');
    path_Code = strrep(fullPath, fileName, '');
    path_Data = fullfile(path_Code, '..', 'data_out_from_matlab', 'custom');      
    full_path = fullfile(path_Data, filename_out);
      
    % https://www.mathworks.com/matlabcentral/answers/246922-how-to-add-headers-to-a-data-matrix
    header = {'Wavelength', 'Spectrum Fit'};      
    mat_out = [lambda, spectrumFit];      
    output = [header; num2cell(mat_out)];
    output_table = cell2table(output);
      
    writetable(output_table, full_path, 'WriteVariableNames', false)
          
    
    