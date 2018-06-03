function error = nomog_fitError(z, bands, linLog, quantaE, xRes, xLims, optFilter, x_ind, yExp, funcName, w, nomoOpt)

    % call the wrapper function to return the best fit data points
    % corresponding to the original x-values
    dataFit = nomog_fitPoints(z, bands, linLog, quantaE, xRes, xLims, optFilter, x_ind, funcName, w, nomoOpt);
    
    % calculate the error compared to the original data
    % compare "yExp" with "dataPoints" (fit)
    
        % calculate the difference between the estimation and its mean -> explained sum of squares
        S_diff_reg = dataFit - mean(dataFit); 
        SS_reg = real(S_diff_reg' * S_diff_reg);

        % calculate the difference between the estimation and the target (residual sum of squares)
        S_diff_resid = dataFit- yExp;
        SS_err = real(S_diff_resid)' * real(S_diff_resid);

        degOfFreedom = length(yExp) - 1; 
        SS_err_norm = SS_err / degOfFreedom;


        error = SS_err_norm;