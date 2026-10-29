# *** Settings ***
# Suite Setup    Run keywords    CI_interface.Common Suite Setup    AND    PCMD Coam Suite Setup    AND    SISO Coam Suite Setup
# Suite Teardown     Run keywords    SISO Coam Suite Teardown    AND    Suite Teardown with SCF
# Test Setup    SISO Coam Test Setup
# Test Teardown    Coam Test Teardown
# Test Timeout    100 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot
# Resource    ../common/RRH_common_keyword.robot
# Resource    Resources/5GC001358-D_keyword.robot
# 
# Documentation
# ...   author: y6lu
# ...   contact: lu.yu@nokia-sbell.com
# ...   squad group: MMW_SG3
# ...   Feature 5GC001358-D in 5G22R2 program
# 
# Force Tags    STATE_SW_UPLOADED    CRT_UTE    RAN_5G    RAN_5G_TDD    CLOUD_5G_CLASSICAL_ASKEY_ASIBR_ABIOB4_3xAZQG    SBTS00    SBTS22R2
# ...    PY36    SBTS22R3
# 
# Library             taf.config.scf        WITH NAME    scf
# Library             taf.sbts.oam.coam.admin   WITH NAME   admin_cli
# 
# 
# 
# *** Variables ***
# ${testline_name}    7_5_UTE5G402T924
# ${scf_file_path}    ${commissionings_path}/HGZ/${testline_name}
# ${scf_file}    SCF_ABIO_3S_1CC_4DL_4UL_none_subsector.xml
# ${scf_path_subsector}    ${commissionings_path}/HGZ/${testline_name}/SCF_ABIO_3S_1CC_4DL_4UL_with_subsector.xml
# 
# ${UE_TYPE}    askey
# #${UE_TYPE}    ${tl.ues[0].capabilities[0]}
# 
# 
# *** Test Cases ***
# [1]CB008124-SR-E_01_IWK1_5GC000704_ULCG_config_setup_during_Intra-gNB_Intra-freq_HO_With_same_UE_CG_activation_status_Wi
# ...th_same_UE_CG_profile_params
#     [Documentation]
#     [Tags]
#     [Setup]
#     [Teardown]    teardown for CB008124
#     Scf commission and wait on-air    scf_name=SCF_CB008124.xml
#     Set PA prepare
#     L3 call setup for CB008124
#     Start Traffic UL
#     Handover and check syslog
#     Stop Traffic UL
#     L3 call detach
# 
# [1]5GC001358-D_53_TDD_Siso_cell_on_air_5GC002089-4_3S-1CC-4DL-4UL-FR1-eCPRI_with_beamforming
#     [Documentation]    *****************
#     ...    Verify support A5G-TD-3S-1CC-4DL-4UL-FR1-eCPRI-5GC002089-4 with beamforming for AZQG
#     ...    ******************
#     [Tags]
#     Commissioning SCF And Check On Air    scf_path=${scf_file_path}/${scf_file}
# 
# [1]5GC001358-D_54_TDD_Siso_cell_block_unblock_5GC002089-4_3S-1CC-4DL-4UL-FR1-eCPRI_with_beamforming
#     [Documentation]    *****************
#     ...    Verify support A5G-TD-3S-1CC-4DL-4UL-FR1-eCPRI-5GC002089-4 with beamforming for AZQG
#     ...    ******************
#     [Tags]
#     ${cell_id_list}    Get All Cell Id
#     #Log To Console    \n ### Prepare UE ###
#     #power_ue.Prepare UE    ue_index=${0}    ue_type=${UE_TYPE}    reset_sol=${True}
#     ${cell_index_length}    get length    ${cell_id_list}
#     FOR    ${cell_index}    IN RANGE    1    ${cell_index_length}
#         Block cell via WebEM and Check status    cell_index=${cell_index}
#         #Check specific cell call normal    cell_index=${cell_index}    cell_index_list=${cell_id_list}
#         Unblock cell via WebEM and Check status    cell_index=${cell_index}
#     END
# 
# [1]5GC001358-D_55_TDD_Siso_RU_lock_unlock_5GC002089-4_3S-1CC-4DL-4UL-FR1-eCPRI_with_beamforming
#     [Documentation]    *****************
#     ...    Verify support A5G-TD-3S-1CC-4DL-4UL-FR1-eCPRI-5GC002089-4 with beamforming for AZQG and OAM behaves
#     ...    correctly during procedure of locking and unlocking.
#     ...    *******************
#     [Tags]
#     General_SiSo_RU_lock_unlock.General_SiSo_RU_lock_unlock    with_call=False
# 
# [1]5GC001358-D_71_TDD_Siso_cell_on_air_5GC002089-33_3S-1CC-2DL-2UL-FR1-eCPRI_without_beamforming_using_subsector
# 	[Tags]
# 	Commissioning SCF And Check On Air    ${scf_path_subsector}
# 
# [1]5GC001358-D_72_TDD_Siso_cell_block_unblock_5GC002089-33_3S-1CC-2DL-2UL-FR1-eCPRI_without_beamforming_using_subsector
#     [Tags]
#     ${cell_id_list}    Get All Cell Id
#     #Log To Console    \n ### Prepare UE ###
#     #power_ue.Prepare UE    ue_index=${0}    ue_type=${UE_TYPE}    reset_sol=${True}
#     ${cell_index_length}    get length    ${cell_id_list}
#     FOR    ${cell_index}    IN RANGE    1    ${cell_index_length}
#         Block cell via WebEM and Check status    cell_index=${cell_index}
#         #Check specific cell call normal    cell_index=${cell_index}    cell_index_list=${cell_id_list}
#         Unblock cell via WebEM and Check status    cell_index=${cell_index}
#     END
# 
# [1]5GC001358-D_73_TDD_Siso_RU_lock_unlock_5GC002089-33_3S-1CC-2DL-2UL-FR1-eCPRI_without_beamforming_using_subsector
# 	[Tags]
# 	Set Test Variable    ${gNb_CuType}    SA+NSA
# 	General_SiSo_RU_lock_unlock.General_SiSo_RU_lock_unlock    with_call=False
# 
# [1]CB008124_HA_01_IWK1_DRX_configuration_for_CG_Type_2_capable_UE_under_CG_Type_2_activated_cell_for_non-VoNR_call
#     [Setup]    Case Setup
#     [Teardown]    teardown for CB008124
#     Scf commission and wait on-air    scf_name=SCF_CB008124_DRX.xml
#     Start Btslog Collect for CB008124
#     L3 call setup for CB008124
#     Start Traffic UL
#     Stop btslog and check CG2 Activate
#     Stop Traffic UL
#     L3 call detach
