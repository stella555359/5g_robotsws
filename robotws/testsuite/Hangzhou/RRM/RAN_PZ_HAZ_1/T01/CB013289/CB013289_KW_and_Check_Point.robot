*** Settings ***

Documentation     Keywords related to CB013289
Library     ute_wtssim
Library     String
Library     OperatingSystem
Library     Collections
Library     ta5g_ue_measurements
Library     taf.config.wts        WITH NAME    wts_conf
Library      Process

Resource    ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot

*** Variables ***

@{pdu1_qos_list}  ${2}  ${3}
@{pdu_qos_list}  ${5}  ${6}
@{pdu_qos_list2}  ${5}  ${6}  ${7}
@{pdu2_qos_list}  ${4}
${carrier_freq_NR}    ${636576}
${carrier_freq_FDD_NR}    ${126530}
${carrier_freq_LTE}    ${2200}
${plugin_folder}   /usr/lib/x86_64-linux-gnu/wireshark/plugins
${plugin_folder_utevm}   /home/ute/.local/lib/wireshark/plugins

${nrcell_distname}=    MRBTS-1/NRBTS-1/NRCELL-1
${nrcell_distname_FDD}=    MRBTS-1/NRBTS-1/NRCELL-3
${nrbts_distname}=    MRBTS-1/NRBTS-1
${T22_counter}=     M55124C07001,M55124C07002,M55125C02001,M55125C02002,M55352C00007,M55352C00008,M55125C00048,M55125C00049
${T22_counter_rule}=    max(M55124C07001)>=1 and max(M55124C07002)>=1 and max(M55125C02001)>=1
...                    and max(M55125C02002)>=1 and max(M55352C00007)>=1 and max(M55352C00008)>=1
...                    and max(M55125C00048)>=1 and max(M55125C00049)>=1
#${T22_counter_rule}=    M55125C02001>0 and M55125C02002>0
${AB1_counter}=     M55125C02001,M55125C02002
${AB1_counter_rule}=    max(M55125C02001)>=1 and max(M55125C02002)>=1

${T44_counter}=     M55125C00048,M55125C00049,M55125C02001,M55125C02002,M55352C00007,M55352C00008
${T44_counter_rule}=    max(M55125C00048)>=1 and max(M55125C00049)>=1 and max(M55125C02001)>=1
...                    and max(M55125C02002)>=1 and max(M55352C00007)>=1 and max(M55352C00008)>=1

${direct_counter}=     M55125C00048,M55125C00049,M55125C02001,M55125C02002,M55352C00007,M55352C00008
${direct_counter_rule}=    max(M55125C00048)>=1 and max(M55125C00049)>=1 and max(M55125C02001)>=1
...                    and max(M55125C02002)>=1 and max(M55352C00007)>=1 and max(M55352C00008)>=1

${indirect_counter}=     M55125C00048,M55125C00049,M55125C02001,M55125C02002,M55352C00007,M55352C00008
${inidrect_counter_rule}=    max(M55125C00048)==0 and max(M55125C00049)==0 and max(M55125C02001)>=1
...                    and max(M55125C02002)>=1 and max(M55352C00007)==0 and max(M55352C00008)==0

${nodata_counter}=     M55125C00048,M55125C00049,M55125C02001,M55125C02002,M55352C00007,M55352C00008
${nodata_counter_rule}=    max(M55125C00048)>=1 and max(M55125C00049)==0 and max(M55125C02001)>=1
...                    and max(M55125C02002)>=1 and max(M55352C00007)==0 and max(M55352C00008)==0

${e1bear_counter}=     M55135C00505,M55133C01004,M55133C01005,M55113C00001
${e1bear_counter_rule}=    max(M55135C00505)>=1 and max(M55133C01004)>=1 and max(M55133C01005)>=1 and max(M55113C00001)>=1

${gtp_packet_counter}=     M55352C00007,M55352C00008
${gtp_packet_counter_rule}=    max(M55352C00007)==0 and max(M55352C00008)==0

*** Keywords ***
Case Precondition
    log to console    Case Precondition
    OperatingSystem.Run    sudo chmod 777 /opt/wts/latest
    Common Test Setup For RRM
    Airphone Common Setup    local_wts_dir=${CURDIR}/config/basic_setup_13289.cfg
    ...                      iphy_path=${CURDIR}/config/iphy.xml
    ...                      scf_file_path=${CURDIR}/config/scf_13289.xml
    Airphone Execute Egate Command    cmd=set_log flush
    Airphone Execute Egate Command    cmd=state_sim_disp
    Start Btslog Collect    names=btslog1

