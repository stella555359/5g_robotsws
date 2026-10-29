*** Settings ***
Documentation    Library for handling integration with RePor

Library         testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.reports.ScoutReport
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.reports.support

Library         taf.sw.reporting_portal


*** Keywords ***
Add scout external execution id to the reporting portal
    ${manual_execution} =    is_it_manual_execution
    ${tl_name_scout} =    testline_name_in_scout
    ${scout_id} =  scout_fetch_configuration    ${tl_name_scout}    ${manual_execution}
    Run Keyword If  '${scout_id}'!='None'  Run Keyword If  '${manual_execution}'=='True'  Add to test data  data={"tc_execution_id": "${scout_id}"}
