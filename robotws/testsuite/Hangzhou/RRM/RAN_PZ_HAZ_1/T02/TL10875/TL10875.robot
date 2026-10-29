*** Settings ***
Documentation
...    Author: Yang Mengli
...    Contact: mengli.yang@nokia-sbell.com
...    this file is collect some Common KWs of AIC,you can use it in your case directly.
...    Please do not modify the file without notification to author


Suite Setup    Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG03_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot


*** Test Cases ***
CB010411_5GC000784_Successful_setup_of_Emergency_call_for_UE_with_ongoing_data_service
    [Tags]        CRT      5GC000784
    [Documentation]
    ...    Author: juan.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    20.10.2022,juan.liu@nokia-sbell.com, draft
    [Setup]        Case Precondition
    Initialize PA Signal
    Start Collect Wireshark Log    container_name=nwmgmt    pod_name=cpif    NE=vCU
    Prepare And Attach UE    ue_index=0
    Start Call For UE    ue_index=0    direction=ul
    Start Call For UE    ue_index=0    direction=dl
    Start Emergency Call For UE   ue_index=0
    Sleep  120s
    Stop Wireshark Log    container_name=nwmgmt    pod_name=cpif    NE=vCU    vcu_log_name=vcu_wireshark
    Check Counter For 5GC000784
    [Teardown]        Case Postcondition


CB010411_5GC001630_SA_NSA_sharing_support_up_to_6_PLMNs_and_multiple_PLMN_Sets_per_cell_with_AMFs
    [Tags]        CRT      5GC001630
    [Documentation]
    ...    Author: juan.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    20.10.2022,juan.liu@nokia-sbell.com, draft
    [Setup]        Case Precondition
    Prepare And Attach UE    ue_index=0
    Start VONR Call For UE    ue_index=0
    Start Call For UE    ue_index=0    direction=dl
    Start Call For UE    ue_index=0    direction=ul
    Prepare And Attach UE    ue_index=1    ui_version=MATE40PROUI1.0
    Start Call For UE    ue_index=1    direction=dl
    Check SA Counter For 26203
    [Teardown]        5GC001630 Postcondition

*** Keywords ***
Case Precondition
    log to console    Case Precondition
    Common Test Setup For AIC
    ${vdu_hostname_dict}    ${vdu_username_dict}    ${vdu_password_dict}    ${vdu_ns_dict}
    ...                                               Get SSH Connection Infor For Multiple vDU With Different vCU
    Set Test Variable    ${vdu_hostname_dict}
    Set Test Variable    ${vdu_username_dict}
    Set Test Variable    ${vdu_password_dict}
    Set Test Variable    ${vdu_ns_dict}
    ${vcu_hostname_list}  ${vcu_username_list}  ${vcu_password_list}  ${vcu_ns_list}
    ...                                               Get SSH Connection Infor For Multiple vCU K8s Master
    Set Test Variable    ${vcu_hostname_list}
    Set Test Variable    ${vcu_username_list}
    Set Test Variable    ${vcu_password_list}
    Set Test Variable    ${vcu_ns_list}
    ${NEW_PLAN_NAME}     Get Test Case Name
    Set Test Variable    ${NEW_PLAN_NAME}

Common Test Setup For AIC
    Create Case Directory
    _Check Maximum Line Length

Case Postcondition
    log to console    Case Postcondition
    Common Test Teardown For AIC
    run keyword and ignore error  Stop Wireshark Log    container_name=nwmgmt    pod_name=cpif    NE=vCU
    ...                                                 vcu_log_name=vcu_wireshark
    run keyword and ignore error  Detach UE    ue_index=0

Common Test Teardown For AIC
    Run keyword and ignore error    Logout To vCU By Rest
    Run keyword and ignore error    vDU Logout By Rest

5GC000749 Postcondition
    log to console    Case Postcondition
    Close LTE Cell PA Signal
    Common Test Teardown For AIC
    run keyword and ignore error  Stop Wireshark Log    container_name=nwmgmt    pod_name=cpif    NE=vCU
    ...                                                 vcu_log_name=vcu_wireshark
    run keyword and ignore error  Detach UE    ue_index=0

5GC001630 Postcondition
    log to console    Case Postcondition
    Common Test Teardown For AIC
    run keyword and ignore error  Unlock One NG-C Links In vCU
    run keyword and ignore error  Detach UE    ue_index=0
    run keyword and ignore error  Detach UE    ue_index=1

5GC002300 Postcondition
    log to console    Case Postcondition
