*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ./Resources/CNI-126050-keywords.robot


Documentation
...    Author: Jiangjing
...    Contact: jiangjing.lin@nokia-sbell.com
...    squad group:SG_08
...    Feature CNI-126050

Force Tags    RAN_5G_TDD    5G_RAN_TDD    CRT_TRUNK    CRT_23R1    CRT_23R2
...    PY36
...    SBTS00

*** Test Cases ***
[1]CNI-126050_02_PM_Counters_Enabled_With_PRACH_PUCCH_F1
    CNI-126050_02_PM_Counters_Enabled_With_PRACH_PUCCH_F1    tput_info=${tput_cni_126050}    interval=${5}
