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
...  @{InactivityTimer}
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
...  NRDRB_5QI-4:fiveqiValueList=129
...  NRDRB_5QI-4:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...  NRDRB_5QI-5:fiveqiValueList=254
...  NRDRB_5QI-5:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
@{CB006112}
...  NRCELL-1:actEnhancedVoNR=true
...  NRBTS:tRLFindForDUVoNR=2000ms
...  NRCELL-1:n310VoNR=n20
...  NRCELL-1:t310VoNR=4000ms
...  NRDRB-3:discardTimer=150ms
...  NRDRB-3:dlFlowControlAlgo=none
...  NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm6bitSN
@{InactivityTimer}
...  NRBTS:activityNotificationLevelSA=drb
...  NRBTS:drbInactivityTimerSA=30
...  NRBTS:drbInactivityTimerSA5qi1=90
...  NRBTS:drbInactivityTimerSA5qi5=60
...  NRBTS:srbInactivityTimerSA=30
${ue_nr_capabilities}  SEPARATOR=
...    E9A09000575F5A13160003C2A002C1262E003387A0E026C830E7CC31E50B03826010188E01F71B0A303582308682041D207036B64C558D0E7C471E819F604F8C48E3C
...    873EA39F30C7942C0E070F05C0017C0070005F0003C000E0741B13703582308682041D207032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB02F8
...    00FEC0BE00078001C0A836236B04610D04083C40E0656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F0000001FC0000000F000381506C41D608C21A
...    08107881C0CAD931562439F604F88E3C62471E439F51CF9863CA1607038784FE0555553F81555541E0007001940E230200000902A0E0A00E230000010902B0F0A0003
...    08C00020902B070A0200018083AC3C28000C1400010041D40E20820005090200E0234028800101042C04303409DB1CF870A74ED8E7C3851276C73E1C089B1CF870A24
...    ED8E7C3813B639F0C1E8260078005038280381804A00E000C0480080C07C120040000000200000401000000008000010040000100200000C010000080080000500400
...    2008020080000600400003802001000000040000400200002401000806018020000280100001600800409024010000180672A6B2A6B052B032B066B056B296B266B01
...    6B036B012B022B07681A0800004B29282000032CA4A0800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA480800044B29202000132CA
...    480800054B29202000172CA4A0800064B29202000062CA480629555D2AAAA55174AA2A82C55038AA0D154A62A93455018AA051549AAA83C5090178095028140A05028
...    140A05028140A05028140A0502814001400203C030404008000100C0182020040100806000001018008202004010080100000101E0186A87C0004080C10181C282C30
...    344044484C5060646C70747C8494989CA0A4A8B4BD05041E06018040
@{parameters_1}
...  NRDRB-2:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-1
...  NRDRB-2:resType=nonGBR

*** Test Cases ***
CB006112-A-B2-01_ET_Verify FDD IMS Signaling will not release before 5qi5drbInactivityTimerSA expries
	[Tags]
  UE Register To GNB  ue_nr_capabilities=${ue_nr_capabilities}
  UE PDU Session Setup
  Wait A While  InactivityTimer=62s
  UE Deregister From GNB
  Check Wireshark Log  ${CURDIR}${/}a2a_CB006112-A-B2-01${/}a2a.ini

CB006112-A-B4-01_ET_FDD Initial Context Setup with mutiple PDU sessions without UE Radio Capability with 5QI-5 setup
	[Tags]
  UE Register To GNB  ue_nr_capabilities=${ue_nr_capabilities}
  PDU Session Setup with Multi Qosflow
  UE PDU Session Modify to Add  qfi=qfi 3
  Wait A While  InactivityTimer=92s
  UE Deregister From GNB
  Check RRC Log  ${CURDIR}${/}a2a_CB006112-A-B4-01${/}a2a.ini
  Check Wireshark Log  ${CURDIR}${/}a2a_CB006112-A-B4-01${/}a2a.ini

CB006112-A-B10-03_ET_FDD check Initial Context Setup with one or multiple PDU sessions without UE Radio Capability with 5QI-129 setup
	[Tags]
  Delta Commission Parameters    ${parameters_1}
  UE Register To GNB  ue_nr_capabilities=${ue_nr_capabilities}
  PDU Session Setup with Multi Qosflow  additional_qosflows_to_activate=4  fiveQi_2=129
  UE PDU Session Setup  pdu=2  gw=2  fiveQi=254  qos_flow_change=5
  UE Deregister From GNB
  Check RRC Log  ${CURDIR}${/}a2a_CB006112-A-B10-03${/}a2a.ini

*** Keywords ***
Common Suite Setup And Setup Airphone Env
  Common Suite Setup
  Setup Airphone Env  tl_type=fdd_sansa_cmwv/2cells

Modify Cfg
  Update Cfg  set_qosflow id=1 5qi=5 default=on
  Update Cfg  set_qosflow id=3 5qi=9
  Update Cfg  set_qosflow id=2 5qi=1
  Update Cfg  set_qosflow id=4 5qi=129
  Update Cfg  set_qosflow id=5 5qi=254
  Update Cfg  set_qosrule id=1 proto=tcp qos_flow=1
  Update Cfg  set_qosrule id=2 proto=udp qos_flow=2
  Update Cfg  set_nwslice id=1 qos_flows=5,4,3,2,1 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=1-3 amf=1
  Update Cfg  ue_nr_capabilities id=1 voice_over_nr=on:on:off
  Update Cfg  amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc
  ${AutoVariable_1}  catenate  SEPARATOR=
  ...  ue_param id=1 nr_usage_setting=voice_centric ue_nr_capabilities=E5A01000074F5E1302000201404824C1800260D0301880
  ...  6804C0203114020299C02A836146B04610D04083E5008B2D931543C09F21CFA067C471E31CF9863CA1607038782E0009E003800278000A
  ...  00E0741B13703582308682041F2804596C98AA1E04F90E7D033E238F18E7CC31E50B0381C3C170004B001C0012C000500702A0D88DAC11
  ...  84341020F940224B64C55050E7C471E31CF9863CA16070387813F8000000FE00000002803800200713400000002989A004C28002623000
  ...  0A034030236C73E1FA05007020080C0600A80C000C0500200000020609A00039F30C7942C0C0F804008000000040000080200000802654
  ...  DE54D606500810000096525040000659494100002965240094AAAE95555038A020B002A050280000004008010A41E0203008
  Update Cfg  ${AutoVariable_1}
  Update Cfg  set_pdu_gateway id=2 ue_nat_ip=72.23.1.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
  Update Cfg  set_pdu_gateway id=3 ue_nat_ip=72.23.2.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1

UE Register To GNB
  [Arguments]  ${ue_nr_capabilities}
  Execute Egate Command  ue_register id=1 ue_nr_capabilities=${ue_nr_capabilities}
  ...  UE now in NG RM Registered

UE PDU Session Setup
  [Arguments]  ${ue_id}=1  ${pdu}=1  ${gw}=1  ${fiveQi}=5  ${qos_flow_default}=1  ${qos_flow_change}=1
  Start RRC Log  PDU_Session_Setup
  Execute Egate Command  qosflow_modify default=on qos_flow=${qos_flow_change} ue=${ue_id}
  ${ret1}=  Execute Egate Command  ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=1 gw=${gw}
  ...  QoS Routing Table
  Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi ${fiveQi} qfi 1
  Execute Egate Command  qosflow_modify default=on qos_flow=1 ue=${ue_id}
  Get RRC Log

UE PDU Session Modify to Add
  [Arguments]  ${qfi}=qfi 2
  Start RRC Log  PDU_Session_Modify
  ${ret1}=  Execute Egate Command  ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=2 by=amf  QoS Routing Table
  Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi 1 ${qfi}
  Should Contain  ${ret1}  discardTimer ms150
  Get RRC Log

UE PDU Session Modify to Del
  ${ret1}=  Execute Egate Command  ue_pdu_session_modify ue=1 pdu=1 qosflows_to_del=2 by=amf
  ...  rrcReconfigurationComplete
  Should Contain  ${ret1}  Removed FiveQi:Qfi mapping fiveQi 1 qfi 2

UE Deregister From GNB
  Execute Egate Command  ue_deregister id=1 ue_deregister_type=switch_off  detached

Wait A While
  [Arguments]  ${InactivityTimer}
  Start RRC Log  rrcRelease
  Sleep  ${InactivityTimer}  wait for UE inactivity
  rrc Should Contain  rrcRelease
  rrc Should Contain  UE1: IS IDLE

PDU Session Setup with Multi Qosflow
  [Arguments]  ${additional_qosflows_to_activate}=3  ${fiveQi_1}=5  ${fiveQi_2}=9  ${ue_id}=1  ${gw}=1
  ...  ${pdu}=1
  Start RRC Log  PDU_Session_Setup_with_Multi_Qosflow
  Execute Egate Command  smf_param id=1 reset
  Execute Egate Command  smf_param id=1 additional_qosflows_to_activate=${additional_qosflows_to_activate}
  ${ret1}=  Execute Egate Command  ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=1 gw=${gw}
  ...  QoS Routing Table
  Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi ${fiveQi_1} qfi 1
  Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi ${fiveQi_2} qfi 2
  Execute Egate Command  smf_param id=1 reset
  Get RRC Log
