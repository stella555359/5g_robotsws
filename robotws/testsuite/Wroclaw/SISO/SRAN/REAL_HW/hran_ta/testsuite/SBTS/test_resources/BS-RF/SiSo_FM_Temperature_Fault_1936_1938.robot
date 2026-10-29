*** Settings ***
Documentation
...  The purpose of this Test Case is to check the correct raise of faults 1936 and 1938 to prevent overheat RF.

Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_general.robot

*** Variables ***

${RMOD_SN}
${node}  default

*** Keywords ***
TC__SiSo_FM_Temperature_Fault_1936_1938
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-37029
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this Test Case is to check the correct raise of faults 1936 and 1938 to prevent overheat RF.
    ...  Files in FRMON are decoded to JSONS. (tempest_inst1_default.bin and tcs.bin).
    ...  Temperature of Pipe defined in variables.py is read from RU runtime logs.
    ...  Offset is calculated based on Thigh value in tcs.bin.
    ...  Decoded JSON tempest_inst1_default.json is downloaded to SMOD and edited (tempOffset value).
    ...  Edited JSON tempest_inst1_default.json is sent to RMOD and coded to binary file.
    ...
    ...  Fault 1936 is generated when validated module temperature exceeds or is equal to the predefined maximum value allowed.
    ...  Fault is trigger almost immediately, should be visible in fault_history_log.txt as EFaultId_FrTempHigh (1167).
    ...
    ...  Fault 1938 is generated when validated temperature of any PA or Pipe sensor in the RF module is higher than
    ...  or equal to the pre-defined value in the unit property file.
    ...  Fault is trigger up to 60s, should be visible in fault_history_log.txt as EFaultId_PipeOverheat (1169)
    ...  At the beginning, fault will have severity=Major in fault_history_log.txt and in WebEM.
    ...  After interval Tt+Tdanger defined in TCS file, fault will have severity=Critical in fault_history_log.txt
    ...  In WebEM it depends on cells configuration per antenna lines, will remain Major or will change to Critical.
    ...
    ...  TC works with RU families: 5.1*, 6.2*
    ...
    ...  *RU must be added to dictionaries in radio_variables.py.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  03.10.2023 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-37029 - Initial creation
    ...  13.01.2025 - according to CNI-113611-A fault 1936 will no longer be visible on WebEM

    Set Tags    CA-BS-RF    OWNER-malgorzata.piecyk-celuch@nokia.com    AUTHOR-malgorzata.piecyk-celuch@nokia.com
    ...    MAINTAINER-malgorzata.piecyk-celuch@nokia.com   PHASE-CRT    SW-SBTS24
    ...    CNI-98737

    step1: Preconditions
    step2: Generate FID 1936
    step3: Recover FID 1936
    step4: Generate FID 1938
    step5: Recover FID 1938

step1: Preconditions

    Log To Console  --------------------
    Log To Console  step1: Preconditions
    Log To Console  --------------------${\n}

    Run Keyword If  '${RMOD_SN}'=='${EMPTY}'
    ...  Fail  Variable RMOD_SN cannot be empty !

    ${rmods_info}  admin.Get FRM  60  ${node}

    FOR  ${rmod}  IN  @{rmods_info}
        Continue For Loop If  '${rmod['serialNumber']}'!='${RMOD_SN}'
        Set Test Variable  ${RMOD_DISTNAME_ID}  ${rmod['id']['internal']}
    END

    Run Keyword If  '${RMOD_DISTNAME_ID}'=='${NONE}'
    ...  Fail  Serial Number ${RMOD_SN} not found in HW Configuration ! Test set to Fail !
    ...  ELSE  Log To Console  RMOD with SN ${RMOD_SN} found in configuration!${\n}

    Log To Console  Soft resetting RU to clear fault_history_log.txt!${\n}
    admin.Reset Unit  ${RMOD_DISTNAME_ID}  timeout=240

    ${cells_status}  Run Keyword And Return Status  Check If All Cells Are onAir  timeout=60  alias=${node}
    Run Keyword If  '${cells_status}'=='True'
    ...  Log To Console  All cells are onAir !
    ...  ELSE
    ...  Fail  Cells are not onAir !

step2: Generate FID 1936

    Log To Console  ${\n}---------------------------
    Log To Console  step2: Generate FID 1936
    Log To Console  ---------------------------${\n}

    radio.Generate Fault  fault_id=1936  ru_serial_number=${RMOD_SN}

    Log To Console  Checking FID 1936 in fault_history_log.txt, please wait !
    ${1167_active}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  240s  30s  radio.Assert Active Fault In Fault History Log File
    ...  ru_serial_number=${RMOD_SN}
    ...  fault_id=1167
    ...  severity=minor

    Run Keyword If  '${1167_active}'=='True'
    ...  Log To Console  ${\n}Found --> Active Minor EFaultId_FrTempHigh (1167) in fault_history_log_for_fault_1167.txt !
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Fault EFaultId_FrTempHigh (1167) not found, please check fault_history_log_for_fault_1167.txt !

