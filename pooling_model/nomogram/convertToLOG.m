function dataIn = convertToLOG(dataIn)
    
    % get the fields of the input structure
    structNames = fieldnames(dataIn);    

    dataIn.response = log10(dataIn.response);

    if ~isempty(cell2mat(strfind(structNames, 'w')))
        dataIn.w = log10(dataIn.w);
    end

    if ~isempty(cell2mat(strfind(structNames, 'SD')))
        dataIn.SD = log10(dataIn.SD);
    end

    if ~isempty(cell2mat(strfind(structNames, 'SEM')))
        dataIn.SEM = log10(dataIn.SEM);
    end