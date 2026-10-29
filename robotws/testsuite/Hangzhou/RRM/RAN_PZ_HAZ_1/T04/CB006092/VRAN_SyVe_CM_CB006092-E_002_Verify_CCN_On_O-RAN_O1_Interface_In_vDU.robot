*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
...   Description: This robot cases is for CB006092-E_002 NetAct Provision
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
${RECOVERY_FLAG}    ${False}

*** Keywords ***
VRAN_SyVe_CM_CB006092-E_002_Verify_CCN_On_O-RAN_O1_Interface_In_vDU
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    25.04.2025, yuyan.xu@nokia-sbell.com
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
    Step 12: Lock Unlock One RMOD And Check CCN
    Step 13: Reset One RMOD And Check CCN

Step ${index}: Select MO Randomly And Check Params
    Log To Console    Step ${index}: Select MO Randomly And Check Params
    ${Param_Name}    Set Variable    adaptiveSrBlockingMinimization
    ${Param_Value}    Set Variable    ${10}
    ${Param_Value_Update}    Set Variable    ${1000}
    ${Param_Dic}    Create Dictionary    ${Param_Name}=${Param_Value}
    ${Param_Dic_Update}    Create Dictionary    ${Param_Name}=${Param_Value_Update}
    ${Param_Dic_Delete}    Create Dictionary    ${Param_Name}=${EMPTY}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    ${nr_cell_elements}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    FOR    ${element}    IN    @{nr_cell_elements}
        ${mo_dn}    L_XML.Get Element Attribute    ${element}    distName
        ${has_param}    Run Keyword And Return Status    L_XML.Element Should Exist
        ...    .//managedObject[@distName="${mo_dn}"]/p[@name="${Param_Name}"]
        Run Keyword If    ${has_param}    Remove Values From List    ${nr_cell_elements}    ${element}
    END
    Should Not Be Empty    ${nr_cell_elements}
    ${count}    Get Length    ${nr_cell_elements}
    ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    ${CELL_DN}    L_XML.Get Element Attribute    ${nr_cell_elements[${index}]}    distName
    ${version}    L_XML.Get Element Attribute    ${scf_xml}    version    .//managedObject[@distName="${CELL_DN}"]
    ${Param_Dic_Prop}    Create Dictionary    meta_class=com.nokia.srbts.nrbts:NRCELL    meta_version=${version}
    ${version}    L_XML.Get Element Attribute    ${scf_xml}    version    .//managedObject[@distName="MRBTS-${vDU_id}"]
    ${MOC_Dic_Prop}    Create Dictionary    meta_class=com.nokia.vdu.5g:MRBTSDESC    meta_version=${version}
    Set Test Variable    ${CELL_DN}
    Set Test Variable    ${Param_Name}
    Set Test Variable    ${Param_Value}
    Set Test Variable    ${Param_Value_Update}
    Set Test Variable    ${Param_Dic}
    Set Test Variable    ${Param_Dic_Update}
    Set Test Variable    ${Param_Dic_Prop}
    Set Test Variable    ${Param_Dic_Delete}
    ${MOC}    Set Variable    MRBTSDESC-0
    ${MOC_Param_Name}    Set Variable    descriptiveName
    ${MOC_Param_Value}    Set Variable    CB006092-E_002 testing
    ${MOC_not_existed}    run keyword and return status    Check Actual Configuration Not Existed MOC    PLMN-PLMN/MRBTS-${vDU_id}/${MOC}
    Should Be True    ${MOC_not_existed}    MOC:MRBTSDESC-0 is existed in vDU
    Set Test Variable    ${MOC}
    Set Test Variable    ${MOC_Param_Name}
    Set Test Variable    ${MOC_Param_Value}
    Set Test Variable    ${MOC_Dic_Prop}
    ${NAMES_OF_SYVE_PLAN}    Create List
    Set Test Variable    ${NAMES_OF_SYVE_PLAN}

Step ${index}: Provision Delta Plan SyVe With Add MOC
    Log To Console    Step ${index}: Provision Delta Plan SyVe With Add MOC
    ${time}    Get Time    epoch
    Set Test Variable    ${name}    CB006092-E_002-Add_MOC_${time}
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}    NetAct Create Plan    ${name}    Automation for CB006092-E_002-Add_MOC
    Append To List    ${NAMES_OF_SYVE_PLAN}    ${name}
    netact.Create Managed Object    plan=${plan}    meta_class=${MOC_Dic_Prop['meta_class']}    meta_version=${MOC_Dic_Prop['meta_version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${vDU_id}/${MOC}    operation=Create    ${MOC_Param_Name}=${MOC_Param_Value}
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=${name}.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    plan_name=${name}    operation_type=plan
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    NetAct Provision Plan    plan_name=${name}    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Set Test Variable    ${RECOVERY_FLAG}    ${True}
    Wait Until Keyword Succeeds    10min    30s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0

Step ${index}: Check MOC Be Added On NetAct And ONAP
    Log To Console    Step ${index}: Check MOC Be Added On NetAct And ONAP
    ${MOC_Param_Dic}    Create Dictionary    ${MOC_Param_Name}=${MOC_Param_Value}
    Wait Until Keyword Succeeds    3x    15s    NetAct Check Actual Configuration Parameters
    ...    ne=PLMN-PLMN/MRBTS-${vDU_id}   dist_name=PLMN-PLMN/MRBTS-${vDU_id}/${MOC}    &{MOC_Param_Dic}
    Sleep    30s
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
    ...    ${VES_CCN_msgs}    MRBTS-${vDU_id}/${MOC}    vDu    ${vesSourceName}    ${dnPrefix}    ${du_ip}    add    ${MOC_Param_Dic}
    log    ${target_VES_CCN_msg}
    should be true    "${target_VES_CCN_msg.__len__()}">="${1}"

Step ${index}: Provision Delta Plan SyVe With Delete MOC
    Log    Step ${index}: Provision Delta Plan SyVe With Delete MOC    console=True
    ${time}    Get Time    epoch
    Set Test Variable    ${name}    CB006092-E_002-Delete_MOC_${time}
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}    NetAct Create Plan    ${name}    Automation for CB006092-E_002-Delete_MOC
    Append To List    ${NAMES_OF_SYVE_PLAN}    ${name}
    netact.Create Managed Object    plan=${plan}    meta_class=${MOC_Dic_Prop['meta_class']}    meta_version=${MOC_Dic_Prop['meta_version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${vDU_id}/${MOC}    operation=Delete    ${MOC_Param_Name}=${MOC_Param_Value}
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=${name}.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    plan_name=${name}    operation_type=plan
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    NetAct Provision Plan    plan_name=${name}    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Wait Until Keyword Succeeds    10min    30s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0

Step ${index}: Check MOC Be Deleted On NetAct And ONAP
    Log    Step ${index}: Check MOC Be Deleted On NetAct And ONAP    console=True
    Wait Until Keyword Succeeds    3x    15s    Check Actual Configuration Not Existed MOC    PLMN-PLMN/MRBTS-${vDU_id}/${MOC}
    ${MOC_Param_Dic}    Create Dictionary    ${MOC_Param_Name}=${MOC_Param_Value}
    Sleep    30s
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
    ...    ${VES_CCN_msgs}    MRBTS-${vDU_id}/${MOC}    vDu    ${vesSourceName}    ${dnPrefix}    ${du_ip}    remove    ${MOC_Param_Dic}
    log    ${target_VES_CCN_msg}
    should be true    "${target_VES_CCN_msg.__len__()}">="${1}"

Step ${index}: Provision Delta Plan SyVe With Add Parameter
    Log To Console    Step ${index}: Provision Delta Plan SyVe With Add Parameter
    ${time}    Get Time    epoch
    Set Test Variable    ${name}    CB006092-E_002-Add_Param_${time}
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}    NetAct Create Plan    ${name}    Automation for CB006092-E_002-Add_Param
    Append To List    ${NAMES_OF_SYVE_PLAN}    ${name}
    netact.Create Managed Object    plan=${plan}    meta_class=${Param_Dic_Prop['meta_class']}
    ...    meta_version=${Param_Dic_Prop['meta_version']}    mo_id=PLMN-PLMN/${CELL_DN}    operation=Update    &{Param_Dic}
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=${name}.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    plan_name=${name}    operation_type=plan
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    NetAct Provision Plan    plan_name=${name}    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Wait Until Keyword Succeeds    10min    30s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0

Step ${index}: Check Parameter Be Added On NetAct And ONAP
    Log To Console    Step ${index}: Check Parameter Be Added On NetAct And ONAP
    ${Param_Value_NA}    convert to string    ${Param_Value}
    ${Param_Dic_NA}    Create Dictionary    ${Param_Name}=${Param_Value_NA}
    Wait Until Keyword Succeeds    3x    15s    NetAct Check Actual Configuration Parameters
    ...    ne=PLMN-PLMN/MRBTS-${vDU_id}    dist_name=PLMN-PLMN/${CELL_DN}   &{Param_Dic_NA}
    Sleep    30s
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
    ...    ${VES_CCN_msgs}    ${CELL_DN}    vDu    ${vesSourceName}    ${dnPrefix}    ${du_ip}    replace    ${Param_Dic}
    log    ${target_VES_CCN_msg}
    should be true    "${target_VES_CCN_msg.__len__()}">="${1}"

Step ${index}: Provision Delta Plan SyVe With Update Parameter
    Log To Console   Step ${index}: Provision Delta Plan SyVe With Update Parameter
    ${time}    Get Time    epoch
    Set Test Variable    ${name}    CB006092-E_002-Update_Param_${time}
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}    NetAct Create Plan    ${name}    Automation for CB006092-E_002-Update_Param
    Append To List    ${NAMES_OF_SYVE_PLAN}    ${name}
    netact.Create Managed Object    plan=${plan}    meta_class=${Param_Dic_Prop['meta_class']}
    ...    meta_version=${Param_Dic_Prop['meta_version']}    mo_id=PLMN-PLMN/${CELL_DN}    operation=Update    &{Param_Dic_Update}
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=${name}.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    plan_name=${name}    operation_type=plan
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    NetAct Provision Plan    plan_name=${name}    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Wait Until Keyword Succeeds    10min    30s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0

Step ${index}: Check Parameter Be Updated On NetAct And ONAP
    Log To Console    Step ${index}: Check Parameter Be Updated On NetAct And ONAP
    ${Param_Value_NA}    convert to string    ${Param_Value_Update}
    ${Param_Dic_Update_NA}    Create Dictionary    ${Param_Name}=${Param_Value_NA}
    Wait Until Keyword Succeeds    3x    15s    NetAct Check Actual Configuration Parameters
    ...    ne=PLMN-PLMN/MRBTS-${vDU_id}    dist_name=PLMN-PLMN/${CELL_DN}    &{Param_Dic_Update_NA}
    Sleep    30s
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
    ...    ${VES_CCN_msgs}    ${CELL_DN}    vDu    ${vesSourceName}    ${dnPrefix}    ${du_ip}    replace    ${Param_Dic_Update}
    log    ${target_VES_CCN_msg}
    should be true    "${target_VES_CCN_msg.__len__()}">="${1}"

Step ${index}: Provision Delta Plan SyVe With Delete Parameter
    Log To Console    Step ${index}: Provision Delta Plan SyVe With Delete Parameter
    ${time}    Get Time    epoch
    Set Test Variable    ${name}    CB006092-E_002-Delete_Param_${time}
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}    NetAct Create Plan    ${name}    Automation for CB006092-E_002-Delete_Param
    Append To List    ${NAMES_OF_SYVE_PLAN}    ${name}
    netact.Create Managed Object    plan=${plan}    meta_class=${Param_Dic_Prop['meta_class']}
    ...    meta_version=${Param_Dic_Prop['meta_version']}    mo_id=PLMN-PLMN/${CELL_DN}    operation=Update    &{Param_Dic_Delete}
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=${name}.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    plan_name=${name}    operation_type=plan
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    NetAct Provision Plan    plan_name=${name}    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Set Test Variable    ${RECOVERY_FLAG}    ${False}
    Wait Until Keyword Succeeds    10min    30s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0

