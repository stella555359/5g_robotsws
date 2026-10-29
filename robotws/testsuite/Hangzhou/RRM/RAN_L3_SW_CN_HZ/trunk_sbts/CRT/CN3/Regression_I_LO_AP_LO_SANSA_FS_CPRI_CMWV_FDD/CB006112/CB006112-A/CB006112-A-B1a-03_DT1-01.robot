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
@{5GC000786}
...  NRCELL-1:actVoNR=true

...  NRDRB_5QI-1:fiveqiValueList=5
...  NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...  NRDRB_5QI-2:fiveqiValueList=9
...  NRDRB_5QI-2:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...  NRDRB_5QI-3:fiveqiValueList=1
...  NRDRB_5QI-3:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-3
...  NRDRB_5QI-5:fiveqiValueList=6
...  NRDRB_5QI-3:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...  NRBTS:timerXnDataFwdGuard=250
...  NRDRB-2:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-1
...  NRDRB-2:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...  NRDRB-2:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...  NRDRB-2:dlFlowControlAlgo=none
...  NRDRB-2:resType=nonGBR
...  NRDRB-2:rlcMode=RLC_UM
...  NRDRB-3:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
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
...  NRDRB_MAC-4:lcgid=4
...  NRDRB-3:dscp=46
...  NRDRB-2:discardTimer=infinity
...  NRDRB-3:discardTimer=150ms
...  NRDRB-3:dlFlowControlAlgo=none
...  NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm6bitSN
...  NRDRB_PDCP-1:pdcpBufDiscardEnabled=false
@{CB006112}
...  NRCELL-1:actEnhancedVoNR=true
...  NRBTS:tRLFindForDUVoNR=2000ms
...  NRCELL-1:n310VoNR=n20
...  NRCELL-1:t310VoNR=4000ms
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
...  NRADJNRCELL-1:ssbFrequency=126530
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
...  NRBTS:cipherPrefL:nea0=9|nea3_128=0
${ue_nr_capabilities_A-B1a-03}  SEPARATOR=
...  E5A00000054F5E13020002054004824C1800260D07006201A0130080C450180533805506C28D608C21A08107CA0702CB64C550F027C873E819F
...  11C78C73E618F28581C0E1E0BF8000000FE000000078001C0E83623606B04610D04083E5038165B262A87813E439F40CF88E3C639F30C7942C0
...  E070F05FC0000007F00000003C000E0541B00B582308682041F281C092D931541439F11C78C73E618F28581C0E1E04FE0000003F80000001E00
...  07000400E2300000000331180098500005801A01811B639F0FD04800E040500603009401800180A00400000041C04D0001CF9863CA160607C02
...  00400000002000004010000040132A6F2A6B0328040800004B29282000032CA4A0800014B292004A55574AAAA81C50900580150281400000020
...  0C018520F0300C020
${ue_nr_capabilities_A-DT1-01}  SEPARATOR=
...  E5A01000074F5E13020002054004824C1800260D07006201A0130080C450180533805506C28D608C21A08107CA0702CB64C550F027C873E819F
...  11C78C73E618F28581C0E1E0BF8000000FE000000078001C0E83623606B04610D04083E5038165B262A87813E439F40CF88E3C639F30C7942C0
...  E070F05FC0000007F00000003C000E0541B00B582308682041F281C092D931541439F11C78C73E618F28581C0E1E04FE0000003F80000001E00
...  07000400E2300000000331180098500005801A01811B639F0FD04800E040500603009401800180A00400000041C04D0001CF9863CA160607C02
...  00400000002000004010000040132A6F2A6B0328040800004B29282000032CA4A0800014B292004A55574AAAA81C50900580150281400000020
...  0C018520F0300C020
${V_1}  SEPARATOR=
...  E5A01000074F5E13020002054004824C1800260D07006201A0130080C450180533805506C28D608C21A08107CA0702CB64C550F027C873E819F
...  11C78C73E618F28581C0E1E0BF8000000FE000000078001C0E83623606B04610D04083E5038165B262A87813E439F40CF88E3C639F30C7942C0
...  E070F05FC0000007F00000003C000E0541B00B582308682041F281C092D931541439F11C78C73E618F28581C0E1E04FE0000003F80000001E00
...  07000400E2300000000331180098500005801A01811B639F0FD04800E040500603009401800180A00400000041C04D0001CF9863CA160607C02
...  00400000002000004010000040132A6F2A6B0328040800004B29282000032CA4A0800014B292004A55574AAAA81C50900580150281400000020
...  0C018520F0300C020

*** Test Cases ***
CB006112-A-B1a-03_ET_Verify GBR call will use PDCD 18bits when UE capbility does not support PDCP shortSN
	[Tags]  QC_xxxx
  UE Register To GNB  ue_nr_capabilities=${ue_nr_capabilities_A-B1a-03}
  UE PDU Session Setup
  UE PDU Session Modify to Add
  UE Deregister From GNB
  Check RRC Log  ${CURDIR}${/}a2a_CB006112-A-B1a-03${/}a2a.ini

