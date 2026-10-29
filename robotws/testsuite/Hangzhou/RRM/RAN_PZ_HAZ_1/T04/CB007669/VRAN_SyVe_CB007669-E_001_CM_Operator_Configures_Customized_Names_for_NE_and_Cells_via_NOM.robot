*** Settings ***
Documentation
...   Author: lixin.kang@nokia-sbell.com
...   Description: This robot cases is for VRAN_SyVe_CB007669-E_001_CM_Operator configures customized names
...    for NE/cells using NMS

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
${plan_path}    /home/ute/Auto5G/robotws/testsuite/Hangzhou/AIC/RAN_PZ_HAZ_1/HAZ11/Plan

*** Keywords ***

VRAN_SyVe_CB007669-E_001_CM_Operator_Configures_Customized_Names_for_NE_and_Cells_via_NOM
    [Documentation]
    ...    Author: lixin.kang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    15.9.2022, lixin.kang@nokia-sbell.com, draft
    #Modify FHGW Name via NOM
    Modify gNB-vCU Name via NOM
    Modify gNB-vDU Name via NOM
    Modify vCU NRCELL Name via NOM
    Modify vDU NRCELL Name via NOM

Case Precondition
    [Arguments]    ${ReIntegrate_FHGW}=False     ${ReIntegrate_vCU}=False
    ...    ${ReIntegrate_vDU}=False
    Log To Console    Case Precondition
    Common Test Setup For AIC
    ${NEW_PLAN_NAME}   Get Test Case Name
    Set Test Variable  ${NEW_PLAN_NAME}
    Setup NOM
    Get FHGW Id

    #ReIntegrate NE
    ${timestamp}    Run Keyword If    ${ReIntegrate_FHGW}    Generate Formatted Timestamp
    ${integrate_plan_path_FHGW}    Run Keyword If    ${ReIntegrate_FHGW}
    ...    Set Variable    ${plan_path}/FHGW-${FHGW_id}-integration-plan.xml
    ${integrate_plan_name_FHGW}    Run Keyword If    ${ReIntegrate_FHGW}
    ...    Set Variable    FHGW-${FHGW_id}-integration-plan
    Run Keyword If    ${ReIntegrate_FHGW}
    ...    NOM Integrate NE    ${integrate_plan_path_FHGW}    ${integrate_plan_name_FHGW}_${timestamp}


    ${timestamp}    Run Keyword If    ${ReIntegrate_vCU}    Generate Formatted Timestamp
    ${integrate_plan_path_vCU}    Run Keyword If    ${ReIntegrate_vCU}
    ...    Set Variable    ${plan_path}/vCU-${vCU_id}-integration-plan.xml
    ${integrate_plan_name_vCU}    Run Keyword If    ${ReIntegrate_vCU}
    ...    Set Variable    vCU-${vCU_id}-integration-plan
    Run Keyword If    ${ReIntegrate_vCU}
    ...    NOM Integrate NE    ${integrate_plan_path_vCU}    ${integrate_plan_name_vCU}_${timestamp}


    ${timestamp}    Run Keyword If    ${ReIntegrate_vDU}    Generate Formatted Timestamp
    ${integrate_plan_path_vDU}    Run Keyword If    ${ReIntegrate_vDU}
    ...    Set Variable    ${plan_path}/vDU-${vDU_id}-integration-plan.xml
    ${integrate_plan_name_vDU}    Run Keyword If    ${ReIntegrate_vDU}
    ...    Set Variable    vDU-${vDU_id}-integration-plan
    Run Keyword If    ${ReIntegrate_vDU}
    ...    NOM Integrate NE    ${integrate_plan_path_vDU}    ${integrate_plan_name_vDU}_${timestamp}

Case Postcondition
    Log To Console    Case Postcondition
    Return From Keyword
    Common Test Teardown For AIC
    vDU Login By Rest
    Run Keyword And Ignore Error    vDU Logout By Rest
    Teardown NOM

Modify FHGW Name via NOM
    ${delta_plan_name_FHGW}    Set Variable    FHGW-${FHGW_id}-delta-plan
    ${integrated_ids_FHGW}    Create List    FHGW-${FHGW_id}

    #CM Upload
    CM Parameter Upload NOM Open API    ${integrated_ids_FHGW}
    ${timestamp}    Generate Formatted Timestamp
    Set Test Variable    ${delta_plan_path_FHGW}    ${TEST_LOG_DIRECTORY}/${delta_plan_name_FHGW}_${timestamp}.xml
    Set Test Variable    ${backup_delta_plan_path_FHGW}    ${TEST_LOG_DIRECTORY}/${delta_plan_name_FHGW}_backup_${timestamp}.xml
    ${fhgwName}    Generate Random OCFDN    FHGW-${FHGW_id}
    Generate XML Plan For Name Update    ${delta_plan_path_FHGW}    ${delta_plan_name_FHGW}    ${backup_delta_plan_path_FHGW}
    ...    ${integrated_ids_FHGW}    FHGW-${FHGW_id}    fhgwName    ${fhgwName}

    CM Plan Import NOM Open API    ${delta_plan_path_FHGW}    ${delta_plan_name_FHGW}_${timestamp}

    #FHGW Provision
    CM Plan Provision NOM Open API    ${delta_plan_name_FHGW}_${timestamp}
    Wait Until Keyword Succeeds    10x    10s    Check CM Parameter Value From NOM Actual Plan
    ...    ${integrated_ids_FHGW}    FHGW-${FHGW_id}    fhgwName=${fhgwName}

    Log To Console    FHGW Name update successfully!

    CM Plan Import NOM Open API    ${backup_delta_plan_path_FHGW}    ${delta_plan_name_FHGW}_backup_${timestamp}
    CM Plan Provision NOM Open API    ${delta_plan_name_FHGW}_backup_${timestamp}
    Wait Until Keyword Succeeds    10x    10s    Check CM Parameter Value From NOM Actual Plan
    ...    ${integrated_ids_FHGW}    FHGW-${FHGW_id}    fhgwName=${original_value}
    Log To Console    FHGW Name recovery successfully!

Modify gNB-vCU Name via NOM
    ${delta_plan_name_vCU}          Set Variable    vCU-${vCU_id}-delta-plan
    ${integrated_ids_vCU}    Create List    MRBTS-${vCU_id}

    #CM Upload
    CM Parameter Upload NOM Open API    ${integrated_ids_vCU}
    ${timestamp}    Generate Formatted Timestamp
    Set Test Variable    ${delta_plan_path_vCU}    ${TEST_LOG_DIRECTORY}/${delta_plan_name_vCU}_${timestamp}.xml
    Set Test Variable    ${backup_delta_plan_path_vCU}    ${TEST_LOG_DIRECTORY}/${delta_plan_name_vCU}_backup_${timestamp}.xml
    ${btsName}    Generate Random OCFDN    MRBTS-${vCU_id}
    Generate XML Plan For Name Update    ${delta_plan_path_vCU}    ${delta_plan_name_vCU}    ${backup_delta_plan_path_vCU}
    ...    ${integrated_ids_vCU}    MRBTS-${vCU_id}    btsName    ${btsName}
    CM Plan Import NOM Open API    ${delta_plan_path_vCU}    ${delta_plan_name_vCU}_${timestamp}

    #vCU Provision
    CM Plan Provision NOM Open API    ${delta_plan_name_vCU}_${timestamp}
    Wait Until Keyword Succeeds    10x    10s    Check CM Parameter Value From NOM Actual Plan
    ...    ${integrated_ids_vCU}    MRBTS-${vCU_id}    btsName=${btsName}
    Check CM Parameter Value From vCU Actual Plan    MRBTS-${vCU_id}    btsName    ${btsName}
    Log To Console    vCU Name update successfully!

    CM Plan Import NOM Open API    ${backup_delta_plan_path_vCU}    ${delta_plan_name_vCU}_backup_${timestamp}
    CM Plan Provision NOM Open API    ${delta_plan_name_vCU}_backup_${timestamp}
    Wait Until Keyword Succeeds    10x    10s    Check CM Parameter Value From NOM Actual Plan
    ...    ${integrated_ids_vCU}    MRBTS-${vCU_id}    btsName=${original_value}
    Check CM Parameter Value From vCU Actual Plan    MRBTS-${vCU_id}    btsName    ${original_value}
    Log To Console    vCU Name recovery successfully!

Modify gNB-vDU Name via NOM
    ${delta_plan_name_vDU}          Set Variable    vDU-${vDU_id}-delta-plan
    ${integrated_ids_vDU}    Create List    MRBTS-${vDU_id}

    #CM Upload
    CM Parameter Upload NOM Open API    ${integrated_ids_vDU}
    ${timestamp}    Generate Formatted Timestamp
    Set Test Variable    ${delta_plan_path_vDU}    ${TEST_LOG_DIRECTORY}/${delta_plan_name_vDU}_${timestamp}.xml
    Set Test Variable    ${backup_delta_plan_path_vDU}    ${TEST_LOG_DIRECTORY}/${delta_plan_name_vDU}_backup_${timestamp}.xml
    ${btsName}    Generate Random OCFDN    MRBTS-${vDU_id}
    Generate XML Plan For Name Update     ${delta_plan_path_vDU}    ${delta_plan_name_vDU}    ${backup_delta_plan_path_vDU}
    ...    ${integrated_ids_vDU}    MRBTS-${vDU_id}    btsName    ${btsName}
    CM Plan Import NOM Open API    ${delta_plan_path_vDU}    ${delta_plan_name_vDU}_${timestamp}

    #vDU Provision
    CM Plan Provision NOM Open API    ${delta_plan_name_vDU}_${timestamp}
    Wait Until Keyword Succeeds    10x    10s    Check CM Parameter Value From NOM Actual Plan
    ...    ${integrated_ids_vDU}    MRBTS-${vDU_id}    btsName=${btsName}
    Check CM Parameter Value From vDU Actual Plan    MRBTS-${vDU_id}    btsName    ${btsName}
    Log To Console    vDU Name update successfully!

    CM Plan Import NOM Open API    ${backup_delta_plan_path_vDU}    ${delta_plan_name_vDU}_backup_${timestamp}
    CM Plan Provision NOM Open API    ${delta_plan_name_vDU}_backup_${timestamp}
    Wait Until Keyword Succeeds    10x    10s    Check CM Parameter Value From NOM Actual Plan
    ...    ${integrated_ids_vDU}    MRBTS-${vDU_id}    btsName=${original_value}
    Check CM Parameter Value From vDU Actual Plan    MRBTS-${vDU_id}    btsName    ${original_value}
    Log To Console    vDU Name recovery successfully!

Modify vCU NRCELL Name via NOM
    ${delta_plan_name_vCU}          Set Variable    vCU-${vCU_id}-delta-plan
    ${integrated_ids_vCU}    Create List    MRBTS-${vCU_id}

    #CM Upload
    CM Parameter Upload NOM Open API    ${integrated_ids_vCU}
    ${timestamp}    Generate Formatted Timestamp
    Set Test Variable    ${delta_plan_path_vCU}    ${TEST_LOG_DIRECTORY}/${delta_plan_name_vCU}_${timestamp}.xml
    Set Test Variable    ${backup_delta_plan_path_vCU}    ${TEST_LOG_DIRECTORY}/${delta_plan_name_vCU}_backup_${timestamp}.xml
    ${cellName}    Generate Random OCFDN    MRBTS-${vCU_id}-NRCELL-1
    Generate XML Plan For Name Update     ${delta_plan_path_vCU}    ${delta_plan_name_vCU}    ${backup_delta_plan_path_vCU}
    ...    ${integrated_ids_vCU}     MRBTS-${vCU_id}/NRBTS-${NRBTS_ID}/NRCELL-1    cellName    ${cellName}
    CM Plan Import NOM Open API    ${delta_plan_path_vCU}    ${delta_plan_name_vCU}_${timestamp}

    #vCU Provision
    CM Plan Provision NOM Open API    ${delta_plan_name_vCU}_${timestamp}
    Wait Until Keyword Succeeds    10x    10s    Check CM Parameter Value From NOM Actual Plan
    ...    ${integrated_ids_vCU}    MRBTS-${vCU_id}/NRBTS-${NRBTS_ID}/NRCELL-1    cellName=${cellName}
    Check CM Parameter Value From vCU Actual Plan    MRBTS-${vCU_id}/NRBTS-${NRBTS_ID}/NRCELL-1    cellName    ${cellName}
    Log To Console    vCU NRCELL Name update successfully!

    CM Plan Import NOM Open API    ${backup_delta_plan_path_vCU}    ${delta_plan_name_vCU}_backup_${timestamp}
    CM Plan Provision NOM Open API    ${delta_plan_name_vCU}_backup_${timestamp}
    Wait Until Keyword Succeeds    10x    10s    Check CM Parameter Value From NOM Actual Plan
    ...    ${integrated_ids_vCU}    MRBTS-${vCU_id}/NRBTS-${NRBTS_ID}/NRCELL-1    cellName=${original_value}
    Check CM Parameter Value From vCU Actual Plan    MRBTS-${vCU_id}/NRBTS-${NRBTS_ID}/NRCELL-1    cellName    ${original_value}
    Log To Console    vCU NRCELL Name recovery successfully!

