function actSpectra = define_actionSpectra(lambda, peak, group, templates, callFrom)

    %% INPUTS
    
        % lambda    - wavelength vector

        % peaks     - cell structure with a cell directly fitting to nomogram
        %             creation function, e.g.
        %             S = nomog_Govardovskii2000(peak_nm, bands, linLog, quantaE, density, xRes, xLims, optFilter)
        %             {1}.nomogInputs = {482;'both';'lin';'Q';0.5;1;[lambda(1) lambda(end)];[]}
        %             {1}.header
        
        % templates - cell with the wanted templates as strings
        %             e.g. 'SWS', 'MWS', LWS', 'VL', 'VprimeL', 'BLH'
        
        % path      - structure containing paths
        
        % callFrom  - defining where this function is called for better use of
        %             different if-else-end structures
        
        if nargin == 4 % not necessary to include in the call
            callFrom = [];
        end
        
        templatePath = '';
        
    %% DEFINE the OUTPUT
    
        % preallocate memory
        actSpectra = cell((length(peak) + length(templates)),1);

        % NOTE! Now the nomograms have no correction for the ocular
        % media, and the templates are for standard observer
        offset = 0.11;
        age_y = 25;
        age_o = 65;
        lensFilter_stdObs = agedLensFilter(age_y, lambda, offset);
        
        if strcmp(group, 'OLD')
            lensFilter_nomogram = agedLensFilter(age_o, lambda, offset);
            
            % How much more you need to filter the std observer for the old
            % group
            lensFilter_template = lensFilter_nomogram ./ lensFilter_stdObs;
        elseif strcmp(group, 'YOUNG')
            lensFilter_nomogram = agedLensFilter(age_y, lambda, offset);
            
            % do nothing, placeholder filter
            lensFilter_template = ones(length(lensFilter_nomogram),1);
            
        else
            
            lensFilter_template = ones(length(lambda),1);
            
        end
        
        % plot(lambda, [lensFilter_stdObs lensFilter_nomogram_OLD lensFilter_template_OLD])
        
        
        %% CREATE the WANTED NOMOGRAMS
        if ~isempty(peak)
        
            for i = 1 : length(peak)
                
                % redefine the inputs
                peak_nm   = peak{i}.nomogInputs{1};
                bands     = peak{i}.nomogInputs{2};
                linLog    = peak{i}.nomogInputs{3};
                quantaE   = peak{i}.nomogInputs{4}; 
                density   = peak{i}.nomogInputs{5};
                xRes      = peak{i}.nomogInputs{6};
                xLims     = peak{i}.nomogInputs{7};
                optFilter = peak{i}.nomogInputs{8};
                
                % create the spectrum
                actSpectra{i}.spectrum_raw = nomog_Govardovskii2000(peak_nm, bands, linLog, quantaE, density, xRes, xLims, optFilter);
                
                % correct for the ocular media
                if strcmp(peak{1}.nomogInputs{3}, 'log')                    
                    actSpectra{i}.spectrum = 10 .^ actSpectra{i}.spectrum_raw;
                    actSpectra{i}.spectrum = actSpectra{i}.spectrum .* lensFilter_nomogram;
                    actSpectra{i}.spectrum = log10(actSpectra{i}.spectrum);
                else
                    actSpectra{i}.spectrum = actSpectra{i}.spectrum_raw;
                end
                
                % copy the header from input
                actSpectra{i}.header = peak{i}.header;
                
            end
        end
        
        %% IMPORT the WANTED TEMPLATES
        if ~isempty(templates)            
            for j = i+1 : length(templates)+i
                
                % copy the header from the input
                actSpectra{j}.header   = templates{j-i};
                
                % match the string given as an input for the wanted action
                % sepctrumt template file, i.e. simple lookup table
                % function   
                [actSpectra{j}.spectrum_raw, ~] = import_spectrumTemplate(templates{j-i}, lambda, templatePath);
                
                % correct for ocular media for non-standard observers
                actSpectra{j}.spectrum = actSpectra{j}.spectrum_raw .* lensFilter_template;
                
                if strcmp(peak{1}.nomogInputs{3}, 'log')
                    actSpectra{j}.spectrum = log10(actSpectra{j}.spectrum);
                end
                
            end
        end
        
        actSpectra{1}.lambda = (xLims(1):xRes:xLims(2))';
        