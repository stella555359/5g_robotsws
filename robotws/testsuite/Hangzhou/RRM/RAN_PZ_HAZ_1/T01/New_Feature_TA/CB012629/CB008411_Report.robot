*** Settings ***
Documentation
...   Author: Qin Zhixia
...   Contact: zhixia.qin@nokia-sbell.com
...   Description: The purpose of this test is to Check CB012629

Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Setup        Common Test Setup For RRM
Test Teardown     CB008411 Teardown

Force Tags
...                CA_RAN_PZ_HAZ_1
...                RAN_PZ_HAZ1_SG02_ST_RRM
...                TA_LEVEL_22
...                CRT
...                TRUNK


Test Timeout    180 minutes

Resource          ../../../Resources/Classical/RRM_Common_Resource.robot
Resource          CommonKeyword/CB012629_Common_KeyWord.robot
Resource          CommonKeyword/CB012629_ET_KeyWord.robot


*** Test Cases ***
13978
    [Tags]    QC_235965       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    sleep        60s


13664
    [Tags]    QC_240857       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    sleep        60s


*** Keywords ***
CB008411 Teardown
     Common Test Teardown For RRM
     ${scf_id}=    Get SCF Internal Id By Scout    no_ute=False