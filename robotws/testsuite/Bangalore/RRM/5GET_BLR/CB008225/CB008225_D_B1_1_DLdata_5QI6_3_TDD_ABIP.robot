*** Settings ***
Force Tags      CLOUD_5G_I_LN_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CIT    CDRT   RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS23R1    SBTS23R2    CONFIGURED

Documentation
...
...             author:            Kiran Vilas Gawade, kiran.vilas_gawade@nokia.com
...             maintainer:        Kiran Vilas Gawade, kiran.vilas_gawade@nokia.com
...
...             INTRODUCTION:     This testcase describes RAN Paging for the UEs in RRC_INACTIVE state
...                               for DL user plane data arrival from UPF. Successful scenario
...             TEST SET NAME:    Use case of the Test case is to verify successful RAN paging for
...                               Inactive mode UE and UE should send RRC Resume Request1 for DL user data.
...                               Verify gNB counters incremented after test execution
...             TESTING SPLIT:    See CB008225 testplan split C
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008225 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_18017,5G_RAN_USR_RRM_18015,5G_RAN_USR_RRM_18717,5G_PM_969

Resource         resources/CB008225_resource.robot

Suite Setup         Run keywords    Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with Delta_Config_RANsha_InactBased-Uelevel_ABIP-apLO_TDD.json
...                 AND     sleep    180
...                 AND     gnb.Perform gNB reboot
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}

Suite Teardown      Run Keywords        Log To console  Suitetardown
...                 AND     Kill WTS processes Using WTS_Runner

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_2CC_gABIP-apLO_tdd_ref.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
#${TRF_ID}    1
${TEST_NAME}        test_case
${split}        resume
${start_ue_id}      ${1}
${end_ue_id}      ${2}
${delta}       30
${tp_duration}      40
${inactivity_timer}      100
# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                6_gfbr_ul=10   6_gfbr_dl=20    6_mfbr_ul=40     6_mfbr_dl=50
...                                 7_gfbr_ul=10   7_gfbr_dl=20    7_mfbr_ul=40     7_mfbr_dl=50
...                                 3_gfbr_ul=10   3_gfbr_dl=20    3_mfbr_ul=40     3_mfbr_dl=50
#Make sure VONR Traffic profile should in kbps for 5QI1 and 5QI 5 i.e QFI 2 and 3
@{QOS_Prof1}               1     #5QI 6
@{QOS_Prof1_speed_dl}      1
@{QOS_Prof1_speed_ul}      1
@{QOS_Prof1_unit}          mbps

@{QOS_Prof2}               1       5            #5QI 3
@{QOS_Prof2_speed_dl}      1       5
@{QOS_Prof2_speed_ul}      1       5
@{QOS_Prof2_unit}          mbps     mbps

${duration}      60
${trf_id}      ${1}
&{nwslices}    ${1}=1    ${2}=2    ${3}=2

*** Test Cases ***

