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
...    @{GBR_5qi_4_71}
...    @{intra_freq_intra_DU_FDD}
#...    @{intra_freq_intra_DU_TDD}
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS/BWP_PROFILE-1:locationAndBandwidthUl:cRbStartUl=crb0
...    NRBTS/BWP_PROFILE-2:locationAndBandwidthUl:cRbSizeUl=allRb
...    NRBTS/BWP_PROFILE-2:locationAndBandwidthUl:cRbStartUl=crb0

@{2271_related_modification}
...    NRCELL:actAdaptiveSr=true
...    NRCELL:adaptiveSrBlockingMinimization=20
...    NRCELL:adaptiveSrLoadThresholdDown=50
...    NRCELL:adaptiveSrLoadThresholdUp=80
...    NRCELL:srPeriodicityMin=slots20
...    NRCELL-11:srPeriodicity=slots80
...    NRCELL-13:srPeriodicity=slots80

...    NRCELL-11:srPeriodicityMin=slots10
...    NRCELL-13:srPeriodicityMin=slots10
#...    NRCELL-4:srPeriodicityMin=slots10
...    NRCELL:vonrReservation=30
...    NRCELL-2:vonrReservation=0
...    NRCELL-1:srPeriodicity=slots80
...    NRCELL-13:preferredVoNrSrPeriod=slots20
...    NRCELL-14:preferredVoNrSrPeriod=slots20
...    NRCELL-11:preferredVoNrSrPeriod=slots20
...    NRCELL-12:preferredVoNrSrPeriod=slots20
...    NRCELL-2:preferredVoNrSrPeriod=slots40
...    NRCELL-1:preferredVoNrSrPeriod=slots40
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true

@{9189_related_modification}
...    NRBTS/NRDRB-13:srPeriodicityDrb=10ms
...    NRBTS/NRDRB-13:payloadSizeSRDrb=500
...    NRCELL:actServiceAwareConfig=true

@{GBR_5qi_4_71}
...    NRCELL:actNonVoNRGbrService=true
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=4
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-17
...    NRBTS/NRDRB_5QI-8:fiveqiValueList=71
...    NRBTS/NRDRB_5QI-8:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-17

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

@{intra_freq_intra_DU_FDD}
...    NRCELL-13/NRCELL_FDD-1:nrarfcnDl=424000
...    NRCELL-13/NRCELL_FDD-1:nrarfcnUl=344000
...    NRCELL-13:gscnOrSsPbchArfcn=5300
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actIntraFreqHoSA=true
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL-11:a3MeasEnabled=rsrp
...    NRCELL-11:a3MeasSsbRsrp:a3HysteresisSsbRsrp=4
...    NRCELL-11:a3MeasSsbRsrp:a3OffsetSsbRsrp=2
...    NRCELL-11:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-11:absThreshSsbRsrpConsolidation=0
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRCELL-11:a5MeasEnabled=rsrp
...    NRCELL-11:a5MeasSsbRsrp:a5HysteresisSsbRsrp=2
...    NRCELL-11:a5MeasSsbRsrp:a5Threshold1SsbRsrp=10
...    NRCELL-11:a5MeasSsbRsrp:a5Threshold2SsbRsrp=30
...    NRCELL-11:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:lcrId=13
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:nrDcAllowed=false
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
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
...    NRCELL-13/NRREL-1:lcrId=11
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-1:nrDcAllowed=false
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3



@{intra_freq_intra_DU_TDD}
...    NRBTS-1:actIntraFreqHoSA=true
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    NRCELL-3:a3MeasEnabled=rsrp
...    NRCELL-3:absThreshSsbRsrpConsolidation=0
...    NRCELL-3:sMeasConfigSsbRsrp=0
...    NRCELL-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=8
...    NRCELL-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=2
...    NRCELL-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-1:gNbId=1
...    NRCELL-3/NRREL-1:gNbIdLength=22
...    NRCELL-3/NRREL-1:lcrId=4
...    NRCELL-3/NRREL-1:removeNotAllowed=false
...    NRCELL-3/NRREL-1:nrDcAllowed=false
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3

@{OnlineParam_for_A013}
...    NRBTS/NRDRB-13:srPeriodicityDrb=80ms
...    NRBTS/NRDRB-13:payloadSizeSRDrb=800
...    NRBTS/NRDRB-10:srPeriodicityDrb=10ms
...    NRBTS/NRDRB-10:payloadSizeSRDrb=900
...    NRBTS/NRDRB-17:srPeriodicityDrb=40ms
...    NRBTS/NRDRB-17:payloadSizeSRDrb=900

@{PM_Counters_Check_A13_1}
...    NRBTS-1:NSL:${ATT_GNB_INTRA_DU_HO_SLICE}=1
...    NRBTS-1:NSL:${SUCC_GNB_INTRA_DU_HO_SLICE}=1
...    NRCELL-11:NRUC:${SR_SLOT20_POOL_SIZE}=160|80|240
...    NRCELL-13:NRUC:${SR_SLOT20_POOL_SIZE}=160|80|240
...    NRCELL-11:NRUC:${SR_SLOT80_POOL_SIZE}=640|320|960
...    NRCELL-13:NRUC:${SR_SLOT80_POOL_SIZE}=640|320|960
...    NRCELL-11:NRUC:${SR_SLOT10_POOL_AS_MAIN}=300
...    NRCELL-13:NRUC:${SR_SLOT10_POOL_AS_MAIN}=300
...    NRCELL-11:NRUC:${SR_SLOT20_POOL_AS_MAIN}=0
...    NRCELL-13:NRUC:${SR_SLOT20_POOL_AS_MAIN}=0
...    NRCELL-11:NRUC:${SR_SLOT80_POOL_AS_MAIN}=0
...    NRCELL-13:NRUC:${SR_SLOT80_POOL_AS_MAIN}=0
...    NRCELL-11:NRUC:${MAX_USED_RES_SLOT20}=1
...    NRCELL-13:NRUC:${MAX_USED_RES_SLOT20}=1
...    NRCELL-11:NRUC:${SUM_USED_RES_SLOT20}>0
...    NRCELL-13:NRUC:${SUM_USED_RES_SLOT20}>0
...    NRCELL-11:NRUC:${MAX_USED_RES_SLOT80}=1
...    NRCELL-13:NRUC:${MAX_USED_RES_SLOT80}=0
...    NRCELL-11:NRUC:${SUM_USED_RES_SLOT80}>10
...    NRCELL-13:NRUC:${SUM_USED_RES_SLOT80}=0
...    NRCELL-11:NRUC:${SUM_USED_RES_SS_SR_SLOT80}>10
...    NRCELL-13:NRUC:${SUM_USED_RES_SS_SR_SLOT80}=0
...    NRCELL-11:NRUC:${NUM_SS_SR_40SLOT_PERIOD_SUC}=0
...    NRCELL-11:NRUC:${NUM_SS_SR_40SLOT_PERIOD_REQ}=0
...    NRCELL-11:NRUC:${NUM_SS_SR_80SLOT_PERIOD_SUC}=1
...    NRCELL-13:NRUC:${NUM_SS_SR_80SLOT_PERIOD_SUC}=0
...    NRCELL-11:NRUC:${NUM_SS_SR_80SLOT_PERIOD_REQ}=1
...    NRCELL-13:NRUC:${NUM_SS_SR_80SLOT_PERIOD_REQ}=0
...    NRCELL-11:NRUC:${MAX_VOICE_OUT_OF_PREF_SR_POOL}=0
...    NRCELL-13:NRUC:${MAX_VOICE_OUT_OF_PREF_SR_POOL}=1
...    NRCELL-11:NRUC:${SUM_VOICE_OUT_OF_PREF_SR_POOL}=0
...    NRCELL-13:NRUC:${SUM_VOICE_OUT_OF_PREF_SR_POOL}>0

