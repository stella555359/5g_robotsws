*** Settings ***
Documentation
...   Author:   Jere Jacklin
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/early_startup_failure_with_flag_manipulation.robot

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown


*** Variables ***
${ALLOWED_ALARMS_FILE}    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
${ADD_FLAG}               ${True}
@{UNALLOWED_SYSLOGS}
${SYSLOG_PRINT}
${WAIT_FOR_CELLS_UP}      ${600}
${WAIT_CHECKS}            300
${WAIT_AFTER_SWDL}        540
${COLLECT_LOGS}           Always
${TEST_LOOPS}             1
${CRITICAL_SERVICE}       CNI-139728=hpd.service
${CCS_SERVICE}            CNI-139728=ccs.service
${HWAPI_SERVICE}          CNI-139728=hwr-startup.service
${BOAM_SERVICE}           CNI-139728=soam-btsomexe.service
${TRS_SERVICE}            CNI-139728=trsw_vtc_daemon_dhcpclientd.service

*** Test Cases ***
UC7 Systemd fails to start critical service
    [Documentation]  Use case 7 of CNI-139728
    Set Suite Variable  ${SYSLOG_PRINT}  Stopped hpd.service
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${CRITICAL_SERVICE}  ${WAIT_AFTER_SWDL}  ${SYSLOG_PRINT}
        ...    name=Systemd fails to start critical ${CRITICAL_SERVICE} service
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Systemd fails to start service
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

UC8 Systemd fails to start CCS service
    [Documentation]  Use case 8 of CNI-139728 - CCS related test
    Set Suite Variable  ${SYSLOG_PRINT}  Stopped ccs.service
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${CCS_SERVICE}  ${WAIT_AFTER_SWDL}  ${SYSLOG_PRINT}
        ...    name=Systemd fails to start critical ${CCS_SERVICE} service
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Systemd fails to start service
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

UC8 Systemd fails to start HWAPI service
    [Documentation]  Use case 8 of CNI-139728 - HWAPI related test
    Set Suite Variable  ${SYSLOG_PRINT}  Stopped hwr-startup.service
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${HWAPI_SERVICE}  ${WAIT_AFTER_SWDL}  ${SYSLOG_PRINT}
        ...    name=Systemd fails to start critical ${HWAPI_SERVICE} service
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Systemd fails to start service
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

UC9 Systemd fails to start BOAM service
    [Documentation]  Use case 9 of CNI-139728 - BOAM related test
    Set Suite Variable  ${SYSLOG_PRINT}  ResetReason 'Spurious warm reset: [INFO] soam-btsomexe', begin
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${BOAM_SERVICE}  ${WAIT_AFTER_SWDL}  ${SYSLOG_PRINT}
        ...    name=Systemd fails to start critical ${BOAM_SERVICE} service
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Systemd fails to start service
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

UC9 Systemd fails to start TRS service
    [Documentation]  Use case 9 of CNI-139728 - TRS related test
    Set Suite Variable  ${SYSLOG_PRINT}  Stopped trsw_vtc_daemon_dhcpclientd.service
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${TRS_SERVICE}  ${WAIT_AFTER_SWDL}  ${SYSLOG_PRINT}
        ...    name=Systemd fails to start critical ${TRS_SERVICE} service
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=Systemd fails to start service
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}

UC11 Secondary detection failure
    [Documentation]  Use case 11 of CNI-139728. NOTE this test requires full rack environment.
    ${FULLRACK}=  Site is fullrack
    IF  ${FULLRACK}
        Set Suite Variable   ${WAIT_AFTER_SWDL}   600
        Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
            ...    ${WAIT_AFTER_SWDL}
            ...    name=Secondary detection failure
            ...    test_case=1
            ...    loops=${TEST_LOOPS}
            ...    keywords=Secondary detection failure
            ...    expected_pass_rate=1
            ...    collect_test_logs=${COLLECT_LOGS}
    ELSE
        Print Text To Eventlog    Test is suitable only for full rack environments
        Fail    Wrong topology. Test is valid only for full rack environments
    END

UC12 BBMOD detection failure
    [Documentation]  Use case 12 of CNI-139728
    Set Suite Variable   ${WAIT_AFTER_SWDL}   600
    ${EXPECTED_SYSLOG_PRINTS}=  Create List   ERadHwapi_AdetFspDetectionTimerValue   ERadHwapi_AdetFctDetectionTimerValue
    Append To List    ${dbws_datapoints}
    Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
        ...    ${WAIT_AFTER_SWDL}
        ...    name=BBMOD detection failure
        ...    test_case=1
        ...    loops=${TEST_LOOPS}
        ...    keywords=BBMOD detection failure
        ...    expected_pass_rate=1
        ...    collect_test_logs=${COLLECT_LOGS}
