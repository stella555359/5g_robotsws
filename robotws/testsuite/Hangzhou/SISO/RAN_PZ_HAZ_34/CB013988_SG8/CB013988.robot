*** Settings ***
Suite Setup    run keywords    SISO Coam Suite Setup    AND    Get btsName
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource     Resources/CB013988_common_keyword.robot
Library    lib/CB013988.py
Variables    TestData/CB013988_variables.py

Documentation
...    Author: jiangjing.lin
...    Contact: jiangjing.lin@nokia-sbell.com
...    squad group:SG_08
...    Feature CB013988

Force Tags            RAN_5G_TDD    5G_RAN_TDD    SBTS00    RAN_5G    5G_RAN    CRT_UTE	   STATE_SW_UPLOADED
...   PY36
...    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQN_5GC002374

*** Test Cases ***
[1]CB013988_A_01_RU_power_reset_and_mplane_reestablished
    CB013988_A_01_RU_power_reset_and_mplane_reestablished    interval=15min

[1]CB013988_A_03_A#B002_RU_power_reset_escalation_for_internal_radio_recovery_ALT1
   CB013988_A_03_A#B002_RU_power_reset_escalation_for_internal_radio_recovery_ALT1    interval=15min
