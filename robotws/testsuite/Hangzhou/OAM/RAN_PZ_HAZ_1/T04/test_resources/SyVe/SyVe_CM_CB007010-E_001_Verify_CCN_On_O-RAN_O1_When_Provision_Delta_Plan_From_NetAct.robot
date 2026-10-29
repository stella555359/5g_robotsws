*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot


*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${ONAP_GET_OUT_FILE}    /tmp/CB007010-E_001.xml
${Integrate_Need}        ${False}


*** Keywords ***
SyVe_CM_CB007010-E_001_Verify_CCN_On_O-RAN_O1_When_Provision_Delta_Plan_From_NetAct
        [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   For case:RAN_ST_CB007010-E_001_CM_Verify CCN on O-RAN O1 interface when provision delta plan from NetAct
    ...  The main steps performed for the test are:
    ...  - Select MO Randomly And Check Params
    ...  - Provision Delta Plan SyVe With Add MOC
    ...  - Check MOC Be Added On NetAct And ONAP
    ...  - Provision Delta Plan SyVe With Delete MOC
    ...  - Check MOC Be Deleted On NetAct And ONAP
    ...  - Provision Delta Plan SyVe With Add Parameter
    ...  - Check Parameter Be Added On NetAct And ONAP
    ...  - Provision Delta Plan SyVe With Update Parameter
    ...  - Check Parameter Be Updated On NetAct And ONAP
    ...  - Provision Delta Plan SyVe With Delete Parameter
    ...  - Check Parameter Be Deleted On NetAct And ONAP
    ...  Pass criteria: Provision delta plan from NetAct,and check CCN on ONAP and netact. Site is OK with no any unexpected alarm.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 05.05.2023 - New case
    ...  - 20.11.2023 - Real ONAP transfer to Simulator

    Set Tags    CA-CM    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com    API
    LOG    ${TEST_NAME} of ${SUITE_NAME} start.    console=${True}
    Step 1: Select MO Randomly And Check Params
    Step 2: Provision Delta Plan SyVe With Add MOC
    Step 3: Check MOC Be Added On NetAct And ONAP
    Step 4: Provision Delta Plan SyVe With Delete MOC
    Step 5: Check MOC Be Deleted On NetAct And ONAP
    Step 6: Provision Delta Plan SyVe With Add Parameter
    Step 7: Check Parameter Be Added On NetAct And ONAP
    Step 8: Provision Delta Plan SyVe With Update Parameter
    Step 9: Check Parameter Be Updated On NetAct And ONAP
    Step 10: Provision Delta Plan SyVe With Delete Parameter
    Step 11: Check Parameter Be Deleted On NetAct And ONAP

TC SetUp
    Log    TC SetUp    console=True
    Common Test Setup
    ${MRBTS_ID}    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${MRBTS_ID}
    Set Test Variable    ${host_ip}    ${ONAP["host_ip"]}
    Set Test Variable    ${user}    ${ONAP["user"]}
    Set Test Variable    ${pwd}    ${ONAP["pwd"]}
#    ${ONAP_INFOR}    Get Informations From ONAP    ${host_ip}    ${user}    ${pwd}
#    Set Test Variable      ${ONAP_INFOR}
#    run keyword if    ${Integrate_Need}    Integrate SBTS To ONAP    ${MRBTS_ID}    ${host_ip}    ${user}    ${pwd}
    Comment    Run Keyword If    ${Integrate_Need}    Integrate SBTS To ONAP Simulator    ${MRBTS_ID}    ${ONAP['host_ip']}

Step ${index}: Select MO Randomly And Check Params
    Log    Step ${index}: Select MO Randomly And Check Params    console=True
    ${Param_Name}    Set Variable    acbECTimer
    ${Param_Value}    Set Variable    ${10}
    ${Param_Value_Update}    Set Variable    ${3}
    ${Param_Dic}    Create Dictionary    ${Param_Name}=${Param_Value}
    ${Param_Dic_Update}    Create Dictionary    ${Param_Name}=${Param_Value_Update}
    ${Param_Dic_Delete}    Create Dictionary    ${Param_Name}=${EMPTY}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${lte_cell_elements}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@class="NOKLTE:LNCEL"]
    FOR    ${element}    IN    @{lte_cell_elements}
        ${mo_dn}    L_XML.Get Element Attribute    ${element}    distName
        ${has_acbECTimer}    Run Keyword And Return Status    L_XML.Element Should Exist
        ...    .//managedObject[@distName="${mo_dn}/SIB-0"]/p[@name="${Param_Name}"]
        Run Keyword If    ${has_acbECTimer}    Remove Values From List    ${lte_cell_elements}    ${element}
    END
    Should Not Be Empty    ${lte_cell_elements}
    ${count}    Get Length    ${lte_cell_elements}
    ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    ${CELL_DN}    L_XML.Get Element Attribute    ${lte_cell_elements[${index}]}    distName
    ${SIB_DN}    Set Variable    ${CELL_DN}/SIB-0
    ${LNBTS_DN}    Fetch From Left    ${CELL_DN}    /LNCEL-
    ${MRBTS_DN}    Fetch From Left    ${CELL_DN}    /LNBTS-
    ${version}    L_XML.Get Element Attribute    ${scf_xml}    version    .//managedObject[@distName="${SIB_DN}"]
    ${Param_Dic_Prop}    Create Dictionary    meta_class=NOKLTE:SIB    meta_version=${version}
    ${version}    L_XML.Get Element Attribute    ${scf_xml}    version    .//managedObject[@distName="${MRBTS_DN}"]
    ${MOC_Dic_Prop}    Create Dictionary    meta_class=com.nokia.srbts:MRBTSDESC    meta_version=${version}
    ${mrbts_id}=    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${SIB_DN}
    Set Test Variable    ${CELL_DN}
    Set Test Variable    ${LNBTS_DN}
    Set Test Variable    ${MRBTS_DN}
    Set Test Variable    ${Param_Name}
    Set Test Variable    ${Param_Value}
    Set Test Variable    ${Param_Value_Update}
    Set Test Variable    ${mrbts_id}
    #Set Test Variable    ${VALUE_PARAM}
    Set Test Variable    ${Param_Dic}
    Set Test Variable    ${Param_Dic_Update}
    Set Test Variable    ${Param_Dic_Prop}
    Set Test Variable    ${Param_Dic_Delete}
    ${MOC}    Set Variable    MRBTSDESC-0
    ${MOC_Param_Name}    Set Variable    descriptiveName
    ${MOC_Param_Value}    Set Variable    CB007010-E_001 testing
    ${MOC_not_existed}    run keyword and return status    Check Actual Configuration Not Existed MOC    PLMN-PLMN/${MRBTS_DN}/${MOC}
    Run Keyword If    "${MOC_not_existed}"=="False"    run keyword and ignore error    Recovery SBTS
    Set Test Variable    ${MOC}
    Set Test Variable    ${MOC_Param_Name}
    Set Test Variable    ${MOC_Param_Value}
    Set Test Variable    ${MOC_Dic_Prop}
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
    ${NAMES_OF_SYVE_PLAN}    Create List
    Set Test Variable    ${NAMES_OF_SYVE_PLAN}

