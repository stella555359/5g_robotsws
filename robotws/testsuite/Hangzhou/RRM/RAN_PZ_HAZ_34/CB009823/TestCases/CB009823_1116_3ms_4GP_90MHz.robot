*** Settings ***
Resource    ./../Resources/CB009823_keywords.robot

Documentation    Suite description
...    author: Wang Yixiang
...    contact: yixiang.x.wang@nokia-sbell.com
...    squad group: I_NSB_MN_RAN_RD_VRF_HAZ3_01_S1_GMS
...    Feature CB009823

Suite Setup  9823 Suite preparation multiGNB
Suite Teardown  run keyword and ignore error    Common suite recovery

*** Variables ***
${DL_TPUT}         1700M
${UL_TPUT}         300M

*** Test Cases ***
CB009823-SR-B_TC211_Keep_RIM-RS1_and_RS2_Detection_within_maxRsDetectDurationWithoutRi_afterRI-Disappeared_r4_1116-3ms-4GP-90MHz_on-Thor
    [Tags]    CRT_TRUNK
    [Documentation]
    ...    UE-2 attach and start DL traffic for data over NAS/SA on gNB2.
    ...    set targetTotalLoad=100 of aggressor cell on gnb1, check alarm 7525 and 7527, setid, SRS stop and rimRsDetectionRequest=True of gNB2
    ...    set targetTotalLoad=0 of aggressor cell on gnb1, check 7525 and 7527 disappear, SRS resume and check TPUT
    [Setup]     9823 case setup    lock_cell=${True}    targetTotalLoad=${True}    frame_bw=90M_1116_3ms_4GP
    Set case variable

    log to console    Make L3 call and Check no DL Mitigation before RI, then Unlock aggressor cells
    Steps Make L3 call and Check no DL Mitigation before RI    check_bip_needed=${False}

    run keyword and continue on failure    Unlock cells
    Set aggressor targetTotalLoad via restAPI   paras=${RESTAPI_MODIFY_TARGET_TOTAL_LOAD}

    log to console    Check fault 7525 raised and check RI from syslog, check RI info from PCMD log
    Steps Check Fault 7525 raised and RI PCMD When RI   framestructure=${frameStructureBW}
                                                ...    transmission_window=${transmission_window}
                                                ...    near_far=${CONFIGS_GNB0["rsNearFarConfig"]}
                                                ...    repetition=${CONFIGS_GNB0["repetitionRsType1"]}
                                                ...    ri_monitor_special_slot_list=${RI_MONITOR_S_SLOT_LIST}
                                                ...    ri_monitor_ul_slot_list=${RI_MONITOR_UL_SLOT_LIST}
                                                ...    check_ri_pcmd=${False}
                                                ...    cm_ri_state=${cm_ri_state}
                                                ...    cm_rimrssetid_state=${cm_rimrssetid_state}
                                                ...    cm_dlmuting_state=${cm_dlmuting_state}
                                                ...    cm_asymmetric_state=${cm_asymmetric_state}
                                                ...    riState=${RI_DETECTED}