Modify vDU NRCELL Name via NOM
    ${delta_plan_name_vDU}     Set Variable    vDU-${vDU_id}-delta-plan
    ${integrated_ids_vDU}    Create List    MRBTS-${vDU_id}

    #CM Upload
    CM Parameter Upload NOM Open API    ${integrated_ids_vDU}
    ${timestamp}    Generate Formatted Timestamp
    Set Test Variable    ${delta_plan_path_vDU}    ${TEST_LOG_DIRECTORY}/${delta_plan_name_vDU}_${timestamp}.xml
    Set Test Variable    ${backup_delta_plan_path_vDU}    ${TEST_LOG_DIRECTORY}/${delta_plan_name_vDU}_backup_${timestamp}.xml
    ${cellName}    Generate Random OCFDN    MRBTS-${vDU_id}-NRCELL-1
    Generate XML Plan For Name Update     ${delta_plan_path_vDU}    ${delta_plan_name_vDU}    ${backup_delta_plan_path_vDU}
    ...    ${integrated_ids_vDU}     MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-1    cellName    ${cellName}
    CM Plan Import NOM Open API    ${delta_plan_path_vDU}    ${delta_plan_name_vDU}_${timestamp}

    #vDU Provision
    CM Plan Provision NOM Open API    ${delta_plan_name_vDU}_${timestamp}
    Wait Until Keyword Succeeds    10x    10s    Check CM Parameter Value From NOM Actual Plan
    ...    ${integrated_ids_vDU}    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-1    cellName=${cellName}
    Check CM Parameter Value From vDU Actual Plan    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-1    cellName    ${cellName}
    Log To Console    vDU NRCELL Name update successfully!

    CM Plan Import NOM Open API    ${backup_delta_plan_path_vDU}    ${delta_plan_name_vDU}_backup_${timestamp}
    CM Plan Provision NOM Open API    ${delta_plan_name_vDU}_backup_${timestamp}
    Wait Until Keyword Succeeds    10x    10s    Check CM Parameter Value From NOM Actual Plan
    ...    ${integrated_ids_vDU}    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-1    cellName=${original_value}
    Check CM Parameter Value From vDU Actual Plan    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-1    cellName    ${original_value}
    Log To Console    vDU NRCELL Name recovery successfully!

Generate XML Plan For Name Update
    [Arguments]   ${plan_path}     ${plan_name}    ${backup_plan_path}    ${integrated_ids}
    ...    ${distName}    ${param}    ${value}
    ${export_timestamp}    Generate Formatted Timestamp
    ${output_actuals_file}    Set Variable     ${TEST_LOG_DIRECTORY}/actual${export_timestamp}.xml

    #CM Export
    CM Export Actual Configuration NOM Open API    ${integrated_ids}    ${output_actuals_file}
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




