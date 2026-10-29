*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT
...    owner-ying.5.chen    team-SG2    release-5G20B    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${UE1_Capabilities}    SEPARATOR=
...    E1A01000074E5A031E000380A03C1260C8000878180C4034026010180E01951B0A3582028680965944C043D6C10101070EF1C39061C0010327
...    8FAB80027800E0009E00151B133582028680965944C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B1375820286809659
...    44C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13B582028680965944C043D6C10101070EF1C39061C00103278FAA80
...    00028000000841C4D00000000202682807008089FEAAAAA058060005038180703005807000683E0000000000000E54D000100000965950034A
...    AA8081C002C00000010020046AC4C0004080C1014181C202C4044484C648494989CA12986B40

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_5QI9}
...    @{PARAMS_FOR_5QI5}
...    @{PARAMS_FOR_5QI1}
...    @{PARAMS_FOR_5QI2}
...    @{PARAMS_FOR_SECURITY}
...    @{PARAMS_FOR_OTHERS}
...    @{PARAMS_FOR_A3}
...    @{PARAMS_FOR_A1}
...    @{PARAMS_FOR_A2}
...    @{PAPAMS_FOR_XN}
...    @{PARAMS_FOR_DRX}
...    @{PARAMS_FOR_neighbourhood}

@{PARAMS_FOR_5QI9}
...    NRBTS/NRDRB_5QI-5:fiveqiValueList=9
...    NRBTS/NRDRB_5QI-5:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-14
...    NRBTS/NRDRB-14:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS/NRDRB-14:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-14:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-14:resType=nonGBR
...    NRBTS/NRDRB-14:rlcMode=RLC_AM
...    NRBTS/NRDRB_MAC-2:lcgid=2
...    NRBTS/NRDRB_MAC-2:schedulPrio=5
...    NRBTS/NRDRB_PDCP-2:cuFlowControlProfId=1
...    NRBTS/NRDRB_RLC_AM-2:duFlowControlProfId=1

@{PARAMS_FOR_5QI5}
...    NRBTS/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS/NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
...    NRBTS/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS/NRDRB-10:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-10:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-10:resType=nonGBR_Signaling
...    NRBTS/NRDRB-10:rlcMode=RLC_AM
...    NRBTS/NRDRB_MAC-3:lcgid=0
...    NRBTS/NRDRB_MAC-3:schedulPrio=4

@{PARAMS_FOR_5QI1}
...    NRCELL-1:actVoNR=true
...    NRCELL-2:actVoNR=true
...    NRBTS:actNormVCFallback=false
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:dscp=46
...    NRBTS/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-15:numSduDiscard=1
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=1
...    NRBTS/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB_MAC-4:lcgid=4
...    NRBTS/NRDRB_MAC-4:schedulPrio=4
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS/NRDRB_PDCP-3:tReorderingUl=ms300
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false

@{PARAMS_FOR_5QI2}
...    NRBTS/NRDRB-16:dlFlowControlAlgo=3gppFlowControl
...    NRBTS/NRDRB-16:dscp=46
...    NRBTS/NRDRB-16:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-16:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS/NRDRB-16:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-16:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-16:numSduDiscard=1
...    NRBTS/NRDRB-16:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-16:queuingDelaySduDiscardThreshold=200
...    NRBTS/NRDRB-16:resType=nonGBR
...    NRBTS/NRDRB-16:rlcMode=RLC_UM
...    MNRBTS/NRDRB-16:schedulWeight=24
...    NRBTS/NRDRB-16:sduDiscardIntervalTmr=100
...    NRBTS/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    NRBTS/NRDRB_5QI-7:fiveqiValueList=128
...    NRBTS/NRDRB_MAC-4:lcgid=4
...    NRBTS/NRDRB_MAC-4:schedulPrio=4

@{PARAMS_FOR_SECURITY}
...    NRBTS:cipherPrefL:nea0=1
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=9
...    NRBTS:integrityProtPrefL:nia0=0
...    NRBTS:integrityProtPrefL:nia1_128=0
...    NRBTS:integrityProtPrefL:nia2_128=0
...    NRBTS:integrityProtPrefL:nia3_128=9

@{PARAMS_FOR_OTHERS}


...    NRBTS:drbInactivityTimerSA=60
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    MRBTS-1/NRBTS-1:actInterFreqHoSA=true

@{PARAMS_FOR_A3}
...     NRBTS/NRCELL-1:a3MeasEnabled=rsrp
...    NRBTS/NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRBTS/NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRBTS/NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRBTS/NRCELL-2:a3MeasEnabled=rsrp
...    NRBTS/NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRBTS/NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=15

@{PARAMS_FOR_neighbourhood}
...    NRBTS/NRCELL-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gNbId=35
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ssBurstSetPeriod=40
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ssbFrequency=630624
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160

@{PARAMS_FOR_DRX}
...    MRBTS-1/NRBTS-1/NRCELL-1:actCDrx=true
...    MRBTS-1/NRBTS-1/NRCELL-1:drxWactDlEnabled=true
...    MRBTS-1/NRBTS-1/NRCELL-1:drxWactUlEnabled=true
...    MRBTS-1/NRBTS-1/NRCELL-1:drxProfile1:drxInactivityTimer=40ms
...    MRBTS-1/NRBTS-1/NRCELL-1:drxProfile1:drxLongCycle=40ms
...    MRBTS-1/NRBTS-1/NRCELL-1:drxProfile1:drxOnDurationTimer=10ms
...    MRBTS-1/NRBTS-1/NRCELL-1:drxProfile1:drxRetransTimerDl=16slot
...    MRBTS-1/NRBTS-1/NRCELL-1:drxProfile1:drxRetransTimerUl=16slot

@{PARAMS_FOR_A1}
...    NRBTS/NRCELL-1:a1MeashoEnabled=rsrp
...    NRBTS/NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRBTS/NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRBTS/NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=34
...    NRBTS/NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRBTS/NRCELL-2:a1MeashoEnabled=rsrp
...    NRBTS/NRCELL-2:a1MeashoEnabledSA=rsrp
...    NRBTS/NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRBTS/NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=34
...    NRBTS/NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480

@{PARAMS_FOR_A2}
...    NRBTS/NRCELL-1:a2MeashoEnabled=rsrpAndRsrq
...    NRBTS/NRCELL-1:a2MeashoEnabledSA=rsrpAndRsrq
...    NRBTS/NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=2
...    NRBTS/NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRBTS/NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRBTS/NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=0
...    NRBTS/NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=31
...    NRBTS/NRCELL-1:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms480
...    NRBTS/NRCELL-2:a2MeashoEnabledSA=rsrpAndRsrq
...    NRBTS/NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=2
...    NRBTS/NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRBTS/NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRBTS/NRCELL-2:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=0
...    NRBTS/NRCELL-2:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=31
...    NRBTS/NRCELL-2:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms480

@{PAPAMS_FOR_XN}
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actIncXn=true
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbId=35
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrarfcn=633408
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:cellDepType=SA+NSA
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:physCellId=381
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbIdLength=22
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:ssbFrequency=630624

${ATT_IF_INTER_GNB_HO_SLICE}     M55149C00570    #The number of Inter-Frequency Inter-gNB HOs attempted
${SUCC_OG_IF_INTER_GNB_HO_SLICE}    M55149C00571    #The number of Inter-Frequency Inter-gNB Outgoing HO successful
${TOT_INTER_FREQ_HO_DECISION_A3}    M55147C00024

@{counters_dict_D015}
...    NRBTS-1:NSL:${ATT_IF_INTER_GNB_HO_SLICE}==1    #M55149C00570==1
...    NRBTS-1:NSL:${SUCC_OG_IF_INTER_GNB_HO_SLICE}==1     #M55149C00571=1
...    NRCELL-1:NMOCU:${TOT_INTER_FREQ_HO_DECISION_A3}==1    #M55147C00024
...    NRCELL-2:NMOCU:${TOT_INTER_FREQ_HO_DECISION_A3}==0

*** Test Cases ***
5GC000786-ET-D015_Verify VoNR_5QI5_5QI1_5QI2 Inter-frequency Inter-gNB handover success with muti target cells and per-UE measurement gaps
    [Documentation]
    ...    1. The purpose of this test case is to setup vonr call and check inter-frequency Inter-GNB handover successful
    ...    2. Test Case Steps:
    ...         cell1 frequency: 636666, cell2 frequency:636666, sim cell frequency: 633508
    ...         a. setup XN link
    ...         b. setup Video call successful
    ...         c. tirgger Inter-Freq Inter-GNB HO, from cell1 ho to sim cell1 and from sim cell1 HO to cell1
    ...         d. check conuter
    [Tags]   QC_61507
    Clear Counter files
    Setup Xn Link To gNB
    Prepare UE History Information
    Trigger UE1 MO VoNR Call With PDU
    Trigger UE1 5QI1 and 5QI2 Setup Successfully
    VoNR call tirgger Inter-Freq Inter-GNB HO by A3
    Trigger UE1 5QI1 And 5QI2 Release Successfully
    Check Counters    ${counters_dict_D015}
    Release UEs    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Setup Xn Link To gNB
    [Arguments]    ${gnb}=3
    BuiltIn.Log    Setup Xn Link Between gNB${gnb} and gNB2...    console=${True}
    execute egate command    gnb_param id=${gnb} xn_listening_socket=1 send_xn_setup=true
    execute egate command    gnb_xn_link_up gnb=${gnb} target=2    GNB-3: XnAP Link with GNB-2

Modify Cfg
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc ims_voice_3gpp=on
    ${set_ue1}    catenate
    ...    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1
    ${ue1_param}    catenate
    ...    ue_param id=1
    ...    ue_nr_capabilities=${UE1_Capabilities}
    ...    nr_usage_setting=voice_centric
    Update Cfg    ${set_ue1}
    Update Cfg    ${ue1_param}
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    ${set_ue2}    catenate
    ...    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645401 mode=nr enb=2 cell=1
    ${ue2_param}    catenate
    ...    ue_param id=2
    ...    ue_nr_capabilities=${UE1_Capabilities}
    ...    nr_usage_setting=voice_centric
    Update Cfg    ${set_ue2}
    Update Cfg    ${ue2_param}
    ${set_ue3}    catenate
    ...    set_ue simulated id=3 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645402 mode=nr enb=2 cell=2
    ${ue3_param}    catenate
    ...    ue_param id=3
    ...    ue_nr_capabilities=${UE1_Capabilities}
    ...    nr_usage_setting=voice_centric
    Update Cfg    ${set_ue3}
    Update Cfg    ${ue3_param}
    ${set_ue4}    catenate
    ...    set_ue simulated id=4 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645403 mode=nr enb=2 cell=2
    ${ue4_param}    catenate
    ...    ue_param id=4
    ...    ue_nr_capabilities=${UE1_Capabilities}
    ...    nr_usage_setting=voice_centric
    Update Cfg    ${set_ue4}
    Update Cfg    ${ue4_param}
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-6 amf=1-6 qos_flows=1,2,3,4 qos_rules=1,2,3
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=2 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=3 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=4 voice_over_nr=on:on:off
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=3 5qi=2
    Update Cfg    set_qosflow id=4 5qi=9
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=3
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-6 amf=1-6 qos_flows=1,2,3,4 qos_rules=1,2,3
    ${gnb3_info}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none xn=10.0.1.124
    ...    nssai=0x1:0xd143a5 amf=1

    ${GNBCELL1_info}    catenate
    ...    set_cell id=1 gnb=3 pci=127:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=633408:633408 gscn=7818
    ...    mandatory_for_activation=off
    Update Cfg    gnb_param id=3 xn_listening_socket=true
    Update Cfg    ${gnb3_info}
    Update Cfg    ${GNBCELL1_info}

Trigger UE1 MO VoNR Call With PDU
    [Arguments]    ${id}=1
    execute egate command    ue_register id=${id}    UE now in NG RM Registered
    ${out}    execute egate command    ue_pdu_session_setup ue=${id} pdu=1 gw=${id} nwslice=1    QoS Routing Table
    should contain    ${out}    Setup QosFlow with QFI:1 5QI:5

Trigger UE1 5QI1 and 5QI2 Setup Successfully
    [Arguments]    ${id}=1
    ${out}    execute egate command    ue_pdu_session_modify ue=${id} pdu=1 qosflows_to_add=2 by=amf    QoS Routing Table
    should contain    ${out}    rrcReconfiguration
    should contain    ${out}    Added QosFlow with QFI:2 5QI:1
    ${out}    execute egate command    ue_pdu_session_modify ue=${id} pdu=1 qosflows_to_add=3 by=amf    QoS Routing Table
    should contain    ${out}    rrcReconfiguration
    should contain    ${out}     Added QosFlow with QFI:3 5QI:2

