*** Settings ***
Documentation     author: Chen Yin
...               contact: yin.1.chen@nokia-sbell.com
...               squad group: SG_02
Library           OperatingSystem
Library           Collections
Library           String
Library           BuiltIn
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.collectors.snapshot     WITH NAME     snapshot
Resource          taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001655/Resources/1347_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Library           taf.ul.parser.pcap        WITH NAME    pcap
Library    taf.hw.rf_attenuator    WITH NAME    attenuator
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/data_analysis.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Library           taf.sw.syslog

*** Variables ***
${cur_relative_dir}      testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB009510/Resources
${tshark_path}    /usr/bin/tshark
${xpath_csiTransmitPower_filed_name}       .//DlData_CsiRsResource_t.csiTransmitPower
${tcpdump_command_template}    {tshark_path} -r {pcap_file} -Y "nr-rrc" -T pdml
${powerControlOffsetSS_field_filter}      \"nr-rrc.c1 == 0 && nr-rrc.powerControlOffsetSS && nr-rrc.criticalExtensions == 0\"
${powerControlOffsetSS_72e_field_filter}      \"nr-rrc.c1 == 0 && nr-rrc.powerControlOffsetSS\"
${dldata_csirssendreq_trs_field_filter}      \"DlData_CsiRsResourceL1sw_t.trsInfo==1 && 3gpp.subcellid==17\"
${dldata_csirssendreq_trs_command_template}    {tshark_path} -r {pcap_file} -Y ${dldata_csirssendreq_trs_field_filter} -T pdml
${dldata_pdschsendreq_trs_field_filter}      \"dldata_pdschsendreql1sw && 3gpp.subcellid==17 && 3gpp.rnti!=65535\"
${dldata_pdschsendreq_trs_command_template}    {tshark_path} -r {pcap_file} -Y ${dldata_pdschsendreq_trs_field_filter} -T pdml
${powerControlOffsetSS_field_name}      nr-rrc.powerControlOffsetSS
${sfn_field_name}      _3gpp.sfn
${slot_field_name}      _3gpp.slot




*** Keywords ***
Test Case Setup
    [Arguments]    ${scf_file_name}
    robot_common_operations.Common Case Setup
    ERR_WRN_Check.Stop BTSlogs Collection And Download Logs To Log Server    Login_UTE=${True}
    COAM Create log directory
    Wait Until Keyword Succeeds    5 min    5 sec    Connect to gnb coam via ssl
    ${scf_base_path}    String.Replace String    ${CURDIR}    ${cur_relative_dir}    ${scf_relative_dir}
    Wait Until Keyword Succeeds    15 min    5 sec    COAM Commission with scf file
    ...     scf_file_path=${scf_base_path}/${testline_name}/${scf_file_name}
#    ...     timeout=600
    ...     is_pdl_checking_needed=True
    COAM Wait for gnb ready and cell setup    timeout=15min
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}



Test Case Teardown
    robot_common_operations.Common Case Teardown
    Run keyword And Ignore Error    Run Keyword If Test Failed    COAM Save snapshot via rest api
    Run keyword And Ignore Error    CI_interface.Common Case Teardown
    Run Keyword And Ignore Error    csn.disconnect    connection=ABIL Loner
    Run Keyword And Ignore Error    csn.disconnect    connection=RU
    Run Keyword And Ignore Error    csn.disconnect    connection=ABIL Master
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    run keyword and ignore error    COAM Teardown gnb connections

UE Attach and Start Traffic
    [Arguments]     ${ue_type}      ${ue_index}=${0}      ${cap_index}=${0}
#    ADB Reboot UE      ue_index=${ue_index}
    Sleep       20s
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    ui_version=Mi11UI12
    Connect to Common Unit Master  alias=ASIK MASTER
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    cap_index=${cap_index}
    Connect to Common Unit Master  alias=ASIK MASTER
    connect to gnb coam via ssl    connection=GNB_OAM
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${DL_THROUGHPUT}    duration=${DURATION}
    ...                       ue_index=${ue_index}    cap_index=${0}    ip_filter=172.      iperf_port=52965
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${UL_THROUGHPUT}     iperf_port=52965
    ...                       duration=${DURATION}    ue_index=${ue_index}

UE Attach and Start Traffic 72e
    [Arguments]     ${ue_type}      ${ue_index}=${0}      ${cap_index}=${0}
#    ADB Reboot UE      ue_index=${ue_index}
    Sleep       20s
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    ui_version=Mi11UI12
    Connect to Common Unit Master  alias=ASIK MASTER
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    cap_index=${cap_index}
    Connect to Common Unit Master  alias=ASIK MASTER
    connect to gnb coam via ssl    connection=GNB_OAM
    Sleep   5sec
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${DL_THROUGHPUT}    duration=${DURATION}
    ...                       ue_index=${ue_index}    cap_index=${0}    apn=dxdata2    process_num=1
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${UL_THROUGHPUT}
    ...                       duration=${DURATION}    ue_index=${ue_index}    apn=dxdata2    process_num=1

Checking UE TPUT
    [Arguments]    ${ue_type}    ${target_throughput_ul}=${UL_TDD_EXPECT_100M}    ${target_throughput_dl}=${DL_TDD_EXPECT_100M}
    ${cell_id}    Create List    ${nrCellIdentity}[0]
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}     duration=2m    check_source=Aasyslog
    ${dl_tput}      power_ue.Check Tput    ue_type=${ue_type}    direction=DL    cells=${cell_id}    check_source=Aasyslog
    ...                                    log=${tput_log}    target_throughput=${target_throughput_dl}
    ${ul_tput}      power_ue.Check Tput    ue_type=${ue_type}    direction=UL    cells=${cell_id}    check_source=Aasyslog
    ...                                    log=${tput_log}    target_throughput=${target_throughput_ul}
    [Return]    ${dl_tput[0]}[average]    ${ul_tput[0]}[average]

UE teardown
    [Arguments]    ${ue_type}
    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul    iperf_port=52965
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl    iperf_port=52965
    power_ue.UE Detach     ue_type=${ue_type}

UE teardown 72e
    [Arguments]    ${ue_type}
    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl
    power_ue.UE Detach     ue_type=${ue_type}


update parameter
    [Arguments]    ${parameter_list}      ${connection}=GNB_OAM
    Wait Until Keyword Succeeds    5 min    5 sec    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    15 min   5 sec    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameter_list}
    [teardown]    COAM Teardown gnb connections    connection=${connection}

Start Collecting Syslog
    Log    Starting Syslog Collection    console=yes
    taf.sw.syslog.Start Syslog    log_dir=${TS_CASE_LOG_PATH}    log_name=syslog.log    ip=192.168.255.126
    ...  alias=local_syslog
    ...  ssh_username=${tl.test_pc.default_ssh_connection_details.username}
    ...  ssh_password=${tl.test_pc.default_ssh_connection_details.password}
    Set Test Variable    ${local_syslog}    ${TS_CASE_LOG_PATH}/syslog.log

Collect Syslog
    Log    END Syslog Collection    console=yes
    taf.sw.syslog.Collect Syslog Results    alias=local_syslog
    [Teardown]  Run Keyword And Ignore Error  taf.sw.syslog.Teardown All Aliases For Syslog

UE detach and stop traffic
    [Arguments]     ${ue_type}
    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul    iperf_port=20965
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl    iperf_port=20965
    power_ue.UE Detach     ue_type=${ue_type}

Setup aasyslog before log collectting
    [Arguments]
    ...    ${aa_sys_mode}=2    ${aa_sys_addr}=0x7F000001    ${aa_sys_udp_port}=0xC738
    Teardown the Aasyslog save progress
    Aasyslog precondition
    ...      aa_sys_mode=${aa_sys_mode}
    ...      aa_sys_addr=${aa_sys_addr}
    ...      aa_sys_udp_port=${aa_sys_udp_port}

Checking syslog for ssPbchBlockPower
    ${output_1}      run     cat '${local_syslog}'|grep '"ssBlockPower":-349'
    ${output_2}      run     cat '${local_syslog}'|grep 'Stored ssBlockPower with value:-349'
    ${status_1}      Run Keyword AND Return Status      Should Not be empty      ${output_1}
    ${status_2}      Run Keyword AND Return Status      Should Not be empty      ${output_2}
    Should be True      '${status_1}'=='True' or '${status_2}'=='True'

