*** Settings ***
Resource    ./../Resources/CB006991_keywords.robot

Documentation    Suite description
...    author: Cheng Catherine
...    contact: catherine.cheng@nokia-sbell.com
...    squad group: NSB_MN_RAN_Pz_3_HAZ_1_SG
...    Feature CB006991

Suite Setup  6991 Suite common setup preparation
Suite Teardown  run keyword and ignore error    Common suite recovery

*** Variables ***
${DL_TPUT}         1000M
${UL_TPUT}         120M

*** Test Cases ***
CNI-102746_TC004_RIM-RS_detection_with_NEAR-FAR-config2_FrameStructure_1116-0ms-6GP
    [Tags]    CRT_TRUNK
    [Documentation]     Author: Cheng Catherine
    ...    Description:The purpose of this test is to verify RI trigger and DL mitigation with near-far
    ...    then gNB stops DL mitigation when RI and RIM-RS disappear with 1116 0ms 60MHz 6GP
    ...    SPECIAL_SLOT_LIST_1116_0 defined in CB006991_variabled.robot, CONFIG_1116_0MS_6GP_60MHZ defined in NIDD_modify_scf.py
    ...    step 1>  UE attach and start DL traffic at victim side, check Special+DL symbols all scheduled
    ...    step 2>  wait and check fault 7525 raised and check RI from syslog
    ...    for non ABIP TL?, check the near-far function by check if rim-rs sent correct on Aggressor side from bip
    ...    step 3>  wait and check fault 7527 raised
    ...    step 4>  capture bip log, and stop DL traffic and check DL mitigation(S+DL sysmbol muted) from bip log
    ...    step 5>  lock aggressor cell, wait and verify fault 7525 & 7527 disappeared, and present from history alarm list
    ...    step 6>  capture bip log, and stop DL traffic and check Special+DL symbols all scheduled from bip log

    [Setup]     6991 case setup    frame_bw=${STR_1116_0MS_6GP_60MHZ}
    set test variable    @{SPECIAL_SLOT_LIST}    @{SPECIAL_SLOT_LIST_1116_0}
    # for 6GP, no dl scheduled on special slots
    set test variable    @{MUTE_SLOT_LIST}    @{PRECED_DL_SLOT_LIST_1116_0}
    set test variable    ${CONFIGS}    ${CONFIG_1116_0MS_6GP_60MHZ}
    set test variable    ${TDD_DL_EXP_TPUT}     ${TDD_DL_EXP_TPUT_60M}
    set test variable    ${TDD_UL_EXP_TPUT}     ${TDD_UL_EXP_TPUT_60M}

    ${list_measurement_ids}    create list    M55194C00001    M55194C00002   M55194C00003   M55194C00004
    ...   M55194C00005    M55194C00007   M55194C00009    M55194C00010   M55194C00011   M55194C00012   M55194C00013
    ...   M55194C00281    M55194C00282
    #${near_far}    set variable if     '${testline_name}'=='7_5_UTE5G402T420'    ${NEAR_ONLY}   ${CONFIGS["near_far"]}

    log to console    step 1: Make L3 call and Check no DL Mitigation before RI for 1116 0ms 60MHz, then Unlock aggressor cells
    Steps Make L3 call and Check no DL Mitigation before RI    check_bip_needed=${False}
    run keyword and continue on failure    Unlock cells
    Set aggressor targetTotalLoad via restAPI   paras=${RESTAPI_MODIFY_TARGET_TOTAL_LOAD}

    log to console    step 2: Check fault 7525 raised check RI from syslog and check rimrs sent correctly on Aggressor side
    Steps Check Fault 7525 raised and RI PCMD When RI   framestructure=${CONFIGS["frameStructureBW"]}
                                                ...    transmission_window=${CONFIGS["transmission_window"]}
                                                ...    near_far=${CONFIGS["near_far"]}
                                                ...    repetition=${CONFIGS["repetitionRsType1"]}
                                                ...    check_rimrs_sent=${True}

    log to console    step 3-4: Check fault 7527 raised, then make call and check DL mitigation from bip log, then check PM counters
    Steps Check Fault 7527 raised and RIMRS PCMD and DL Mitigation started from Bip When RI
                                                    ...    SetId_Aggressor=${CONFIGS["rsSetIdAggressor"]}
                                                    ...    dlMuteSlotsStr=${CONFIGS["dlMuteSlotsStr"]}
                                                    ...    repetitionRsType1=${CONFIGS["repetitionRsType1"]}
                                                    ...    setId_show_in_fault=${True}

    run keyword if   '${PROGRAM}'>'24R1'    Steps Check PM Counters for RI and RIMRS
                                                    ...    list_measurement_ids=${list_measurement_ids}
                                                    ...    ul_ri_symbols=${UL_RI_SYMBOLS_CNI102746}
                                                    ...    rimrs_setid_num=${1}
                                                    ...    RSSI_SB3=${False}
                                                    ...    RSSI_SB4=${False}
                                                    ...    is_sl_mute=${False}

    log to console    step 5-6: start to lock aggressor cell and check if alsrm 7525 & 7527 canceled
    Steps Trigger RI Disappear and Check Fault 7525 7527 canceled and DL Mitigation stopped
                                                ...    SetId_Aggressor=${CONFIGS["rsSetIdAggressor"]}
                                                ...    dlMuteSlotsStr=${CONFIGS["dlMuteSlotsStr"]}
                                                ...    is_pdsch_scheduled_on_s_d_slot=${True}
                                                ...    setId_show_in_fault=${True}

    [Teardown]  run keyword and ignore error    6991 case teardown   detach_ue=${True}
    ...   unlock_cell=${True}    targetTotalLoad=${True}
