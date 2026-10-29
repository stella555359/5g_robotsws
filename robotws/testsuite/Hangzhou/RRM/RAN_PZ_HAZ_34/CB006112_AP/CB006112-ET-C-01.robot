*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: VRF_HAZ3
Suite Setup       Common Suite Setup And Setup Airphone Env    tl_type=fdd_sansa_cmwv/2cells    match_string=${WAIT_STRINGS}
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        CA_5G_RRM    release-5G21A    tl-CLOUD_5G_I_LO_AP_LO
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
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

@{WAIT_STRINGS}
...    GNB-3: XnAP Link with GNB-2
...    GNB-4: XnAP Link with GNB-2

*** Test Cases ***
CB006112-ET-C-01_TDD Voice call reject due to number of GBR resources limits
  log to console    case1: CB006112-ET-C-01
  delta commission parameters    NRCELL-1:maxNumOfGBRBearersSA=2
  UE Register And Setup Pdu Session with 5QI5 And Modify Pdu Session With 5QI1    ue_id=1
  UE Register And Setup Pdu Session with 5QI5 And 5QI1    ue_id=2
  UE Register And Trigger VONR should fail    ue_id=3
  UE Deregister From GNB  ue_id=1,2,3
  Check counters  ${PM_Counters_Check}

  delta commission parameters    NRCELL-1:maxNumOfGBRBearersSA=10
  log to console    05288264 EDA case1: VoipState=silent if no UL VoIP package,
  log to console    VoipState=talk if UL VoIP package interval < 100ms
  # enable NRBTS/NRCELL.actUlVoNrActivityStateMonitor (NRCELL:actInternalImprovements1 bit0)
  delta commission parameters    NRCELL-1:actInternalImprovements1=4611686018427387903
  start to capture gnb ttitrace    tag=eda_case1    cell_id=1
  start to capture gnb bip log    tag=eda_case1    interface=L2Hi-L2Lo
  UE Register And Setup Pdu Session with 5QI5 And Modify Pdu Session With 5QI1    ue_id=1
  start UL voice packet with interval of voice packet less than 100ms    ue_id=1
  stop to capture gnb bip log    tag=eda_case1
  ${ttitrace_log_path}    stop capture gnb ttitrace   tag=eda_case1   decode_flag=True
  ${voipState_act}    get_csv_columns    ${ttitrace_log_path}/format_ttiTrace_ul.csv    voipState    type=voipStateData
  @{voipState_exp}    create list    SILENT    SILENT    TALK
  lists should be equal    ${voipState_act}    ${voipState_exp}

  log to console    05288264 EDA case2: VoipState=silent if UL VoIP package interval > 100ms
  delta commission parameters    NRCELL-1:actInternalImprovements1=4611686018427387903
  start to capture gnb ttitrace    tag=eda_case2    cell_id=1
  UE Register And Setup Pdu Session with 5QI5 And 5QI1    ue_id=2
  start ul voice packet with interval of voice packet larger than 100ms    ue_id=2
  ${ttitrace_log_path}    stop capture gnb ttitrace   tag=eda_case2   decode_flag=True
  ${voipState_act}    get_csv_columns    ${ttitrace_log_path}/format_ttiTrace_ul.csv    voipState    type=voipStateData
  @{voipState_exp}    create list    SILENT    SILENT
  run keyword and continue on failure    lists should be equal    ${voipState_act}    ${voipState_exp}

  log to console    05288264 EDA case3: VoipState=unknown if no UL VoIP package,
  log to console    VoipState=silent if UL VoIP package interval > 100ms
  # disable NRBTS/NRCELL.actUlVoNrActivityStateMonitor (NRCELL:actInternalImprovements1 bit0)
  delta commission parameters    NRCELL-1:actInternalImprovements1=4611686018427387902
  start to capture gnb ttitrace    tag=eda_case3    cell_id=1
  UE Register And Setup Pdu Session with 5QI5 And Modify Pdu Session With 5QI1    ue_id=3
  start UL voice packet with interval of voice packet larger than 100ms    ue_id=3
  ${ttitrace_log_path}    stop capture gnb ttitrace   tag=eda_case3   decode_flag=True
  ${voipState_act}    get_csv_columns    ${ttitrace_log_path}/format_ttiTrace_ul.csv    voipState    type=voipStateData
  @{voipState_exp}    create list    UNKNOWN    TALK    SILENT
  lists should be equal    ${voipState_act}    ${voipState_exp}

  log to console    05288264 EDA case4: VoipState=talk if UL VoIP package interval < 100ms
  delta commission parameters    NRCELL-1:actInternalImprovements1=4611686018427387902
  start to capture gnb ttitrace    tag=eda_case4    cell_id=1
  start to capture gnb bip log    tag=eda_case4    interface=L2Hi-L2Lo
  UE Register And Setup Pdu Session with 5QI5 And 5QI1    ue_id=4
  start ul voice packet with interval of voice packet less than 100ms    ue_id=4
  stop to capture gnb bip log    tag=eda_case4
  ${ttitrace_log_path}    stop capture gnb ttitrace   tag=eda_case4   decode_flag=True
  ${voipState_act}    get_csv_columns    ${ttitrace_log_path}/format_ttiTrace_ul.csv    voipState    type=voipStateData
  @{voipState_exp}    create list    UNKNOWN    TALK
  lists should be equal    ${voipState_act}    ${voipState_exp}

