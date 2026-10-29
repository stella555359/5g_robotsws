*** Settings ***
Documentation
...   author: Wiktor Jarosinski
...   contact: wiktor.jarosinski@nokia.com
...   Description:   Keywords for tput TOL
Library     taf.ue
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/webem_operations.py

*** Variables ***
${enb_mplane}   ${tl.enbs[0].oam_ip.v4}
${TEST_CELL}    1
${TEST_CELL2}    21

*** Keywords ***
TOL_TPUT_AHFIB
    [Arguments]    ${dependent_cells}
    Require ue      ue_alias=UE_2     capabilities=RFCW20EQWYA
    lock_all_cells_except   ${TEST_CELL}    enb_host=${enb_mplane}
    Attach UE   UE_2
    Turn Mobile Data On     UE_2
    Start Data Transfer    DT_1    UE_2    dl    protocol=tcp    duration=30s
    Await Data Transfer Finish     DT_1
    Get Data Transfer Statistics    DT_1     omit=20     end=40
    taf.ue.Stop Data Transfers For All Ues
    Start Data Transfer    DT_2    UE_2    ul    protocol=tcp    duration=30s
    Await Data Transfer Finish     DT_2
    Get Data Transfer Statistics    DT_2     omit=20     end=40
    taf.ue.Stop Data Transfers For All Ues
    Detach ue   UE_2
    log to console      Back to Default TL state...
    unlock_all_cells    enb_host=${enb_mplane}

TOL_TPUT_AHLOA
    [Arguments]    ${dependent_cells}
    Require ue      ue_alias=UE_2     capabilities=RFCW20EQWYA
    lock_all_cells_except   ${TEST_CELL2}    enb_host=${enb_mplane}
    Attach UE   UE_2
    Turn Mobile Data On     UE_2
    Start Data Transfer    DT_1    UE_2    dl    protocol=tcp    duration=30s
    Await Data Transfer Finish     DT_1
    Get Data Transfer Statistics    DT_1     omit=20     end=40
    taf.ue.Stop Data Transfers For All Ues
    Start Data Transfer    DT_2    UE_2    ul    protocol=tcp    duration=30s
    Await Data Transfer Finish     DT_2
    Get Data Transfer Statistics    DT_2     omit=20     end=40
    taf.ue.Stop Data Transfers For All Ues
    Detach ue   UE_2
    log to console      Back to Default TL state...
    unlock_all_cells    enb_host=${enb_mplane}