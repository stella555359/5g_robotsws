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
TC__SyVe_CM_CB007010_B_002_Creation_And_Deleteion_Of_NR_Cell_For_cOAM_SBTS
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing provision a random selected lncell delete and add from ONAP.
    ...    TA_RAN_ST_CB007010-B_B2_002_CM_Creation and Deleteion of LTE Cell for cOAM SBTS
    ...    The main steps performed for the test are:
    ...
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Prepare ONAP SCF Files
    ...    - Remove LNCELs Via Netconf
    ...    - Check CCN And LNCELL Deleted
    ...    - Create LNCELs Via Netconf
    ...    - Check CCN And LNCELL Created
    ...
    ...    Pass criteria: delete and add lncell provision operation works as expected; states and alarms are as expected
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 12.09.2023 - New Case
    Set Tags    AUTHOR-bin.7.liu@nokia-sbell.com    Maintainer–I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Upload configuration status
    Step 5: Prepare ONAP SCF Files
    Step 6: Remove Cell Via Netconf
    Step 7: Check CCN And Cell Deleted
    Step 8: Create Cell Via Netconf
    Step 9: Check CCN And Cell Created

Step ${index}: Check ${when} BTS state
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    5 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Check CCN And Cell Deleted
    Log    Step ${index}: Check CCN And Cell Deleted    console=True
    Wait Until Keyword Succeeds    10x    30s    Check Cell Deleted From WebEM
    Comment    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['ves_collector_5g']}    ${ves_ccn_file}
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ${target_VES_CCN_msg}    Filter VES VsCmOperationFeedbackNotification CCN    ${VES_CCN_msgs}    ${PRIMARY_CORE_DN}    provision    completed
    Log    ${target_VES_CCN_msg}
    Should Be Equal As Integers    ${target_VES_CCN_msg.__len__()}    ${1}
    ${dic_param_value}    Create Dictionary
    FOR    ${dn}    IN    @{LIST_DN_TO_REMOVE}
        ${count}    Get Actual Configuration MO Count    PLMN-PLMN/${dn}
        Should Be Equal As Integers    ${count}    ${0}
        ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN    ${VES_CCN_msgs}    ${dn}    ${PRIMARY_CORE_DN}    ${MPLANE_IP}    remove
        ...    ${dic_param_value}
        Should Not Be Empty    ${target_VES_CCN_msg}
    END

Step ${index}: Check CCN And Cell Created
    Log    Step ${index}: Check CCN And Cell Created    console=True
    Wait Until Keyword Succeeds    10x    30s    Check Cell Created From WebEM
    Set Test Variable    ${NEED_RECOVER}    ${True}
    Comment    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['ves_collector_5g']}    ${ves_ccn_file}
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ${target_VES_CCN_msg}    Filter VES VsCmOperationFeedbackNotification CCN    ${VES_CCN_msgs}    ${PRIMARY_CORE_DN}    provision    completed
    Log    ${target_VES_CCN_msg}
    Should Be Equal As Integers    ${target_VES_CCN_msg.__len__()}    ${1}
    ${dic_param_value}    Create Dictionary
    ${count}    Get Actual Configuration MO Count    PLMN-PLMN/${CELL_MAPPING_DN_TO_DELETED}
    Should Be Equal As Integers    ${count}    ${1}
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN    ${VES_CCN_msgs}    ${CELL_MAPPING_DN_TO_DELETED}    ${PRIMARY_CORE_DN}
    ...    ${MPLANE_IP}    add    ${dic_param_value}
    Should Not Be Empty    ${target_VES_CCN_msg}
    ${count}    Get Actual Configuration MO Count    PLMN-PLMN/${CELL_DN_TO_DELETED}
    Should Be Equal As Integers    ${count}    ${1}
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN    ${VES_CCN_msgs}    ${CELL_DN_TO_DELETED}    ${PRIMARY_CORE_DN}
    ...    ${MPLANE_IP}    replace    ${dic_param_value}
    Should Not Be Empty    ${target_VES_CCN_msg}

Step ${index}: Prepare ONAP SCF Files
    Log To Console    Step ${index}: Prepare ONAP SCF Files
    Get Origin Variables From SBTS
    ${onap_path}    Transfer SCF DN To Xpath Of ONAP Get Result    ${DN_NRDU}
    ${onap_nrdu_filter_str}    Set Variable    ${onap_path}/attributes/refNrCellGroup/refNrCellGroup[text()="${NRCELL_ID}"]
    ${cmd_get_config_head}    Set Variable    get-config --source running --filter-xpath
    ${onap_remove_filter_str}    ${onap_create_filter_str}    Generate Filter Strings For Create And Remove MOs    ${LIST_DN_TO_REMOVE}
    ${cmd_get_config}    Set Variable    ${cmd_get_config_head} ${onap_remove_filter_str}|${onap_nrdu_filter_str} --out=/tmp/${ONAP_SCF_REMVOE}
    Comment    Exucute One Command On Netconf CLI    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['ves_collector_5g']}    ${MPLANE_IP}    ${cmd_get_config}
    Execute NetConf Command On ONAP Simulator    MRBTS-${MRBTS_ID}  ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    ${cmd_get_config}
    ${cmd_get_config}    Set Variable    ${cmd_get_config_head} ${onap_create_filter_str}|${onap_nrdu_filter_str} --out=/tmp/${ONAP_SCF_CREATE}
    Comment    Exucute One Command On Netconf CLI    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['ves_collector_5g']}    ${MPLANE_IP}    ${cmd_get_config}
    Execute NetConf Command On ONAP Simulator    MRBTS-${MRBTS_ID}  ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    ${cmd_get_config}
    Get Files From ONAP Simulator
    Comment    Get File From Pod To Local    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['ves_collector_5g']}
    ...    /tmp/${ONAP_SCF_REMVOE}    ${BTSFiles}/${ONAP_SCF_REMVOE}
    Comment    Get File From Pod To Local    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['ves_collector_5g']}
    ...    /tmp/${ONAP_SCF_CREATE}    ${BTSFiles}/${ONAP_SCF_CREATE}
    Modify ONAP SCF Files
    Put Files To ONAP Simulator
    Comment    Put File From Local To Pod    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['ves_collector_5g']}
    ...    /tmp/new_${ONAP_SCF_REMVOE}    ${BTSFiles}/new_${ONAP_SCF_REMVOE}
    Comment    Put File From Local To Pod    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['ves_collector_5g']}
    ...    /tmp/new_${ONAP_SCF_CREATE}    ${BTSFiles}/new_${ONAP_SCF_CREATE}

Step ${index}: Remove Cell Via Netconf
    Log To Console    Step ${index}: Remove Cell Via Netconf
    Comment    ${ves_ccn_file}    Start VES Log Listen    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['ves_collector_5g']}    smod_SN=${PRIMARY_CORE_DN}
    Start VES Log Listen On ONAP Simulator    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    Set Test Variable    ${NEED_RECOVER}    ${True}
    ${cmd_get_config}    Catenate    edit-config --target running --config=/tmp/${ONAP_SCF_REMVOE} --test test-then-set
    ...    --error rollback --rpc-timeout 300s
    Comment    ${ret}    Exucute One Command On Netconf CLI    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['ves_collector_5g']}    ${MPLANE_IP}    ${cmd_get_config}
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${MRBTS_ID}  ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
	...   ${cmd_get_config}
    ${str_ok}    Get Lines Matching Pattern    ${ret}    OK    case_insensitive=True
    Should Be Equal As Strings    ${str_ok.strip()}    OK    ignore_case=True
    Append To List    ${UNEXPECTED_ALARMS}    ${UNEXPECTED_ALARM}
    Wait Until Keyword Succeeds    5 min    30 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms

Step ${index}: Create Cell Via Netconf
    Log To Console    Step ${index}: Create Cell Via Netconf
    Comment    ${ves_ccn_file}    Start VES Log Listen    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['ves_collector_5g']}    smod_SN=${PRIMARY_CORE_DN}
    Start VES Log Listen On ONAP Simulator    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    ${cmd_get_config}    Catenate    edit-config --target running --config=/tmp/${ONAP_SCF_CREATE} --test test-then-set
    ...    --error rollback --rpc-timeout 300s
    Comment    ${ret}    Exucute One Command On Netconf CLI    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['ves_collector_5g']}    ${MPLANE_IP}    ${cmd_get_config}
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${MRBTS_ID}  ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
	...   ${cmd_get_config}
    ${str_ok}    Get Lines Matching Pattern    ${ret}    OK    case_insensitive=True
    Should Be Equal As Strings    ${str_ok.strip()}    OK    ignore_case=True
    Wait Until Keyword Succeeds    10 min    30 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms

Particular Teardown
    Remove Values From List    ${UNEXPECTED_ALARMS}    ${UNEXPECTED_ALARM}
    Run Keyword If    ${NEED_RECOVER}    Run Keywords
    ...    coam.Perform Commissioning    bts_id=${MRBTS_ID}    scf_file=${BTS_scf_initial}    should_activate=True    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Set Test Variable    ${NEED_RECOVER}    ${False}
    Common Test Setup
    Set Test Variable    ${MRBTS_ID}    ${MRBTS_DN.split("-")[-1]}
    Comment    ${ONAP_INFOR}    Get Informations From ONAP    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    Comment    Set Test Variable    ${ONAP_INFOR}
    Comment    Run Keyword If    ${Integrate_Need}    Integrate SBTS To ONAP    ${MRBTS_ID}    ${ONAP["host_ip"]}    ${ONAP["user"]}
    ...    ${ONAP["pwd"]}
    Comment    Run Keyword If    ${Integrate_Need}    Integrate SBTS To ONAP Simulator    ${MRBTS_ID}    ${ONAP['host_ip']}
    ${UNEXPECTED_ALARM}    Create Dictionary    alarmId=${7115}    faultId=${4639}
    Set Test Variable    ${UNEXPECTED_ALARM}

