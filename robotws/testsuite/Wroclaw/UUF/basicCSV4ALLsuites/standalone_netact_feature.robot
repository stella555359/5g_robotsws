*** Settings ***
Documentation
...                author: Lukasz Klosinski
...                modify: Marek Starzyk
...                maintainer: Marek Starzyk
...                contact: marek.starzyk@nokia.com
...                Test suite for basic UUF OAM upgrade and rollback tests via NetAct in the standalone configuration:

Force Tags         CA_VRF_WRO3

Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Resource           ../resources/common/uuf_keywords.robot
Variables          ../resources/common/uuf_netact.py

Test Timeout       100h
Suite Setup        Standalone Common Suite Setup

# robot -L TRACE /home/ute/MN/UTE/robotws/testsuite/Wroclaw/UUF/basicCSV4ALLsuites/standalone_netact_feature.robot

*** Variables ***
@{CUSTOMERS}                      Generic
${INITIAL}                        ${None}
${CANDIDATE}                      ${None}
${ITERATION}                      1
${ROLLBACK}                       ${True}
${FALLBACK}                       ${True}
${STOP_TEST_AFTER_FAIL}           ${False}
${IP_VERSION}                     IPv4       # Set IPv6 if you want to test on IPv6

${NETACT}                         srnclab2001
${NETACT_PASS}                    ${None}

${FEATURE}                        CB012755-SR
${CONFIG_TYPE}                    ${None}    # Set test line configuration e.g. 'ASIB+ABIC', '2ASIL'
                                             # If the config_type and feature are filled,
                                             # the log from the passed iteration will be sent to nescrotta.

${REPORT}                         ${True}
${QC_REPORT}                      ${True}
${REPORT_COMMENT}                 standalone_upgrade_via_netact_test_UUFWRO3_RFRL2

${QC_DOMAIN}                      MN_RAN
${TEST_QC_ID}                     ${None}
${QC_PROJECT}                     ${None}

# All test line specific variables are imported during the 'Standalone Common Suite Setup'
# from the 'tl_specific_variables' dictionary located in the file
# testsuite/Wroclaw/UUF/resources/common/temporary_alarms.py.
# If you want to add a specific alarm, please add it to the dictionary.
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
    [Timeout]   98h
    netact_feature_test
    ...    ${NODES}
    ...    ${enb1}
    ...    ${ITERATION}
    ...    netact_dict=${NETACT_DICT}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    report_comment=${REPORT_COMMENT}
    ...    customers_list=${CUSTOMERS}
    ...    rollback=${ROLLBACK}
    ...    fallback=${FALLBACK}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    feature=${FEATURE}
    ...    config_type=${CONFIG_TYPE}
