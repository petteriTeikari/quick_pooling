function [peak, templates] = poolingModel_defineNeededSpectra(mode, group, linLog, options)
    
    if strcmpi(mode, 'simple') || strcmpi(mode, 'opponent_(L-M)') || ...
        strcmpi(mode, 'opponent_(M+L)-S') || strcmpi(mode, 'opponent_(+L-M)-S')
       
        % Insignificant overhead if all possible action spectra are created
        % in all cases anyway simplifying the development
        
        templates{1} = 'SWS';
        templates{2} = 'MWS';
        templates{3} = 'LWS';
        templates{4} = 'Vl';        
        
        peak{1}.header = 'OPN4 R';
        peak{1}.nomogInputs = {482;'both';linLog;'Q';0.5;1;[380 780];[]};

        peak{2}.header = 'RODS';
        peak{2}.nomogInputs = {495;'both';linLog;'Q';0.4;1;[380 780];[]};
        
        peak{3}.header = 'OPN4 M';
        peak{3}.nomogInputs = {587;'both';linLog;'Q';10^-4;1;[380 780];[]};

    elseif strcmpi(mode, 'dynamic')
        
        % if the nomogram is created using a call from
        % poolingModel_function() during the optimization instead of
        % initializing constant templates before optimization.
        % THIS COULD be the case when you want to fit an equilibrium
        % spectrum when you cannot assume a fixed shape but rather than
        % create need R and M isoforms on every step
        
        Rpeak = options.Rpeak;
        Mpeak = options.Mpeak;
        
        peak{1}.header = 'OPN4 R';
        peak{1}.nomogInputs = {Rpeak;'both';linLog;'Q';0.5;1;[380 780];[]};
        
        % slight overhead of having to create ROD template on every step :(
        peak{2}.header = 'RODS';
        peak{2}.nomogInputs = {495;'both';linLog;'Q';0.5;1;[380 780];[]};
        
        peak{3}.header = 'OPN4 M';
        peak{3}.nomogInputs = {Mpeak;'both';linLog;'Q';10^-4;1;[380 780];[]};
        
    else
        
        errordlg('mode?!?')
        
    end
    