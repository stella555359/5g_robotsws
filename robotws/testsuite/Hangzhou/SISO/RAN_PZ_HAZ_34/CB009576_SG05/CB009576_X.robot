*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Timeout         500 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    ./resource/CB009576_X_resource.robot

Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CB009576 in 5G24R2 program

Force Tags    RAN_5G_TDD
...    PY36

*** Variables ***

*** Test Cases ***
[1]CB009576-SR-X_BTS_block_unblock _sucess_ratio
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    CB009576-SR-X_BTS_block_unblock _sucess_ratio
    [Teardown]    SISO Coam Test Teardown
[1]CB009576-SR-X_RU_Reset_sucess_ratio
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup 
    CB009576-SR-X_RU_Reset_sucess_ratio
    [Teardown]    SISO Coam Test Teardown
[1]CB009576-SR-X_Cell_block_unblock_sucess_ratio
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup 
    CB009576-SR-X_Cell_block_unblock_sucess_ratio
    [Teardown]    SISO Coam Test Teardown
[1]CB009576-SR-X_KPI1a_Site_Reset_duration
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup 
    CB009576-SR-X_KPI1a_Site_Reset_duration
    [Teardown]    SISO Coam Test Teardown
[1]CB009576-SR-X_KPI9_10_RAT_Reset_duration
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup 
    CB009576-SR-X_KPI9_10_RAT_Reset_duration
    [Teardown]    SISO Coam Test Teardown
[1]CB009576-SR-X_KPI3_Power_On_Reset_duration
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup 
    CB009576-SR-X_KPI3_Power_On_Reset_duration
    [Teardown]    SISO Coam Test Teardown
[1]CB009576-SR-X_KPI4_Software_Upgrade_duration
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup 
    CB009576-SR-X_KPI4_Software_Upgrade_duration
    [Teardown]    SISO Coam Test Teardown
[1]CB009576-SR-X_KPI2c_d_Software_Activation_duration
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup 
    CB009576-SR-X_KPI2c_d_Software_Upgrade_duration
    [Teardown]    SISO Coam Test Teardown
[1]CB009576-SR-J_FDSW_service_buttom_reset
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup 
    CB009576-SR--J_FDSW_service_buttom_reset
    [Teardown]    SISO Coam Test Teardown


