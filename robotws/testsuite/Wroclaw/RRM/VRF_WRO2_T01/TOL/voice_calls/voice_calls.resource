*** Settings ***
Documentation
...   author: Wiktor Jarosinski
...   contact: wiktor.jarosinski@nokia.com
...   Description:   Keywords of Voice Calls for TOL
Library     taf.ue
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/webem_operations.py

*** Variables ***
${enb_mplane}   ${tl.enbs[0].oam_ip.v4}
${TEST_CELL}    1
${TEST_CELL2}    21

*** Keywords ***
Voice Call AHFIB
    Require ue      ue_alias=UE_2     capabilities=RFCW20EQWYA
    lock_all_cells_except   ${TEST_CELL}    enb_host=${enb_mplane}
    Attach UE   UE_2
    Turn Mobile Data On     UE_2
    Start Voice Call    vc_alias=VC_1   ue_alias=UE_2   to=+555800903300992     duration=30s
    Stop Voice Call     vc_alias=VC_1
    log to console      Back to Default TL state...
    unlock_all_cells    enb_host=${enb_mplane}

Voice Call AHLOA
    Require ue      ue_alias=UE_2     capabilities=RFCW20EQWYA
    lock_all_cells_except   ${TEST_CELL2}    enb_host=${enb_mplane}
    Attach UE   UE_2
    Turn Mobile Data On     UE_2
    Start Voice Call    vc_alias=VC_1   ue_alias=UE_2   to=+555800903300992     duration=30s
    Stop Voice Call     vc_alias=VC_1
    log to console      Back to Default TL state...
    unlock_all_cells    enb_host=${enb_mplane}

Emergency Call AHFIB
    Require ue      ue_alias=UE_2     capabilities=RFCW20EQWYA
    lock_all_cells_except   ${TEST_CELL}    enb_host=${enb_mplane}
    Attach UE   UE_2
    Turn Mobile Data On     UE_2
    Start Voice Call    vc_alias=VC_1   ue_alias=UE_2   to=911     duration=30s
    Stop Voice Call     vc_alias=VC_1
    log to console      Back to Default TL state...
    unlock_all_cells    enb_host=${enb_mplane}

Emergency Call AHLOA
    Require ue      ue_alias=UE_2     capabilities=RFCW20EQWYA
    lock_all_cells_except   ${TEST_CELL2}    enb_host=${enb_mplane}
    Attach UE   UE_2
    Turn Mobile Data On     UE_2
    Start Voice Call    vc_alias=VC_1   ue_alias=UE_2   to=911   duration=30s
    Stop Voice Call     vc_alias=VC_1
    log to console      Back to Default TL state...
    unlock_all_cells    enb_host=${enb_mplane}