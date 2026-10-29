*** Settings ***
Documentation
...  The purpose of this Test Case is to check the correct raise of fault 1933 to prevent overheat RF

Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_general.robot

*** Variables ***

${RMOD_SN}    	# RU serial number
${node}  default

*** Keywords ***
TC__SiSo_FM_Temperature_Fault_1933
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-33601
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this Test Case is to check the correct raise of fault 1933 to prevent overheat RF
    ...  and verify of correct operation of fan(s).
    ...  Fault ID name according to NIDD: EFaultId_FrFanBroken.
    ...  Files in FRMON are decoded to JSONS. (tempest_inst1_default.bin and tcs.bin).
    ...  In tcs.json values: Nrmp_fail, deltaTmulti and deltaTctl are modified and RU reboot is performed.
    ...  Temperature of Pipe defined in variables.py is read from RU runtime logs.
    ...  Offset is calculated based on Thigh value in tcs.bin.
    ...  Decoded JSON tempest_inst1_default.json is downloaded to SMOD and edited (tempOffset value).
    ...  Edited JSON tempest_inst1_default.json is sent to RMOD and coded to binary file.
    ...  Fan setpoint is modified to value: 0.
    ...  Fault is trigger up to 60s, should be visible with severity Minor on WebEm and in fault_history_log.txt
    ...  as EFaultId_FanBroken (1164) with severity Critical.
    ...  With FID 1933 may be visible FID: 1927, 1936, 1938 depends on Tblock value in TCS file.
    ...
    ...  TC works with RU families: 5.1*, 6.2*, tested on AHEGHA, AHPMDH, AHLOB.
    ...
    ...  *RU must be added to dictionaries in radio_variables.py.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  02.04.2024 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-33601 - Initial creation

    Set Tags    CA-BS-RF    OWNER-malgorzata.piecyk-celuch@nokia.com    AUTHOR-malgorzata.piecyk-celuch@nokia.com
    ...    MAINTAINER-malgorzata.piecyk-celuch@nokia.com   PHASE-CRT    SW-SBTS24    CNI-101475

    step1: Preconditions
    step2: Generate FID 1933
    step3: Recover FID 1933

step1: Preconditions

    Log  --------------------  console=True
    Log  ${\n}step1: Preconditions  console=True
    Log  --------------------${\n}  console=True

    Run Keyword If  '${RMOD_SN}'=='${EMPTY}'
    ...  Fail  Variable RMOD_SN cannot be empty !

    ${rmods_info}  admin.Get FRM  60  ${node}

    FOR  ${rmod}  IN  @{rmods_info}
        Continue For Loop If  '${rmod['serialNumber']}'!='${RMOD_SN}'
        Set Test Variable  ${RMOD_DISTNAME_ID}  ${rmod['id']['internal']}
    END

    Run Keyword If  '${RMOD_DISTNAME_ID}'=='${NONE}'
    ...  Fail  Serial Number ${RMOD_SN} not found in HW Configuration ! Test set to Fail !
    ...  ELSE  Log  RMOD with SN ${RMOD_SN} found in configuration!${\n}  console=True

    Log  Soft resetting RU to clear fault_history_log.txt!${\n}  console=True
    admin.Reset Unit  ${RMOD_DISTNAME_ID}  timeout=320

    ${cells_status}  Run Keyword And Return Status  Check If All Cells Are onAir  timeout=60  alias=${node}
    Run Keyword If  '${cells_status}'=='True'
    ...  Log  All cells are onAir !  console=True
    ...  ELSE
    ...  Fail  Cells are not onAir !

step2: Generate FID 1933

    Log  ${\n}-------------------  console=True
    Log  step2: Generate FID 1933  console=True
    Log  -------------------${\n}  console=True

    radio.Generate Fault  fault_id=1933  ru_serial_number=${RMOD_SN}  reboot_timeout=320

    Log  Waiting for raise of FaultID 1933 !  console=True
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=1933  severity=Minor  timeout=180
    Run Keyword If  '${alarm_status}'=='True'
    ...  Log  FaultID 1933 RAISED !${\n}  console=True
    ...  ELSE  Run Keywords
    ...  Log  Fault 1933 NOT raised !  console=True
    ...  AND  radio.Recover Fault  fault_id=1933  ru_serial_number=${RMOD_SN}
    ...  AND  Fail  Fault 1933 NOT raised !

    Log  Checking FauldID 1933 in fault_history_log.txt, please wait !  console=True
    ${1164_active}  Run Keyword And Return Status  radio.Assert Active Fault In Fault History Log File
    ...  ru_serial_number=${RMOD_SN}
    ...  fault_id=1164
    ...  severity=critical
    Run Keyword If  '${1164_active}'=='True'
    ...  Log  Found --> Active Critical EFaultId_FanBroken (1164) in fault_history_log_for_fault_1164.txt !${\n}  console=True
    ...  ELSE  Run Keywords
    ...  Log  Fault 1933 is not visible in fault_history_log.txt !  console=True
    ...  AND  radio.Recover Fault  fault_id=1933  ru_serial_number=${RMOD_SN}
    ...  AND  Fail  Fault EFaultId_FanBroken (1164) not found, please check fault_history_log_for_fault_1164.txt !

    Log  Checking presence of other temperature faults  console=True
    ${1927_status}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=1927  severity=Major   timeout=180
    ${1938_status}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=1938  severity=Major   timeout=180
    Run Keyword If  '${1927_status}'=='True' or '${1938_status}'=='True'  Run Keywords
    ...  Log  Additional faults are presence, checking if RMOD is degraded  console=True
    ...  AND  Check availability status of RMOD
    ...  ELSE
    ...  Log  No other visible faults  console=True

step3: Recover FID 1933

    Log  ${\n}------------------  console=True
    Log  step3: Recover FID 1933  console=True
    Log  ------------------${\n}  console=True

    radio.Recover Fault  fault_id=1933  ru_serial_number=${RMOD_SN}

    Log  Waiting for clear of FaultID 1933 !${\n}  console=True
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Inactive  faultId=1933  timeout=300
    Run Keyword If  '${alarm_status}'=='True'
    ...  Log  FaultID 1933 CLEARED !${\n}  console=True
    ...  ELSE  Run Keywords
    ...  Log  Fault 1933 NOT cleared !  console=True
    ...  AND  radio.Recover Fault  fault_id=1933  ru_serial_number=${RMOD_SN}
    ...  AND  Fail  Fault 1933 NOT cleared !

    ${cells_status}  Run Keyword And Return Status  Check If All Cells Are onAir  timeout=60  alias=${node}
    Run Keyword If  '${cells_status}'=='True'
    ...  Log To Console  All cells are onAir !
    ...  ELSE
    ...  Fail  Cells are not onAir !

Check availability status of RMOD
    ${rmod_state}  Run Keyword And Return Status  admin.Assert  RMOD  ${RMOD_DISTNAME_ID}
    ...  availabilityStatus=regex"(?i)Degraded"  timeout=180s  alias=${node}
    Run Keyword If  '${rmod_state}'=='True'
    ...  Log  ${\n}RMOD is degraded as expected !${\n}  console=True
    ...  ELSE  Run Keywords
    ...  Log  RMOD is not degraded !  console=True
    ...  AND  radio.Recover Fault  fault_id=1933  ru_serial_number=${RMOD_SN}
    ...  AND  Fail  RMOD is not degraded, as expected! Recovery performed.  console=True

TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown
