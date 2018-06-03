function out = calc_fitStats(exp, y, weights_for_fit, K, mode)  

    % convert to weights the error
           
    % y        - fit
    % exp      - experimental data
    % N        - number of data points used to fit the experimental curve
    N = length(y);
    
    % K        - number of free parameters     
    
    % Calculate the total sum of square of the experimental data
    SS_diff = exp - mean(exp);           
    SS_tot = SS_diff' * SS_diff;
   
    % calculate the difference between the estimation and its mean -> explained sum of squares
    S_diff_reg = y- mean(y); 
    SS_reg = real(S_diff_reg' * S_diff_reg);

    % calculate the difference between the estimation and the target (residual sum of squares)
    S_diff_resid = y - exp;
    
    % weight the residuals
    
    % for some reason, for the final stats, the weights become a scalar 0
    if length(weights_for_fit) == 1
        % no weighing
        S_diff_w = S_diff_resid;
    else
        S_diff_w = S_diff_resid .* weights_for_fit;
    end
    
    % the scalar to optimize
    SS_err = real(S_diff_w)' * real(S_diff_w);
    
    degOfFreedom = length(y) - 1; 
    SS_err_norm = SS_err / degOfFreedom;
    
    
    % Calculate Akaike Information Criterion (AIC)             
    % The Akaike Information Criterion: 2*N log L+2*m, where m is the number of estimated parameters.        
    AIC = 2*(N+1) + ( (K+1) * (log( 2*pi() * (SS_err/(K+1)) ) + 1) ); % http://www.biomecardio.com/matlab/polydeg.html    

    % Calculate corrected Akaike Information Criterion (AICc)            
        % Burnham & Anderson (2002) strongly recommend using AICc, rather than AIC, if n is small or k is large. Since AICc converges to AIC as n gets large, AICc generally should be employed regardless.
        % http://en.wikipedia.org/wiki/Akaike_information_criterion#AICc_and_AICu
        AICc = AIC + ((2*K) * (K+1)) / (N - K - 1);        
    
    % Schwarz Information Criterion (ABIC)
    ABIC = (N * log(SS_err)) + 2*K;
    
    % Bayesian information criterion (BIC)
    L = 0; % http://en.wikipedia.org/wiki/Likelihood
    BIC = (-2 * log(L)) + (K * log(N));

    % Calculate R Square            
    R2 = 1 - (real(SS_err) / real(SS_tot));
    if R2 < 0 % if R2 negative
        R2 = real(SS_reg) / real(SS_tot);
    end
    R2 = R2 - 1; % optimizer tries to minimize this, i.e. 1 of the best fit becomes 0 for the optimizer
    
    % Adjusted R Square    
    
    % correlation
    rCorr = corr(exp, y);
    
    if strcmp(mode, 'optim')
        % Value to be minized
        out = SS_err_norm;
        
    elseif strcmp(mode, 'spectrum')    
        
        % [y exp S_diff_resid]
        % weights_for_fit
        % S_diff_w        
        
        out.R2 = R2 + 1;
        out.AIC = AIC;        
        out.AICc = AICc;
        out.ABIC = ABIC;
        out.BIC = BIC;
        out.SS_tot = SS_tot;
        out.SS_err = SS_err;
        out.SS_reg = SS_reg;    
        out.rCorr = rCorr;
        out.N = N;
        out.K = K;
    end
