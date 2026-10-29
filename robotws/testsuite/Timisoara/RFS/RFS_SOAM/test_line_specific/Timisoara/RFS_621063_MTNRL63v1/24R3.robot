*** Settings ***
Documentation    Robot Test Suite 2
Resource    ../../../test_resources/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.robot
Resource    ../../../test_resources/SBTS_SBTS__CM__Occupied_bandwidth_validation_CB008992.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS1_BTS2_Common_Startup_Check_TRM_Feature.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.robot

Library    taf.sbts.oam.coam.admin  WITH NAME  coam

Library    Collections
Library    taf/rfrl/csv4all/CSV4AllTestCases.py
Resource   taf/rfrl/uuf4all/uuf4all_keywords.robot

#UUF4ALL scope
Suite Setup                     Set Initial And Candidate

#UUF4ALL scope
Force Tags      CA_VRF_TSR2




*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${VAR_PTH}    /home/ute/MN/UTE/robotws/testsuite/Timisoara/RFS/RFS_SOAM/test_line_specific/Timisoara
${CNI_127210_ENABLED}    ${True}

# UUF4ALL Section
#Helper variable do teremine status of ST4.7 upgrade

${UPDATE_TEST_FAILED}          ${False}

@{CUSTOMERS}=                   Generic
${INITIAL}=                     ${None}
${CANDIDATE}=                   ${None}
${UPGRADE_ITERATION}=           3
${TEMP_ALLOWED_FAULTS}=         ${None}

# cellX2 links and/or NG links and/or E1 link unavailability: 7107
# FID 10 already exepted by default, need also 1815
# CNI 103974: 4773
# DSS alarms: 7513 7511 7509
@{CUSTOM_ALLOWED_ALARMS}        4773  1815  7300  7513  7511  7509  7107  62003  6134  4452  4530


&{node1}                        node_alias=NR_BTS1
...                             testline_object=${tl.enbs[0]}
...                             source_sw=${INITIAL}
...                             target_sw=${CANDIDATE}
...                             temporary_allowed_alarms=${TEMP_ALLOWED_FAULTS}
...                             custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}

&{node2}                        node_alias=LTE_BTS2
...                             testline_object=${tl.enbs[1]}
...                             source_sw=${INITIAL}
...                             target_sw=${CANDIDATE}
...                             temporary_allowed_alarms=${TEMP_ALLOWED_FAULTS}
...                             custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}

@{nodes}                        ${node1}  ${node2}


*** Test Cases ***

#UUF4ALL Upgrade Test-Case
PRELIMINARY UPGRADE
    [Timeout]   24h
    # Here is where the magic happens, single keyword to run the upgrade
    # the bts to target software
    # after which you can continue with our scope

    e2e_tl_upgrade_test
    ...   nodes_details=${nodes}
    ...   test_nodes_details=${nodes}
    ...   iterations_per_node=1
    ...   report=${True}
    ...   customers_list=${CUSTOMERS}

    # In test teardown we change the value of our global flag to indicate
    # the status of an upgrade
    [Teardown]   Run Keyword If Test Failed   Set Test Failed

UPDATE ROLLBACK UUF
    [Timeout]   24h

    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...   nodes_details=${nodes}
    ...   test_nodes_details=${nodes}
    ...   iterations_per_node=3
    ...   report=${True}
    ...   customers_list=${CUSTOMERS}
    ...   restore_to_target_sw=True

    # In test teardown we change the value of our global flag to indicate
    # the status of an upgrade
    [Teardown]   Run Keyword If Test Failed   Set Test Failed

# UUF Site Reset test
UUF SITE RESET WITHOUT HWF
    [Timeout]   24h
    e2e_tl_site_reset_without_hwf_with_oam_kpi
    ...   nodes_details=${nodes}
    ...   test_nodes_details=${nodes}
    ...   iterations_per_node=5
    ...   report=${True}
    ...   customers_list=${CUSTOMERS}


