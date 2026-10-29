*** Settings ***
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
...  @{CB006112}
...  @{5GC000704}
...  @{CDRX}
...  @{5GC000706}
...  @{relation_error_fix}
@{5GC000786}
...  NRCELL-1:actVoNR=true

...  NRDRB_5QI-1:fiveqiValueList=5
...  NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...  NRDRB_5QI-5:fiveqiValueList=9
...  NRDRB_5QI-5:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...  NRDRB_5QI-3:fiveqiValueList=1
...  NRDRB_5QI-3:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-3
...  NRDRB-2:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-1
...  NRDRB-2:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...  NRDRB-2:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...  NRDRB-2:dlFlowControlAlgo=none
...  NRDRB-2:rlcMode=RLC_UM
...  NRDRB-3:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...  NRDRB-3:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...  NRDRB-3:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...  NRDRB-3:resType=GBR
...  NRDRB-3:rlcMode=RLC_UM
...  NRDRB_RLC_UM-1:dlTReassemblyUm=ms15
...  NRDRB_RLC_UM-1:ulTReassemblyUm=ms15
...  NRDRB_MAC-3:lcgid=4
...  NRDRB-3:dscp=46
...  NRDRB-2:discardTimer=infinity
...  NRDRB_PDCP-1:pdcpBufDiscardEnabled=false
...  NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
@{CB006112}
...  NRCELL-1:actEnhancedVoNR=true
...  NRBTS:tRLFindForDUVoNR=2000ms
...  NRCELL-1:n310VoNR=n20
...  NRCELL-1:t310VoNR=4000ms
...  NRDRB-3:discardTimer=150ms
...  NRDRB-3:dlFlowControlAlgo=none
...  NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm6bitSN
@{CDRX}
...  NRCELL-1:actCDrx=true
...  NRCELL-1:actCDrxVoNR=true
...  NRCELL-1:drxProfile1:drxInactivityTimer=40ms|drxRetransTimerUl=16slot
...  NRCELL-1:drxProfile1:drxLongCycle=80ms|drxRetransTimerUl=16slot
...  NRCELL-1:drxProfile1:drxOnDurationTimer=10ms|drxRetransTimerUl=16slot
...  NRCELL-1:drxProfile1:drxRetransTimerDl=16slot|drxRetransTimerUl=16slot
...  NRCELL-1:drxProfile2:drxInactivityTimer=4ms|drxRetransTimerUl=0slot
...  NRCELL-1:drxProfile2:drxLongCycle=40ms|drxRetransTimerUl=0slot
...  NRCELL-1:drxProfile2:drxOnDurationTimer=6ms|drxRetransTimerUl=0slot
...  NRCELL-1:drxProfile2:drxRetransTimerDl=0slot|drxRetransTimerUl=0slot

@{5GC000704}

