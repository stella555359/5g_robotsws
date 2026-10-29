*** Settings ***
Documentation
...    Author: sudi Lou
...    Contact: sudi.lou@nokia-sbell.com
...    this file is module case template,you can create your test case according to this template.
...    Please do not modify the file without notification to author

Suite Setup    Run keywords    Common Suite Setup For AIC
...            AND    Config network For Local Env_250
Suite Teardown    Run keywords     Common Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      VRF_HAZ1             #Competence Area
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot


*** Variables ***
@{pdu1_qos_list}    ${3}  ${4}
${carrier_freq_nr_cell1}    636576
${carrier_freq_nr_cell2}    636576
${carrier_freq_nr_cell3}    176210
${carrier_freq_LTE}    1

*** Test Cases ***
Upgrade_airphone_and_wts_build
    [Tags]    upgrade_airphone
    Config Iphy Ip For Local Env_250
    [Teardown]    Case Postcondition For AP

CB013289-PMO#1_T26_Counter_update_for_the_successful_Inter-RAT_handover_with_direct_data_forwarding
    [Tags]    NFTA    TC26
    [Documentation]
    ...    Author: sudi.lou@nokia-sbell.com
	...    Description: This user scenario describes gNB’s behavior when a ‘B2 Measurement Report’ is received from the UE,
	...                 IRAT HO is triggered with direct data forwarding through X2 interface with 5QI1&2.
    [Setup]    Case T26 Precondition
#    Parameter Updated In vCU to Enable QoS Flow Forwarding
#	Parameter Updated In vCU with direct data forwarding by X2
    Start Counter For CB013289_T26
    ${webem_info}    Get WebEM Info    ne_type=vcu
    ${vcu_profile}    Create List    tracerVcu
    ${vcu_trace_id}    Start Capture Log By Dcap    webem_info=${webem_info}    vcu_custom_profile=${vcu_profile}
	UE Register And PDU Session Setup
	UE PDU Session Modify   ue_id=1  pdu=1  qos_flow_list=@{pdu1_qos_list}  by=amf
	Start data traffic on 2 PDU sessions    ue_id=1
	sleep    5s    reason=wait call stable
	Trigger inter-RAT Handover    ue_id=1  phycell_id=11
	sleep    5s    reason=wait call stable
	Stop Trace In DCAP    btsip=${webem_info['host']}
    ${trace_file_path}    Get Trace Log    btsip=${webem_info['host']}
#    Check Emil Log    ${trace_zip_file_path}
#    Log To Console    \ncheck counter
#    wait until keyword succeeds   6min  30s   Collect And Check Counter    product_type=vcu    bts_index=${0}    cudu_index=0
#    ${trace_file_path}    Set Variable    /home/ute/Downloads/11073_10.107.92.20_20240927T013000_start_trace_cell-trace.lcbin
#    Connect To DCAP    ${tl.test_pcs[0].default_ssh_connection_details.addr}    9443    ${None}    ${None}    dcapv3
#    ...    ${TRUE}    dcap-master
#    Check HandoverRequired message in Emil log    ${trace_file_path}    dcap-master
    [Teardown]    Case Postcondition

CB013289-A_US#B1_TC28_PCMD_Monitoring_of_patial_QoS_Flow_forwarding_status_during_IRAT_HO_to_LTE_at_gNB-CU-CP_direct_forwarding
    [Tags]    CRT    TC28
    [Documentation]
    ...    Author: sudi.lou@nokia-sbell.com
	...    Description: This user scenario describes gNB’s behavior when a ‘B2 Measurement Report’ is received from the UE,
	...                 IRAT HO is triggered with direct data forwarding through X2 interface with 5QI1&2.
    [Setup]    Case Precondition
