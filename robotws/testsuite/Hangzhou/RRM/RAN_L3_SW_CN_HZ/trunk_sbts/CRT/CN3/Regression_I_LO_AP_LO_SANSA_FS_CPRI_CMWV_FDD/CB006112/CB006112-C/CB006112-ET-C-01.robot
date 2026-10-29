*** Settings ***
Documentation
...    author: Li Zhiguo
...    contact: zhiguo.li@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup  Common Suite Setup And Setup Airphone Env
Suite Teardown  Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup  Common Test Setup And Start To Capture Logs
Test Teardown  Common Test Teardown And Stop Capture Logs
Force Tags  QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  RAN_5G_FDD  CRT  CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD  team-DevHZ5_SG1
...  owner-pei.han  release-5G21A
Resource  ../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...  @{5GC000786}
...  @{CB006112-A}
...  @{5GC000704}
...  @{CB006112-C}
...  @{relation_error_fix}
@{5GC000786}
...  NRCELL-1:actVoNR=true

...  NRDRB_5QI-1:fiveqiValueList=5
...  NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...  NRDRB_5QI-5:fiveqiValueList=9
...  NRDRB_5QI-5:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...  NRDRB_5QI-3:fiveqiValueList=1
...  NRDRB_5QI-3:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-3
...  NRDRB_5QI-3:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...  NRBTS:timerXnDataFwdGuard=250
...  NRDRB-2:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-1
...  NRDRB-2:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...  NRDRB-2:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...  NRDRB-2:dlFlowControlAlgo=none
...  NRDRB-2:rlcMode=RLC_UM
...  NRDRB-3:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...  NRDRB-3:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...  NRDRB-3:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...  NRDRB-3:cellAggrLevel=Not FR1 CA eligible
...  NRDRB-3:resType=GBR
...  NRDRB-3:maxDataRateGbrDl=1000
...  NRDRB-3:maxDataRateGbrUl=1000
...  NRDRB-15:maxDataRateGbrDl=1000
...  NRDRB-3:queuingDelayDiscarding=Disabled