#    run keyword and ignore error  Modify Parameters By Delta Plan    ne=vDU    parameter=actEirpControl    value=false
    Common Test Teardown For AIC
    run keyword and ignore error  Detach UE    ue_index=0

CB008021 Postcondition
    log to console    Case Postcondition
#    run keyword and ignore error  Modify Parameters By Delta Plan    ne=all    parameter=actNrUlRipMeasurement
#    ...                                            value=disabled    mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    run keyword and ignore error  Unlock One NG-C Links In vCU
    Close LTE Cell PA Signal
    Common Test Teardown For AIC
    run keyword and ignore error  Detach UE    ue_index=1

US5GC000731 Case Postcondition
    log to console    Case Postcondition
    Modify PA Signal For CB011178
    Common Test Teardown For AIC
    run keyword and ignore error  Stop Wireshark Log    container_name=nwmgmt    pod_name=cpif    NE=vCU
    ...                                                 vcu_log_name=vcu_wireshark

Start Collect Wireshark Log
    [Arguments]    ${container_name}=cpif    ${pod_name}=cpif    ${NE}=vDU    ${gnb_index}=${0}    ${index}=${0}
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
    ...       ELSE IF    '${NE}'=='Multi_vDU'    Start Collect Wireshark Log Inter vDU
    ...                                                           container_name=${container_name}
    ...                                                           pod_name=${pod_name}
    ...                                                           gnb_index=${gnb_index}
    ...                                                           gnb2_index=${gnb_index}
    ...                                                           index=${index}

Start Collect Wireshark Log In vCU
    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cpif    ${index}=${0}
    Log to Console    \n***Start Wireshark Log In vCU***
    Start Wireshark Log In vCU   container_name=${container_name}
    ...                          pod_name=${pod_name}
    ...                          timeout=${10}
    ...                          protocol=sctp
    ...                          interface=any
    ...                          hostname=${vcu_hostname_list[${index}]}
    ...                          username=${vcu_username_list[${index}]}
    ...                          password=${vcu_password_list[${index}]}
    ...                          namespace=${vcu_ns_list[${index}]}

Start Collect Wireshark Log In vDU
    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cprt    ${gnb_index}=${0}    ${index}=${0}
    Log to Console    \n***Start Wireshark Log In vCU***
    Start Wireshark Log In vDU   container_name=${container_name}
    ...                          pod_name=${pod_name}
    ...                          timeout=${10}
    ...                          protocol=sctp
    ...                          interface=any
    ...                          hostname=${vdu_hostname_dict['vcu_${gnb_index}_vdu_hostname'][${index}]}
    ...                          username=${vdu_username_dict['vcu_${gnb_index}_vdu_username'][${index}]}
    ...                          password=${vdu_password_dict['vcu_${gnb_index}_vdu_password'][${index}]}
    ...                          namespace=${vdu_ns_dict['vcu_${gnb_index}_vdu_ns'][${index}]}

Start Collect Wireshark Log Both vCU And vDU
    [Arguments]    ${container_name}=cprt    ${vdu_pod_name}=cprt    ${vcu_pod_name}=cpif
    ...            ${index}=${0}    ${gnb_index}=${0}    ${gnb2_index}=${0}
    Log to Console    \n***Start Wireshark Log In vCU with ${gnb_index}***
    Start Wireshark Log In vCU   container_name=${container_name}
    ...                          pod_name=${vcu_pod_name}
    ...                          timeout=${10}
    ...                          protocol=sctp
    ...                          interface=any
    ...                          hostname=${vcu_hostname_list[${index}]}
    ...                          username=${vcu_username_list[${index}]}
    ...                          password=${vcu_password_list[${index}]}
    ...                          namespace=${vcu_ns_list[${index}]}
    Start Wireshark Log In vDU   container_name=${container_name}
    ...                          pod_name=${vdu_pod_name}
    ...                          timeout=${10}
    ...                          protocol=sctp
    ...                          interface=any
    ...                          hostname=${vdu_hostname_dict[vcu_${gnb2_index}_vdu_hostname][${index}]}
    ...                          username=${vdu_hostname_dict[vcu_${gnb2_index}_vdu_hostname][${index}]}
    ...                          password=${vdu_hostname_dict[vcu_${gnb2_index}_vdu_hostname][${index}]}
    ...                          namespace=${vdu_hostname_dict[vcu_${gnb2_index}_vdu_hostname][${index}]}

