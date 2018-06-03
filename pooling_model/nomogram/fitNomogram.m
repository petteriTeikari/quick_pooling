function [nomoOut, fitY, statOptim, statFinal] = fitNomogram(x, y, density, w, lambda, nomo, nomoOptions, optFilter) 

    % x - x-vector
    % y - y-vector
    % x - weights      
    
    %% Do INPUT checking
    
        % default values        
        lambdaDef = (380:1:780)';
        nomoDef = 'govardovskii2000_both';
        densityDef = 0.3;
        
        % options structure
        nomoOptionsDef.fitPeakInit = 460; % initial guess for peak wavelength              
        
        % find the corresponding points from the fitted continuous output
        % spectrum corresponding to the input data
        fitOptions.xIndInput = zeros(length(x),1); % preallocate memory        
        for i = 1 : length(x)
             fitOptions.xIndInput(i) = find(lambda == x(i));
        end
        
        % indices of input data corresponding to lambdaDef
        nomoOptions.xIndInput = fitOptions.xIndInput;
    
        % use shorter variable names
        nomoOptionsDef.linLog = 'lin';
        nomoOptionsDef.quantaE = 'Q';
        nomoOptionsDef.xRes = 1;
        nomoOptionsDef.xLims = [min(lambdaDef) max(lambdaDef)];
        nomoOptionsDef.boundsPeak = [400 650];
        nomoOptionsDef.boundsDens = [0 0.4];       
        
        optFilterDef = [];
        
        if nargin == 0 || nargin == 1
            errordlg('Supply the input data')         
        elseif nargin == 2        
            density = densityDef;
            w = ones(length(y),1);  
            lambda = lambdaDef;
            nomo = nomoDef;
            nomoOptions = nomoOptionsDef;
            optFilter = optFilterDef;            
        elseif nargin == 3
            w = ones(length(y),1);  
            lambda = lambdaDef;
            nomo = nomoDef;
            nomoOptions = nomoOptionsDef;
            optFilter = optFilterDef;            
        elseif nargin == 4
            lambda = lambdaDef;
            nomo = nomoDef;
            nomoOptions = nomoOptionsDef;
            optFilter = optFilterDef;             
        elseif nargin == 5
            nomo = nomoDef;
            nomoOptions = nomoOptionsDef;
            optFilter = optFilterDef; 
        elseif nargin == 6
            nomoOptions = nomoOptionsDef;
            optFilter = optFilterDef; 
        elseif nargin == 7
            optFilter = optFilterDef;
        elseif nargin == 8
            % nothing to be done
        else
            errordlg('Too many inputs')
        end
    
    %% General fitting settings            
    z(1)  = nomoOptions.fitPeakInit; % initial guess for peak wavelength      
    z(2)  = density;
    x_ind = nomoOptions.xIndInput;
    
        % use shorter variable names
        linLog  = nomoOptions.linLog;
        quantaE = nomoOptions.quantaE;
        xRes    = nomoOptions.xRes;
        xLims   = nomoOptions.xLims;
        
        bound1 = nomoOptions.boundsPeak;
        bound2 = nomoOptions.boundsDens;
        
        % Available NOMOGRAM models
            
            % models defined as functions of "z" instead of typical x as we
            % used already x and y to define our experimental data        
            
            % for curve fitting / optimization help, see for example
            % http://www.mathworks.com/matlabcentral/newsreader/view_thread/156711
            
        % GOVARDOVSKI et al. (2000): Alpha and Beta bands
        if strcmp(nomo, 'govardovskii2000_both') == 1
            bands = 'both';
            funcName = str2func('nomog_Govardovskii2000'); % create a variable pointing to the function                                 
            fitFunc = @(z) nomog_fitError(z, bands, linLog, quantaE, xRes, xLims, optFilter, x_ind, y, funcName, w, nomoOptions);

        % GOVARDOVSKI et al. (2000): Only Alpha band
        elseif strcmp(nomo, 'govardovskii2000_alpha') == 1
            bands = 'alpha';
            funcName = str2func('nomog_Govardovskii2000'); % create a variable pointing to the function            
            fitFunc = @(z) nomog_fitError(z, bands, linLog, quantaE, xRes, xLims, optFilter, x_ind, y, funcName, w, nomoOptions);

        % GOVARDOVSKI et al. (2000): Only Beta band
        elseif strcmp(nomo, 'govardovskii2000_beta') == 1
            bands = 'beta';
            funcName = str2func('nomog_Govardovskii2000'); % create a variable pointing to the function
            fitFunc = @(z) nomog_fitError(z, bands, linLog, quantaE, xRes, xLims, optFilter, x_ind, y, funcName, w, nomoOptions);

        % LAMB (1995): Only Alpha defined in the model
        elseif strcmp(nomo, 'lamb1995') == 1

        % STAVENGA (2010): Alpha and Beta bands
        elseif strcmp(nomo, 'stavenga2010_both') == 1

        % STAVENGA (2010): Only Alpha band
        elseif strcmp(nomo, 'stavenga2010_alpha') == 1

        % STAVENGA (2010): Only Beta band
        elseif strcmp(nomo, 'stavenga2010_beta') == 1

        % DARTNALL (1953): Both Alpha and Beta band in the template
        elseif strcmp(nomo, 'dartnall1953') == 1

        % BARLOW (1982)
        elseif strcmp(nomo, 'barlow1982') == 1

        % MACNICHOL (1986)
        elseif strcmp(nomo, 'macNichol1986') == 1

        % BAYLOR et al. (1987)
        elseif strcmp(nomo, 'baylor1987') == 1

        else
            % nothing
        end 
       
    %% Optimize                

        % call the optimization routine
        [z, statOptim] = nomog_optimizationForFit(z, bound1, bound2, [x y w], fitFunc, nomoOptions);
        
        % After optimization, obtain the final continuous spectrum 
        % with the y-points corresponding to the input data        
        xPeak   = z(1);
        density = z(2);
        [nomoOut, fitY, statFinal] = nomog_finalFit(xPeak, density, x_ind, funcName, nomoOptions, nomo, [x y], optFilter);
        
        
        
    