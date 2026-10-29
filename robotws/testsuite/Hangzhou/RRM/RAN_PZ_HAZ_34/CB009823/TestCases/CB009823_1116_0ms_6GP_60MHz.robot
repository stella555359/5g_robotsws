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
${DL_TPUT}         1000M
${UL_TPUT}         200M

*** Test Cases ***
CB009823-SR-F_TC301_RIM-RS_transmission_and_detection_for_all_subfeatures_100MHz_100MHz-100MHz_overlap_100MHz_1116-0ms-4GP_numRbForRs-48_Loki
    [Tags]    CRT_TRUNK
    [Documentation]
    ...    1. UE-2 attach and start DL traffic for data over NAS/SA on gNB2.
    ...    2. set targetTotalLoad=100 of aggressor cell on gnb1, check alarm 7525, 7527, 7532, setid, not enough
    ...    3. set rsDetectionWindow=special+2UL slots, check rimRsDetectionRequest in bip and near in PCMD log
    ...    4. set rsDetectionWindow=diable of victim cell and  targetTotalLoad=0 of aggressor cell, check 7525 and 7532 canceled,
    ...       and check RS1 is transmitted sequence belong to [(rsType1NScId)/2, (rsType1NScId)-1],
    ...       then check 7527 canceled, SRS resume and check TPUT
    [Setup]     9823 case setup    lock_cell=${False}    targetTotalLoad=${True}    frame_bw=60M_1116_0ms_6GP
    Set case variable

    log to console    Make L3 call and Check no DL Mitigation before RI, then Unlock aggressor cells
    Steps Make L3 call and Check no DL Mitigation before RI    check_bip_needed=${False}
    Set aggressor targetTotalLoad via restAPI   paras=${RESTAPI_MODIFY_TARGET_TOTAL_LOAD}

    log to console    Check fault 7525 raised and check RI from syslog, check RI info from PCMD log
    Steps Check Fault 7525 raised and RI PCMD When RI   framestructure=${frameStructureBW}
                                                ...    transmission_window=${transmission_window}
                                                ...    near_far=${CONFIGS_GNB0["rsNearFarConfig"]}
                                                ...    repetition=${CONFIGS_GNB0["repetitionRsType1"]}
                                                ...    ri_monitor_special_slot_list=${RI_MONITOR_S_SLOT_LIST}
                                                ...    ri_monitor_ul_slot_list=${RI_MONITOR_UL_SLOT_LIST}
                                                ...    check_ri_pcmd=${False}
                                                ...    check_asymmetric=${True}
                                                ...    tcpdump_collector_name=TC301_PCMD_RI
                                                ...    cm_ri_state=on
                                                ...    cm_rimrssetid_state=on
                                                ...    cm_dlmuting_state=on
                                                ...    cm_asymmetric_state=on
                                                ...    riState=${RI_DETECTED}
#                                                ...    asymmetricState=${ASYMMETRIC}
#                                                ...    rimRsSetIdType1=11160    rimRsSetIdType2=11160
#                                                ...    pdcchMutingStatus=${None}    pdschMutingStatus=${1DL_MUTING}

    log to console    Check fault 7527 raised and RIMRS PCMD log, then make call and check DL mitigation from bip log
    Steps Check Fault 7527 raised and RIMRS PCMD and DL Mitigation started from Bip When RI   SetId_Aggressor=${CONFIGS_GNB1["rsSetId"]}
                                                ...    dlMuteSlotsStr=${dlMuteSlotsStr}
                                                ...    repetitionRsType1=${CONFIGS_GNB0["repetitionRsType1"]}
                                                ...    repetitionRsType2=${CONFIGS_GNB0["repetitionRsType2"]}
                                                ...    check_rimrs_pcmd=${True}
                                                ...    feature=9823
                                                ...    tcpdump_collector_name=TC301_SU_PCMD_RIMRS
                                                ...    check_asymmetric=${True}
                                                ...    own_setid=${CONFIGS_GNB0["rsSetId"]}
                                                ...    check_enough=${True}
                                                ...    enough_indicator_monitor=${ENOUGH}
                                                ...    enough_verdict_monitor=${ENOUGH}
                                                ...    enough_indicator_transmit=${NOT_ENOUGH}
                                                ...    rsType1NScId=${CONFIGS_GNB0["rsType1NScId"]}
                                                ...    rsType2NScId=${CONFIGS_GNB0["rsType2NScId"]}
                                                ...    setId_show_in_fault=${True}
                                                ...    check_rimrs_detect_enable=${False}
                                                ...    check_bip_needed=${False}
                                                ...    cm_rimrssetid_state=on
                                                ...    cm_dlmuting_state=on
                                                ...    cm_asymmetric_state=on
                                                ...    asymmetricState=${ASYMMETRIC}
                                                ...    rimRsSetIdType1=11160    rimRsSetIdType2=11160
                                                ...    pdcchMutingStatus=${None}    pdschMutingStatus=${1DL_MUTING}

    log to console    change RSDistanceThreshold to 10 and check fault cancel
    Steps enable RSDistanceThreshold and Check Fault cancel
                                                ...    cm_rimrssetid_state=on
                                                ...    cm_dlmuting_state=on

    log to console    change RSDistanceThreshold to 0 and check fault raised
    Steps disable RSDistanceThreshold and Check Fault raised    SetId_Aggressor=${CONFIGS_GNB1["rsSetId"]}
                                                ...    dlMuteSlotsStr=${dlMuteSlotsStr}
                                                ...    feature=9823
                                                ...    setId_show_in_fault=${True}
                                                ...    cm_rimrssetid_state=on
                                                ...    cm_dlmuting_state=on
                                                ...    rimRsSetIdType1=11160    rimRsSetIdType2=11160
                                                ...    pdcchMutingStatus=${None}    pdschMutingStatus=${1DL_MUTING}

    log to console    start to set aggressor targetTotalLoad 0 and check if alsrm 7525 & 7527 canceled
    Steps Trigger RI Disappear but RIMRS exist then Check Fault 7525 7527 canceled and DL Mitigation stopped
                                                ...    SetId_Aggressor=${CONFIGS_GNB1["rsSetId"]}
                                                ...    dlMuteSlotsStr=${dlMuteSlotsStr}
                                                ...    rs_detect_duration_without_Ri=${CONFIGS_GNB0["maxRsDetectDurationWithoutRi"]}
                                                ...    feature=9823
                                                ...    rsType1NScId=${CONFIGS_GNB0["rsType1NScId"]}
												...    rsType2NScId=${CONFIGS_GNB0["rsType2NScId"]}
                                                ...    check_asymmetric=${True}
                                                ...    pdsch_slot_list=${PDSCH_SLOT_LIST}
												...    check_rimrs_pcmd=${True}
                                                ...    check_repetition=${False}
                                                ...    check_enough=${True}
                                                ...    enough_indicator_monitor=${ENOUGH}
                                                ...    enough_verdict_monitor=${ENOUGH}
                                                ...    enough_indicator_transmit=${ENOUGH}
                                                ...    setId_show_in_fault=${True}
                                                ...    cm_ri_state=on
                                                ...    cm_rimrssetid_state=on
                                                ...    cm_dlmuting_state=on
                                                ...    cm_asymmetric_state=on
                                                ...    rimRsSetIdType1=11160    rimRsSetIdType2=11160
                                                ...    pdcchMutingStatus=${None}    pdschMutingStatus=${1DL_MUTING}

    [Teardown]  run keyword and ignore error    9823 case teardown   detach_ue=${True}
    ...   unlock_cell=${False}    targetTotalLoad=${True}

