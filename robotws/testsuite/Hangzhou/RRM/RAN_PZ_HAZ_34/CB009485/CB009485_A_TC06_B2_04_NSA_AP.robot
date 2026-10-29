*** Settings ***
Documentation
...    author:  yuhua.zhu@nokia-sbell.com
...    contact: yuhua.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    tl-CLOUD_5G_I_LO_AP_LO    release-26R1
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
${UTE_WIRESHARK_FLAG}    ${False}
@{PARAMS_IN_SWCONFIG}
...    0x5A0609=1    #L2-HI rdDebugPcmdNrt
...    0x5A0610=1    #L2-HI rdDebugPcmdRt
...    0x5B0609=1    #L2-HI rdDebugPcmdNrt
...    0x5B0610=1    #L2-HI rdDebugPcmdRt
...    0x57000E=1    #enable L2-LO NRT PCMD debug logs
...    0x58057a=4    #L2-PS rdFeatureFlagBitmapLevel 4DEBUG
...    0x58057b=8    #L2-PSrdFeatureFlagBitmap0 8PF_METRIC
...    0x580582=3    #L2-PSrdFeatureFlagBitmap7 3RAT1_ALLOC
...    0x58057f=0x10000000     #L2-PSrdFeatureFlagBitmap4
...    0x890004=0
...    0x890003=0
${BTS_NUMBER}     1

${BTS_STARTUP_RETRY}    4
${DU_BEARER_RECORD_F}    nsetapx.DuVendorExtensionRecordDataType == 13


*** Test Cases ***
CB009485_SR_A_TC06_B2_04 Verify Sucessful NSA gNB-DU reports Bearer Trace Record for MeNB initiated SgNB Modification(E-RABs to be deleted)_multi_UE
    [Documentation]
    ...    Verify Sucessful NSA gNB-DU reports Bearer Trace Record for MeNB initiated SgNB Modification(E-RABs to be deleted)_multi_UE,
    ...    Attach UE31
    ...    Add 3 bearers
	...    Attach UE32
    ...    Add 2 bearers
	...    Attach UE34
    ...    Add 2 bearers
	...    bearer_del_UE31 2 bearers
	...    bearer_del_UE31 1 bearer
	...    bearer_del_UE32 2 bearers
	...    bearer_del_UE34 1 bearer
	[Tags]    QC_61711    Zhu Yuhua
	log to console    step1: attach NSA UE31 and establish 1 bearer
	start to capture wireshark log    attach_31
	UE_Attach   31    2
	Send And Verify Throuput    31    2    1.8    all
	${bearerrecord}    create list    bearerRecord/data/trigger=ctxSetup
    ...                               setupBearers/DuBearerSetupItem/drb-Id=4
    ...                               setupBearers/DuBearerSetupItem/eutran-Qos/qci=9
    ...                               eutran-Qos/arp/priorityLevel=15
    ...                               eutran-Qos/arp/preemptionCapability=shallNotTriggerPreemption
    ...                               eutran-Qos/arp/preemptionVulnerability=notPreemptable
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    attach_31    ${DU_BEARER_RECORD_F}    times=1
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${DU_BEARER_RECORD_F}
    ...                       check_fields=${bearerrecord}
	...                       packet_num=all

	log to console    step2: add 1st bearer
	start to capture wireshark log    bearer_31_add_3
	NSA add drb    31    3
	${bearerrecord}    create list    bearerRecord/data/trigger=ctxModification
    ...                               setupBearers/DuBearerSetupItem/drb-Id=5
    ...                               setupBearers/DuBearerSetupItem/eutran-Qos/qci=[RE].*
    ...                               eutran-Qos/arp/priorityLevel=15
    ...                               eutran-Qos/arp/preemptionCapability=shallNotTriggerPreemption
    ...                               eutran-Qos/arp/preemptionVulnerability=notPreemptable
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    bearer_31_add_3    ${DU_BEARER_RECORD_F}    times=1
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${DU_BEARER_RECORD_F}
    ...                       check_fields=${bearerrecord}
	...                       packet_num=all

	log to console    step3: add 2nd bearer
	start to capture wireshark log    bearer_31_add_4
	NSA add drb    31    4
	${bearerrecord}    create list    bearerRecord/data/trigger=ctxModification
    ...                               setupBearers/DuBearerSetupItem/drb-Id=6
    ...                               setupBearers/DuBearerSetupItem/eutran-Qos/qci=[RE].*
    ...                               eutran-Qos/arp/priorityLevel=15
    ...                               eutran-Qos/arp/preemptionCapability=shallNotTriggerPreemption
    ...                               eutran-Qos/arp/preemptionVulnerability=notPreemptable
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    bearer_31_add_4    ${DU_BEARER_RECORD_F}    times=1
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${DU_BEARER_RECORD_F}
    ...                       check_fields=${bearerrecord}
	...                       packet_num=all

	log to console    step4: add 3rd bearer
	start to capture wireshark log    bearer_31_add_5
	NSA add drb    31    5
	${bearerrecord}    create list    bearerRecord/data/trigger=ctxModification
    ...                               setupBearers/DuBearerSetupItem/drb-Id=7
    ...                               setupBearers/DuBearerSetupItem/eutran-Qos/qci=[RE].*
    ...                               eutran-Qos/arp/priorityLevel=15
    ...                               eutran-Qos/arp/preemptionCapability=shallNotTriggerPreemption
    ...                               eutran-Qos/arp/preemptionVulnerability=notPreemptable
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    bearer_31_add_5    ${DU_BEARER_RECORD_F}    times=1
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${DU_BEARER_RECORD_F}
    ...                       check_fields=${bearerrecord}
	...                       packet_num=all

    log to console    step1: attach NSA UE32 and establish 1 bearer
	start to capture wireshark log    attach_32
	UE_Attach   32    2
	Send And Verify Throuput    32    2    1.8    all
	${bearerrecord}    create list    bearerRecord/data/trigger=ctxSetup
    ...                               setupBearers/DuBearerSetupItem/drb-Id=4
    ...                               setupBearers/DuBearerSetupItem/eutran-Qos/qci=9
    ...                               eutran-Qos/arp/priorityLevel=15
    ...                               eutran-Qos/arp/preemptionCapability=shallNotTriggerPreemption
    ...                               eutran-Qos/arp/preemptionVulnerability=notPreemptable
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    attach_32    ${DU_BEARER_RECORD_F}    times=1
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${DU_BEARER_RECORD_F}
    ...                       check_fields=${bearerrecord}
	...                       packet_num=all

	log to console    step2: add 1st bearer
	start to capture wireshark log    bearer_32_add_4
	NSA add drb    32    4
	${bearerrecord}    create list    bearerRecord/data/trigger=ctxModification
    ...                               setupBearers/DuBearerSetupItem/drb-Id=5
    ...                               setupBearers/DuBearerSetupItem/eutran-Qos/qci=[RE].*
    ...                               eutran-Qos/arp/priorityLevel=15
    ...                               eutran-Qos/arp/preemptionCapability=shallNotTriggerPreemption
    ...                               eutran-Qos/arp/preemptionVulnerability=notPreemptable
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    bearer_32_add_4    ${DU_BEARER_RECORD_F}    times=1
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${DU_BEARER_RECORD_F}
    ...                       check_fields=${bearerrecord}
	...                       packet_num=all

	log to console    step3: add 2nd bearer
	start to capture wireshark log    bearer_32_add_5
	NSA add drb    32    5
	${bearerrecord}    create list    bearerRecord/data/trigger=ctxModification
    ...                               setupBearers/DuBearerSetupItem/drb-Id=6
    ...                               setupBearers/DuBearerSetupItem/eutran-Qos/qci=[RE].*
    ...                               eutran-Qos/arp/priorityLevel=15
    ...                               eutran-Qos/arp/preemptionCapability=shallNotTriggerPreemption
    ...                               eutran-Qos/arp/preemptionVulnerability=notPreemptable
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    bearer_32_add_5    ${DU_BEARER_RECORD_F}    times=1
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${DU_BEARER_RECORD_F}
    ...                       check_fields=${bearerrecord}
	...                       packet_num=all

	log to console    step1: attach NSA UE34 and establish 1 bearer
	start to capture wireshark log    attach_34
	UE_Attach   34    2
	Send And Verify Throuput    34    2    1.8    all
	${bearerrecord}    create list    bearerRecord/data/trigger=ctxSetup
    ...                               setupBearers/DuBearerSetupItem/drb-Id=4
    ...                               setupBearers/DuBearerSetupItem/eutran-Qos/qci=9
    ...                               eutran-Qos/arp/priorityLevel=15
    ...                               eutran-Qos/arp/preemptionCapability=shallNotTriggerPreemption
    ...                               eutran-Qos/arp/preemptionVulnerability=notPreemptable
	${wireshark_log_path}    stop_wireshark_log_after_filter_found    attach_34    ${DU_BEARER_RECORD_F}    times=1
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${DU_BEARER_RECORD_F}
    ...                       check_fields=${bearerrecord}
	...                       packet_num=all

	log to console    step2: add 1st bearer
	start to capture wireshark log    bearer_34_add_4
	NSA add drb    34    4
	${bearerrecord}    create list    bearerRecord/data/trigger=ctxModification
    ...                               setupBearers/DuBearerSetupItem/drb-Id=5
    ...                               setupBearers/DuBearerSetupItem/eutran-Qos/qci=[RE].*
    ...                               eutran-Qos/arp/priorityLevel=15
    ...                               eutran-Qos/arp/preemptionCapability=shallNotTriggerPreemption
    ...                               eutran-Qos/arp/preemptionVulnerability=notPreemptable
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    bearer_34_add_4    ${DU_BEARER_RECORD_F}    times=1
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${DU_BEARER_RECORD_F}
    ...                       check_fields=${bearerrecord}
	...                       packet_num=all

	log to console    step3: add 2nd bearer
	start to capture wireshark log    bearer_34_add_5
	NSA add drb    34    5
	${bearerrecord}    create list    bearerRecord/data/trigger=ctxModification
    ...                               setupBearers/DuBearerSetupItem/drb-Id=6
    ...                               setupBearers/DuBearerSetupItem/eutran-Qos/qci=[RE].*
    ...                               eutran-Qos/arp/priorityLevel=15
    ...                               eutran-Qos/arp/preemptionCapability=shallNotTriggerPreemption
    ...                               eutran-Qos/arp/preemptionVulnerability=notPreemptable
	${wireshark_log_path}    stop_wireshark_log_after_filter_found    bearer_34_add_5    ${DU_BEARER_RECORD_F}    times=1
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${DU_BEARER_RECORD_F}
    ...                       check_fields=${bearerrecord}
	...                       packet_num=all

	start to capture wireshark log    bearer_del_UE31_3_4
	NSA del drb    31    3,4
	${bearerrecord}    create list    bearerRecord/data-r2/trigger=ctxModification
    ...                               releasedBearers/DuBearerReleaseItem/drb-Id=5,6
	${wireshark_log_path}    stop_wireshark_log_after_filter_found    bearer_del_UE31_3_4    ${DU_BEARER_RECORD_F}    times=1
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${DU_BEARER_RECORD_F}
    ...                       check_fields=${bearerrecord}
	...                       packet_num=all

	start to capture wireshark log    bearer_del_UE31_5
	NSA del drb    31    5
	${bearerrecord}    create list    bearerRecord/data-r2/trigger=ctxModification
    ...                               releasedBearers/DuBearerReleaseItem/drb-Id=7
	${wireshark_log_path}    stop_wireshark_log_after_filter_found    bearer_del_UE31_5    ${DU_BEARER_RECORD_F}    times=1
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${DU_BEARER_RECORD_F}
    ...                       check_fields=${bearerrecord}
	...                       packet_num=all

	start to capture wireshark log    bearer_del_UE32_4_5
	NSA del drb    32    4,5
	${bearerrecord}    create list    bearerRecord/data-r2/trigger=ctxModification
    ...                               releasedBearers/DuBearerReleaseItem/drb-Id=5,6
	${wireshark_log_path}    stop_wireshark_log_after_filter_found    bearer_del_UE32_4_5    ${DU_BEARER_RECORD_F}    times=1
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${DU_BEARER_RECORD_F}
    ...                       check_fields=${bearerrecord}
	...                       packet_num=all

	start to capture wireshark log    bearer_del_UE34_4
	NSA del drb    34    4
	${bearerrecord}    create list    bearerRecord/data-r2/trigger=ctxModification
    ...                               releasedBearers/DuBearerReleaseItem/drb-Id=5
	${wireshark_log_path}    stop_wireshark_log_after_filter_found    bearer_del_UE34_4    ${DU_BEARER_RECORD_F}    times=1
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${DU_BEARER_RECORD_F}
    ...                       check_fields=${bearerrecord}
	...                       packet_num=all
    Release Ues    ue_type=all

*** Keywords ***
Perform Steps After Onair
    Start TCE    ${TCE_PORT}

Modify Cfg
    ${set_ue31}    catenate    set_ue simulated id=31 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
	...    eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g imsi=311:489:21645500
    ${set_ue32}    catenate    set_ue simulated id=32 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
    ...    eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g imsi=311:489:21645501
    ${set_ue33}    catenate    set_ue simulated id=33 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
	...    eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g imsi=311:489:21645502
    ${set_ue34}    catenate    set_ue simulated id=34 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
	...    eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g imsi=311:489:21645503
    ${set_ue35}    catenate    set_ue simulated id=35 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00
	...    eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g imsi=311:489:21645507
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    set_bearer id=3 ue=31 qci=8 pdn=1
    Update Cfg    set_bearer id=4 ue=31 qci=7 pdn=1
    Update Cfg    set_bearer id=5 ue=31 qci=6 pdn=1
    Update Cfg    set_bearer id=6 ue=31 qci=5 pdn=1
    Update Cfg    set_bearer id=3 ue=32 qci=8 pdn=1
    Update Cfg    set_bearer id=4 ue=32 qci=7 pdn=1
    Update Cfg    set_bearer id=5 ue=32 qci=6 pdn=1
    Update Cfg    set_bearer id=6 ue=32 qci=5 pdn=1
    Update Cfg    set_bearer id=3 ue=34 qci=8 pdn=1
    Update Cfg    set_bearer id=4 ue=34 qci=7 pdn=1
    Update Cfg    set_bearer id=5 ue=34 qci=6 pdn=1
    Update Cfg    set_bearer id=6 ue=34 qci=5 pdn=1
    Update Cfg    set_bearer id=3 ue=35 qci=8 pdn=1
    Update Cfg    set_bearer id=4 ue=35 qci=7 pdn=1
    Update Cfg    set_bearer id=5 ue=35 qci=6 pdn=1
    Update Cfg    set_bearer id=6 ue=35 qci=5 pdn=1
    Update Cfg    ${set_ue31}
    Update Cfg    ${set_ue32}
    Update Cfg    ${set_ue33}
    Update Cfg    ${set_ue34}
    Update Cfg    ${set_ue35}


