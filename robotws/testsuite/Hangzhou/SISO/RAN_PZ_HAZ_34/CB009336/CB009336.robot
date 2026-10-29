*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Test Timeout         1h

Resource    ./resource/CB009336_Common_KW.robot

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...    Feature CB009336 in SBTS23R3 program

Force Tags            RAN_5G_TDD    RAN_5G

*** Variables ***

*** Test Cases ***
[1]CB009336_5G_B1_Configuration_for_TDD_CPRI_FR1_NR+LTE_on_ASIB+ABIO_concurrent_mode_General_SiSo_RF_Lock_Unlock
    [Tags]    SBTS00    1S-2CC-NR70-LTE20
    Set Test Variable   ${gNb_CuType}   SA
    E2E_SiSo_RU_lock_and_unlock_gNB    with_call=${True}

[1]CB009336_A2_AWHHF_70Mhz_4DL_256QAM_4UL_64QAM_with_L3Call_Peak_5GC001116_3ms
    [Tags]    SBTS00    1S-2CC-NR70-NR70
    ${cell_list}    create list    ${1}
    Get UE From Init File and Make call    cell_list=${cell_list}   with_peak=${True}    duration=${300}

[1]CB009336_A2_Common_SiSo_State Management_Cell block & unblock
    [Tags]    SBTS00    1S-2CC-NR70-NR70
    Common_SiSo_State_Management_Cell_block_unblock    with_call=${True}

*** Keywords ***
