function dataIn = convertToLIN(dataIn)

    % get the fields of the input structure
    structNames = fieldnames(dataIn);    

    dataIn.response = 10 .^ dataIn.response;

    if ~isempty(cell2mat(strfind(structNames, 'w')))
        dataIn.w = 10 .^ dataIn.w;
    end

    if ~isempty(cell2mat(strfind(structNames, 'SD')))
        dataIn.SD = 10 .^ dataIn.SD;
    end

    if ~isempty(cell2mat(strfind(structNames, 'SEM')))
        dataIn.SEM = 10 .^ dataIn.SEM;
    end