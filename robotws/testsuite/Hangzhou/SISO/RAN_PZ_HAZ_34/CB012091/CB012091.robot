*** Settings ***
Suite Setup          Run keywords    SISO Coam Suite Setup    AND    get all nr cells id    AND
...    get all nr cells id except cell1
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown

Resource    Resource/CB012091_Common_KW.robot

Documentation
...    Author: Lin jiangjing
...    Contact: jiangjing.lin@nokia-sbell.com
...    squad group:SG_08

Force Tags    RAN_5G_TDD    RAN_5G    SBTS00    STATE_SW_UPLOADED

*** Test Cases ***
[1]CB012091-SR-A_07 RU returning from PowerSaving Mode to normal operation due to at least one carrier enabling on RU triggered by 5GC000431
    [Tags]    CIT_TRUNK
    RU returning from PowerSaving Mode to normal operation due to at least one carrier enabling on RU triggered by 5GC000431

#[1]CB012091-SR-A_09 RU returning from PowerSaving Mode to normal operation due to RU lock
#    RU returning from PowerSaving Mode to normal operation due to RU lock

[1]CB012091-SR-A_14 RU Recovery during extreme deep sleep mode due to RU restart
    [Tags]    CIT_TRUNK
    RU Recovery during extreme deep sleep mode due to RU restart

[1]CB012091-SR-A_10 RU returning from PowerSaving Mode to normal operation due to change of EnergySavingMode
    [Tags]    CIT_TRUNK
    RU returning from PowerSaving Mode to normal operation due to change of EnergySavingMode

[1]CB012091-SR-A_13 RU returning from PowerSaving Mode to normal operation due to time window ends
    RU returning from PowerSaving Mode to normal operation due to time window ends

[1]CB012091-SR-A_24 Extreme Deep Sleep Mode temperature threshold impact
    Extreme Deep Sleep Mode temperature threshold impact

[1]CB012091-SR-A_05 RU entering extreme deep sleep mode after all cells blocked
    RU entering extreme deep sleep mode after all cells blocked