...  NRDRB-3:rlcMode=RLC_UM
...  NRDRB_RLC_UM-1:dlTReassemblyUm=ms15
...  NRDRB_RLC_UM-1:ulTReassemblyUm=ms15
...  NRDRB_MAC-3:lcgid=4
...  NRDRB-3:dscp=46
...  NRDRB-2:discardTimer=infinity
...  NRDRB_PDCP-1:pdcpBufDiscardEnabled=false
...  NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
@{CB006112-A}
...  NRCELL-1:actEnhancedVoNR=true
...  NRBTS:tRLFindForDUVoNR=2000ms
...  NRCELL-1:n310VoNR=n20
...  NRCELL-1:t310VoNR=4000ms
...  NRDRB-3:discardTimer=150ms
...  NRDRB-3:dlFlowControlAlgo=none
...  NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm6bitSN
...  NRCELL-1:actAdaptVoipTbs=true
...  NRCELL-1:actVoipPacketAggr=true
...  NRDRB_PDCP-1:pdcpBufDiscardEnabled=false
@{CB006112-C}
...  NRCELL-1:actGBRAdmissionControl=EnhancedVoNR
...  NRCELL-1:maxNumOfGBRBearersSA=10
...  NRCELL-1:maxGBRTrafficLimit=50
...  NRCELL-1:addNumOfGBRBearers=0
...  NRCELL-1:actVoNrMobilityThresholds=VoNrMobilityThresholds
...  NRBTS:actInterFreqHoSA=true
...  NRCELL-1:a2MeashoEnabledSA=rsrpAndRsrq
...  NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...  NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=6|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...  NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=50|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...  NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=60|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...  NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...  NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=0|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...  NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresisHoSsbRsrqVoNr=6|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...  NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=32|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...  NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdHoSsbRsrqVoNr=35|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...  NRCELL-1:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms480|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...  NRCELL-1:a1MeashoEnabledSA=rsrpAndRsrq
...  NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...  NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=6|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...  NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...  NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=70|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...  NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...  NRCELL-1:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=0|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...  NRCELL-1:a1MeashoSsbRsrqSA:a1HysteresisHoSsbRsrqVoNr=6|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...  NRCELL-1:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=35|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...  NRCELL-1:a1MeashoSsbRsrqSA:a1ThresholdHoSsbRsrqVoNr=40|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...  NRCELL-1:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms480|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...  NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrpAndRsrq
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrpVoNr=ms256
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=2|a3TimeToTriggerSsbRsrpVoNr=ms256
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrpVoNr=ms256
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=2|a3TimeToTriggerSsbRsrpVoNr=ms256
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480|a3TimeToTriggerSsbRsrpVoNr=ms256
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0|a3TimeToTriggerSsbRsrqVoNr=ms256
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrqVoNr=2|a3TimeToTriggerSsbRsrqVoNr=ms256
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=3|a3TimeToTriggerSsbRsrqVoNr=ms256
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrqVoNr=2|a3TimeToTriggerSsbRsrqVoNr=ms256
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms480|a3TimeToTriggerSsbRsrqVoNr=ms256
...  NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrpAndRsrq
...  NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0|a5TimeToTriggerSsbRsrpVoNr=ms256
...  NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrpVoNr=2|a5TimeToTriggerSsbRsrpVoNr=ms256
...  NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=40|a5TimeToTriggerSsbRsrpVoNr=ms256
...  NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrpVoNr=50|a5TimeToTriggerSsbRsrpVoNr=ms256
...  NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=50|a5TimeToTriggerSsbRsrpVoNr=ms256
...  NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrpVoNr=60|a5TimeToTriggerSsbRsrpVoNr=ms256
...  NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms480|a5TimeToTriggerSsbRsrpVoNr=ms256
...  NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0|a5TimeToTriggerSsbRsrqVoNr=ms256
...  NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5HysteresisSsbRsrqVoNr=2|a5TimeToTriggerSsbRsrqVoNr=ms256
...  NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold1SsbRsrq=10|a5TimeToTriggerSsbRsrqVoNr=ms256
...  NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold1SsbRsrqVoNr=20|a5TimeToTriggerSsbRsrqVoNr=ms256
...  NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold2SsbRsrq=20|a5TimeToTriggerSsbRsrqVoNr=ms256
...  NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold2SsbRsrqVoNr=30|a5TimeToTriggerSsbRsrqVoNr=ms256
...  NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms480|a5TimeToTriggerSsbRsrqVoNr=ms256
...  NRCELL-1/NRHOIF-1:cellDepType=SA
...  NRCELL-1/NRHOIF-1:freqBandIndicatorNR=71
...  NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...  NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...  NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...  NRCELL-1/NRHOIF-1:scs=15 KHz
...  NRCELL-1/NRHOIF-1:ssbFrequency=126530
...  XNLINK-1:cPlaneIpAddr=10.0.1.124
...  NRADJGNB-1:administrativeState=Unlocked
...  NRADJGNB-1:gNbIdLength=22
...  NRADJGNB-1:gNodeBId=35
...  NRADJGNB-1:xnLinkRef=1
...  NRADJGNB-1:gnbPlmn:mcc=311|mncLength=3
...  NRADJGNB-1:gnbPlmn:mnc=489|mncLength=3
...  NRADJNRCELL-2:cellDepType=SA
...  NRADJNRCELL-2:fiveGsTac=788
...  NRADJNRCELL-2:gNbId=35
...  NRADJNRCELL-2:gNbIdLength=22
...  NRADJNRCELL-2:lcrId=1
...  NRADJNRCELL-2:nrarfcn=126530
...  NRADJNRCELL-2:physCellId=49
...  NRADJNRCELL-2:gnbPlmn:mcc=311|mncLength=3
...  NRADJNRCELL-2:gnbPlmn:mnc=489|mncLength=3
...  NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...  NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...  NRCELL-1/NRREL-1:gNbId=35
...  NRCELL-1/NRREL-1:gNbIdLength=22
...  NRCELL-1/NRREL-1:lcrId=1
...  NRCELL-1/NRREL-1:removeNotAllowed=false
...  NRCELL-1/NRREL-1:gnbPlmn:mcc=311|mncLength=3
...  NRCELL-1/NRREL-1:gnbPlmn:mnc=489|mncLength=3
@{5GC000704}

...  NRBTS:actConflictConfiguration=true
...  NRBTS:actIntraFreqHoSA=true
...  NRPMRNL-1:miNrRelReportCu=5min
...  NRCELL-1:a3MeasEnabled=rsrp
...  NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrp=ms320
...  NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrp=ms320
...  NRCELL-1:filterCoeffSsbRsrp=fc4
...  NRCELL-1:absThreshSsbRsrpConsolidation=1
...  NRCELL-1:sMeasConfigSsbRsrp=20
...  NRBTS:actIncXn=true
...  XNLINK-2:cPlaneIpAddr=10.0.1.122
...  NRADJGNB-2:administrativeState=Unlocked
...  NRADJGNB-2:gNbIdLength=22
...  NRADJGNB-2:gNodeBId=36
...  NRADJGNB-2:xnLinkRef=2
...  NRADJGNB-2:gnbPlmn:mcc=311|mncLength=3
...  NRADJGNB-2:gnbPlmn:mnc=489|mncLength=3
...  NRADJNRCELL-1:cellDepType=SA
...  NRADJNRCELL-1:fiveGsTac=788
...  NRADJNRCELL-1:gNbId=36
...  NRADJNRCELL-1:gNbIdLength=22
...  NRADJNRCELL-1:lcrId=1
...  NRADJNRCELL-1:nrarfcn=126290
...  NRADJNRCELL-1:physCellId=48
...  NRADJNRCELL-1:gnbPlmn:mcc=311|mncLength=3
...  NRADJNRCELL-1:gnbPlmn:mnc=489|mncLength=3
...  delete:NRADJNRCELL-1:freqBandIndicatorNR
...  NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...  NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...  NRCELL-1/NRREL-10:gNbId=36
...  NRCELL-1/NRREL-10:gNbIdLength=22
...  NRCELL-1/NRREL-10:lcrId=1
...  NRCELL-1/NRREL-10:removeNotAllowed=false
...  NRCELL-1/NRREL-10:gnbPlmn:mcc=311|mncLength=3
...  NRCELL-1/NRREL-10:gnbPlmn:mnc=489|mncLength=3
...  NRBTS:cipherPrefL:nea0=9|nea3_128=0
${ue_nr_capabilities}  SEPARATOR=
...  E1A01000074E5A031E000382A003C1260C80008683803100D0098040623805506C28D608C21A08107CA0702CB64C550F027C873E819F11C78C
...  73E618F28581C0E1E0BF8000000FE000000078001C0AA36236B04650D0408380000650380F5B040A041C3BC70E418700040C9E3E2FE0000003
...  F80000001E000702A0D805AC1184341020F940E0496C98AA0A1CF88E3C639F30C7942C0E070F027F0000001FC0000000F00038002107118000
...  00001988C004C280002C00700808DFEAAAAA09801800140E0A00E06013003800301F008010000000080000100400001005CA9BCA9AC0CA0102
...  000012CA4A080000CB29282000052CA480169555D2AAAA07142401600560B0580000008030063562600020406080A0C0E10162022242632424
...  A4C4E5094C35A0
@{OnlineParam_C_01}
...  NRCELL-1:maxNumOfGBRBearersSA=2
@{PM_Counters_Check}
...  NRCELL-1:RSACU:${SA_GBR_DRB_REQ}=3
...  NRCELL-1:RSACU:${SA_GBR_DRB_SUCC}=2
...  NRCELL-1:RSACU:${SA_GBR_REJ_LACK_DRB}=1
...  NRCELL-1:RSACU:${SA_GBR_DRB_REL}=2
...  NRBTS-1:NSL:${SA_GBR_DRB_REQ_SLICE}=3
...  NRBTS-1:NSL:${SA_GBR_DRB_SUCC_SLICE}=2
...  NRCELL-1:NRANS:${RA_NGBR_DRB_SA_PLMN}=3
...  NRCELL-1:NRANS:${RA_GBR_DRB_SA_PLMN}=2
...  NRCELL-1:RSADU:${SA_DU_GBR_REJ_LACK_DRB}=0
${SA_GBR_DRB_REQ}  M55138C01001
${SA_GBR_DRB_SUCC}  M55138C01002
${SA_GBR_REJ_LACK_DRB}  M55138C01003
${SA_GBR_DRB_REL}  M55138C01004
${SA_GBR_DRB_REQ_SLICE}  M55149C01001
${SA_GBR_DRB_SUCC_SLICE}  M55149C01002
${RA_NGBR_DRB_SA_PLMN}  M55145C00502
${RA_GBR_DRB_SA_PLMN}  M55145C00503
${SA_DU_GBR_REJ_LACK_DRB}  M55139C00503
@{relation_error_fix}
...  NRCELL-1:measGapSelectionSA=favourUeThroughput
...  NRCELL-1:actGbrRacTdEnhResourcePriority=false

