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
...    @{GBR_5qi_4}
...    @{HO_flag}
...    @{NRCELL_11_configuration}
...    @{NRADJGNB}
...    @{NRADJNRCELL}
...    @{Xn_link}

@{2271_related_modification}
...    NRCELL:actAdaptiveSr=true
...    NRCELL:adaptiveSrBlockingMinimization=20
...    NRCELL:adaptiveSrLoadThresholdDown=50
...    NRCELL:adaptiveSrLoadThresholdUp=80
...    NRCELL-2:srPeriodicity=slots160
...    NRCELL-11:srPeriodicity=slots80
...    NRCELL-12:srPeriodicity=slots20
...    NRCELL:srPeriodicityMin=slots20
...    NRCELL-11:srPeriodicityMin=slots10
...    NRCELL-12:srPeriodicityMin=slots10
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:vonrReservation=30
...    NRCELL-11:vonrReservation=0
...    NRCELL-2:vonrReservation=50
...    NRCELL-2:preferredVoNrSrPeriod=slots80
...    NRCELL-1:preferredVoNrSrPeriod=slots40
...    NRCELL-11:preferredVoNrSrPeriod=slots20
...    NRCELL-12:preferredVoNrSrPeriod=slots20
...    NRCELL-13:preferredVoNrSrPeriod=slots20
...    NRCELL-14:preferredVoNrSrPeriod=slots20

@{9189_related_modification}
...    NRCELL:actServiceAwareConfig=true
#default 5qi=8
...    NRBTS/NRDRB-13:srPeriodicityDrb=40ms
...    NRBTS/NRDRB-13:payloadSizeSRDrb=750
#5qi=4
...    NRBTS/NRDRB-17:srPeriodicityDrb=80ms
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

@{HO_flag}
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:actInterFreqHoSA=true
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    NRBTS-1:actIntraNrNgHo=sourceAndTarget
...    NRBTS-1:tNgRelocExecDeltN=3000
...    NRBTS-1:tNgRelocOverallN=2000
...    NRBTS-1:tNgRelocPrepN=2000
...    NRBTS-1:tNgRelocCancelN=2000

@{NRCELL_11_configuration}
...    NRCELL-11:a1MeashoEnabledSA=rsrp
...    NRCELL-11:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=20
...    NRCELL-11:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=80
...    NRCELL-11:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-11:a2MeashoEnabledSA=rsrp
...    NRCELL-11:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=26
...    NRCELL-11:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=80
...    NRCELL-11:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL-11:absThreshSsbRsrpConsolidation=0
...    NRCELL-11:sMeasConfigSsbRsrp=0
...    NRCELL-11:a3MeasSsbRsrp:a3HysteresisSsbRsrp=8
...    NRCELL-11:a3MeasSsbRsrp:a3OffsetSsbRsrp=2
...    NRCELL-11:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms80
...    NRCELL-11/NRHOIF-1:cellDepType=SA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:ssbFrequency=513150
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=35
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:nrDcAllowed=false
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-11/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-11/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms80
...    NRCELL-11/NRHOIF-2:a5MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-2:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-11/NRHOIF-2:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-11/NRHOIF-2:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-11/NRHOIF-2:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms160
...    NRCELL-11/NRHOIF-2:cellDepType=SA
...    NRCELL-11/NRHOIF-2:freqBandIndicatorNR=71
...    NRCELL-11/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-2:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-2:ssbFrequency=127230
...    NRCELL-11/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=36
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:lcrId=1
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:handoverAllowedSA=XnHoNotAllowed
...    NRCELL-11/NRREL-2:nrDcAllowed=false
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3

@{NRADJGNB}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=35
...    NRBTS/NRADJGNB-1:gNodeBIdCtrl=oamControlled
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=36
...    NRBTS/NRADJGNB-2:gNodeBIdCtrl=oamControlled
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-2:xnLinkRef=2
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3

@{NRADJNRCELL}
...    NRBTS/NRADJNRCELL-1:cellDepType=SA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=41
...    NRBTS/NRADJNRCELL-1:gNbId=35
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=513234
...    NRBTS/NRADJNRCELL-1:physCellId=381
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:cellDepType=SA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=71
...    NRBTS/NRADJNRCELL-2:gNbId=36
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=1
...    NRBTS/NRADJNRCELL-2:nrarfcn=135000
...    NRBTS/NRADJNRCELL-2:physCellId=382
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3

@{Xn_link}
...    NRBTS:actIncXn=true
...    NRBTS/XNLINK-1:cPlaneIpAddr=10.0.1.122
...    NRBTS/XNLINK-1:cPlaneIpAddrCtrl=oamControlled
...    NRBTS/XNLINK-2:cPlaneIpAddr=10.0.1.124
...    NRBTS/XNLINK-2:cPlaneIpAddrCtrl=oamControlled

@{online_modification_A19}
...    NRCELL-11:actEnhancedVoNR=false
...    NRCELL-11:actVoNR=false

*** Test Cases ***
CB009189-ET-A18_SA_FDD_9189DRBsl40_add_VONRsl20_interfreq_intergNB_HO_A3_TDD
    [Documentation]
    ...    1. This user scenario describes Inter-frequency Inter-gNB handover to target cell after
    ...    successfully configure periodicity and possibly grant size for Scheduling Request per DRB profile.
    ...    2. Configuration
    ...    5GC002271 feature is enabled,and CB009189 flag is enabled.
    ...    A3 is configured for NRCELL-11, and NRHOIF and NRREL are configured for NRCELL-11.
    ...    NRADJGNB and NRADJNRCELL are configured.
    ...    3. Test Case Steps:
    ...    a.UE register on NRCELL-11, and check SR period selection.
    ...    b.setup VONR, check TPUT, and check SR period selection.
    ...    c.trigger A3 measurement to HO to simgNB , then HO back to NRCELL-1, check SR period selection.
    ...    d.UE deregister.
    [Tags]    QC_224563    owner-kexin.bao
    Trigger Xn Setup From Remote GNB    gnb_id=3    based=xn_based
    UE Attach To Target Cell    ue_id=81    cell_id=11    regexp=periodicityAndOffset sl40
    Setup DRBs and Verify Tput A18    ue_id=81
    Trigger Measurement to HO    ue_id=81    carrierfreq1=424090    carrierfreq2=513150    phycell_id=381    event=A3
    ...    pass_regexp=Inter-eNB handover from EXT_ENB-2.11 to ENB-3.1 performed     regexp=rrcReconfigurationComplete
    Trigger Measurement to HO    ue_id=81    carrierfreq1=513150    carrierfreq2=518910    phycell_id=51    event=A3
    ...    pass_regexp=Inter-eNB handover from ENB-3.1 to EXT_ENB-2.2 performed    regexp=periodicityAndOffset sl80
    Verify Tput on Every DRB
    UE Deregister From gNB    ue_id=81
    Check RRC log    ${CURDIR}${/}a2a_CB009189A018${/}a2a.ini

CB009189-ET-A19_SA_FDD_9189DRBsl40_9189DRBsl80_VONRaddfail_intergNB_NGHO_A5_FDD_w_indirect_DLdata_forwarding
    [Documentation]
    ...    1. This user scenario describes Inter-frequency Inter-gNB handover to target cell after
    ...    successfully configure periodicity and possibly grant size for Scheduling Request per DRB profile.
    ...    2. Configuration
    ...    5GC002271 feature is enabled,and CB009189 flag is enabled.
    ...    A3 is configured for NRCELL-11, and NRHOIF and NRREL are configured for NRCELL-11.
    ...    NRADJGNB and NRADJNRCELL are configured.
    ...    3. Test Case Steps:
    ...    a.UE register on NRCELL-11, and check SR period selection.
    ...    b.setup DRBs, check TPUT, and check SR period selection.
    ...    c.send A5 measurement, then XN HO successfully, then HO back to NRCELL-12 ,and check SR period selection.
    ...    d.UE deregister.
    [Tags]    QC_224562    owner-kexin.bao
    OnlineParamChange    ${online_modification_A19}
    Trigger Xn Setup From Remote GNB    gnb_id=4    based=ng_based
    Enable indirect data forwarding function
    UE Attach To Target Cell    ue_id=81    cell_id=11    regexp=periodicityAndOffset sl40
    Setup DRBs and Verify Tput A19    ue_id=81
    Trigger Measurement to HO    ue_id=81    carrierfreq1=424090    carrierfreq2=127230    phycell_id=382    event=A5
    ...    pass_regexp=Inter-eNB handover from EXT_ENB-2.11 to ENB-4.1 performed     regexp=rrcReconfigurationComplete
    Trigger Measurement to HO    ue_id=81    carrierfreq1=127230    carrierfreq2=127450    phycell_id=61    event=A5
    ...    pass_regexp=Inter-eNB handover from ENB-4.1 to EXT_ENB-2.12 performed    regexp=periodicityAndOffset sl20
    Verify Tput on Every DRB
    UE Deregister From gNB    ue_id=81
    Check RRC log    ${CURDIR}${/}a2a_CB009189A019${/}a2a.ini

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
    Update Cfg    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc indirect_data_forwarding=on

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

