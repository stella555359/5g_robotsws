*** Settings ***

Documentation    author：Pengliang Wu
...              contact: pengliang.wu@nokia-sbell.com
...              squad group: mmw_SG_04

Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Library             ../../CB007306_OTA/Resources/CB007306_common.py
#Library     taf.sw.nrdim    WITH NAME    NRDIM
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME
...    throughput_computation


*** Variables ***
${CURDIR_path}                  ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}
${gNB1_ip}                      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${gNB1_username}                ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB1_password}                ${tl.gnbs[0].cu.oam_http_connection_details.password}
${UTE_IP}                       ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}                 ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}                 ${tl.test_pc.default_ssh_connection_details.password}
${case18_tcpdump_name}          tcpdump_18
${luashark_path}                /opt/ute/luashark/luashark_script/generated_luashark/
${ul_iperf_port_list}           ${tl.ues[1].iperf_details.ports[0:3]}
${dl_iperf_port_list}           ${tl.ues[1].iperf_details.ports[3:6]}
@{empty_list}



*** Keywords ***
Case Suit Setup
    [Arguments]  ${gnb_index}=${0}    ${combine_mode}=${EMPTY}
    Select and setup Commission SCF    gnb_index=${gnb_index}    combine_mode=${combine_mode}
    Check GNB on air    bts_host=${gNB1_ip}    username=${gNB1_username}     password=${gNB1_password}

Case18 Teardown
    Run Keyword And Ignore Error    detach multi power ue
    Modify Common parameter via Coam    input_list=${case18_frame_recovery}
    Check GNB on air    bts_host=${gNB1_ip}    username=${gNB1_username}     password=${gNB1_password}

Case7 Setup
    Case Suit Setup
    robot_common_operations.Common case Setup

Common Case Teardown
    Run Keyword If    "${TEST_STATUS}"=="FAIL"    Save Snapshot    bts_host=${gNB1_ip}
    robot_common_operations.Common Case Teardown
    CI_interface.Common Case Teardown

Save Snapshot
    [Arguments]    ${bts_host}=${gNB1_ip}    ${connection}=cOAM    ${timeout}=10min
    log to console    Save Snapshot...
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    run keyword and ignore error     coam.teardown    connection=${connection}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB1_username}    password=${gNB1_password}
    ...    connection=${connection}
    ${snapshot_path}    coam.get_snapshot    target_file_name=${output_dir}/${timestamp}_snapshot.zip    connection=${connection}
    ...    timeout=${timeout}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${snapshot_path}

Check GNB on air
    [Timeout]    20 min
    [Arguments]  ${bts_host}=${gNB1_ip}    ${username}=${gNB1_username}    ${password}=${gNB1_password}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    Wait Until Keyword Succeeds    1200s    10s    Verify all cells should be onair
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

Select and setup Commission SCF
    [Arguments]     ${bts_host}=${gNB1_ip}    ${username}=${gNB1_username}    ${password}=${gNB1_password}
    ...    ${combine_mode}=${EMPTY}    ${gnb_index}=0
     ${default_scf}    Get sw build version for scf name    combine_mode=${combine_mode}    gnb_index=${gnb_index}
     Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
     log to console    Start commission with SCF
     COAM Commission with scf file      scf_file_path=${default_scf}    timeout=1000
     Wait Until Keyword Succeeds    1200s    10s    Verify all cells should be onair
     [Teardown]    Run keyword and ignore error     COAM Teardown gnb connections

