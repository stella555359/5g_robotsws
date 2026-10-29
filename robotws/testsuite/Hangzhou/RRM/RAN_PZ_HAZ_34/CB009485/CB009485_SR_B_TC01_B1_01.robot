*** Settings ***
Documentation
...    author: Ma Keyun
...    contact: keyun.ma@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup        Common Suite Setup And Setup Airphone Env And Start TCE
Suite Teardown     Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup         Common Test Setup And Start To Capture Logs
Test Teardown      Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS26R1    tl-CLOUD_5G_I_BOO_AP_LOO
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
${TCE_PORT_GNB1}  49100
# don't change the following setting
${AUTO_ANALYSIS_FLAG}    ${False}
${NRARFCN127180}    127210
${CUBearerRecord}     nsetapx.CuVendorExtensionRecordDataType == 0
@{ueReleaseRecord_Feilds}
...    ueReleaseRecord/data-r1/trigger=amf
...    ueReleaseRecord/data-r1/reason=fiveGCgenRelease
...    ueReleaseRecord/data-r1/ueCtxReleaseCmdRcvTime/seconds=[RE].*
...    ueReleaseRecord/data-r1/ueCtxReleaseCmdRcvTime/useconds=[RE].*
...    ueReleaseRecord/data-r1/ueCtxReleaseCmplSendTime/seconds=[RE].*
...    ueReleaseRecord/data-r1/ueCtxReleaseCmplSendTime/useconds=[RE].*
...    ueReleaseRecord/data-r1/rrcReleaseSendTime/seconds=[RE].*
...    ueReleaseRecord/data-r1/rrcReleaseSendTime/useconds=[RE].*

*** Test Cases ***
CB009485_SR_B_TC01_B1_01_Verify gNB-CU UE Release Trace Record is reported after successful transition of UE from RRC CONNECTED to IDLE
    [Documentation]    The purpose of this test case is to check following scenarios:
    ...    This user scenario validates that gNB-CU UE Release Trace Record is reported after successful transition of UE from RRC CONNECTED
    ...    to IDLE where UE Context Release is triggered by AMF.
    ...    Requirement Coverage:
    ...    5G_RAN_USR_COM_25491, fully covered
    ...    USCB009485-B#B01: RRC CONNECTED to IDLE transition - Successful (AMF Triggered)
    ...    Case steps:
    ...    1.setup SA call and start traffic for UE83 sucessfully
    ...    1.setup SA call and start traffic for UE84 sucessfully
    ...    3.Trigger UE from connected to idle by AMF for UE83 and UE84
    ...    4.Check UE Release Trace Record from TCE
    ...    Expected Results:
    ...        1-2. UEs attached successfully, traffic is stable.
    ...        3. UE from connected to idle.
    ...             A new  SBA Trace Session with PCMD content is started
    ...             Target gnb reports UE Release Trace Record (5G_TC_118) with IEs corresponding to the TCE from CU-UP:
    ...               Triggered by = amf
    ...               Reason = fiveGCgenRelease
    [Tags]    TC01
    SA UE attach With Traffic    ueid=83    cell=11
    SA UE attach With Traffic    ueid=84    cell=12
    check wireshark logs   83
    check wireshark logs   84

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
    [Arguments]    ${ueid}=83    ${cell}=1
    BuiltIn.Log    UE${ue_id} start to register...    console=${True}
    Execute Egate Command    ue_location_change id=${ueid} enb=2 cell=${cell}
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


trigger UE from connected to idle by AMF for UE
    [Arguments]    ${ue_id}=83
     Execute Egate Command    ue_ng_ctx_release id=${ue_id} cause=NAS_normal_release
  #  Report A2 and configured B2 for UE    ue_id=${ue_id}
 #   Report B2 and Trigger HO from cell12 to lte cell    ue_id=${ue_id}

check wireshark logs
    [Arguments]    ${ue_id}=83    ${filter}=${CUBearerRecord}    ${check_fields}=${ueReleaseRecord_Feilds}
    BuiltIn.Log    UE${ue_id} start to from_connected_to_idle...    console=${True}
    start to capture wireshark log    tag=UE${ue_id}_from_connected_to_idle
    trigger UE from connected to idle by AMF for UE    ue_id=${ue_id}
    sleep    10s    reason=wait timer
    download and check wireshark fields    tag=UE${ue_id}_from_connected_to_idle
    ...                                    filter=${filter}
    ...                                    check_fields=${check_fields}

download and check wireshark fields
    [Arguments]    ${tag}    ${filter}    ${check_fields}
    ${wireshark_log_path}    stop_wireshark_log_after_filter_found    ${tag}    ${filter}
    check_wireshark_fields    pcap_file=${wireshark_log_path}
    ...                       filter=${filter}
    ...                       check_fields=${check_fields}
    ...                       packet_num=all
