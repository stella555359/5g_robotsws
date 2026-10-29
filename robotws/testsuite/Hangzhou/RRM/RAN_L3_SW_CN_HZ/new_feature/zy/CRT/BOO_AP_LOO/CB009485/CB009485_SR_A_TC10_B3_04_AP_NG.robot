*** Settings ***
Documentation
...    author: Yan Suzhen
...    contact: susana.yan@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup        Common Suite Setup And Setup Airphone Env And Start TCE
Suite Teardown     Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup         Common Test Setup And Start To Capture Logs
Test Teardown      Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS25R3    tl-CLOUD_5G_I_BOO_AP_LOO
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
${TCE_PORT_GNB1}  49100
# don't change the following setting
${AUTO_ANALYSIS_FLAG}    ${False}
${NRARFCN127180}    127210
@{PARAMS_IN_SWCONFIG}    0x1003F=1    0x10040=1    0x10041=1    0x1002A=1    0x4F0214=0    0x590072=1    0x66001b=1
...    0x890001=1    0x890002=1    0x890003=1    0x890004=1    0x890005=1    0x890006=1    0x890008=1
${DUBearerRecord}     nsetapx.DuVendorExtensionRecordDataType == 13
@{BearerRecord_Feilds}
...    bearerRecord/data-r2/trigger=ctxSetup
...    bearerRecord/data-r2/setupBearers=1 item
...    bearerRecord/data-r2/setupBearers/DuBearerDataSetupItem/drb-Id=4
...    bearerRecord/drbLevelQos/nonDynamicFiveQiDescriptor/fiveQi=6
...    bearerRecord/drbLevelQos/arp/priorityLevel=15
...    bearerRecord/drbLevelQos/arp/preemptionCapability=shallNotTriggerPreemption
...    bearerRecord/drbLevelQos/arp/preemptionVulnerability=preemptable
...    bearerRecord/drbLevelQos/pduSessionId=1
...    bearerRecord/snssai/sst=01
...    bearerRecord/snssai/sd=d143a5
...    bearerRecord/qosFlowsMappedToBearer=1 item
...    bearerRecord/DuQosFlowMappedToBearerItem/qfi=1
...    bearerRecord/DuQosFlowMappedToBearerItem/fiveQi=6
...    bearerRecord/DuQosFlowMappedToBearerItem/arp/priorityLevel=15
...    bearerRecord/DuQosFlowMappedToBearerItem/arp/preemptionCapability=shallNotTriggerPreemption
...    bearerRecord/DuQosFlowMappedToBearerItem/arp/preemptionVulnerability=preemptable
...    bearerRecord/DuQosFlowMappedToBearerItem/pduSessionId=1
${CUBearerRecord}     nsetapx.CuVendorExtensionRecordDataType == 0
@{ueReleaseRecord_Feilds}
...    ueReleaseRecord/data-r1/trigger=gNB
...    ueReleaseRecord/data-r1/reason=handoverSuccess
...    ueReleaseRecord/data-r1/ueCtxReleaseCmdRcvTime/seconds=[RE].*
...    ueReleaseRecord/data-r1/ueCtxReleaseCmdRcvTime/useconds=[RE].*
...    ueReleaseRecord/data-r1/ueCtxReleaseCmplSendTime/seconds=[RE].*
...    ueReleaseRecord/data-r1/ueCtxReleaseCmplSendTime/useconds=[RE].*

*** Test Cases ***
CB009485_SR_A_TC10_B3_04_Verify gNB-DU reports Bearer Trace Record on target gNB during successful NG based Inter-RAT HO from LTE eNB for SA call
    [Documentation]    The purpose of this test case is to check following scenarios:
    ...    USCB009485-A#B21-ALT2: Monitoring PCMD content related to CB009485 for DU Bearer Trace Record
    ...    during Bearer Setup after successful Inter-gNB HO (NG based Inter-RAT)
    ...    Case steps:
    ...    1.setup SA call and start traffic for UE1 sucessfully
    ...    2.Trigger B2 measurement report to HO to interRAT LTE
    ...    3.Trigger inter-RAT NG HO from lte to gnb and check wirshark logs.
    ...    Expected Results:
    ...        1-2. UE attached and handover to ENB successfully, traffic is stable.
    ...        3. HO performed successfully.
    ...             A new  SBA Trace Session with PCMD content is started
    ...             Target gnb reports Bearer Trace Record (5G_TC_825) with IEs corresponding to the cell from target gNB
    ...             NR Bearer Data (5G_TC_929)
    ...             set up bearer data list
    [Tags]    TC10
    SA UE attach With Traffic
    trigger handover from 5G to ENB
    trigger handover from ENB to 5G and check wireshark logs