Case Precondition For ANR
    log to console    Case Precondition
    OperatingSystem.Run    sudo chmod 777 /opt/wts/latest
    Common Test Setup For RRM
    Airphone Common Setup    local_wts_dir=${CURDIR}/config/basic_setup_13289.cfg
    ...                      iphy_path=${CURDIR}/config/iphy.xml
    ...                      scf_file_path=${CURDIR}/config/SCF_ANR.xml
    Airphone Execute Egate Command    cmd=set_log flush
    Airphone Execute Egate Command    cmd=state_sim_disp
    Start Btslog Collect    names=btslog1

Case Postcondition
    log to console    Case Postcondition
    Run Keyword And Ignore Error    Stop data traffic on 2 PDU sessions    ue_id=1
    ${btslog_name1}    Stop Btslog Collect    names=btslog1
    Airphone Common Teardown
    Run Keyword If Test Failed    Run Keyword And Ignore Error    Collect Coam Snapshot
    ${DATE}=    Get Current Date    result_format=%Y%m%d_%H%M
    Wait Until Keyword Succeeds    3x    1min    COAM_Admin.Login    alias=SCF_backup
    Run Keyword And Ignore Error    COAM_Admin.BackupSCF    local_dir=${TEST_LOG_DIRECTORY}    file_name=SCF_${DATE}.xml
    ...    connection=SCF_backup
    Run Keyword And Ignore Error    COAM_Admin.Logout    connection=SCF_backup

Start Collect Wireshark For GNB
    ${wireshark_argument}   Create Dictionary   wireshark_options=-i any
    ${dict_argument}   Create Dictionary   argument=${wireshark_argument}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}

Stop Wireshark log For GNB
    ${local_file_path}    Log Collection    stop_and_download    wireshark    product_type=gnb    bts_index=${0}
    [Return]    ${local_file_path}

UE Register And PDU Session Setup
    [Arguments]    ${ue_id}=1    ${pass_regexp}=QoS Routing Table    ${ue_gw}=1
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}
    sleep    5s
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    sleep    5s
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_gw}    pass_regexp=${pass_regexp}
    sleep    5s

UE${ue_id:\d+} Register
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}
    sleep    5s

UE${ue_id:\d+} And PDU Session-${pdu_id:\d+} Gateway-${gw_id:\d+} Setup
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${gw_id}
    ...                                pass_regexp=QoS Routing Table
    sleep    5s

Start ${traffic_rate:\d+}Mbps Traffic On PDU Session-${pdu_id:\d+} QFI-${qfi_id:\d+} ${direction:(ul|dl)} for UE${ue_id:\d+}
    ${cmd}    Catenate   trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=${direction} Mbps=${traffic_rate}
    Airphone Execute Egate Command    cmd=${cmd}
    sleep    5s

Send A2 Measurement
    [Arguments]  ${ue_id}=1
    ${meas_id_A2}=    Get Measurement Id For Frequency    ue_id=${ue_id}    event_type=EventA2    carrier_freq=${carrier_freq_NR}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A2} event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
#    Airphone Execute Egate Command    cmd=${cmd}
    ${output}=    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${cmd}
    ...                   pass_regexp=${None}
    ...                   timeout=100s

Configure ECGI For ANR
    [Arguments]  ${ue_id}=1
    ${cmd}    Catenate    ue_nr_rrc_reconf_param id=${ue_id} if_contains=report_cgi_eutra anr_cgi_delay=100
    ${output}=    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${cmd}
    ...                   pass_regexp=${None}
    ...                   timeout=100s

Send B2 Measurement And Attempt Handover
    [Arguments]  ${ue_id}=1    ${phycell_id}=11
    ${meas_id}=    Get Measurement Id For Frequency    ue_id=${ue_id}    event_type=EventB2    carrier_freq=${carrier_freq_LTE}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=B2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    ...   phycell_id=${phycell_id} nrsrp_nr=60 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=60:30:0
#    Airphone Execute Egate Command    cmd=${cmd}    pass_regexp=Received HandoverNotify
    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${cmd}
    ...                   pass_regexp=Received HandoverNotify
    ...                   timeout=100s

Trigger inter-RAT Handover
    [Arguments]  ${ue_id}=1    ${phycell_id}=11
    Send A2 Measurement    ue_id=${ue_id}
    Sleep   5s
    Send B2 Measurement And Attempt Handover    ue_id=${ue_id}    phycell_id=${phycell_id}

