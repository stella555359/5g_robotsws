*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04

Library     OperatingSystem
Library    Collections
Library     taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008828/resources/common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/TTI_logs_Capture.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/TTI_stream_Analysis_MMW4.py
Library     TTI_stream_Analysis_MMW4.TTI_Stream_analysis    WITH NAME    TTI_Stream
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/android_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/l1l2bip_collect.robot


*** Variables ***
${gNB_ip}                     ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${gNB_username}               ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}               ${tl.gnbs[0].cu.oam_http_connection_details.password}
${gNB_ssh_name}               ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${gNB_ssh_password}           ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${ute_password}               ${tl.test_pc.default_ssh_connection_details.password}
${ap_ip}                      ${tl.ues[0].l1.common_units[0].lmp_connection.addr}
${MRBTS_ID}                   MRBTS-${tl.gnbs[0].instance_id}
${NRBTS_ID}                   NRBTS-${tl.gnbs[0].global_bts_id}
${NRCELL3_ID}                 NRCELL-3
@{dl_cell_list}               16387    16390
@{dl_cell_list1}              16385    16386    16387   16388    16389    16390
@{dl_cell_list2}              16387
@{allowed_list1}              ${4655}    ${61524}    ${4654}    ${61652}    ${61649}
${cfg_file}                   ${CURDIR}/config/basic.cfg




*** Keywords ***
########### setup KW #################
CB008927 Suit Setup
    _Create Suite Log Directory
    Enable Syslog Info Level Prints
    Run Keyword And Ignore Error  Setup SSH keys on WTS
    Run Keyword And Ignore Error  Setup SSH keys on UTE
    Copy TargetBD Xml From BTS
    robot_common_operations.Common Suite Setup

CB008927 Suit Teardown
    robot_common_operations.Common Suite Teardown

Test Case Setup
    [Arguments]   ${cfg_filepath}=${cfg_file}    ${scf_name}=_normal    ${reset_tl}=${FALSE}
    _Create Test Log Directory
    Set Suite Variable    ${Test_case_log_dir}  ${output_dir}/${TEST_NAME[:30]}
    Create Directory    ${Test_case_log_dir}
    Run Keyword If    '${scf_name}' != 'None'    Setup Commission SCF    scf_name=${scf_name}
    Prepare Airphone Config File    scf_name=${scf_name}
    CB008927_common_keyword.Prepare Test Environement And Reach Onair    perform_tl_reset=${reset_tl}
    ...   cfg_filepath=${cfg_filepath}
    robot_common_operations.Common Case Setup
    Check Alarm List on BTS

Case Teardown
    robot_common_operations.Common case Teardown
    CI_interface.Common Case Teardown
    Run Keyword If    "${TEST_STATUS}"=="FAIL"    Save Snapshot

Prepare Airphone Config File
    [Arguments]    ${scf_name}
    @{RF_list}    Create List    RF.FRM5    RF.SRM6    RF.FRM6
    ${basic_file}    Run Keyword If    '${scf_name}'=='_469'    Set Variable    basic_469.cfg
    ...    ELSE IF    '${scf_name}'=='_normal'    Set Variable    basic_normal.cfg
    ...    ELSE IF    '${scf_name}'=='_144631'    Set Variable    basic_144631.cfg
    ...    ELSE    Set Variable    basic_EDA.cfg
    ${iphy_file}    Run Keyword If    '${scf_name}'=='_469'    Set Variable    iphy_469.xml
    ...    ELSE IF    '${scf_name}'=='_normal'    Set Variable    iphy_normal.xml
    ...    ELSE IF    '${scf_name}'=='_144631'    Set Variable    iphy_144631.xml
    ...    ELSE    Set Variable    iphy_EDA.xml
    ${new_iphy_file}    Modify_RF_version_to_iphy    TargetBD_file=${TargetBD_file_path}    iphy_name=${iphy_file}    config_path=${CURDIR}/config
    ...    RF_list=${RF_list}
    Run    sudo scp ${CURDIR}/config/${basic_file} ${CURDIR}/config/basic.cfg
    ssh.connect_to    hostname=${ap_ip}    username=${gNB_ssh_name}     password=${gnb_ssh_password}    alias=AP_CON
    ssh.Upload File  local_path=${CURDIR}/config/iphy.xml    remote_path=/ffs/run/simmode/iphy.xml    connection=AP_CON
    [Teardown]  Run keyword and ignore error    ssh.disconnect    connection=AP_CON

Setup SSH keys on UTE
    Run and return rc and output    sshpass -p ${ute_password} ssh-copy-id ute@127.0.0.1

Case469 Setup
    Test Case Setup    scf_name=_469

Case Normal Setup
    Test Case Setup    scf_name=_normal

EDA Case Setup
    Test Case Setup    scf_name=_EDA

Prepare Test Environement And Reach Onair
    [Arguments]    ${perform_tl_reset}     ${cfg_filepath}
    ${BBU_TYPE}  Get Bbu Type
    BuiltIn.Log  bbu_type\=${BBU_TYPE}  console=True
    Set Suite Variable  ${BBU_TYPE}
    Run Keyword If    ${perform_tl_reset}    Reset Testline
    Configure VM interfaces
    Modify SCTP Timeout
    Make Sure GNB AP SSH OK
    run keyword if    ${WIRESHARK_FLAG} is ${True}    Run Keyword And Ignore Error    AP_lib.Start To Capture Wireshark Log
    ...    startup_1
    Wait Gnb Configured State and Start Wts_2    ${cfg_filepath}

Wait Gnb Configured State and Start Wts_2
    [Arguments]    ${cfg_filepath}    ${bts_host}=${gNB_ip}
    ${configured_status}  Set Variable  ${False}
    ${configured_status}    wait gnb configured state  600
    _handle cfg bts1    ${cfg_filepath}
    Return From Keyword If    '${configured_status}'=='${False}'    ${configured_status}
    Run Keyword And Ignore Error    _Start Capture SosReport
    configure and start wts    ${WTS_FILE_PATH}  ${DEBUG_LOG_LEVEL}
    ${onair_status}  Set Variable  ${False}
    Run Keyword And Ignore Error    _Stop Capture SosReport
    Check GNB on air    bts_host=${bts_host}

############# Start Traffic #################
SA UE Attach on cell
    [Arguments]    ${if_ul}    ${if_dl}    ${ue_id_list}    ${trf_num}=${1}    ${dl_mbps}=0    ${ul_mbps}=0    ${nwslice}=1    ${pdu_id}=1
    FOR  ${ue_id}  IN  @{ue_id_list}
        Log to console    UE-${ue_id} start attach
        Set Internal Traffic Type To UEs    ue_id=${ue_id}    pdu_id=${pdu_id}
        Register Ue With Default Pdu Session    ue_id=${ue_id}    nwslice=${nwslice}    other_pud=${False}  other_plmn=${False}    pdu_id=${pdu_id}
        Run Keyword And Ignore Error    Run Keyword If    ${if_dl}    Start DL Traffic With Multi Trd Id    trf_num=${trf_num}    ue_id=${ue_id}
        ...    pdu_id=${pdu_id}    dl_mbps=${dl_mbps}    duration=6000
        Run Keyword If    ${if_ul}    AP_lib.Execute Egate Command
        ...    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=${ul_mbps} trf_id=1 seconds=6000
        ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue
        Exec A4 Measurement Report    ue_id=${ue_id}
        sleep    2s
        Show Tput    ue_id=${ue_id}
    END

Show Tput
    [Arguments]    ${ue_id}
    AP_lib.Execute Egate Command    ue_stats_nr id=${ue_id} type=pdsch scell=primary,secondary
    ...    pass_regexp=UE-${ue_id}: NR PDSCH Throughput

