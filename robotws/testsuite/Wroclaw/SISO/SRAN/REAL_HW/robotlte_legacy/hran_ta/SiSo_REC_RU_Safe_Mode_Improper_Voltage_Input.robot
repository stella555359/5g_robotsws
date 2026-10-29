*** Settings ***
Documentation
...  The purpose of this Test Case is to check the correct raise of alarms indicate problems with RU power supply

Resource   resources/ca_BSRF_general.robot
Library  taf.sbts.oam.coam.admin    WITH NAME    admin

*** Variables ***

${RMOD_SN}   L1182013373      # RU serial number
${VOLT_HIGH_THRESHOLD}  57    # Range is 57-60, step 0.5
${VOLT_LOW_THRESHOLD}  40.5     # Range is 36-40.5
${TOO_HIGH_VOLT}  60          #  Value must be higher than ${VOLT_HIGH_THRESHOLD}
${TOO_LOW_VOLT}  37           #  Value must be lower than ${VOLT_LOW_THRESHOLD}
${NOMINAL_VOLT}  52           #  Nominal voltage value, range is 40.5 - 57
${node}  default
${REMOTE_HOST}

*** Keywords ***
TC__SiSo_REC_RU_Safe_Mode_Improper_Voltage_Input
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-21968
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this Test Case is to check the correct raise of alarms indicate problems with RU power supply.
    ...  Fault for voltage too low:
    ...  Range: -36DCV to -40.5DCV, default -40.5DCV, step 0.5DCV
    ...  Critical severity - when RU DC voltage lower than threshold
    ...  Fault for voltage too high:
    ...  Range: -57DCV to -60DCV, default -57DCV, step 0.5DCV
    ...  Critical severity - when RU DC voltage lower than threshold
    ...  Fault for unstable voltage counter:
    ...  Range: 0 to 10, default: 5, step: 1, 0 means disable
    ...  Fault is generated when input voltage low/high fault is triggered repeatedly and exceed the configured counter threshold.
    ...  In all cases RU automatously go to "safe-mode"
    ...  Thresholds are configured per RU and it can be done via WebEM/NMS/CLI.
    ...
    ...  "Safe-mode" is checked by the lack of carriers power.
    ...  Faults are checked in WebEM and fault_history_log.txt on RU
    ...  fault_history_log.txt is saved in Test Files directory after execution
    ...  TC works with RU families: GAIA, 5.1*, 6.0*, 6.1* and 6.2*
    ...
    ...  * means, that RU must be added to dictionaries in ca_BSRF_radio_operation.py
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 11.10.2021 - https://jira3.int.net.nokia.com/browse/TAT-21968 - Initial creation
    ...  - 07.12.2021 - https://jira3.int.net.nokia.com/browse/TAT-22174 - 5.1 and 6.1 RUs support added
    ...  - 21.06.2022 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-8933 - 6.2 - Zodiac RUs support added

    Set Tags    CA-BS-RF    OWNER-mateusz.kawka@nokia.com    AUTHOR-mateusz.kawka@nokia.com
    ...    MAINTAINER-mateusz.kawka@nokia.com    GROUP_IN_CHARGE-WRO_3_Vrf    PHASE-CRT    SW-SBTS22
    ...    FEATURE-CB007086  FEATURE-CB008222
  Common Test Setup
  Logging With Timestamp
    ...  message=TC__SiSo_REC_RU_Safe_Mode_Improper_Voltage_Input will be executed
    ...  style=STEP
    ...  frame=${TRUE}
    SiSo_REC_RU_Safe_Mode_Improper_Voltage_Input.step1: Preconditions
    step2: Set Too Low Voltage On RU
    step3: Set Too High Voltage On RU
    step4: Set Unstable Voltage On RU
  [Teardown]    Common Test Teardown

