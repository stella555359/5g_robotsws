*** Settings ***
Documentation
...            author:       Hubert Chrzan, hubert.chrzan@nokia.com
...            maintainer:   Hubert Chrzan, hubert.chrzan@nokia.com

Force Tags      RF50

Library     taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations    WITH NAME    ru_operations
Library     ta5g_cell_operations    WITH NAME    cellop
Resource    ./resources/main_2vms.robot
Resource    ./resources/wts_2vms.robot
Resource    ./resources/l3call_2vms.robot

Test Setup        Generic Test Setup CNI-120690
Test Teardown     Generic Test Teardown CNI-120690

*** Variables ***
${WTS1_ALIAS}=         wts1
${WTS2_ALIAS}=         wts2
${dl_tput_wts1}        1000
${ul_tput_wts1}        170
${dl_tput_wts2}        80
${ul_tput_wts2}        80
${ue_id}               1

*** Test Cases ***
CNI_120690_Cell_Block_Unblock_With_L3_Call
    [Documentation]    Test case with Block and Unblock Cells procedure
    cellop.lock_single_cell    cell_id=1
    cellop.unlock_single_cell    cell_id=1
    Sleep    60s
    cellop.lock_single_cell    cell_id=7
    cellop.unlock_single_cell    cell_id=7
    Sleep    60s
    Wait for gNB To Be Ready
    Full L3Call

CNI_120690_RF_Lock_Unlock_With_L3_Call
    [Documentation]    Test case with Block and Unblock Radio Units via WebEM procedure
    ru_operations.lock_radio_unit_from_GUI    radio_unit_id=1
    ru_operations.unlock_radio_unit_from_GUI    radio_unit_id=1
    Sleep    60s
    ru_operations.lock_radio_unit_from_GUI    radio_unit_id=7
    ru_operations.unlock_radio_unit_from_GUI    radio_unit_id=7
    Sleep    60s
    Wait for gNB To Be Ready
    Full L3Call

CNI_120690_RF_Module_Reset_With_L3_call
    [Documentation]    Test case with Block and Reset Radio Units procedure
    ru_operations.reset_radio_unit_from_GUI    radio_unit_id=1
    Sleep    60s
    ru_operations.reset_radio_unit_from_GUI    radio_unit_id=7
    Sleep    60s
    Wait for gNB To Be Ready
    Full L3Call

CNI_120690_TL_Site_Reset_With_L3_Call
    [Documentation]    Test case with Site Reset procedure
    Site Reset via API
    Wait for gNB To Be Ready
    Sleep    60s
    Full L3Call

*** Keywords ***
Full L3Call
    Register For SA UEs    ue_id=${ue_id}    alias=${WTS1_ALIAS}
    Register For SA UEs    ue_id=${ue_id}    alias=${WTS2_ALIAS}

    #DL
    Start Traffic For SA UEs    ue_id=${ue_id}    dir=dl    alias=${WTS1_ALIAS}
    Start Traffic For SA UEs    ue_id=${ue_id}    dir=dl    alias=${WTS2_ALIAS}
    Run Keyword And Continue On Failure    Validate Bearer Stats for UEs    ue_id=${ue_id}    expected_tput=${dl_tput_wts1}    dir=dl
    ...    alias=${WTS1_ALIAS}
    Run Keyword And Continue On Failure    Validate Bearer Stats for UEs    ue_id=${ue_id}    expected_tput=${dl_tput_wts2}    dir=dl
    ...    alias=${WTS2_ALIAS}
    Stop Internal SA Traffic CNI-120690    ue_id=${ue_id}    alias=${WTS1_ALIAS}
    Stop Internal SA Traffic CNI-120690    ue_id=${ue_id}    alias=${WTS2_ALIAS}

    #UL
    Start Traffic For SA UEs    ue_id=${ue_id}    dir=ul    alias=${WTS1_ALIAS}
    Start Traffic For SA UEs    ue_id=${ue_id}    dir=ul    alias=${WTS2_ALIAS}
    Run Keyword And Continue On Failure    Validate Bearer Stats for UEs    ue_id=${ue_id}    expected_tput=${ul_tput_wts1}    dir=ul
    ...    alias=${WTS1_ALIAS}
    Run Keyword And Continue On Failure    Validate Bearer Stats for UEs    ue_id=${ue_id}    expected_tput=${ul_tput_wts2}    dir=ul
    ...    alias=${WTS2_ALIAS}
    Stop Internal SA Traffic CNI-120690    ue_id=${ue_id}    alias=${WTS1_ALIAS}
    Stop Internal SA Traffic CNI-120690    ue_id=${ue_id}    alias=${WTS2_ALIAS}

    Detach SA UEs    alias=${WTS1_ALIAS}
    Detach SA UEs    alias=${WTS2_ALIAS}

Site Reset via API
    [Documentation]    Reboots GNB via COAM Reset Site operation triggering AP reboot in parallel.
    Log to Console    -----Rebooting GNB and AP via COAM-----
    Reset AP via PDU    PDU_PORT=${tl.ues[1].l1.common_units[0].pdu_port.port_no}    alias=${WTS2_ALIAS}
    bbu.reset_bts
