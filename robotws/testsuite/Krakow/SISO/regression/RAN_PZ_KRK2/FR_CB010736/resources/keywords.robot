*** Settings ***
Documentation
...    author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com
...    maintainer: Piotr Wajda, piotr.wajda@nokia.com

Library    Collections
Library    taf.rfrl.bts.devices.du.commissioning.GnbCommissioning    WITH NAME    GnbCommissioningOp
Library    taf.rfrl.bts.devices.du.du_operations.GnbDuOperations    WITH NAME    GnbDuOp
Library    taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    GnbCells
Library    testsuite.Krakow.SISO.regression.RAN_PZ_KRK2.FR_CB010736.resources.CustomCommissioning    WITH NAME    DuSW
Library    testsuite.Krakow.SISO.regression.RAN_PZ_KRK2.FR_CB010736.resources.CustomCell    WITH NAME    CustomCell

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/procedures/SISO/Online_Cell_addition_deletion.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Cell_block_and_unblock.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_RF_lock_unlock.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_RF_module_power_reset.robot

Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   resources.py

*** Variables ***
@{CUSTOM_ALLOWED_ALARMS}                  Unit power reset    No connection to unit    Not able to synchronize baseband bus
${CELL_ID_TO_DELETE}                      ${144}
${CELL_GROUP_ID_TO_DELETE}                ${144}
${CELL_ID_TO_COPY_CELL_DATA_FROM}         ${143}
${EXPECTED_DL_THP_WITH_CELL}              ${None}
${EXPECTED_UL_THP_WITH_CELL}              ${None}
${EXPECTED_DL_THP_WITH_CELL_DELETED}      ${None}
${EXPECTED_UL_THP_WITH_CELL_DELETED}      ${None}
${CAPABILITIES}                           REAL_UE
${DURATION}                               300s

*** Keywords ***
Commission gNB To 25 MHz
    GnbCommissioningOp.perform_bts_full_commissioning    scf_file=${CURDIR}/commissioning/25MHz.xml
    ...                                                  timeout=${900}
    Wait to On Air

Wait to On Air
    GnbDuOp.wait_for_site_to_be_onair
    Wait Until Keyword Succeeds    10 min    3 sec    GnbCells.Verify all cells are onair

RF Module Power Reset
    Set test variable    @{mandatory_alarms}    10
    Set test variable    @{mandatory_alarms_after_power_on}    4589
    General SiSo Auto RF module power reset    mandatory_alarms=@{mandatory_alarms}
    ...                                        mandatory_alarms_after_power_on=${mandatory_alarms_after_power_on}

Cell Addition And Deletion
    Online Cell Addition Deletion Without L3 Call    cell_id_to_delete=${CELL_ID_TO_DELETE}
    ...                                              cell_id_to_copy_from=${CELL_ID_TO_COPY_CELL_DATA_FROM}
    ...                                              cell_group_id_to_delete=${CELL_GROUP_ID_TO_DELETE}

Online Cell Addition Deletion Without L3 Call
    [Arguments]    ${cell_id_to_delete}    ${cell_id_to_copy_from}    ${cell_group_id_to_delete}
    Remove Fr1 Cell And Nrcellgrp From Configuration    cell_group_id=${cell_group_id_to_delete}
    ...                               cell_id=${cell_id_to_delete}
    Run Keyword And Continue On Failure    Verify Setup Of All Cells
    CustomCell.add_new_cell_based_on_existing_cell_to_configuration_with_new_cell_group
    ...    cell_parameters=${cell_parameters}
    ...    cell_id_to_copy_from=${cell_id_to_copy_from}
    ...    group_id=${cell_group_id_to_delete}
    Wait to On Air

RU Reset Test Setup
    Set Test Variable    ${CUSTOM_ALLOWED_ALARMS}
    Common Preconditions With Watching Alarms