Start Collect Wireshark Log Inter vDU
    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cprt    ${gnb_index}=${0}
    ...            ${gnb2_index}=${0}    ${index}=${0}
    Log to Console    \n***Start Wireshark Log In vCU***
    Start Wireshark Log In vDU   container_name=${container_name}
    ...                          pod_name=${pod_name}
    ...                          timeout=${10}
    ...                          protocol=sctp
    ...                          interface=any
    ...                          hostname=${vdu_hostname_dict['vcu_${gnb_index}_vdu_hostname'][${index}]}
    ...                          username=${vdu_username_dict['vcu_${gnb_index}_vdu_username'][${index}]}
    ...                          password=${vdu_password_dict['vcu_${gnb_index}_vdu_password'][${index}]}
    ...                          namespace=${vdu_ns_dict['vcu_${gnb_index}_vdu_ns'][${index}]}
    Start Wireshark Log In vDU   container_name=${container_name}
    ...                          pod_name=${pod_name}
    ...                          timeout=${10}
    ...                          protocol=sctp
    ...                          interface=any
    ...                          hostname=${vdu_hostname_dict['vcu_${gnb2_index}_vdu_hostname'][${index}]}
    ...                          username=${vdu_username_dict['vcu_${gnb2_index}_vdu_username'][${index}]}
    ...                          password=${vdu_password_dict['vcu_${gnb2_index}_vdu_password'][${index}]}
    ...                          namespace=${vdu_ns_dict['vcu_${gnb2_index}_vdu_ns'][${index}]}

Prepare And Attach UE
    [Arguments]    ${ue_index}=${0}    ${ui_version}=default
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
    Log to Console    \n***Prepare UE***
    Prepare UE    ${ue_${ue_index}_type}    ue_index=${ue_index}    ui_version=${ui_version}
    UE Attach    ${ue_${ue_index}_type}    ue_index=${ue_index}    verify_attach=True
    [Return]     ${ue_${ue_index}_type}

Prepare And Attach Commercial UE
    [Arguments]    ${ue_index}=${0}    ${ui_version}=MATE40PROUI1.0
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
    Log to Console    \n***Prepare UE***
    Prepare UE    ${ue_${ue_index}_type}    ue_index=${ue_index}    ui_version=${ui_version}
    UE Attach    ${ue_${ue_index}_type}    ue_index=${ue_index}    verify_attach=True
    [Return]     ${ue_${ue_index}_type}

Attach UE
    [Arguments]    ${ue_index}=${0}
    Log to Console    \n***UE Attach***
    UE Attach    ${ue_${ue_index}_type}    ue_index=${ue_index}    verify_attach=True
    sleep    60s    reason=wait attach UE Successfully

Stop Wireshark Log
    [Arguments]    ${container_name}=cpif    ${pod_name}=cpif    ${NE}=vDU
    ...            ${vcu_log_name}=vcu_wireshark    ${vdu_log_name}=vdu_wireshark
    Run Keyword If    '${NE}'=='vDU'    Stop Wireshark Log In vDU
    ...                                                           container_name=${container_name}
    ...                                                           pod_name=${pod_name}
    ...                                                           vdu_log_name=${vdu_log_name}
    ...    ELSE IF    '${NE}'=='vCU'    Stop Wireshark Log In vCU
    ...                                                           container_name=${container_name}
    ...                                                           pod_name=${pod_name}
    ...                                                           vcu_log_name=${vcu_log_name}
    ...    ELSE IF    '${NE}'=='all'    Stop Wireshark Log Both vCU And vDU
    ...                                                           container_name=${container_name}
    ...                                                           pod_name=${pod_name}
    ...                                                           vcu_log_name=${vcu_log_name}
    ...                                                           vdu_log_name=${vdu_log_name}

Stop Wireshark Log In vDU
    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cpif    ${vdu_log_name}=vdu_wireshark
    ${wireshark_local_file_path_vDU}    Stop Wireshark Log And Download To K8s Master In vDU   gnb_index=${0}
    ...                                                                    container_name=${container_name}
    ...                                                                    pod_name=${pod_name}
    ...                                                                    timeout=${10}
    ...                                                                    log_name=${vdu_log_name}
    Set Test Variable    ${wireshark_local_file_path_vDU}

Stop Wireshark Log In vCU
    [Arguments]    ${container_name}=nwmgmt    ${pod_name}=cpif    ${vcu_log_name}=vcu_wireshark
    ${wireshark_local_file_path_vCU}    Stop Wireshark Log And Download To K8s Master In vCU   gnb_index=${0}
    ...                                                                    container_name=${container_name}
    ...                                                                    pod_name=${pod_name}
    ...                                                                    timeout=${10}
    ...                                                                    log_name=${vcu_log_name}
    Set Test Variable    ${wireshark_local_file_path_vCU}