[1][1.0] CB008225_D_B1_1 Successful RESUME procedure for UE in RRC Inactive State - Inactivity based - DL User Data_5QI6-3_TDD_LN

    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
    Wait until the next Measurement Period starts  additional_time=${0}
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof1}                ${2}=${QOS_Prof2}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul}       ${2}=${QOS_Prof2_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl}       ${2}=${QOS_Prof2_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof1_unit}           ${2}=${QOS_Prof2_unit}
    ${cnai}          Create Dictionary         ${1}=on                      ${2}=on
    ${state}         Create Dictionary         ${1}=inactive                ${2}=inactive
    ${trigger}       Create Dictionary         ${1}=dldata_ranpaging        ${2}=dldata_ranpaging
    ${qos}           Create Dictionary         ${1}=ngbr                       ${2}=gbr

    Start Log      btslog     cprt
    ${ue_to_bearer_list}      MultiUE Register should be Successful with CNAI     ${start_ue_id}    ${end_ue_id}      cnai=${cnai}
    Create Modify PDU session   ${start_ue_id}    ${end_ue_id}    ${qos_profile}   pdu_id=1
    ...     gfbr_mfbr_profile=${gfbr_mfbr_profile}                       ue_to_bearer_list=${ue_to_bearer_list[1]}
    Start Data Transfer     ${start_ue_id}     ${end_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${delta}s
    ${inactivity_start}     Stop MultiUE Data Traffic for SA with timestamp        ${start_ue_id}    ${end_ue_id}      ${qos_profile}      ${state}
    ${tp_read}          Verify data transfer and get tp gbr_nongbr      ${start_ue_id}     ${end_ue_id}
    ...     ${delta}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    Reset Bearer Stats        ${start_ue_id}        ${end_ue_id}
    Sleep till inactivity timer expiry
    ${full_rnti_list}      ${inactivity_stop}     Check MultiUE RRC State       ${start_ue_id}    ${end_ue_id}        state=${state}
    ${cause_list}       Trigger RRC Resume        ${start_ue_id}       ${end_ue_id}        ${state}        ${trigger}     ${qos}
    Start Data Transfer     ${start_ue_id}     ${end_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${duration}s
    ${tp_read1}          Verify data transfer and get tp gbr_nongbr      ${start_ue_id}     ${end_ue_id}
    ...     ${duration}   both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    ${scen1}     Stop Log      btslog     cprt    test_scenario=SCN_1

    sleep   300s
    Wait until the current Measurement Period stops  additional_time=${0}
    Get Resume counters and validate        M55124C00007        M55124C00010        M55306C06002        M55138C00059      value_expected=2
    ${inactivity_timer_cal}        Verify Inactivity Timer         ${start_ue_id}       ${end_ue_id}            ${state}
         ...      ${inactivity_start}        ${inactivity_stop}        ${delta}        ${inactivity_timer}
    Verify MultiUE Cplane messages from pcap       ${scen1}[cprt]/NODECPRT_GNB.pcap       ${start_ue_id}      ${end_ue_id}
    ...       ${qos_profile}          ${full_rnti_list}          ${state}       ${split}      ${cause_list}        activityNotify=uE
    MultiUE Deregister should be Successful   ${start_ue_id}    ${end_ue_id}

    log to console   Inactivity based on UE is per slice - UL User Data
    Perform SCF Delta Commissioning with Delta_Config_NonRANsha_InactBased-DRBlevel-PerSlice_gABIP-apLO_TDD.json

    Set Suite Variable    ${nwslice_ID}      &{nwslices}
    log to console   UE attach trigerring now...
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof1}                ${2}=${QOS_Prof2}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul}       ${2}=${QOS_Prof2_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl}       ${2}=${QOS_Prof2_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof1_unit}           ${2}=${QOS_Prof2_unit}
    ${cnai}          Create Dictionary         ${1}=on                      ${2}=on
    ${state}         Create Dictionary         ${1}=inactive                ${2}=inactive
    ${trigger}       Create Dictionary         ${1}=uldata         ${2}=uldata

    Start Log      btslog     cprt
    ${ue_to_bearer_list}      MultiUE Register should be Successful with CNAI Multi Slice     ${start_ue_id}    ${end_ue_id}      cnai=${cnai}
    Create Modify PDU session   ${start_ue_id}    ${end_ue_id}    ${qos_profile}   pdu_id=1
    ...     gfbr_mfbr_profile=${gfbr_mfbr_profile}                       ue_to_bearer_list=${ue_to_bearer_list[1]}
    Start Data Transfer     ${start_ue_id}     ${end_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${delta}s
    ${inactivity_start}     Stop MultiUE Data Traffic for SA with timestamp        ${start_ue_id}    ${end_ue_id}      ${qos_profile}      ${state}
    ${tp_read}          Verify data transfer and get tp gbr_nongbr      ${start_ue_id}     ${end_ue_id}
    ...     ${delta}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    Reset Bearer Stats     ${start_ue_id}     ${end_ue_id}
    Sleep till inactivity timer expiry
    ${full_rnti_list}      ${inactivity_stop}     Check MultiUE RRC State       ${start_ue_id}    ${end_ue_id}        state=${state}
    ${cause_list}       Trigger RRC Resume        ${start_ue_id}       ${end_ue_id}        ${state}        ${trigger}
    Start Data Transfer     ${start_ue_id}     ${end_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${duration}s
    ${tp_read1}          Verify data transfer and get tp gbr_nongbr      ${start_ue_id}     ${end_ue_id}
    ...     ${duration}   both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    ${scen2}     Stop Log      btslog     cprt    test_scenario=SCN_2

    ${inactivity_timer_cal}        Verify Inactivity Timer         ${start_ue_id}       ${end_ue_id}            ${state}
         ...      ${inactivity_start}        ${inactivity_stop}        ${delta}        ${inactivity_timer}
    Verify MultiUE Cplane messages from pcap       ${scen2}[cprt]/NODECPRT_GNB.pcap       ${start_ue_id}      ${end_ue_id}
    ...       ${qos_profile}          ${full_rnti_list}          ${state}       ${split}      ${cause_list}        activityNotify=dRB

    [Teardown]  Run Keywords   Log To console  TCTeardown
    ...         AND        Link SCOUT SCF to Configuration ID for Reporting