Exec A4 Measurement Report
    [Arguments]    ${ue_id}=21
    Log to console    UE-${ue_id} trigger A4 Measurement Report
    ${scell_pci_list}    Create List    50    51    54    52    55
    ${meas_id_list}    Create List    1    2    3    4    5
    FOR    ${i}    IN RANGE    ${0}    ${5}
        ${meas_id}    set variable    ${meas_id_list}[${i}]
        ${pci}    set variable    ${scell_pci_list}[${i}]
        ${A4_command}    Catenate
        ...    ue_schedule_measurement_send_nr id=${ue_id} action=SEND_IMMEDIATELY periodicity=100 delay=10
        ...    meas_id=${meas_id} event=A4 phycell_id=${pci} nrsrp_nr=100
        AP_lib.Execute Egate Command    ${A4_command}
        sleep    0.5s
    END

SA MultiUE Attach on cell
    [Arguments]    ${if_ul}    ${if_dl}    ${ue_id_str}    ${trf_num}=${1}    ${dl_mbps}=0    ${ul_mbps}=0    ${nwslice}=1    ${pdu_id}=1
    Set Internal Traffic Type To UEs    ue_id=${ue_id_str}    pdu_id=${pdu_id}
    Register Ue With Default Pdu Session    ue_id=${ue_id_str}    nwslice=${nwslice}    other_pud=${False}  other_plmn=${False}    pdu_id=${pdu_id}
    Run Keyword And Ignore Error    Run Keyword If    ${if_dl}    Start DL Traffic With Multi Trd Id    trf_num=${trf_num}    ue_id=${ue_id_str}
    ...    pdu_id=${pdu_id}    dl_mbps=${dl_mbps}    duration=6000
    Run Keyword If    ${if_ul}    AP_lib.Execute Egate Command
    ...    trf_data_start ue=${ue_id_str} pdu=${pdu_id} qfi=1 dir=ul mbps=${ul_mbps} trf_id=1 seconds=6000
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue
    sleep    1s

Verify Throughput SA
    [Arguments]    ${ue_id}=1    ${exp_dl_tp}=270    ${exp_ul_tp}=10    ${sleep_time}=15s  ${pdu_id}=1
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}=  Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}=  Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}=  AP_lib.Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-. *0 *0 *0 *0
    Run Keyword And Continue On Failure    Should Be True    ${dl_throughput}/1000>${exp_dl_tp}
    Run Keyword And Continue On Failure    Should Be True    ${ul_throughput}/1000>${exp_ul_tp}

Mulite UE Check TP
    [Arguments]    ${ue_id_list}    ${exp_ul_tp}    ${exp_dl_tp}    ${sleep_time}=15s    ${pdu_id}=1
    sleep    ${sleep_time}    sleep for Tput stable
    FOR  ${ue_id}  IN  @{ue_id_list}
        CB008927_common_keyword.Verify Throughput SA    ue_id=${ue_id}    exp_dl_tp=${exp_dl_tp}    exp_ul_tp=${exp_ul_tp}
        ...    sleep_time=1s    pdu_id=${pdu_id}
    END

Start SA Data Traffic In Dl Ul
    [Arguments]    ${if_ul}    ${if_dl}    ${trf_num}    ${ue_id_list}    ${dl_mbps}    ${ul_mbps}     ${pdu_id}=1    ${duration}=6000
    Run Keyword If    ${if_dl}    Start DL Traffic With Multi UE    trf_num=${trf_num}    ue_id_list=${ue_id_list}    pdu_id=${pdu_id}
    ...    dl_mbps=${dl_mbps}    duration=${duration}
    Run Keyword If    ${if_ul}   Start UL Traffic With Multi UE    ue_id_list=${ue_id_list}    pdu_id=${pdu_id}    ul_mbps${ul_mbps}
    ...    duration=${duration}

Start DL Traffic With Multi UE
    [Arguments]    ${trf_num}    ${ue_id_list}    ${pdu_id}=1    ${dl_mbps}=100    ${duration}=6000
    FOR  ${ue_id}  IN  @{ue_id_list}
        Start DL Traffic With Multi Trd Id    trf_num=${trf_num}    ue_id=${ue_id}    pdu_id=${pdu_id}    dl_mbps=${dl_mbps}    duration=${duration}
    END

Start DL Traffic With Multi Trd Id
    [Arguments]    ${trf_num}    ${ue_id}    ${pdu_id}=1    ${dl_mbps}=100    ${duration}=6000
    ${trf_num}    Evaluate    ${trf_num}+1
    FOR  ${trf_id}  IN RANGE  1    ${trf_num}
        AP_lib.Execute Egate Command
        ...    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=${dl_mbps} trf_id=${trf_id} seconds=${duration}
        ...    pass_regexp=Started Downlink Internal traffic Receiver on Ue
    END

Start UL Traffic With Multi UE
    [Arguments]    ${ue_id_list}    ${pdu_id}=1    ${ul_mbps}=100    ${duration}=6000
    FOR  ${ue_id}  IN  @{ue_id_list}
        AP_lib.Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=${ul_mbps}  trf_id=1
        ...    seconds=${duration}    pass_regexp=Started Uplink Internal traffic Receiver on Ue
    END

Stop Traffic and release UE
    [Arguments]    ${ue_id_list}
    FOR  ${ue_id}  IN  @{ue_id_list}
        log to console    Detach UE-${ue_id}
        AP_lib.Execute Egate Command   ue_deregister id=${ue_id} ue_deregister_type=switch_off    pass_regexp=UE Deregister request
    END

############ check bts on air #################
Save Snapshot
    [Arguments]    ${connection}=cOAM    ${timeout}=10min
    log to console    Save Snapshot...
    run keyword and ignore error     coam.teardown    connection=${connection}
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    ${snapshot_path}    coam.get_snapshot    target_file_name=${Test_case_log_dir}/snapshot.zip    connection=${connection}    timeout=${timeout}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${snapshot_path}

Adapt to ute cloud commission scf
    ${TL_NAME}   set variable if      '${testline_name}' == '${EMPTY}'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TL_NAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${TL_NAME}   Set Variable    7_5${TL_NAME}[0]
    Set Suite Variable    ${CURDIR_path}    ${CURDIR}/../../../../../../commissionings/HGZ/${TL_NAME}

