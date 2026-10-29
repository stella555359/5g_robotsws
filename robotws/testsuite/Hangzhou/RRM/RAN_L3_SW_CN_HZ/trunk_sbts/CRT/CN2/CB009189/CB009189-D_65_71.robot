*** Settings ***
Documentation    Suite description
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-niya.ma
...    CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD    CRT    CB009189    release-SBTS23R1
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    @{RanSharing}
...    @{MultiAMF}
...    @{MultiPLMN}
...    @{NRPLMNSET_SA_NSA}
...    @{SNSSAI}
...    @{TRACKINGAREA}
...    @{5qi80_related_modification}
...    @{CASE71_new_slice}

@{RanSharing}
...    NRBTS-1:actRanSharing=true

...    NRBTS-1:actNgcFlexSaMode=true
...    delete:NRCELL:trackingAreaDN
...    delete:NRCELL:configuredEpsTac

@{MultiAMF}
...    SERVEDAMF-1:amfIPAddress=10.0.1.1
...    SERVEDAMF-2:amfIPAddress=10.0.1.102

@{MultiPLMN}
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3
...    NRPLMN-2:mcc=311
...    NRPLMN-2:mnc=402

@{NRPLMNSET_SA_NSA}
...    NRCELL-1/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-100
...    NRCELL-1/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_1}
...    NRCELL-2/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-100
...    NRCELL-2/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_1}
...    NRCELL-11/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL-11/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST}
...    NRCELL-12/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-100
...    NRCELL-12/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_1}
...    NRCELL-13/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-100
...    NRCELL-13/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_1}
...    NRCELL-14/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-100
...    NRCELL-14/NRPLMNSET_SA-1:nrPlmnDNList=${NRPLMNDNLIST_1}

...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=200
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=${NRPLMNDNLIST}

@{SNSSAI}
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}

@{TRACKINGAREA}
...    TRACKINGAREA-100:fiveGsTac=100
...    TRACKINGAREA-100:snssaiList:snssaiDN=${SNSSAIDNLIST}
...    TRACKINGAREA-200:fiveGsTac=200
...    TRACKINGAREA-200:snssaiList:snssaiDN=${SNSSAIDNLIST}

${NRPLMNDNLIST}    SEPARATOR=,
...    MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRPLMN-2
${NRPLMNDNLIST_1}    MRBTS-1/NRBTS-1/NRPLMN-1
${SNSSAIDNLIST}    MRBTS-1/NRBTS-1/SNSSAI-1

@{5qi80_related_modification}
...    NRBTS-1/NRDRB-15:actDddsReduction=false
...    NRBTS-1/NRDRB-15:actLostPduFastRetx=false
...    NRBTS-1/NRDRB-15:discardTimer=infinity
...    NRBTS-1/NRDRB-15:dlFlowControlAlgo=3gppFlowControl
...    NRBTS-1/NRDRB-15:dscp=0
...    NRBTS-1/NRDRB-15:endMarkerTimer=2000
...    NRBTS-1/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS-1/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS-1/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS-1/NRDRB-15:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-15:numSduDiscard=1
...    NRBTS-1/NRDRB-15:queuingDelayDiscarding=Controlled Delay (CoDel)
...    NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=750
...    NRBTS-1/NRDRB-15:resType=nonGBR
...    NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-15:schedulWeight=1
...    NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=500
...    NRBTS-1/NRDRB-15:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS-1/NRDRB-15:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS-1/NRDRB-15:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS-1/NRDRB-15:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS-1/NRDRB-15:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS-1/NRDRB-15:nsaDrbParam:dlDataSplitMode=dlOverF1U
...    NRBTS-1/NRDRB-15:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS-1/NRDRB-15:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS-1/NRDRB-15:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS-1/NRDRB-15:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS-1/NRDRB-15:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS-1/NRDRB-15:nsaDrbParam:prioritizeX2Period=500
...    NRBTS-1/NRDRB-15:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS-1/NRDRB-15:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS-1/NRDRB_5QI-3:fiveqiValueList=80
...    NRBTS-1/NRDRB_5QI-3:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15

@{CASE71_new_slice}
...    NRBTS:actAdditionalSliceSupport=true

...    NRBTS/SNSSAI-2:administrativeState=Unlocked
...    NRBTS/SNSSAI-2:sd=13714342
...    NRBTS/SNSSAI-2:sst=2
...    NRBTS/SNSSAI-2:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2

@{rlc_mode_am}
...    NRBTS-1/NRDRB-15:rlcMode=RLC_AM

@{rlc_mode_um}
...    NRBTS-1/NRDRB-15:rlcMode=RLC_UM

