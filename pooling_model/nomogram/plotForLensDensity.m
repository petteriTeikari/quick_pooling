peak_nm = 495;
bands = 'both';
linLog  = 'lin';        
quantaE = 'Q';
density = 0.40;
xRes    = 0.01;
xLims   = [380 780];

S = nomog_Govardovskii2000(peak_nm, bands, linLog, quantaE, density, xRes, xLims)
lambda = (xLims(1):xRes:xLims(2))'

dlmwrite('nomoGovardov_495.txt', [lambda S])

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

  