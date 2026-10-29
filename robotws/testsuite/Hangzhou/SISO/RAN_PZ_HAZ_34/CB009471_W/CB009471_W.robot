*** Settings ***
Suite Setup          Suite Case Setup
Suite Teardown       Suite Case Teardown
 

Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009471_W/Resources/CB009471_W_keyword.robot


 
Documentation
...    Author:Chen Xu
...    contact:xu.2.chen@nokia-sbell.com
...    squad group:SG_05
...    Feature CB009471_W
 
Force Tags    SBTS00
...   PY36
 
*** Variables ***
 
*** Test Cases ***

[2.1] General_SiSo_Cell_block_and_unblock
  [Setup]  Test Case Setup  General_SiSo_Cell_block_and_unblock
  [Teardown]  Test Case Teardown
  [tags]  Cell_block
  #Log To Console  AP_cell_block_unblock
  #AP_CELL_block_unblock_then_L3call
  #AP_CELL_block_unblock_then_L3call  block_list=${AP2_cell_list}  target_ap=ap2
  #AP_CELL_block_unblock_then_L3call  block_list=${AP3_cell_list}  target_ap=ap3
  Log To Console  General_SiSo_Cell_block_and_unblock
  9471_General_SiSo_Cell_block_and_unblock  range_time=${5}
#  COAM Teardown gnb connections

[2.0] Manual_SiSo_SM_NR_RAT_reset
  [Setup]  Test Case Setup  Manual_SiSo_SM_NR_RAT_reset
  [Teardown]  Test Case Teardown
  [tags]  RAT_reset
  9471_Manual_SiSo_SM_NR_RAT_reset  range_time=${5}

[2.0] Manual_SiSo_SM_BTS_Site_Reset
  [Setup]  Test Case Setup  Manual_SiSo_SM_BTS_Site_Reset
  [Teardown]  Test Case Teardown
  [tags]  Site_Reset
  Log To Console  Manual_SiSo_SM_BTS_Site_Reset
  9471_Manual_SiSo_SM_BTS_Site_Reset  range_time=${5}
