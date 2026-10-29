*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD   CRT    STATE_CONFIGURED
...    owner-ying.5.chen   owner-yin.zhang    team-SG2    release-5G20B    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
Resource  ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_5QI9}
...    @{PARAMS_FOR_5QI5}
...    @{PARAMS_FOR_5QI1}
...    @{PARAMS_FOR_SECURITY}
...    @{PARAMS_FOR_OTHERS}
...    @{PARAMS_FOR_DRX}
...    @{PARAMS_FOR_A1A2}
...    @{PARAMS_FOR_INTER_FREQ_A3A5}
@{PARAMS_FOR_5QI9}
...    NRBTS/NRDRB_5QI-5:fiveqiValueList=9
...    NRBTS/NRDRB_5QI-5:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-14
...    NRBTS/NRDRB-14:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS/NRDRB-14:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-14:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-14:resType=nonGBR
...    NRBTS/NRDRB-14:rlcMode=RLC_AM
...    NRBTS/NRDRB_MAC-2:lcgid=1
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
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=1
...    NRBTS/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB_MAC-4:lcgid=4
...    NRBTS/NRDRB_MAC-4:schedulPrio=5
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS/NRDRB_PDCP-3:tReorderingUl=ms300
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false
@{PARAMS_FOR_SECURITY}
...    NRBTS:cipherPrefL:nea0=0
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=1
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:integrityProtPrefL:nia0=0
...    NRBTS:integrityProtPrefL:nia1_128=0
...    NRBTS:integrityProtPrefL:nia2_128=9
...    NRBTS:integrityProtPrefL:nia3_128=0
@{PARAMS_FOR_OTHERS}


...    NRBTS:drbInactivityTimerSA=60
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots320
@{PARAMS_FOR_DRX}
...    NRCELL-1:actCDrx=true
...    NRCELL-1:drxWactDlEnabled=true
...    NRCELL-1:drxWactUlEnabled=true
...    NRCELL-1:drxProfile1:drxInactivityTimer=20ms
...    NRCELL-1:drxProfile1:drxLongCycle=40ms
...    NRCELL-1:drxProfile1:drxOnDurationTimer=10ms
...    NRCELL-1:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-1:drxProfile1:drxRetransTimerUl=16slot
@{PARAMS_FOR_A1A2}
...    NRCELL-1:a1MeashoEnabled=rsrpAndRsrq
...    NRCELL-1:a1MeashoEnabledSA=rsrpAndRsrq
...    NRCELL-1:a2MeashoEnabled=rsrq
...    NRCELL-1:a2MeashoEnabledSA=rsrq
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=34
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL-1:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=0
...    NRCELL-1:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=38
...    NRCELL-1:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms480
...    NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=0
...    NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=31
...    NRCELL-1:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms480
@{PARAMS_FOR_INTER_FREQ_A3A5}
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actInterFreqInterGnbMobilityNSA=true
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrq
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrq
...    NRCELL-1/NRHOIF-1:cellDepType=SA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf3
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=40
...    NRCELL-1/NRHOIF-1:ssbFrequency=630624
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=15
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=30
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms320
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=3
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=50
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=80
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms2560
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5HysteresisSsbRsrq=5
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold1SsbRsrq=40
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold2SsbRsrq=75
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms5120
# fix relation error
...    NRBTS/NRPMRNL-1:miNrRelReportCu=5min

${UECapabilities}    SEPARATOR=
...    E9A01000064E5A031E000380A03C1260C8000878180C4034026010180E01951B0A3582028680965944C043D6C10101070EF1C390
...    61C00103278FAB800FF800E003FE00151B133582028680965944C043D6C10101070EF1C39061C00103278FAB800FF800E003FE00
...    151B137582028680965944C043D6C10101070EF1C39061C00103278FAB800FF800E003FE00151B13B582028680965944C043D6C1
...    0101070EF1C39061C00103278FAA8000028000000841C4D00000000202682807008089EC1601800140E0601C0C01601C001A0423
...    E0000000000000E54D000100000965950034AAA8081C002C00000010020046AC4C0004080C1014181C202C4044484C648494989C
...    A12984D0

*** Test Cases ***
5GC000786-ET-A020_Verify_measurement_gap_DRX_interworking_with_VoNR_call_TDD_SA_Airphone
    [Tags]    QC_61499    owner-jun.15.zhang    A020
    Trigger UE1 5QI9 Setup And Check DRX Setup And A2 Configured
    Trigger UE1 5QI5 Setup Successfully
    UE1 Report A2 And Check DRX released And MeasGap Setup
    Trigger UE1 5QI1 Setup Successfully
    UE1 Report A1 And Check MeasGap Released And A2 Configured
    Trigger UE1 5QI1 Release And Check DRX Setup
    UE1 Report A2 And Check DRX released And MeasGap Setup
    Trigger UE1 5QI5 Release Successfully
    Release UEs    ue_type=all

5GC000786-ET-A022_Verify_DRX_interworking_with_VoNR_call_TDD_SA_Airphone
    [Tags]    QC_61500    owner-jun.15.zhang    A022
    Trigger UE2 5QI9 Setup And Check DRX Setup
    Trigger UE2 5QI5 Setup Successfully
    Trigger UE2 5QI1 Setup And Check DRX Released
    Trigger UE2 5QI1 Release And Check DRX Setup
    Trigger UE2 5QI5 Release Successfully
    Release UEs    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
  Common Suite Setup
  Setup Airphone Env  tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes ims_voice_3gpp=on
    #UE configuration
    ${set_ue1}    catenate
    ...    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1
    ${ue1_cap}    catenate    SEPARATOR=
    ...    29A010000109801D06C4DAA5608C2000001803D5555554F5555555028038004003000000000713400000000989A007EFFFFF0140180E
    ...    060180B0140180421E000000000000045400000000000005400000400801022280
    Update Cfg    ${set_ue1}
    Update Cfg    ue_param id=1 ue_nr_capabilities=${ue1_cap} nr_usage_setting=voice_centric
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    ${set_ue2}    catenate
    ...    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645401 mode=nr enb=2 cell=1
    ${ue2_param}    catenate
    ...    ue_param id=2
    ...    ue_nr_capabilities=${UECapabilities}
    ...    nr_usage_setting=voice_centric
    Update Cfg    ${set_ue2}
    Update Cfg    ${ue2_param}
    Update Cfg    ue_nr_capabilities id=2 voice_over_nr=on:on:off
    #5QI configuration
    Update Cfg    set_qosflow id=1 5qi=5 default=off
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=3 5qi=9 default=on
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=1,2,3 qos_rules=1,2 default=on ue=1-6 amf=1-6

Trigger UE${id} 5QI9 Setup And Check DRX Setup And A2 Configured
    execute egate command    ue_register id=${id}    UE now in NG RM Registered
    ${out}    execute egate command    ue_pdu_session_setup ue=${id} pdu=1 gw=${id} nwslice=1    drx-Config setup
    should contain    ${out}    eventId eventA2
    should contain    ${out}    Setup QosFlow with QFI:1 5QI:9

Trigger UE${id} 5QI9 Setup And Check DRX Setup
    execute egate command    ue_register id=${id}    UE now in NG RM Registered
    ${out}    execute egate command    ue_pdu_session_setup ue=${id} pdu=1 gw=${id} nwslice=1    drx-Config setup
    should contain    ${out}    Setup QosFlow with QFI:1 5QI:9

Trigger UE${id} 5QI5 Setup Successfully
    ${out}    execute egate command    ue_pdu_session_modify ue=${id} pdu=1 qosflows_to_add=1 by=amf    QoS Routing Table
    should contain    ${out}    rrcReconfiguration
    should contain    ${out}    Added QosFlow with QFI:2 5QI:5

Trigger UE${id} 5QI1 Setup Successfully
    ${out}    execute egate command    ue_pdu_session_modify ue=${id} pdu=1 qosflows_to_add=2 by=amf    QoS Routing Table
    should contain    ${out}    rrcReconfiguration
    should contain    ${out}    Added QosFlow with QFI:3 5QI:1

Trigger UE${id} 5QI1 Setup And Check DRX Released
    ${out}    execute egate command    ue_pdu_session_modify ue=${id} pdu=1 qosflows_to_add=2 by=amf    QoS Routing Table
    should contain    ${out}    rrcReconfiguration
    should contain    ${out}    Added QosFlow with QFI:3 5QI:1
    should contain    ${out}    drx-Config release : NULL

Trigger UE${id} 5QI1 Release And Check DRX Setup
    ${out}    execute egate command    ue_pdu_session_modify ue=${id} pdu=1 qosflows_to_del=2 by=amf
    ...    Pdu Session Resource Modify Response Message
    should contain    ${out}    Deleting QosFlow with QFI:3 5QI:1
    should contain    ${out}    drx-Config setup

Trigger UE${id} 5QI5 Release Successfully
     ${out}    execute egate command    ue_pdu_session_modify ue=${id} pdu=1 qosflows_to_del=1 by=amf
     ...    Pdu Session Resource Modify Response Message
     should contain    ${out}    Deleting QosFlow with QFI:2 5QI:5
     should contain    ${out}    rrcReconfiguration

UE${id} Report A2 And Check DRX released And MeasGap Setup
   ${a2_measid}    get nr meas id for specific type and frequency    ${id}    carrierfreq=636576    event_type=A2
   ${a2_report_cmd}    catenate
   ...    ue_measurement_send_nr id=1 meas_id=${a2_measid} event=A2 srsrp_nr=7 srsrq_nr=7 srs_result=0:7:7:0
   ...    phycell_id=50 nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:0
   ${out}    execute egate command    ${a2_report_cmd}    rrcReconfigurationComplete
   should contain    ${out}    gapUE setup
   should contain    ${out}    drx-Config release : NULL

UE${id} Report A1 And Check MeasGap Released And A2 Configured
    ${a1_measid}    get nr meas id for specific type and frequency    ${id}    carrierfreq=636576    event_type=A1
    ${out}    execute egate command
    ...    ue_measurement_send_nr id=1 meas_id=2 event=A1 srsrp_nr=80 srsrq_nr=80 srs_result=0:30:30:0 phycell_id=50
    ...    rrcReconfigurationComplete
    should contain    ${out}    eventId eventA2
    should contain    ${out}    gapUE release : NULL