#                                                ...    asymmetricState=${None}
#                                                ...    rimRsSetIdType1=11160    rimRsSetIdType2=11160
#                                                ...    pdcchMutingStatus=${None}    pdschMutingStatus=${1DL_S_MUTING}

    log to console    Check fault 7527 raised and RIMRS PCMD log, then make call and check DL mitigation from bip log
    Steps Check Fault 7527 raised and RIMRS PCMD and DL Mitigation started from Bip When RI   SetId_Aggressor=${CONFIGS_GNB1["rsSetId"]}
                                                ...    dlMuteSlotsStr=${dlMuteSlotsStr}
                                                ...    repetitionRsType1=${CONFIGS_GNB0["repetitionRsType1"]}
                                                ...    repetitionRsType2=${CONFIGS_GNB0["repetitionRsType2"]}
                                                ...    check_rimrs_pcmd=${False}
                                                ...    feature=9823
                                                ...    srs_check=not exist
                                                ...    setId_show_in_fault=${True}
                                                ...    cm_rimrssetid_state=${cm_rimrssetid_state}
                                                ...    cm_dlmuting_state=${cm_dlmuting_state}
                                                ...    cm_asymmetric_state=${cm_asymmetric_state}
                                                ...    asymmetricState=${None}
                                                ...    rimRsSetIdType1=11160    rimRsSetIdType2=11160
                                                ...    pdcchMutingStatus=${None}    pdschMutingStatus=${1DL_S_MUTING}

    log to console    start to set aggressor targetTotalLoad 0 and check if alsrm 7525 & 7527 canceled
    Steps Trigger RI Disappear but RIMRS exist then Check Fault 7525 7527 canceled and DL Mitigation stopped
                                                ...    SetId_Aggressor=${CONFIGS_GNB1["rsSetId"]}
                                                ...    dlMuteSlotsStr=${dlMuteSlotsStr}
                                                ...    rs_detect_duration_without_Ri=${CONFIGS_GNB0["maxRsDetectDurationWithoutRi"]}
                                                ...    feature=9823
                                                ...    repetitionRsType1=${CONFIGS_GNB0["repetitionRsType1"]}
                                                ...    repetitionRsType2=${CONFIGS_GNB0["repetitionRsType2"]}
                                                ...    exp_dl_tput_gap=${exp_dl_tput_gap}
                                                ...    exp_ul_tput_gap=${exp_ul_tput_gap}
                                                ...    setId_show_in_fault=${True}
                                                ...    cm_ri_state=${cm_ri_state}
                                                ...    cm_rimrssetid_state=${cm_rimrssetid_state}
                                                ...    cm_dlmuting_state=${cm_dlmuting_state}
                                                ...    cm_asymmetric_state=${cm_asymmetric_state}
                                                ...    rimRsSetIdType1=11160    rimRsSetIdType2=11160
                                                ...    pdcchMutingStatus=${None}    pdschMutingStatus=${1DL_S_MUTING}
    [Teardown]  run keyword and ignore error    9823 case teardown   detach_ue=${True}
    ...   unlock_cell=${False}    targetTotalLoad=${True}

*** Keywords ***
Set case variable
    [Documentation]    Set variables for 9823
    ...    Author: Wang Yixiang
    @{SPECIAL_SLOT_LIST}    set variable    ${SPECIAL_SLOT_LIST_1116_3}
    @{MUTE_SLOT_LIST}    Combine Lists    ${SPECIAL_SLOT_LIST_1116_3}    ${PRECED_DL_SLOT_LIST_1116_3}
    @{RI_MONITOR_S_SLOT_LIST}    set variable if    '${PROGRAM}'<'25R1'    ${RI_MONITOR_S_SLOT_LIST_1116_3}    ${RI_MONITOR_S_SLOT_LIST_1116_3_V2}
    @{RI_MONITOR_UL_SLOT_LIST}    set variable if    '${PROGRAM}'<'25R1'    ${RI_MONITOR_UL_SLOT_LIST_1116_3}    ${RI_MONITOR_UL_SLOT_LIST_1116_3_V2}
    set test variable    @{SPECIAL_SLOT_LIST}
    set test variable    @{MUTE_SLOT_LIST}
    set test variable    @{RI_MONITOR_S_SLOT_LIST}
    set test variable    @{RI_MONITOR_UL_SLOT_LIST}
    set test variable    ${TDD_DL_EXP_TPUT}     ${TDD_DL_EXP_TPUT_90M_1116}
    set test variable    ${TDD_UL_EXP_TPUT}     ${TDD_UL_EXP_TPUT_90M_1116}
    set test variable    ${transmission_window}     6min
    set test variable    ${frameStructureBW}     1116_3ms_4gp_90MHZ
    set test variable    ${dlMuteSlotsStr}     ${DL_MUTE_SLOTS_SPECIAL_PRECEDING}
    ${exp_dl_tput_gap}   evaluate    ${TDD_DL_EXP_TPUT}*0.03
    ${exp_ul_tput_gap}   evaluate    ${TDD_UL_EXP_TPUT}*0.03
    set test variable    ${exp_dl_tput_gap}
    set test variable    ${exp_ul_tput_gap}
    ${cm_ri_state}    Set Variable If    '${PROGRAM}'>='25R3'    on    off
    ${cm_rimrssetid_state}    Set Variable If    '${PROGRAM}'>='25R3'    on    off
    ${cm_dlmuting_state}    Set Variable If    '${PROGRAM}'>='25R3'    on    off
    ${cm_asymmetric_state}    Set Variable If    '${PROGRAM}'>='25R3'    on    off
    set test variable    ${cm_ri_state}
    set test variable    ${cm_rimrssetid_state}
    set test variable    ${cm_dlmuting_state}
    set test variable    ${cm_asymmetric_state}