*** Test Cases ***
CB006112-ET-C-01_TDD Voice call reject due to number of GBR resources limits
  [Tags]
  OnlineParamChange  ${OnlineParam_C_01}
  UE-1 attach to gNB
  UE-2 attach to gNB
  UE-3 attach to gNB
  UE Deregister From GNB  ue_id=1,2,3
  Check counters  ${PM_Counters_Check}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
  Common Suite Setup
  ${match_string}  Create List  GNB-3: XnAP Link with GNB-2  GNB-4: XnAP Link with GNB-2
  Setup Airphone Env  tl_type=fdd_sansa_cmwv/2cells  match_string=${match_string}

Modify Cfg
  Update Cfg  set_qosflow id=1 5qi=5 default=on
  Update Cfg  set_qosflow id=3 5qi=9
  Update Cfg  set_qosflow id=2 5qi=1
  Update Cfg  set_qosflow id=4 5qi=2
  Update Cfg  set_qosflow id=5 5qi=6
  Update Cfg  set_qosrule id=1 proto=tcp qos_flow=1
  Update Cfg  set_qosrule id=2 proto=udp qos_flow=2
  Update Cfg  set_nwslice id=1 qos_flows=5,4,3,2,1 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=1-5 amf=1
  Update Cfg  ue_nr_capabilities id=1-5 voice_over_nr=on:on:off
  Update Cfg  amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc
  ${AutoVariable_1}  catenate  SEPARATOR=
  ...  ue_param id=1-5 nr_usage_setting=voice_centric ue_nr_capabilities=E1A01000074E5A031E000382A003C1260C800086838031
  ...  00D0098040623805506C28D608C21A08107CA0702CB64C550F027C873E819F11C78C73E618F28581C0E1E0BF8000000FE000000078001C0A
  ...  A36236B04650D0408380000650380F5B040A041C3BC70E418700040C9E3E2FE0000003F80000001E000702A0D805AC1184341020F940E049
  ...  6C98AA0A1CF88E3C639F30C7942C0E070F027F0000001FC0000000F0003800210711800000001988C004C280002C00700808DFEAAAAA0980
  ...  1800140E0A00E06013003800301F008010000000080000100400001005CA9BCA9AC0CA0102000012CA4A080000CB29282000052CA4801695
  ...  55D2AAAA07142401600560B0580000008030063562600020406080A0C0E10162022242632424A4C4E5094C35A0
  Update Cfg  ${AutoVariable_1}
  Update Cfg  set_pdu_gateway id=2 ue_nat_ip=72.23.1.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
  Update Cfg  set_pdu_gateway id=3 ue_nat_ip=72.23.2.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
  Update Cfg  set_pdu_gateway id=4 ue_nat_ip=72.23.3.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
  ${AutoVariable_2}  catenate
  ...  set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x24:22 daemon=10.0.2.1:22222 x2_peers=none
  ...  xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
  Update Cfg  ${AutoVariable_2}
  Update Cfg  set_cell id=1 gnb=3 pci=16:0 tac=788 nrci=0x01 tdd_cell=off proxy=10.0.2.92:9999 nr_arfcn=135760:126380 gscn=1579
  Update Cfg  gnb_param id=3 xn_listening_socket=1 send_xn_setup=false
  ${AutoVariable_3}  catenate
  ...  set_gnb id=4 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none
  ...  xn=10.0.1.124 nssai=0x1:0xd143a5 amf=1
  Update Cfg  ${AutoVariable_3}
  Update Cfg  set_cell id=1 gnb=4 pci=16:1 tac=788 nrci=0x01 tdd_cell=off proxy=10.0.2.90:9999 nr_arfcn=135760:126380 gscn=1582
  Update Cfg  gnb_param id=4 xn_listening_socket=1 send_xn_setup=false
  ${AutoVariable_3}  catenate
  ...  set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
  ...  nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645401 mode=nr enb=2 cell=1
  ${AutoVariable_4}  catenate
  ...  set_ue simulated id=3 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
  ...  nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645402 mode=nr enb=2 cell=1
  Update Cfg  ${AutoVariable_3}
  Update Cfg  ${AutoVariable_4}

