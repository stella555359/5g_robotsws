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
SyVe_CM_CB007010-B_007_STATE_HW_RMOD_Reset_Request_To_SBTS_Via_HWRESETREQ_From_SMO
        [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   For case:TA_RAN_ST_CB007010-B_B2_006_CM_STATE_HW RMOD reset request to SBTS via HWRESETREQ object from SMO
    ...  The main steps performed for the test are:
    ...  - Setup Relationship Between RMOD And Cells
    ...  - Select One RMOD Randomly
    ...  - Provision Delta Plan On NetConf
    ...  - Check RMOD And Cells Action On SBTS
    ...  - Check Feedback and CCN Message On VES
    ...  Pass criteria: Provision delta plan from NetConf,and check parameter value on NetAct and CCN on ONAP.
    ...  Site is OK with no any unexpected alarm.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 10.09.2023 - New case

    Set Tags    CA-CM    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com    API
    LOG    ${TEST_NAME} of ${SUITE_NAME} start.    console=${True}
    Step 1: Setup Relationship Between RMOD And Cells
    Step 2: Select One RMOD Randomly
    Step 3: Provision Delta Plan On NetConf
    Step 4: Check RMOD And Cells Action On SBTS
    Step 5: Check Feedback and CCN Message On VES

Step ${index}: Setup Relationship Between RMOD And Cells
    Log To Console    Step ${index}:Setup Relationship Between RMOD And Cells
    Get Cell IDs for All RAT
    ${btsInfo}    coam.Get Bts Info
    Set Test Variable    ${rmod_list}     ${btsInfo['radioModules']['rmod']}
    log    ${rmod_list}
    ${rmods_cells_mapping}    Get Relationship Between RMODs And Cells
    Set Test Variable    ${rmods_cells_mapping}

Step ${index}: Select One RMOD Randomly
    Log To Console    Step ${index}: Select One RMOD Randomly
    ${count}    Get Length    ${rmod_list}
    ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    ${RMOD_TO_OPER_CONFIG}    Set Variable    ${rmod_list[${index}]['id']['configuration']}
    ${RMOD_TO_OPER_INTERNAL}    Set Variable    ${rmod_list[${index}]['id']['internal']}
    Set Test Variable    ${RMOD_TO_OPER_CONFIG}
    Set Test Variable    ${RMOD_TO_OPER_INTERNAL}
    Set Test Variable    ${expect_disabled_cell_dic}    ${rmods_cells_mapping['${RMOD_TO_OPER_INTERNAL}']}
    ${online_GNCEL_ids}    Copy List    ${GSM_cell_ids}
    ${online_WNCEL_ids}    Copy List    ${WCDMA_cell_ids}
    ${online_LNCEL_ids}    Copy List    ${LTE_cell_ids}
    ${online_NRCEL_ids}    Copy List    ${NR_cell_ids}
    Set Test Variable     ${online_GNCEL_ids}
    Set Test Variable     ${online_WNCEL_ids}
    Set Test Variable     ${online_LNCEL_ids}
    Set Test Variable     ${online_NRCEL_ids}
    Log To Console    "Reset RMOD:"${RMOD_TO_OPER_CONFIG}
    ${RMOD_TO_OPER_ONAP}    Set Variable    SubNetwork=${BTS_ID},ManagedElement=MRBTS-${BTS_ID}
    ${tmp}    Remove String    ${RMOD_TO_OPER_CONFIG}    MRBTS-${BTS_ID}/
    ${tmp_list}    Split String    ${tmp}    /
    FOR    ${item}    IN    @{tmp_list}
        ${item_list}    Split String    ${item}    -
        ${RMOD_TO_OPER_ONAP}    Set Variable    ${RMOD_TO_OPER_ONAP},${item_list[0]}=${item_list[1]}
    END
    Set Test Variable    ${RMOD_TO_OPER_ONAP}
    Log To Console    "Reset RMOD On ONAP:"${RMOD_TO_OPER_ONAP}

Step ${index}: Provision Delta Plan On NetConf
    Log To Console    Step ${index}: Provision Delta Plan On NetConf
    ${time}    Get Time    epoch
    ${fileName_init}    Set Variable    onap_rmod_${time}.xml    #${Test Results Dir}
    ${fileName_updated}    Set Variable    onap_rmod_${time}_updated.xml
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
	Generate RMOD Delta Plan For NetConf    ${Test Results Dir}/${fileName_init}    ${Test Results Dir}/${fileName_updated}    ${RMOD_TO_OPER_ONAP}
	Put File From Local To Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    /tmp/${fileName_updated}    ${Test Results Dir}/${fileName_updated}
	Start VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
	${output}    Execute NetConf Command On ONAP Simulator    MRBTS-${BTS_ID}  ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
	...    ${cmd_editConfig}
	Should Contain    ${output}    \r\nOK\r\n
	Set Test Variable    ${needRecovery}    True

    #below are used for real ONAP
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

Step ${index}: Check RMOD And Cells Action On SBTS
    Log To Console    Step ${index}:Check RMOD And Cells Action On SBTS
    Wait Until Keyword Succeeds    3min    5s    coam.Assert    RMOD    ${RMOD_TO_OPER_INTERNAL}    operationalState=${_Disabled_}
    Wait Until Keyword Succeeds    15min    5s    Check All Cells Status As Expected
    Wait Until Keyword Succeeds    15min    15s    coam.Assert    RMOD    ${RMOD_TO_OPER_INTERNAL}    operationalState=${_Enabled_}
    Wait Until Keyword Succeeds    20min    30s    Check SBTS SMOD RMOD Cells Alarms
    ${Param_Res_Dic}    Create Dictionary    	hwResetResult=success
    Wait Until Keyword Succeeds    3x    15s    Check WebEM After Modify Parameters
    ...    MRBTS-${BTS_ID}/MNL-1/CMD-1/HWRESETREQ-1/HWRESETRES-1    configurationAndRuntimeObjects    &{Param_Res_Dic}

Check All Cells Status As Expected
    Log To Console    Check All Cells Status As Expected
    ${disabled_gncel_list}    Set Variable    ${expect_disabled_cell_dic['activeGsmCellsList']}
    ${disabled_wncel_list}    Set Variable    ${expect_disabled_cell_dic['activeWcdmaCellsList']}
    ${disabled_lncel_list}    Set Variable    ${expect_disabled_cell_dic['activeLteCellsList']}
    ${disabled_nrcel_list}    Set Variable    ${expect_disabled_cell_dic['activeNrCellsList']}
    Check RMOD Related Cell Status As Expected    GNCEL    ${disabled_gncel_list}    ${cells_GSM_offline_state}
    Check RMOD Related Cell Status As Expected    WNCEL    ${disabled_wncel_list}    ${cells_WCDMA_offline_state}
    Check RMOD Related Cell Status As Expected    LNCEL    ${disabled_lncel_list}    ${cells_LTE_offline_state}
    Check RMOD Related Cell Status As Expected    NRCEL    ${disabled_nrcel_list}    ${cells_NR_offline_state}
    Check Online Cell Status As Expected    GNCEL    ${online_GNCEL_ids}    ${cells_GSM_expected_state}
    Check Online Cell Status As Expected    WNCEL    ${online_WNCEL_ids}    ${cells_WCDMA_expected_state}
    Check Online Cell Status As Expected    LNCEL    ${online_LNCEL_ids}    ${cells_LTE_expected_state}
    Check Online Cell Status As Expected    NRCEL    ${online_NRCEL_ids}    ${cells_NR_expected_state}

Check RMOD Related Cell Status As Expected
    [Arguments]     ${tech_cell}    ${cell_id_list}    ${expected_status}
    FOR    ${cell_id}    IN    @{cell_id_list}
        Remove Values From List    ${online_${tech_cell}_ids}    ${cell_id}
        coam.Assert    ${tech_cell}    ${cell_id}    ${expected_status}    timeout=15s
    END

Check Online Cell Status As Expected
    [Arguments]     ${tech_cell}    ${cell_id_list}    ${expected_status}
    FOR    ${cell_id}    IN    @{cell_id_list}
        ${dic_cell_state}    coam.Assert    ${tech_cell}    ${cell_id}    ${expected_status}
    END

Step ${index}: Check Feedback and CCN Message On VES
    Log To Console    Step ${index}: Check Feedback and CCN Message On VES
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ${target_VES_CCN_feedback}    Filter VES VsCmOperationFeedbackNotification CCN
    ...    ${VES_CCN_msgs}    ${Primary_SN}    provision    completed
    Log    ${target_VES_CCN_feedback}
    Should Be Equal As Integers	   ${target_VES_CCN_feedback.__len__()}    ${1}

    ${Param_Req_Dic}    Create Dictionary    targetHwResetUDN=${RMOD_TO_OPER_ONAP}
    ${Param_Res_Dic}    Create Dictionary    	hwResetResult=success
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
    ...    ${VES_CCN_msgs}    MRBTS-${BTS_ID}/MNL-1/CMD-1/HWRESETREQ-1   ${Primary_SN}    ${MPLANE_IP}    add    ${Param_Req_Dic}
    log    ${target_VES_CCN_msg}
    should be true    "${target_VES_CCN_msg.__len__()}">="${1}"
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
    ...    ${VES_CCN_msgs}    MRBTS-${BTS_ID}/MNL-1/CMD-1/HWRESETREQ-1/HWRESETRES-1   ${Primary_SN}    ${MPLANE_IP}    replace    ${Param_Res_Dic}
    log    ${target_VES_CCN_msg}
    should be true    "${target_VES_CCN_msg.__len__()}">="${1}"

    # Below for real ONAP
#    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages
#    ...    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['ves_collector_5g']}    ${LogFile}
#    ${target_VES_CCN_feedback}    Filter VES VsCmOperationFeedbackNotification CCN
#    ...    ${VES_CCN_msgs}    ${Primary_SN}    provision    completed
#    Log    ${target_VES_CCN_feedback}
#    Should Be Equal As Integers	   ${target_VES_CCN_feedback.__len__()}    ${1} 
#    ${Param_Req_Dic}    Create Dictionary    targetHwResetUDN=${RMOD_TO_OPER_ONAP}
#    ${Param_Res_Dic}    Create Dictionary    	hwResetResult=success
#    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
#    ...    ${VES_CCN_msgs}    MRBTS-${BTS_ID}/MNL-1/CMD-1/HWRESETREQ-1   ${Primary_SN}    ${MPLANE_IP}    add    ${Param_Req_Dic}
#    log    ${target_VES_CCN_msg}
#    should be true    "${target_VES_CCN_msg.__len__()}">="${1}"
#    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
#    ...    ${VES_CCN_msgs}    MRBTS-${BTS_ID}/MNL-1/CMD-1/HWRESETREQ-1/HWRESETRES-1   ${Primary_SN}    ${MPLANE_IP}    replace    ${Param_Res_Dic}
#    log    ${target_VES_CCN_msg}
#    should be true    "${target_VES_CCN_msg.__len__()}">="${1}"


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

Generate RMOD Delta Plan For NetConf
    [Arguments]    ${source_file}    ${target_file}    ${rmod_dn}
	Log To Console    Generate RMOD Delta Plan For NetConf
    ${file_content}    OperatingSystem.Get File    ${source_file}
    ${file_content}    Remove String    ${file_content}    <data xmlns="urn:ietf:params:xml:ns:netconf:base:1.0">
    ${file_content}    Remove String    ${file_content}    </data>
    ${scf_xml}    L_XML.Parse xml    ${file_content}
    L_XML.Remove Elements    source=${scf_xml}    xpath=//attributes    remove_tail=True
    L_XML.Add Element    ${scf_xml}    <CMD/>    xpath=//MNL
    L_XML.Add Element    ${scf_xml}    <id>1</id>    xpath=//CMD
    L_XML.Add Element    ${scf_xml}    <HWRESETREQ/>    xpath=//CMD
    L_XML.Add Element    ${scf_xml}    <id>1</id>    xpath=//HWRESETREQ
    L_XML.Add Element    ${scf_xml}    <attributes/>    xpath=//HWRESETREQ
    L_XML.Add Element    ${scf_xml}    <targetHwResetUDN>${rmod_dn}</targetHwResetUDN>    xpath=//HWRESETREQ/attributes
    L_XML.Save Xml    ${scf_xml}    ${target_file}
    ${file_content}    OperatingSystem.Get File    ${target_file}
    ${file_content}    Replace String    ${file_content}    \&\#13;    ${EMPTY}

    ${parsed_xml}    XML.Parse XML    ${file_content}
    XML.Set Element Attribute    ${parsed_xml}    xmlns:nc    urn:ietf:params:xml:ns:netconf:base:1.0    .
    XML.Set Elements Attribute    ${parsed_xml}    nc:operation    create    .//CMD
    XML.Set Elements Attribute    ${parsed_xml}    nc:operation    create    .//HWRESETREQ
    XML.Save Xml    ${parsed_xml}    ${target_file}
    Sleep    10s    time for file creation

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
    # Below for real ONAP
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