UE PDU Session Modify
    [Documentation]
    ...    Added additional qos flows to pdu session of an UE. By default adds flows 2 and 3, which are pre-configured in
    ...    basic_setup.cfg and necessary for VoNR.
    ...
    ...    | ue_id              | Specified UE ID                                          |
    ...    | pdu                | PDU Session to be modified                               |
    ...    | list qos_flow_list | list of all the used qos_flows that should be added      |
    ...    | by                 | Device type initiating the procedure ue|amf              |
    ...    | pass_regexp        | regexp to pass the KW if found in egate command response |
    ...    | fail_regexp        | regexp to fail the KW if found in egate command response |
    ...
    [Arguments]   ${ue_id}   ${pdu}=1   ${qos_flow_list}=${NONE}   ${by}=amf   ${pass_regexp}=QosFlow with QFI
    ${default_qos_list}   Create List   ${2}   ${3}
    ${qos_flow_list}      Set Variable If   ${qos_flow_list}   ${qos_flow_list}   ${default_qos_list}

    FOR   ${qos_parameter}   IN   @{qos_flow_list}
        ${cmd1}    Catenate    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qos_parameter} by=${by}
        Airphone Execute Egate Command    cmd=${cmd1}    pass_regexp=${pass_regexp}
        sleep    10s
    END
    sleep    10s

UE PDU Session Setup
    [Documentation]
    ...    Performs ue_pdu_session_setup and checks if given ``pass_regexp`` is found in egate console output.
    ...
    ...    | pdu            | PDU Session ID                                                                            |
    ...    | gw             | PDU Gateway ID. Specifies gateway to use for this PDU session                             |
    ...    | ue_id          | Specified UE ID                                                                           |
    ...    | nwslice        | Requested Network Slice for the PDU Session                                               |
    ...    | pass_regexp    | Initial Context Setup Successful (for 1st PDU session)                                    |
    ...    | ..             | Pdu Session.*successfully (for further PDU sessions in case of more than 1 PDU session)   |
    ...    | fail_regexp    | regexp to fail the KW if found in egate command response                                  |
    ...
    ...    *Returns*   ue ip    and    egate console output
    ...
    [Arguments]   ${ue_id}=1   ${pdu}=1   ${nwslice}=1   ${gw}=1   ${pass_regexp}=Initial Context Setup Successful
    ${cmd1}    Catenate    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=${nwslice} gw=${gw}
#    Airphone Execute Egate Command    cmd=${cmd1}    pass_regexp=${pass_regexp}
    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${cmd1}
    ...                   pass_regexp=${pass_regexp}
    ...                   timeout=100s
    sleep    5s

Start data traffic on 2 PDU sessions
    [Arguments]   ${ue_id}=1
    FOR   ${trf_id}    ${pdu}    ${qfi}          IN
    ...   1            1         1
    ...   2            1         2
    ...   3            1         3
    ...   1            2         1
    ...   2            2         2
          Start data traffic in egate   ue_id=${ue_id}   direction=dl   protocol=udp   trf_id=${trf_id}   pdu=${pdu}   qfi=${qfi}   Mbps=2
    END

Stop data traffic on 2 PDU sessions
    [Arguments]   ${ue_id}=1
    FOR   ${trf_id}    ${pdu}    ${qfi}          IN
    ...   1            1         1
    ...   2            1         2
    ...   3            1         3
    ...   1            2         1
    ...   2            2         2
          Stop data traffic in egate   ue_id=${ue_id}   direction=dl   trf_id=${trf_id}   pdu=${pdu}   qfi=${qfi}
    END

Start data traffic in egate
    [Documentation]
    ...    Start data traffic (NSA/SA)
    ...
    ...    | ue_id          | ue_id configured in WTS configuration                                         |
    ...    | direction:     | dl or ul traffic direction                                                    |
    ...    | protocol:      | L3 protocol type, e.g. udp|tcp|icmp                                           |
    ...    | ack_mode:      | toggle for receiver to generate an ack, e.g. on|off                           |
    ...    | trf_id:        | traffic id, e.g. 1                                                            |
    ...    | cl_trf_stats   | toggle for clear L3 statistics for the traffic instance, e.g. on|off          |
    ...    | kwargs:        | dictionary of pairs "parameter:value", e.g. id=2, mbps=5, rtp_codec=custom    |
    ...    | ..             | rtp_ps=32 or rtp_ts_step=1000                                                 |
    ...
    [Arguments]   ${ue_id}=${EMPTY}   ${direction}=${EMPTY}   ${protocol}=udp   ${ack_mode}=off   ${trf_id}=1
    ...   ${cl_trf_stats}=on    &{kwargs}
    ${command_args}   Convert Dictionary to Parameter String    &{kwargs}
    ${command}   Catenate
    ...   trf_data_start ue=${ue_id} dir=${direction} trf_id=${trf_id}
    ...   protocol=${protocol} ack_mode=${ack_mode} cl_trf_stats=${cl_trf_stats}${command_args}
    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${command}
    ...                   pass_regexp=${None}
    ...                   timeout=100s