Get sw build version for scf name
    [Arguments]     ${combine_mode}=${EMPTY}    ${gnb_index}=0
    Connect to Common Unit Master    gnb_index=${gnb_index}
    ssh.force_reconnect    connection=ASIK Master
    ${cmd_get_sw_file_name}    Set variable    ls /ffs/run |grep TargetBD.*.xml |grep -v .xml.
    ${sw_file_name}    ssh.execute    command=${cmd_get_sw_file_name}    connection=ASIK Master
    @{sw_version_list}    Get regexp matches    ${sw_file_name}    TargetBD_(.*?)_    1
    Run keyword and ignore error    Remove values From List     ${sw_version_list}    BSR
    ${sw_version_list_1}    Strip string    ${sw_version_list[0]}
    ${if_SBTS}    run keyword and return status    should contain    ${sw_file_name}     9999
    ${sw_version}    set variable if    ${if_SBTS}    SBTS00    ${sw_version_list_1}
    ${default_scf_name}    Catenate    gNB${gnb_index}_SCF_${combine_mode}${sw_version}.xml
    log to console    Selected SCF name: ${default_scf_name}
    ${default_scf}    set variable    ${CURDIR_path}/${default_scf_name}
    set suite variable    ${default_scf}
    [Return]  ${default_scf}


Modify Common parameter via Coam
    [Arguments]  ${input_list}    ${bts_ip}=${gNB1_ip}    ${username}=${gNB1_username}    ${password}=${gNB1_password}
    log to console    Modify parameter for BTS ip:${bts_ip}
    Connect to gnb coam via ssl    bts_host=${bts_ip}    username=${username}    password=${password}
    coam.Perform Parameter Recommissioning    dist_name=${input_list}[dist_name]   parameter=${input_list}[parameter]
    ...    value=${input_list}[value]
    ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}
    ...    connection=GNB_OAM
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

L3 Call
    [Arguments]    ${nrcell_index_list}    ${ul_throughput}    ${dl_throughput}    ${expected_ul}    ${expected_dl}
    ...    ${time}    ${if_check_tcpdump}=${False}    ${sleep_time}=10s
    ${cellid_list}    create list
    FOR  ${each_cellid}  IN  @{nrcell_index_list}
        ${cellid}    Get nrCellIdentity form BTS by NRCELL id    nrcell_id=${each_cellid}
        append to list    ${cellid_list}    ${cellid}
    END
    Run keyword if    '${if_check_tcpdump}'=='True'    Start wireshark capture from gNB or Enb    filename=${case18_tcpdump_name}
    attach power ue
    Run keyword if    '${if_check_tcpdump}'=='True'    Stop wireshark capture from gNB or Enb    filename=${case18_tcpdump_name}
    Run keyword if    '${if_check_tcpdump}'=='True'    CB009102_common_keyword_2.Convert pcap to text
    ...    source=${OUTPUT_DIR}/${TEST NAME}/${case18_tcpdump_name}.pcap
    ...    target=${OUTPUT_DIR}/${TEST NAME}/${case18_tcpdump_name}.txt
    ...    filter=x2ap
    start power ue traffic ul and dl Samsung      ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}
    sleep    ${sleep_time}
    Check power ue Tput    ul_throughput=${expected_ul}    dl_throughput=${expected_dl}    time=${time}    cells=${cellid_list}
    stop multi power ue traffic ul and dl samsung
    detach multi power ue
    Run keyword if    '${if_check_tcpdump}'=='True'     Check wireshark log Parameter    txt_filename=${case18_tcpdump_name}
    ...     parameters=${case18_parameters_check}


Check wireshark log Parameter
    [Arguments]     ${txt_filename}     ${parameters}      ${logpath}=${OUTPUT_DIR}/${TEST NAME}
    ${val_result}    CB007306_common.Check_Wireshark_Parameter_From_Txt    txt_file_path=${logpath}/${txt_filename}.txt
    ...    parameters=${parameters}
    ${val_list}     set variable    ${val_result}[resultList]
    FOR    ${val1}    IN    @{val_list}
        Run Keyword And Continue On Failure    should be equal    ${val1}    ${True}
    END

