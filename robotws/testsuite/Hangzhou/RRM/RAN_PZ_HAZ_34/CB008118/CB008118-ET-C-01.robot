*** Settings ***
Documentation
...    author: Song Jiana
...    contact: jiana.song@nokia.com
...    squad group: VRF_HAZ_T03
Suite Setup       Common Suite Setup And Setup RJIO Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        CA_5G_RRM    release-5G21A    tl-CLOUD_5G_I_E_AP_LOOO
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/Module/Log_Analysis.robot
*** Variables ***
${Added_5QI1_Success}
...    Added QosFlow with QFI:4 5QI:1
${Setup_5QI5_Success}
...    Setup QosFlow with QFI:1 5QI:5
${Added_5QI5_Success}
...    Added QosFlow with QFI:3 5QI:5
${Setup_5QI7_Success}
...    Setup QosFlow with QFI:1 5QI:7
${Setup_5QI9_Success}
...    Setup QosFlow with QFI:1 5QI:9
${Added_5QI65_Success}
...    Added QosFlow with QFI:2 5QI:65
${Added_5QI66_Success}
...    Added QosFlow with QFI:2 5QI:66
${Setup_5QI65_Success}
...    Setup QosFlow with QFI:1 5QI:65
${Setup_5QI69_Success}
...    Setup QosFlow with QFI:1 5QI:69
${TC16_Setup_5QI70_Success}
...    Setup QosFlow with QFI:1 5QI:70
${TC16_Added_5QI69_Success}
...    Added QosFlow with QFI:2 5QI:69
${TC16_Added_5QI65_Success}
...    Added QosFlow with QFI:3 5QI:65
${Remove_5QI65_Success}
...    Deleting QosFlow with QFI:2 5QI:65
${Added_5QI9_Success}
...    Added QosFlow with QFI:2 5QI:9
${ROHC_maxCID}
...    maxCID 4
${DRX_5QI69}
...    drx-LongCycleStartOffset ms160
${DRX_5QI65}
...    drx-LongCycleStartOffset ms40
&{dcap_info}    host=127.0.0.1    port=9443    username=${None}    password=${None}
@{FAULTS_EXCLUDED_CHECKING}    7529     4282
*** Test Cases ***
USCB008118-C_IWK1_TC01
    [Tags]    QC_181445       QCD_MN_RAN      QCP_RAN_VRF
  # delta commission parameters    NRCELL-1:maxNumOfGBRBearersSA=10
  log to console    05288264 EDA case1: VoipState=silent if no UL CQI65 package,
  log to console    VoipState=talk if UL VoIP package interval < 100ms
  # enable NRBTS/NRCELL.actUlVoNrActivityStateMonitor (NRCELL:actInternalImprovements1 bit0)
  delta commission parameters    NRCELL-1:actInternalImprovements1=4611686018427387903
  UE Deregister From gNB      ue_id=1
  start to capture gnb ttitrace    tag=case1    cell_id=1
  Establish mcs-PriorityAccess    ue_id=1
  UE Register And PDU Session Setup   ue_id=1   qos_flow=19   pass_regexp=${Setup_5QI69_Success}
  UE Modify new PDU    ue_id=1    pdu=1    qosflows_to_add=15    pass_regexp=${ROHC_maxCID}
  start UL voice packet with interval of voice packet less than 100ms    ue_id=1
  ${ttitrace_log_path}    stop capture gnb ttitrace   tag=case1   decode_flag=True
  ${voipState_act}    get_csv_columns    ${ttitrace_log_path}/format_ttiTrace_ul.csv    voipState    type=voipStateData
  @{voipState_exp}    create list    SILENT    TALK
  lists should be equal    ${voipState_act}    ${voipState_exp}
  log to console    05288264 EDA case2: VoipState=silent if UL VoIP package interval > 100ms
  delta commission parameters    NRCELL-1:actInternalImprovements1=4611686018427387903
  start to capture gnb ttitrace    tag=case2    cell_id=1
  UE Deregister From gNB      ue_id=1
  Establish mcs-PriorityAccess    ue_id=1
  UE Register And PDU Session Setup   ue_id=1   qos_flow=19   pass_regexp=${Setup_5QI69_Success}
  UE Modify new PDU    ue_id=1    pdu=1    qosflows_to_add=15    pass_regexp=${ROHC_maxCID}
  start UL voice packet with interval of voice packet larger than 100ms    ue_id=1
  ${ttitrace_log_path2}    stop capture gnb ttitrace   tag=case2   decode_flag=True
  ${voipState_act2}    get_csv_columns    ${ttitrace_log_path2}/format_ttiTrace_ul.csv    voipState    type=voipStateData
  @{voipState_exp2}    create list    SILENT
  lists should be equal    ${voipState_act2}    ${voipState_exp2}
  UE Deregister From gNB      ue_id=1

*** Keywords ***
Common Suite Setup And Setup RJIO Env
    Update bsr package
    Common Suite Setup And Setup Airphone Env    tl_type=tddfdd_sansa_cmwv/RJIO    cfg=wts.cfg

Update bsr package
    Run     sshpass -p 'Ut3pa5s#ff97' scp ute@10.56.218.196:/home/ute/BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip /home/ute/
    ${dllink}   Set Variable     https://artifactory-espoo1.int.net.nokia.com/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_4_H4_ALN30_ARP30_P00_6TO4_60_00421_00001.zip
    Run     wget ${dllink}/${filename} -P /home/ute
    coam.setup admin
    ${ret}    coam.Update Software    /home/ute/${filename}
    coam.teardown admin

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
    Execute Egate Command  ue_deregister id=${ue_ids} ue_deregister_type=switch_off
  END

Qosflow_modify
  [Arguments]  ${qos_flow}=1  ${ue_id}=1
  Execute Egate Command  qosflow_modify default=on qos_flow=${qos_flow} ue=${ue_id}

UE PDU Session Setup with Multi Qosflow
  [Arguments]  ${additional_qosflows_to_activate}=2  ${fiveQi_1}=5  ${fiveQi_2}=1  ${ue_id}=1    ${pdu}=1
  Execute Egate Command  smf_param id=1 reset
  Execute Egate Command  smf_param id=1 additional_qosflows_to_activate=${additional_qosflows_to_activate}
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
    # execute egate command    trf_data_start ue=${ue_id} pdu=1 qfi=2 dir=ul trf_id=1 period_ms=120 burst=1    EGATE>
    execute egate command    trf_data_start ue=${ue_id} pdu=1 qfi=2 dir=ul trf_id=1 period_ms=240 burst=1    EGATE>
    sleep    3s
    execute egate command    ue_stats_nr id=1 scell=0-7 type=pusch

start UL voice packet with interval of voice packet less than 100ms
    [Arguments]    ${ue_id}
    execute egate command    trf_data_start ue=${ue_id} pdu=1 qfi=2 dir=ul trf_id=1 period_ms=50 burst=1    EGATE>
    sleep    5s
    execute egate command    ue_stats_nr id=${ue_id} scell=0-7 type=pusch

Establish mcs-PriorityAccess
    [Arguments]    ${ue_id}=1
    execute egate command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=mcs-PriorityAccess

UE Register And PDU Session Setup
    [Arguments]    ${ue_id}=1    ${qos_flow}=5    ${pdu}=1    ${nwslice}=1    ${pass_regexp}=QoS Routing Table
    execute egate command    ue_register id=${ue_id}
    sleep   1s
    execute egate command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal default_qos_flow=${qos_flow}
    sleep   1s
    execute egate command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=${nwslice} gw=1    pass_regexp=${pass_regexp}

UE Modify new PDU
    [Arguments]    ${ue_id}=1    ${pdu}=1   ${qosflows_to_add}=65   ${pass_regexp}=QoS Routing Table
    execute egate command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qosflows_to_add} by=amf
    ...    pass_regexp=${pass_regexp}
    sleep    1s

Send GBR Throughput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1
    execute egate command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl trf_id=3 protocol=tcp mbps=1 seconds=600
    ...    pass_regexp=UE ${ue_id}: TCP DL
    execute egate command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul trf_id=4 protocol=tcp mbps=1 seconds=600
    ...    pass_regexp=UE ${ue_id}: TCP UL

Stop GBR Throughput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1
    execute egate command    trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl trf_id=3
#    ...    pass_regexp=UE ${ue_id}: TCP DL
    execute egate command    trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul trf_id=4
#    ...    pass_regexp=UE ${ue_id}: TCP UL

Verify Throuput on Pcell
    [Arguments]    ${ue_id}=1    ${pcell_dl}=0    ${ul}=0    ${pdu_id}=1
     sleep    10s    #sleep for stable traffic
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000>${pcell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=2    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}