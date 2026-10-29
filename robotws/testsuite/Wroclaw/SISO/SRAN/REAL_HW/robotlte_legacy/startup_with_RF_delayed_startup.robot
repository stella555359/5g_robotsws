*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS

Resource    ../Resources/Setup/setup_and_teardown.robot
Resource  ./common_setup.robot
Resource  ./site_operations.robot
Resource  ./site_verifications.robot
Resource  ./variables.robot


Library  BuiltIn
Library  Collections
Library  String
Library  robot.libraries.DateTime
Library  taf.sbts.oam.coam.admin    WITH NAME    admin
Library  ute_admin_infomodel    WITH NAME    admin_im

*** Variables ***
${FAULT_10_STARTUP_TIMEOUT}=  900  # 13 minutes + 2 mins for time between BTS startup and FRI timer to start


*** Keywords ***
Perform BTS Startup With RF Delayed Startup On Every Node
  [Arguments]  &{kwargs}
  FOR  ${node}  IN  @{cfg.active_bts_list}
    BTS Startup With RF Delayed Startup  ${node}  ${node}  &{kwargs}
  END

BTS Startup With RF Delayed Startup
  [Documentation]
  ...  This test case is for a BTS startup with RF delayed startup. Initially, all BB cards and RF modules are
  ...  turned off, except for one RF module that can be defined by the user. The test case checks the RU power removed
  ...  state and the state of all affected RUs. In the next step, the state of all cells is checked.
  ...  The test case waits for FAULT_10_STARTUP_TIMEOUT, which is 900 seconds by default, for fault 10
  ...  on the turned-off RU. After that, all alarms are verified. In the last step, the RU is turned on,
  ...  and the state of cells and alarms are checked again.
  ...  Parameters:
  ...  Name  |  Mandatory  |  Default value  |  Description
  ...  FAULT_10_STARTUP_TIMEOUT |  Yes  |  900  |  Timeout for fault 10 after startup
  ...
  ...  User input:
  ...  Name  |  Mandatory  |  Default value  |  Description
  ...  RF  |  No  |  First RF in CFG  |  Serial number of RF that should be turn on with delay
  ...  Delay  |  No  |  0  |  Delay after power on - tested RU still off
  [Arguments]  ${node}  ${alias}=${cfg.primary_node_bts_id}  &{kwargs}

  ${rf_list}=  Get Dictionary Keys  ${cfg.RF_INFO}
  ${RF_status}=  Run Keyword And Return Status  Variable Should Exist  ${CUSTOM_RADIO_UNIT_LIST}
  ${rf_list}=  Set Variable If  ${RF_status}  ${CUSTOM_RADIO_UNIT_LIST}  ${rf_list}
  ${status_RF}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs['RF']}
  ${ru_sn_index}=  Evaluate  random.randint(0, len(${rf_list})-1)  modules=random
  ${ru_sn}=  Set Variable If  ${status_RF}  ${kwargs['RF']}  ${rf_list[${ru_sn_index}]}
  ${status_delay}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs['Delay']}
  ${delay}=  Set Variable If  ${status_delay}  ${kwargs['Delay']}  0
  ${ru_bts_id}  ${ru_dist_name}=  Get RU Node Data  ${ru_sn}

  Step 1: Turn Off All Devices  ${node}
  Step 2: Turn On All Devices Without 1 RM  ${node}  ${ru_sn}
  Step 3: Check Faults And State For Affected RUs  ${cfg}  ${ru_sn}  ${ru_bts_id}  ${ru_dist_name}  ${delay}
  Step 4: Turn On RF And Check Faults And State  ${cfg}  ${ru_sn}  ${ru_bts_id}  ${ru_dist_name}
  [Teardown]  Run Keywords
  ...  Verify Multi BTS State
  ...  AND  Verify Alarms  alias=${alias}
  ...  AND  Run Keyword If  '${KEYWORD STATUS}' != 'PASS'  Perform RU Power Insert  ${ru_sn}  ${FR_AVAILABILITY_TIMEOUT} sec

Step 1: Turn Off All Devices
  [Arguments]  ${node}
  Log To Console  \nTuning Off All Devices on Node=${node} started
  PDU Switch OFF Device Lists
  ...  serial_number_list=${cfg.NODES['${node}']['scf_hw_sm_list']}
  PDU Switch OFF Device Lists
  ...  serial_number_list=${cfg.NODES['${node}']['scf_hw_fr_list']}
  Sleep  20 sec

Step 2: Turn On All Devices Without 1 RM
  [Arguments]  ${node}  ${ru_sn}
  ${delay_rf_list}=  Create List  ${ru_sn}
  ${radios_to_power_on}=  Subtract List From List  ${cfg.NODES['${node}']['scf_hw_fr_list']}  ${delay_rf_list}
  PDU Switch On Device Lists
  ...  serial_number_list=${radios_to_power_on}
  PDU Switch On Device Lists
  ...  serial_number_list=${cfg.NODES['${node}']['scf_hw_sm_list']}
  Log To Console  BTS startup with RF delayed startup on node=${node} finished

Step 3: Check Faults And State For Affected RUs
  [Arguments]  ${cfg}  ${ru_sn}  ${ru_bts_id}  ${ru_dist_name}  ${delay}
  Verify RU Power Remove Insert State  ${ru_bts_id}  ${ru_dist_name}  Remove  ${FAULT_10_TIMEOUT} sec
  Verify RU Power Remove Insert State For Affected RUs  ${ru_bts_id}  ${ru_sn}  Remove  ${FAULT_10_TIMEOUT} sec
  Sleep  ${delay}s
  Verify RU Power Remove Insert Cells State
  ...  ${cfg}
  ...  ${ru_bts_id}
  ...  ${ru_sn}
  ...  ${ru_dist_name}
  ...  Remove
  ...  ${FAULT_10_TIMEOUT} sec
  Check Fault 10 After Startup  ${ru_bts_id}  ${FAULT_10_STARTUP_TIMEOUT} sec
  Verify FID 4589  ${ru_bts_id}
  Verify RU Power Remove Insert Alarms  ${ru_bts_id}  ${ru_sn}  ${ru_dist_name}  Remove  ${FAULT_10_TIMEOUT} sec

Step 4: Turn On RF And Check Faults And State
  [Arguments]  ${cfg}  ${ru_sn}  ${ru_bts_id}  ${ru_dist_name}
  ${ru_startup_start_date}=  Perform RU Power Insert  ${ru_sn}  ${FR_AVAILABILITY_TIMEOUT} sec
  ${ru_startup_end_date}=  Verify RU Power Remove Insert State
  ...  ${ru_bts_id}
  ...  ${ru_dist_name}
  ...  Insert
  ...  ${FR_AVAILABILITY_TIMEOUT} sec
  Verify RU Power Remove Insert State For Affected RUs  ${ru_bts_id}  ${ru_sn}  Insert  ${FR_AVAILABILITY_TIMEOUT} sec
  Verify RU Power Remove Insert Cells State
  ...  ${cfg}
  ...  ${ru_bts_id}
  ...  ${ru_sn}
  ...  ${ru_dist_name}
  ...  Insert
  ...  ${FR_AVAILABILITY_TIMEOUT} sec
  Verify RU Power Remove Insert Alarms  ${ru_bts_id}  ${ru_sn}  ${ru_dist_name}  Insert  ${FR_AVAILABILITY_TIMEOUT} sec
  ${ru_startup_status}  ${time_diff}=  Verify RU Startup Time
  ...  Power
  ...  ${cfg}
  ...  ${ru_bts_id}
  ...  ${ru_startup_start_date}
  ...  ${ru_startup_end_date}
  Run Keyword If  not ${ru_startup_status}  FAIL

Check Fault 10 After Startup
  [Arguments]  ${ru_bts_id}  ${timeout}
  [Timeout]  900 sec
  ${alarm_list}=  Create List  faultId=10, severity=Critical
  Log To Console  Checking fault 10 on Radio
  ${alarm_state_status}=  Run Keyword And Continue On Failure
  ...  Check Mandatory Alarm Active List
  ...  ${ru_bts_id}
  ...  ${alarm_list}
  ...  ${timeout}
