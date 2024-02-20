function tbl = load_ipg_platoon_data(path)
% ipg_drag_mass_analysis
% Evan Stegner
% '../../IPG_data/platoon_noTrailer_wDragSweep/*.dat'
% clearvars
warning('off', 'MATLAB:table:ModifiedAndSavedVarnames')
datfiles =dir(path);
datfiles = rmfield(datfiles, 'datenum');
datfiles = rmfield(datfiles, 'isdir');
datfiles = rmfield(datfiles, 'date');
datfiles = rmfield(datfiles, 'bytes');

addpath("functions")
addpath(genpath("lookups"))

%% index dictionary to interpret the meaning of the file strings
index_dict = readmatrix('index_dict_v3.csv');

%% Load data and add metadata
tblArr=cell(length(datfiles),1);
for q = 1:length(datfiles)
    fprintf('%i of %i files\n',q,length(datfiles) )
    subtbl = flat_ipg_data(strcat(datfiles(q).folder,'\',datfiles(q).name));
    %file identification
    [truck,set_velocity,ego_m,other_m,drag_reduction_ratio] = file_id_ipg(datfiles(q).name,index_dict);
    %appending identifier to it
    subtbl = [repmat(table(truck,set_velocity,ego_m,other_m,drag_reduction_ratio),height(subtbl),1),subtbl];
    subtbl.ID = repmat(q,height(subtbl),1);

    % add features
    
    subtbl = add_features_ipg(subtbl);
    
    %put it the array
    tblArr{q}=subtbl;
end

tbl = vertcat(tblArr{:});