Set default SCF
    [Arguments]      ${scf_name}    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    separator=_
    ${version_scf}    run keyword if    '${version_list[2]}'=='9999'    Set Variable    SBTS00
    ...    ELSE   Set Variable    ${version_list[0]}
    ${default_scf_path}    set variable if    '${scf_name}'=='_normal'   ${CURDIR_path}/SCF_${version_scf}.xml
    ...    ${CURDIR_path}/SCF_${version_scf}${scf_name}.xml
    set suite variable    ${default_scf_path}
    log to console   ${default_scf_path}
    [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Setup Commission SCF
    [Arguments]  ${scf_name}    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Adapt to ute cloud commission scf
    Set default SCF    scf_name=${scf_name}    bts_host=${bts_host}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    COAM Commission with scf file    scf_file_path=${default_scf_path}    connection=${connection}
    sleep   3min
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Check GNB on air
    [Timeout]    20 min
    [Arguments]  ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air    connection=${connection}
    Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Get Alarm on BTS
    [Arguments]  ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    @{active_alarms}    coam.get_active_alarms    connection=${connection}
    @{history_alarms}    coam.get_historic_alarms    connection=${connection}
    ${active_id_list}    Get Alarm ID From BTS    output_alarms=${active_alarms}
    ${history_id_list}    Get Alarm ID From BTS    output_alarms=${history_alarms}
    [Return]  ${active_id_list}    ${history_id_list}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Get Alarm ID From BTS
    [Arguments]  ${output_alarms}
    ${len}    Get Length    ${output_alarms}
    @{fault_id_list}    create list
    FOR    ${i}    IN RANGE    ${len}
        ${fault_id}     get from dictionary  ${output_alarms}[${i}]   additionalFaultID
        APPEND TO LIST  ${fault_id_list}    ${fault_id}
    END
    [Return]  ${fault_id_list}

Check Alarm List on BTS Temp
    [Arguments]  ${allowed_list}=None    ${not_allowed_list}=None    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    ${actual_fault_id_list}    ${history_id_list}    Get Alarm on BTS    bts_host=${bts_host}    connection=${connection}
    ${history_id_len}    Get Length    ${history_id_list}
    Run Keyword if    ${allowed_list} != None        Check List1 content in List2    list1=${actual_fault_id_list}    list2=${allowed_list}
    Run Keyword if    ${not_allowed_list} != None    Check List1 content not in List2    list1=${not_allowed_list}    list2=${actual_fault_id_list}
    Run Keyword if    ${history_id_len} != ${0}    Save Snapshot
    Should be equal    ${history_id_len}    ${0}

Check Alarm List on BTS
    [Arguments]  ${allowed_list}=${allowed_list1}    ${not_allowed_list}=None    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    ${status}    Run Keyword And Return Status    Check Alarm List on BTS Temp    allowed_list=${allowed_list}
    ...    not_allowed_list=${not_allowed_list}    bts_host=${bts_host}    connection=${connection}
    Run Keyword if    ${status} == ${False}    Save Snapshot
    Should be equal    ${status}    ${True}

Check List1 content in List2
    [Arguments]  ${list1}    ${list2}
    ${len1}    Get Length    ${list1}
    ${len2}    Get Length    ${list2}
    Run Keyword And Continue On Failure    Should be true    ${len1}<=${len2}
    FOR  ${i}  IN  @{list1}
        Run Keyword And Continue On Failure    Should contain    ${list2}    ${i}
    END

Check List1 content not in List2
   [Arguments]  ${list1}    ${list2}
    FOR  ${i}  IN  @{list1}
        Run Keyword And Continue On Failure    Should not contain    ${list2}    ${i}
    END

############# About log #################
Collect Aasyslog
    [Arguments]    ${log_time}
    ${log_path}    power_ue.Collect Tput   ue_type=samsung    duration=${log_time}    ignore_time=10s
    [Return]    ${log_path}

Check TP From Aasyslog
    [Arguments]    ${ul_list}    ${dl_list}    ${exp_ul_tp}    ${exp_dl_tp}    ${log_path}    ${if_ul}=${True}    ${if_dl}=${True}
    run keyword and continue on failure    run keyword if    ${if_ul}==${True}    power_ue.Check Tput    ue_type=samsung
    ...    direction=UL    log=${log_path}    cells=${ul_list}    target_throughput=${exp_ul_tp}    target_avg_percent=1
    ...    actCarrierAggregation=${True}    min_percent=0
    run keyword and continue on failure    run keyword if    ${if_dl}==${True}    power_ue.Check Tput    ue_type=samsung
    ...    direction=DL    log=${log_path}    cells=${dl_list}    target_throughput=${exp_dl_tp}    target_avg_percent=1
    ...    actCarrierAggregation=${True}    min_percent=0

Common Capture BIP log and download
    [Arguments]    ${target_dir}    ${duration}=3s    ${target_file_name}=l1l2bip_log    ${interface}=L1-L2    ${destination}=Local
    ...    ${nr_phy_cell_ids}=${None}
    Collect Interface Mirroring Bip Collector    target_file_name=${target_file_name}    nr_phy_cell_ids=${nr_phy_cell_ids}
    ...    gnb_index=${0}    timeout=900    interface=${interface}    destination=${destination}
    ...    host_ip=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    sleep    ${duration}
    ${full_log_path}    Get Bip Log Via Interface Mirroring Collector    target_file_name=${target_file_name}
    ...    pattern=*.pcap    target_dir=${target_dir}
    [Return]    ${full_log_path}

Covert Pcap To Pdml
    [Arguments]  ${pcap_file}   ${output_file}    ${filter}
    Set Test Variable    ${command}    tshark -V -r ${pcap_file} -Y ${filter} -T pdml > ${output_file}
    Run    ${command}

Covert Pcap To txt
    [Arguments]  ${pcap_file}   ${output_file}    ${filter}
    Set Test Variable    ${command}    tshark -V -r ${pcap_file} -Y ${filter} -T text > ${output_file}
    Run    ${command}

pdml entries should match
    [Arguments]      ${pdmlFile}     ${field_name}    ${attrib_value}    ${expect_value}
    [Documentation]      this KW matches the entry in the pdml file
    ${pdml_entries}    taf_pdml_analyser.get_pdml_entries     ${pdmlFile}
	...          field_name=${field_name}      attrib_name=show    attrib_value=${attrib_value}
	${attrib_values}    taf_pdml_analyser.get_attrib_value_from_pdml_entries    ${pdml_entries}
    ...    field_name=${field_name}    attrib_name=showname
    should contain     ${attrib_values}[0]      ${expect_value}

Start Catch Trace Log
    [Arguments]    ${filename}   ${time}=3s    ${connection}=GNB_SSH
    Log To Console    Start Catch Trace Log
    ssh.Connect to    hostname=${gNB_ip}    username=${gNB_ssh_name}   password=${gNB_ssh_password}    alias=${connection}
    sleep    2s
    ssh.send_command    command=tcpdump sctp -i any -w /tmp/${filename} &   connection=${connection}
    sleep    ${time}
    [Teardown]    ssh.disconnect    connection=${connection}

_get_PID
    [Arguments]    ${connection}    ${command}
    Log To Console    Get PID
    ssh.send_command    command=${command}   connection=${connection}
    ${PID}    ssh.read output    connection=${connection}
    ${PID}    strip_string    ${PID}
    should not be empty    ${PID}
    [Return]    ${PID}

Stop And Copy Log To UTE
    [Arguments]    ${filename}    ${time}=10s     ${connection}=GNB_SSH
    Log To Console    Stop And Copy Log To UTE
    ssh.Connect to    hostname=${gNB_ip}    username=${gNB_ssh_name}   password=${gNB_ssh_password}    alias=${connection}
    sleep    2s
    ${PID}    wait until keyword succeeds    1min    2s    _get_PID    connection=${connection}
    ...    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'
    Log To Console    kill PID
    ssh.send_command    command=kill -9 ${PID}    connection=${connection}
    Log To Console    download file to local
    ssh.download_file    remote_path=/tmp/${filename}    local_path=${Test_case_log_dir}/${filename}    connection=${connection}
    sleep    ${time}
    [Return]    ${Test_case_log_dir}/${filename}
    [Teardown]    ssh.disconnect    connection=${connection}

Capture TTI log
    [Timeout]    20min
    [Arguments]    ${tti_log}    ${filter}=None    ${log_time}=3    ${bts_ip}=${gNB_ip}    ${eth_port_on_ute}=eth3    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${csv_path}    CB008927_common_keyword.Capture And Decode TTitrace Log    duration=${log_time}    filter=${filter}
    ...    eth_port_on_ute=${eth_port_on_ute}    log_dir=${tti_log}
    ${UL_DL_csv_file_path_dict}=  Create Dictionary
    ...    DL=${csv_path}/tcpdump_ttitrace_dl.csv
    ...    UL=${csv_path}/tcpdump_ttitrace_ul.csv
    [Return]  ${UL_DL_csv_file_path_dict}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Capture And Decode TTitrace Log
    [Documentation]    Migrate from ET
    [Arguments]    ${log_dir}=${Test_case_log_dir}/ttitrace_streaming/    ${collector_names}=l2stream3_ttitrace    ${duration}=3
    ...    ${filter}=None    ${eth_port_on_ute}=eth3
    TTI_logs_Capture.Start Ttitrace With Streaming Mode    collector_names=${collector_names}    eth_port_on_ute=${eth_port_on_ute}
    Sleep    ${duration}s    reason=Wait for logs
    TTI_logs_Capture.Stop Ttitrace    collector_names=${collector_names}    log_dir=${log_dir}
    ${csv_file_path}    TTI_logs_Capture.Decode Ttitrace Logs    log_dir=${log_dir}    collector_names=${collector_names}
    ...    by_filter=${True}    except_filter=${False}    filter=${filter}
    [Return]    ${csv_file_path}

Copy TargetBD Xml From BTS
    [Arguments]     ${connection}=GNB_SSH
    ssh.Connect to    hostname=${gNB_ip}    username=${gNB_ssh_name}   password=${gNB_ssh_password}    alias=${connection}
    Log To Console    download file to local
    ${output}    ssh.execute    command=ls /ffs/run    connection=${connection}
    @{files}    Split String    ${output}    \n
    BuiltIn.Log    ${files}
    ${file}    Get_TargetBD_file_name    input_list=${files}
    ssh.download_file    remote_path=/ffs/run/${file}    local_path=${output_dir}/${file}    connection=${connection}
    sleep    10s
    Set Suite Variable    ${TargetBD_file_path}    ${output_dir}/${file}
    log to console    ${TargetBD_file_path}
    [Teardown]    ssh.disconnect    connection=${connection}




############# Modify Parameter #################
Modify Parameters with json
    [Arguments]    ${input_list}    ${bts_host}=${gNB_ip}    ${delta_id}=update_parameter    ${connection}=GNB_OAM    ${time}=5min
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    coam.create_delta    delta_id=${delta_id}
    FOR    ${item}  IN    @{input_list}
        ${operation}    get from dictionary    ${item}    operation
        Run keyword if    '${operation}'=='update'
        ...    coam.append_parameter_update_to_delta    dist_name=${item['dist_name']}    parameter=${item['parameter']}
        ...    value=${item['value']}    delta_id=${delta_id}
        Run keyword if    '${operation}'=='delete'
        ...    coam.append_parameter_delete_to_delta    dist_name=${item['dist_name']}    parameter=${item['parameter']}
        ...    delta_id=${delta_id}
        Log to console    Add task - ${operation}: ${item['dist_name']}.${item['parameter']}
    END
    ${delta_file}    coam.get_delta    delta_id=${delta_id}
    ${timeout}    set variable    480
    Log to console    Perform parameters via delta_id:${delta_id} is ongoing, timeout ${timeout}s.
    coam.perform_delta_recommissioning
    ...    delta_file=${delta_file}
    ...    skip_parameter_relation_errors=${False}
    ...    should_activate=${True}
    ...    timeout=${timeout}
    ...    connection=${connection}
    Log to console    Perform parameters done.
    run keyword and ignore error    coam.remove_delta    delta_id=${delta_id}
    sleep    ${time}
    [Teardown]    run keyword and ignore error    coam.teardown      connection=${connection}

Modify Parameter And Wait On Air
    [Timeout]    20min
    [Arguments]    ${input_list}    ${bts_host}=${gNB_ip}    ${delta_id}=update_parameter    ${connection}=GNB_OAM
    Modify Parameters with json    input_list=${input_list}    bts_host=${bts_host}    delta_id=${delta_id}
    ...    connection=${connection}    time=10s
    Check GNB on air    bts_host=${bts_host}    connection=${connection}

############# Get GNB Counter #################
get_bts_counters
    [Arguments]    ${counter_ids}    ${NRCELL_ID}=${NRCELL3_ID}    ${connection}=GNB_OAM
    @{counter_value_list}    Create list
    ${counter_id_list}    Split String    ${counter_ids}    separator=,
    ${counter_len}    Get Length    ${counter_id_list}
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Log To Console    get bts counter
    ${counter_value}    coam.get_PM_counters    counter_ids=${counter_ids}    connection=${connection}
    FOR  ${item}  IN RANGE    0    ${counter_len}
        ${counter_id}    Set Variable    ${counter_id_list[${item}]}
        ${counter_content}    Set Variable    ${counter_value['BTS']['${MRBTS_ID}']['${NRBTS_ID}']['${NRCELL_ID}']}
        ${result}   find_key_in_dict    nested_dict=${counter_content}    target_key=${counter_id}
        Append To List    ${counter_value_list}    ${result}
    END
    [Return]    ${counter_value_list}
    [Teardown]    run keyword and ignore error    coam.teardown      connection=${connection}


############# Case Check Log #################
Check value From Bip
    [Arguments]    ${log_path}    ${pcap_file}    ${numOfPdschSymbols}    ${filter}=dldata_pdschsendreq    ${field_name}=DlData_PdschGrant
    ${output_log}    Set Variable    ${log_path}/${pcap_file}
    ${pdml_path}    Set Variable    ${output_log}/${pcap_file}.pdml
    ${bip_cover_result}    Run Keyword And Return Status    Covert Pcap To Pdml    pcap_file=${output_log}/${pcap_file}.pcap
    ...   output_file=${pdml_path}    filter=${filter}
    ${rat0Bitmap_value}    Get_packet_info    file_path=${pdml_path}    field_name=${field_name}.rat0Bitmap
    ${numOfPdschSymbols_value}    Get_packet_info    file_path=${pdml_path}    field_name=${field_name}.numOfPdschSymbols
    ${check_rat0Bitmap_result}    Check_the_list_contains_zero_or_non_zero    value_list=${rat0Bitmap_value}    check_value=2
    Run Keyword And Continue On Failure     Should Be True    ${check_rat0Bitmap_result}
    Run Keyword And Continue On Failure    List Should Contain Value    ${numOfPdschSymbols_value}    ${numOfPdschSymbols}

Check rat0Bitmap value From Bip
    [Arguments]    ${file_path}    ${check_value}
    ${rat0Bitmap_value}    Get_packet_info    file_path=${file_path}    field_name=DlData_PdschGrant.rat0Bitmap
    ${check_result}    Check_the_list_contains_zero_or_non_zero    value_list=${rat0Bitmap_value}    check_value=${check_value}
    Run Keyword And Continue On Failure     Should Be True    ${check_result}

Check numOfPdschSymbols value From Bip
    [Arguments]    ${file_path}    ${check_value}
    ${numOfPdschSymbols_value}    Get_packet_info    file_path=${file_path}    field_name=DlData_PdschGrant.numOfPdschSymbols
    Run Keyword And Continue On Failure    List Should Contain Value    ${numOfPdschSymbols_value}    ${check_value}

Check BWP_ID From Tcpdump
    [Arguments]    ${file_path}    ${check_value}
    @{dl_field_list}    Create List    UEContextModificationResponse    DUtoCURRCInformation    BWP-Downlink    bwp-Id
    ${dl_bwp_value_list}    Get_Field_Value_From_Frame_Content    file_path=${file_path}    field_list=${dl_field_list}
    ${vaild_list1}    ${invaild_list1}    Check_list_Only_Contain_one_value    input_list=${dl_bwp_value_list}    check_value=1
    ${vaild_list2}    ${invaild_list2}    Check_list_Only_Contain_one_value    input_list=${dl_bwp_value_list}    check_value=2
    ${vaild_list1_len}    Get Length    ${vaild_list1}
    ${vaild_list2_len}    Get Length    ${vaild_list2}
    ${check_value1_result}    Run Keyword If    ${vaild_list1_len} > ${0} and ${vaild_list2_len} == ${0}    Set Variable    True
    ...    ELSE    Set Variable    False
    ${check_value2_result}    Run Keyword If    ${vaild_list1_len} > ${0} and ${vaild_list2_len} > ${0}    Set Variable    True
    ...    ELSE    Set Variable    False
    Run Keyword And Continue On Failure    Run Keyword If    ${check_value} == 1    Should Be True    ${check_value1_result}
    ...    ELSE        Should Be True    ${check_value2_result}

Case 08 UE start Traffic
    SA UE Attach on cell    if_ul=${True}    if_dl=${True}    trf_num=${7}    ue_id_list=${all_ue_list[2:3]}    dl_mbps=170    ul_mbps=130
    CB008927_common_keyword.Common Capture BIP log and download    target_dir=${Test_case_log_dir}    target_file_name=l1l2bip_log
    ${aasyslog_path}    Collect Aasyslog    log_time=5m
    sleep    5min
    [Return]    ${aasyslog_path}
    [Teardown]    Stop Traffic and release UE    ue_id_list=${all_ue_list[2:3]}

Case 08 check point
    [Arguments]    ${log_path}    ${pcap_file}   ${aasyslog_path}    ${befor_counter}    ${numOfPdschSymbols}=14
    sleep    1min
    ${status}    Run Keyword And Return Status    Check value From Bip    log_path=${log_path}    pcap_file=${pcap_file}
    ...    numOfPdschSymbols=${numOfPdschSymbols}    filter=dldata_pdschsendreql1sw    field_name=DlData_PdschGrantL1sw
    Run Keyword If    ${status}==${False}    Check value From Bip    log_path=${log_path}    pcap_file=${pcap_file}
    ...    numOfPdschSymbols=${numOfPdschSymbols}    filter=dldata_pdschsendreq    field_name=DlData_PdschGrant
    Check TP From Aasyslog    ul_list=${dl_cell_list}    dl_list=${dl_cell_list}    exp_ul_tp=100    exp_dl_tp=870    log_path=${aasyslog_path}
    ${after_counter}    get_bts_counters    counter_ids=M55335C02019    NRCELL_ID=${NRCELL3_ID}
    ${counter_value}    Case8_Count_counter_value    befor_counter=${befor_counter[0]}    after_counter=${after_counter[0]}
    Run Keyword And Continue On Failure     Should Be True    ${counter_value} > ${245000}

Case 07 check Bip And Tcpdump
    [Arguments]    ${tti_path}    ${tcpdump_name}   ${tcpdump_check_value}    ${check_value}    ${log_path}=${Test_case_log_dir}
    Covert Pcap To txt    pcap_file=${log_path}/${tcpdump_name}.pcap   output_file=${log_path}/${tcpdump_name}.txt    filter='f1ap || ngap'
    Check BWP_ID From Tcpdump    file_path=${log_path}/${tcpdump_name}.txt    check_value=${tcpdump_check_value}
    ${dl_tti_file}    Get From Dictionary    ${tti_path}    DL
    ${rat0Bitmap_value}    TTI_Stream.get_dlFdSchedData_rat0Bitmap_value    file_path=${dl_tti_file}
    ${check_result}    Check_the_list_contains_zero_or_non_zero    value_list=${rat0Bitmap_value}    check_value=${check_value}
    Run Keyword And Continue On Failure     Should Be True    ${check_result}

Case 07 UE start Traffic
    [Arguments]    ${trf_num}    ${dl_mbps}    ${ul_mbps}    ${ue_id_list}    ${exp_ul_tp}    ${exp_dl_tp}    ${tcpdump_name}    ${tti_log_name}
    ...    ${duration}
    Start Catch Trace Log    filename=${tcpdump_name}
    SA UE Attach on cell    if_ul=${True}    if_dl=${True}    trf_num=${trf_num}    ue_id_list=${ue_id_list}    dl_mbps=${dl_mbps}
    ...    ul_mbps=${ul_mbps}
    ${file_path}    Stop And Copy Log To UTE    filename=${tcpdump_name}
    ${csv_file_path}    Capture TTI log    tti_log=${Test_case_log_dir}/${tti_log_name}    filter=dlFdSchedData|dlHarqRxDataArray    log_time=3
    sleep    ${duration}
    Mulite UE Check TP    ue_id_list=${ue_id_list}    exp_ul_tp=${exp_ul_tp}    exp_dl_tp=${exp_dl_tp}    sleep_time=10s
    [Return]    ${csv_file_path}
    [Teardown]    Stop Traffic and release UE    ue_id_list=${ue_id_list}

Case 07 check Counter
    [Arguments]    ${befor_counter}
    sleep   5min
    ${after_counter}    get_bts_counters    counter_ids=M55138C00057,M55308C36003,M55308C36004    NRCELL_ID=${NRCELL3_ID}
    ${all_counter_value_list}    Case7_Count_counter_value    befor_counter_list=${befor_counter}    after_counter_list=${after_counter}
    ${M55308C36003_zero_result}    ${M55308C36003_none_zero_result}    Check_list_Only_Contain_one_value
    ...    input_list=${all_counter_value_list[1]}    check_value=0
    ${M55308C36004_zero_result}    ${M55308C36004_none_zero_result}    Check_list_Only_Contain_one_value
    ...    input_list=${all_counter_value_list[2]}    check_value=0
    ${M55308C36003_none_zero_len}    Get Length    ${M55308C36003_none_zero_result}
    ${M55308C36004_none_zero_len}    Get Length    ${M55308C36004_none_zero_result}

   # ${M55308C36003_result}    Check_the_list_contains_zero_or_non_zero    value_list=${all_counter_value_list[1]}    check_value=2
   # ${M55308C36004_result}    Check_the_list_contains_zero_or_non_zero    value_list=${all_counter_value_list[2]}    check_value=2
    Run Keyword And Continue On Failure    List Should Contain Value    ${all_counter_value_list[0]}    ${4}
    Run Keyword And Continue On Failure     Should Be True    ${M55308C36003_none_zero_len}>${0}
    Run Keyword And Continue On Failure     Should Be True    ${M55308C36004_none_zero_len}>${0}

Case 05 Capture log And Check
    [Arguments]    ${exp_ul_tp}    ${exp_dl_tp}    ${tti_log_name}    ${actDlDynSwitchAlloc}=${False}
    ${aasyslog_path}    Collect Aasyslog    log_time=1m
    Check TP From Aasyslog    ul_list=${dl_cell_list}    dl_list=${dl_cell_list}    exp_ul_tp=${exp_ul_tp}    exp_dl_tp=${exp_dl_tp}
    ...    log_path=${aasyslog_path}
    ${UL_DL_csv_file_path_dict}    Capture TTI log    filter=dlFdSchedData    log_time=4    tti_log=${Test_case_log_dir}/${tti_log_name}
    ${dl_tti_file}    Get From Dictionary    ${UL_DL_csv_file_path_dict}    DL
    ${dmrsConfigType_value_list}    TTI_Stream.get_dlFdSchedData_dmrsConfigType_value    file_path=${dl_tti_file}
    ${rat0Bitmap_value_list}    TTI_Stream.get_dlFdSchedData_rat0Bitmap_value    file_path=${dl_tti_file}
    ${dmrsConfigType_vaild_result}    ${dmrsConfigType_invaild_result}    Check_list_Only_Contain_one_value
    ...    input_list=${dmrsConfigType_value_list}    check_value=TYPE2
    ${rat0Bitmap_vaild_result}    ${rat0Bitmap_invaild_result}    Check_list_Only_Contain_one_value
    ...    input_list=${rat0Bitmap_value_list}    check_value=0
    ${dmrsConfigType_invaild_len}    Get Length    ${dmrsConfigType_invaild_result}
    ${rat0Bitmap_invaild_len}    Get Length    ${rat0Bitmap_invaild_result}
    Run Keyword And Continue On Failure     Should Be True    ${dmrsConfigType_invaild_len}==${0}
    Run Keyword And Continue On Failure     Run Keyword If    ${actDlDynSwitchAlloc}==${False}    Should Be True    ${rat0Bitmap_invaild_len}==${0}
    Run Keyword And Continue On Failure     Run Keyword If    ${actDlDynSwitchAlloc}==${True}    Should Be True    ${rat0Bitmap_invaild_len}>${500}

Case 02 UE start Traffic
    [Arguments]    ${dl_mbps}    ${ul_mbps}    ${ue_id_list}    ${tti_log_name}    ${trf_num}=${1}
    SA UE Attach on cell    if_ul=${True}    if_dl=${True}    trf_num=${trf_num}    ue_id_list=${ue_id_list}    dl_mbps=${dl_mbps}
    ...    ul_mbps=${ul_mbps}
    ${aasyslog_path}    Collect Aasyslog    log_time=1m
    ${csv_file_path}    Capture TTI log    tti_log=${Test_case_log_dir}/${tti_log_name}    filter=dlFdSchedData|dlHarqRxDataArray    log_time=3
    [Return]    ${aasyslog_path}    ${csv_file_path}
    [Teardown]    Stop Traffic and release UE    ue_id_list=${ue_id_list}

Case 02 check Point
    [Arguments]    ${aasyslog_path}    ${tti_path}    ${exp_dl_tp}
    Check TP From Aasyslog    ul_list=${dl_cell_list1}    dl_list=${dl_cell_list1}    exp_ul_tp=10    exp_dl_tp=${exp_dl_tp}
    ...    log_path=${aasyslog_path}
    ${dl_tti_file}    Get From Dictionary    ${tti_path}    DL
    ${input_dict}    TTI_Stream.get_dlFdSchedData_rat0Bitmap_physCellId    file_path=${dl_tti_file}
    ${result_list}    Check_rat0Bitmap_and_physCellId    input_dict=${input_dict}
    ${bler}    TTI_Stream.get_HarqRxDataArray_ackNack_number    file_path=${dl_tti_file}    direction=dl
    ${physCellId_num}    Get Length    ${result_list}
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${physCellId_num}    ${6}
    Run Keyword And Continue On Failure    List Should Not Contain Value    ${result_list}    ${False}
    Run Keyword And Continue On Failure    Should Be True    ${bler}<=${1}

Case 04 UE start Traffic
    [Arguments]    ${dl_mbps}    ${ul_mbps}    ${tti_log_name}
    SA UE Attach on cell    if_ul=${True}    if_dl=${True}    trf_num=${9}    ue_id_list=${all_ue_list[10:11]}    dl_mbps=${dl_mbps}
    ...    ul_mbps=${ul_mbps}
    SA UE Attach on cell    if_ul=${True}    if_dl=${True}    trf_num=${3}    ue_id_list=${all_ue_list[11:12]}    dl_mbps=${dl_mbps}
    ...    ul_mbps=${ul_mbps}
    ${aasyslog_path}    Collect Aasyslog    log_time=1m
    ${csv_file_path}    Capture TTI log    tti_log=${Test_case_log_dir}/${tti_log_name}    filter=dlFdSchedData|dlHarqRxDataArray    log_time=3
    [Return]    ${aasyslog_path}    ${csv_file_path}
    [Teardown]    Stop Traffic and release UE    ue_id_list=${all_ue_list[10:12]}

Case 04 check Point
    [Arguments]   ${aasyslog_path}    ${tti_path}=none    ${exp_ul_tp}=105    ${exp_dl_tp}=1380    ${cell_list}=${dl_cell_list2}
    ...    ${check_numOfPrb}=${True}    ${exp_bler}=${0.5}
    Check TP From Aasyslog    ul_list=${cell_list}    dl_list=${cell_list}    exp_ul_tp=${exp_ul_tp}    exp_dl_tp=${exp_dl_tp}
    ...    log_path=${aasyslog_path}
    ${dl_tti_file}    Get From Dictionary    ${tti_path}    DL
    ${rat0Bitmap_value_list}    TTI_Stream.get_dlFdSchedData_rat0Bitmap_value    file_path=${dl_tti_file}
    ${rat0Bitmap_vaild_result}    ${rat0Bitmap_invaild_result}    Check_list_Only_Contain_one_value
    ...    input_list=${rat0Bitmap_value_list}    check_value=0
    ${bler}    TTI_Stream.get_HarqRxDataArray_ackNack_number    file_path=${dl_tti_file}    direction=dl
    ${rat0Bitmap_invaild_len}    Get Length    ${rat0Bitmap_invaild_result}
    Run Keyword And Continue On Failure    Should Be True    ${rat0Bitmap_invaild_len}>=${0}
    Run Keyword And Continue On Failure    Should Be True    ${bler}<=${exp_bler}
    Run Keyword If    ${check_numOfPrb}    Check slot numOfPrb rrmDlUsedMcs Value    tti_path=${dl_tti_file}

Check slot numOfPrb rrmDlUsedMcs Value
    [Arguments]    ${tti_path}
    @{check_key_list}    Create List    13    14
    ${slot_dict}    TTI_Stream.get_dlFdSchedData_slot_numOfPrb_rrmDlUsedMcs    file_path=${tti_path}
    ${slot0_rrmDlUsedMcs_len}    ${slot0_rrmDlUsedMcs_numOfPrb_216_len}    Count_the_value_of_two_layers_list    input_list=${slot_dict['0']}
    ...    check_key_list=${check_key_list}    check_value=216
    ${slot0_rrmDlUsedMcs_len}    ${slot0_rrmDlUsedMcs_numOfPrb_51_len}    Count_the_value_of_two_layers_list    input_list=${slot_dict['0']}
    ...    check_key_list=${check_key_list}    check_value=51
    ${slot1_rrmDlUsedMcs_len}    ${slot1_rrmDlUsedMcs_numOfPrb_216_len}    Count_the_value_of_two_layers_list    input_list=${slot_dict['1']}
    ...    check_key_list=${check_key_list}    check_value=216
    ${slot1_rrmDlUsedMcs_len}    ${slot1_rrmDlUsedMcs_numOfPrb_51_len}    Count_the_value_of_two_layers_list    input_list=${slot_dict['1']}
    ...    check_key_list=${check_key_list}    check_value=51
    ${total_numOfPrb_216}    Evaluate    ${slot0_rrmDlUsedMcs_numOfPrb_216_len}+${slot1_rrmDlUsedMcs_numOfPrb_216_len}
    ${total_numOfPrb_51}    Evaluate    ${slot0_rrmDlUsedMcs_numOfPrb_51_len}+${slot1_rrmDlUsedMcs_numOfPrb_51_len}
    ${diff_numOfPrb}    Evaluate    abs(${total_numOfPrb_216}-${total_numOfPrb_51})
    Run Keyword And Continue On Failure    Should Be True    ${slot0_rrmDlUsedMcs_len}>${0}
    Run Keyword And Continue On Failure    Should Be True    ${slot1_rrmDlUsedMcs_len}>${0}
    Run Keyword And Continue On Failure    Should Be True    ${diff_numOfPrb}<${5}

Case 06 UE start Traffic
    [Arguments]    ${tti_log_name}
    SA UE Attach on cell    if_ul=${True}    if_dl=${True}    trf_num=${3}    ue_id_list=${all_ue_list[0:1]}    dl_mbps=170    ul_mbps=130
    SA UE Attach on cell    if_ul=${True}    if_dl=${True}    trf_num=${2}    ue_id_list=${all_ue_list[1:3]}    dl_mbps=1    ul_mbps=1
    ${aasyslog_path}    Collect Aasyslog    log_time=90s
    ${csv_file_path}    Capture TTI log    tti_log=${Test_case_log_dir}/${tti_log_name}    filter=dlFdSchedData|dlHarqRxDataArray    log_time=3
    [Return]    ${aasyslog_path}    ${csv_file_path}
    [Teardown]    Stop Traffic and release UE    ue_id_list=${all_ue_list[0:3]}

Case 06 check Point
    [Arguments]   ${aasyslog_path}=none    ${tti_path}=none    ${exp_ul_tp}=130    ${exp_dl_tp}=160
    Check TP From Aasyslog    ul_list=${dl_cell_list1[0:1]}    dl_list=${dl_cell_list1[0:1]}    exp_ul_tp=${exp_ul_tp}    exp_dl_tp=${exp_dl_tp}
    ...    log_path=${aasyslog_path}
    ${dl_tti_file}    Get From Dictionary    ${tti_path}    DL
    ${rat0Bitmap_value_list}    TTI_Stream.get_dlFdSchedData_rat0Bitmap_value    file_path=${dl_tti_file}
    ${startPrb_value_list}    TTI_Stream.get_dlFdSchedData_startPrb_value    file_path=${dl_tti_file}
    ${rat0Bitmap_vaild_result}    ${rat0Bitmap_invaild_result}    Check_list_Only_Contain_one_value
    ...    input_list=${rat0Bitmap_value_list}    check_value=0
    ${startPrb_min_value}    Evaluate    min(${startPrb_value_list})
    ${bler}    TTI_Stream.get_HarqRxDataArray_ackNack_number    file_path=${dl_tti_file}    direction=dl
    ${rat0Bitmap_invaild_len}    Get Length    ${rat0Bitmap_invaild_result}
    Run Keyword And Continue On Failure    Should Be True    ${rat0Bitmap_invaild_len}>${100}
    Run Keyword And Continue On Failure    Should Be True    ${startPrb_min_value}>=${9}
    Run Keyword And Continue On Failure    Should Be True    ${bler}<=${0.5}

SA UE Attach on cell And Circular Flow
    [Arguments]    ${if_ul}    ${if_dl}    ${ue_id}    ${interval_time}    ${count}    ${dl_mbps}=0    ${ul_mbps}=0
    ...    ${nwslice}=1    ${pdu_id}=1
    Set Internal Traffic Type To UEs    ue_id=${ue_id}    pdu_id=${pdu_id}
    Register Ue With Default Pdu Session    ue_id=${ue_id}    nwslice=${nwslice}    other_pud=${False}  other_plmn=${False}    pdu_id=${pdu_id}
    FOR   ${i}  IN RANGE  ${count}
        ${tmp}    Evaluate    ${count}-${1}
        sleep    ${interval_time}
        Run Keyword If    ${if_dl}    AP_lib.Execute Egate Command
        ...    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=${dl_mbps} trf_id=1 seconds=6000
        ...    pass_regexp=Started Downlink Internal traffic
        Run Keyword If    ${if_ul}    AP_lib.Execute Egate Command
        ...    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=${ul_mbps} trf_id=1 seconds=6000
        ...    pass_regexp=Started Uplink Internal traffic
        sleep   60s
        ${UL_DL_csv_file_path_dict}    Run Keyword If    ${i}==${tmp}    Capture TTI log    filter=dlFdSchedData|dlDtxOptimData|dlHarqRxDataArray
        ...    log_time=3    tti_log=${Test_case_log_dir}/ttitrace_streaming
        Run Keyword If    ${if_dl}    AP_lib.Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 trf_id=1
        ...    pass_regexp=Traffic was stopped
    END
    [Return]    ${UL_DL_csv_file_path_dict}

Case 10 UE start Traffic
    [Arguments]
    SA UE Attach on cell    if_ul=${True}    if_dl=${True}    ue_id_list=${all_ue_list[1:2]}    dl_mbps=2    ul_mbps=1    nwslice=2
    SA UE Attach on cell    if_ul=${True}    if_dl=${True}    ue_id_list=${all_ue_list[2:3]}    dl_mbps=2    ul_mbps=1    nwslice=3
    ${csv_file_path}    SA UE Attach on cell And Circular Flow    if_ul=${True}    if_dl=${True}    ue_id=${all_ue_list[0]}
    ...    dl_mbps=2    ul_mbps=1    nwslice=1    interval_time=20s    count=${8}
    [Return]    ${csv_file_path}
    [Teardown]    Stop Traffic and release UE    ue_id_list=${all_ue_list[0:3]}

Case 10 Check TTI Log
    [Arguments]    ${tti_path}    ${dlDtxOptimEvent_value}=REMOVALUE
    ${dl_tti_file}    Get From Dictionary    ${tti_path}    DL
    ${bler}    TTI_Stream.get_HarqRxDataArray_ackNack_number    file_path=${dl_tti_file}    direction=dl
    ${dlDtxOptimEvent_dict}    TTI_Stream.get_dlDtxOptimData_dlDtxOptimEvent    file_path=${dl_tti_file}
    ${REMOVALUE_len}    Get From Dictionary    ${dlDtxOptimEvent_dict}    ${dlDtxOptimEvent_value}
    Run Keyword And Continue On Failure    Should Be True    ${bler}<=${0}
    Run Keyword And Continue On Failure    Should Be True    ${REMOVALUE_len}>${500}

Case 10 check Counter
    [Arguments]    ${befor_counter}
    ${after_counter}    get_bts_counters    counter_ids=M55308C33000,M55308C33001,M55308C11001,M55308C11002    NRCELL_ID=${NRCELL3_ID}
    ${all_counter_value_list}    Case7_Count_counter_value    befor_counter_list=${befor_counter}    after_counter_list=${after_counter}
    FOR  ${counter_value_list}  IN  @{all_counter_value_list}
        ${result}    set variable    ${counter_value_list[-1]}
        Run Keyword And Continue On Failure     Should Be True    ${result}>${0}
    END

Generate EDA case UE ID And Counter ID
    [Arguments]    ${ue_number}    ${counter_list}
    @{ue_id_list}    Create List
    FOR   ${id}   IN RANGE  ${1}   ${ue_number}
        Append To List    ${ue_id_list}    ${id}
    END
    ${counter_ids}=    Evaluate   ','.join(${counter_list})
    [Return]    ${ue_id_list}    ${counter_ids}

EDA case1 check Point
    [Arguments]   ${cell_list}    ${log_name}    ${tti_log_name}=ttitrace_streaming    ${exp_ul_tp}=60    ${exp_dl_tp}=660
    ${aasyslog_path}    Stop Capture Aasyslog    log_name=${log_name}
    ${csv_file_path}    Capture TTI log    tti_log=${Test_case_log_dir}/${tti_log_name}    filter=dlFdSchedData|dlHarqRxDataArray    log_time=3
    Check TP From Aasyslog    ul_list=${cell_list}    dl_list=${cell_list}    exp_ul_tp=${exp_ul_tp}    exp_dl_tp=${exp_dl_tp}
    ...    log_path=${aasyslog_path}
    ${dl_tti_file}    Get From Dictionary    ${csv_file_path}    DL
    ${bler}    TTI_Stream.get_HarqRxDataArray_ackNack_number    file_path=${dl_tti_file}    direction=dl
    Run Keyword And Continue On Failure    Should Be True    ${bler}<=${0.5}

Calculate based on counter value
    [Arguments]    ${result_list}
    ${sum_result}    Evaluate    sum(${result_list[1:]})
    ${tmp1}    Run Keyword If    '${result_list[${0}]}' != '${0}'    Evaluate    ${sum_result}/${result_list[${0}]}
    ${Calculate_result}    Set Variable If    '${result_list[${0}]}' != '${0}'    ${tmp1}    ${result_list[${0}]}
    [Return]    ${Calculate_result}

EDA Counter Check Point
    [Arguments]    ${counter_dict}    ${except_msg3_value}    ${counter_id_list}
    @{result_list}    Create List
    FOR   ${i}  IN  @{counter_id_list}
        ${result}    Get From Dictionary    ${counter_dict}    ${i}
        Append To List    ${result_list}    ${result}
    END
    ${MSG4_success_rate}    Evaluate    ${result_list[${1}]}/${result_list[${0}]}
    ${RRC_Establish_success_rate}    Evaluate    ${result_list[${2}]}/${result_list[${1}]}
    ${Ul_PRB_average_market_share}    Evaluate    ${result_list[${3}]}/${result_list[${4}]}
    ${Dl_PRB_average_market_share}    Evaluate    ${result_list[${5}]}/${result_list[${6}]}

    ${DATA_SLOT_PDSCH_result}    Calculate based on counter value    result_list=${result_list[7:10]}
    ${DATA_SLOT_PUSCH_result}    Calculate based on counter value    result_list=${result_list[10:13]}
    ${SGNB_SA_DU_ADMISSION_REQ1_result}    Calculate based on counter value    result_list=${result_list[13:15]}

    ${SA_admission_failure_rate}    Set Variable    ${0}
    FOR   ${i}  IN  @{result_list[15:]}
        ${SA_admission_failure_rate}    Evaluate    ${SA_admission_failure_rate}+${i}
    END

    ${Counter_KPI_result}    Create Dictionary    MSG3_receive=${result_list[${0}]}    MSG5_receive=${result_list[${1}]}
    ...    MSG4_success_rate=${MSG4_success_rate}    RRC_attempts=${result_list[${2}]}    RRC_Establish_success_rate=${RRC_Establish_success_rate}
    ...    Ul_PRB_average_market_share=${Ul_PRB_average_market_share}    Dl_PRB_average_market_share=${Dl_PRB_average_market_share}
    ...    DATA_SLOT_PDSCH=${DATA_SLOT_PDSCH_result}    DATA_SLOT_PUSCH=${DATA_SLOT_PUSCH_result}
    ...    SGNB_SA_DU_ADMISSION_REQ1=${SGNB_SA_DU_ADMISSION_REQ1_result}    SA_admission_failure_rate=${SA_admission_failure_rate}

    Run Keyword And Continue On Failure    Should Be True    ${result_list[${0}]}>=${except_msg3_value}
    Run Keyword And Continue On Failure    Should Be True    ${result_list[${1}]}>=${except_msg3_value}
    Run Keyword And Continue On Failure    Should Be True    ${MSG4_success_rate}>=0.99
    [Return]    ${Counter_KPI_result}

Stop Capture Aasyslog
    [Arguments]    ${log_name}
    ${current_time}    DateTime.Get Current Date    result_format=%Y-%m-%d_%H:%M:%S
    ${local_path}    set variable    ${OUTPUT_DIR}/${current_time}_${log_name}
    Download Aasyslog File From GNB    log_path=/tmp/${log_name}    local_path=${local_path}
    ...                                gnb_index=${0}    du_index=${0}
    ...                                host=${EMPTY}    username=${gNB_ssh_name}    password=${gNB_ssh_password}
    [Return]    ${local_path}
    [Teardown]    Teardown the Aasyslog save progress    gnb_index=${0}    du_index=${0}
    ...    host=${EMPTY}    username=${gNB_ssh_name}    password=${gNB_ssh_password}

Capture aasyslog And check TP
    [Arguments]    ${cell_list}    ${exp_ul_tp}    ${exp_dl_tp}    ${log_time}=90s
    ${aasyslog_path}    Collect Aasyslog    log_time=${log_time}
    Check TP From Aasyslog    ul_list=${cell_list}    dl_list=${cell_list}    exp_ul_tp=${exp_ul_tp}    exp_dl_tp=${exp_dl_tp}
    ...    log_path=${aasyslog_path}

Batch Register Ue With Default Pdu Session
    [Arguments]    ${ue_id}=1     ${pdu_id}=1    ${gw}=1    ${nwslice}=1
    Set Internal Traffic Type To UEs    ue_id=${ue_id}
    AP_lib.Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE performed Registration type INITIAL_REGISTRATION
    sleep   10s
    AP_lib.Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice} gw=${gw}
    ...     pass_regexp=setup/reestablishment complete
    sleep   5s

