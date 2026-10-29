*** Settings ***

Documentation     Keywords related to CB012629
Resource          CB012629_Common_Variables.robot


*** Keywords ***
Case Precondition For CB008225
    log to console    Case Precondition
    ${wts_folder_link}    Run    ls -l /opt/iphy | grep latest | awk '{print $11}'
    Run Keyword If   "${wts_folder_link}"!="/opt/wts/latest"  Create wts folder if not exists
    Case Precondition   operation=env_setup_sa  tag=CB008225
    OperatingSystem.Run     DCAP_Basic_controller start
    Download wireshark plugin

Case Precondition For CommonET
    log to console    Case Precondition
    ${wts_folder_link}    Run    ls -l /opt/iphy | grep latest | awk '{print $11}'
    Run Keyword If   "${wts_folder_link}"!="/opt/wts/latest"  Create wts folder if not exists
    Case Precondition   operation=env_setup_sansa  tag=CommonET
    OperatingSystem.Run     DCAP_Basic_controller start
    Download wireshark plugin

Case Precondition For 5QI1
    log to console    Case Precondition
    ${wts_folder_link}    Run    ls -l /opt/iphy | grep latest | awk '{print $11}'
    Run Keyword If   "${wts_folder_link}"!="/opt/wts/latest"  Create wts folder if not exists
    Case Precondition   operation=env_setup_sansa  tag=vonr
    OperatingSystem.Run     DCAP_Basic_controller start

Case Precondition For FR2
    log to console    Case Precondition
    ${wts_folder_link}    Run    ls -l /opt/iphy | grep latest | awk '{print $11}'
    Run Keyword If   "${wts_folder_link}"!="/opt/wts/latest"  Create wts folder if not exists
    Download wireshark plugin
    Case Precondition   operation=env_setup_sa  tag=fr2


Case Precondition
    [Arguments]   ${operation}=env_setup_sansa   ${tag}=CLOUD_5G_I_LO_AP_LO
    ${wts_folder_link}    Run    ls -l /opt/iphy | grep latest | awk '{print $11}'
    Run Keyword If   "${wts_folder_link}"!="/opt/wts/latest"  Create wts folder if not exists
    Airphone Operation  edaemon_egate_setup  gnb  tag=${tag}
    Airphone Operation  ${operation}  gnb  tag=${tag}

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Airphone Execute Egate Command    cmd=${cmd}

UE Register
    [Arguments]    ${ue_id}=1  ${gnb_id}=2  ${cell_id}=1  ${gw}=1  ${pass_regexp}=QoS Routing Table
    Log To Console    ${gw}
    Log To Console    ${pass_regexp}
    Airphone Execute Egate Command    cmd=ue_change_location id=${ue_id} enb=${gnb_id} cell=${cell_id}
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register

UE Register And PDU Session Setup
    [Arguments]    ${ue_id}=1  ${gnb_id}=2  ${cell_id}=1  ${gw}=1  ${pass_regexp}=QoS Routing Table
    ${cmd}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Airphone Execute Egate Command    cmd=ue_change_location id=${ue_id} enb=${gnb_id} cell=${cell_id}
    Airphone Execute Egate Command    cmd=${cmd}
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gw}    pass_regexp=${pass_regexp}

UE Modify new PDU
    [Arguments]    ${ue_id}=1    ${pdu}=1   ${qosflows_to_add}=2   ${pass_regexp}=QoS Routing Table
    Airphone Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qosflows_to_add} by=amf    pass_regexp=${pass_regexp}

UE setup new PDU
    [Arguments]    ${ue_id}=1    ${pdu}=2    ${nwslice}=2    ${gateway}=2    ${pass_regexp}=QoS Routing Table
    Airphone Execute Egate Command   cmd=set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Airphone Execute Egate Command   cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=${nwslice} gw=${gateway}    pass_regexp=${pass_regexp}

Trigger RRC Resume
    [Arguments]    ${ue_id}=1  ${gnb_id}=2  ${cell_id}=1  ${msg}=${EMPTY}  ${cause}=mt_Access   ${pass_regexp}=none   ${action}=${EMPTY}
    sleep    2s    #sleep for inactive precedure complete
    Airphone Execute Egate Command
    ...       cmd=ue_nr_rrc_resume_request_param id=${ue_id} gnb=${gnb_id} cell=${cell_id} msg=${msg} cause=${cause} action=${action}
    Airphone Execute Egate Command    cmd=ue_nr_rrc_resume id=${ue_id}    pass_regexp=${pass_regexp}

