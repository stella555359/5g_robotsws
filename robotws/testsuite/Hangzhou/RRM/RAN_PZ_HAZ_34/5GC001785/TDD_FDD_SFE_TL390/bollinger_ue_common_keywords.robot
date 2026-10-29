*** Settings ***
Documentation
...    author: ming.shi
...    contact: ming.shi@nokia-sbell.com

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB010701/Resources/CB010701_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/l1l2bip_collect.robot
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/TDD_FDD_SFE_TL390/CB010701_variables.py
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/get_counters_from_pm_file.py

*** Variables ***
${logname_B_B3_003_attach_1}    B_B3_003_attach_1110_0ms_3TX_1.pcap
${logname_B_B3_003_attach_2}    B_B3_003_attach_1110_0ms_3TX_2.pcap
${logname_B_B3_003_attach_3}    B_B3_003_attach_1110_0ms_3TX_3.pcap
${logname_B_B3_003_RRCReconfiguration}    B_B3_003_RRCReconfiguration.pcap
${expected_tput_ul_T_1116_3}    204
${expected_tput_ul_F_1110_0_10M}    52
${Send_Tput_UL_T_F}    400M
${ue_type}           ${tl.ues[-1].capabilities[0]}
${gnb_instance0}    ${tl.gnbs[0].instance_id}
${bts_host}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
${DL_PORT}        ${tl.ues[-1].iperf_details.port}
${UL_PORT}        ${tl.ues[-1].iperf_details.port}
@{ports_1}    ${5}    ${6}    ${7}    ${8}
@{values_1}    ${0}    ${0}    ${0}    ${0}
@{ports_2}    ${1}    ${2}    ${3}    ${4}
@{values_2}    ${0}    ${0}    ${0}    ${0}
@{values_3}    ${127}    ${127}    ${127}    ${127}
${dl_throughput}    800M
${ul_throughput}    400M
${tput_dl_pcell}    50
${tput_dl_scell}    50
${tput_ul_pcell}    50
${tput_ul_scell}    150
${ue_ip9}     ${tl.ues[9].sec_key}
${ue_ip10}    ${tl.ues[10].sec_key}
${ports_39011}    ${tl.ues[9].iperf_details.iperf_interval}
${length_39011}    ${tl.ues[9].iperf_details.iperf_version}


*** Keywords ***
MTK restart network interface
    ${rc}    ${output}=    run and return rc and output    java -jar selenium-server-4.31.0.jar hub > selenium_server.txt &
    ${tl_id}=    Evaluate    str(${tl.gnbs[0].instance_id})[0:3]
    ${rc}    ${output}=    run and return rc and output
    ...    source CIENV/7_5_UTE5G402T${tl_id}/bin/activate;python3 remote_operate_power_reeset_on_web.py

MTK attach UE
    [Arguments]    ${logname}    ${ue_index}=${0}    ${ue_type}=mtk    ${gnb_index}=${0}    ${ue_alias}=UE_${ue_index}
    Start capture gNB log on master    filename=${logname}    gNB_index=${gnb_index}
    MTK UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    gnb_index=${gnb_index}    ue_alias=${ue_alias}
    [Teardown]    Stop and download the Logs    filename=${logname}   gNB_index=${gnb_index}

MTK start traffic with DL and UL
    [Arguments]    ${scellid}=301   ${pcellid}=1
    ...    ${tput_dl_pcell}=NULL    ${tput_dl_scell}=NULL    ${tput_ul_pcell}=NULL    ${tput_ul_scell}=NULL    ${ue_type}=mtk
    ...    ${ul_throughput}=${ul_throughput}    ${ue_index}=${0}
    ...    ${gnb_index}=${0}    ${seg_size}=1180    ${dl_length}=1024B    ${duration}=2000    ${checktime}=30
    ...    ${ports}=${ports_${tl.gnbs[0].instance_id}}    ${length}=${length_${tl.gnbs[0].instance_id}}
    ...    ${UE_IP}=${UE_IP}    #${apn}=weistatic
