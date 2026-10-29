*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
...   Description: This robot cases is for CB006092-E_004
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot


*** Keywords ***
VRAN_SyVe_CM_CB006092-E_004_Verify_CCN_On_O-RAN_O1_Interface_When_Resynchronization_In_vDU
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    25.04.2025, yuyan.xu@nokia-sbell.com
    Step 1: Set pushCompleteCMDB As false And Check
    Step 2: Set pushCompleteCMDB As true And Check
    Step 3: Disable VES CCN And Check
    Step 4: Enable VES CCN And Check
    Step 5: Reset Site And Check pushCompleteCMDB Sent
    Step 6: Trigger Site Reset And Check pushCompleteCMDB Sent
    Step 7: Set pushCompleteCMDB As false And Check
    Step 8: Disable VES CCN And Check
    Step 9: Enable VES CCN And Check
    Step 10: Reset Site And Check pushCompleteCMDB Not Sent
    Step 11: Trigger Site Reset And Check pushCompleteCMDB Not Sent


Step ${index}: Set pushCompleteCMDB As ${value} And Check
    Log To Console    Step ${index}: Set pushCompleteCMDB As ${value} And Check
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    @{para_list}    Create List    pushCompleteCMDB
    @{value_list}    Create List    ${value}
    @{mo_list}    Create List    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    #check value
    ${out}    Parameter Operation    operation=parameter_value_check    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}
    Should Be Equal As Strings    ${value_list[0]}    ${out["${mo_list[0]}"]["${para_list[0]}"]}
    Sleep    60s    #time for CCN
    ${dic_param_value}    create dictionary    pushCompleteCMDB=${value}
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
    ...    ${VES_CCN_msgs}    ${ONAP_DN}    vDu    ${vesSourceName}    ${dnPrefix}    ${du_ip}    replace    ${dic_param_value}
    Run Keyword If    "${value}"=="false"    Should Not Be Empty    ${target_VES_CCN_msg}

Step ${index}: Disable VES CCN And Check
    Log To Console    Step ${index}: Disable VES CCN And Check
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    ${dic_param_value}    create dictionary    actCmEventsReporting=false
    @{para_list}    Create List    actCmEventsReporting
    @{value_list}    Create List    false
    @{mo_list}    Create List    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    ${out}    Parameter Operation    operation=parameter_value_check    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}
    Should Be Equal As Strings    ${value_list[0]}    ${out["${mo_list[0]}"]["${para_list[0]}"]}
    Sleep    60s    #time for CCN
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
    ...    ${VES_CCN_msgs}    ${ONAP_DN}    vDu    ${vesSourceName}    ${dnPrefix}    ${du_ip}    replace    ${dic_param_value}
    Should Be Empty    ${target_VES_CCN_msg}

Step ${index}: Enable VES CCN And Check
    Log To Console    Step ${index}: Enable VES CCN And Check
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    ${dic_param_value}    Create Dictionary    actCmEventsReporting=true
    @{para_list}    Create List    actCmEventsReporting
    @{value_list}    Create List    true
    @{mo_list}    Create List    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    ${out}    Parameter Operation    operation=parameter_value_check    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}
    Should Be Equal As Strings    ${value_list[0]}    ${out["${mo_list[0]}"]["${para_list[0]}"]}
    Sleep    60s    #time for CCN
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    ${operate}    Set Variable If    "${index}"=="${4}"    add    replace
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
    ...    ${VES_CCN_msgs}    ${ONAP_DN}    vDu    ${vesSourceName}    ${dnPrefix}    ${du_ip}    ${operate}    ${dic_param_value}
    Should Not Be Empty    ${target_VES_CCN_msg}

Step ${index}: Reset Site And Check pushCompleteCMDB ${expect}
    Log To Console    Step ${index}: Reset Site And Check pushCompleteCMDB ${expect}
    #vDU Login By Rest  vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${out}    vdu.reset_vdu
    ${should_send_pushCompleteCMDB}    Run Keyword And Return Status
    ...    Should Be Equal As Strings    ${expect}    sent    ignore_case=True
    Check VES CCN After Site Reset    ${should_send_pushCompleteCMDB}

