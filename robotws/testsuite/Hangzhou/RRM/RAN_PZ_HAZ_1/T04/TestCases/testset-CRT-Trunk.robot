*** Settings ***
Documentation
...   Author: lixin.kang@nokia-sbell.com

Suite Setup    Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      TRUNK             #Tag Item

Test Timeout    600 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../CB007669/VRAN_SyVe_CB007669-E_001_CM_Operator_Configures_Customized_Names_for_NE_and_Cells_via_NOM.robot
Resource          ../CB007669/VRAN_SyVe_CB007669_E_002_Configurable_Identifiers_In_WebEM_vDU.robot
Library           ute_reporting_portal

*** Variables ***
${build}    vDUCNF00_0.300.10296

*** Test Cases ***
CB007669-E_001
    [Tags]    CB007669-E
    [Timeout]    30 minutes
    [Documentation]
    ...    Author: lixin.kang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    15.9.2022, lixin.kang@nokia-sbell.com, draft
    [Setup]    Run Keywords    Set Test Variable    ${plan_path}
    ...    /home/ute/Auto5G/robotws/testsuite/Hangzhou/AIC/RAN_PZ_HAZ_1/HAZ11/TestData/Plan_NOM
    ...    AND    Set Library Search Order    VRAN_SyVe_CB007669-E_001_CM_Operator_Configures_Customized_Names_for_NE_and_Cells_via_NOM
    ...    AND    Set Library Search Order    AIC_Nom
    ...    AND    VRAN_SyVe_CB007669-E_001_CM_Operator_Configures_Customized_Names_for_NE_and_Cells_via_NOM.Case Precondition
    ...    False    True    True
    VRAN_SyVe_CB007669-E_001_CM_Operator_Configures_Customized_Names_for_NE_and_Cells_via_NOM
    [Teardown]    Run Keywords    VRAN_SyVe_CB007669-E_001_CM_Operator_Configures_Customized_Names_for_NE_and_Cells_via_NOM.Case Postcondition
    ...    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1.0] VRAN_SyVe_CB007669-E_001_CM_Operator configures customized names for NE cells using NMS
    ...    424674    ${build}

CB007669-E_002
    [Tags]    CB007669-E
    [Timeout]    30 minutes
    [Documentation]
    ...    Author: bin.7.liu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    9.2.2023, bin.7.liu@nokia-sbell.com, draft
    [Setup]    Run Keywords    Set Library Search Order    VRAN_SyVe_CB007669_E_002_configurable_identifiers_in_WebEM_vDU
    ...    AND    VRAN_SyVe_CB007669_E_002_configurable_identifiers_in_WebEM_vDU.Case Precondition
    VRAN_SyVe_CB007669_E_002_configurable_identifiers_in_WebEM_vDU
    [Teardown]    Run Keywords    VRAN_SyVe_CB007669_E_002_configurable_identifiers_in_WebEM_vDU.Case Postcondition
    ...    AND    Run Keyword If Test Passed    Run Keyword And Ignore Error
    ...    Report To Reporting Portal
    ...    [1][1.0] CB007669_E_Case2_configurable_identifiers_in_WebEM_vDU
    ...    491488    ${build}

*** Keywords ***
Report To Reporting Portal
    [Arguments]    ${test_run}    ${qc_instance_id}    ${build}    ${status}=passed
    [Documentation]    Keyword send report to reporting portal and return link
    ${qc_domain}=    set variable    MN_RAN
    ${qc_project}=    set variable    RAN_ST
    ${ca}=    convert to string    RAN_PZ_HAZ_1
    &{empty_dict}=    Create Dictionary
    ${add_info}    Create List
    ${testline_name}    Set Variable    5G_Hangzhou_UTE5GAIC015T0011083
    log    ${testline_name}    console=${True}
    ${link_to_reporting_portal}=    ute_reporting_portal.report to rp    qc_domain=${qc_domain}    qc_project=${qc_project}
    ...    name=${test_run}    result=${status}    ca=${ca}    build=${build}    links=&{empty_dict}    tool=Robot
    ...    add_info=${add_info}    testline=${testline_name}    qc_id=${qc_instance_id}
    set suite variable    ${LINK_TO_RP}    ${link_to_reporting_portal}