%get_baseline_consumption The purpose of this script is to get brakeless,
%drag-reductionless fuel consumption for the ipg simulation study
clearvars

datfiles =dir('../../IPG_data/baseline_noTrailer/*.dat');
datfiles = rmfield(datfiles, 'datenum');
datfiles = rmfield(datfiles, 'isdir');
datfiles = rmfield(datfiles, 'date');
datfiles = rmfield(datfiles, 'bytes');


addpath("functions")
addpath(genpath("lookups"))

%% index dictionary to interpret the meaning of the file strings
index_dict = readmatrix('index_dict_v2_baseline.csv');

tblArr=cell(length(datfiles),1);
for q = 1%length(datfiles)
    fprintf('%i of %i files\n',q,length(datfiles) )
    subtbl = flat_ipg_data(strcat(datfiles(q).folder,'\',datfiles(q).name));
    %file identification
    [truck,set_velocity,ego_m,~,drag_reduction_ratio] = file_id_ipg(datfiles(q).name,index_dict);
    %appending identifier to it
    subtbl = [repmat(table(truck,set_velocity,ego_m,drag_reduction_ratio),height(subtbl),1),subtbl];
    subtbl.ID = repmat(q,height(subtbl),1);

    % no need to add features unless I want effective mass
    subtbl = add_features_ipg(subtbl);

    %put it the array
    tblArr{q}=subtbl;
end

tbl = vertcat(tblArr{:});

