*** Settings ***
Documentation     author: Sravani K
...               contact: sravani.k@nokia.com
...               Description: This testsuite validates Cell Soft reset with 16DL8UL MIMO

Resource    ../../../gNB_P1/External_L3_Call_Common_Keywords.robot
Resource    ../../../QT/resources/Keywords/gnb_keywords.robot

*** Variables ***
${L3call_testsuite}    ${CURDIR}/../../../QT/L3call_Parallel_custom.robot


*** Test Cases ***
Validate Cell Delete and Setup with 16DL8UL MIMO
    [Tags]    AP_P1
    [Setup]    Update bsr package for 16DL8UL
    Set Test Variable    ${topology}    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD_AQQL_16DL8UL
    Set Test Variable    ${component_carrier}    1
    Perform L3 call and check status    ${topology}    ${component_carrier}    ${L3call_testsuite}
    ...    verification=@{verification_list_custom}
    Run And Return Rc And Output
    ...    cp ${OUTPUT_DIR}/${topology}_L3_call.html ${OUTPUT_DIR}/../${topology}_L3call_log.html

*** Keywords ***
Update bsr package for 16DL8UL
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQL_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001.zip
    ${wget_cmd}    Set Variable    sudo wget ${dllink}/${filename} --user=app1 --password=AP2ert23WFmnMEDhDkxLs2ojjok -P ${CURDIR}/BSR
    Run    ${wget_cmd}
    admin.setup admin
    ${ret}     admin.Update Software      ${CURDIR}/BSR/BSR_AQQL_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001.zip
    [Teardown]    admin.teardown admin
