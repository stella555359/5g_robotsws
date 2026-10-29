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
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-2:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS/BWP_PROFILE-2:locationAndBandwidthUl:cRbStartUl=crb0
...    @{2271_related_modification}
...    @{9189_related_modification}
...    @{GBR_5qi_4}
...    @{inter_RAT_HO_modification}
...    @{NRCELL_12_configuration}
...    @{NRCELL_1_configuration}

@{2271_related_modification}
...    NRCELL:actAdaptiveSr=true
...    NRCELL:adaptiveSrBlockingMinimization=20
...    NRCELL:adaptiveSrLoadThresholdDown=50
...    NRCELL:adaptiveSrLoadThresholdUp=80
...    NRCELL-1:srPeriodicity=slots160
...    NRCELL-2:srPeriodicity=slots40
...    NRCELL-11:srPeriodicity=slots80
...    NRCELL-12:srPeriodicity=slots40
...    NRCELL:srPeriodicityMin=slots10
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    NRCELL-2:actVoNR=false
...    NRCELL-2:actEnhancedVoNR=false
...    NRCELL:vonrReservation=30
...    NRCELL-11:vonrReservation=0
...    NRCELL-1:vonrReservation=50
...    NRCELL-1:preferredVoNrSrPeriod=slots80
...    NRCELL-11:preferredVoNrSrPeriod=slots20
...    NRCELL-12:preferredVoNrSrPeriod=slots40
...    NRCELL-13:preferredVoNrSrPeriod=slots20
...    NRCELL-14:preferredVoNrSrPeriod=slots20

@{9189_related_modification}
...    NRCELL:actServiceAwareConfig=true
...    NRCELL-2:actServiceAwareConfig=false
#default 5qi=8
...    NRBTS/NRDRB-13:srPeriodicityDrb=10ms
...    NRBTS/NRDRB-13:payloadSizeSRDrb=750
#5qi=4
...    NRBTS/NRDRB-17:srPeriodicityDrb=5ms
...    NRBTS/NRDRB-17:payloadSizeSRDrb=150

@{GBR_5qi_4}
...    NRCELL:actNonVoNRGbrService=true
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=4
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-17
...    NRBTS/NRDRB_5QI-8:fiveqiValueList=71
...    NRBTS/NRDRB_5QI-8:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-17
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

@{NRCELL_12_configuration}
...    NRCELL-12:measGapSelectionSA=favourUeThroughput
...    NRCELL-12:a1MeashoEnabled=rsrpAndRsrq
...    NRCELL-12:a2MeashoEnabled=rsrpAndRsrq
...    NRCELL-12:a1MeashoEnabledSA=rsrpAndRsrq
...    NRCELL-12:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-12:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=6|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-12:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-12:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=70|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-12:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-12:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=0|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-12:a1MeashoSsbRsrqSA:a1HysteresisHoSsbRsrqVoNr=6|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-12:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=30|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-12:a1MeashoSsbRsrqSA:a1ThresholdHoSsbRsrqVoNr=40|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-12:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms480|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-12:a2MeashoEnabledSA=rsrpAndRsrq
...    NRCELL-12:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-12:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=6|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-12:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=50|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-12:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=60|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-12:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-12:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=0|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-12:a2MeashoSsbRsrqSA:a2HysteresisHoSsbRsrqVoNr=6|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-12:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=20|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-12:a2MeashoSsbRsrqSA:a2ThresholdHoSsbRsrqVoNr=30|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-12:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms480|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-12/NRRELE-1:cellIndividualOffset=0dB
...    NRCELL-12/NRRELE-1:eNodeBId=18
...    NRCELL-12/NRRELE-1:eutranCellExcluded=false
...    NRCELL-12/NRRELE-1:lcrId=1
...    NRCELL-12/NRRELE-1:removeNotAllowed=false
...    NRCELL-12/NRRELE-1:ecgiPlmn:mcc=311
...    NRCELL-12/NRRELE-1:ecgiPlmn:mnc=489
...    NRCELL-12/NRRELE-1:ecgiPlmn:mncLength=3
...    NRCELL-12:nrhoirDNList=MRBTS-1/NRBTS-1/NRHOIR-1

