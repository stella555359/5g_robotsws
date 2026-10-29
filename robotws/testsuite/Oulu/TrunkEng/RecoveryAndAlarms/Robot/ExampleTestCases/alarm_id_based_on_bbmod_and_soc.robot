*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

Resource    testsuite/Oulu/TrunkEng/Common/Robot/Resources/common_resources.robot
Resource    testsuite/Oulu/TrunkEng/RecoveryAndAlarms/Robot/TestKeywords/bbmod_soc_test_kws.robot

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Run Keywords  Common Test Setup
...               AND           Start Alarm Listener  ${ALLOWED_ALARMS_FILE}
Test Teardown     Common Test Teardown

*** Variables ***
${ALLOWED_ALARMS_FILE}  testsuite/Oulu/TrunkEng/RecoveryAndAlarms/allowed_alarms.txt
${BBMOD}                BBMOD1
${SOC}                  K2C

*** Test Cases ***
Get Alarm Id Of Given Bbmod and Soc
    Run Keyword In Loop And Return Pass Rate
        ...    name=Get Alarm Id Of Given Bbmod and Soc
        ...    test_case=1
        ...    loops=1
        ...    keywords=Alarm Id Of Bbmod Soc
        ...    expected_pass_rate=1

*** Keywords ***
Alarm Id Of Bbmod Soc
    Print Step Text   1  Get alarm id of given bbmod and soc
    ${BBMOD_OBJ}=     Get Bbmod Object From User Given Values  ${BBMOD}
    ${bbmod_name}=    Get Values From Object    ${BBMOD_OBJ}  name
# if cell resources are not given in kw call then cell resources are called in the method, this is the best way so
# cell resources are parsed always before stuff is done
    Get Alarm Id Based On Cell Resources On Bbmod And Soc  ${bbmod_name}  ${SOC}

# cell resources can be get before hand and give to each call, this saves time but if reset etc are done then resources may be changed
    ${CELL_RES}=  Get Cell Resources
    Get Alarm Id Based On Cell Resources On Bbmod And Soc  ${bbmod_name}  K2D  ${CELL_RES}
    Get Alarm Id Based On Cell Resources On Bbmod And Soc  ${bbmod_name}  K2A  ${CELL_RES}
    Get Alarm Id Based On Cell Resources On Bbmod And Soc  ${bbmod_name}  K2B  ${CELL_RES}
