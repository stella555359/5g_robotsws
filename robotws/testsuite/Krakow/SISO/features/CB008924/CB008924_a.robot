*** Settings ***
Documentation
...   Test suite for regression testing of feature CB008924
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Resource     taf/rfrl/procedures/SISO/General_SiSo_Cell_block_and_unblock.robot
Resource     taf/rfrl/procedures/SISO/General_SiSo_Auto_RF_lock_unlock.robot
Resource     taf/rfrl/bts/robot/gnb.robot
Resource     ./resources/common_keywords.robot

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./resources/common_variables.py
Force Tags   STATE_SW_UPLOADED    RAN_5G    PY36    CLOUD_5G_CLASSICAL_FULLRACK_ASIBLR_ABIOB1B4_2xAHFII_FHED
...          SBTS00    SBTS23R1

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
Suite Teardown    Common Suite Teardown

*** Variables ***
@{CellIDs}          LNCEL-11    LNCEL-12    LNCEL-13    LNCEL-19    LNCEL-22    LNCEL-31    LNCEL-32    LNCEL-33
...                 LNCEL-39    NRCELL-16  NRCELL-17   NRCELL-21   NRCELL-36   NRCELL-37

${capabilities}         REAL_UE

*** Test Cases ***
CB008924_A6_SiSo_Auto_SM_Cell_block_unblock
    [Setup]    Actions before test    alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Cell_block_unblock]
    [Timeout]    20h
    Call to selected cells      CellIDs=${CellIDs}      duration=120s       deviation=25%
    ...       tc_name=Cell_block_unblock
    General SiSo Cell block and unblock
    Call to selected cells      CellIDs=${CellIDs}      duration=120s       deviation=25%      prepareUE=False
    ...       tc_name=Cell_block_unblock       index_run=2
    [Teardown]    Actions after test

CB008924_A6_SiSo_Auto_SM_BTS_Site_Reset
    [Setup]    Actions before test    alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[BTS_reset]
    [Timeout]    20h
    Call to selected cells      CellIDs=${CellIDs}      duration=120s       deviation=25%      tc_name=BTS_reset
    FOR     ${iteration}    IN RANGE    2   4
        Reset gNB
        Wait Until Keyword Succeeds     900 sec     30 sec   Verify gNB is onAir
        Wait Until Keyword Succeeds     900 sec     30 sec   Verify Setup of All Cells
        Call to selected cells      CellIDs=${CellIDs}      duration=120s       deviation=25%       prepareUE=False
        ...      tc_name=BTS_reset       index_run=${iteration}
    END
    [Teardown]    Actions after test

CB008924_A6_SiSo_Auto_RU_Module_reset_from_GUI
    [Setup]    Actions before test    alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[RU_reset]
    [Timeout]    20h
    SiSo RF module reset from GUI
    Call to selected cells      CellIDs=${CellIDs}      duration=120s       deviation=25%      tc_name=RU_reset
    [Teardown]    Actions after test

CB008924_A6_SiSo_Auto_SM_RF_Module_lock_unlock
    [Setup]    Actions before test    alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[RU_lock_unlock]
    [Timeout]    20h
    Call to selected cells      CellIDs=${CellIDs}      duration=120s       deviation=25%
    ...      tc_name=RU_lock_unlock
    General SiSo Auto RF Lock Unlock
    Call to selected cells      CellIDs=${CellIDs}      duration=120s       deviation=25%      prepareUE=False
    ...       tc_name=RU_lock_unlock       index_run=2
    [Teardown]    Actions after test

CB008924_A6_SiSo_Auto_Data_call
    [Setup]    Actions before test
    [Timeout]    20h
    Call to selected cells      CellIDs=${CellIDs}      duration=360s       deviation=5%       tc_name=Data_call
    [Teardown]    Actions after test

CB008924_A6_SiSo_Auto_CM_Recommissioning
    [Setup]    Actions before test    alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Recommissioning]
    [Timeout]    20h
    Perform_recommissoning    all_parameters_to_change=${ALL_PARAMETERS_TO_CHANGE}
    [Teardown]    Actions after test