Step ${index}: Provision Delta Plan SyVe With Add MOC
    Log    Step ${index}: Provision Delta Plan SyVe With Add MOC    console=True
    Set Test Variable    ${name}    CB007010-E_001-Add_MOC
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}    NetAct Create Plan    ${name}    Automation for ${TEST_NAME}
    Append To List    ${NAMES_OF_SYVE_PLAN}    ${name}
    netact.Create Managed Object    plan=${plan}    meta_class=${MOC_Dic_Prop['meta_class']}    meta_version=${MOC_Dic_Prop['meta_version']}
    ...    mo_id=PLMN-PLMN/${MRBTS_DN}/${MOC}    operation=Create    ${MOC_Param_Name}=${MOC_Param_Value}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv
    ...    dist_names=PLMN-PLMN/${MRBTS_DN}    plan_name=${name}    operation_type=plan
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
#    ${LogFile_Add_MOC}    Start VES Log Listen    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['ves_collector_5g']}    BTS_ID=${mrbts_id}
#    Set Test Variable    ${LogFile_Add_MOC}
    NetAct Provision Plan    plan_name=${name}    dist_names=PLMN-PLMN/${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check MOC Be Added On NetAct And ONAP
    Log    Step ${index}: Check MOC Be Added On NetAct And ONAP    console=True
    ${MOC_Param_Dic}    Create Dictionary    ${MOC_Param_Name}=${MOC_Param_Value}
    Wait Until Keyword Succeeds    3x    15s    NetAct Check Actual Configuration Parameters
    ...    dist_name=PLMN-PLMN/${MRBTS_DN}/${MOC}    &{MOC_Param_Dic}
    Sleep    30s
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
#    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages
#    ...    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['ves_collector_5g']}    ${LogFile_Add_MOC}
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
    ...    ${VES_CCN_msgs}    ${MRBTS_DN}/${MOC}    ${Primary_SN}    ${MPLANE_IP}    add    ${MOC_Param_Dic}
    log    ${target_VES_CCN_msg}
    should be true    "${target_VES_CCN_msg.__len__()}">="${1}"

Step ${index}: Provision Delta Plan SyVe With Delete MOC
    Log    Step ${index}: Provision Delta Plan SyVe With Delete MOC    console=True
    Set Test Variable    ${name}    CB007010-E_001-Delete_MOC
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}    NetAct Create Plan    ${name}    Automation for ${TEST_NAME}
    Append To List    ${NAMES_OF_SYVE_PLAN}    ${name}
    netact.Create Managed Object    plan=${plan}    meta_class=${MOC_Dic_Prop['meta_class']}    meta_version=${MOC_Dic_Prop['meta_version']}
    ...    mo_id=PLMN-PLMN/${MRBTS_DN}/${MOC}    operation=Delete    ${MOC_Param_Name}=${MOC_Param_Value}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv
    ...    dist_names=PLMN-PLMN/${MRBTS_DN}    plan_name=${name}    operation_type=plan
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
#    ${LogFile_Delete_MOC}    Start VES Log Listen    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['ves_collector_5g']}    BTS_ID=${mrbts_id}
#    Set Test Variable    ${LogFile_Delete_MOC}
    NetAct Provision Plan    plan_name=${name}    dist_names=PLMN-PLMN/${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check MOC Be Deleted On NetAct And ONAP
    Log    Step ${index}: Check MOC Be Deleted On NetAct And ONAP    console=True
    Wait Until Keyword Succeeds    3x    15s    Check Actual Configuration Not Existed MOC    PLMN-PLMN/${MRBTS_DN}/${MOC}
    ${MOC_Param_Dic}    Create Dictionary    ${MOC_Param_Name}=${MOC_Param_Value}
    Sleep    30s
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
#    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages
#    ...    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['ves_collector_5g']}    ${LogFile_Delete_MOC}
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
    ...    ${VES_CCN_msgs}    ${MRBTS_DN}/${MOC}    ${Primary_SN}    ${MPLANE_IP}    remove    ${MOC_Param_Dic}
    log    ${target_VES_CCN_msg}
    should be true    "${target_VES_CCN_msg.__len__()}">="${1}"

Check Actual Configuration Not Existed MOC
    [Arguments]    ${dist_name}
    Log    Check Actual Configuration Not Existed MOC    console=True
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${status}=    Run Keyword And Return Status    netact.Export Configuration    local_dir=${Test Results Dir}/NetActLogs
    ...    file_name=check_netact_plan_delete_MOC.xml    dist_names=${dist_name}    ui_values=false
    ${scf_xml}=    L_XML.Parse Xml    ${Test Results Dir}/NetActLogs/check_netact_plan_delete_MOC.xml
    ${object}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@distName="${dist_name}"]
    ${obj_count}    Get Length    ${object}
    Should Be Equal As Integers    ${obj_count}    ${0}

