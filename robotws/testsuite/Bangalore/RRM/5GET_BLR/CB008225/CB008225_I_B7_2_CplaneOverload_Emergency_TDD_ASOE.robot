*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Documentation
...
...             author:            Kiran Vilas Gawade, kiran.vilas_gawade@nokia.com
...             maintainer:        Kiran Vilas Gawade, kiran.vilas_gawade@nokia.com
...
...             INTRODUCTION:     This testcase describes the counter update for UE in RRC_INACTIVE state
...                               that is successfully transitioned to RRC_CONNECTED state for resumeCause Emergency
...                               Connection (EM) during C-Plane Overload
...             TEST SET NAME:    Use case of the testcase describes the gNB behavior for UE in RRC_INACTIVE state that
...                              successfully transitioned to RRC_CONNECTED state for resumeCause Emergency Connection (EM) during C-Plane Overload
...             TESTING SPLIT:    See CB008225 testplan split I
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008225 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_18354

Resource         resources/CB008225_resource.robot

Suite Setup         Run keywords    Suite setup from scratch
...                 AND     Add RD Parameters To GNB Swconfig File      ${radparam}
...              AND     Perform SCF Delta Commissioning with Delta_Config_NonRANsha_InactBased_UeLevel_gASOE_apLO_TDD_Emergency.json
...                 AND     sleep    180
...                 AND     gnb.Perform gNB reboot
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Kill WTS processes Using WTS_Runner
...                 AND     Stop Log       snapshot

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_2CC_gASOE-apLO_tdd_emergency.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
#${TRF_ID}    1
${TEST_NAME}        test_case
${split}     fallback
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
@{QOS_Prof1_speed_dl}      10
@{QOS_Prof1_speed_ul}      10
@{QOS_Prof1_unit}          mbps

@{QOS_Prof2}               1       5            #5QI 3
@{QOS_Prof2_speed_dl}      1       20
@{QOS_Prof2_speed_ul}      1       20
@{QOS_Prof2_unit}          mbps     mbps

${duration}      60
${trf_id}      ${1}
${radparam}                SEPARATOR=${EMPTY}    0x890073 = 0

*** Test Cases ***

[1][1.0] CB008225-I_B7_2 - RRCResumeRequest1 for resumeCause for EM during C-Plane Overload (Success) with NRRCC_RRC_RESUME Counters TDD_ASOE

    set test variable      ${LOG_PATH}
#    Perform SCF Delta Commissioning with temp_Online_Delta_Config_NonRANsha_InactBased_UeLevel_gASOE_apLO_TDD.json
    Wait until the next Measurement Period starts  additional_time=${0}
    log to console   UE attach trigerring now...
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof1}                ${2}=${QOS_Prof2}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul}       ${2}=${QOS_Prof2_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl}       ${2}=${QOS_Prof2_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof1_unit}           ${2}=${QOS_Prof2_unit}
    ${cnai}                  Create Dictionary           ${1}=on                     ${2}=on
    ${state}                  Create Dictionary          ${1}=inactive               ${2}=inactive
    ${trigger}             Create Dictionary             ${1}=emergency                  ${2}=emergency

    Start Log      btslog     cprt
    ${ue_to_bearer_list}=      MultiUE Register should be Successful with CNAI     ${start_ue_id}    ${end_ue_id}      cnai=${cnai}
    Create Modify PDU session   ${start_ue_id}    ${end_ue_id}    ${qos_profile}   pdu_id=1
    ...     gfbr_mfbr_profile=${gfbr_mfbr_profile}                       ue_to_bearer_list=${ue_to_bearer_list[1]}
    Perform CPLANE OVL activation via R&D mechanism
    Start Data Transfer     ${start_ue_id}     ${end_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${delta}s
    ${inactivity_start}     Stop MultiUE Data Traffic for SA with timestamp        ${start_ue_id}    ${end_ue_id}      ${qos_profile}      ${state}
    ${tp_read}          Verify data transfer and get tp gbr_nongbr      ${start_ue_id}     ${end_ue_id}
    ...     ${delta}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    Perform SCF Delta Commissioning with Online_Delta_Config_NonRANsha_InactBased_UeLevel_gASOE_apLO_TDD.json
    Sleep till inactivity timer expiry
    ${full_rnti_list}      ${inactivity_stop}     Check MultiUE RRC State       ${start_ue_id}    ${end_ue_id}        state=${state}
    sleep   100s
    ${cause_list}       Trigger RRC Resume        ${start_ue_id}       ${end_ue_id}        ${state}        ${trigger}
    Start Data Transfer     ${start_ue_id}     ${end_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${delta}s
    ${scen1}     Stop Log      btslog     cprt
    sleep   300s
    Wait until the current Measurement Period stops  additional_time=${0}
    Get Fallback counters and validate       M55124C00007     M55124C00013      M55124C00014     M55306C06002       value_expected=2
    ${inactivity_timer_cal}        Verify Inactivity Timer         ${start_ue_id}       ${end_ue_id}            ${state}
         ...      ${inactivity_start}        ${inactivity_stop}        ${delta}        ${inactivity_timer}
    Verify MultiUE Cplane messages from pcap       ${scen1}[cprt]/NODECPRT_GNB.pcap       ${start_ue_id}      ${end_ue_id}
    ...       ${qos_profile}          ${full_rnti_list}          ${state}       ${split}      ${cause_list}        activityNotify=uE
    Verify UE Successful ICS due to fallback cause emergency       ${scen1}[cprt]/NODECPRT_GNB.pcap         ${4}

    [Teardown]  Run Keywords   Log To console  TCTeardown
    ...         AND        Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Verify UE Successful ICS due to fallback cause emergency
	[Arguments]    ${pcap_file}         ${count}
    ${pdmlFile}   Fetch filtered PDML file from pcap      ${pcap_file}        filterExp=ngap.InitialContextSetupResponse_element       filterName=ICS
    ${ICS_pkt}    analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=ngap.InitialContextSetupResponse_element
    ...                                                path=ngap.InitialContextSetupResponse_element
    ...                                                pkt_count=${1}
    Should Be Equal           ${ICS_pkt}          ${count}
    Log to Console      Verified UE Successful ICS due to fallback cause emergency
