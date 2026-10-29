*** Settings ***
Library     taf.transport.ssh    WITH NAME    ssh
Resource  testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008828/resources/CB008828_keyword.robot

Test Teardown    CB008828 Common Test Teardown

Suite Setup    Suite Case19 Setup
Suite Teardown    Suite Case D Teardown

*** Variables ***


*** Test Cases ***
[1]CB008828_SR_019_D#B1_Online_activation_of_CB008828_with_PM_counters 
  [Setup]  Test Case Setup  Online_activation_of_CB008828
  [Teardown]  Test Case Teardown
  [Documentation]    Author: Yang Liqin
  [tags]  case19 
  Log To Console  Online_activation_of_CB008828
  Online activation of CB008828 with PM counters