Step ${index}: Check Parameter Be Deleted On NetAct And ONAP
    Log To Console    Step ${index}: Check Parameter Be Deleted On NetAct And ONAP
    ${Param_List}    Create List    ${Param_Name}
    Wait Until Keyword Succeeds    3x    15s    Check Actual Configuration Not Existed Parameters    PLMN-PLMN/${CELL_DN}   ${Param_List}
    Sleep    30s
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    ${del_list}    Create List    ${Param_Name}
    ${Param_Dic_De}    Create Dictionary    !DELETE!=${del_list}
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN
    ...    ${VES_CCN_msgs}    ${CELL_DN}    vDu    ${vesSourceName}    ${dnPrefix}    ${du_ip}    replace    ${Param_Dic_De}
    log    ${target_VES_CCN_msg}
    should be true    "${target_VES_CCN_msg.__len__()}">="${1}"

Step ${index}: Lock Unlock One RMOD And Check CCN
    Log To Console    Step ${index}: Lock Unlock One RMOD And Check CCN
    ${rmods_list}    Get RMOD ID List
    ${rmod_id}    Evaluate    random.choice(${rmods_list})    modules=random, sys
    ${rmod_id_list}    Create List    ${rmod_id}
    #check CCN on ves
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    Lock RU With Ru Id And Check Status In vDU    ${rmod_id_list}
    Sleep    30s
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    ${Lock_RF_Dic}    Create Dictionary    administrativeState=Locked
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN    ${VES_CCN_msgs}    MRBTS-${vDU_id}/EQM-1/APEQM-1/RMOD-${rmod_id}
    ...    vDu    ${vesSourceName}    ${dnPrefix}    ${du_ip}    replace    ${Lock_RF_Dic}
    log    ${target_VES_CCN_msg}
    should be true    "${target_VES_CCN_msg.__len__()}">="${1}"
    #check CCN on ves
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    Unlock RU With Ru Id And Check Status In vDU    ${rmod_id_list}
    Sleep    30s
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    ${Unlock_RF_Dic}    Create Dictionary    administrativeState=Unlocked
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN    ${VES_CCN_msgs}    MRBTS-${vDU_id}/EQM-1/APEQM-1/RMOD-${rmod_id}
    ...    vDu    ${vesSourceName}    ${dnPrefix}    ${du_ip}    replace    ${Unlock_RF_Dic}
    log    ${target_VES_CCN_msg}
    should be true    "${target_VES_CCN_msg.__len__()}">="${1}"

Step ${index}: Reset One RMOD And Check CCN
    Log To Console    Step ${index}: Reset One RMOD And Check CCN
    ${rmods_list}    Get RMOD ID List
    ${rmod_id}    Evaluate    random.choice(${rmods_list})    modules=random, sys
    ${rmod_id_list}    Create List    ${rmod_id}
    #check CCN on ves
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    Reset RUs By Rest In vDU    ${rmod_id_list}
    Sleep    30s
    Wait Until Keyword Succeeds    10min    30s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Sleep    30s
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    log    ${VES_CCN_msgs}
    ${Unlock_RF_Dic}    Create Dictionary    administrativeState=Unlocked
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN    ${VES_CCN_msgs}    MRBTS-${vDU_id}/EQM_R-1/APEQM_R-1/RMOD_R-${rmod_id}
    ...    vDu    ${vesSourceName}    ${dnPrefix}    ${du_ip}    replace    ${Unlock_RF_Dic}
    log    ${target_VES_CCN_msg}
    should be true    "${target_VES_CCN_msg.__len__()}">="${1}"

Check Actual Configuration Not Existed MOC
    [Arguments]    ${dist_name}
    Log    Check Actual Configuration Not Existed MOC    console=True
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${status}=    Run Keyword And Return Status    netact.Export Configuration    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs
    ...    file_name=check_netact_plan_delete_MOC.xml    dist_names=${dist_name}    ui_values=false
    ${scf_xml}=    L_XML.Parse Xml    ${TEST_LOG_DIRECTORY}/NetActLogs/check_netact_plan_delete_MOC.xml
    ${object}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@distName="${dist_name}"]
    ${obj_count}    Get Length    ${object}
    Should Be Equal As Integers    ${obj_count}    ${0}

Check Actual Configuration Not Existed Parameters
    [Arguments]    ${dist_name}    ${param_list}
    Log    Check Actual Configuration Not Existed Parameters    console=True
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${status}=    Run Keyword And Return Status    netact.Export Configuration    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs
    ...    file_name=check_netact_plan_delete_param.xml    dist_names=${dist_name}    ui_values=false
    ${scf_xml}=    L_XML.Parse Xml    ${TEST_LOG_DIRECTORY}/NetActLogs/check_netact_plan_delete_param.xml
    ${object}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@distName="${dist_name}"]
    ${obj_count}    Get Length    ${object}
    Should Be Equal As Integers    ${obj_count}    ${1}
    FOR    ${param}    IN    @{param_list}
        ${parameter}    L_XML.Get Elements     ${scf_xml}
        ...    .//managedObject[@distName="${dist_name}"]/p[@name="${param}"]
        ${parameter_count}    Get Length    ${parameter}
        Should Be Equal As Integers    ${parameter_count}    ${0}
    END

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

Case Postcondition
    Log To Console    Case Postcondition
    ${out}   Run Keyword If    ${RECOVERY_FLAG}
    ...    Parameter Operation    operation=full_commission    product_type=vdu    scf_path=${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    Wait Until Keyword Succeeds    20min    30s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Common Test Teardown For AIC
    Teardown NetAct