*** Settings ***
Documentation
...   Testsuite for regression testing of feature CB009499
...   author: Arkadiusz Gurgul, arkadiusz.gurgul@nokia.com
...   maintainer: Arkadiusz Gurgul, arkadiusz.gurgul@nokia.com

Library        taf.rfrl.bts.devices.du.commissioning.GnbCommissioning    WITH NAME    GnbC
Library        taf.rfrl.bts.devices.du.du_operations.GnbDuOperations    WITH NAME    GnbDuOp
Library        taf.rfrl.bts.devices.du.du_operations.EnbDuOperations    WITH NAME    EnbDuOp
Library        taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    GnbCells
Resource       taf/rfrl/ue/robot/REAL_UE.robot
Resource       taf/rfrl/procedures/resources/robot/utilities.robot
Resource       taf/rfrl/bts/robot/common/gnb_observers.robot
Resource       taf/rfrl/bts/robot/common/gnb_cell.robot

Resource       testsuite/Krakow/SISO/resources/RAN_PZ_KRK2/CB011050/keywords.robot

*** Variables ***
${CAPABILITIES}                     REAL_UE
${UE}                               REAL_UE
${REBOOT_UE}                        ${False}
${REBOOT_UE_TIMEOUT}                100
${L3_CALL_STATUS}                   ${True}

*** Keywords ***
Commission Bts to particular config
    [Arguments]    ${GNB_FULL_COMMISSIONING_PATH}=None
    GnbC.perform_bts_full_commissioning    scf_file=${GNB_FULL_COMMISSIONING_PATH}
    ...                                    timeout=500
    GnbDuOp.wait_for_site_to_be_onair
    Wait Until Keyword Succeeds    10 min    3 sec    GnbCells.Verify all cells are onair

Block Unblock RAT
    [Arguments]    ${rat}
    GnbDuOp.block_rat    rat=${rat}
    GnbDuOp.unblock_rat    rat=${rat}
    Wait Until Keyword Succeeds    3 min    3 sec    GnbDuOp.wait for site to be onair
    Wait Until Keyword Succeeds    3 min    3 sec    GnbDuOp.verify bts is onair
Block Unblock NR RAT
    Block Unblock RAT    rat=NR

Block Unblock LTE RAT
    Block Unblock RAT    rat=LTE

Prepare Ue
    Prepare Ue for L3 Call
    ...    capabilities=${UE}
    ...    alias=${UE}
    ...    reboot_ue=${REBOOT_UE}
    ...    timeout_reboot_ue=${REBOOT_UE_TIMEOUT}

Perform L3 call on selected cell custom
    [Arguments]    ${cell_id}    ${tput_dl}    ${tput_ul}    ${deviation}
    Unblock cell before L3 call    ${cell_id}
    Log to console    Run tput on cell ${cell_id} DL
    ${status}    Run keyword and ignore error
    ...    Verify L3 call One Way Data Transfer
    ...    direction=dl
    ...    duration=60s
    ...    tput=${tput_dl}
    ...    protocol=udp
    ...    deviation=${deviation}
    ...    buffer_client=4M
    ...    buffer_server=4M
    ...    interval=1
    ...    alias=${UE}
    Analyse L3 call status
    ...    l3_call_status=${status}
    ...    cell_id=${cell_id}
    Log to console    Run tput on cell ${cell_id} UL
    ${status}    Run keyword and ignore error
    ...    Verify L3 call One Way Data Transfer
    ...    direction=ul
    ...    duration=60s
    ...    tput=${tput_ul}
    ...    protocol=udp
    ...    deviation=${deviation}
    ...    buffer_client=4M
    ...    buffer_server=4M
    ...    interval=1
    ...    alias=${UE}
    Block cell after L3 call    ${cell_id}
    Analyse L3 call status
    ...    l3_call_status=${status}
    ...    cell_id=${cell_id}
L3 Call NR
    [Arguments]    ${tput_dl_5g}=${TPUT_DL_5G}    ${tput_ul_5g}=${TPUT_UL_5G}    ${cell_id_5g}=${CELL_ID_5G}

    Block all cells before L3 call
    Perform L3 call on selected cell custom
    ...    cell_id=${cell_id_5g}
    ...    tput_dl=${tput_dl_5g}
    ...    tput_ul=${tput_ul_5g}
    ...    deviation=10%
    Run keyword if    ${L3_CALL_STATUS}==${False}    Fail    Tput not as expected
    [Teardown]    L3 call teardown

L3 Call LTE
    [Arguments]    ${tput_dl_4g}=${TPUT_DL_4G}    ${tput_ul_4g}=${TPUT_UL_4G}    ${cell_id_4g}=${CELL_ID_4G}

    Block all cells before L3 call
    Perform L3 call on selected cell custom
    ...    cell_id=${cell_id_4g}
    ...    tput_dl=${tput_dl_4g}
    ...    tput_ul=${tput_ul_4g}
    ...    deviation=15%
    Run keyword if    ${L3_CALL_STATUS}==${False}    Fail    Tput not as expected
    [Teardown]    L3 call teardown