#    ${UE_IP}    Get UE IP from wirehsark    logname=${logname}    apn=${apn}
    run keyword If    '${dl_throughput}'!='NULL'
    ...    Power UE Start DL traffic    ue_type=${ue_type}    dl_throughput=${dl_throughput}    dl_port=${dl_port}
    ...    duration=${duration}    seg_size=${seg_size}    ue_index=${ue_index}    dl_length=${dl_length}
    Prepare bollinger for UL traffic    ue_ip_addr=${UE_IP}    ue_index=${ue_index}
    ...    ports=${ports}    length=${length}
    MTK restart network interface
    sleep    40s
    run keyword If    '${ul_throughput}'!='NULL'
     ...    bollinger UE Start UL traffic    ue_index=${ue_index}    ue_ip=${UE_IP}    ul_time=${duration}
    Prepare to caculate PM counter    period=start
    Wait until keyword succeeds    3X   10s    Check 2CC DLUL tput    scellid=${scellid}    pcellid=${pcellid}
    ...    tput_dl_pcell=${tput_dl_pcell}    tput_dl_scell=${tput_dl_scell}    tput_ul_pcell=${tput_ul_pcell}
    ...    tput_ul_scell=${tput_ul_scell}    duration=${checktime}    gnb_index=${gnb_index}

MTK UE reboot for WA
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} reboot   connection=cygwin
    sleep   70s
    [Teardown]    csn.disconnect      connection=cygwin

Check 10701 KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    ${M55181C00013}=    Set Variable    ${dict_kpis_name_value}[${CB010701_counters[0]}]
    ${M55165C00039}=    Set Variable    ${dict_kpis_name_value}[${CB010701_counters[1]}]
    ${M55118C00054}=    Set Variable    ${dict_kpis_name_value}[${CB010701_counters[2]}]
    ${M55181C00003}=    Set Variable    ${dict_kpis_name_value}[${CB010701_counters[3]}]
    ${M55370C00038}=    Set Variable    ${dict_kpis_name_value}[${CB010701_counters[4]}]
    ${M55370C00039}=    Set Variable    ${dict_kpis_name_value}[${CB010701_counters[5]}]
    ${M55370C00040}=    Set Variable    ${dict_kpis_name_value}[${CB010701_counters[6]}]
    Should Be True    ${M55181C00013} == ${300}
    Should Be True    ${M55165C00039} == ${300}
    Should Be True    ${M55118C00054} == ${300}
    Should Be True    ${M55181C00003} == ${300}
    Should Be True    ${M55370C00038} > ${0}
    Should Be True    ${M55370C00039} > ${0}
    Should Be True    ${M55370C00040} > ${0}

get dict kpi from pm file
    [Arguments]    ${index}=${0}    ${bts_ip}=${tl.gnbs[${index}].cu.oam_ssh_connection_details.addr}
    ...    ${bts_username}=${tl.gnbs[${index}].cu.oam_ssh_connection_details.username}
    ...    ${bts_password}=${tl.gnbs[${index}].cu.oam_ssh_connection_details.password}
    ...    ${kpi_path}=${CURDIR}
    ...    ${KPI_file}=CB008246_E_006_KPI.txt
    ...    ${para_index}=${2}
    ${newest_xml_file}=    get_newest_pm_xml_file    ip=${bts_ip}    username=${bts_username}    password=${bts_password}
    ...    connection=gNB${index}    local_path=${epc_log_path}
    ${dict_kpi_value}=    calculate_dict_kpis_from_pm_file    pm_xml_file=${newest_xml_file}
    ...    kpi_file=${kpi_path}/${KPI_file}    para_index=${para_index}
    [Return]    ${dict_kpi_value}

MTK UE detach and stop traffic
    [Arguments]    ${ue_type}=mtk    ${ue_index}=${0}
    Run Keyword And Ignore Error   Stop UE DLUL traffic    ue_index=${ue_index}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

MTK UE recover
    MTK UE detach and stop traffic    ue_type=mtk    ue_index=${9}


#MTK UE recover
#    FOR    ${i}    IN    ${9}    ${9}
#        MTK UE detach and stop traffic    ue_type=mtk    ue_index=${i}
#    END

feature CB010701 case steps
    Online modify parmeters    parameters_to_update=${parameters_to_update_CB013151_CNI156183}    skip_parameter_relation_errors=False
    ping_pang_common_keywords.Set the attenuation value of ports simultaneously
    ...    att_ports=${ports_1}
    ...    values=${values_1}
    ...    att_ipaddr=${tl.attenuator[3].ip_addr}
    ping_pang_common_keywords.Set the attenuation value of ports simultaneously
    ...    att_ports=${ports_2}
    ...    values=${values_3}
    ...    att_ipaddr=${tl.attenuator[3].ip_addr}
#    Reboot PC    ue_index=${9}
#    Reboot PC    ue_index=${10}
    MTK UE reboot for WA    ue_index=${9}
#    MTK UE reboot for WA    ue_index=${10}
    MTK prepare UE    ue_index=${9}    ue_type=mtk
#    MTK prepare UE    ue_index=${10}    ue_type=mtk
    enable_vonr_capability    alias=UE_${9}