step1: Preconditions
    Logging With Timestamp
    ...  message=step1: Preconditions
    ...  style=STEP
    ...  frame=${TRUE}

    Run Keyword If  '${RMOD_SN}'=='${EMPTY}'
    ...  Fail  Variable RMOD_SN cannot be empty !

    ${voltage_percent_dict}  Create Dictionary
    ...  36=-120  36.5=-118  37=-116  37.5=-114  38=-112  38.5=-109  39=-107  39.5=-105  40=-103  40.5=-100
    ...  57=100  57.5=104  58=107  58.5=110  59=114  59.5=117  60=120

    ${percent_values_status}  Check If Current Build Is Newer Than    SBTS24R3_ENB_9999_240319_000001  alias=${node}

    ${rmods_info}  admin.Get FRM  60  ${node}

    FOR  ${rmod}  IN  @{rmods_info}
        Continue For Loop If  '${rmod['serialNumber']}'!='${RMOD_SN}'
        ${rmod_config_id}  Set Variable  ${rmod['id']['configuration']}
        ${rmod_distname_id}  Set Variable  ${rmod['id']['internal']}
    END

    Set Test Variable  ${RMOD_DISTNAME_ID}

    Run Keyword If  '${rmod_distname_id}'=='${NONE}'
    ...  Fail  Serial Number ${RMOD_SN} not found in HW Configuration ! Test set to Fail !
    ...  ELSE
    ...  Logging With Timestamp
    ...  message=RMOD with SN ${RMOD_SN} found in configuration!${\n}

    Logging With Timestamp
    ...  message=Soft resetting RU to clear fault_history_log.txt!

    admin.Reset Unit  ${RMOD_DISTNAME_ID}  timeout=300  connection=${node}

    ${cells_status}  Run Keyword And Return Status  Check If All Cells Are onAir  timeout=900  alias=${node}
    Run Keyword If  '${cells_status}'=='True'
    ...  Logging With Timestamp
    ...  message=All cells are onAir
    ...  ELSE
    ...  Fail  Cells are not onAir after RU soft reset!

    ${rmod_number}  Evaluate  '${rmod_config_id}'.rsplit('-',1)[1]

    ${bts_params} =  admin.Get parameters for all  BTS  connection=${node}
    Set Test Variable  ${BTS_ID}  ${bts_params[0].btsId}

    Set Test Variable  ${object_thresholds}  MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${rmod_number}

    Logging With Timestamp
    ...  message=Delta recommissioning, please wait!
    ${high_volt_numeric}  Evaluate  int(${VOLT_HIGH_THRESHOLD})*10
    ${low_volt_numeric}  Evaluate  int(${VOLT_LOW_THRESHOLD})*10

    ${high_volt_percent}  Get From Dictionary  ${voltage_percent_dict}  ${VOLT_HIGH_THRESHOLD}
    ${low_volt_percent}  Get From Dictionary  ${voltage_percent_dict}  ${VOLT_LOW_THRESHOLD}

    ${high_volt}  Set Variable If  ${percent_values_status}  ${high_volt_percent}  ${high_volt_numeric}
    ${low_volt}  Set Variable If  ${percent_values_status}  ${low_volt_percent}  ${low_volt_numeric}

    ${unstable_counter}  Set Variable  2
    ${unstable_counter}  Evaluate  int(${unstable_counter})

    admin.Create Delta
    admin.Append Parameter Update To Delta   ${object_thresholds}  alVoltHighThreshold  ${high_volt}
    admin.Append Parameter Update To Delta   ${object_thresholds}  alVoltLowThreshold  ${low_volt}
    admin.Append Parameter Update To Delta   ${object_thresholds}  alVoltUnstableThreshold  ${unstable_counter}

    ${delta}  admin.Get Delta
    admin.Perform Delta Recommissioning  ${delta}  connection=${node}
    admin.Remove Delta

    Logging With Timestamp
    ...  message=Delta recommissioning done, set:
    ...  message_2=alVoltHighThreshold -> ${VOLT_HIGH_THRESHOLD} Volt
    Logging With Timestamp
    ...  message=alVoltLowThreshold -> ${VOLT_LOW_THRESHOLD} Volt
    ...  message_2=alVoltUnstableThreshold -> ${unstable_counter}

    Sleep  60s

    ${all_carr}  ${off_carr}  ${wo_carr}  Get RU Carriers Power Count  ${RMOD_SN}  ${REMOTE_HOST}

    Set Test Variable  ${REF_ALL_CARRIERS_COUNT}  ${all_carr}
    Set Test Variable  ${REF_OFF_CARRIERS_COUNT}  ${off_carr}
    Set Test Variable  ${REF_WORKING_CARRIERS_COUNT}  ${WO_carr}
    Set Test Variable  ${UNSTABLE_COUNTER}

