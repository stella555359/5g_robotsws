*** Settings ***
Library  taf/rfrl/procedures/resources/python/utilities.py

*** Keywords ***
Run script
    [Arguments]  ${command}
    ${result} =  Run Process   ${command}  shell=True
    Log to console  ${result.stderr}
    Log to console  ${result.stdout}

Set Script Path
    ${cmd} =  build_script_command
    Set Global Variable  ${command}  ${cmd}

Set Variables GLUON
    Set Global Variable  ${INGRESS_MAX_1}  ${422}
    Set Global Variable  ${INGRESS_MIN_1}  ${241}

    Set Global Variable  ${INGRESS_MAX_2}  ${550}
    Set Global Variable  ${INGRESS_MIN_2}  ${450}

    Set Global Variable  ${INGRESS_MAX_3}  ${2178}
    Set Global Variable  ${INGRESS_MIN_3}  ${1782}

    Set Global Variable  ${INGRESS_MAX_4}  ${7630}
    Set Global Variable  ${INGRESS_MIN_4}  ${6242}

    Set Global Variable  ${INGRESS_MAX_5}  ${90772}
    Set Global Variable  ${INGRESS_MIN_5}  ${37134}

    Set Global Variable  ${ICMP_packets_number}  ${500}

    Set Global Variable  ${container_name}  0x2018
    Set Global Variable  ${eth3_ip}  172.22.56.165
    Set Global Variable  ${dest_ip}  172.22.56.162

Set Variables ASMR
    Set Global Variable  ${INGRESS_MAX_1}  ${312}
    Set Global Variable  ${INGRESS_MIN_1}  ${256}

    Set Global Variable  ${INGRESS_MAX_2}  ${450}
    Set Global Variable  ${INGRESS_MIN_2}  ${350}

    Set Global Variable  ${INGRESS_MAX_3}  ${2024}
    Set Global Variable  ${INGRESS_MIN_3}  ${1656}

    Set Global Variable  ${INGRESS_MAX_4}  ${2722}
    Set Global Variable  ${INGRESS_MIN_4}  ${2268}

    Set Global Variable  ${INGRESS_MAX_5}  ${91030}
    Set Global Variable  ${INGRESS_MIN_5}  ${74480}

    Set Global Variable  ${ICMP_packets_number}  ${400}

    Set Global Variable  ${container_name}  0x1018
    Set Global Variable  ${eth3_ip}  172.22.48.165
    Set Global Variable  ${dest_ip}  172.22.48.162

Set RU Account Pass For 22R1
    set_ru_account_pass

Set Up DHCP
    bbuhelpers.set_dhcp    container_name=${container_name}
    gnbru.reset_radio_unit    timeout=${600}
    gnbbbu.wait_for_site_to_be_onair

Get Egress ICMP Info
    ${egress_ICMP_rules}    gnbru.get_ru_discard_rules_info    gnb_id=${0}    du_id=${0}    radio_unit_id=${0}    rate_limit=${null}
    Set Suite Variable    ${egress_ICMP_rules}

Egress_rate_limiting_ICMP
    [Arguments]    ${type}
    should contain    ${egress_ICMP_rules}    ${type}

Egress_rate_limiting_ICMP_no
    [Arguments]    ${type}
    should not contain    ${egress_ICMP_rules}    ${type}

Stateful_packet_filtering_for_RU_initiated_traffic_flows_IPv4
    [Arguments]    ${dest_ip}
    ${counter_before}=  gnbru.get_ru_discard_rules_info    gnb_id=${0}    du_id=${0}    radio_unit_id=${0}    rate_limit=${FALSE}
    ruhelpers.spam_ls
    ${counter_mid}=  gnbru.get_ru_discard_rules_info    gnb_id=${0}    du_id=${0}    radio_unit_id=${0}    rate_limit=${FALSE}
    should be true  ${counter_mid}-${counter_before}<10
    Send_packets    protocol=TCP   dest_ip=${dest_ip}   dport=21   sport=1500   flags=APRSF   interval=0.1   number_of_packets=1000
    Send_packets    protocol=TCP   dest_ip=${dest_ip}   dport=22   sport=1500   flags=APRSF   interval=0.1   number_of_packets=1000
    ${counter_after}=  gnbru.get_ru_discard_rules_info   gnb_id=${0}    du_id=${0}    radio_unit_id=${0}    rate_limit=${FALSE}
    should be true  ${counter_after}-${counter_mid}>=1800

