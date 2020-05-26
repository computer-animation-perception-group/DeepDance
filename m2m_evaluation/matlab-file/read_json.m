function json_data = read_json(json_path)
    fid = fopen(json_path); 
    raw = fread(fid,inf); 
    json_str = char(raw'); 
    fclose(fid);  
    json_data = jsondecode(json_str);
    json_data = struct2cell(json_data);
    json_data = cell2mat(json_data);
end