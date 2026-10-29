*** Settings ***
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/common.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/alarms.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/ald.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/power_saving.robot

Documentation
...  TEST NAME:     ALD.07_ALD_Manual_commissioning_with_Nokia_MHA_Passdev_as_RX_Gain
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to check commissioning of new passive additional RX gain device.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  06.03.2018 - https://jira3.int.net.nokia.com/browse/TAT-9320 - test draft creation
...  21.06.2018 - TAT-10492
...  27.09.2018 - TAT-12094
...  27.09.2018 - TAT-12094  - remove parameter linkModeSynchronization from delta
...  12.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-14560
...  22.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15418
...  14.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-16528
...  03.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-15283
...  03.08.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21470
...  26.08.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21781
...  06.12.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-36 - Switch to hran_frame_sbts_siso resource
...  16.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-73 - change max gain to 12
...  19.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-147 - Adaptation to CNI-82119 and migration from hran_ta to robotlte repository
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***


*** Keywords ***
ALD.07_ALD_Manual_commissioning_with_Nokia_MHA_Passdev_as_RX_Gain

	ALD.07_ALD_Manual_commissioning_with_Nokia_MHA_Passdev_as_RX_Gain.Test_Step.0 Check If ALDs Are In Configuration
    ALD.07_ALD_Manual_commissioning_with_Nokia_MHA_Passdev_as_RX_Gain.Test_Step.1 Select Passive Device Parameters
    ALD.07_ALD_Manual_commissioning_with_Nokia_MHA_Passdev_as_RX_Gain.Test_Step.2 Create And Activate Delta With Passdev
    ALD.07_ALD_Manual_commissioning_with_Nokia_MHA_Passdev_as_RX_Gain.Test_Step.3 FEG calculation
    ALD.07_ALD_Manual_commissioning_with_Nokia_MHA_Passdev_as_RX_Gain.Test_Step.4 Create And Activate Delta Removing Passdev
    ALD.07_ALD_Manual_commissioning_with_Nokia_MHA_Passdev_as_RX_Gain.Test_Step.5 FEG calculation

ALD.07_ALD_Manual_commissioning_with_Nokia_MHA_Passdev_as_RX_Gain.Test_Step.0 Check If ALDs Are In Configuration
    [Documentation]  Test step which checking if ALDs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    Set Test Variable  ${COMMISSIONING_PATH}  /home/ute/testline_configuration/${TESTLINE_NAME}/node1/SCF_01_${RELEASE}.xml
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    Set Test Variable  ${num_of_MHAs}
    Set Test Variable  ${ALD_R_MHAs}
    Log  You have ${num_of_MHAs} MHAs in configuration  console=${True}

ALD.07_ALD_Manual_commissioning_with_Nokia_MHA_Passdev_as_RX_Gain.Test_Step.1 Select Passive Device Parameters
    [Documentation]  This step serach parameters neeeded to add new passive device.
    Log to console    \n========================================
    Log  Step: 1 Select Passive Device Parameters  console=${True}
    Log to console    ========================================
    ${ANTL_A_with_channel}=  Get ANTLs Without MHA With Channel
    ${RMOD_ID_A}  ${ANTL_ID_A}=  Select Random ANTL Without MHA With Channel  ${ANTL_A_with_channel}
    Log  Chosen RMOD ID: ${RMOD_ID_A} ANTL ID: ${ANTL_ID_A}  console=${True}
    Log   ------ Generating Passiv Device Data ------  console=${True}
    ${RX_gain}=  Generate Random Number With Range  start_range=${1}  end_range=${120}
    ${RX_gain}=  Convert To Number  ${RX_gain}
    ${RX_gain_devided}=  Evaluate  ${RX_gain}/10
    ${description}=  Generate Random String  45  [LETTERS][NUMBERS][]~`!%^*()-=+\|;:',.<>/
    ${type}=  Generate Random String  45  [LETTERS][NUMBERS][]~`!%^*()-=+\|;:',.<>/
    ${unit_position}=  Generate Random String  45  [LETTERS][NUMBERS][]~`!%^*()-=+\|;:',.<>/
    ${vendor}=  Generate Random String  30  [LETTERS][NUMBERS][]~`!%^*()-=+\|;:',.<>/
    ${manufacturer_data}=  Generate Random String  45  [LETTERS][NUMBERS][]~`!%^*()-=+\|;:',.<>/
    ${familiy_type}=  Generate Random String  45  [LETTERS][NUMBERS][]~`!%^*()-=+\|;:',.<>/
    ${type_number}=  Generate Random String  45  [LETTERS][NUMBERS][]~`!%^*()-=+\|;:',.<>/
    ${version}=  Generate Random String  30  [LETTERS][NUMBERS][]~`!%^*()-=+\|;:',.<>/
    ${serial_number}=  Generate Random String  45  [LETTERS][NUMBERS][]~`!%^*()-=+\|;:',.<>/
    ${free_passdev_id}=  Get First Unused Passdev Number
    ${free_loglink_id}=  Get First Unused Loglink
    Log   ---- Randomly selected RX gain: ${RX_gain_devided} dB  console=${True}
    Log   ---------------------- TX gain: 0 dB  console=${True}
    Log   --------------- TX Attenuation: 0 dB  console=${True}
    Log   ------------------ Description: ${description}  console=${True}
    Log   ------------------------- Type: ${type}  console=${True}
    Log   ---------------- Unit Position: ${unit_position}  console=${True}
    Log   ----------------------- Vendor: ${vendor}  console=${True}
    Log   ------------ Manufacturer data: ${manufacturer_data}  console=${True}
    Log   ------------------ Family Type: ${familiy_type}  console=${True}
    Log   ------------------ Type Number: ${type_number}  console=${True}
    Log   ---------------------- Version: ${version}  console=${True}
    Log   ---------------- Serial Number: ${serial_number}   console=${True}
    Set Test Variable  ${RX_gain}
    Set Test Variable  ${description}
    Set Test Variable  ${type}
    Set Test Variable  ${unit_position}
    Set Test Variable  ${vendor}
    Set Test Variable  ${manufacturer_data}
    Set Test Variable  ${familiy_type}
    Set Test Variable  ${type_number}
    Set Test Variable  ${version}
    Set Test Variable  ${serial_number}
    Set Test Variable  ${free_passdev_id}
    Set Test Variable  ${free_loglink_id}
    Set Test Variable  ${RMOD_ID_A}
    Set Test Variable  ${ANTL_ID_A}

ALD.07_ALD_Manual_commissioning_with_Nokia_MHA_Passdev_as_RX_Gain.Test_Step.2 Create And Activate Delta With Passdev
    [Documentation]
    ...  This test step:
    ...  Created delta commissionig with new passive device
    ...  Saved delta comissionig with new passive device
    ...  Applied this delta commissionig and check if reset was not performed
    Log to console    \n========================================
    Log  Step: 2 Create And Activate Delta With Passdev  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    Log  Reset counter before applying delta: ${pre_action_reset_number}  console=${True}
    ${delta_passdev}=    Set Variable    passdev
    ${PASSDEV_DN}=  Set Variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/PASSDEV-${free_passdev_id}
    ${LOGLINK_DN}=  Set Variable  MRBTS-${MRBTS_ID}/EQM-1/HWTOP-1/LOGLINK-${free_loglink_id}
    ${ANTL_DN}=  Set Variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_ID_A}/ANTL-${ANTL_ID_A}
    admin.create delta  ${delta_passdev}
    admin.append managed object to delta  ${PASSDEV_DN}  create  ${delta_passdev}
    admin.append parameter update to delta  ${PASSDEV_DN}  deviceDescription  ${description}  ${delta_passdev}
    admin.append parameter update to delta  ${PASSDEV_DN}  inventoryUnitType  ${type}  ${delta_passdev}
    admin.append parameter update to delta  ${PASSDEV_DN}  additionalRxGain  ${RX_gain}  ${delta_passdev}
    admin.append parameter update to delta  ${PASSDEV_DN}  additionalTxAttenuation  0  ${delta_passdev}
    admin.append parameter update to delta  ${PASSDEV_DN}  additionalTxGain  0  ${delta_passdev}
    admin.append parameter update to delta  ${PASSDEV_DN}  unitPosition  ${unit_position}  ${delta_passdev}
    admin.append parameter update to delta  ${PASSDEV_DN}  vendorName  ${vendor}  ${delta_passdev}
    admin.append parameter update to delta  ${PASSDEV_DN}  manufacturerData  ${manufacturer_data}  ${delta_passdev}
    admin.append parameter update to delta  ${PASSDEV_DN}  vendorUnitFamilyType  ${familiy_type}  ${delta_passdev}
    admin.append parameter update to delta  ${PASSDEV_DN}  vendorUnitTypeNumber  ${type_number}  ${delta_passdev}
    admin.append parameter update to delta  ${PASSDEV_DN}  versionNumber  ${version}  ${delta_passdev}
    admin.append parameter update to delta  ${PASSDEV_DN}  serialNumber  ${serial_number}  ${delta_passdev}
    admin.append managed object to delta  ${LOGLINK_DN}  create  ${delta_passdev}
    admin.append parameter update to delta  ${LOGLINK_DN}  firstEndpointDN  ${PASSDEV_DN}  ${delta_passdev}
    admin.append parameter update to delta  ${LOGLINK_DN}  linkModeConfiguration  false  ${delta_passdev}
    admin.append parameter update to delta  ${LOGLINK_DN}  linkModeDC  false  ${delta_passdev}
    admin.append parameter update to delta  ${LOGLINK_DN}  linkModeData  true  ${delta_passdev}
    admin.append parameter update to delta  ${LOGLINK_DN}  secondEndpointDN  ${ANTL_DN}  ${delta_passdev}
    admin.get delta  ${delta_passdev}
    admin.save delta  ${RESULTS}/delta_passdev.json  ${delta_passdev}
    admin.perform delta recommissioning  ${RESULTS}/delta_passdev.json  ${SKIP_PARAMETER_RELATION_ERRORS}  ${SHOULD_ACTIVATE}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    Log  Reset counter after applying delta: ${post_action_reset_number}  console=${True}
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    Run Keyword If  ${counter_diff}!=${0}
#    ...  Fail  msg=Detected unexpected BTS reset

ALD.07_ALD_Manual_commissioning_with_Nokia_MHA_Passdev_as_RX_Gain.Test_Step.${n} FEG calculation
    [Documentation]  This keyword is checking if front end gain is calculated properly.
    Log to console    \n========================================
    Log  Step: ${n} FEG calculation  console=${True}
    Log to console    ========================================
    Check FEG On Antl Without MHA
    Check FEG On Antl With MHA

ALD.07_ALD_Manual_commissioning_with_Nokia_MHA_Passdev_as_RX_Gain.Test_Step.4 Create And Activate Delta Removing Passdev
    [Documentation]
    ...  This test step:
    ...  Created delta commissionig which delte passive device
    ...  Saved delta comissionig which delte passive device
    ...  Applied this delta commissionig and check if reset was not performed
    Log to console    \n========================================
    Log  Step: 4 Create And Activate Delta Removing Passdev  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    Log  Reset counter before applying delta: ${pre_action_reset_number}  console=${True}
    ${delta_passdev_del}=    Set Variable    passdev_del
    admin.create delta  ${delta_passdev_del}
    admin.append managed object to delta  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/PASSDEV-${free_passdev_id}  delete  ${delta_passdev_del}
    admin.append managed object to delta  MRBTS-${MRBTS_ID}/EQM-1/HWTOP-1/LOGLINK-${free_loglink_id}  delete  ${delta_passdev_del}
    admin.get delta  ${delta_passdev_del}
    ${json_path}=  Set Variable  ${RESULTS}/delta_passdev_del.json
    admin.save delta  ${json_path}  ${delta_passdev_del}
    admin.perform delta recommissioning  ${json_path}  ${SKIP_PARAMETER_RELATION_ERRORS}  ${SHOULD_ACTIVATE}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    Log  Reset counter after applying delta: ${post_action_reset_number}  console=${True}
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    Run Keyword If  ${counter_diff}!=${0}
#    ...  Fail  msg=Detected unexpected BTS reset
    Check If Unexpected Alarms Are Raised  ${skip_fault}

ALD.07_ALD_Manual_commissioning_with_Nokia_MHA_Passdev_as_RX_Gain.Test Specific Teardown
    [Documentation]  Test teardown which restores original configuration settings.
    Log  \nRestoring original configuration settings  console=${True}
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    admin.perform commissioning  ${MRBTS_ID}  ${COMMISSIONING_PATH}  ${SKIP_PARAMETER_RELATION_ERRORS}  ${SHOULD_ACTIVATE}  timeout=600
	Check SMODs State  ${SMOD_expected_states}
	Check RMODs State  ${RMOD_expected_states}
	Check ALDs State  ${ALD_expected_states}
    common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    admin.teardown admin  alias=${ute_admin_alias}

ALD.07_ALD_Manual_commissioning_with_Nokia_MHA_Passdev_as_RX_Gain.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keyword  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
    Run Keyword If Test Failed  ALD.07_ALD_Manual_commissioning_with_Nokia_MHA_Passdev_as_RX_Gain.Test Specific Teardown