Trigger UE1 5QI1 And 5QI2 Release Successfully
    [Arguments]    ${id}=1
    BuiltIn.Log    Trigger UE1 5QI1 And 5QI2 Release Successfully...    console=${True}
    ${cmd}    Catenate    ue_pdu_session_modify ue=${id} pdu=1 qosflows_to_del=2,3 by=amf
    ${ret1}=    execute_egate_command    ${cmd}    Pdu Session Resource Modify Response Message    timeout=20s
    Should Contain    ${ret1}    Deleting QosFlow with QFI:3 5QI:2
    Should Contain    ${ret1}    Deleting QosFlow with QFI:2 5QI:1
    Should Contain    ${ret1}    drx-Config setup

VoNR call tirgger Inter-Freq Inter-GNB HO by A3
    UE1 Tirgger Inter-Freq Inter-GNB HO back and forth

UE1 Tirgger Inter-Freq Inter-GNB HO back and forth
    [Arguments]    ${ue}=1
    BuiltIn.Log    UE${ue} Tirgger Intra-Frequency Intra-DU HO To Cell...    console=${True}
    Sleep    2s    #Wait pre-RrcReconfigurationComplete sent out
    Trigger first UE1 A2 Measurement Report
    ${measid_1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=630624    event_type=A3
    ${inter_freq_inter_gNB_1}    catenate
    ...    ue_measurement_send_nr id=${ue} meas_id=${measid_1} event=A3 srsrp_nr=25 srsrq_nr=10 phycell_id=381
    ...    nrsrp_nr=85 nrsrq_nr=50 phycell_id=382 nrsrp_nr=75 nrsrq_nr=40
    execute egate command    ${inter_freq_inter_gNB_1}    pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed

    Trigger second UE1 A2 Measurement Report
    ${measid_2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=636576    event_type=A3
    ${inter_freq_inter_gNB_2}    catenate
    ...    ue_measurement_send_nr id=${ue} meas_id=${measid_2} event=A3 srsrp_nr=15 srsrq_nr=10 phycell_id=50 nrsrp_nr=85 nrsrq_nr=50
    execute egate command    ${inter_freq_inter_gNB_2}    pass_regexp=Inter-eNB handover

Prepare UE History Information
    [Arguments]    ${ue}=1
    BuiltIn.Log    Add UE History Information List With Sim Gnb Cell...    console=${True}
    execute egate command    ue_history_information_list id=1 action=reset
    execute egate command
    ...    ue_history_information_list_add_ngran id=${ue} cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    execute egate command
    ...    ue_history_information_list_add_ngran id=${ue} cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    execute egate command
    ...    ue_history_information_list_add_ngran id=${ue} cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=99
    execute egate command    ue_history_information_list id=${ue} action=commit
    execute egate command    ue_enb_param id=${ue} ue_history_list=1

Trigger first UE1 A2 Measurement Report
    [Arguments]    ${ue}=1
    BuiltIn.Log    Trigger UE${ue} A2 Measurement Report
    Sleep    2s    #Wait pre-RrcReconfigurationComplete sent out
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=636576    event_type=A2
    ${A2_Event}    catenate    ue_measurement_send_nr id=${ue} meas_id=${measid} event=A2 srsrp_nr=7 srsrq_nr=7 srs_result=0:7:7:0
    ...    phycell_id=50 nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:0
    ${ret1}=    execute_egate_command    ${A2_Event}    rrcReconfiguration    timeout=20s
    Should Contain    ${ret1}    gapUE setup

Trigger second UE1 A2 Measurement Report
    [Arguments]    ${ue}=1
    BuiltIn.Log    Trigger UE${ue} A2 Measurement Report
    Sleep    2s    #Wait pre-RrcReconfigurationComplete sent out
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=630624    event_type=A2
    ${A2_Event}    catenate    ue_measurement_send_nr id=${ue} meas_id=${measid} event=A2 srsrp_nr=7 srsrq_nr=7 srs_result=0:7:7:0
    ...    phycell_id=50 nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:0
    ${ret1}=    execute_egate_command    ${A2_Event}    rrcReconfiguration    timeout=20s
    Should Contain    ${ret1}    gapUE setup


