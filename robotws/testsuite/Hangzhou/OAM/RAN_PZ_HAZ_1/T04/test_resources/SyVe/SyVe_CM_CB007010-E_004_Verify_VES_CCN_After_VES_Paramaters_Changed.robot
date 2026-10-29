*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${Integrate_Need}    ${False}

*** Keywords ***
SyVe_CM_CB007010-E_004_Verify_VES_CCN_After_VES_Paramaters_Changed
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    For case:RAN_ST_CB007010-E_004_CM_Verify CCN on O-RAN O1 interface after VES notification functionality gets enabled
    ...    The main steps performed for the test are:
    ...    - Set pushCompleteCMDB As false And Check
    ...    - Set pushCompleteCMDB As true And Check
    ...    - Disable VES CCN And Check
    ...    - Enable VES CCN And Check
    ...    - Reset Site And Check pushCompleteCMDB Sent
    ...    - Trigger Site Reset And Check pushCompleteCMDB Sent
    ...    - Set pushCompleteCMDB As false And Check
    ...    - Disable VES CCN And Check
    ...    - Enable VES CCN And Check
    ...    - Reset Site And Check pushCompleteCMDB Not Sent
    ...    - Trigger Site Reset And Check pushCompleteCMDB Not Sent
    ...    Pass criteria: Provision delta plan from NetAct,and check CCN and check configuration get from ONAP Netconf,
    ...    same as on get from NetAct. Site is OK with no any unexpected alarm.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 06.08.2023 - New case
    ...    - 23.07.2025 removed CB013033 limitation due to PR840751
    Set Tags    CA-CM    AUTHOR-bin.7.liu@nokia-sbell.com    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com    API
    Log To Console    ${TEST_NAME} start.
    #20250214:disable step1-6 for CB013033 during 25R3 #20250723 removed this limitation
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

TC Setup
    Log To Console    TC Setup
    Common Test Setup
    Set Test Variable    ${BTS_ID}    ${MRBTS_DN.split("-")[-1]}
    Comment    ${ONAP_INFOR}    Get Informations From ONAP    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    Comment    Set Test Variable    ${ONAP_INFOR}
    Comment    Run Keyword If    ${Integrate_Need}    Integrate SBTS To ONAP    ${BTS_ID}    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    Comment    Run Keyword If    ${Integrate_Need}    Integrate SBTS To ONAP Simulator    ${BTS_ID}    ${ONAP['host_ip']}
    Prepare Case Variables CB007010_E_004

TC Teardown
    Log To Console    TC Teardown
    ${dic_param_value}    Create Dictionary
    ...    pushCompleteCMDB=true    actCmEventsReporting=true    heartBeatSendingInterval=${0}    activateSendingFmEvents=true
    Perform Delta Of ONAP And Check    ${ONAP_DN}    ${dic_param_value}
    Run Keyword If    '${actMplaneFronthaulFirewall_to_set}'=='${initial_actMplaneFronthaulFirewall}'
    ...    Set Param Trigger Site Reset    ${actMplaneFronthaulFirewall_to_set}
    Wait Until Keyword Succeeds    15 min    60 sec    Check SBTS SMOD RMOD Cells Alarms
    Comment    Tear VES Log Listener    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['ves_collector_5g']}
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    Common Test Teardown

Prepare Case Variables CB007010_E_004
    netact.Export Configuration    local_dir=${Test Results Dir}/NetActLogs
    ...    file_name=scf_from_netact.xml    dist_names=${MRBTS_DN}    ui_values=${True}
    Set Test Variable    ${BTS_FULL_SCF_FILE}    ${Test Results Dir}/NetActLogs/scf_from_netact.xml
    ${scf_content}    L_XML.Parse XML    ${BTS_FULL_SCF_FILE}
    ${count}    L_XML.Get Element Count    ${scf_content}    .//managedObject[@class="SMOD_R"]
    ${xpath}    Set Variable If    '${count}'=='${1}'    .//managedObject[@class="SMOD_R"]/p[@name="serialNumber"]
    ...    .//managedObject[@class="SMOD_R"]/p[@name="activeRole" and text()="Primary"]/../p[@name="serialNumber"]
    ${PRIMARY_CORE_DN}    L_XML.Get Element Text    ${scf_content}    ${xpath}
    Set Test Variable    ${PRIMARY_CORE_DN}
    Set Test Variable    ${ONAP_DN}    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${initial_actMplaneFronthaulFirewall}    L_XML.Get Element Text
    ...    ${scf_content}    .//managedObject[@class="FEATCADM"]/p[@name="actMplaneFronthaulFirewall"]
    Set Test Variable    ${initial_actMplaneFronthaulFirewall}
    #${actMplaneFronthaulFirewall_to_set} is always opposite the current value
    ${actMplaneFronthaulFirewall_to_set}    Set Variable If
    ...    '${initial_actMplaneFronthaulFirewall}'=='true'    false    true
    Set Test Variable    ${actMplaneFronthaulFirewall_to_set}

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

Get First VES pushCompleteCMDB MSN
    [Arguments]    ${VES_CCN_msgs}    ${core_SN}    ${bts_id}    ${mplane_ip}
    ${dic_standard_head}    Create Dictionary    sourceName=NOK${core_SN}    reportingEntityName=NOK${core_SN}
    ...    priority=Normal    eventName=StndDefined_mrbts-Nokia_3gppNotifyMoiChanges
    ...    vesEventListenerVersion=7.2    stndDefinedNamespace=3GPP-Provisioning
    ${VES_CCN_notifyMOIChanges}    Filter VES CCN MSG    ${dic_standard_head}    ${VES_CCN_msgs}
    ${systemDN}    Set Variable    SubNetwork=${bts_id},ManagedElement=MRBTS-${bts_id}
    ${dic_data_head}    Create Dictionary    systemDN=${systemDN}    notificationType=notifyMOIChanges    href=${mplane_ip}
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

Perform Delta Of ONAP And Check
    [Arguments]    ${MO}    ${dic_param}
    ${params}    Get Dictionary Keys    ${dic_param}
    ${parameter_list}    Create List
    ${query_list}    Create List
    FOR    ${param}    IN    @{params}
        ${dic_p}    create dictionary    parameterName=${param}    operation=update    value=${dic_param["${param}"]}
        Append To List    ${parameter_list}    ${dic_p}
        Append To List    ${query_list}    ${param}=${dic_param["${param}"]}
    END
    ${query_str}    Catenate    SEPARATOR=,    @{query_list}
    coam.Perform Object Recommissioning    dist_name=${MO}    operation=update    parameter=${parameter_list}
    ute_admin_infomodel.query_infomodel    //MPLANEONAP_A-1 is [${query_str}]    timeout=20

Set Param Trigger Site Reset
    [Arguments]    ${val_to_set}
    ${dn}    Set variable    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ${dict_actMplaneFronthaulFirewall}    Create Dictionary
    ...    parameterName=actMplaneFronthaulFirewall    operation=update    value=${val_to_set}
    ${param_list}    Create List    ${dict_actMplaneFronthaulFirewall}
    coam.Perform Object Recommissioning    dist_name=${dn}    operation=update    parameter=${param_list}

Check VES CCN After Site Reset
    [Arguments]    ${should_send_pushCompleteCMDB}
    Comment    ${ves_ccn_file}    Start VES Log Listen
    ...    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['ves_collector_5g']}    ${BTS_ID}
    Start VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    Wait Until Keyword Succeeds    20 min    60 sec    Check SBTS SMOD RMOD Cells Alarms
    Comment    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages
    ...    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['ves_collector_5g']}    ${ves_ccn_file}
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ${VES_pushCompleteCMDB_msg}    Get First VES pushCompleteCMDB MSN    ${VES_CCN_msgs}    ${PRIMARY_CORE_DN}    ${BTS_ID}    ${MPLANE_IP}
    ${is_sent}    Run Keyword And Return Status    Should Not Be Empty    ${VES_pushCompleteCMDB_msg}
    Should Be Equal As Strings    ${is_sent}    ${should_send_pushCompleteCMDB}    ignore_case=True
    Run Keyword If    ${is_sent}    Check MOs From VES    ${BTS_scf_initial}    ${VES_pushCompleteCMDB_msg}