[1]SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_bbmod_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BBMOD_RESET_WRN_THR}    390
    ...    AND    Set Test Variable    ${BBMOD_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RESET_BBMOD_TYPE_LIST}    ABIA, ABIL, ABIN, ABIO, ABIP, ABIQ

    ...    AND    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    ...    AND    Append To List  ${RMOD_ECPRI_fid16_exceptions}  AKNB
    ...    AND    Append To List  ${RMOD_ECPRI_fid16_exceptions}  AKQJ

    TC__SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_rat_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    360
    ...    AND    Set Test Variable    ${LTE_RESET_WRN_THR}    180
    ...    AND    Set Test Variable    ${WCDMA_RESET_WRN_THR}    175
    ...    AND    Set Test Variable    ${GSM_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RAT_TECH}    ALL
    ...    AND    Set Test Variable    ${RESET_TYPE}    Hard

    ...    AND    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    TC__SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS_SBTS__STATE__RM_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__rm_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RM_CONFIGURED_INFO}    ALL
    ...    AND    Set Test Variable    ${RM_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RM_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RM_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${RM_RESET_WRN_THR}    180
    ...    AND    Set Test Variable    ${CNI_103974}    True

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    TC__SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS_SBTS__STATE__BTS1_BTS2_Common_Startup_Check_TRM_Feature
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_common_startup_check_trm_feature_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${tempRadioMasterTriggerTime}    2
    ...    AND    Set Test Variable    ${tempRadioMasterRecovTime}    2

    ...    AND    SBTS_SBTS__STATE__BTS1_BTS2_Common_Startup_Check_TRM_Feature.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS1_BTS2_Common_Startup_Check_TRM_Feature
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS1_BTS2_Common_Startup_Check_TRM_Feature
    TC__SBTS_SBTS__STATE__BTS1_BTS2_Common_Startup_Check_TRM_Feature
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS1_BTS2_Common_Startup_Check_TRM_Feature.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS_SBTS__CM__Occupied_bandwidth_validation_CB008992
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__cm__occupied_bandwith_validation_CB008992_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS}    BTS2
    ...    AND    Set Test Variable    ${SCF_file_path}    ${VAR_PTH}/RFS_621063_MTNRL63v1/MTNRL63_SBTS2_24R3_OWBEXCEDED.xml

    ...    AND    SBTS_SBTS__CM__Occupied_bandwidth_validation_CB008992.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__CM__Occupied_bandwidth_validation_CB008992
    ...    AND    Set Library Search Order    SBTS_SBTS__CM__Occupied_bandwidth_validation_CB008992
    TC__SBTS_SBTS__CM__Occupied_bandwidth_validation_CB008992
    [Teardown]    Run Keywords    SBTS_SBTS__CM__Occupied_bandwidth_validation_CB008992.TC Teardown
    ...    AND    Restore Resource Search Order


[1]RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESSES}    None
    ...    AND    Set Test Variable    ${UEs_CAPABILITIES}    Askey NokiaXR20
    ...    AND    Set Test Variable    ${UEs_BTS_CALL}    BTS2 BTS1
    ...    AND    Set Test Variable    ${UEs_TECHNOS}    NR LTE
    ...    AND    Set Test Variable    ${CELLS}    DEFAULT;DEFAULT
    ...    AND    Set Test Variable    ${CALL_DIRECTIONS_UEs}    uplink_downlink uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    25
    ...    AND    Set Test Variable    ${PROTOCOLS}    udp udp
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${SKIP_FAILING_UE}    False
    ...    AND    Set Test Variable    ${DELAY_BETWEEN_SNAPSHOTS}    30

    ...    AND    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    TC__RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order



*** Keywords ***
#UUF4ALL Test Helper KW
Set Test Failed
    Set Suite Variable  ${UPDATE_TEST_FAILED}  ${True}

#UUF4ALL Test Helper KW
Check Update Status
    Run Keyword If      ${UPDATE_TEST_FAILED}  Fail

#UUF4ALL Test Helper KW
Simple admin connection
    ${setup_status}=  run keyword and return status  coam.setup admin
    ...  bts_host=192.168.255.1
    ...  bts_port=443
    ...  admin_api_log_dir=/home/ute/admin_logs/
    ...  name=alias
    Log                       Admin Setup Status: ${setup_status}
    run keyword unless        ${setup_status}  Fail  Setup Admin Failed
    &{bts_info}               coam.get_bts_info  connection=alias  timeout=60
    Log                       ${bts_info}
    [Teardown]  run keyword
    ...       coam.teardown_admin  connection=alias

#UUF4ALL Test Helper KW
Set Initial And Candidate
    ${initial_sw}             Get Source SW
    ${candidate_sw}           Get Target SW

    Set to dictionary         ${node1}
    ...                       source_sw=${initial_sw}
    ...                       target_sw=${candidate_sw}

    Set to dictionary         ${node2}
    ...                       source_sw=${initial_sw}
    ...                       target_sw=${candidate_sw}


