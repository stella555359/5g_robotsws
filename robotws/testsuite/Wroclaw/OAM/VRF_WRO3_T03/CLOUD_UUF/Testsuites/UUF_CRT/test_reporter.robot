*** Settings ***
Documentation
...    Author: marek.starzyk@nokia.com
...    Description: Suite prepared for reporting test execution to UUF Test Runs in the reporting portal.
...    Group in charge: I_MN_RAN_PZ_3_WRO_1_GMS <I_MN_RAN_PZ_3_WRO_1@internal.nsn.com>
...    Sample execution:
...    robot -L TRACE /home/ute/MN/UTE/robotws/testsuite/Wroclaw /OAM/VRF_WRO3_T01/CLOUD_UUF/Testsuites/UUF_CRT/test_reporter.robot

Library  taf.sw.reporting_portal
Library  DateTime
Library  String
Library  Collections

*** Variables ***
# failed or passed
${RESULT}             passed
${TESTLINE}           10_16_UTESRANCLOUD2164
${TESTER_NAME}        ${EMPTY}
${COMMENT}            ${EMPTY}

${CANDIDATE_BUILD}    ${EMPTY}
${INITIAL_BUILD}      ${EMPTY}
${CU_BUILD}           ${EMPTY}
${CU_CAAS_BUILD}      ${EMPTY}
${DU_CAAS_BUILD}      ${EMPTY}
${FHGW_BUILD}         ${EMPTY}
${QC_ID}              ${EMPTY}
${CASE_TYPE}          Upgrade

${TOOL}               MantaRay
${PRODUCT}            AEQQ+AHPMDG
${TDD_FDD_VARIANT}    TDD+FDD
${SA_NSA_VARIANT}     NSA+SA
${HW_ID}              N/A
@{CUSTOMERS}          TEF O2 Germany

${CA}                 VRF_OAM
${LOCATION}           VRF_WRO3
${ORGANIZATION}       VRF_WRO3_T01
${QC_DOMAIN}          MN_RAN
${QC_PROJECT}         RAN_VRF

${UUF_TEST}           ${True}
${NAME_TO_REPORT}     ${EMPTY}
${DATE FORMAT}        %Y-%m-%d %H:%M:%S

*** Test Cases ***
Report Test To Reporting Portal
    Validate Customers  ${CUSTOMERS}
    ${now}=    Get Current Date    result_format=${DATE FORMAT}
    ${starttime}=  Replace String  ${now}.000  -  ${EMPTY}
    Log to console    ${starttime}
    ${link_to_reporting_portal}=
    ...    report to rp
    ...    name=${NAME_TO_REPORT}
    ...    result=${RESULT}
    ...    ca=${CA}
    ...    location=${LOCATION}
    ...    organization=${ORGANIZATION}
    ...    uuf_test=${UUF_TEST}
    ...    comment=${COMMENT}
    ...    testline=${TESTLINE}
    ...    build=${CANDIDATE_BUILD}
    ...    parameter_1=${INITIAL_BUILD}
    ...    cu_build=${CU_BUILD}
    ...    cu_caas_build=${CU_CAAS_BUILD}
    ...    du_caas_build=${DU_CAAS_BUILD}
    ...    fhgw_build=${FHGW_BUILD}
    ...    qc_id=${QC_ID}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_project=${QC_PROJECT}
    ...    username=${TESTER_NAME}
    ...    starttime=${starttime}
    ...    endtime=${starttime}
    ...    customers=${CUSTOMERS}
    ...    tool=${TOOL}
    ...    case_type=${CASE_TYPE}
    ...    product=${PRODUCT}
    ...    sa_nsa_variant=${SA_NSA_VARIANT}
    ...    tdd_fdd_variant=${TDD_FDD_VARIANT}
    ...    hw_id=${HW_ID}
    Log To Console    ${link_to_reporting_portal}


*** Keywords ***
Validate Customers
    [Arguments]  ${customers_list}
    ${invalide_list}  Create List
    FOR  ${customer}  IN  @{customers_list}
        ${match}=  Run Keyword  Validate Customer  ${customer}
        Run Keyword if  ${match}  Log  Customer name is correct
        ...  ELSE  Append To List  ${invalide_list}  ${customer}
    END
    Run Keyword If    ${invalide_list}!=[]
    ...    Fatal Error    Invalid Customer: ${invalide_list}

Validate Customer
    [Arguments]  ${customer}
    @{valid_customers}  Create List  TEF O2 Germany  Generic
    ${is_correct}=  Evaluate  '${customer}' in ${valid_customers}
    [RETURN]  ${is_correct}
