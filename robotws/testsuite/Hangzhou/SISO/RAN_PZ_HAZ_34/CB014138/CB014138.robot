*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
Test Timeout         2h

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource      ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource      testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB014138/Resource/CB014138_Common_KW.robot

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...
...    Feature CB014138: Extreme Deep sleep feature support for Habrok Radios with ASOG ASOH in SBTS26R1 program
...    With this feature ASOG ASOH can be used with Habrok Radios to support extreme deep sleep mode feature.

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY310    master_classicalbts_all


*** Test Cases ***
[1]CB014138-A-003_RU returning from EDSM to normal operation
    [Tags]    3S-4CC_CB015690-AVQO    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    #WA to avoid RU does not enter EDSM due to reset in 2 hours, can be ignored if case tag of SCF used.
    Log to console    \nreset bts before test EDSM
    Perform BTS Site Reset
    sleep    300s
    Wait until keyword succeeds    10 min    60 sec   verify all cells should be onair
    RU_returning_from_SLEEP_EXTREME_to_normal_operation_due_to_change_of_EnergySavingMode
    [Teardown]    SISO Coam Test Teardown
    # [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    # ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    # ...    AND    SISO Coam Test Teardown