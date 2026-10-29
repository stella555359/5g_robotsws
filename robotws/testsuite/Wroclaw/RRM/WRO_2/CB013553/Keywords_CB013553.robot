*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Damian Rzeczkowski
...              :contact: rzeczkowski.damian@gmail.com

Library      ta_pcmd.tshark_plugin_configurator
Library      ta_pcmd
Library      String
Library      taf.sbts.oam.coam.admin    WITH NAME    coam
Library      ute_wtssim
Library      ta5g_testline_management
Library      ta5g_tshark
Library      ta5g_ue_mobility
Library      ta5g_throughput
Library      ta5g_scfc_analysis
Library      ta5g_egate
Library      ta5g_commissioning
Library      ta5g_iphy
Library      ta5g_cell_operations
Library      ../resources/common_functions.py
Library      ../CB008490/resources/common_keywords.py
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/testline_configuration.robot
Resource     ../keywords/tshark_verifying.robot


*** Keywords ***
Attach UE And Establish PDU Session
    [Arguments]    ${ue_id}    ${cell_id}    ${pdu_id}    ${gw_id}
    Execute Egate Command    cmd=ue_change_location id=${ue_id} cell=${cell_id}
    Execute Egate Command    cmd=ue_register id=${ue_id}
    Sleep    3
    Set Internal Traffic Type To UE    ue_id=${ue_id}    pdu_id=${pdu_id}
    Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id}
	Sleep    3

Set Internal Traffic Type To UE
    [Arguments]    ${ue_id}    ${pdu_id}
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

Verify SCell Addition Messages For 6CC For TDD PCell
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE}    continue_on_failure=False
    tshark_verifying.Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_BE_SETUP_MOD_LIST_TDD_PCell}        continue_on_failure=False
    tshark_verifying.Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_ADD_MOD_LIST_TDD_PCell}             continue_on_failure=False

Verify SCell Addition Messages For 6CC For FDD PCell
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE}    number_of_messages=2    continue_on_failure=False
    tshark_verifying.Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_BE_SETUP_MOD_LIST_FDD_PCell}        number_of_messages=2
    ...                                                                                                        continue_on_failure=False
    tshark_verifying.Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_ADD_MOD_LIST_FDD_PCell}             continue_on_failure=False

Verify ULTxSwitching On TDD PCell and FDD Scell
    tshark_verifying.Verify Tcpdump Log    packet_filter=${ultxswithing_on_TDD_PCell}    continue_on_failure=False
    tshark_verifying.Verify Tcpdump Log    packet_filter=${ultxswitching_on_FDD_SCell}    continue_on_failure=False

Verify ULTxSwitching On FDD PCell and TDD Scell
    tshark_verifying.Verify Tcpdump Log    packet_filter=${ultxswithing_on_FDD_PCell}    continue_on_failure=False
    tshark_verifying.Verify Tcpdump Log    packet_filter=${ultxswitching_on_TDD_SCell}    continue_on_failure=False

Verify Counters for CB013553
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55181C00014    >0    ACC_NUM_UL_2TX_SW_OP1_UE_CAP
    ...    M55118C00112    >0    ACC_NUM_UL_2TX_SW_OP1_UE_CONFG
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...    M55181C00014    >0    ACC_NUM_UL_2TX_SW_OP1_UE_CAP
    ...    M55118C00112    >0    ACC_NUM_UL_2TX_SW_OP1_UE_CONFG
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-7
    ...    file_path=${pm_counter_file}

Start UL Tput on UE1
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 trf_id=1 dir=ul mbps=175

Start UL Tput on UE2
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=2 trf_id=2 dir=ul mbps=175

