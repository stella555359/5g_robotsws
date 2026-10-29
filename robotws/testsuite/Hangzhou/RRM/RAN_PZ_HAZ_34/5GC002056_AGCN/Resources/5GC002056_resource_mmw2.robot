*** Settings ***
Documentation
...    author: jiayi tang
...    contact: jiayi.tang@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_2_SG
...    Feature 5GC002256 program

Library    SSHLibrary    WITH NAME    ssh_lib
Library    ute_reporting_portal
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/kpi_reporter.py
Library    kpi_reporter.KpiReporter    WITH NAME    KpiReporter
Library    taf.hw.rf_attenuator    WITH NAME    atten
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot

*** Variables ***
${du_ip}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${du_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${du_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${maxMIMO_Layers_filter1}    nr-rrc.maxMIMO_Layers == 1 and nr-rrc.c1 == 0
${maxMIMO_Layers_filter2}    nr-rrc.maxMIMO_Layers == 2 and nr-rrc.c1 == 0
${xpath}    .//nr-rrc.uplinkConfig_element/nr-rrc.pusch_ServingCellConfig/nr-rrc.setup_element/nr-rrc.maxMIMO_Layers
${rank_port1}    ${tl.attenuator.attenuator_ports[13].port_no}
${rank_port2}    ${tl.attenuator.attenuator_ports[14].port_no}
${attenuator_port}    ${tl.attenuator.port}
${CASE_LOG_PATH}    ${logPath}
${ue_type}    huawei_android
${ue_index}    0

*** Keywords ***
TopYong Attenuation Initial Value set
    attenuator.setup_attenuator    attenuator=${tl.attenuator}
    atten.set_attenuation    ${rank_port1}    ${10}
    atten.set_attenuation    ${rank_port2}    ${10}
    sleep    3s

TopYong Attenuation Value Change
    attenuator.setup_attenuator    attenuator=${tl.attenuator}
    atten.set_attenuation    ${rank_port1}    ${50}
    atten.set_attenuation    ${rank_port2}    ${50}
    sleep    3s
    atten.set_attenuation    ${rank_port1}    ${10}
    atten.set_attenuation    ${rank_port2}    ${10}

Get TcpdumpLogs from Remote machine with local capture
    ${executor_du}=  Create Dictionary
    ...  host=${du_ip}
    ...  user=${du_username}
    ...  password=${du_password}
    tcpdump.create_tcpdump_collector
    ...     name=tcpdump
    ...     options=-i any
    ...     executor=${executor_du}
    ...     capture_locally=yes
    core.setup_collectors    names=tcpdump
    core.start_collectors    names=tcpdump
    TopYong Attenuation Value Change
    sleep    3s
    TopYong Attenuation Initial Value set
    sleep    3s
    TopYong Attenuation Value Change
    sleep    3s
    core.stop_collectors    names=tcpdump
    core.collect_collectors    names=tcpdump    target_dir=${logPath}
    core.teardown_collectors    names=tcpdump

Check Rank Value
    [Arguments]    ${pcap_file}=${logPath}/tcpdump/tcpdump.pcap    ${filter_expression}=${maxMIMO_Layers_filter2}
    ${filtered_packets}    container_log_capturing.Load pcap with filter    pcap_file=${pcap_file}    filter_expression=${filter_expression}
    ${maxMIMO_Layers}    cap.Get Field Value By Xpath     pdml_list=${filtered_packets}    xpath=${xpath}    attribute_name=value
    #${maxMIMO_Layers}    Evaluate    map(lambda x: int(x, 16), ${maxMIMO_Layers})
    should not be empty    ${maxMIMO_Layers}

Check Rank Value Disable
    [Arguments]    ${pcap_file}=${logPath}/tcpdump/tcpdump.pcap    ${filter_expression}=${maxMIMO_Layers_filter2}
    ${filtered_packets}    container_log_capturing.Load pcap with filter    pcap_file=${pcap_file}    filter_expression=${filter_expression}
    ${maxMIMO_Layers}    cap.Get Field Value By Xpath     pdml_list=${filtered_packets}    xpath=${xpath}    attribute_name=value
    #${maxMIMO_Layers}    Evaluate    map(lambda x: int(x, 16), ${maxMIMO_Layers})
    should be empty    ${maxMIMO_Layers}

Start UL L3call
     power_ue.Prepare UE    ue_type=${ue_type}
     Sleep   1s
     power_ue.UE Attach    ue_type=${ue_type}
     Sleep    1s
     power_ue.Verify attach    ue_type=${ue_type}
     power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=50    duration=120    protocol=udp
     Sleep    80s
     power_ue.Check Tput    ue_type=${ue_type}    direction=ul    target_throughput=50    target_avg_percent=0.6    min_percent=0.5
     [teardown]    Run keyword And ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul
