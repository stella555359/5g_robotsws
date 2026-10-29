*** Settings ***
Resource  ./Resources/keywords_12486.robot

Suite Setup    12486 Suite Setup

Suite Teardown   case.Suite Case Teardown
Test Teardown  12486 case Teardown


Documentation
...    Author:Yang Liqin
...    contact:liqin.yang@nokia-sbell.com
...    squad group:SG_05
...    Feature CB012486
 
Force Tags    SBTS00
...   PY36
 
*** Variables ***
 
*** Test Cases ***
Manual_SiSo_SM_NR_RAT_reset
  [Setup]  case.Test Case Setup  Manual_SiSo_SM_NR_RAT_reset
  [Documentation]  10+10+10 5GC001116 with 3ms shift 16D8U+8D8U+8D8U
  [tags]  NR_RAT_reset
  12486_Manual_SiSo_SM_NR_RAT_reset

General_SiSo_Cell_block_and_unblock
  [Setup]  case.Test Case Setup  General_SiSo_Cell_block_and_unblock
  [Documentation]  100+50+50 5GC001116 with 3ms shift 8D8U+8D8U+8D8U
  [tags]  block
  Log To Console  General_SiSo_Cell_block_and_unblock
  12486_General_SiSo_Cell_block_and_unblock
#  COAM Teardown gnb connections

General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
  [Setup]  case.Test Case Setup  Collect_RFSW_logs_from_RU_into_BTS_Snapshot
  [Documentation]  10+10(DoD 2cc) 5GC001116 with 0ms shift 16D8U+16D8U
    [Tags]    RFSW
  12486_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot

Manual_SiSo_CM_Recommissioning  
  [Setup]  case.Test Case Setup  Manual_SiSo_CM_Recommissioning
  [Documentation]  90+50+50 5GC001070 8D8U+8D8U+8D8U
  [tags]  CM_Recommissioning
  12486_Manual_SiSo_CM_Recommissioning
  
Manual_SiSo_STARTUP_BTS_Power_Reset
  [Setup]  case.Test Case Setup  Manual_SiSo_STARTUP_BTS_Power_Reset
  [Documentation]  90+10+10 5GC001116 with 3ms shift 8D8U+8D8U+8D8U
  [tags]  power
  12486_Manual_SiSo_STARTUP_BTS_Power_Reset

General_SiSo_Online_Cell_Addition_Deletion
  [Setup]  case.Test Case Setup  Online_Cell_Addition_Deletion
  [Documentation]  10+10+10 5GC001208 8D8U+8D8U+8D8U
  [tags]  cell_add
  12486_General_SiSo_Online_Cell_Addition_Deletion

General_SiSo_Commissioning_BTS_Template_Commissioning
  [Setup]  case.Test Case Setup  Commissioning_BTS_Template_Commissioning
  [Documentation]  90+10+10 5GC001116 with 3ms shift 8D8U+8D8U+8D8U
  [Tags]  Commissioning
  CI_interface.Common Suite Setup
  General_SiSo_Commissioning_BTS_Template_Commissioning

Common_SiSo_Call_Multi UE throughput testing
  [Setup]  case.Test Case Setup  Call_Multi UE throughput testing
  [Documentation]  80+50+50 5GC001070 16D8U+8D8U+8D8U
  [Tags]  Multi_UE
  12486_Common_SiSo_Call_Multi UE throughput testing

General_SiSo_custom_beam_set_realization_to_gNB
  [Setup]  case.Test Case Setup  custom_beam_set_realization_to_Gnb
  # [Teardown]  run keyword and ignore error    COAM Teardown gnb connections
  [Documentation]  40+50(DoD 2cc) 5GC001116 with 0ms shift 16D8U+16D8U basicBeamSet=beamset6
  [Tags]  beam
  12486_General_SiSo_custom_beam_set_realization_to_Gnb
  
General_SiSo_Auto_RF_lock_unlock_with_L3call
  [Setup]  case.Test Case Setup  Auto_RF_lock_unlock_with_L3call
  # [Teardown]  run keyword and ignore error    COAM Teardown gnb connections
  [Documentation]  60+10+10 5GC001116 with 3ms shift 16D8U+8D4U+4D4U prachconfigurationindex=12
  [Tags]  RF_lock
  12486_Auto_RF_lock_unlock_with_L3call

General_SiSo_RF_module_reset_from_GUI_with_L3call
  [Setup]  case.Test Case Setup  RF_module_reset_from_GUI_with_L3call
  # [Teardown]  run keyword and ignore error    COAM Teardown gnb connections
  [Documentation]  60+20 5GC001116 with 3ms shift 8D4U+8D4U prachconfigurationindex=12
  [Tags]  RF_reset
  12486_RF_module_reset_from_GUI_with_L3call
