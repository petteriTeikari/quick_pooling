function [CUSTOM, CUSTOM_HEADERS, CUSTOM_META] = import_custom_data(path_Data)

    filenames = {'brainardData_LIN_2001.csv', ...
                 'thapanData_LIN_2001.csv'};
            
    for i = 1 : length(filenames)
        
        filename = filenames{i};
        full_path = fullfile(path_Data, filename);        
        raw = importdata(full_path);
        data = raw.data;
        CUSTOM{i}.lambda = data(:,1);
        CUSTOM{i}.melatonin = data(:,2);
                
        CUSTOM_HEADERS = raw.colheaders;
        
        string_header = strrep(filename, 'Data_LIN_', '');
        string_header = strrep(string_header, '.csv', '');
        
        CUSTOM_META.strNames{i} = string_header
        
    end
    