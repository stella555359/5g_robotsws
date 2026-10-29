*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${Integrate_Need}        ${False}
${needRecovery}       False
${NEED_TO_CHECK_LTE_RAT_STATUS}    False

*** Keywords ***
SyVe_CM_CB007010-B_005_STATE_SW_Reset_Request_To_SBTS_Via_SWRESETREQ_From_SMO
        [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   For case:TA_RAN_ST_CB007010-B_B2_005_CM_STATE_SW reset request to SBTS via SWRESETREQ object from SMO
    ...  The main steps performed for the test are:
    ...  - Provision Delta Plan With powerReset On NetConf
    ...  - Check PowerReset Action On SBTS
    ...  - Check PowerReset Feedback and CCN Message On VES
    ...  - Provision Delta Plan With gnbReset On NetConf
    ...  - Check GnbReset Action On SBTS
    ...  - Check GnbReset Feedback and CCN Message On VES
    ...  Pass criteria: Provision delta plan from NetConf,and check parameter value on NetAct and CCN on ONAP.
    ...  Site is OK with no any unexpected alarm.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 09.27.2023 - New case

    Set Tags    CA-CM    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com    API
    LOG    ${TEST_NAME} of ${SUITE_NAME} start.    console=${True}
    Step 1: Provision Delta Plan With powerReset On NetConf
	Step 2: Check PowerReset Action On SBTS
    Step 3: Check PowerReset Feedback and CCN Message On VES
	Step 4: Provision Delta Plan With gnbReset On NetConf
	Step 5: Check GnbReset Action On SBTS
    Step 6: Check GnbReset Feedback and CCN Message On VES


Step ${index}: Provision Delta Plan With ${resetlevel} On NetConf
    Log To Console    Step ${index}: Provision Delta Plan With ${resetlevel} On NetConf
    ${time}    Get Time    epoch
    ${fileName_init}    Set Variable    onap_${resetlevel}_${time}.xml    #${Test Results Dir}
    ${fileName_updated}    Set Variable    onap_${resetlevel}_${time}_updated.xml
    Delete CMD Via Admin
    ${tmp_para}    Set Variable    validatePlanAgainstDetectedHW
    ${cmd_getConfig}    Set Variable
    ...    get-config --source running --filter-xpath ManagedElement/MNL/id[text()="1"]/../attributes/${tmp_para} --out=/tmp/${fileName_init}
    ${cmd_editConfig}    Set Variable
    ...    edit-config --target running --config=/tmp/${fileName_updated} --test test-then-set --error rollback --rpc-timeout 160s
    #Simulator
    Execute NetConf Command On ONAP Simulator    MRBTS-${BTS_ID}  ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${cmd_getConfig}
    Get File From Simulator To Local    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    /tmp/${fileName_init}    ${Test Results Dir}/${fileName_init}
	Generate SW Reset Delta Plan For NetConf    ${Test Results Dir}/${fileName_init}    ${Test Results Dir}/${fileName_updated}    ${resetlevel}
	Put File From Local To Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    /tmp/${fileName_updated}    ${Test Results Dir}/${fileName_updated}
	Start VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
	${output}    Execute NetConf Command On ONAP Simulator    MRBTS-${BTS_ID}  ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
	...   ${cmd_editConfig}
	Should Contain    ${output}    \r\nOK\r\n
	Set Test Variable    ${needRecovery}    True

    # below are used for real ONAP
#    Exucute One Command On Netconf CLI
#    ...    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['netconf_server']}    ${MPLANE_IP}    ${cmd_getConfig}
#    Get File From Pod To Local    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['netconf_server']}
#    ...    /tmp/${fileName_init}    ${Test Results Dir}/${fileName_init}
#    Generate Delta Plan For NetConf    ${Test Results Dir}/${fileName_init}    ${Test Results Dir}/${fileName_updated}    ${resetlevel}
#    Put File From Local To Pod    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['netconf_server']}
#    ...    /tmp/${Test Results Dir}/${fileName_updated}    ${Test Results Dir}/${fileName_updated}
#    #Start CCN
#    ${output}    Exucute One Command On Netconf CLI
#    ...    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['netconf_server']}    ${MPLANE_IP}    ${cmd_editConfig}
#    Should Contain    ${output}    \r\nOK\r\n
#    Set Test Variable    ${needRecovery}    True

Delete CMD Via Admin
    ${scf_initial}    coam.Get Scf
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_content}    L_XML.Parse xml    ${scf_initial}
    ${cmds}   L_XML.Get Elements
    ...    ${scf_content}    .//managedObject[@distName="MRBTS-${BTS_ID}/MNL-1/CMD-1"]
    ${CMD_Existed}    Set Variable If  "${cmds.__len__()}">="${1}"    ${True}    ${False}
    ${empty_list}    Create List
    Run Keyword If    ${CMD_Existed}    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1/CMD-1
    ...    parameter=${empty_list}    operation=delete
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms

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

Step ${index}: Check PowerReset Action On SBTS
    Log To Console    Step ${index}: Check PowerReset Action On SBTS
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    ${ims2_file_path_name}    Set Variable    ${Test Results Dir}/BTSFiles/check_PowerReset_InfoModel_log.ims2
    ${reset_was_triggered}    Infomodel Check IM log if BTS reset was triggered    ${ims2_file_path_name}
    Should Be True    ${reset_was_triggered}
    ${Param_Res_Dic}    Create Dictionary    	swResetResult=success
    Wait Until Keyword Succeeds    3x    15s    Check WebEM After Modify Parameters
    ...    MRBTS-${BTS_ID}/MNL-1/CMD-1/SWRESETREQ-1/SWRESETRES-1    configurationAndRuntimeObjects    &{Param_Res_Dic}

Step ${index}: Check GnbReset Action On SBTS
    Log To Console    Step ${index}: Check GnbReset Action On SBTS
    FOR    ${index}    IN RANGE    0    120
        sleep    3s
        ${result}    ${rat_status}=    run keyword and ignore error    Check NR RAT status
        Check Other RAT Status Enabled
        ${reset}    run keyword and return status    Should Be Equal As Strings    ${rat_status}    ALL_DISABLED
        exit for loop if    ${reset}
    END
    should be equal as strings    ${reset}    True
    FOR    ${index}    IN RANGE    0    120
        sleep    3s
        ${NRcells_Status}    Run Keyword And Return Status    coam.Assert Every    NRCEL    operationalState=${_Enabled_}
        Check Other RAT Status Enabled
        exit for loop if    ${NRcells_Status}
    END
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    ${Param_Req_Dic}    Create Dictionary    	swResetLevel=gnbReset
    Check WebEM After Modify Parameters   MRBTS-${BTS_ID}/MNL-1/CMD-1/SWRESETREQ-1   &{Param_Req_Dic}
    ${Param_Res_Dic}    Create Dictionary    	swResetResult=success
    Wait Until Keyword Succeeds    3x    15s    Check WebEM After Modify Parameters
    ...    MRBTS-${BTS_ID}/MNL-1/CMD-1/SWRESETREQ-1/SWRESETRES-1   configurationAndRuntimeObjects    &{Param_Res_Dic}

Check Other RAT Status Enabled
    ${gsm_state}    Run Keyword If    ${GSM_cell_ids}    Check GSM RAT status
    ${wcdma_state}    Run Keyword If    ${WCDMA_cell_ids}    Check WCDMA RAT status
    ${lte_state}    Run Keyword If    ${LTE_cell_ids} and ${NEED_TO_CHECK_LTE_RAT_STATUS}       Check LTE RAT status
    Run Keyword If    ${GSM_cell_ids}    Should Be Equal As Strings    ${gsm_state}    ALL_ENABLED
    Run Keyword If    ${WCDMA_cell_ids}    Should Be Equal As Strings    ${wcdma_state}    ALL_ENABLED
    Run Keyword If    ${LTE_cell_ids} and ${NEED_TO_CHECK_LTE_RAT_STATUS}    Should Be Equal As Strings
    ...    ${lte_state}    ALL_ENABLED

Check ${rat_techo} RAT status
    ${rat}    String.Convert To Lower Case    ${rat_techo}
    ${btsinfo_list}    coam.Get Bts Info
    ${rat_status}    set variable    ${btsinfo_list['ratState']['${rat}']}
    [Return]    ${rat_status}

Step ${index}: Check ${Type} Feedback and CCN Message On VES
    Log To Console    Step ${index}: Check GnbReset Feedback and CCN Message On VES
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ${target_VES_CCN_feedback}    Filter VES VsCmOperationFeedbackNotification CCN
    ...    ${VES_CCN_msgs}    ${Primary_SN}    provision    completed
    Log    ${target_VES_CCN_feedback}
    Should Be Equal As Integers	   ${target_VES_CCN_feedback.__len__()}    ${1} 
    ${Param_Req_Dic}    Create Dictionary    swResetLevel=${Type}
    ${Param_Res_Dic}    Create Dictionary    	swResetResult=success
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
    ...    ${VES_CCN_msgs}    MRBTS-${BTS_ID}/MNL-1/CMD-1/SWRESETREQ-1   ${Primary_SN}    ${MPLANE_IP}    add    ${Param_Req_Dic}
    log    ${target_VES_CCN_msg}
    should be true    "${target_VES_CCN_msg.__len__()}">="${1}"
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
    ...    ${VES_CCN_msgs}    MRBTS-${BTS_ID}/MNL-1/CMD-1/SWRESETREQ-1/SWRESETRES-1   ${Primary_SN}    ${MPLANE_IP}    replace    ${Param_Res_Dic}
    log    ${target_VES_CCN_msg}
    should be true    "${target_VES_CCN_msg.__len__()}">="${1}"
    # Below for real ONAP
#    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages
#    ...    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['ves_collector_5g']}    ${LogFile}
#    ${target_VES_CCN_feedback}    Filter VES VsCmOperationFeedbackNotification CCN
#    ...    ${VES_CCN_msgs}    ${Primary_SN}    provision    completed
#    Log    ${target_VES_CCN_feedback}
#    Should Be Equal As Integers	   ${target_VES_CCN_feedback.__len__()}    ${1} 
#
#    ${Param_Req_Dic}    Create Dictionary    swResetLevel=${Type}
#    ${Param_Res_Dic}    Create Dictionary    	swResetResult=success
#    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
#    ...    ${VES_CCN_msgs}    MRBTS-${BTS_ID}/MNL-1/CMD-1/SWRESETREQ-1   ${Primary_SN}    ${MPLANE_IP}    add    ${Param_Req_Dic}
#    log    ${target_VES_CCN_msg}
#    should be true    "${target_VES_CCN_msg.__len__()}">="${1}"
#    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
#    ...    ${VES_CCN_msgs}    MRBTS-${BTS_ID}/MNL-1/CMD-1/SWRESETREQ-1/SWRESETRES-1   ${Primary_SN}    ${MPLANE_IP}    replace    ${Param_Res_Dic}
#    log    ${target_VES_CCN_msg}
#    should be true    "${target_VES_CCN_msg.__len__()}">="${1}"

TC SetUp
    Log To Console    TC SetUp
    Common Test Setup
    ${BTS_ID}    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${BTS_ID}
    ${NRBTS_ID}    Fetch NRBTS ID
    Set Test Variable    ${NRBTS_ID}

    ${Primary_SN}    Set Variable
    ${bts_info}    coam.Get Bts Info
    ${smod_info_list}=    Get From Dictionary    ${bts_info}    systemModules
    FOR    ${smod}    IN    @{smod_info_list}
        ${sn}    Get From Dictionary    ${smod}    serialNumber
        ${id}    Get From Dictionary    ${smod}    id
        ${config_DN}    Get From Dictionary    ${id}    configuration
        ${mode_name}    Fetch From Right    ${config_DN}    /
        ${Primary_SN}    Set Variable If  "${mode_name}"=="SMOD-1"    ${sn}    ${Primary_SN}
        Exit For Loop If    "${mode_name}"=="SMOD-1"
    END
    Set Test Variable    ${Primary_SN}
#    Set Test Variable    ${host_ip}    ${ONAP["host_ip"]}
#    Set Test Variable    ${user}    ${ONAP["user"]}
#    Set Test Variable    ${pwd}    ${ONAP["pwd"]}
#    ${ONAP_INFOR}    Get Informations From ONAP    ${host_ip}    ${user}    ${pwd}
#    Set Test Variable      ${ONAP_INFOR}
#    run keyword if    ${Integrate_Need}    Integrate SBTS To ONAP    ${BTS_ID}    ${host_ip}    ${user}    ${pwd}
    Comment    Run Keyword If    ${Integrate_Need}    Integrate SBTS To ONAP Simulator    ${BTS_ID}    ${ONAP['host_ip']}

TC TearDown
    Log To Console    TC TearDown
    Run Keyword If    ${needRecovery}    Delete CMD Via Admin
    Common Test Teardown