#	Parameter Updated In vCU to Enable QoS Flow Forwarding    5QI1_dataForwarding=noIRATDataFwd   5QI2_dataForwarding=noIRATDataFwd
    Config include_e-rab_ids for eNB
    ${webem_info}    Get WebEM Info    ne_type=vcu
    ${vcu_profile}    Create List    tracerVcu
    ${vcu_trace_id}    Start Capture Log By Dcap    webem_info=${webem_info}    vcu_custom_profile=${vcu_profile}
    UE Register And PDU Session Setup
    UE PDU Session Modify   ue_id=1  pdu=1  qos_flow_list=@{pdu1_qos_list}  by=amf
    Start data traffic on 2 PDU sessions    ue_id=1
    sleep    5s    reason=wait call stable
    Trigger inter-RAT Handover    ue_id=1  phycell_id=11
    sleep    5s    reason=wait call stable
    Stop Trace In DCAP    btsip=${webem_info['host']}
    ${trace_file_path}    Get Trace Log    btsip=${webem_info['host']}
    ${flag}    Set Variable    False
    FOR    ${trace_file}    IN    @{trace_file_path}
        ${flag}    Check Emil Log for TC28    ${trace_file}    ${flag}    dcap-master
        exit for loop if    '${flag}'=='True'
    END
    should be equal    ${flag}    True    Check emil log failed!
    [Teardown]    Case TC28 Postcondition

CB013289-A_US#B2_TC29_PCMD_Monitoring_of_QoS_Flow_forwarding_status_during_IRAT_HO_to_LTE_at_gNB-CU-UP
    [Tags]    CRT    TC29
    [Documentation]
    ...    Author: sudi.lou@nokia-sbell.com
	...    Description: This user scenario describes gNB’s behavior when a ‘B2 Measurement Report’ is received from the UE,
	...                 IRAT HO is triggered with direct data forwarding through X2 interface with 5QI1&2.
    [Setup]    Case Precondition
	Parameter Updated In vCU to Enable QoS Flow Forwarding
    ${webem_info}    Get WebEM Info    ne_type=vcu
    ${vcu_profile}    Create List    tracerVcu
    ${vcu_trace_id}    Start Capture Log By Dcap    webem_info=${webem_info}    vcu_custom_profile=${vcu_profile}
    UE Register And PDU Session Setup
    UE PDU Session Modify   ue_id=1  pdu=1  qos_flow_list=@{pdu1_qos_list}  by=amf
    Start data traffic on 2 PDU sessions    ue_id=1
    sleep    5s    reason=wait call stable
    Trigger inter-RAT Handover    ue_id=1  phycell_id=11
    sleep    5s    reason=wait call stable
    Stop Trace In DCAP    btsip=${webem_info['host']}
    ${trace_file_path}    Get Trace Log    btsip=${webem_info['host']}
    ${flag}    Set Variable    False
    FOR    ${trace_file}    IN    @{trace_file_path}
        ${flag}    Check Emil Log about CUUP    ${trace_file}    ${flag}    dcap-master
        exit for loop if    '${flag}'=='True'
    END
    should be equal    ${flag}    True    Check emil log failed!
    [Teardown]    Case TC28 Postcondition

*** Keywords ***
Case Precondition
    Case Precondition For AP    tag=${none}    product_type=vdu    operation=env_setup_sa
    Common Test Setup For AIC
    Log To Console  \n===Case Precondition Finished===

Case T26 Precondition
    Log To Console  \n===configure eth0 ===
    OperatingSystem.Run    sudo ip addr add 10.97.65.238/32 dev eth0
    OperatingSystem.Run    sudo ip addr add 10.97.65.239/32 dev eth0
    OperatingSystem.Run    sudo ip addr add 10.97.65.240/32 dev eth0
    Log To Console  \n===configure eth3 ===
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/32 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.134/32 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/32 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.136/32 dev eth3
    Case Precondition For AP    tag=TL11073_basic    product_type=vdu    operation=env_setup_sa
    Common Test Setup For AIC
    Log To Console  \n===Case Precondition Finished===

Case Postcondition
    Run Keyword And Ignore Error    Stop Trace In DCAP    btsip=${webem_info['host']}
    Case Postcondition For AP
    Log To Console  \n===Case Postcondition Finished===

Case TC28 Postcondition
#    Parameter Updated In vCU to Enable QoS Flow Forwarding
    Run Keyword And Ignore Error    Stop Trace In DCAP    btsip=${webem_info['host']}
    Case Postcondition For AP
    Common Test Teardown For AIC
    Log To Console  \n===Case Postcondition Finished===

Parameter Updated In vCU to Enable QoS Flow Forwarding
    [Arguments]   ${actInterRatHoDirectDlDataFwd}=IRATDirectDataFwdOnX2
    ...           ${5QI1_dataForwarding}=IRATDataFwd   ${5QI2_dataForwarding}=IRATDataFwd
    ...           ${5QI5_dataForwarding}=IRATDataFwd   ${5QI7_dataForwarding}=IRATDataFwd
    @{para_list}          Create List    actInterRatHoSADlDataForward    actInterRatHoDirectDlDataFwd    iRatDataForwardingMethod
    ...                                  dataForwarding    dataForwarding    dataForwarding    dataForwarding
    @{mo_list_vcu}        Create List    MRBTS-11073/NRBTS-11073    MRBTS-11073/NRBTS-11073    MRBTS-11073/NRBTS-11073/NRADJECELL-1
	...                                  MRBTS-11073/NRBTS-11073/NRDRB_5QI-1    MRBTS-11073/NRBTS-11073/NRDRB_5QI-2
	...                                  MRBTS-11073/NRBTS-11073/NRDRB_5QI-5    MRBTS-11073/NRBTS-11073/NRDRB_5QI-7
    @{value_list_true}    Create List    true    ${actInterRatHoDirectDlDataFwd}    directDataFwd    ${5QI1_dataForwarding}
	...                                  ${5QI2_dataForwarding}    ${5QI5_dataForwarding}    ${5QI7_dataForwarding}
	Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vcu}    product_type=vcu

Config include_e-rab_ids for eNB
    Execute Egate Command    cmd=gnb_param id=4 include_e-rab_ids=0,1
#    Execute Egate Command    cmd=gnb_param id=4 include_e-rab_ids=none

UE Register And PDU Session Setup
    [Arguments]    ${ue_id}=1
    Execute Egate Command    cmd=ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    sleep    5s
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    sleep    5s
	UE PDU Session Setup    ue_id=1  pdu=1  gw=1  pass_regexp=Initial Context Setup Successful
    sleep    5s
	Execute Egate Command    cmd=qosflow_modify qos_flow=2 default=on
	sleep    5s
	UE PDU Session Setup    ue_id=1  pdu=2  gw=2  pass_regexp=Pdu Session.*successfully
	Execute Egate Command    cmd=qosflow_modify qos_flow=1 default=on

UE PDU Session Modify
    [Documentation]
    ...    Added additional qos flows to pdu session of an UE. By default adds flows 3, which are pre-configured in
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
    ${default_qos_list}   Create List   ${3}
    ${qos_flow_list}      Set Variable If   ${qos_flow_list}   ${qos_flow_list}   ${default_qos_list}

    FOR   ${qos_parameter}   IN   @{qos_flow_list}
        ${cmd1}    Catenate    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qos_parameter} by=${by}
        Execute Egate Command    cmd=${cmd1}    pass_regexp=${pass_regexp}
        sleep    5s
    END
    sleep    5s

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
#    Execute Egate Command    cmd=${cmd1}    pass_regexp=${pass_regexp}
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
          Start data traffic in egate   ue_id=${ue_id}   direction=dl   protocol=udp   trf_id=${trf_id}   pdu=${pdu}   qfi=${qfi}   mbps=2
    END

Stop data traffic on 2 PDU sessions
    [Arguments]   ${ue_id}=1
    FOR   ${trf_id}    ${pdu}    ${qfi}          IN
    ...   1            1         1
    ...   2            1         2
    ...   3            1         3
    ...   1            2         1
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


Trigger inter-RAT Handover
    [Arguments]  ${ue_id}=1    ${phycell_id}=11
    Send A2 Measurement    ue_id=${ue_id}
    Sleep   5s
    Send B2 Measurement And Attempt Handover    ue_id=${ue_id}    phycell_id=${phycell_id}

Send A2 Measurement
    [Arguments]  ${ue_id}=1
	${meas_id_A2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrier_freq_nr_cell1}    event_type=A2
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A2} event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    ${output}=    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${cmd}
    ...                   pass_regexp=${None}
    ...                   timeout=100s

Send B2 Measurement And Attempt Handover
    [Arguments]  ${ue_id}=1    ${phycell_id}=11
    ${meas_id_B2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}
    ...    carrierfreq=${carrier_freq_LTE}    event_type=B2    carrierfreq_rat=EUTRAN
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_B2} event=B2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    ...   phycell_id=${phycell_id} nrsrp_nr=70 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=70:30:0
    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${cmd}
    ...                   pass_regexp=Received HandoverNotify
    ...                   timeout=100s

Start Traffic In AP
    ${traffic_info_dic}    Create Dictionary    call_type=SA    ue_id=1    bearer_id=2    dir=dlul
    ...                                     pdu_id=1    time_len=5s    trf_id=1    mbps_ul=5m    mbps_dl=135m
    ...                                     qfi_id=1    time=999    type=l3    profile_id=1
    ...                                     gnb_id=0    cell_id=1    protocol=udp
    AP Traffic    operation=start_traffic    traffic_info_dic=${traffic_info_dic}

Stop Traffic In AP
    ${traffic_info_dic}    Create Dictionary    ue_id=1    bearer_id=2    dir=dl    trf_id=1
    AP Traffic    operation=stop_traffic    traffic_info_dic=${traffic_info_dic}

Start Counter For CB013289_T26
    ${MRBTS_ID}    Set Variable   ${MRBTS_ID_list}[0]
    ${dim_dn_base}    Set Variable   MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}

    ${M55337C00_rule1}    Catenate    Distname: ${dim_dn_base}; Counter: M55337C00001; Counter rule: max(M55337C00001)>0;
    ${M55337C00_rule2}    Catenate    Distname: ${dim_dn_base}; Counter: M55337C00002; Counter rule: max(M55337C00002)>0;
    ${M55337C00_rule3}    Catenate    Distname: ${dim_dn_base}; Counter: M55337C00005; Counter rule: max(M55337C00005)>0;
    ${M55337C00_rule4}    Catenate    Distname: ${dim_dn_base}; Counter: M55337C00007; Counter rule: max(M55337C00007)>0;

    ${M55337C01_rule1}    Catenate    Distname: ${dim_dn_base}; Counter: M55337C01001; Counter rule: max(M55337C01001)>0;
    ${M55337C01_rule2}    Catenate    Distname: ${dim_dn_base}; Counter: M55337C01002; Counter rule: max(M55337C01002)>0;
    ${M55337C01_rule3}    Catenate    Distname: ${dim_dn_base}; Counter: M55337C01005; Counter rule: max(M55337C01005)>0;
    ${M55337C01_rule4}    Catenate    Distname: ${dim_dn_base}; Counter: M55337C01007; Counter rule: max(M55337C01007)>0;

    ${rule1}    Catenate    Distname: ${dim_dn_base}/NRCELL-1; Counter: M55125C02001; Counter rule: max(M55125C02001)>0
    ${rule2}    Catenate    Distname: ${dim_dn_base}/NRCELL-1; Counter: M55125C02002; Counter rule: max(M55125C02002)>0

    ${rule3}    Catenate    Distname: ${dim_dn_base}/NRCELL-1; Counter: M55125C00048; Counter rule: max(M55125C00048)>0
    ${rule4}    Catenate    Distname: ${dim_dn_base}/NRCELL-1; Counter: M55125C00049; Counter rule: max(M55125C00049)>0

    ${rule5}    Catenate    Distname: ${dim_dn_base}/NRCELL-1/NRPMQAP-1; Counter: M55352C00007; Counter rule: max(M55352C00007)>0
    ${rule6}    Catenate    Distname: ${dim_dn_base}/NRCELL-1/NRPMQAP-1; Counter: M55352C00008; Counter rule: max(M55352C00008)>0

    ${rule_list}    Create List    ${M55337C00_rule1}    ${M55337C00_rule2}    ${M55337C00_rule3}    ${M55337C00_rule4}
    ...                            ${M55337C01_rule1}    ${M55337C01_rule2}    ${M55337C01_rule3}    ${M55337C01_rule4}
    ...                            ${rule1}    ${rule2}    ${rule3}    ${rule4}    ${rule5}    ${rule6}
    Start Counter    rule_list=${rule_list}    product_type=vcu    bts_index=0

Open DCAP
    OperatingSystem.Run    DCAP_Basic_controller start

Get WebEM Info
    [Arguments]    ${ne_type}=vdu   ${gnb_index}=0    ${vdu_index}=0
    ${oam_httpaddr}    Set Variable If    '${ne_type.upper()}'=='VDU'
    ...                 ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ...                                   '${ne_type.upper()}'=='VCU'
    ...                 ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}

    ${oam_web_ip}    set variable if    ':' in '''${oam_httpaddr}'''   [${oam_httpaddr}]    ${oam_httpaddr}
    &{webem_info}=    create dictionary    host=${oam_web_ip}    username=Nemuadmin    password=Nokia@123    port=443
    Set Test Variable    ${webem_info}
    [return]    ${webem_info}

Start Capture Log By Dcap
    [Arguments]    ${webem_info}=${None}    ${vdu_custom_profile}=${None}   ${vcu_custom_profile}=${None}
    Connect To DCAP    ${tl.test_pcs[0].default_ssh_connection_details.addr}    9443    ${None}    ${None}    dcapv3
    ...    ${TRUE}    dcap-master
    Make Sure BTS Integrated In DCAP    bts_dic=${webem_info}

    ${trace_id}    Run Keyword If   '''${vdu_custom_profile}'''!='''${None}'''
    ...         Start Trace In DCAP    ${webem_info}    vdu_custom_profile=${vdu_custom_profile}
    ...  ELSE IF  '''${vcu_custom_profile}'''!='''${None}'''
    ...         Start Trace In DCAP    ${webem_info}    vcu_custom_profile=${vcu_custom_profile}
    Log To Console     Trace Collection start on DCAP
    [Return]    ${trace_id}

Get Trace Log
    [Arguments]    ${btsip}
    ${trace_file_path}    Download Trace File    btsip=${btsip}
    @{zip_file_name}    OperatingSystem.List Files In Directory    ${trace_file_path}    *.zip
    ${zip_file_path}    Set Variable    ${trace_file_path}/${zip_file_name[0]}
    ${target_dir}=    Join Path  ${trace_file_path}  unzip-files
    ${log_file_paths}    Extract log from trace file    tti_archive=${zip_file_path}    directory=${target_dir}    postfix=.lcbin
    [Return]    ${log_file_paths}

Check Emil Log for TC26
    [Arguments]    ${trace_file}    ${connection}
#    [Arguments]    ${trace_file}    ${message_filter}    ${message_key}    ${connection}
    ${message_filter}    Create List    User data=NgAP: HandoverRequired
    ${json_file_path}    Get Emil Decoded Data In Json    file_path=${trace_file}    connection=${connection}
        ...                filter=${message_filter}
    Check Message In JSON File    ${json_file_path}

Check HandoverRequired message in Emil log
    [Arguments]    ${trace_file}    ${connection}
    ${message_filter}    Create List    User data=NgAP: HandoverRequired
    ${json_file_path}    Get Emil Decoded Data In Json    file_path=${trace_file}    connection=${connection}
        ...                filter=${message_filter}

    ${parsed_json}    OperatingSystem.Get File    ${json_file_path}
    ${context_dict}    json.Loads    ${parsed_json}
#    ${flag}    Set Variable    False
    ${trace_info}=    Set Variable    ${context_dict}[emil_data][rows]
    FOR    ${trace}    IN    @{trace_info}
#        ${return_info}    Run Keyword And Ignore Error    Check Jsoncontent in Emil Log    ${trace}
        ${trace_info}=    Set Variable    ${trace}[JsonContent][0]
#    ${record_data}=    Set Variable    ${trace_info}[NGAP-PDU][initiatingMessage][data]
#    ${trigger}=    Set Variable    ${record_data}[trigger]
#    ${result}=    Set Variable    ${record_data}[result]
#    ${modified_pdu_sessions}=    Set Variable    ${record_data}[modifiedPduSessionResources]
#
#    Should Be Equal    ${trigger}    pduSessionResourceModifyOperation
#    Should Be Equal    ${result}    success
#
#    ${pdu_session1_qfis}    Create List    ${1}    ${2}    ${3}
#    ${pdu_session2_qfis}    Create List    ${1}
#    FOR    ${session}    IN    @{modified_pdu_sessions}
#        ${pdu_session_id}=    Set Variable    ${session}[pduSessionId]
#        ${forwarding_qos_flows}=    Set Variable    ${session}[forwardingQosFlows]
#        ${qfi_info}    Get qfi id in forwardingQosFlows list    ${forwarding_qos_flows}
#        Run Keyword If    ${pdu_session_id}==1    Should Be Equal    ${pdu_session1_qfis}    ${qfi_info}
#        ...    ELSE IF    ${pdu_session_id}==2    Should Be Equal    ${pdu_session2_qfis}    ${qfi_info}
#    END
#
#        ${flag}=    set variable if    '${return_info[0]}'=='PASS'    True
#        exit for loop if    '${flag}'=='True'
    END
