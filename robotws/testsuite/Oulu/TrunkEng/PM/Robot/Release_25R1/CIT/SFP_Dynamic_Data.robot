*** Settings ***

Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_TRUNK_OUL1_GMS <I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com>

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/PM/Robot/TestKeywords/SFP_Dynamic_Data.robot

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
...               AND           Init PM File Check    ${BASELINE}
...                                                   ${IGNORED_MEAS}
...                                                   ${IGNORED_COUNTERS}
Test Teardown     Common Test Teardown


*** Variables ***
${MEAS_INTERVAL}        ${15}
${UPLOAD_INTERVAL}      ${15}
${TEST_LOOPS}           1
${PASS_RATE}            1
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/PM/Resources/A_alarms_branch.txt
${BASELINE}             testsuite/Oulu/TrunkEng/PM/Resources/baseline_SBTS25R1.xml
${IGNORED_MEAS}         testsuite/Oulu/TrunkEng/PM/Resources/I_measurements_branch.txt
${IGNORED_COUNTERS}     testsuite/Oulu/TrunkEng/PM/Resources/I_counters_branch.txt
# Syslog prints that will be printed to eventlog when found from the syslog, will not fail the test if found/not found
@{SYSLOG_LIST}          ResetCounter  Detected most recent reset type  Failed to execute executable  RecoveryConstraints
                        ...    Executing recovery action  RecoveryActionController   HW resource started up
# List of unallowed syslog prints that will fail the test if seen during test.
# In this test there is no site reset etc. so no resets should be seen in syslogs
@{UNALLOWED_SYSLOGS}    4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)
...                     1 (ERPresetTypeApplication)  13 (ERPresetTypeApplicationBts)
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure

*** Test Cases ***
SFP Dynamic Data Test
    Run Keyword In Loop And Return Pass Rate
        ...    ${UPLOAD_INTERVAL}  ${MEAS_INTERVAL}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}
        ...    name=First Intermediate Period
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
		...    keywords=PM SFP Dynamic Data
        ...    expected_pass_rate=${PASS_RATE}
        ...    collect_test_logs=${COLLECT_LOGS}