@{NRCELL_1_configuration}
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRCELL-1:a1MeashoEnabled=rsrpAndRsrq
...    NRCELL-1:a2MeashoEnabled=rsrpAndRsrq
...    NRCELL-1:a1MeashoEnabledSA=rsrpAndRsrq
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=6|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=70|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=0|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrqSA:a1HysteresisHoSsbRsrqVoNr=6|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=30|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrqSA:a1ThresholdHoSsbRsrqVoNr=40|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms480|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a2MeashoEnabledSA=rsrpAndRsrq
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=6|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=50|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=60|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=0|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresisHoSsbRsrqVoNr=6|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=20|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdHoSsbRsrqVoNr=30|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms480|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1/NRRELE-1:cellIndividualOffset=0dB
...    NRCELL-1/NRRELE-1:eNodeBId=18
...    NRCELL-1/NRRELE-1:eutranCellExcluded=false
...    NRCELL-1/NRRELE-1:lcrId=1
...    NRCELL-1/NRRELE-1:removeNotAllowed=false
...    NRCELL-1/NRRELE-1:ecgiPlmn:mcc=311
...    NRCELL-1/NRRELE-1:ecgiPlmn:mnc=489
...    NRCELL-1/NRRELE-1:ecgiPlmn:mncLength=3
...    NRCELL-1:nrhoirDNList=MRBTS-1/NRBTS-1/NRHOIR-1

@{inter_RAT_HO_modification}
...    NRBTS:actInterRatHoFromEutraToSA=true
...    NRBTS:actInterRatHoSA=true
...    NRBTS:nonContentRachAcFullConfigHo=true
...    NRBTS:tNgRelocExecDeltL=5000
...    NRBTS/NRADJECELL-1:eNodeBId=18
...    NRBTS/NRADJECELL-1:ePSTrackingAreaCode=0
...    NRBTS/NRADJECELL-1:earfcnValue=1
...    NRBTS/NRADJECELL-1:lcrId=1
...    NRBTS/NRADJECELL-1:physCellId=11
...    NRBTS/NRADJECELL-1:ecgiPlmn:mcc=311
...    NRBTS/NRADJECELL-1:ecgiPlmn:mnc=489
...    NRBTS/NRADJECELL-1:ecgiPlmn:mncLength=3
...    NRBTS/NRADJECELL-1:enbPlmn:mcc=311
...    NRBTS/NRADJECELL-1:enbPlmn:mnc=489
...    NRBTS/NRADJECELL-1:enbPlmn:mncLength=3

...    NRHOIR-1:allowedMeasBandwidth=mbw100
...    NRHOIR-1:b2MeashoEnabled=rsrp
...    NRHOIR-1:b2Threshold1hoRsrp=35
...    NRHOIR-1:b2Threshold1hoRsrpVoNr=35
...    NRHOIR-1:b2Threshold1hoRsrq=50
...    NRHOIR-1:b2Threshold1hoRsrqVoNr=50
...    NRHOIR-1:earfcnValue=1
...    NRHOIR-1:eutraFreqQOffsetRange=0dB
...    NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrp=0|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrpVoNr=4|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrp=18|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrpVoNr=28|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrp=ms480|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrq=0|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrqVoNr=4|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrq=2|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrqVoNr=10|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2TimeToTriggerhoRsrq=ms480|b2TimeToTriggerhoRsrqVoNr=ms512

*** Test Cases ***
CB009189-ET-A24_SA_FDD_VONRsl40_add_9189DRBsl5_interRAT_HO
    [Documentation]
    ...    1. This user scenario describes Inter-RAT handover to target cell after
    ...    successfully configure periodicity and possibly grant size for Scheduling Request per DRB profile.
    ...    2. Configuration
    ...    5GC002271 feature is enabled,and CB009189 flag is enabled.
    ...    A2 is configured for NRCELL-12.
    ...    NRHOIR and NRADJECELL are configured.
    ...    3. Test Case Steps:
    ...    a.UE register on NRCELL-12, and check SR period selection.
    ...    b.setup VONR , check TPUT.
    ...    c.setup 9189 DRB for UE3, check TPUT.
    ...    d.send A2 B2 measurement, then inter-RAT HO to simgNB and HO back successfully,and check SR period selection.
    ...    e.UE deregister.
    [Tags]    QC_224568    owner-kexin.bao
    Clear Counter Files
    UE Attach To Target Cell    ue_id=81    cell_id=12    regexp=periodicityAndOffset sl10
    Setup DRBs and Check Tput A24
    Send A2 To Trigger B2    ue_id=81    carrierfreq=127450    event_type=A2
    Trigger_B2_MR_to_HO_to_LTE    ue_id=81    carrierfreq=1    event_type=B2    phycell_id=11
    Trigger_HO_back_from_LTE    ue_id=81    target_cell=11
    Verify Tput on Every DRB A24
    UE Deregister From gNB    ue_id=81
    Check RRC log    ${CURDIR}${/}a2a_CB009189A024${/}a2a.ini

CB009189-ET-A25_SA_TDD_9189enable_9189DRBsl20_2271DRBsl10_interRAT_HO_9189disable
    [Documentation]
    ...    1. This user scenario describes Inter-RAT handover to target cell after
    ...    successfully configure periodicity and possibly grant size for Scheduling Request per DRB profile.
    ...    2. Configuration
    ...    5GC002271 feature is enabled,and CB009189 flag is enabled.
    ...    A2 is configured for NRCELL-12.
    ...    NRHOIR and NRADJECELL are configured.
    ...    3. Test Case Steps:
    ...    a.UE register on NRCELL-1 with 9189 default DRB, and check SR period selection.
    ...    b.setup normal DRB , check TPUT.
    ...    c.send A2 B2 measurement, then inter-RAT HO to simgNB and HO back successfully,and check SR period selection.
    ...    d.UE deregister.
    [Tags]    QC_224567    owner-kexin.bao
    UE Attach Preparation
    UE Attach To Target Cell    ue_id=81    cell_id=1    regexp=periodicityAndOffset sl20
    Setup DRBs and Check Tput A25
    Send A2 To Trigger B2    ue_id=81    carrierfreq=518910    event_type=A2
    Trigger_B2_MR_to_HO_to_LTE    ue_id=81    carrierfreq=1    event_type=B2    phycell_id=11
    Trigger_HO_back_from_LTE    ue_id=81    target_cell=2
    Verify Tput on Every DRB A25
    UE Deregister From gNB    ue_id=81
    Check RRC log    ${CURDIR}${/}a2a_CB009189A025${/}a2a.ini

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
    Update Cfg    set_qosflow id=5 5qi=5 default=on
    Update Cfg    set_qosflow id=6 5qi=6
    Update Cfg    set_qosflow id=7 5qi=7
    Update Cfg    set_qosflow id=8 5qi=8
    ${set_gnb5}    catenate    set_gnb id=5 type=simulated plmn=311:489 ng=10.0.1.15 daemon=10.0.2.1:22222 gnb_id=0x12:28
    ...    nssai=0x01:0xD143A5
    Update Cfg    ${set_gnb5}
    ${set_gnb5_cell1}    catenate    set_cell id=1 gnb=5 pci=3:2 earfcn=1:18001 tac=0 proxy=10.0.2.92:12218 nrci=0x1
    ...    tdd_cell=on bw=20MHz technology=lte
    Update Cfg    ${set_gnb5_cell1}
    Update Cfg    gnb_param id=5 xn_listening_socket=true

UE Attach To Target Cell
    [Arguments]    ${ue_id}    ${cell_id}    ${regexp}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${retvalue}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table
    Should Contain    ${retvalue}    ${regexp}

Verify Throuput
    [Arguments]    ${ue_id}    ${qfi}    ${Tput_dl}    ${Tput_ul}    ${sleep_time}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Verify Throuput A24
    [Arguments]    ${ue_id}    ${qfi}    ${Tput_dl}    ${Tput_ul}    ${sleep_time}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}>${Tput_ul}

Send And Verify Throuput
    [Arguments]    ${ue_id}=81    ${qfi}=1    ${send_dl}=70    ${send_ul}=10    ${sleep_time}=10s
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=${qfi} dir=dl mbps=${send_dl}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=${qfi} dir=ul mbps=${send_ul}
    Verify Throuput    ${ue_id}    ${qfi}    ${send_dl}*0.9    ${send_ul}*0.9    ${sleep_time}