*** Keywords ***
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
  Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
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

Qosflow_modify
  [Arguments]  ${qos_flow}=1  ${ue_id}=1
  Execute Egate Command  qosflow_modify default=on qos_flow=${qos_flow} ue=${ue_id}

UE PDU Session Setup with Multi Qosflow
  [Arguments]  ${additional_qosflows_to_activate}=2  ${fiveQi_1}=5  ${fiveQi_2}=1  ${ue_id}=1    ${pdu}=1
  Execute Egate Command  smf_param id=1 reset
  Execute Egate Command  smf_param id=1 additional_qosflows_to_activate=${additional_qosflows_to_activate}
  Execute Egate Command  set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
  ${ret1}=  Execute Egate Command  ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=1 gw=${ue_id}
  ...  pass_regexp=QoS Routing Table
  Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi ${fiveQi_1} qfi 1
  Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi ${fiveQi_2} qfi 2
  Execute Egate Command  smf_param id=1 reset

UE Register And Setup Pdu Session with 5QI5 And Modify Pdu Session With 5QI1
    [Arguments]    ${ue_id}
    UE Register To GNB    ${ue_id}
    UE PDU Session Setup    ${ue_id}
    UE PDU Session Modify to Add    ${ue_id}

UE Register And Setup Pdu Session with 5QI5 And 5QI1
    [Arguments]    ${ue_id}
    UE Register To GNB  ue_id=${ue_id}
    UE PDU Session Setup with Multi Qosflow  ue_id=${ue_id}  additional_qosflows_to_activate=2

UE Register And Trigger VONR should fail
  [Arguments]    ${ue_id}
  UE Register To GNB  ${ue_id}
  UE PDU Session Setup  ${ue_id}
  UE PDU Session Modify to Add_Failed  ${ue_id}

start UL voice packet with interval of voice packet larger than 100ms
    [Arguments]    ${ue_id}
#    execute egate command    trf_data_start ue=${ue_id} pdu=1 qfi=2 dir=ul trf_id=1 period_ms=120 burst=1    Started Uplink Internal traffic
    execute egate command    trf_data_start ue=${ue_id} pdu=1 qfi=2 dir=ul trf_id=1 period_ms=240 burst=1    Started Uplink Internal traffic
    sleep    5s
    execute egate command    ue_stats_nr id=${ue_id} scell=0-7 type=pusch    EGATE>

start UL voice packet with interval of voice packet less than 100ms
    [Arguments]    ${ue_id}
    execute egate command    trf_data_start ue=${ue_id} pdu=1 qfi=2 dir=ul trf_id=1 period_ms=50 burst=1    Started Uplink Internal traffic
    sleep    5s
    execute egate command    ue_stats_nr id=${ue_id} scell=0-7 type=pusch    EGATE>
