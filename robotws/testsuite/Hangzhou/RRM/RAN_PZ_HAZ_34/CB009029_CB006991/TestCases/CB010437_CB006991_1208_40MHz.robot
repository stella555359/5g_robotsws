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
${DL_TPUT}         600M
${UL_TPUT}         60M


*** Test Cases ***
CB010437-SR-A_TC403_PCMD_trace_content_RIM_report_normally_after_cell lock_unlock_for_robust_FrameStructure_1208
    [Tags]    CRT_TRUNK
    [Documentation]     Author: Cheng Catherine
    ...    Description:The purpose of this test is to verify RI trigger and DL mitigation,
    ...    then gNB stops DL mitigation when RI and RIM-RS disappear with 1208 40MHz
    ...    SPECIAL_SLOT_LIST_1208 defined in CB006991_variabled.robot, CONFIG_1208_2GP_40MHZ defined in NIDD_modify_scf.py
    ...    step 1>  UE attach and start DL traffic at victim side, check Special+DL symbols all scheduled
    ...    step 2>  wait and check fault 7525 raised and check RI from syslog, check RI info from PCMD log
    ...    step 3>  wait and check fault 7527 raised and check RIMRS info from PCMD log
    ...    step 4>  capture bip log and check DL mitigation(S+DL sysmbol muted) from bip log
    ...    step 5>  lock aggressor cell, wait and verify fault 7525 & 7527 disappeared, and present from history alarm list
    ...    step 6>  capture bip log, and stop DL traffic and check Special+DL symbols all scheduled from bip log

    [Setup]     6991 case setup    frame_bw=${STR_1208_2GP_40MHZ}
    @{RI_MONITOR_S_SLOT_LIST}    set variable if    '${PROGRAM}'<'25R1'    ${RI_MONITOR_S_SLOT_LIST_1208}    ${RI_MONITOR_S_SLOT_LIST_1208_V2}
    @{RI_MONITOR_UL_SLOT_LIST}    set variable if    '${PROGRAM}'<'25R1'    ${RI_MONITOR_UL_SLOT_LIST_1208}    ${RI_MONITOR_UL_SLOT_LIST_1208_V2}
    @{MUTE_SLOT_LIST}    Combine Lists     ${SPECIAL_SLOT_LIST_1208}     ${PRECED_DL_SLOT_LIST_1208}
    set test variable    @{SPECIAL_SLOT_LIST}    @{SPECIAL_SLOT_LIST_1208}
    set test variable    @{MUTE_SLOT_LIST}
    set test variable    @{RI_MONITOR_S_SLOT_LIST}
    set test variable    @{RI_MONITOR_UL_SLOT_LIST}
    set test variable    ${CONFIGS}    ${CONFIG_1208_2GP_40MHZ}
    set test variable    ${TDD_DL_EXP_TPUT}     ${TDD_DL_EXP_TPUT_40M}
    set test variable    ${TDD_UL_EXP_TPUT}     ${TDD_UL_EXP_TPUT_40M}

    log to console    step 1: Make L3 call and Check no DL Mitigation before RI for 1208 40MHz, then Unlock aggressor cells
    Steps Make L3 call and Check no DL Mitigation before RI
    run keyword and continue on failure    Unlock cells
    Set aggressor targetTotalLoad via restAPI   paras=${RESTAPI_MODIFY_TARGET_TOTAL_LOAD}

    log to console    step 2: Check fault 7525 raised and check RI from syslog, check RI info from PCMD log
    Steps Check Fault 7525 raised and RI PCMD When RI   framestructure=${CONFIGS["frameStructureBW"]}
                                                ...    transmission_window=${CONFIGS["transmission_window"]}
                                                ...    near_far=${CONFIGS["near_far"]}
                                                ...    repetition=${CONFIGS["repetitionRsType1"]}
                                                ...    ri_monitor_special_slot_list=${RI_MONITOR_S_SLOT_LIST}
                                                ...    ri_monitor_ul_slot_list=${RI_MONITOR_UL_SLOT_LIST}
                                                ...    check_ri_pcmd=${True}

    log to console    step 3-4: Check fault 7527 raised and RIMRS PCMD log, then make call and check DL mitigation from bip log
    Steps Check Fault 7527 raised and RIMRS PCMD and DL Mitigation started from Bip When RI   SetId_Aggressor=${CONFIGS["rsSetIdAggressor"]}
                                                                                ...    dlMuteSlotsStr=${CONFIGS["dlMuteSlotsStr"]}
                                                                                ...    repetitionRsType1=${CONFIGS["repetitionRsType1"]}
                                                                                ...    check_rimrs_pcmd=${True}

    log to console    step 4.1: no RI or RIMRS PCMD after PCMD MO deleted
    run keyword if    '${PROGRAM}'>'25R1'    Steps Check no RI or RIMRS PCMD after PCMD MO deleted

    log to console    step 5-6: start to lock aggressor cell and check if alarm 7525 & 7527 canceled
    Steps Trigger RI Disappear and Check Fault 7525 7527 canceled and DL Mitigation stopped
                                                ...    SetId_Aggressor=${CONFIGS["rsSetIdAggressor"]}
                                                ...    dlMuteSlotsStr=${CONFIGS["dlMuteSlotsStr"]}

    [Teardown]  run keyword and ignore error    6991 case teardown   detach_ue=${True}
    ...   unlock_cell=${True}    targetTotalLoad=${True}