TC Teardown
    Particular Teardown

Get Origin Variables From SBTS
    ${time}    Get Time    epoch
    ${selected_cell}    Evaluate    random.choice(${ALL_NR_CELL_SCF_DN})    modules=random, sys
    netact.Export Configuration    local_dir=${Test Results Dir}/NetActLogs    file_name=scf_from_netact.xml    dist_names=${MRBTS_DN}
    ...    ui_values=${True}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${Test Results Dir}/NetActLogs/scf_from_netact.xml
    ${val_vesCMFeedbackNotificationInt}    L_XML.Get Element Text    ${scf_xml}
    ...    .//managedObject[@class="MPLANEONAP"]/p[@name="vesCMFeedbackNotificationInt"]
    Should Not Be Equal As Integers    ${val_vesCMFeedbackNotificationInt}    0    Must set feedback CCN on.
    ${selected_cell_lcrid}    L_XML.Get Element Text    ${scf_xml}    .//managedObject[@distName="PLMN-PLMN/${selected_cell}"]/p[@name="lcrId"]
    ${cell_cellmapping_str}    catenate    SEPARATOR=    LCELNR-    ${selected_cell_lcrid}
    ${dn_cellMapping}    L_XML.Get Element Attribute    ${scf_xml}
    ...    distName    .//managedObject[@class="LCELNR" and contains(@distName,"${cell_cellmapping_str}")]
    ${dn_nr_cell_group}    L_XML.Get Element Attribute    ${scf_xml}    distName
    ...    .//managedObject[@class="NRCELLGRP"]/list[@name="nrCellList"]/p[text()="${selected_cell_lcrid}"]/../..
    ${DN_NRDU}    L_XML.Get Element Attribute    ${scf_xml}    distName    .//managedObject[@class="NRDU"]
    ${DN_NRDU}    Set Variable    ${DN_NRDU.replace("PLMN-PLMN/","")}
    ${CELL_DN_TO_DELETED}    Set Variable    ${selected_cell.replace("PLMN-PLMN/","")}
    ${CELL_MAPPING_DN_TO_DELETED}    Set Variable    ${dn_cellMapping.replace("PLMN-PLMN/","")}
    ${NR_CELLGROUP_DN}    Set Variable    ${dn_nr_cell_group.replace("PLMN-PLMN/","")}
    ${count}    L_XML.Get Element Count    ${scf_xml}    .//managedObject[@class="SMOD_R"]
    ${xpath}    Set Variable If    '${count}'=='${1}'    .//managedObject[@class="SMOD_R"]/p[@name="serialNumber"]
    ...    .//managedObject[@class="SMOD_R"]/p[@name="activeRole" and text()="Primary"]/../p[@name="serialNumber"]
    ${PRIMARY_CORE_DN}    L_XML.Get Element Text    ${scf_xml}    ${xpath}
    ${LIST_DN_TO_REMOVE}    Create List    ${CELL_DN_TO_DELETED}    ${CELL_MAPPING_DN_TO_DELETED}    ${NR_CELLGROUP_DN}
    Set Test Variable    ${PRIMARY_CORE_DN}
    Set Test Variable    ${NR_CELLGROUP_DN}
    Set Test Variable    ${LIST_DN_TO_REMOVE}
    Set Test Variable    ${ONAP_SCF_REMVOE}    CB007010_remove_NRCELL_${time}.xml
    Set Test Variable    ${ONAP_SCF_CREATE}    CB007010_create_NRCELL_${time}.xml
    Set Test Variable    ${CELL_DN_TO_DELETED}
    Set Test Variable    ${CELL_MAPPING_DN_TO_DELETED}
    Set Test Variable    ${DN_NRDU}
    Set Test Variable    ${NRCELL_ID}    ${selected_cell_lcrid}

