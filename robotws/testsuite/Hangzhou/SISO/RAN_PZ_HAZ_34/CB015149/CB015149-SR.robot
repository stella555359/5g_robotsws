*** Settings ***
Suite Setup       SISO Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown
#Test Setup
#Test Teardown
Test Timeout      1.5 hours

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource     ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource     ${BASIC_PATH_5G}/OAM_KPI_61a_SiSo_Auto_BTS_site_reset.robot

Documentation
...    Author: Zheng Jack
...    Contact: jack.zheng@nokia-sbell.com
...    Squad group:SG_05

Force Tags    RAN_5G    RAN_5G_TDD    SBTS00    PY310

*** Variables ***
${MAX_LOOP}    ${5}


*** Test Cases ***
[1]CB015149-SR-A-03-OAM_KPI_61a_SiSo_Auto_BTS_site_reset
    [Tags]    CRT_TRUNK    CB015149_ABIP_ABIO_RF_Sharing
    [Setup]    SISO Coam Test Setup
    OAM_KPI_61a_SiSo_Auto_BTS_site_reset
    [Teardown]    SISO Coam Test Teardown