Trigger A1 Measurement
    [Arguments]    ${ue_id}    ${meas_id}    ${srsrp_nr}    ${srsrq_nr}    ${timeout}=60
    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id\=${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${meas_id} event\=A1 srsrp_nr\=${srsrp_nr} srsrq_nr\=${srsrq_nr}
    ...    pass_regexp=message c1 : rrcReconfigurationComplete
    ...    timeout=${timeout}

Release Multiple UEs Without Confirmation
    [Arguments]    ${number_of_ues}
    ${number_of_simulated_ues_increased_by_one} =    Evaluate    ${number_of_ues}+1
    FOR    ${ue_id}    IN RANGE    1    ${number_of_simulated_ues_increased_by_one}    1
        ${pdu_id_eval}=  Evaluate  (${ue_id} % 14)+1
        Execute Egate Command    cmd=ue_pdu_session_release ue=${ue_id} pdu=${pdu_id_eval} by=amf
        Sleep    1
        Execute Egate Command    cmd=ue_deregister id=${ue_id} by=ue ue_deregister_type=switch_off
    END

Start Listening On TCE Port
    ${tce_port}=    Get TCE Port
    Turn On Netcat    options=-l  ip=  port=${tce_port}
    Sleep    30s    # Break needed for proper enabling Netcat to listening messages on NRPPA

Get TCE Port
    ${tce_port_param_in_list}=    Create List        tcePortNumber
    coam.Setup Admin
    ${tce_list} =    coam.Get Parameter By Class    class_name=TCE    parameter_list=@{tce_port_param_in_list}
    [Return]    ${tce_list[0]['parameters']['tcePortNumber']}
    [Teardown]    Run Keywords    coam.Teardown Admin

Get TCE IP
    ${tce_ip_param_in_list}=    Create List        tceIpAddress
    coam.Setup Admin
    ${tce_list} =    coam.Get Parameter By Class    class_name=TCE    parameter_list=@{tce_ip_param_in_list}
    [Return]    ${tce_list[0]['parameters']['tceIpAddress']}
    [Teardown]    Run Keywords    coam.Teardown Admin

Stop Listening On TCE Port
    Turn Off Netcat

Start Subscriber Trace
    [Arguments]    ${ue_id}=1
    ${tce_ip}=    Get TCE IP
    ${start_trace_cmd}=    Catenate    ng_ue_trace_start    id=${ue_id}    trace_plmn=310:260    trace_ref_id=1    trace_rec_session_ref_id=2
    ...                                ifaces_to_trace=E1,F1-C,NG-C,Uu,Xn-C    trace_depth=maximum tce_ip=${tce_ip}
    Execute Egate Cmd    cmd=${start_trace_cmd}

Stop Subscriber Trace
    [Arguments]    ${ue_id}=1
    Execute Egate Cmd    cmd=ng_ue_trace_stop id=${ue_id} trace_plmn=310:260 trace_ref_id=1 trace_rec_session_ref_id=2

Stop Vm Ethernet Interfaces
    ${tce_ip}=    Get TCE IP
    ${tce_ip_last_octet}=    Fetch From Right    string=${tce_ip}    marker=.
    @{eth3_ips}=    Create List    ${tce_ip_last_octet}    101    102
    Stop Interfaces    eth=eth3    ips_range=${eth3_ips}

Attach SA UE And Establish PDU Session
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${pdu_id}=1    ${gw_id}=1
    Log  \n==== Attach SA UE And Establish PDU Session ====  console=True
    Execute Egate Command    cmd=ue_change_location id=${ue_id} cell=${cell_id}
    Execute Egate Command    cmd=ue_register id=${ue_id} mode=ccsrt
    Sleep    3
    Set Internal Traffic Type To UE    ue_id=${ue_id}    pdu_id=${pdu_id}
    Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id}
	Sleep    3

Start Tshark For TCE Msgs And Store Alias
    ${tce_alias}=    Start Tshark For Custom Interface    eth_interface=eth3    log_dirpath=${None}  log_filename_prefix=TCE
    ...                                                   capture_filter=tcp    preferences=None
    Set Test Variable    ${tce_alias}    ${TCE_ALIAS}

Start Vm Ethernet Interfaces
    ${tce_ip}=    Get TCE IP
    ${tce_ip_last_octet}=    Fetch From Right    string=${tce_ip}    marker=.
    @{eth3_ips}=    Create List    ${tce_ip_last_octet}    101    102
    Configure Interfaces    eth=eth3    ips_range=${eth3_ips}

Prepare Test Setup For One Real Gnb
    [Arguments]    ${tc_id}    ${iphy}=IPHY    ${scfc}=SCFC    ${cfg}=cfg
    ${iphy}=    Create Config File Path Variable Name     filetype=${iphy}    name=${tc_id}
    ${scfc}=    Create Config File Path Variable Name     filetype=${scfc}    name=${tc_id}
    ${cfg}=     Create Config File Path Variable Name     filetype=${cfg}     name=${tc_id}

    ${iphy_filename}=    Get Variable Value    ${iphy}
    ${scfc_filename}=    Get Variable Value    ${scfc}
    ${cfg_filename}=     Get Variable Value    ${cfg}
    Run Keywords
    ...                Update And Put Iphy Xml         input_filepath=${iphy_filename}
    ...    AND         Find Scfc And Fix And Send Full Commissioning    scfc_filename=${scfc_filename}
    ...    AND         Reset Wts
    ...    AND         Check Radios Availability
    ...    AND         Start Vm Ethernet Interfaces
    ...    AND         Reach Onair    lua_cfg=${cfg_filename}

Wait ${x:\d+}s To Reset Wts
    Sleep    ${x}s

Start Specific Data UL Traffic
    [Arguments]    ${ue_id}    ${pdu_id}    ${qfi}=1    ${mbps_per_trf_id}=175    ${first_trf_id}=1    ${last_trf_id}=8
    Log  \n==== Start Full UL througput ====  console=True
    FOR    ${INDEX}  IN RANGE    ${first_trf_id}   ${last_trf_id}+1
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} trf_id=${INDEX} dir=ul mbps=${mbps_per_trf_id}
    END

Validate Trace Recording Session Elements SBA
    [Arguments]   ${filter}    ${alias}=${TCE_ALIAS}    ${number_of_messages}=1    ${timeout}=60
    Log  \n==== Validate Trace Recording Sesion Elements SBA ====  console=True
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${alias}
    ...    packet_filter=nsetapx.traceActivationType == 1 && ${filter}
    ...    number_of_messages=${number_of_messages}
    ...    timeout=${timeout}

Validate Trace Recording Session Elements MBA
    [Arguments]   ${filter}    ${alias}=${TCE_ALIAS}    ${number_of_messages}=1    ${timeout}=60
    Log  \n==== Validate Trace Recording Sesion Elements MBA ====  console=True
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${alias}
    ...    packet_filter=nsetapx.traceActivationType == 0 && ${filter}
    ...    number_of_messages=${number_of_messages}
    ...    timeout=${timeout}

Get PUSCH UE Stats from Egate
    Execute egate command and wait for data    cmd=ue_stats_nr id=1 scell=0-5 type=pusch

Flush Egate Logs
    Execute egate command   cmd=set_log flush
    Sleep    10
