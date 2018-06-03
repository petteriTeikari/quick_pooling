function S = nomog_lamb1995(peak_nm, bands, linLog, quantaE, density, xRes, xLims, optFilter)

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

    % Lamb's template equation (1995)
    % http://cvision.ucsd.edu/database/text/pigments/lamb.htm
    % Implementation by Petteri Teikari, INSERM, 2011, (petteri.teikari@gmail.com)         

    % Lamb, T.D. "Photoreceptor spectral sensitivities: Common shape in 
    % the long-wavelength region." Vision Research 35, no. 22 
    % (November 1995): 3083-3091. 
    % http://dx.doi.org/10.1016/0042-6989(95)00114-F.        

    % create the wavelength vector
        lambda = (xLims(1) : xRes : xLims(2)); % [nm]      

    % Constants        
        A = 0.880;
        B = 0.924;
        C = 1.104;
        D = 0.655;

        a = 70;
        b = 28.5;
        c = -14.1;        

    % Vectorize the variables to avoid using a for-loop
        A = A * ones(1, length(lambda));
        B = B * ones(1, length(lambda));
        C = C * ones(1, length(lambda));
        D = D * ones(1, length(lambda));

        a = a * ones(1, length(lambda));
        b = b * ones(1, length(lambda));
        c = c * ones(1, length(lambda));

    % Defining denominator terms as their own variables to make the
    % code a bit more readable              
        denom_term1 = exp(a .* (A - (peak_nm ./ lambda) ) );
        denom_term2 = exp(b .* (B - (peak_nm ./ lambda) ) );
        denom_term3 = exp(c .* (C - (peak_nm ./ lambda) ) );
        denom_term4 = D;         

    % Calculating spectral sensitivity (i.e. Lamb nomogram)
    % Equation 2' from Lamb (1995)    
    
        S_alpha_initLinQ = (1 ./ (denom_term1 + denom_term2 + denom_term3 + denom_term4))';       
        
        % no beta band defined in Lamb's paper, only a zero vector to match
        % the following function
        S_betaBand_initLinQ = zeros(length(S_alpha_initLinQ),1);
            
    %% DETERMINE THE OUTPUT depending on the input FLAGs given
    S =  nomog_defineOutputCommon(S_alpha_initLinQ, S_betaBand_initLinQ,...
         bands, linLog, quantaE, density, lambda', optFilter); 

        