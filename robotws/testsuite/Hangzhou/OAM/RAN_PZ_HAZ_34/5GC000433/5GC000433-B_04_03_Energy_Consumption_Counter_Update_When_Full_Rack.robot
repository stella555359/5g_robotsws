*** Settings ***
Suite Setup           Run Keywords     SISO Coam Suite Setup
...                   AND     Case Preparation
Suite Teardown        SISO Coam Suite Teardown
Test Setup            SISO Coam Test Setup
Test Teardown         SISO Coam Test Teardown
Test Timeout          200 min

Resource      Resource/5GC000433_common_KW.robot
#Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC000433-A/Resources/5GC000433_common_keywords.robot


Documentation
...    Author: Annie hu
...    Contact: Annie.hu@nokia-sbell.com
...    squad group:SG_05
...    Feature 5GC000443-B in 5G21A program

Force Tags            5G_RAN_TDD
...    PY36

*** Variables ***

*** Test Cases ***
[1]5GC000433-B_04_03_Energy_Consumption_Counter_Update_When_Full_Rack
    [Tags]     CDRT_21B    CRT_22R1    CDRT_TRUNK   CRT_22R2
     wait until keyword succeeds    5x   2s    Check Energy_Measurement_Counter M40002C    interval=15min  
     wait until keyword succeeds    5x   2s    Check Energy_Measurement_Counter M40003C    interval=15min
     wait until keyword succeeds    5x   2s    Check Energy_Measurement_Counter M40004C    interval=15min


*** Keywords ***