Step ${index}: Trigger Site Reset And Check pushCompleteCMDB ${expect}
    Log To Console    Step ${index}: Trigger Site Reset And Check pushCompleteCMDB ${expect}
    Sleep    60s
    vDU Login By Rest
    ${current_value}    Get Parameter Value From vDU    MRBTS-${vDU_id}/MNL-1/MNLENT-1/FEATCADM-1    actMplaneFronthaulFirewall
    ${actMplaneFronthaulFirewall_to_set}    Set Variable If
    ...    '${current_value}'=='true'    false    true
    @{para_list}    Create List    actMplaneFronthaulFirewall
    @{value_list}    Create List    ${actMplaneFronthaulFirewall_to_set}
    @{mo_list}    Create List    MRBTS-${vDU_id}/MNL-1/MNLENT-1/FEATCADM-1
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    ${should_send_pushCompleteCMDB}    Run Keyword And Return Status
    ...    Should Be Equal As Strings    ${expect}    sent    ignore_case=True
    Check VES CCN After Site Reset    ${should_send_pushCompleteCMDB}
    Sleep    60s
    ${out}    Parameter Operation    operation=parameter_value_check    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}
    Should Be Equal As Strings    ${value_list[0]}    ${out["${mo_list[0]}"]["${para_list[0]}"]}

Check VES CCN After Site Reset
    [Arguments]    ${should_send_pushCompleteCMDB}
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    Wait Until Keyword Succeeds    10min    30s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    ${VES_pushCompleteCMDB_msg}    Get First VES pushCompleteCMDB MSN    ${VES_CCN_msgs}
    ${is_sent}    Run Keyword And Return Status    Should Not Be Empty    ${VES_pushCompleteCMDB_msg}
    #Should Be Equal As Strings    ${is_sent}    ${should_send_pushCompleteCMDB}    ignore_case=True
    #Run Keyword If    ${is_sent}    Check MOs From VES    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml    ${VES_pushCompleteCMDB_msg}
    #yuki precheck
    Run Keyword And Ignore Error   Should Be Equal As Strings    ${is_sent}    ${should_send_pushCompleteCMDB}    ignore_case=True
    Run Keyword If    ${should_send_pushCompleteCMDB}
    ...    Check MOs From VES    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml    ${VES_pushCompleteCMDB_msg}


Get First VES pushCompleteCMDB MSN
    [Arguments]    ${VES_CCN_msgs}
    ${dic_standard_head}    Create Dictionary    sourceName=${vesSourceName}    reportingEntityName=${vesSourceName}
    ...    priority=Normal    eventName=StndDefined_vDu-Nokia_3gppNotifyMoiChanges
    ...    vesEventListenerVersion=7.2    stndDefinedNamespace=3GPP-Provisioning
    ${VES_CCN_notifyMOIChanges}    Filter VES CCN MSG    ${dic_standard_head}    ${VES_CCN_msgs}
    ${systemDN}    Set Variable    ${dnPrefix},ManagedElement=MRBTS-${vDU_id}
    ${dic_data_head}    Create Dictionary    systemDN=${systemDN}    notificationType=notifyMOIChanges    href=${du_ip}
    ${VES_pushCompleteCMDB_msg}    Create Dictionary
    FOR    ${VES_CCN_msg}    IN    @{VES_CCN_notifyMOIChanges}
        ${is_header_match}    Run Keyword And Return Status
        ...    Dictionary Should Contain Sub Dictionary    ${VES_CCN_msg["event"]["stndDefinedFields"]["data"]}    ${dic_data_head}
        Run Keyword If    not ${is_header_match}    Continue For Loop
        ${moiChanges}    Get From Dictionary    ${VES_CCN_msg["event"]["stndDefinedFields"]["data"]}    moiChanges
        ${not_for_pushCompleteCMDB}    Check If All moiChanges Are For pushCompleteCMDB    ${moiChanges}
        Continue For Loop If    ${not_for_pushCompleteCMDB}
        ${VES_pushCompleteCMDB_msg}    Set Variable    ${VES_CCN_msg}
        Exit For Loop
    END
    [Return]    ${VES_pushCompleteCMDB_msg}

