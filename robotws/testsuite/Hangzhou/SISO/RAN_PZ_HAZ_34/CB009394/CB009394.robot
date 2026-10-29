*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Test Timeout         3h

Resource    ./resource/CB009394_Common_KW.robot
Variables    ./resource/variables.py

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...    Feature CB009394 in SBTS23R4 program with mixed AWHQV 2CC(9394-B) and AWHTA 2CC(9394-D)

Force Tags            RAN_5G_TDD    RAN_5G

*** Variables ***
@{band}    70M    30M

*** Test Cases ***
#Config: AWHQV (1S-2CC-4D4U_20-20M); AWHTA (2S-2CC-4D4U_50-50M)
[1]CB009394-SR-B-08_2CC_cell_block_unblock
    [Tags]    CRT_TRUNK
    ${cell_list}    create list    ${1}  ${2}  ${5}  ${6}
    ${band_list}    create list    ${20}  ${20}  ${50}  ${50}
    Modify bandwidth for multi cells   ${cell_list}   ${band_list}
    General_SiSo_Cell_block_and_unblock   with_call=${False}

[1]CB009394-SR-B-03_2CC_4DL_256QAM_4UL_64QAM_50MHz_30Mhz_with_L3Call_mcs27
    [Tags]    CRT_TRUNK
    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
#    Commission SCF With Specific Band If Needed    band=${band}
#    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
#    ${bandlist}    create list    ${50}    ${30}
#    General_SiSo_E2E_system_setup_with_data_transfer_multi_cc_with_different_bandwith    bandlist=${bandlist}    cell_id=1
#    ...    prach_index=98    iperf_type=via_command    enable_2197=${False}
    ${cell_list}    create list    ${1}  ${2}  ${6}
    ${band_list}    create list    ${50}  ${30}  ${50}
    Modify bandwidth for multi cells   ${cell_list}   ${band_list}
    ${cell_list}    create list    ${1}
    Get UE From Init File and Make call    cell_list=${cell_list}  with_peak=${False}
#[1]CB009394-SR-B-06_2CC_4DL_256QAM_4UL_256QAM_30MHz_20Mhz_with_L3Call_mcs27
#[1]CB009394-SR-B-05_2CC_4DL_256QAM_4UL_256QAM_40MHz_20Mhz_with_L3Call_mcs27
#[1]CB009394-SR-B-04_2CC_4DL_256QAM_4UL_64QAM_40MHz_30Mhz_with_L3Call_mcs27
#[1]CB009394-SR-B-02_2CC_4DL_256QAM_4UL_64QAM_60MHz_30Mhz_with_L3Call_mcs27
#Config: AWHQV (1S-2CC-4D4U_40-20M); AWHTA (2S-2CC-4D4U_100-100M)
[1]CB009394-SR-D-08_2CC_cell_lock_unlock
    [Tags]    CRT_TRUNK
    ${cell_list}    create list    ${1}  ${2}  ${5}  ${6}
    ${band_list}    create list    ${40}  ${20}  ${100}  ${100}
    Modify bandwidth for multi cells   ${cell_list}   ${band_list}
    General_SiSo_Cell_lock_and_unlock   with_call=${False}

[1]CB009394-SR-D-04_2CC_4DL_256QAM_4UL_64QAM_100MHz_40Mhz_with_L3Call_mcs27
    [Tags]    CRT_TRUNK
    ${cell_list}    create list    ${6}
    ${band_list}    create list    ${40}
    Modify bandwidth for multi cells   ${cell_list}   ${band_list}
    ${cell_list}    create list    ${1}
    Get UE From Init File and Make call    cell_list=${cell_list}  with_peak=${False}