step3: Recover FID 1936

    Log To Console  ${\n}---------------------------
    Log To Console  step3: Recover FID 1936
    Log To Console  ---------------------------${\n}

    radio.Recover Fault  fault_id=1936  ru_serial_number=${RMOD_SN}
    Log To Console  Waiting for clear of FaultID 1936 !${\n}
    ${1167_cleared}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  5min  30s  radio.Assert Inactive Fault In Fault History Log File
    ...  ru_serial_number=${RMOD_SN}
    ...  fault_id=1167
    ...  severity=minor

    Run Keyword If  '${1167_cleared}'=='True'
    ...  Log To Console  ${\n}Found --> Inactive Minor EFaultId_FrTempHigh (1167) in fault_history_log_for_fault_1167.txt !${\n}
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Inactive fault EFaultId_FrTempHigh (1167) not found, please check fault_history_log_for_fault_1167.txt !${\n}

step4: Generate FID 1938

    Log To Console  ${\n}---------------------------
    Log To Console  step4: Generate FID 1938
    Log To Console  ---------------------------${\n}

    radio.Generate Fault  fault_id=1938  ru_serial_number=${RMOD_SN}

    Log To Console  Checking FID 1938 with severity Major in fault_history_log.txt, please wait !
    ${1169_active}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  120s  15s  radio.Assert Active Fault In Fault History Log File
    ...  ru_serial_number=${RMOD_SN}
    ...  fault_id=1169
    ...  severity=major

    Run Keyword If  '${1169_active}'=='True'
    ...  Log To Console  ${\n}Found --> Active Major EfaultId_FrPipeOverheat (1169) in fault_history_log_for_fault_1169.txt !
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Fault EfaultId_FrPipeOverheat (1169) not found, please check fault_history_log_for_fault_1169.txt !
    Sleep    60s

    Log To Console  ${\n}Checking FID 1938 with severity Critical in fault_history_log.txt, please wait !
    ${1169_active}  Run Keyword And Return Status  radio.Assert Active Fault In Fault History Log File
    ...  ru_serial_number=${RMOD_SN}
    ...  fault_id=1169
    ...  severity=critical

    Run Keyword If  '${1169_active}'=='True'
    ...  Log To Console  ${\n}Found --> Active Critical EfaultId_FrPipeOverheat (1169) in fault_history_log_for_fault_1169.txt !
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Fault EfaultId_FrPipeOverheat (1169) not found, please check fault_history_log_for_fault_1169.txt !

    Log To Console  ${\n}Waiting for raise of FaultID 1938 !${\n}
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=1938  alarmId=7116  timeout=180
    Run Keyword If  '${alarm_status}'=='True'
    ...  Log To Console  FaultID 1938 RAISED !${\n}
    ...  ELSE  Run Keywords
    ...  Log To Console  Fault 1938 NOT raised !
    ...  AND  radio.Recover Fault  fault_id=1938  ru_serial_number=${RMOD_SN}
    ...  AND  Fail  Fault 1938 NOT raised !

    ${rmod_status}  Run Keyword And Return Status  Assert  RMOD  ${RMOD_DISTNAME_ID}  availabilityStatus=regex"(?i)Degraded"  timeout=60s
    Run Keyword If  '${rmod_status}'=='True'
    ...  Log To Console  RMOD is Degraded, as expected !
    ...  ELSE  Run Keywords
    ...  Log To Console  RMOD is NOT Degraded, but it should be !
    ...  AND  radio.Recover Fault  fault_id=1938  ru_serial_number=${RMOD_SN}
    ...  AND  Fail  RMOD is NOT Degraded, but it should be !

step5: Recover FID 1938

    Log To Console  ${\n}---------------------------
    Log To Console  step5: Recover FID 1938
    Log To Console  ---------------------------${\n}

    radio.Recover Fault  fault_id=1938  ru_serial_number=${RMOD_SN}
    Log To Console  Waiting for clear of FaultID 1938 !${\n}
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Inactive  faultId=1938  timeout=330
    Run Keyword If  '${alarm_status}'=='True'
    ...  Log To Console  FaultID 1938 CLEARED !${\n}
    ...  ELSE  Run Keywords
    ...  Log To Console  Fault 1938 NOT cleared !
    ...  AND  radio.Recover Fault  fault_id=1938  ru_serial_number=${RMOD_SN}
    ...  AND  Fail  Fault 1938 NOT cleared !

    ${cells_status}  Run Keyword And Return Status  Check If All Cells Are onAir  timeout=60  alias=${node}
    Run Keyword If  '${cells_status}'=='True'
    ...  Log To Console  All cells are onAir !
    ...  ELSE
    ...  Fail  Cells are not onAir !

    ${1169_cleared}  Run Keyword And Return Status  radio.Assert Inactive Fault In Fault History Log File
    ...  ru_serial_number=${RMOD_SN}
    ...  fault_id=1169
    ...  severity=critical

    Run Keyword If  '${1169_cleared}'=='True'
    ...  Log To Console  ${\n}Found --> Inactive critical EfaultId_FrPipeOverheat (1169) in fault_history_log_for_fault_1169.txt !{\n}
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Inactive fault EfaultId_FrPipeOverheat (1169) not found, please check fault_history_log_for_fault_1169.txt !${\n}


Checking Status Of Cells
    ${cells_status}  Run Keyword And Return Status  Check If All Cells Are onAir    timeout=60  alias=${node}
    Run Keyword If  '${cells_status}'=='True'
    ...  Log To Console  All cells are onAir !{\n}
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Cells are not onAir !{\n}


TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown
