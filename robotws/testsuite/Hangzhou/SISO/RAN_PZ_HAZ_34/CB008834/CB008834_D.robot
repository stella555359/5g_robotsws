*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Test Timeout         4h

Resource    ./resource/CB008834_Common_KW.robot

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...    Feature CB008334 in SBTS23R4 program

Force Tags            RAN_5G_TDD    RAN_5G

*** Variables ***

*** Test Cases ***
[1]CB008834-D-23R3_N_CB008834_5_01_General_SiSo_Commissioning_BTS_Template_Commissioning
    [Tags]    SBTS00
    General_SiSo_Commissioning_BTS_Template_Commissioning

[1]CB008834-D-23R3_N_CB008834_5_02_General_SiSo_Cell_block_and_unblock
    [Tags]    SBTS00
    General_SiSo_Cell_block_and_unblock    with_call=${False}
[1]CB008834-D-23R3_N_CB008834_5_03_Manual_SiSo_SM_BTS_Site_Reset
    [Tags]    SBTS00
    General_SiSo_Auto_BTS_site_reset    with_call=${False}

[1]CB008834-D-23R3_N_CB008834_5_04_General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    [Tags]    SBTS00
    ${bandlist}    create list    ${100}
    General_SiSo_E2E_system_setup_with_data_transfer_multi_cc_with_different_bandwith    bandlist=${bandlist}
    ...    ue_num_each_call=1    4G_check=${False}

[1]CB008834-D-23R3_N_CB008834_5_05_Common_SiSo_single_UE_peak_tput_verification
    [Tags]    SBTS00
    ${cell_list}    create list    ${1}
    Get UE From Init File and Make call    cell_list=${cell_list}  with_peak=${True}


*** Keywords ***
