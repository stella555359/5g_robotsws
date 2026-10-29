import os
curr_dir = os.path.dirname(__file__)

TOPOLOGY_TO_LUA = {
    'CLOUD_5G_I_LO_AP_LO:VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE':
        curr_dir + '/../config/SANSA_TDD_2c_FDD_2c_1eNBsim_1gNBsim.lua',
    'CLOUD_5G_I_LO_AP_LO:VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ':
        curr_dir + '/../config/SANSA_TDD_2c_FDD_2c_1eNBsim_1gNBsim.lua',
    'CLOUD_5G_I_LO_AP_LO:VARIANT_SANSA_FS_ECPRI_CMWV_TDD':
        curr_dir + '/../config/SA_TDD_2c_1gNBSim.lua',
}
