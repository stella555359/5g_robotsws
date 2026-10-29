*** Settings ***
Suite Setup          CBRS Suite Setup
Suite Teardown       CBRS Suite Teardown
Test Setup           CBRS Test Setup    actCbrsEnhMeas=${True}
Test Teardown        CBRS Test Teardown    actCbrsEnhMeas=${True}

Resource    resources/CB008498_common_keywords.robot

Documentation
...    Author:wangqingqing
...    contact:qingqing.wang@nokia-sbell.com
...    squad group:SG_08
...    Feature CB008498

Force Tags    SBTS00    CRT_22R3    CRT_22R4    CRT_23R1
...    PY36

*** Variables ***

*** Test Cases ***
[1]CB008498_6_De-activation of NR CBRS for AZQC
    [Tags]    CRT_TRUNK
    Verify_the_CBRS_online_de-activation_is_successful

[1]CB008498_7_two_cell_different_priority_only_20MHz_available
    [Tags]    CRT_TRUNK
    CB008498_7_two_cell_different_priority_only_20MHz_available

[1]CB008498_9_Online_change_CBSD_parameter
    [Tags]    CIT_TRUNK
    CB008498_9_Online_change_CBSD_parameter

[1]CB008498_12_Online_change_cell_priority_higher_than_onair_one
    [Tags]    CRT_TRUNK
    CB008498_12_Online_change_cell_priority_higher_than_onair_one

[1]CB008498_14_config_PAL_grant_PAL+GAA
    [Tags]    CRT_TRUNK
    CB008498_14_config_PAL_grant_PAL+GAA

[1]CB008498_16_cell1_pmax+cell2_pmax_bigger_than_37
    [Tags]    CRT_TRUNK
    CB008498_16_HW_validation_for_desirepmax_of_two_cell

[1][2.0] General_SiSo_Auto_E2E_system_setup_with_data_transfer_conducted
    [Tags]    CRT_TRUNK
    General_SiSo_Auto_E2E_system_setup_with_data_transfer_conducted_2CC_AZQC

[1][1.0] General_SiSo_RU_lock_unlock
    [Tags]    CRT_TRUNK
    CB008468_General_SiSo_RU_lock_unlock_AZQC

[1][1.0] General_SiSo_Cell_block_and_unblock
    [Tags]    CRT_TRUNK
    CB008468_General_SiSo_Cell_block_and_unblock_2CC_AZQC

[1]CB008498_20_General_SiSo_delete_one_CBRS_cell
    [Tags]    CRT_TRUNK
    CB008498_20_General_SiSo_delete_one_CBRS_cell

[1]CB008498_19_General_SiSo_online_add_one_higher_priority_CBRS_cell_20MHz_available
    [Tags]    CRT_TRUNK
    CB008498_19_General_SiSo_online_add_one_higher_priority_CBRS_cell_20MHz_available

[1]CB008498_21_continue_channel_CA_channelSpace2020_is_20MHz
    [Tags]    CRT_TRUNK
    CB008498_21_continue_channel_CA_channelSpace2020_is_20MHz

[1]CB008498_27_continue_channel_CA_enable_channelSpace2020_change_to_19.2MHz
    [Tags]    CRT_TRUNK
    CB008498_27_continue_channel_CA_enable_channelSpace2020_change_to_19.2MHz

[1]CB008498_30_contiguous_CA_have_higher_priority
    [Tags]    CRT_TRUNK
    CB008498_30_contiguous_CA_have_higher_priority

[1]CB009154-A_FCE_Heartbeatresponse_500_featureCapabilityExchangeresponse_102
    [Tags]    CRT_TRUNK
    CB009154-A_FCE_Heartbeatresponse_500_featureCapabilityExchangeresponse_102_MP

[1]CB009154-C_9_CBSD_behavior_check_when_BBMOD_reset
    [Tags]    CRT_TRUNK
    CB009154-C_9_CBSD_behavior_check_when_BBMOD_reset_MP

*** Keywords ***
