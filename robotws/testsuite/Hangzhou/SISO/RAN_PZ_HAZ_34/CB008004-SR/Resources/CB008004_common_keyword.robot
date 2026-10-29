*** Settings ***
Documentation
...               author: wang zhouqun
...               contact: zhouqun.wang@nokia-sbell.com
...               squad group: MMW_SG_04

Library     taf.sbts.oam.coam.admin       WITH NAME    coam
Library     taf.transport.ssh            WITH NAME    csn
Library     taf.config.scf.interface.scf     WITH NAME   scf
Library     taf.hw.rf_attenuator    WITH NAME    att
Library     taf.ul.mobile.ui.android    WITH NAME    android_mobile
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/TTI_Trace_Analysis_MMW4.py
Library     TTI_Trace_Analysis_MMW4.TTI_Trace_analysis    WITH NAME    TTI_Trace
Library     ute_syslog
Library     taf.collectors.btslog  WITH NAME   btslog
Library     taf.selenium.sbts     WITH NAME     selenium_coam
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
${CURDIR_path}             ${CURDIR}/../../../../../../commissionings/HGZ/7_5_UTE5G402T7422/
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
${WEBEM_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${DU_OAM_IP}                ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${ue_type}    ${tl.ues[2].capabilities[3]}
${IPERF_portlist}    ${tl.appserver.iperf_details.ports}
${cell_1}    ${16385}
${cell_2}    ${16386}
${dist_actEcpriRuPtpOnlySync}     MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
${dist_frameStartOffset}          MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
${dist_sfnOffset}     MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
${dist_actCellTimingOffset}     MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
${TEST_NAME}          tmp
${btslog_para_1}     [DL_N1_1_C1] alpha
${btslog_para_2}     [DL_N1_1_C1] beta
${btslog_para_3}     [UL_N1_1_C3] alpha
${btslog_para_4}     [UL_N1_1_C3] beta
${TEST_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}       ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}       ${tl.test_pc.default_ssh_connection_details.password}

*** Keywords ***
Case Suite Setup
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup
    Iptables UDP destination port ACCEPT

Iptables UDP destination port ACCEPT
    [Arguments]    ${connection}=ute
    ssh.Connect to     hostname=${TEST_PC_IP}   username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
    ssh.Send Command
    ...    command=sudo iptables -I INPUT -i eth0 -p udp --destination-port 51000 -j ACCEPT    connection=${connection}
    [Teardown]       ssh.Disconnect    connection=${connection}

Set parameter Value
    [Arguments]    ${parameter}    ${dist_name}    ${parameter_value}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}
    ...    connection=${connection}
    Log To Console    set ${parameter} to ${parameter_value}
    perform muti Parameter recommissioning    dist_name=${dist_name}    parameter=${parameter}
    ...    value=${parameter_value}    operation=update
    Run keyword and continue on failure    Wait Until Keyword Succeeds    15min    20s    Check cell on air

Setup Commission SCF
    [Arguments]    ${default_scf}    ${connection}=GNB_OAM
    Log To Console    Setup Commission SCF
#    ${default_scf}    Set Default scf name
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}
    ...     connection=${connection}
    COAM Commission with scf file    scf_file_path=${default_scf}    timeout=${1000}
    Run keyword and continue on failure    Wait Until Keyword Succeeds    15min    20s    Check cell on air
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Set Default scf name
    [Arguments]  ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}
    ...    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    ${if_common_load}     run keyword and return status    should contain    ${version_list[2]}    9999
#    ${if_23R3_load}     run keyword and return status    should contain    ${version_list[0]}    SBTS23R3
#    ${default_scf}    set variable if    ${if_common_load}    ${CURDIR_path}SCF_SBTS00.xml
#    ...    ${if_23R3_load}    ${CURDIR_path}SCF_SBTS23R3.xml
    ${version_scf}    set variable if    ${if_common_load}    SBTS00    ${version_list[0]}
    ${default_scf}    set variable    ${CURDIR_path}SCF_${version_scf}
    set suite variable    ${default_scf}
    log to console   ${default_scf}
    [Return]  ${default_scf}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Check cell on air
    [Arguments]    ${connection}=GNB_OAM
    BuiltIn.Log    \n Start to check Cell On Air \n    console=yes
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}
    ...    connection=${connection}
    Verify all cells should be onair
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

perform muti Parameter recommissioning
    [Arguments]   ${dist_name}    ${parameter}   ${value}     ${operation}=create    ${connection}=GNB_OAM
    ...    ${skip_parameter_relation_errors}=${True}     ${should_activate}=${True}
    coam.Perform Parameter Recommissioning
    ...    dist_name=${dist_name}
    ...    parameter=${parameter}
    ...    value=${value}
    ...    operation=${operation}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${should_activate}
    ...    connection=${connection}

Change Multiple Parameter by selenium
    [Arguments]  ${frameStartOffset_value}    ${sfnOffset_value}
    ...    ${despite_errors}=${False}
    ...    ${dist1_frameStartOffset}=${dist_frameStartOffset}/NRCELL-1
    ...    ${dist2_frameStartOffset}=${dist_frameStartOffset}/NRCELL-2
    ...    ${dist1_sfnOffset}=${dist_sfnOffset}/NRCELL-1
    ...    ${dist2_sfnOffset}=${dist_sfnOffset}/NRCELL-2
    log to console    \n***Change Multiple Parameter Online***
    Login to webui
    ${frameStartOffset_dicet1}    Create Dictionary    dist_name=${dist1_frameStartOffset}
    ...    filter_param=Frame start offset    abbr=frameStartOffset
    ${frameStartOffset_dicet2}    Create Dictionary    dist_name=${dist2_frameStartOffset}
    ...    filter_param=Frame start offset    abbr=frameStartOffset
    @{frameStartOffset_list}    create list
    ...     ${frameStartOffset_dicet1}    ${frameStartOffset_dicet2}
    ${sfnOffset_dicet1}    Create Dictionary    dist_name=${dist1_sfnOffset}
    ...    filter_param=SFN offset    abbr=sfnOffset
    ${sfnOffset_dicet2}    Create Dictionary    dist_name=${dist2_sfnOffset}
    ...    filter_param=SFN offset    abbr=sfnOffset
    @{sfnOffset_list}    create list
    ...    ${sfnOffset_dicet1}    ${sfnOffset_dicet2}
    FOR  ${item1}  IN  @{frameStartOffset_list}
        selenium_coam.set_parameter_value  dist_name=${item1}[dist_name]
        ...    filter_param=${item1}[filter_param]
        ...    abbr=${item1}[abbr]    new_value=${frameStartOffset_value}
    END
    FOR  ${item2}  IN  @{sfnOffset_list}
        selenium_coam.set_parameter_value  dist_name=${item2}[dist_name]
        ...    filter_param=${item2}[filter_param]
        ...    abbr=${item2}[abbr]    new_value=${sfnOffset_value}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=300
    sleep    15s
    selenium_coam.logout
    Run keyword and continue on failure    Wait Until Keyword Succeeds    15min    20s    Check cell on air

Login to webui
    [Arguments]    ${url}=https://${DU_OAM_IP}    ${WEBEM_USERNAME}=${WEBEM_USERNAME}    ${WEBEM_PASSWORD}=${WEBEM_PASSWORD}
    selenium_coam.enable_virtual_display
    selenium_coam.login   url=${url}    username=${WEBEM_USERNAME}
    ...    password=${WEBEM_PASSWORD}

Generate_random
    [Arguments]    ${start}    ${stop}    ${step}
    ${random_value}    Generate_random_number    start=${start}   stop=${stop}   step=${step}
    [Return]    ${random_value}

single ue attach
    [Arguments]    ${ue_index}=${2}
    log to console       Prepare UE and attach
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False

sumsung Start Traffic
    [Arguments]    ${cell_list}    ${ue_index}    ${ul_throughput}    ${dl_throughput}
    ...    ${gnb_index}=${0}    ${ue_mode}=NSA
    single ue attach
    Log To Console    start traffic
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}    ue_index=${ue_index}
    ...    duration=600    ue_mode=${ue_mode}    protocol=udp    iperf_type=via_command
    ...    iperf_port=${IPERF_portlist}[0]   process_num=${1}
    sleep    3s
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}    ue_index=${ue_index}
    ...    duration=600    ue_mode=${ue_mode}    protocol=udp    iperf_type=via_command
    ...    iperf_port=${IPERF_portlist}[0]   process_num=${1}

sumsung Stop Traffic
    [Arguments]    ${ue_index}
    Log To Console    stop traffic
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    ...    iperf_port=${IPERF_portlist}[0]    iperf_type=via_command
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    ...    iperf_port=${IPERF_portlist}[0]    iperf_type=via_command
    Log To Console    UE Detach
    run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}

check Peak
    [Arguments]    ${gnb_index}    ${cell_list}    ${ul_peak}    ${dl_peak}    ${actCarrierAggregation}=${True}
    Log To Console    check throughput
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    gnb_index=${gnb_index}    duration=60s    ignore_time=5s
    set suite variable    ${log_path}
    run keyword and continue on failure    power_ue.Check Tput
    ...    ue_type=${ue_type}    direction=ul    log=${log_path}    cells=${cell_list}    target_throughput=${ul_peak}
    ...    actCarrierAggregation=${actCarrierAggregation}
    run keyword and continue on failure    power_ue.Check Tput
    ...    ue_type=${ue_type}    direction=dl    log=${log_path}    cells=${cell_list}    target_throughput=${dl_peak}
    ...    actCarrierAggregation=${actCarrierAggregation}

Start Traffic and check peak
    [Arguments]    ${cell_list}    ${ue_index}    ${ul_peak}    ${dl_peak}    ${ul_throughput}    ${dl_throughput}
    ...     ${gnb_index}=${0}    ${ue_mode}=NSA
    Log To Console    start traffic and  check peak
    sumsung Start Traffic    cell_list=${cell_list}    ue_index=${ue_index}    ul_throughput=${ul_throughput}
    ...    dl_throughput=${dl_throughput}
    sleep    30s
    check Peak    gnb_index=${gnb_index}     cell_list=${cell_list}   ul_peak=${ul_peak}    dl_peak=${dl_peak}
    sumsung Stop Traffic    ue_index=${ue_index}

Start Traffic and stop btslog and check peak
    [Arguments]    ${cell_list}    ${ue_index}    ${ul_peak}    ${dl_peak}    ${ul_throughput}    ${dl_throughput}
    ...    ${gnb_index}=${0}    ${ue_mode}=NSA
    Log To Console    start traffic and  stop btslog and check peak
    sumsung Start Traffic    cell_list=${cell_list}    ue_index=${ue_index}    ul_throughput=${ul_throughput}
    ...    dl_throughput=${dl_throughput}
    Stop Btslog Collect
    sleep    30s
    check Peak    gnb_index=${gnb_index}     cell_list=${cell_list}   ul_peak=${ul_peak}    dl_peak=${dl_peak}
    sumsung Stop Traffic    ue_index=${ue_index}

Start Btslog Collect
    [Arguments]    ${names}=btslog    ${btslog_path}=/opt/btslog/btslog
    ...            ${btslog_launcher_path}=/opt/btslog/btslog_launcher    ${bts_logs_dir}=/tmp/btslog2
    Log To Console    \n ### Btslog Collect Start ###
    __Make empty BTS logs dir      ${bts_logs_dir}
    btslog.Create Btslog Collector    name=${names}    btslog_path=${btslog_path}
    ...          log_dir=${bts_logs_dir}     btslog_launcher_path=${btslog_launcher_path}
    btslog.Set Suite Alias    ${names}
    core.Setup Collectors    names=${names}
    core.Start Collectors    names=${names}

__Make empty BTS logs dir
    [Arguments]     ${bts_logs_dir}=/tmp/btslog2
    Run  if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi

Stop Btslog Collect
    [Arguments]    ${names}=btslog
    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...    username=${tl.test_pc.default_ssh_connection_details.username}
    ...    password=${tl.test_pc.default_ssh_connection_details.password}    alias=ute
    Log To Console    \n ### Btslog Collect Stop ###
    core.Stop Collectors    names=${names}
    core.Collect Collectors    names=${names}
    core.Teardown Collectors    names=${names}
    __Copy btslog to logs dir and clean BTSlog workspace

__Copy btslog to logs dir and clean BTSlog workspace
    [Arguments]     ${bts_logs_dir}=/tmp/btslog2
    Run  if [ ! -d ${OUTPUT DIR}/${TEST_NAME} ]; then mkdir ${OUTPUT DIR}/${TEST_NAME}; else rm ${OUTPUT DIR}/${TEST_NAME}/*; fi
    Run  mv ${bts_logs_dir}/syslog_files.tgz ${OUTPUT_DIR}/${TEST_NAME}/bts_log.tgz
    Run  tar -xzf ${OUTPUT DIR}/${TEST_NAME}/bts_log.tgz -C ${OUTPUT DIR}/${TEST_NAME}
    Run  rm ${bts_logs_dir}/*

Stop btslog and check UE attach
    [Arguments]    ${ue_type}=${ue_type}
    Log To Console    Stop btslog and check UE attach
    Stop Btslog Collect
    single ue attach
    Log To Console    UE Detach
    run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}

Compare alpha and beta
    [Arguments]    ${frameStartOffset_value}    ${sfnOffset_value}    ${timingAdvanceOffset}=${13792}
    log to console    compare alpha and beta
    ${para_list}     create list    ${btslog_para_1}    ${btslog_para_2}    ${btslog_para_3}    ${btslog_para_4}
    ${alpha_beta_list_calculated}    calculate_alpha_beta    frameStartOffset=${frameStartOffset_value}
    ...   sfnOffset=${sfnOffset_value}
    ...     timingAdvanceOffset=${timingAdvanceOffset}
    ${alpha_beta_dict_inlog}     find_all_value_of_parameter    para_list=${para_list}    file_path=${OUTPUT DIR}/${TEST_NAME}
    FOR  ${i}  IN RANGE   4
        ${alpha_beta_list_inlog}    Get From Dictionary    ${alpha_beta_dict_inlog}  ${para_list}[${i}]
        Log To Console    ${alpha_beta_list_inlog}
        list should contain value    ${alpha_beta_list_inlog}    ${alpha_beta_list_calculated}[${i}]
    END

Case Setup
    CI_interface.Common Case Setup
    robot_common_operations.Common case Setup
    ${default_scf}    Set Default scf name
    Setup Commission SCF    default_scf=${default_scf}_8022.xml
    Set parameter Value    parameter=actCellTimingOffset    dist_name=${dist_actCellTimingOffset}    parameter_value=${true}

Case Teardown
    [Arguments]    ${ue_index}=${2}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${DU_OAM_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}
    ...    connection=${connection}
    Run keyword and ignore error    Stop Btslog Collect
    Run keyword and ignore error    sumsung Stop Traffic    ue_index=${ue_index}
    ${default_scf}    Set Default scf name
    Setup Commission SCF    default_scf=${default_scf}_7841.xml
    CI_interface.Common Case Teardown
    robot_common_operations.Common case Teardown
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Suite Teardown
    ${default_scf}    Set Default scf name
    Setup Commission SCF    default_scf=${default_scf}_7841.xml
    CI_interface.Common Case Teardown
    robot_common_operations.Common Suite Teardown

CB008004-SR-CE_001_Case_Setup
    CI_interface.Common Case Setup
    robot_common_operations.Common case Setup
    ${default_scf}    Set Default scf name
    Setup Commission SCF    default_scf=${default_scf}_8022.xml
    Set parameter Value    parameter=actCellTimingOffset    dist_name=${dist_actCellTimingOffset}    parameter_value=${false}
    log to console    delete TEST_NAME dir
    ssh.connect_to      hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...                 username=${tl.test_pc.default_ssh_connection_details.username}
    ...                 password=${tl.test_pc.default_ssh_connection_details.password}
    ...                 alias=ute
    sleep    10s
    ssh.execute    command=rm -rf ${OUTPUT DIR}/${TEST_NAME}
    ...    connection=ute
    sleep    1s

Check alpha and beta in BTSlog
    [Arguments]    ${DL_alpha}    ${DL_beta}    ${UL_alpha}    ${UL_beta}
    log to console    check alpha and beta in BTSLOG
    ${para_list}     create list    ${btslog_para_1}    ${btslog_para_2}    ${btslog_para_3}    ${btslog_para_4}
    ${alpha_beta_list_inlog}     find_all_value_of_parameter    para_list=${para_list}    file_path=${OUTPUT DIR}/${TEST_NAME}
    ${DL_alpha_value}    Get From Dictionary    ${alpha_beta_list_inlog}  ${para_list}[${0}]
    ${DL_beta_value}    Get From Dictionary    ${alpha_beta_list_inlog}  ${para_list}[${1}]
    ${UL_alpha_value}    Get From Dictionary    ${alpha_beta_list_inlog}  ${para_list}[${2}]
    ${UL_beta_value}    Get From Dictionary    ${alpha_beta_list_inlog}  ${para_list}[${3}]
    run keyword and continue on failure    List Should Contain Value   ${DL_alpha_value}   ${DL_alpha}
    run keyword and continue on failure    List Should Contain Value   ${DL_beta_value}   ${DL_beta}
    run keyword and continue on failure    List Should Contain Value   ${UL_alpha_value}   ${UL_alpha}
    run keyword and continue on failure    List Should Contain Value   ${UL_beta_value}   ${UL_beta}


Change Offset value and attach UE
    [Arguments]    ${frameStartOffset_value}   ${sfnOffset_value}    ${DL_alpha}    ${DL_beta}    ${UL_alpha}    ${UL_beta}
    Start Btslog Collect
    Change Multiple Parameter by selenium    frameStartOffset_value=${frameStartOffset_value}     sfnOffset_value=${sfnOffset_value}
    Run keyword and continue on failure    Wait Until Keyword Succeeds    15min    20s    Check cell on air
    Stop Btslog Collect
    Check alpha and beta in BTSlog    DL_alpha=${DL_alpha}    DL_beta=${DL_beta}    UL_alpha=${UL_alpha}    UL_beta=${UL_beta}
    single ue attach
    Log To Console    UE Detach
    run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}