Stop Wireshark Log Both vCU And vDU
    [Arguments]    ${container_name}=cpif    ${pod_name}=cpif
    ...            ${vcu_log_name}=vcu_wireshark    ${vdu_log_name}=vdu_wireshark
    ${wireshark_local_file_path_vCU}    Stop Wireshark Log And Download To K8s Master In vCU   gnb_index=${0}
    ...                                                                    container_name=${container_name}
    ...                                                                    pod_name=${pod_name}
    ...                                                                    timeout=${10}
    ...                                                                    log_name=${vcu_log_name}
    Set Test Variable    ${wireshark_local_file_path_vCU}
    ${wireshark_local_file_path_vDU}    Stop Wireshark Log And Download To K8s Master In vDU   gnb_index=${0}
    ...                                                                    container_name=${container_name}
    ...                                                                    pod_name=${pod_name}
    ...                                                                    timeout=${10}
    ...                                                                    log_name=${vdu_log_name}
    Set Test Variable    ${wireshark_local_file_path_vDU}

Check Wireshark Log For CNI_75911
    [Arguments]    ${input_file}=${wireshark_local_file_path_vCU}
    Log To Console    Check WPS VONR call priorityLevelARP
    ${VONR_filter} =    catenate    ngap.priorityLevelARP == 2
    ${result} =    Analysis Wireshark Log    input_file=${input_file}
    ...                                      filter_expression=${VONR_filter}
    should contain      ${result}      PDUSessionResourceModifyRequest
    Log To Console    Check Emergency VONR call priorityLevelARP
    ${Emergency_filter} =    catenate    ngap.priorityLevelARP == 1
    ${result} =    Analysis Wireshark Log    input_file=${input_file}
    ...                                      filter_expression=${Emergency_filter}
    should contain      ${result}      PDUSessionResourceSetupRequest

Start Call For UE
    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_${ue_index}_type}    ${direction}=dl    ${throughput}=110M
    Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=${direction}    dt_index=${ue_index}
    ...              throughput=${throughput}    duration=${600}
    sleep    5s    reason=wait call sucessfully

Start Call For 5GC002300
    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_${ue_index}_type}    ${direction}=dl    ${throughput}=110M
    Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=${direction}    dt_index=${ue_index}
    ...              throughput=${throughput}    duration=${720}
    sleep    5s    reason=wait call sucessfully

Detach UE
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_${ue_index}_type}
    UE Detach    ${ue_type}    ue_index=${ue_index}
    sleep    60s    reason=wait detach UE Successfully

Check Counter For 5GC000784
    Sleep    600s    reason=wait generate counter
    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    &{type1_counter_dict}    create dictionary    counterId=M55125C05505,M55125C05506
    ...                                           dimDN=${dim_dn}/NRCELL-1
    ...                                           ne=vCU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    ${type1_counter_list}    Create List    ${type1_counter_dict}
    FOR    ${counter}    IN    @{type1_counter_list}
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

Check Counter For 5GC002300
    Sleep    600s    reason=wait generate counter
    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    &{type1_counter_dict}    create dictionary    counterId=M55324C00101,M55324C00201,M55324C00301,M55324C00401,M55324C00501
    ...                                           dimDN=${dim_dn}/NRCELL-1
    ...                                           ne=vDU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    &{type2_counter_dict}    create dictionary    counterId=M55324C00601,M55324C00701,M55324C00800,M55324C00801,M55324C00802
    ...                                           dimDN=${dim_dn}/NRCELL-1
    ...                                           ne=vDU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    ${type1_counter_list}    Create List    ${type1_counter_dict}
    ${type2_counter_list}    Create List    ${type2_counter_dict}
    FOR    ${counter}    IN    @{type1_counter_list}
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
    FOR    ${counter}    IN    @{type2_counter_list}
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

Start Counter For CB011178_5GC002300
    ${rule}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2;
    ...         Counter: M55324C00101;
    ...         Counter rule: max(M55324C00101)>0;
    ${rule_list}    Create List    ${rule}
    Start Counter    rule_list=${rule_list}    product_type=vdu    bts_index=0

Check SA Counter For 46002
    Sleep    300s    reason=wait generate counter
    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    &{type1_counter_dict}    create dictionary    counterId=M55338C00001,M55338C00002
    ...                                           dimDN=${dim_dn}/NRCELL-1/MCC-460/MNC-02
    ...                                           ne=vDU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    &{type2_counter_dict}    create dictionary    counterId=M55326C01001,M55326C02007,M55326C01002,M55326C03007
    ...                                           dimDN=${dim_dn}/MCC-460/MNC-02
    ...                                           ne=vCU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    &{type3_counter_dict}    create dictionary    counterId=M55145C00220,M55145C00223
    ...                                           dimDN=${dim_dn}/NRCELL-1/MCC-460/MNC-02
    ...                                           ne=vCU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    &{type4_counter_dict}    create dictionary    counterId=M55149C01003
    ...                                           dimDN=${dim_dn}/MCC-460/MNC-02/SST-1/SD-13714341
    ...                                           ne=vCU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    ${type1_counter_list}    Create List    ${type1_counter_dict}
    ${type2_counter_list}    Create List    ${type2_counter_dict}
    ${type3_counter_list}    Create List    ${type3_counter_dict}
    ${type4_counter_list}    Create List    ${type4_counter_dict}
    FOR    ${counter}    IN    @{type1_counter_list}
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
    FOR    ${counter}    IN    @{type2_counter_list}
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
    FOR    ${counter}    IN    @{type3_counter_list}
        ${counter_id_list}=    split_string    ${counter['counterId']}    ,
        ${ne}    Set Variable    ${counter['ne']}
        Run Keyword If    '${ne}'=='vDU'    Check Counter In vDU    counter_id_list=${counter_id_list}
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
    FOR    ${counter}    IN    @{type4_counter_list}
        ${counter_id_list}=    split_string    ${counter['counterId']}    ,
        ${ne}    Set Variable    ${counter['ne']}
        Run Keyword If    '${ne}'=='vDU'    Check Counter In vDU    counter_id_list=${counter_id_list}
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

Check SA Counter For 26203
    Sleep    600s    reason=wait generate counter
    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    &{type1_counter_dict}    create dictionary    counterId=M55338C00001,M55338C00002
    ...                                           dimDN=${dim_dn}/NRCELL-1/MCC-262/MNC-03
    ...                                           ne=vDU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    ${type1_counter_list}    Create List    ${type1_counter_dict}
    FOR    ${counter}    IN    @{type1_counter_list}
        ${counter_id_list}=    split_string    ${counter['counterId']}    ,
        ${ne}    Set Variable   ${counter['ne']}
        Run Keyword If    '${ne}'=='vDU'     Check Counter In vDU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=5
        ...    ELSE IF    '${ne}'=='vCU'    Check Counter In vCU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=5
    END


Check NSA Counter For 26203
    Sleep    600s    reason=wait generate counter
    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    &{type1_counter_dict}    create dictionary    counterId=M55338C00001,M55338C00002
    ...                                           dimDN=${dim_dn}/NRCELL-1/MCC-262/MNC-03
    ...                                           ne=vDU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    &{type2_counter_dict}    create dictionary    counterId=M55326C01001
    ...                                           dimDN=${dim_dn}/MCC-262/MNC-03
    ...                                           ne=vCU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    ${type1_counter_list}    Create List    ${type1_counter_dict}
    ${type2_counter_list}    Create List    ${type2_counter_dict}
    FOR    ${counter}    IN    @{type1_counter_list}
        ${counter_id_list}=    split_string    ${counter['counterId']}    ,
        ${ne}    Set Variable   ${counter['ne']}
        Run Keyword If    '${ne}'=='vDU'     Check Counter In vDU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=5
        ...    ELSE IF    '${ne}'=='vCU'    Check Counter In vCU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=5
    END
    FOR    ${counter}    IN    @{type2_counter_list}
        ${counter_id_list}=    split_string    ${counter['counterId']}    ,
        ${ne}    Set Variable   ${counter['ne']}

        Run Keyword If    '${ne}'=='vDU'     Check Counter In vDU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=5
        ...    ELSE IF    '${ne}'=='vCU'    Check Counter In vCU    counter_id_list=${counter_id_list}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=5
    END
    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    &{counter_dict}    create dictionary    counterId=M55326C02005,M55326C02007
    ...                                           dimDN=${dim_dn}/MCC-262/MNC-03
    ...                                           ne=vCU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    ${counter_list}    Create List    ${counter_dict}
    FOR    ${counter}    IN    @{counter_list}
        ${ne}    Set Variable   ${counter['ne']}
        ...    ELSE IF    '${ne}'=='vCU'    Check Any One Value In Multiple Counters In vCU
        ...                                                         counter_id_list=${counter['counterId']}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
    END

Start Counter For 5GC000749
    ${rule}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1;
    ...         Counter: M55124C02501;
    ...         Counter rule: max(M55124C02501)==0;
    ${rule_list}    Create List    ${rule}
    Start Counter    rule_list=${rule_list}    product_type=vcu    bts_index=${0}
