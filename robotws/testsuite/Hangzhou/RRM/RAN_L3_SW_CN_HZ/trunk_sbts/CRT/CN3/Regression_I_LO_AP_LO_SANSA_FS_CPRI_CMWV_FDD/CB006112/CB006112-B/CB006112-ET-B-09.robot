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
@{CB006112}
...  NRCELL-1:actEnhancedVoNR=true
...  NRBTS:tRLFindForDUVoNR=2000ms
...  NRCELL-1:n310VoNR=n20
...  NRCELL-1:t310VoNR=4000ms
...  NRDRB-3:discardTimer=150ms
...  NRDRB-3:dlFlowControlAlgo=none
...  NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm6bitSN
${MaxNumDedicatedBearer}  0x66001f
@{PARAMS_IN_SWCONFIG}  ${MaxNumDedicatedBearer}=2

${ue_nr_capabilities}  SEPARATOR=
...  E5A01000074F5E13020002054004824C1800260D07006201A0130080C450180533805506C28D608C21A08107CA0702CB64C550F027C873E819F
...  11C78C73E618F28581C0E1E0BF8000000FE000000078001C0E83623606B04610D04083E5038165B262A87813E439F40CF88E3C639F30C7942C0
...  E070F05FC0000007F00000003C000E0541B00B582308682041F281C092D931541439F11C78C73E618F28581C0E1E04FE0000003F80000001E00
...  07000400E2300000000331180098500005801A01811B639F0FD04800E040500603009401800180A00400000041C04D0001CF9863CA160607C02
...  00400000002000004010000040132A6F2A6B0328040800004B29282000032CA4A0800014B292004A55574AAAA81C50900580150281400000020
...  0C018520F0300C020

*** Test Cases ***
CB006112-ET-B-09_TDD when MaxNumDedicatedBearer reached configure 5QI-1 and 5QI-5 DRBs with lowest bearer group index
	[Tags]
  UE-1 attach to gNB
  UE-2 attach to gNB
  UE-3 attach to gNB
  UE-4 attach to gNB
  UE Deregister From GNB  ue_id=1,2,3,4
  Check Wireshark Log  ${CURDIR}/a2a_CB006112-ET-B-09/a2a.ini

*** Keywords ***
Common Suite Setup And Setup Airphone Env
  Common Suite Setup
  Setup Airphone Env  tl_type=fdd_sansa_cmwv/2cells

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
  ...  ue_param id=1-5 nr_usage_setting=voice_centric ue_nr_capabilities=E5A01000074F5E1302000201404824C1800260D0301880
  ...  6804C0203114020299C02A836146B04610D04083E5008B2D931543C09F21CFA067C471E31CF9863CA1607038782E0009E003800278000A00
  ...  E0741B13703582308682041F2804596C98AA1E04F90E7D033E238F18E7CC31E50B0381C3C170004B001C0012C000500702A0D805AC118434
  ...  1020F940224B64C55050E7C471E31CF9863CA16070387813F8000000FE00000002803800200713400000001989A004C280001406806046D8
  ...  E7C3F40A00E04010180C01501800180A00400000040C13400073E618F2858181F008010000000080000100400001004CA9BCA9AC0CA01020
  ...  00012CA4A080000CB29282000052CA480129555D2AAAA0714041600540A0500000008010021483C0406010
  Update Cfg  ${AutoVariable_1}
  Update Cfg  set_pdu_gateway id=2 ue_nat_ip=72.23.1.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
  Update Cfg  set_pdu_gateway id=3 ue_nat_ip=72.23.2.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
  Update Cfg  set_pdu_gateway id=4 ue_nat_ip=72.23.3.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
  ${AutoVariable_2}  catenate
  ...  set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x24:22 daemon=10.0.2.1:22222 x2_peers=none
  ...  xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
  Update Cfg  ${AutoVariable_2}
  Update Cfg  set_cell id=1 gnb=3 pci=16:0 tac=788 nrci=0x01 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=126380:126380 gscn=1579
  Update Cfg  gnb_param id=3 xn_listening_socket=1 send_xn_setup=false
  ${AutoVariable_3}  catenate
  ...  set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
  ...  nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645401 mode=nr enb=2 cell=1
  ${AutoVariable_4}  catenate
  ...  set_ue simulated id=3 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
  ...  nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645402 mode=nr enb=2 cell=1
  ${AutoVariable_5}  catenate
  ...  set_ue simulated id=4 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
  ...  nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645403 mode=nr enb=2 cell=1
  Update Cfg  ${AutoVariable_3}
  Update Cfg  ${AutoVariable_4}
  Update Cfg  ${AutoVariable_5}  
  
UE Register To GNB
  [Arguments]  ${ue_id}=1
  Execute Egate Command  ue_register id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}
  ...  UE now in NG RM Registered

UE PDU Session Setup
  [Arguments]  ${ue_id}=1  ${pdu}=1  ${gw}=1  ${fiveQi}=5
  ${ret1}=  Execute Egate Command  ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=1 gw=${gw}  QoS Routing Table
  Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi ${fiveQi} qfi 1

UE PDU Session Modify to Add
  [Arguments]  ${ue_id}=1  ${pdu}=1
  ${ret1}=  Execute Egate Command  ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=2 by=amf
  ...  pass_regexp=QoS Routing Table
  Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi 1 qfi 2
  Should Contain  ${ret1}  discardTimer ms150

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
  Start RRC Log  PDU_Session_Setup_with_Multi_Qosflow
  Execute Egate Command  smf_param id=1 reset
  Execute Egate Command  smf_param id=1 additional_qosflows_to_activate=${additional_qosflows_to_activate}
  ${ret1}=  Execute Egate Command  ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=1 gw=${gw}  QoS Routing Table
  Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi ${fiveQi_1} qfi 1
  Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi ${fiveQi_2} qfi 2
  Execute Egate Command  smf_param id=1 reset
  Get RRC Log

UE-1 attach to gNB
  UE Register To GNB  ue_id=1
  Qosflow_modify  qos_flow=3  ue_id=1
  UE PDU Session Setup  fiveQi=9

UE-2 attach to gNB
  UE Register To GNB  ue_id=2
  UE PDU Session Setup  ue_id=2  gw=2
  UE PDU Session Modify to Add  ue_id=2

UE-3 attach to gNB
  UE Register To GNB  ue_id=3
  UE PDU Session Setup with Multi Qosflow  additional_qosflows_to_activate=2  gw=3  ue_id=3

UE-4 attach to gNB
  UE Register To GNB  ue_id=4
  UE PDU Session Setup with Multi Qosflow  additional_qosflows_to_activate=3  gw=4  ue_id=4  fiveQi_2=9
