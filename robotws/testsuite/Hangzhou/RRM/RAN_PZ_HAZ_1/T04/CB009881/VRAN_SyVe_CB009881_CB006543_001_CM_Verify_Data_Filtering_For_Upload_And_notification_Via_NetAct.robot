*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
...   Description: This robot cases is for [1.0] vRAN_SyVe_CB009881_CB006543_001_CM_Verify data filtering for
...    upload&notification operation from NMS
Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Library             SSHLibrary




*** Keywords ***

VRAN_SyVe_CB009881_CB006543_001_CM_Verify_Data_Filtering_For_Upload_And_notification_Via_NetAct
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    Case steps refer to VRAN_SyVe_CB007669-E_001_CM_Operator_Configures_Customized_Names_for_NE_and_Cells_via_NOM
    ...    history change: <date>,<who>,<what and how>
    ...    28.12.2022, yuyan.xu@nokia-sbell.com, draft
#    Modify FHGW Name via NetAct
    Modify gNB-vCU Name via NetAct
    Modify gNB-vDU Name via NetAct
    Modify vCU NRCELL Name via NetAct
    Modify vDU NRCELL Name via NetAct

Case Precondition
    [Arguments]    ${ReIntegrate_vCU}=False    ${ReIntegrate_vDU}=False
    Log To Console    Case Precondition
    Common Test Setup For AIC
    ${NEW_PLAN_NAME}   Get Test Case Name
    Set Test Variable  ${NEW_PLAN_NAME}
    Setup NetAct    ${NETACT}
    AIC_NetAct.Get FHGW Id
    #ReIntegrate NE
    Run Keyword If    ${ReIntegrate_vCU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${cu_ip}    PLMN-PLMN/MRBTS-${vCU_id}    ${cu_release}    ${cu_mr}
    Run Keyword If    ${ReIntegrate_vDU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${du_ip}    PLMN-PLMN/MRBTS-${vDU_id}    ${du_release}    ${du_mr}

Case Postcondition
    Log To Console    Case Postcondition
    Common Test Teardown For AIC
    vDU Login By Rest
    Run Keyword And Ignore Error    vDU Logout By Rest
    Teardown NetAct

Modify FHGW Name via NetAct
    ${delta_plan_name_FHGW}    Set Variable    FHGW-${FHGW_id}-delta-plan
    ${integrated_ids_FHGW}    Create List    FHGW-${FHGW_id}
    #CM Upload
    NetAct CM Upload    dist_names=PLMN-PLMN/FHGW-${FHGW_id}

    ##CM Parameter Upload NOM Open API    ${integrated_ids_FHGW}
    ${timestamp}    AIC_NetAct.Generate Formatted Timestamp
    Set Test Variable    ${delta_plan_path_FHGW}    ${TEST_LOG_DIRECTORY}/${delta_plan_name_FHGW}_${timestamp}.xml
    Set Test Variable    ${backup_delta_plan_path_FHGW}    ${TEST_LOG_DIRECTORY}/${delta_plan_name_FHGW}_backup_${timestamp}.xml
    ${fhgwName}    Generate Random OCFDN    FHGW-${FHGW_id}
    Generate XML Plan For Name Update    ${delta_plan_path_FHGW}    ${delta_plan_name_FHGW}    ${backup_delta_plan_path_FHGW}
    ...    PLMN-PLMN/FHGW-${FHGW_id}    fhgwName    ${fhgwName}

    NetAct Import Plan    local_dir=${TEST_LOG_DIRECTORY}    file_name=${delta_plan_name_FHGW}_${timestamp}.xml
    ...    plan_name=${delta_plan_name_FHGW}_${timestamp}
    NetAct Provision Plan    plan_name=${delta_plan_name_FHGW}_${timestamp}    dist_names=PLMN-PLMN/FHGW-${FHGW_id}
    ...    backup_plan_name=${delta_plan_name_FHGW}_backup_${timestamp}    create_backup_plan=True    provisioning_operation=activate
    #Wait Until Keyword Succeeds    10x    10s    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/FHGW-${FHGW_id}
    #...    dist_name=PLMN-PLMN/FHGW-${FHGW_id}    fhgwName=${fhgwName}
    Log To Console    FHGW Name update successfully!

    NetAct Provision Plan    plan_name=${delta_plan_name_FHGW}_backup_${timestamp}    dist_names=PLMN-PLMN/FHGW-${FHGW_id}
    ...    backup_plan_name=None    create_backup_plan=False    provisioning_operation=activate
    #Wait Until Keyword Succeeds    10x    10s    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/FHGW-${FHGW_id}
    #...    dist_name=PLMN-PLMN/FHGW-${FHGW_id}    fhgwName=${original_value}
    Log To Console    FHGW Name recovery successfully!

Modify gNB-vCU Name via NetAct
    ${delta_plan_name_vCU}          Set Variable    vCU-${vCU_id}-delta-plan
    ${integrated_ids_vCU}    Create List    MRBTS-${vCU_id}

    #CM Upload
    Clean Plan From NetAct Before Upload    ${vCU_id}
    ${parameters}    Create Dictionary    -lteHwContentInUse=${True}    -sranBtsHwContentInUse=${True}
    NetAct CM Upload    dist_names=PLMN-PLMN/MRBTS-${vCU_id}    parameters=${parameters}    check_feedback=True
    Check All MO Type In Uploaded CM Plan    ${vCU_id}

    ${timestamp}    AIC_NetAct.Generate Formatted Timestamp
    Set Test Variable    ${delta_plan_path_vCU}    ${TEST_LOG_DIRECTORY}/${delta_plan_name_vCU}_${timestamp}.xml
    Set Test Variable    ${backup_delta_plan_path_vCU}    ${TEST_LOG_DIRECTORY}/${delta_plan_name_vCU}_backup_${timestamp}.xml
    ${btsName}    Generate Random OCFDN    MRBTS-${vCU_id}
    Generate XML Plan For Name Update    ${delta_plan_path_vCU}    ${delta_plan_name_vCU}    ${backup_delta_plan_path_vCU}
    ...    PLMN-PLMN/MRBTS-${vCU_id}    btsName    ${btsName}

    NetAct Import Plan    local_dir=${TEST_LOG_DIRECTORY}    file_name=${delta_plan_name_vCU}_${timestamp}.xml
    ...    plan_name=${delta_plan_name_vCU}_${timestamp}
    #vCU Provision
    NetAct Provision Plan    plan_name=${delta_plan_name_vCU}_${timestamp}    dist_names=PLMN-PLMN/MRBTS-${vCU_id}
    ...    backup_plan_name=${delta_plan_name_vCU}_backup_${timestamp}    create_backup_plan=True    provisioning_operation=activate
    Wait Until Keyword Succeeds    10x    10s    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vCU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vCU_id}    btsName=${btsName}
    Check CM Parameter Value From vCU Actual Plan    MRBTS-${vCU_id}    btsName    ${btsName}
    Log To Console    vCU Name update successfully!

    NetAct Provision Plan    plan_name=${delta_plan_name_vCU}_backup_${timestamp}    dist_names=PLMN-PLMN/MRBTS-${vCU_id}
    ...    backup_plan_name=None    create_backup_plan=False    provisioning_operation=activate
    Wait Until Keyword Succeeds    10x    10s    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vCU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vCU_id}    btsName=${original_value}
    Check CM Parameter Value From vCU Actual Plan    MRBTS-${vCU_id}    btsName    ${original_value}
    Log To Console    vCU Name recovery successfully!

Modify gNB-vDU Name via NetAct
    ${delta_plan_name_vDU}          Set Variable    vDU-${vDU_id}-delta-plan
    ${integrated_ids_vDU}    Create List    MRBTS-${vDU_id}

    #CM Upload
    Clean Plan From NetAct Before Upload    ${vDU_id}
    ${parameters}    Create Dictionary    -lteHwContentInUse=${True}    -sranBtsHwContentInUse=${True}
    NetAct CM Upload    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    parameters=${parameters}    check_feedback=True
    Check All MO Type In Uploaded CM Plan    ${vDU_id}
    Check MO Type In Uploaded HW Plan    ${vDU_id}

    ${timestamp}    AIC_NetAct.Generate Formatted Timestamp
    Set Test Variable    ${delta_plan_path_vDU}    ${TEST_LOG_DIRECTORY}/${delta_plan_name_vDU}_${timestamp}.xml
    Set Test Variable    ${backup_delta_plan_path_vDU}    ${TEST_LOG_DIRECTORY}/${delta_plan_name_vDU}_backup_${timestamp}.xml
    ${btsName}    Generate Random OCFDN    MRBTS-${vDU_id}
    Generate XML Plan For Name Update     ${delta_plan_path_vDU}    ${delta_plan_name_vDU}    ${backup_delta_plan_path_vDU}
    ...    PLMN-PLMN/MRBTS-${vDU_id}    btsName    ${btsName}

    NetAct Import Plan    local_dir=${TEST_LOG_DIRECTORY}    file_name=${delta_plan_name_vDU}_${timestamp}.xml
    ...    plan_name=${delta_plan_name_vDU}_${timestamp}
    #vDU Provision
    NetAct Provision Plan    plan_name=${delta_plan_name_vDU}_${timestamp}    dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    ...    backup_plan_name=${delta_plan_name_vDU}_backup_${timestamp}    create_backup_plan=True    provisioning_operation=activate
    Wait Until Keyword Succeeds    10x    10s    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vDU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vDU_id}    btsName=${btsName}
    Check CM Parameter Value From vDU Actual Plan    MRBTS-${vDU_id}    btsName    ${btsName}
    Log To Console    vDU Name update successfully!

    NetAct Provision Plan    plan_name=${delta_plan_name_vDU}_backup_${timestamp}    dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    ...    backup_plan_name=None    create_backup_plan=False    provisioning_operation=activate
    Wait Until Keyword Succeeds    10x    10s    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vDU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vDU_id}    btsName=${original_value}
    Check CM Parameter Value From vDU Actual Plan    MRBTS-${vDU_id}    btsName    ${original_value}
    Log To Console    vDU Name recovery successfully!


Modify vCU NRCELL Name via NetAct
    ${delta_plan_name_vCU}          Set Variable    vCU-${vCU_id}-delta-plan
    ${integrated_ids_vCU}    Create List    MRBTS-${vCU_id}

    #CM Upload
    NetAct CM Upload    dist_names=PLMN-PLMN/MRBTS-${vCU_id}
    ${timestamp}    AIC_NetAct.Generate Formatted Timestamp
    Set Test Variable    ${delta_plan_path_vCU}    ${TEST_LOG_DIRECTORY}/${delta_plan_name_vCU}_${timestamp}.xml
    Set Test Variable    ${backup_delta_plan_path_vCU}    ${TEST_LOG_DIRECTORY}/${delta_plan_name_vCU}_backup_${timestamp}.xml
    ${cellName}    Generate Random OCFDN    MRBTS-${vCU_id}-NRCELL-0
    Generate XML Plan For Name Update     ${delta_plan_path_vCU}    ${delta_plan_name_vCU}    ${backup_delta_plan_path_vCU}
    ...    PLMN-PLMN/MRBTS-${vCU_id}/NRBTS-${NRBTS_ID}/NRCELL-0    cellName    ${cellName}

    NetAct Import Plan    local_dir=${TEST_LOG_DIRECTORY}    file_name=${delta_plan_name_vCU}_${timestamp}.xml
    ...    plan_name=${delta_plan_name_vCU}_${timestamp}

    #vCU Provision
    NetAct Provision Plan    plan_name=${delta_plan_name_vCU}_${timestamp}    dist_names=PLMN-PLMN/MRBTS-${vCU_id}
    ...    backup_plan_name=${delta_plan_name_vCU}_backup_${timestamp}    create_backup_plan=True    provisioning_operation=activate
    Wait Until Keyword Succeeds    10x    10s    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vCU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vCU_id}/NRBTS-${NRBTS_ID}/NRCELL-0    cellName=${cellName}
    Check CM Parameter Value From vCU Actual Plan    MRBTS-${vCU_id}/NRBTS-${NRBTS_ID}/NRCELL-0    cellName    ${cellName}
    Log To Console    vCU NRCELL Name update successfully!

    NetAct Provision Plan    plan_name=${delta_plan_name_vCU}_backup_${timestamp}    dist_names=PLMN-PLMN/MRBTS-${vCU_id}
    ...    backup_plan_name=None    create_backup_plan=False    provisioning_operation=activate
    Wait Until Keyword Succeeds    10x    10s    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vCU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vCU_id}/NRBTS-${NRBTS_ID}/NRCELL-0    cellName=${original_value}
    Check CM Parameter Value From vCU Actual Plan    MRBTS-${vCU_id}/NRBTS-${NRBTS_ID}/NRCELL-0    cellName    ${original_value}
    Log To Console    vCU NRCELL Name recovery successfully!


Modify vDU NRCELL Name via NetAct
    ${delta_plan_name_vDU}     Set Variable    vDU-${vDU_id}-delta-plan
    ${integrated_ids_vDU}    Create List    MRBTS-${vDU_id}

    #CM Upload
    NetAct CM Upload    dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    ${timestamp}    AIC_NetAct.Generate Formatted Timestamp
    Set Test Variable    ${delta_plan_path_vDU}    ${TEST_LOG_DIRECTORY}/${delta_plan_name_vDU}_${timestamp}.xml
    Set Test Variable    ${backup_delta_plan_path_vDU}    ${TEST_LOG_DIRECTORY}/${delta_plan_name_vDU}_backup_${timestamp}.xml
    ${cellName}    Generate Random OCFDN    MRBTS-${vDU_id}-NRCELL-0
    Generate XML Plan For Name Update     ${delta_plan_path_vDU}    ${delta_plan_name_vDU}    ${backup_delta_plan_path_vDU}
    ...    PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-0    cellName    ${cellName}

    NetAct Import Plan    local_dir=${TEST_LOG_DIRECTORY}    file_name=${delta_plan_name_vDU}_${timestamp}.xml
    ...    plan_name=${delta_plan_name_vDU}_${timestamp}
    #vDU Provision
    NetAct Provision Plan    plan_name=${delta_plan_name_vDU}_${timestamp}    dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    ...    backup_plan_name=${delta_plan_name_vDU}_backup_${timestamp}    create_backup_plan=True    provisioning_operation=activate
    Wait Until Keyword Succeeds    10x    10s    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vDU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-0    cellName=${cellName}
    Check CM Parameter Value From vDU Actual Plan    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-0    cellName    ${cellName}
    Log To Console    vDU NRCELL Name update successfully!

    NetAct Provision Plan    plan_name=${delta_plan_name_vDU}_backup_${timestamp}    dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    ...    backup_plan_name=None    create_backup_plan=False    provisioning_operation=activate
    Wait Until Keyword Succeeds    10x    10s    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vDU_id}
    ...    dist_name=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-0    cellName=${original_value}
    Check CM Parameter Value From vDU Actual Plan    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-0    cellName    ${original_value}
    Log To Console    vDU NRCELL Name recovery successfully!


Generate XML Plan For Name Update
    [Arguments]   ${plan_path}     ${plan_name}    ${backup_plan_path}
    ...    ${distName}    ${param}    ${value}
    ${export_timestamp}    AIC_NetAct.Generate Formatted Timestamp
    ${output_actuals_file}    Set Variable     ${TEST_LOG_DIRECTORY}/actual_${export_timestamp}.xml

    #CM Export
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}    file_name=actual_${export_timestamp}.xml
    ...    dist_names=${distName}    plan_name=${plan_name}    operation_type=actual
    ##CM Export Actual Configuration NOM Open API    ${integrated_ids}    ${output_actuals_file}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${output_actuals_file}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${distName}"]
    ${status}    ${current_value}    Run Keyword And Ignore Error   L_XML.Get Element Text    ${scf_xml}
    ...    .//managedObject[@distName="${distName}"]/p[@name="${param}"]
    ${original_value}    Set Variable If    '${status}'=='PASS'    ${current_value}    ${EMPTY}
    ${meta_version}   Set Variable    ${MO_items['version']}
    ${meta_class}    Set Variable    ${MO_items['class']}
    ${xml1}    Set Variable    <?xml version="1.0" encoding="UTF-8" standalone="yes"?><raml version="2.1" xmlns="raml21.xsd">
    ${xml2}    Set Variable    <cmData type="plan" scope="changes" name="${plan_name}"><header>
    ${xml3}    Set Variable    <log action="update" dateTime="2021-04-12T15:29:20+03:00">ModifyingMO</log></header>
    ${xml4}    Set Variable    <managedObject class="${meta_class}" version="${meta_version}" distName="${distName}" operation="update">
    ${xml5}    Set Variable    <p name="${param}">${value}</p></managedObject></cmData></raml>
    ${xml6}    Set Variable    <cmData type="plan" scope="changes" name="${plan_name}_backup"><header>
    ${xml7}    Set Variable    <p name="${param}">${original_value}</p></managedObject></cmData></raml>
    ${xmlfile}    Set Variable    ${xml1}${xml2}${xml3}${xml4}${xml5}
    ${backupxmlfile}    Set Variable    ${xml1}${xml6}${xml3}${xml4}${xml7}
    Create File    ${plan_path}    ${xmlfile}
    Create File    ${backup_plan_path}    ${backupxmlfile}
    Set Test Variable    ${original_value}

Check CM Parameter Value From vCU Actual Plan
    [Arguments]     ${mo_dn}    ${para_name}    ${expected_value}
    ${value}    Get Parameters Of Current Plan Via Rest    parameter_name=${para_name}   mo_dn=${mo_dn}
    ${actual_value}    Set Variable If    '${value}'=='None'    ${EMPTY}    ${value}
    Should Be True    "${actual_value}" == "${expected_value}"
    Logout To vCU By Rest

