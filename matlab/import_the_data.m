function [OLD, YOUNG, OLD_headers, YOUNG_headers] = import_the_data(path_Data, pattern)

    listing = dir(fullfile(path_Data, pattern));
    j_old = 1;
    j_young = 1;
    
    for i = 1 : length(listing)
        filename = listing(i);
        full_path = fullfile(path_Data, filename.name);
        true = isempty(strfind(filename.name, 'OLD'));        
        
        if true == 0
            OLD_table{j_old} = readtable(full_path);    
            [raw_in,~,~] = importdata(full_path,',',1);            
            OLD{j_old}.lambda = raw_in.data(:,1);
            OLD{j_old}.melatonin = raw_in.data(:,2:end);
            
            fid = fopen(full_path);
            OLD_headers = textscan(fid,'%s',1);
            OLD_headers = OLD_headers{1};            
            OLD_headers = strsplit(cell2mat(OLD_headers),',');
            OLD_headers = OLD_headers(2:end);
            fclose(fid);
            
            j_old = j_old + 1;
            
        else
            YOUNG_table{j_young} = readtable(full_path);            
            [raw_in,~,~] = importdata(full_path,',',1);
            YOUNG{j_young}.lambda = raw_in.data(:,1);
            YOUNG{j_young}.melatonin = raw_in.data(:,2:end);
            
            fid = fopen(full_path);
            YOUNG_headers = textscan(fid,'%s',1);
            YOUNG_headers = YOUNG_headers{1};
            YOUNG_headers = strsplit(cell2mat(YOUNG_headers),',');
            YOUNG_headers = YOUNG_headers(2:end);
            fclose(fid);
            
            j_young = j_young + 1;
        end                
        
    end
    