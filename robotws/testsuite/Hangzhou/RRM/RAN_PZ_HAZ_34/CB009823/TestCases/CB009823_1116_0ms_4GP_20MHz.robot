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
${DL_TPUT}         350M
${UL_TPUT}         40M

*** Test Cases ***
CB009823-SR-C_TC201_RIM-RS_type1_type2_detection_NEAR-FAR-config1_shift40Sym_r4-r8_rsDetectionWindow-SUU_to_disable_RI-SUU_1116-0ms-4GP_100MHz
    [Tags]    CRT_TRUNK
    [Documentation]
    ...    1. UE-2 attach and start DL traffic for data over NAS/SA on gNB2.
    ...    2. set targetTotalLoad=100 of aggressor cell on gnb1, rsDetectionWindow=special+UL slots, near-far config2,
    ...       check alarm 7525 and 7527, setid, rimRsDetectionRequest=True of special+1st UL slot,
    ...       check only far is received
    ...    3. set rsDetectionWindow=special+2UL slots, check rimRsDetectionRequest in bip and nearfar in PCMD log
    ...    4. set rsDetectionWindow=diable of victim cell and  targetTotalLoad=0 of aggressor cell, check 7527 disappear then 7525 disappear,
    ...       SRS resume and check TPUT
    [Setup]     9823 case setup    lock_cell=${True}    frame_bw=20M_1116_0ms_4GP
    Set case variable

    log to console    Make L3 call and Check no DL Mitigation before RI, then Unlock aggressor cells
    Steps Make L3 call and Check no DL Mitigation before RI    check_bip_needed=${False}
    run keyword and continue on failure    Unlock cells   lock_cell_list=@{CELL_LIST_GNB1}   lock_cell_connection=${OAM_ALIAS_GNB1}
    Set aggressor targetTotalLoad via restAPI   paras=${RESTAPI_MODIFY_TARGET_TOTAL_LOAD}

    log to console    Check fault 7525 raised and check RI from syslog, check RI info from PCMD log
    Steps Check Fault 7525 raised and RI PCMD When RI   framestructure=${frameStructureBW}
                                                ...    transmission_window=${transmission_window}
                                                ...    near_far=${CONFIGS_GNB0["rsNearFarConfig"]}
                                                ...    repetition=${CONFIGS_GNB0["repetitionRsType1"]}
                                                ...    ri_monitor_special_slot_list=${RI_MONITOR_S_SLOT_LIST}
                                                ...    ri_monitor_ul_slot_list=${RI_MONITOR_UL_SLOT_LIST}
                                                ...    check_ri_pcmd=${True}
                                                ...    tcpdump_collector_name=TC201_PCMD_RI

    log to console    Check fault 7527 raised and RIMRS PCMD log, then make call and check DL mitigation from bip log
    log to console    Athough rsdetectionWidown is S+U, and only far can detected when 1st pt, but both near far will be validated in 2nd pt
    Steps Check Fault 7527 raised and RIMRS PCMD and DL Mitigation started from Bip When RI   SetId_Aggressor=${CONFIGS_GNB1["rsSetId"]}
                                                ...    dlMuteSlotsStr=${dlMuteSlotsStr}
                                                ...    repetitionRsType1=${CONFIGS_GNB0["repetitionRsType1"]}
                                                ...    repetitionRsType2=${CONFIGS_GNB0["repetitionRsType2"]}
                                                ...    check_rimrs_pcmd=${True}
                                                ...    feature=9823
                                                ...    tcpdump_collector_name=TC201_SU_PCMD_RIMRS
                                                ...    near_far=far
                                                ...    detection_disable_ul_slot_list=${DETECTION_DISABLE_SLOT_LIST}
                                                ...    target_file_name=bip_log_during_RI_SU
                                                ...    rimrs_enable_slot_list=${SU_DETECTION_ENABLE_SLOT_LIST}
                                                ...    setId_show_in_fault=${True}
                                                ...    check_rimrs_detect_enable=${False}
                                                ...    check_bip_needed=${False}
    # fault 7527 may not cancel after CB014133 introduced on 25R3, so skip the check on 25R3 and later releases
    Run Keyword If   '${PROGRAM}' < '25R3'  Steps set rsDetectionWindow SUU then Check Fault 7527 and 7535 cancel   dlMuteSlotsStr=${dlMuteSlotsStr}

    log to console    after set rsDetectionWindow=SUU, Check 7527 raised and RIMRS PCMD log, then make call and check DL mitigation from bip log
    Steps Check Fault 7527 raised and RIMRS PCMD and DL Mitigation started from Bip When RI   SetId_Aggressor=${CONFIGS_GNB1["rsSetId"]}
                                                ...    dlMuteSlotsStr=${dlMuteSlotsStr}
                                                ...    repetitionRsType1=${CONFIGS_GNB0["repetitionRsType1"]}
                                                ...    repetitionRsType2=${CONFIGS_GNB0["repetitionRsType2"]}
                                                ...    check_rimrs_pcmd=${True}
                                                ...    feature=9823
                                                ...    near_far=both
                                                ...    tcpdump_collector_name=TC201_SUU_PCMD_RIMRS
                                                ...    target_file_name=bip_log_during_RI_SUU
                                                ...    rimrs_enable_slot_list=${SUU_DETECTION_ENABLE_SLOT_LIST}
                                                ...    setId_show_in_fault=${True}
                                                ...    check_rimrs_detect_enable=${False}
                                                ...    check_bip_needed=${False}

    log to console    start to rsDetectionWindow=disable RS detection and check if alsrm 7527 and 7535 canceled
    Run Keyword If    '${PROGRAM}' >= '25R3'   Enable fault 7527 fault 7535 CM on and check NRRIMINFO
    Steps Trigger rsDetectionWindow disable then Check Fault 7527 canceled and DL Mitigation stopped then RI disappear and 7525 cancel
                                                ...    SetId_Aggressor=${CONFIGS_GNB1["rsSetId"]}
                                                ...    dlMuteSlotsStr=${dlMuteSlotsStr}
                                                ...    feature=9823
                                                ...    check_rs_detect_false=${True}
                                                ...    setId_show_in_fault=${True}
                                                ...    check_pcmd_setid_reset=${True}
                                                ...    cm_rimrssetid_state=${cm_rimrssetid_state}
                                                ...    cm_dlmuting_state=${cm_dlmuting_state}
                                                ...    riState=${None}
    Run Keyword If    '${PROGRAM}' >= '25R3'    run keyword and continue on failure
    ...    Wait and Get NRRIMINFO via WEBEM and Check NRRIMINFO Value is as Expected
    ...    asymmetricState=${None}    riState=${None}    rimRsSetIdType1=${None}    rimRsSetIdType2=${None}
    ...    pdcchMutingStatus=${None}    pdschMutingStatus=${NO_MUTING}
    [Teardown]  run keyword and ignore error    9823 case teardown   detach_ue=${True}
    ...   unlock_cell=${True}    targetTotalLoad=${True}