Check CM Parameter Value From vDU Actual Plan
    [Arguments]     ${mo_dn}    ${para_name}   ${expected_value}
    vDU Login By Rest
    ${value}    Online Get VDU Parameter Value    ${mo_dn}    ${para_name}
    ${actual_value}    Set Variable If    '${value}'=='None'    ${EMPTY}    ${value}
    Should Be True    "${actual_value}" == "${expected_value}"
    vDU Logout By Rest

Generate Random OCFDN
    [Arguments]     ${NE_ID}
    ${special_charactor}   Create List   ~    !    @    \#    $    %    ^    *    ()    -    _    +
    ...    \=    {}    []    \    |    :    ;    ""    ''    ,    .    /    ${EMPTY}
    ${fixed_str}    Set Variable    ${NE_ID}_autotest
    ${OCFDN}    Set Variable   ${fixed_str}
    FOR    ${index}    IN RANGE    0    8
        ${tmp_str1}    Evaluate    random.choice(${special_charactor})    modules=random, sys
        ${OCFDN}      Set Variable    ${OCFDN}${tmp_str1}
    END
    ${current_str_len}    Get Length    ${OCFDN}
    ${cnt}    Evaluate    80-${current_str_len}-1
    ${tmp_str2}    Generate Random String    ${cnt}
    ${OCFDN}    Set Variable    ${OCFDN}_${tmp_str2}
    [Return]     ${OCFDN}

Check All MO Type In Uploaded CM Plan
    [Arguments]     ${current_ne_id}
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    root    arthur
    SSHLibrary.Write    cd /var/opt/nokia/oss/global/cmmne3s/work
    SSHLibrary.Write    ls | grep -E MRBTS${current_ne_id}_"[0-9]+"_UL.xml.gz
    ${output}    SSHLibrary.Read    delay=1s
    Should Contain    ${output}    _UL.xml.gz
    ${tmp_file_name}    Fetch From Right     ${output}    MRBTS
    ${tmp_file_name}    Fetch From Left    ${tmp_file_name}    .xml.gz
    ${cm_file_name}    Set Variable    MRBTS${tmp_file_name}.xml.gz
    SSHLibrary.Write    gunzip ${cm_file_name}
    SSHLibrary.Write    cat MRBTS${tmp_file_name}.xml
    ${filecontent}    SSHLibrary.Read    delay=1s
    ${MO_MRBTS}    Run Keyword And Return Status    Should Contain    ${filecontent}    5g:MRBTS
    ${MO_EQM_R}    Run Keyword And Return Status    Should Contain    ${filecontent}    eqmr:EQM_R
    ${MO_NRBTS}    Run Keyword And Return Status    Should Contain    ${filecontent}    nrbts:NRBTS
    ${MO_MNL}    Run Keyword And Return Status    Should Contain    ${filecontent}    mnl:MNL
    ${MO_TNL}    Run Keyword And Return Status    Should Contain    ${filecontent}    tnl:TNL
    Should Be True    ${MO_MRBTS} and ${MO_EQM_R} and ${MO_NRBTS} and ${MO_MNL} and ${MO_TNL}
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Check MO Type In Uploaded HW Plan
    [Arguments]     ${current_ne_id}
    [Documentation]   Keywrod for checking hw config In uploaded  plan
    ...   It only suitable for vDU since only vDU has HW plan.
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    root    arthur
    SSHLibrary.Write    cd /var/opt/nokia/oss/global/cmmne3s/work
    SSHLibrary.Write    ls | grep -E MRBTS${current_ne_id}_"[0-9]+"_HW_UL.xml.gz
    ${output}    SSHLibrary.Read    delay=1s
    Should Contain    ${output}    _HW_UL.xml.gz
    ${tmp_file_name}    Fetch From Right     ${output}    MRBTS
    ${tmp_file_name}    Fetch From Left    ${tmp_file_name}    .xml.gz
    ${hw_file_name}    Set Variable    MRBTS${tmp_file_name}.xml.gz
    SSHLibrary.Write    gunzip ${hw_file_name}
    SSHLibrary.Write    cat MRBTS${tmp_file_name}.xml
    ${filecontent}    SSHLibrary.Read    delay=1s
    ${MO_MRBTS}    Run Keyword And Return Status    Should Contain    ${filecontent}    eqm.hw:INVUNIT
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

Clean Plan From NetAct Before Upload
    [Arguments]     ${current_ne_id}
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    root    arthur
    SSHLibrary.Write    cd /var/opt/nokia/oss/global/cmmne3s/work
    SSHLibrary.Write    sudo rm -rf MRBTS${current_ne_id}_*.*
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection


