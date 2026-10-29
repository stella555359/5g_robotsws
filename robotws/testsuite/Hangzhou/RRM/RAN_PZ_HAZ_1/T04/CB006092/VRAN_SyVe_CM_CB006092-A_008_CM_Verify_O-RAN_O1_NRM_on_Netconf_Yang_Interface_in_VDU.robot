*** Settings ***
Documentation
...   Author: lixin.kang@nokia-sbell.com
...   Description: This robot cases is for NFTA
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
${RECOVERY_FLAG}    ${False}

*** Keywords ***
VRAN_SyVe_CM_CB006092-A_008_CM_Verify_O-RAN_O1_NRM_on_Netconf_Yang_Interface_in_VDU
    [Documentation]
    ...    Author: lixin.kang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    23.06.2025, lixin.kang@nokia-sbell.com
    Step 1: Modify Parameter Values From Local
    Step 2: Check Parameter Values From SMO
    Step 3: Modify dnPrefix From Local
    Step 4: Check dnPrefix From SMO

Step ${index}: Modify Parameter Values From Local
    Log To Console    Step ${index}: Modify Parameter Values From Local
    vDU Login By Rest
    ${status}    ${dnPrefix}    Run Keyword And Ignore Error    Get Parameter Value From vDU     MRBTS-${vDU_id}    dnPrefix
    ${dnPrefix}    Set Variable If    "${status}"=="PASS"    ${dnPrefix}    ${EMPTY}
    Set Test Variable    ${dnPrefix}
    ${status}    ${userDefinedState}    Run Keyword And Ignore Error    Get Parameter Value From vDU     MRBTS-${vDU_id}   userDefinedState
    ${userDefinedState}    Set Variable If    "${status}"=="PASS"     ${userDefinedState}    ${EMPTY}
    Set Test Variable    ${userDefinedState}
    ${status}    ${priorityLabel}    Run Keyword And Ignore Error    Get Parameter Value From vDU     MRBTS-${vDU_id}    priorityLabel
    ${priorityLabel}    Set Variable If    "${status}"=="PASS"     ${priorityLabel}    ${EMPTY}
    Set Test Variable    ${priorityLabel}
    ${status}    ${userLabel}    Run Keyword And Ignore Error    Get Parameter Value From vDU     MRBTS-${vDU_id}/MNL-1   userLabel
    ${userLabel}    Set Variable If    "${status}"=="PASS"     ${userLabel}    ${EMPTY}
    Set Test Variable    ${userLabel}
    @{para_list}    Create List    userDefinedState    priorityLabel    userLabel
    @{value_list}    Create List    A-008    ${vDU_id}    HZ杭州
    @{mo_list}    Create List    MRBTS-${vDU_id}   MRBTS-${vDU_id}    MRBTS-${vDU_id}/MNL-1
    Start VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    Set Test Variable    ${RECOVERY_FLAG}    ${True}
    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0

Step ${index}: Check Parameter Values From SMO
    Log To Console    Step ${index}: Check Parameter Values From SMO
    ${time}    Get Time    epoch
    ${ONAP_GET_OUT_FILE}    Set Variable    /tmp/CB006092-A_012_get-config_${time}.xml
    ${cmd}    Set Variable    get-config --source running --out ${ONAP_GET_OUT_FILE}
    Upload SCF From Netconf    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${cmd}
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ${param_dic}    Create Dictionary    userDefinedState=A-008    priorityLabel=${vDU_id}    userLabel=HZ杭州
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN    ${VES_CCN_msgs}    MRBTS-${vDU_id}
    ...    vDu    ${vesSourceName}    ${dnPrefix}    ${du_ip}    replace    ${param_dic}

Step ${index}: Modify dnPrefix From Local
    Log To Console    Step ${index}: Modify dnPrefix From Local
    vDU Login By Rest
    ${dnPrefix}    Get Parameter Value From vDU     MRBTS-${vDU_id}    dnPrefix
    Set Test Variable    ${dnPrefix}
    @{para_list}    Create List    dnPrefix
    @{value_list}    Create List    SubNetwork=North
    @{mo_list}    Create List    MRBTS-${vDU_id}
    Start VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    Wait Until Keyword Succeeds    20m    30s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0

Step ${index}: Check dnPrefix From SMO
    Log To Console    Step ${index}: Check dnPrefix From SMO
    ${time}    Get Time    epoch
    ${ONAP_GET_OUT_FILE}    Set Variable    /tmp/CB006092-A_012_get-config_${time}.xml
    ${cmd}    Set Variable    get --out ${ONAP_GET_OUT_FILE}
    Upload SCF From Netconf    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${cmd}
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ${param_dic}    Create Dictionary    SubNetwork=North
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN    ${VES_CCN_msgs}    MRBTS-${vDU_id}
    ...    vDu    ${vesSourceName}    SubNetwork=North    ${du_ip}    replace    ${param_dic}

Upload SCF From Netconf
    [Arguments]    ${host_ip}    ${user}    ${pwd}    ${cmd}
    ${start_time}    Get Time
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd}
    ${end_time}    Get Time
    ${time}    Subtract Date From Date    ${end_time}    ${start_time}
    Should Be True    ${time}<50
    Should Not Contain    ${ret}    Not connected to a NETCONF server
    Log To Console    Upload SCF From Netconf Success

Case Precondition
    [Arguments]    ${ReIntegrate_vCU}=False    ${ReIntegrate_vDU}=False
    Log To Console    Case Precondition
    Log    ${ReIntegrate_vCU}
    Common Test Setup For AIC
    Setup NetAct    ${NETACT}
    #ReIntegrate NE
    Run Keyword If    ${ReIntegrate_vDU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${du_ip}    PLMN-PLMN/MRBTS-${vDU_id}    ${du_release}    ${du_mr}
    #need develop kw
    #Run Keyword If    ${Integrate_Need}    Integrate SBTS To ONAP Simulator    ${vDU_id}    ${ONAP['host_ip']}
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=scf_from_netact.xml
    ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    plan_name=None    ui_values=${True}    operation_type=actual
    Set Test Variable    ${BTS_FULL_SCF_FILE}    ${TEST_LOG_DIRECTORY}/NetActLogs/scf_from_netact.xml
    vDU Login By Rest
    ${vesSourceName}    Get Parameter Value From vDU     MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1    vesSourceName
    Set Test Variable    ${vesSourceName}

Case Postcondition
    Log To Console    Case Postcondition
    @{para_list}    Create List    dnPrefix    userDefinedState    priorityLabel    userLabel
    @{value_list}    Create List    ${dnPrefix}    ${userDefinedState}    ${priorityLabel}    ${userLabel}
    @{mo_list}    Create List    MRBTS-${vDU_id}    MRBTS-${vDU_id}   MRBTS-${vDU_id}    MRBTS-${vDU_id}/MNL-1
    ${out}   Run Keyword If    ${RECOVERY_FLAG}
    ...    Parameter Operation    operation=parameter_update    product_type=vdu    para_list=@{para_list}
    ...    mo_list=@{mo_list}    value_list=@{value_list}
    Wait Until Keyword Succeeds    20m    30s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Common Test Teardown For AIC
    Teardown NetAct