Get Files From ONAP Simulator
    SSHLibrary.Open Connection    ${ONAP["host_ip"]}
    ${out_put}    SSHLibrary.Login    ${ONAP["user"]}    ${ONAP["pwd"]}
    SSHLibrary.Set Client Configuration    prompt=$
    SSHLibrary.Set Client Configuration    timeout=300 seconds
    SSHLibrary.Get File    /tmp/${ONAP_SCF_REMVOE}    ${BTSFiles}/${ONAP_SCF_REMVOE}
    SSHLibrary.Get File    /tmp/${ONAP_SCF_CREATE}    ${BTSFiles}/${ONAP_SCF_CREATE}
    [Teardown]    SSHLibrary.Close Connection

Put Files To ONAP Simulator
    SSHLibrary.Open Connection    ${ONAP["host_ip"]}
    ${out_put}    SSHLibrary.Login    ${ONAP["user"]}    ${ONAP["pwd"]}
    SSHLibrary.Set Client Configuration    prompt=$
    SSHLibrary.Set Client Configuration    timeout=300 seconds
    SSHLibrary.Put File    ${BTSFiles}/new_${ONAP_SCF_REMVOE}    /tmp/${ONAP_SCF_REMVOE}
    SSHLibrary.Put File    ${BTSFiles}/new_${ONAP_SCF_CREATE}    /tmp/${ONAP_SCF_CREATE}
    [Teardown]    SSHLibrary.Close Connection

Get Actual Configuration MO Count
    [Arguments]    ${dist_name}
    Log    Get Actual Configuration MO Count    console=True
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${status}=    Run Keyword And Return Status    netact.Export Configuration    local_dir=${Test Results Dir}/NetActLogs
    ...    file_name=check_netact_plan_delete_MOC.xml    dist_names=${dist_name}    ui_values=false
    ${scf_xml}=    L_XML.Parse Xml    ${Test Results Dir}/NetActLogs/check_netact_plan_delete_MOC.xml
    ${object}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@distName="${dist_name}"]
    ${obj_count}    Get Length    ${object}
    [Return]    ${obj_count}

Check Cell Deleted From WebEM
    ${cell_list_afterdelete}    coam.Get Cell List
    ${CELL_list_delete}    Set Variable    ${cell_list_afterdelete['cells']['nr']}
    ${CELL_list_delete_DN}    Create List
    FOR    ${item}    IN    @{CELL_list_delete}
        ${cell_DN_DE}    Set Variable    ${item['id']['configuration']}
        Append To List    ${CELL_list_delete_DN}    ${cell_DN_DE}
    END
    List Should Not Contain Value    ${CELL_list_delete_DN}    ${CELL_DN_TO_DELETED}

Check Cell Created From WebEM
    ${cell_list_afteradd}    coam.Get Cell List
    ${CELL_list_add}    Set Variable    ${cell_list_afteradd['cells']['nr']}
    ${CELL_list_add_DN}    Create List
    FOR    ${item}    IN    @{CELL_list_add}
        ${cell_DN_ADD}    Set Variable    ${item['id']['configuration']}
        Append To List    ${CELL_list_add_DN}    ${cell_DN_ADD}
    END
    List Should Contain Value    ${CELL_list_add_DN}    ${CELL_DN_TO_DELETED}

Modify ONAP SCF Files
    ${parsed_xml}    XML.Parse XML    ${BTSFiles}/${ONAP_SCF_REMVOE}
    ${e_onap}    XML.Get Element    ${parsed_xml}    ManagedElement
    Modify ONAP Plan Create Or Delete MOs    ${e_onap}    ${LIST_DN_TO_REMOVE}    delete
    ${scf_dn}    Set Variable    ${DN_NRDU}
    ${dic_param}    Create Dictionary    refNrCellGroup[1]    ${EMPTY}
    Modify ONAP Plan Parameters Of MO    ${scf_dn}    ${dic_param}    ${e_onap}    delete
    XML.Save XML    ${e_onap}    ${BTSFiles}/new_${ONAP_SCF_REMVOE}
    ${parsed_xml}    XML.Parse XML    ${BTSFiles}/${ONAP_SCF_CREATE}
    ${e_onap}    XML.Get Element    ${parsed_xml}    ManagedElement
    Modify ONAP Plan Create Or Delete MOs    ${e_onap}    ${LIST_DN_TO_REMOVE}    create
    ${simpleId}    Evaluate    ${NRBTS_runtime_cell_number}-1
    ${simpleId}    Convert To String    ${simpleId}
    ${dic_param}    Create Dictionary    refNrCellGroup[1].simpleId    [${simpleId}]
    Modify ONAP Plan Parameters Of MO    ${scf_dn}    ${dic_param}    ${e_onap}
    ${dic_param}    Create Dictionary    refNrCellGroup[1].refNrCellGroup    ${EMPTY}
    Modify ONAP Plan Parameters Of MO    ${scf_dn}    ${dic_param}    ${e_onap}    create
    XML.Save XML    ${e_onap}    ${BTSFiles}/new_${ONAP_SCF_CREATE}