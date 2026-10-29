*** Settings ***
Force Tags      CLOUD_5G_I_LN_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Documentation
...
...             author:            Kiran Vilas Gawade, kiran.vilas_gawade@nokia.com
...             maintainer:        Kiran Vilas Gawade, kiran.vilas_gawade@nokia.com
...
...             INTRODUCTION:     This testcase describes the gNB behaviour for UE in RRC_INACTIVE state
...                         that is successfully transitioned to RRC_CONNECTED state in case of UE context or DRB resource
...                         shortage and ARP-based preemption enabled. Successful Resume procedure.
...             TEST SET NAME:    Use case of the the gNB behaviour for UE in RRC_INACTIVE state that is successfully transitioned
...                     to RRC_CONNECTED state in case of UE context or DRB resource shortage and ARP-based preemption enabled.
...             TESTING SPLIT:    See CB008225 testplan split I
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008225 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_18316

Resource         resources/LN_CB008225_resource.robot

Suite Setup         Run keywords      Suite setup from scratch
...              AND     Perform SCF Delta Commissioning with Delta_Config_NonRANsha_InactBased_UeLevel_UePreemption_gLN_apLO_TDD.json
...                 AND     sleep    180
...                 AND     gnb.Perform gNB reboot
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Kill WTS processes Using WTS_Runner
...                 AND     Stop Log       snapshot

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_2CC_gLN-apLO_tdd_preemption.cfg
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
${end_ue_id}      ${3}
${delta}       30
${tp_duration}      40
${inactivity_timer}      100
# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                6_gfbr_ul=10   6_gfbr_dl=20    6_mfbr_ul=40     6_mfbr_dl=50
...                                 7_gfbr_ul=10   7_gfbr_dl=20    7_mfbr_ul=40     7_mfbr_dl=50
...                                 3_gfbr_ul=10   3_gfbr_dl=20    3_mfbr_ul=40     3_mfbr_dl=50
#Make sure VONR Traffic profile should in kbps for 5QI1 and 5QI 5 i.e QFI 2 and 3
@{QOS_Prof1}               1     #5QI 6    ARP(7)
@{QOS_Prof1_speed_dl}      10
@{QOS_Prof1_speed_ul}      1
@{QOS_Prof1_unit}          mbps

@{QOS_Prof2}               1       22            #5QI 9     ARP(9)
@{QOS_Prof2_speed_dl}      10       10
@{QOS_Prof2_speed_ul}      10       10
@{QOS_Prof2_unit}          mbps     mbps

${duration}      600
${trf_id}      ${1}

*** Test Cases ***

[1][1.0] CB008225-I_B1_1-Successful transition of suspended UE in RRC_INACTIVE state to RRC_CONNECTED with DRB preemption limit maxNumOfRrcSA TDD_LN

    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
#    Modify NIDD parameters     paramName=maxNumOfRrcSA       paramValue=3       operation=update       paramDst=MRBTS-1/NRBTS-1/NRCELL-1
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof1}                ${2}=${QOS_Prof2}             ${3}=${QOS_Prof1}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul}       ${2}=${QOS_Prof2_speed_ul}    ${3}=${QOS_Prof1_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl}       ${2}=${QOS_Prof2_speed_dl}    ${3}=${QOS_Prof1_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof1_unit}           ${2}=${QOS_Prof2_unit}        ${3}=${QOS_Prof1_unit}
    ${cnai}                  Create Dictionary           ${1}=on                     ${2}=on                       ${3}=on
    ${state}                  Create Dictionary          ${1}=inactive               ${2}=active                   ${3}=active
    ${trigger}             Create Dictionary             ${1}=uldata                  ${2}=uldata                    ${3}=uldata

    Start Log      btslog     cprt
    ${ue_to_bearer_list}=      MultiUE Register should be Successful with CNAI     ${start_ue_id}    ${end_ue_id}      cnai=${cnai}
    Start Data Transfer     ${start_ue_id}     ${end_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    PDU Modfication and Deletion of other PDU       2       2      1     qosflows_to_add=22       qosflows_to_del=1
    sleep   ${delta}s
    ${inactivity_start}     Stop MultiUE Data Traffic for SA with timestamp        ${start_ue_id}    ${end_ue_id}      ${qos_profile}      ${state}
    Modify NIDD parameters     paramName=maxNumOfRrcSA       paramValue=2       operation=update       paramDst=MRBTS-1/NRBTS-1/NRCELL-1
    Sleep till inactivity timer expiry
    ${full_rnti_list}      ${inactivity_stop}     Check MultiUE RRC State       ${start_ue_id}    ${end_ue_id}        state=${state}
    ${cause_list}       Trigger RRC Resume        ${start_ue_id}       ${end_ue_id}        ${state}        ${trigger}
    Start Data Transfer     1     1     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    ${scen1}     Stop Log      btslog     cprt

    ${inactivity_timer_cal}        Verify Inactivity Timer         ${start_ue_id}       ${end_ue_id}            ${state}
         ...      ${inactivity_start}        ${inactivity_stop}        ${delta}        ${inactivity_timer}
    Verify MultiUE Cplane messages from pcap       ${scen1}[cprt]/NODECPRT_GNB.pcap        1        1
    ...       ${qos_profile}          ${full_rnti_list}          ${state}       ${split}      ${cause_list}        activityNotify=uE
    Verify UE released due to preemption        ${scen1}[cprt]/NODECPRT_GNB.pcap          2

    [Teardown]  Run Keywords   Log To console  TCTeardown
    ...         AND        Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
PDU Modfication and Deletion of other PDU
     [Arguments]          ${start_ue_id}     ${end_ue_id}      ${pdu_id}     ${qosflows_to_add}     ${qosflows_to_del}
     FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
     wtsrunner.ue_pdu_session_modify      ue=${ue_idx}       pdu=${pdu_id}    qosflows_to_add=${qosflows_to_add}
     ...           qosflows_to_del=${qosflows_to_del}       by=amf
     ${output}    Read WTS Output Until Pattern Matches    .*Added QosFlow with QFI:2 fiveQI:9*.     ${Timeout_SA}
     Print Matching Lines from Output File    ${output}    .*Deleting QosFlow with QFI:1 5QI:6*.
     Print Matching Lines from Output File    ${output}    .*Added QosFlow with QFI:2 fiveQI:9*.
     Log to Console  ${Pdu_session_mod_patten}
     wtsrunner.trf_data_start     ue=${ue_idx}     pdu=${pdu_id}   qfi=2    dir=dl    trf_id=1     mbps=10
     ${output1}   Read WTS Output For Pattern And Print matching Lines      .*UE${ue_idx}: Started Downlink Internal traffic Receiver*.
     ...          ${Timeout_SA}
     END

Verify UE released due to preemption
	[Arguments]    ${pcap_file}         ${idx}=${ue_idx}
    ${pdmlFile}=   Fetch filtered PDML file from pcap    ${pcap_file}         filterExp=ngap.UEContextReleaseRequest_element
    ...              filterName=UE_${idx}_preemption
    ${rel_cause}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=ngap.UEContextReleaseRequest_element
    ...                                                path=ngap.radioNetwork
    ...                                                endPacket=-${1}
    ...                                                kind=show
    List Should Contain Value            ${rel_cause}         46
    Log to Console      Verified UE ${idx} preemption

