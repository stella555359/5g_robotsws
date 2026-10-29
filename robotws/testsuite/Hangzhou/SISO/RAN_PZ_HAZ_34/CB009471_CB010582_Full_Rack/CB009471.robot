*** Settings ***
Suite Setup          Suite Case Setup
Suite Teardown       Suite Case Teardown
 

Resource  testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009471_CB010582_Half_Rack/Resources/CB009471_keyword.robot


 
Documentation
...    Author:Yang Liqin
...    contact:liqin.yang@nokia-sbell.com
...    squad group:SG_05
...    Feature CB009471
 
Force Tags    SBTS00
...   PY36
 
*** Variables ***
${cpe}  ${True} 
*** Test Cases ***
[2.0] Manual_SiSo_SM_BTS_Site_Reset
  [Setup]  Test Case Setup  Manual_SiSo_SM_BTS_Site_Reset
  [Teardown]  Test Case Teardown
  [tags]  test  bts_reset  
  Log To Console  Manual_SiSo_SM_BTS_Site_Reset
  9471_Manual_SiSo_SM_BTS_Site_Reset  range_time=${1}

# [2.1] General_SiSo_Cell_block_and_unblock
#   [Setup]  Test Case Setup  General_SiSo_Cell_block_and_unblock
#   [Teardown]  Test Case Teardown
#   [tags]  test  block  1930
#   Log To Console  General_SiSo_Cell_block_and_unblock
#   9471_General_SiSo_Cell_block_and_unblock
#  COAM Teardown gnb connections
  
# [1.0] OAM_KPI_61a_SiSo_Auto_BTS_site_reset
#   [Setup]  Test Case Setup  OAM_KPI_61a_SiSo_Auto_BTS_site_reset
#   [Teardown]  Test Case Teardown
#   #  [tags]  test
#     Log To Console  OAM_KPI_61a_SiSo_Auto_BTS_site_reset
#     9471_OAM_KPI_61a_SiSo_Auto_BTS_site_reset
    
[2.0] Manual_SiSo_SM_NR_RAT_reset
  [Setup]  Test Case Setup  Manual_SiSo_SM_NR_RAT_reset
  [Teardown]  Test Case Teardown
   # [tags]  test
  9471_Manual_SiSo_SM_NR_RAT_reset

# [1.0] Manual_SiSo_SM_LTE Cell_block_unblock
#   [Setup]  Test Case Setup  Manual_SiSo_SM_LTE Cell_block_unblock
#   [Teardown]  Test Case Teardown
#   [Documentation]  Purpose of this test case is to verify that operations of blocking and unblocking of LTE cell are possible
#   [tags]  test  1930 
#   9471_Manual_SiSo_SM_LTE Cell_block_unblock

# [2.0] Manual_SiSo_CM_Recommissioning
#   [Setup]  Test Case Setup  Manual_SiSo_CM_Recommissioning
#   [Teardown]  Test Case Teardown
#   [Documentation]  dist_name='MRBTS-1930/MNL-1/MNLENT-1/SYNC-1/CLOCK-1' | abbr='holdOverModeUsed' | value='false'
#   [tags]  test  cm  1930
#   9471_Manual_SiSo_CM_Recommissioning

# [1.0] Manual_SiSo_SM_LTE RAT reset
#   [Setup]  Test Case Setup  Manual_SiSo_SM_LTE_RAT_reset
#   [Teardown]  Test Case Teardown
#   # [tags]  test
#   Manual_SiSo_SM_LTE_RAT_reset  with_call=${False}
#   Wait Until Keyword Succeeds  30min  30s  Verify all cells should be onair  cell_type=nr
#   Make calls for all bbmods
  
# [1.0] Manual_SiSo_STARTUP_BTS_Power_Reset
#   [Setup]  Test Case Setup  Manual_SiSo_STARTUP_BTS_Power_Reset
#   [Teardown]  Test Case Teardown
#   [tags]  test  power
#     9471_Manual_SiSo_STARTUP_BTS_Power_Reset
