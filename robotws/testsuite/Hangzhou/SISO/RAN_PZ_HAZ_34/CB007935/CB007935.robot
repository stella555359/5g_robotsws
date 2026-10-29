*** Settings ***
Documentation
...    Author:Yang Liqin
...    contact:liqin.yang@nokia-sbell.com
...    squad group:SG_05
...    Feature CB007935
Library     taf.transport.ssh    WITH NAME    ssh
Resource  ./Resources/CB007935_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/case.robot


Suite Setup    7935_Suite Case Setup
# Suite Teardown    case.Suite Case Teardown
Suite Teardown    case.Suite Case Teardown

# Test Teardown  case.Test Case Teardown
Test Teardown  Run keywords    case.Test Case Teardown
...  AND  Disconnect TPS

*** Test Cases ***
[1]CB007935_C_07_General_SiSo_RU_module_reset_from_GUI
  [Setup]  case.Test Case Setup  C_07_General_SiSo_RU_module_reset_from_GUI
  [Documentation]    Author: Yang Liqin
  [Tags]  C07
  Log To Console  C_07_General_SiSo_RU_module_reset_from_GUI
  CB007935_keyword.General_SiSo_RU_module_reset_from_GUI

[1]CB007935_A_01_Assisted_SyncE_Holdover_Estimate_No_impairmen
  [Setup]  case.Test Case Setup  A_01_Assisted_SyncE_Holdover_Estimate_No_impairmen
  [Documentation]    Author: Yang Liqin
  [Tags]  A01
  Log To Console  A_01_Assisted_SyncE_Holdover_Estimate_No_impairmen
  RU_Supported_NIDD_Status_Read_Only_Parameters

[1]CB007935_A_03_RU_SyncE_Network_Rearrangement_PM_Counter
  [Setup]  case.Test Case Setup  A_03_RU_SyncE_Network_Rearrangement_PM_Counter
  [Documentation]    Author: Yang Liqin
  [Tags]  A03
  Log To Console  A_03_RU_SyncE_Network_Rearrangement_PM_Counter
  RU_SyncE_Network_Rearrangement_PM_Counter

[1]CB007935_C_01_Operation_in_Manual_Assisted_holdover_Mode_with_maximum_HO_period
  [Setup]  case.Test Case Setup  C_01_Operation_in_Manual_Assisted_holdover_Mode_with_maximum_HO_period
  [Documentation]    Author: Yang Liqin
  [Tags]  C01
  Log To Console  C_01_Operation_in_Manual_Assisted_holdover_Mode_with_maximum_HO_period
  Operation_in_Manual_Assisted_holdover_Mode

