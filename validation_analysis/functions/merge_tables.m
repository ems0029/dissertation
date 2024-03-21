function merged_table = merge_tables(table_1,table_2)
   table_2.G = table_2.G+max(table_1.G);
   table_2(:,{'N_plat','N_ref'}) = table_2(:,{'N_plat','N_ref'})+max([table_1.N_plat;table_1.N_ref]);
   commonvars = intersect(table_1.Properties.VariableNames,table_2.Properties.VariableNames,'stable');
   merged_table = [table_1(:,commonvars);table_2(:,commonvars)];
end
