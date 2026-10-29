*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Timeout         2h

Resource    ./Resource/CB009074_Common_KW.robot

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...    Feature CB009077 in SBTS24R3 program

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY310    master_classicalbts_all

*** Test Cases ***
[1]CB009074-A_01_AEQV_NIDD parameter and feature activate_RF scan test in online mode
    [Tags]    CRT_25R1    CRT_25R2    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    Set RF to Split Mode   ru_type=32TRX
    All_RF_scan_test_with_Split_mode_in_online_mode   antenna_panel=PHYANT-1 Top Array

    Set RF to Full Mode   ru_type=32TRX
    All_RF_scan_test_with_full_mode_in_online_mode
    [Teardown]    SISO Coam Test Teardown
