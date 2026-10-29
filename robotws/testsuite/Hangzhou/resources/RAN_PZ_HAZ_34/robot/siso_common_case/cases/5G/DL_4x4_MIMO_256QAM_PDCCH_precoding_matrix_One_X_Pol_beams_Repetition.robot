*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_csn.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/aasyslog.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot

*** Variables ***

*** Keywords ***
DL_4x4_MIMO_256QAM_PDCCH_precoding_matrix_One_X_Pol_beams_Repetition
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to modify dlMimoMode then make througput and check bip log
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 21.01.2021 - - Created
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${ue_index}=${0}  ${cell_id}=1  ${dlMimoMode_value}=4x4 or 4x2 Open Loop Spatial Multiplexing
    ${origin_value}    Get dlMimoMode Value Via API    cell_id=${cell_id}
    Perform dlMimoMode Value Via API    cell_id=${cell_id}    dlMimoMode_value=${dlMimoMode_value}
    ${lua_script_path}    Download luashark from Artifactory and Extract
    Connect to Common Unit Master
    Precondition for bip capture with gnbMirroring scripts
    ${ue_index_list}    create list    ${ue_index}
    ${ue_and_cell}    Ue Attach and Start DL UL Traffic    ue_index_list=${ue_index_list}
    teardown the aasyslog save progress
    UE Verify Peak Throughput    ue_index_list=${ue_index_list}    ue_and_cell=${ue_and_cell}    duration=${30}
    Connect to Common Unit Master
    Bip Capture with gnbMirroring scripts with retry
    ${bip_log_list}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC
    Check pdcchPrecodingOption4x4 and numOfLayers in BIP log    bip_log=${bip_log_list}[0]
    ...    lua_script_path=${lua_script_path}
    [Teardown]      run keywords    Ue Stop DL UL Traffic and Detach    ${ue_index_list}    AND
    ...    Perform dlMimoMode Value Via API    cell_id=${cell_id}    dlMimoMode_value=${origin_value}