Trigger RRC Resume wo Action
    [Arguments]    ${ue_id}=1  ${gnb_id}=2  ${cell_id}=1  ${msg}=${EMPTY}  ${cause}=mt_Access   ${pass_regexp}=none
    sleep    2s    #sleep for inactive precedure complete
    Airphone Execute Egate Command
    ...       cmd=ue_nr_rrc_resume_request_param id=${ue_id} gnb=${gnb_id} cell=${cell_id} msg=${msg} cause=${cause}
    Airphone Execute Egate Command    cmd=ue_nr_rrc_resume id=${ue_id}    pass_regexp=${pass_regexp}

Send UAI to gNB
    [Arguments]    ${ue_id}=1    ${state}=inactive    ${pass_regexp}=none
    Airphone Execute Egate Command    cmd=ue_assistance_send_nr ue_id=${ue_id} PreferredRRCState=${state}    pass_regexp=${pass_regexp}

UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Airphone Execute Egate Command   cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off
    sleep   15s

Multi UE Detach
   [Arguments]    ${ue_id}=1   ${num}=6
   sleep  5s
   FOR  ${ue_id}    IN RANGE    1    ${num}
        UE Deregister From gNB    ue_id=${ue_id}
   END

Start data traffic in egate
    [Arguments]   ${ue_id}=${EMPTY}   ${direction}=ul  ${protocol}=udp   ${ack_mode}=off   ${trf_id}=1  ${qfi}=1
    ...   ${cl_trf_stats}=on   ${mbps}=10   &{kwargs}
    ${command}   Catenate
    ...   trf_data_start ue=${ue_id} dir=${direction} trf_id=${trf_id}
    ...   protocol=${protocol} ack_mode=${ack_mode} cl_trf_stats=${cl_trf_stats}
    ...   pdu=1 qfi=${qfi} mbps=${mbps}
    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${command}
    ...                   pass_regexp=${None}
    ...                   timeout=100s

Stop data traffic in egate
    [Arguments]   ${ue_id}=1   ${direction}=ul   ${trf_id}=1   ${pass_regexp}=none   &{kwargs}
    Send Egate Command and verify output   cmd=trf_data_stop ue=${ue_id} dir=${direction} trf_id=${trf_id} pdu=1 qfi=1
    ...   pass_regexp=${pass_regexp}

Start traffic to Active
    [Arguments]   ${ue_id}=1
    Airphone Execute Egate Command    cmd=data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=100
    Airphone Execute Egate Command    cmd=data_trf_start ue=${ue_id} pdu=2 qfi=1 dir=dl trf_id=2 mbps=100
    Airphone Execute Egate Command    cmd=data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=3 mbps=10
    Airphone Execute Egate Command    cmd=data_trf_start ue=${ue_id} pdu=2 qfi=1 dir=ul trf_id=4 mbps=10

Start traffic to 5QI5 and 5QI1
    [Arguments]    ${ue_id}=23   ${pdu}=1
    Airphone Execute Egate Command
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=1 dir=dl trf_id=1 protocol=tcp seconds=6000
    Airphone Execute Egate Command
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=1 dir=ul trf_id=2 protocol=tcp seconds=6000
    Airphone Execute Egate Command
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=2 dir=dl trf_id=1 rtp_codec=amr_wb_18_25 seconds=6000
    Airphone Execute Egate Command
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=2 dir=ul trf_id=2 rtp_codec=amr_wb_18_25 seconds=6000

Check traffic for 5QI5 and 5QI1
    [Arguments]    ${ue_id}=23   ${pdu}=1
    Airphone Execute Egate Command      cmd=qfi_stats ue=${ue_id} pdu=${pdu} qfi=1 dir=dl    pass_regexp=Parameter
    Airphone Execute Egate Command      cmd=qfi_stats ue=${ue_id} pdu=${pdu} qfi=1 dir=ul    pass_regexp=Parameter
    Airphone Execute Egate Command      cmd=qfi_stats ue=${ue_id} pdu=${pdu} qfi=2 dir=dl    pass_regexp=Parameter
    Airphone Execute Egate Command      cmd=qfi_stats ue=${ue_id} pdu=${pdu} qfi=2 dir=ul    pass_regexp=Parameter


Get Measurement Id
    [Arguments]  ${ue_id}=1  ${event_type}=A2  ${carrier_freq}=0
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency  ue_id=${ue_id}  event_type=${event_type}  carrierfreq=${carrier_freq}
    [Return]    ${meas_id}

Trigger Inter-gNB Inter-Freq HO
    [Arguments]  ${ue_id}=1   ${carrier_freq_source}=633216   ${carrier_freq_target}=633408   ${pass_regexp}=none
    ${meas_id_A2}=    Get Measurement Id    ue_id=${ue_id}    event_type=A2   carrier_freq=${carrier_freq_source}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A2} event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    Airphone Execute Egate Command      cmd=${cmd}
    ${meas_id_A3}=    Get Measurement Id    ue_id=${ue_id}    event_type=A3   carrier_freq=${carrier_freq_target}
    ${cmd}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A3} event=A3 srsrp_nr=11 phycell_id=381 nrsrp_nr=85
    Airphone Execute Egate Command     cmd=${cmd}    pass_regexp=${pass_regexp}

Trigger HO Back from SiM to Real
    [Arguments]  ${ue_id}=1  ${event_type}=A2  ${carrier_freq}=633216   ${pass_regexp}=none
    Log To Console    ${event_type}
    ${meas_id_A3}    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq}    event_type=A3
    Airphone Execute Egate Command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A3} event=A3 srsrp_nr=30 phycell_id=50 nrsrp_nr=80
    ...    pass_regexp=${pass_regexp}

Stop traffic to Inactive
    [Arguments]   ${ue_id}=1   ${pass_regexp}=none
    Airphone Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=1
    Airphone Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=2    pass_regexp=${pass_regexp}   timeout=21s

Send Egate Command and verify output
    [Documentation]
    [Arguments]   ${cmd}   ${timeout}=180   ${return_output}=${True}   ${pass_regexp}=${None}   ${fail_regexp}=${None}
    ${output}   ute_wtssim.execute egate command and wait for data
    ...   cmd=${cmd}   pass_regexp=${pass_regexp}   fail_regexp=${fail_regexp}
    ...   timeout=${timeout}   return_output=${return_output}
    [Return]   ${output}

Setup Xn Link To gNB
    [Arguments]    ${gnb_id}=3    ${pass_regexp}=none
    Airphone Execute Egate Command   cmd=gnb_param id=${gnb_id} xn_listening_socket=1 send_xn_setup=true sib1_period=160ms
    Airphone Execute Egate Command
    ...    cmd=gnb_xn_link_up gnb=${gnb_id} target=2    pass_regexp=${pass_regexp}

Trigger RRC Reestablish
    [Arguments]   ${ue_id}=1   ${pass_regexp}=NR RRC Reestablishment sucessfully completed  ${cause}=otherFailure
    Airphone Execute Egate Command   cmd=ue_rrc_reestablish id=${ue_id} gnb=2 cell=1 cause=${cause}
    ...   pass_regexp=${pass_regexp}

Trigger UE exsit IDLE
    [Arguments]   ${ue_id}=1   ${pass_regexp}=Initial Context Setup Successful
    Airphone Execute Egate Command   cmd=ue_im_exit id=${ue_id}
    ...   pass_regexp=${pass_regexp}

AMF ICS without PDU session
    ${cmd}    catenate    amf_param id=1 empty_pdu_session_list=on send_ics_registration=on
    Airphone Execute Egate Command    cmd=${cmd}

Modify RRC Setup reason
    [Arguments]    ${ue_id}=1
    ${cmd}    catenate    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=mo-Signalling
     Airphone Execute Egate Command    cmd=${cmd}


Start ET Emil
    start_dcap_controller_common
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info_loacl_emil}
    Log Collection    start    emil    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}

Download ET Emil
    ${local_file_path}    Log Collection    stop_and_download    emil    product_type=gnb    bts_index=${0}
    [Return]   ${local_file_path}
