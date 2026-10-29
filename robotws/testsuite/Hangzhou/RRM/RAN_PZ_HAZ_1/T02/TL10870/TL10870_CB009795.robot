*** Settings ***
Documentation
...    Author: lanhua zhao
...    Contact: lanhua.zhao@nokia-sbell.com
...    this file is for CB009795.
...    Please do not modify the file without notification to author


Suite Setup    Common Suite Setup For AIC
#Suite Teardown    Common Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      VRF_HAZ1             #Competence Area
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot




*** Test Cases ***
CB009795_07_Monitoring_behavior_of_MBA_Trace_Session_with_PCMD_content_after_L3_layer_failure_in_gNB-CU-UP
    [Tags]    CRT    TC07
    [Documentation]
    ...    Author: lanhua.zhao@nokia-sbell.com
    ...    History change: 11.26.2024, Lanhua add case CB009795_07
    [Setup]    Case Precondition
    Open DCAP
    Download Wireshark Plugin Nsetapx
    Set Initialize PA Value    pa_port=9;10-16;1-8;    pa_value=5;127;127;
    Collect Wireshark Log    log_type=wireshark_oam    product_type=vcu    bts_index=${0}
    Prepare And Attach UE    ue_index=1    ui_version=default
    Start DL and UL Call For UE    ue_index=1
    Delete Pod    pod_name=cpnrt
    Sleep    60s
    ${local_file_path}    Stop And Download Wireshark Log    log_type=wireshark_oam    product_type=vcu    bts_index=${0}
    Sleep    5s
    Check Wireshark Log For CB009795_07    wireshark_path=${local_file_path}
    [Teardown]    Case Postcondition

*** Keywords ***
Case Precondition
    log to console    Case Precondition
    Common Test Setup For AIC

Case Postcondition
    log to console    Case Postcondition
    vDU Login By Rest
    Run Keyword And Ignore Error    Detach UE    ue_index=${1}
    Common Test Teardown For AIC
    Run Keyword And Ignore Error    vDU Logout By Rest

Prepare And Attach UE
    [Arguments]    ${ue_index}=${0}    ${ui_version}=MATE40PROUI1.0
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
    Log to Console    \n***Prepare UE***
    Prepare UE    ${ue_${ue_index}_type}    ue_index=${ue_index}    ui_version=${ui_version}
    UE Attach    ${ue_${ue_index}_type}    ue_index=${ue_index}    verify_attach=True
    [Return]     ${ue_${ue_index}_type}

Parameter Updated In vDU For CB009795
    @{para_list}          Create List    actChipsetAndRanInfoExchange
    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    @{value_list_true}    Create List    true
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vdu

Modify PA Signal For Source And Target
    ${source_pa_port_list}     Create List     1    2
    ${source_pa_value_list}    Create List     127    20
    ${target_pa_port_list}     Create List    5    6    9
    ${target_pa_value_list}    Create List    0    127
    Modify PA    source_pa_port_list=${source_pa_port_list}
    ...          source_pa_value_list=${source_pa_value_list}
    ...          target_pa_port_list=${target_pa_port_list}
    ...          target_pa_value_list=${target_pa_value_list}
    ...          step=${10}

Check Wireshark Log For CB009795_07
    [Arguments]    ${wireshark_path}=${wireshark_local_file_path_vCU}
    &{analysis_dict}       Create Dictionary    filter_conditions=nsetapx.TraceMessage == 5
    ${expect_message}=    Set Variable    StopRecordingSession
    ${result}=    Log Analysis    operation=filter    log_type=wireshark    log_path=${wireshark_path}
    ...                           analysis_dict=${analysis_dict}
    Should Contain    ${result}    ${expect_message}


Open DCAP
    OperatingSystem.Run    DCAP_Basic_controller start