@{PM_Counters_Check_A13_2}
...    NRCELL-13:NRUC:${MAX_USED_RES_SLOT20}=0
...    NRCELL-13:NRUC:${SUM_USED_RES_SLOT20}=0
...    NRCELL-13:NRUC:${MAX_USED_RES_SLOT40}=1
...    NRCELL-13:NRUC:${SUM_USED_RES_SLOT40}>0
...    NRCELL-13:NRUC:${MAX_USED_RES_SLOT80}=1
...    NRCELL-13:NRUC:${SUM_USED_RES_SLOT80}>0
...    NRCELL-13:NRUC:${SUM_USED_RES_SS_SR_SLOT80}>10
...    NRCELL-13:NRUC:${NUM_SS_SR_80SLOT_PERIOD_SUC}=1
...    NRCELL-13:NRUC:${NUM_SS_SR_80SLOT_PERIOD_REQ}=1
...    NRCELL-13:NRUC:${MAX_VOICE_OUT_OF_PREF_SR_POOL}=0
...    NRCELL-13:NRUC:${SUM_VOICE_OUT_OF_PREF_SR_POOL}=0

${ATT_GNB_INTRA_DU_HO_SLICE}    M55149C00004
#The number of Intra-Frequency Intra-gNB Intra-DU HO attempted for the given slice and PLMN
${SUCC_GNB_INTRA_DU_HO_SLICE}    M55149C00005
#The number of Intra-Frequency Intra-gNB Intra-DU HO successful for the given slice and PLMN
${SR_SLOT20_POOL_SIZE}    M55165C00003
#The total number of resources in the slots20 scheduling request pool.
${SR_SLOT80_POOL_SIZE}    M55165C00005
#The total number of resources in the slots80 scheduling request pool.
${SR_SLOT10_POOL_AS_MAIN}    M55165C00008
#The counter indicates how often slot10 SR pool is the main pool.
${SR_SLOT20_POOL_AS_MAIN}    M55165C00009
#The counter indicates how often slot20 SR pool is the main pool.
${SR_SLOT80_POOL_AS_MAIN}    M55165C00011
#The counter indicates how often slot80 SR pool is the main pool.
${MAX_USED_RES_SLOT10}    M55165C00018
#The maximum number of resources that are allocated to UEs in slot10 SR pool. UE number
${SUM_USED_RES_SLOT10}    M55165C00019
#The sum of used slot10 SR pool resources. seconds
${MAX_USED_RES_SLOT20}    M55165C00020
#The maximum number of resources that are allocated to UEs in slot20 SR pool. UE number
${SUM_USED_RES_SLOT20}    M55165C00021
#The sum of used slot20 SR pool resources. seconds
${MAX_USED_RES_SLOT40}    M55165C00022
#The maximum number of resources that are allocated to UEs in slot40 SR pool. UE number?
${SUM_USED_RES_SLOT40}    M55165C00023
#The sum of used slot20 SR pool resources. seconds
${MAX_USED_RES_SLOT80}    M55165C00024
#The maximum number of resources that are allocated to UEs in slot40 SR pool. UE number?
${SUM_USED_RES_SLOT80}    M55165C00025
#The sum of used slot80 SR pool resources. seconds
${MAX_VOICE_OUT_OF_PREF_SR_POOL}    M55165C00028
#The maximum number of resources used by UEs with VoNR in the pools with different SR periods than the preferred one (configured for voice).
${SUM_VOICE_OUT_OF_PREF_SR_POOL}    M55165C00029
#The sum of SR resources used by UEs with VoNR in the pools with different SR periods than the preferred one (configured for voice).
${SUM_SR_SLOT20_POOL_FREE_RES}    M55165C00032
#The number of free scheduling resources (still available for allocations) in slot20 SR pool.
${SUM_USED_RES_SS_SR_SLOT20}    M55165C00503
#This counter provides the sum of slot20 SR resources used by service-specific SR.
${SUM_USED_RES_SS_SR_SLOT80}    M55165C00505
#This counter provides the sum of slot80 SR resources used by service-specific SR.
${NUM_SS_SR_20SLOT_PERIOD_SUC}    M55165C00509
#This counter provides the number of service-specific SR periodicity requests for 20 Slots, which are successfully admitted
${NUM_SS_SR_40SLOT_PERIOD_SUC}    M55165C00510
#This counter provides the number of service-specific SR periodicity requests for 40 Slots, which are successfully admitted
${NUM_SS_SR_80SLOT_PERIOD_SUC}    M55165C00511
#This counter provides the number of service-specific SR periodicity requests for 80 Slots, which are successfully admitted
${NUM_SS_SR_20SLOT_PERIOD_REQ}    M55165C00515
#This counter provides the number of service-specific SR periodicity requests for 20 Slots.
${NUM_SS_SR_40SLOT_PERIOD_REQ}    M55165C00516
#This counter provides the number of service-specific SR periodicity requests for 40 Slots.
${NUM_SS_SR_80SLOT_PERIOD_REQ}    M55165C00517
#This counter provides the number of service-specific SR periodicity requests for 80 Slots.

