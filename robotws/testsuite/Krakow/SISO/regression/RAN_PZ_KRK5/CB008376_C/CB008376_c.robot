*** Settings ***
Documentation
...   Test suite for regression testing of feature CB008376_C
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Resource     taf/rfrl/procedures/SISO/General_SiSo_Cell_block_and_unblock.robot
Resource     taf/rfrl/procedures/SISO/General_SiSo_Auto_RF_lock_unlock.robot
#Resource     taf/rfrl/procedures/SISO/General_SiSo_HWPTA_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot.robot
Resource     taf/rfrl/bts/robot/gnb.robot
Resource     ./resources/common_keywords.robot
Library      taf.rfrl.utilities.logger.custom_logger        WITH NAME    logger
Variables    ./resources/common_variables.py

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
Suite Teardown    Common Suite Teardown

*** Variables ***
@{Cell_IDs}         NRCELL-1
${capabilities}     REAL_UE

*** Test Cases ***
#Turn power on
#    Turn test line on

[1]CB008376_C_SiSo_Auto_SM_Cell_lock_unlock
    [Setup]    Actions before test
    [Timeout]    20h
    SISO lock unlock all cells
    Call to selected cells      CellIDs=${Cell_IDs}      duration=120s     tc_name=Cell_lock_unlock
    [Teardown]    Actions after test

[1]CB008376_C_SiSo_Auto_SM_Cell_block_unblock
    [Setup]    Actions before test    alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Cell_block_unblock]
    [Timeout]    20h
    General SiSo Cell block and unblock
    Call to selected cells      CellIDs=${Cell_IDs}      duration=120s     tc_name=Cell_block_unblock
    [Teardown]    Actions after test

[1]CB008376_C_SiSo_Auto_RU_Module_reset_from_GUI
    [Setup]    Actions before test
    [Timeout]    20h
    SiSo RF module reset from GUI
    Call to selected cells      CellIDs=${Cell_IDs}      duration=120s     tc_name=RU_reset
    [Teardown]    Actions after test

[1]CB008376_C_SiSo_Auto_SM_RF_Module_lock_unlock
    [Setup]    Actions before test
    [Timeout]    20h
    General SiSo Auto RF Lock Unlock
    Call to selected cells      CellIDs=${Cell_IDs}      duration=120s     tc_name=RF_lock_unlock
    [Teardown]    Actions after test

[1]CB008376_C_SiSo_Auto_SM_BTS_Site_Reset
    [Setup]    Actions before test    alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[BTS_reset]
    [Timeout]    20h
    Reset gNB
    Wait Until Keyword Succeeds     900 sec     30 sec   Verify gNB is onAir
    Wait Until Keyword Succeeds     900 sec     30 sec   Verify Setup of All Cells
    Call to selected cells      CellIDs=${CellIDs}      duration=120s     tc_name=BTS_reset
    [Teardown]    Actions after test

[1]CB008376_C_Manual_SiSo_CM_Recommissioning
    [Setup]    Actions before test    alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Recommissioning]
    [Timeout]    20h
    Perform_recommissoning    all_parameters_to_change=${ALL_PARAMETERS_TO_CHANGE}
    [Teardown]    Actions after test

#[1]CB008376_C_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#    [Setup]    Actions before test    alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Snapshot]
#    Prepare logs path
#    ${status} =	Run Keyword And Expect Error     STARTS: Several failures occurred
#    ...     General_SiSo_HWPTA_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot
#    local_resources.check_snapshot_status     status=${status}
#    [Teardown]    Actions after test

#Turn power off
#    Turn test line off
