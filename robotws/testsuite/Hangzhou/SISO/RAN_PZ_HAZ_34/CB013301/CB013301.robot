*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
Test Timeout         2h

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource      ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource      ${BASIC_PATH_5G}/BTS/Manual_SiSo_SM_NR_RAT_reset.robot

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...
...    Feature CB013301: TDD additional eCPRI config for 26R1 in SBTS26R1 program
...    This feature supports ABIP/Q+ ABIO configuration block for TDD mMIMO LTE/NR up to 5 carriers.
...
...    Config to be regression:
...    3S- 5cc (3cc NR 8DL4UL layers/8DL8UL streams+2cc LTE 8DL4UL layers/8DL8UL streams) with 2x ABIQ+ 1xABIO.
...    Each radio with up to 4*25GE (or 1*50GE+ 2*25GE). Valid radio: Habrok.
...
...    Or the 5cc is built on with 1x ABIP + 1xABIO, NR 8Rx IRC.
...    Each radio with up to 3*25GE (or 1*50GE+ 1*25GE). Valid radio: Habrok.

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY310    master_classicalbts_all


*** Test Cases ***
[1]CB013301_SR_A1_04_configuration_with_3S_3cc_NR_16DL8UL_And_2cc_LTE_8DL8UL_Mmimo_radios_on_ABIP_And_ABIO_RAT_reset
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    Manual_SiSo_SM_NR_RAT_reset    bbmod_index=${2}    with_call=${False}
    [Teardown]    SISO Coam Test Teardown

    # [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    # ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    # ...    AND    SISO Coam Test Teardown