Stop data traffic in egate
    [Documentation]
    ...    Stop running data traffic (NSA/SA) for the given ``ue_id``.
    ...
    ...    | ue_id:     | ue_id configured in WTS configuration             |
    ...    | direction  | ul|dl|bi traffic direction                        |
    ...    | trf_id:    | traffic id, e.g. 1                                |
    ...    | kwargs:    | dictionary of pairs "parameter:value" (e.g. id=2) |
    ...
    [Arguments]   ${ue_id}   ${direction}   ${trf_id}=1   &{kwargs}
    ${command_args}   Convert Dictionary to Parameter String   &{kwargs}
    Send Egate Command and verify output   cmd=trf_data_stop ue=${ue_id} dir=${direction} trf_id=${trf_id}${command_args}
    ...   pass_regexp=${direction.upper()} Traffic was stopped||Stopping .* traffic

Convert Dictionary to Parameter String
    [Documentation]
    ...
    ...    | kwargs | dictionary of pairs "parameter:value" |
    ...
    ...     *Scope*  Internal
    ...
    [Arguments]   &{kwargs}
    ${command_args}   Set Variable   ${EMPTY}
    FOR   ${key}   IN   @{kwargs}
       ${value}   Collections.Get From Dictionary   ${kwargs}   ${key}
        ${command_args}   Set Variable   ${command_args} ${key}=${value}
    END
    [Return]   ${command_args}

Get Measurement Id For Frequency
    [Arguments]  ${ue_id}=1  ${event_type}=EventA3  ${carrier_freq}=0  ${trigger}=rsrp
    get_ue_measurement_configuration  ue_id=${ue_id}  alias=${ue_id}_meas
    ${meas_id}    get_meas_id_for_measurement_on_frequency  event_type=${event_type}  carrier_freq=${carrier_freq}
    ...    alias=${ue_id}_meas  trigger=${trigger}
    #Log to console  MeasId for ${event_type} on carrier freq ${carrier_freq} is: ${meas_id}
    [Return]    ${meas_id}

Send Egate Command and verify output
    [Documentation]
    ...    Same as keyword `ute_wtssim.execute`_ egate command and wait for data.
    ...
    ...    http://doc.ute.nsn-rdnet.net/packages/ute_wtssim/interfaces/ute_wtssim.html#execute-egate-command-and-wait-for-data
    ...
    ...    It sends the given ``cmd`` to egate execute.
    ...    ``timeout`` defines the  timeout for this operation.
    ...    ``return_output`` boolean ${False} or ${Ture} indicate whether egate log should be printed out.
    ...    If given regexp ``pass_regexp`` is found in the command response the KW passes whereas if
    ...    the given ``fail_regexp`` is found in the command output the KW fails. The first occurance decides the result.
    ...    If ``return_output`` is True the egate console output will be returned to the caller.
    ...
    ...    | cmd            | Command to execute                                                |
    ...    | timeout        | Timeout for this operation                                        |
    ...    | return_output  | boolean Flag indicating whether egate log should be printed out   |
    ...    | pass_regexp    | Regexp indicating that the command passed                         |
    ...    | fail_regexp    | Regexp indicating that the command failed                         |
    ...    | wts_alias      | alias name to handle egate for ute_wtssim                         |
    ...
    ...    *Example*
    ...    |  `Start WTS for Airphone` |
    ...    |  `Config WTS for Airphone` |
    ...    | wts_ue.Send Egate Command and verify output | cmd=sim_state_disp | pass_regexp=The state is ACTIVE |
    ...
    ...    *Returns*   egate console output
    ...
    [Arguments]   ${cmd}   ${timeout}=10   ${return_output}=${True}   ${pass_regexp}=${None}   ${fail_regexp}=${None}
    ${output}   ute_wtssim.execute egate command and wait for data
    ...   cmd=${cmd}   pass_regexp=${pass_regexp}   fail_regexp=${fail_regexp}
    ...   timeout=${timeout}   return_output=${return_output}
    [Return]   ${output}

Active Feature CB013289 On ${interface:(IRATDirectDataFwdOnNg|IRATDirectDataFwdOnXn|IRATDirectDataFwdOnX2|noIRATDirectDataFwd)}
    @{para_list}    Create List    actInterRatHoDirectDlDataFwd
    @{mo_list}    Create List    MRBTS-1/NRBTS-1
    @{value_list}    Create List    ${interface}
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}
    sleep    10s

Feature CB005876 Set With ${actInterRatHoSADlDataForward:(false|true)}
    @{para_list}    Create List    actInterRatHoSADlDataForward
    @{mo_list}    Create List    MRBTS-1/NRBTS-1
    @{value_list}    Create List    ${actInterRatHoSADlDataForward}
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}
    sleep    10s

Set NRANRPRE-${ANR_id:\d+} iRatDataForwardingMethod with ${value:(directDataFwd|indirectDataFwd|noDataFwd)}
    @{para_list}    Create List    iRatDataForwardingMethod
    @{mo_list}    Create List    MRBTS-1/NRBTS-1/NRANRPRE-${ANR_id}
    @{value_list}    Create List    ${value}
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}
    sleep    10s

Set NRADJECELL-${NRADJ_id:\d+} iRatDataForwardingMethod with ${value:(directDataFwd|indirectDataFwd|noDataFwd)}
    @{para_list}    Create List    iRatDataForwardingMethod
    @{mo_list}    Create List    MRBTS-1/NRBTS-1/NRADJECELL-${NRADJ_id}
    @{value_list}    Create List    ${value}
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}
    sleep    10s

Delete MRBTS-${MRBTS_id:\d+} NRBTS-${NRBTS_id:\d+} NRANRPRE-${ANR_id:\d+} Object
    COAM_Admin.Login
    @{parameter_delta_list}=       create list
    COAM_Admin.perform_object_recommissioning    dist_name=MRBTS-${MRBTS_id}/NRBTS-${NRBTS_id}/NRANRPRE-${ANR_id}
    ...    parameter_delta_list=${parameter_delta_list}   operation=delete
    sleep    10s

Delete MRBTS-${MRBTS_id:\d+} NRBTS-${NRBTS_id:\d+} NRDRB_5QI-${5qi_id:\d+} Object
    COAM_Admin.Login
    @{parameter_delta_list}=       create list
    COAM_Admin.perform_object_recommissioning    dist_name=MRBTS-${MRBTS_id}/NRBTS-${NRBTS_id}/NRDRB_5QI-${5qi_id}
    ...    parameter_delta_list=${parameter_delta_list}   operation=delete
    sleep    12s

Set NRDRB_5QI-${5QI_id:\d+} dataForwarding with ${value:(IRATDataFwd|noIRATDataFwd)}
    @{para_list}    Create List    dataForwarding
    @{mo_list}    Create List    MRBTS-1/NRBTS-1/NRDRB_5QI-${5QI_id}
    @{value_list}    Create List    ${value}
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}
    sleep    10s

Modify IPIF IPADDRESSV4
    [Arguments]    ${mrdn}     ${value}
    @{para_list}    Create List    localIpAddr
    @{mo_list}    Create List    ${mrdn}
    @{value_list}    Create List    ${value}
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}
    sleep    10s

Set pduSessionEndMarkerTimer with ${timer:\d+}ms
    @{para_list}    Create List    pduSessionEndMarkerTimer
    @{mo_list}    Create List    MRBTS-1/NRBTS-1
    @{value_list}    Create List    ${timer}
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}
    sleep    10s

Delta Plan Commission
    [Arguments]  ${delta_plan_file}
    ${out}     Parameter Operation    operation=delta_plan_update   product_type=gnb
    ...                               delta_file_path=${delta_plan_file}
    Log To Console    delta plan update result: ${out}

Start DCAP On VM
    OperatingSystem.Run    DCAP_Basic_controller start
    sleep    15s

Trigger ICS With Trace Start
    [Arguments]    ${ue_id}=1    ${tce_ip}=0.0.0.0
    ${command} =  catenate   SEPARATOR=
    ...    amf_ue_ics_param id=1 ue=${ue_id} object_id=1 location_reporting_reference_id=1 trace_activation=on
    ...    \ trace_plmn=311:489 trace_ref_id=1 trace_rec_session_ref_id=1 trace_depth=medium
    ...    \ ifaces_to_trace=Uu,NG-C,Xn-C,F1-C,E1 tce_ip=${tce_ip}
    Airphone Execute Egate Command    cmd=${command}

Start Subscriber Trace
    [Arguments]    ${ue_id}=1    ${trace_session_id}=1    ${tce_ip}=10.0.1.1
    ${command} =  catenate  SEPARATOR=
    ...           ue_ng_trace_start id=${ue_id} tce_ip=${tce_ip} trace_depth=minimum ifaces_to_trace=Uu,NG-C,Xn-C,F1-C,E1
    ...           \ trace_plmn=311:489 trace_rec_session_ref_id=${trace_session_id} trace_ref_id=${trace_session_id}
    Airphone Execute Egate Command    cmd=${command}

Stop Subscriber Trace
    [Arguments]    ${ue_id}=1    ${trace_session_id}=1
    ${command} =  catenate  SEPARATOR=
    ...           ue_ng_trace_stop id=${ue_id} trace_plmn=311:489 trace_rec_session_ref_id=${trace_session_id}
    ...           \ trace_ref_id=${trace_session_id}
    Airphone Execute Egate Command    cmd=${command}

Trigger inter-RAT Handover For FDD
    [Arguments]  ${ue_id}=1    ${phycell_id}=11
    Send A2 Measurement For FDD    ue_id=${ue_id}
    Sleep   5s
    Send B2 Measurement And Attempt Handover    ue_id=${ue_id}    phycell_id=${phycell_id}

Send A2 Measurement For FDD
    [Arguments]  ${ue_id}=1
    ${meas_id_A2}=    Get Measurement Id For Frequency    ue_id=${ue_id}    event_type=EventA2    carrier_freq=${carrier_freq_FDD_NR}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A2} event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
#    Airphone Execute Egate Command    cmd=${cmd}
    ${output}=    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${cmd}
    ...                   pass_regexp=${None}
    ...                   timeout=100s

Prepare WTS Config
    [Arguments]    ${wts_cfg_name}
    wts_conf.load_wts_cfg    file_path=${wts_cfg_name}
    wts_conf.modify    amf_param id=1      modification=indirect_data_forwarding=off allocate_e-rab_id=off
    wts_conf.save_wts_cfg    file_path=${CURDIR}/config/basic_setup_13289.cfg

Prepare WTS Config With Active direct DataFW
    [Arguments]    ${wts_cfg_name}
    wts_conf.load_wts_cfg    file_path=${wts_cfg_name}
    wts_conf.modify    amf_param id=1      modification=indirect_data_forwarding=off allocate_e-rab_id=on
    wts_conf.save_wts_cfg    file_path=${CURDIR}/config/basic_setup_13289.cfg

Prepare WTS Config With Active Indirect DataFW
    [Arguments]    ${wts_cfg_name}
    wts_conf.load_wts_cfg    file_path=${wts_cfg_name}
    wts_conf.modify    amf_param id=1      modification=indirect_data_forwarding=on allocate_e-rab_id=on
    wts_conf.save_wts_cfg    file_path=${CURDIR}/config/basic_setup_13289.cfg

IRAT HO with Muti UE and HO back to 5G
    FOR    ${UE_ID}    IN    @{UE_ID_LIST}
        Trigger inter-RAT Handover    ue_id=${UE_ID}  phycell_id=11
        sleep    10s
        ${cmd1}    Catenate    gnb_trigger_inter_rat_handover_to_5g ue=${UE_ID} target_gnb=2 target_cell=1 plmn=311:489
        Airphone Operation    operation=send_common_command
        ...                   product_type=${None}
        ...                   traffic_info_dic=${None}
        ...                   tag=${None}
        ...                   cmd=${cmd1}
        ...                   pass_regexp=handover from ENB-5.1 to EXT_ENB-2.1 performed
        ...                   timeout=10s
        sleep    5s
    END

Prepare WTS Config With Active direct DataFW For MUE
    [Arguments]    ${wts_cfg_name}
    wts_conf.load_wts_cfg    file_path=${wts_cfg_name}
    wts_conf.modify    amf_param id=1      modification=indirect_data_forwarding=off allocate_e-rab_id=on
    wts_conf.save_wts_cfg    file_path=${CURDIR}/config/basic_setup_13289_MUE.cfg

Prepare WTS Config With Active Indirect DataFW For MUE
    [Arguments]    ${wts_cfg_name}
    wts_conf.load_wts_cfg    file_path=${wts_cfg_name}
    wts_conf.modify    amf_param id=1      modification=indirect_data_forwarding=on allocate_e-rab_id=on
    wts_conf.save_wts_cfg    file_path=${CURDIR}/config/basic_setup_13289_MUE.cfg

Download wireshark plugin
    sleep    5s
    ${nsetapx_plugin_addr} =  catenate   SEPARATOR=
    ...    https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark/SBTS00_ENB_9990_240823_000009/
    ...    mcshark-4.0-1.29.0-SBTS00_ENB_9990_240823_000009+buster.so
    log to console    ${nsetapx_plugin_addr}
    ${ver}   Run   ls ${plugin_folder}/
    ${exist}   Run   cd ${plugin_folder}/${ver}/epan;ls mcshark*
    ${exist_utevm}   Run   cd ${plugin_folder_utevm}/${ver}/epan;ls mcshark*
    Run Keyword If   ${exist.count('No such file or directory')}>0 and ${exist_utevm.count('No such file or directory')}>0   Run
    ...   cd ${plugin_folder}/${ver}/epan;sudo wget ${nsetapx_plugin_addr}

Download wireshark PCMD plugin
    sleep    5s
    ${nsetapx_plugin_addr}  Catenate    SEPARATOR=
    ...  https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP_X/nsetapx-1.13.4/
    ...  nsetapx-4.0-0.7.0-1.13.4+bookworm.so
    log to console    ${nsetapx_plugin_addr}
    ${ver}   Run   ls ${plugin_folder}/
    ${exist}   Run   cd ${plugin_folder}/${ver}/epan;ls nsetapx*
    ${exist_utevm}   Run   cd ${plugin_folder_utevm}/${ver}/epan;ls nsetapx*
    Run Keyword If   ${exist.count('No such file or directory')}>0 and ${exist_utevm.count('No such file or directory')}>0   Run
    ...   cd ${plugin_folder}/${ver}/epan;sudo wget ${nsetapx_plugin_addr}

