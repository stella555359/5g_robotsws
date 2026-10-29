*** Settings ***
Documentation
...    author: Wang Yishuang
...    contact: yishuang.wang@nokia-sbell.com
...    squad group: SG_03
...    feature : 5GC001700BA

Library      OperatingSystem
Library      Collections
Library      String
Library      BuiltIn
Library      Telnet
#Library    ../../libraries/L3Call.py
#Library    ../../../../../resources/python_libs/Attenuation.py
Library     taf.hw.rf_attenuator    WITH NAME    att
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource     taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
#Library    Attenuation.Attenuation    WITH NAME    atten

*** Variables ***
${enb_b1_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}
${enbcell7_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-7
${enbcell8_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-8
${enbcell9_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-9
${enb_para}    administrativeState
${enb_b1_para}    actDynTrigLteNrDualConnectivity
${ue_type}    ${tl.ues[0].capabilities[1]}
${ul_tp_expect}    4.8
${dl_tp_expect}    9

### HBTE PA ###
${vendor}                    ${tl.attenuators[0].vendor}
${max_attenuation_value}     ${127}
${att_ipaddr}                ${tl.attenuator[0].ip_addr}
${att_connection_port}       ${tl.attenuator[0].attenuator_ports[1]}
${att_api_port}              ${tl.attenuator[0].port}
${att_port_1}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_5}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_6}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_7}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_8}                ${tl.attenuator[0].attenuator_ports[8]}

*** Keywords ***
##power UE
Precondition for power UE
    [Arguments]    ${ue_type}    ${ui_version}=default    ${ue_index}=${0}
    power_ue.Prepare UE    ue_type=${ue_type}    ui_version=${ui_version}    ue_index=${ue_index}    reset_sol=pc_reset

Attach and check power UE
    [Arguments]    ${ue_type}    ${ue_index}=${0}
     ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}

Adjust the atten and check HO status
    [Arguments]    ${value1}    ${value2}    ${hwcheck_index}={1}    ${status}=PASS    ${gnb_index}=${0}    ${du_index}=${0}    ${log_type}=Aasyslog
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2   log_name=5Grach.txt
    ${5Gra_l2lo_counter}    ${5Gra_l2lo_timed}    Get 5GRACH success times on gnb side    gnb_index=${gnb_index}
    ...                                                                          hwcheck_index=${hwcheck_index}
    ...                                                                          log_type=${log_type}
    ...                                                                          log_loca=l2lo
    Adjust RU atten for HO    value1=${value1}    value2=${value2}
    sleep    50s
    ${5Grach_ing}    ${5Grach_time_ing}    Get 5GRACH success times on gnb side    gnb_index=${gnb_index}
    ...                                                                            hwcheck_index=${hwcheck_index}
    ...                                                                            log_type=${log_type}
    ...                                                                            log_loca=l2lo
    run keyword if     '${status}'=='PASS'    verify 5G rach success    before=${5Gra_l2lo_counter}     after=${5Grach_ing}
    ...                                         before_time=${5Gra_l2lo_timed}    after_time=${5Grach_time_ing}
    run keyword if     '${status}'=='FAIL'    verify 5G rach not success    before=${5Gra_l2lo_counter}     after=${5Grach_ing}
    ...                                         before_time=${5Gra_l2lo_timed}    after_time=${5Grach_time_ing}
    [Teardown]    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}

Adjust RU atten for HO
    [Arguments]    ${value1}    ${value2}
    Adjust RU Attenuation ${value1} ${value2}

Adjust RU Attenuation ${value1} ${value2}
    Adjust RU1 Attenuation to ${value1}
    Adjust RU2 Attenuation to ${value2}

Adjust the HBTE attenuation value
    [Arguments]      ${value1}     ${value2}    ${att_port1}=${att_port_1}
    ...    ${att_port2}=${att_port_2}    ${att_port3}=${att_port_3}    ${att_port4}=${att_port_4}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    att.set_attenuation     port=${att_port1}    value=${value1}
    att.set_attenuation     port=${att_port2}    value=${value1}
    att.set_attenuation     port=${att_port3}    value=${value2}
    att.set_attenuation     port=${att_port4}    value=${value2}
    ${value_port1}    att.read_attenuation    port=${att_port1}
    should be equal    ${value_port1}    ${value1}
    ${value_port2}    att.read_attenuation    port=${att_port2}
    should be equal    ${value_port2}    ${value1}
    ${value_port3}    att.read_attenuation    port=${att_port3}
    should be equal    ${value_port3}    ${value2}
    ${value_port4}    att.read_attenuation    port=${att_port4}
    should be equal    ${value_port4}    ${value2}

Start DL UL traffic and monitor throughput
    [Arguments]    ${cell_id}=${cell1_id}    ${ue_index}=${0}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}    duration=1200s    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}    duration=1200s    ue_index=${ue_index}
    Evaluate throughput on source cell    cell_id=${cell_id}    ue_index=${ue_index}

