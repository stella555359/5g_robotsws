*** Settings ***
Documentation     author: Chandana
...               contact: chandana.m_s@nokia.com
Suite Setup       ReachOnAir
Suite Teardown    Collect logs and cleanup
Test Setup        Create Test Case Folder
Library           OperatingSystem
Library           DateTime
Library           Collections
Library           ute_wtssim
Library           taf.transport.ssh    WITH NAME    ssh
Resource          ../../../Resources/Variables/Common_Variables.robot
Library           ../../../Resources/Python/ScfHelper.py    WITH NAME    scf_helper
Library           ../../../Resources/Python/AdminHelper.py    WITH NAME    admin_helper
Resource          ../../../Resources/robot/gnb.robot
Resource          ../../../Resources/robot/ute_setup.robot
Resource          ../../../Resources/robot/wts.robot
Resource          ../../../Resources/robot/log.robot
Resource          ../../../Resources/robot/suite_common_keywords.robot

*** Variables ***
${WTS_CFG_PATH}            ${CURDIR}/cfg
&{tddframe_list_params}    frameStructureType=semiStatic    ulDlDataSlotRatio=1/4    guardPeriodLength=2Symbols
&{drx_list_params}         drxLongCycle=40ms    drxOnDurationTimer=10ms    drxInactivityTimer=40ms
...                        drxRetransTimerDl=16slot    drxRetransTimerUl=16slot
${drx_list_name}           drxProfile1
${tddframe_list_name}      tddFrameStructure
&{csi_list_params}         csiReportPeriodicity=slots320
&{drx_flag}                actCDrx=true

*** Test Cases ***
Verify DRX functionality in NSA mode
    [Tags]    CRT
    UE Attach    ue_id=${UE_ID}    profile_id=${PROFILE_ID}
    SGNB Addition For Bearer    ue_id=${UE_ID}    target_gnb=${GNB_ID}    target_cells=${CELL_ID}    bearer=${BEARER_ID}
    Start Data Transfer And Verify Throughput    bearer=${BEARER_ID}    ue_id=${UE_ID}
    [Teardown]    Run Keywords    Stop All Data Transfer    ${UE_ID}    bearer=${BEARER_ID}
    ...    AND    UE Detach    ${UE_ID}    AND    Common Test Teardown

*** Keywords ***
ReachOnAir
    Suite Common Keywords    feature_folder=5GC000772
    Get original params from gnB
    ${delta}    Enable DRX Feature
    Recommission GNB With Delta    ${delta}
    Reboot for DRX
    Wait for gNB To Be Ready
    Prepare Environment Based On Run Type     cfg_type=custom
    Start WTS With Configuration
    Ensure Egate state
    Establish X2 link And Wait For Cell Setup
    Wait Until Keyword Succeeds    15min    30sec    gnb.Ensure radio module is online

Enable DRX Feature
    Initialise Delta Store    name=commondrx
    Add Param To Delta    dist_name=${PM_INTERVAL_DISTNAME}    param_name=reportingIntervalPm    value=5min
    Run Keyword If    '${RUN_TYPE}'=='FS_TDD_NSA'    Add List Parameters To Delta    dist_name=${NRCELL_DISTNAME}    list_name=${tddframe_list_name}
    ...    &{tddframe_list_params}
    Add Param To Delta    dist_name=${NRCELL_DISTNAME}    param_name=actCDrx    value=true
    Add List Parameters To Delta    dist_name=${NRCELL_DISTNAME}    list_name=${drx_list_name}    &{drx_list_params}
    Add List Parameters To Delta    dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-1    list_name=periodicCsiAcquisition    &{csi_list_params}
    ${delta}    Collect delta store
    [Return]    ${delta}

Verify drx prints in gNB logs
    ssh.connect_to    hostname=${DU_HOST}    username=${DU_USER}    password=${DU_PWD}    alias=DU_conn
    ssh.execute    bget 0:1 /tmp/node_0xe005/tmp/startup_cp_rt.log /tmp/ startup_cp_rt.log    connection=DU_conn
    ssh.download_file    remote_path=/tmp/startup_cp_rt.log    local_path=${LOG_PATH}/startup_cp_rt_772_02.log    connection=DU_conn
    ${drx_info1}    ssh.execute    cat /tmp/startup_cp_rt.log | grep -i UeContextModification    connection=DU_conn
    should contain    ${drx_info1}    Received UeContextModificationRequest from CU
    should contain    ${drx_info1}    Forward common::f1ap::UeContextModificationResponse to CU
    ${drx_ps1}    ssh.execute    cat /tmp/startup_cp_rt.log | grep -i drx    connection=DU_conn
    should contain    ${drx_ps1}    drxLongCycle: 80
    should contain    ${drx_ps1}    onDurationSlot: 20

Collect logs and cleanup
    Common Suite Teardown Keywords
    ${revert_delta}     Revert drx config
    Recommission GNB With Delta    ${revert_delta}
    Reboot for DRX
    Wait for gNB To Be Ready

Get original params from gnB
    ${scf_path}    admin_helper.download current scf file
    ${drx_value}    scf_helper.get_feature_paramters_from_scf    ${scf_path}     ${drx_flag}     ${NRCELL_DISTNAME}
    ${drx_list_parameters}    scf_helper.get_feature_paramters_from_scf    ${scf_path}    ${drx_list_params}   ${NRCELL_DISTNAME}
    ...     ${drx_list_name}
    Run Keyword If    '${RUN_TYPE}'=='FS_TDD_NSA'    Get TDD params    ${scf_path}
    Set Suite Variable    ${drx_value}
    Set Suite Variable    ${drx_list_parameters}

Get TDD params
    [Arguments]    ${scf_path}
    ${tdd_list_parameters}    scf_helper.get_feature_paramters_from_scf    ${scf_path}    ${tddframe_list_params}   ${NRCELL_DISTNAME}
    ...     ${tddframe_list_name}
    Set Suite Variable    ${tdd_list_parameters}

Revert drx config
    Initialise Delta Store    name=revert_commondrx
    Add Param To Delta    dist_name=${PM_INTERVAL_DISTNAME}    param_name=reportingIntervalPm    value=60min
    Run Keyword If    '${RUN_TYPE}'=='FS_TDD_NSA'    Add List Parameters To Delta    dist_name=${NRCELL_DISTNAME}    list_name=${tddframe_list_name}
    ...    &{tdd_list_parameters}
    ${value}    Get from Dictionary    ${drx_value}    actCDrx
    Add Param To Delta    dist_name=${NRCELL_DISTNAME}    param_name=actCDrx    value=${value}
    Add List Parameters To Delta    dist_name=${NRCELL_DISTNAME}    list_name=${drx_list_name}    &{drx_list_parameters}
    Add List Parameters To Delta    dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-1    list_name=periodicCsiAcquisition    &{csi_list_params}
    ${delta}    Collect delta store
    [Return]    ${delta}

Reboot for DRX
    Reboot Airphone For Recovery

Test Teardown
    Stop All Data Transfer    ${UE_ID}    bearer=${BEARER_ID}
    UE Detach    ${UE_ID}
    WTS Teardown Keywords
