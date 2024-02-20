function tbl = convert_ipg_units(tbl)
% for sim data
tbl.engine_rpm= tbl.engine_rpm*30/pi;
end