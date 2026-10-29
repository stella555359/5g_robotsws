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
TC__SyVe_CM_CB007010_B_002_Creation_And_Deleteion_Of_LTE_Cell_For_cOAM_SBTS
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
    Step 6: Remove LNCELs Via Netconf
    Step 7: Check CCN And LNCELL Deleted
    Step 8: Create LNCELs Via Netconf
    Step 9: Check CCN And LNCELL Created

Step ${index}: Check ${when} BTS state
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    5 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=${EXPECTED_ALARMS}    unexpected_alarms=${UNEXPECTED_ALARMS}
    ...    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=${EXPECTED_ALARMS}    unexpected_alarms=${UNEXPECTED_ALARMS}
    ...    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Check CCN And LNCELL Deleted
    Log    Step ${index}: Check CCN And LNCELL Deleted    console=True
    Wait Until Keyword Succeeds    10x    30s    Check LNCELL Deleted From WebEM
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

Step ${index}: Check CCN And LNCELL Created
    Log    Step ${index}: Check CCN And LNCELL Created    console=True
    Wait Until Keyword Succeeds    10x    30s    Check LNCELL Created From WebEM
    Set Test Variable    ${NEED_RECOVER}    ${True}
    Comment    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['ves_collector_5g']}    ${ves_ccn_file}
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ${target_VES_CCN_msg}    Filter VES VsCmOperationFeedbackNotification CCN    ${VES_CCN_msgs}    ${PRIMARY_CORE_DN}    provision    completed
    Log    ${target_VES_CCN_msg}
    Should Be Equal As Integers    ${target_VES_CCN_msg.__len__()}    ${1}
    ${dic_param_value}    Create Dictionary
    FOR    ${dn}    IN    @{CELL_MAPPING_DN_TO_DELETED}
        ${count}    Get Actual Configuration MO Count    PLMN-PLMN/${dn}
        Should Be Equal As Integers    ${count}    ${1}
        ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN    ${VES_CCN_msgs}    ${dn}    ${PRIMARY_CORE_DN}    ${MPLANE_IP}    add
        ...    ${dic_param_value}
        Should Not Be Empty    ${target_VES_CCN_msg}
    END
    FOR    ${dn}    IN    @{CELL_DN_TO_DELETED}
        ${count}    Get Actual Configuration MO Count    PLMN-PLMN/${dn}
        Should Be Equal As Integers    ${count}    ${1}
        ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN    ${VES_CCN_msgs}    ${dn}    ${PRIMARY_CORE_DN}    ${MPLANE_IP}    replace
        ...    ${dic_param_value}
        Should Not Be Empty    ${target_VES_CCN_msg}
    END

Step ${index}: Prepare ONAP SCF Files
    Log To Console    Step ${index}: Prepare ONAP SCF Files
    Random Select LNCEL
    ${cmd_get_config_head}    Set Variable    get-config --source running --filter-xpath
    ${onap_remove_filter_str}    ${onap_create_filter_str}    Generate Filter Strings For Create And Remove MOs    ${LIST_DN_TO_REMOVE}
    ${cmd_get_config}    Set Variable    ${cmd_get_config_head} ${onap_remove_filter_str} --out=/tmp/${ONAP_SCF_REMVOE}
    Comment    Exucute One Command On Netconf CLI    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['ves_collector_5g']}    ${MPLANE_IP}    ${cmd_get_config}
    Execute NetConf Command On ONAP Simulator    MRBTS-${MRBTS_ID}  ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    ${cmd_get_config}
    ${cmd_get_config}    Set Variable    ${cmd_get_config_head} ${onap_create_filter_str} --out=/tmp/${ONAP_SCF_CREATE}
    Comment    Exucute One Command On Netconf CLI    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['ves_collector_5g']}    ${MPLANE_IP}    ${cmd_get_config}
    Execute NetConf Command On ONAP Simulator    MRBTS-${MRBTS_ID}  ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}    ${cmd_get_config}
    Get Files From ONAP Simulator
    Comment    Get File From Pod To Local    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['ves_collector_5g']}
    ...    /tmp/${ONAP_SCF_REMVOE}    ${BTSFiles}/${ONAP_SCF_REMVOE}
    Comment    Get File From Pod To Local    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['ves_collector_5g']}
    ...    /tmp/${ONAP_SCF_CREATE}    ${BTSFiles}/${ONAP_SCF_CREATE}
    ${parsed_xml}    XML.Parse XML    ${BTSFiles}/${ONAP_SCF_REMVOE}
    ${e_onap}    XML.Get Element    ${parsed_xml}    ManagedElement
    Modify ONAP Plan Create Or Delete MOs    ${e_onap}    ${LIST_DN_TO_REMOVE}    delete
    XML.Save XML    ${e_onap}    ${BTSFiles}/new_${ONAP_SCF_REMVOE}
    ${parsed_xml}    XML.Parse XML    ${BTSFiles}/${ONAP_SCF_CREATE}
    ${e_onap}    XML.Get Element    ${parsed_xml}    ManagedElement
    Modify ONAP Plan Create Or Delete MOs    ${e_onap}    ${LIST_DN_TO_REMOVE}    create
    XML.Save XML    ${e_onap}    ${BTSFiles}/new_${ONAP_SCF_CREATE}
    Put Files To ONAP Simulator
    Comment    Put File From Local To Pod    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['ves_collector_5g']}
    ...    /tmp/new_${ONAP_SCF_REMVOE}    ${BTSFiles}/new_${ONAP_SCF_REMVOE}
    Comment    Put File From Local To Pod    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}    ${ONAP_INFOR['ves_collector_5g']}
    ...    /tmp/new_${ONAP_SCF_CREATE}    ${BTSFiles}/new_${ONAP_SCF_CREATE}

