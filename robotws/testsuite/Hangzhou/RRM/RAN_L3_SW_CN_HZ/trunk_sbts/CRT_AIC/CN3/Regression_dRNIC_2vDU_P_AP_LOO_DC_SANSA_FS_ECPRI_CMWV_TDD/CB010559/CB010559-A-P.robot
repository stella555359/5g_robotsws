*** Settings ***
Documentation
...    author: kang.xiang
Suite Setup    Common Suite Setup And Setup Airphone Env Aic 2CU 2DU
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    team-SG3    owner-kang.xiang    release-SBTS26R3
...    CLOUD_5GC_dRNIC_2vDU_P_AP_LOO_DC    VARIANT_SANSA_FS_ECPRI_CMWV_TDD    master_vDU
Resource    ../../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2du/2vcu_4cells_du1_2T_du2_2T
${RESOURCES_LEAKAGE_FLAG}  ${False}
${InactivityTimerSA}    NRBTS:drbInactivityTimerSA=120    NRBTS:srbinactivitytimerSA=120

@{feature_rcr_paramter_cu}
...    NRBTS:rrcReestabTypeSA=sameGNB    #5GC000732
...    NRBTS:actRrcRREUnprepgNB=intergNB    #CB010559
...    NRBTS:timerUEContextRetrieval=300
...    NRBTS:timerKeepUECtxtServgNB=2000
...    NRBTS:tWaitingRlRecoverSA=5000ms
...    ${InactivityTimerSA}

@{feature_rcr_paramter_du}
...    NRBTS:rrcReestabTypeSA=sameGNB    #5GC000732
...    NRBTS:actRrcRREUnprepgNB=intergNB    #CB010559
...    NRCELL:t301=2000ms

@{xn_of_nradjgnb}
...    NRBTS:actIncXn=true
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBIdCtrl=oamControlled
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJGNB-1:xnLinkRef=1

@{xn_of_nradjnrcell}
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:nrarfcn=636666

@{xn_of_NRREL}
...    NRCELL/NRREL-1:gNbIdLength=22
...    NRCELL/NRREL-1:gnbPlmn:mcc=311
...    NRCELL/NRREL-1:gnbPlmn:mnc=489
...    NRCELL/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL/NRREL-1:handoverAllowedSA=allowed
...    NRCELL/NRREL-1:removeNotAllowed=false

@{xn_of_xnlink}
...    NRBTS/NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS/XNLINK-1:cPlaneIpAddrCtrl=oamControlled

@{xn_of_gnb1}
...    @{xn_of_nradjgnb}
...    @{xn_of_nradjnrcell}
...    @{xn_of_NRREL}
...    @{xn_of_xnlink}
...    NRBTS/NRADJGNB-1:gNodeBId=2
...    NRBTS/NRADJNRCELL-1:gNbId=2
...    NRBTS/NRADJNRCELL-1:lcrId=2
...    NRBTS/NRADJNRCELL-1:physCellId=51
...    NRCELL/NRREL-1:gNbId=2
...    NRCELL/NRREL-1:lcrId=2
...    NRBTS/XNLINK-1:cPlaneIpAddr=10.0.12.31

@{xn_of_gnb2}
...    @{xn_of_nradjgnb}
...    @{xn_of_nradjnrcell}
...    @{xn_of_NRREL}
...    @{xn_of_xnlink}
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJNRCELL-1:gNbId=1
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRCELL/NRREL-1:gNbId=1
...    NRCELL/NRREL-1:lcrId=1
...    NRBTS/XNLINK-1:cPlaneIpAddr=10.0.12.10

@{VoNR_parameter_cu}
...    NRCELL:actVoNR=true
...    NRBTS/NRDRB-5:actDddsReduction=false
...    NRBTS/NRDRB-5:actLostPduFastRetx=false
...    NRBTS/NRDRB-5:discardTimer=20ms
...    NRBTS/NRDRB-5:dlFlowControlAlgo=none
...    NRBTS/NRDRB-5:dscp=0
...    NRBTS/NRDRB-5:durationThresDiscardDl=50
...    NRBTS/NRDRB-5:endMarkerTimer=2000
...    NRBTS/NRDRB-5:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-5:maxTransferDelayGbr=20
...    NRBTS/NRDRB-5:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS/NRDRB-5:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS/NRDRB-5:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS/NRDRB-5:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS/NRDRB-5:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS/NRDRB-5:nsaDrbParam:dlDataSplitMode=dlOverF1UX2U
...    NRBTS/NRDRB-5:nsaDrbParam:dlNumOfCongOrGainDdds=2
...    NRBTS/NRDRB-5:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS/NRDRB-5:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS/NRDRB-5:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS/NRDRB-5:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS/NRDRB-5:nsaDrbParam:prioritizeX2Period=500
...    NRBTS/NRDRB-5:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS/NRDRB-5:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS/NRDRB-5:numSduDiscard=1
...    NRBTS/NRDRB-5:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-5:queuingDelaySduDiscardThreshold=750
...    NRBTS/NRDRB-5:resType=GBR
...    NRBTS/NRDRB-5:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-5:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-5:rlcMode=RLC_UM
...    NRBTS/NRDRB-5:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-5:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-5:volThresDiscardDl=100
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_PDCP-3:cuFlowControlProfId=1
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardThreshold=20000
...    NRBTS/NRDRB_PDCP-3:pdcpDelayThreshRetxMode=disabled
...    NRBTS/NRDRB_PDCP-3:tReorderingDl=ms100
...    NRBTS/NRDRB_PDCP-3:tReorderingUl=ms100
...    NRBTS/NRDRB_PDCP-3:xxFlowControlProfForCuIdx=1

@{VoNR_parameter_du}
...    NRCELL:actVoNR=true
...    NRBTS/NRDRB-5:discardTimer=20ms
...    NRBTS/NRDRB-5:dlFlowControlAlgo=none
...    NRBTS/NRDRB-5:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-5:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-5:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-5:resType=GBR
...    NRBTS/NRDRB-5:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-5:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-5:rlcMode=RLC_UM
...    NRBTS/NRDRB-5:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-5:nrDrbRlcAmDN=${EMPTY}
...    NRBTS/NRDRB-5:schedulWeight=${EMPTY}
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_MAC-3:lcgid=4
...    NRBTS/NRDRB_MAC-3:schedulBSD=20ms

@{PARAMS_IN_SCF_CU}
...    @{feature_rcr_paramter_cu}
...    @{xn_of_gnb1}
...    @{VoNR_parameter_cu}
...    NRBTS/NRDRB-5:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-5

@{PARAMS_IN_SCF_CU2}
...    @{feature_rcr_paramter_cu}
...    @{xn_of_gnb2}
...    @{VoNR_parameter_cu}
...    NRBTS/NRDRB-5:nrDrbPdcpDN=MRBTS-2/NRBTS-2/NRDRB_PDCP-3
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-2/NRBTS-2/NRDRB-5

@{PARAMS_IN_SCF_DU1}    @{feature_rcr_paramter_du}
...    @{VoNR_parameter_du}
...    NRBTS/NRDRB-5:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS/NRDRB-5:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-5

@{PARAMS_IN_SCF_DU2}    @{feature_rcr_paramter_du}
...    @{VoNR_parameter_du}
...    NRBTS/NRDRB-5:nrDrbMacDN=MRBTS-2/NRBTS-2/NRDRB_MAC-3
...    NRBTS/NRDRB-5:nrDrbRlcUmDN=MRBTS-2/NRBTS-2/NRDRB_RLC_UM-1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-2/NRBTS-2/NRDRB-5

${REESTAB_UNPREP_ACC_OTH_FAIL}    M55124C00043
${REESTAB_UNPREP_ATT_OTH_FAIL}    M55124C00044
${REESTAB_UNPREP_ACC_FALLBACK}    M55124C00046
${REESTAB_UNPREP_FALLBACK}    M55124C00047
${REESTAB_UNPREP_ACC_VONR}    M55124C00045
${REESTAB_UNPREP_ACC_HO_FAIL}    M55124C00048
${REESTAB_UNPREP_ATT_HO_FAIL}    M55124C00049

@{PM_Counters_RRE_to_unprepare_gNB}
...    NRCELL-1:${REESTAB_UNPREP_ACC_OTH_FAIL} =1
...    NRCELL-1:${REESTAB_UNPREP_ATT_OTH_FAIL}=1
...    NRCELL-1:${REESTAB_UNPREP_ACC_FALLBACK} =0
...    NRCELL-1:${REESTAB_UNPREP_FALLBACK} =0
...    NRCELL-1:${REESTAB_UNPREP_ACC_VONR} =0
...    NRCELL-1:${REESTAB_UNPREP_ACC_HO_FAIL} =0
...    NRCELL-1:${REESTAB_UNPREP_ATT_HO_FAIL} =0

@{PM_Counters_RRE_to_unprepare_gNB_with_vonr}
...    NRCELL-1:${REESTAB_UNPREP_ACC_VONR} =1
...    NRCELL-1:${REESTAB_UNPREP_ACC_FALLBACK} =0
...    NRCELL-1:${REESTAB_UNPREP_FALLBACK} =0
...    NRCELL-1:${REESTAB_UNPREP_ACC_HO_FAIL} =1
...    NRCELL-1:${REESTAB_UNPREP_ATT_HO_FAIL} =1

${ue_nr_capabilities}    SEPARATOR=
...    E1A03FA0474E7AEFFFFFAFC2200782E0203C127BE7FFFFF800F00C6FBE00050370101F8E0155DF0A3FE2F08762F82087F540A083D951D
...    220624FAC41E420F081425BE7E57771DF001DDC77C000CC005000742AEF851FF17843B17C1043FAA05041ECA8E9103127D620F2107840
...    A12DF3F33BB8EF800EEE3BE000660028003A1577C4DFF8BC21D8BE0821FD502820F65474881893EB1079083C205096F9F95DFC7FC0077
...    F1FF000330014001D00650389A000000C40A83C4D000C2680004C40AC1C4D080004620540E268400033102B070A020002188150785000
...    18280002988100900A2026C04605000C2508206811B649F0214285B24F810236C93E04085B24F810276C93E042853B649F000160C318C
...    631BFFFE000138036002800301C1401C0C4270070007000603E0488200000041000002208004000004100080000882001004001040020
...    080220800402008410008040188200100C021040020180601B072F2A2B072F2A28060800004B2CA82000032CB2A0800014B2CA0200007
...    2CB2801A83D5D2AAAA0F174AA283839804F9BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C07
...    0079BF01C070079BF01C070079BF01C0700001400600400C010020808020040200801001C0180180400300A00A01801001C0180380400
...    700A01201802001C0380180800301200A02801041C0080180100300400A0080103801001004002004004010001AB06020721252627287
...    70000000361781C06000601A