*** Test Cases ***
CB009189-D_ID_65_5QI80_setup_ICS_wo_PDU_session_with_multiple_PLMNIDs_then_repeat_after_DRB_mapped_to_RLC_AM
    [Documentation]
    ...    1. muitiple PLMNID feature enable.
    ...    2. 5QI-80 DRB profile is configured and DRB mapped to RLC-UM
    ...    3. Initial Context Setup without PDU session
    [Tags]    QC_223936    owner-niya.ma
    Verify 5QI80 with multi AMF
    OnlineParamChange    @{rlc_mode_am}
    Verify 5QI80 with multi AMF
    OnlineParamChange    @{rlc_mode_um}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB009189D065${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB009189-D_ID_71_5QI80_setup_ICS_with_PDU_session_using_new_slices_then_release_one_PDU_session_remains
    [Documentation]
    ...    1. CB008120 feature enable,ActAdditionalSliceSupport=true.and new slices profile is configured.
    ...    2. 5QI-80 DRB profile is configured and DRB mapped to RLC-UM
    ...    3. Initial Context Setup without PDU session
    [Tags]    QC_222501    owner-niya.ma
    UE Attach To Target Cell With Multi PDU    ue_id=81    cell_id=11
    Send And Verify Throuput    ue_id=81    qfi=1    send_dl=20    send_ul=10    sleep_time=60s    pdu=1
    Send And Verify Throuput    ue_id=81    qfi=1    send_dl=20    send_ul=10    sleep_time=60s    pdu=2
    PDU Release    ue_id=81    pdu=1
    Verify Throuput    ue_id=81    qfi=1    Tput_dl=18    Tput_ul=9    sleep_time=60s    pdu=2
    UE Deregister From gNB    ue_id=81
    Check Wireshark Log    ${CURDIR}${/}a2a_CB009189D071${/}a2a.ini    wait_string=UEContextReleaseComplete::4


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F_2N41_2N71_2N66

Modify Cfg
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=1 5qi=1
    Update Cfg    set_qosflow id=2 5qi=2 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=6
    Update Cfg    set_qosflow id=7 5qi=7
    Update Cfg    set_qosflow id=8 5qi=8
    Update Cfg    set_qosflow id=9 5qi=80 default=on
    Update Cfg    set_amf_region id=2 tac_list=0,100,200,258,788 plmn=311:402
    Update Cfg    set_amf id=2 daemon=$SERVER_IP:$EDAEMON_PORT ng=10.0.1.102:38412 region=2 set_id=3 pointer=2
    Update Cfg    amf_param id=2 full_nas_auth=on ims_voice_3gpp=on nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc
    ${amf}    Catenate    set_ue simulated id=81 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+snow3g+aes+zuc
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:402:0000:0:0:021645481 enb=2 cell=11 mode=nr
    Update Cfg    ${amf}
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1-2
    Update Cfg    set_nwslice id=2 snssai=0x02:0xD143A6 ue=all amf=1

ICS Without PDU
    [Arguments]    ${ue_id}    ${cell_id}    ${amf_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    amf_param id=${amf_id} send_ics_registration=on
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table
    Execute Egate Command    amf_param id=${amf_id} send_ics_registration=off

UE Attach To Target Cell With Multi PDU
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=1 nwslice=2    QoS Routing Table

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

PDU Release
    [Arguments]    ${ue_id}    ${pdu}
  Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=${pdu} by=amf
  ...    N4 Session Release for PDU Session 1. All ongoing traffic will be stopped

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Verify Throuput
    [Arguments]    ${ue_id}    ${qfi}    ${Tput_dl}    ${Tput_ul}    ${sleep_time}    ${pdu}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    [Arguments]    ${ue_id}    ${qfi}    ${send_dl}    ${send_ul}    ${sleep_time}    ${pdu}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl mbps=${send_dl}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul mbps=${send_ul}
    Verify Throuput    ${ue_id}    ${qfi}    ${send_dl}*0.9    ${send_ul}*0.9    ${sleep_time}    ${pdu}

Verify 5QI80 with multi AMF
    ICS Without PDU    ue_id=81    cell_id=11    amf_id=2
    Send And Verify Throuput    ue_id=81    qfi=1    send_dl=20    send_ul=10    sleep_time=60s    pdu=1
    ICS Without PDU    ue_id=82    cell_id=11    amf_id=1
    Send And Verify Throuput    ue_id=82    qfi=1    send_dl=20    send_ul=10    sleep_time=60s    pdu=1
    Verify Throuput    ue_id=81    qfi=1    Tput_dl=18    Tput_ul=9    sleep_time=60s    pdu=1
    Verify Throuput    ue_id=82    qfi=1    Tput_dl=18    Tput_ul=9    sleep_time=60s    pdu=1
    UE Deregister From gNB    ue_id=81
    UE Deregister From gNB    ue_id=82