Check Counter For 5GC000749
    Sleep    700s    reason=wait generate counter

    Collect And Check Counter    product_type=vcu    bts_index=${0}    cudu_index=${0}

Check Counter For 5GC009794
    Sleep    360s    reason=wait generate counter
    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    &{type1_counter_dict}    create dictionary    counterId=M55369C00000,M55369C00001,M55369C00002,M55369C00003
    ...                                           dimDN=${dim_dn}/NRCELL-2
    ...                                           ne=vDU
    ...                                           gnbIndex=0
    ...                                           comparison=less
    ...                                           value=0
    &{type2_counter_dict}    create dictionary    counterId=M55369C00100,M55369C00101,M55369C00102,M55369C00103
    ...                                           dimDN=${dim_dn}/NRCELL-2
    ...                                           ne=vDU
    ...                                           gnbIndex=0
    ...                                           comparison=less
    ...                                           value=0
    &{type3_counter_dict}    create dictionary    counterId=M55369C00200,M55369C00201,M55369C00202,M55369C00203
    ...                                           dimDN=${dim_dn}/NRCELL-2
    ...                                           ne=vDU
    ...                                           gnbIndex=0
    ...                                           comparison=less
    ...                                           value=0
    ${type1_counter_list}    Create List    ${type1_counter_dict}
    ${type2_counter_list}    Create List    ${type2_counter_dict}
    ${type3_counter_list}    Create List    ${type3_counter_dict}
    FOR    ${counter}    IN    @{type1_counter_list}
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
    FOR    ${counter}    IN    @{type2_counter_list}
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
    FOR    ${counter}    IN    @{type3_counter_list}
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

Check Any One Value In Multiple Counters
    Sleep    360s    reason=wait generate counter
    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}

    ${avg_ul_rip_counter}    Generate Counter PIId    start_id=M55360C00000    stop_id=M55360C00272
    ${max_ul_rip_counter}    Generate Counter PIId    start_id=M55360C01000    stop_id=M55360C01272

    &{type1_counter_dict}    create dictionary    counterId=${avg_ul_rip_counter}
    ...                                           dimDN=${dim_dn}/NRCELL-1
    ...                                           ne=vDU
    ...                                           gnbIndex=0
    ...                                           comparison=less
    ...                                           value=0
    &{type2_counter_dict}    create dictionary    counterId=${max_ul_rip_counter}
    ...                                           dimDN=${dim_dn}/NRCELL-1
    ...                                           ne=vDU
    ...                                           gnbIndex=0
    ...                                           comparison=less
    ...                                           value=0
    ${counter_list}    Create List    ${type1_counter_dict}    ${type2_counter_dict}
    FOR    ${counter}    IN    @{counter_list}
        ${ne}    Set Variable   ${counter['ne']}
        Run Keyword If    '${ne}'=='vDU'     Check Any One Value In Multiple Counters In vDU
        ...                                                         counter_id_list=${counter['counterId']}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
        ...    ELSE IF    '${ne}'=='vCU'    Check Any One Value In Multiple Counters In vCU
        ...                                                         counter_id_list=${counter['counterId']}
        ...                                                         dim_dn=${counter['dimDN']}
        ...                                                         gnb_index=${counter['gnbIndex']}
        ...                                                         comparison=${counter['comparison']}
        ...                                                         expected_value=${counter['value']}
        ...                                                         get_number=3
    END

Check Any One Value In Multiple Counters In vDU
    [Arguments]    ${counter_id_list}    ${dim_dn}    ${gnb_index}=0
    ...            ${comparison}=greater    ${expected_value}=0    ${get_number}=3
    Log to Console    \n***check any one value in multiple counters in vDU***
    ${status}=   set variable   False
    ${counter_values_final_list}    Create List
    FOR    ${counter_id}    IN    @{counter_id_list}
        ${counter_values_final_list}    Run Keyword And Ignore Error    Check Counter For vDU
        ...                                            counter_id=${counter_id}
        ...                                            dimension_dn=${dim_dn}
        ...                                            comparison=${comparison}
        ...                                            expected_value=${expected_value}
        ...                                            get_number=${get_number}
        ...                                            gnb_index=${gnb_index}
        ${status}=    set variable if    '${counter_values_final_list[0]}'=='PASS'    True
        exit for loop if    '${status}'=='True'
    END

