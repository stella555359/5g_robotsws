*** Settings ***
Documentation
...    author: Cindy JIN
...    contact: cindy.1.jin@nokia-sbell.com
...    squad group: SG_03
...    feature : 5GC000710_A

Library      OperatingSystem
Library      Collections
Library      String
Library      BuiltIn
Library      Telnet
Library    ../../libraries/L3Call.py
#Library    ../../../../../resources/python_libs/Attenuation.py
Library     taf.hw.rf_attenuator    WITH NAME    att
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource     taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
#Library     Attenuation.Attenuation    WITH NAME    atten
Variables      710_Case_Commission/__init__.py
Variables      5GC000710_test_parameters.py

*** Variables ***
${ENB_ADDRESS}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
${LOCAL_MASTER_IP}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${PEER_MASTER_IP}     ${tl.gnbs[1].cu.oam_http_connection_details.addr}
#${enb_b1_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}
${enb_para}    administrativeState
${enb_b1_para}    actDynTrigLteNrDualConnectivity
${ul_tp_expect}    8
${dl_tp_expect}    45
${ul_time}    600
${ul_length}    1024B
${ul_throughput}     10M
${dl_time}    600
${dl_length}    1024B
${dl_throughput}    50M
*** Keywords ***
##cell status
Prepare the gNB cells onair status
    [Arguments]    ${gnb_index}=${0}    ${tl_scf_file_name}=${tl_scf_file_name}
    ${cell_status}    run keyword and return status    Prepare the gNB cells onair    gnb_index=${gnb_index}
    ...                 tl_scf_file_name=${tl_scf_file_name}
    set suite variable    ${cell_status}

Prepare the gNB cells onair
    [Arguments]    ${gnb_index}=${0}    ${tl_scf_file_name}=${tl_scf_file_name}
    login and load scf    bts_host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}    connection=gnb${gnb_index}
    ...                   tl_scf_file_name=${tl_scf_file_name}
    sleep    2min
    wait until keyword succeeds    10 min    20 sec    Check the cells status on air
    ...                   bts_host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}    connection=gnb${gnb_index}


Precondition for enb
    [Arguments]    ${enb_scf_file_name}    ${connection}=enb     ${enb_index}=${0}
    Connect to eNB via ssl    connection=${connection}     enb_index=${enb_index}
    COAM Commission with scf file    scf_file_path=${tl_scf_dir_path}${enb_scf_file_name}    timeout=800    is_pdl_checking_needed=${False}
    ...    connection=${connection}
    [Teardown]    coam.teardown    connection=${connection}

Check the cells status on air
    [Arguments]     ${bts_host}    ${connection}
    Connect to gnb coam via ssl    connection=${connection}    bts_host=${bts_host}
    Verify all cells should be onair    connection=${connection}
    [Teardown]    coam.teardown    connection=${connection}

##power UE
adjust PA to trigger HO
    [Arguments]    ${value1}    ${value2}=${0}    ${Att_port_1}=${att_port_1}     ${Att_port_2}=${att_port_2}
    ...       ${Att_port_9}=${att_port_9}    ${Att_port_10}=${att_port_10}
    Adjust the PA attenuation value    value_1=${value1}     value_2=${value1}
    ...     value_3=${value2}     value_4=${value2}    att_port_1=${Att_port_1}      att_port_2=${Att_port_2}
    ...     att_port_3=${Att_port_9}     att_port_4=${Att_port_10}    atten_ip=${atten_ip}

Adjust the PA attenuation value
    [Arguments]     ${value_1}     ${value_2}     ${value_3}     ${value_4}
    ...             ${att_port_1}=${att_port_1}    ${att_port_2}=${att_port_2}     ${att_port_3}=${att_port_3}
    ...             ${att_port_4}=${att_port_4}     ${atten_ip}=${atten_ip}
    [Documentation]    Auther:cris.cai@nokia-sbell.com
    ...                modify HBTE PA value default value[0-63db] if not set the max_attenuation value below
    ...                for value plz set in your case level
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    attenuator.set_attenuation     port=${att_port_1}    value=${value_1}
    attenuator.set_attenuation     port=${att_port_2}    value=${value_2}
    attenuator.set_attenuation     port=${att_port_3}    value=${value_3}
    attenuator.set_attenuation     port=${att_port_4}    value=${value_4}
    ${value_port_1}    attenuator.read_attenuation    port=${att_port_1}
    should be equal    ${value_port_1}    ${value_1}
    ${value_port_2}    attenuator.read_attenuation    port=${att_port_2}
    should be equal    ${value_port_2}    ${value_2}
    ${value_port_3}    attenuator.read_attenuation    port=${att_port_3}
    should be equal    ${value_port_3}    ${value_3}
    ${value_port_4}    attenuator.read_attenuation    port=${att_port_4}
    should be equal    ${value_port_4}    ${value_4}
    sleep    1s


