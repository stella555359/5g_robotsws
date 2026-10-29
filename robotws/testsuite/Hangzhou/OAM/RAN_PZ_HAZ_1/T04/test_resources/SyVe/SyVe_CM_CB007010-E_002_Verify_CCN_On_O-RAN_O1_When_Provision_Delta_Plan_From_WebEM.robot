*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${ONAP_GET_OUT_FILE}    /tmp/CB007010-E_002.xml
${Integrate_Need}        ${False}


*** Keywords ***
SyVe_CM_CB007010-E_002_Verify_CCN_On_O-RAN_O1_When_Provision_Delta_Plan_From_WebEM
        [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   For case:RAN_ST_CB007010-E_002_CM_Verify CCN on O-RAN O1 interface when provision delta plan from WebEM
    ...  The main steps performed for the test are:
    ...  - Select MO Randomly And Check Params
    ...  - Perform Delta Plan With Add MOC
    ...  - Check MOC Be Added On NetAct And ONAP
    ...  - Perform Delta Plan With Delete MOC
    ...  - Check MOC Be Deleted On NetAct And ONAP
    ...  - Perform Delta Plan With Add Parameter
    ...  - Check Parameter Be Added On NetAct And ONAP
    ...  - Perform Delta Plan With Update Parameter
    ...  - Check Parameter Be Updated On NetAct And ONAP
    ...  - Perform Delta Plan With Delete Parameter
    ...  - Check Parameter Be Deleted On NetAct And ONAP
    ...  Pass criteria: Provision delta plan from WebEM,and check CCN on ONAP and netact. Site is OK with no any unexpected alarm.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 05.05.2023 - New case
    ...  - 20.11.2023 - Real ONAP transfer to Simulator

    Set Tags    CA-CM    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com    API
    LOG    ${TEST_NAME} of ${SUITE_NAME} start.    console=${True}
    Step 1: Select MO Randomly And Check Params
    Step 2: Perform Delta Plan With Add MOC
    Step 3: Check MOC Be Added On NetAct And ONAP
    Step 4: Perform Delta Plan With Delete MOC
    Step 5: Check MOC Be Deleted On NetAct And ONAP
    Step 6: Perform Delta Plan With Add Parameter
    Step 7: Check Parameter Be Added On NetAct And ONAP
    Step 8: Perform Delta Plan With Update Parameter
    Step 9: Check Parameter Be Updated On NetAct And ONAP
    Step 10: Perform Delta Plan With Delete Parameter
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
    Comment    Run Keyword If    ${Integrate_Need}    Integrate SBTS To ONAP Simulator    ${MRBTS_ID}    ${host_ip}

Step ${index}: Select MO Randomly And Check Params
    Log    Step ${index}: Select MO Randomly And Check Params    console=True
    ${Param_Name}    Set Variable    useId
    ${Param_Value}    Set Variable    2
    ${Param_Value_Update}    Set Variable    3
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${lte_cell_elements}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@class="NOKLTE:LNCEL"]
    FOR    ${element}    IN    @{lte_cell_elements}
        ${mo_dn}    L_XML.Get Element Attribute    ${element}    distName
        ${has_useId}    Run Keyword And Return Status    L_XML.Element Should Exist
        ...    .//managedObject[@distName="${mo_dn}"]/p[@name="${Param_Name}"]
        Run Keyword If    ${has_useId}    Remove Values From List    ${lte_cell_elements}    ${element}
    END
    Should Not Be Empty    ${lte_cell_elements}
    ${count}    Get Length    ${lte_cell_elements}
    ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    ${CELL_DN}    L_XML.Get Element Attribute    ${lte_cell_elements[${index}]}    distName
    ${LNBTS_DN}    Fetch From Left    ${CELL_DN}    /LNCEL-
    ${MRBTS_DN}    Fetch From Left    ${CELL_DN}    /LNBTS-
    ${mrbts_id}=    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${CELL_DN}
    Set Test Variable    ${LNBTS_DN}
    Set Test Variable    ${MRBTS_DN}
    Set Test Variable    ${Param_Name}
    Set Test Variable    ${Param_Value}
    Set Test Variable    ${Param_Value_Update}
    Set Test Variable    ${mrbts_id}
    ${MOC}    Set Variable    MRBTSDESC-0
    ${MOC_Param_Name}    Set Variable    descriptiveName
    ${MOC_Param_Value}    Set Variable    CB007010-E_002 testing
    NetAct CM Upload    dist_names=PLMN-PLMN/${MRBTS_DN}
    ${MOC_not_existed}    run keyword and return status    Check Actual Configuration Not Existed MOC    PLMN-PLMN/${MRBTS_DN}/${MOC}
    Run Keyword If    "${MOC_not_existed}"=="False"    Recovery SBTS
    Set Test Variable    ${MOC}
    Set Test Variable    ${MOC_Param_Name}
    Set Test Variable    ${MOC_Param_Value}
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

Step ${index}: Perform Delta Plan With Add MOC
    Log    Step ${index}: Perform Delta Plan With Add MOC    console=True
#    ${LogFile_Add_MOC}    Start VES Log Listen    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['ves_collector_5g']}    BTS_ID=${mrbts_id}
#    Sleep    5s
#    Set Test Variable    ${LogFile_Add_MOC}
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    ${param_dic}    create dictionary    parameterName=${MOC_Param_Name}    operation=update    value=${MOC_Param_Value}
    @{parameter_list}    Create List    ${param_dic}
    coam.perform_object_recommissioning    dist_name=${MRBTS_DN}/${MOC}    operation=create    parameter=@{parameter_list}
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check MOC Be Added On NetAct And ONAP
    Log    Step ${index}: Check MOC Be Added On NetAct And ONAP    console=True
    ${Param_Dic}    Create Dictionary    ${MOC_Param_Name}=${MOC_Param_Value}
    Wait Until Keyword Succeeds    3x    15s    NetAct Check Actual Configuration Parameters
    ...    dist_name=PLMN-PLMN/${MRBTS_DN}/${MOC}    &{Param_Dic}
    Sleep    30s
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
#    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages
#    ...    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['ves_collector_5g']}    ${LogFile_Add_MOC}
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
    ...    ${VES_CCN_msgs}    ${MRBTS_DN}/${MOC}    ${Primary_SN}    ${MPLANE_IP}    add    ${Param_Dic}
    log    ${target_VES_CCN_msg}
    should be true    "${target_VES_CCN_msg.__len__()}">="${1}"

Step ${index}: Perform Delta Plan With Delete MOC
    Log    Step ${index}: Perform Delta Plan With Delete MOC    console=True
#    ${LogFile_Delete_MOC}    Start VES Log Listen    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['ves_collector_5g']}    BTS_ID=${mrbts_id}
#    Sleep    5s
#    Set Test Variable    ${LogFile_Delete_MOC}
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    @{parameter_list}    Create List
    coam.perform_object_recommissioning    dist_name=${MRBTS_DN}/${MOC}    operation=delete    parameter=@{parameter_list}
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check MOC Be Deleted On NetAct And ONAP
    Log    Step ${index}: Check MOC Be Deleted On NetAct And ONAP    console=True
    Wait Until Keyword Succeeds    3x    15s    Check Actual Configuration Not Existed MOC    PLMN-PLMN/${MRBTS_DN}/${MOC}
    ${Param_Dic}    Create Dictionary    ${MOC_Param_Name}=${MOC_Param_Value}
    Sleep    30s
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
#    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages
#    ...    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['ves_collector_5g']}    ${LogFile_Delete_MOC}
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
    ...    ${VES_CCN_msgs}    ${MRBTS_DN}/MRBTSDESC-0    ${Primary_SN}    ${MPLANE_IP}    remove    ${Param_Dic}
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

Step ${index}: Perform Delta Plan With Add Parameter
    Log    Step ${index}: Perform Delta Plan With Add Parameter    console=True
