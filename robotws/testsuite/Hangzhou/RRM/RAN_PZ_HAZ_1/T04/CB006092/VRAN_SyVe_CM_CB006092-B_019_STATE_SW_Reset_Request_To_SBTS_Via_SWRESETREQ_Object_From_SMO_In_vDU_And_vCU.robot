*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
...   Description: This robot cases is for RAN_ST_CB006092-B_016_CM_Creation and Deletion of managed object for vDU
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot


*** Keywords ***
VRAN_SyVe_CM_CB006092-B_019_STATE_SW_Reset_Request_To_SBTS_Via_SWRESETREQ_Object_From_SMO_In_vDU_And_vCU
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    09.07.2025, yuyan.xu@nokia-sbell.com
    Step 1: Provision Delta Plan With btsReset On NetConf In vCU
    Step 2: Check btsReset Action On vCU
    Step 3: Check btsReset Feedback and CCN Message On VES In vCU
    Step 4: Provision Delta Plan With btsReset On NetConf In vDU
    Step 5: Check btsReset Action On vDU
    Step 6: Check btsReset Feedback and CCN Message On VES In vDU

Step ${index}: Provision Delta Plan With ${resetlevel} On NetConf In vCU
    Log To Console    Step ${index}: Provision Delta Plan With ${resetlevel} On NetConf In vCU
    ${time}    Get Time    epoch
    ${fileName_init}    Set Variable    onap_vCU_${resetlevel}_${time}.xml
    ${fileName_updated}    Set Variable    onap_vCU_${resetlevel}_${time}_updated.xml
    Delete CMD Via Admin    ${TEST_LOG_DIRECTORY}/backup_scf_vcu/vCU_scf.xml    ${vCU_id}    vCU
    Login To vCU By Rest
    Wait Until Keyword Succeeds    20min    60s    Check All Cells On Air In vCU    gnb_index=0
    ${cmd_getConfig}    Set Variable
    ...    get-config --source running --filter-xpath ManagedElement/MNL/id[text()="1"] --out=/tmp/${fileName_init}
    ${cmd_editConfig}    Set Variable
    ...    edit-config --target running --config=/tmp/${fileName_updated} --test test-then-set --error rollback --rpc-timeout 160s
    Execute NetConf Command On ONAP Simulator    MRBTS-${vCU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd_getConfig}
    Get File From Simulator To Local    ${host_ip}    ${user}    ${pwd}
    ...    /tmp/${fileName_init}    ${TEST_LOG_DIRECTORY}/${fileName_init}
	Generate SW Reset Delta Plan For NetConf    ${TEST_LOG_DIRECTORY}/${fileName_init}    ${TEST_LOG_DIRECTORY}/${fileName_updated}    ${resetlevel}
	Put File From Local To Simulator    ${host_ip}    ${user}    ${pwd}
    ...    /tmp/${fileName_updated}    ${TEST_LOG_DIRECTORY}/${fileName_updated}
	Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
	${output}    Execute NetConf Command On ONAP Simulator    MRBTS-${vCU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd_editConfig}
	Should Contain    ${output}    \r\nOK\r\n

Delete CMD Via Admin
    [Arguments]    ${scf_file}    ${BTS_ID}    ${NE_Type}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_content}    L_XML.Parse xml    ${scf_file}
    ${cmds}   L_XML.Get Elements
    ...    ${scf_content}    .//managedObject[@distName="MRBTS-${BTS_ID}/MNL-1/CMD-1"]
    ${CMD_Existed}    Set Variable If  "${cmds.__len__()}">="${1}"    ${True}    ${False}
    Return From Keyword If    "${CMD_Existed}"=="${False}"
    ${delta_plan}    Set Variable    [{"distName": "MRBTS-${BTS_ID}/MNL-1/CMD-1", "operation": "delete"}]
    ${out}    Run keyword If    "${NE_Type.lower()}"=="vcu"    cu.perform_delta_recommissioning    ${delta_plan}
    ...    ELSE    vdu.perform_delta_recommissioning    ${delta_plan}
    Should Be Equal As Strings    ${out["status"]}    success

Step ${index}: Provision Delta Plan With ${resetlevel} On NetConf In vDU
    Log To Console    Step ${index}: Provision Delta Plan With ${resetlevel} On NetConf In vDU
    ${time}    Get Time    epoch
    ${fileName_init}    Set Variable    onap_vDU_${resetlevel}_${time}.xml
    ${fileName_updated}    Set Variable    onap_vDU_${resetlevel}_${time}_updated.xml
    Delete CMD Via Admin    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml    ${vDU_id}    vDU
    vDU Login By Rest
    Wait Until Keyword Succeeds    10min    10s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    ${tmp_para}    Set Variable    timeZone
    ${cmd_getConfig}    Set Variable
    ...    get-config --source running --filter-xpath ManagedElement/MNL/id[text()="1"]/../attributes/${tmp_para} --out=/tmp/${fileName_init}
    ${cmd_editConfig}    Set Variable
    ...    edit-config --target running --config=/tmp/${fileName_updated} --test test-then-set --error rollback --rpc-timeout 160s
    #Simulator
    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd_getConfig}
    Get File From Simulator To Local    ${host_ip}    ${user}    ${pwd}
    ...    /tmp/${fileName_init}    ${TEST_LOG_DIRECTORY}/${fileName_init}
	Generate SW Reset Delta Plan For NetConf    ${TEST_LOG_DIRECTORY}/${fileName_init}    ${TEST_LOG_DIRECTORY}/${fileName_updated}    ${resetlevel}
	Put File From Local To Simulator    ${host_ip}    ${user}    ${pwd}
    ...    /tmp/${fileName_updated}    ${TEST_LOG_DIRECTORY}/${fileName_updated}
	Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
	${output}    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd_editConfig}
	Should Contain    ${output}    \r\nOK\r\n

Generate SW Reset Delta Plan For NetConf
    [Arguments]    ${source_file}    ${target_file}    ${reset_level}
	Log To Console    Generate SW Reset Delta Plan For NetConf
    ${file_content}    OperatingSystem.Get File    ${source_file}
    ${file_content}    Remove String    ${file_content}    <data xmlns="urn:ietf:params:xml:ns:netconf:base:1.0">
    ${file_content}    Remove String    ${file_content}    </data>
    ${scf_xml}    L_XML.Parse xml    ${file_content}
    L_XML.Remove Elements    source=${scf_xml}    xpath=//attributes    remove_tail=True
    L_XML.Add Element    ${scf_xml}    <CMD/>    xpath=//MNL
    L_XML.Add Element    ${scf_xml}    <id>1</id>    xpath=//CMD
    L_XML.Add Element    ${scf_xml}    <SWRESETREQ/>    xpath=//CMD
    L_XML.Add Element    ${scf_xml}    <id>1</id>    xpath=//SWRESETREQ
    L_XML.Add Element    ${scf_xml}    <attributes/>    xpath=//SWRESETREQ
    L_XML.Add Element    ${scf_xml}    <swResetLevel>${reset_level}</swResetLevel>    xpath=//SWRESETREQ/attributes
    L_XML.Save Xml    ${scf_xml}    ${target_file}
    ${file_content}    OperatingSystem.Get File    ${target_file}
    ${file_content}    Replace String    ${file_content}    \&\#13;    ${EMPTY}
    ${parsed_xml}    XML.Parse XML    ${file_content}
    XML.Set Element Attribute    ${parsed_xml}    xmlns:nc    urn:ietf:params:xml:ns:netconf:base:1.0    .
    XML.Set Elements Attribute    ${parsed_xml}    nc:operation    create    .//CMD
    XML.Set Elements Attribute    ${parsed_xml}    nc:operation    create    .//SWRESETREQ
    XML.Save Xml    ${parsed_xml}    ${target_file}
    Sleep    10s    time for file creation

Step ${index}: Check btsReset Action On vCU
    Log To Console    Step ${index}: Check btsReset Action On vCU
     ${reset_status}    Set Variable
    FOR    ${index}    IN RANGE    0    20
        ${reset_status}    Run Keyword And Return Status    Check IP Is Pingable    ${vCU_oamssh_ip}    expect_pingable=${False}
        Exit For Loop If    ${reset_status}
        Sleep    10s
    END
    Should Be True    ${reset_status}
    Wait Until Keyword Succeeds    10min    30s    Login To vCU By Rest
    Wait Until Keyword Succeeds    20min    60s    Check All Cells On Air In vCU    gnb_index=0
    Sleep    30s
    @{para_list}    Create List    swResetResult
    @{value_list}    Create List    success
    @{mo_list}    Create List    MRBTS-${vCU_id}/MNL-1/CMD-1/SWRESETREQ-1/SWRESETRES-1
    ${out}    Parameter Operation    operation=parameter_value_check    product_type=vcu
    ...    para_list=@{para_list}    mo_list=@{mo_list}
    Should Be Equal As Strings    ${out["${mo_list[0]}"]["${para_list[0]}"]}    success

