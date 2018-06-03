function dataPoints = nomog_fitPoints(z, bands, linLog, quantaE, xRes, xLims, optFilter, x_ind, funcName, w, nomoOpt)

    % simple wrapper to pick just the corresponding points from the fit to
    % the original data points
        
    % re-assign variables    
    if length(z) == 1
        % the last iteration return zero values
        peak_nm = NaN;
        density = NaN;
    else
        peak_nm = z(1);    
        density = z(2);
    end
    
    % create the full spectrum
    S = funcName(peak_nm, bands, linLog, quantaE, density, xRes, xLims, optFilter);
        
    % normalize the weights
    w = w / max(w);
    
    % then pick the needed points, with or without weights
    if nomoOpt.weighedFit == 1
        dataPoints = w .* S(x_ind);  
    else
        dataPoints = S(x_ind);
    end