Get nrCellIdentity form BTS by NRCELL id
    [Arguments]     ${nrcell_id}=NRCELL-1
    Connect to gnb coam via ssl    connection=GNB_OAM    bts_host=${gNB1_ip}    username=${gNB1_username}    password=${gNB1_password}
    ${subcells_info}    coam.get_subcells_info    connection=GNB_OAM
    ${cell_group}    Get All Cell Group Id    connection=GNB_OAM
    FOR    ${group_id}  IN    @{cell_group}
        ${nrcell_dict}    set variable    ${subcells_info['NRCELLGRP-${group_id}']}
        ${nrcell_id_list}    get dictionary keys    ${nrcell_dict}
        ${cell_id}    set variable    ${nrcell_dict['${nrcell_id_list}[0]']['NRCELL_L']['parameters']['nrCellIdentity']}
        EXIT FOR LOOP IF    '${nrcell_id}'=='${nrcell_id_list}[0]'
    END
    [Return]     ${cell_id}
    [Teardown]    Run keyword and ignore error     COAM Teardown gnb connections

attach power ue
    [Arguments]    ${ue_index}=${1}
    log to console       Prepare UE
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=samsung
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=samsung    log_type=Aasyslog
#    power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False    gnb_index=${gnb_index}


start power ue traffic ul and dl Samsung
    [Arguments]     ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${ul_duration}=1000    ${dl_duration}=1000
    ...    ${protocol}=udp    ${ue_index}=${1}
    log to console      Start traffic    console=yes
    run keyword and continue on failure      power_ue.Start traffic    ue_index=${ue_index}    direction=ul
    ...    throughput=${ul_throughput}    duration=${ul_duration}    ue_type=samsung    iperf_type=via_command    protocol=${protocol}
    ...    iperf_port=${ul_iperf_port_list}[${0}]
    sleep    1s
    run keyword and continue on failure     power_ue.Start traffic    ue_index=${ue_index}    direction=dl
    ...    throughput=${dl_throughput}    duration=${dl_duration}    ue_type=samsung    protocol=${protocol}
    ...    iperf_port=${dl_iperf_port_list}[${0}]

Check power ue Tput
    [Arguments]     ${time}=5m    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${target_avg_percent}=0.98    ${min_percent}=0.85
    ...    ${cells}=${EMPTY}    ${gnb_index}=${0}
    ${log_path}    power_ue.Collect Tput     ue_type=samsung    duration=${time}    gnb_index=${gnb_index}    log_dir=${OUTPUT_DIR}/${TEST NAME}/
#    run keyword and continue on failure    power_ue.Check Tput    ue_type=samsung    direction=ul    target_throughput=${ul_throughput}
#    ...     target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    cells=${cells}    log=${log_path}
#    ...     actCarrierAggregation=${True}
    log to console    ul_target:${ul_throughput}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=samsung    direction=dl    target_throughput=${dl_throughput}
    ...     target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    cells=${cells}    log=${log_path}
    ...     actCarrierAggregation=${True}

stop multi power ue traffic ul and dl samsung
    [Arguments]    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}    ${ue_index}=${1}
    log to console     Stop traffic    console=yes
    run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=samsung    iperf_type=${protocol}
    ...    protocol=${protocol}    iperf_port=${ul_iperf_port_list}[${0}]
    run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=samsung    protocol=${protocol}
    ...    iperf_port=${dl_iperf_port_list}[${0}]

detach multi power ue
    [Arguments]    ${ue_index}=${1}
    log to console      UE Detach    console=yes
    Set Suite Variable    ${brand}    samsung
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=samsung

Connect to GNB
    [Arguments]    ${du_index}=${0}    ${alias}=ASIK Master    ${gnb_index}=${0}
    csn.Connect to    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...               ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=${alias}

Start wireshark capture from gNB or Enb
    [Documentation]    Description: Start X2 log capture on gNB or Enb
    [Arguments]     ${filename}=tcpdump    ${interface}=any    ${index}=${0}    ${alias}=ASIK Master
    Connect to GNB   gnb_index=${index}    alias=${alias}
    ${log_name}    Set variable    ${filename}.pcap
    ${log_full_path_gnb}    join path    /tmp    ${log_name}
    csn.send command    command=ps -ef |grep tcpdump |grep -v grep |grep ${interface} |awk '{print $2}' |xargs kill -2    connection=${alias}
    sleep    2s
    csn.send command    command=nohup tcpdump sctp -i ${interface} -w ${log_full_path_gnb}     connection=${alias}
    sleep    2s
    Trace capturing process should be triggered    log_prefix=${log_name}    connection_alias=${alias}
    [Return]    ${alias}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${alias}


Stop wireshark capture from gNB or Enb
    [Documentation]    Description: Stop X2 log capture on gNB or Enb, and download x2 log to testpc
    [Arguments]     ${filename}=tcpdump    ${logpath}=${OUTPUT_DIR}/${TEST NAME}    ${index}=${0}    ${alias}=ASIK Master
    Connect to GNB       gnb_index=${index}    alias=${alias}
    Stop trace capturing    log_prefix=${filename}    connection_alias=${alias}
    ${log_full_path_ute}    set variable     ${logpath}/${filename}.pcap
    csn.download_file   remote_path=/tmp/${filename}.pcap   local_path=${log_full_path_ute}   connection=${alias}
    csn.execute    command=rm /tmp/${filename}.pcap    connection=${alias}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${alias}

Convert pcap to text
    [Arguments]    ${source}    ${target}    ${filter}   ${connection}=ute
    log to console      'convert pcap->txt: '${source}
    csn.connect_to   hostname=${UTE_IP}    username=${UTE_USERNAME}    password=${UTE_PASSWORD}    alias=${connection}
    sleep    1s
    csn.send_command
    ...  command=nice tshark -X lua_script:${luashark_path} -V -r ${source} -T text > ${target} -Y '${filter}'   connection=${connection}
    csn.await execution end  connection=${connection}  timeout=30min
    sleep    5s
    [Teardown]      run keyword and ignore error    csn.Disconnect    connection=${connection}

# NRDIM keyword
Get Theoretical TP From NRDIM
    [Arguments]    ${dl_cell_list}=${empty_list}
    ${default_scf}    Get sw build version for scf name    gnb_index=${0}
    ${total_ul_tp}    ${total_dl_tp}    Calculate Theoretical TP    scf_path=${default_scf}    dl_cell_list=${dl_cell_list}
    ...    ul_cell_list=${dl_cell_list[0:0]}
    ${total_dl_tp}    Evaluate    ${total_dl_tp}-${36}    #rat1
    [Return]    ${total_ul_tp}    ${total_dl_tp}

Calculate Theoretical TP
    [Arguments]  ${scf_path}    ${dl_cell_list}=${empty_list}    ${ul_cell_list}=${empty_list}
    ${total_ul_tp}    set variable    ${0}
    ${total_dl_tp}    set variable    ${0}
    ${dl_cell_num}    get length    ${dl_cell_list}
    ${ul_cell_num}    get length    ${ul_cell_list}
    FOR  ${i}  IN RANGE   ${dl_cell_num}
        ${cell_id}    Evaluate    ${dl_cell_list}[${i}]
        ${calculator_tp_dl}    ${calculator_tp_ul}    throughput_computation.get_theoretical_throughput    scf_path=${scf_path}    cell_id=${cell_id}
        ${total_dl_tp}    Evaluate    ${calculator_tp_dl}+${total_dl_tp}
    END
    FOR  ${i}  IN RANGE   ${ul_cell_num}
        ${cell_id}    Evaluate    ${ul_cell_list}[${i}]
        ${calculator_tp_dl}    ${calculator_tp_ul}    throughput_computation.get_theoretical_throughput    scf_path=${scf_path}    cell_id=${cell_id}
        ${total_ul_tp}    Evaluate    ${calculator_tp_ul}+${total_ul_tp}
    END
    [Return]  ${total_ul_tp}    ${total_dl_tp}
