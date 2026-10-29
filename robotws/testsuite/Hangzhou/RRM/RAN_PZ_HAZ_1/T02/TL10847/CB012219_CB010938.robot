*** Settings ***
Documentation
...    Author: shuangfeng
...    Contact: shuangfeng.f.sun@nokia-sbell.com
...    this file is module case template,you can create your test case according to this template.
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
Resource          ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot

*** Test Cases ***
CB012219_03_CB010938_Chipset_and_RAN_Identification_exchange_during_UE_registration
    [Tags]    CRT    CB012219_03
    [Documentation]
    ...    Author: shuangfeng.f.sun@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Initialize PA Signal FOR 10847
    Set Initialize PA Value    pa_port=13;    pa_value=0;
    Start Collect Wireshark Log In vCU
    Start Counter For CB012219_03
    @{para_list}          Create List    actChipsetAndRanInfoExchange
    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    @{value_list_true}    Create List    false
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vcu
    sleep    5s
    @{para_list}          Create List    actChipsetAndRanInfoExchange
    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    @{value_list_true}    Create List    true
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vcu
    sleep    5s
    Set Library Search Order    AIC_UE    real_ue
    Prepare And Attach UE For Qualcomm    ue_index=0
    Start DL and UL Call For UE    ue_index=0    ue_type=qualcomm
    Sleep    5s    reason=wait call stable
    ${local_file_path}    Stop Wireshark Log And Download To K8s Master In vCU
    ${result}    Check dummy4 in UERadioCapability      ${local_file_path}
    Sleep    360s
    Collect And Check Counter
    [Teardown]    Case Postcondition

*** Keywords ***
Start Collect Wireshark Log In vCU
    [Arguments]
    Log to Console    \n***Start Wireshark Log In vCU***
    Start Wireshark Log In vCU

Check dummy4 in UERadioCapability
    [Arguments]    ${local_file_path}=/home/ute/test_results/

    ${average_latency}    Set Variable    ${0}
    @{latency_list}    Create List
    ${measurement_report_filter}    Set Variable       nr-rrc.maxSimultaneousResourceSetsPerCC == 5
    ${updated_cell}=    Run
    ...    tshark -Y "${measurement_report_filter}" -T fields -e f1ap.nRPCI -r ${local_file_path}
    [Return]    ${updated_cell}

Prepare And Attach UE For Qualcomm
    [Arguments]    ${ue_index}=${0}    ${capabilities}=REAL_QUALCOMM_UE
    set test variable    ${ue_type}    qualcomm
    Log to Console    \n***Prepare UE***
    ute_ue.Require Ue    ue_alias=UE_${ue_index}    capabilities=${capabilities}
    Detach UE    ue_index=${ue_index}    ue_type=qualcomm
    UE Attach    ${ue_type}    ue_index=${ue_index}    verify_attach=True
    [Return]     ${ue_type}

Prepare UE as M80
    [Arguments]    ${ue_index}=${0}
    Log to Console    \n***Prepare M80***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
    Log to Console    \n***Prepare UE***
    Prepare UE    ${ue_type}    ue_index=${ue_index}    ui_version=default
    Log to Console    \n***UE Prepared...***
    [Return]     ${ue_${ue_index}_type}

Attach UE as M80
    [Arguments]    ${ue_index}=${0}
    Log to Console    \n***M80 attach***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
    UE Attach    ${ue_type}    ue_index=${ue_index}    verify_attach=True
    Log to Console    \n***UE Attached...***

Start DL and UL Call For UE
    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_${ue_index}_type}
    Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    dt_index=${ue_index}
    ...              throughput=110M    duration=${600}
    Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul    dt_index=${ue_index}
    ...              throughput=110M    duration=${600}

Case Precondition
    log to console    Case Precondition
    Common Test Setup For AIC

Common Test Setup For AIC
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${tc_name}=    Replace String    ${TEST_NAME}    ${SPACE}    _
    ${case_log_path}    Join path    ${SUITE_LOG_DIRECTORY}    ${tc_name}_${timestamp}
    Set Suite Variable    ${TEST_LOG_DIRECTORY}    ${case_log_path}
    Create directory    ${TEST_LOG_DIRECTORY}