...  NRBTS:actConflictConfiguration=true
...  NRBTS:actIntraFreqHoSA=true
...  NRPMRNL-1:miNrRelReportCu=5min
...  NRCELL-1:a3MeasEnabled=rsrp
...  NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrp=ms320
...  NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrp=ms320
...  NRCELL-1:filterCoeffSsbRsrp=fc4
...  NRCELL-1:absThreshSsbRsrpConsolidation=80
...  NRCELL-1:sMeasConfigSsbRsrp=20
...  NRBTS:actIncXn=true
...  XNLINK-1:cPlaneIpAddr=10.0.1.122
...  NRADJGNB-1:administrativeState=Unlocked
...  NRADJGNB-1:gNbIdLength=22
...  NRADJGNB-1:gNodeBId=36
...  NRADJGNB-1:xnLinkRef=1
...  NRADJGNB-1:gnbPlmn:mcc=311|mncLength=3
...  NRADJGNB-1:gnbPlmn:mnc=489|mncLength=3
...  NRADJNRCELL-1:cellDepType=SA+NSA
...  NRADJNRCELL-1:fiveGsTac=788
...  NRADJNRCELL-1:gNbId=36
...  NRADJNRCELL-1:gNbIdLength=22
...  NRADJNRCELL-1:lcrId=1
...  NRADJNRCELL-1:nrarfcn=126290
...  NRADJNRCELL-1:physCellId=48
...  NRADJNRCELL-1:gnbPlmn:mcc=311|mncLength=3
...  NRADJNRCELL-1:gnbPlmn:mnc=489|mncLength=3
...  NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...  NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...  NRCELL-1/NRREL-10:gNbId=36
...  NRCELL-1/NRREL-10:gNbIdLength=22
...  NRCELL-1/NRREL-10:lcrId=1
...  NRCELL-1/NRREL-10:removeNotAllowed=false
...  NRCELL-1/NRREL-10:gnbPlmn:mcc=311|mncLength=3
...  NRCELL-1/NRREL-10:gnbPlmn:mnc=489|mncLength=3
@{5GC000706}
...  NRBTS:actInterFreqHoSA=true
...  NRCELL-1:a2MeashoEnabledSA=rsrp
...  NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0|a2TimeToTriggerhoSsbRsrpSA=ms480
...  NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=60|a2TimeToTriggerhoSsbRsrpSA=ms480
...  NRCELL-1:a1MeashoEnabledSA=rsrp
...  NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0|a1TimeToTriggerhoSsbRsrpSA=ms480
...  NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=70|a1TimeToTriggerhoSsbRsrpSA=ms480
...  NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...  NRCELL-1/NRHOIF-1:cellDepType=SA
...  NRCELL-1/NRHOIF-1:chBw=20MHz
...  NRCELL-1/NRHOIF-1:freqBandIndicatorNR=71
...  NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...  NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...  NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...  NRCELL-1/NRHOIF-1:ssbFrequency=126400
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrp=ms320
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrp=ms320
${ue_nr_capabilities}  SEPARATOR=
...  E5A01000074F5E13020002054004824C1800260D07006201A0130080C450180533805506C28D608C21A08107CA0702CB64C550F027C873E819F
...  11C78C73E618F28581C0E1E0BF8000000FE000000078001C0E83623606B04610D04083E5038165B262A87813E439F40CF88E3C639F30C7942C0
...  E070F05FC0000007F00000003C000E0541B00B582308682041F281C092D931541439F11C78C73E618F28581C0E1E04FE0000003F80000001E00
...  07000400E2300000000331180098500005801A01811B639F0FD04800E040500603009401800180A00400000041C04D0001CF9863CA160607C02
...  00400000002000004010000040132A6F2A6B0328040800004B29282000032CA4A0800014B292004A55574AAAA81C50900580150281400000020
...  0C018520F0300C020
@{relation_error_fix}
...  NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots320
...  NRCELL-1:measGapSelectionSA=favourUeThroughput
${wait to Get RRC Log}  2s

*** Test Cases ***
CB006112-ET-B-04_FDD non GNB DRX parameter will be used when PDU Session Resource Modify Request to remove 5QI1 Qos flow
  [Tags]
  Smf Param Reset Before Register
  UE Register To GNB
  UE PDU Session Setup with Multi Qosflow
  UE PDU Session Modify to Del
  UE Deregister From GNB
  Check RRC Log  ${CURDIR}${/}a2a_CB006112-ET-B-04${/}a2a.ini

CB006112-ET-B-05_switch back non-GBR DRX profile when pdu session release for Voice call release
  [Tags]
  Smf Param Reset Before Register
  UE Register To GNB
  Default_Qosflow_modify  qos_flow=3
  UE PDU Session Setup  fiveQi=9
  Default_Qosflow_modify
  UE PDU Session Setup with Multi Qosflow  pdu=2  gw=2
  UE PDU Session Release
  UE Deregister From GNB
  Check RRC Log  ${CURDIR}${/}a2a_CB006112-ET-B-05${/}a2a.ini

CB006112-ET-B-11_FDD Voice DRX Interaction with measurement gap
  [Tags]
  Smf Param Reset Before Register
  UE Register To GNB
  UE PDU Session Setup
  A2 measurement report
  UE PDU Session Modify to Add
  A1 measurement report
  UE PDU Session Modify to Del
  UE Deregister From GNB
  Check RRC Log  ${CURDIR}${/}a2a_CB006112-ET-B-11${/}a2a.ini

*** Keywords ***
Common Suite Setup And Setup Airphone Env
  Common Suite Setup
  Setup Airphone Env  tl_type=fdd_sansa_cmwv/2cells  match_string=GNB-3: XnAP Link with GNB-2

Modify Cfg
  Update Cfg  set_qosflow id=1 5qi=5 default=on
  Update Cfg  set_qosflow id=3 5qi=9
  Update Cfg  set_qosflow id=2 5qi=1
  Update Cfg  set_qosrule id=1 proto=tcp qos_flow=1
  Update Cfg  set_qosrule id=2 proto=udp qos_flow=2
  Update Cfg  set_nwslice id=1 qos_flows=3,2,1 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=1-5 amf=1
  Update Cfg  ue_nr_capabilities id=1-5 voice_over_nr=on:on:off
  Update Cfg  amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc
  ${AutoVariable_1}  catenate  SEPARATOR=
  ...  ue_param id=1-5 nr_usage_setting=voice_centric ue_nr_capabilities=E5A01000074F5E13020002054004824C1800260D07006201
  ...  A0130080C450180533805506C28D608C21A08107CA0702CB64C550F027C873E819F11C78C73E618F28581C0E1E0BF8000000FE000000078001
  ...  C0E83623606B04610D04083E5038165B262A87813E439F40CF88E3C639F30C7942C0E070F05FC0000007F00000003C000E0541B00B58230868
  ...  2041F281C092D931541439F11C78C73E618F28581C0E1E04FE0000003F80000001E0007000400E2300000000331180098500005801A01811B6
  ...  39F0FD04800E040500603009401800180A00400000041C04D0001CF9863CA160607C0200400000002000004010000040132A6F2A6B03280408
  ...  00004B29282000032CA4A0800014B292004A55574AAAA81C509005801502814000000200C018520F0300C020
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

