function [truck,velocity,ego_mass,other_mass,drr] = file_id_ipg(filename_str,index_dict)

% Example inputs (uncomment for testing)
% filename_str = 'LeadRun_065233_velo_10_massL_20.dat';
% filename_str = 'FollowRun_034007_velo_0_massL_1_massF_0.dat';
% filename_str = 'LeadRun_brakeless_111036ACM_velo_0_massL_0.dat';
% filename_str = 'FollowRunDragSweep_000000ACM_velo_10_massL_5_massF_8_drr_3.dat'
filename_str =erase(filename_str,".dat");

splitName   = upper(string(strsplit(filename_str,"_")));


%% Truck
switch splitName(1)
    case {'LEADRUN','LEADRUNI85','LEADRUNBRAKELESSI85'}
        truck = "L";
    case {'FOLLOWRUN','FOLLOWRUNDRAGSWEEP','FOLLOWRUNI85'}
        truck = "F";
end



%% velocity
v_find = @(x) index_dict(index_dict(:,1)==double(x),2);
m_find = @(x) index_dict(index_dict(:,1)==double(x),3);
drr_find = @(x) index_dict(index_dict(:,1)==double(x),4);

% brakeless case
if length(splitName)==7
    velocity=v_find(splitName(5));
    ego_mass=m_find(splitName(7));
    other_mass = -1;
    drr = 1.0;
    truck = "C";
    return
end

% drr case
if length(splitName)==10
    drr = drr_find(splitName(10));
else
    drr = 1.0;
end

velocity = v_find(splitName(4));
if truck == "L"
    ego_mass = m_find(splitName(6));
    other_mass = -1;
elseif truck == "F"
    if length(splitName)>=8
        ego_mass = m_find(splitName(8));
        other_mass = m_find(splitName(6));
    else
        ego_mass = m_find(splitName(6));
        other_mass = ego_mass;
    end
end

end
