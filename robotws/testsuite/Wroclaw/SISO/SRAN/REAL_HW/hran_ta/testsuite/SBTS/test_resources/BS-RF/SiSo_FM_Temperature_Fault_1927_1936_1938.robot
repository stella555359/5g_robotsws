*** Settings ***
Documentation
...  The purpose of this Test Case is to check the correct raise of faults 1927, 1936, 1938 to prevent overheat RF.

Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_general.robot

*** Variables ***

${RMOD_SN}
@{FAULT_1938_ALLOWED}  AHCA  AHFIB   #list of RMODs with allowed fault 1938 when fault 1927 major appear
${node}  default

*** Keywords ***
TC__SiSo_FM_Temperature_Fault_1927_1936_1938
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
    ...  Faults are checked in WebEM and fault_history_log.txt on RU.
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
    step4: Generate FID 1927 with severity Minor
    step5: Recover FID 1927
    step6: Generate FID 1927 with severity Major
    step7: Recover FID 1927
    step8: Generate FID 1938
    step9: Recover FID 1938

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
        Set Test Variable  ${RMOD_NAME}  ${rmod['productName']}
    END

    Run Keyword If  '${RMOD_DISTNAME_ID}'=='${NONE}'
    ...  Fail  Serial Number ${RMOD_SN} not found in HW Configuration ! Test set to Fail !
    ...  ELSE  Log To Console  RMOD with SN ${RMOD_SN} found in configuration!${\n}

    ${bts_params}  admin.Get parameters for all  BTS  alias=${node}
    ${bts_id}  Set Variable  ${bts_params[0].btsId}

    Set Test Variable    ${FMCADM_OBJECT}    MRBTS-${bts_id}/MNL-1/MNLENT-1/FMCADM-1

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

    ${cells_status}  Run Keyword And Return Status  Check If All Cells Are onAir  timeout=60  alias=${node}
    Run Keyword If  '${cells_status}'=='True'
    ...  Log To Console  All cells are onAir !
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Cells are not onAir !

step4: Generate FID 1927 with severity Minor

    Log To Console  ${\n}---------------------------
    Log To Console  step4: Generate FID 1927 with severity Minor
    Log To Console  ---------------------------${\n}

    Log To Console  Perform recommissioning, please wait !${\n}
    admin.Perform Parameter Recommissioning  ${FMCADM_OBJECT}  actPipePowerDecreased1dBFaults  update  true  alias=${node}
    Log To Console  Perform recommissioning done, set:${\n}actPipePowerDecreased1dBFaults -> true${\n}

    radio.Generate Fault  fault_id=1927  ru_serial_number=${RMOD_SN}  severity=Minor
    Log To Console  Checking FID 1927 with severity Minor in fault_history_log.txt, please wait !
    ${1312_active}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  120s  15s  radio.Assert Active Fault In Fault History Log File
    ...  ru_serial_number=${RMOD_SN}
    ...  fault_id=1312
    ...  severity=minor

    Run Keyword If  '${1312_active}'=='True'
    ...  Log To Console  Found --> Active Minor EFaultId_FrPowerDecreased (1312) in fault_history_log_for_fault_1312.txt !
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Fault EFaultId_FrPowerDecreased (1312) not found, please check fault_history_log_for_fault_1312.txt !

    Log To Console  ${\n}Waiting for raise of FaultID 1927 with severity Minor !
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=1927  severity=Minor    timeout=300
    Run Keyword If  '${alarm_status}'=='True'
    ...  Log To Console  FaultID 1927 with severity Minor raised !${\n}
    ...  ELSE  Run Keywords
    ...  Log To Console  Fault 1927 with severity Minor not raised !
    ...  AND  radio.Recover Fault  fault_id=1927  ru_serial_number=${RMOD_SN}
    ...  AND  admin.Perform Parameter Recommissioning  ${FMCADM_OBJECT}  actPipePowerDecreased1dBFaults  update  false  alias=${node}
    ...  AND  Fail  Fault 1927 with severity Minor not raised !

    ${cells_status}  Run Keyword And Return Status  Check If All Cells Are onAir  timeout=60  alias=${node}
    Run Keyword If  '${cells_status}'=='True'
    ...  Log To Console  All cells are onAir !
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Cells are not onAir !

