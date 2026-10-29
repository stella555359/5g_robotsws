*** Settings ***
Documentation    Keywords to change mcc
...              Author:    Klaudyna Piechocka
...              Contact:   klaudyna.piechocka@nokia.com

Library     taf.nms.netact             WITH NAME    nms
Library     taf.sbts.oam.coam.admin    WITH NAME    admin
Library     Collections

*** Variables ***
${param_name_mcc}=     mcc

*** Keywords ***
Change mcc parameter
    [Documentation]    Description:    KW to check change mcc parameter using MantaRay
    ...                Input:          param_value = planned value value of mcc
    ...                                LAB_NAME = name of NetAct lab BTS is integrated to
    ...                Output:         None
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]    ${param_value}
    ${MOC_DN_1}=    Set Variable    MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
    ${MOC_DN_2}=    Set Variable    MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRPLMN-1
    ${temp_connection}=    Connect to Admin
    ${delta_id}=    admin.create_delta
    admin.append_parameter_update_to_delta    ${MOC_DN_1}    ${param_name_mcc}    ${param_value}    ${delta_id}
    admin.append_parameter_update_to_delta    ${MOC_DN_2}    ${param_name_mcc}    ${param_value}    ${delta_id}
    ${delta}=    admin.get_delta    ${delta_id}
    admin.perform_delta_recommissioning    ${delta}    connection=${temp_connection}

Change mcc parameter NMS
    [Documentation]    Description:    KW to check change mcc parameter using MantaRay
    ...                Input:          param_value = planned value value of mcc
    ...                                LAB_NAME = name of NetAct lab BTS is integrated to
    ...                Output:         None
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]    ${param_value}    ${LAB_NAME}
    ${MOC_DN_1}=    Set Variable    MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
    ${MOC_DN_2}=    Set Variable    MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRPLMN-1
    ${plan_conf}=       Create Plan Configuration    plan_mcc    new plan    alias=${LAB_NAME}
    ${meta_class_1}     ${meta_version_1}    ${parameters_1}=    Get Actual Configuration MO Data   ${MOC_DN_1}    ${LAB_NAME}
    ${meta_class_2}     ${meta_version_2}    ${parameters_2}=    Get Actual Configuration MO Data   ${MOC_DN_2}    ${LAB_NAME}
    Create Managed Object    ${plan_conf}    ${meta_class_1}    ${meta_version_1}    PLMN-PLMN/${MOC_DN_1}    UPDATE
    ...                                            alias=${LAB_NAME}    ${param_name_mcc}=${param_value}
    Create Managed Object    ${plan_conf}    ${meta_class_2}    ${meta_version_2}    PLMN-PLMN/${MOC_DN_2}    UPDATE
    ...                                            alias=${LAB_NAME}    ${param_name_mcc}=${param_value}
    Wait Until Keyword Succeeds   5x   30s   Provision Plan
    ...                 plan_name=plan_mcc
    ...                 backup_plan_name=None
    ...                 create_backup_plan=False
    ...                 provisioning_operation=activate
    ...                 ignore_errors=False
    ...                 alias=${LAB_NAME}
    [Teardown]    Delete Plan Configuration    ${plan_conf}

Check_If_ActCertValidation_Parameter_Is_Frozen
    ${value_rsa}=     Check current parameter value     dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...                                                 param_name=actCertValidation
    Should Contain    ${value_rsa}    true
    ${value_ecdsa}=   Check current parameter value     dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMPECDSA-1
    ...                                                            param_name=actCertValidation
    Should Contain    ${value_ecdsa}  true
    No Faults Except Allowed Should Be Present On BTS
    Run Keyword And Expect Error        *               Change Parameter on BTS
    ...                                                 dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...                                                 param_name=actCertValidation
    ...                                                 param_value=false
    Run Keyword And Expect Error        *               Change Parameter on BTS
    ...                                                 dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMPECDSA-1
    ...                                                 param_name=actCertValidation
    ...                                                 param_value=false
    ${value_rsa}=      Check current parameter value    dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...                                                 param_name=actCertValidation
    Should Contain     ${value_rsa}    true
    ${value_ecdsa}=    Check current parameter value    dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMPECDSA-1
    ...                                                 param_name=actCertValidation
    Should Contain     ${value_ecdsa}  true
    No Faults Except Allowed Should Be Present On BTS
