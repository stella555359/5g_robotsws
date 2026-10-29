*** Settings ***
Library     taf.transport.ssh    WITH NAME    ssh
Resource  ./Resources/CNI128069_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/case.robot

Documentation
...    author: Liqin Yang
...    contact: liqin.yang@nokia-sbell.com
...    Group: HGZ_SG5

Suite Setup    case.Suite Case Setup
Suite Teardown    case.Suite Case Teardown
Test Teardown  case.Test Case Teardown

*** Test Cases ***
[1]CNI_128069_007_DL_and_UL_SAS_same_scheduleweight_full_buffer
  [Setup]  case.Test Case Setup  DL_and_UL_SAS_same_scheduleweight_full_buffer
  [Documentation]    Author: Yang Liqin
  [Tags]  Case7
  Log To Console  DL_and_UL_SAS_same_scheduleweight_full_buffer
  DL_and_UL_SAS_same_scheduleweight_full_buffer

[1]CNI_128069_006_UL_SAS_same_scheduleweight_full_buffer
  [Setup]  case.Test Case Setup  UL_SAS_same_scheduleweight_full_buffer
  [Documentation]    Author: Yang Liqin
  [Tags]  Case6
  Log To Console  UL_SAS_same_scheduleweight_full_buffer
  UL_SAS_same_scheduleweight_full_buffer

[1]CNI_128069_001_DL_SAS_same_scheduleweight_full_buffer_test
  [Setup]  case.Test Case Setup  DL_SAS_same_scheduleweight_full_buffer_test
  [Documentation]    Author: Yang Liqin
  [Tags]  Case1
  Log To Console  DL_SAS_same_scheduleweight_full_buffer_test
  DL_SAS_same_scheduleweight_full_buffer_test

[1]CNI_128069_002_DL_SAS_different_scheduleweight_full_buffer_test
  [Setup]  case.Test Case Setup  DL_SAS_different_scheduleweight_full_buffer_test
  [Documentation]    Author: Yang Liqin
  [Tags]  Case2
  Log To Console  DL_SAS_different_scheduleweight_full_buffer_test
  DL_SAS_different_scheduleweight_full_buffer_test

[1]CNI_128069_003_DL_SAS_same_scheduleweight_some_RGs_no_UE
  [Setup]  case.Test Case Setup  DL_SAS_same_scheduleweight_some_RGs_no_UE
  [Documentation]    Author: Yang Liqin
  [Tags]  Case3
  Log To Console  DL_SAS_same_scheduleweight_some_RGs_no_UE
  DL_SAS_same_scheduleweight_some_RGs_no_UE

[1]CNI_128069_004_DL_SAS_same_scheduleweight_some_RGs_low_buffer
  [Setup]  case.Test Case Setup  DL_SAS_same_scheduleweight_some_RGs_low_buffer
  [Documentation]    Author: Yang Liqin
  [Tags]  Case4
  Log To Console  DL_SAS_same_scheduleweight_some_RGs_low_buffer
  DL_SAS_same_scheduleweight_some_RGs_low_buffer

[1]CNI_128069_005_DL_SAS_same_scheduleweight_some_RGs_run_mixed_GBR_and_nonGBR_traffic
  [Setup]  case.Test Case Setup  DL_SAS_same_scheduleweight_some_RGs_run_mixed_GBR_nonGBR
  [Documentation]    Author: Yang Liqin
  [Tags]  Case5
  Log To Console  DL_SAS_same_scheduleweight_some_RGs_run_mixed_GBR_nonGBR
  DL_SAS_same_scheduleweight_some_RGs_run_mixed_GBR_nonGBR