Evaluate throughput on source cell
    [Arguments]    ${cell_id}=${cell1_id}     ${ue_index}=${0}
    wait until keyword succeeds    2min    30s    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=${dl_tp_expect}
    ...    ue_index=${ue_index}    sample=${8}    start_offset=${3}    sleep_time=${30}    cellid=${cell_id}
    wait until keyword succeeds    2min    30s    power_ue.Check throughput    ue_type=${ue_type}    direction=ul    throughput=${ul_tp_expect}
    ...    ue_index=${ue_index}    sample=${8}    start_offset=${3}    sleep_time=${30}    cellid=${cell_id}

Evaluate throughput on target cell
    [Arguments]    ${cell_id}=${cell2_id}     ${ue_index}=${0}
    wait until keyword succeeds    2min    30s    power_ue.Check throughput    ue_type=${ue_type}    direction=ul    throughput=${ul_tp_expect}
    ...    ue_index=${ue_index}    sample=${8}    start_offset=${3}    sleep_time=${30}    cellid=${cell_id}
    wait until keyword succeeds    2min    30s    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=${ul_tp_expect}
    ...    ue_index=${ue_index}    sample=${8}    start_offset=${3}    sleep_time=${30}    cellid=${cell_id}

Recover the env atten to normal value
    [Arguments]    ${value1}    ${value2}
    Adjust RU1 Attenuation to ${value1}
    Adjust RU2 Attenuation to ${value2}

COAM get cell id
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${info_cell1}    selenium_coam.get_cell_info    cell_idx=${1}
    ${info_cell2}    selenium_coam.get_cell_info    cell_idx=${2}
    set suite variable    ${cell1_id}    ${info_cell1['NR cell ID']}
    set suite variable    ${cell2_id}    ${info_cell2['NR cell ID']}
    [Teardown]    Run keyword and ignore error   selenium_coam.logout

Lock Unlock eNB cells
    [Arguments]    ${status}=locked
    Connect and Modify the parameter on enblte   dist_name=${enbcell7_dist}    parameter=${enb_para}    value=${status}
    sleep    5s
    Connect and Modify the parameter on enblte   dist_name=${enbcell8_dist}    parameter=${enb_para}    value=${status}
    sleep    5s
    Connect and Modify the parameter on enblte   dist_name=${enbcell9_dist}    parameter=${enb_para}    value=${status}

Check PM counter Result
    [Arguments]    ${counter_id}    ${full_path}    ${date}=all
    Connect to gnb coam via ssl
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${full_path}    date=${date}
    [Return]    ${counter_value}
    [Teardown]    COAM Teardown gnb connections

Sum the list value
    [Arguments]    ${counter_result}
    ${length}    Get Length    ${counter_result}
    ${sum_result}    set variable    ${0}
    FOR    ${i}    IN RANGE    ${length}
        ${sum_result}    Evaluate    ${sum_result} + ${counter_result[${i}]}
    END
    [Return]      ${sum_result}

Check PM counter Result for M55313C04008
    [Arguments]    ${instance}=${gnb_instance}
    ${M55313C04008}    wait until keyword succeeds    10min    3min
    ...    Check PM counter Result    counter_id=M55313C04008    full_path=BTS/BTS/NRBTS-${instance}/NX2UB
    ${M55313C04008_sum}    Sum the list value    ${M55313C04008}
    should be equal     ${M55313C04008_sum}    ${0}

Tests Recovery
    [Arguments]    ${x2logname}    ${value1}=${5}    ${value2}=${5}
    run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}
    run keyword and ignore error  Stop and Save classical enb x2 Logs    x2logname=${x2logname}
    csn.disconnect    connection=enb
    Connect and Modify the parameter on enblte   dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    Close the iperf process on APPserver    dl_port=${dl_port}
    Close the iperf process on Qualcomm    ue_index=${0}
    Recover the env atten to normal value    value1=${value1}    value2=${value2}
    run keyword and ignore error    CI_interface.Common Case Teardown

Tests Recovery 20A
    [Arguments]    ${x2logname}
    run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
    run keyword and ignore error  Stop and Save classical enb x2 Logs    x2logname=${x2logname}
    csn.disconnect    connection=enb
    Connect and Modify the parameter on enblte   dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    Lock Unlock eNB cells    status=unlocked
    Adjust the Attenuation Value    ports=${5GRU2_ANT1}    value=${20}    attenuation_port_numbers_oneport=${5GRU2_ANT1}
    ...    atten_ip=${atten2_ip}
    Adjust the Attenuation Value    ports=${5GRU3_ANT1}    value=${25}    attenuation_port_numbers_oneport=${5GRU3_ANT1}
    ...    atten_ip=${atten2_ip}
