*** Settings ***
Documentation
...             author:                 Wojciech Gicala, wojciech.gicala@nokia.com
...                                     Nelsandro Sampaio, nelsandro.sampaio@nokia.com
...
...             maintainer:             Wojciech Gicala, wojciech.gicala@nokia.com
...                                     Nelsandro Sampaio, nelsandro.sampaio@nokia.com

Library      String
Library      OperatingSystem
Library      ta5g_tshark
Library      ute_fsmaccess
Library      ta5g_pm_counters           WITH NAME     pmcounter
Library      ta5g_commissioning
Library      taf.wts.config
Library      taf.config.wts              WITH NAME    wtscfg
Library      taf.collectors.l2stream3    WITH NAME    l2stream3
Library      taf.transport.ssh           WITH NAME    taf_ssh
Library      taf.wts.runner              WITH NAME    wtsrunner
Library      taf.collectors.core         WITH NAME    core
Library      taf.collectors.tcpdump      WITH NAME    tcpdump
Library      taf.converters.sherpa       WITH NAME    sherpa
Library      taf.analyzer.sherpa         WITH NAME    sherpa_analyzer
Library      taf.sbts.oam.coam.admin     WITH NAME    admin
Library      RunnerExtension.py
Library      CB007090-library.py
Variables    ta5g_global_var

*** Variables ***
&{AP_ASIK}     Ip=192.168.200.1    Username=toor4nsn    Password=oZPS0POrRieRtu    Connection=ApAsik
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}             /opt/wts/latest
${DEFAULT_WTS_CFG}     /opt/wts/latest/basic_setup.cfg
${BIP_PATH}           ${OUTPUT_DIR}/bip_logs

*** Keywords ***
Wait till gNB is ready
    admin.Connect To
    Wait Until Keyword Succeeds    15min    30sec    Check gNB general state
    Sleep                          30s    reason=problems with cell setup on AP
    [Teardown]    admin.Teardown

Check gNB general state
    ${bts_state}                  admin.Get Mrbts State
    ${bts_hw_info}                admin.Get Bts Info
    ${cells_info}                 admin.Get Cells Info
    ${radio_state}                Set Variable
    ...                           ${bts_hw_info['radioModules']['rmod'][0]['status']['proceduralStatus']}
    ${procedural_status}          Set Variable    ${cells_info[0]['status']['proceduralStatus']}
    Log to Console                [INFO] BTS STATE : ${bts_state}
    Should Contain Any            ${bts_state}    Configured    IntegratedToRan    onAir    ignore_case=${TRUE}
    Log to Console                [INFO] RADIO STATE : ${radio_state}
    Should Be Equal As Strings    ${radio_state}    Configured    ignore_case=${TRUE}
    Log to Console                [INFO] CELL STATE : ${procedural_status}
    Should Contain Any            ${procedural_status}    Configured    onAir    ignore_case=${TRUE}

Change WTS nr_arfcn
    wtscfg.Load Wts Cfg    ${DEFAULT_WTS_CFG}
    wtscfg.Modify          set_cell id=1 gnb=2      nr_arfcn=633364:633364
    wtscfg.Modify          set_cell id=2 gnb=2      nr_arfcn=633364:633364
    wtscfg.Save Wts Cfg    ${DEFAULT_WTS_CFG}

Prepare WTS config files for Multiple UEs SA
    [Documentation]      Add Multiple SA UEs to WTS config files
    Load Cfg     ${DEFAULT_WTS_CFG}
    Add Ue      ue_id=2-10
    ...         ue_type=SA
    ...         change_sec_key=${False}
    ...         sec_key=0102030405060708090A0B0C0D0EFF00
    ...         uec=1
    Save Cfg    ${DEFAULT_WTS_CFG}

Start WTS Applications and Reach OnAir state
    [Documentation]    Start WTS till it reach OnAir
    [Arguments]        ${wts_cfg_file}=${DEFAULT_WTS_CFG}
    Stop Edaemon and Egate process
    Configure UTE ETH3 interface
    Connect to virtual machine
    initialize egate      edaemon_egate_ssh_alias=${WTS.Connection}
    ...                   dir_path=${WTS_DIR}
    ...                   edaemon_port=22222
    ...                   egate_port=20000
    ...                   egate_console_ip=${WTS.Ip}
    ...                   sudo_pass=ute
    ...                   wts_file=${wts_cfg_file}


Modify dedicated aggregation level to ${al} on BWP-${bwp}
    admin.Setup admin
    admin.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-1/NRBTS-1/BWP_PROFILE-${bwp}/PDCCH-1
    ...    parameter=dciDedicatedAggregationLevel
    ...    operation=update
    ...    value=${al}
    ...    skip_parameter_relation_errors=True
    admin.Teardown admin


Close All WTS connections
    RunnerExtension.kill_wts_processes      wts_connection=${WTS.Connection}


Report CQI with index ${nr_cqi_index} for UEs with the following IDs: ${list_of_ue_ids}
    [Documentation]   Report CQI for multiple UEs
    ...   Usage example - Report CQI with index 13 for UEs with the following IDs: 1, 2, 3, 4
    report_cqi_for_multiple_ues        string_of_ids=${list_of_ue_ids}
    ...                                nr_cqi_index=${nr_cqi_index}


Report CQI ${cqi} for UE-${ue_id}
    report_cqi    ue_id=${ue_id}
    ...           cqi_nr=${cqi}


