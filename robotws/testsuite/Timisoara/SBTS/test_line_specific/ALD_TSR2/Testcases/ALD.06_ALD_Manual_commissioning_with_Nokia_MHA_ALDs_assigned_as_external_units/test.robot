*** Settings ***
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/common.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/alarms.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/ald.robot
Resource    ../../../../../../Wroclaw/OAM/RAN_PZ_WRO3_SG01/resources/power_saving.robot

Documentation
...  TEST NAME:     ALD.06_ALD_Manual_commissioning_with_Nokia_MHA_ALDs_assigned_as_external_units
...  AUTHORS:       damian.sliwinski@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to check delta commissioning MHA as external device.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  10.04.2018 https://jira3.int.net.nokia.com/browse/TAT-9900 - test draft creation
...  08.05.2018 - Test creation
...  10.05.2018 - Changes aftre review
...  21.05.2018  - TAT-10492
...  12.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-14560
...  03.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-15283
...  30.07.2021 - https://jira3.int.net.nokia.com/browse/TAT-21678
...  06.12.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-36 - Switch to hran_frame_sbts_siso resource
...  22.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-161 - Adaptation to CNI-82119 and migration from hran_ta to robotlte repository
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***


*** Keywords ***
ALD.06_ALD_Manual_commissioning_with_Nokia_MHA_ALDs_assigned_as_external_units

	ALD.06_ALD_Manual_commissioning_with_Nokia_MHA_ALDs_assigned_as_external_units.Test_Step.0 Check If ALDs Are In Configuration
    ALD.06_ALD_Manual_commissioning_with_Nokia_MHA_ALDs_assigned_as_external_units.Test_Step.1 Select LNA and LOGLINK
    ALD.06_ALD_Manual_commissioning_with_Nokia_MHA_ALDs_assigned_as_external_units.Test_Step.2 Create and Activate Delta with External Unit
    ALD.06_ALD_Manual_commissioning_with_Nokia_MHA_ALDs_assigned_as_external_units.Test_Step.3 FEG calculation
    ALD.06_ALD_Manual_commissioning_with_Nokia_MHA_ALDs_assigned_as_external_units.Test_Step.4 Create and Activate Delta with Removing External Unit
    ALD.06_ALD_Manual_commissioning_with_Nokia_MHA_ALDs_assigned_as_external_units.Test_Step.5 FEG calculation
    ALD.06_ALD_Manual_commissioning_with_Nokia_MHA_ALDs_assigned_as_external_units.Test_Step.6 Check states and alarms on BTS

ALD.06_ALD_Manual_commissioning_with_Nokia_MHA_ALDs_assigned_as_external_units.Test_Step.0 Check If ALDs Are In Configuration
    [Documentation]  Test step which checking if ALDs are in configuration.
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    Set Test Variable  ${COMMISSIONING_PATH}  /home/ute/testline_configuration/${TESTLINE_NAME}/node1/SCF_01_${RELEASE}.xml
    ${ALD_R_RAEs}  ${ALD_R_MHAs}  ${ALD_R_RETs}
    ...  ${ALD_R_ALL}  ${num_of_RAEs}  ${num_of_MHAs}  ${num_of_RETs}  ${num_of_ALDs}  Sorting ALD_R by type
    Set Test Variable  ${num_of_MHAs}
    Set Test Variable  ${ALD_R_MHAs}
    Run Keyword If  ${num_of_MHAs}==${0}
    ...  Fail  msg=There is no at least one MHA in configuration
    Log  You have ${num_of_MHAs} MHAs in configuration  console=${True}

ALD.06_ALD_Manual_commissioning_with_Nokia_MHA_ALDs_assigned_as_external_units.Test_Step.1 Select LNA and LOGLINK
    [Documentation]  Test step chooses LNA and LOGLINK to change as external device.
    Log to console    \n========================================
    Log  Step: 1 Select LNA and LOGLINK  console=${True}
    Log to console    ========================================
    ${loglink_a_linkModeData_true}  ${loglink_a_firstEndpointDN}=  Get Loglink_A List With linkModeData On True
    ${LNA}=  Create List
    ${LOGLINK_A}=  Create List
    ${LNA_LOGLINK}=  Create Dictionary
    FOR  ${distName}  ${firstEndpointDN}  IN ZIP  ${loglink_a_linkModeData_true}  ${loglink_a_firstEndpointDN}
        ${ald_firstEndpointDN}=  Run Keyword And Return Status  Should Contain  ${firstEndpointDN}  ALD_A-
        Run Keyword If  ${ald_firstEndpointDN}==${True}
        ...  Set To Dictionary  ${LNA_LOGLINK}  ${firstEndpointDN}=${distName}
    END
    ${LNA_A_list}=  Get Dictionary Keys  ${LNA_LOGLINK}
    ${chosen_LNA_A}=  Evaluate  random.choice(${LNA_A_list})  random
    ${chosen_LOGLINK_A}=  Get From Dictionary  ${LNA_LOGLINK}  ${chosen_LNA_A}
    ${chosen_ALD_A}=  Should Match Regexp  ${chosen_LNA_A}  ALD_A-\\d+/LNA_A-\\d+
    ${chosen_ALD_A}=  Replace String  ${chosen_ALD_A}  search_for=_A  replace_with=
    Log  ${chosen_ALD_A} has been selected to change as external device  console=${true}
    ${LNA_ID}=  Evaluate  re.search(r'LNA_A-(\\d+)','''${chosen_LNA_A}''').group(1)  re
    ${LOGLINK_ID}=  Evaluate  re.search(r'LOGLINK_A-(\\d+)','''${chosen_LOGLINK_A}''').group(1)  re
    Set Test Variable  ${LNA_ID}
    Set Test Variable  ${LOGLINK_ID}

ALD.06_ALD_Manual_commissioning_with_Nokia_MHA_ALDs_assigned_as_external_units.Test_Step.2 Create and Activate Delta with External Unit
    [Documentation]  Test step create delta commissioning which changes MHA to external devicee.
    Log to console    \n========================================
    Log  Step: 2 Create and Activate Delta with External Unit  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    Log  Reset counter before applying delta: ${pre_action_reset_number}  console=${True}
    ${delta_external}  Set Variable  external_device
    admin.create delta  ${delta_external}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/EQM-1/HWTOP-1/LOGLINK-${LOGLINK_ID}  linkModeData  false  ${delta_external}
    admin.get delta  ${delta_external}
    ${json_path}=  Set Variable  ${RESULTS}/external_device.json
    admin.save delta  ${json_path}  delta_id=${delta_external}
    admin.perform delta recommissioning  ${json_path}  ${SKIP_PARAMETER_RELATION_ERRORS}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    Log  Reset counter after applying delta: ${post_action_reset_number}  console=${True}
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    Run Keyword If  ${counter_diff}!=${0}
#    ...  Fail  msg=Detected unexpected BTS reset

ALD.06_ALD_Manual_commissioning_with_Nokia_MHA_ALDs_assigned_as_external_units.Test_Step.${n} FEG calculation
    [Documentation]  This keyword is checking if front end gain is calculated properly.
    Log to console    \n========================================
    Log  Step: ${n} FEG calculation  console=${True}
    Log to console    ========================================
    Check FEG On Antl Without MHA
    Check FEG On Antl With MHA

ALD.06_ALD_Manual_commissioning_with_Nokia_MHA_ALDs_assigned_as_external_units.Test_Step.4 Create and Activate Delta with Removing External Unit
    [Documentation]  Test step create delta commissioning which change back MHA from external device to this BTS device.
    Log to console    \n========================================
    Log  Step: 4 Create and Activate Delta with Removing External Unit  console=${True}
    Log to console    ========================================
    ${pre_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    Log  Reset counter before applying delta: ${pre_action_reset_number}  console=${True}
    ${delta_external}  Set Variable  external_device
    admin.create delta  ${delta_external}
    admin.append parameter update to delta  MRBTS-${MRBTS_ID}/EQM-1/HWTOP-1/LOGLINK-${LOGLINK_ID}  linkModeData  true  ${delta_external}
    admin.get delta  ${delta_external}
    ${json_path}=  Set Variable  ${RESULTS}/remove_external_device.json
    admin.save delta  ${json_path}  delta_id=${delta_external}
    admin.perform delta recommissioning  ${json_path}  ${SKIP_PARAMETER_RELATION_ERRORS}
    ${post_action_reset_number}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    Log  Reset counter after applying delta: ${post_action_reset_number}  console=${True}
#    ${counter_diff}  Evaluate  abs(${pre_action_reset_number} - ${post_action_reset_number})
#    Run Keyword If  ${counter_diff}!=${0}
#    ...  Fail  msg=Detected unexpected BTS reset

ALD.06_ALD_Manual_commissioning_with_Nokia_MHA_ALDs_assigned_as_external_units.Test_Step.6 Check states and alarms on BTS
    [Documentation]
    ...  1. Check if all ALDs achieve expected state: administrativeState=unlocked, operationalState=enabled.
    ...  2. Check if all cells are on air.
    ...  3. Check active alarms on BTS.
    Log to console    \n========================================
    Log  Step: 4 Check states and alarms on BTS  console=${True}
    Log to console    ========================================
	Check ALDs State  ${ALD_expected_states}
    Check If NLWG Cells Are OnAir
    Check If Unexpected Alarms Are Raised  ${skip_fault}

ALD.06_ALD_Manual_commissioning_with_Nokia_MHA_ALDs_assigned_as_external_units.Test Specific Teardown
    [Documentation]  Test teardown which restores original configuration settings.
    Log  Restoring original configuration settings.  console=${True}
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

ALD.06_ALD_Manual_commissioning_with_Nokia_MHA_ALDs_assigned_as_external_units.Test Case Teardown
    [Arguments]  ${SEND_SNAPSHOT_FOR_SCRAMBLING}=${False}
    Run Keyword  common.Common Test Teardown  ${SEND_SNAPSHOT_FOR_SCRAMBLING}
    Run Keyword If Test Failed  ALD.06_ALD_Manual_commissioning_with_Nokia_MHA_ALDs_assigned_as_external_units.Test Specific Teardown
