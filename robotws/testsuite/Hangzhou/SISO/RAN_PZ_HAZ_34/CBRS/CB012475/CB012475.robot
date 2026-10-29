*** Settings ***
Suite Setup          CBRS Suite Setup
Suite Teardown       CBRS Suite Teardown
Test Setup           Run keywords    CBRS Test Setup    AND    AlarmWatchdog.add_allow_alarms    fault_id=4681
Test Teardown        Run keywords    AlarmWatchdog.remove_allow_alarms    fault_id=4681     AND     CBRS Test Teardown


Resource    resources/CB012475_common_keywords.robot

Documentation
...    Author:wangqingqing
...    contact:qingqing.wang@nokia-sbell.com
...    squad group:SG_08
...    Feature CB012475

Force Tags    SBTS00
...    PY36

*** Variables ***

*** Test Cases ***
[1][1.0]CB012475-A_22_Supercell_CBRS_disable_enable_TS2.0
    [Tags]    CRT_TRUNK
    CB012475-A_22_Supercell_CBRS_disable_enable_TS2.0

[1][1.0]CB012475-A_9_General_SiSo_E2E_system_setup_with_data_transfer_conducted_2-3_2CC
    [Tags]    CRT_TRUNK
    CB012475-A_9_General_SiSo_E2E_system_setup_with_data_transfer_conducted_2-3_2CC

[1]CB012475-B_39_SISO_supercell_setup_with_degradation_RU_reset_2-3
    [Tags]    CRT_TRUNK
    CB012475-B_39_SISO_supercell_setup_with_degradation_RU_reset_2-3

[1]CB012475-B_31_SISO_supercell_setup_with_degradation_two_subcells_not get_grant_1-3
    [Tags]    CRT_TRUNK
    CB012475-B_31_SISO_supercell_setup_with_degradation_two_subcells_not get_grant_1-3

[1]CB012475-B_28_supercell_degraded startup_one_CBSD_HB_failure
    [Tags]    CRT_TRUNK
    CB012475-B_28_supercell_degraded startup_one_CBSD_HB_failure

[1]CB012475-B_32_SISO_supercell_setup_with_degradation_1-3_PAL_second_grant_bring_up_more_subcells
    [Tags]    CRT_TRUNK
    CB012475-B_32_SISO_supercell_setup_with_degradation_1-3_PAL_second_grant_bring_up_more_subcells

[1]CB012475-B_41_Supercell becomes degraded in runtime_grant_suspend_second_grant_used
    [Tags]    CRT_TRUNK
    CB012475-B_41_Supercell becomes degraded in runtime_grant_suspend_second_grant_used
    
[1]CB012475-B_42_Supercell becomes degraded in runtime_grant_terminated_second_grant_not_used
    [Tags]    CRT_TRUNK
    CB012475-B_42_Supercell becomes degraded in runtime_grant_terminated_second_grant_not_used



[1]CB012475-B_45_Supercell_Online_Change_Parameters_desiredPmax_maxGrantPwrRed
    [Tags]    CRT_TRUNK
    CB012475-B_45_Supercell_Online_Change_Parameters_desiredPmax_maxGrantPwrRed

[1]CB012475-B_40_SISO_supercell_setup_with_degradation_supercell_block_unblock_mix_normal_CBRS_cell
    [Tags]    CRT_TRUNK
    CB012475-B_40_SISO_supercell_setup_with_degradation_supercell_block_unblock_mix_normal_CBRS_cell

10564_BB_reset
    10564_BB_reset

10564_RU_reset
    10564_RU_reset


12475_load_scf
    12475_load_scf


*** Keywords ***
