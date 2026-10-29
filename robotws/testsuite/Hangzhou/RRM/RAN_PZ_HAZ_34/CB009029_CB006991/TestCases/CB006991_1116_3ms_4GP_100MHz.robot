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
${DL_TPUT}         1600M
${UL_TPUT}         300M

*** Test Cases ***
CB006991-SR-F_TC012_DL mitigation adaptaion based on multiple detected RIM-RS type 1 signals with CB009007 enable_1116-3ms-4GP
    [Tags]    CRT_TRUNK
    [Documentation]     Author: Cheng Catherine
    ...    Description:The purpose of this test is to verify RI trigger and DL mitigation,
    ...    then gNB stops DL mitigation when RI and RIM-RS disappear with 1116 3ms 100MHz
    ...    SPECIAL_SLOT_LIST_1116_3 defined in CB006991_variabled.robot, CONFIG_1116_3MS_4GP_100MHZ defined in NIDD_modify_scf.py
    ...    step 1>  UE attach and start DL traffic at victim side, check Special+DL symbols all scheduled
    ...    step 2>  wait and check fault 7525 raised and check RI from syslog, check RI info from PCMD log
    ...    step 3>  wait and check fault 7527 raised and check RIMRS info from PCMD log
    ...    step 4>  capture bip log and check DL mitigation(S+DL sysmbol muted) from bip log
    ...    step 5>  change nrRimMitigationScheme to no mitigation, check fault info and DL mitigation stopped from bip
    ...    step 6>  lock aggressor cell, wait and verify fault 7525 & 7527 disappeared, and present from history alarm list
    ...    step 7>  capture bip log, and stop DL traffic and check Special+DL symbols all scheduled from bip log

    [Setup]     6991 case setup    frame_bw=${STR_1116_3MS_4GP_100MHZ}
    @{RI_MONITOR_S_SLOT_LIST}    set variable if    '${PROGRAM}'<'25R1'    ${RI_MONITOR_S_SLOT_LIST_1116_3}   ${RI_MONITOR_S_SLOT_LIST_1116_3_V2}
    @{RI_MONITOR_UL_SLOT_LIST}    set variable if    '${PROGRAM}'<'25R1'    ${RI_MONITOR_UL_SLOT_LIST_1116_3}   ${RI_MONITOR_UL_SLOT_LIST_1116_3_V2}
    set test variable    @{SPECIAL_SLOT_LIST}    @{SPECIAL_SLOT_LIST_1116_3}
    set test variable    @{MUTE_SLOT_LIST}    @{SPECIAL_SLOT_LIST_1116_3}
    set test variable    @{RI_MONITOR_S_SLOT_LIST}
    set test variable    @{RI_MONITOR_UL_SLOT_LIST}
    set test variable    ${CONFIGS}    ${CONFIG_1116_3MS_4GP_100MHZ}
    set test variable    ${TDD_DL_EXP_TPUT}     ${TDD_DL_EXP_TPUT_100M}
    set test variable    ${TDD_UL_EXP_TPUT}     ${TDD_UL_EXP_TPUT_100M}
    ${exp_dl_tput_gap}   evaluate    ${TDD_DL_EXP_TPUT}*0.03
    ${exp_ul_tput_gap}   evaluate    ${TDD_UL_EXP_TPUT}*0.03
    set test variable    ${exp_dl_tput_gap}
    set test variable    ${exp_ul_tput_gap}

    log to console    step 1: Make L3 call and Check no DL Mitigation before RI for 1116 3ms 100MHz, then Unlock aggressor cells
    Steps Make L3 call and Check no DL Mitigation before RI   before_ri=${True}
    run keyword and continue on failure    Unlock cells
    Set aggressor targetTotalLoad via restAPI   paras=${RESTAPI_MODIFY_TARGET_TOTAL_LOAD}

    log to console    step 2: Check fault 7525 raised and check RI from syslog, check RI info from PCMD log
    Steps Check Fault 7525 raised and RI PCMD When RI   framestructure=${CONFIGS["frameStructureBW"]}
                                                ...    transmission_window=${CONFIGS["transmission_window"]}
                                                ...    near_far=${CONFIGS["near_far"]}
                                                ...    repetition=${CONFIGS["repetitionRsType1"]}
                                                ...    ri_monitor_special_slot_list=${RI_MONITOR_S_SLOT_LIST}
                                                ...    ri_monitor_ul_slot_list=${RI_MONITOR_UL_SLOT_LIST}
                                                ...    check_ri_pcmd=${False}

    log to console    step 3-4: Check fault 7527 raised and RIMRS PCMD log, then make call and check DL mitigation from bip log
    Steps Check Fault 7527 raised and RIMRS PCMD and DL Mitigation started from Bip When RI with update p0 if needed

    log to console    step 5: change to no mitigation, check fault info and DL mitigation stopped from bip
    Steps Change Rim Mitigation Scheme to no Mitigation and Check no DL Mitigation When RI    SetId_Aggressor=${CONFIGS["rsSetIdAggressor"]}
    ...    dlMuteSlotsStr=${CONFIGS["dlMuteSlotsStr"]}     setId_show_in_fault=${True}

    log to console    step 6-7: start to lock aggressor cell and check if alsrm 7525 & 7527 canceled
    run keyword if   '${PROGRAM}'>'23R4'
                ...    Steps Trigger RI Disappear but RIMRS exist then Check Fault 7525 7527 canceled and DL Mitigation stopped
                                                                    ...    SetId_Aggressor=${CONFIGS["rsSetIdAggressor"]}
                                                                    ...    dlMuteSlotsStr=${None}
                                                                    ...    check_bip_needed=${True}
                                                                    ...    after_ri=${True}
                                                                    ...    rs_detect_duration_without_Ri=${MIN_RS_DETECTION_DURATION_WO_RI}
                                                                    ...    srs_check=exist
                                                                    ...    exp_dl_tput_gap=${exp_dl_tput_gap}
                                                                    ...    exp_ul_tput_gap=${exp_ul_tput_gap}
                                                                    ...    setId_show_in_fault=${True}
    ...    ELSE    Steps Trigger RI Disappear and Check Fault 7525 7527 canceled and DL Mitigation stopped
                                                                    ...    SetId_Aggressor=${CONFIGS["rsSetIdAggressor"]}
                                                                    ...    dlMuteSlotsStr=${None}
                                                                    ...    srs_check=exist


    [Teardown]  run keyword and ignore error    6991 case teardown   detach_ue=${True}
    ...   unlock_cell=${False}    targetTotalLoad=${True}