Trigger Xn Setup From Remote GNB
    [Arguments]    ${gnb_id}    ${based}
    Execute Egate Command    gnb_param id=${gnb_id} send_xn_setup=true
    Execute Egate Command    gnb_xn_link_up gnb=${gnb_id} target=2    GNB-${gnb_id}: XnAP Link with GNB-2
    Execute Egate Command    gnb_param id=${gnb_id} sa_ho=${based}

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

Trigger Measurement to HO
    [Arguments]    ${ue_id}    ${carrierfreq1}    ${carrierfreq2}    ${phycell_id}    ${event}    ${pass_regexp}    ${regexp}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq1}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=eventId event${event}
    sleep    2s    sleep for A3 MR
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq2}    event_type=${event}
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event} srsrp_nr=10
    ...    phycell_id=${phycell_id} nrsrp_nr=80
    ${retvalue}    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}
    Should Contain    ${retvalue}    ${regexp}

Enable indirect data forwarding function
    execute egate command    amf_timer T_Local=4000
    execute egate command    amf_timer T_NotifyProcessing=2500
    execute egate command    upf_param id=1 end_markers_delay=1000
    execute egate command    set_pdu_param ue=6 pdu=1 trf_type=internal

Setup DRBs and Verify Tput A18
    [Arguments]    ${ue_id}
    Send And Verify Throuput    ue_id=${ue_id}    qfi=1    send_dl=10    send_ul=5    sleep_time=10s
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=5 by=amf
    ...    pass_regexp=Added QosFlow with QFI:2 5QI:5
    Send And Verify Throuput    ue_id=${ue_id}    qfi=2    send_dl=10    send_ul=5    sleep_time=10s
#    Verify Throuput    ue_id=${ue_id}    qfi=1    Tput_dl=9    Tput_ul=4    sleep_time=2s
    ${retvalue}    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=1 by=amf
    ...    pass_regexp=Added QosFlow with QFI:3 5QI:1
    Should Contain    ${retvalue}    periodicityAndOffset sl20
    Send And Verify Throuput    ue_id=${ue_id}    qfi=3    send_dl=10    send_ul=5    sleep_time=10s
#    Verify Throuput    ue_id=${ue_id}    qfi=1    Tput_dl=9    Tput_ul=4    sleep_time=2s
#    Verify Throuput    ue_id=${ue_id}    qfi=2    Tput_dl=9    Tput_ul=4    sleep_time=2s

Setup DRBs and Verify Tput A19
    [Arguments]    ${ue_id}
    Send And Verify Throuput    ue_id=${ue_id}    qfi=1    send_dl=10    send_ul=5    sleep_time=10s
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=10 by=amf
    ...    pass_regexp=Added QosFlow with QFI:2 5QI:71
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=5 by=amf
    ...    pass_regexp=Added QosFlow with QFI:3 5QI:5
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=1 by=amf
    ...    pass_regexp=Deleted Unsuccessful QosFlow QFI:4
    Send And Verify Throuput    ue_id=${ue_id}    qfi=2    send_dl=10    send_ul=5    sleep_time=10s
    Send And Verify Throuput    ue_id=${ue_id}    qfi=3    send_dl=10    send_ul=5    sleep_time=10s

Verify Tput on Every DRB
    Verify Throuput    ue_id=81    qfi=1    Tput_dl=9    Tput_ul=4    sleep_time=10s
    Verify Throuput    ue_id=81    qfi=2    Tput_dl=9    Tput_ul=4    sleep_time=2s
    Verify Throuput    ue_id=81    qfi=3    Tput_dl=9    Tput_ul=4    sleep_time=2s