Check Any One Value In Multiple Counters In vCU
    [Arguments]    ${counter_id_list}    ${dim_dn}    ${gnb_index}=0
    ...            ${comparison}=greater    ${expected_value}=0    ${get_number}=3
    Log to Console    \n***check any one value in multiple counters in vCU***
    ${status}=   set variable   False
    ${counter_values_final_list}    Create List
    FOR    ${counter_id}    IN    @{counter_id_list}
        @{words}=    split string    ${counter_id}   C
        ${mea_id}=   Fetch From Right    ${words[0]}  M
        ${counter_values_final_list}    Run Keyword And Ignore Error    Check Counter For vCU
        ...                                            counter_id=${counter_id}
        ...                                            measurement_id=${mea_id}
        ...                                            dimension_dist_name=${dim_dn}
        ...                                            comparison=${comparison}
        ...                                            expected_value=${expected_value}
        ...                                            get_number=${get_number}
        ...                                            gnb_index=${gnb_index}
        ${status}=    set variable if    '${counter_values_final_list[0]}'=='PASS'    True
        exit for loop if    '${status}'=='True'
    END


Start VONR Call For UE
    [Arguments]    ${ue_index}=${0}     ${capabilities}=OPPO
    Start VONR Call    ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    vc_alias=VC_1    call_number=004488
    ...            duration=600s    capabilities=${capabilities}

Start VONR Call Without Require UE
    [Arguments]    ${ue_index}=${0}
#    ute_ue.detach_ue    UE_${ue_index}
#    ute_ue.attach_ue    UE_${ue_index}
#    Sleep    5
#    Detach UE0
#    Attach UE0
    Start Voice Call    vc_alias=VC_1   ue_alias=UE_${ue_index}    to=004488    duration=600s

Start Emergency Call Without Require UE
    [Arguments]    ${ue_index}=${0}    ${vc_alias}=VC_1
    Start Voice Call    vc_alias=${vc_alias}   ue_alias=UE_${ue_index}    to=911    duration=600s

Start Emergency Call For UE
    [Arguments]    ${ue_index}=${0}     ${capabilities}=REAL_ANDROID_UE
    Log To Console    \n***Start Emergency call***
    Start VONR Call    ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    vc_alias=VC_1    call_number=911
    ...            duration=600s    capabilities=${capabilities}

Stop VONR Call For UE
    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_${ue_index}_type}    ${vc_alias}=VC_1
    Log To Console    \n*** Stop VONR Call***
    Stop VONR Call    ue_type=${ue_type}      vc_alias=${vc_alias}

Check VONR Call
    [Arguments]      ${expected_status}=hold
    Log to Console    \n***Check VONR Call Status***
    ${vc_status} =    Check VONR Call Status    vc_alias=VC_1
    should be equal    "${vc_status}"  "${expected_status}"   The status of Voice Call is not expected!

Check Emergency Call Status
    [Arguments]      ${expected_status}=hold
    Log to Console    \n***Check Emergency Call Status***
    ${vc_status} =    Check VONR Call Status    vc_alias=VC_1
    should be equal    "${vc_status}"  "${expected_status}"   The status of Emergency Call is not expected!

Lock All NG-C Links
    BTS Operation    operation=nglink_lock      product_type=vcu    bts_index=0
    ...              distname_id=nglink-ALL    need_verify=yes

Unlock One NG-C Links In vCU
    BTS Operation    operation=nglink_unlock    product_type=vcu    bts_index=0
    ...              distname_id=nglink-1      need_verify=yes
    wait until keyword succeeds    10min    20s    Check All Cells On Air In vCU

##########    5GC000746    ##########
Trigger CMAS Notification
    Log to console    start to trigger cmas
    CMAS Notification    amf=&{amf1-amf1-zheng}
    ...                          message_identifier=4372    serial_number=51
    ...                          repetition_period=5
    ...                          number_of_broadcasts_requested=${10}
    ...                          connection=${cbctest_alias}
    ...                          nr_of_bits_g_node_b_id=22
    ...                          cell_id=178176002
    ...                          test_amf_name=test_amf_RRM3.py
    Log to console    stop to trigger cmas

