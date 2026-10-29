*** Settings ***
Documentation
...   Test suite for regression testing of feature CB008973
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Library      taf.rfrl.utilities.test_config
Resource     taf/rfrl/procedures/SISO/General_SiSo_Cell_block_and_unblock.robot
Resource     taf/rfrl/procedures/SISO/General_SiSo_HWPTA_BTS_Template_Commissioning_Recommissioning.robot
#Resource     taf/rfrl/procedures/SISO/General_SiSo_HWPTA_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot.robot
Resource     taf/rfrl/procedures/resources/robot/LogCollection.robot
Resource     taf/rfrl/bts/robot/gnb.robot
Resource     ./resources/common_keywords.robot

Variables    ./resources/common_variables.py

Suite Setup        Common Suite Setup With Commissioning     asir_hub=${True}
Suite Teardown     Common Suite Teardown


*** Variables ***
@{CellIDs}           NRCELL-10   NRCELL-20    NRCELL-30     LNCEL-11    LNCEL-21    LNCEL-31    LNCEL-41
...                  LNCEL-42    LNCEL-255
@{CellIDs_1}         NRCELL-10   NRCELL-30     LNCEL-21    LNCEL-41
@{CellIDs_2}         NRCELL-20   LNCEL-11      LNCEL-31    LNCEL-42
@{CellIDs_3}         LNCEL-21    LNCEL-31    LNCEL-41      LNCEL-42    LNCEL-255
@{CellIDs_Asir}      NRCELL-10    NRCELL-20    NRCELL-30     LNCEL-11    LNCEL-21    LNCEL-31    LNCEL-41
...                  LNCEL-42
@{Cell_255}          LNCEL-255
@{CellIDs_CIT}         NRCELL-20    NRCELL-30    LNCEL-42      LNCEL-255
${capabilities}      REAL_UE

*** Test Cases ***
#Power on
#    Turn test line on
#    Wait Until Keyword Succeeds                     600 sec     30 sec   Verify gNB is onAir

CB008973_C2_LTE_FDD_Block_unblock_ASiR-pRRH_by_ASiRWebEM
    [Setup]    Actions before test    alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[pRRH_block]
    Block Ants
    BuiltIn.Sleep   10s
    Unblock Ants
    Wait Until Keyword Succeeds     900 sec     30 sec   Verify Setup of All Cells
    Call to selected cells          CellIDs=${CellIDs}      duration=120s       deviation=40%     tc_name=pRRH_block
    [Teardown]    Actions after test

#####CDRT
CB008973_C2_LTE_FDD_Lock_unlock_ASiR-HUB_by_WebEM
    [Setup]    Actions before test      alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[ASiR_HUB_lock]
    Lock HUBS
    Wait Until Keyword Succeeds  10x  60  Check Hub Status Via Gnb  1  administrativeState=locked
    Unlock HUBS
    Wait Until Keyword Succeeds  10x  60  Check Hub Status Via Gnb  1  administrativeState=unlocked
    Call to selected cells          CellIDs=${CellIDs_CIT}      duration=120s       deviation=40%      tc_name=ASiR_HUB_lock
    [Teardown]    Actions after test

##CIT
CB008973_C2_LTE_FDD_Manual_SiSo_SM_BTS_Site_Reset
    [Setup]    Actions before test
    Call to selected cells      CellIDs=${CellIDs_CIT}      duration=120s       deviation=40%       tc_name=BTS_reset
    FOR     ${iteration}    IN RANGE    2   4
       Reset gNB
       Wait Until Keyword Succeeds     1200 sec     30 sec   Verify gNB is onAir
       Wait Until Keyword Succeeds     1200 sec     30 sec   Verify Setup of All Cells
       Call to selected cells      CellIDs=${CellIDs_CIT}      duration=120s       deviation=40%       tc_name=BTS_reset
       ...                         index_run=${iteration}
    END
    [Teardown]    Actions after test

CB008973_C2_LTE_FDD_Reset_ASiR-pRRH_by_ASiRWebEM
    [Setup]    Actions before test      alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[pRRH_Reset]
    Reset Ants
    Wait Until Keyword Succeeds     900 sec     30 sec   Verify Setup of All Cells
    Call to selected cells          CellIDs=${CellIDs}      duration=120s       deviation=40%       tc_name=pRRH_Reset
    [Teardown]      Actions after test

CB008973_C2_Manual_SiSo_SM_NR RAT reset
    [Setup]    Actions before test
    Call to selected cells         CellIDs=${CellIDs}      duration=120s       deviation=40%       tc_name=NR_RAT_Reset
    NR RAT Reset
    Call to selected cells         CellIDs=${CellIDs}      duration=120s       deviation=40%       tc_name=NR_RAT_Reset
    ...                            prepareUE=False        index_run=2
    [Teardown]      Actions after test

CB008973_C2_LTE_FDD_Reset_BBMOD_from_WebEM
    [Setup]    Actions before test      alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[BBMOD_Reset]
    Reset BBMODs
    Wait Until Keyword Succeeds     900 sec     30 sec   Verify Setup of All Cells
    Call to selected cells          CellIDs=${CellIDs}      duration=120s       deviation=40%       tc_name=BBMOD_Reset
    [Teardown]      Actions after test

CB008973_C2_LTE_FDD_Lock_unlock_the_BBMOD
    [Setup]    Actions before test
    Lock BBMODs
    Check All BBMODs Status     availabilityStatus=Online  administrativeState=locked  operationalState=Enabled
    Unlock BBMODs
    Check All BBMODs Status     availabilityStatus=Online  administrativeState=unlocked  operationalState=Enabled
    Wait Until Keyword Succeeds     900 sec     30 sec   Verify Setup of All Cells
    Call to selected cells          CellIDs=${CellIDs}      duration=120s       deviation=20%       tc_name=BBMOD_lock
    [Teardown]    Actions after test

CB008973_C2_LTE_FDD_General_SiSo_Cell_block_and_unblock
    [Setup]    Actions before test    alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Cell_block_unblock]
    Call to selected cells      CellIDs=${CellIDs}      duration=120s       deviation=40%     tc_name=Cell_block_unblock
    General SiSo Cell block and unblock
    Call to selected cells          CellIDs=${CellIDs_1}      duration=360s       deviation=5%     tc_name=Cell_block_unblock
    ...                         index_run=2       prepareUE=False
    Call to selected cells          CellIDs=${CellIDs_2}      duration=360s       deviation=5%
    ...                         tc_name=Cell_block_unblock     index_run=3
    Call to selected cells          CellIDs=${Cell_255}      duration=360s       deviation=5%
    ...                         tc_name=Cell_block_unblock     index_run=4
    [Teardown]    Actions after test

CB008973_C2_LTE_FDD_General_SiSo_Commissioning_BTS_Template_Commissioning
    [Setup]    Actions before test    alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Recomm_and_comm]
    SiSo_Commissioning_BTS_Template_Commissioning
    Perform_recommissoning    all_parameters_to_change=${ALL_PARAMETERS_TO_CHANGE}
    [Teardown]    Actions after test

#CB008973_C2_LTE_FDD_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#    [Setup]    Actions before test      alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Snapshot]
#    Verify snapshot
#    [Teardown]      Actions after test

########################### CNI FOR TRUNK ASIM ONLY ###########################
CNI105353_IPsec_feature_activation_in_RuProtectEnabled_mode
    [Setup]    Actions before test      alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[IPsec]
    CNI105353 IPsec feature activation in RuProtectEnabled mode
    [Teardown]    Actions after test

CNI105353_IPsec_feature_deactivation_from_RuProtectEnabled_to_RuProtectDisabled
    [Setup]    Actions before test      alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[IPsec]
    CNI105353 IPsec feature deactivation from RuProtectEnabled to RuProtectDisabled
    [Teardown]    Actions after test

#Power off
#    Turn test line off