CB006112-ET-DT1-01_Verify TDD New discardTimer will be used in target cell when handover to target cell
	[Tags]
  Set UE Parameters Before Register
  UE Register To GNB  ue_nr_capabilities=${ue_nr_capabilities_A-DT1-01}
  UE PDU Session Setup
  UE PDU Session Modify to Add
  Intra-frequency handover to Sim gNB
  Intra-frequency handover to Real gNB
  UE Deregister From GNB
  Check RRC Log  ${CURDIR}${/}a2a_CB006112-ET-DT1-01${/}a2a.ini

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
  Update Cfg  set_nwslice id=1 qos_flows=3,2,1 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=1-3 amf=1
  Update Cfg  ue_nr_capabilities id=1 voice_over_nr=on:on:off
  Update Cfg  amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc
  Update Cfg  ue_param id=1 nr_usage_setting=voice_centric ue_nr_capabilities=${V_1}
  Update Cfg  set_pdu_gateway id=2 ue_nat_ip=72.23.1.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
  Update Cfg  set_pdu_gateway id=3 ue_nat_ip=72.23.2.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
  ${V_2}  catenate
  ...  set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x24:22 daemon=10.0.2.1:22222 x2_peers=none
  ...  xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
  Update Cfg  ${V_2}
  ${V_3}  catenate
  ...  set_cell id=1 gnb=2 pci=20:0 tac=788 nrci=0x01 tdd_cell=off
  ...  proxy=10.0.2.80:9999|10.0.2.80:8888 nr_arfcn=135760:126380 mandatory_for_activation=off
  Update Cfg  ${V_3}
  Update Cfg
  ...  set_cell id=1 gnb=3 pci=16:0 tac=788 nrci=0x01 proxy=10.0.2.92:9999 nr_arfcn=135760:126380 gscn=1579
  Update Cfg  gnb_param id=3 xn_listening_socket=1 send_xn_setup=false rlc_config=5:um:size_12

Set UE Parameters Before Register
  Execute Egate Command
  ...  ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
  Execute Egate Command
  ...  ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
  Execute Egate Command  ue_history_information_list id=1 action=commit
  Execute Egate Command  ue_enb_param id=1 ue_history_list=1
  Execute Egate Command  gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3 rlc_config=5:um:size_12
  Execute Egate Command  gnb_xn_link_up gnb=3 target=2  GNB-3: XnAP Link with GNB-2

UE Register To GNB
  [Arguments]  ${ue_nr_capabilities}
  Execute Egate Command  ue_register id=1 ue_nr_capabilities=${ue_nr_capabilities}  UE now in NG RM Registered

UE PDU Session Setup
  Start RRC Log  PDU_Session_Setup
  ${ret1}=  Execute Egate Command  ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1  QoS Routing Table
  Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi 5 qfi 1
  Get RRC Log

UE PDU Session Modify to Add
  Start RRC Log  PDU_Session_Modify
  ${ret1}=  Execute Egate Command  ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=2 by=amf
  ...  pass_regexp=Received Uplink NAS Transport Message with RAN UE NGAP ID
  Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi 1 qfi 2
  Should Contain  ${ret1}  discardTimer ms150
  Get RRC Log

UE PDU Session Modify to Add_Failed
  ${ret1}=  Execute Egate Command  ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=2 by=amf
  ...  fail_regexp=rrcReconfigurationComplete
  Should Not Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi 1 qfi 2

UE PDU Session Modify to Del
  ${ret1}=  Execute Egate Command  ue_pdu_session_modify ue=1 pdu=1 qosflows_to_del=2 by=amf
  ...  rrcReconfigurationComplete
  Should Contain  ${ret1}  Removed FiveQi:Qfi mapping fiveQi 1 qfi 2

UE Deregister From GNB
  Execute Egate Command  ue_deregister id=1 ue_deregister_type=switch_off  detached

Wait A While
  Sleep  5s

Intra-frequency handover to Sim gNB
  ${ret1}=  Execute Egate Command
  ...  ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=50 srsrq_nr=30 phycell_id=48 nrsrp_nr=70 nrsrq_nr=30
  ...  rrcReconfigurationComplete
  Should Contain  ${ret1}  UE1: Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed

Intra-frequency handover to Real gNB
  Start RRC Log  HO_to_Real_gNB
  ${ret1}=  Execute Egate Command
  ...  ue_measurement_send_nr id=1 meas_id=3 event=A3 srsrp_nr=50 srsrq_nr=30 phycell_id=60 nrsrp_nr=70 nrsrq_nr=30
  ...  rrcReconfigurationComplete
  Should Contain  ${ret1}  discardTimer ms150
  Should Contain  ${ret1}  Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed
  Get RRC Log
