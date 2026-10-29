*** Settings ***
Documentation
...    author: kang.xiang
Suite Setup    Common Suite Setup And Setup Airphone Env Aic 2DU
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    team-L3CN3_SG1    owner-kang.xiang    release-SBTS25R1
...    CLOUD_5GC_dRNIC_2vDU_P_AP_LOO_DC    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_4CPIF_HA    master_vDU
Resource    ../../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/2du/4cells_du1_2T_du2_2T
${MULTI_CPIF_FLAG}    ${True}
${REDUNDANT_MODE_CU_FLAG}    ${True}

@{rrcReestabTypeSAEqualSameGNB}
...    NRBTS:rrcReestabTypeSA=sameGNB
...    NRBTS:tRLFindForDUSA=3000ms
...    NRBTS:tWaitingRlRecoverSA=5000ms

${X2_UEREL_INCOMING_RESET}    M55110C00019
${X2_UEREL_INC_PARTIAL_RESET}    M55110C00027
@{X2_UEREL_INC_PARTIAL_RESET_and_Incoming_Reset}
...    NRBTS-1:${X2_UEREL_INCOMING_RESET}=2
...    NRBTS-1:${X2_UEREL_INC_PARTIAL_RESET}=0

@{cuUeIdToLinkMappingUpdateDelay}    NRBTS:cuUeIdToLinkMappingUpdateDelay=500ms
@{PARAMS_IN_SCF_CU}
...    @{cuUeIdToLinkMappingUpdateDelay}
...    @{forPMPCounterCalc}
...    @{actNSASlice}
...    @{forXNHOandRRE}
...    @{ngcFlexEnabled}

${sctpWaitTimeInitSeqRetry}    NRSCTP-1:sctpProfile:sctpWaitTimeInitSeqRetry=60

@{PARAMS_IN_SCF_DU1}    @{actNSASlice_of_du}    @{forPMPCounterCalc_DU}    ${sctpWaitTimeInitSeqRetry}
@{PARAMS_IN_SCF_DU2}    @{actNSASlice_of_du}    @{forPMPCounterCalc_DU}    ${sctpWaitTimeInitSeqRetry}

@{forPMPCounterCalc}
...    NRBTS:actNrpmqapProfiles=true
...    NRBTS/NRDRB-5:actDddsReduction=false
...    NRBTS/NRDRB-5:actLostPduFastRetx=false
...    NRBTS/NRDRB-5:discardTimer=20ms
...    NRBTS/NRDRB-5:dlFlowControlAlgo=none
...    NRBTS/NRDRB-5:dscp=0
...    NRBTS/NRDRB-5:durationThresDiscardDl=50
...    NRBTS/NRDRB-5:endMarkerTimer=2000
...    NRBTS/NRDRB-5:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-5:maxTransferDelayGbr=20
...    NRBTS/NRDRB-5:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
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
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-5
...    NRBTS/NRDRB_PDCP-3:cuFlowControlProfId=1
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardThreshold=20000
...    NRBTS/NRDRB_PDCP-3:pdcpDelayThreshRetxMode=disabled
...    NRBTS/NRDRB_PDCP-3:tReorderingDl=ms100
...    NRBTS/NRDRB_PDCP-3:tReorderingUl=ms100
...    NRBTS/NRDRB_PDCP-3:xxFlowControlProfForCuIdx=1
...    NRBTS/NRPMRNL-1/NRPMQAP-1:cfg5qiRange=1-9
...    NRBTS/NRPMRNL-1/NRPMQAP-1:cfgProfType=both
...    NRBTS/NRPMRNL-1/NRPMQAP-1:cfgArpRange=${EMPTY}
...    NRBTS/NRPMRNL-1/NRPMQAP-1:cfgQciRange=${EMPTY}
...    NRBTS/SERVEDAMF-2:administrativeState=Unlocked
...    NRBTS/SERVEDAMF-2:amfIPAddress=10.0.11.2
...    NRBTS/SERVEDAMF-2:defaultAMF=true
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrNgcFlexInterface=5min
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrNgInterfaceNrpmqap=5min
...    NRCELL:actVoNR=true

@{forPMPCounterCalc_DU}    NRBTS:actNrpmqapProfiles=true
...    NRCELL:actVoNR=true
...    NRBTS/NRDRB-5:discardTimer=20ms
...    NRBTS/NRDRB-5:dlFlowControlAlgo=none
...    NRBTS/NRDRB-5:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-5:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-5:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-5:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS/NRDRB-5:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-5:resType=GBR
...    NRBTS/NRDRB-5:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-5:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-5:rlcMode=RLC_UM
...    NRBTS/NRDRB-5:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-5:nrDrbRlcAmDN=${EMPTY}
...    NRBTS/NRDRB-5:schedulWeight=${EMPTY}
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-5
...    NRBTS/NRDRB_MAC-3:lcgid=4
...    NRBTS/NRDRB_MAC-3:schedulBSD=20ms
...    NRBTS/NRPMRNL-1/NRPMQAP-1:cfgProfType=both

@{actNSASlice}
...    NRBTS:actNsaSlice=true
...    NRBTS/NRDRB_QCI-98:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...    NRBTS/NRDRB_QCI-98:qciValueList=98
...    NRBTS/NRNWSLICE_NSA-1:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRNWSLICE_NSA-1:operatorSpecificQCIList=98
...    NRBTS/NRNWSLICE_NSA-1:s1Uplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-3/IPNO-1/IPIF-4/IPADDRESSV4-1
...    NRBTS/NRNWSLICE_NSA-1:f1Uplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1

@{actNSASlice_of_du}
...    NRBTS:actNsaSlice=true
...    NRBTS/NRDRB_QCI-98:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...    NRBTS/NRDRB_QCI-98:qciValueList=98
...    NRBTS/NRNWSLICE_NSA-1:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/NRNWSLICE_NSA-1:operatorSpecificQCIList=98
...    NRBTS/NRNWSLICE_NSA-1:f1Uplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1

@{forXNHOandRRE}    @{XNHO}    @{rrcReestabTypeSAEqualSameGNB}
@{XNHO}
...    NRBTS:actIncXn=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=35
...    NRBTS/NRADJGNB-1:gNodeBIdCtrl=oamControlled
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJNRCELL-1:cellDepType=SA
...    NRBTS/NRADJNRCELL-1:gNbId=35
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=0
...    NRBTS/NRADJNRCELL-1:physCellId=48
...    NRBTS/NRADJNRCELL-1:ssbFrequency=636576
...    NRCELL:a1MeashoEnabled=rsrp
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=0
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=60
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=0
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=36
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=36
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:cellDepType=SA+NSA
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL/NRREL-1:gNbId=35
...    NRCELL/NRREL-1:gNbIdLength=22
...    NRCELL/NRREL-1:gnbPlmn:mcc=311
...    NRCELL/NRREL-1:gnbPlmn:mnc=489
...    NRCELL/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL/NRREL-1:handoverAllowedSA=allowed
...    NRCELL/NRREL-1:lcrId=1
...    NRCELL/NRREL-1:removeNotAllowed=false
...    NRBTS/NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS/XNLINK-1:cPlaneIpAddr=10.0.12.11
...    NRBTS/XNLINK-1:cPlaneIpAddrCtrl=oamControlled

@{ngcFlexDisabled}    NRBTS:actNgcFlexSaMode=false    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrNgcFlexInterface=disabled
@{ngcFlexEnabled}    NRBTS:actNgcFlexSaMode=true    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrNgcFlexInterface=5min

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

@{Delta_for_cell_amf_link_lock_cu}    NRCELL:administrativeState=Locked    NRBTS/SERVEDAMF-1:administrativeState=Locked
...    NRBTS/SERVEDAMF-2:administrativeState=Locked

${Delta_for_amf_link_unlock_cu}    NRBTS/SERVEDAMF-1:administrativeState=Locked

@{PARAMS_IN_SWCONFIG_CU}  0x66001b=0  0x890001=0  0x890002=0  0x890003=0  0x890004=0  0x890005=0  0x890006=0

${trsconfig_proc_check}  "ps -ef|grep -v grep|grep '/bin/bash /opt/nokia/SS_OAM/TRSCONFIG/runvcu.sh'"|awk '{print $2}'

*** Test Cases ***
System operation with cpif failover
    [Tags]
    [Documentation]    cpif failover + L3 Call
    Check PTP Master Clock State
    Trsconfig Recovery From CU
    FOR    ${num}    IN RANGE    0    10
        Log To Console    ${num}
        Lock Cells And AMF Link
        Trigger Cpif Failover
        Unlock Cell4 And Cell1 Then Wait gNB Recover To Onair
    END
    Register For Normal Call and create PDU Successfully    ue_id=1    cell_id=1
    Register For Normal Call and create PDU Successfully    ue_id=2    cell_id=4
    Release Ues    ue_type=all


*** Keywords ***
Check PTP Master Clock State
    Object Should Exist In Du  PTPMASTER_R-1:clockState=MASTER_CLOCK_OK

Trsconfig Recovery From CU
    ${oamconfig_pod_name}    Find Pod Fullname In Aic vCU    oamconfig
    ${trsconfig_proc_id}  Execute Cmd On Vcu  kubectl exec -i ${oamconfig_pod_name} -n ${VCU_NAMESPACE} -- bash -c ${trsconfig_proc_check}
    Execute Cmd On Vcu  kubectl exec -i ${oamconfig_pod_name} -n ${VCU_NAMESPACE} -- bash -c "kill ${trsconfig_proc_id}"
    sleep    10s    wait trsconfig recovery
    ${trsconfig_proc_id}  Execute Cmd On Vcu  kubectl exec -i ${oamconfig_pod_name} -n ${VCU_NAMESPACE} -- bash -c ${trsconfig_proc_check}
    Lock Cell1
    Sleep    10s    wait cell stable
    Unlock Cell1
    Object Should Exist In Cu  NRCELL-1:operationalState=enabled
    Object Should Exist In Cu  NRCELL-1:barringStatus=unbarred

Lock Cells And AMF Link
    Delta Commission Parameters Cu    ${Delta_for_cell_amf_link_lock_cu}
    Object Should Exist In Cu  NRCELL-1:administrativeState=Locked
    Object Should Exist In Cu  NRCELL-2:administrativeState=Locked
    Object Should Exist In Cu  NRCELL-3:administrativeState=Locked
    Object Should Exist In Cu  NRCELL-4:administrativeState=Locked
    Object Should Exist In Cu  SERVEDAMF-1:administrativeState=Locked
    Object Should Exist In Cu  SERVEDAMF-2:administrativeState=Locked
    ${DU_STATE_ret}    Get Du State
    ${DU2_STATE_ret}    Get Du2 State
    Should Be True     "${DU_STATE_ret}"=="integrated to RAN"
    Should Be True     "${DU2_STATE_ret}"=="integrated to RAN"

Trigger Cpif Failover
    ${cpif_name}  Find Pod Fullname In Aic vCU  cpif
    ${cpifa1_name}  Find Pod Fullname In Aic vCU  cpifa1
    ${cpifa2_name}  Find Pod Fullname In Aic vCU  cpifa2
    ${cpifa3_name}  Find Pod Fullname In Aic vCU  cpifa3
    Start To Capture Wireshark Log Vcu    pod_name=cpif    redundantRole=standby
    Start To Capture Wireshark Log Vcu    pod_name=cpifa1    redundantRole=standby
    Start To Capture Wireshark Log Vcu    pod_name=cpifa2    redundantRole=standby
    Start To Capture Wireshark Log Vcu    pod_name=cpifa3    redundantRole=standby
    ${cpif_instance_list}    create list    ${cpif_name}    ${cpifa1_name}    ${cpifa2_name}    ${cpifa3_name}
    FOR    ${cpif_instance}    IN    @{cpif_instance_list}
        log to console    ${cpif_instance}
        Execute Cmd On Vcu  kubectl delete pod ${cpif_instance} -n ${VCU_NAMESPACE};date
    END
    sleep    1s    wait cpif pod get up

Unlock Cell4 And Cell1 Then Wait gNB Recover To Onair
    ${cell4_id}    Create List    4
    ${cell1_id}    Create List    1
    ${ng_link_id}    Create List    1
    unlock_cell_cu    cell_ids=${cell4_id}
    unlock_nglink_cu    ng_links_ids=${ng_link_id}
    Wait 10min If gNB onair Fail    DU_state="integrated to RAN"    DU2_state="onAir"
    unlock_cell_cu    cell_ids=${cell1_id}
    Wait 10min If gNB onair Fail    DU_state="onAir"    DU2_state="onAir"
    Sleep    5s    wait cell onair with stability

Wait Gnb Onair State Aic
    [Arguments]    ${DU_state}    ${DU2_state}
    ${onair_status_du}  Get Du State
    ${onair_status_du2}  Get Du2 State
    ${operational_state_cu}  Get Cu State
    Should Be True  "${operational_state_cu}"=="enabled"
    Should Be True  "${onair_status_du}"==${DU_state}
    Should Be True  "${onair_status_du2}"==${DU2_state}

Wait 10min If gNB onair Fail
    [Documentation]    Wait 10min due to vDU will be auot reset sometimes.
    [Arguments]    ${DU_state}    ${DU2_state}
    ${onair_status}    Set Variable    ${False}
    ${onair_status}    Run Keyword And Return Status    Wait Until Keyword Succeeds     5min    10s    Wait Gnb Onair State Aic
    ...    DU_state=${DU_state}    DU2_state=${DU2_state}
    Run Keyword If    '${onair_status}' == '${False}'    Sleep  600s
    Run Keyword If    '${onair_status}' == '${False}'    Fail    Wait AiC Gnb Onair State failed

