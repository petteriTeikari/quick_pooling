function [S, S_prefiltered, t] = importSensitivities(path, p)
    
    % IMPORT LINEAR SENSITIVITIES
    % ---------------------------
    
        tic; % start timing

        % 1st column - Wavelength
        % 2nd column - Sensitivity
        % (path, fileName, wavelengthCol, sensitivityCol, noOfHeaders, delimiter)
        S.melatonin = importSensitivityData(path, 'brainardThapan_melatoninSuppression_LIN_Rea2011.txt', 1, 2, 1, '\t');
        S.opn4 = importSensitivityData(path, 'melanopsin_lambNomogram_peak482nm_380to780nm_1nm.txt', 1, 2, 1, '\t');        
        S.SWS = importSensitivityData(path, 'coneFundamentals_LINss10deg_380to780nm_1nm_Lin-E.txt', 1, 4, 1, '\t');
        S.MWS = importSensitivityData(path, 'coneFundamentals_LINss10deg_380to780nm_1nm_Lin-E.txt', 1, 3, 1, '\t');
        S.LWS = importSensitivityData(path, 'coneFundamentals_LINss10deg_380to780nm_1nm_Lin-E.txt', 1, 2, 1, '\t');
        S.rods = importSensitivityData(path, 'v_lambda_Scotopic_1951e_LIN_380to780nm_1nm.txt', 1, 2, 1, '\t');
        S.V = importSensitivityData(path, 'v_lambda_linCIE2008v10e_LIN_380to780nm_1nm.txt', 1, 2, 1, '\t');

        % function of LWS and MWS cones, equation (6)
        S.cones(:,1) = S.LWS(:,1);
        
        S.cones(:,2) = (p .* S.LWS(:,2)) + ((p-1) .* S.MWS(:,2));
            S.cones(:,2) = S.cones(:,2)/max(S.cones(:,2)); % scale to 1 being the max
            
            S.cones(:,2) = S.V(:,2);
            % S.cones(:,2) = S.MWS(:,2);           
            
        t.importSensitivities = toc; % stop timing
        
        % Change possible NaN-values to 0
        S.opn4(isnan(S.opn4) == 1) = 0;
        S.opn4meta(isnan(S.opn4meta) == 1) = 0;       
        S.opn4_bistable(isnan(S.opn4_bistable) == 1) = 0; 
        S.opn4_bistable_wLens(isnan(S.opn4_bistable_wLens) == 1) = 0; 
        S.SWS(isnan(S.SWS) == 1) = 0;
        S.MWS(isnan(S.MWS) == 1) = 0;
        S.LWS(isnan(S.LWS) == 1) = 0; 
        S.rods(isnan(S.rods) == 1) = 0; 
        S.V(isnan(S.V) == 1) = 0;
        S.cones(isnan(S.cones) == 1) = 0;
        
        % CORRECT FOR LENS ABSORPTION
        % ---------------------------
        tic; % start timing
        S_prefiltered.opn4 = correctLinearSensitivityForPrefiltering(S.opn4, path.Code, path.Sensitivity);
        S_prefiltered.opn4meta = correctLinearSensitivityForPrefiltering(S.opn4meta, path.Code, path.Sensitivity);
        S_prefiltered.opn4_bistable = correctLinearSensitivityForPrefiltering(S.opn4_bistable, path.Code, path.Sensitivity);        
        S_prefiltered.SWS = correctLinearSensitivityForPrefiltering(S.SWS, path.Code, path.Sensitivity);
        S_prefiltered.MWS = correctLinearSensitivityForPrefiltering(S.MWS, path.Code, path.Sensitivity);
        S_prefiltered.LWS = correctLinearSensitivityForPrefiltering(S.LWS, path.Code, path.Sensitivity);
        S_prefiltered.rods = correctLinearSensitivityForPrefiltering(S.rods, path.Code, path.Sensitivity);
        S_prefiltered.V = correctLinearSensitivityForPrefiltering(S.V, path.Code, path.Sensitivity);
        S_prefiltered.cones = correctLinearSensitivityForPrefiltering(S.cones, path.Code, path.Sensitivity);
        t.correctForPrefiltering = toc;    