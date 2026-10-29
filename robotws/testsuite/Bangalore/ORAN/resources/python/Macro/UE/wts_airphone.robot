*** Settings ***
Resource            ../resources.txt

*** Variables ***

*** Keywords ***
Get LteEmulator object
    [Arguments]       ${enb_id}=0
    [Documentation]	    This will return the LteEmulator object if LTEEmuCore or enbs are defined.
    ...    para: enb_id:    end id
    ${lteemu_type}=     testlineInfo.has_lteemu_core     ${tl}
    ${tl_lteemu}   set variable if  '${lteemu_type}'=='True'    ${tl.core}     ${tl.enbs[${enb_id}]}
    [Return]   ${tl_lteemu}

Connect LteEmulator
    [Arguments]       ${alias}=LTEemu    ${enb_id}=0
    ${tl_lteemu}=    Get LteEmulator object    enb_id=${enb_id}
    ssh.Connect to     hostname=${tl_lteemu.default_ssh_connection_details.addr}
    ...                username=${tl_lteemu.default_ssh_connection_details.username}
    ...                password=${tl_lteemu.default_ssh_connection_details.password}
    ...                alias=${alias}

Connect to L2L3
    [Arguments]        ${alias}=l2l3    ${id}=0
    ssh.Connect to     hostname=${tl.ues[${id}].l3_ssh_connection_details.addr}
    ...                username=${tl.ues[${id}].l3_ssh_connection_details.username}
    ...                password=${tl.ues[${id}].l3_ssh_connection_details.password}
    ...                alias=${alias}

Start L2L3 Binary
    [Documentation]	WTS (WrapAround Test Solution) is a simulator for 4G UE, 5G UE CPlane, eNB and Core Network
    ...                 This keyword starts L2L3 Binary
    ...                 Creation Date: 10-June-2018
    ...                 Modified Date: 22-Nov-2018 changes are added due to PR11111 - modified to WTS support
    ...                 Last Modified by: shobha.k_reddy@nokia.com
    [Arguments]            ${id}=0
    Connect to L2L3        alias=l2l3    id=${id}
    ssh.send Command       command=cd /opt/Airphone/L3;rm -fr SYSLOG.log        connection=l2l3
    ssh.send Command       command=cd /opt/AirPhone/L3; ./l3 ${L3_port}                connection=l2l3
    ssh.read_output_until    match=Starting Cell Setup    timeout=20    connection=l2l3

Start LteEmulator Binary
    [Documentation]	Starts LTEsimulator edaemon(Starts all simulated components like
    ...                                        sim_uec-simulates User Equipments L3 and PDCP,
    ...                                        sim_enb-simulates eNB,
    ...                                        sim_mme,sim_pgw,sim_sgw - simulates Core Network)
    ...                 and Egate - User Interface
    ...                 egate console
    ...                 Creation Date: 10-June-2018
    ...                 Modified Date: 22-Nov-2018  modified to WTS support
    ...                 Last Modified by: shobha.k_reddy@nokia.com
    [Arguments]             ${enb_id}=0
    ${tl_lteemu}=    Get LteEmulator object    enb_id=${enb_id}
    wts_airphone.Connect LteEmulator       alias=LTEemu    enb_id=${enb_id}
    ${lteemu_type}=     testlineInfo.has_lteemu_core     ${tl}
    ${edaemon_port}    set variable if  '${lteemu_type}'=='False'    ${edaemon_port}      ${tl.core.edaemon_port}
    ${egate_port}     set variable if  '${lteemu_type}'=='False'      ${egate_port}      ${tl.core.egate_port}
    ssh.execute    command=sudo fuser -k 2152/udp     connection=LTEemu
    ssh.send Command        command=cd ${tl_lteemu.dir_path}; rm -rf *.log*    connection=LTEemu
    lteemu.Configure Lteemu Edaemon       edaemon_ssh_alias=LTEemu
    ...                                   directory_path=${tl_lteemu.dir_path}
    ...                                   port=${edaemon_port}
    ...                                   sudo_password=ute
    lteemu.Configure Lteemu Egate         egate_ssh_alias=LTEemu
    ...                                   directory_path=${tl_lteemu.dir_path}
    ...                                   port=${egate_port}
    lteemu.Start Lteemu                   egate_console_ip=${tl_lteemu.default_ssh_connection_details.addr}
    ...                                   egate_port=${egate_port}

Load Config File To Reach Active State
    [Documentation]	 pre-requisite LTEsimulator edaemon and egate should be started
    ...                  Creation Date: 10-June-2018
    ...                  Modified Date: 25-Jun-201  modified to WTS support
    ...                  Last Modified by: venkata.rajesh@nokia.com
    [Arguments]      ${enb_id}=0      ${cfg_filename}=None    ${gNbCuType}=NSA
    ${tl_lteemu}=    Get LteEmulator object    enb_id=${enb_id}
    ${cfg_filename}   set variable if   '${cfg_filename}' != 'None'    ${cfg_filename}
    ...   ${tl_lteemu.dir_path}/${tl_lteemu.cfg_filename}
    lteemu.Configure                      file=${cfg_filename}
    ${reg_expected}   set variable if  '${gNbCuType}'=='NSA'      CHANGE STATE: ACTIVE - SimMode is ready now
    ...    SystemInformationBlockType1-NR updated
    lteemu.Read Lteemu Output Until Re    expected=${reg_expected}      timeout=540

Setup X2AP Link Between Enb and Gnb
    [Documentation]     setup X2 link
    ...         Prior to this command LTE Environment should be Up i.e.
    ...         5g_uec ahould be active,enb,mme,sgw,pgw should be active
    ...         Usage: X2AP Link between enb and gnb
    ...         or X2AP Link between enb and gnb     enb_id=1   target_id=2
    ...         or X2AP Link between enb and gnb     global_enb_id_of_enb=1
    ...         global_enb_id_of_enb is optional parameter if user passes this it will consider
    ...         in message construction otherwise not. The other two i.e. enb_id and terget_id
    ...         are mandatory if not passed default value will be taken
    ...         Creation Date: 10-June-2018
    ...         Modified Date: 22-Nov-2018  modified to WTS support
    ...         Last Modified by: shobha.k_reddy@nokia.com
    [Arguments]     ${use_global_enb_id_of_enb}=${None}    ${enb_id}=1     ${target_id}=2
    lteemu.Enb X2 Link Up    enb_id=${enb_id}    target_id=${target_id}    use_global_enb_id_of_enb=${use_global_enb_id_of_enb}
    lteemu.Read Lteemu Output Until Re
    ...    expected=ENB-1: X2AP Link with [EG]NB-2 .*(\\n)?? (\\n)??i(\\n)??s(\\n)?? (\\n)??u(\\n)??p    timeout=10

Enb Attach For NSA
    [Documentation]     command used to attach UE to enbsim
    ...         Prior to this command LTE Environment should be Up i.e.
    ...         5g_uec ahould be active,enb,mme,sgw,pgw should be active
    ...         Usage: Enb attach for NSA id=1 or simply Enb attach for NSA
    ...         it will consider default id as 1 when not passed as well
    ...         Creation Date: 10-June-2018
    ...         Modified Date: 22-Nov-2018  modified to WTS support
    ...         Last Modified by: shobha.k_reddy@nokia.com
    [Arguments]                           ${id}=1         ${profile}=1
    lteemu.Ue Attach                      id=${id}      profile=${profile}
    lteemu.Read Lteemu Output Until Re    expected=UE IS ACTIVE               timeout=20

UE Register for SA
    [Documentation]     command is used for registerd UE to AMF
    ...         Creation Date: 14-Jan-2020
    ...         Modified Date:
    ...         Last Modified by: venkata.rajesh@nokia.com
    [Arguments]                           ${id}=1
    lteemu.ue_register                      id=${id}
    lteemu.Read Lteemu Output Until Re    expected=UE now in NG RM Registered state               timeout=20

Setup PDU session for SA
    [Documentation]     command is used for Setup PDU session for specific UE
    ...         Creation Date: 14-Jan-2020
    ...         Modified Date:
    ...         Last Modified by: venkata.rajesh@nokia.com
    [Arguments]       ${pdu}=1   ${gw}=1     ${ue}=1    ${nwslice}=1
    lteemu.ue_pdu_session_setup               pdu=${pdu}       ue=${ue}    gw=${gw}    nwslice=${nwslice}
    lteemu.Read Lteemu Output Until Re    expected=Pdu Session Resource Setup Response Message with RAN UE
    ...    timeout=20

Start sgNB Addition Procedure
    [Documentation]     triggers dual connectivity
    ...                 Prior to this command LTE Environment should be Up i.e.
    ...                 5g_uec ahould be active,enb,mme,sgw,pgw should be active
    ...                 Creation Date: 10-June-2018
    ...                 Modified Date: 22-Nov-2018  modified to WTS support
    ...                 Last Modified by: shobha.k_reddy@nokia.com
    [Arguments]    ${ue}=1     ${target_gnb}=1    ${target_cells}=2     ${bearer}=${None}     ${type}=${None}
    lteemu.Ue Dc Enb Start      ue=${ue}    target_gnb=${target_gnb}    target_cells=${target_cells}
    ...                         bearer=${bearer}    type=${type}
    lteemu.Read Lteemu Output Until        expected=Successfully reconfigured dual connectivity      timeout=30

Start gNB Attach
    [Documentation]     Triggers dual connectivity and verify Attach is succesful
    [Arguments]    ${ue}=1     ${target_gnb}=1    ${target_cells}=2     ${bearer}=${None}     ${type}=${None}
    lteemu.Ue Dc Enb Start      ue=${ue}    target_gnb=${target_gnb}    target_cells=${target_cells}
    ...                         bearer=${bearer}    type=${type}
    lteemu.Read Lteemu Output Until        expected=reported successful RA      timeout=10

Verify messages in SgNB addition procedure
    [Documentation]    Verification of SgNBAdditionRequestAcknowledge,
    ...                SgNBReconfigurationComplete and SNStatusTransfer  messages
    ...                to confirm that SgNB Addition process us success
    ...                Creation Date: 10-June-2018
    ...                Modified Date: 22-Nov-2018  modified to WTS support
    ...                Last Modified by: shobha.k_reddy@nokia.com
    [Arguments]       ${enb_id}=1
    Log to console    Verification of messages in Sgnb Addition procedure
    ${tl_lteemu}=    Get LteEmulator object    enb_id=${enb_id}
    ${log_path}=    set variable  ${tl_lteemu.dir_path}/enb_${enb_id}.log
    lteemu.Read Lteemu Log   log_path=${log_path}    expected=UeProcDcBearerHandout:SendSgnbAdditionRequest
    lteemu.Read Lteemu Log   log_path=${log_path}    expected=Enter void enb::UeProcInitialContextSetup::SendRRCConnectionReconfiguration
    lteemu.Read Lteemu Log   log_path=${log_path}    expected=OnRRCConnectionReconfigurationComplete.
    lteemu.Read Lteemu Log   log_path=${log_path}    expected=SendSNStatusTransfer

kill L2L3 Binary
    [Documentation]        Kill L3 Binary
    ...                    Creation Date: 10-June-2018
    ...                    Modified Date: 22-Nov-2018  modified to WTS support
    ...                    Last Modified by: shobha.k_reddy@nokia.com
    [Arguments]            ${id}=0
    Connect to L2L3        alias=l2l3    id=${id}
    ssh.send command       command=ps aux | grep './l3' | grep -v grep |awk '{print $2}' | xargs kill -9     connection=l2l3
    sleep     2s
    ssh.disconnect         connection=l2l3

Kill LteEmu Edaemon Egate
    [Documentation]        Kill LteEmulator and Egate binary
    ...                    Creation Date: 10-June-2018
    ...                    Modified Date: 22-Nov-2018  modified to WTS support
    ...                    Last Modified by: shobha.k_reddy@nokia.com
    [Arguments]                    ${enb_id}=0
    wts_airphone.Connect LteEmulator              alias=LTEemu                     enb_id=${enb_id}
    lteemu.Reset Lteemu Cfg
    sleep    1s
    ${lteemu_type}=     testlineInfo.has_lteemu_core     ${tl}
    ${edaemon_port}    set variable if  '${lteemu_type}'=='False'    ${edaemon_port}      ${tl.core.edaemon_port}
    ${egate_port}     set variable if  '${lteemu_type}'=='False'      ${egate_port}      ${tl.core.egate_port}
    lteemu.Kill Lteemu Edaemon     edaemon_port=${edaemon_port}     connection=LTEemu     sudo_password=ute
    sleep      5s
    lteemu.Kill Lteemu Egate       egate_port=${egate_port}         connection=LTEemu     sudo_password=ute
    sleep      5s
    ssh.disconnect                 connection=LTEemu

Get Remote IP from config file
    [Documentation]     Get the remote ip from config file to start DL Data
    [Arguments]      ${enb_id}=0      ${ue}=1   ${cfg_filename}=None
    ${lteemu_type}=     testlineInfo.has_lteemu_core     ${tl}
    ${cfg_filename}   set variable if   '${cfg_filename}' != 'None'    ${cfg_filename}
    ...   ${lteemu_type.dir_path}/${lteemu_type.cfg_filename}
    wts_airphone.Connect LteEmulator       alias=LTEemu    enb_id=${enb_id}
    ${remote_ip}    ssh.execute    command=grep -oP '^set_bearer.* ue=${ue} .* ip=\\K[\\d+ | .]*' ${cfg_filename}
    ...    connection=LTEemu
    should not be empty  ${remote_ip}
    ${remote_ip}   set variable    ${remote_ip.strip()}
    [Return]  ${remote_ip}

Start Data From WTS
    [Documentation]     Start data traffic on a bearer
    ...                 Prior to this command LTE Environment should be Up i.e.
    ...                 5g_uec ahould be active,enb,mme,sgw,pgw should be active
    [Arguments]    ${ue}=1             ${id}=6                   ${dir}=dl           ${mbps}=${None}         ${trf_id}=${None}
    ...            ${size}=${None}     ${period_ms}=${None}      ${burst}=${None}    ${protocol}=${none}     ${remote_ip}=${None}
    lteemu.Trf Data Start              ue=${ue}                  id=${id}            dir=${dir}              mbps=${mbps}
    ...                                trf_id=${trf_id}          size=${size}        period_ms=${period_ms}    burst=${burst}
    ...                                protocol=${protocol}      remote_ip=${remote_ip}
    ${dir}=    convert to UpperCase     ${dir}
    lteemu.Read Lteemu Output Until Re                           expected=UDP ${dir} TRF:      timeout=10

Stop Data From WTS
    [Documentation]     Stop data traffic on a bearer
    ...                 Prior to this data should be started.
    [Arguments]            ${id}=6        ${trf_id}=1     ${ue}=1        ${dir}=dl
    lteemu.Trf Data Stop   ue=${ue}       id=${id}        dir=${dir}     trf_id=${trf_id}

Start Downlink Data From Lteemu
    [Documentation]     Start DL data traffic on a bearer
    ...                 Prior to this command LTE Environment should be Up i.e.
    ...                 5g_uec ahould be active,enb,mme,sgw,pgw should be active
    ...                 Usage:Start downlink data - by default it will start traffic
    ...                 in downlink direction.
    ...                 Creation Date: 10-June-2018
    ...                 Modified Date: 22-Nov-2018  modified to WTS support
    ...                 Last Modified by: shobha.k_reddy@nokia.com
    [Arguments]    ${ue}=1             ${id}=6        ${mbps}=${None}         ${trf_id}=${None}    ${remote_ip}=${None}
    ...            ${size}=${None}     ${period_ms}=${None}      ${burst}=${None}    ${protocol}=${none}
    Start Data From WTS                ue=${ue}                  id=${id}            dir=dl              mbps=${mbps}
    ...                                trf_id=${trf_id}          size=${size}        period_ms=${period_ms}    burst=${burst}
    ...                                protocol=${protocol}      remote_ip=${remote_ip}

Stop Downlink Data From Lteemu
    [Documentation]     Stop DL data traffic on a bearer
    ...                 Prior to this DL data should be started.
    ...                 Creation Date: 10-June-2018
    ...                 Modified Date: 22-Nov-2018  modified to WTS support
    ...                 Last Modified by: shobha.k_reddy@nokia.com
    [Arguments]            ${id}=6        ${trf_id}=1     ${ue}=1
    Stop Data From WTS   ue=${ue}       id=${id}        dir=dl     trf_id=${trf_id}

Verify Bearer Stats From WTS
    [Documentation]     Verify Bearer Stats for specific data
    [Arguments]            ${id}=2        ${trf_id}=1     ${ue}=1      ${dir}=dl     ${type}=l3
    ...   ${tx_rx_max_diff_pkts}=${10}
    lteemu.Bearer Stats   ue=${ue}   id=${id}   dir=${dir}   trf_id=${trf_id}    type=${type}
    ${bearer_stats}=    lteemu.read_lteemu_output_until     Average packet interval           30
    ${total_pkts_received}=   Get regexp matches    ${bearer_stats}     Total packets received (.*)    1
    ${total_pkts_received}   convert to integer  ${total_pkts_received[0].strip()}
    ${total_pkts_sent}=   Get regexp matches    ${bearer_stats}     Total packets sent (.*)    1
    ${total_pkts_sent}   convert to integer  ${total_pkts_sent[0].strip()}
    should not be equal as integers  ${total_pkts_received}    0
    ${pkts_diff}=  evaluate  ${total_pkts_sent}-${total_pkts_received}
    run keyword if   ${pkts_diff} > ${tx_rx_max_diff_pkts}   fail
    ...   msg=Data Transfer Failed, packets sent=${total_pkts_sent} packets received=${total_pkts_received}

Reset Config
    [Documentation]     reset the config file
    ...                 Creation Date: 10-June-2018
    ...                 Modified Date: 22-Nov-2018  modified to WTS support
    ...                 Last Modified by: shobha.k_reddy@nokia.com
    lteemu.Reset Lteemu Cfg

Configure UE Parameters For Dual Connectivity
    [Documentation]     Updates online changeable UE parameters, applicable for eNB endc
    ...                 Creation Date: 10-June-2018
    ...                 Modified Date: 22-Nov-2018  modified to WTS support
    ...                 Last Modified by: shobha.k_reddy@nokia.com
    [Arguments]         ${id}=6    ${p_max_nr}=1     ${p_max_eutra}=1    ${unsupported_ext_hdr_type}=dl
    ...                 ${at}=${None}
    lteemu.Ue Enb Endc Param    id=${id}             p_max_nr=${p_max_nr}         p_max_eutra=${p_max_eutra}
    ...                         unsupported_ext_hdr_type=${unsupported_ext_hdr_type}       at=${at}

DualConnectivity MN Initiated Release From Enb
    [Documentation]     Trigger LTE-NR dual connectivity release
    ...                 verification message needs to be added
    ...                 Creation Date: 10-June-2018
    ...                 Modified Date: 22-Nov-2018  modified to WTS support
    ...                 Last Modified by: shobha.k_reddy@nokia.com
    [Arguments]         ${ue}=1     ${bearer}=6      ${by}=enb             ${cause}=off
    lteemu.enb_ue_dc_release     ue=${ue}     bearer=${bearer}      by=${by}           cause=${cause}

Configure Parameters Related To Dual Connectivity For Enb
    [Documentation]     Modify parameters online related to dual connectivity - ENB
    ...                 verification message needs to be added
    ...                 Creation Date: 10-June-2018
    ...                 Modified Date: 22-Nov-2018  modified to WTS support
    ...                 Last Modified by: shobha.k_reddy@nokia.com
    [Arguments]         ${id}=1     ${x2_gnb_retry_limit}=${None}      ${send_reset_response}=${None}
    ...                 ${scg_dl_dist_percent}=${None}                 ${dud_retx_indication}=${None}
    ...                 ${enable_dud_poll_bit}=${None}                 ${dud_poll_period_in_packet}=${None}
    ...                 ${dud_poll_period_in_ms}=${None}               ${enable_dud_payload}=${None}
    ...                 ${enable_dud_payload_in_polling}=${None}       ${force_nru_sn_jump}=${None}
    ...                 ${enable_dl_data_forwarding}=${None}           ${enable_ul_data_forwarding}=${None}
    ...                 ${use_nr_ran_cont}=${None}                     ${inject_gtpu_error_ind_after_sgnb_release}=${None}
    ...                 ${dl_data_shuffling}=${None}                   ${action}=${None}
    ...                 ${dl_flush_nr_pdpc_pdu_sn}=${None}             ${dl_discard_nr_pdpc_pdu_sn}=${None}
    ...                 ${serv_cell_index}=${None}                     ${menb_failure_scenario}=${None}
    ...                 ${ddds_suspend}=${None}                        ${control_flow_period}=${None}
    ...                 ${desired_buffer_sizes}=${None}                ${dl_data_delivery_success_rate}=${None}
    ...                 ${long_pdcp_pdu_number_comprehension_required}=${None}       ${modify_gtpu_header}=${None}
    lteemu.enb_endc_param    id=${id}     x2_gnb_retry_limit=${x2_gnb_retry_limit}
    ...                 send_reset_response=${send_reset_response}
    ...                 scg_dl_dist_percent=${scg_dl_dist_percent}
    ...                 dud_retx_indication=${dud_retx_indication}
    ...                 enable_dud_poll_bit=${enable_dud_poll_bit}
    ...                 dud_poll_period_in_packet=${dud_poll_period_in_packet}
    ...                 dud_poll_period_in_ms=${dud_poll_period_in_ms}
    ...                 enable_dud_payload=${enable_dud_payload}
    ...                 enable_dud_payload_in_polling=${enable_dud_payload_in_polling}
    ...                 force_nru_sn_jump=${force_nru_sn_jump}
    ...                 enable_dl_data_forwarding=${enable_dl_data_forwarding}
    ...                 enable_ul_data_forwarding=${enable_ul_data_forwarding}
    ...                 use_nr_ran_cont=${use_nr_ran_cont}
    ...                 inject_gtpu_error_ind_after_sgnb_release=${inject_gtpu_error_ind_after_sgnb_release}
    ...                 dl_data_shuffling=${dl_data_shuffling}
    ...                 action=${action}
    ...                 dl_flush_nr_pdpc_pdu_sn=${dl_flush_nr_pdpc_pdu_sn}
    ...                 dl_discard_nr_pdpc_pdu_sn=${dl_discard_nr_pdpc_pdu_sn}
    ...                 serv_cell_index=${serv_cell_index}
    ...                 menb_failure_scenario=${menb_failure_scenario}
    ...                 ddds_suspend=${ddds_suspend}
    ...                 control_flow_period=${control_flow_period}
    ...                 desired_buffer_sizes=${desired_buffer_sizes}
    ...                 dl_data_delivery_success_rate=${dl_data_delivery_success_rate}
    ...                 long_pdcp_pdu_number_comprehension_required=${long_pdcp_pdu_number_comprehension_required}
    ...                 modify_gtpu_header=${modify_gtpu_header}