Modify Cfg Aic
    Set QCI and Qos in WTS
    Set Bear in WTS
    Enable VoiceOverNRSupported in Uecapability for SA UE
    Set Sim gNB
    Set Second Sim AMF

Enable VoiceOverNRSupported in Uecapability for SA UE
    FOR    ${ue_id}    IN RANGE    1    30
        Update Cfg Aic    ue_param id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}
	END

Set QCI and Qos in WTS
    Update Cfg Aic    set_qosflow id=1 5qi=5 default=on
    Update Cfg Aic    set_qosflow id=2 5qi=6 default=off
    Update Cfg Aic    set_qosflow id=3 5qi=1
    Update Cfg Aic    enb_param id=1 drb_id_begin=3 endc_capable_qci=98
    Update Cfg Aic    qci_set qci=98 gbr=no priority=9 delay=300

Set Bear in WTS
    ${bearSetting1}    catenate
    ...    set_bearer id=2 ue=31 qci=98 pdn=1 ip=4.7.254.208 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
    ${bearSetting2}    catenate
    ...    set_bearer id=2 ue=32 qci=98 pdn=1 ip=4.7.254.209 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
    ${bearSetting3}    catenate
    ...    set_bearer id=2 ue=33 qci=98 pdn=1 ip=4.7.254.210 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
    ${bearSetting4}    catenate
    ...    set_bearer id=2 ue=34 qci=98 pdn=1 ip=4.7.254.211 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
    ${bearSetting5}    catenate
    ...    set_bearer id=2 ue=35 qci=98 pdn=1 ip=4.7.254.212 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
    Update Cfg Aic    ${bearSetting1}
    Update Cfg Aic    ${bearSetting2}
    Update Cfg Aic    ${bearSetting3}
    Update Cfg Aic    ${bearSetting4}
    Update Cfg Aic    ${bearSetting5}

Set Sim gNB
    ${v1}    catenate
    ...    set_gnb id=2 type=external plmn=311:489 ng=10.0.11.10 gnb_id=0x01:22 daemon=10.0.2.1:22222 xn=10.0.12.10
    ...    s1u=10.0.1.210 x2=10.0.1.10:36422 x2u=10.0.1.210 x2_peers=none amf=1-2

    Update Cfg Aic    ${v1}
    Update Cfg Aic    amf_ng_setup_param id=1 gnb=2 action=Respond_in_active_state ntimes=indefinite nth=1
    Update Cfg Aic    amf_ng_setup_param id=2 gnb=2 action=Respond_in_active_state ntimes=indefinite nth=1

Set Second Sim AMF
    ${v1}    catenate
    ...    amf_param id=2 reg_procedure_sequence=parallel_init_ctx_setup_req_and_reg_accept full_nas_auth=on
    ...    nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g
    Update Cfg Aic    set_amf_region id=2 tac_list=200,280,300,400,500,600 plmn=311:489,311:490,311:491
    Update Cfg Aic    set_amf id=2 daemon=10.0.2.1:22222 ng=10.0.11.2:38412 region=2 set_id=1 pointer=1
    Update Cfg Aic    ${v1}
    Update Cfg Aic    set_backup_amf main=1 backup_amfs=2
    Update Cfg Aic    set_nwslice id=1 snssai=0x01:13714341 amf=1-2 default=on ue=all

UE PDU Session Setup
    [Arguments]    ${ue_id}=1    ${gw_id}=1
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${gw_id}    QoS Routing Table

Modify UE Establishemnt Cause
    [Arguments]    ${ue_id}    ${cause}
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=${cause}

UE Register To GNB
    [Arguments]    ${ue_id}
    [Return]    ${matchecd_groups}[0][0]    ${matchecd_groups}[0][1]    ${matchecd_groups}[0][2]
    ${output}    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Reg
    ${filter_string}    catenate
    ...    AMF-(\\d+): UE with RAN UE NGAP ID (\\d+) and AMF UE NGAP ID (\\d+) is now Registered
    ${matchecd_groups}    Get Regexp Matches    ${output}    ${filter_string}    1    2    3
    log    ${matchecd_groups}[0][0]
    log    ${matchecd_groups}[0][1]
    log    ${matchecd_groups}[0][2]

Register For Normal Call and create PDU Successfully
    [Arguments]    ${ue_id}    ${cell_id}    ${enb_id}=2
    [Return]    ${amf_index}    ${sa_ueID}    ${amf_ngap_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Modify UE Establishemnt Cause    ${ue_id}    mo-Signalling
    ${amf_index}    ${sa_ueID}    ${amf_ngap_id}    UE Register To GNB    ${ue_id}
    UE PDU Session Setup    ${ue_id}    ${ue_id}


