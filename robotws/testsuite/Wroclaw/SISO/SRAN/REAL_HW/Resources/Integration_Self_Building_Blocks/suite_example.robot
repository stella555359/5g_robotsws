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

${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=            Failed      # possible settings : Failed, Always, None

${CUSTOM_LIVE_MODE_PRIMARY_NODE_IP}=    10.42.184.146

&{SM_VM_IP_ADDRESS_DICT}=
...  L1173212304=10.42.184.146
...  L1173212320=10.42.184.125

&{CUSTOM_PDU_CONFIG}=
...  L1141527943=Aten,,10.42.51.180,4
...  L123456=APC,default,10.44.11.11,1
...  L123456=APC,default,10.44.11.11,1
...  L123456=APC,default,10.44.11.11,1

@{additional_common_fault_list}=
...  faultId=2403
...  faultId=1898
...  faultId=4261
...  faultId=4003

&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=   common=@{additional_common_fault_list}
${CHECK_SWCONFIG}=  ${False}
####################

&{PARAMETERS}=
  ...  states=${LNCEL_onair_states}
  ...  onair=${True}
  ...  timeout=240
  ...  ru_sn=L1154809204,L6141629878

${BTS_ID}=  1411

*** Test Cases ***
Test Script 1
  [Setup]  Configuration Precondition
  Block Unblock Cell TG
  ...  lte_cell_list=49901,49902
  ...  wcdma_cell_list=19001
  ...  N=2
  BTS Site Reset TG
  ...  graceful=${True}
  ...  expected_BTS_status=OnAir
  ...  HW_check=${False}
  ...  cells_check=${True}
  ...  time_after_run=20
  ...  N=2
  ...  snapshot=Always

Test Script 2
  [Setup]  Configuration Precondition  N=2
  Execute Test In Loop  Test Group 1

Test Script 3
  [Setup]  Configuration Precondition
  Check If Cell Is In Requested State
  ...  states=${LNCEL_onair_states}
  ...  class=LNCEL
  ...  onair=${True}
  ...  timeout=240
  ...  cell=49902
  Get Active Alarms On BTS
  Wait Specified Time
  ...  time=20
  ...  snapshot=Always
  Check If Cell Is In Requested State
  ...  states=${LNCEL_onair_states}
  ...  class=LNCEL
  ...  onair=${True}
  ...  timeout=240
  ...  cell=49902
  ...  N=2
  Block Cell
  ...  timeout=20
  ...  lte_cell_list=49901,49902
  ...  wcdma_cell_list=19001
  ...  N=2
  Unblock Cell
  ...  timeout=100
  ...  lte_cell_list=49901,49902
  ...  wcdma_cell_list=19001
  Lock Radio
  Unlock Radio
  Power Reset Unit
  ...  device_sn=L1154809204
  ...  N=2
  Test Group 2


*** Keywords ***
Test Group 1
    Get Active Alarms On BTS  N=2
    Check BTS STATE IS OnAir


Test Group 2
  Get Active Alarms On BTS
  ...  N=2
  Wait Specified Time
  ...  time=20
  ...  snapshot=Always
  Check If Cell Is In Requested State
  ...  states=${LNCEL_onair_states}
  ...  class=LNCEL
  ...  onair=${True}
  ...  timeout=240
  ...  cell=49902
  Block Cell
  ...  timeout=20
  ...  cell_lncel=49901
  ...  cell_wncel=49901
  Unblock Cell
  ...  class=LNCEL
  ...  timeout=100
  ...  cell=49901