Common Suite Setup For AIC
    Create Suite Directory
    ${vdu_version}=    Get vDU Version
    Set Suite Variable    ${VDU_VERSION}    ${vdu_version}
    Get SSH Connection Infor For vDU K8s Master
    Get SSH Connection Infor For vCU K8s Master
    ${mrbts_id_list}    ${nrbts_id_list}    Get Multi Gnb Id
    Set suite variable     ${MRBTS_ID_LIST}    ${mrbts_id_list}
    Set suite variable     ${NRBTS_ID_LIST}    ${nrbts_id_list}
    Run Keyword And Ignore Error    Get Iperf Info
    Run Keyword And Ignore Error    Prepare Netrc On VM
    Run Keyword And Ignore Error    Get TestLine Name From UTE Cloud
    Run Keyword And Ignore Error    Get Testline Type

Case Postcondition
    log to console    Case Postcondition
    vDU Login By Rest
    Run Keyword And Ignore Error    Detach UE    ue_index=${0}    ue_type=qualcomm
    Common Test Teardown For AIC
    Run Keyword And Ignore Error    vDU Logout By Rest

Start Counter For CB012219_02
    ${rule2}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2;
    ...         Counter: M55181C00008;
    ...         Counter rule: max(M55181C00008)>=1;
    ${rule1}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2;
    ...         Counter: M55181C00009;
    ...         Counter rule: max(M55181C00009)>=1;
    ${rule_list}    Create List    ${rule2}    ${rule1}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=vcu    bts_index=0
    ...                                                     counter_rule=${rule_list}

Start Counter For CB012219_03
    ${rule2}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2;
    ...         Counter: M55181C00008;
    ...         Counter rule: max(M55181C00008)>0;
    ${rule1}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2;
    ...         Counter: M55181C00009;
    ...         Counter rule: max(M55181C00009)>=1;
    ${rule3}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2;
    ...         Counter: M55124C00025;
    ...         Counter rule: max(M55124C00025)>=1;
    ${rule_list}    Create List    ${rule2}    ${rule1}    ${rule3}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=vcu    bts_index=0
    ...                                                     counter_rule=${rule_list}

Start Counter For CB012219_25_False
    ${rule2}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2;
    ...         Counter: M55181C00008;
    ...         Counter rule: min(M55181C00008)==0;
    ${rule1}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2;
    ...         Counter: M55181C00009;
    ...         Counter rule: min(M55181C00009)==0;
    ${rule_list}    Create List    ${rule2}    ${rule1}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=vcu    bts_index=0
    ...                                                     counter_rule=${rule_list}

Collect And Check Counter
    ${result}    Counter Operation    operation=collect_counter_and_check_rule    product_type=vcu
    ...                               bts_index=0    cudu_index=0
    Log To Console    \nCounter Rule Collect and Check Result is: ${result}

Check Counter for CB010938
    Sleep    360s    reason=wait generate counter
    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    &{type1_counter_dict}    create dictionary    counterId=M55124C00025,M55181C00008,M55181C00009
    ...                                           dimDN=${dim_dn}/NRCELL-2
    ...                                           ne=vCU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    &{type2_counter_dict}    create dictionary    counterId=M55124C00026
    ...                                           dimDN=${dim_dn}/NRCELL-2
    ...                                           ne=vCU
    ...                                           gnbIndex=0
    ...                                           comparison=equal
    ...                                           value=0
    ${counter_list}    Create List    ${type1_counter_dict}    ${type2_counter_dict}

    FOR    ${counter}    IN    @{counter_list}
        ${counter_id_list}=    split_string    ${counter['counterId']}    ,
        ${ne}    Set Variable   ${counter['ne']}

        Run Keyword If    '${ne}'=='vDU'     Check Counter In vDU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
        ...    ELSE IF    '${ne}'=='vCU'    Check Counter In vCU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
    END

Check Counter In vDU
    [Arguments]    ${counter_id_list}    ${dim_dn}    ${gnb_index}=0
    ...            ${comparison}=greater    ${expected_value}=0    ${get_number}=3
    Log to Console    \n***check counter in vDU***
    FOR    ${counter_id}    IN    @{counter_id_list}
        Check Counter For vDU   counter_id=${counter_id}
        ...                     dimension_dn=${dim_dn}
        ...                     comparison=${comparison}
        ...                     expected_value=${expected_value}
        ...                     get_number=${get_number}
        ...                     gnb_index=${gnb_index}
    END

Check Counter In vCU
    [Arguments]    ${counter_id_list}    ${dim_dn}    ${gnb_index}=0
    ...            ${comparison}=greater    ${expected_value}=0    ${get_number}=3
    Log to Console    \n***check counter in vCU***
    FOR    ${counter_id}    IN    @{counter_id_list}
        @{words}=    split string    ${counter_id}   C
        ${mea_id}=   Fetch From Right    ${words[0]}  M

        Check Counter For vCU   counter_id=${counter_id}
        ...                     measurement_id=${mea_id}
        ...                     dimension_dist_name=${dim_dn}
        ...                     comparison=${comparison}
        ...                     expected_value=${expected_value}
        ...                     get_number=${get_number}
        ...                     gnb_index=${gnb_index}
    END

Start Collect Wireshark Log
    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cpif    ${NE}=vDU    ${gnb_index}=${0}
    ...            ${gnb2_index}=${1}    ${index}=${0}    ${index1}=${0}
    Run Keyword If    '${NE}'=='vCU'    Start Collect Wireshark Log In vCU
    ...                                                           container_name=${container_name}
    ...                                                           pod_name=${pod_name}
    ...                                                           index=${index}
    ...       ELSE IF    '${NE}'=='vDU'    Start Collect Wireshark Log In vDU
    ...                                                           container_name=${container_name}
    ...                                                           pod_name=${pod_name}
    ...                                                           gnb_index=${gnb_index}
    ...                                                           index=${index}
    ...       ELSE IF    '${NE}'=='all'    Start Collect Wireshark Log Both vCU And vDU
    ...                                                           container_name=${container_name}
    ...                                                           vdu_pod_name=cprt
    ...                                                           vcu_pod_name=cpif
    ...                                                           gnb_index=${gnb_index}
    ...                                                           index=${index}
    ...                                                           index1=${index1}
    ...       ELSE IF    '${NE}'=='Multi_vDU'    Start Collect Wireshark Log For Multi vDU
    ...                                                           container_name=${container_name}
    ...                                                           pod_name=${pod_name}
    ...                                                           gnb_index=${gnb_index}
    ...                                                           gnb2_index=${gnb2_index}
    ...                                                           index=${index}
    ...                                                           index1=${index1}
    ...       ELSE IF    '${NE}'=='Multi_vCU'    Start Collect Wireshark Log For Multi vCU
    ...                                                           container_name=${container_name}
    ...                                                           pod_name=${pod_name}
    ...                                                           index=${index}
    ...                                                           index1=${index1}

Check Wireshark Log
    [Arguments]    ${input_file}=${wireshark_local_file_path_vCU}
    ${filter_list} =    Create list    f1ap.service_state == 0
    ${expect_message}=    Create list    UEContextReleaseCommand
    ${filter_length}    get length    ${filter_list}
    FOR    ${index}    IN RANGE    ${filter_length}
        ${result} =    Analysis Wireshark Log    input_file=${input_file}
        ...                                      filter_expression=${filter_list[${index}]}
        should contain    ${result}    ${expect_message[${index}]}
    END

Detach UE
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_${ue_index}_type}
    UE Detach    ${ue_type}    ue_index=${ue_index}
    sleep    60s    reason=wait detach UE Successfully

Initialize PA Signal FOR 10847
    SetInitializePAValue    pa_port=1-32;    pa_value=120;