UE Register To GNB
  [Arguments]  ${ue_id}=1
  Execute Egate Command  ue_register id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}
  ...  UE now in NG RM Registered

UE PDU Session Setup
  [Arguments]  ${ue_id}=1  ${pdu}=1  ${gw}=1  ${fiveQi}=5
  ${ret1}=  Execute Egate Command  ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=1 gw=${gw}
  ...  pass_regexp=QoS Routing Table
  Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi ${fiveQi} qfi 1

UE PDU Session Modify to Add
  [Arguments]  ${ue_id}=1  ${pdu}=1
  ${ret1}=  Execute Egate Command  ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=2 by=amf
  ...  pass_regexp=QoS Routing Table
  Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi 1 qfi 2
  Should Contain  ${ret1}  discardTimer ms150

UE PDU Session Modify to Add_Failed
  [Arguments]  ${ue_id}=1  ${pdu}=1
  ${ret1}=  Execute Egate Command  ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=2 by=amf
  ...  fail_regexp=rrcReconfigurationComplete
  Should Not Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi 1 qfi 2

UE PDU Session Modify to Del
  [Arguments]  ${ue_id}=1  ${pdu}=1
  ${ret1}=  Execute Egate Command  ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=2 by=amf
  ...  rrcReconfigurationComplete
  Should Contain  ${ret1}  Removed FiveQi:Qfi mapping fiveQi 1 qfi 2

UE Deregister From GNB
  [Arguments]  ${ue_id}=1
  FOR  ${ue_ids}  IN  @{ue_id.split(",")}
    Execute Egate Command  ue_deregister id=${ue_ids} ue_deregister_type=switch_off  detached
  END
Wait A While
  Sleep  5s

Qosflow_modify
  [Arguments]  ${qos_flow}=1  ${ue_id}=1
  Execute Egate Command  qosflow_modify default=on qos_flow=${qos_flow} ue=${ue_id}

UE PDU Session Setup with Multi Qosflow
  [Arguments]  ${additional_qosflows_to_activate}=2  ${fiveQi_1}=5  ${fiveQi_2}=1  ${ue_id}=1  ${gw}=1  ${pdu}=1
  Execute Egate Command  smf_param id=1 reset
  Execute Egate Command  smf_param id=1 additional_qosflows_to_activate=${additional_qosflows_to_activate}
  ${ret1}=  Execute Egate Command  ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=1 gw=${gw}
  ...  pass_regexp=QoS Routing Table
  Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi ${fiveQi_1} qfi 1
  Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi ${fiveQi_2} qfi 2
  Execute Egate Command  smf_param id=1 reset

OnlineParamChange
  [Arguments]  ${Online_Param}
  Delta Commission Parameters  ${Online_Param}
  Cells Should Be Onair    check_sib=${False}

UE-1 attach to gNB
  UE Register To GNB
  UE PDU Session Setup
  UE PDU Session Modify to Add

UE-2 attach to gNB
  UE Register To GNB  ue_id=2
  UE PDU Session Setup with Multi Qosflow  ue_id=2  additional_qosflows_to_activate=2  gw=2

UE-3 attach to gNB
  UE Register To GNB  ue_id=3
  UE PDU Session Setup  ue_id=3  gw=3
  UE PDU Session Modify to Add_Failed  ue_id=3
