*** Settings ***
Documentation
...    Author:Yang Liqin
...    contact:liqin.yang@nokia-sbell.com
...    squad group:SG_05
...    Feature CB012170
Library     taf.transport.ssh    WITH NAME    ssh
Resource  ./Resources/CB012170_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/case.robot


Suite Setup    12170_Suite Case Setup
Suite Teardown    case.Suite Case Teardown

Test Teardown  case.Test Case Teardown
# Test Teardown  Run keywords    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
# ...  AND  run keyword and ignore error    COAM Teardown gnb connections

*** Test Cases ***
[1]CB012170_SR_001_A#B1_Online_feature_activation
  [Setup]  case.Test Case Setup  Online_feature_activation_AQQF
  [Documentation]    Author: Yang Liqin
  [Tags]  Case1
  Log To Console  Online_feature_activation
  Online_feature_activation_or_deactivation  cell_id=1
  Connect to gnb coam via ssl
  Online_feature_activation_or_deactivation  cell_id=3



