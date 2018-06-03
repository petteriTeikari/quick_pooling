function dataPoints = nomog_Govardovskii2000_points(z, bands, linLog, quantaE, xRes, xLims, optFilter, x_ind)

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
    S = nomog_Govardovskii2000(peak_nm, bands, linLog, quantaE, density, xRes, xLims, optFilter);
        
    % then pick the needed points
    dataPoints = S(x_ind);