*** Test Cases ***
CB010559-A-P_Successful_RRE_unprepared_gNB_without_HO
    [Documentation]
    ...    1. xn and neighbour moc configured gnb1 cell1 and gnb2 cell2
    ...    2. ue register into gnb1 cell1 and pdu session setup without vonr
    ...    3. ue rrc reestablish to unprepared gnb cell2
    ...    4. check RRE procedure message and counter
    ...    5. same procedure for ue2 with vonr
    [Tags]
    Clear Counter Files Cu Aic
    Check Xnlink Available
    UE Register To GNB2 And Pdu setup
    Trigger RRE to Unprepared GNB1
    Check WireShark Log Aic    ${CURDIR}${/}A2A${/}a2a.ini    wait_string=UEContextRelease::2
    Check Counters Cu Aic    ${PM_Counters_RRE_to_unprepare_gNB}
    Start To Capture Wireshark Log Aic    ue2_vonr
    UE Register To GNB2 And Pdu setup    ue_id=2
    Setup VoNR Session For UE2
    Trigger RRE to Unprepared GNB1    ue_id=2    cause=handoverFailure
    Check WireShark Log Aic    ${CURDIR}${/}A2A${/}ue2_vonr.ini    name=ue2_vonr    wait_string=UEContextRelease::2
    Check Counters Cu Aic    ${PM_Counters_RRE_to_unprepare_gNB_with_vonr}

*** Keywords ***
Modify Cfg Aic
    Set QCI and Qos in WTS
    Enable VoiceOverNRSupported in Uecapability for SA UE
    Set Sim gNB

Enable VoiceOverNRSupported in Uecapability for SA UE
    FOR    ${ue_id}    IN RANGE    1    30
        Update Cfg Aic    ue_param id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}
	END

Set QCI and Qos in WTS
    Update Cfg Aic    set_qosflow id=1 5qi=5 default=on
    Update Cfg Aic    set_qosflow id=2 5qi=6 default=off
    Update Cfg Aic    set_qosflow id=3 5qi=1

Set Sim gNB
    ${v1}    catenate
    ...    set_gnb id=2 type=external plmn=311:489 ng=10.0.11.10 gnb_id=0x01:22 daemon=10.0.2.1:22222 xn=10.0.12.10
    ...    s1u=10.0.1.210 x2=10.0.1.10:36422 x2u=10.0.1.210 x2_peers=none amf=1
    ${v3}    catenate
    ...    set_gnb id=3 type=external plmn=311:489 ng=10.0.11.31 gnb_id=0x02:22 daemon=10.0.2.1:22222 xn=10.0.12.31
    ...    s1u=10.0.12.231 x2=10.0.1.31:36422 x2u=10.0.1.231 x2_peers=none amf=1
    ${v2}    catenate
    ...    set_gnb id=4 type=simulated plmn=311:489 ng=10.0.11.11 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.12.11 nssai=0x1:0xd143a5,0x1:0xd143a6 amf=1
    Update Cfg Aic    ${v1}
    Update Cfg Aic    ${v2}
    Update Cfg Aic    ${v3}
    Update Cfg Aic    gnb_param id=4 xn_listening_socket=1 send_xn_setup=true measEvent=A3
    ${cfg_cmd_3}    catenate
    ...    set_cell id=1 gnb=4 pci=16:0 tac=280 nrci=0x01 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=636666:636666 gscn=7880
    Update Cfg Aic    ${cfg_cmd_3}

Check Xnlink Available
    Object Should Exist In Cu2  XNLINK-1:xnLinkStatus=available

UE Register To GNB2 And Pdu setup
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=3 cell=2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Reg
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    QoS Routing Table

Trigger RRE to Unprepared GNB1
    [Arguments]    ${ue_id}=1    ${cause}=otherFailure
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=1 cause=${cause}    rrcReestablishmentComplete
    sleep    5s    wait RRE prodcedure complete
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    pass_regexp=UE${ue_id}: detached
    sleep    120s    debug for waiting
#    Execute Egate Command    ue_disp    timeout=120s    pass_regexp=UE CONTEXT RELEASE COMPLETE
#    # ap can't send derigister to gnb1 after RRE
#    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Reg
#    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    pass_regexp=UE${ue_id}: detached

Setup VoNR Session For UE2
    Execute Egate Command     ue_pdu_session_modify ue=2 pdu=1 qosflows_to_add=3 by=amf    QoS Routing Table