#    ${LogFile_Add_Param}    Start VES Log Listen    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['ves_collector_5g']}    BTS_ID=${mrbts_id}
#    Set Test Variable    ${LogFile_Add_Param}
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    coam.perform_parameter_recommissioning    dist_name=${CELL_DN}
    ...    operation=update    parameter=${Param_Name}    value=${Param_Value}
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check Parameter Be Added On NetAct And ONAP
    Log    Step ${index}: Check Parameter Be Added On NetAct And ONAP    console=True
    ${Param_Dic}    Create Dictionary    ${Param_Name}=${Param_Value}
    Wait Until Keyword Succeeds    3x    15s    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/${CELL_DN}    &{Param_Dic}
    Sleep    30s
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
#    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages
#    ...    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['ves_collector_5g']}    ${LogFile_Add_Param}
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
    ...    ${VES_CCN_msgs}    ${CELL_DN}    ${Primary_SN}    ${MPLANE_IP}    replace    ${Param_Dic}
    log    ${target_VES_CCN_msg}
    should be true    "${target_VES_CCN_msg.__len__()}">="${1}"

Step ${index}: Perform Delta Plan With Update Parameter
    Log    Step ${index}: Perform Delta Plan With Update Parameter    console=True
#    ${LogFile_Update_Param}    Start VES Log Listen    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['ves_collector_5g']}    BTS_ID=${mrbts_id}
#    Set Test Variable    ${LogFile_Update_Param}
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    coam.perform_parameter_recommissioning    dist_name=${CELL_DN}
    ...    operation=update    parameter=${Param_Name}    value=${Param_Value_Update}
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check Parameter Be Updated On NetAct And ONAP
    Log    Step ${index}: Check Parameter Be Updated On NetAct And ONAP    console=True
    ${Param_Dic}    Create Dictionary    ${Param_Name}=${Param_Value_Update}
    Wait Until Keyword Succeeds    3x    15s    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/${CELL_DN}    &{Param_Dic}
    Sleep    30s
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
#    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages
#    ...    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['ves_collector_5g']}    ${LogFile_Update_Param}
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
    ...    ${VES_CCN_msgs}    ${CELL_DN}    ${Primary_SN}    ${MPLANE_IP}    replace    ${Param_Dic}
    should be true    "${target_VES_CCN_msg.__len__()}">="${1}"
    log    ${target_VES_CCN_msg}

Step ${index}: Perform Delta Plan With Delete Parameter
    Log    Step ${index}: Perform Delta Plan With Delete Parameter    console=True
#    ${LogFile_Delete_Param}    Start VES Log Listen    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['ves_collector_5g']}    BTS_ID=${mrbts_id}
#    Set Test Variable    ${LogFile_Delete_Param}
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    coam.perform_parameter_recommissioning    dist_name=${CELL_DN}
    ...    operation=delete    parameter=${Param_Name}    value=${Param_Value}
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check Parameter Be Deleted On NetAct And ONAP
    Log    Step ${index}: Check Parameter Be Deleted On NetAct And ONAP    console=True
    ${Param_List}    Create List    ${Param_Name}
    ${Param_Dic}    Create Dictionary    ${Param_Name}=${Param_Value_Update}
    Wait Until Keyword Succeeds    3x    15s    Check Actual Configuration Not Existed Parameters    PLMN-PLMN/${CELL_DN}    ${Param_List}
    Sleep    30s
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
#    ${VES_CCN_msgs}    Stop VES Log Listen And Get Messages
#    ...    ${host_ip}    ${user}    ${pwd}    ${ONAP_INFOR['ves_collector_5g']}    ${LogFile_Delete_Param}
    ${del_list}    Create List    ${Param_Name}
    ${Param_Dic}    Create Dictionary    !DELETE!=${del_list}
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
    ...    ${VES_CCN_msgs}    ${CELL_DN}    ${Primary_SN}    ${MPLANE_IP}    replace    ${Param_Dic}
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
    coam.perform_parameter_recommissioning    dist_name=${CELL_DN}
    ...    operation=delete    parameter=${Param_Name}    value=${Param_Value}
    @{parameter_list}    Create List
    coam.perform_object_recommissioning    dist_name=${MRBTS_DN}/MRBTSDESC-0    operation=delete    parameter=@{parameter_list}
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms

TC TearDown
    Log    TC TearDown    console=True
    run keyword if test failed      Recovery SBTS
    Common Test Teardown

