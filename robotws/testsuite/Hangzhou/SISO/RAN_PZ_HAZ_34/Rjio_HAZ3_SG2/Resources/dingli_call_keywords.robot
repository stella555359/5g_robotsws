*** Settings ***
Documentation     author: Deng Xueqin
...               contact: xueqin.deng@nokia-sbell.com
...               squad group: HAZ3_SG2

Library           taf.ue.pioneer.client       WITH NAME           pclient

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/cell_addition_deletion_online.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot

*** Variables ***
${dingli_index}    1
${dingli_imei}    ${tl.ues[${dingli_index}].imei}
${appserver_addr}    ${tl.ues[${dingli_index}].iperf_details.ssh_connection_details.addr}
${appserver_username}    ${tl.ues[${dingli_index}].iperf_details.ssh_connection_details.username}
${appserver_password}    ${tl.ues[${dingli_index}].iperf_details.ssh_connection_details.password}
${dl_traffic_port}    ${tl.ues[${dingli_index}].iperf_details.port}
${ul_traffic_port}    ${tl.ues[${dingli_index}].iperf_details.ssh_connection_details.port}
${ue_controller_ip}    ${tl.ues[${dingli_index}].ssh_connection_details.addr}
${ue_controller_username}    ${tl.ues[${dingli_index}].ssh_connection_details.username}
${ue_controller_password}    ${tl.ues[${dingli_index}].ssh_connection_details.password}

${testtime}    1200
${buffersize}    1024
${packetsize}    1400


*** Keywords ***
Dingli l3call traffic nCA
    [Arguments]    ${gci}
    ${tput_cell}    Get tput cell info    tput_info=${tput_define_HO}   cell_id=${gci}
    Perform dingli attach
    Dingli start traffic
    ...    tput_ul=${tput_cell['ul_tp']}    tput_dl=${tput_cell['dl_tp']}
    Dingli check throughput
    ...    tput_ul_exp=${tput_cell['ul_exp']}    tput_dl_exp=${tput_cell['dl_exp']}    cell_id=${cell_${gci}_id}
    [Teardown]    run keyword and ignore error    Dingli stop traffic and detach

Dingli l3call traffic CA
    [Arguments]    ${gcip}    ${gcis}
    ${tput_pcell}    Get tput cell info    tput_info=${tput_define}   cell_id=${gcip}
    ${tput_scell}    Get tput cell info    tput_info=${tput_define_Scell}   cell_id=${gcis}
    Perform dingli attach
    Dingli start traffic
    ...    tput_ul=${tput_pcell['ul_tp']}    tput_dl=${tput_pcell['dl_tp']}
    Dingli check throughput
    ...    tput_ul_exp=${tput_pcell['ul_exp']}    tput_dl_exp=${tput_pcell['dl_exp']}    cell_id=${cell_${gcip}_id}
    Dingli check throughput
    ...    tput_ul_exp=${tput_scell['ul_exp']}    tput_dl_exp=${tput_scell['dl_exp']}    cell_id=${cell_${gcis}_id}
    [Teardown]    run keyword and ignore error    Dingli stop traffic and detach
    
Dingli call Setup
    [Arguments]    ${ue_index}=${dingli_index}    ${power_reset}=${true}    ${detach_request}=${true}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    set suite variable    ${ue_type}
    log    ${ue_type}
    log to console  \n***Prepare UE***
    power_ue.Prepare UE    ue_index=${ue_index}   ue_type=${ue_type}
    ...    power_reset=${power_reset}    detach_request=${detach_request}

Dingli call teardown
    Log To Console    \n *** Call teardown***
    power_ue.Teardown UE    ue_type=${ue_type}    ue_index=${dingli_index}

Perform dingli attach
    [Arguments]    ${ue_index}=${dingli_index}    ${power_reset}=${true}
    log to console  \n***UE Attach***
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}
    ...    log_type=Aasyslog    power_reset=${power_reset}
    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False

Dingli start UL traffic
    [Arguments]    ${tput}    ${ue_index}=${dingli_index}    ${apn_address}=dxdata1    ${duration}=1200
    log to console    \n***Start UL traffic***
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul     throughput=${tput}
    ...    apn_address=${apn_address}    duration=${duration}    protocol=UDP    ue_mode=SA
    Sleep   3s
	
Dingli start DL traffic
    [Arguments]        ${tput}    ${ue_index}=${dingli_index}    ${apn_address}=dxdata1    ${duration}=1200
    log to console    \n***Start DL traffic***
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl     throughput=${tput}
    ...    apn_address=${apn_address}    duration=${duration}    protocol=UDP    ue_mode=SA
    Sleep   3s

Get tput cell info
    [Arguments]    ${tput_info}    ${cell_id}
    ${tput_cell}    set variable    ${tput_info[${cell_id}]}
    log to console    \n***tput info for cell ${cell_id} is: ${tput_cell}***\n
    [Return]    ${tput_cell}

Dingli start traffic
    [Arguments]    ${tput_ul}    ${tput_dl}
    Dingli start UL traffic    tput=${tput_ul}
    Dingli start DL traffic    tput=${tput_dl}

Dingli check throughput
    [Arguments]    ${tput_ul_exp}    ${tput_dl_exp}    ${cell_id}    ${ue_index}=${dingli_index}
    ${cell_list}    create list    ${cell_id}
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    ue_index=${ue_index}     duration=1m    check_source=aasyslog
    log to console   \n***Check Tput***
    ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${cell_list}    check_source=aasyslog
    ...    ue_index=${ue_index}    ultarget_throughput=${tput_ul_exp}    dltarget_throughput=${tput_dl_exp}
    
Dingli stop traffic and detach
    log to console    \n***Stop Traffic and Detach***
    run keyword and ignore error    power_ue.Stop traffic    direction=ul    ue_index=${dingli_index}    ue_type=${ue_type}
    run keyword and ignore error    power_ue.Stop traffic    direction=dl    ue_index=${dingli_index}    ue_type=${ue_type}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${dingli_index}   power_reset=${true}