function spectrum = importSensitivityData(path, fileName, wavelengthCol, sensitivityCol, noOfHeaders, delimiter)

    fileName
    importedData = importdata(fileName, delimiter, noOfHeaders);
    x = importedData.data(:,wavelengthCol);
    y = importedData.data(:,sensitivityCol);
    spectrum = [x y];    
