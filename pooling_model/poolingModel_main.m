function [spec, points, stats, actSpectra, x, fval, output_struct, statParam, x0_names] = ...
    poolingModel_main(lambda,y,weights_for_fit,group,mode,linLog,comb_k,contr,p,densit,fMe,oppon,bound,costF,options,path)

    spec   = [];
    points = [];
    stats  = [];

    % INPUTS (see useDefaultOptionsForMixedModels.m for further details)
    
        % x      - experimental x vector (e.g. wavelengths)
        % y      - experimental y vector (e.g. sensitivity)
        % err    - errors associated     (e.g. SD)
        
        % mode   - what model of the submodels to be used
        %          'simple'
        %          'opponent'
        %          'simpleBi'
        %          'opponentBi'
        
        % linLog - linear or logarithmic fitting
        
        % comb_k - 2 column vector,                        [k1 k2]
        % contr  - initial guesses for contributions,      [m0 c0 r0]
        % p      - LWS/MWS ratio,                           e.g  0.62
        % densit - densities for the photopigments         [dens_M dens_C dens_R dens_CS]
        % fMe    - initial value for metaMelanop fraction   e.g. 0.5
        % oppon  - opponent model parameters (x0)          [fB0 fD0 fE0]
    
        % bound  - structure for the model bounds, names same as for initial parameters
        %
        %           * if the structure does not exist then that parameter
        %             is not going to be optimized at all
        %
        %           * if it is [] or NaN then the default values are used
        %
        %             .comb_k
        %             .contr
        %             .p
        %             .densit
        %             .fMe
        %             .oppon
        
        % costF  - if you want to define an other cost function rather than
        %          least-squares, this should be a string and then you do
        %          custom if-else-end switch
        %          default is ......   
        
        % options - structure containing general options for the model
        %             .    
    
    %% OPTIMIZE the weights for the contribution model
    % -----------------------------------------------             
        
        % Define the rod, cone, melanopsin contributions corresponding to the
        % experimentally acquired action spectrum      
        
            % redefine the variables for easier reading of this code
            
                % initial values
                m0      = contr(1);
                c0      = contr(2);
                r0      = contr(3);
                k1      = comb_k(1);
                k2      = comb_k(2);
                inhMWS  = oppon(4);
                fB0     = oppon(1);
                fD0     = oppon(2);
                fE0     = oppon(3);                
                dens_M  = densit(1);
                dens_C  = densit(2);
                dens_CS = densit(3);
                dens_R  = densit(4);            
                
        % define the action spectra used in the optimization procedure
            callFrom = 'poolingModel';            
            [peak, templates] = poolingModel_defineNeededSpectra(mode, group, linLog, options);
            xLims = peak{1}.nomogInputs{7};
            xRes = peak{1}.nomogInputs{6};
            lambda_nomo = (xLims(1):xRes:xLims(2))';
            actSpectra = define_actionSpectra(lambda_nomo, peak, group, templates, callFrom);
            
            % TODO! You could do debug plot here to make sure that
            % actSpectra are indeed in LOG/LINEAR with OCULAR MEDIA
            % correction
            
         % Parameter that can be changed during optimization
            x0 = [m0; c0; r0; k1; k2; inhMWS; fB0; fD0; fE0; dens_R; dens_C; dens_CS; dens_M];
            x0_names = {'m0'; 'c0'; 'r0'; 'k1'; 'k2'; 'inhMWS'; 'fB0'; 'fD0'; 'fE0'; 'dens_R'; 'dens_C'; 'dens_CS'; 'dens_M'};
                
        % MANIPULATE THESE if you want to CONSTRAIN some variables
        % We are defining the free parameters for AIC, from these
        % automatically, so we do not want to keep the opponent model
        % parameters non-fixed
        if strcmp(mode, 'simple') % no opponency
            lb = [0.0; 0.03; 0.1; 1.0; 10.0; 1; 1.5; 1.5; 1.25; 0.40; 0.38; 0.30; dens_M]; % lower bounds for x0 variables
            ub = [1.5; 1.12; 1.5; 1.0; 10.0; 1; 1.5; 1.5; 1.25; 0.40; 0.38; 0.30; dens_M]; % upper bounds for x0 variables                          
        elseif strcmp(mode, 'opponent_(L-M)') % Kurtenbach et al. (1999) 
            lb = [0.0; 0.03; 0.1; 1.0; 10.0; 1; 1.5; 0.0; 0.00; 0.40; 0.38; 0.30; dens_M]; % lower bounds for x0 variables
            ub = [1.5; 1.12; 1.5; 1.0; 10.0; 1; 1.5; 1.5; 1.25; 0.40; 0.38; 0.30; dens_M]; % upper bounds for x0 variables                          
        elseif strcmp(mode, 'opponent_(M+L)-S') % Spitschan et al. (2014)
            lb = [0.0; 0.03; 0.1; 1.0; 10.0; 1; 0; 0.0; 0.00; 0.40; 0.38; 0.30; dens_M]; % lower bounds for x0 variables
            ub = [1.5; 1.12; 1.5; 1.0; 10.0; 1; 1.5; 1.5; 1.25; 0.40; 0.38; 0.30; dens_M]; % upper bounds for x0 variables                          
        elseif strcmp(mode, 'opponent_(+L-M)-S') %  Woelders et al. (2018)
            lb = [0.0; 0.03; 0.1; 1.0; 10.0; 0; 0.0; 0.0; 0.00; 0.40; 0.38; 0.30; dens_M]; % lower bounds for x0 variables
            ub = [1.5; 1.12; 1.5; 1.0; 10.0; 1.5; 1.5; 1.5; 1.25; 0.40; 0.38; 0.30; dens_M]; % upper bounds for x0 variables                          
        end
            
        % Define the contents statParam
        
            % Calculate the total sum of square of the experimental data
            % SS_diff = y - mean(y);           
            % SS_tot  = SS_diff' * SS_diff; 
            
            % Number of input data points
            statParam.N = length(~isnan(y));
            
            % Number of free parameters
            statParam.K = defineNoFreeParameters(x0, ub, lb, mode);
                                    
        % Inequality estimation parameters, 'doc fmincon' for more info
        % when defined as empty ([]) these have no significance to anything
            A = [];
            b = [];
            Aeq = [];
            beq = [];            
            nonlcon = [];                     
         
         % Define the minimization function   
            output = 'optim';
            % options.modeNomogram = 'dynamic'; % updated on each iteration if 'dynamic', useful for fMe
            options.modeNomogram = 'static'; % for 'simple' mode to initialize the shapes only once
            options.biPhi = 0.70; % relative quantum efficiency
            f = @(x) poolingModel_function(x, lambda, y, weights_for_fit, mode, statParam, output, actSpectra, options);

        % Define options for minimization function
            optimOpt = optimset('LargeScale','off', 'Display', 'on');
            optimOpt = optimset(optimOpt, 'Algorithm', 'interior-point');
            % optimOpt = optimset(optimOpt, 'UseParallel', 'always');                
            
        %% Optimize using fmincon   
            [x, fval, exitflag, output_struct] = fmincon(f,x0,A,b,Aeq,beq,lb,ub,nonlcon,optimOpt);
            
                % Confidence intervals are usually given with respect to estimates of parameters describing data. 
                % (Examples are the mean, standard deviation, standard error of the estimate, and so forth.) 
                % If you are fitting data, you should be using lsqcurvefit. 
                % The fmincon function does not return covariance matrices on the parameters it optimises, 
                % so you cannot calculate confidence intervals on those estimates.
                % https://uk.mathworks.com/matlabcentral/answers/139728-how-to-get-confidence-interval-with-fmincon-optimization
           
            % After optimization, obtain the spectrum and statistical
            % parameters with the optimized values
            output = 'spectrum';
            
            % TODO! WHy weights become 0 with a length of 1?
            spec = poolingModel_function(x, lambda, y, weights_for_fit, mode, statParam, output, actSpectra, options);
        
        %% Get the stats
        
            output = 'optim';
            stats = poolingModel_function(x, lambda, y, weights_for_fit, mode, statParam, output, actSpectra, options);
        
        %% And the points 
        
            lambdaInd = extractIndices(lambda, actSpectra{1}.lambda);
            points = spec(lambdaInd);
           