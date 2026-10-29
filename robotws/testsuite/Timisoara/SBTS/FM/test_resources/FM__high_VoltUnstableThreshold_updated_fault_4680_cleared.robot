*** Settings ***
Documentation
    ...  Test case will verify clearing of the fault 4680(triggered by repeated fault 2919)
    ...  when SBTS RMOD scf parameter VoltUnstableThreshold is updated.
    ...  Test case will power reset the BBMOD where the sync CABLINK from RF is connected.
    ...  After performing the reset, test checks that only the mapped cells on that BBMOD are affected and services reach OnAir state after.
    ...  In the first step test will change alVoltUnstableThreshold to 2 and alVoltHighThreshold to 58V.
    ...  To be able to change alVoltLowThreshold the value given should be 107 % due to correspondence in NIDD.(see req. OM_GEN_SFS_MIG_RULES_338)
    ...  After that the voltage on the RMOD will be increased and fault 2919 should be seen.
    ...  After alarm is seen voltage will be decreased below threshold and fault should be cleared in 5 minutes.
    ...  Voltage is then increased again in a time interval of alVoltUnstableThreshold*10 min and fault 4680 should be seen.
    ...  alVoltUnstableThreshold  is updated to 3 and fault 4680 should be cleared.
    ...  After test default values would be set: RMOD voltage 48V, alVoltUnstableThreshold 5 and alVoltHighThreshold 57V.
    ...  To be able to change alVoltLowThreshold the value given should be 100 % due to correspondence in NIDD.(see req. OM_GEN_SFS_MIG_RULES_338)

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${PSU_IP}  ${EMPTY}  # Mandatory IP of PSU unit.
${RMOD_SN}  ${EMPTY}  # Mandatory serial number of RMOD connected to PSU.
${DEFAULT_VOLTAGE}  48  # Default RMOD voltage.
${ALARM_TIMEOUT}  360  # Should be at least 5min for alarm to clear.
${RECOVERY_TIMEOUT}  300  # Time for cells to be online.
${NETACT_TIMEOUT}  60  # Time for alarm to be seen and cleared from Netact.


*** Keywords ***
TC__FM__high_VoltUnstableThreshold_updated_fault_4680_cleared
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-22262
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 26.01.2022 - https://jira3.int.net.nokia.com/browse/TAT-22262 - Initial TAT creation
    ...  - 28.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25066 - Replace ute_pdu with taf.pdu
    ...  - 07.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-23840 - Test improvement
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 19.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28415 - Enhancement modify migration values for parameter
    ...  - 31.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28670 - Enhancement for EDA
    ...  - 05.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28711 - Update alarm check in WebEM and Netact
    ...  - 24.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30086 - Enhancement for supplementary alarm information check
    ...  *******************

    Set Tags  CA-FM  OWNER-virgil.blot@nokia.com  MAINTAINER-bogdan.boldurean@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS22  FEATURE-CB007086

    Step 0: Get RMOD And Change Parameters
    Step 1: Set Voltage To 58
    Step 2: Check Alarm Active
    Step 3: Set Voltage To 57
    Step 4: Check Alarm Inactive
    Step 5: Set Voltage To 58
    Step 6: Check Alarm Active


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
        IF  ${rmod_obj}  BREAK
    END
    Set Test Variable  ${RMOD_CONFIG_NAME}  ${rmod_obj}[id][configuration]
    Set Test Variable  ${RMOD_R}  ${rmod_obj}[id][internal]
    ${RMOD_dist_name}  Replace String Using Regexp  ${RMOD_R}  .+/MRBTS_R-\\d+  MRBTS-${BTS_ID}
    Set Test Variable  ${RMOD_DIST_NAME}
    ${bts_name}  Get Bts Name
    Set Test Variable  ${BTS_NAME}
    Log  Checking baseband power reset.  console=true
    ${rmod_r_dn}  Get Module Dist Name By Serial Number And Class  ${RMOD_SN}  RMOD
    ${rmod_cells}  Get Cell Mapping By Module Id  ${rmod_r_dn}
    Log  Get cable that is primary link. Checking linkModeSynchronization.  console=true
    ${cables}  Get Parameters For All  CABLINK
    FOR  ${cable}  IN  @{cables}
         ${rmod_status}  Run Keyword And Return Status  Should Be Equal  ${cable}[secondEndpointDN]  ${rmod_r_dn}
         ${link_mode_status}  IF  ${rmod_status}  Run Keyword And Return Status  Should Be Equal As Strings  ${cable}[linkModeSynchronization]  True
         ${bbmod_r_dn}  Set Variable If  ${link_mode_status}  ${cable}[firstEndpointDN]
         IF  ${link_mode_status}  Log  Cablink that has synchronization mapped : ${cable}[id]  console=true
         IF  ${link_mode_status}  BREAK
    END
    Set Test Variable  ${RMOD_CELLS}
    Log  BBMOD dist_name: ${bbmod_r_dn}  console=true
    ${bbmod_cells}  Get Cell Mapping By Module Id  ${bbmod_r_dn}
    ${affected_cells}  Combine Lists   ${rmod_cells}  ${bbmod_cells}
    Remove Duplicates  ${affected_cells}
    Log  Affected cells mapped on BMMOD and RMOD : ${affected_cells}  console=true
    Log  Performing baseband power reset.  console=true
    coam.Reset Unit  dist_name=${bbmod_r_dn}  reset_type=PowerReset  timeout=300
    Log  Checking affected resources.  console=true
    Wait Until Keyword Succeeds  300s  30  Check Parameters Status For Cells  ${affected_cells}  operationalState=${DISABLED}
    Log  Waiting for resources to recover.  console=true
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  30  Check modules and cells
    ${voltage_to_value_mapping}  Create Dictionary  36=-120  36.5=-118  37=-116  37.5=-114  38=-112  38.5=-109  39=-107  39.5=-105  40=-103  40.5=-100
    ...  57=100  57.5=104  58=107  58.5=110  59=114  59.5=117  60=120
    Set Test Variable  ${VOLTAGE_TO_VALUE_MAPPING}
    Log  Parameters will be changed for ${RMOD_CONFIG_NAME}  console=true
    Log  Setting alVoltUnstableThreshold to 2.  console=true
    coam.Perform Parameter Recommissioning  ${RMOD_CONFIG_NAME}  alVoltUnstableThreshold  update  2
    Log  Setting alVoltHighThreshold to 58.  console=true
    coam.Perform Parameter Recommissioning  ${RMOD_CONFIG_NAME}  alVoltHighThreshold  update  ${VOLTAGE_TO_VALUE_MAPPING}[58]


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
    ${start_time_fid_2919}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME_FID_2919}
    ${supplementary_alarm_info_regexp}  Catenate  SEPARATOR=${SPACE}  Radio's input voltage is higher or equal to configured threshold
    ...  58V \\(107%\\)
    ${fault_2919_params}  Get String With Alarm Parameters  ${FAULT_2919}
    ${fault_2919_with_suppl_info}  Catenate  ${fault_2919_params},  notifier="[${BTS_NAME}] ${RMOD_DIST_NAME}",
    ...  supplAlarmInfo=regex"${supplementary_alarm_info_regexp}"
    Assert Alarm Active  parameters=${fault_2919_with_suppl_info}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_2919} is active in WebEM.  console=true
    Log  Checking affected resources.  console=true
    Wait Until Keyword Succeeds  300s  30  Check Parameters Status For Cells  ${RMOD_CELLS}  operationalState=${DISABLED}
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_2919}  additional_fault_id=${FAULT_2919}[fault_id]
    ...  suppl_info=${supplementary_alarm_info_regexp}  object_id=${RMOD_DIST_NAME}
    Log  Fault ${FAULT_2919} is active in Netact.  console=true


Step 4: Check Alarm Inactive
    [Documentation]  Fault 2919 should be cleared in 5 min.

    Log  \nStep 4: Check alarm inactive.  console=true
    Log  Wait ${ALARM_TIMEOUT}s for fault 2919 to clear.  console=true
    ${fault_2919_params}  Get String With Alarm Parameters  ${FAULT_2919}
    Assert Alarm Inactive  parameters=${fault_2919_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_2919} is cleared in WebEM.  console=true
    Log  Waiting for cells to be on air.  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  30  Check All Cells
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_2919}  time_from=${START_TIME_FID_2919}
    ...  additional_fault_id=${FAULT_2919}[fault_id]
    Log  Fault &{FAULT_2919} is cleared in Netact.  console=true


Step 6: Check Alarm Active
    [Documentation]  For fault 4680 to be seen, voltage should be increased in a time period of alVoltUnstableThreshold*10 mins.

    Log  \nStep 6: Check alarm active.  console=true
    ${fault_2919_params}  Get String With Alarm Parameters  ${FAULT_2919}
    ${status}  Run Keyword And Return Status  Assert Alarm Inactive  parameters=${fault_2919_params}
    IF  ${status}
        Log  Fault ${FAULT_2919} cleared from WebEM.  console=true
    ELSE
        Set Test Restriction  Fault ${FAULT_2919} in not cleared after second voltage increase.
    END
    ${fault_4680_params}  Get String With Alarm Parameters  ${FAULT_4680}
    Assert Alarm Active  parameters=${fault_4680_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_4680} is active in WebEM.  console=true
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_4680}  additional_fault_id=${FAULT_4680}[fault_id]
    ...  object_id=${RMOD_DIST_NAME}
    Log  Fault ${FAULT_4680} is active in Netact.  console=true


Set Default Values
    Log  \nSet default values Voltage:${DEFAULT_VOLTAGE}V, alVoltUnstableThreshold:5 and alVoltHighThreshold:57V  console=true
    Set Voltage  ${INTERFACES['RMOD_${RMOD_SN}']['OUTLET']}  ${DEFAULT_VOLTAGE}  pdu_device=${PDU_DEVICE}
    Sleep  1  Sleep needed for voltage to change on PSU.
    ${volt}  Get Voltage  pdu_device=${PDU_DEVICE}
    Log  Voltage after change: ${volt}V.  console=true
    coam.Perform Parameter Recommissioning  ${RMOD_CONFIG_NAME}  alVoltUnstableThreshold  update  5
    coam.Perform Parameter Recommissioning  ${RMOD_CONFIG_NAME}  alVoltHighThreshold  update  ${VOLTAGE_TO_VALUE_MAPPING}[57]
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  30  Check All Cells


TC Setup
    Common Test Setup  tc_name=FM__high_VoltUnstableThreshold_fault_4680_cleared
    Setup NetAct
    ${pdu_device}  Setup Pdu  PSU  ${PSU_IP}
    Set Test Variable  ${PDU_DEVICE}


TC Teardown
    Set Default Values
    Run Keyword And Ignore Error  Teardown Pdu  pdu_device=${PDU_DEVICE}
    Teardown NetAct
    Common Test Teardown
