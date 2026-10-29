*** Settings ***
Documentation
...                author: Lukasz Klosinski
...                modify: Marek Starzyk
...                maintainer: Marek Starzyk
...                contact: marek.starzyk@nokia.com
...                Test suite for CRT execution with a upgrade and rollback tests in a dual core configuration:

Force Tags         CA_VRF_WRO3

Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Resource           ../../../resources/common/uuf_keywords.robot

Test Timeout       100h
Suite Setup        Standalone Common Suite Setup

*** Variables ***
@{CUSTOMERS}                      TMO US
${INITIAL}                        ${None}
${CANDIDATE}                      ${None}
${ITERATION}                      5

${REPORT}                         ${True}
${QC_REPORT}                      ${True}
${REPORT_COMMENT}                 BUCKET_8_5_UPGRADE_UUFWRO3_RFRL2

${QC_DOMAIN}                      MN_RAN
${TEST_QC_ID}                     ${None}
${QC_PROJECT}                     ${None}

${TEMPORARY_ALLOWED_FAULTS_4G}    ${None}
${CUSTOM_ALLOWED_ALARMS_4G}       ${None}
${HW_TO_ONAIR_TIME}               ${None}

&{enb1}                           node_alias=4G           testline_object=${tl.enbs[0]}
...                               source_sw=${INITIAL}    target_sw=${CANDIDATE}
...                               temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_4G}
...                               custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_4G}
...                               hw_to_onair_timeout=${HW_TO_ONAIR_TIME}

@{NODES}                          ${enb1}

*** Test Cases ***
Upgrade rollback test
    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...    ${NODES}
    ...    ${enb1}
    ...    ${ITERATION}
    ...    report=${REPORT}
    ...    report_comment=${REPORT_COMMENT}
    ...    customers_list=${CUSTOMERS}
    ...    restore_to_target_sw=${False}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