*** Keywords ***
Set case variable
    [Documentation]    Set variables for 9823
    ...    Author: Wang Yixiang
    @{SPECIAL_SLOT_LIST}    set variable    ${SPECIAL_SLOT_LIST_1116_0}
    @{MUTE_SLOT_LIST}    Combine Lists    ${SPECIAL_SLOT_LIST_1116_0}    ${PRECED_DL_SLOT_LIST_1116_0}
    @{RI_MONITOR_S_SLOT_LIST}    set variable if    '${PROGRAM}'<'25R1'    ${RI_MONITOR_S_SLOT_LIST_1116_0}    ${RI_MONITOR_S_SLOT_LIST_1116_0_V2}
    @{RI_MONITOR_UL_SLOT_LIST}    set variable if    '${PROGRAM}'<'25R1'    ${RI_MONITOR_UL_SLOT_LIST_1116_0}    ${RI_MONITOR_UL_SLOT_LIST_1116_0_V2}
    ${dlMuteSlotsStr}    set variable if   '${PROGRAM}'>='24R3'   ${DL_MUTE_SLOTS_1st_PRECEDING}    ${DL_MUTE_SLOTS_SPECIAL_PRECEDING}
    set test variable    @{SPECIAL_SLOT_LIST}
    set test variable    @{MUTE_SLOT_LIST}
    set test variable    @{RI_MONITOR_S_SLOT_LIST}
    set test variable    @{RI_MONITOR_UL_SLOT_LIST}
    set test variable    ${TDD_DL_EXP_TPUT}     ${TDD_DL_EXP_TPUT_60M}
    set test variable    ${TDD_UL_EXP_TPUT}     ${TDD_UL_EXP_TPUT_60M}
    set test variable    ${transmission_window}     6min
    set test variable    ${frameStructureBW}     1116_0ms_4gp_20MHZ
    set test variable    ${dlMuteSlotsStr}
    ${exp_dl_tput_gap}   evaluate    ${TDD_DL_EXP_TPUT}*0.03
    ${exp_ul_tput_gap}   evaluate    ${TDD_UL_EXP_TPUT}*0.03
    set test variable    ${exp_dl_tput_gap}
    set test variable    ${exp_ul_tput_gap}
    set test variable    ${UL_SLOT_LIST}    ${UL_SLOT_LIST_1116_0}
    ${SU_DETECTION_ENABLE_SLOT_LIST}    create list    ${3}   ${4}   ${13}   ${14}
    ${DETECTION_DISABLE_SLOT_LIST}    create list    ${5}   ${15}
    ${PDSCH_SLOT_LIST}    create list    ${2}   ${12}
    set test variable    ${DETECTION_DISABLE_SLOT_LIST}
    set test variable    ${SU_DETECTION_ENABLE_SLOT_LIST}
    set test variable    ${PDSCH_SLOT_LIST}