step2: Set Too Low Voltage On RU
    Logging With Timestamp
    ...  message=step2: Set Low Votage On RU
    ...  style=STEP
    ...  frame=${TRUE}

    Set Voltage On RU  ${TOO_LOW_VOLT}
    Logging With Timestamp
    ...  message=Waiting for raise of FaultID 2920!
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=2920  timeout=60  connection=${node}
    admin.Add Allowed Alarm  faultId=2920  connection=${node}
    Run Keyword If  '${alarm_status}'=='True'
    ...  Logging With Timestamp
    ...  message=FaultID 2920 RAISED !
    ...  ELSE  Run Keywords
    ...  Logging With Timestamp
    ...  message=Fault 2920 NOT raised ! Voltage restoring to ${NOMINAL_VOLT} Volt !
    ...  AND  Set Voltage On RU  ${NOMINAL_VOLT}
    ...  AND  Fail  Fault 2920 NOT raised !

    ${1340_active}  Run Keyword And Return Status
    ...    radio.Assert Active Fault In Fault History Log File
    ...    ru_serial_number=${RMOD_SN}
    ...    fault_id=1340
    ...    severity=critical
    ...    remote_host=${REMOTE_HOST}
    admin.Add Allowed Alarm  faultId=1340  connection=${node}
    Run Keyword If  ${1340_active}
    ...  Logging With Timestamp
    ...  message=Found --> Active critical EFaultId_DCInputVoltageTooLow (1340) in fault_history_log.txt !
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Fault EFaultId_DCInputVoltageTooLow (1340) not found, please check fault_history_log.txt!

    ${2920_all_carr}  ${2920_off_carr}  ${2920_wo_carr}  Get RU Carriers Power Count  ${RMOD_SN}  ${REMOTE_HOST}

    ${off_carriers_status}  Run Keyword And Return Status
    ...  Should Be Equal As Integers  ${REF_ALL_CARRIERS_COUNT}  ${2920_off_carr}

    Run Keyword If  '${off_carriers_status}'=='True'
    ...  Logging With Timestamp
    ...  message=All carriers are OFF, RU is in safe-mode !
    ...  ELSE
    ...  Run Keyword And Continue On Failure  Fail  Not all carriers are OFF when FaultID 2920 !

    Set Voltage On RU  ${NOMINAL_VOLT}
    Logging With Timestamp
    ...  message=Waiting for clear of FaultID 2920!
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Inactive  faultId=2920  timeout=320  connection=${node}
    admin.Add Allowed Alarm  faultId=2920  connection=${node}
    Run Keyword If  '${alarm_status}'=='True'
    ...  Logging With Timestamp
    ...  message=FaultID 2920 CLEARED
    ...  ELSE  Fail  Fault 2920 NOT cleared after filtering time (300s) !

    ${cells_status}  Run Keyword And Return Status  Check If All Cells Are onAir  timeout=300  alias=${node}
    Run Keyword If  '${cells_status}'=='True'
    ...  Logging With Timestamp
    ...  message=All cells are onAir
    ...  ELSE
    ...  Fail  Cells are not onAir after exit RU from safe-mode !

    Sleep  60s

    ${2920_all_carr}  ${2920_off_carr}  ${2920_wo_carr}  Get RU Carriers Power Count  ${RMOD_SN}  ${REMOTE_HOST}

    ${carriers_status}  Run Keyword And Return Status
    ...  Should Be Equal As Integers  ${REF_WORKING_CARRIERS_COUNT}  ${2920_wo_carr}

    Run Keyword If  '${carriers_status}'=='True'
    ...  Logging With Timestamp
    ...  message=All carriers are RECOVERED
    ...  ELSE
    ...  Fail  NOT all carriers are recovered after safe-mode exit ! Set Test Fail !

    ${1340_cleared}  Run Keyword And Return Status
    ...    radio.Assert Inactive Fault In Fault History Log File
    ...    ru_serial_number=${RMOD_SN}
    ...    fault_id=1340
    ...    severity=critical
    ...    remote_host=${REMOTE_HOST}

    Run Keyword If  ${1340_cleared}
    ...  Logging With Timestamp
    ...  message=Found --> Inactive critical EFaultId_DCInputVoltageTooLow (1340) in fault_history_log.txt
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Fault EFaultId_DCInputVoltageTooLow (1340) not found, please check fault_history_log.txt!


