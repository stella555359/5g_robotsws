*** Settings ***
Documentation
...                author: Lukasz Klosinski
...                modify: Marek Starzyk
...                maintainer: Marek Starzyk
...                contact: marek.starzyk@nokia.com
...                Test suite for CRT execution UUF OAM upgrade and rollback tests via NetAct in the standalone configuration:

Force Tags         CA_VRF_WRO3

Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Resource           ../../../resources/common/uuf_keywords.robot

Test Timeout       100h
Suite Setup        Standalone Common Suite Setup

*** Variables ***
@{CUSTOMERS}                      TMO US
${INITIAL}                        ${None}
${CANDIDATE}                      ${None}
${ITERATION}                      3
${ROLLBACK}                       ${True}
${FALLBACK}                       ${False}
${IP_VERSION}                     IPv4       # Set IPv6 if you want to test on IPv6

${NETACT}                         srnclab2001
${NETACT_PASS}                    Gamazda!20

${REPORT}                         ${True}
${QC_REPORT}                      ${True}
${REPORT_COMMENT}                 BUCKET_8_1_NETACT_UPGRADE_UUFWRO3_RFRL2

${QC_DOMAIN}                      MN_RAN
${TEST_QC_ID}                     ${None}
${QC_PROJECT}                     ${None}

&{tl_specific_variables}

&{NETACT_DICT}                    name=${NETACT}               username=omc     password=${NETACT_PASS}
...                               ip_version=${IP_VERSION}     security_mode=no TLS

&{enb1}                           node_alias=4G           testline_object=${tl.enbs[0]}
...                               source_sw=${INITIAL}    target_sw=${CANDIDATE}
...                               temporary_allowed_alarms=${tl_specific_variables}
...                               custom_allowed_alarms=${tl_specific_variables}
...                               hw_to_onair_timeout=${tl_specific_variables}

@{NODES}                          ${enb1}

*** Test Cases ***
Upgrade rollback test
    netact_feature_test
    ...    ${NODES}
    ...    ${enb1}
    ...    ${ITERATION}
    ...    netact_dict=${NETACT_DICT}
    ...    report=${REPORT}
    ...    report_comment=${REPORT_COMMENT}
    ...    customers_list=${CUSTOMERS}
    ...    rollback=${ROLLBACK}
    ...    fallback=${FALLBACK}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
