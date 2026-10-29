*** Settings ***
Documentation
...   The purpose of this Test Case is to check the correct raise of fault 1937 to prevent overheat RF.

Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_general.robot

*** Variables ***

${RMOD_SN}      # RU serial number
${node}  default


*** Keywords ***
TC__SiSo_FM_Temperature_Fault_1937
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-33601
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this Test Case is to check the correct raise of fault 1937 to prevent overheat RF.
    ...  Fault 1937 is generated when validated sensor temperature exceeds or is equal to the predefined value on the unit property file.
    ...  Files in FRMON are decoded to JSONS. (tempest_inst1_default.bin and tcs.bin)
    ...  Temperature of Unit defined in variables.py is read from RU runtime logs.
    ...  Offset is calculated based on Tdanger value in tcs.bin
    ...  Decoded JSON tempest_inst1_default.json is downloaded to SMOD and edited (tempOffset value).
    ...  Edited JSON tempest_inst1_default.json is sent to RMOD and coded to binary file.
    ...  Fault is trigger up to 60s, should be visible in fault_history_log.txt as EFaultId_FrDangerouslyOverheat (1168)
    ...  and in WebEM with Critical severity.
    ...
    ...  TC works with RU families: 5.1*, 6.2*, tested on AHPMDA
    ...
    ...  *RU must be added to dictionaries in radio_variables.py.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  08.11.2023 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-33601 - Initial creation

    Set Tags    CA-BS-RF    OWNER-malgorzata.piecyk-celuch@nokia.com    AUTHOR-malgorzata.piecyk-celuch@nokia.com
    ...    MAINTAINER-malgorzata.piecyk-celuch@nokia.com   PHASE-CRT    SW-SBTS24
    ...    CNI-101475

    step1: Preconditions
    step2: Generate FID 1937
    step3: Recover FID 1937


step1: Preconditions

    Log To Console  --------------------
    Log To Console  step1: Preconditions
    Log To Console  --------------------${\n}

    Run Keyword If  '${RMOD_SN}'=='${EMPTY}'
    ...  Fail  Variable RMOD_SN cannot be empty !

    ${rmods_info}  admin.Get FRM  60  ${node}

    FOR  ${rmod}  IN  @{rmods_info}
        Continue For Loop If  '${rmod['serialNumber']}'!='${RMOD_SN}'
        ${rmod_config_id}  Set Variable  ${rmod['id']['configuration']}
        Set Test Variable  ${RMOD_DISTNAME_ID}  ${rmod['id']['internal']}
    END

    ${rmod_id}  Query Infomodel  get object ${RMOD_DISTNAME_ID}
    ${hw_release}    Set Variable      ${rmod_id.radioModuleHwReleaseCode}
    ${hw_release}  Evaluate  re.search(r'\\d+\\.\\d+\|d+', '${hw_release}').group(0)  re

    ${status_hw_release}=    Run Keyword And Return Status     Should Be True    '${hw_release}'>='5.1'
    Run Keyword If    '${status_hw_release}'=='False'
    ...  Run Keywords
    ...  Log To Console    HW release is less than 5.1
    ...  AND  Fail    HW release is less than 5.1

    Run Keyword If  '${RMOD_DISTNAME_ID}'=='${NONE}'
    ...  Fail  Serial Number ${RMOD_SN} not found in HW Configuration ! Test set to Fail !
    ...  ELSE  Log To Console  RMOD with SN ${RMOD_SN} found in configuration!${\n}

    ${bts_params} =  admin.Get parameters for all  BTS  alias=${node}

    Log To Console  Checking cells status...${\n}
    ${cells_status}  Run Keyword And Return Status  Check If All Cells Are onAir  timeout=60  alias=${node}
    Run Keyword If  '${cells_status}'=='True'
    ...  Log To Console  All cells are onAir !${\n}
    ...  ELSE  Fail   Cells are not onAir !

    Log To Console  Getting carriers power information...${\n}
    ${all_carr}  ${off_carr}  ${wo_carr}  Get RU Carriers Power Count  ${RMOD_SN}

    Set Test Variable  ${REF_ALL_CARRIERS_COUNT}  ${all_carr}
    Set Test Variable  ${REF_OFF_CARRIERS_COUNT}  ${off_carr}
    Set Test Variable  ${REF_WORKING_CARRIERS_COUNT}  ${wo_carr}

