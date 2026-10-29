*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown

Test Timeout         3h

Resource      ../CB011159/resource/CB011159_Common_KW.robot
# Resource      testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB006277/resource/resources_l3call.robot
# Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/ue.robot
# Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot


Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...    Feature CB011159-CA RF sharing in SBTS25R1 program

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY39    master_classicalbts_all

*** Variables ***

*** Test Cases ***
[1]CB010971_SR_B_8_2CC_4D4U_Verify_Tput_With_50+50_mMIMO
    [Tags]    1S-2CC-4D4U   CRT_TRUNK
    [Setup]   SISO Coam Test Setup
    Step1: Enable CB008322 feature flag     ru_index=${2}    chbw=50MHz
    Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=nr
    # Step2: Verify Uplink or Downlink Tput can reach expected result
    [Teardown]    SISO Coam Test Teardown


*** Keywords ***
