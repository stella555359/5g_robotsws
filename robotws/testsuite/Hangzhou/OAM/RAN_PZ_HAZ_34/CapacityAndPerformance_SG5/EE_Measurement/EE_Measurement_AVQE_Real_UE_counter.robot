*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Timeout         5h

Resource    ./Resource/CB012662_Common_KW.robot

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...    Feature CB012662 in SBTS25R1 program

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY39    master_classicalbts_all

*** Variables ***

*** Test Cases ***
RU energy consumption counters based on RF load with UE
    [Tags]     CRT_TRUNK
    [Setup]    run keywords   SISO Coam Test Setup    AND    TestSuilt.Start
    RU energy consumption counters based on RF load with UE   ru_index=${2}
    [Teardown]    SISO Coam Test Teardown

*** Keywords ***
