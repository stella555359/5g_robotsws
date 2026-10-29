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
...  NRDRB-2:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-1
...  NRDRB-2:dlFlowControlAlgo=3gppFlowControl
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
...  NRDRB_PDCP-1:pdcpBufDiscardEnabled=false
@{CB006112}
...  NRCELL-1:actEnhancedVoNR=true
...  NRBTS:tRLFindForDUVoNR=2000ms
...  NRCELL-1:n310VoNR=n20
...  NRCELL-1:t310VoNR=4000ms
...  NRDRB-3:discardTimer=150ms
...  NRDRB-3:dlFlowControlAlgo=none
...  NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm6bitSN
@{VoNR_OFF}
...  NRCELL-1:actEnhancedVoNR=false
...  NRCELL-1:actVoNR=false
@{VoNR_ON}
...  NRCELL-1:actEnhancedVoNR=true
...  NRCELL-1:actVoNR=true
${ue_nr_capabilities_C01_01}  SEPARATOR=
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
@{PM_Counters_Check}
...  NRCELL-1:NNGCC:${NG_UE_RADIO_CAP_CHK_REQ_RCVD}=5
...  NRCELL-1:NNGCC:${NG_UE_RAD_CAP_CHK_RES_SNT_VONR}=2
...  NRCELL-1:NNGCC:${NG_UE_RAD_CAP_CHK_RES_NO_VONR}=1
${NG_UE_RADIO_CAP_CHK_REQ_RCVD}  M55125C05001
${NG_UE_RAD_CAP_CHK_RES_SNT_VONR}  M55125C05002
${NG_UE_RAD_CAP_CHK_RES_NO_VONR}  M55125C05003

*** Test Cases ***
CB006112-ET-A-C01-01_Verify NGAP_UE Radio Capability Check counters
	[Tags]
  UE Register To GNB  ue_nr_capabilities=${ue_nr_capabilities_C01_01}
  AMF Trigger UE Radio Capability Check  pass_regexp=NgAP:ERROR_INDICATION
  UE PDU Session Setup_Delay_Capability Check
  AMF Trigger UE Radio Capability Check  Received UE Radio Capability Check Response with IMSVoiceSupportIndicator:SUPPORTED
  Set VoNR OFF
  AMF Trigger UE Radio Capability Check  Received UE Radio Capability Check Response with IMSVoiceSupportIndicator:NOT-SUPPORTED
  Set VoNR ON
  UE PDU Session Modify to Add
  AMF Trigger UE Radio Capability Check  Received UE Radio Capability Check Response with IMSVoiceSupportIndicator:SUPPORTED
  UE Deregister From GNB
  Check counters  ${PM_Counters_Check}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
  Common Suite Setup
  Setup Airphone Env  tl_type=fdd_sansa_cmwv/2cells  cfg=auto

Modify Cfg
  Update Cfg  set_qosflow id=1 5qi=5 default=on
  Update Cfg  set_qosflow id=3 5qi=9
  Update Cfg  set_qosflow id=2 5qi=1
  Update Cfg  set_qosrule id=1 proto=tcp qos_flow=1
  Update Cfg  set_qosrule id=2 proto=udp qos_flow=2
  Update Cfg  set_nwslice id=1 qos_flows=3,2,1 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=1-3 amf=1
  Update Cfg  ue_nr_capabilities id=1 voice_over_nr=on:on:off
  Update Cfg  amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc
  ${AutoVariable_1}  catenate  SEPARATOR=
  ...  ue_param id=1 nr_usage_setting=voice_centric ue_nr_capabilities=E5A01000074F5E13020002054004824C1800260D070062
  ...  01A0130080C450180533805506C28D608C21A08107CA0702CB64C550F027C873E819F11C78C73E618F28581C0E1E0B80027800E0009E00
  ...  078001C0E83623606B04610D04083E5038165B262A87813E439F40CF88E3C639F30C7942C0E070F05C0012C0070004B0003C000E0541B0
  ...  0B582308682041F281C092D931541439F11C78C73E618F28581C0E1E04FE0000003F80000001E0007000400E2300000000331180098500
  ...  005801A01811B639F0FD04800E040500603009401800180A00400000041C04D0001CF9863CA160607C0200400000002000004010000040
  ...  132A6F2A6B0328040800004B29282000032CA4A0800014B292004A55574AAAA81C5090058015028140000002004008520F0300C020
  Update Cfg  ${AutoVariable_1}
  Update Cfg  set_pdu_gateway id=2 ue_nat_ip=72.23.1.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
  Update Cfg  set_pdu_gateway id=3 ue_nat_ip=72.23.2.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1

UE Register To GNB
  [Arguments]  ${ue_nr_capabilities}
  Execute Egate Command  ue_register id=1 ue_nr_capabilities=${ue_nr_capabilities}
  ...  UE now in NG RM Registered

UE PDU Session Setup
  ${ret1}=  Execute Egate Command  ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1  rrcReconfigurationComplete
  Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi 5 qfi 1

UE PDU Session Modify to Add
  ${ret1}=  Execute Egate Command  ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=2 by=amf
  ...  pass_regexp=rrcReconfigurationComplete
  Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi 1 qfi 2

Set VoNR OFF
  Delta Commission Parameters    ${VoNR_OFF}

Set VoNR ON
  Delta Commission Parameters    ${VoNR_ON}

UE Deregister From GNB
  Execute Egate Command  ue_deregister id=1 ue_deregister_type=switch_off  detached

Wait A While
  Sleep  5s

AMF Trigger UE Radio Capability Check
  [Arguments]  ${pass_regexp}
  ${ret1}=  Execute Egate Command  amf_ue_trigger_radio_capability_check id=1 ue=1 gnb=2 ue_radio_capability=none
  ...  ${pass_regexp}
  Should Contain  ${ret1}  Send UE Radio Capability Check Request to GNB-2 Successful

UE PDU Session Setup_Delay_Capability Check
  Start RRC Log  PDU_Session_Setup
  Execute Egate Command  ue_nr_rrc_reconf_param id=1 if_contains=any delay=2s
  Execute Egate Command  ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1  Hit on error cases presence=any action=delay
  AMF Trigger UE Radio Capability Check  pass_regexp=NgAP:ERROR_INDICATION
  Sleep  2s  get RRC log
  rrc Should Contain  Created FiveQi:Qfi mapping fiveQi 5 qfi 1
  rrc Should Contain  rrcReconfigurationComplete
