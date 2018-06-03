% SUBFUNCTION to perform the final fit for the nomogram
function [nomoOut, fitY, statOut] = nomog_finalFit(xPeak, density, x_ind, funcName, opt, nomo, origData, optFilter)

    %% The continuous spectrum

        if ~isempty(strfind(nomo, 'both'))
            bands = 'both';
        elseif ~isempty(strfind(nomo, 'alpha'))
            bands = 'alpha';
        elseif ~isempty(strfind(nomo, 'beta'))
            bands = 'beta';
        end            

        % call the function
        nomoOut = funcName(xPeak, bands, opt.linLog, opt.quantaE, density, opt.xRes, opt.xLims, optFilter);

        % scale back to match the 
        normFactor = max(origData(:,2)) / max(nomoOut);
        nomoOut = nomoOut * normFactor;
        
        
    %% Pick the points from the created spectrum 
    % matching the original data points        
        fitY = nomoOut(x_ind);
     
        
    %% Do something for the stats    
        statOut = [];