Step ${index}: Provision Delta Plan SyVe With Add Parameter
    Log    Step ${index}: Provision Delta Plan SyVe With Add Parameter    console=True
    Set Test Variable    ${name}    CB007010-E_001-Add_Param
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}    NetAct Create Plan    ${name}    Automation for ${TEST_NAME}
    Append To List    ${NAMES_OF_SYVE_PLAN}    ${name}
    netact.Create Managed Object    plan=${plan}    meta_class=${Param_Dic_Prop['meta_class']}
    ...    meta_version=${Param_Dic_Prop['meta_version']}    mo_id=PLMN-PLMN/${SIB_DN}    operation=Update    &{Param_Dic}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv
    ...    dist_names=PLMN-PLMN/${MRBTS_DN}    plan_name=${name}    operation_type=plan
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
#    ${LogFile_Add_Param}    Start VES Log Listen    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['ves_collector_5g']}    BTS_ID=${mrbts_id}
#    Set Test Variable    ${LogFile_Add_Param}
    NetAct Provision Plan    plan_name=${name}    dist_names=PLMN-PLMN/${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check Parameter Be Added On NetAct And ONAP
    Log    Step ${index}: Check Parameter Be Added On NetAct And ONAP    console=True
    ${Param_Value_NA}    convert to string    ${Param_Value}
    ${Param_Dic_NA}    Create Dictionary    ${Param_Name}=${Param_Value_NA}
    Wait Until Keyword Succeeds    3x    15s    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/${SIB_DN}   &{Param_Dic_NA}
    Sleep    30s
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
#    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages
#    ...    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['ves_collector_5g']}    ${LogFile_Add_Param}
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
    ...    ${VES_CCN_msgs}    ${SIB_DN}    ${Primary_SN}    ${MPLANE_IP}    replace    ${Param_Dic}
    log    ${target_VES_CCN_msg}
    should be true    "${target_VES_CCN_msg.__len__()}">="${1}"

Step ${index}: Provision Delta Plan SyVe With Update Parameter
    Log    Step ${index}: Provision Delta Plan SyVe With Update Parameter    console=True
    Set Test Variable    ${name}    CB007010-E_001-Update_Param
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}    NetAct Create Plan    ${name}    Automation for ${TEST_NAME}
    Append To List    ${NAMES_OF_SYVE_PLAN}    ${name}
    netact.Create Managed Object    plan=${plan}    meta_class=${Param_Dic_Prop['meta_class']}
    ...    meta_version=${Param_Dic_Prop['meta_version']}    mo_id=PLMN-PLMN/${SIB_DN}    operation=Update    &{Param_Dic_Update}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv
    ...    dist_names=PLMN-PLMN/${MRBTS_DN}    plan_name=${name}    operation_type=plan
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
#    ${LogFile_Update_Param}    Start VES Log Listen    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['ves_collector_5g']}    BTS_ID=${mrbts_id}
#    Set Test Variable    ${LogFile_Update_Param}
    NetAct Provision Plan    plan_name=${name}    dist_names=PLMN-PLMN/${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check Parameter Be Updated On NetAct And ONAP
    Log    Step ${index}: Check Parameter Be Updated On NetAct And ONAP    console=True
    ${Param_Value_NA}    convert to string    ${Param_Value_Update}
    ${Param_Dic_Update_NA}    Create Dictionary    ${Param_Name}=${Param_Value_NA}
    Wait Until Keyword Succeeds    3x    15s    NetAct Check Actual Configuration Parameters
    ...    dist_name=PLMN-PLMN/${SIB_DN}    &{Param_Dic_Update_NA}
    Sleep    30s
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
#    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages
#    ...    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['ves_collector_5g']}    ${LogFile_Update_Param}
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
    ...    ${VES_CCN_msgs}    ${SIB_DN}    ${Primary_SN}    ${MPLANE_IP}    replace    ${Param_Dic_Update}
    log    ${target_VES_CCN_msg}
    should be true    "${target_VES_CCN_msg.__len__()}">="${1}"

Step ${index}: Provision Delta Plan SyVe With Delete Parameter
    Log    Step ${index}: Provision Delta Plan SyVe With Delete Parameter    console=True
    Set Test Variable    ${name}    CB007010-E_001-Delete_Param
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}    NetAct Create Plan    ${name}    Automation for ${TEST_NAME}
    Append To List    ${NAMES_OF_SYVE_PLAN}    ${name}
    netact.Create Managed Object    plan=${plan}    meta_class=${Param_Dic_Prop['meta_class']}
    ...    meta_version=${Param_Dic_Prop['meta_version']}    mo_id=PLMN-PLMN/${SIB_DN}    operation=Update    &{Param_Dic_Delete}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv
    ...    dist_names=PLMN-PLMN/${MRBTS_DN}    plan_name=${name}    operation_type=plan
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
#    ${LogFile_Delete_Param}    Start VES Log Listen    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['ves_collector_5g']}    BTS_ID=${mrbts_id}
#    Set Test Variable    ${LogFile_Delete_Param}
    NetAct Provision Plan    plan_name=${name}    dist_names=PLMN-PLMN/${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check Parameter Be Deleted On NetAct And ONAP
    Log    Step ${index}: Check Parameter Be Deleted On NetAct And ONAP    console=True
    ${Param_List}    Create List    ${Param_Name}
    Wait Until Keyword Succeeds    3x    15s    Check Actual Configuration Not Existed Parameters    PLMN-PLMN/${SIB_DN}    ${Param_List}
    Sleep    30s
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
#    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages
#    ...    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['ves_collector_5g']}    ${LogFile_Delete_Param}
    ${del_list}    Create List    ${Param_Name}
    ${Param_Dic_De}    Create Dictionary    !DELETE!=${del_list}
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
    ...    ${VES_CCN_msgs}    ${SIB_DN}    ${Primary_SN}    ${MPLANE_IP}    replace    ${Param_Dic_De}
    log    ${target_VES_CCN_msg}
    should be true    "${target_VES_CCN_msg.__len__()}">="${1}"

Check Actual Configuration Not Existed Parameters
    [Arguments]    ${dist_name}    ${param_list}
    Log    Check Actual Configuration Not Existed Parameters    console=True
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${status}=    Run Keyword And Return Status    netact.Export Configuration    local_dir=${Test Results Dir}/NetActLogs
    ...    file_name=check_netact_plan_delete_param.xml    dist_names=${dist_name}    ui_values=false
    ${scf_xml}=    L_XML.Parse Xml    ${Test Results Dir}/NetActLogs/check_netact_plan_delete_param.xml
    ${object}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@distName="${dist_name}"]
    ${obj_count}    Get Length    ${object}
    Should Be Equal As Integers    ${obj_count}    ${1}
    FOR    ${param}    IN    @{param_list}
        ${parameter}    L_XML.Get Elements     ${scf_xml}
        ...    .//managedObject[@distName="${dist_name}"]/p[@name="${param}"]
        ${parameter_count}    Get Length    ${parameter}
        Should Be Equal As Integers    ${parameter_count}    ${0}
    END

Recovery SBTS
    Log    Recovery SBTS    console=True
    coam.perform_parameter_recommissioning    dist_name=${SIB_DN}
    ...    operation=delete    parameter=${Param_Name}    value=${Param_Value}
    @{parameter_list}    Create List
    coam.perform_object_recommissioning    dist_name=${MRBTS_DN}/MRBTSDESC-0    operation=delete    parameter=@{parameter_list}
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms

TC TearDown
    Log    TC TearDown    console=True
    run keyword if test failed      Recovery SBTS
    FOR    ${plan_name}    IN    @{NAMES_OF_SYVE_PLAN}
        Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${plan_name}
    END
    Common Test Teardown