step2: Generate FID 1937

    Log To Console  ${\n}---------------------------
    Log To Console  step2: Generate FID 1937
    Log To Console  ---------------------------${\n}

    radio.Generate Fault  fault_id=1937  ru_serial_number=${RMOD_SN}    code_type=Temporary

    Log To Console  Waiting for raise of FaultID 1937 on WebEM !${\n}
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=1937  timeout=300    severity=Critical
    Run Keyword If  '${alarm_status}'=='True'
    ...  Log To Console  FaultID 1937 RAISED !${\n}
    ...  ELSE  Run Keywords
    ...  Log To Console  Fault 1937 NOT raised !
    ...  AND  radio.Recover Fault  fault_id=1937  ru_serial_number=${RMOD_SN}
    ...  AND  Fail  Fault 1937 NOT raised !

    Log To Console  Checking FID 1937 in fault_history_log.txt, please wait !
    ${1168_active}  Run Keyword And Return Status  radio.Assert Active Fault In Fault History Log File
    ...  ru_serial_number=${RMOD_SN}
    ...  fault_id=1168
    ...  severity=critical

    Run Keyword If  '${1168_active}'=='True'
    ...  Log To Console  ${\n}Found --> Active Critical EFaultId_FrDangerouslyOverheat (1168) in fault_history_log_for_fault_1168.txt !${\n}
    ...  ELSE  Run Keywords
    ...  Log To Console  Fault EFaultId_FrDangerouslyOverheat (1168) not found, please check fault_history_log_for_fault_1168.txt !
    ...  AND  radio.Recover Fault  fault_id=1937  ru_serial_number=${RMOD_SN}
    ...  AND  Fail  Fault EFaultId_FrDangerouslyOverheat (1168) not found !

    Log To Console    Getting carriers power information...${\n}
    ${1937_all_carr}  ${1937_off_carr}  ${1937_wo_carr}  Get RU Carriers Power Count  ${RMOD_SN}
    ${off_carriers_status}  Run Keyword And Return Status
    ...  Should Be Equal As Integers  ${REF_ALL_CARRIERS_COUNT}  ${1937_off_carr}

    Run Keyword If  '${off_carriers_status}'=='True'
    ...  Log To Console  All carriers are OFF as expected !${\n}
    ...  ELSE  Run Keywords
    ...  Log To Console  Not all carriers are OFF when FaultID 1937 !
    ...  AND  radio.Recover Fault  fault_id=1937  ru_serial_number=${RMOD_SN}
    ...  AND  Fail  Not all carriers are OFF when FaultID 1937 !

    Log To Console    Checking all cells states...${\n}

    ${nr_cells}  Get Cells Mapping By RMOD Id  NR  ${RMOD_DISTNAME_ID}
    ${lte_cells}    Get Cells Mapping By RMOD Id  LTE  ${RMOD_DISTNAME_ID}
    ${wcdma_cells}  Get Cells Mapping By RMOD Id  WCDMA  ${RMOD_DISTNAME_ID}
    ${gsm_cells}  Get Cells Mapping By RMOD Id  GSM  ${RMOD_DISTNAME_ID}
    ${all_rat_cells}    Combine Lists    ${nr_cells}  ${lte_cells}  ${wcdma_cells}  ${gsm_cells}

    ${cell_state_list}    Create List
    FOR  ${cell}  IN  @{all_rat_cells}
       ${rat}  Run Keyword If  'LNCEL' in '${cell}'  Set Variable  LN
       ...  ELSE IF  'NRCEL' in '${cell}'  Set Variable  NR
       ...  ELSE IF  'WNCEL' in '${cell}'  Set Variable  WN
       ...  ELSE  Set Variable  GN
       ${cell_state}  Run Keyword And Return Status  Assert   ${rat}CEL   ${cell}  operationalState=regex"(?i)Disabled"   timeout=10s  alias=${node}
       Run Keyword If  '${cell_state}'=='True'
       ...  Log To Console  ${cell} is disabled as expected !${\n}
       ...  ELSE  Run Keywords
       ...  Log To Console  ${cell} is not disabled !
       ...  AND    Append To List    ${cell_state_list}    False
    END
    ${disabled_status}  Run Keyword And Return Status  Should be empty  ${cell_state_list}
    Run Keyword If  '${disabled_status}'=='True'
    ...  Log to console  Cell(s) are disabled as expected !${\n}
    ...  ELSE  Run Keywords
    ...  Log to console  Cell(s) are not disabled !${\n}
    ...  AND  radio.Recover Fault  fault_id=1937  ru_serial_number=${RMOD_SN}
    ...  AND  Fail  Cell(s) are not disabled !