Step ${index}: Check btsReset Action On vDU
    Log To Console    Step ${index}: Check btsReset Action On vDU
     ${reset_status}    Set Variable
    FOR    ${index}    IN RANGE    0    20
        ${reset_status}    Run Keyword And Return Status    Check IP Is Pingable    ${vDU_oamssh_ip}    expect_pingable=${False}
        Exit For Loop If    ${reset_status}
        Sleep    10s
    END
    Should Be True    ${reset_status}
    Wait Until Keyword Succeeds    10min    10s    vDU Login By Rest
    Wait Until Keyword Succeeds    10min    10s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Sleep    30s
    @{para_list}    Create List    swResetResult
    @{value_list}    Create List    success
    @{mo_list}    Create List    MRBTS-${vDU_id}/MNL-1/CMD-1/SWRESETREQ-1/SWRESETRES-1
    ${out}    Parameter Operation    operation=parameter_value_check    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}
    Should Be Equal As Strings    ${out["${mo_list[0]}"]["${para_list[0]}"]}    success

Step ${index}: Check ${Type} Feedback and CCN Message On VES In ${NE}
    Log To Console    Step ${index}: Check ${Type} Feedback and CCN Message On VES In ${NE}
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    ${target_VES_CCN_msg}    Filter VES VsCmOperationFeedbackNotification CCN
    ...    ${VES_CCN_msgs}    ${NE}    ${vesSourceName_${NE}}    provision    completed
    Log    ${target_VES_CCN_msg}
    Should Be Equal As Integers    ${target_VES_CCN_msg.__len__()}    ${1}
    ${Param_Req_Dic}    Create Dictionary    swResetLevel=${Type}
    ${Param_Res_Dic}    Create Dictionary    	swResetResult=success
    ${ne_ip}    Set Variable If    "${NE.lower()}"=="vdu"    ${du_ip}    ${cu_ip}
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN    ${VES_CCN_msgs}
    ...    MRBTS-${${NE}_id}/MNL-1/CMD-1/SWRESETREQ-1   ${NE}    ${vesSourceName_${NE}}    ${dnPrefix_${NE}}    ${ne_ip}    add    ${Param_Req_Dic}
    log    ${target_VES_CCN_msg}
    should be true    "${target_VES_CCN_msg.__len__()}">="${1}"
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN    ${VES_CCN_msgs}    MRBTS-${${NE}_id}/MNL-1/CMD-1/SWRESETREQ-1/SWRESETRES-1
    ...   ${NE}    ${vesSourceName_${NE}}    ${dnPrefix_${NE}}    ${ne_ip}    add    ${Param_Res_Dic}
    log    ${target_VES_CCN_msg}
    should be true    "${target_VES_CCN_msg.__len__()}">="${1}"


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
    #Run Keyword If    ${Integrate_Need}    Integrate SBTS To ONAP Simulator    ${MRBTS_ID}    ${ONAP['host_ip']}
    Set Test Variable    ${host_ip}    ${ONAP["host_ip"]}
    Set Test Variable    ${user}    ${ONAP["user"]}
    Set Test Variable    ${pwd}    ${ONAP["pwd"]}
    vDU Login By Rest
    ${vesSourceName_vDU}    Get Parameter Value From vDU     MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1    vesSourceName
    Set Test Variable    ${vesSourceName_vDU}
    ${dnPrefix_vDU}    Get Parameter Value From vDU     MRBTS-${vDU_id}    dnPrefix
    Set Test Variable    ${dnPrefix_vDU}
    Login To vCU By Rest
    ${vesSourceName_vCU}    Get Parameter Value From vCU     MRBTS-${vCU_id}/MNL-1/MNLENT-1/MPLANEONAP-1    vesSourceName
    Set Test Variable    ${vesSourceName_vCU}
    ${dnPrefix_vCU}    Get Parameter Value From vCU     MRBTS-${vCU_id}    dnPrefix
    Set Test Variable    ${dnPrefix_vCU}

Case Postcondition
    Log To Console    Case Postcondition
    Common Test Teardown For AIC
    Teardown NetAct