*** Keywords ***
Set case variable
    [Documentation]    Set variables for 9823
    ...    Author: Wang Yixiang
    @{SPECIAL_SLOT_LIST}    set variable    ${SPECIAL_SLOT_LIST_1116_0}
    @{MUTE_SLOT_LIST}    Combine Lists    ${SPECIAL_SLOT_LIST_1116_0}    ${PRECED_DL_SLOT_LIST_1116_0}    ${PRECED_2DL_SLOT_LIST_1116_0}
    @{RI_MONITOR_S_SLOT_LIST}    set variable if    '${PROGRAM}'<'25R1'    ${RI_MONITOR_S_SLOT_LIST_1116_0}    ${RI_MONITOR_S_SLOT_LIST_1116_0_V2}
    @{RI_MONITOR_UL_SLOT_LIST}    set variable if    '${PROGRAM}'<'25R1'    ${RI_MONITOR_UL_SLOT_LIST_1116_0}    ${RI_MONITOR_UL_SLOT_LIST_1116_0_V2}
    set test variable    @{SPECIAL_SLOT_LIST}
    set test variable    @{MUTE_SLOT_LIST}
    set test variable    @{RI_MONITOR_S_SLOT_LIST}
    set test variable    @{RI_MONITOR_UL_SLOT_LIST}
    set test variable    ${TDD_DL_EXP_TPUT}     ${TDD_DL_EXP_TPUT_20M_1116}
    set test variable    ${TDD_UL_EXP_TPUT}     ${TDD_UL_EXP_TPUT_20M_1116}
    set test variable    ${transmission_window}     6min
    set test variable    ${frameStructureBW}     1116_0ms_4gp_20MHZ
    set test variable    ${dlMuteSlotsStr}     ${DL_MUTE_SLOTS_SPECIAL_2PRECEDING}
    ${exp_dl_tput_gap}   evaluate    ${TDD_DL_EXP_TPUT}*0.03
    ${exp_ul_tput_gap}   evaluate    ${TDD_UL_EXP_TPUT}*0.03
    set test variable    ${exp_dl_tput_gap}
    set test variable    ${exp_ul_tput_gap}
    set test variable    ${UL_SLOT_LIST}    ${UL_SLOT_LIST_1116_0}
    ${SU_DETECTION_ENABLE_SLOT_LIST}    create list    ${3}   ${4}   ${13}   ${14}
    ${SUU_DETECTION_ENABLE_SLOT_LIST}    create list    ${3}   ${4}   ${5}   ${13}   ${14}   ${15}
    ${DETECTION_DISABLE_SLOT_LIST}    create list    ${5}   ${15}
    set test variable    ${DETECTION_DISABLE_SLOT_LIST}
    set test variable    ${SU_DETECTION_ENABLE_SLOT_LIST}
    set test variable    ${SUU_DETECTION_ENABLE_SLOT_LIST}
    ${cm_rimrssetid_state}    Set Variable If    '${PROGRAM}'>='25R3'    on    off
    ${cm_dlmuting_state}    Set Variable If    '${PROGRAM}'>='25R3'    on    off
    set test variable    ${cm_rimrssetid_state}
    set test variable    ${cm_dlmuting_state}

Enable fault 7527 fault 7535 CM on and check NRRIMINFO
    [Documentation]    Enable dlMutingReport and rimRsStateReport cm on
    ...    Author: Wu Rong
    run keyword and continue on failure    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${ENABLE_DLMUTING_RIMRS_CM_ON}     skip_parameter_relation_errors=${False}
    ...    connection=${OAM_ALIAS_GNB0}    timeout=120
    run keyword and continue on failure    Wait and Get NRRIMINFO via WEBEM and Check NRRIMINFO Value is as Expected
    ...    asymmetricState=${None}    riState=${None}    rimRsSetIdType1=11160    rimRsSetIdType2=11160
    ...    pdcchMutingStatus=${None}    pdschMutingStatus=${2DL_S_MUTING}