Step ${index}: Disable VES CCN And Check
    Log To Console    Step ${index}: Disable VES CCN And Check
    Comment    ${ves_ccn_file}    Start VES Log Listen    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['ves_collector_5g']}
    ...    ${BTS_ID}
    Start VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ${dic_param_value}    create dictionary    actCmEventsReporting=false    activateSendingFmEvents=false
    Perform Delta Of ONAP And Check    ${ONAP_DN}    ${dic_param_value}
    Sleep    60s    #time for CCN
    Comment    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages
    ...    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['ves_collector_5g']}    ${ves_ccn_file}
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
    ...    ${VES_CCN_msgs}    ${ONAP_DN}    ${PRIMARY_CORE_DN}    ${MPLANE_IP}    replace    ${dic_param_value}
    Should Be Empty    ${target_VES_CCN_msg}

Step ${index}: Enable VES CCN And Check
    Log To Console    Step ${index}: Enable VES CCN And Check
    Comment    ${ves_ccn_file}    Start VES Log Listen
    ...    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['ves_collector_5g']}    ${BTS_ID}
    Start VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ${dic_param_value}    Create Dictionary    actCmEventsReporting=true
    Perform Delta Of ONAP And Check    ${ONAP_DN}    ${dic_param_value}
    Sleep    60s    #time for CCN
    Comment    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages
    ...    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['ves_collector_5g']}    ${ves_ccn_file}
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ${operate}    Set Variable If    "${index}"=="${4}"    add    replace
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
    ...    ${VES_CCN_msgs}    ${ONAP_DN}    ${PRIMARY_CORE_DN}    ${MPLANE_IP}    ${operate}    ${dic_param_value}
    Should Not Be Empty    ${target_VES_CCN_msg}

Step ${index}: Set pushCompleteCMDB As ${value} And Check
    Log To Console    Step ${index}: Set pushCompleteCMDB As ${value} And Check
    Comment    ${ves_ccn_file}    Start VES Log Listen    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['ves_collector_5g']}
    ...    ${BTS_ID}
    Start VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ${dic_param_value}    create dictionary    pushCompleteCMDB=${value}
    Perform Delta Of ONAP And Check    ${ONAP_DN}    ${dic_param_value}
    Sleep    60s    #time for CCN
    Comment    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages
    ...    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['ves_collector_5g']}    ${ves_ccn_file}
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN    ${VES_CCN_msgs}    ${ONAP_DN}    ${PRIMARY_CORE_DN}    ${MPLANE_IP}    replace
    ...    ${dic_param_value}
    Should Not Be Empty    ${target_VES_CCN_msg}

Step ${index}: Reset Site And Check pushCompleteCMDB ${expect}
    Log To Console    Step ${index}: Reset Site And Check pushCompleteCMDB ${expect}
    coam.reset
    ${should_send_pushCompleteCMDB}    Run Keyword And Return Status
    ...    Should Be Equal As Strings    ${expect}    sent    ignore_case=True
    Check VES CCN After Site Reset    ${should_send_pushCompleteCMDB}

Step ${index}: Trigger Site Reset And Check pushCompleteCMDB ${expect}
    Log To Console    Step ${index}: Trigger Site Reset And Check pushCompleteCMDB ${expect}
    Set Param Trigger Site Reset    ${actMplaneFronthaulFirewall_to_set}
    ${actMplaneFronthaulFirewall_to_set}    Set Variable If
    ...    '${actMplaneFronthaulFirewall_to_set}'=='true'    false    true
    Set Test Variable    ${actMplaneFronthaulFirewall_to_set}
    ${should_send_pushCompleteCMDB}    Run Keyword And Return Status
    ...    Should Be Equal As Strings    ${expect}    sent    ignore_case=True
    Check VES CCN After Site Reset    ${should_send_pushCompleteCMDB}
