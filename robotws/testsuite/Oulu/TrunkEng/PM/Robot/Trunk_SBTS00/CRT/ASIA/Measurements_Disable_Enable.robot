*** Settings ***

Documentation
...   Author:   Pekka Lonnakko
...   Contact:  I_MN_RAN_RD_TV_TRUNK_OUL1_GMS <I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com>

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/PM/Robot/TestKeywords/Measurements_Disable_Enable.robot

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
...               AND           Init PM File Check    ${BASELINE}
...                                                   ${IGNORED_MEAS}
...                                                   ${IGNORED_COUNTERS}
Test Teardown     Common Test Teardown


*** Variables ***
${UPLOAD_PERIOD}             ${15}
${MEAS_INTERVAL}             ${15}
${LOOPS}                     1
${PASS_RATE}                 1
${ALLOWED_ALARMS_FILE}       testsuite/Oulu/TrunkEng/PM/Resources/Allowed_alarms_SBTS00.txt
${BASELINE}                  testsuite/Oulu/TrunkEng/PM/Resources/Baseline_SBTS00.xml
${IGNORED_MEAS}              testsuite/Oulu/TrunkEng/PM/Resources/Ignored_measurements_SBTS00.txt
${IGNORED_COUNTERS}          testsuite/Oulu/TrunkEng/PM/Resources/Ignored_counters_SBTS00.txt
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}              On failure

&{DISABLED_DICT}             tcpUdpStatisticsInterval=disabled
...                          mtX2AP=disabled
...                          mtEPSBearer=disabled
...                          lte_IP_Stats_Interval=disabled
...                          ethernetInterfaceStatisticsInterval=disabled
...                          lte_ETHIF_Stats_Interval=disabled
...                          lte_IP_Filtering_Interval=disabled
...                          lte_Ethernet_Link_Interval=disabled
...                          mtS1AP=disabled
...                          sctpStatisticsInterval=disabled
...                          ipInterfaceStatisticsInterval=disabled
...                          mtRRC=disabled

*** Test Cases ***
Measurements Disable And Enable
    Run Keyword In Loop And Return Pass Rate
        ...    ${UPLOAD_PERIOD}  ${MEAS_INTERVAL}  ${DISABLED_DICT}
        ...    name=Measurements Disable And Enable
        ...    test_case=1
        ...    loops=${LOOPS}
		...    keywords=Measurements Disable And Enable
        ...    expected_pass_rate=${PASS_RATE}
        ...    collect_test_logs=${COLLECT_LOGS}
