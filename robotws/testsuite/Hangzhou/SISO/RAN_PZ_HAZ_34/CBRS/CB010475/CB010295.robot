*** Settings ***
Suite Setup          CB010295 LTE TL CBRS Suite Setup
Suite Teardown       CBRS Suite Teardown
Test Setup           Run keywords    LTE TL CBRS Test Setup    AND    AlarmWatchdog.add_allow_alarms    fault_id=6832  
Test Teardown        LTE TL CBRS Test Teardown


Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CBRS/CB010475/Resources/CB010295_common_keywords.robot

Documentation
...    Author:renzhenzhen
...    contact:zhenzhen.ren@nokia-sbell.com
...    squad group:SG_08
...    Feature CB010295_LTE_only

Force Tags            RAN_5G_TDD    5G_RAN_TDD    master_classicalbts_all    RAN_5G    5G_RAN    STATE_SW_UPLOADED
...    PY36


*** Variables ***


*** Test Cases ***
[1]01_General_SiSo_Online_Commissioning_From_Frame_1_7_To_0_6
    [Tags]    CRT_TRUNK    CRT_23R4
    CB010295 Start SAS server for LTE only
    CB010295_General_SiSo_Online_Commissioning_From_Frame_1_7_To_0_6

[1]12_General_SiSo_RU_lock_and_unlock
    [Tags]    CRT_TRUNK    CRT_23R4
    CB010295 Start SAS server for LTE only
    CB010295_General_SiSo_RU_lock_and_unlock

[1]11_General_SiSo_Cell_block_and_unblock_with_L3call
    [Tags]    CRT_TRUNK    CRT_23R4
    AlarmWatchdog.add_allow_alarms    fault_id=49
    CB010295 Start SAS server for LTE only
    CB010295_General_SiSo_Cell_block_and_unblock_with_L3call

