*** Settings ***
Force Tags  PY39

Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     Collections
Library     taf.sw.reporting_portal
Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource    testsuite/Oulu/TrunkEng/Obsolete/TKW_omkpi_rf_sw_update_loops.robot
Variables   testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/omkpi_targets_example.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${RF_SW_PATH}           https://es-si-s3-z2.eecloud.nsn-net.net/lterel/build/RUSW/RUSW_AHCA_000009_088908A-473966A-473966B.zip
${WAIT_FOR_CELLS_UP}    300
${REPORT}               ${True}
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
@{SYSLOG_LIST}          Detected most recent reset type was   failed to execute   FirmwareActivationColdReset   BW.bin updated
...                     status = 70426 UPDATED
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}    4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)

# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
# seconds, 0 if no waiting nor printing before post conditions check
${WAIT_CHECKS}          60

# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         On failure
${TEST_LOOPS}           1
${REFERENCE_TESTLINE}   ${EMPTY}
${SCOUT_TL_NAME}        ${EMPTY}

*** Test Cases ***
OMKPI Rf Sw Update
    [Documentation]  Get the RF SW to be downloaded from the user given given path. Procedure introduced in 24R3-SR with CB010779.
    ...              RF SW will be uploaded just to radios that are supported by the give build. After Radio SW SWDL, SWDL of T1
    ...              will be done and RF SW update will be done again. After that SWDL of T2 and RF SW update will be done again.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${RF_SW_PATH}
        ...    name=OMKPI Loop Rf Sw Update
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=OMKPI Loop RF SW Update
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