Start DL UL traffic and monitor throughput
    [Arguments]    ${cell_id}=${nrcellid}    ${ue_index}=${0}    ${gnb_index}=${0}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}    duration=1200s    ue_index=${ue_index}
    ...     iperf_port=${DL_PORT}    process_num=${1}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}    duration=1200s    ue_index=${ue_index}
    ...     iperf_port=${UL_PORT}
    Evaluate throughput on source cell    cell_id=${cell_id}    ue_index=${ue_index}

Evaluate throughput on source cell
    [Arguments]    ${cell_id}=${nrcellid}     ${ue_index}=${0}    ${gnb_index}=${0}
    wait until keyword succeeds    2min    10s    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=${dl_tp_expect}
    ...    ue_index=${ue_index}    gnb_index=${gnb_index}    sample=${6}    start_offset=${3}    sleep_time=${20}    cellid=${cell_id}
    wait until keyword succeeds    2min    10s    power_ue.Check throughput    ue_type=${ue_type}    direction=ul    throughput=${ul_tp_expect}
    ...    ue_index=${ue_index}    gnb_index=${gnb_index}    sample=${6}    start_offset=${3}    sleep_time=${20}    cellid=${cell_id}

Evaluate throughput on target cell
    [Arguments]    ${cell_id}=${nrcellid}     ${ue_index}=${0}    ${gnb_index}=${1}
    wait until keyword succeeds    2min    30s    power_ue.Check throughput    ue_type=${ue_type}    direction=ul    throughput=${ul_tp_expect}
    ...    ue_index=${ue_index}    gnb_index=${gnb_index}    sample=${6}    start_offset=${3}    sleep_time=${30}    cellid=${cell_id}
    wait until keyword succeeds    2min    30s    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=${dl_tp_expect}
    ...    ue_index=${ue_index}    gnb_index=${gnb_index}     sample=${6}    start_offset=${3}    sleep_time=${30}    cellid=${cell_id}

Lock Unlock eNB cells
    [Arguments]    ${status}=locked
    Connect and Modify the parameter on enblte   dist_name=${enbcell7_dist}    parameter=${enb_para}    value=${status}
    sleep    5s
    Connect and Modify the parameter on enblte   dist_name=${enbcell8_dist}    parameter=${enb_para}    value=${status}
    sleep    5s
    Connect and Modify the parameter on enblte   dist_name=${enbcell9_dist}    parameter=${enb_para}    value=${status}

Tests Recovery
    [Arguments]    ${x2logname}    ${value1}=${0}    ${value2}=${127}
    run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}
    run keyword and ignore error  Stop and Save classical enb x2 Logs    x2logname=${x2logname}
    csn.disconnect    connection=enb
    run keyword and ignore error     power_ue.Stop traffic    ue_type=${ue_type}   direction=ul    ue_index=${0}
    run keyword and ignore error     power_ue.Stop traffic    ue_type=${ue_type}   direction=dl    ue_index=${0}
    adjust PA to trigger HO    value1=${value1}    value2=${value2}
    run keyword and ignore error    CI_interface.Common Case Teardown


Start Capture Classical enb x2 Logs
    [Arguments]    ${x2logname}
    RUN KEYWORD AND IGNORE ERROR    enb connections
    Start To Capture Wireshark Logs    filename=${x2logname}    connection=enb    interface=any
    sleep    3s

Start To Capture Wireshark Logs
    [Arguments]     ${filename}    ${connection}    ${interface}
    csn.send command    command=tcpdump sctp -i ${interface} -w ${gnb_path}${filename}   connection=${connection}
    sleep    3s
Stop and Save classical enb x2 Logs
    [Arguments]    ${x2logname}
    enb connections
    Stop and download Logs    logname=${x2logname}    connection=enb
enb connections
    csn.Connect To    hostname=${ENB_ADDRESS}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=enb

Stop and download Logs
    [Arguments]    ${logname}    ${connection}
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file   remote_path=${gnb_path}${logname}   local_path=${epc_log_path}${logname}
    ...    connection=${connection}
    sleep    3


##check counter
Check PM the counter Result  ### change the name
    [Arguments]    ${counter_id}    ${dic_path}    ${gnb_index}=${0}    ${counter_increase}=True
    ${counter_value}    Check PM counter from webui    counter_id=${counter_id}    full_path=${dic_path}    gnb_index=${gnb_index}
    ${counter_sum}    Sum the list value    ${counter_value}
    Run keyword if    "${counter_increase}" == "True"    should be true    ${counter_sum} >= ${1}
    ...    ELSE    should be true     ${counter_sum} == ${0}


Sum the list value
    [Arguments]    ${counter_result}
    ${length}    Get Length    ${counter_result}
    ${sum_result}    set variable    ${0}
    FOR    ${i}    IN RANGE    ${length}
        ${sum_result}    Evaluate    ${sum_result} + ${counter_result[${i}]}
    END
    [Return]      ${sum_result}

