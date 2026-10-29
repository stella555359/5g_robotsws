*** Settings ***
Suite Setup           Run Keywords     SISO Coam Suite Setup
...                   AND     Case Preparation
Suite Teardown        SISO Coam Suite Teardown
Test Setup            SISO Coam Test Setup
Test Teardown         SISO Coam Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    Resources/5GC002637_common_keywords.robot

Documentation
...    author: Qingqing Wang
...    contact: qingqing.1.wang@nokia-sbell.com
...    squad group: SG_08
...    feature : 5GC002637-A

Force Tags            RAN_5G_TDD    5G_RAN_TDD    master_classicalbts_all    RAN_5G    5G_RAN    STATE_SW_UPLOADED
...    PY36
...    21A_classicalbts    SBTS21B    SBTS00    CLOUD_5G_CLASSICAL_ANDROID_ASIKL_ABILB1_AAHF    SBTS22R1    CRT_22R4
...    CRT_23R1

*** Variables ***

*** Test Cases ***
[1]5GC002637-A_05_MAC_Throughput_Counter__Activate_Deactivate_via_WebEM
    [Tags]    CDRT_TRUNK    CRT_22R1    CRT_22R2    CRT_22R3    CRT_TRUNK
	MAC_Throughput_Counter__Activate_Deactivate_via_WebEM    interval=15min

[1]5GC002637-A_02_Throughput_Counter_Feature_Deactivate_via_WebUI
    [Tags]    CDRT_TRUNK    CRT_22R1    CRT_22R2    CRT_22R3    CRT_TRUNK
	Throughput_Counter_Deactivate_via_WebUI    interval=15min

[1]5GC002637-A_01_Throughput_Counter_Feature_Activate_via_WebUI
    [Tags]    CDRT_TRUNK    CRT_22R1    CRT_22R2    CRT_22R3    CRT_TRUNK
	Throughput_Counter_Activate_via_WebUI    interval=15min

[1]5GC002637-A_40_KPI_5100C_monitor
    [Tags]    CRT_22R1    CRT_22R2    CRT_22R3    CRT_TRUNK
	5GC002637-A_40_KPI_5100C_monitor    interval=15min