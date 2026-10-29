*** Settings ***

Documentation
...   Author:   Pekka Lonnakko
...   Contact:  I_MN_RAN_RD_TV_TRUNK_OUL1_GMS <I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com>

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/PM/Robot/TestKeywords/Measurement_interval_change.robot

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
...               AND           Init PM File Check    ${BASELINE}
...                                                   ${IGNORED_MEAS}
...                                                   ${IGNORED_COUNTERS}
Test Teardown     Common Test Teardown


*** Variables ***
${UPLOAD_PERIOD}             ${60}
${MEAS_INTERVAL}             ${15}
${LOOPS}                     1
${PASS_RATE}                 1
${ALLOWED_ALARMS_FILE}       testsuite/Oulu/TrunkEng/PM/Resources/Allowed_alarms_SBTS00.txt
${BASELINE}                  testsuite/Oulu/TrunkEng/PM/Resources/Baseline_SBTS00.xml
${IGNORED_MEAS}              testsuite/Oulu/TrunkEng/PM/Resources/Ignored_measurements_SBTS00.txt
${IGNORED_COUNTERS}          testsuite/Oulu/TrunkEng/PM/Resources/Ignored_counters_SBTS00.txt
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}              On failure
${RT_ALARM_UPDATE_INTERVAL}  5000

&{MEAS_INTERVALS}            mtCellAvailability=60
...                          mtCellLoad=720
...                          mtCellThruput=360
...                          mtIntereNBHo=disabled
...                          mtLTEM=720
...                          mtLTEMperLNBTS=360
...                          mtMBMS=1440
...                          mtMobilityEvents=720
...                          mtNBIoT=60
...                          mtProSe=30
...                          mtRRC=1440
...                          mtS1AP=30
...                          mtUEQuantity=30
...                          mtInterHomeeNBHo=1440
...                          lte_IP_Stats_Interval=30
...                          lte_IPSec_Interval=disabled
...                          lte_PHB_Stats_Interval=360
...                          ethernetLinkInterval=30
...                          mtSBTSAntennaLine=360
...                          tcpUdpStatisticsInterval=60
...                          s1X2TacStatisticsInterval=disabled
...                          topFreqSyncStatisticsInterval=1440
...                          bridgePortStatisticsInterval=1440

*** Test Cases ***
Measurement Interval Change
    Run Keyword In Loop And Return Pass Rate
        ...    ${UPLOAD_PERIOD}  ${MEAS_INTERVAL}  ${MEAS_INTERVALS}
        ...    name=Measurement Interval Change
        ...    test_case=1
        ...    loops=${LOOPS}
		...    keywords=Measurement Interval Change
        ...    expected_pass_rate=${PASS_RATE}
        ...    collect_test_logs=${COLLECT_LOGS}