UE_Attach
    [Arguments]    ${UE_ID}=31    ${BEARER_ID}=2
    Execute Egate Command    ue_attach id=${UE_ID}    UE IS ACTIVE    timeout=300
    Execute Egate Command    enb_endc_param id=1 serving_cell_index_range_scg=5:31
    Execute Egate Command
    ...    ue_dc_enb_start ue=${UE_ID} target_gnb=2 target_cells=1 bearer=${BEARER_ID} type=split_scg
    ...    Successfully reconfigured dual connectivity    timeout=20s



Send And Verify Throuput
    [Arguments]    ${UE_ID}    ${BEARER_ID}    ${ul_throuput_expect}    ${dcgroup}
    Execute Egate Command    data_trf_start ue=${UE_ID} id=2 dir=dl mbps=2 trf_id=2    UE ${UE_ID}: UDP DL
    Execute Egate Command    data_trf_start ue=${UE_ID} id=2 dir=ul mbps=2    UE ${UE_ID}: UDP UL
    Verify Throuput    ${UE_ID}    ${BEARER_ID}    ${ul_throuput_expect}    ${dcgroup}


Verify Throuput
    [Arguments]    ${UE_ID}    ${BEARER_ID}    ${ul_throuput_expect}    ${dcgroup}    ${sleep_time}=10s
    sleep    ${sleep_time}
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${UE_ID}     bearer_id=${BEARER_ID}    direction=ul    dc_cell_group=${dcgroup}    rate_type=ave
    Should Be True    ${ul_throuput}/1000>=${ul_throuput_expect}
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${UE_ID}     bearer_id=${BEARER_ID}    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>1.8


Stop Traffic
    Execute Egate Command    trf_data_stop ue=31    pass_regexp=Traffic was stopped

UE Detach From GNB
    [Arguments]    ${expect_string}=${EMPTY}
    Execute Egate Command  ue_detach id=31    ${expect_string}

Stop Capture Logs And Restore ENV In Test Teardown
    UE Detach From GNB
    Common Test Teardown And Stop Capture Logs

NSA del drb
    [Arguments]    ${ue_id}=31    ${bearer_id}=3
    Execute Egate Command    bearer_del ue=${ue_id} id=${bearer_id}
	...    pass_regexp=deleted in result of PGW-initiated Bearer Deletion procedure

NSA add drb
    [Arguments]    ${ue_id}=31    ${bearer_id}=3
	Execute Egate Command    bearer_add ue=${ue_id} id=${bearer_id} filter=0 precedence=${bearer_id}
    Execute Egate Command    enb_ue_dc_modify ue=${ue_id} bearer_to_add=${bearer_id} by=enb cause=RN_CauseRadioNetwork_unspecified type=split_scg
    ...    pass_regexp=success-SgNBReconfComp

download and check wireshark fields
    [Arguments]    ${tag}    ${filter}    ${check_fields}
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    ${tag}    ${filter}
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${filter}
    ...                       check_fields=${check_fields}