*** Test Cases ***
CB009189-ET-A13_SA_FDD_9189DRBsl80_add_VONRsl20_9189DRBaddfail_intrafreq_intraDU_intragNB_HO_A5
    [Documentation]
    ...    1. This user scenario describes Intra-frequency Intra-DU Intra-gNB handover to target cell after
    ...    successfully configure periodicity and possibly grant size for Scheduling Request per DRB profile.
    ...    2. Configuration
    ...    5GC002271 feature is enabled,and CB009189 flag is enabled.
    ...    A5 is configured for NRCELL-11.
    ...    3. Test Case Steps:
    ...    a.UE register, and check SR period selection.
    ...    b.setup VONR and GBR bearer, check SR period selection.
    ...    c.send A5 measurement, then intrafreq intraDU HO to NRCELL-13 successfully,and check SR period selection.
    ...    d.online modify NRCELL-13:preferredVoNrSrPeriod from slots20 to slots40.
    ...    e.UE deregister.
    ...    f.UE register, and check SR period selection.
    ...    g.setup VONR , check SR period selection.
    ...    h.UE deregister.
    [Tags]    QC_221193    owner-kexin.bao
    OnlineParamChange    ${OnlineParam_for_A013}
    Clear Counter Files
    First Attach and HO
    Check Counters    ${PM_Counters_Check_A13_1}
    Clear Counter Files    ${False}
    Second Attach
    Check Wireshark Log    ${CURDIR}${/}a2a_CB009189A013${/}a2a.ini    wait_string=UEContextReleaseComplete::8
    Check Counters    ${PM_Counters_Check_A13_2}

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
    Update Cfg    set_qosflow id=10 5qi=71 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all

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

Verify Throuput
    [Arguments]    ${ue_id}    ${qfi}    ${Tput_dl}    ${Tput_ul}    ${sleep_time}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    [Arguments]    ${ue_id}=81    ${qfi}=1    ${send_dl}=70    ${send_ul}=10    ${sleep_time}=10s
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=${qfi} dir=dl mbps=${send_dl}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=${qfi} dir=ul mbps=${send_ul}
    Verify Throuput    ${ue_id}    ${qfi}    ${send_dl}*0.9    ${send_ul}*0.9    ${sleep_time}

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger A3
    [Arguments]    ${ue_id}    ${carrierfreq}    ${phycell_id}    ${pass_regexp}    ${regexp}
    sleep    2s    sleep for A3 MR
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=70
    ...    phycell_id=${phycell_id} nrsrp_nr=80
    ${retvalue}    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}
    Should Contain    ${retvalue}    ${regexp}
    Verify Throuput    ${ue_id}    qfi=1    Tput_dl=63    Tput_ul=9    sleep_time=10s

Setup VONR on NRCELL-11
    [Arguments]    ${ue_id}    ${regexp}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=5 by=amf
    ...    pass_regexp=Added QosFlow with QFI:2 5QI:5
    Send And Verify Throuput    ue_id=${ue_id}    qfi=2    send_dl=10    send_ul=3    sleep_time=10s
    Verify Throuput    ue_id=${ue_id}    qfi=1    Tput_dl=9    Tput_ul=2    sleep_time=2s
    ${retvalue}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=1 by=amf
    ...    pass_regexp=Added QosFlow with QFI:3 5QI:1
    should contain    ${retvalue}    ${regexp}
    Send And Verify Throuput    ue_id=${ue_id}    qfi=3    send_dl=10    send_ul=3    sleep_time=10s
    Verify Throuput    ue_id=${ue_id}    qfi=1    Tput_dl=9    Tput_ul=2    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=2    Tput_dl=9    Tput_ul=2    sleep_time=2s

