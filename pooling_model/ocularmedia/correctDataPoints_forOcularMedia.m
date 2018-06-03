function yOut = correctDataPoints_forOcularMedia(x, y, lensModel_x, lensModel_y)

    %% NOTE
    
        %% the input lensModel_y must be defined as LOG DENSITY for this
        % function to work correctly. This is the default format from the
        % functions in this ocularmedia -folder.

        %% input y need to be in LOG also

    % find the corresponding points from the fitted continuous output
    % spectrum corresponding to the input data
    xIndInput = zeros(length(x),1); % preallocate memory        
    for i = 1 : length(x)
         xIndInput(i) = find(lensModel_x == x(i));
    end
    
    %% PICK points from the ocular media model correspondin to our experimental data
    lensModel_y_forInputData = lensModel_y(xIndInput);
    
    %% Standard correction is to assume that our y-data is obtained with the lens 
    % so we need add the LENS DENSITY in LOG domain to estimate what would
    % have been the retinal response to each wavelength    
    yOut = y + lensModel_y_forInputData;
    
        %% If you need to do the inverse and add the effect of lens density
        % for your synthetic nomogram data for example you can call this
        % function differently, instead of:
        % yOut = correctDataPoints_forOcularMedia(x, y, lensModel_x, lensModel_y)
        
        % multiply the lensModel_y with -1
        % yOut = correctDataPoints_forOcularMedia(x, y, lensModel_x, (-1 * lensModel_y))
        
        % then you define lens model as transmittance and adding the
        % transmittane in LOG to your y will cause the response to reduce
    
    
    