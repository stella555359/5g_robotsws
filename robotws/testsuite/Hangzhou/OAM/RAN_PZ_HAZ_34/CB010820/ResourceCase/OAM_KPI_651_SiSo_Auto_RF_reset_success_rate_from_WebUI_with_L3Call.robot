*** Settings ***
Resource    ../Resource/Common.robot


*** Variables ***


*** Keywords ***
Test_Case_OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI_with_L3Call
    Case Setup: OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI_with_L3Call
    OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI_with_L3Call
    [Teardown]   Case Teardown: OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI_with_L3Call


OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI_with_L3Call
    Log To Console   OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI_with_L3Call
    ${rmod_obj_list}   coam.get_managed_objects   class_name=RMOD_R   timeout=${60}   connection=COAM
    @{rmod_dn_list}   Evaluate   [i['distName'] for i in $rmod_obj_list]
    FOR   ${rmod_dn}   IN   @{rmod_dn_list}
        COAM Reset RMOD   dist_name=${rmod_dn}
        Wait Until Keyword Succeeds   15m   1m   COAM ADMIN Check Cell Onair

        CB010820 L3 Call Common Keyword

    END


Case Setup: OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI_with_L3Call
    Set Suite Variable   ${DEFINE_TEST_NAME}   OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI_with_L3Call
    CB010820 Common Case Setup
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    Wait Until Keyword Succeeds   20m   1m   COAM ADMIN Check Cell Onair


Case Teardown: OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI_with_L3Call
    Run Keyword And Ignore Error   COAM Logout
    CB010820 Common Case Teardown