Send And Verify Throuput A24
    [Arguments]    ${ue_id}=81    ${qfi}=1    ${send_dl}=70    ${send_ul}=10    ${sleep_time}=10s
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=${qfi} dir=dl mbps=${send_dl}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=${qfi} dir=ul kbps=${send_ul}
    Verify Throuput A24    ${ue_id}    ${qfi}    ${send_dl}*0.9    ${send_ul}*0.9    ${sleep_time}

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger_B2_MR_to_HO_to_LTE
    [Arguments]    ${ue_id}    ${carrierfreq}    ${event_type}    ${phycell_id}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}
    ...    event_type=B2    carrierfreq_rat=EUTRAN
    ${meas_para}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} srsrp_nr=11
    ...    srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=30 nrsrq_nr=30
    Execute Egate Command    ${meas_para}    pass_regexp=UeContextReleaseComplete
    sleep    20s    reason=wait timer

Trigger_HO_back_from_LTE
    [Arguments]    ${ue_id}    ${target_cell}
    Execute Egate Command    gnb_trigger_inter_rat_handover_to_5g ue=${ue_id} target_gnb=2 target_cell=${target_cell} plmn=311:489
    ...    pass_regexp=ENB-5.1 to EXT_ENB-2.${target_cell}
    sleep    100s    reason=wait timer

Send A2 To Trigger B2
    [Arguments]    ${ue_id}    ${carrierfreq}    ${event_type}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=${event_type}
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type} srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=measObject measObjectEUTRA

UE Attach Preparation
    Execute Egate Command    qosflow_modify default=on qos_flow=8 priority=1

Setup DRBs and Check Tput A24
    Send And Verify Throuput A24    ue_id=81    qfi=1    send_dl=10    send_ul=800    sleep_time=10s
    ${retvalue}    Execute Egate Command    ue_pdu_session_modify ue=81 pdu=1 qosflows_to_add=1 by=amf
    ...    pass_regexp=Added QosFlow with QFI:2 5QI:1
    Should Contain    ${retvalue}    periodicityAndOffset sl40
    Send And Verify Throuput A24    ue_id=81    qfi=2    send_dl=10    send_ul=800    sleep_time=10s
    Verify Throuput A24    ue_id=81    qfi=1    Tput_dl=9    Tput_ul=720    sleep_time=2s
    ${retvalue}    Execute Egate Command    ue_pdu_session_modify ue=81 pdu=1 qosflows_to_add=4 by=amf
    ...    pass_regexp=Added QosFlow with QFI:3 5QI:4
    Should Contain    ${retvalue}    periodicityAndOffset sl5
    Send And Verify Throuput A24    ue_id=81    qfi=3    send_dl=10    send_ul=800    sleep_time=10s
    Verify Throuput A24    ue_id=81    qfi=1    Tput_dl=9    Tput_ul=720    sleep_time=2s
    Verify Throuput A24    ue_id=81    qfi=2    Tput_dl=9    Tput_ul=720    sleep_time=2s

Setup DRBs and Check Tput A25
    Send And Verify Throuput    ue_id=81    qfi=1    send_dl=10    send_ul=5    sleep_time=10s
    Execute Egate Command    ue_pdu_session_modify ue=81 pdu=1 qosflows_to_add=6 by=amf
    ...    pass_regexp=Added QosFlow with QFI:2 5QI:6
    Send And Verify Throuput    ue_id=81    qfi=2    send_dl=10    send_ul=5    sleep_time=10s
    Verify Throuput    ue_id=81    qfi=1    Tput_dl=9    Tput_ul=4    sleep_time=10s

Verify Tput on Every DRB A24
    Verify Throuput A24    ue_id=81    qfi=1    Tput_dl=9    Tput_ul=720    sleep_time=10s
    Verify Throuput A24    ue_id=81    qfi=2    Tput_dl=9    Tput_ul=720    sleep_time=2s
    Verify Throuput A24    ue_id=81    qfi=3    Tput_dl=9    Tput_ul=720    sleep_time=2s

Verify Tput on Every DRB A25
    Verify Throuput    ue_id=81    qfi=1    Tput_dl=9    Tput_ul=4    sleep_time=10s
    Verify Throuput    ue_id=81    qfi=2    Tput_dl=9    Tput_ul=4    sleep_time=2s
