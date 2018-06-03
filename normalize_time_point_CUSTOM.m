function [tp_out, stats] = normalize_time_point_CUSTOM(mat_per_tp, ...
                                                       normalize_method)
                                                   
    % Easier variable names
    x = mat_per_tp.lambda;
    y = mat_per_tp.melatonin;
    
    [no_of_timepoints, ~] = size(y);      
    
    % NORMALIZE
    if strcmp(normalize_method, 'raw')
        normStr = 'No normalization';
    
    elseif strcmp(normalize_method, 'nonneg')
        normStr = 'Non-negative';
        min_y_per_subject = nanmin(y);
        min_y_per_column = repmat(min_y_per_subject, no_of_timepoints, 1);
        y = y - min_y_per_column;        
        
    elseif strcmp(normalize_method, 'nonneg_maxnorm')
        normStr = 'Non-negative_normToUnity';
        
        min_v = nanmin(y);
        y = y - min_v;
        max_v = nanmax(y);
        y = y / max_v;        
        
    elseif strcmp(normalize_method, 'z')
        normStr = 'Z-normalized';
        y = (y - mean_rep_timepoint) ./ stdev_rep_timepoint;
        
    elseif strcmp(normalize_method, 'max') || strcmp(normalize_method, 'max_min')
        
        for sub = 1 : no_of_subjects
            if strcmp(normalize_method, 'max_min')
                y(:,sub) = y(:,sub) - min(y(:,sub));
                normStr = 'Normalized to (max-min) range per subject';
            else
                normStr = 'Normalized to max per subject';
            end
            y(:,sub) = y(:,sub) / max(y(:,sub));
        end
    end      
        
    % OUTPUT
    tp_out = y;
    stats.x = x;
    stats.n = 1; % no_of_subjects;
    
    stats.stdev_relative = ones(length(x),1); % abs(stdev_per_tp ./ mean_per_tp);
    stats.stdev = zeros(length(x),1); % abs(stdev_per_tp ./ mean_per_tp);
    stats.variance = ones(length(x),1); % stdev_per_tp .^ 2;
    stats.variance_relative = ones(length(x),1); % abs(stats.variance ./ mean_per_tp);
    stats.no_weighing = ones(length(stats.variance_relative), 1);             
    
    % OUTPUT AS WELL
    stats.y = y; % mean_per_tp;    
    
    
    