step3: Set Too High Voltage On RU
    Logging With Timestamp
    ...  message=step3: Set Too High Voltage On RU
    ...  style=STEP
    ...  frame=${TRUE}

    Set Voltage On RU  ${TOO_HIGH_VOLT}
    Logging With Timestamp
    ...  message=Waiting for RAISE of FaultID 2919!
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=2919  timeout=60  connection=${node}
    admin.Add Allowed Alarm  faultId=2919  connection=${node}
    Run Keyword If  '${alarm_status}'=='True'
    ...  Logging With Timestamp
    ...  message=FaultID 2919 RAISED !
    ...  ELSE  Run Keywords
    ...  Logging With Timestamp
    ...  message=FaultID 2919 NOT raised ! Voltage restoring to ${NOMINAL_VOLT}V
    ...  AND  Set Voltage On RU  ${NOMINAL_VOLT}
    ...  AND  Fail  FaultID 2919 NOT raised !

    ${1341_active}  Run Keyword And Return Status
    ...    radio.Assert Active Fault In Fault History Log File
    ...    ru_serial_number=${RMOD_SN}
    ...    fault_id=1341
    ...    severity=critical
    ...    remote_host=${REMOTE_HOST}
    admin.Add Allowed Alarm  faultId=1341  connection=${node}
    Run Keyword If  ${1341_active}
    ...  Logging With Timestamp
    ...  message=Found --> Active critical EFaultId_DCInputVoltageTooHigh (1341) in fault_history_log.txt
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Fault EFaultId_DCInputVoltageTooHigh (1341) not found, please check fault_history_log.txt!

    ${2919_all_carr}  ${2919_off_carr}  ${2919_wo_carr}  Get RU Carriers Power Count  ${RMOD_SN}  ${REMOTE_HOST}

    ${off_carriers_status}  Run Keyword And Return Status
    ...  Should Be Equal As Integers  ${REF_ALL_CARRIERS_COUNT}  ${2919_off_carr}

    Run Keyword If  '${off_carriers_status}'=='True'
    ...  Logging With Timestamp
    ...  message=All carriers are OFF, RU is in safe-mode
    ...  ELSE
    ...  Run Keyword And Continue On Failure  Fail  Not all carriers are OFF when FaultID 2919 !

    Set Voltage On RU  ${NOMINAL_VOLT}
    Logging With Timestamp
    ...  message=Waiting for CLEAR of FaultID 2919!
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Inactive  faultId=2919  timeout=320  connection=${node}
    Run Keyword If  '${alarm_status}'=='True'
    ...  Logging With Timestamp
    ...  message=FaultID 2919 CLEARED
    ...  ELSE  Fail  FaultID 2919 NOT cleared after filtering time (300s) !

    ${cells_status}  Run Keyword And Return Status  Check If All Cells Are onAir  timeout=300  alias=${node}
    Run Keyword If  '${cells_status}'=='True'
    ...  Logging With Timestamp
    ...  message=All cells are onAir
    ...  ELSE
    ...  Fail  Cells are not onAir after exit RU from safe-mode !

    Sleep  60s

    ${2919_all_carr}  ${2919_off_carr}  ${2919_wo_carr}  Get RU Carriers Power Count  ${RMOD_SN}  ${REMOTE_HOST}
    ${carriers_status}  Run Keyword And Return Status
    ...  Should Be Equal As Integers  ${REF_WORKING_CARRIERS_COUNT}  ${2919_wo_carr}

    Run Keyword If  '${carriers_status}'=='True'
    ...  Logging With Timestamp
    ...  message=All carriers are RECOVERED !
    ...  ELSE
    ...  Fail  NOT all carriers are recovered after safe-mode exit ! Set Test Fail !

    ${1341_cleared}  Run Keyword And Return Status
    ...    radio.Assert Inactive Fault In Fault History Log File
    ...    ru_serial_number=${RMOD_SN}
    ...    fault_id=1341
    ...    severity=critical
    ...    remote_host=${REMOTE_HOST}

    Run Keyword If  ${1341_cleared}
    ...  Logging With Timestamp
    ...  message=Found --> Inactive critical EFaultId_DCInputVoltageTooHigh (1341) in fault_history_log.txt
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Fault EFaultId_DCInputVoltageTooHigh (1341) not found, please check fault_history_log.txt!


step4: Set Unstable Voltage On RU
    Logging With Timestamp
    ...  message=step4: Set Unstable Voltage On RU
    ...  style=STEP
    ...  frame=${TRUE}

    Set Voltage On RU  ${TOO_HIGH_VOLT}
    Logging With Timestamp
    ...  message=Waiting for RAISE of FaultID 4680 !
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=4680  timeout=60  connection=${node}
    admin.Add Allowed Alarm  faultId=4680  connection=${node}
    Run Keyword If  '${alarm_status}'=='True'
    ...  Logging With Timestamp
    ...  message=FaultID 4680 RAISED !
    ...  ELSE  Run Keywords
    ...  Logging With Timestamp
    ...  message=FaultID 4680 NOT raised ! Voltage restoring to ${NOMINAL_VOLT}V !
    ...  AND  Set Voltage On RU  ${NOMINAL_VOLT}
    ...  AND  Fail  FaultID 4680 NOT raised !

    ${1396_active}  Run Keyword And Return Status
    ...    radio.Assert Active Fault In Fault History Log File
    ...    ru_serial_number=${RMOD_SN}
    ...    fault_id=1396
    ...    severity=critical
    ...    remote_host=${REMOTE_HOST}
    admin.Add Allowed Alarm  faultId=1396  connection=${node}
    Run Keyword If  ${1396_active}
    ...  Logging With Timestamp
    ...  message=Found --> Active critical EFaultId_InputVoltageUnstable (1396) in fault_history_log.txt
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Fault EFaultId_InputVoltageUnstable (1396) not found, please check fault_history_log.txt!

    ${4680_all_carr}  ${4680_off_carr}  ${4680_wo_carr}  Get RU Carriers Power Count  ${RMOD_SN}  ${REMOTE_HOST}

    ${off_carriers_status}  Run Keyword And Return Status
    ...  Should Be Equal As Integers  ${REF_ALL_CARRIERS_COUNT}  ${4680_off_carr}

    Run Keyword If  '${off_carriers_status}'=='True'
    ...  Logging With Timestamp
    ...  message=All carriers are OFF, RU is in safe-mode !
    ...  ELSE
    ...  Run Keyword And Continue On Failure  Fail  Not all carriers are OFF when FaultID 2919 !

    Set Voltage On RU  ${NOMINAL_VOLT}
    Logging With Timestamp
    ...  message=Recommissioning alVoltUnstableThreshold to CLEAR FaultID 4680, please wait!

    admin.Perform Parameter Recommissioning   ${object_thresholds}  alVoltUnstableThreshold
    ...  update  ${UNSTABLE_COUNTER+2}  skip_parameter_relation_errors=True  connection=${node}
    Logging With Timestamp
    ...  message=Waiting for CLEAR of FaultID 4680!
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Inactive  faultId=4680  timeout=320  connection=${node}
    Run Keyword If  '${alarm_status}'=='True'
    ...  Logging With Timestamp
    ...  message=FaultID 4680 CLEARED !
    ...  ELSE  Fail  FaultID 4680 NOT cleared after recommissioning !

    ${cells_status}  Run Keyword And Return Status  Check If All Cells Are onAir  timeout=300  alias=${node}
    Run Keyword If  '${cells_status}'=='True'
    ...  Logging With Timestamp
    ...  message=All cells are onAir !
    ...  ELSE
    ...  Fail  Cells are not onAir after exit RU from safe-mode !

    Sleep  60s

    ${4680_all_carr}  ${4680_off_carr}  ${4680_wo_carr}  Get RU Carriers Power Count  ${RMOD_SN}  ${REMOTE_HOST}

    ${carriers_status}  Run Keyword And Return Status
    ...  Should Be Equal As Integers  ${REF_WORKING_CARRIERS_COUNT}  ${4680_wo_carr}

    Run Keyword If  '${carriers_status}'=='True'
    ...  Logging With Timestamp
    ...  message=All carriers are RECOVERED !
    ...  ELSE
    ...  Fail  NOT all carriers are recovered after safe-mode exit ! Set Test Fail !

    ${1396_cleared}  Run Keyword And Return Status
    ...    radio.Assert Inactive Fault In Fault History Log File
    ...    ru_serial_number=${RMOD_SN}
    ...    fault_id=1396
    ...    severity=critical
    ...    remote_host=${REMOTE_HOST}

    Run Keyword If  ${1396_cleared}
    ...  Logging With Timestamp
    ...  message=Found --> Inactive critical EFaultId_InputVoltageUnstable (1396) in fault_history_log.txt !
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Fault EFaultId_InputVoltageUnstable (1396) not found, please check fault_history_log.txt!

Get RU Carriers Power Count
    [Arguments]  ${rmod_sn}  ${remote_host}
    [Documentation]
    ...  KW gets carriers count
    ...  KW returns count for:
    ...  All carriers count
    ...  Off carriers count
    ...  Working carriers count
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com
    ...  +--------------+------+--------------------------------------------------+
    ...  | Parameter    | Man. | Description                                      |
    ...  +==============+======+==================================================+
    ...  | rmod_sn      | Yes  | radio serial number                              |
    ...  +--------------+------+--------------------------------------------------+
    ...  | remote_host  | Yes  | VM IP with connected BTS that radio belongs to   |
    ...  +--------------+------+--------------------------------------------------+

    ${ref_carriers_dict}    radio.Get Carriers Power
    ...    ru_serial_number=${rmod_sn}
    ...    direction=TX
    ...    return_antennas=False
    ...    remote_host=${remote_host}

    ${power_values}  Get Dictionary Values  ${ref_carriers_dict}

    FOR  ${carrier}  ${power}  IN ZIP  ${ref_carriers_dict.keys()}  ${ref_carriers_dict.values()}
        Logging With Timestamp
        ...  message=${carrier} -> ${power}
    END

    ${all_carr_count}  Get Length  ${power_values}
    ${off_carr_count}  Get Match Count  ${power_values}  OFF
    ${WO_carr_count}  Evaluate  ${all_carr_count}-${off_carr_count}

    [Return]  ${all_carr_count}  ${off_carr_count}  ${WO_carr_count}

Set Voltage On RU
    [Arguments]  ${voltage}
    [Documentation]
    ...  KW sets required voltage on RU
    ...  Argument Voltage is passed as decimal
    ...  SSH connection to RU must be opened before.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com
    ...
    ...  +--------------+------+--------------------------------------------------+
    ...  | Parameter    | Man. | Description                                      |
    ...  +==============+======+==================================================+
    ...  | voltage      | Yes  | voltage value set in TC variables                |
    ...  +--------------+------+--------------------------------------------------+

    ${ru_hw_release_code}  Get RU HW Release Code  ${RMOD_SN}

    Logging With Timestamp
    ...  message=Opening connection to RU with SN ${RMOD_SN}!
    Open Connection To Radio Module  ${RMOD_SN}  ${REMOTE_HOST}

    Logging With Timestamp
    ...  message=Setting --> ${voltage} Volt <-- on RU ${ru_hw_release_code} with SN: ${RMOD_SN}
    ${hex_voltage}  Evaluate  hex(${voltage}000)
    Run Keyword If  ${ru_hw_release_code}<5.1
    ...  radio.Send Command  rad -pw 0x1E3 ${hex_voltage}    delay=1
    ...  ELSE
    ...  radio.Send Command  rad -mw 0x110032 ${hex_voltage}    delay=1
    ${ru_output}  Run Keyword And Continue On Failure  radio.Read Until Regexp  succesfully
    Log to console  ${ru_output}${\n}

    [Teardown]  radio.Close SSH Connection

Get RU HW Release Code
    [Arguments]  ${ru_sn}
    [Documentation]
    ...  KW returns HWReleaseCode for RU unit.
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com
    ...
    ...  +--------------+------+--------------------------------------------------+
    ...  | Parameter    | Man. | Description                                      |
    ...  +==============+======+==================================================+
    ...  | ru_sn        | Yes  | serial number of radio unit under test           |
    ...  +--------------+------+--------------------------------------------------+

    ${hw_release}=  IF  '${CFG['RF_INFO']['${ru_sn}']['scf_release_code']}'=='RRH-ORAN'
    ...  radio.Get Radio Module Hardware Family  ru_name=${CFG['RF_INFO']['${ru_sn}']['scf_variant']}
    ...  ELSE
    ...  Evaluate  re.search(r'\\d+\\.\\d+\|d+', '${CFG['RF_INFO']['${ru_sn}']['scf_release_code']}').group(0)  re

    [Return]  ${hw_release}
