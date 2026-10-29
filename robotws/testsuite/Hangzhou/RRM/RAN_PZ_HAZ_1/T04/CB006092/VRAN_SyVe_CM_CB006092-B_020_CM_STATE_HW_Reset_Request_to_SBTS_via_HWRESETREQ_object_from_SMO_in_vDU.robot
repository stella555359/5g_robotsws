*** Settings ***
Documentation
...   Author: lixin.kang@nokia-sbell.com
...   Description: This robot cases is for RAN_ST_CB006092-B_020_CM_STATE_HW reset request to SBTS via HWRESETREQ object from SMO in vDU
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
${RECOVERY_FLAG}    ${False}
${du_oamssh_ip}    ${tl.gnbs[0].dus[0].oam_http_connection_details.addr}

*** Keywords ***
VRAN_SyVe_CM_CB006092-B_020_CM_STATE_HW_Reset_Request_to_SBTS_via_HWRESETREQ_object_from_SMO_in_vDU
    [Documentation]
    ...    Author: lixin.kang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    04.07.2025, lixin.kang@nokia-sbell.com
    Step 1: Setup Relationship Between RMOD And Cells
    Step 2: Select One RMOD Randomly
    Step 3: Provision Delta Plan On NetConf
    Step 4: Check RMOD And Cells Action
    Step 5: Check Feedback and CCN Message On VES

Step ${index}: Setup Relationship Between RMOD And Cells
    Log To Console    Step ${index}:Setup Relationship Between RMOD And Cells
    ${cell_info}    vdu.get_vdu_cells_status
    ${cells_dn_list}    Create List
    FOR    ${cell}    IN    @{cells_dn_list}
        Append To List    ${cells_dn_list}    ${cell["dist_names"]["config"]}
    END
    Set Test Variable    ${cells_dn_list}
    ${rmods_info}   vdu.get_rmods_status
    Set Test Variable    ${rmods_info}
    ${rmods_cells_mapping}    Get Relationship Between RMODs And Cells
    Set Test Variable    ${rmods_cells_mapping}

Step ${index}: Select One RMOD Randomly
    Log To Console    Step ${index}: Select One RMOD Randomly
    ${count}    Get Length    ${rmods_info}
    ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    ${RMOD_TO_OPER_CONFIG}    Set Variable    ${rmods_info[${index}]['dist_names']['config']}
    Set Test Variable    ${RMOD_TO_OPER_CONFIG}
    Set Test Variable    ${expect_disabled_cell_dic}    ${rmods_cells_mapping['${RMOD_TO_OPER_CONFIG}']}
    Log To Console    "Reset RMOD:"${RMOD_TO_OPER_CONFIG}
    ${RMOD_TO_OPER_ONAP}    Set Variable    ${dnPrefix},ManagedElement=MRBTS-${vDU_id}
    ${tmp}    Remove String    ${RMOD_TO_OPER_CONFIG}    MRBTS-${vDU_id}/
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
    ${fileName_init}    Set Variable    onap_rmod_${time}.xml
    ${fileName_updated}    Set Variable    onap_rmod_${time}_updated.xml
    Run Keyword And Ignore Error    Delete CMD Via Admin
    ${cmd_getConfig}    Set Variable
    ...    get-config --source running --filter-xpath ManagedElement/MNL/id[text()="1"] --out=/tmp/${fileName_init}
    ${cmd_editConfig}    Set Variable
    ...    edit-config --target running --config=/tmp/${fileName_updated} --test test-then-set --error rollback --rpc-timeout 160s
    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${cmd_getConfig}
    Get File From Simulator To Local    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    /tmp/${fileName_init}    ${TEST_LOG_DIRECTORY}/${fileName_init}
	Generate RMOD Delta Plan For NetConf    ${TEST_LOG_DIRECTORY}/${fileName_init}    ${TEST_LOG_DIRECTORY}/${fileName_updated}
	...    ${RMOD_TO_OPER_ONAP}
	Put File From Local To Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    /tmp/${fileName_updated}    ${TEST_LOG_DIRECTORY}/${fileName_updated}
	Start VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
	${output}    Execute NetConf Command On ONAP Simulator
	...    MRBTS-${vDU_id}    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${cmd_editConfig}
	Should Contain    ${output}    \r\nOK\r\n
	Set Test Variable    ${needRecovery}    True

Step ${index}: Check RMOD And Cells Action
    Log To Console    Step ${index}:Check RMOD And Cells Action On SBTS
    Check All RMOD Status As Expected
    Check All Cells Status As Expected
    Wait Until Keyword Succeeds    10m    30s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    @{para_list}    Create List    hwResetResult
    @{value_list}    Create List     success
    @{mo_list}    Create List     MRBTS-${vDU_id}/MNL-1/CMD-1/HWRESETREQ-1/HWRESETRES-1
    ${out}    Parameter Operation     operation=parameter_value_check    product_type=vdu    para_list=@{para_list}    mo_list=@{mo_list}
    Should Be Equal As Strings     ${out["${mo_list[0]}"]["${para_list[0]}"]}    success

Step ${index}: Check Feedback and CCN Message On VES
    Log To Console    Step ${index}: Check Feedback and CCN Message On VES
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ${target_VES_CCN_feedback}    Filter VES VsCmOperationFeedbackNotification CCN
    ...    ${VES_CCN_msgs}    vDU    ${vesSourceName}    provision    completed
    Log    ${target_VES_CCN_feedback}
    Should Be Equal As Integers	   ${target_VES_CCN_feedback.__len__()}    ${1}
    ${Param_Req_Dic}    Create Dictionary    targetHwResetUDN=${RMOD_TO_OPER_ONAP}
    ${Param_Res_Dic}    Create Dictionary    	hwResetResult=success
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
    ...    ${VES_CCN_msgs}    MRBTS-${vDU_id}/MNL-1/CMD-1/HWRESETREQ-1    vDu    ${vesSourceName}
    ...    ${dnPrefix}    ${du_oamssh_ip}    add    ${Param_Req_Dic}
    Log    ${target_VES_CCN_msg}
    Should Be True    "${target_VES_CCN_msg.__len__()}">="${1}"
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
    ...    ${VES_CCN_msgs}    MRBTS-${vDU_id}/MNL-1/CMD-1/HWRESETREQ-1/HWRESETRES-1    vDu    ${vesSourceName}
    ...    ${dnPrefix}    ${du_oamssh_ip}    add    ${Param_Res_Dic}
    Log    ${target_VES_CCN_msg}
    Should Be True    "${target_VES_CCN_msg.__len__()}">="${1}"

Get Relationship Between RMODs And Cells
    FOR    ${rmod}    IN    @{rmods_info}
        ${status}    ${radioMasterDN}    Run Keyword And Ignore Error    Get Parameter Value From vDU
        ...    ${rmod["dist_names"]["config"]}     radioMasterDN
        ${is_rfsharing_slave}    Run Keyword And Return Status    Should Contain    ${radioMasterDN}    MRBTS-${vDU_id}/EQM-1/SMOD_EXT-
        Run Keyword If    ${is_rfsharing_slave}   Remove Values From List    ${rmods_info}    ${rmod}
    END
    ${rmods_cells_mapping}    Create Dictionary
    FOR    ${rmod}    IN    @{rmods_info}
        ${cell_dic}    Get RMOD Related Cells    ${rmod["dist_names"]["runtime"]}
        Set To Dictionary    ${rmods_cells_mapping}    ${rmod["dist_names"]["config"]}    ${cell_dic}
    END
    [Return]     ${rmods_cells_mapping}

Get RMOD Related Cells
    [Arguments]    ${RMOD_MO_R}
    [Documentation]    Get 2G/3G/4G/5G cells related to one RMOD.
    ${empty_list}    Create List
    ${cell_dic}    Create Dictionary    activeNrCellsList=${empty_list}
    ${back_scf_xml}    vdu.get_current_plan_file    local_dir_path=${TEST_LOG_DIRECTORY}    filename=scf_backup.xml    include_runtime_data=${True}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${full_scf_xml}    L_XML.Parse Xml    ${back_scf_xml}
    ${cell_list_item}    L_XML.Get Elements    ${full_scf_xml}    .//managedObject[@distName="${RMOD_MO_R}"]/list
    FOR    ${item}    IN    @{cell_list_item}
        ${key}    L_XML.Get Element Attribute    ${item}    name
        ${value}     L_XML.Get Elements Texts    ${item}   p
        ${rmod_related_cells}    Fetch NRCELL List By Cellmapping ID RF   ${value}
        ${tmp_list}    Combine Lists    ${cell_dic['${key}']}    ${rmod_related_cells}
        ${tmp_list}    Remove Duplicates    ${tmp_list}
        Set To Dictionary    ${cell_dic}    ${key}    ${tmp_list}
    END
    [Return]    ${cell_dic}

Fetch NRCELL List By Cellmapping ID RF
    [Arguments]     ${cellmids}
    [Documentation]    Invoke by KW:Get RMOD Related Cells
    ${cell_list}    Create List
    FOR    ${cellmid}    IN    @{cellmids}
        ${cell_dn}    Get Cell DistName By Lcrid   ${cellmid}
        Append To List     ${cell_list}    ${cell_dn}
    END
    [Return]     ${cell_list}

Get Cell DistName By Lcrid
    [Arguments]     ${Lcrid}
    ${cell_info}    vdu.get_vdu_cells_status
    ${cells_dn_list}    Create List
    ${cell_dn}    Set Variable
    FOR    ${cell}    IN    @{cell_info}
        Append To List    ${cells_dn_list}    ${cell["dist_names"]["config"]}
    END
    FOR    ${cell}    IN    @{cells_dn_list}
        ${cell_lcrid}    Get Parameter Value From vDU    ${cell}    lcrId
        Return From Keyword If    "${cell_lcrid}"=="${Lcrid}"    ${cell}
    END
    [Return]    ${cell_dn}

Check All RMOD Status As Expected
    Log To Console    Check All RMOD Status As Expected
     ${rmods_info}    vdu.get_rmods_status
     FOR     ${rmod}    IN    @{rmods_info}
         Run Keyword If    '${rmod['dist_names']['config']}'=='${RMOD_TO_OPER_CONFIG}'
         ...    Should Be Equal As Strings    ${rmod['operational_state']}    disabled
         ...    ELSE    Should Be Equal As Strings    ${rmod['operational_state']}    enabled
     END

Check All Cells Status As Expected
    Log To Console    Check All Cells Status As Expected
    ${activeNrCellsList}    Set Variable    ${rmods_cells_mapping['${RMOD_TO_OPER_CONFIG}']['activeNrCellsList']}
    FOR    ${cell_dn}    IN    @{activeNrCellsList}
        ${cell_id}    Fetch From Right    ${cell_dn}    -
        ${administrative_state}    ${operational_state}    vDU Get Specified Cell Status    ${cell_id}
        Should Be Equal As Strings     ${operational_state}    disabled
        Should Be Equal As Strings     ${administrative_state}    unlocked
        Remove Values From List     ${cells_dn_list}    ${cell_dn}
    END

Check RMOD Related Cell Status As Expected
    [Arguments]     ${tech_cell}    ${cell_id_list}    ${expected_status}
    FOR    ${cell_id}    IN    @{cell_id_list}
        Remove Values From List    ${online_${tech_cell}_ids}    ${cell_id}
        coam.Assert    ${tech_cell}    ${cell_id}    ${expected_status}    timeout=15s
    END

Delete CMD Via Admin
      Set Test Variable    ${delta_plan}    [{"distName": "MRBTS-${vDU_id}/MNL-1/CMD-1", "operation": "delete"}]
      ${out}    vdu.Perform Delta Recommissioning     ${delta_plan}
      Should Be Equal As Strings     ${out["status"]}  success

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
    vDU Login By Rest
    ${vesSourceName}    Get Parameter Value From vDU     MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1    vesSourceName
    Set Test Variable    ${vesSourceName}
    ${dnPrefix}    Get Parameter Value From vDU     MRBTS-${vDU_id}   dnPrefix
    Set Test Variable    ${dnPrefix}

Case Postcondition
    Log To Console    Case Postcondition
    Run Keyword And Ignore Error     Delete CMD Via Admin
    Common Test Teardown For AIC
    Teardown NetAct