Trigger UE Dual Connectivity Failure
    [Documentation]    This command will trigger UE Dual Connectivity failure scenario
    [Arguments]    ${ue_cm_id}=1
    lteemu.ue_dc_start_error    ue_cm_id=${ue_cm_id}

Modify Enb Behavior to Trigger Failure During SgNB Addition
    [Documentation]    For triggering failure scenarios during SgNB addition Dual Connectivity procedure
    [Arguments]    ${ue_cm_id}=1    ${gnb_id}=2    ${if_contains}=${None}    ${action}=${None}
    ...    ${sn_status_transfer_timeout}=${None}
    lteemu.enb_cmd_sgnb_add_req_param    ue_cm_id=${ue_cm_id}    gnb_id=${gnb_id}    if_contains=${if_contains}
    ...    action=${action}    sn_status_transfer_timeout=${sn_status_transfer_timeout}

Enb Detach For NSA
    [Documentation]     command used to detach UE
    ...                 Prior to this command LTE Environment should be Up
    ...                 Creation Date: 10-June-2018
    ...                 Modified Date: 22-Nov-2018  modified to WTS support
    ...                 Last Modified by: shobha.k_reddy@nokia.com
    [Arguments]         ${id}=1
    lteemu.Ue Detach    id=${id}
    lteemu.Read Lteemu Output Until Re       expected=UE${id}: detached               timeout=10

Send Hex command
    [Documentation]    command used to send hex dump
    ...                 Creation Date: 31-Jan-2019
    ...                 Modified Date: 31-Jan-2019
    ...                 Last Modified by: madhavi.mada@nokia.com
    [Arguments]        ${hex_msg}    ${source}=enb:1   ${target}=gnb:2
    lteemu.send_hex    source=${source}    target=${target}   msg=${hex_msg}

Send enb param command
    [Documentation]    command used to send end param
    ...                Creation Date: 31-Jan-2019
    ...                Modified Date: 31-Jan-2019
    ...                Last Modified by: madhavi.mada@nokia.com
    [Arguments]        ${id}=1        ${state}=${None}     ${send_extension}=${None}
    lteemu.enb_param   id=${id}    state=${state}    extend_enb_ue_x2ap_id=${send_extension}

Send ue test mode
    [Documentation]    command used to send end param
    ...                Creation Date: 10-Jun-2020
    ...                Modified Date: 10-Jun-2020
    ...                Last Modified by: klaus.schulte@nokia.com
    [Arguments]        ${id}=1      ${profile_index}=0      ${action}=activate     ${testmode}=csi_report_override
    lteemu.ue_testmode_set_param     ${id}    test_mode=${testmode}    action=${action}    profile_index=${profile_index}

Send enb ue dc modify command
     [Documentation]    Command to trigger LTE-NR dual connectivity modification
     ...                Creation Date: 31-Jan-2019
     ...                 Modified Date: 31-Jan-2019
     ...                 Last Modified by: madhavi.mada@nokia.com
     [Arguments]        ${cause}    ${id}=1     ${by}=enb    ${bearer_id}=${None}    ${ambr}=${None}
     lteemu.enb_ue_dc_modify    id=${id}   by=${by}    cause=${cause}    bearer_to_modify=${bearer_id}   ambr=${ambr}
