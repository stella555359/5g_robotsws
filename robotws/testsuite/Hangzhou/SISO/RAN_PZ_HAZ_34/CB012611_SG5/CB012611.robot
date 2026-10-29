*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown

Test Timeout         3h

Resource      Resource/CB012611_Common_KW.robot


Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...    Feature CB012611 This Feature allows to use ABIO board where one SoC is not available/damaged

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY39    master_classicalbts_all

*** Test Cases ***
[1]CB012611_5G_B_04_ABIO_reset_with_single_failed_Loki
    [Tags]    CRT_TRUNK
    [Setup]   SISO Coam Test Setup
    ABIO reset with single failed Loki  bbmod_index=${1}
    [Teardown]    SISO Coam Test Teardown
