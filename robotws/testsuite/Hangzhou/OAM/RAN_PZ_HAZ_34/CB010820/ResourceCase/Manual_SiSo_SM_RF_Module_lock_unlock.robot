*** Settings ***
Resource    ../Resource/Common.robot


*** Variables ***


*** Keywords ***
Test_Case_Manual_SiSo_SM_RF_Module_lock_unlock
    Case Setup: Manual_SiSo_SM_RF_Module_lock_unlock
    Manual_SiSo_SM_RF_Module_lock_unlock
    [Teardown]   Case Teardown: Manual_SiSo_SM_RF_Module_lock_unlock


Manual_SiSo_SM_RF_Module_lock_unlock
    Log To Console   Manual_SiSo_SM_RF_Module_lock_unlock
    ${rmod_obj_list}   coam.get_managed_objects   class_name=RMOD_R   timeout=${60}   connection=COAM
    @{rmod_dn_list}   Evaluate   [i['distName'] for i in $rmod_obj_list if i['parameters']['productName']=='AEHC']
    FOR   ${rmod_dn}   IN   @{rmod_dn_list}
        coam.lock   dist_name=${rmod_dn}   connection=COAM   timeout=${600}
        coam.unlock   dist_name=${rmod_dn}   connection=COAM   timeout=${600}
        Wait Until Keyword Succeeds   15m   1m   COAM ADMIN Check Cell Onair

        CB010820 L3 Call Common Keyword

    END

Case Setup: Manual_SiSo_SM_RF_Module_lock_unlock
    Set Suite Variable   ${DEFINE_TEST_NAME}   Manual_SiSo_SM_RF_Module_lock_unlock
    CB010820 Common Case Setup
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    Wait Until Keyword Succeeds   20m   1m   COAM ADMIN Check Cell Onair


Case Teardown: Manual_SiSo_SM_RF_Module_lock_unlock
    Run Keyword And Ignore Error   COAM Logout

    CB010820 Common Case Teardown