Checking syslog for ssPbchBlockPower 72e
    ${output_1}      run     cat '${local_syslog}'|grep '"ssBlockPower":'
    ${output_2}      run     cat '${local_syslog}'|grep 'Stored ssBlockPower with value:'
    ${status_1}      Run Keyword AND Return Status      Should Not be empty      ${output_1}
    ${status_2}      Run Keyword AND Return Status      Should Not be empty      ${output_2}
    Should be True      '${status_1}'=='True' or '${status_2}'=='True'

Get wireshark title
    COAM Navigate to login page via webUI    download_dir=${OUTPUT DIR}
    ${current_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    ${stream}    Split String    ${current_version['Active']}

	${stream}      String.Split String       ${current_version['Active']}      _
    Run keyword if      "${stream}[0]"=="SBTS25R1"
    ...      Get all wireshark title in branch release
    ...      ELSE
    ...      Get all wireshark title in Trunk
    COAM selenium logout

Get all wireshark title in branch release
    Set Suite Variable    ${dldata_pdschsendreq_command_template}      {tshark_path} -r {pcap_file} -Y dldata_pdschsendreq -T pdml
    Set Suite Variable    ${dft_flag_field_name}      DlData_CsiRsResource_t.trsInfo
    Set Suite Variable    ${dldata_csirssendreq_command_filter}          \"dldata_csirssendreq\"
    Set Suite Variable    ${dldata_csirssendreq_command_template}         {tshark_path} -r {pcap_file} -Y dldata_csirssendreq -T pdml
    Set Suite Variable    ${dldata_pdschsendreq_command_filter}      \"dldata_pdschsendreq&&3gpp.rnti!=65535\"
    Set Suite Variable    ${dldata_pdschsendreq_numofprb_field_name}      DlData_PdschGrant.numOfPrb
    Set Suite Variable    ${dldatacsirssendreq_msg}      \"dldata_csirssendreq\"
    Set Suite Variable
    ...    ${filter_expression}      dldata_csirssendreq&&DlData_CsiRsResource_t.csiRsConfig !=8&& 3gpp.subcellid==6

Get all wireshark title in Trunk
    Set Suite Variable    ${dldata_pdschsendreq_command_template}      {tshark_path} -r {pcap_file} -Y dldata_pdschsendreql1sw -T pdml
    Set Suite Variable    ${dft_flag_field_name}      DlData_CsiRsResourceL1sw_t.trsInfo
    Set Suite Variable    ${dldata_csirssendreq_command_filter}          \"dldata_csirssendreql1sw\"
    Set Suite Variable    ${dldata_csirssendreq_command_template}         {tshark_path} -r {pcap_file} -Y dldata_csirssendreql1sw -T pdml
    Set Suite Variable    ${dldata_pdschsendreq_command_filter}      \"dldata_pdschsendreql1sw&&3gpp.rnti!=65535\"
    Set Suite Variable    ${dldata_pdschsendreq_numofprb_field_name}      DlData_PdschGrantL1sw.numOfPrb
    Set Suite Variable    ${dldatacsirssendreq_msg}      \"dldata_csirssendreql1sw\"
    Set Suite Variable
    ...    ${filter_expression}      dldata_csirssendreql1sw&&DlData_CsiRsResource_t.csiRsConfig !=8&& 3gpp.subcellid==6

Checking bip log for csrispower
    [Arguments]    ${bip_log_path}
    Get wireshark title
    Set Suite Variable    ${command_template_dldatacsirssendreq_msg}      {tshark_path} -r {pcap_file}
    ...      -Y ${dldatacsirssendreq_msg} -T pdml
    ${package}=      Load BIP Log with Template Command
    ...      pcap_file=${bip_log_path}      command_template=${command_template_dldatacsirssendreq_msg}
    pcap.filter_packets_by_expression    filter_expression=${filter_expression}
    ${csiTransmitPower_values}       Get value from Bip Log by xpath     xpath=${xpath_csiTransmitPower_filed_name}
    ${csiTransmitPower_value}      Remove Duplicates      ${csiTransmitPower_values}
    ${length}    Get Length    ${csiTransmitPower_value}
    Should Be True    ${length}>=${2}
    List Should Contain Value    ${csiTransmitPower_value}    -330

Checking powerControlOffsetSS in tcpdump during attach procedure
    [Arguments]    ${tcpdump_file_path}
    Load BIP Log with Template Command    pcap_file=${tcpdump_file_path}
    ...                                   command_template=${tcpdump_command_template}
    ...                                   tshark_path=${tshark_path}
    Filter Packets By Expression      filter_expression=${powerControlOffsetSS_field_filter}
    ${powerControlOffsetSS_list}      Get value from Bip Log      field_name=${powerControlOffsetSS_field_name}
    ${length}    Get Length    ${powerControlOffsetSS_list}
    FOR      ${i}      IN RANGE      ${length}
        Should be True      ${powerControlOffsetSS_list}[${i}]==${1}
    END

Checking powerControlOffsetSS for 72E in tcpdump during attach procedure
    [Arguments]    ${tcpdump_file_path}
    Load BIP Log with Template Command    pcap_file=${tcpdump_file_path}
    ...                                   command_template=${tcpdump_command_template}
    ...                                   tshark_path=${tshark_path}
    Filter Packets By Expression      filter_expression=${powerControlOffsetSS_72e_field_filter}
    ${powerControlOffsetSS_list}      Get value from Bip Log      field_name=${powerControlOffsetSS_field_name}
    ${length}    Get Length    ${powerControlOffsetSS_list}
    Should be True      ${powerControlOffsetSS_list}[0]==${2}
    FOR      ${i}      IN RANGE    1      ${length}
        Should be True      ${powerControlOffsetSS_list}[${i}]==${1}
    END

Checking numofprb in bip file
    [Arguments]    ${bip_path}
    Get wireshark title
    Load BIP Log with Template Command    pcap_file=${bip_path}
    ...                                   command_template=${dldata_csirssendreq_command_template}
    ...                                   tshark_path=${tshark_path}
    Filter Packets By Expression      filter_expression=${dldata_csirssendreq_command_filter}
    ${dft_flag}      Get Value from Bip Log      field_name=${dft_flag_field_name}
    ${sfn_list}      Get value from Bip Log      field_name=${sfn_field_name}
    ${csirssendreq_length}      Get Length      ${dft_flag}
    ${index_list}      Create List
    FOR      ${i}      IN RANGE      ${csirssendreq_length}
        ${sfn_value}      Set Variable If      ${dft_flag}[${i}]==1    ${sfn_list}[${i}]
        Exit For Loop If      ${dft_flag}[${i}]==1
    END
    Load BIP Log with Template Command    pcap_file=${bip_path}
    ...                                   command_template=${dldata_pdschsendreq_command_template}
    ...                                   tshark_path=${tshark_path}
    Filter Packets By Expression      filter_expression=${dldata_pdschsendreq_command_filter}
    ${dft_flag}      Get Value from Bip Log      field_name=${dft_flag_field_name}
    ${pdschsendreq_sfn_list}      Get value from Bip Log      field_name=${sfn_field_name}
    ${numofprb}      Get Value from Bip Log      field_name=${dldata_pdschsendreq_numofprb_field_name}
    ${pdschsendreq_legth}      Get Length      ${pdschsendreq_sfn_list}
    FOR      ${j}      IN RANGE      ${pdschsendreq_legth}
        Run keyword If      ${pdschsendreq_sfn_list}[${j}]==${sfn_list}[${i}]      Exit For Loop
    END
    Should be True      ${numofprb}[${j}]>${0}

Checking pdsch is scheduled in same slot
    [Arguments]    ${bip_path}
    Get wireshark title
    Load BIP Log with Template Command    pcap_file=${bip_path}
    ...                                   command_template=${dldata_csirssendreq_trs_command_template}
    ...                                   tshark_path=${tshark_path}
    ${sfn_list}      Get value from Bip Log      field_name=${sfn_field_name}
    ${slot_list}      Get value from Bip Log      field_name=${slot_field_name}
    Load BIP Log with Template Command    pcap_file=${bip_path}
    ...                                   command_template=${dldata_pdschsendreq_trs_command_template}
    ...                                   tshark_path=${tshark_path}
    FOR    ${sfn}    ${slot}    IN ZIP    ${sfn_list}    ${slot_list}
        ${numofprb}    Check expression in Bip Log by Name    filter_expression=3gpp.sfn==${sfn} and 3gpp.slot==${slot}
        ...                                                 field_name=${dldata_pdschsendreq_numofprb_field_name}
        Should be True      ${numofprb[0]}>${0}
    END