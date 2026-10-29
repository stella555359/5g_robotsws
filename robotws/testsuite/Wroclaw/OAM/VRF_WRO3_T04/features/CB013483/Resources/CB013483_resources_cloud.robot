*** Settings ***
Documentation    Additional keywords for CB013483
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
    [Arguments]    ${param_value}    ${hw_type}    ${LAB_NAME}
    IF    '${hw_type}'=='vDU'
        ${MOC_DN_1}=     Set Variable     MRBTS-${MRBTS}/NRBTS-${MRBTS}
        ${MOC_DN_2}=     Set Variable     MRBTS-${MRBTS}/NRBTS-${MRBTS}/NRPLMN-1
    ELSE IF    '${hw_type}'=='vCU'
        ${MOC_DN_1}=     Set Variable     MRBTS-${MRBTS_CU}/NRBTS-${MRBTS}
        ${MOC_DN_2}=     Set Variable     MRBTS-${MRBTS_CU}/NRBTS-${MRBTS}/NRPLMN-1
    ELSE
        Fail    msg=hw_type doesn't exist
    END
    ${plan_mcc}=    Create Plan Configuration    aplan_mcc    new plan    alias=${LAB_NAME}
    ${meta_class_1}     ${meta_version_1}    ${parameters_1}=    Get Actual Configuration MO Data   ${MOC_DN_1}    ${LAB_NAME}
    ${meta_class_2}     ${meta_version_2}    ${parameters_2}=    Get Actual Configuration MO Data   ${MOC_DN_2}    ${LAB_NAME}
    Create Managed Object    ${plan_mcc}    ${meta_class_1}    ${meta_version_1}    PLMN-PLMN/${MOC_DN_1}    UPDATE
    ...                                            alias=${LAB_NAME}    ${param_name_mcc}=${param_value}
    Create Managed Object    ${plan_mcc}    ${meta_class_2}    ${meta_version_2}    PLMN-PLMN/${MOC_DN_2}    UPDATE
    ...                                            alias=${LAB_NAME}    ${param_name_mcc}=${param_value}
    ${result}=          Provision Plan
    ...                 plan_name=aplan_mcc
    ...                 backup_plan_name=None
    ...                 create_backup_plan=False
    ...                 provisioning_operation=activate
    ...                 ignore_errors=False
    ...                 alias=${LAB_NAME}
    [Teardown]    Delete Plan Configuration    ${plan_mcc}
