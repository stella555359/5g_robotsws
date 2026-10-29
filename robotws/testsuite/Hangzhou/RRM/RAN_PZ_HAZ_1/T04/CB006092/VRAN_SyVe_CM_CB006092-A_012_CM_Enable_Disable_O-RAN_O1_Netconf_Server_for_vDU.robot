*** Settings ***
Documentation
...   Author: lixin.kang@nokia-sbell.com
...   Description: This robot cases is for CB006092-A_012 vDU
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
${RECOVERY_FLAG}    ${False}

*** Keywords ***
VRAN_SyVe_CM_CB006092-A_012_CM_Enable_Disable_O-RAN_O1_Netconf_Server_for_vDU
    [Documentation]
    ...    Author: lixin.kang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    23.06.2025, lixin.kang@nokia-sbell.com
    Step 1: Disable O1 Protocol Status And Check
    Step 2: Enable O1 Protocol Status And Check
    Step 3: Check Netconf Get After Full Commission

Step ${index}: Disable O1 Protocol Status And Check
    Log To Console    Step ${index}: Disable O1 Protocol Status And Check
    Set O1 Protocol Status And Check    ${false}    ${du_ip}

Step ${index}: Enable O1 Protocol Status And Check
    Log To Console    Step ${index}: Enable O1 Protocol Status And Check
    Set O1 Protocol Status And Check    ${true}    ${du_ip}
    Get And Check Partial CM Data From ONAP
    vDU Login By Rest
    ${time}    Get Time    epoch
    ${backup_scf_for_fullcomm}    vdu.get_current_plan_file    local_dir_path=${TEST_LOG_DIRECTORY}    filename=backup_scf_${time}.xml
    Set Test Variable    ${backup_scf_for_fullcomm}
    vDU Logout By Rest

Step ${index}: Check Netconf Get After Full Commission
    Log To Console    Step ${index}: Check Netconf Get After Full Commission
    Parameter Operation    operation=full_commission    product_type=vdu    scf_path=${backup_scf_for_fullcomm}
    Wait Until Keyword Succeeds    20m   60s   vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Connect To Netconf    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${du_ip}

Connect To Netconf
    [Arguments]    ${host_ip}    ${user}    ${pwd}    ${du_ip}
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${host_ip}    ${user}    ${pwd}    status
    Should Contain    ${ret}    Current NETCONF session
    Should Contain    ${ret}    ${du_ip}
    Log To Console    Connect To Netconf Success

Upload SCF From Netconf
    [Arguments]    ${host_ip}    ${user}    ${pwd}
    ${time}    Get Time    epoch
    ${ONAP_GET_OUT_FILE}    Set Variable    /tmp/CB006092-A_012_get-config_${time}.xml
    ${cmd}    Set Variable    get-config --source running --out ${ONAP_GET_OUT_FILE}
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd}
    Should Not Contain    ${ret}    Not connected to a NETCONF server
    Log To Console    Upload SCF From Netconf Success

Set O1 Protocol Status And Check
    [Arguments]    ${status}    ${du_ip}
    @{para_list}    Create List    activateOranO1NetconfService    actCmEventsReporting
    @{value_list}    Create List    ${status}    ${status}
    @{mo_list}    Create List    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Sleep    10s
    ${feedback}    Run Keyword And Return Status
    ...    Connect To Netconf    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${du_ip}
    Should Be Equal    ${feedback}    ${status}
    ${feedback}    Run Keyword And Return Status
    ...    Upload SCF From Netconf   ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    Should Be Equal    ${feedback}    ${status}

Get And Check Partial CM Data From ONAP
    ${DIC_DIF_ALL}    Create Dictionary
    ${DIC_NOT_EXIST_ALL}    Create Dictionary
    ${MO_type_list}    Create List    RMOD
    FOR    ${MO_type}    IN    @{MO_type_list}
        ${filter}    Set Variable    ManagedElement//${MO_type}
        ${diff_values}    ${not_exist_values}    Get And Check MO Data From ONAP    ${filter}    ${MO_type}
        Run Keyword If    '${diff_values.__len__()}'!='${0}'    Set To Dictionary    ${DIC_DIF_ALL}    ${MO_type}    ${diff_values}
        Run Keyword If    '${not_exist_values.__len__()}'!='${0}'    Set To Dictionary    ${DIC_NOT_EXIST_ALL}    ${MO_type}    ${not_exist_values}
    END
    #${file_content}    OperatingSystem.Get File    ${ONAP_IGNORE_PARAMS_FILE}
    #${ONAP_IGNORE_PARAMS}    Evaluate    ${file_content}
    ${DIC_DIF_ALL}    Remove Ignore Parameters    ${DIC_DIF_ALL}    #${ONAP_IGNORE_PARAMS}
    ${DIC_NOT_EXIST_ALL}    Remove Ignore Parameters    ${DIC_NOT_EXIST_ALL}    #${ONAP_IGNORE_PARAMS}
    Run Keyword And Ignore Error    Should Be Empty    ${DIC_DIF_ALL}
    Run Keyword And Ignore Error    Should Be Empty    ${DIC_NOT_EXIST_ALL}

Get And Check MO Data From ONAP
    [Arguments]    ${filter_xpath}    ${MO_type}
    ${time}    Get Time    epoch
    ${ONAP_GET_OUT_FILE}    Set Variable    /tmp/CB006092-A_012_get-config_${time}.xml
    ${cmd}    Set Variable    get-config --source running --filter-xpath ${filter_xpath} --out ${ONAP_GET_OUT_FILE}
    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    ${cmd}
    Get File From Simulator To Local
    ...    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    ${ONAP_GET_OUT_FILE}
    ...    ${TEST_LOG_DIRECTORY}/${ONAP_GET_OUT_FILE.split('/')[-1]}
    ${diff_values}    ${not_exist_values}    Check Netconf Get
    ...    ${MO_type}    ${BTS_FULL_SCF_FILE}    ${TEST_LOG_DIRECTORY}/${ONAP_GET_OUT_FILE.split('/')[-1]}
    [Return]    ${diff_values}    ${not_exist_values}

Check Netconf Get
    [Arguments]    ${MO_type}    ${scf_file}    ${onap_get_xml}
    ${scf_content}    L_XML.Parse XML    ${scf_file}
    ${onap_get_content}    L_XML.Parse XML    ${onap_get_xml}
    ${elements}    L_XML.Get Elements    ${scf_content}    .//managedObject[@class="${MO_type}"]
    ${count}    Get Length    ${elements}
    ${ran_index}    Evaluate    random.randint(0, ${count-1})    modules=random, sys
    ${dn}    L_XML.Get Element Attribute    ${elements[${ran_index}]}    distName
    ${diff_values}    Create Dictionary
    ${not_exist_values}    Create Dictionary
    #Check parameters of ${dn} those are not list nor structure
    Get MO Different P Parameters Of Netconf Get    ${scf_content}    ${onap_get_content}    ${dn}    ${diff_values}    ${not_exist_values}
    #Check parameters of ${dn} those are list
    Get MO Different List Parameters Of Netconf Get    ${scf_content}    ${onap_get_content}    ${dn}    ${diff_values}    ${not_exist_values}
    #Check parameters of ${dn} those are structure
    Get MO Different Struture Parameters Of Netconf Get    ${scf_content}    ${onap_get_content}    ${dn}    ${diff_values}    ${not_exist_values}
    [Return]    ${diff_values}    ${not_exist_values}

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
    #Run Keyword If    ${Integrate_Need}    Integrate VDU To ONAP Simulator    ${vDU_id}    ${ONAP['host_ip']}
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=scf_from_netact.xml
    ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    plan_name=None    ui_values=${True}    operation_type=actual
    Set Test Variable    ${BTS_FULL_SCF_FILE}    ${TEST_LOG_DIRECTORY}/NetActLogs/scf_from_netact.xml
    vDU Login By Rest

Case Postcondition
    Log To Console    Case Postcondition
    ${out}   Run Keyword If    ${RECOVERY_FLAG}
    ...    Parameter Operation    operation=full_commission    product_type=vdu    scf_path=${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    Wait Until Keyword Succeeds    20m    30s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Common Test Teardown For AIC
    Teardown NetAct