Step ${index}: Remove LNCELs Via Netconf
    Log To Console    Step ${index}: Remove LNCELs Via Netconf
    Append To List    ${UNEXPECTED_ALARMS}    ${UNEXPECTED_ALARM}
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
    Wait Until Keyword Succeeds    5 min    30 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms

Step ${index}: Create LNCELs Via Netconf
    Log To Console    Step ${index}: Create LNCELs Via Netconf
    Comment    ${ves_ccn_file}    Start VES Log Listen    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['ves_collector_5g']}    smod_SN=${PRIMARY_CORE_DN}
    Start VES Log Listen On ONAP Simulator    ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
    ${cmd_get_config}    Catenate    edit-config --target running --config=/tmp/${ONAP_SCF_CREATE} --test test-then-set
    ...    --error rollback --rpc-timeout 300s
    Comment    ${ret}    Exucute One Command On Netconf CLI    ${ONAP["host_ip"]}    ${ONAP["user"]}    ${ONAP["pwd"]}
    ...    ${ONAP_INFOR['ves_collector_5g']}    ${MPLANE_IP}    ${cmd_get_config}
    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${MRBTS_ID}  ${ONAP['host_ip']}    ${ONAP['user']}    ${ONAP['pwd']}
	...  ${cmd_get_config}
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