step5: Recover FID 1927

    Log To Console  ${\n}---------------------------
    Log To Console  step5: Recover FID 1927
    Log To Console  ---------------------------${\n}

    radio.Recover Fault  fault_id=1927  ru_serial_number=${RMOD_SN}

    Log To Console  Waiting for clear of FaultID 1927 !${\n}
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Inactive  faultId=1927  timeout=300
    Run Keyword If  '${alarm_status}'=='True'
    ...  Log To Console  FaultID 1927 CLEARED !${\n}
    ...  ELSE  Run Keywords
    ...  Log To Console  Fault 1927 NOT cleared !
    ...  AND  radio.Recover Fault  fault_id=1927  ru_serial_number=${RMOD_SN}
    ...  AND  admin.Perform Parameter Recommissioning  ${FMCADM_OBJECT}  actPipePowerDecreased1dBFaults  update  false  alias=${node}
    ...  AND  Fail  Fault 1927 NOT cleared !

    ${cells_status}  Run Keyword And Return Status  Check If All Cells Are onAir  timeout=60  alias=${node}
    Run Keyword If  '${cells_status}'=='True'
    ...  Log To Console  All cells are onAir !
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Cells are not onAir !

    ${1312_cleared}  Run Keyword And Return Status  radio.Assert Inactive Fault In Fault History Log File
    ...  ru_serial_number=${RMOD_SN}
    ...  fault_id=1312
    ...  severity=minor

    Run Keyword If  '${1312_cleared}'=='True'
    ...  Log To Console  ${\n}Found --> Inactive Minor EFaultId_FrPowerDecreased (1312) in fault_history_log_for_fault_1312.txt !
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Inactive fault EFaultId_FrPowerDecreased (1312) not found, please check fault_history_log_for_fault_1312.txt !

step6: Generate FID 1927 with severity Major

    Log To Console  ${\n}---------------------------
    Log To Console  step6: Generate FID 1927 with severity Major
    Log To Console  ---------------------------${\n}

    radio.Generate Fault  fault_id=1927  ru_serial_number=${RMOD_SN}  severity=Major
    Log To Console  Checking FID 1927 with severity Major in fault_history_log.txt, please wait !
    ${1152_active}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  120s  15s  radio.Assert Active Fault In Fault History Log File
    ...  ru_serial_number=${RMOD_SN}
    ...  fault_id=1152
    ...  severity=major

    Run Keyword If  '${1152_active}'=='True'
    ...  Log To Console  Found --> Active Major EFaultId_FrPowerDecreased (1152) in fault_history_log_for_fault_1152.txt !
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Fault EFaultId_FrPowerDecreased (1152) not found, please check fault_history_log_for_fault_1152.txt !

    Log To Console  Waiting for raise of FaultID 1927 with severity Major !${\n}
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=1927  severity=Major    timeout=300
    Run Keyword If  '${alarm_status}'=='True'
    ...  Log To Console  FaultID 1927 with severity Major raised !${\n}
    ...  ELSE  Run Keywords
    ...  Log To Console  Fault 1927 with severity Major not raised !
    ...  AND  radio.Recover Fault  fault_id=1927  ru_serial_number=${RMOD_SN}
    ...  AND  admin.Perform Parameter Recommissioning  ${FMCADM_OBJECT}  actPipePowerDecreased1dBFaults  update  false  alias=${node}
    ...  AND  Fail  Fault 1927 with severity Major not raised !

    ${rmod_status}  Run Keyword And Return Status  Assert  RMOD  ${RMOD_DISTNAME_ID}  availabilityStatus=regex"(?i)Degraded"  timeout=60s
    Run Keyword If  '${rmod_status}'=='True'
    ...  Log To Console  RMOD is Degraded, as expected !
    ...  ELSE  Run Keywords
    ...  Log To Console  RMOD is NOT Degraded, but it should be !
    ...  AND  radio.Recover Fault  fault_id=1927  ru_serial_number=${RMOD_SN}
    ...  AND  admin.Perform Parameter Recommissioning  ${FMCADM_OBJECT}  actPipePowerDecreased1dBFaults  update  false  alias=${node}
    ...  AND  Fail  RMOD is NOT Degraded, but it should be !

    ${1938_verification}  Run Keyword And Return Status  List Should Not Contain Value  ${FAULT_1938_ALLOWED}  ${RMOD_NAME}
    Run Keyword If  '${1938_verification}'=='False'  Run Keywords
    ...  Log  For ${RMOD_NAME} fault 1938 can appear and it is allowed, verification will be performed  console=True
    ...  AND  Check Fault 1938 Occurrence  ${RMOD_SN}

