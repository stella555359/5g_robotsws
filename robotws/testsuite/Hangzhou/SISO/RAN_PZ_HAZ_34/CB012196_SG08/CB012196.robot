*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_SISO_operation.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    Resources/CB012196_common_keywords.robot


Documentation
...    Author:zhenzhen ren
...    contact:zhenzhen.ren@nokia-sbell.com
...    squad group:SG_08
...    Feature CB012196-B in 25R1

Force Tags            RAN_5G_TDD    5G_RAN_TDD    RAN_5G    5G_RAN    CRT_UTE    STATE_SW_UPLOADED    SBTS00
...    PY36





*** Test Cases ***
Config1_General_SiSo_BB_sub_unit_lock_unlock_with_L3_call
    [Tags]    CRT_24R3   CRT_TRUNK
    Commissioning SCF And Check BTS On Air    scf_name=config1
    Config1_General_SiSo_BB_sub_unit_lock_unlock_with_L3_call

Config2_General_SiSo_Online_Cell_Addition_Deletion
    [Tags]    CRT_24R3   CRT_TRUNK
    Commissioning SCF And Check BTS On Air    scf_name=config2
    Config2_General_SiSo_Online_Cell_Addition_Deletion

Config4_General_SiSo_RU_lock_unlock
    [Tags]    CRT_24R3   CRT_TRUNK
    Commissioning SCF And Check BTS On Air    scf_name=config4
    Config4_General_SiSo_RU_lock_unlock

Config4_General_SiSo_Cell_block_and_unblock
    [Tags]    CRT_24R3   CRT_TRUNK
    AlarmWatchdog.add_allow_alarms    fault_id=49
    Commissioning SCF And Check BTS On Air    scf_name=config4
    Config4_General_SiSo_Cell_block_and_unblock

Config4_General_SiSo_E2E_system_setup_with_data_transfer_conducted
    [Tags]    CRT_24R3   CRT_TRUNK
    Commissioning SCF And Check BTS On Air    scf_name=config4
    Config4_General_SiSo_E2E_system_setup_with_data_transfer_conducted

Config5_General_SiSo_RU_lock_unlock
    [Tags]    CRT_24R3   CRT_TRUNK
    Commissioning SCF And Check BTS On Air    scf_name=config5
    Config5_General_SiSo_RU_lock_unlock

Config5_General_SiSo_Cell_block_and_unblock
    [Tags]    CRT_24R3   CRT_TRUNK
    AlarmWatchdog.add_allow_alarms    fault_id=49
    Commissioning SCF And Check BTS On Air    scf_name=config5
    Config5_General_SiSo_Cell_block_and_unblock

Config5_General_SiSo_BB_sub_unit_reset_with_L3_call
    [Tags]    CRT_24R3   CRT_TRUNK
    Commissioning SCF And Check BTS On Air    scf_name=config5
    Config5_General_SiSo_BB_sub_unit_reset_with_L3_call


Config5_General_SiSo_E2E_system_setup_with_data_transfer_conducted
    [Tags]    CRT_24R3   CRT_TRUNK
    Commissioning SCF And Check BTS On Air    scf_name=config5
    Config5_General_SiSo_E2E_system_setup_with_data_transfer_conducted

Config5_Manual_SiSo_SM_NR_RAT_reset
    [Tags]    CRT_24R3   CRT_TRUNK
    Commissioning SCF And Check BTS On Air    scf_name=config5
    Config5_Manual_SiSo_SM_NR_RAT_reset


Config5_new_case_for_cell_switching_off
    [Tags]    CRT_24R3   CRT_TRUNK
    Commissioning SCF And Check BTS On Air    scf_name=EnergySaving
    Config5_new_case_for_cell_switching_off

Config5_Manual_SiSo_SM_BTS_Block_Site
    [Tags]    CRT_24R3   CRT_TRUNK
    AlarmWatchdog.add_allow_alarms    fault_id=50
    Commissioning SCF And Check BTS On Air    scf_name=config5
    Config5_Manual_SiSo_SM_BTS_Block_Site

Config5_OAM_KPI_61a_SiSo_Auto_BTS_site_reset
    [Tags]    CRT_24R3   CRT_TRUNK
    Commissioning SCF And Check BTS On Air    scf_name=config5
    E2E_TL_Activation_Reset_with_OAM_KPI_SG08
#    Config5_OAM_KPI_61a_SiSo_Auto_BTS_site_reset