Setup GBR Bearer Successfully on NRCELL-11
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=4 by=amf
    ...    pass_regexp=Added QosFlow with QFI:4 5QI:4
    Send And Verify Throuput    ue_id=${ue_id}    qfi=4    send_dl=10    send_ul=3    sleep_time=10s
    Verify Throuput    ue_id=${ue_id}    qfi=1    Tput_dl=9    Tput_ul=2    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=2    Tput_dl=9    Tput_ul=2    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=3    Tput_dl=9    Tput_ul=2    sleep_time=2s

Setup GBR Bearer Fail on NRCELL-11
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=10 by=amf
    ...    pass_regexp=Deleted Unsuccessful QosFlow QFI:5
    Verify Throuput    ue_id=${ue_id}    qfi=1    Tput_dl=9    Tput_ul=2    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=2    Tput_dl=9    Tput_ul=2    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=3    Tput_dl=9    Tput_ul=2    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=4    Tput_dl=9    Tput_ul=2    sleep_time=2s

Setup VONR And GBR Bearer on NRCELL-11
    [Arguments]    ${ue_id}    ${regexp}
    Send And Verify Throuput    ue_id=${ue_id}    qfi=1    send_dl=10    send_ul=3    sleep_time=10s
    Setup VONR on NRCELL-11    ue_id=${ue_id}    regexp=${regexp}
    Setup GBR Bearer Successfully on NRCELL-11    ue_id=${ue_id}
    Setup GBR Bearer Fail on NRCELL-11    ue_id=${ue_id}

Setup VONR on NRCELL-13
    [Arguments]    ${ue_id}    ${regexp}
    Send And Verify Throuput    ue_id=${ue_id}    qfi=1    send_dl=10    send_ul=3    sleep_time=10s
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=5 by=amf
    ...    pass_regexp=Added QosFlow with QFI:2 5QI:5
    Send And Verify Throuput    ue_id=${ue_id}    qfi=2    send_dl=10    send_ul=3    sleep_time=10s
    Verify Throuput    ue_id=${ue_id}    qfi=1    Tput_dl=9    Tput_ul=2    sleep_time=2s
    ${retvalue}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=1 by=amf
    ...    pass_regexp=Added QosFlow with QFI:3 5QI:1
    should contain    ${retvalue}    ${regexp}
    Send And Verify Throuput    ue_id=${ue_id}    qfi=3    send_dl=10    send_ul=3    sleep_time=10s
    Verify Throuput    ue_id=${ue_id}    qfi=1    Tput_dl=9    Tput_ul=2    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=2    Tput_dl=9    Tput_ul=2    sleep_time=2s

Trigger A5
    [Arguments]    ${ue_id}    ${carrierfreq}    ${phycell_id}    ${pass_regexp}    ${regexp}
    sleep    2s    sleep for A5 MR
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A5
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A5 srsrp_nr=8
    ...    phycell_id=${phycell_id} nrsrp_nr=80
    ${retvalue}    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}
    Should Contain    ${retvalue}    ${regexp}
    Verify Throuput    ue_id=${ue_id}    qfi=1    Tput_dl=9    Tput_ul=2    sleep_time=10s
    Verify Throuput    ue_id=${ue_id}    qfi=2    Tput_dl=9    Tput_ul=2    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=3    Tput_dl=9    Tput_ul=2    sleep_time=2s
    Verify Throuput    ue_id=${ue_id}    qfi=4    Tput_dl=9    Tput_ul=2    sleep_time=2s

First Attach and HO
    UE Attach To Target Cell    ue_id=81    cell_id=11    regexp=periodicityAndOffset sl80
    Setup VONR And GBR Bearer on NRCELL-11    ue_id=81    regexp=periodicityAndOffset sl20
    Trigger A5    ue_id=81    carrierfreq=424090    phycell_id=62
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.11 to EXT_ENB-2.13    regexp=periodicityAndOffset sl20
    OnlineParamChange    NRCELL-13:preferredVoNrSrPeriod=slots40
    UE Deregister From gNB    ue_id=81

Second Attach
    UE Attach To Target Cell    ue_id=81    cell_id=13    regexp=periodicityAndOffset sl80
    Setup VONR on NRCELL-13    ue_id=81    regexp=periodicityAndOffset sl40
    UE Deregister From gNB    ue_id=81