step7: Recover FID 1927

    Log To Console  ${\n}---------------------------
    Log To Console  step7: Recover FID 1927
    Log To Console  ---------------------------${\n}

    radio.Recover Fault  fault_id=1927  ru_serial_number=${RMOD_SN}
    Log To Console  Waiting for clear of FaultID 1927 !${\n}
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Inactive  faultId=1927  timeout=330
    Run Keyword If  '${alarm_status}'=='True'
    ...  Log To Console  FaultID 1927 CLEARED !${\n}
    ...  ELSE  Run Keywords
    ...  Log To Console  Fault 1927 NOT cleared !
    ...  AND  radio.Recover Fault  fault_id=1927  ru_serial_number=${RMOD_SN}
    ...  AND  admin.Perform Parameter Recommissioning  ${FMCADM_OBJECT}  actPipePowerDecreased1dBFaults  update  false  alias=${node}
    ...  AND  Fail  Fault 1927 NOT cleared !

    ${cells_status}  Run Keyword And Return Status  Check If All Cells Are onAir  timeout=60  alias=${node}
    Run Keyword If  '${cells_status}'=='True'
    ...  Log To Console  All cells are onAir !
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Cells are not onAir !

    ${1152_cleared}  Run Keyword And Return Status  radio.Assert Inactive Fault In Fault History Log File
    ...  ru_serial_number=${RMOD_SN}
    ...  fault_id=1152
    ...  severity=major

    Run Keyword If  '${1152_cleared}'=='True'
    ...  Log To Console  ${\n}Found --> Inactive Major EFaultId_FrPowerDecreased (1152) in fault_history_log_for_fault_1152.txt !${\n}
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Inactive fault EFaultId_FrPowerDecreased (1152) not found, please check fault_history_log_for_fault_1152.txt !${\n}

    Log To Console  Perform recommissioning, please wait!${\n}
    admin.Perform Parameter Recommissioning  ${FMCADM_OBJECT}  actPipePowerDecreased1dBFaults  update  false  alias=${node}
    Log To Console  Perform recommissioning done, set:${\n}actPipePowerDecreased1dBFaults -> false

step8: Generate FID 1938

    Log To Console  ${\n}---------------------------
    Log To Console  step8: Generate FID 1938
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
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=1938  timeout=180
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

step9: Recover FID 1938

    Log To Console  ${\n}---------------------------
    Log To Console  Recover FID 1938
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
    ...  Log To Console  ${\n}Found --> Inactive critical EfaultId_FrPipeOverheat (1169) in fault_history_log_for_fault_1169.txt !
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Inactive fault EfaultId_FrPipeOverheat (1169) not found, please check fault_history_log_for_fault_1169.txt !${\n}

Check Fault 1938 Occurrence
    [Arguments]  ${rmod_sn}
    Log To Console  Checking FID 1938 in fault_history_log.txt, please wait !
    ${1169major_active}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  120s  15s  radio.Assert Active Fault In Fault History Log File
    ...  ru_serial_number=${RMOD_SN}
    ...  fault_id=1169
    ...  severity=major
    Run Keyword If  '${1169major_active}'=='True'
    ...  Log To Console  ${\n}Found --> Active Major EfaultId_FrPipeOverheat (1169) in fault_history_log_for_fault_1169.txt !
    Sleep  60s

    ${1169critical_active}  Run Keyword And Return Status  radio.Assert Active Fault In Fault History Log File
    ...  ru_serial_number=${RMOD_SN}
    ...  fault_id=1169
    ...  severity=critical
    Run Keyword If  '${1169critical_active}'=='True'
    ...  Log To Console  ${\n}Found --> Active Critical EfaultId_FrPipeOverheat (1169) in fault_history_log_for_fault_1169.txt !

    Log To Console  ${\n}Checking FID 1938 on WebEM !${\n}
    ${1938_webem}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=1938  timeout=180
    Run Keyword If  '${1169major_active}'=='True' or '${1169critical_active}'=='True' or '${1938_webem}'=='True'  Run Keywords
    ...  Log To Console  FaultID 1938 RAISED !${\n}
    ...  AND  step9: Recover FID 1938
    ...  ELSE
    ...  Log To Console  Fault 1938 NOT raised !


TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown
