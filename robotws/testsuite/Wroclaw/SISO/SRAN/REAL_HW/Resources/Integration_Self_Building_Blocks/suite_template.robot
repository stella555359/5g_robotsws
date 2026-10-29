*** Settings ***
Documentation
...   author: Piotr Korczynski
...   contact: piotr.korczynski@nokia.com

Resource    ../../Resources/Setup/setup_and_teardown.robot
Resource    ../../Resources/Integration_Self_Building_Blocks/test_procedures.robot
Resource    ../../Resources/Integration_Self_Building_Blocks/test_scripts.robot
Resource    ../../Resources/Integration_Self_Building_Blocks/test_groups.robot



Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition


*** Variables ***

${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=            None      # possible settings : Failed, Always, None

${CUSTOM_LIVE_MODE_PRIMARY_NODE_IP}=    10.42.184.146
#@{CUSTOM_LIVE_MODE_AUXILLARY_NODES_IPS_LIST}=

&{SM_VM_IP_ADDRESS_DICT}=
...  L1173212304=10.42.184.146
...  L1173212320=10.42.184.125

&{CUSTOM_PDU_CONFIG}=
...  L1141527943=Aten,,10.42.51.180,4
...  L123456=APC,default,10.44.11.11,1
...  L123456=APC,default,10.44.11.11,1
...  L123456=APC,default,10.44.11.11,1

${SKIP_TRUCK_ROLL}=   ${True}
@{additional_common_fault_list}=
...  faultId=2403
...  faultId=1898
...  faultId=4261
...  faultId=4003

&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=   common=@{additional_common_fault_list}
${CUSTOM_LOOP_LOGS_OPTIMIZATION}=  ${False}
${CHECK_SWCONFIG}=  ${False}
####################


&{PARAMETERS}=
  ...  states=${LNCEL_onair_states}
  ...  onair=${True}
  ...  timeout=240
  ...  ru_sn=L1154809204,L6141629878
  ...  device_sn=L1154809204,L6141629878
${BTS_ID}=  1411

*** Test Cases ***
Test Script
  [Setup]  Configuration Precondition
  ## Test Groups
  Block Unblock Cell TG
  ...  lte_cell_list=49901,49902
  ...  wcdma_cell_list=19001
  ...  time_after_run=10s
  ...  check_faults_active=True
  ...  check_faults_history=True
  ...  procedure_specific_faults=faultId=49
  ...  time=20   # time between block and unblock
  ...  nr_cell_list=49901
  ...  gsm_cell_list=49901,49902
  ...  N=2
  ...  snapshot=Always  # take snapshot after each iteration
  BTS Site Reset TG
  ...  graceful=${True}
  ...  expected_BTS_status=OnAir
  ...  HW_check=${False}  # after site reset HW will be checked or not
  ...  cells_check=${True} # after site reset cells will be checked or not
  ...  time_after_run=10s
  ...  check_faults_active=True
  ...  check_faults_history=True

## Test Procedures
  Block Cell
  ...  lte_cell_list=49901,49902
  ...  check_faults_active=True
  ...  check_faults_history=True
  ...  procedure_specific_faults=faultId=49
  ...  time_after_run=10 min
  Unblock Cell
  ...  time_after_run=10s
  ...  lte_cell_list=49901,49902
  ...  check_faults_active=True
  ...  check_faults_history=True
  ...  procedure_specific_faults=faultId=49
  Lock Radio
  ...  ru_sn=L1154809204
  ...  timeout=20
  Unlock Radio
  ...  ru_sn=L1154809204
  ...  timeout=20
  Cell Administrative State Change
  ...  value=locked
  ...  lte_cell_list=49901,49902
  Cell Administrative State Change
  ...  value=unlocked
  ...  lte_cell_list=49901,49902
  BTS Block
  ...  timeout=20
  BTS Unblock
  ...  timeout=100

  BTS Reset
  ...  graceful=${True}

  Power Off Unit
  ...  device_sn=L1154809204

  Power On Unit
  ...  device_sn=L1154809204

  Power Reset Unit
  ...  device_sn=L1154809204
  ...  time=20
  Power Reset BTS
  Sleep  10s
  Wait Specified Time
  ...  time=20

  Save BTS Snapshot
  Check BTS STATE IS OnAir
  Check If All Cells Are OnAir
  Get Active Alarms On BTS

  Check If Cell Is In Requested State
  ...  states=${LNCEL_onair_states}
  ...  class=LNCEL
  ...  onair=${True}
  ...  timeout=240
  ...  cell=49902