*** Keywords ***
Steps Check Fault 7527 raised and RIMRS PCMD and DL Mitigation started from Bip When RI with update p0 if needed
    [Documentation]    Check fault 7527 raised and RIMRS PCMD and DL Mitigation started from Bip When RI with update p0 if needed
    run keyword if    '${tl.gnbs[0].instance_id}'=='4294967184'    coam_gnb_classical.COAM Update several parameters via rest api
                                                 ...    parameters_to_update_via_api=${RESTAPI_p0NominalPusch}
                                                 ...    skip_parameter_relation_errors=${False}
                                                 ...    connection=${OAM_ALIAS_GNB0}

    Steps Check Fault 7527 raised and RIMRS PCMD and DL Mitigation started from Bip When RI   SetId_Aggressor=${CONFIGS["rsSetIdAggressor"]}
                                                                                ...    dlMuteSlotsStr=${CONFIGS["dlMuteSlotsStr"]}
                                                                                ...    repetitionRsType1=${CONFIGS["repetitionRsType1"]}
                                                                                ...    setId_show_in_fault=${True}
                                                                                ...    check_rimrs_pcmd=${True}
                                                                                ...    srs_check=not exist

    [Teardown]    run keyword if   '${tl.gnbs[0].instance_id}'=='4294967184'   coam_gnb_classical.COAM Update several parameters via rest api
                                                 ...    parameters_to_update_via_api=${RESTAPI_p0NominalPusch_back}
                                                 ...    skip_parameter_relation_errors=${False}
                                                 ...    connection=${OAM_ALIAS_GNB0}