Check Write Replace Warning In Log
    [Arguments]    ${input_file}=${wireshark_local_file_path_vCU}    ${sib_type}=SIB8
    Log to Console    \n***Check if AMF sends WriteReplaceWarningRequest to gNB-CU-CP
    ${request_filter} =    catenate      ngap.WriteReplaceWarningRequest_element
    ${result} =    Analysis Wireshark Log    input_file=${input_file}
    ...                                      filter_expression=${request_filter}
    should contain    ${result}    WriteReplaceWarningRequest
    Log to Console    \n***Check if Write Replace Warning is broadcast
    ${sib_filter} =    catenate      f1ap.sIBtype
    ${result} =    Analysis Wireshark Log    input_file=${input_file}
    ...                                      filter_expression=${sib_filter}
    should contain    ${result}    ${sib_type}
    Log to Console    \n***Check if gNB-DU sends WriteReplaceWarningResponse to gNB-CU-CP
    ${response_filter} =    catenate      f1ap.WriteReplaceWarningResponse_element
    ${result} =    Analysis Wireshark Log    input_file=${input_file}
    ...                                      filter_expression=${response_filter}
    should contain    ${result}    WriteReplaceWarningResponse
    Log to Console    \n***Check if gNB-CU-CP sends WriteReplaceWarningResponse to AMF with BroadcastCompletedAreaList
    ${response_filter} =    catenate      ngap.BroadcastCompletedAreaList
    ${result} =    Analysis Wireshark Log    input_file=${input_file}
    ...                                      filter_expression=${response_filter}
    should contain    ${result}    WriteReplaceWarningResponse

Check Counter For Successful_CMAS
    Sleep    360s    reason=wait generate counter
    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
    ${dim_dn}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    Log to Console    \n***Check M55119C02001(NNGCB_WRWR_REQ_RECD), M55119C02002(NNGCB_WRWR_RESP_SENT) counters
    &{type1_counter_dict}    create dictionary    counterId=M55119C02001,M55119C02002
    ...                                           dimDN=${dim_dn}
    ...                                           ne=vCU
    ...                                           gnbIndex=0
    ...                                           comparison=greater
    ...                                           value=0
    &{type2_counter_dict}    create dictionary    counterId=M55119C02006
    ...                                           dimDN=${dim_dn}
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
############################## PA ##############################
Open LTE Cell PA Signal
    ${source_pa_port_list}     Create List     9
    ${source_pa_value_list}    Create List     127    0
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}
    ...                               pa_value=${source_pa_value_list}    step=${10}
    PA Operation    source=&{source}    target=none

Close LTE Cell PA Signal
    ${source_pa_port_list}     Create List     9
    ${source_pa_value_list}    Create List     0    127
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}
    ...                               pa_value=${source_pa_value_list}    step=${10}
    PA Operation    source=&{source}    target=none

Initialize PA Signal
    Set Initialize PA Value    pa_port=5-6;1,2;9;    pa_value=0;127;127;

Modify PA Signal For CB011178
    ${source_pa_port_list}     Create List     1    2
    ${source_pa_value_list}    Create List     40    20
    ${target_pa_port_list}     Create List    5    6    7    8    9
    ${target_pa_value_list}    Create List    0    127
    Modify PA    source_pa_port_list=${source_pa_port_list}
    ...          source_pa_value_list=${source_pa_value_list}
    ...          target_pa_port_list=${target_pa_port_list}
    ...          target_pa_value_list=${target_pa_value_list}
    ...          step=${10}

Prepare PA Signal For 731
    ${source_pa_port_list}     Create List    1    2
    ${source_pa_value_list}    Create List    20    30
    Modify PA Only In Source    source_pa_port_list=${source_pa_port_list}
    ...                         source_pa_value_list=${source_pa_value_list}
    ...                         step=${10}

Modify PA Signal For 731
    ${source_pa_port_list}     Create List    1    2
    ${source_pa_value_list}    Create List    30    127
    Modify PA Only In Source    source_pa_port_list=${source_pa_port_list}
    ...                         source_pa_value_list=${source_pa_value_list}
    ...                         step=${10}

############################## parameter ##############################
Online Change miNrRlfPerCell to 5min
    @{para_list}          Create List    miNrRlfPerCell
    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPMRNL-1
    @{value_list_true}    Create List    5min
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vcu

Parameter Updated Both VDU And VCU
    @{para_list}          Create List    actCDrx
    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    @{value_list_true}    Create List    true
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vdu
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vcu
############################## log ##############################
Check RLF F1AP message matching counter M55129CXXXXX
    [Arguments]    ${local_file_path}=/home/ute/test_results/
    ...            ${filter}=f1ap.procedureCode == 8
    ...            ${camped_cell_dist}=NRCELL-2
    ${second_time}=    Run
    ...    tshark -Y "${filter}" -T fields -e f1ap.radioNetwork -r ${local_file_path}
    Log To Console    ${second_time}
    ${second_time}=   Get Regexp Matches    ${second_time}   \\d+
    ${RLF_count}=       Get Match Count     ${second_time}      12
    Run Keyword If    ${RLF_count}>0    Check Counter value Be Equal To Expected Value For vCU    counter_id=M55129C00003
    ...                      measurement_id=55129
    ...                      dimension_dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${camped_cell_dist}
    ...                      expected_value=${RLF_count}
    ...                      get_number=5
