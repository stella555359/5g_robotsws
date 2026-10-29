*** Settings ***
Library     taf.transport.ssh    WITH NAME    ssh
Resource  ./Resources/CNI112690_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/case.robot


Suite Setup    case.Suite Case Setup
Suite Teardown    case.Suite Case Teardown

*** Variables ***


*** Test Cases ***
CNI_112690_005_bts_reset_on_webem_after_PCIe_issues_on_primary_core 
  [Setup]  case.Test Case Setup  bts_reset_on_webem_after_PCIe_issues_on_primary_core
  [Teardown]  case.Test Case Teardown
  [Documentation]    Author: Yang Liqin
  Log To Console  bts_reset_on_webem_after_PCIe_issues_on_primary_core
  bts_reset_on_webem_after_PCIe_issues_on_primary_core