#    enable_vonr_capability    alias=UE_${10}
    sleep    5s
    Wait until keyword succeeds    3X    10s    MTK attach UE    logname=${logname_B_B3_003_attach_1}    ue_index=${9}
#    Wait until keyword succeeds    3X    10s    MTK attach UE    logname=${logname_B_B3_003_attach_2}    ue_index=${10}
    Start capture gNB log on master    filename=${logname_B_B3_003_attach_3}    gNB_index=${0}
    ping_pang_common_keywords.Set the attenuation value of ports simultaneously
    ...    att_ports=${ports_2}
    ...    values=${values_2}
    ...    att_ipaddr=${tl.attenuator[3].ip_addr}
    sleep    10s
    Run keyword and continue on failure    MTK start traffic with DL and UL    ue_index=${9}    UE_IP=${ue_ip9}
    ...    tput_dl_pcell=${tput_dl_pcell}    tput_dl_scell=${tput_dl_scell}    tput_ul_pcell=${tput_ul_pcell}    tput_ul_scell=${tput_ul_scell}
#    MTK start traffic with DL and UL    ue_index=${10}    UE_IP=${ue_ip10}
#    ...    tput_dl_pcell=${tput_dl_pcell}    tput_dl_scell=${tput_dl_scell}    tput_ul_pcell=${tput_ul_pcell}    tput_ul_scell=${tput_ul_scell}
    Stop and download the Logs    filename=${logname_B_B3_003_attach_3}   gNB_index=${0}
    Prepare to caculate PM counter    period=start
    Sleep    6m    reason=wait for whole 5min and wait for pm file generated
#    Check gnb counters 10701    counter_ids=${counter_ids}    dic_paths=${counter_paths}    expected_values=${expected_values}
    Check 10701 Pcell KPI from pm file    KPI_file=CB010701_pcell_counters.txt    para_index=${1}
    Check 10701 Scell KPI from pm file    KPI_file=CB010701_scell_counters.txt    para_index=${10}
    ${13151_C_bip}    Collect bip log for 13151    target_file_name=13151_bip_273Prb    gnb_index=${0}
    check 13151 bip log    filepath=${13151_C_bip}    subcellid=${3}
    [Teardown]    Run Keywords
#    ...    Stop UE DLUL traffic    ue_index=${9}    dl_port=NULL    AND
    ...    Run Keyword And Ignore Error     Stop and download the Logs    filename=${logname_B_B3_003_attach_1}   gNB_index=${0}    AND
#    ...    Run Keyword And Ignore Error     Stop and download the Logs    filename=${logname_B_B3_003_attach_2}   gNB_index=${0}    AND
    ...    Run Keyword And Ignore Error     Stop and download the Logs    filename=${logname_B_B3_003_attach_3}   gNB_index=${0}    AND
    ...    Online modify parmeters    parameters_to_update=${parameters_to_recovery_CB013151_CNI156183}    skip_parameter_relation_errors=False

Reboot PC
    [Arguments]    ${ue_index}=${9}   ${connection}=gnb    #${serial_number}=${tl.ues[${ue_index}].serial_number}    ${ue_type}=xiaomi
    log to console    PC_reboot
    Run Keyword And Ignore Error   csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=${connection}
    Run Keyword And Ignore Error    csn.send_command    command=shutdown /r /f /t 0
    ...   connection=${connection}
    sleep    120s
    Run Keyword And Ignore Error   csn.disconnect      connection=${connection}

Check gnb counters 10701
    [Arguments]    ${counter_ids}    ${dic_paths}    ${gnb_id}=${1}    ${timeout}=300    #${expected_values}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].cu.oam_ssh_connection_details.addr}
    FOR    ${index}    ${counter_id}    IN ENUMERATE    @{counter_ids}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
        ...    dic_path=${dic_paths}[${index}]    timeout=${timeout}
#        IF    '${counter_id}' == 'M55370C00039'
#            should be true   ${counter_value}[0]>${expected_values}[${index}]
#        ELSE
#            should be true   ${counter_value}[0]==${expected_values}[${index}]
#        END
    END
    [Teardown]    COAM Teardown gnb connections

Check 10701 Pcell KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    ${M55181C00013}=    Set Variable    ${dict_kpis_name_value}[${CB010701_pcell_counters[0]}]
    ${M55165C00039}=    Set Variable    ${dict_kpis_name_value}[${CB010701_pcell_counters[1]}]
    ${M55118C00054}=    Set Variable    ${dict_kpis_name_value}[${CB010701_pcell_counters[2]}]
    ${M55181C00003}=    Set Variable    ${dict_kpis_name_value}[${CB010701_pcell_counters[3]}]
    ${M55370C00038}=    Set Variable    ${dict_kpis_name_value}[${CB010701_pcell_counters[4]}]
    ${M55370C00039}=    Set Variable    ${dict_kpis_name_value}[${CB010701_pcell_counters[5]}]
    ${M55370C00040}=    Set Variable    ${dict_kpis_name_value}[${CB010701_pcell_counters[6]}]
    Should Be True    ${M55181C00013} == ${300}
    Should Be True    ${M55165C00039} == ${300}
    Should Be True    ${M55118C00054} == ${300}
    Should Be True    ${M55181C00003} == ${300}
    Should Be True    ${M55370C00038} == ${0}
    Should Be True    ${M55370C00039} == ${0}
    Should Be True    ${M55370C00040} > ${1}
#
Check 10701 Scell KPI from pm file
    [Arguments]     ${KPI_file}    ${para_index}    ${index}=${0}
    ${dict_kpis_name_value}=    get dict kpi from pm file    KPI_file=${KPI_file}    para_index=${para_index}    index=${index}
    ${M55370C00038}=    Set Variable    ${dict_kpis_name_value}[${CB010701_scell_counters[0]}]
    ${M55370C00039}=    Set Variable    ${dict_kpis_name_value}[${CB010701_scell_counters[1]}]
    ${M55370C00040}=    Set Variable    ${dict_kpis_name_value}[${CB010701_scell_counters[2]}]
    Should Be True    ${M55370C00038} == ${0}
    Should Be True    ${M55370C00039} > ${1}
    Should Be True    ${M55370C00040} == ${0}

Collect bip log for 13151
    [Arguments]    ${target_file_name}    ${gnb_index}=${0}
    Collect Interface Mirroring Bip Collector    target_file_name=${target_file_name}    interface=L1-L2    nr_phy_cell_ids=1,301
    ...                                          host_ip=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...                                          username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...                                          password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    sleep    0.5s    reason=wait for a while after start traffic.
    ${13151_bip}     Get Bip Log Via Interface Mirroring Collector    target_file_name=${target_file_name}    target_dir=${epc_log_path}
    [Return]     ${13151_bip}[0]

check 13151 bip log
    [Arguments]    ${filepath}    ${subcellid}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${filepath}    alias=test6
#    ${filter_expression}=     Catenate    ((3gpp.subcellid == ${subcellid}) && (UlData_puschReceiveReqGrant_t.startPrb == 0)) &&
#    ...                                     (UlData_puschReceiveReqGrant_t.numOfPrb == 273)
    ${filter_expression}=     Catenate    (((3gpp.subcellid == ${subcellid}) && (UlData_puschReceiveReqGrant_t.startPrb == 0)) &&
    ...                                   (UlData_puschReceiveReqGrant_t.numOfPrb == 273)) && (UlData_puschReceiveReqGrant_t.mcs == 27)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
#    ${numOfPrb}=     cap.Get Field Value By Xpath    xpath=.//UlData_puschReceiveReqGrant_t.numOfPrb    pcap_parser=test6
#    should contain    ${numOfPrb}    273
    ${mcs}=     cap.Get Field Value By Xpath    xpath=.//UlData_puschReceiveReqGrant_t.mcs    pcap_parser=test6
    should contain    ${mcs}    27

#feature CB010701 case steps
#    ping_pang_common_keywords.Set the attenuation value of ports simultaneously
#    ...    att_ports=${case_test_info}[source_cell][cell_ant_port]
#    ...    values=${case_test_info}[source_cell][cell_ant_initial_value]
#    ...    att_ipaddr=${case_test_info}[source_cell][att_ip_addr]
#    MTK UE reboot for WA    ue_index=${9}
#    MTK UE reboot for WA    ue_index=${10}
#    MTK prepare UE    ue_index=${9}    ue_type=mtk
#    MTK prepare UE    ue_index=${10}    ue_type=mtk
#    MTK attach UE    logname=${logname_B_B3_003_attach_1}    ue_index=${9}
#    MTK attach UE    logname=${logname_B_B3_003_attach_2}    ue_index=${10}
#    MTK restart network interface
#    MTK start traffic with DL and UL
#    ping_pang_common_keywords.Set the attenuation value of ports simultaneously
#    ...    att_ports=${case_test_info}[source_cell][cell_ant_port]
#    ...    values=${case_test_info}[source_cell][cell_ant_initial_value]
#    ...    att_ipaddr=${case_test_info}[source_cell][att_ip_addr]
#    Prepare to caculate PM counter    period=start
#    Sleep    6m    reason=wait for whole 5min and wait for pm file generated
#    Check 10701 KPI from pm file    KPI_file=CB010701_counters.txt    para_index=${1}