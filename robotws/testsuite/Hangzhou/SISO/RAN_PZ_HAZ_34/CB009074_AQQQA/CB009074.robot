*** Settings ***

Library     taf.transport.ssh    WITH NAME    ssh
Resource  ./Resources/CB009074_keyword.robot

Suite Setup    Suite Case Setup

Suite Teardown    Suite Case Teardown


*** Test Cases ***
[1]CB009074_5G_002_RF6.2b_AQQQA_scan_test_with_Composite_Rx_in_online_mode
  [Setup]  Test Case Setup  AQQQA_scan_test_with_Composite_Rx
  [Teardown]  Test Case Teardown
  [Documentation]    Author: Yang Liqin
  [tags]  case2 
  Log To Console  AQQQA_scan_test_with_Composite_Rx
  Run Keyword And Continue On Failure  AQQQA_scan_test_with_capture_type
  Run Keyword And Continue On Failure  3_AQQQA_8D8U_scan_test_with_Carrier Rx (FIR9)
  7_AQQQA_scan_enable_and_disable_several_times


[1]CB009074_5G_005_RF6.2b_AQQQA_scan_test_with_Composite_Rx_via_WebEM_CLI_during_ongoing_capture_in_online_mode
  [Setup]  Precondition for WEBCLI case  
  [Teardown]  Run keywords  Clean Testing Env  AND  
  ...  Test Case Teardown
  [tags]  case5 
  Log To Console  AQQQA_scan_test_with_Composite_Rx_via_WebEM_CLI
  Run Keyword And Continue On Failure  5_Start two RF Scanning test via WEBCLI
  6_AQQQA_scan_test_with_Raw Composite_Rx (RxADC)_via_WebEM_and_WebEM_CLI

