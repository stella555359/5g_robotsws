*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_SISO_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB005763/Resources/CB005763_keyword.robot

Documentation
...    Author:Ye Tianyi
...    contact:tianyi.ye@nokia-sbell.com
...    squad group:Vrf3_SG8
...    Feature CB005763

Force Tags    SBTS00
...    PY36

*** Variables ***
${LOOP_number}    20

*** Test Cases ***
[1]CB005763-BA_Dying_Gasp_alarm_check_RF_split_AZNA
    [Tags]    CRT_TRUNK
    CB005763-BA_Dying_Gasp_alarm_check_RF_split_AZNA

[1]CB005763-BI_Dying_Gasp_alarm_check_AZQF
    [Tags]    CRT_TRUNK
    CB005763-BI_Dying_Gasp_alarm_check_AZQF

[1]CB005763-CA_RF_chain_Dying_Gasp_alarm_check_when_first_RU_power_off_AZNA
    [Tags]    CRT_TRUNK
    CB005763-CA_RF_chain_Dying_Gasp_alarm_check_when_first_RU_power_off_AZNA

[1]CB005763-DC_Dying_Gasp_alarm_check_ecpri_AQQJ
    [Tags]    CRT_TRUNK
    CB005763-BI_Dying_Gasp_alarm_check_AZQF

[1]CB005763_RU_power_off_power_on_loop
    [Tags]    CRT_TRUNK
    General_SISO_RU_power_off_power_on_loop