Batch SA UE Attach on cell
    [Arguments]    ${start_ue_id}    ${step}    ${ue_num}   ${nwslice}=1    ${pdu_id}=1
    FOR  ${i}  IN RANGE    ${start_ue_id}    ${ue_num}    ${step}
        ${ue_id}    Set Variable    ${i}-${i+${step}-${1}}
        Batch Register Ue With Default Pdu Session    ue_id=${ue_id}     pdu_id=${pdu_id}    gw=1    nwslice=${nwslice}
    END
    sleep    5s

Batch SA UE Dettach on cell
    [Arguments]    ${start_ue_id}    ${step}    ${ue_num}
    FOR  ${i}  IN RANGE    ${start_ue_id}    ${ue_num}    ${step}
        ${ue_id}    Set Variable    ${i}-${i+${step}-${1}}
        AP_lib.Execute Egate Command   ue_deregister id=${ue_id} ue_deregister_type=switch_off
    END

EDA Case Test
    [Arguments]    ${counter_list}    ${cycles}=${7}    ${cell_list}=${dl_cell_list1[:5]}    ${ue_number}=${81}    ${exp_ul_tp}=40
    ...    ${exp_dl_tp}=630    ${log_name}=aasyslog_tput.txt    ${step}=${20}
    ${ue_id_list}    ${counter_ids}    Generate EDA case UE ID And Counter ID    ue_number=${ue_number}    counter_list=${counter_list}
    ${befor_counter}    Wait Until Keyword Succeeds    5min   20s    get_bts_counters    counter_ids=${counter_ids}    NRCELL_ID=${NRCELL3_ID}
    Log To Console    Start 60UEs Traffic....
    SA UE Attach on cell    if_ul=${True}    if_dl=${True}    trf_num=${5}    ue_id_list=${ue_id_list[0:1]}    dl_mbps=150    ul_mbps=60
    Capture aasyslog And check TP    cell_list=${cell_list}    exp_ul_tp=${exp_ul_tp}    exp_dl_tp=${exp_dl_tp}
    FOR   ${i}   IN RANGE  ${cycles}
        Log To Console    UE 20-${ue_number} attach times: ${i}
        Run Keyword If    '${i}'=='${0}'    Start aasyslog capture    duration=20s    log_name=${log_name}
        Batch SA UE Attach on cell    start_ue_id=${21}    step=${step}    ue_num=${ue_number}
        Run Keyword If    '${i}'=='${0}'    EDA case1 check Point    cell_list=${cell_list}
        ...    tti_log_name=ttitrace_streaming     exp_ul_tp=${exp_ul_tp}   exp_dl_tp=${exp_dl_tp}    log_name=${log_name}
        Batch SA UE Dettach on cell    start_ue_id=${21}    step=${step}    ue_num=${ue_number}
    END
    Capture aasyslog And check TP    cell_list=${cell_list}    exp_ul_tp=${exp_ul_tp}    exp_dl_tp=${exp_dl_tp}
    Stop Traffic and release UE    ue_id_list=${ue_id_list[0:1]}
    sleep    6min
    ${after_counter}   get_bts_counters    counter_ids=${counter_ids}    NRCELL_ID=${NRCELL3_ID}
    ${all_counter_value_dict}    All_Counter_Value_Dict    befor_counter_list=${befor_counter}    after_counter_list=${after_counter}
    ...    counter_id_list=${counter_list}
    ${except_msg3_value}    Evaluate    (${ue_number}-${20})*${cycles}+1
    EDA Counter Check Point    counter_dict=${all_counter_value_dict}    except_msg3_value=${except_msg3_value}    counter_id_list=${counter_list}
    [Teardown]    Save Snapshot
