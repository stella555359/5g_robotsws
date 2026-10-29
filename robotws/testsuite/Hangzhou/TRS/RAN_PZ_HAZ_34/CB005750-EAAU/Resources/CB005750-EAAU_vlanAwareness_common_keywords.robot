*** Settings ***
Documentation
...    author: Wu Fangmin
...    contact: fangmin.wu@nokia-sbell.com
...    squad group: MMW_HZ_SG_03
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Variables ***

${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${TestPC_addr}    ${tl.test_pc.default_ssh_connection_details.addr}
${TestPC_username}    ${tl.test_pc.default_ssh_connection_details.username}
${TestPC_password}    ${tl.test_pc.default_ssh_connection_details.password}
${nrbtsId}    ${tl.gnbs[0].instance_id}
${mrbtsId}    ${tl.gnbs[0].global_bts_id}

*** Keywords ***

login on gNB DU
    csn.Connect To    hostname=${asik_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=gnb DU

Du COAM Update Parameter
    [Arguments]   ${dist_name}   ${parameter}   ${value}   ${connection}=GNB_OAM
    Log    \n Du COAM Update Parameter     console=yes
    Cloud DU connect to gnb coam via ssl
    coam.perform_parameter_recommissioning   dist_name=${dist_name}   parameter=${parameter}   value=${value}
    ...   operation=update
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=60
    ...   connection=${connection}
    sleep    5s
    [teardown]    COAM Teardown gnb connections

Check all EIF port status on DU should be up
    login on gNB DU
    ${EIF1_status}    csn.execute    dbgnac show port 13    connection=gnb DU
    should not contain    ${EIF1_status}    down
    ${EIF2_status}    csn.execute    dbgnac show port 14    connection=gnb DU
    should contain    ${EIF2_status}    down
    ${EIF3_status}    csn.execute    dbgnac show port 15    connection=gnb DU
    should not contain    ${EIF3_status}    down
    [Teardown]    csn.disconnect    connection=gnb DU

TestPC connections
    csn.Connect To    hostname=${TestPC_addr}
    ...               username=${TestPC_username}
    ...               password=${TestPC_password}
    ...               alias=TestPC

Send all type traffic and capture tcpdump from testcenter
    [Arguments]     ${testcenter_tclfile}    ${Log_name}
    Log    \n send traffic and collect logs     console=yes
    TestPC connections
    csn.send command    command=sudo tclsh ${testcenter_tclfile}    connection=TestPC
    sleep    60s
    ${current_time}=   Get Current Date
    ${converted_date}=    Convert Date    date=${current_time}     result_format=%Y%m%d%H%M%S
    set test variable    ${wireshark_log_path}     ${LOG_PATH}/${Log_name}_${converted_date}.pcap
    csn.send command    command=mv ${TS_LOG_PATH_BASE}${Log_name}.pcap ${wireshark_log_path}    connection=TestPC
    [Teardown]    csn.disconnect    connection=TestPC

Analysis log
    [Arguments]    ${log_path}    ${accepted_ip}    ${dropped_ip}
    Log    \n Analysis wireshark log     console=yes
    tsk.read_cap    cap_file=${log_path}
    ${result}=    tsk.get_latest50_packages_startwith_192_168     field_expression=ip.dst
    ${dropped_ip_len}    get length    ${dropped_ip}
    FOR    ${i}    IN RANGE    ${dropped_ip_len}
         Should not contain   container=${result}     item=${dropped_ip[${i}]}
     END
    ${accepted_ip_len}    get length    ${accepted_ip}
    FOR    ${i}    IN RANGE    ${accepted_ip_len}
         Should contain   container=${result}     item=${accepted_ip[${i}]}
     END

Check FDB mac address contain VLAN-ID and DST-MAC
    [Arguments]    ${VLAN_ID}
    login on gNB DU
    sleep    10s
    ${IPV_status}    csn.execute    dbgnac show mac|grep DY|grep 13    connection=gnb DU
    should contain    container=${IPV_status}   item=${VLAN_ID}
    [Teardown]    csn.disconnect    connection=gnb DU

Check FDB mac address not contain VLAN-ID and DST-MAC
    [Arguments]    ${VLAN_ID}
    login on gNB DU
    sleep    10s
    ${IPV_status}    csn.execute    dbgrrc show mac|grep Dy|grep 15    connection=gnb DU
    should not contain    container=${IPV_status}    item=${VLAN_ID}
    [Teardown]    csn.disconnect    connection=gnb DU

Backup wireshark Files
    [Arguments]     ${Log_name}
    TestPC connections
    csn.send command    command=mv ${TS_LOG_PATH_BASE}${Log_name} ${LOG_PATH}/${Log_name}    connection=TestPC
    [Teardown]    csn.disconnect    connection=TestPC