#    should be equal    ${flag}    True    Check emil log failed!

Check Emil Log for TC28
    [Arguments]    ${trace_file}    ${flag}    ${connection}
    ${message_filter}    Create List    User data=CU: PduSessionResourceInfoTraceRecord
    ${json_file_path}    Get Emil Decoded Data In Json    file_path=${trace_file}    connection=${connection}
        ...                filter=${message_filter}

    ${parsed_json}    OperatingSystem.Get File    ${json_file_path}
    ${context_dict}    json.Loads    ${parsed_json}
    ${trace_info}=    Set Variable    ${context_dict}[emil_data][rows]
    FOR    ${trace}    IN    @{trace_info}
        ${return_info}    Run Keyword And Ignore Error    Check PDU Session Resource Info Record    ${trace}
        ${flag}=    set variable if    '${return_info[0]}'=='PASS'    True
        exit for loop if    '${flag}'=='True'
    END
    [Return]    ${flag}

Check PDU Session Resource Info Record
    [Arguments]    ${emil_data}
    ${JsonContent_info}=    Set Variable    ${emil_data}[JsonContent][1]
    ${record_data}=    Set Variable    ${JsonContent_info}[CuVendorExtensionRecordDataType][pduSessionResourceInfoRecord][data]

    ${trigger}=    Set Variable    ${record_data}[trigger]
    ${result}=    Set Variable    ${record_data}[result]
    ${forwardingTarget}=    Set Variable    ${record_data}[forwardingTarget]
    ${forwardingType}=    Set Variable    ${record_data}[forwardingType]
    ${modified_pdu_sessions}=    Set Variable    ${record_data}[modifiedPduSessionResources]

    Should Be Equal    ${trigger}    handover
    Should Be Equal    ${result}    success
    Should Be Equal    ${forwardingTarget}    eutran
    Should Be Equal    ${forwardingType}    direct

    ${expected_include_qfis}    Create List    ${1}    ${1}
    ${expected_include_eradids}    Create List    ${0}    ${1}
    ${expected_refused_qfis}    Create List    ${2}    ${3}
    ${expected_refused_eradids}    Create List    ${2}    ${3}
    ${actual_include_qfis}    Create List
    ${actual_include_eradids}    Create List
    ${actual_refused_qfis}    Create List
    ${actual_refused_eradids}    Create List
    FOR    ${session}    IN    @{modified_pdu_sessions}
        ${pdu_session_id}=    Set Variable    ${session}[pduSessionId]

        ${forwarding_qos_flows}=    Set Variable    ${session}[forwardingQosFlows]
        ${qfi_info}    ${erabId_info}    Get qfi and erabId in forwardingQosFlows list    ${forwarding_qos_flows}
        ...                           ${actual_include_qfis}     ${actual_include_eradids}

        exit for loop if    '${pdu_session_id}'=='2'

        ${forwarding_refused_qos_flows}=    Set Variable    ${session}[forwardingRefusedQosFlows]
        ${refused_qfi_info}    ${refused_erabId_info}    Get qfi and erabId in forwardingQosFlows list    ${forwarding_refused_qos_flows}
        ...                                              ${actual_refused_qfis}    ${actual_refused_eradids}
    END
    Sort List    ${actual_include_qfis}
    Sort List    ${actual_include_eradids}
    Sort List    ${actual_refused_qfis}
    Sort List    ${actual_refused_eradids}
    Should Be Equal    ${expected_include_qfis}    ${actual_include_qfis}
    Should Be Equal    ${expected_include_eradids}    ${actual_include_eradids}
    Should Be Equal    ${expected_refused_qfis}    ${actual_refused_qfis}
    Should Be Equal    ${expected_refused_eradids}    ${actual_refused_eradids}

