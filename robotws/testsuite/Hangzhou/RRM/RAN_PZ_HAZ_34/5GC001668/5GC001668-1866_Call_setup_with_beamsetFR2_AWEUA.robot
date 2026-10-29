# *** Settings ***
# Documentation     author: deng xueqin
# ...               contact: xueqin.deng@nokia-sbell.com
# ...               squad group: 5G_PZ_MMW_HZ_2_SG
# 
# 
# Suite Setup       Test Suite Setup
# Suite Teardown    Test Suite Teardown
# 
# Resource          Resources/common_keyword.robot
# 
# *** Variables ***
# ${BSR_path}=    /home/ute/Downloads
# ${BSR_name}=    BSR_AWEUA_32_beamSetFR2_16_8_8_1P_N45_45_N15_5_0007_00001
# 
# *** Test Cases ***
# [1]5GC001668-AD_048_Call setup UL_DL traffic withbeamSetFR2_32A
#     [Setup]    robot_common_operations.Common Case Setup
#     Config beamset value    beamSet=beamSetAbf_32a
#     ${bip1_log}    UE attach and collect bip log    bip_log_path=${1668_log_dir}
#     Perform UL DL data traffic and check throughput
#     Analyse bip log for beamforming    bip_log=${bip1_log}
#     [Teardown]    L3 call case teardown
# 
# [1]5GC001668-SB_018_Call setup DL traffic with beamSetFR2_16_8_8_1P
#     [Setup]    robot_common_operations.Common Case Setup
#     Config beamset value    beamSet=beamSetFR2_16_8_8_1P_N45_45_N10_10
#     ${bip2_log}    UE attach and collect bip log    bip_log_path=${1668_log_dir}
#     Perform DL data traffic and check throughput
#     Analyse bip log for beamforming    bip_log=${bip2_log}
#     [Teardown]    L3 call case teardown
# 
# [1]5GC001668-SC_021_Call setup DL traffic with beamSetFR2_8_8_8_8_1P
#     [Setup]    robot_common_operations.Common Case Setup
#     Config beamset value    beamSet=beamSetFR2_8_8_8_8_1P_N45_45_0_20
#     ${bip3_log}    UE attach and collect bip log    bip_log_path=${1668_log_dir}
#     Perform DL data traffic and check throughput
#     Analyse bip log for beamforming    bip_log=${bip3_log}
#     [Teardown]    L3 call case teardown
# 
# [1]5GC001866_F_015_Call setup UL_DL traffic with beamSetFR2_16_8_8_1P
#     [Setup]    robot_common_operations.Common Case Setup
#     Config beamset value    beamSet=beamSetAbf_32a
#     Apply specific beam set realization    BSR_path=${BSR_path}    BSR_name=${BSR_name}
#     ${bip4_log}    UE attach and collect bip log    bip_log_path=${1668_log_dir}
#     Perform UL DL data traffic and check throughput
#     Analyse bip log for beamforming    bip_log=${bip4_log}
#     [Teardown]    L3 call case teardown
# 
# *** Keywords ***
# Apply specific beam set realization
#     [Arguments]    ${BSR_path}    ${BSR_name}
#     Du login page via webUI
#     ${bts_id}   selenium_coam.get_bts_id
#     set test variable    ${bts_id}
#     Download BSR package to gNB    file_path=${BSR_path}/${BSR_name}.zip
#     Check BSR file installed    BSR_name=${BSR_name}
#     Activate BSR via WebEM    BSR_name=${BSR_name}
#     sleep    5s
#     Wait until keyword succeeds    15 min    30 sec
#     ...    Du Check cell on air via WebUI without login
#     Check BSR applied    BSR_name=${BSR_name}
#     [Teardown]    DU COAM selenium logout
# 
# Download BSR package to gNB
#     [Arguments]    ${file_path}
#     selenium_coam.load_software_package_from_local_drive    file_path=${file_path}
#     sleep    5s
#     selenium_coam.software_update    is_activate=${True}
# 
# Check BSR file installed
#     [Arguments]    ${BSR_name}
#     ${beamSetInstall}    selenium_coam.get_parameter_value    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}
#     ...  filter_param=Beam set installed    node_index=${0}
#     Should Be Equal    ${beamSetInstall}    ${BSR_name}
# 
# Activate BSR via WebEM
#     [Arguments]    ${BSR_name}
#     selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}
#     ...  filter_param=Activate custom beam set realization    new_value=true
#     sleep    2s
#     : FOR    ${cell_id}    IN    @{cell_list}
#     \    selenium_coam.set_parameter_value    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id}
#     ...   filter_param=Custom Beam Set Name   new_value=${BSR_name}
#     sleep    1s
#     selenium_coam.validate_plan
#     sleep    3s
#     selenium_coam.activate_plan    activate_plan_despite_errors=True
# 
# Check BSR applied
#     [Arguments]    ${BSR_name}
#     : FOR    ${cell_id}    IN    @{cell_list}
#     \    ${beamSetInused}    selenium_coam.get_parameter_value    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id}
#     ...   filter_param=Beam Set in Use
#     \    Should Be Equal    ${beamSetInused}    ${BSR_name}
# 
