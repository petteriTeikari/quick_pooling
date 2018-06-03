function S_out = truncate_spectrum(lambda, S, lambdaLimits, specRes_out)

    % truncate the input spectrum to match the template limits or other
    % limits, default values are 380 nm for minimum wavelength and 780 nm
    % for the maximum wavelength as most of the templates are for that
    % wavelength region and calculations are hugely simplified using the
    % same wavelength range
    
        min_Out_lambda      = min(lambdaLimits);
        max_Out_lambda      = max(lambdaLimits);

        min_S_lambda        = min(lambda);
        max_S_lambda        = max(lambda);

        % specRes_out
    
    %% handle different situations
    
        % need to be finished with elses and elseifs !!!!!!!!!, incomplete
    
        % When the length of the template is bigger than the 380-780nm, for
        % example the case with color matching functions (CMF)    
        if min_Out_lambda > min_S_lambda  && max_S_lambda > max_Out_lambda
            min_trim = min_Out_lambda - min_S_lambda;
            max_trim = max_S_lambda - max_Out_lambda;           
            S_out = S((min_trim+1) : (end-max_trim));
            
        elseif min_Out_lambda == min_S_lambda  && max_S_lambda == max_Out_lambda
            % no change            
            S_out = S;
            
        else
            errodlg('truncate_spectrum.m needs your help in doing some more conditions! Or you did some mistake :p')
            
        end