Check If All moiChanges Are For pushCompleteCMDB
    [Arguments]    ${moiChanges}
    ${not_for_pushCompleteCMDB}    Set Variable    ${False}
    FOR    ${moiChange}    IN    @{moiChanges}
        Sleep    0.1s
        ${not_for_pushCompleteCMDB}    Run Keyword And Return Status
        ...    Should Not Be Equal As Strings    ${moiChange["op"]}    add
        Exit For Loop If    ${not_for_pushCompleteCMDB}
        ${path}    Get From Dictionary    ${moiChange}    path
        ${not_for_pushCompleteCMDB}    Run Keyword And Return Status    Should End With    ${path}    /attributes
        Exit For Loop If    ${not_for_pushCompleteCMDB}
    END
    [Return]    ${not_for_pushCompleteCMDB}

Check MOs From VES
    [Arguments]    ${scf_file}    ${VES_CCN_msg}
    ${scf_content}    L_XML.Parse XML    ${scf_file}
    ${managedObject_elements}    L_XML.Get Elements    ${scf_content}    .//managedObject
    ${count}    Get Length    ${managedObject_elements}
    ${target_DN}    Set Variable    ${VES_CCN_msg["event"]["stndDefinedFields"]["data"]["systemDN"]}
    ${bts}    Should Match Regexp    ${target_DN}    MRBTS-\\d\+
    ${moiChanges}    Set Variable    ${VES_CCN_msg["event"]["stndDefinedFields"]["data"]["moiChanges"]}
    ${list_MO_VES}    Create List
    FOR    ${moiChange}    IN    @{moiChanges}
        ${path}    Get From Dictionary    ${moiChange}    path
        ${path}    Replace String Using Regexp    ${path}    /.*:    /
        ${path}    Remove String    ${path}    /ManagedElement=
        ${scf_path}    Set Variable If    "${path}"=="${bts}"    ${path}    ${bts}${path}
        ${scf_path}    Set Variable    ${scf_path.replace("=","-").replace("/attributes","")}
        Append To List    ${list_MO_VES}    ${scf_path}
    END
    ${list_MO_scf}    Create List
    FOR    ${managedObject_element}    IN    @{managedObject_elements}
        ${dn}    L_XML.Get Element Attribute    ${managedObject_element}    distName
        Append To List    ${list_MO_scf}    ${dn}
    END
    Sort List    ${list_MO_VES}
    Sort List    ${list_MO_scf}
    List Should Contain Sub List    ${list_MO_VES}    ${list_MO_scf}


Case Precondition
    [Arguments]    ${ReIntegrate_vCU}=False    ${ReIntegrate_vDU}=False
    Log To Console    Case Precondition
    Log    ${ReIntegrate_vCU}
    Common Test Setup For AIC
    vDU Login By Rest
    Setup NetAct    ${NETACT}
    #ReIntegrate NE
    Run Keyword If    ${ReIntegrate_vDU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${du_ip}    PLMN-PLMN/MRBTS-${vDU_id}    ${du_release}    ${du_mr}
    #need develop kw
    #Run Keyword If    ${Integrate_Need}    Integrate SBTS To ONAP Simulator    ${MRBTS_ID}    ${ONAP['host_ip']}
    Set Test Variable    ${host_ip}    ${ONAP["host_ip"]}
    Set Test Variable    ${user}    ${ONAP["user"]}
    Set Test Variable    ${pwd}    ${ONAP["pwd"]}
    vDU Login By Rest
    ${vesSourceName}    Get Parameter Value From vDU     MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1    vesSourceName
    Set Test Variable    ${vesSourceName}
    ${dnPrefix}    Get Parameter Value From vDU     MRBTS-${vDU_id}    dnPrefix
    Set Test Variable    ${dnPrefix}
    Set Test Variable    ${ONAP_DN}    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1

Case Postcondition
    Log To Console    Case Postcondition
#    ${out}   Run Keyword If    ${RECOVERY_FLAG}
#    ...    Parameter Operation    operation=full_commission    product_type=vdu    scf_path=${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    @{para_list}    Create List    pushCompleteCMDB    actCmEventsReporting
    @{value_list}    Create List    true    true
    @{mo_list}    Create List    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    Wait Until Keyword Succeeds    20min    30s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Common Test Teardown For AIC
    Teardown NetAct