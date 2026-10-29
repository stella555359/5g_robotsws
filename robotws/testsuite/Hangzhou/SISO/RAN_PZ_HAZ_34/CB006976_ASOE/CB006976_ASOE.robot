*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot

Variables   TestData/variables.py

Documentation
...    Author:shasha.liu
...    contact:shasha.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CB006976 in 22R1 program
...    Configuration: A5G-TD-3S-2CC-8DL-4UL-FR1-eCPRI-CB006976-A1 with BF MAA OBW 150Mhz/200Mhz

Force Tags      5G_RAN_TDD
...    PY36

*** Variables ***
${MAX_LOOP}    2

*** Test Cases ***
[1]General_SiSo_Cell_lock_and_unlock
    [Tags]   CRT_22R1   CRT_22R3   CRT_TRUNK
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    ${stream}    get stream from version    ${Active_SW_version}
    ${QC_ID}    Set Variable if    '${stream}'=='SBTS23R1'    QC_431982
    ...                            '${stream}'=='SBTS23R2'    QC_496330
    ...                            '${stream}'=='SBTS00'      QC_172672
    Set Tags    ${QC_ID}
    General_SiSo_Cell_lock_and_unlock    with_call=${False}

[1]General_SiSo_RU_lock_unlock
    [Tags]   CRT_22R1   CRT_TRUNK
    General_SiSo_RU_lock_unlock    with_call=${False}

#[1][1.0] General_SiSo_E2E_system_setup_with_data_transfer_conducted
#    General_SiSo_E2E_system_setup_with_data_transfer    band=50
#
#[1][1.0] General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#
#[1][1.0] General_SiSo_Commissioning_BTS_Template_Commissioning
#    General_SiSo_Commissioning_BTS_Template_Commissioning
#
#[1][1.0] General_SiSo_RF_module_power_reset
#    General_SiSo_RF_module_power_reset
#
#[1][2.0] General_SiSo_Automatic_RAT_SW_upgrade
#    General_SiSo_Auto_Automatic_RAT_SW_upgrade
#
#[1][2.0] General_SiSo_RF_alarms_with_recovery
#    General_SiSo_RF_alarms_with_recovery
#
#[1][2.0] General_SiSo_RU_module_reset_from_GUI
#    General_SiSo_RF_module_reset_from_GUI
#
#[1]OAM_KPI_61a_SiSo_Auto_BTS_site_reset
#    OAM_KPI_61a_SiSo_Auto_BTS_site_reset

*** Keywords ***
