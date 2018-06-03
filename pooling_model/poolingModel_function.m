function yOut = poolingModel_function(x, lambda, y, weights_for_fit, mode, statParam, output, actSpectra, options)

    % INPUTS
    % x       - x(1): k1
    %         - x(2): k2
    %         - x(3): m
    %         - x(4): c
    %         - x(5): r
    %         - x(6): 
    %         - ...
    %         - x(i): more parameters
        
    % OUTPUT
    % yOut    - result of some cost function, this could be the
    %           least-squares error between the input and the fit for
    %           example    
   
    debugOn = 0;
    
    %% DEFINE PHOTORECEPTOR TERMS
    
        % You could use string matching from the actSpectra{i}.header field
        % but now lazy programmer was lazy and hard-coded things, so the
        % index inside {i} could be obtained automatically
    
        % Melanopsin
        OPN4 = (x(1) .* actSpectra{1}.spectrum) .^ x(5);        
        
        % Cones
        Vlambda = actSpectra{7}.spectrum;
        C = (x(2) .* Vlambda) .^ x(4); % v(lambda)
                             % correct if you want to use MWS/LWS
        
        % Rods
        R = (x(3) .* actSpectra{2}.spectrum) .^ x(4);

        % S-Cones
        SWS = actSpectra{4}.spectrum;        
        
        % MWS and LWS cones separately
        MWS = actSpectra{5}.spectrum;
        LWS = actSpectra{6}.spectrum;
        
        % save('spectra.mat')
            
        % Opponent term, from  Spitschan et al. (2014)
        % https://dx.doi.org/10.1073/pnas.1400942111
        % LWS+MWS - x*SWS
        if strcmp(mode, 'opponent_(M+L)-S')
            Opp = (x(8) .* abs(x(9).*(LWS+MWS) - (x(7) .* SWS))) .^ x(4);
            
        % Opponent term, from  Woelders et al. (2018)
        % https://doi.org/10.1073/pnas.1716281115
        % L - x1*M - x2*S
        elseif strcmp(mode, 'opponent_(+L-M)-S')
            Opp = (x(8) .* abs(x(9).*LWS - (x(6) .* MWS) - (x(7) .* SWS))) .^ x(4);
  
        % Opponent term, from Kurtenbach et al. (1999) 
        % http://dx.doi.org/10.1364/JOSAA.16.001541
        % LWS - x*MWS    
        else % strcmp(mode, 'opponent_(L-M)')
            Opp = (x(8) .* abs(LWS - (x(9) .* MWS))) .^ x(4);
        end
        
        
        
       
        
        
       
    %% CORRECT TERMS if the experimental data is as discrete data points
    % which is most likely to be the case for photoreception studies
    
        if strcmp(output, 'spectrum') == 1
            % if your input is truely spectral
            % this is typically only the case for the "final call"           
            
        elseif strcmp(output, 'optim') == 1
            lambdaInd = extractIndices(lambda, actSpectra{1}.lambda);
        
            OPN4      = OPN4(lambdaInd);            
            C         = C(lambdaInd);
            R         = R(lambdaInd);
            % Cs        = Cs(lambdaInd);
            Opp       = Opp(lambdaInd);            
            
        end
        
   
    %% COMBINATION MODELS
    
        if strcmp(mode, 'simple') == 1
            % Combine the 3 above defined terms - ORIGINAL VERSION
            Sfit = ( OPN4 + ( (C + R).^(1/x(4)) ).^x(5)  ) .^(1/x(5));                         
            
        elseif strcmp(mode, 'opponent_(L-M)') == 1 % from Kurtenbach et al. (1999)   
            % add spectral opponency and S-cone contribution
            Sfit = ( OPN4 + ( (C + R + Opp).^(1/x(4)) ).^x(5)  ) .^(1/x(5));                  
            
        elseif strcmp(mode, 'opponent_(M+L)-S') == 1 % Spitschan et al. (2014)
            Sfit = ( OPN4 + ( (C + R + Opp).^(1/x(4)) ).^x(5)  ) .^(1/x(5));
            
        elseif strcmp(mode, 'opponent_(+L-M)-S') == 1 % Woelders et al. (2018)
            Sfit = ( OPN4 + ( (C + R + Opp).^(1/x(4)) ).^x(5)  ) .^(1/x(5));
            
        else                
            errordlg('String mismatch? Define variable "mode" better')            
        end
        
        if debugOn == 1
            %% DEBUG
            subplot(3,1,3)
            plot(lambda,Sfit)
            xlim([380 650]); ylim([0 1.2])
            pause(0.2)
        end
        
        
    %% CALCULATE the COST FUNCTION
    
        % So if Matlab is a bit novel to you, what has happened here is
        % that the poolingModel_main() calls this whole function many times
        % during the optimization routine and tries to change the input
        % values (in variable "x") on every call and then your goodness of
        % fit is quantified finally with this single scalar cost function
        % which is minimized here        
        
        % [max(y(:)) max(Sfit(:))]
        
        
        if strcmp(output, 'optim') == 1            
            yOut = calc_fitStats(y, Sfit, weights_for_fit, statParam.K, output);            
        else
            Sfit = Sfit / max(Sfit(:));
            yOut = Sfit;
        end
