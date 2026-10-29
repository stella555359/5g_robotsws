*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Timeout         180 min

Resource    ../CapacityAndPerformance_SG5/CB008681_ASIL/Resources/OMKPI_KW_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB006277/CB006277-PhaseE/Resources/CB006277_common_keywords.robot
Resource    Resources/CB012702_common_keyword.robot

Documentation
...    Author: Shi Jeffrey
...    Contact: jeffrey.shi@nokia-sbell.com
...    squad group:SG_05
...    Feature CB0012702

Force Tags    RAN_5G_TDD

*** Test Cases ***
[1]CB012702-SR-01_SiteReset_KPI#1a_with_and_without_feature_enabled_SingleABIO_faulty
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    Set_flag_for_BBMOD_faulty
    OAM_KPI_1a_Site_Reset_with_faulty_BBMOD    with_graceful=false
    Check_Alarm_Expected
   [Teardown]    Run keywords    Clear_flag_for_BBMOD_faulty    AND
   ...    Reset_gNB_after_clear_flag    AND
   ...    Save Coam Snapshot    timeout=${1800}    AND
   ...    SISO Coam Test Teardown