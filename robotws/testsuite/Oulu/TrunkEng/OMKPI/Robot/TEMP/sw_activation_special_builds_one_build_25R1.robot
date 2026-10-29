*** Settings ***

Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     Collections
Library     taf.sw.reporting_portal
Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/Resources/OMKPI_common.robot
Resource    testsuite/Oulu/TrunkEng/OMKPI/Robot/TestKeywords/omkpi_sw_dl.robot
Variables   testsuite/Oulu/TrunkEng/OMKPI/Robot/Targets/omkpi_targets_example.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${WAIT_FOR_CELLS_UP}     600
${REPORT}                ${True}
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
@{SYSLOG_LIST}           Detected most recent reset type was   failed to execute   FirmwareActivationColdReset   BW.bin updated
...                      status = 70426 UPDATED
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}     4 (ERPresetTypeSpuriousReset)    14 (ERPresetTypeSpuriousResetBts)
# If set to ${True} makes SWDL by usin LMP connection, if set to ${False} uses S1 ip for SWDL
${LMP_SWDL}              ${True}
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}   /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
# seconds, 0 if no waiting nor printing before post conditions check
${WAIT_CHECKS}           90
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}          Always
${TEST_LOOPS}            1
${REFERENCE_TESTLINE}    ${EMPTY}
# User has manually downloaded build to PC and wants to use it for SWDL test
${ONE_BUILD}             /home/ute/Downloads/25R1.zip

# This KPI_TO_BE_TESTED variable can be used to calculate desired SWDL KPI values. Value can be for example:
# 2c or 2d
# 2a or 2b
# Sw inter activation without firmware update
# Sw intra activation without firmware update
# Sw inter activation with firmware update
# Sw intra activation with firmware update
# Inter-release SW activation downtime without firmware update
# Inter-release SW activation downtime with firmware updates
# Complete upgrade
${KPI_TO_BE_TESTED}     kpi 2a or 2b

*** Test Cases ***
OMKPI Sw Activation Special Builds One Build
    [Documentation]  Build is given by user is download to BTS, check that everything ok and calculate KPI.
    ...              NOTE builds can be what ever you want to use. NOTE if SW active on BTS is different than given builds,
    ...              Rollbacks between SWDLs are made.
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}   ${LMP_SWDL}    ${OAM_KPI_TARGETS}
        ...    ${KPI_TO_BE_TESTED}   ${ONE_BUILD}
        ...    name=OMKPI Sw Activation Special One Build
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=OMKPI SW DL One Package
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
        ...    omkpi_case=${True}
