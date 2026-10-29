# *** Settings ***
# Documentation     author: Dong Tingting
# ...               contact: tingting.dong@nokia-sbell.com
# ...               squad group: MMW_02
# Suite Setup       SISO Coam Suite Setup
# Suite Teardown    SISO Coam Suite Teardown
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${base_path}/5G_Setup_And_Teardown.robot
# Resource    ${base_path}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
# Resource    ${base_path}/General_SiSo_BTS_startup_with_RF_delayed_startup.robot
# Resource    ${base_path}/General_SiSo_RF_module_power_reset.robot
# Resource    ${base_path}/Cell/General_SiSo_Cell_block_and_unblock.robot
# 
# Resource          Resources/L3call_keywords.robot
# Force Tags    5G_RAN    5G_RAN_TDD    RAN_5G    RAN_5G_TDD    SBTS00    CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AQQN    STATE_SW_UPLOADED    PY39
# 
# *** Variables ***
# @{GNB_PS_CELL_INDEX_LIST}    1
# # ${if_commissioning}   False
# ${scf_1sector}    SCF_SBTS00.xml
# ${base_path}    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G
# *** Keywords ***
# 
# *** Test Cases ***
# [1][1.0] General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#     [Tags]    CRT_UTE
#     [Setup]    SISO Coam Test Setup
#     General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#     [Teardown]    SISO Coam Test Teardown
# 
# [1][2.0] General_SiSo_BTS_startup_with_RF_delayed_startup
#     [Documentation]     check the RU connection, detection and configuration to the BTS in a reliable time.
#     [Tags]    CRT_UTE
#     [Setup]    SISO Coam Test Setup
#     General_SiSo_BTS_startup_with_RF_delayed_startup
#     coam wait gnb and cells ready    timeout=20min    gnb_type='${gNb_CuType}'
#     [Teardown]    SISO Coam Test Teardown
# 
# [1][1.0] General_SiSo_E2E_system_setup_with_data_transfer_OTA
#     [Documentation]
#     ...    The purpose of this test is to verify L3 call.
#     [Tags]    CRT_UTE
#     [Setup]    SISO Coam Test Setup
#     Do_L3call_with_data_transfer_tp_check_from_gnb    ul_tp=50M  dl_tp=300M  protocol=udp  traffic_duration=900
#         ...    ul_tp_target=35  dl_tp_target=150  check_duration=5m
#     [Teardown]    Run Keyword And Ignore Error    SISO Coam Test Teardown
# 
# [1][1.0] General_SiSo_RF_module_power_reset
#     [Documentation]    General_SiSo_RF_module_power_reset
#     [Tags]    CRT_UTE
#     [Setup]    SISO Coam Test Setup
#     General_SiSo_RF_module_power_reset
#     [Teardown]    SISO Coam Test Teardown
# 
# [1][1.0] General_SiSo_Cell_block_and_unblock
#     [Tags]    CRT_UTE
#     [Setup]    SISO Coam Test Setup
#     General_SiSo_Cell_block_and_unblock    with_call=${False}
#     Do_L3call_with_data_transfer_tp_check_from_gnb    ul_tp=50M  dl_tp=300M  protocol=udp  traffic_duration=900
#         ...    ul_tp_target=35  dl_tp_target=150  check_duration=5m
#     [Teardown]    Run Keyword And Ignore Error    SISO Coam Test Teardown
# 
