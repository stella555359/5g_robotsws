*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/kill_applications_reset.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/bbmod_soc_test_kws.robot

Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.FspIP  WITH NAME  FSP
Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.SSHConnection  WITH NAME  SSH
Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Applications

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown


*** Variables ***
# Max time to wait for cells to be up and running, currently mandatory to be given as integer, later also string will be suitable
${WAIT_FOR_CELLS_UP}    ${300}
# Wait after test and site reset, value can be given as string.
${WAIT_CNTR_CLEAR}      360
# Time for wait alarm when alarm activated, needs to be long so 10 alarm have time to be raised
${WAIT_FOR_ALARM}       422
# time to wait before common post conditions checks
${WAIT_CHECKS}          180
# Suite Variable that's value is changed in Test Cases
${UNIT}                 BBMOD1
# Application which is killed from DistributedCplane virtual node on primary soc of bbmod
${APPLICATION}          UECexe
# Prints that are monitored from syslog to eventlog
@{SYSLOG_LIST}          ResetCounter  Detected most recent reset type    Failed to execute executable
                        ...    Executing recovery action  RecoveryActionController  Set alarm  Reset count
                        ...    Please contact the owner of   RESET, DDAL_HOTPLUG_EVT_RIO_REMOVE received device_id
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
# How many times test will be run, needs to be more than 0
${TEST_LOOPS}           1

*** Test Cases ***
BBMOD1 kill UECexe from DistributedCplane
    Sleep  1s
    [Documentation]  Kill ${APPLICATION} from DistributedCplane of primary soc of ${UNIT} and expect autonomous rat reset.
    [Tags]  "${UNIT} kill ${APPLICATION} from DistributedCplane" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${UNIT}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SYSLOG_LIST}
        ...    ${WAIT_CNTR_CLEAR}    ${WAIT_CHECKS}
        ...    name=${UNIT} crash ${APPLICATION} from DistributedCplane recovery
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Kill DistributedCPlane application from bbmod, internal autonomous reset
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

BBMOD1 kill CELLCexe from DistributedCplane
    Sleep  1s
    Set Suite Variable    ${APPLICATION}    CELLCexe
    [Documentation]  Kill ${APPLICATION} from DistributedCplane of primary soc of ${UNIT} and expect autonomous rat reset.
    [Tags]  "${UNIT} kill ${APPLICATION} from DistributedCplane" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${UNIT}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SYSLOG_LIST}
        ...    ${WAIT_CNTR_CLEAR}    ${WAIT_CHECKS}
        ...    name=${UNIT} crash ${APPLICATION} from DistributedCplane recovery
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Kill DistributedCPlane application from bbmod, internal autonomous reset
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

BBMOD1 kill FaultServiceExe from DistributedCplane
    Sleep  1s
    Set Suite Variable    ${APPLICATION}    FaultServiceExe
    [Documentation]  Kill ${APPLICATION} from DistributedCplane of primary soc of ${UNIT} and expect autonomous rat reset.
    [Tags]  "${UNIT} kill ${APPLICATION} from DistributedCplane" -test loops: ${TEST_LOOPS}
    Set Suite Variable   ${UNIT}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_FOR_ALARM}  ${APPLICATION}  ${UNIT}  ${SYSLOG_LIST}
        ...    ${WAIT_CNTR_CLEAR}    ${WAIT_CHECKS}
        ...    name=${UNIT} crash ${APPLICATION} from DistributedCplane recovery
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Kill DistributedCPlane application from bbmod, internal autonomous reset
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