Convert Pcap To Sherpa Csv
    [Arguments]                ${log_dir}
    ${executor}=  Create Dictionary
    ...  host=${tl.test_pc.default_ssh_connection_details.addr}
    ...  user=${tl.test_pc.default_ssh_connection_details.username}
    ...  password=${tl.test_pc.default_ssh_connection_details.password}
    sherpa.Create Sherpa Converter
    ...    name=sherpa
    ...    executor=${executor}
    ...    sudo_password=ute
    ...    file_path_pattern=${log_dir}/l2stream3/tcpdump/*.pcap
    ...    output_path=${log_dir}/
    sherpa.Setup       sherpa
    sherpa.Convert     sherpa
    sherpa.Teardown    sherpa


Setup Sherpa Trace
    [Arguments]    ${name}=l2stream3
    Variable Should Exist    ${ENB_BRANCH}
    ...    msg=Please execute test with parameter -v ENB_BRANCH:SBTSxxx specifying correct branch
    ${release}    Set Variable If    '${ENB_BRANCH}' == 'SBTS00'    SBTS22R3    ${ENB_BRANCH}
    ${executor}=  Create Dictionary
    ...  host=192.168.255.129
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    ...  release=${release}
    ${l2_stream_config_1}=  Create Dictionary
    ...  nr_phy_cell_ids=50
    ...  up_sw=L2Ps
    ...  trace_type=Sherpa
    @{l2_stream_configuration}    Create List    ${l2_stream_config_1}
    ${source_ip_addr}=  Get source IP address  gnb_id=${0}  du_id=${0}  comu_id=${0}
    tcpdump.create tcpdump collector
    ...  name=tcpdump
    ...  options=-i eth3 udp and src ${source_ip_addr} and dst 10.0.1.1 and dst port 5678
    ...  sudo_password=ute
    l2stream3.create sbts l2stream collector
    ...  name=${name}
    ...  webservice=${executor}
    ...  source_ip_addr=${source_ip_addr}
    ...  destination_ip_addr=10.0.1.1
    ...  dscp=15
    ...  collector=tcpdump
    ...  l2_stream_configuration=${l2_stream_configuration}
    core.setup_collectors    names=${name}
    core.Set Suite Alias    ${name}


Start Sherpa Trace
    [Arguments]    ${name}=l2stream3
    core.start_collectors    names=${name}


Stop and Collect Sherpa Trace
    [Arguments]    ${name}=l2stream3    ${dir}=${TRACE_DIR}
    core.stop_collectors    names=${name}
    core.collect_collectors    names=${name}    target_dir=${dir}


Attach UE-${ue_id} with profile ${profile} and Establish DC
    attach_single_ue_to_enodeb     ue_id=${ue_id}    profile=${profile}
    sleep      1s
    start_eutran_new_radio_dual_connectivity         ue_id=${ue_id}
    sleep      1s

Register UE-${ue_id} and establish PDU session
    register_ue_from_5gcn      ue_id=${ue_id}
    establish_pdu_session_for_user_equipment       ue_id=${ue_id}

Register UE-${ue_id} without PDU session
    register_ue_from_5gcn      ue_id=${ue_id}

Establish PDU session for UE-${ue_id}
    establish_pdu_session_for_user_equipment       ue_id=${ue_id}

Register multiple UEs from UE-${first_ue_id} to UE-${last_ue_id} and establish PDU session
    register_multiple_ues_and_establish_pdu_session     first_ue_id=${first_ue_id}
    ...                                                 last_ue_id=${last_ue_id}

Deregister multiple UEs from UE-${first_ue_id} to UE-${last_ue_id}
    deregister_multiple_ues     first_ue_id=${first_ue_id}
    ...                         last_ue_id=${last_ue_id}

Detach multiple SA UEs from UE-${first_ue_id} to UE-${last_ue_id} with interval of ${timeout} seconds after each detach
    deregister_multiple_ues     first_ue_id=${first_ue_id}
    ...                         last_ue_id=${last_ue_id}
    ...                         timeout=${timeout}

Deregister UE-${ue_id}
    deregister_ue_from_5gcn       ue_id=${ue_id}

Start ping ${dir} traffic sending ${packets} packets with burst ${burst} size ${size} and period_ms ${period_ms} for UE-${ue_id} in ${mode} Mode
    Log to console  Start ping ${dir} traffic sending ${packets} packets with burst ${burst} size ${size} for UE-${ue_id} in ${mode} Mode

    start_data_ping_for_ue_in_sa_nsa_configuration            ue_id=${ue_id}
    ...                                                       direction=${dir}
    ...                                                       mode=${mode}
    ...                                                       burst=${burst}
    ...                                                       bearer_id=2
    ...                                                       size=${size}
    ...                                                       packets=${packets}
    ...                                                       period_ms=${period_ms}

Start ${rate} Mbps ${dir} traffic for UE-${ue_id} in ${mode} Mode
    ${dir}=         Convert To Lower Case       ${dir}
    Run keyword if     '${mode}' =='NSA'        start_data_traffic_for_ue_in_sa_nsa_configuration
    ...     mode=${mode}     ue=${ue_id}     dir=${dir}      id=2       mbps=${rate}
    Run keyword if     '${mode}' == 'SA'        start_data_traffic_for_ue_in_sa_nsa_configuration
    ...     mode=${mode}     ue=${ue_id}      pdu=1      qfi=1        dir=${dir}   mbps=${rate}


Start ${rate} ${order_traffic} in ${dir} direction traffic for multiple UEs from UE-${first_ue} to UE-${last_ue} in ${mode} Mode
     ${dir}=         Convert To Lower Case       ${dir}
    Run keyword if     '${mode}' =='NSA'        start_data_traffic_for_multiple_ues
    ...          first_ue_id=${first_ue}        last_ue_id=${last_ue}    mode=${mode}      order=${order_traffic}
    ...          dir=${dir}         id=2         mbps=${rate}
    Run keyword if     '${mode}' == 'SA'        start_data_traffic_for_multiple_ues
    ...          first_ue_id=${first_ue}        last_ue_id=${last_ue}    mode=${mode}      order=${order_traffic}
    ...          pdu=1      qfi=1       dir=${dir}       mbps=${rate}

Stop Traffic for UE-${ue_id}
    stop_data_traffic    ue_id=${ue_id}    bearer_id=2

Stop DL Traffic for UE-${ue_id} in SA Mode
    stop_dl_data_traffic_sa        ue_id=${ue_id}

Stop UL Traffic for UE-${ue_id} in SA Mode
    stop_ul_data_traffic_sa      ue_id=${ue_id}

Start AMF paging to gNB for UE-${ue_id}
    start_amf_paging    ue_id=${ue_id}

Switch UE-${ue_id} to idle\
    switch_ue_to_idle    ue_id=${ue_id}

Release DC and Detach UE-${ue_id} with bearer ID-${bearer_id}
    detach_ue_from_lte_and_release_endc         ue_id=${ue_id}
    ...                                         bearer_id=${bearer_id}
    ...                                         time_between_operations=1


UTE SCTP Modification
    [Documentation]    Starting AirPhone load 4.0.10852, the sack timeout in the WTS VM and AP ASIK must be
    ...                configured before cell setup. This aims to prevent delayed messaging between AirPhone
    ...                and WTS (e.g. CTRL_ADD_UE_NR for attach procedure).
    taf_ssh.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}
    ...               alias=${AP_ASIK.Connection}
    ${command}        Catenate    sysctl -w net.sctp.sack_timeout=10 &&
    ...               sysctl -w net.sctp.rto_min=200 &&
    ...               sysctl -w net.sctp.rto_initial=200 &&
    ...               sysctl -w net.sctp.rto_max=800
    taf_ssh.Execute       ${command}    ${AP_ASIK.Connection}
    taf_ssh.Disconnect    ${AP_ASIK.Connection}


Stop Edaemon and Egate process
    [Documentation]    Kill edaemon and egate if already running.
    ${edaemon_pid}=    Run    pgrep edaemon
    ${edaemon_status}    Run Keyword and Return Status    Should Not Be Empty    ${edaemon_pid}
    Run Keyword If    ${edaemon_status}    Run    sudo pkill -9 edaemon
    ${egate_pid}=    Run    pgrep egate
    ${egate_status}    Run Keyword and Return Status    Should Not Be Empty    ${egate_pid}
    Run Keyword If    ${egate_status}    Run    sudo pkill -9 egate

Configure UTE ETH3 interface
    Run    sudo ip addr add 10.0.1.131/24 dev eth3
    Run    sudo ip addr add 10.0.1.132/24 dev eth3
    Run    sudo ip addr add 10.0.1.133/24 dev eth3
    Run    sudo ip addr add 10.0.1.134/24 dev eth3
    Run    sudo ip addr add 10.0.1.135/24 dev eth3
    Run    sudo ip addr add 10.0.1.136/24 dev eth3
    Run    sudo ip addr add 10.0.1.137/24 dev eth3
    Run    sudo ip addr add 10.0.1.99/24 dev eth3
    Run    sudo ip addr add 10.0.1.121/24 dev eth3

Connect to virtual machine
    [Documentation]    Establish a ssh connection to the WTS machine where the simulator is present
    taf_ssh.Connect to     hostname=${WTS.Ip}
    ...                    username=${WTS.Username}
    ...                    alias=${WTS.Connection}

Get source IP address
    [Arguments]    ${gnb_id}=${0}  ${du_id}=${0}  ${comu_id}=${0}
    ${asik_alias}=    Connect to gNB CU and return connection alias  gnb_id=${gnb_id}  du_id=${du_id}  comu_id=${comu_id}
    ${raw_ip}=  taf_ssh.execute  ip -o -4 addr show | grep [b,f][p,r][0,1]  connection=${asik_alias}
    ${source_ip}=  get_ip  raw_ip=${raw_ip}
    [return]  ${source_ip}

Connect to gNB CU and return connection alias
    [Arguments]    ${gnb_id}=${0}  ${du_id}=${0}  ${comu_id}=${0}  ${alias}=ssh-gnb-${gnb_id}-${du_id}-${comu_id}
    taf_ssh.Connect_to     hostname=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.addr}
    ...                    username=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.username}
    ...                    password=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.password}
    ...                    alias=${alias}
    ...                    proxy=${None}
   taf_ssh.Force Reconnect    ${alias}
    [Return]    ${alias}


Check NG Link Status, Cell Setup and wait till SIB messages are received
    NG Link Status Verification
    Cell Setup status verification
    SIB Decoding Verification


NG Link Status Verification
    ${pattern}         Set Variable    NG link is Up
    Wait Until Keyword Succeeds    5 min    5 sec    CB007090-keywords.Search pattern should Exists In EGATE
    ...                            ${WTS_DIR}/egate_console.log     ${pattern}

Cell Setup status verification
    Wait Until Keyword Succeeds    5 min    5 sec    CB007090-keywords.Search grep pattern should Exists
    ...                            /tmp/APL3*.log    Cell Setup completed

SIB Decoding Verification
    ${pattern}         Set Variable    SystemInformationBlockType1
    Wait Until Keyword Succeeds    5 min    5 sec    CB007090-keywords.Search pattern should Exists In EGATE
    ...                            ${WTS_DIR}/egate_console.log     ${pattern}

Search pattern should Exists In EGATE
    [Arguments]    ${file}    ${pattern}    ${grepArgs}=grep -i
    ${command}        Catenate    ${grepArgs} '${pattern}' ${file}
    ${result}         Run    ${command}
    Should Contain    """${result}"""    ${pattern}    ignore_case=${TRUE}

Search grep pattern should Exists
    [Arguments]    ${file}    ${expected}    ${connection}=${AP_ASIK.Connection}    ${grepArgs}=grep -i    ${sudo}=${EMPTY}
    ${command}        Catenate    ${sudo} ${grepArgs} '${expected}' ${file}
    taf_ssh.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}
    ...               alias=${AP_ASIK.Connection}
    ${actual}         taf_ssh.Execute    ${command}    ${connection}
    taf_ssh.Disconnect    ${AP_ASIK.Connection}
    ${result}         Run Keyword And Return Status
    ...               Should Match Regexp    ${actual}    ${expected}    msg=No match for ${expected}
    Should be True    ${result}    msg=File or pattern does not exist!

${action} dynamic PDCCH time domain
    [Documentation]    This keyword sets to true (Activate) or false (Deactivate) the parameter actDynPdcchTd.
    ...                Usage example:    - Activate dynamic PDCCH time domain
    ...                                  - Deactivate dynamic PDCCH time domain
    admin.Setup admin
    &{opt}=  Create Dictionary  Activate=true  Deactivate=false
    ${dict}    Create Dictionary
    ...    actDynPdcchTd    ${opt}[${action}]
    ...    pdcchBlockingThreshold    30
    ...    pdcchFreeThreshold        50
    ${dynPdcchTdMgt}    Create List    ${dict}
    admin.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-1/NRBTS-1/NRCELL-1
    ...    parameter=dynPdcchTdMgt
    ...    operation=update
    ...    value=${dynPdcchTdMgt}
    ...    skip_parameter_relation_errors=True
    admin.Teardown Admin

Set pdcchBlockingThreshold=${blocking} and pdcchFreeThreshold=${free}
    [Documentation]    This keyword allows thresholds modification. Applicable with dynamic PDCCH feature activated.
    ...                Usage example:    - Set pdcchBlockingThreshold=30 and pdcchFreeThreshold=50
    ${dict}    Create Dictionary
    ...    actDynPdcchTd    true
    ...    pdcchBlockingThreshold    ${blocking}
    ...    pdcchFreeThreshold        ${free}
    ${dynPdcchTdMgt}    Create List    ${dict}
    admin.Setup admin
    admin.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-1/NRBTS-1/NRCELL-1
    ...    parameter=dynPdcchTdMgt
    ...    operation=update
    ...    value=${dynPdcchTdMgt}
    ...    skip_parameter_relation_errors=True
    admin.Teardown Admin

Verify that ${counter} is ${condition} with feature ${status} based on ${counter_files}
    verify_counters    counter=${counter}
    ...                condition=${condition}
    ...                status=${status}
    ...                counter_files=${counter_files}

Verify that after some seconds PDCCH is on N symbol(s) for slots without common channels with specific AL used
    [Arguments]    ${symbols}    ${aggregation_level}    ${sherpa_csv}
    ${data}=        read_and_parse_csv_data_into_dictionary    sherpa_trace_file_path=${sherpa_csv}
    verify_the_number_of_symbols_expected_for_pdcch_at_slots_without_common_channel     data=${data}
    ...                                                                                 exp_symbols=${symbols}
    ...                                                                                 exp_aggregation_level=${aggregation_level}

Verify that after some seconds PDCCH is on ${n_symbols} symbol(s) for slots with common channels with AL${al} used on TDD
    ${data}=        read_and_parse_csv_data_into_dictionary    sherpa_trace_file_path=${OUTPUT_DIR}/Suite_Setup_Logs/tcpdump/micro__l1l2Trace.csv
    verify_the_number_of_symbols_expected_for_pdcch_at_slots_with_common_channel     data=${data}
    ...                                                                              expected_symbols=${n_symbols}
    ...                                                                              expected_aggregation_level=${al}


Verify that counters for DL slots with 3 symbols or more are equal to zero
    [Documentation]    Checks that 3 symbols for PDCCH are not used
    [Arguments]        ${pm_counter_path}
    ${counter_list} =    Create List        M55335C02008    M55335C02009    M55335C05008    M55335C05009
    pmcounter.verify_if_latest_pm_counters_in_counter_id_list_have_exact_value     counter_id_list=${counter_list}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${pm_counter_path}


Attach UE${ue_id} with ${traffic} ${mbps_kbps} traffic and use AL${al}
    ${cqi}    Get CQI for AL${al}

    execute egate command    csi_override_testmode_nr profile_id\=${ue_id} cqi\=${cqi} pmi\=2 ri\=0 cqi_mode\=fixed
    attach ue    ue_id=${ue_id}
    establish pdu session with traffic  ue_id=${ue_id}    gw_id=${ue_id}    throughput=${traffic}${mbps_kbps}
    ...                                 pass_regexp=Initial Context Setup Successful for UE with AMF UE ID
    execute egate command    ue_testmode_set_nr id\=${ue_id} profile_id\=${ue_id} action\=activate testmode\=csi_override scell\=0

Get CQI for AL${al}
    [Documentation]
    ...    This keyword works properly with following CQI thresholds settings
    ...    cqiDciCssAl1 = 12
    ...    cqiDciCssAl2 = 10
    ...    cqiDciCssAl4 = 8
    ...    cqiDciCssAl8 = 6
    ...    cqiDciCssAl16 = 0

    ${cqi}=    Set variable if
    ...                        ${al}==1    13
    ...                        ${al}==2    11
    ...                        ${al}==4    9
    ...                        ${al}==8    7
    Return from keyword    ${cqi}

Assign AL${al} to UE${ue_id}
    ${cqi}    Get CQI for AL${al}
    execute egate command    csi_override_testmode_nr profile_id\=${ue_id} cqi\=${cqi} pmi\=2 ri\=0 cqi_mode\=fixed
    execute egate command    ue_testmode_set_nr id\=${ue_id} profile_id\=${ue_id} action\=activate testmode\=csi_override scell\=0

Perform scf comissioning with ${scf_path_to_specific_file}
    ${scf_converted}    Fix vlan id in scfc    input_filepath=${scf_path_to_specific_file}
    admin.Setup admin
    admin.Perform commissioning   scf_file=${scf_converted}    skip_parameter_relation_errors=${TRUE}
    admin.Teardown admin

Should Be Larger Than
    [Arguments]    ${value_1}    ${value_2}
    Run Keyword If    ${value_1} <= ${value_2}
    ...    Fail    The value ${value_1} is not larger than ${value_2}
