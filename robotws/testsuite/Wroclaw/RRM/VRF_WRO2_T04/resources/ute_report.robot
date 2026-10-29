*** Settings ***
Documentation
...   author: Tomasz Godlewski
...   contact: tomasz.godlewski@nokia.com

Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/scout_report.py  WITH NAME  scout_report
Library    taf.sw.reporting_portal

*** Keywords ***
Add Scout Data Info To Testcase
    ${scout_id}    scout_report.scout_fetch_configuration
    Run Keyword If    '${scout_id}'!='None'    Add To Test Data    data={"tc_execution_id": "${scout_id}"}
