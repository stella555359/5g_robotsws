*** Settings ***
Documentation
...   author: PZ_2_WRO_5

Library         testsuite.Wroclaw.RRM.VRF_WRO2_T05.classical.regression.common_keywords.resource.ScoutReport
Library         taf.sw.reporting_portal  WITH NAME  rep


*** Keywords ***
Add scout external execution id to the reporting portal
    ${manual_execution} =    is_it_manual_execution
    ${tl_name_scout} =    Get TL in scout
    ${scout_id} =  scout_fetch_configuration    ${tl_name_scout}  ${manual_execution}
    Run Keyword If  '${scout_id}'!='None'  rep.Add To Test Data  data={"tc_execution_id": "${scout_id}"}