step3: Recover FID 1937

    Log To Console  ${\n}---------------------------
    Log To Console  step3: Recover FID 1937
    Log To Console  ---------------------------${\n}

    radio.Recover Fault  fault_id=1937  ru_serial_number=${RMOD_SN}

    Log To Console  Waiting for clear of FaultID 1937 !${\n}
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Inactive  faultId=1937  timeout=300
    Run Keyword If  '${alarm_status}'=='True'
    ...  Log To Console  FaultID 1937 CLEARED !${\n}
    ...  ELSE  Run Keywords
    ...  Log To Console  Fault 1937 NOT cleared !
    ...  AND  radio.Recover Fault  fault_id=1937  ru_serial_number=${RMOD_SN}
    ...  AND  Fail  Fault 1937 NOT cleared !

    ${cells_status}  Run Keyword And Return Status  Check If All Cells Are onAir  timeout=60  alias=${node}
    Run Keyword If  '${cells_status}'=='True'
    ...  Log To Console  All cells are onAir !
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Cells are not onAir !

    ${1168_cleared}  Run Keyword And Return Status  radio.Assert Inactive Fault In Fault History Log File
    ...  ru_serial_number=${RMOD_SN}
    ...  fault_id=1168
    ...  severity=critical

    Run Keyword If  '${1168_cleared}'=='True'
    ...  Log To Console  ${\n}Found --> Inactive Critical EFaultId_FrDangerouslyOverheat (1168) in fault_history_log_for_fault_1168.txt !${\n}
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Inactive fault EFaultId_FrDangerouslyOverheat (1168) not found, please check fault_history_log_for_fault_1168.txt !${\n}

    Log To Console    Getting carriers power information...${\n}
    ${1937_all_carr}  ${1937_off_carr}  ${1937_wo_carr}  Get RU Carriers Power Count  ${RMOD_SN}
    ${carriers_status}  Run Keyword And Return Status
    ...  Should Be Equal As Integers  ${REF_WORKING_CARRIERS_COUNT}  ${1937_wo_carr}

    Run Keyword If  '${carriers_status}'=='True'
    ...  Log to console  All carriers are recovered !${\n}
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  NOT all carriers are recovered ! Set Test Fail !


Get RU Carriers Power Count
    [Arguments]  ${RMOD_SN}

    ${ref_carriers_dict}    radio.Get Carriers Power    ${RMOD_SN}    direction=Tx
    ${carriers_power_values}  Get Dictionary Values  ${ref_carriers_dict}
    ${power_values_list}  Get Power Values For RU  ${carriers_power_values}

    FOR  ${carrier}  ${power}  IN ZIP  ${ref_carriers_dict.keys()}  ${ref_carriers_dict.values()}
        Log to console  ${carrier} -> ${power}
    END

    ${all_carr_count}  Get Length    ${power_values_list}
    ${off_carr_count}  Get Match Count  ${power_values_list}  OFF
    ${WO_carr_count}  Evaluate  ${all_carr_count}-${off_carr_count}

    [Return]  ${all_carr_count}  ${off_carr_count}  ${WO_carr_count}


Get Power Values For RU
    [Arguments]  ${carriers_power_list}

    ${power_list}  Create List
    FOR  ${carriers}  IN  @{carriers_power_list}
        ${power}  Get Dictionary Values  ${carriers}
        Append To List  ${power_list}  ${power}
    END
    ${power_list}  Evaluate  [x for y in ${power_list} for x in y]

    [Return]  ${power_list}


TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown
