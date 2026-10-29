*** Settings ***
Documentation
...  The purpose of this Test Case is to check the correct information about radio check points in Diagnostic Check

Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_general.robot
Resource    ../../../../resources/ca_BSRF_Diagnostic_Check.robot


*** Variables ***

${RMOD_SN}      # RU serial number
${node}    default

*** Keywords ***
TC__SiSo_FM_RU_Diagnostic_check_NOK_scenario_RU_Temperature_sensor_missing
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-35868
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this Test Case is to check the correct information about radio check points in Diagnostic Check.
    ...  TC raise fault 1940. Fault should be visible in fault_history_log.txt as minor EFaultId_TemperValueMissing (1171).
    ...  Active fault causes change in RU diagnostic check report - check point RU Temperature sensor (ID42) change status from OK to NOK.
    ...  TC check if NOK status is visible.
    ...  After that TC cleared fault 1940, EFaultId_TemperValueMissing (1171) shoulden't be visible in fault_history_log.txt.
    ...  Check point RU Temperature sensor (ID42) should change status to OK.
    ...
    ...  TC works with RU families: 5.1*, 6.2*, tested on AHFIB, AHFII.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 27.09.2023 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-35868 - Initial creation
    ...  - 13.01.2024 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-49170 - changes due to pronto 04237743

    Set Tags
    ...    OWNER-lukasz.wystup@nokia.com
    ...    AUTHOR-lukasz.wystup@nokia.com
    ...    MAINTAINER-lukasz.wystup@nokia.com
    ...    FEATURE-CB010823

    step1: Preconditions
    step2: Generate Temperature sensor missing FID 1940
    step3: Get DC report and check temperature sensor NOK status
    step4: Recovery Temperature sensor missing FID 1940
    step5: Get DC report and check temperature sensor OK status

step1: Preconditions

    Log to console  --------------------
    Log to console  step1: Preconditions
    Log to console  --------------------${\n}

    Check If RMOD Is Avaliable In Config And Prepare Distname For Diagnostic Check

    Log to console  Soft resetting RU to clear fault_history_log.txt!${\n}
    admin.Reset Unit  ${RMOD_DISTNAME_ID}  timeout=240

    Set Test Variable  ${DEGRADED_CELL_REGEX}  availabilityStatus=regex"[Dd]egraded|[Ff]ailed|[Oo]ff\\s?line"

    ${cells_status}  Run Keyword And Return Status  Check If All Cells Are onAir  timeout=60  alias=${node}
    Run Keyword If  '${cells_status}'=='True'
    ...  Log To Console  All cells are onAir!
    ...  ELSE  Fail  Cells are not onAir!

step2: Generate Temperature sensor missing FID 1940
    Log to console  ${\n}---------------------------
    Log to console  step2: Generate Temperature sensor missing FID 1940
    Log to console  ---------------------------${\n}

    radio.Generate Fault  1940  ${RMOD_SN}
    Log to Console  Waiting to generate fault.${\n}
    Sleep  300s
    ${DC_1_result}  admin.Run Diagnostic Check  timeout=500
    Log to console  Diagnostic Check finished. [OK]

    Log to console  Checking FID 1940 with severity Minor in fault_history_log.txt.

    ${1171_active}  Run Keyword And Return Status  radio.Assert Active Fault In Fault History Log File  ru_serial_number=${RMOD_SN}
    ...  fault_id=1171
    ...  severity=minor
    Run Keyword If  ${1171_active}
    ...  Log to console  ${\n}Found --> Active minor EFaultId_TemperValueMissing (1171) in fault_history_log_for_fault_1171.txt!
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Fault EFaultId_TemperValueMissing (1171) not found, please check fault_history_log_for_fault_1171.txt!

step3: Get DC report and check temperature sensor NOK status
    Log to console  ${\n}---------------------------
    Log to console  step3: Get DC report and check temperature sensor NOK status
    Log to console  ---------------------------${\n}

    Get DC Report And Check CP Result  42  NOK  ${connection}

step4: Recovery Temperature sensor missing FID 1940
    Log to console  ${\n}---------------------------
    Log to console  step4: Recovery Temperature sensor missing FID 1940
    Log to console  ---------------------------${\n}

    radio.Recover Fault  1940  ${RMOD_SN}
    Log to console  Waiting for clear of FaultID 1940 !${\n}
    Sleep  300s
    ${DC_2_result}  admin.Run Diagnostic Check  timeout=500
    Log to console  Diagnostic Check finished. [OK]

    ${1171_inactive}  Run Keyword And Return Status  radio.Assert Inactive Fault In Fault History Log File  ru_serial_number=${RMOD_SN}
    ...  fault_id=1171
    ...  severity=minor
    Run Keyword If  ${1171_inactive}
    ...  Log to console  ${\n}Found --> InActive minor EFaultId_TemperValueMissing (1171) in fault_history_log_for_fault_1171.txt!
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  InActive minor EFaultId_TemperValueMissing (1171) not found in fault_history_log_for_fault_1171.txt!${\n}

step5: Get DC report and check temperature sensor OK status
    Log to console  ${\n}---------------------------
    Log to console  tep5: Get DC report and check temperature sensor OK status
    Log to console  ---------------------------${\n}

    ${second_connection}  admin.Connect To  name=dc_second_connection
    Get DC Report And Check CP Result  42  OK  ${second_connection}
    admin.teardown  connection=${second_connection}


TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown
