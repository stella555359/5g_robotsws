*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_FDD
...             CIT    CDRT   RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS23R3    CONFIGURED

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



Suite Setup         Run keywords    Prepare TL with all config files
...                 AND    Run Keyword and Ignore Error      Suite setup from scratch
#Suite Setup         Run keywords     Run Keyword and Ignore Error      Suite setup from scratch
...                 AND    Add routes
...                 AND    gnb.Perform gNB reboot
...                 AND    Sleep   500s    reason=wait for RMOD to comeup
...                 AND    Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND    sleep  60s   reason=wait for mib sib

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
#...                 AND     Link SCOUT SCF to Configuration ID for Reporting
...                 AND     Kill WTS processes Using WTS_Runner

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_c_b3_5.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        51
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TEST_NAME}        test_case
${cause}      2
${start_ue_id}      ${51}
${end_ue_id}      ${51}
${delta}       30
${tp_duration}      40
${inactivity_timer}      100
${SCFC}=                   ${CURDIR}/config/SBTS24R3/C_B3_5_PagingCounters_scf.xml
${AP_XML}=                 ${CURDIR}/config/wts/C_B3_5_PagingCounters_iphy.xml

# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                6_gfbr_ul=10   6_gfbr_dl=20    6_mfbr_ul=40     6_mfbr_dl=50
...                                 7_gfbr_ul=10   7_gfbr_dl=20    7_mfbr_ul=40     7_mfbr_dl=50
...                                 3_gfbr_ul=10   3_gfbr_dl=20    3_mfbr_ul=40     3_mfbr_dl=50
#Make sure VONR Traffic profile should in kbps for 5QI1 and 5QI 5 i.e QFI 2 and 3
@{QOS_Prof1}               1     #5QI 6
@{QOS_Prof1_speed_dl}      10
@{QOS_Prof1_speed_ul}      10
@{QOS_Prof1_unit}          mbps

@{QOS_Prof2}               1       5            #5QI 3
@{QOS_Prof2_speed_dl}      1       5
@{QOS_Prof2_speed_ul}      1       5
@{QOS_Prof2_unit}          mbps     mbps

@{QOS_Prof3}               1        6            #5QI 4
@{QOS_Prof3_speed_dl}      1        30
@{QOS_Prof3_speed_ul}      1        30
@{QOS_Prof3_unit}          mbps     mbps

${duration}      60
${trf_id}      ${1}

*** Test Cases ***

[1.0] CB008225_C_B3_5 Verify M55331C00004 counters are updated for UE in RRC Inactive State - Inactivity based - DL user data from UPF_5QI6-3_FDD_LO

    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
    Wait until the next Measurement Period starts  additional_time=${0}
    ${qos_profile}               Create Dictionary   ${51}=${QOS_Prof1}                ${52}=${QOS_Prof2}             ${53}=${QOS_Prof3}
    ${qos_profile_speed_ul}      Create Dictionary   ${51}=${QOS_Prof1_speed_ul}       ${52}=${QOS_Prof2_speed_ul}    ${53}=${QOS_Prof3_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${51}=${QOS_Prof1_speed_dl}       ${52}=${QOS_Prof2_speed_dl}    ${53}=${QOS_Prof3_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${51}=${QOS_Prof1_unit}           ${52}=${QOS_Prof2_unit}        ${53}=${QOS_Prof3_unit}
    ${cnai}                  Create Dictionary           ${51}=on                     ${52}=on                       ${53}=on
    ${state}                  Create Dictionary          ${51}=inactive               ${52}=inactive                  ${53}=inactive
    Start Log      btslog     cprt
    ${ue_to_bearer_list}=      MultiUE Register should be Successful with CNAI     ${start_ue_id}    ${end_ue_id}      cnai=${cnai}
    Create Modify PDU session   ${start_ue_id}    ${end_ue_id}    ${qos_profile}   pdu_id=1
    ...     gfbr_mfbr_profile=${gfbr_mfbr_profile}                       ue_to_bearer_list=${ue_to_bearer_list[1]}
    Start Data Transfer     ${start_ue_id}     ${end_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${delta}s
    ${inactivity_start}     Stop MultiUE Data Traffic for SA with timestamp      ${start_ue_id}    ${end_ue_id}     ${qos_profile}     state=${state}
    ${tp_read}          Verify data transfer and get tp gbr_nongbr      ${start_ue_id}     ${end_ue_id}
    ...     ${delta}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    Sleep till inactivity timer expiry
    ${full_rnti_list}      ${inactivity_stop}     Check MultiUE RRC State       ${start_ue_id}    ${end_ue_id}        state=${state}
    Trigger DL Data split-C       ${start_ue_id}       ${end_ue_id}        ${state}
    ${scen1}     Stop Log      btslog     cprt
    sleep   300s
    Wait until the current Measurement Period stops  additional_time=${0}
    Get Paging counters and validate       M55331C00004     M55124C00007     M55306C06002     value_expected=1      cellid=3

    ${inactivity_timer_cal}        Verify Inactivity Timer         ${start_ue_id}       ${end_ue_id}            ${state}
         ...      ${inactivity_start}        ${inactivity_stop}        ${delta}        ${inactivity_timer}
 #   Verify MultiUE Cplane messages from pcap       ${scen1}[cprt]/NODECPRT_GNB.pcap       ${start_ue_id}      ${end_ue_id}
 #   ...       ${qos_profile}          ${full_rnti_list}          ${state}        activityNotify=dRB
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting


*** Keywords ***

Trigger DL Data split-C
    [Arguments]     ${start_ue_id}    ${end_ue_id}       ${state}
   	FOR     ${idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
   	Run Keyword If  '${state[${idx}]}' == 'active' or '${state[${idx}]}' == 'idle'       Continue For Loop
#    wtsrunner.ue_nr_rrc_resume_request_param         id=${ue_idx}         cause=mt_Access
    wtsrunner.trf_data_start     ue=${idx}     pdu=1   qfi=1    dir=dl    trf_id=1     mbps=20
    Log to Console          UE ${idx}  Trigger DL Data
    END



Add routes
    [Documentation]    This keyword is to configure VM interfaces..
    Run    sudo ip addr add 10.0.1.132/24 dev eth3
    Run    sudo ip addr add 10.0.1.133/24 dev eth3
    Run    sudo ip addr add 10.0.1.131/24 dev eth3
    Run    sudo ip addr add 10.0.1.134/24 dev eth3
    Run    sudo ip addr add 10.0.1.135/24 dev eth3
    Run    sudo ip addr add 10.0.1.136/24 dev eth3
    Run    sudo ip addr add 10.0.1.99/24 dev eth3
    Run    sudo ip addr add 10.0.1.121/24 dev eth3
    Run    sudo ip addr add 10.0.1.137/24 dev eth3
    Run    sudo ip addr add 10.0.1.3/24 dev eth3
    Run    sudo ip addr add 10.0.1.4/24 dev eth3
    Run    sudo ip addr add 10.0.1.61/24 dev eth3
    Run    sudo ip addr add 10.0.1.62/24 dev eth3
    Run    sudo ip addr add 10.0.1.138/24 dev eth3
    Run    sudo ip addr add 10.0.1.139/24 dev eth3
    Run    sudo ip addr add 10.0.1.140/24 dev eth3
    Run    sudo ip addr add 10.0.1.141/24 dev eth3



