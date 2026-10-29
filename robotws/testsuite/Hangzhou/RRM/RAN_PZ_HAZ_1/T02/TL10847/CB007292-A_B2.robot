*** Settings ***
Documentation
...   Author: shuangfeng.f.sun@nokia-sbell.com
...   Contact: shuangfeng.f.sun@nokia-sbell.com

Suite Setup    Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG03_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot
Resource          ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot

*** Test Cases ***
CB007292-A_B2_No_broadcast_of_eCallOverIMS_support_in_SIB1
    [Tags]    CRT    CB007292-A_B2
    [Timeout]    45min
    [Documentation]
    ...    Author: Shuangfeng.f.sun@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Common Case Precondition
    Initialize PA Signal FOR 10847
    Set Initialize PA Value    pa_port=17,21;    pa_value=0;
    @{para_list}          Create List    actECallOverIMS
    @{mo_list_vdu}        Create List    MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    @{value_list_true}    Create List    false
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vdu
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vcu
    Start Collect Wireshark Log In vCU
    Prepare And Attach UE    ue_index=1    ui_version=S21
    Start DL and UL Call For UE    ue_index=1
    @{para_list}          Create List    actECallOverIMS
    @{mo_list_vdu}        Create List    MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    @{value_list_true}    Create List    true
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vdu
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vcu
    ${local_file_path}    Stop Wireshark Log And Download To K8s Master In vCU
    ${result}    Check eCallOverIMS_Support in SIB1    ${local_file_path}
    should contain    ${result}    99
    Sleep     5s
    Start Collect Wireshark Log In vCU
    @{para_list}          Create List    actECallOverIMS
    @{mo_list_vdu}        Create List    MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    @{value_list_true}    Create List    false
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vdu
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vcu
    ${local_file_path}    Stop Wireshark Log And Download To K8s Master In vCU
    ${result}    Check eCallOverIMS_Support in SIB1      ${local_file_path}
    Should be empty    ${result}
    [Teardown]    Case Postcondition

*** Keywords ***
Get TestLine Threshold From File
    [Arguments]    ${file_path}    ${threshold}
    ${json_content}    get_content_from_yml    ${file_path}
    [Return]    ${json_content}[${threshold}]

Check eCallOverIMS_Support in SIB1
    [Arguments]    ${local_file_path}=/home/ute/test_results/
    ${average_latency}    Set Variable    ${0}
    @{latency_list}    Create List
    ${measurement_report_filter}    Set Variable        nr-rrc.eCallOverIMS_Support == 0
    ${updated_cell}=    Run
    ...    tshark -Y "${measurement_report_filter}" -T fields -e f1ap.nRPCI -r ${local_file_path}
    [Return]    ${updated_cell}

Common Case Precondition
    log to console    Case Precondition
    Common Test Setup For AIC
    ${NEW_PLAN_NAME}   Get Test Case Name
    Set Test Variable  ${NEW_PLAN_NAME}

Start Collect Wireshark Log In vCU
    [Arguments]
    Log to Console    \n***Start Wireshark Log In vCU***
    Start Wireshark Log In vCU

Stop Wireshark Log In vCU
    ${local_file_path}    Stop Wireshark Log And Download To K8s Master In vCU

Start DL traffic by index
    [Arguments]    ${ue_index}=${0}
    Start traffic    ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    direction=dl   dt_index=${0}
    ...              throughput=10M    duration=${600}

Prepare And Attach UE
    [Arguments]    ${ue_index}=${0}    ${ui_version}=MATE40PROUI1.0
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
    Log to Console    \n***Prepare UE***
    Prepare UE    ${ue_${ue_index}_type}    ue_index=${ue_index}    ui_version=${ui_version}
    Log to Console    \n***Prepare to attach.***
    UE Attach    ${ue_${ue_index}_type}    ue_index=${ue_index}    verify_attach=True
    Log to Console    \n***UE attached.***
    [Return]     ${ue_${ue_index}_type}

Initialize PA Signal FOR 10847
    SetInitializePAValue    pa_port=1-32;    pa_value=120;

Case Postcondition
    log to console    Case Postcondition
    Common Test Teardown For AIC