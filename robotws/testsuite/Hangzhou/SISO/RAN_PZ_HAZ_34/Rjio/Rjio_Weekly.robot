*** Settings ***
#Suite Setup          Run Keywords    RJIO Suite Setup    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
Suite Setup          RJIO Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        RJIO Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ./Resources/Rjio_keywords.robot


Documentation
...    Author: Melinda
...    Contact: meinda.gao@nokia-sbell.com
...    squad group:SG_08
...    E2E Rjio

Force Tags    PY36


*** Variables ***
@{cell_id63}    ${63}
@{multe_ue_list}    2   3

${CRT_flag}    ${True}
*** Test Cases ***
[1]Rjio_E2E_05_Radio_Lock_Unlock
    reboot_ue_except_askey_and_cpe
    FOR   ${index}   IN RANGE   0    5
        RU_lock_unlock_execute    CRT_flag=${CRT_flag}
    END

[1]Rjio_E2E_06_Cell_Block_Unblock
    reboot_ue_except_askey_and_cpe
    FOR   ${index}   IN RANGE   0    5
        cell_block_unblock_execute    CRT_flag=${CRT_flag}
    END

[1]Rjio_E2E_23_PTP_Failure_Between_SM_And_RM_Reference
    reboot_ue_except_askey_and_cpe
    FOR   ${index}   IN RANGE   0    5
        PTP failure between SM and RM reference    CRT_flag=${CRT_flag}
    END

#[1]Rjio_E2E_69_RU_Entering_Deep_Sleep_Mode_During_Low_Traffic_Periods_IWK_5GC000431_CB009925
#    Rjio_E2E_69_RU_Entering_Deep_Sleep_Mode_During_Low_Traffic_Periods_IWK_5GC000431_CB009925

#[1]Rjio_E2E_70_RU_Exiting_Deep_Sleep_Mode_Due_to_at_least_one_carrier_enabling_on_RU_IWK_5GC000431_CB009925
#    Rjio_E2E_70_RU_Exiting_Deep_Sleep_Mode_Due_to_at_least_one_carrier_enabling_on_RU_IWK_5GC000431_CB009925    CRT_flag=${CRT_flag}

[1]Rjio_E2E_71_HO_Between_CA_And_TDD_With_BWP_Test​
    Rjio_E2E_71_HO_Between_CA_And_TDD_With_BWP_Test

[1]Rjio_E2E_73_BWP_Test​_At_Cell_Edge
    Rjio_E2E_73_BWP_Test​_At_Cell_Edge

[1]Rjio_E2E_24_Site_Reset_With_L3_Call
    reboot_ue_except_askey_and_cpe
    FOR   ${index}   IN RANGE   0    5
        Site_reset_with_call    CRT_flag=${CRT_flag}
    END

[1]Rjio_E2E_38_SRS-Based_Mu-Mimo_Upto_8_Layers
    Rjio_E2E_38_SRS-Based_Mu-Mimo_Upto_8_Layers    ue_index_list=${multe_ue_list}

[1]Rjio_E2E_75_RAT_reset
    alarm_1907_check_by_rat_reset

[1]Rjio_E2E_69_RU_Entering_And_Existing_Deep_Sleep_Mode_By_Cell_Block_and_Unblock
    Rjio_E2E_69_RU_Entering_And_Existing_Deep_Sleep_Mode_By_Cell_Block_and_Unblock

[1]Rjio_E2E_70_Mixed_Power_Saving_Check
    Rjio_E2E_70_Mixed_Power_Saving_Check

[1]Rjio_E2E_13_SW_Upgrade_Netact
    NetAct_SW_Upgrade_and_rollback

#[1]Rjio_E2E_03_Power_Reset_Rf
#    FOR   ${index}   IN RANGE   0    20
#        General_SiSo_RF_module_power_reset
#    END

#[1]Rjio_E2E_20_Continuous_Snapshot_Fetching.
#    FOR   ${index}   IN RANGE   0    20
#        ${snapshot_zip_file_full}    Save Full Snapshot
#        check_unexpected_alarms
#    END

#[1]Rjio_E2E_63_Mobility_UE_based_ANR-34
#    Rjio_E2E_63_Mobility_UE_based_ANR_for_NR_Neighbor

*** Keywords ***
