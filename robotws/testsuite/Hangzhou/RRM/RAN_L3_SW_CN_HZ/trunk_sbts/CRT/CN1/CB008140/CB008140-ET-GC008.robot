*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOO]    team-Rock
...    owner-jing.ye    release-SBTS23R3    CRT
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_BOTH}
...    @{DRB}
...    @{Redirect_Config}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_BOTH}

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=1
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsUl=2
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRDU-1:actConnectedModeMobilityCA=true

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:gNbId=2
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-14:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-14:fiveGsTac=200
...    NRBTS/NRADJNRCELL-14:gNbId=2
...    NRBTS/NRADJNRCELL-14:gNbIdLength=22
...    NRBTS/NRADJNRCELL-14:lcrId=14
...    NRBTS/NRADJNRCELL-14:nrarfcn=153400
...    NRBTS/NRADJNRCELL-14:freqBandIndicatorNR=28
...    NRBTS/NRADJNRCELL-14:physCellId=63
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=2
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-14:gNbId=2
...    NRCELL-11/NRREL-14:gNbIdLength=22
...    NRCELL-11/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-14:lcrId=14
...    NRCELL-11/NRREL-14:removeNotAllowed=false
...    NRCELL-11/NRREL-14:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-14:sCellOperationalMode=dlOnly
...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms

@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS:actInterFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=1
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:gNbId=1
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=368400
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:ssbFrequency=368430
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS/NRADJNRCELL-12:gNbId=1
...    NRBTS/NRADJNRCELL-12:gNbIdLength=22
...    NRBTS/NRADJNRCELL-12:lcrId=12
...    NRBTS/NRADJNRCELL-12:nrarfcn=374000
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:ssbFrequency=373970
...    NRBTS/NRADJNRCELL-12:freqBandIndicatorNR=3
...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-14:a2MeasSCellRelEnabled=rsrp
...    NRCELL-14:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-14:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=0ms

@{PARAMS_FOR_BOTH}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1

@{DRB}
...    NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS-1/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS-1/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS-1/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS-1/NRDRB-15:dscp=46
...    NRBTS-1/NRDRB-15:nrDrbId=15
...    NRBTS-1/NRDRB-15:actDddsReduction=false
...    NRBTS-1/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS-1/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS-1/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-15:numSduDiscard=1
...    NRBTS-1/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS-1/NRDRB-15:queuingDelaySduDiscardThreshold=750
...    NRBTS-1/NRDRB-15:resType=GBR
...    NRBTS-1/NRDRB-15:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-15:cellAggrLevel=Not FR1 CA eligible
...    NRBTS-1/NRDRB-15:sduDiscardIntervalTmr=500
...    NRBTS-1/NRDRB-15:discardTimer=10ms
...    NRBTS-1/NRDRB-15:l2OHFactorDl=16
...    NRBTS-1/NRDRB-15:l2OHFactorUl=35
...    NRBTS-1/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS-1/NRDRB-15:schedulWeight=1
...    NRBTS-1/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS-1/NRDRB-15:actLostPduFastRetx=false
...    NRBTS-1/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS-1/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS-1/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:nrDrbRlcUmId=1
...    NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS-1/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS-1/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRBTS-1/NRDRB_PDCP-2:maxCidAllowed=4
...    NRBTS-1/NRDRB_MAC-4:lcgid=4
...    NRBTS-1/NRDRB_MAC-4:delayTarget=50
...    NRBTS-1/NRDRB_MAC-4:schedulPrio=5
...    NRBTS-1/NRDRB_MAC-4:prioritisedBitRate=16kBps
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=disabled

@{Redirect_Config}
...    NRBTS:actNormVCFallback=true
...    NRBTS:actRedirect=true
...    NRBTS:act3gppBL22R2=true
...    NRCELL-11:voiceFBMode=redirection
...    NRCELL-11/NRREDRT-0:redirPrio=1
...    NRCELL-11/NRREDRT-0:redirRat=eutra
...    NRCELL-11/NRREDRT-0:redirFreqEutra=39750
...    delete:NRCELL-11/NRREDRT-0:redirSsbScs
...    delete:NRCELL-11/NRREDRT-0:redirFreqNr

@{CELL1_CELL14_Added_As_Scell_Based_On_A1}
...    SCellIndex 1 activated successfully
...    SCellIndex 2 activated successfully
...    pcid:60, scellIdx:0
...    pcid:50, scellIdx:1
...    pcid:63, scellIdx:2

${SA_Capa_UE1_voiceFallbackIndicationEPS-r16}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623809DC6C06C0D608C21A08107482406D6C98AB1A1CF88E3D033EC09F1891C
...    790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D805AC1184341020F10480CAD931562439F604F88E3C62471E439F51CF9863CA1607038784FEC00
...    0003FB000000260001C0AA36266B04610D04083A412030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF0004C000381506C1BD608C2
...    1A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000130000E0551B13758230868000010090185B24CA88873E238F2
...    0C7A067D813E01CF9863CA1607038782F55555553D5555554260001C012587898001C4C000000160562E2600071300038980000042C0AC5C02000C260184C0001058
...    158F80400181B03098061300006160562E0100060080C0D800102C0AC7C02000C030181B0309A00050B02B1700800303606130000C160561E010006130000E160561
...    E0100060080010160561E0D800606C0012160561E0100060180014160561E03000606C0016160562E0100060180C0D800302C0AC3C1B000E2600000D0B02B1713000
...    309806008001C160563E2600061300C010181B0007858158B8980018020303600100B02B1F134003004060180C0D800442C08048037001A0264002809A1E81D21285
...    1226C73E1C4891226C73E1C4891226C73E1C68912244D8E7C38912244D8E7C38D1224489B1CF871224489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1
...    CF870A244D8E7C38912244D8E7C3851226C73E1C4891226C73E1C68912244D8E7C38912244D8E7C38D1224489B1CF8603624318C6318C6318C6318C63183D04C00F0
...    00A070500703009401C0018090010180F82400800000004002000000080000300400000802000008010000060080000400400002802001004010040000300200001C
...    010008000000200002001000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652DE4CDE02D606D6025604560ED0341000
...    009652504000065949810000196524040000E594901000049652404000165949810000696524040001E594901000089652404000265949010000A96524040002E594
...    9410000C96524040000C594900CD2AABA55554AA2E95455058AA0B1541A2A94C55268AA031540A2A93555078A1202F012A05028140A05028140A05028140A0502814
...    0A05028008840400801010020044020040080801002020040088040300501002004040080118080600A020180280801002020040088040400501010014040580B180
...    80600C02018028080600C02004008804030050100C014040080108080600A02004008404030050100C014202018030080600C10100C018040300508080600A020180
...    28804030050100C018040300508080600C020040088040080101002004040300518080100202004008080600A02018028804008010100C0180403006180801002020
...    18028080600C02018028D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C380A0300D

*** Test Cases ***
CB008140-ET-GC008_EPS_fallback_triggered_with_inter-gNB_CA 
    [Documentation]
    ...    The purpose of this test case is to check EPS fallback triggered with inter-gNB CA(FFT).
    ...    [Configuration]:
    ...    Cell 11 on gNB1 is Pcell.
    ...    Cell1 and cell14 on gNB2 has been configured as candidate SCell of Cell1.
    ...    2.Test Case Steps:
    ...      a. UE1 attach to cell11
    ...      b. Start both UL/DL traffic
    ...      c. Trigger MR for Scell Addition.(CA: cell11+cell1+cell14)
    ...      d. Check Throughput For FFT
    ...      e. Setup VONR Call On New PDU Session Will Trigger EPS Fallback
    ...      f. Deregister UE
    [Tags]    GC008    QC_253781
    Update UE capa    ${SA_Capa_UE1_voiceFallbackIndicationEPS-r16}    1
    Sa Ue Attach
    Send Throughput
    Wait Until Keyword Succeeds    20s    5s    Verify Throughput For Pcell
    Trigger MR for Scell Addition
    Wait Until Keyword Succeeds    20s    5s    Verify Throughput For FFT
    Setup VONR Call On New PDU Session Will Trigger EPS Fallback
    Check WireShark Log    ${CURDIR}${/}A2A_GC_008${/}a2a_gnb.ini    wait_string=IgNBCAReleaseRequestAcknowledge::1
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_GC_008${/}a2a_gnb2.ini    wait_string=UEContextRelease::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2F_gnb2_2T2F

Modify Cfg
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null nea=null voice_fallback=on
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=1,2,3 qos_rules=1,2 default=on ue=all amf=1
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 qos_flows=2,3 qos_rules=1,2 ue=all amf=1
    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=2
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=3

Update UE capa
    [Arguments]    ${SA_Capa}=none    ${ue_id}=1
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa}
    Execute Egate Command    ${cmd}

Sa Ue Attach
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=11
    ...    ${pass_regexp}=NG RM Register
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${pass_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    pass_regexp=Initial Context Setup Successful

Trigger MR for Scell Addition
    [Arguments]    ${event_type}=A1    ${carrierfreq}=363850    ${srsrp_nr}=100    ${srsrq_nr}=100    ${ue_id}=1
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${CELL1_CELL14_Added_As_Scell_Based_On_A1}

Send Throughput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=50 trf_id=1    UE ${ue_id}: UDP UL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=6    UE ${ue_id}: UDP DL

Verify Throughput For Pcell
    [Arguments]    ${ue_id}=1    ${pcell_tput}=90    ${ul_tput}=45
    ${dl_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${pcell_tput}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul_tput}

Verify Throughput For FFT
    [Arguments]    ${ue_id}=1    ${total_dl_tput}=700    ${ul_tput}=45
    Verify DL throughput    ${ue_id}    ${total_dl_tput}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul_tput}

Verify DL throughput
    [Arguments]    ${ue_id}=1    ${total_tput}=700
    ${pcell_dl}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_dl}/1000 > 0
    ${total_dl}    Set Variable    ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${total_dl}    Evaluate    ${scell1_tput}+${total_dl}
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > 0
    ${total_dl}    Evaluate    ${scell2_tput}+${total_dl}
    Should Be True    ${total_dl}/1000>${total_tput}

Setup VONR Call On New PDU Session Will Trigger EPS Fallback
    [Arguments]    ${ue_id}=1    ${gateway}=2    ${pdu}=2    ${qosflows}=3
    Execute Egate Command    qosflow_modify qos_flow=2 default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=1 gw=${gateway}    pass_regexp=QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qosflows} by=amf
    ...    pass_regexp=RRCConnectionRelease contains voiceFallbackIndication_r16



