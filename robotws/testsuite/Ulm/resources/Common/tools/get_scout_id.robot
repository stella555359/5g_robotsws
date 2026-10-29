*** Settings ***
Documentation   This is a testcase meant for manual testers to retrieve tc_execution_id needed for Reporting

Resource    ../reporting.robot


*** Test Cases ***
Get SCOUT TC ID for Reporting
  [Documentation]
  ...   trigger SCF upload to scout, returns scout_scf_id
  ...
  ${scf_id}=  Set SCOUT TC ID For Reporting
  Log To Console  \ntc_execution_id: \n${scf_id}