Get SCF DNs To Be Deleted
    ${CELL_DN_TO_DELETED}    Create List
    ${CELL_MAPPING_DN_TO_DELETED}    Create List
    ${nbiot_cells}    Get Dictionary Values    ${LTE_NB_IoT_FDD_SCF_DIC}
    Remove Values From List    ${ALL_LTE_CELL_SCF_DN}    @{nbiot_cells}
    ${selected_cell}    Evaluate    random.choice(${ALL_LTE_CELL_SCF_DN})    modules=random, sys
    netact.Export Configuration    local_dir=${Test Results Dir}/NetActLogs    file_name=scf_from_netact.xml    dist_names=${MRBTS_DN}
    ...    ui_values=${True}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${Test Results Dir}/NetActLogs/scf_from_netact.xml
    ${selected_lncell_lcrid}    L_XML.Get Element Text    ${scf_xml}    .//managedObject[@distName="PLMN-PLMN/${selected_cell}"]/p[@name="lcrId"]
    ${lncell_cellmapping_str}    catenate    SEPARATOR=    LCELL-    ${selected_lncell_lcrid}
    ${dn_cellMapping}    L_XML.Get Element Attribute    ${scf_xml}
    ...    distName    .//managedObject[@class="LCELL" and contains(@distName,"${lncell_cellmapping_str}")]
    Append To List    ${CELL_DN_TO_DELETED}    ${selected_cell.replace("PLMN-PLMN/","")}
    Append To List    ${CELL_MAPPING_DN_TO_DELETED}    ${dn_cellMapping.replace("PLMN-PLMN/","")}
    ${child_cell}    Pop From Dictionary    ${LTE_NB_IoT_FDD_SCF_DIC}    ${selected_cell.replace("PLMN-PLMN/","")}    ${EMPTY}
    ${count}    L_XML.Get Element Count    ${scf_xml}    .//managedObject[@class="SMOD_R"]
    ${xpath}    Set Variable If    '${count}'=='${1}'    .//managedObject[@class="SMOD_R"]/p[@name="serialNumber"]
    ...    .//managedObject[@class="SMOD_R"]/p[@name="activeRole" and text()="Primary"]/../p[@name="serialNumber"]
    ${PRIMARY_CORE_DN}    L_XML.Get Element Text    ${scf_xml}    ${xpath}
    Set Test Variable    ${PRIMARY_CORE_DN}
    Return From Keyword If    '${child_cell}'=='${EMPTY}'    ${CELL_DN_TO_DELETED}    ${CELL_MAPPING_DN_TO_DELETED}
    ${selected_lncell_lcrid}    L_XML.Get Element Text    ${scf_xml}    .//managedObject[@distName="PLMN-PLMN/${child_cell}"]/p[@name="lcrId"]
    ${lncell_cellmapping_str}    catenate    SEPARATOR=    LCELL-    ${selected_lncell_lcrid}
    ${dn_cellMapping}    L_XML.Get Element Attribute    ${scf_xml}    distName
    ...    .//managedObject[@class="LCELL" and contains(@distName,"${lncell_cellmapping_str}")]
    Append To List    ${CELL_DN_TO_DELETED}    ${child_cell.replace("PLMN-PLMN/","")}
    Append To List    ${CELL_MAPPING_DN_TO_DELETED}    ${dn_cellMapping.replace("PLMN-PLMN/","")}
    [Return]    ${CELL_DN_TO_DELETED}    ${CELL_MAPPING_DN_TO_DELETED}

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

Random Select LNCEL
    ${time}    Get Time    epoch
    ${CELL_DN_TO_DELETED}    ${CELL_MAPPING_DN_TO_DELETED}    Get SCF DNs To Be Deleted
    ${LIST_DN_TO_REMOVE}    Combine Lists    ${CELL_DN_TO_DELETED}    ${CELL_MAPPING_DN_TO_DELETED}
    Log List    ${LIST_DN_TO_REMOVE}
    Set Test Variable    ${LIST_DN_TO_REMOVE}
    Set Test Variable    ${ONAP_SCF_REMVOE}    CB007010_remove_LNCELL_${time}.xml
    Set Test Variable    ${ONAP_SCF_CREATE}    CB007010_create_LNCEL_${time}.xml
    Set Test Variable    ${CELL_DN_TO_DELETED}
    Set Test Variable    ${CELL_MAPPING_DN_TO_DELETED}

Check LNCELL Deleted From WebEM
    ${cell_list_afterdelete}    coam.Get Cell List
    ${LNCELL_list_delete}    Set Variable    ${cell_list_afterdelete['cells']['lte']}
    ${LNCELL_list_delete_DN}    Create List
    FOR    ${item}    IN    @{LNCELL_list_delete}
        ${Lncell_DN_DE}    Set Variable    ${item['id']['configuration']}
        Append To List    ${LNCELL_list_delete_DN}    ${Lncell_DN_DE}
    END
    FOR    ${cell}    IN    @{CELL_DN_TO_DELETED}
        List Should Not Contain Value    ${LNCELL_list_delete_DN}    ${cell}
    END

Check LNCELL Created From WebEM
    ${cell_list_afteradd}    coam.Get Cell List
    ${LNCELL_list_add}    Set Variable    ${cell_list_afteradd['cells']['lte']}
    ${LNCELL_list_add_DN}    Create List
    FOR    ${item}    IN    @{LNCELL_list_add}
        ${Lncell_DN_ADD}    Set Variable    ${item['id']['configuration']}
        Append To List    ${LNCELL_list_add_DN}    ${Lncell_DN_ADD}
    END
    FOR    ${cell}    IN    @{CELL_DN_TO_DELETED}
        List Should Contain Value    ${LNCELL_list_add_DN}    ${cell}
    END