Get qfi and erabId in forwardingQosFlows list
    [Arguments]    ${forwarding_qos_flows}    ${qfi_list}    ${erabId_list}
    FOR    ${flow_info}    IN    @{forwarding_qos_flows}
        ${qfi}=    Set Variable    ${flow_info}[qfi]
        ${erabId}=    Set Variable    ${flow_info}[erabId]
        append to list    ${qfi_list}    ${qfi}
        append to list    ${erabId_list}    ${erabId}
    END
    [Return]   ${qfi_list}    ${erabId_list}

Check Emil Log
    [Arguments]    ${trace_file}    ${connection}
#    [Arguments]    ${trace_file}    ${message_filter}    ${message_key}    ${connection}
    ${message_filter}    Create List    User data=CU: PduSessionResourceInfoTraceRecord
    ${json_file_path}    Get Emil Decoded Data In Json    file_path=${trace_file}    connection=${connection}
        ...                filter=${message_filter}
#    ${expected_message}    Set Variable    "trigger": "handover"
    Check Message In JSON File    ${json_file_path}
#    Check Message In JSON File    ${json_file_path}    ${expected_message}
#    Check Message In JSON File    ${json_file_path}    forwardingType
#    User data=CU: PduSessionResourceInfoTraceRecord #view=message
#    files/v1/session1/1000/0?selectrow=OriginalRowIndex=6&tree=n&msgjsoncontent=n&msgtextcontent=y&view=trace
     #msgtextcontent=y&view=trace

Check Emil Log about CUUP
    [Arguments]    ${trace_file}    ${flag}    ${connection}
#    [Arguments]    ${trace_file}    ${message_filter}    ${message_key}    ${connection}
    ${message_filter}    Create List    User data=CUUP: CuUpPduSessionResourceInfoTraceRecord
    ${json_file_path}    Get Emil Decoded Data In Json    file_path=${trace_file}    connection=${connection}
        ...                filter=${message_filter}

    ${parsed_json}    OperatingSystem.Get File    ${json_file_path}
    ${context_dict}    json.Loads    ${parsed_json}
    ${trace_info}=    Set Variable    ${context_dict}[emil_data][rows]
    FOR    ${trace}    IN    @{trace_info}
        ${return_info}    Run Keyword And Ignore Error    Check Jsoncontent in Emil Log    ${trace}
        ${flag}=    set variable if    '${return_info[0]}'=='PASS'    True
        exit for loop if    '${flag}'=='True'
    END
    [Return]    ${flag}

Check Jsoncontent in Emil Log
    [Arguments]    ${emil_data}
    ${trace_info}=    Set Variable    ${emil_data}[JsonContent][1]
    ${record_data}=    Set Variable    ${trace_info}[CuUpVendorExtensionRecordDataType][pduSessionResourceInfoRecord][data]
    ${trigger}=    Set Variable    ${record_data}[trigger]
    ${result}=    Set Variable    ${record_data}[result]
    ${modified_pdu_sessions}=    Set Variable    ${record_data}[modifiedPduSessionResources]

    Should Be Equal    ${trigger}    pduSessionResourceModifyOperation
    Should Be Equal    ${result}    success

    ${pdu_session1_qfis}    Create List    ${1}    ${2}    ${3}
    ${pdu_session2_qfis}    Create List    ${1}
    FOR    ${session}    IN    @{modified_pdu_sessions}
        ${pdu_session_id}=    Set Variable    ${session}[pduSessionId]
        ${forwarding_qos_flows}=    Set Variable    ${session}[forwardingQosFlows]
        ${qfi_info}    Get qfi id in forwardingQosFlows list    ${forwarding_qos_flows}
        Run Keyword If    ${pdu_session_id}==1    Should Be Equal    ${pdu_session1_qfis}    ${qfi_info}
        ...    ELSE IF    ${pdu_session_id}==2    Should Be Equal    ${pdu_session2_qfis}    ${qfi_info}
    END

Get qfi id in forwardingQosFlows list
    [Arguments]    ${forwarding_qos_flows}
    ${qfi_list}    Create List
    FOR    ${qfi_info}    IN    @{forwarding_qos_flows}
        ${qfi}=    Set Variable    ${qfi_info}[qfi]
        append to list    ${qfi_list}    ${qfi}
    END
    [Return]   ${qfi_list}
