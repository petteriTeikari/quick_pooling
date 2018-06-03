function options = useDefaultOptionsForMixedModels()
% default options

    %% General Mixed Models
    options.mixedModels.model = 'All';
    
    %% Photoreceptor pooling    
    
        %% POSSIBLE MODELS
            
            % mode   - what model of the submodels to be used
             modeDef = 'simple';
                %          'opponent'
                %          'simbleBi'
                %          'opponentBi'      
                
        %% Linear or log
            linLog = 'log';
        
        %% Model parameters: Original model

            % LWS/MWS-ratio
            % Ratio 1.625, ratio of standard observer
            % Pokorny, Jin & Smith 1993, http://dx.doi.org/10.1364/JOSAA.10.001304

                % This parameter will define the shape of the CONE action
                % spectrum and with the default values it corresponds to the
                % V(lambda). You should notice that the ratio varies as a
                % change of eccentricity and depending on the subject so
                % the V(lambda) is just some "average value" for given test
                % field (2 or 10 degrees available from CIE)
                p_def = 0.62; 

            % Combination rule parameters
                k1_def = 1;  % fixed to 1 in the original paper (McDougal and Gamlin 2010)
                k2_def = 10; % fixed to 10 in the original paper (McDougal and Gamlin 2010)

            % Cone/Rod/Melanopsin contribution parameters
            % These are the initial "guesses" (x0) for the optimization
            % function to be optimized
                m0_def = 1;
                c0_def = 1;
                r0_def = 1;
    
        %% Model parameters: Extended model'        

            % self-screening for photopigments
                dens_M_def = 0.40*10^-4;    % 0.50 in Tsujimura et al. (2010), http://dx.doi.org/10.1098/rspb.2010.0330
                                            % 10^-4 lower than for
                                            % rods/cones, practically
                                            % nothing
                                            % Do et al. 2009, http://dx.doi.org/10.1038/nature07682
                                            
                dens_C_def = 0.38;    % 0.27 in Lamb (1995), http://dx.doi.org/10.1016/0042-6989(95)00114-F (diff. for S-cones!)
                                      % 0.38 for M/L-cones, Stockman et al. (1999), http://dx.doi.org/10.1016/S0042-6989(98)00225-9
                dens_CS_def = 0.30;   % 0.30 for S-cones, Stockman et al. (1999), http://dx.doi.org/10.1016/S0042-6989(98)00225-9
                dens_R_def = 0.40;    % 0.4 in Lamb (1995), http://dx.doi.org/10.1016/0042-6989(95)00114-F

            % Bistable MELANOPSIN term
                fMe0_def = 0.5; 

            % additional opponent cone parameters, from Kurtenbach et al.
            % (1999), http://dx.doi.org/10.1364/JOSAA.16.001541
                fB0_def = 0.2; 
                fD0_def = 0.2;       
                fE0_def = 1.25; % constant at the paper                 
                
            % Inhibitory MWS component from Woelders
                inh_MWS = 0.3; % initial guess
    
        %% Compile this to structure
        options.poolingModel.mode    = modeDef;
        options.poolingModel.comb_k  = [k1_def k2_def]; % [k1 k2]
        options.poolingModel.contr   = [m0_def c0_def r0_def]; % [m c r]
        options.poolingModel.p       = p_def;
        options.poolingModel.densit  = [dens_M_def dens_C_def dens_CS_def dens_R_def]; % [OPN4 Cone S-Cone Rod]
        options.poolingModel.fMe     = fMe0_def;
        options.poolingModel.oppon   = [fB0_def fD0_def fE0_def inh_MWS]; % [fB0 fD0 fE0]
        options.poolingModel.bound   = [];
        options.poolingModel.costF   = []; 
        options.poolingModel.linLog  = linLog;
    