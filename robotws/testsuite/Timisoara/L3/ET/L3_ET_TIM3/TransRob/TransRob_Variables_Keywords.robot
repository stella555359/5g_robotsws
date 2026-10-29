*** Settings ***
Library     taf.config.wts        WITH NAME    wts_conf
Variables    ./config/variables.py

*** Variables ***
${custom-scf}    ${CURDIR}/../resources/custom-config/2_CELLS_SANSA_TDD_inter-gNB_HO/2_CELLS_SANSA_TDD_inter-gNB_HO.xml
${custom-iphy}   ${CURDIR}/../resources/custom-config/2_CELLS_SANSA_TDD_inter-gNB_HO/iphy.xml
#${endmarker}     Received  by UPF from source gNb through the forwarding tunnel

*** Keywords ***
Start UTE eth3 interfaces
    Log To Console  \n===configure IPs on PC ===
    OperatingSystem.Run  sudo ip addr add 10.0.2.1/24 dev eth4
    Log  10.0.1.121~155 is configured for your use  console=yes
    FOR  ${number}  IN RANGE  121  156
        OperatingSystem.Run  sudo ip addr add 10.0.1.${number}/24 dev eth3
    END
    Log  proxy server ip is 10.0.2.80  console=yes
    Log  10.0.2.90~100 is configured for more proxy servers  console=yes
    FOR  ${number}  IN RANGE  90  101
        OperatingSystem.Run  sudo ip addr add 10.0.2.${number}/24 dev eth4
    END
    Log  AMF ip is 10.0.1.1  console=yes
    Log  10.0.1.9~15 10.0.1.100~10.0.1.109 is configured for you to set more AMFs  console=yes
    FOR  ${number}  IN RANGE  9  16
        OperatingSystem.Run  sudo ip addr add 10.0.1.${number}/24 dev eth3
    END
    FOR  ${number}  IN RANGE  100  110
        OperatingSystem.Run  sudo ip addr add 10.0.1.${number}/24 dev eth3
    END
    OperatingSystem.Run  ip addr show eth3
    OperatingSystem.Run  ip addr show eth4


Add UE History Information List
    Execute Egate Command
    ...    cmd=ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command
    ...    cmd=ue_history_information_list_add_ngran id\=1 cell_type\=large nrcgi\=311:489|0x01 gnb_id\=3 time_ue_stayed_in_cell\=98
    Execute Egate Command    cmd=ue_history_information_list id=1 action=commit
    Execute Egate Command    cmd=ue_enb_param id=1 ue_history_list=1
    Execute Egate Command    cmd=gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3

Register UE And Check A2 MeasConfig
#    Start RRC Log     Check_A2_MeasConfig
    Execute Egate Command    cmd=ue_register id=1    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command    cmd=ue_pdu_session_setup ue=1 pdu=1 gw=1 nwslice=1    pass_regexp=QoS Routing Table
#    Check RRC log    ${CURDIR}${/}a2a_CIT024${/}Check_A2_MeasConfig.ini

UE Triggers Inter-Frequency Inter-gNB HO and Check MeasGap Setup
    Execute Egate Command    cmd=data_trf_start ue=1 pdu=1 qfi=1 dir=dl trf_id=4 mbps=10    pass_regexp=UE 1: UDP DL
    Execute Egate Command    cmd=data_trf_start ue=1 pdu=1 qfi=1 dir=ul trf_id=5 mbps=10    pass_regexp=UE 1: UDP UL
    Send A2 MR And Check MeasGap Setup
    Send RRC Reconfiguration invalid payload
    Send A3 MR Then HO
#    Verify Throughput

UE HO back from sim_gNB and check MeasGap Release
    ${cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=50    nrsrp_nr=30 nrsrq_nr=30
    ...    rs_type=ssb index=0 nrs_result=30:30:30
    ${meas_gap_release}=    Execute Egate Command    cmd=${cmd}    pass_regexp=Inter-eNB handover
    ${tmp_log}=    Remove Blank Character    ${meas_gap_release}
    Should Contain    ${tmp_log}    spCellConfigCommon{physCellId50
    Should Contain    ${tmp_log}    cfra
    Should Contain    ${meas_gap_release}    gapUE release : NULL

Verify Throughput
    [Documentation]    verify Tput in scell is not 0
    [Arguments]    ${Tput_dl}=9    ${Tput_ul}=9    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=1 scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Stop and Analyze wireshark log
    Check Wireshark Log     ${CURDIR}${/}a2a_CIT024${/}Check_HO.ini    wait_string=PathSwitchRequestAcknowledge
    BuiltIn.Log To Console    Wirshark check is done

Analyze PM Counters
    Check Counters    ${PM_Counters_Check_CIT024}
    BuiltIn.Log To Console    PM check is done

Ue_Deregister_With Traffic_Stop_And_Pdu_Session_Release
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1    pass_regexp=Stopped Downlink Internal traffic on Ue:1 UpfId:1 Pdu:1 Qfi:1 TrfId:4
    Execute Egate Command    cmd=ue_pdu_session_release ue=1 pdu=1    pass_regexp=Successfully released PDU Session
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off    pass_regexp=UE CONTEXT RELEASE COMPLETE

Teardown Of Ue Deregister
    Ue_Deregister_With Traffic_Stop_And_Pdu_Session_Release
    Common Test Teardown And Stop Capture Logs

Send A3 MR Then HO
    ${cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=4 event=A3 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=381 nrsrp_nr=30 nrsrq_nr=30
    ...    rs_type=ssb index=0 nrs_result=30:30:30
    ${ho_log}=    Execute Egate Command    cmd=${cmd}    pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    ${ho_log}    Remove Blank Character    ${ho_log}
    Should Contain    ${ho_log}    spCellConfigCommon{physCellId381
    sleep    15s    #wait for be stable

Remove Blank Character
    [Arguments]    ${str}
    ${str}=    Remove String    ${str}    ${SPACE}
    ${str}=    Remove String    ${str}    \r\n
    ${str}=    Remove String    ${str}    \n
    ${str}=    Remove String    ${str}    \x1b[K
    [Return]    ${str}

Send A2 MR And Check MeasGap Setup
    ${A2_egate_log}=    Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=1 event=A2 srsrp_nr=11 srsrq_nr=11    pass_regexp=eventA3
    Should Contain    ${A2_egate_log}    gapOffset 8
    Should Contain    ${A2_egate_log}    mgl ms3
    Should Contain    ${A2_egate_log}    mgrp ms160
    Should Contain    ${A2_egate_log}    mgta ms0dot5

Send RRC Reconfiguration invalid payload
    Execute Egate Command  cmd=ue_nr_rrc_reconf_param id=1 if_contains=any action=send_hex hex=${RRC_RECONFIGURATION_PAYLOAD}

Prepare Preconditions
    Find Scfc and Send Delta Commissioning    scfc_filename=CB005876_IRAT.json
    Find Scfc and Send Delta Commissioning    scfc_filename=CNI-86916.json
    Prepare WTS Config
    Reach Onair             lua_cfg=/opt/iphy/latest/basic_setup_5876_new.cfg     check_edaemon_port=True
    Execute Egate Command   cmd=amf_timer T_Local=1000
    Execute Egate Command   cmd=amf_timer T_NotifyProcessing=500
    Execute Egate Command   cmd=upf_param id=1 end_markers_delay=500

Prepare WTS Config
    wts_conf.load_wts_cfg    file_path=/opt/iphy/latest/basic_setup.cfg
    FOR   ${command}        IN
    ...   set_enb id=1
    ...   enb_param id=1
    ...   set_cell id=1 enb=1
    ...   enb_endc_param id=1
    ...   mme_pool_area id=1
    ...   set_mme id=1
    ...   set_sgw id=1
    ...   set_pgw id=1
          wts_conf.delete   ${command}
    END
    wts_conf.insert    set ENB1_S1U_ADDR="10.0.1.136"  before  set_amf_region id=1
    wts_conf.modify    set_amf_region id=1     modification=tac_list=7627107,100,788,0,222,200
    wts_conf.modify    amf_param id=1          modification=indirect_data_forwarding=on ims_voice_3gpp=on
    wts_conf.modify    set_cell id=1 gnb=2    modification=tac=0
    wts_conf.insert    set_gnb id=1 type=simulated plmn=311:489 ng=$ENB1_S1_ADDR daemon=$SERVER_IP:$DAEMON_PORT gnb_id=0x12:28 nssai=0x01:0xD143A5
    ...  after  set_cell id=1 gnb=2
    wts_conf.insert    set_cell id=1 gnb=1 pci=3:2 earfcn=1:18001 tac=222 proxy=$SERVER_IP:12219 nrci=0x1 tdd_cell=on  after  set_gnb id=1
    wts_conf.modify    set_cell id=1 gnb=1    modification=bw=20MHz technology=lte mandatory_for_activation=off
    wts_conf.insert    gnb_param id=1 xn_listening_socket=off  after  set_cell id=1 gnb=1
    wts_conf.modify    ue_param id=1    modification=ue_nr_capabilities=${UE_NR_CAPABILITIES}
    wts_conf.insert    ue_param id=1 dual_conn=eutra_nr  after  ue_param id=1
    wts_conf.insert    ue_param id=1 nr_usage_setting=voice_centric  after  ue_param id=1
    wts_conf.modify    qosflow_set id=1    modification=5qi=5
    wts_conf.modify    set_qosflow id=2    modification=5qi=1
    wts_conf.modify    set_qosflow id=3    modification=5qi=2
    wts_conf.insert    set_qosflow id=4 5qi=6  after  set_qosflow id=3
    wts_conf.delete    set_qosrule id=1
    wts_conf.delete    set_qosrule id=2
    wts_conf.insert    set_qosrule id=1 proto=udp qos_flow=1  after  set_qosflow id=4
    wts_conf.insert    set_qosrule id=2 proto=udp qos_flow=2  after  set_qosrule id=1
    wts_conf.insert    set_qosrule id=3 proto=udp qos_flow=3  after  set_qosrule id=2
    wts_conf.insert    set_qosrule id=4 proto=udp qos_flow=4  after  set_qosrule id=3
    wts_conf.delete    set_pdu_gateway id=2
    wts_conf.insert    set_pdu_gateway id=2 ue_nat_ip=72.23.0.2 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP  after  set_pdu_gateway id=1
    wts_conf.modify    nwslice_set id=1    modification=qos_flows=1,2,3,4 qos_rules=1,2,3,4
    FOR    ${ue_id}    IN RANGE    101  111
        Delete NSA UEs      ue_id=${ue_id}
    END
    FOR    ${ue_id}    IN RANGE    121  131
        Delete NSA UEs      ue_id=${ue_id}
    END
    FOR    ${ue_id}    IN RANGE    151  161
        Delete NSA UEs     ue_id=${ue_id}
    END
    FOR    ${ue_id}    IN RANGE    171  181
        Delete NSA UEs     ue_id=${ue_id}
    END
    FOR   ${command}        IN
    ...   uec_param id=1 reordering_window_size=1000
    ...   sim_debug_log level=4 mme=1
    ...   sim_debug_log level=4 uec=1
    ...   sim_debug_log level=4 pgw=1
    ...   sim_debug_log level=4 sgw=1
          wts_conf.delete   ${command}
    END
    wts_conf.modify    set_log    modification=max_file_num=10
    wts_conf.save_wts_cfg    file_path=/opt/iphy/latest/basic_setup_5876_new.cfg

Delete NSA UEs
    [Arguments]  ${ue_id}=11
    FOR   ${command}        IN
    ...   set_ue simulated id=${ue_id}
    ...   ue_param id=${ue_id}
    ...   set_bearer id=2 ue=${ue_id}
          wts_conf.delete   ${command}
    END

Start data traffic on 2 PDU sessions
    FOR   ${trf_id}    ${pdu}    ${qfi}          IN
    ...   1            1         1
    ...   2            1         2
    ...   3            1         3
    ...   1            2         1
    ...   2            2         2
          Execute Egate Command     cmd=trf_data_start ue=1 pdu=${pdu} qfi=${qfi} trf_id=${trf_id} protocol=udp dir=dl mbps=2
#          Start Data Traffic   ues=1   pdu=${pdu}  optional_parameters=qfi=${qfi} trf_id=${trf_id} protocol=udp   direction=dl   throughput=2mbps
    END

Stop data traffic on 2 PDU sessions
    FOR   ${trf_id}    ${pdu}    ${qfi}          IN
    ...   1            1         1
    ...   2            1         2
    ...   3            1         3
    ...   1            2         1
    ...   2            2         2
          Execute Egate Command     cmd=trf_data_stop ue=1 pdu=${pdu} qfi=${qfi} trf_id=${trf_id} dir=dl
#          Stop data traffic   ues=1   pdu=${pdu}   optional_parameters=qfi=${qfi} trf_id=${trf_id}   direction=dl
    END

Trigger inter-RAT Handover
    Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=1 event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    Sleep   3s
    ${meas_id}=    Get Measurement id    event_type=B2
    ${cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=${meas_id} event=B2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0 phycell_id=11
    ...   nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:0
    Execute Egate Command    cmd=${cmd}   pass_regexp=IRAT Handover from NR to EUTRA completed
    Sleep    60s

Get Measurement id
    [Arguments]  ${event_type}  ${ue_id}=1
    ${measurements}=    Execute Egate Command    cmd=ue_meas_cfg_disp id=${ue_id}  pass_regexp=Event${event_type}
    ${matching_lines}=  Get Lines Containing String  ${measurements}  Event${event_type}
    ${first_line}=  Get Line  ${matching_lines}  0
    @{words}=  Split String  ${first_line}
    [Return]  ${words}[0]

Verify EndMarker received from gNB
    Sleep    60s
    Verify Egate Content      expected_pattern=End marker received?      occurrence=3
    Verify Egate Content      expected_pattern=Yes          occurrence=3

