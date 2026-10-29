*** Settings ***

Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Library     Collections
Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/Common/Robot/TestKeywords/upgrade_sw_to_bts.robot

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown


Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown


*** Variables ***
${WAIT_FOR_CELLS_UP}    300
${REPORT}               ${True}
# to list below you can add prints that will be monitored from syslog, if print is found, it is written to eventlog
@{SYSLOG_LIST}          Detected most recent reset type was    failed to execute
# to list below you can add prints that will fail the test if they are found from syslog
@{UNALLOWED_SYSLOGS}    13 (ERPresetTypeApplicationBts)  4 (ERPresetTypeSpuriousReset)
                   ...  14 (ERPresetTypeSpuriousResetBts)
# Path to allowed alarms file
${ALLOWED_ALARMS_FILE}  /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/OMKPI/allowed_alarms.txt
# seconds, 0 if no waiting nor printing before post conditions check
${WAIT_CHECKS}          0
# Build that will be downloaded to eNB
${BUILD_TO_DOWNLOAD}    SBTS00_ENB_9999_230503_000013
# Existing released OK builds to try:
# SBTS00_ENB_9999_230501_000009
# SBTS00_ENB_9999_230418_000008
# SBTS00_ENB_9999_230422_000013
# If True saves SW build to pc before uploading it to BTS. If False uses link to SW build for uploading
# NOTE saves 10min if build is not saved on PC
${SAVE_BUILD_TO_PC}     ${False}
# Collect logs variable. Possible values are: On failure/Never/Always
${COLLECT_LOGS}         Never


*** Test Cases ***
Upgrade Sw To Bts
    [Documentation]  Get build url to artifactory and download it to BTS
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${BUILD_TO_DOWNLOAD}  ${SAVE_BUILD_TO_PC}  ${WAIT_FOR_CELLS_UP}  ${WAIT_CHECKS}  ${SYSLOG_LIST}
        ...    ${UNALLOWED_SYSLOGS}
        ...    name=Upgrade build to BTS
        ...    test_case=1
        ...    loops=1
		...    keywords=Upgrade Sw To Bts
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
