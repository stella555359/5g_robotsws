*** Settings ***

Documentation     author: Merin Varghese
...               contact: merin.varghese@nokia.com
...               Description: CB009301 focuses on integrated fronthaul delay measurement
...               and adaptation for eCPRI FH-interfaces

Resource        ../../../Resources/robot/suite_common_keywords.robot
Resource        ../../../Resources/robot/ue_operations.robot
Resource        ../../../Resources/robot/gnb.robot
Resource        ../../../Resources/robot/wts.robot
Library         ../../../Resources/Python/Utilities.py    WITH NAME    utilities

Suite Setup       Common Suite Setup    feature_folder=CB009301

*** Variables ***
${dl_tput}                    10
${ul_tput}                    10
@{SA_UE_List}                 1
@{Delay_list}                 dlMinDelay    ulMinDelay
@{SA_Scell_Index}             0
${IS_ORAN}                    True
${RFM_Plugin}                 RFMPlugin_O-RU_FJ_TA08029-B311-01_0006.zip
${TC1_configs}                ${CURDIR}/Config_Files/TC1_ORAN/
${TC2_configs}                ${CURDIR}/Config_Files/TC2_ORAN/
${TC3_configs}                ${CURDIR}/Config_Files/TC3_ORAN/
${REPETITIONS_9301}           1

*** Test Cases ***
CB009301_A-001_Enable and disable feature CB009301 and eCPRI message type5 session creation and deletion
    [Documentation]    Enable and disable feature CB009301 and eCPRI message type5 session creation and deletion
    [Tags]    AP_REG    CB009301_TC1
    [Setup]    Generic Test Setup    feature=CB009301    cell_deployment=SA    custom_config=True    custom_config_folder=${TC1_configs}
    Activate eCPRI Delay Measurement
    Run Keyword And Continue On Failure    Get fronthaul Measured Delay for UL and DL
    Register and Start Traffic For SA UEs    ${SA_UE_List}   uplink_tput=${ul_tput}
    ...     downlink_tput=${dl_tput}
    Sleep    30s
    Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA
    Validate UE stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    scell=${SA_Scell_Index}
    Stop Traffic and Detach SA UEs    sa_ue_list=${SA_UE_List}
    [Teardown]    Run Keywords    Revert gNB configuration    AND    Simple Test Teardown    ${SA_UE_List}

CB009301_A-005_Verification of eCPRI delay measurement with Multi RU configuration on both LOKI_A and LOKI_B
    [Documentation]    The purpose of this test case is to verify the multiple eCPRI message type5 session creation
    ...    according to the no of configured RUs in LokiA and LokiB
    [Tags]    AP_REG    CB009301_TC2
    [Setup]    Generic Test Setup    feature=CB009301    cell_deployment=SA    custom_config=True
    ...    custom_config_folder=${TC2_configs}
    Activate eCPRI Delay Measurement
    Run Keyword And Continue On Failure    Get fronthaul Measured Delay for UL and DL
    Register and Start Traffic For SA UEs    ${SA_UE_List}   uplink_tput=${ul_tput}
    ...     downlink_tput=${dl_tput}
    Sleep    30s
    Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA
    Validate UE stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    scell=${SA_Scell_Index}
    Stop Traffic and Detach SA UEs    sa_ue_list=${SA_UE_List}
    [Teardown]    Run Keywords    Revert gNB configuration    AND    Simple Test Teardown    ${SA_UE_List}

CB009301_A-008_Check measurement not triggered by lock unlock cell
    [Documentation]    The purpose of this test case  is to verify lock/unlock cell will not trigger re-measurement
    [Tags]    AP_REG    CB009301_TC3
    [Setup]    Generic Test Setup    feature=CB009301    cell_deployment=SA    custom_config=True
    ...    custom_config_folder=${TC3_configs}
    Activate eCPRI Delay Measurement
    FOR    ${index}    IN RANGE    ${REPETITIONS_9301}
        Run Keyword And Continue On Failure    Get fronthaul Measured Delay for UL and DL
        Perform NR Cell Lock and Unlock
        Sleep    60s
        Run Keyword And Continue On Failure    Get fronthaul Measured Delay for UL and DL
        Register and Start Traffic For SA UEs    ${SA_UE_List}   uplink_tput=${ul_tput}
        ...     downlink_tput=${dl_tput}
        Sleep    30s
        Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
        ...    expected_ul_tput=${ul_tput}    mode=SA
        Validate UE stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
        ...    expected_ul_tput=${ul_tput}    scell=${SA_Scell_Index}
        Stop Traffic and Detach SA UEs    sa_ue_list=${SA_UE_List}
    END
    [Teardown]    Run Keywords    Revert gNB configuration    AND    Simple Test Teardown    ${SA_UE_List}

*** Keywords ***
Activate eCPRI Delay Measurement
    Set distnames for FH delay measurement
    Download original SCF file and get the original feature flag value
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${FEATCADM_dist}    actEcpriDelayMeasurement=true
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}
    Set Test Variable    ${Gnb_Revert}    True
    Wait for gNB To Be Ready

Set distnames for FH delay measurement
    Set global variable    ${FEATCADM_dist}    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    Set global variable    ${CABLINK_dist}    MRBTS-${BTS_ID}/EQM_R-4/HWTOP_R-1/CABLINK_R-1001/FHLKDLY_R-1

Download original SCF file and get the original feature flag value
    ${original_scf_path}    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_original.xml
    set test variable    ${original_scf_path}

Get fronthaul Measured Delay for UL and DL
    admin.Connect To
    ${param_value}    admin.Get Parameter By Distname    dist_name=${CABLINK_dist}    parameter_list=${Delay_list}
    ${dlMinDelay}=    Set Variable    ${param_value[0]["parameters"]["dlMinDelay"]}
    ${ulMinDelay}=    Set Variable    ${param_value[0]["parameters"]["ulMinDelay"]}
    Run Keyword And Continue On Failure    Should Be True    ${dlMinDelay} >= 0
    Run Keyword And Continue On Failure    Should Be True    ${ulMinDelay} >= 0
    Log to console     Going to check in btslog        format=*^60
    Wait Until Keyword Succeeds
    ...    120sec
    ...    20sec    Verify min delay values in syslog    ${dlMinDelay}    ${ulMinDelay}
    [Teardown]    admin.Teardown

Revert gNB configuration
    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_used_during_TC.xml
    return from keyword if    '${Gnb_Revert}' == 'False'
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${FEATCADM_dist}    actEcpriDelayMeasurement=false
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}
    Set Test Variable    ${Gnb_Revert}    True
    Wait for gNB To Be Ready

Verify min delay values in syslog
    [Arguments]    ${dlMinDelay}    ${ulMinDelay}
    ${rc}    ${output}=    Run and Return RC and Output    grep -i ",\\sDelay measurement result" /tmp/btslog2/SYSLOG_*
    Should be Equal as Integers     ${rc}    0    msg=expected prints not found in syslog
    run keyword if    ${rc} == 0    log to console    ${output}
    utilities.verify_if_syslog_and_ui_values_match    ${output}    ${ulMinDelay}    ${dlMinDelay}