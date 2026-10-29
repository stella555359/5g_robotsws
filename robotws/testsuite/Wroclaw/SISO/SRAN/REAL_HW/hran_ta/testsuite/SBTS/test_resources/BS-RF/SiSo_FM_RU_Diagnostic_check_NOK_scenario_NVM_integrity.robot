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
TC__SiSo_FM_RU_Diagnostic_check_NOK_scenario_NVM_integrity
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-41927
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this Test Case is to check the correct information about radio check points in Diagnostic Check.
    ...  Active fault causes change in RU diagnostic check report - check point RU SW package and NVM integrity (ID40)
    ...  change status from OK to NOK.
    ...  TC check if NOK status is visible.
    ...  Check point RU Temperature sensor (ID40) should change status to OK.
    ...
    ...  TC works with RU families: 5.1*, 6.2*, tested on AHFIB, AHFII.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 07.12.2023 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-41927 - Initial creation
    ...  - 19.06.2024 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-47585 - Add checking OK status in preconditions
    ...  - 13.01.2024 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-49170 - changes due to pronto 04237743

    Set Tags
    ...    OWNER-lukasz.wystup@nokia.com
    ...    AUTHOR-lukasz.wystup@nokia.com
    ...    MAINTAINER-lukasz.wystup@nokia.com
    ...    FEATURE-CB010823

    step1: Preconditions
    step2: Change CRC32 hash in integrity json for active slot
    step3: Get DC report and check NVM integrity NOK status
    step4: Recovery CRC32 hash in integrity json for active slot
    step5: Get DC report and check NVM integrity OK status

step1: Preconditions

    Log to console  --------------------
    Log to console  step1: Preconditions
    Log to console  --------------------${\n}

    Preconditions For CNI-127210
    ${release}  admin.Get Sw Release Name  connection=${node}
    ${proper_sw}  Run Keyword If  "${release}"=="SBTS24R3" and ${PRECOND_FOR_CNI}
    ...  Check If Current Build Is Newer Than  SBTS24R3_ENB_0000_000536_000000
    ...  ELSE IF  ${PRECOND_FOR_CNI}  Check If Current Build Is Newer Than  SBTS25R1_ENB_9999_240926_000004
    Run keyword If   ${proper_sw}  Set Test Variable  ${PRECOND_FOR_CNI}  False
    Set Test Variable  ${RECOVER_CRC32}  ${FALSE}
    Check If RMOD Is Avaliable In Config And Prepare Distname For Diagnostic Check
    ${DC_0_result}  admin.Run Diagnostic Check  timeout=500
    Log to console  Diagnostic Check finished. [OK]
    ${zero_connection}  admin.Connect To  name=dc_zero_connection
    Get DC Report And Check CP Result  checkpoint=40  expected_status=OK  connection=${zero_connection}  precondition=${TRUE}
    admin.Teardown  connection=${zero_connection}

step2: Change CRC32 hash in integrity json for active slot
    Log to console  ${\n}---------------------------
    Log to console  step2: Change CRC32 hash in integrity json for active slot
    Log to console  ---------------------------${\n}

    Set Test Variable  ${RECOVER_CRC32}  ${TRUE}
    ${new_values_dict}  Create Dictionary  0=da6b0a13  1=4f32ab21  2=9263d712
    ${stored_crc32_value}  radio.Override CRC32 Hash In Integrity File
    ...  ru_serial_number=${RMOD_SN}
    ...  new_value=${new_values_dict}
    Set Test Variable  ${ORIGINAL_CRC32}  ${stored_crc32_value}

    Log to console  Override values ${stored_crc32_value} in integrity json.${\n}

    Set Test Variable  ${DEGRADED_CELL_REGEX}  availabilityStatus=regex"[Dd]egraded|[Ff]ailed|[Oo]ff\\s?line"

    ${cells_status}  Run Keyword And Return Status  Check If All Cells And Modules Are OnAir  timeout=300
    Run Keyword If  '${cells_status}'=='True'
    ...  Log To Console  All cells are onAir!
    ...  ELSE  Fail  Cells are not onAir!
    Log to Console  Waiting for generate fault on testing RMOD.${\n}
    Set Start Timestamp In IMS For CNI-127210
    Sleep  60s

    ${DC_1_result}  admin.Run Diagnostic Check  timeout=500
    Log to console  Diagnostic Check finished. [OK]
    Check Active Fault In IMS For CNI-127210  fault_id=4681  severity=Minor
    Check Diagnostic Check Error Status  fault_status=Active

step3: Get DC report and check NVM integrity NOK status
    Log to console  ${\n}---------------------------
    Log to console  step3: Get DC report and check NVM integrity NOK status
    Log to console  ---------------------------${\n}

    Get DC Report And Check CP Result  40  NOK  ${connection}

step4: Recovery CRC32 hash in integrity json for active slot
    Log to console  ${\n}---------------------------
    Log to console  step4: Recovery CRC32 hash in integrity json for active slot
    Log to console  ---------------------------${\n}

    Set Start Timestamp In IMS For CNI-127210
    Log to console  Override values to original in binary file${\n}
    radio.Override CRC32 Hash In Integrity File
    ...  ru_serial_number=${RMOD_SN}
    ...  new_value=${ORIGINAL_CRC32}

    ${cells_status}  Run Keyword And Return Status  Check If All Cells And Modules Are OnAir  timeout=300

    Run Keyword If  '${cells_status}'=='True'
    ...  Log To Console  All cells are onAir!
    ...  ELSE  Fail  Cells are not onAir!

    ${DC_2_result}  admin.Run Diagnostic Check  timeout=500
    Log to console  Diagnostic Check finished. [OK]

step5: Get DC report and check NVM integrity OK status
    Log to console  ${\n}---------------------------
    Log to console  step5: Get DC report and check NVM integrity OK status
    Log to console  ---------------------------${\n}

    ${second_connection}  admin.Connect To  name=dc_second_connection
    Get DC Report And Check CP Result  40  OK  ${second_connection}
    admin.Teardown  connection=${second_connection}
    Check Removed Active Fault In IMS For CNI-127210
    Check Diagnostic Check Error Status  fault_status=Inactive

TC Setup
    Common Test Setup

TC Teardown
    Run Keyword If Test Failed  Run Keyword If  ${RECOVER_CRC32}  radio.Override CRC32 Hash In Integrity File
    ...  ru_serial_number=${RMOD_SN}
    ...  new_value=${ORIGINAL_CRC32}
    Common Test Teardown
