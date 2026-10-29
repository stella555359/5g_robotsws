*** Settings ***
Documentation
    ...  Test case will verify clearing of the fault 4680(triggered by repeated fault 2920)
    ...  when SBTS RMOD scf parameter VoltUnstableThreshold is updated.
    ...  In the first step test will change alVoltUnstableThreshold to 2 and alVoltLowThreshold to 39V.
    ...  To be able to change alVoltLowThreshold the value given should be -107 % due to correspondence in NIDD.(see req. OM_GEN_SFS_MIG_RULES_339)
    ...  After that the voltage on the RMOD will be decreased and fault 2920 should be seen.
    ...  After alarm is seen voltage will be increased above threshold and fault should be cleared in 5 minutes.
    ...  Voltage is then decreased again in a time interval of alVoltUnstableThreshold*10 min and fault 4680 should be seen.
    ...  After fault is seen voltage will increase again above threshold and RMOD resets, fault 4680 should be cleared.
    ...  After test default values would be set: RMOD voltage 48V, alVoltUnstableThreshold 5 and alVoltLowThreshold 40.5V.
    ...  To be able to change alVoltLowThreshold the value given should be -100 % due to correspondence in NIDD.(see req. OM_GEN_SFS_MIG_RULES_339)

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${PSU_IP}  ${EMPTY}  # Mandatory IP of PSU unit.
${RMOD_SN}  ${EMPTY}  # Mandatory serial number of RMOD connected to PSU.
${DEFAULT_VOLTAGE}  48  # Default RMOD voltage.
${ALARM_TIMEOUT}  360  # Should be at least 5min for alarm to clear.
${RECOVERY_TIMEOUT}  300  # Time for cells to be online.
${NETACT_TIMEOUT}  60  # Time for alarm to be seen and cleared from Netact.


*** Keywords ***
TC__FM__low_VoltUnstable_recovered_fault_4680_cleared
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-22263
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 27.01.2022 - https://jira3.int.net.nokia.com/browse/TAT-22263 - Initial TAT creation
    ...  - 28.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25066 - Replace ute_pdu with taf.pdu
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  - 19.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28415 - Enhancement modify migration values for parameter
    ...  - 05.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28711 - Update alarm check in WebEM and Netact
    ...  *******************

    Set Tags  CA-FM  OWNER-virgil.blot@nokia.com  MAINTAINER-bogdan.boldurean@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS22  FEATURE-CB007086

    Step 0: Get RMOD And Change Parameters
    Step 1: Set Voltage To 38
    Step 2: Check Alarm Active
    Step 3: Set Voltage To 40
    Step 4: Check Alarm Inactive
    Step 5: Set Voltage To 38
    Step 6: Check Alarm Active
    Step 7: Set Voltage To 48
    Step 8: Reset RMOD And Check Alarm Cleared


Step 0: Get RMOD And Change Parameters
    Log  \nStep 0: Get RMOD and change parameters.  console=true
    IF  '${PSU_IP}'=='${EMPTY}'
      Fail  IP for PSU was not provided.
    ELSE IF  '${RMOD_SN}'=='${EMPTY}'
      Fail  RMOD SN was not provided.
    END
    ${rmods}  Get Frm
    FOR  ${rmod}  IN  @{rmods}
        ${rmod_obj}  Set Variable If  '${rmod}[serialNumber]'=='${RMOD_SN}'  ${rmod}
        IF  ${rmod_obj}  Exit For Loop
    END
    Set Test Variable  ${RMOD_CONFIG_NAME}  ${rmod_obj}[id][configuration]
    Set Test Variable  ${RMOD_R}  ${rmod_obj}[id][internal]
    ${RMOD_dist_name}  Replace String Using Regexp  ${RMOD_R}  .+/MRBTS_R-\\d+  MRBTS-${BTS_ID}
    Set Test Variable  ${RMOD_DIST_NAME}
    ${bts_name}  Get Bts Name
    Set Test Variable  ${BTS_NAME}
    ${voltage_to_value_mapping}  Create Dictionary  36=-120  36.5=-118  37=-116  37.5=-114  38=-112  38.5=-109  39=-107  39.5=-105  40=-103  40.5=-100
    ...  57=100  57.5=104  58=107  58.5=110  59=114  59.5=117  60=120
    Set Test Variable  ${VOLTAGE_TO_VALUE_MAPPING}
    Log  Parameters will be changed for ${RMOD_CONFIG_NAME}  console=true
    Log  Setting alVoltUnstableThreshold to 2.  console=true
    coam.Perform Parameter Recommissioning  ${RMOD_CONFIG_NAME}  alVoltUnstableThreshold  update  2
    Log  Setting alVoltLowThreshold to 39V.  console=true
    coam.Perform Parameter Recommissioning  ${RMOD_CONFIG_NAME}  alVoltLowThreshold  update  ${VOLTAGE_TO_VALUE_MAPPING}[39]


Step ${id}: Set Voltage To ${voltage}
    Log  \nStep ${id}: Set Voltage to ${voltage}.  console=true
    ${volt}  Get Voltage  pdu_device=${PDU_DEVICE}
    Log  Voltage before change: ${volt}V.  console=true
    Set Voltage  ${INTERFACES['RMOD_${RMOD_SN}']['OUTLET']}  ${voltage}  pdu_device=${PDU_DEVICE}
    Sleep  1  Sleep needed for voltage to change on PSU.
    ${volt}  Get Voltage  pdu_device=${PDU_DEVICE}
    Log  Voltage after change: ${volt}V.  console=true


Step 2: Check Alarm Active
    Log  \nStep 2: Check alarm active.  console=true

    ${fault_2920_params}  Get String With Alarm Parameters  ${FAULT_2920}
    ${fault_2920_params}  Catenate  ${fault_2920_params},  notifier="[${BTS_NAME}] ${RMOD_DIST_NAME}"
    Assert Alarm Active  parameters=${fault_2920_params}
    Log  Fault ${FAULT_2920} is active in WebEM.  console=true

    ${start_time_fid_2920}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME_FID_2920}
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  10
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_2920}  additional_fault_id=${FAULT_2920}[fault_id]
    ...  suppl_info=Radio's input voltage is lower or equal to configured threshold
    ...  object_id=${RMOD_DIST_NAME}
    Log  Fault ${FAULT_2920} is active in Netact.  console=true


Step 4: Check Alarm Inactive
    [Documentation]  Fault 2920 should be cleared in 5 min.

    Log  \nStep 4: Check alarm inactive.  console=true
    Log  Wait ${ALARM_TIMEOUT}s for fault to clear.  console=true
    ${fault_2920_params}  Get String With Alarm Parameters  ${FAULT_2920}
    Assert Alarm Inactive  parameters=${fault_2920_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_2920} is cleared in WebEM.  console=true

    Log  Waiting for cells to be on air.  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  10
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_2920}  time_from=${START_TIME_FID_2920}
    ...  additional_fault_id=${FAULT_2920}[fault_id]
    Log  Fault ${FAULT_2920} cleared from Netact.  console=true


Step 6: Check Alarm Active
    [Documentation]  For fault 4680 to be seen, voltage should be increased in a time period of alVoltUnstableThreshold*10 mins.

    Log  \nStep 6: Check alarm active.  console=true
    ${fault_2920_params}  Get String With Alarm Parameters  ${FAULT_2920}
    ${status}  Run Keyword And Return Status
    ...  Assert Alarm Inactive  parameters=${fault_2920_params}
    IF  ${status}
      Log  Fault ${FAULT_2920} cleared from WebEM.  console=true
    ELSE
      Set Test Restriction  Fault ${FAULT_2920} in not cleared after second voltage increase.
    END
    ${fault_4680_params}  Get String With Alarm Parameters  ${FAULT_4680}
    ${fault_4680_params}  Catenate  ${fault_4680_params},  notifier="[${BTS_NAME}] ${RMOD_DIST_NAME}"
    Assert Alarm Active  parameters=${fault_4680_params}  timeout=2min
    Log  Fault ${FAULT_4680} is active in WebEM.  console=true

    ${start_time_fid_4680}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME_FID_4680}
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  10
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_4680}  additional_fault_id=${FAULT_4680}[fault_id]
    ...  object_id=${RMOD_DIST_NAME}
    Log  Fault ${FAULT_4680} is present in Netact.  console=true


Step 8: Reset RMOD And Check Alarm Cleared
    Log  \nStep 8: Reset RMOD and check alarm cleared.  console=true
    Log  Reset RMOD with distName ${RMOD_R}  console=true
    coam.Reset Unit  ${RMOD_R}  timeout=300
    Log  Wait for cells to be online.  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells

    ${fault_4680_params}  Get String With Alarm Parameters  ${FAULT_4680}
    Assert Alarm Inactive  parameters=${fault_4680_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_4680} is cleared in WebEM.  console=true

    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  10
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4680}  time_from=${START_TIME_FID_4680}
    ...  additional_fault_id=${FAULT_4680}[fault_id]
    Log  Fault ${FAULT_4680} is cleared in Netact.  console=true


Set Default Values
    Log  \nSet default values Voltage:${DEFAULT_VOLTAGE}V, alVoltUnstableThreshold:5 and alVoltLowThreshold:40.5V  console=true
    Set Voltage  ${INTERFACES['RMOD_${RMOD_SN}']['OUTLET']}  ${DEFAULT_VOLTAGE}  pdu_device=${PDU_DEVICE}
    Sleep  1  Sleep needed for voltage to change on PSU.
    ${volt}  Get Voltage  pdu_device=${PDU_DEVICE}
    Log  Voltage after change: ${volt}V.  console=true
    coam.Perform Parameter Recommissioning  ${RMOD_CONFIG_NAME}  alVoltUnstableThreshold  update  5
    coam.Perform Parameter Recommissioning  ${RMOD_CONFIG_NAME}  alVoltLowThreshold  update  ${VOLTAGE_TO_VALUE_MAPPING}[40.5]
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells


TC Setup
    Common Test Setup  tc_name=FM__low_VoltUnstable_recovered_fault_4680_cleared
    Setup NetAct
    ${pdu_device}  Setup Pdu  PSU  ${PSU_IP}
    Set Test Variable  ${PDU_DEVICE}


TC Teardown
    Set Default Values
    Run Keyword And Ignore Error
    ...  Teardown Pdu  pdu_device=${PDU_DEVICE}
    Teardown NetAct
    Common Test Teardown
