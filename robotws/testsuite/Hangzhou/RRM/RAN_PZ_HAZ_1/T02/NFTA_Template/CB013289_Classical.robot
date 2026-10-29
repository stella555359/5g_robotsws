*** Settings ***
Documentation
...    Author: cici wei
...    Contact: cici.wei@nokia-sbell.com
...    this file is module case template,you can create your test case according to this template.
...    Please do not modify the file without notification to author


Suite Setup    Common Suite Setup For RRM
#Suite Teardown    Common Suite Teardown For RRM

Force Tags
...      CRT             #Tag Item
...      VRF_HAZ1             #Competence Area
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../Resources/Classical/RRM_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot





*** Test Cases ***
CB013289-A#EC1_TC12_Inter-RAT_handover_from_NR_to_LTE_without_data_forwarding_for_peer_eNodeB_not_support_direct_forwarding
    [Tags]    TC12    NFTA
    [Documentation]
    ...    Author: cici.wei@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Parameter Updated In Gnb For CB013289_TC12
	SetInitializePAValue    pa_port=1,2;    pa_value=0;
	Collect Wireshark Log    log_type=wireshark    product_type=gnb    bts_index=${0}
	Prepare And Attach UE    ue_index=0
    Start DL and UL Call For UE    ue_index=${0}
    Start VONR Call For UE    ue_index=0    capabilities=samsung23
    Trigger A2 By Modify PA Signal
    ${local_file_path}    Stop And Download Wireshark Log    log_type=wireshark   product_type=gnb    bts_index=${0}
	Check Wireshark Log For CB013289_TC12    wireshark_path=${local_file_path}
    [Teardown]    Case Postcondition


*** Keywords ***
Case Precondition
    log to console    Case Precondition
    Common Test Setup For RRM

Case Postcondition
    log to console    Case Postcondition
    Common Test Teardown For RRM

Prepare And Attach UE
    [Arguments]    ${ue_index}=${0}    ${ui_version}=S21
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
    Log to Console    \n***Prepare UE***
    Prepare UE    ${ue_${ue_index}_type}    ue_index=${ue_index}    ui_version=${ui_version}
    UE Attach    ${ue_${ue_index}_type}    ue_index=${ue_index}    verify_attach=True
    [Return]     ${ue_${ue_index}_type}

Parameter Updated In Gnb For CB013289_TC12
    @{para_list}          Create List    actInterRatHoDirectDlDataFwd    iRatDataForwardingMethod
    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRADJECELL-1
    @{value_list_true}    Create List    IRATDirectDataFwdOnNg    directDataFwd
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=gnb

Trigger A2 By Modify PA Signal
    ${source_pa_port_list}     Create List     1    2
    ${source_pa_value_list}    Create List     0    127
    ${target_pa_port_list}     Create List    7    8
    ${target_pa_value_list}    Create List    127    0
    Modify PA    source_pa_port_list=${source_pa_port_list}
    ...          source_pa_value_list=${source_pa_value_list}
    ...          target_pa_port_list=${target_pa_port_list}
    ...          target_pa_value_list=${target_pa_value_list}
    ...          step=${10}

Stop VONR Call For UE
    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_${ue_index}_type}
    Log To Console    \n*** Stop VONR Call***
    Stop VONR Call    ue_type=${ue_type}      vc_alias=VC_1

Start VONR Call Without Require UE
    [Arguments]    ${ue_index}=${0}
#    ute_ue.detach_ue    UE_${ue_index}
#    ute_ue.attach_ue    UE_${ue_index}
#    Sleep    5
#    Detach UE0
#    Attach UE0
    Start Voice Call    vc_alias=VC_1   ue_alias=UE_${ue_index}    to=004488    duration=600s

Check Wireshark Log For CB013289_TC12_before
    [Arguments]    ${input_file}=${wireshark_local_file_path_vCU}
    ${filter_list} =    Create list    f1ap.procedureCode == 11
    ${expect_message}=    Create list    RRC Setup Request
    ${filter_length}    get length    ${filter_list}
    FOR    ${index}    IN RANGE    ${filter_length}
        ${result} =    Analysis Wireshark Log    input_file=${input_file}
        ...                                      filter_expression=${filter_list[${index}]}
        should contain    ${result}    ${expect_message[${index}]}
    END

Check Wireshark Log For CB013289_TC12
    [Arguments]    ${wireshark_path}=${wireshark_local_file_path_vCU}
    &{analysis_dict}       Create Dictionary    filter_conditions=f1ap.procedureCode==11
    ${expect_message}=    Set Variable    RRC Setup Request
    ${result}=    Log Analysis    operation=filter    log_type=wireshark    log_path=${wireshark_path}
    ...                           analysis_dict=${analysis_dict}
    Should Contain    ${result}    ${expect_message}