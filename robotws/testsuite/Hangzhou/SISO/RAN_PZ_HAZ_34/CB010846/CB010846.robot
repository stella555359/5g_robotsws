*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown

Test Timeout         3h

Resource      Resource/CB010846_Common_KW.robot


Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...    Feature CB010846 BB Capacity board improvement in reconfiguration and recoveryin SBTS25R1 program

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY39    master_classicalbts_all

*** Variables ***

*** Test Cases ***
[1]CB010846_5G_A_02_eCPRI_RU_resiliency_to_BTS_DU_L1Soc_reset_Controlled_case
    [Tags]    CRT_TRUNK
    [Setup]   SISO Coam Test Setup
    eCPRI_RU_resiliency_to_BTS_DU_L1Soc_reset_Controlled_case    ru_index=${1}
    [Teardown]    SISO Coam Test Teardown

[1]CB010846_5G_C_01_RU_resiliency_to_BTS_DU_L1Soc_reset_on_line_activation
    [Tags]    CRT_TRUNK
    [Setup]   SISO Coam Test Setup
    eCPRI_RU_resiliency_to_BTS_DU_L1Soc_reset_on_line_activation
    [Teardown]    SISO Coam Test Teardown

[1]CB010846_5G_D_01_eCPRI_RU_resiliency_to_BTS_DU_L1Soc_reset_uncontrolled_case
    [Tags]    CRT_TRUNK
    [Setup]   SISO Coam Test Setup
    eCPRI_RU_resiliency_to_BTS_DU_L1Soc_reset_uncontrolled_case    ru_index=${1}
    [Teardown]    SISO Coam Test Teardown

*** Keywords ***