*** Keywords ***
Modify Cfg
    ${ue_83}    catenate
    ...    set_ue simulated id=83 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nea=null+zuc
    ...    nia=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645483 enb=2 cell=12 mode=nr
    Update Cfg    ${ue_83}
    Update Cfg    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.1.14 daemon=$SERVER_IP:$EDAEMON_PORT gnb_id=0x12:28 nssai=0x01:0xD143A5
    ${V1}    catenate
    ...    set_cell id=1 gnb=5 pci=3:2 earfcn=1:18001 tac=0 proxy=$SERVER_IP:12220 nrci=0x1 tdd_cell=on bw=20MHz technology=lte
    ...    mandatory_for_activation=off
    Update Cfg    ${V1}
    Update Cfg    gnb_param id=5 xn_listening_socket=1 send_xn_setup=false sa_ho=ng_based

Common Suite Setup And Setup Airphone Env And Start TCE
    Common Suite Setup And Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F
    Start TCE    ${TCE_PORT_GNB1}

SA UE attach With Traffic
    [Arguments]    ${ueid}=83
    BuiltIn.Log    UE${ue_id} start to register...    console=${True}
    Execute Egate Command    ue_location_change id=${ueid} enb=2 cell=12
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ueid}    Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ueid} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ueid} nwslice=1 gw=1    QoS Routing Table
    Send And Verify Throuput

Send And Verify Throuput
    [Arguments]    ${ue_id}=83    ${expectedTput_dl}=40    ${expectedTput_ul}=7
    Send Traffic    ue_id=${ue_id}
    Verify Throuput    ue_id=${ue_id}    expectedTput_dl=${expectedTput_dl}    expectedTput_ul=${expectedTput_ul}

Send Traffic
    [Arguments]    ${ue_id}=83
    Run Keyword And Ignore Error    Execute Egate Command
    ...    data_trf_start ue=${ue_id} pdu=1 dir=ul mbps=10 trf_id=1    pass_regexp=Started Uplink Internal traffic
    Run Keyword And Ignore Error    Execute Egate Command
    ...    data_trf_start ue=${ue_id} pdu=1 dir=dl mbps=50 trf_id=2    pass_regexp=UE${ue_id}: Started Downlink Internal traffic

Verify Throuput
    [Arguments]    ${ue_id}=83    ${sleep_time}=10s    ${expectedTput_dl}=40    ${expectedTput_ul}=8
    sleep    ${sleep_time}    #wait trf stable
    ${dl_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${dl_throuput}/1000>${expectedTput_dl}
    ${ul_throuput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throuput}/1000>${expectedTput_ul}

Get A2 Measurement ID
    [Arguments]    ${ue_id}=83    ${ssbfreq}=${NRARFCN127180}
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    ${ssbfreq}    A2
    [Return]    ${meas_id}

Report A2 and configured B2 for UE
    [Arguments]    ${ue_id}=83
    ${a2_mrid}    Get A2 Measurement ID
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${a2_mrid} event=A2 srsrp_nr=30 srsrq_nr=30
    ...    rrcReconfigurationComplete

Report B2 and Trigger HO from cell12 to lte cell
    [Arguments]    ${ue_id}=83    ${filter}=${CUBearerRecord}    ${check_fields}=${ueReleaseRecord_Feilds}
    BuiltIn.Log    UE${ue_id} start to handover from gnb cell12 to lte cell...    console=${True}
    ${mea_id}    get nr meas id for specific type and frequency    ${ue_id}    1    B2    EUTRAN
    start to capture wireshark log    tag=UE${ue_id}_HO_toltefrom5g
    ${A3_cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${mea_id} event=B2 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=11 nrsrp_nr=30 nrsrq_nr=30
    Execute Egate Command    ${A3_cmd}    Successful handover from EXT_ENB-2.12 to ENB-5.1
    sleep    10s    reason=wait timer
    download and check wireshark fields    tag=UE${ue_id}_HO_toltefrom5g
    ...                                    filter=${filter}
    ...                                    check_fields=${check_fields}
trigger handover from 5G to ENB
    [Arguments]    ${ue_id}=83
    Report A2 and configured B2 for UE    ue_id=${ue_id}
    Report B2 and Trigger HO from cell12 to lte cell    ue_id=${ue_id}

trigger handover from ENB to 5G and check wireshark logs
    [Arguments]    ${ue_id}=83    ${filter}=${DUBearerRecord}    ${check_fields}=${BearerRecord_Feilds}
    BuiltIn.Log    UE${ue_id} start to handover from lte cell to gnb cell12...    console=${True}
    start to capture wireshark log    tag=UE${ue_id}_HO_FromlteTo5g
    ${cmd}    Catenate    gnb_trigger_inter_rat_handover_to_5g ue=${ue_id} target_gnb=2 target_cell=12 plmn=311:489
    Execute Egate Command    ${cmd}    pass_regexp=handover
    sleep    10s    reason=wait timer
    download and check wireshark fields    tag=UE${ue_id}_HO_FromlteTo5g
    ...                                    filter=${filter}
    ...                                    check_fields=${check_fields}

download and check wireshark fields
    [Arguments]    ${tag}    ${filter}    ${check_fields}
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    ${tag}    ${filter}
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${filter}
    ...                       check_fields=${check_fields}
    ...                       packet_num=all
