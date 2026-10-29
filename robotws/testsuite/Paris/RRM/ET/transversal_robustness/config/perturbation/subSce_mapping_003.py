# ======================================================================================
# List variable defining the mapping of sub-scenarios for TMO_SFE_LTD_14UB_937_001.robot
# Feature implementation per scenario:
# - subSce1: 937_13244_001.sce -> trigger for feature 937 + testmode for Cqi degradation, but 13244 not oam activated
# - subSce2: 937_13244_002.sce -> trigger for feature 937 + testmode for 13244-A, and 13244  oam activated
# - subSce3: 937_13244_003.sce -> trigger for feature 937 + testmode for 13244-A + 13244-B, and 13244  oam activated
# ======================================================================================
bkg_map_TMO_SFE_LTD = [
    {"name": "bkg", "offset": 1, "duration": 24, "sce_name": "bkg_14UEs_SFE_TMO_VoNR_HO_937.txt"}
]

subSce_map_TMO_SFE_LTD_2SUB_001 = [
    {"name": "subSce1", "offset": 6, "duration": 2, "sce_name": "pert_937_13244_001.sce"},
    {"name": "subSce2", "offset": 12, "duration": 2, "sce_name": "pert_937_13244_002.sce"},
    {"name": "subSce3", "offset": 18, "duration": 2, "sce_name": "pert_937_13244_003.sce"}
]
