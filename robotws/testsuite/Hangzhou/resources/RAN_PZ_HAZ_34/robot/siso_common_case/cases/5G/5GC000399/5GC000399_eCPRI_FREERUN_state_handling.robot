*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/soap.robot
*** Variables ***

*** Keywords ***
5GC000399_eCPRI_FREERUN_state_handling
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify FREERUN state handling for 5G eCPRI RU
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 21.10.2020 - - Created
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    Selenium Login And Disable Screen Lock
    ${modify_params}    Generate Modify Parameters      modify_params=${TOP_DOMAIN_NUMBER_MODIFY}
    ${orig_params}  Generate Origion Parameters  modify_params=${modify_params}
    modify parameters on webem    modify_params=${modify_params}    despite_errors=${True}
    Wait For Expect Fault Present   faultId=${16}     timeout=180
    Wait For Expect Fault Present   faultId=${4298}     timeout=180
    modify parameters on webem    modify_params=${orig_params}
    Wait For Expect Fault To Disappear   faultId=${16}   timeout=180
    Wait For Expect Fault To Disappear   faultId=${4298}     timeout=180
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    [Teardown]   Selenium Logout And Close Browser