Smf Param Reset Before Register
  Execute Egate Command  smf_param id=1 reset

UE Register To GNB
  [Arguments]  ${ue_id}=1
  Execute Egate Command  ue_register id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}
  ...  UE now in NG RM Registered

UE PDU Session Setup
  [Arguments]  ${ue_id}=1  ${pdu}=1  ${gw}=1  ${fiveQi}=5
  Start RRC Log  PDU_Session_Setup
  ${ret1}=  Execute Egate Command  ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=1 gw=${gw}
  ...  pass_regexp=QoS Routing Table
  Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi ${fiveQi} qfi 1
  rrc Should Contain  drx-LongCycleStartOffset ms80

UE PDU Session Modify to Add
  [Arguments]  ${ue_id}=1  ${pdu}=1
  Start RRC Log  PDU_Session_Modify_to_Add
  ${ret1}=  Execute Egate Command  ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=2 by=amf
  ...  pass_regexp=QoS Routing Table
  Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi 1 qfi 2
  Should Contain  ${ret1}  discardTimer ms150
  Sleep  ${wait to Get RRC Log}
  Get RRC Log

UE PDU Session Modify to Del
  [Arguments]  ${ue_id}=1  ${pdu}=1
  Start RRC Log  PDU_Session_Modify_to_Del
  ${ret1}=  Execute Egate Command  ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=2 by=amf
  ...  rrcReconfigurationComplete
  Should Contain  ${ret1}  Removed FiveQi:Qfi mapping fiveQi 1 qfi 2
  rrc Should Contain  drx-LongCycleStartOffset ms80

UE PDU Session Release
  [Arguments]  ${ue_id}=1  ${pdu}=2
  Start RRC Log  PDU_Session_Release
  ${ret1}=  Execute Egate Command  ue_pdu_session_release pdu=${pdu} ue=${ue_id} by=amf
  ...  pass_regexp=Successfully released PDU Session
  Should Contain  ${ret1}  Released PDU session ID=2 using Gateway ID=2
  rrc Should Contain  drx-LongCycleStartOffset ms80

UE Deregister From GNB
  [Arguments]  ${ue_id}=1
  Execute Egate Command  ue_deregister id=${ue_id} ue_deregister_type=switch_off  detached

Default_Qosflow_modify
  [Arguments]  ${qos_flow}=1  ${ue_id}=1
  Execute Egate Command  qosflow_modify default=on qos_flow=${qos_flow} ue=${ue_id}

UE PDU Session Setup with Multi Qosflow
  [Arguments]  ${additional_qosflows_to_activate}=2  ${fiveQi_1}=5  ${fiveQi_2}=1  ${ue_id}=1
  ...  ${gw}=1  ${pdu}=1
  Start RRC Log  PDU_Session_Setup_with_Multi_Qosflow
  Execute Egate Command  smf_param id=1 reset
  Execute Egate Command  smf_param id=1 additional_qosflows_to_activate=${additional_qosflows_to_activate}
  ${ret1}=  Execute Egate Command  ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=1 gw=${gw}
  ...  QoS Routing Table
  Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi ${fiveQi_1} qfi 1
  Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi ${fiveQi_2} qfi 2
  Execute Egate Command  smf_param id=1 reset
  rrc Should Contain  drx-LongCycleStartOffset ms40

A2 measurement report
  ${ret1}=  Execute Egate Command  ue_measurement_send_nr id=1 meas_id=1 phycell_id=60 event=A2 srsrp_nr=50 srsrq_nr=30
  ...  rrcReconfigurationComplete
  Should Contain  ${ret1}  eventId eventA1
  Should Contain  ${ret1}  gapUE setup
  Should Contain  ${ret1}  drx-Config release : NULL

A1 measurement report
  Start RRC Log  A1_measurement_report
  ${ret1}=  Execute Egate Command  ue_measurement_send_nr id=1 meas_id=4 phycell_id=60 event=A1 srsrp_nr=80 srsrq_nr=30
  ...  rrcReconfigurationComplete
  Should Contain  ${ret1}  eventId eventA2
  rrc Should Contain  drx-LongCycleStartOffset ms40
