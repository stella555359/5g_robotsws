# *** Settings ***
# Force Tags            5G_RAN_TDD    STATE_SW_UPLOADED    master_classicalbts_all    CLOUD_5G_CLASSICAL_QC_ASIBL_ABIOB1B2_3xAHFIB_2xAEHC_ENB
# ...    PY39
# ...           CIT    5G_RAN    SBTS00    RAN_5G    RAN_5G_TDD
# Documentation    Auther:xiaoxia.hao@nokia-sbell.com
# Suite Setup    Suite Setup For RFS On UTE Cloud
# Suite Teardown    702 Suite TearDown For UTE
# Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000702/Resources/5GC000702_common_ute.robot
# Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008145_A/TestData/variables.py
# 
# *** Variables ***
# 
# *** Test Cases ***
# #[1]5GC008145_A_25_SA_TDD_BF_Activated_2UE_1Sector_2CC_8DL_8UL_ECPRI_90Mhz_50Mhz_Cell_lock_and_unlock
# #    [Documentation]    CHBW:90_50MHz
# #    [Timeout]    120m
# #    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_1Sector_2CC_8DL_8UL_90_50_${stream}
# #    ${90MHz_50MHz_Tput}    set variable if    'SBTS00' in '${stream}'    ${frame_structure_list_90MHz_50MHz_SBTS00}
# #    ...                                                                                  ${frame_structure_list_90MHz_50MHz}
# #    5GC008145_A_SA_TDD_BF_Activated_2UE_8DL_8UL_ECPRI    frames_info=${90MHz_50MHz_Tput}    cellid=5
# #    [Teardown]   702 Case TearDown For UTE
# #
# #