Stateless_packet_filtering_for_IPv4
    [Arguments]    ${dest_ip}
    ${counter_before}=  gnbru.get_ru_discard_rules_info    gnb_id=${0}    du_id=${0}    radio_unit_id=${0}    rate_limit=${FALSE}
    Sendd_packets    protocol=UDP    dest_ip=${dest_ip}    dport=13100    sport=13001    interval=0.05    number_of_packets=1000
    ${counter_mid}=  gnbru.get_ru_discard_rules_info    gnb_id=${0}    du_id=${0}    radio_unit_id=${0}    rate_limit=${FALSE}
    should be true  ${counter_mid}-${counter_before}<100
    Sendd_packets    protocol=UDP    dest_ip=${dest_ip}    dport=13100    sport=13100    interval=0.05    number_of_packets=1000
    ${counter_after}=  gnbru.get_ru_discard_rules_info    gnb_id=${0}    du_id=${0}    radio_unit_id=${0}    rate_limit=${FALSE}
    should be true  ${counter_after}-${counter_mid}>=900

Ingress_rate_limiting_ICMP_IPv4
    [Arguments]    ${type}    ${dest_ip}    ${table}    ${rate_limit}  ${max}  ${min}  ${number_of_packets}
    ${counter_before}=  gnbru.get_ru_discard_rules_info    gnb_id=${0}    du_id=${0}    radio_unit_id=${0}    rate_limit=${rate_limit}
    ...                 table=${table}
    Send_ICMP_packets    dest_ip=${dest_ip}   type=${type}   interval=${number_of_packets}   number_of_packets=${number_of_packets}
    ${counter_after}=  gnbru.get_ru_discard_rules_info    gnb_id=${0}    du_id=${0}    radio_unit_id=${0}    rate_limit=${rate_limit}
    ...                 table=${table}
    should be true  ${max}>=(${counter_after}-${counter_before})>=${min}

Send_ICMP_packets
    [Arguments]    ${dest_ip}    ${type}    ${interval}    ${number_of_packets}
    ${command}=  Catenate   ${command}
    ...          -destination_address ${dest_ip}
    ...          -source 172.21.1.18
    ...          -protocol ICMP
    ...          -type ${type}
    ...          -pps ${interval}
    ...          -loop ${number_of_packets}
    ...          -interface ${interface}
    Run script  ${command}

Send_packets
    [Arguments]    ${protocol}    ${dest_ip}    ${dport}    ${sport}    ${flags}    ${interval}  ${number_of_packets}
    ${command}=  Catenate   ${command}
    ...          -destination_address ${dest_ip}
    ...          -source 172.21.1.18
    ...          -protocol ${protocol}
    ...          -dport ${dport}
    ...          -sport ${sport}
    ...          -flags ${flags}
    ...          -number_of_packets ${number_of_packets}
    ...          -interval ${interval}
    ...          -interface ${interface}
    Run script  ${command}

Sendd_packets
    [Arguments]    ${protocol}    ${dest_ip}    ${dport}    ${sport}   ${interval}   ${number_of_packets}
    ${command}=  Catenate   ${command}
    ...          -destination_address ${dest_ip}
    ...          -source 172.21.1.18
    ...          -protocol ${protocol}
    ...          -dport ${dport}
    ...          -sport ${sport}
    ...          -number_of_packets ${number_of_packets}
    ...          -interval ${interval}
    ...          -interface ${interface}
    Run script  ${command}

Fast_send_packets
    [Arguments]    ${protocol}    ${dest_ip}    ${dport}    ${sport}    ${flags}    ${pps}    ${loop}
    ${command}=  Catenate   ${command}
    ...          -destination_address ${dest_ip}
    ...          -source 172.21.1.18
    ...          -protocol ${protocol}
    ...          -dport ${dport}
    ...          -sport ${sport}
    ...          -flags ${flags}
    ...          -pps ${pps}
    ...          -loop ${loop}
    ...          -interface ${interface}
    Run script  ${command}

Fast_Sendd_packets
    [Arguments]    ${protocol}    ${dest_ip}    ${dport}    ${sport}    ${pps}    ${loop}
    ${command}=  Catenate   ${command}
    ...          -destination_address ${dest_ip}
    ...          -source 172.21.1.18
    ...          -protocol ${protocol}
    ...          -dport ${dport}
    ...          -sport ${sport}
    ...          -pps ${pps}
    ...          -loop ${loop}
    ...          -interface ${interface}
    Run script  ${command}

Send_packets_parallel
    ${command}=  Catenate  ${command}
    ...  -parallel
    ...  -destination_address ${dest_ip}
    ...  -interface ${interface}
    ...  -source 172.21.1.18
    Run script  ${command}