CB013289 Check Direct Path Item
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=ngap.id == 22
    ...            ${second_filter}=s1ap.id == 78
    Log To Console    ${second_filter}
    ${direct_path_item}=    Run
    ...    tshark -Y "${first_filter}" -T fields -e ngap.DirectForwardingPathAvailability -r ${local_file_path}
    Log To Console    ${direct_path_item}
    Should Be Equal    ${direct_path_item}    0    #'0' means Direct Path is available

CB013289 AB1 TC02 Check Ponit 1
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=ngap.id == 249
    ...            ${second_filter}=s1ap.id == 78
    ${ho_command_erab_id_list}=    Run
    ...    tshark -Y "${first_filter}" -T fields -e ngap.e_RAB_ID -r ${local_file_path}
    Log To Console    ${ho_command_erab_id_list}

    FOR    ${pdu}    ${id}    ${erab_id}             IN
    ...    1         0        0
    ...    1         1        1
    ...    1         2        2
    ...    2         3        3
    ...    2         4        4
    ...    2         5        5
    ...    2         6        6
        Should Contain    ${ho_command_erab_id_list}   ${erab_id}
    END

    ${ho_required_erab_id_list}=    Run
    ...    tshark -Y "${second_filter}" -T fields -e s1ap.e_RAB_ID -r ${local_file_path}
    Log To Console    ${ho_required_erab_id_list}
    ${length}    Get Length    ${ho_required_erab_id_list}
    Should Be Equal     ${ho_required_erab_id_list}    ${ho_command_erab_id_list}
    FOR    ${pdu}    ${id}    ${erab_id}             IN
    ...    1         0        0
    ...    1         1        1
    ...    1         2        2
    ...    2         3        3
    ...    2         4        4
    ...    2         5        5
    ...    2         6        6
        Should Contain    ${ho_required_erab_id_list}   ${erab_id}
    END

CB013289 Check Data Forwarding By NG interface
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=e1ap.id == 76
    ${ranue_id}=    Run
    ...    tshark -Y "${first_filter}" -T fields -e e1ap.RANUEID -r ${local_file_path}
    Log To Console    'ranue_id'\
    Log To Console    ${ranue_id}
    Should Start With    ${ranue_id}    ff

CB013289 AB1 TC06 Check Ponit 1
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=ngap.id == 249
    ...            ${second_filter}=s1ap.id == 78
    ${ho_command_erab_id_list}=    Run
    ...    tshark -Y "${first_filter}" -T fields -e ngap.e_RAB_ID -r ${local_file_path}
    Log To Console    ${ho_command_erab_id_list}

    FOR    ${pdu}    ${id}    ${erab_id}             IN
    ...    1         0        0
    ...    1         1        1
    ...    1         2        2
    ...    2         3        3
    ...    2         4        4
    ...    3         6        5
    ...    3         7        6
    ...    3         8        7
    ...    3         9        8
        Should Contain    ${ho_command_erab_id_list}   ${erab_id}
    END

    ${ho_required_erab_id_list}=    Run
    ...    tshark -Y "${second_filter}" -T fields -e s1ap.e_RAB_ID -r ${local_file_path}
    Log To Console    ${ho_required_erab_id_list}
    ${length}    Get Length    ${ho_required_erab_id_list}
    Should Be Equal     ${ho_required_erab_id_list}    ${ho_command_erab_id_list}
    FOR    ${pdu}    ${id}    ${erab_id}             IN
    ...    1         0        0
    ...    1         1        1
    ...    1         2        2
    ...    2         3        3
    ...    2         4        4
    ...    3         6        5
    ...    3         7        6
    ...    3         8        7
    ...    3         9        8
        Should Contain    ${ho_required_erab_id_list}   ${erab_id}
    END

CB013289 AB2 TC10 Check Ponit 1
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=ngap.qosFlowToBeForwardedList
    ...            ${second_filter}=s1ap.id == 78
    ${ho_command_qos_id_list}=    Run
    ...    tshark -Y "${first_filter}" -T fields -e ngap.qosFlowIdentifier -r ${local_file_path}
    Log To Console    ${ho_command_qos_id_list}

    FOR    ${pdu}    ${id}    ${qos_id}             IN
    ...    1         0        1
    ...    1         1        2
    ...    1         2        3
    ...    2         3        1
    ...    2         4        2
        Should Contain    ${ho_command_qos_id_list}   ${qos_id}
    END

    ${ho_required_erab_id_list}=    Run
    ...    tshark -Y "${second_filter}" -T fields -e s1ap.e_RAB_ID -r ${local_file_path}
    Log To Console    ${ho_required_erab_id_list}
    ${length}    Get Length    ${ho_required_erab_id_list}

    FOR    ${pdu}    ${id}    ${erab_id}             IN
    ...    1         0        0
    ...    1         1        1
    ...    1         2        2
    ...    2         3        3
    ...    2         4        4
        Should Contain    ${ho_required_erab_id_list}   ${erab_id}
    END

CB013289 PCMD CUCP MBA Check Ponit
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=nsetapx.trigger == 2
    ...            ${second_filter}=s1ap.id == 78
    Log To Console    ${second_filter}
    ${tshark_cmd}  catenate    tshark -Y "${first_filter}" -o ntrstr.defragment:TRUE -d tcp.port==49151,ntrstr
    ...  -d tcp.port==49148,ntrstr -d tcp.port==15000-15500,ntrstr -T fields -e nsetapx.traceActivationType -r ${local_file_path}
    ${PCMD_traceActivationType}=    Run    ${tshark_cmd}
    Log To Console    ${PCMD_traceActivationType}
    Should Be Equal    ${PCMD_traceActivationType}    0    #'0' means 'MBA'

    ${tshark_cmd_1}  catenate    tshark -Y "${first_filter}" -o ntrstr.defragment:TRUE -d tcp.port==49151,ntrstr
    ...  -d tcp.port==49148,ntrstr -d tcp.port==15000-15500,ntrstr -T fields -e nsetapx.forwardingType -r ${local_file_path}
    ${PCMD_forwardingType}=    Run    ${tshark_cmd_1}
    Log To Console    ${PCMD_forwardingType}
    Should Be Equal    ${PCMD_forwardingType}    1    #'1' means 'Direct'

    ${tshark_cmd_2}  catenate    tshark -Y "${first_filter}" -o ntrstr.defragment:TRUE -d tcp.port==49151,ntrstr
    ...  -d tcp.port==49148,ntrstr -d tcp.port==15000-15500,ntrstr -T fields -e nsetapx.forwardingTarget -r ${local_file_path}
    ${PCMD_forwardingTarget}=    Run    ${tshark_cmd_2}
    Log To Console    ${PCMD_forwardingTarget}
    Should Be Equal    ${PCMD_forwardingTarget}    1    #'1' means 'eutran'

CB013289 EC1 TC15 Check Ponit 1
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=e1ap.dL_TX_Stop == 0
    ...            ${second_filter}=ngap.id == 101
    ${ranue_id}=    Run
    ...    tshark -Y "${first_filter}" -T fields -e e1ap.RANUEID -r ${local_file_path}
    Log To Console    'ranue_id'\
    Log To Console    ${ranue_id}
    Should Be Empty    ${ranue_id}

    ${ho_required_erab_id_list}=    Run
    ...    tshark -Y "${second_filter}" -T fields -e s1ap.e_RAB_ID -r ${local_file_path}
    FOR    ${pdu}    ${id}    ${erab_id}             IN
    ...    1         0        0
    ...    1         1        1
    ...    1         2        2
        Should Contain    ${ho_required_erab_id_list}   ${erab_id}
    END

Start Collect Counter
    [Arguments]    ${distname}    ${counter}    ${counter_rule}
    ${rule1}    Catenate
    ...         Distname: ${distname};
    ...         Counter: ${counter};
    ...         Counter rule: ${counter_rule};
    ${rule_list}    Create List    ${rule1}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0    counter_rule=${rule_list}
    ...                  wait_for_next_counter_generate=${true}

Stop Collect Counter and verify PM counters
    ${result}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0
    Log To Console    \nCounter Rule Collect and Check Result is: ${result}


Start Collect Counter For Multi Rule
    [Arguments]    ${distname}    ${counter}    ${counter_rule}    ${second_distname}    ${second_counter}    ${second_counter_rule}
    ${rule1}    Catenate
    ...         Distname: ${distname};
    ...         Counter: ${counter};
    ...         Counter rule: ${counter_rule};
    ${rule2}    Catenate
    ...         Distname: ${second_distname};
    ...         Counter: ${second_counter};
    ...         Counter rule: ${second_counter_rule};
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0    counter_rule=${rule_list}
    ...                  wait_for_next_counter_generate=${true}

Start Collect Counter For T52
    ${rule1}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55352C00007;
    ...         Counter rule: max(M55352C00007);
    ${rule2}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55352C00008;
    ...         Counter rule: max(M55352C00008);
    ${rule_list}    Create List    ${rule1}    ${rule2}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0    counter_rule=${rule_list}
    ...                  wait_for_next_counter_generate=${true}

Stop Collect Counter and verify PM counters For T52
    ${result}    Counter Operation    operation=collect_counter_and_calculate   product_type=gnb    bts_index=0    cudu_index=0
    Log To Console    \nCounter Rule Collect and Check Result is: ${result}
    [Return]    ${result}
