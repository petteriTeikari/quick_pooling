function S = nomog_dartnallTemplate(peak_nm, bands, linLog, quantaE, density, xRes, xLims, optFilter)

    %% INPUTSs:
    % =======
    
        % peak_nm  - is the wavelength of peak sensitivity in nm. 
        % linLog   - output, LINEAR or LOG
        % quantaE  - output, in QUANTA or as ENERGY
        % density  - peak axial density for self-screening
        % xLims    - min/max wavelength for the created vector                
        % xRes     - the spectral resolution of the created nomogram [nm]      
        
            % Default density values from the literature
            % 0.50 in Tsujimura et al. (2010) for melanopsin,   http://dx.doi.org/10.1098/rspb.2010.0330
	    %         insanely high density estimate for melanopsin!			
            % 10^4 lower than for rods/cones by Do et al. (2009), http://dx.doi.org/10.1038/nature07682
            % 0.27 in Lamb (1995) CONES, (diff. for S-cones!)   http://dx.doi.org/10.1016/0042-6989(95)00114-F 
            % 0.38 for M/L-cones, Stockman et al. (1999),       http://dx.doi.org/10.1016/S0042-6989(98)00225-9
            % 0.30 for S-cones, Stockman et al. (1999),         http://dx.doi.org/10.1016/S0042-6989(98)00225-9
            % 0.4 in Lamb (1995) RODS,                          http://dx.doi.org/10.1016/0042-6989(95)00114-F        

            
    %% OUTPUT:
    % =======
        % S - vector, continuous action spectrum
        
        
    %% CHECK for NUMBER of inputs    
    
        % default values
        def_bands = 'both';
        def_linLog  = 'lin';        
        def_quantaE = 'Q';
        def_density = 0;
        def_xRes    = 1;
        def_xLims   = [380 780];
        def_optFilter = [];

        if nargin == 0
            errordlg('Supply at least the peak wavelength')                
        elseif nargin == 1
            bands   = def_bands;
            linLog  = def_linLog;
            quantaE = def_quantaE;
            density = def_density;
            xRes    = def_xRes;
            xLims   = def_xLims;
            optFilter = def_optFilter;
        elseif nargin == 2        
            linLog  = def_linLog;
            quantaE = def_quantaE;            
            density = def_density;
            xRes    = def_xRes;
            xLims   = def_xLims;      
            optFilter = def_optFilter;
        elseif nargin == 3
            quantaE = def_quantaE;
            density = def_density;
            xRes    = def_xRes;
            xLims   = def_xLims;      
            optFilter = def_optFilter;
        elseif nargin == 4
            density = def_density;
            xRes    = def_xRes;
            xLims   = def_xLims;
            optFilter = def_optFilter;
        elseif nargin == 5
            xRes    = def_xRes;
            xLims   = def_xLims;
            optFilter = def_optFilter;
        elseif nargin == 6
            xLims   = def_xLims;
            optFilter = def_optFilter;
        elseif nargin == 7
            optFilter = def_optFilter;
        elseif nargin == 8
            % nothing to be done
        else
            errordlg('Too many inputs')
        end

    %% Main IMPLEMENTATION
    
        % Dartnall's rhodopsin template or nomogram (1953)
        % http://www-cvrl.ucsd.edu/database/text/pigments/dartrhod.htm
        % Implementation by Petteri Teikari, petteri.teikari@gmail.com

        % Dartnall, H J A. "The interpretation of spectral sensitivity 
        % curves." British Medical Bulletin 9, no. 1 (1953): 24-30. 
        % http://www.ncbi.nlm.nih.gov/pubmed/13032421.        

        % Dartnall TEMPLATE
        % http://cvrl.ucl.ac.uk/database/text/pigments/dartrhod.htm
        dartnallTemplate(:,1) = [5200 4800 4400 4000 3600 3200 2800 2400 2000 1600 1200 800 400 0 -400 -800 -1200 -1600 -2000 -2400 -2800 -3200 -3600];
        dartnallTemplate(:,2) = [-0.6780 -0.6480 -0.6110 -0.5530 -0.5020 -0.4500 -0.3720 -0.2920 -0.2180 -0.1520 -0.0940 -0.0460 -0.0130 0 -0.0130 -0.0560 -0.1370 -0.2640 -0.4320 -0.6580 -0.9590 -1.3010 -1.7000];

        % create the corresponding wavelength vector with a given peak
        % wavelength
        lambdaOrig          = dartnallTemplate(:,1) + (1 / (peak_nm * 10^-7)); % 1/? [cm-1]
        lambdaOrig          = 1 ./ lambdaOrig; % ? [cm]
        lambdaOrig          = lambdaOrig * 10^7; % ? [nm]
        templateAbsorbance  = dartnallTemplate(:,2);
        
        % interpolate the created Dartnall spectral sensitivity to the
        % given range (S_dartnall.lambdaOrig) and do "NaN-padding" until
        % the original extremes (x_min : x_max). Use the nm_res as the
        % interpolation spectral resolution.

            % Note: More recently, it has been shown that pigment shape
            % invariance is improved when other scales, such the fourth 
            % root of wavelength (Barlow, 1982) or log frequency 
            % (Mansfield, 1985), are used. Thus, the Dartnall 
            % nomogram remains useful, but over only a restricted range of 
            % wavenumbers near the rhodopsin lambda_max. 
            % http://www-cvrl.ucsd.edu/database/text/pigments/dartrhod.htm

            % wavelength vector from the template in nm_res steps
            % Note: Ends of the vector are rounded to integer nanometers
            lambdaTmp    = round(min(lambdaOrig)) : xRes : round(max(lambdaOrig));            
            quantaLogTmp = interp1(lambdaOrig, templateAbsorbance, lambdaTmp);

            % Do NaN-padding
            lambda = (xLims(1) : xRes : xLims(2)); % [nm], final Wavelength vector
            quanta_log = zeros(length(lambda),1);
            quanta_log(:) = NaN;
 
        % Place the created quantaLogTmp to the created
        % S_dartnall.quanta_log

            % if minimum nm of quantaLogTmp is LARGER (or the SAME) 
            % than the minimum of the final wavelength vector
            if min(lambdaTmp) >= min(lambda)                   

                ind1 = find(lambda == min(lambdaTmp));

                if max(lambdaTmp) <= max(lambda)
                    ind2 = find(lambda == max(lambdaTmp));
                else
                    ind_tmp = find(max(lambda) == lambdaTmp);                        
                    quantaLogTmp2 = quantaLogTmp(1:ind_tmp);
                    quantaLogTmp = quantaLogTmp2;
                    ind2 = length(lambda);
                end

                quanta_log(ind1:ind2) = quantaLogTmp;

            % and if minimum nm of quantaLogTmp is SMALLER than the 
            % minimum of the final wavelength vector 
            elseif min(lambdaTmp) < min(lambda)

                ind_tmp = find(lambdaTmp == min(lambda));

                    % truncate the temp-vector                         
                    quantaLogTmp2 = quantaLogTmp(ind_tmp:end);
                    quantaLogTmp = quantaLogTmp2;
                    ind1 = 1;

                    if max(lambdaTmp) <= max(lambda)
                        ind2 = find(lambda == max(lambdaTmp));
                    else
                        ind_tmp = find(max(lambda) == lambdaTmp);
                        quantaLogTmp2 = quantaLogTmp(1:ind_tmp);
                        quantaLogTmp = quantaLogTmp2;
                        ind2 = length(lambda);
                    end

                quanta_log(ind1:ind2) = quantaLogTmp;

            else
                disp('Error, check wavelength definitions') % should not occur
            end

            % Assign the results to the output structure        
            lambda =  lambda'; % wavelength
            
            % make it comparable to the following subfunction with
            % different alpha and beta bands.            
            S_alpha_initLinQ = 10 .^ quanta_log; % LINEAR
            
                % convert NaNs to zeroes
                S_alpha_initLinQ(isnan(S_alpha_initLinQ)) = 0;
            
                % HOWEVER, NOTE that when you look carefully the Dartnall
                % template you can see that its shape is similar to
                % Govardovskii et al. (2000) with both ALPHA and BETA bands
                % so it already contains both bands
                S_betaBand_initLinQ = zeros(length(S_alpha_initLinQ),1);
            

    %% DETERMINE THE OUTPUT depending on the input FLAGs given
    S =  nomog_defineOutputCommon(S_alpha_initLinQ, S_betaBand_initLinQ,...
         bands, linLog, quantaE, density, lambda', optFilter); 

        
