*** Settings ***
Documentation    Suite description
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-kexin.bao
...    CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD    CRT    CB009189    release-SBTS23R1
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    @{2271_related_modification}
...    @{9189_related_modification}
#...    @{intra_freq_intra_DU_TDD}
...    @{GBR_5qi_4_200}
...    @{FDD_NRCELL_HO_configuration}
...    @{NRADJGNB}
...    @{NRADJNRCELL}
...    @{XN_Link}
...    @{GBR_5qi_1}
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-2:bwpType=dedicated
...    NRBTS/BWP_PROFILE-2:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS/BWP_PROFILE-2:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-2:locationAndBandwidthDl:cRbSizeDl=allRb
...    NRBTS/BWP_PROFILE-2:locationAndBandwidthDl:cRbStartDl=crb0
#...    NRBTS/BWP_PROFILE-2/PDCCH-1:locationAndBandwidthDl:cRbStartUl=crb0
@{PARAMS_IN_SWCONFIG}
...    0x890003=1 # CP-UE log level, default=2, 0=trace 1=debug 2=info 3=warning 4=error 5=vip 6=disable

@{2271_related_modification}
...    NRCELL:actAdaptiveSr=true
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:adaptiveSrBlockingMinimization=20
...    NRCELL:adaptiveSrLoadThresholdDown=50
...    NRCELL:adaptiveSrLoadThresholdUp=80
...    NRCELL:srPeriodicityMin=slots20
...    NRCELL:vonrReservation=30
...    NRCELL-2:vonrReservation=0
...    NRCELL-1:srPeriodicity=slots80
...    NRCELL-13:preferredVoNrSrPeriod=slots20
...    NRCELL-14:preferredVoNrSrPeriod=slots20
...    NRCELL-1:preferredVoNrSrPeriod=slots80
...    NRCELL-2:preferredVoNrSrPeriod=slots40
...    NRCELL-11:preferredVoNrSrPeriod=slots40
...    NRCELL-12:preferredVoNrSrPeriod=slots20
...    NRCELL:actVoNR=true


@{9189_related_modification}
...    NRCELL:actServiceAwareConfig=true
...    NRCELL-13:actServiceAwareConfig=false
#...    NRCELL-11:actServiceAwareConfig=false
#5QI=7
...    NRBTS/NRDRB-12:srPeriodicityDrb=40ms
...    NRBTS/NRDRB-12:payloadSizeSRDrb=500
#5QI=4/200
...    NRBTS/NRDRB-17:srPeriodicityDrb=5ms
...    NRBTS/NRDRB-17:payloadSizeSRDrb=500



...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actIntraFreqHoSA=true
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min

...    NRBTS/NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disable
...    NRBTS/NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disable
...    NRBTS/NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disable
...    NRBTS/NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disable
...    NRBTS/NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disable
...    NRBTS/NRPMRNL-1:miNrNgcFlexInterface=disable
#@{intra_freq_intra_DU_TDD}
#...    NRBTS:actInterMeNBMobility=true
#...    NRBTS:actIntraMeNBMobility=true

#...    NRBTS-1:actInterFreqInterGnbMobilityNSA=true
#...    NRBTS-1:actInterFreqIntraGnbMobilityNSA=true
#...    NRBTS-1:actIntraFreqInterGnbMobilityNSA3x=true
#
#
#...    NRCELL-3:a3MeasEnabled=rsrp
#...    NRCELL-3:absThreshSsbRsrpConsolidation=0
#...    NRCELL-3:sMeasConfigSsbRsrp=0
#...    NRCELL-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=8
#...    NRCELL-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=2
#...    NRCELL-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
#...    NRCELL-3:a5MeasEnabled=rsrp
#...    NRCELL-3:actGBRAdmissionControl=GBRService
#...    NRCELL-3:a5MeasSsbRsrp:a5HysteresisSsbRsrp=2
#...    NRCELL-3:a5MeasSsbRsrp:a5Threshold1SsbRsrp=10
#...    NRCELL-3:a5MeasSsbRsrp:a5Threshold2SsbRsrp=30
#...    NRCELL-3:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
#...    NRCELL-3/NRREL-1:cellIndividualSsbRsrpOffset=0dB
#...    NRCELL-3/NRREL-1:cellIndividualSsbRsrqOffset=0dB
#...    NRCELL-3/NRREL-1:gNbId=1
#...    NRCELL-3/NRREL-1:gNbIdLength=22
#...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
#...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
#...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
#...    NRCELL-3/NRREL-1:removeNotAllowed=false
#...    NRCELL-3/NRREL-1:lcrId=4
#


@{GBR_5qi_4_200}
...    NRCELL:actNonVoNRGbrService=true
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=4
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-17
...    NRBTS/NRDRB_5QI-7:fiveqiValueList=200
...    NRBTS/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-17

...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false
...    NRBTS/NRDRB_PDCP-3:tReorderingDl=ms80
...    NRBTS/NRDRB_PDCP-3:tReorderingUl=ms80
...    delete:NRBTS/NRDRB_PDCP-3:maxCidAllowed
...    delete:NRBTS/NRDRB_PDCP-3:outOfOrderDeliveryDl
...    delete:NRBTS/NRDRB_PDCP-3:outOfOrderDeliveryUl
...    delete:NRBTS/NRDRB_PDCP-3:pdcpDelayThresh1TrigType
...    delete:NRBTS/NRDRB_PDCP-3:pdcpMaxNumRetxPdu
...    delete:NRBTS/NRDRB_PDCP-3:pdcpPduRetxDelayThresh1
...    delete:NRBTS/NRDRB_PDCP-3:pdcpPduRetxDelayThresh2
...    delete:NRBTS/NRDRB_PDCP-3:pdcpRetxPduSendMaxDelay
...    delete:NRBTS/NRDRB_PDCP-3:pdcpSNLengthRedCap
...    delete:NRBTS/NRDRB_PDCP-3:xxFlowControlProfForCuIdx

...    NRBTS/NRDRB-17:actDddsReduction=false
...    NRBTS/NRDRB-17:actLostPduFastRetx=false
...    NRBTS/NRDRB-17:discardTimer=300ms
...    NRBTS/NRDRB-17:dlFlowControlAlgo=3gppFlowControl
...    NRBTS/NRDRB-17:dscp=28
...    NRBTS/NRDRB-17:l2OHFactorDl=16
...    NRBTS/NRDRB-17:l2OHFactorUl=35
...    NRBTS/NRDRB-17:maxDataRateGbrDl=30720
...    NRBTS/NRDRB-17:maxDataRateGbrUl=30720
...    NRBTS/NRDRB-17:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-17:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-17:maxTransferDelayGbr=20
...    NRBTS/NRDRB-17:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-7
...    NRBTS/NRDRB-17:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-17:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-17:numSduDiscard=1
...    NRBTS/NRDRB-17:queuingDelayDiscarding=Controlled Delay (CoDel)
...    NRBTS/NRDRB-17:queuingDelaySduDiscardThreshold=750
...    NRBTS/NRDRB-17:resType=GBR
...    NRBTS/NRDRB-17:rlcMode=RLC_AM
...    NRBTS/NRDRB-17:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-17:nsaDrbParam=${EMPTY}
...    NRBTS/NRDRB_MAC-5:delayTarget=50
...    NRBTS/NRDRB_MAC-5:lcgid=5
...    NRBTS/NRDRB_MAC-5:prioritisedBitRate=16kBps
...    NRBTS/NRDRB_MAC-5:schedulBSD=50ms
...    NRBTS/NRDRB_MAC-5:schedulPrio=4
...    NRBTS/NRDRB_MAC-7:delayTarget=50
...    NRBTS/NRDRB_MAC-7:lcgid=5
...    NRBTS/NRDRB_MAC-7:prioritisedBitRate=16kBps
...    NRBTS/NRDRB_MAC-7:schedulBSD=5ms
...    NRBTS/NRDRB_MAC-7:schedulPrio=7

@{GBR_5qi_1}
...    NRBTS/NRDRB_5QI-1:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10

...    NRBTS/NRDRB_MAC-3:delayTarget=50
...    NRBTS/NRDRB_MAC-3:lcgid=4
...    NRBTS/NRDRB_MAC-3:prioritisedBitRate=16kBps
...    NRBTS/NRDRB_MAC-3:schedulBSD=50ms
...    NRBTS/NRDRB_MAC-3:schedulPrio=5

...    NRBTS/NRDRB-10:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-10:rlcMode=RLC_UM
...    NRBTS/NRDRB-10:resType=GBR
...    NRBTS/NRDRB-10:discardTimer=100ms
...    NRBTS/NRDRB-10:dlFlowControlAlgo=none
...    NRBTS/NRDRB-10:dscp=46
...    NRBTS/NRDRB-10:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-10:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-10:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-10:maxTransferDelayGbr=20
...    NRBTS/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS/NRDRB-10:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-10:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-10:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-10:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS/NRDRB-10:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS/NRDRB-10:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS/NRDRB-10:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS/NRDRB-10:nsaDrbParam:dlDataSplitMode=dlOverF1U
...    NRBTS/NRDRB-10:nsaDrbParam:dlNumOfCongOrGainDdds=2
...    NRBTS/NRDRB-10:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS/NRDRB-10:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100

...    NRBTS/NRDRB-10:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS/NRDRB-10:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS/NRDRB-10:nsaDrbParam:prioritizeX2Period=500
...    NRBTS/NRDRB-10:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS/NRDRB-10:nsaDrbParam:ulDataSplitThreshold=infinity
...    NRBTS/NRDRB-10:numSduDiscard=1
#...    NRBTS/NRDRB-10:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100

...    NRBTS/NRDRB-17:queuingDelayDiscarding=Controlled Delay (CoDel)
...    NRBTS/NRDRB-17:queuingDelaySduDiscardThreshold=750
...    NRBTS/NRDRB-17:resType=GBR
...    NRBTS/NRDRB-17:rlcMode=RLC_AM
...    NRBTS/NRDRB-17:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-17:nsaDrbParam=${EMPTY}

...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50
...    NRBTS/NRDRB_RLC_UM-1:nrDrbRlcUmId=1
...    NRBTS/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms50

@{FDD_NRCELL_HO_configuration}
...    NRCELL-11:a3MeasEnabled=rsrp
...    NRCELL-11:a3MeasSsbRsrp:a3HysteresisSsbRsrp=4
...    NRCELL-11:a3MeasSsbRsrp:a3OffsetSsbRsrp=2
...    NRCELL-11:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-11:absThreshSsbRsrpConsolidation=0
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=36
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-13:a3MeasEnabled=rsrp
...    NRCELL-13:a3MeasSsbRsrp:a3HysteresisSsbRsrp=4
...    NRCELL-13:a3MeasSsbRsrp:a3OffsetSsbRsrp=2
...    NRCELL-13:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-13:absThreshSsbRsrpConsolidation=0
...    NRCELL-13:measGapSelectionSA=favourUeThroughput
...    NRCELL-13:sMeasConfigSsbRsrp=0
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-1:gNbId=1
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-1:lcrId=11

@{NRADJGNB}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=36
...    NRBTS/NRADJGNB-1:gNodeBIdCtrl=oamControlled
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3

@{NRADJNRCELL}
...    NRBTS/NRADJNRCELL-1:cellDepType=SA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=66
...    NRBTS/NRADJNRCELL-1:gNbId=36
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=344000
...    NRBTS/NRADJNRCELL-1:physCellId=382
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:ssbFrequency=424090


@{XN_Link}
...    NRBTS:actIncXn=true
...    NRBTS/XNLINK-1:cPlaneIpAddr=10.0.1.124
...    NRBTS/XNLINK-1:cPlaneIpAddrCtrl=oamControlled

...    NRBTS:actIntraNrNgHo=sourceAndTarget
...    NRBTS:tNgRelocExecDeltN=3000
...    NRBTS:tNgRelocCancelN=2000
...    NRBTS:tNgRelocOverallN=2000
...    NRBTS:tNgRelocPrepN=2000

@{OnlineParam_for_A023}
...    NRBTS/NRDRB-13:srPeriodicityDrb=10ms
...    NRBTS/NRDRB-13:payloadSizeSRDrb=100

*** Test Cases ***
CB009189-ET-A023_SA_FDD_9189enable_9189DRBsl10_add_VONRsl20_intergNB_HO_A3_9189disable_FDD
    [Documentation]
    ...    1. This user scenario describes Inter-gNB handover to target cell after
    ...    successfully configure periodicity and possibly grant size for Scheduling Request per DRB profile.
    ...    2. Configuration
    ...    5GC002271 feature is enabled,and CB009189 flag is enabled.
    ...    A3 is configured for NRCELL-11.
    ...    3. Test Case Steps:
    ...    a.UE register on NRCELL-11, and check SR period selection.
    ...    b.setup VONR, check SR period selection.
    ...    c.send A3 measurement, intergNB Xn HO to simGNB and HO back to NRCELL-13 successfully,then check SR period selection.
    ...    d.UE deregister.
    [Tags]    QC_224561    owner-kexin.bao
    OnlineParamChange    ${OnlineParam_for_A023}
    XN setup
    UE Attach To Target Cell    ue_id=81    cell_id=11    regexp=periodicityAndOffset sl10
    Setup VONR    ue_id=81    pdu_id=1
    Handover From gNB to Sim Should Success    ue_id=81    carrierfreq=424090    event_id=A3    phycell_id=382
    Handover From Sim to gNB Should Success    ue_id=81    carrierfreq=427970    event_id=A3    phycell_id=62
    UE Deregister From gNB    ue_id=81
    Check Wireshark Log    ${CURDIR}${/}a2a_CB009189A023${/}a2a.ini    wait_string=UEContextReleaseComplete::6

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
    Update Cfg    set_qosflow id=8 5qi=8 default=on
    Update Cfg    set_qosflow id=20 5qi=200 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    ${CELL_382}    Catenate    set_cell id=1 gnb=4 pci=127:1 tac=200 nrci=0x01 tdd_cell=off proxy=$PROXY_SERVER4_IP:9999
    ...    nr_arfcn=344000:424000 gscn=5300 mandatory_for_activation=off
    Update Cfg    ${CELL_382}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

UE Attach To Target Cell
    [Arguments]    ${ue_id}    ${cell_id}    ${regexp}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${retvalue}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table
    Should Contain    ${retvalue}    ${regexp}

Setup VONR And GBR Bearer
    [Arguments]    ${ue_id}    ${pdu_id_1}    ${pdu_id_2}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id_1} qosflows_to_add=5 by=amf
    ...    pass_regexp=Created FiveQi:Qfi mapping fiveQi 5
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id_1} qosflows_to_add=1 by=amf
    ...    pass_regexp=periodicityAndOffset sl80
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id_1} qosflows_to_add=20 by=amf
    ...    pass_regexp=Created FiveQi:Qfi mapping fiveQi 200
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id_2} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id_2} gw=${pdu_id_2} nwslice=1    QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id_2} qosflows_to_add=7 by=amf
    ...    pass_regexp=Created FiveQi:Qfi mapping fiveQi 7

Verify Throuput
    [Arguments]    ${ue_id}    ${pdu_id}    ${Tput_dl}    ${Tput_ul}    ${sleep_time}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${send_dl}=70    ${send_ul}=10    ${sleep_time}=10s
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=${send_dl}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=${send_ul}
    Verify Throuput    ${ue_id}    ${pdu_id}    ${send_dl}*0.9    ${send_ul}*0.9    ${sleep_time}

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger A5 And Delete DRB
    [Arguments]    ${ue_id}    ${carrierfreq}    ${phycell_id}    ${pass_regexp}    ${regexp}
    sleep    2s    sleep for A5 MR
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A5
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A5 srsrp_nr=8
    ...    phycell_id=${phycell_id} nrsrp_nr=80
    ${retvalue}    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}
    Should Contain    ${retvalue}    ${regexp}
    Verify Throuput    ${ue_id}    pdu_id=1    Tput_dl=63    Tput_ul=9    sleep_time=10s
    Verify Throuput    ${ue_id}    pdu_id=2    Tput_dl=63    Tput_ul=9    sleep_time=10s
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_del=8 pdu=1 qosflows_to_del=20 by=amf
    ...    periodicityAndOffset sl40

XN setup
    Execute Egate Command    gnb_param id=4 xn_listening_socket=1 send_xn_setup=true measEvent=A3
    Execute Egate Command    gnb_xn_ngran_conf_update_param id=4 reset
    Execute Egate Command    gnb_xn_setup_param id=4 reset
    Execute Egate Command    gnb_xn_link_up gnb=4 target=2    GNB-4: XnAP Link with GNB-2
    Execute Egate Command    gnb_param id=4 sa_ho=xn_based

Setup VONR
    [Arguments]    ${ue_id}    ${pdu_id}
    Execute Egate Command    ue_pdu_session_modify ue=81 pdu=1 qosflows_to_add=5 by=amf    pass_regexp=Created FiveQi:Qfi mapping fiveQi 5
    Execute Egate Command    ue_pdu_session_modify ue=81 pdu=1 qosflows_to_add=1 by=amf    pass_regexp=Created FiveQi:Qfi mapping fiveQi 1
    Send And Verify Throuput    ue_id=81    pdu_id=1    send_dl=70    send_ul=10    sleep_time=10s

Handover From gNB to Sim Should Success
    [Arguments]    ${ue_id}    ${carrierfreq}    ${event_id}    ${phycell_id}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=${event_id}
    ${cmd}    Set Variable
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_id} srsrp_nr=20 phycell_id=${phycell_id} nrsrp_nr=80
    Execute Egate Command    ${cmd}    pass_regexp=Inter-eNB handover from EXT_ENB-2.11 to ENB-4.1 performed
    Execute Egate Command    ue_disp state=ACTIVE    4.1

Handover From Sim to gNB Should Success
    [Arguments]    ${ue_id}    ${carrierfreq}    ${event_id}     ${phycell_id}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=${event_id}
    ${cmd}    Set Variable
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_id} srsrp_nr=20 phycell_id=${phycell_id} nrsrp_nr=80
    Execute Egate Command    ${cmd}    pass_regexp=Inter-eNB handover from ENB-4.1 to EXT_ENB-2.13 performed
    Execute Egate Command    ue_disp state=ACTIVE    2.13
    Verify Throuput    ue_id=${ue_id}    pdu_id=1    Tput_dl=63    Tput_ul=9    sleep_time=10s
