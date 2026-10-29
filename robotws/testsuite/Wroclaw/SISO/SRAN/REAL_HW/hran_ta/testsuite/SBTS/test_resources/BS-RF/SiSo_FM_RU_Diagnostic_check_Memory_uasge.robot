*** Settings ***
Documentation
...  The purpose of this Test Case is to check the correct information about radio check points in Diagnostic Check -
...  radio checks the level of memory usage.

Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_general.robot
Resource    ../../../../resources/ca_BSRF_Diagnostic_Check.robot


*** Variables ***

${RMOD_SN}      # RU serial number
&{memory_threshold}    memoryTestThreshold=20.0
${node}    default

*** Keywords ***
TC__SiSo_FM_RU_Diagnostic_check_Memory_uasge
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-38419
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this Test Case is to check the correct information about radio check points in Diagnostic Check -
    ...  radio checks the level of memory usage.
    ...  TC change memoryTestThreshold in binnary file on RMOD. It cause that level of memoty usage is higher than treshold.
    ...  Active fault causes change in RU diagnostic check report - check point RU Memory usage (ID41) change status from OK to NOK.
    ...  TC check if NOK status is visible.
    ...  After that TC rewrite orginal binnary file on RMOD.
    ...  Check point RU Memory usage (ID41) should change status to OK.
    ...
    ...  TC works with RU families: 5.1*, tested on AHFIB.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 11.10.2023 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-38419 - Initial creation
    ...  - 19.06.2024 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-47585 - Add checking OK status in preconditions
    ...  - 13.01.2024 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-49170 - changes due to pronto 04237743
    ...  - 23.04.2024 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-49288 - sleep for rmod reset increased

    Set Tags
    ...    OWNER-lukasz.wystup@nokia.com
    ...    AUTHOR-lukasz.wystup@nokia.com
    ...    MAINTAINER-lukasz.wystup@nokia.com
    ...    FEATURE-CB010823

    step1: Preconditions
    step2: Generate level of memory usage higher than treshold
    step3: Get DC report and check memory usage NOK status
    step4: Recovery level of memory usage lower than treshold
    step5: Get DC report and check memory usage OK status

step1: Preconditions

    Log to console  --------------------
    Log to console  step1: Preconditions
    Log to console  --------------------${\n}

    Set Test Variable  ${RECOVER_TRESHOLD}  ${FALSE}
    Check If RMOD Is Avaliable In Config And Prepare Distname For Diagnostic Check
    ${DC_0_result}  admin.Run Diagnostic Check  timeout=500
    Log to console  Diagnostic Check finished. [OK]
    ${zero_connection}  admin.Connect To  name=dc_zero_connection
    Get DC Report And Check CP Result  checkpoint=41  expected_status=OK  connection=${zero_connection}  precondition=${TRUE}
    admin.Teardown  connection=${zero_connection}

step2: Generate level of memory usage higher than treshold
    Log to console  ${\n}---------------------------
    Log to console  step2: Generate level of memory usage higher than treshold
    Log to console  ---------------------------${\n}

    ${binary_file_dict}  radio.Get Decoded Binary File
    ...    ru_serial_number=${RMOD_SN}
    ...    filename=sysmon_primary
    Set Test Variable    ${BINARY}    ${binary_file_dict}

    Set Test Variable  ${RECOVER_TRESHOLD}  ${TRUE}
    Log to console  Override values ${memory_threshold} in binary file${\n}
    radio.Override Values In Binary File
    ...    ru_serial_number=${RMOD_SN}
    ...    filename=sysmon_primary
    ...    values_dict=${memory_threshold}
    ...    reset_ru=${TRUE}

    Log to console  Reseting RMOD and wait for OnAir status${\n}
    Sleep  40s

    Set Test Variable  ${DEGRADED_CELL_REGEX}  availabilityStatus=regex"[Dd]egraded|[Ff]ailed|[Oo]ff\\s?line"

    ${cells_status}  Run Keyword And Return Status  Check If All Cells And Modules Are OnAir  timeout=300
    Run Keyword If  '${cells_status}'=='True'
    ...  Log To Console  All cells are onAir!
    ...  ELSE  Fail  Cells are not onAir!
    Log to Console  Waiting for generate fault on testing RMOD.${\n}
    Sleep  60s

    ${DC_1_result}  admin.Run Diagnostic Check  timeout=500
    Log to console  Diagnostic Check finished. [OK]

step3: Get DC report and check memory usage NOK status
    Log to console  ${\n}---------------------------
    Log to console  step3: Get DC report and check memory usage NOK status
    Log to console  ---------------------------${\n}

    Get DC Report And Check CP Result  checkpoint=41  expected_status=NOK  connection=${connection}

step4: Recovery level of memory usage lower than treshold
    Log to console  ${\n}---------------------------
    Log to console  step4: Recovery level of memory usage lower than treshold
    Log to console  ---------------------------${\n}

    Log to console  Override values to original in binary file${\n}
    radio.Override Values In Binary File
    ...    ru_serial_number=${RMOD_SN}
    ...    filename=sysmon_primary
    ...    values_dict=${BINARY}
    ...    reset_ru=${TRUE}

    Log to console  Reseting RMOD and wait for OnAir status${\n}
    Sleep  40s

    ${cells_status}  Run Keyword And Return Status  Check If All Cells And Modules Are OnAir  timeout=300

    Run Keyword If  '${cells_status}'=='True'
    ...  Log To Console  All cells are onAir!
    ...  ELSE  Fail  Cells are not onAir!

    ${DC_2_result}  admin.Run Diagnostic Check  timeout=500
    Log to console  Diagnostic Check finished. [OK]

step5: Get DC report and check memory usage OK status
    Log to console  ${\n}---------------------------
    Log to console  step5: Get DC report and check memory usage OK status
    Log to console  ---------------------------${\n}

    ${second_connection}  admin.Connect To  name=dc_second_connection
    Get DC Report And Check CP Result  checkpoint=41  expected_status=OK  connection=${second_connection}
    admin.Teardown  connection=${second_connection}

TC Setup
    Common Test Setup

TC Teardown
    Run Keyword If Test Failed  Run Keyword If  ${RECOVER_TRESHOLD}  radio.Override Values In Binary File
    ...    ru_serial_number=${RMOD_SN}
    ...    filename=sysmon_primary
    ...    values_dict=${BINARY}
    ...    reset_ru=${TRUE}
    Common Test Teardown
