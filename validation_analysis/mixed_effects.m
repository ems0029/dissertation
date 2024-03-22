% mixed effects
% takes a long time to fit
% nfc_tbl_aug =nfc_tbl_aug(nfc_tbl_aug.set==1,:);
C = unique([nfc_tbl_aug.N_plat;nfc_tbl_aug.N_ref]);
nfc_tbl_aug.q_plat=categorical(nfc_tbl_aug.N_plat,C);
nfc_tbl_aug.q_ref=categorical(nfc_tbl_aug.N_ref,C);
X = [ones(height(nfc_tbl_aug),1),nfc_tbl_aug.delPAD,nfc_tbl_aug.delPaero,nfc_tbl_aug.delP_fan,nfc_tbl_aug.NPC_inf,nfc_tbl_aug.NFC_inf];
y = [nfc_tbl_aug.delP_true,nfc_tbl_aug.delF_true,nfc_tbl_aug.NPC_true,nfc_tbl_aug.NFC_true];
Z = {nfc_tbl_aug.flip,-nfc_tbl_aug.flip};
Z = nfc_tbl_aug.flip.*(onehotencode(nfc_tbl_aug.q_plat,2)-onehotencode(nfc_tbl_aug.q_ref,2));
G = {nfc_tbl_aug.q_plat,nfc_tbl_aug.q_ref};
