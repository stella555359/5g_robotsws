*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
...   Description: This robot cases is for RAN_ST_CB006092-B_016_CM_Creation and Deletion of managed object for vDU
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
${RECOVERY_FLAG}    ${False}

*** Keywords ***
VRAN_SyVe_CM_CB006092-B_016_Creation_And_Deletion_Of_Managed_Object_In_vDU
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    25.06.2025, yuyan.xu@nokia-sbell.com
    Step 1: Prepare ONAP SCF Files
    Step 2: Remove Cell Via Netconf
    Step 3: Check CCN And Cell Deleted
    Step 4: Create Cell Via Netconf
    Step 5: Check CCN And Cell Created

Step ${index}: Prepare ONAP SCF Files
    Log To Console    Step ${index}: Prepare ONAP SCF Files
    Get Origin Variables From SBTS
    ${time}    Get Time    epoch
    Set Test Variable    ${onap_scf_remove}    CB006092-B_016_remove_NRCELL_${time}.xml
    Set Test Variable    ${onap_scf_create}    CB006092-B_016_create_NRCELL_${time}.xml
    Set Test Variable    ${onap_scf_afterremove}    CB006092-B_016_after_remove_NRCELL_${time}.xml

    ${onap_path}    Transfer SCF DN To Xpath Of ONAP Get Result    ${DN_NRDU}
    ${onap_nrdu_filter_str}    Set Variable    ${onap_path}/attributes/refNrCellGroup/refNrCellGroup[text()="${NRCELL_ID}"]
    ${cmd_get_config_head}    Set Variable    get-config --source running --filter-xpath
    ${onap_remove_filter_str}    ${onap_create_filter_str}    Generate Filter Strings For Create And Remove MOs    ${LIST_DN_TO_REMOVE}
    ${cmd_get_config}    Set Variable    ${cmd_get_config_head} ${onap_remove_filter_str}|${onap_nrdu_filter_str} --out=/tmp/${onap_scf_remove}
    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd_get_config}
    ${cmd_get_config}    Set Variable    ${cmd_get_config_head} ${onap_create_filter_str}|${onap_nrdu_filter_str} --out=/tmp/${onap_scf_create}
    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd_get_config}
    #Get Files From ONAP Simulator
    ${onap_get_file_remove}    Set Variable   ${TEST_LOG_DIRECTORY}/${onap_scf_remove}
    ${onap_get_file_create}    Set Variable   ${TEST_LOG_DIRECTORY}/${onap_scf_create}
    Get File From Simulator To Local    ${host_ip}    ${user}    ${pwd}    ${onap_scf_remove}    ${onap_get_file_remove}
    Get File From Simulator To Local    ${host_ip}    ${user}    ${pwd}    ${onap_scf_create}    ${onap_get_file_create}
    Modify ONAP SCF Files
    #Put Files To ONAP Simulator
    Put File From Local To Simulator    ${host_ip}    ${user}    ${pwd}    /tmp/new_${onap_scf_remove}    ${TEST_LOG_DIRECTORY}/new_${onap_scf_remove}
    Put File From Local To Simulator    ${host_ip}    ${user}    ${pwd}    /tmp/new_${onap_scf_create}    ${TEST_LOG_DIRECTORY}/new_${onap_scf_create}

Modify ONAP SCF Files
    ${parsed_xml}    XML.Parse XML    ${TEST_LOG_DIRECTORY}/${onap_scf_remove}
    ${e_onap}    XML.Get Element    ${parsed_xml}    ManagedElement
    Modify ONAP Plan Create Or Delete MOs    ${e_onap}    ${LIST_DN_TO_REMOVE}    delete
    ${scf_dn}    Set Variable    ${DN_NRDU}
    ${dic_param}    Create Dictionary    refNrCellGroup[1]    ${EMPTY}
    Modify ONAP Plan Parameters Of MO    ${scf_dn}    ${dic_param}    ${e_onap}    delete
    XML.Save XML    ${e_onap}    ${TEST_LOG_DIRECTORY}/new_${onap_scf_remove}
    ${parsed_xml}    XML.Parse XML    ${TEST_LOG_DIRECTORY}/${onap_scf_create}
    ${e_onap}    XML.Get Element    ${parsed_xml}    ManagedElement
    Modify ONAP Plan Create Or Delete MOs    ${e_onap}    ${LIST_DN_TO_REMOVE}    create
    ${simpleId}    Evaluate    ${cell_count}-1
    ${simpleId}    Convert To String    ${simpleId}
    ${dic_param}    Create Dictionary    refNrCellGroup[1].simpleId    [${simpleId}]
    Modify ONAP Plan Parameters Of MO    ${scf_dn}    ${dic_param}    ${e_onap}
    ${dic_param}    Create Dictionary    refNrCellGroup[1].refNrCellGroup    ${EMPTY}
    Modify ONAP Plan Parameters Of MO    ${scf_dn}    ${dic_param}    ${e_onap}    create
    XML.Save XML    ${e_onap}    ${TEST_LOG_DIRECTORY}/new_${onap_scf_create}

Get Origin Variables From SBTS
    vDU Login By Rest
    ${cells_list}    vdu.get_vdu_cell_id
    ${cell_count}    Get Length    ${cells_list}
    Set Test Variable    ${cell_count}
    ${selected_cell_dic}    Evaluate    random.choice(${cells_list})    modules=random, sys
    ${keys}    Get Dictionary Keys    ${selected_cell_dic}
    Set Test Variable    ${selected_cell}    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${keys[0]}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    ${val_vesCMFeedbackNotificationInt}    L_XML.Get Element Text    ${scf_xml}
    ...    .//managedObject[@class="com.nokia.srbts.mnl:MPLANEONAP"]/p[@name="vesCMFeedbackNotificationInt"]
    Should Not Be Equal As Integers    ${val_vesCMFeedbackNotificationInt}    0    Must set feedback CCN on.
    ${selected_cell_lcrid}    L_XML.Get Element Text    ${scf_xml}    .//managedObject[@distName="${selected_cell}"]/p[@name="lcrId"]
    ${cell_cellmapping_str}    catenate    SEPARATOR=    LCELNR-    ${selected_cell_lcrid}
    ${dn_cellMapping}    L_XML.Get Element Attribute    ${scf_xml}
    ...    distName    .//managedObject[@class="com.nokia.srbts.mnl:LCELNR" and contains(@distName,"${cell_cellmapping_str}")]
    ${dn_nr_cell_group}    L_XML.Get Element Attribute    ${scf_xml}    distName
    ...    .//managedObject[@class="com.nokia.srbts.nrbts:NRCELLGRP"]/list[@name="nrCellList"]/p[text()="${selected_cell_lcrid}"]/../..
    ${DN_NRDU}    L_XML.Get Element Attribute    ${scf_xml}    distName    .//managedObject[@class="com.nokia.srbts.nrbts:NRDU"]
    ${CELL_DN_TO_DELETED}    Set Variable    ${selected_cell}
    ${CELL_MAPPING_DN_TO_DELETED}    Set Variable    ${dn_cellMapping}
    ${NR_CELLGROUP_DN}    Set Variable    ${dn_nr_cell_group}
    ${LIST_DN_TO_REMOVE}    Create List    ${CELL_DN_TO_DELETED}    ${CELL_MAPPING_DN_TO_DELETED}    ${NR_CELLGROUP_DN}
    Set Test Variable    ${NR_CELLGROUP_DN}
    Set Test Variable    ${CELL_DN_TO_DELETED}
    Set Test Variable    ${CELL_MAPPING_DN_TO_DELETED}
    Set Test Variable    ${LIST_DN_TO_REMOVE}
    Set Test Variable    ${DN_NRDU}
    Set Test Variable    ${NRCELL_ID}    ${selected_cell_lcrid}

Step ${index}: Remove Cell Via Netconf
    Log To Console    Step ${index}: Remove Cell Via Netconf
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    ${cmd_edit_config}    Catenate    edit-config --target running --config=/tmp/new_${onap_scf_remove} --test test-then-set
    ...    --error rollback --rpc-timeout 300s
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd_edit_config}
    ${str_ok}    Get Lines Matching Pattern    ${ret}    OK    case_insensitive=True
    Should Be Equal As Strings    ${str_ok.strip()}    OK    ignore_case=True
    Set Test Variable    ${RECOVERY_FLAG}    ${True}
    #Append To List    ${UNEXPECTED_ALARMS}    ${UNEXPECTED_ALARM}
    vDU Login By Rest
    Wait Until Keyword Succeeds    10min    10s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Sleep    30s

Step ${index}: Check CCN And Cell Deleted
    Log To Console    Step ${index}: Check CCN And Cell Deleted
    #check cell deleted on webem
    vDU Login By Rest
    ${cells_list}    vdu.get_vdu_cell_id
    ${current_cells_list}    Create List
    FOR    ${cell}    IN    @{cells_list}
        ${keys}   Get Dictionary Keys    ${cell}
        Append To List    ${current_cells_list}    ${keys[0]}
    END
    List Should Not Contain Value    ${current_cells_list}    ${selected_cell.split("/")[-1]}
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}

    #need update below kw
    ${target_VES_CCN_msg}    Filter VES VsCmOperationFeedbackNotification CCN    ${VES_CCN_msgs}    vDu    ${vesSourceName}    provision    completed
    Log    ${target_VES_CCN_msg}
    Should Be True    "${target_VES_CCN_msg.__len__()}">="${1}"
    #Updated 2025-09-26: add checkpoint get nrcell is empty from onap which be deleted, as some remove CCN message will missing.
    ${cmd_get_config_head}    Set Variable    get-config --source running --filter-xpath
    ${cmd_get_config}    Set Variable
    ...   ${cmd_get_config_head} ManagedElement/NRBTS/id[text()="${NRBTS_ID}"]/../NRCELL/id[text()="${NRCELL_ID}"] --out=/tmp/${onap_scf_afterremove}
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd_get_config}
    ${onap_get_file_afterremove}    Set Variable   ${TEST_LOG_DIRECTORY}/${onap_scf_afterremove}
    Get File From Simulator To Local    ${host_ip}    ${user}    ${pwd}    ${onap_scf_afterremove}    ${onap_get_file_afterremove}
    ${parsed_xml}    XML.Parse XML    ${TEST_LOG_DIRECTORY}/${onap_scf_afterremove}
    ${e_count}    XML.Get Element Count    ${parsed_xml}    ManagedElement
    Should Be Equal As Integers    ${e_count}    ${0}    Check cell is deleted on netconf failed.
#   ${dic_param_value}    Create Dictionary
#   FOR    ${dn}    IN    @{LIST_DN_TO_REMOVE}
#       ${count}    Get Actual Configuration MO Count    PLMN-PLMN/${dn}
#       Should Be Equal As Integers    ${count}    ${0}
#       ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
#       ...    ${VES_CCN_msgs}    ${dn}    vDu    ${vesSourceName}    ${dnPrefix}    ${du_ip}    remove    ${dic_param_value}
#       log    ${target_VES_CCN_msg}
#       Should Not Be Empty    ${target_VES_CCN_msg}
#   END

Get Actual Configuration MO Count
    [Arguments]    ${dist_name}
    Log    Get Actual Configuration MO Count    console=True
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${status}=    Run Keyword And Return Status    netact.Export Configuration    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs
    ...    file_name=check_netact_plan_delete_MOC.xml    dist_names=${dist_name}    ui_values=false
    ${scf_xml}=    L_XML.Parse Xml    ${TEST_LOG_DIRECTORY}/NetActLogs/check_netact_plan_delete_MOC.xml
    ${object}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@distName="${dist_name}"]
    ${obj_count}    Get Length    ${object}
    [Return]    ${obj_count}


Step ${index}: Create Cell Via Netconf
    Log To Console    Step ${index}: Create Cell Via Netconf
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    ${cmd_edit_config}    Catenate    edit-config --target running --config=/tmp/new_${onap_scf_create} --test test-then-set
    ...    --error rollback --rpc-timeout 300s
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd_edit_config}
    ${str_ok}    Get Lines Matching Pattern    ${ret}    OK    case_insensitive=True
    Should Be Equal As Strings    ${str_ok.strip()}    OK    ignore_case=True
    Set Test Variable    ${RECOVERY_FLAG}    ${False}
    vDU Login By Rest
    Wait Until Keyword Succeeds    10min    10s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Sleep    30s

Step ${index}: Check CCN And Cell Created
    Log    Step ${index}: Check CCN And Cell Created    console=True
    #check cell deleted on webem
    vDU Login By Rest
    ${cells_list}    vdu.get_vdu_cell_id
    ${current_cells_list}    Create List
    FOR    ${cell}    IN    @{cells_list}
        ${keys}   Get Dictionary Keys    ${cell}
        Append To List    ${current_cells_list}    ${keys[0]}
    END
    List Should Contain Value    ${current_cells_list}    ${selected_cell.split("/")[-1]}
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    #need update below kw
    ${target_VES_CCN_msg}    Filter VES VsCmOperationFeedbackNotification CCN    ${VES_CCN_msgs}    vDu    ${vesSourceName}    provision    completed
    Log    ${target_VES_CCN_msg}
    Should Be True    "${target_VES_CCN_msg.__len__()}">="${1}"

    ${dic_param_value}    Create Dictionary
    ${count}    Get Actual Configuration MO Count    PLMN-PLMN/${CELL_MAPPING_DN_TO_DELETED}
    Should Be Equal As Integers    ${count}    ${1}
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
    ...    ${VES_CCN_msgs}    ${CELL_MAPPING_DN_TO_DELETED}    vDu    ${vesSourceName}    ${dnPrefix}    ${du_ip}    add    ${dic_param_value}
    Should Not Be Empty    ${target_VES_CCN_msg}
    ${count}    Get Actual Configuration MO Count    PLMN-PLMN/${CELL_DN_TO_DELETED}
    Should Be Equal As Integers    ${count}    ${1}
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
    ...    ${VES_CCN_msgs}    ${CELL_DN_TO_DELETED}    vDu    ${vesSourceName}    ${dnPrefix}    ${du_ip}    replace    ${dic_param_value}
    Should Not Be Empty    ${target_VES_CCN_msg}


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
    ${vesSourceName}    Get Parameter Value From vDU     MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1    vesSourceName
    Set Test Variable    ${vesSourceName}
    ${dnPrefix}    Get Parameter Value From vDU     MRBTS-${vDU_id}    dnPrefix
    Set Test Variable    ${dnPrefix}
    #${UNEXPECTED_ALARM}    Create Dictionary    alarmId=${7115}    faultId=${4639}
    #Set Test Variable    ${UNEXPECTED_ALARM}

Case Postcondition
    Log To Console    Case Postcondition
    ${out}   Run Keyword If    ${RECOVERY_FLAG}
    ...    Parameter Operation    operation=full_commission    product_type=vdu    scf_path=${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    Wait Until Keyword Succeeds    20min    30s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    #Remove Values From List    ${UNEXPECTED_ALARMS}    ${UNEXPECTED_ALARM}
    Common Test Teardown For AIC
    Teardown NetAct