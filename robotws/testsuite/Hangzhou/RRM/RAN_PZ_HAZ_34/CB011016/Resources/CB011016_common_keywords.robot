*** Settings ***
Documentation
...    author: xiaodan.li
...    contact: xiaodan.li@nokia-sbell.com
...    squad group: SG_03
...    feature : CB008140

Library     DateTime
Library     taf.analyzer.pcap    WITH NAME    cap
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.hw.rf_attenuator    WITH NAME    atten
Library     taf.config.testline    WITH NAME    testline
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot


*** Variables ***
${ue_type}           ${tl.ues[0].capabilities[0]}
${iperf_port}    ${tl.ues[${0}].iperf_details.port}
${tl_scf_dir_path}    /opt/workspace/CRT/Master/SCF_file/
${gnb_instance}    ${tl.gnbs[0].instance_id}
${bts_host0}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${bts_host1}    ${tl.gnbs[1].cu.oam_http_connection_details.addr}
${att_port_1_gnb1_cell1_37711}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_gnb1_cell1_37711}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3_gnb1_cell1_37711}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4_gnb1_cell1_37711}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_1_gnb1_cell2_37711}                ${tl.attenuator[1].attenuator_ports[5]}
${att_port_2_gnb1_cell2_37711}                ${tl.attenuator[1].attenuator_ports[6]}
${att_port_3_gnb1_cell2_37711}                ${tl.attenuator[1].attenuator_ports[7]}
${att_port_4_gnb1_cell2_37711}                ${tl.attenuator[1].attenuator_ports[8]}
${att_port_1_gnb2_cell1_37711}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_2_gnb2_cell1_37711}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_3_gnb2_cell1_37711}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_4_gnb2_cell1_37711}                ${tl.attenuator[0].attenuator_ports[8]}
${att_ipaddr_gnb1_cell1_37711}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb1_cell2_37711}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_gnb2_cell1_37711}                ${tl.attenuator[0].ip_addr}
${att_port_1_gnb1_cell1_38811}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_gnb1_cell1_38811}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3_gnb1_cell1_38811}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4_gnb1_cell1_38811}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_1_gnb1_cell2_38811}                ${tl.attenuator[1].attenuator_ports[1]}
${att_port_2_gnb1_cell2_38811}                ${tl.attenuator[1].attenuator_ports[2]}
${att_port_3_gnb1_cell2_38811}                ${tl.attenuator[1].attenuator_ports[3]}
${att_port_4_gnb1_cell2_38811}                ${tl.attenuator[1].attenuator_ports[4]}
${att_port_1_gnb2_cell1_38811}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_2_gnb2_cell1_38811}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_3_gnb2_cell1_38811}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_4_gnb2_cell1_38811}                ${tl.attenuator[0].attenuator_ports[8]}
${att_ipaddr_gnb1_cell1_38811}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb1_cell2_38811}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_gnb2_cell1_38811}                ${tl.attenuator[0].ip_addr}
${att_port_1_gnb1_cell1_37611}                ${tl.attenuator[0].attenuator_ports[9]}
${att_port_2_gnb1_cell1_37611}                ${tl.attenuator[0].attenuator_ports[10]}
${att_port_3_gnb1_cell1_37611}                ${tl.attenuator[0].attenuator_ports[11]}
${att_port_4_gnb1_cell1_37611}                ${tl.attenuator[0].attenuator_ports[12]}
${att_port_1_gnb2_cell2_37611}                ${tl.attenuator[1].attenuator_ports[9]}
${att_port_2_gnb2_cell2_37611}                ${tl.attenuator[1].attenuator_ports[10]}
${att_port_3_gnb2_cell2_37611}                ${tl.attenuator[1].attenuator_ports[11]}
${att_port_4_gnb2_cell2_37611}                ${tl.attenuator[1].attenuator_ports[12]}
${att_port_1_gnb2_cell1_37611}                ${tl.attenuator[0].attenuator_ports[13]}
${att_port_2_gnb2_cell1_37611}                ${tl.attenuator[0].attenuator_ports[14]}
${att_port_3_gnb2_cell1_37611}                ${tl.attenuator[0].attenuator_ports[15]}
${att_port_4_gnb2_cell1_37611}                ${tl.attenuator[0].attenuator_ports[16]}
${att_port_1_enb_cell_37611}                  ${tl.attenuator[2].attenuator_ports[9]}
${att_ipaddr_gnb1_cell1_37611}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb2_cell2_37611}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_gnb2_cell1_37611}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_enb_cell_37611}                  ${tl.attenuator[2].ip_addr}
@{gnb_id}    37611    37711    38811
@{branch}    SBTS24R2_ENB_9999

*** Keywords ***
Adjust gNB_RU Attenuation
    [Arguments]     ${tl}=${gnb_instance}
    ...    ${gnb1_cell1_value}=${127}    ${gnb2_cell2_value}=${127}    ${gnb2_cell1_value}=${127}
    ...    ${enb_cell_value}=${127}
    ####create cell list#####
    @{att_ports_gnb1_cell1}    Create List    ${att_port_1_gnb1_cell1_${tl}}    ${att_port_2_gnb1_cell1_${tl}}
    ...    ${att_port_3_gnb1_cell1_${tl}}    ${att_port_4_gnb1_cell1_${tl}}
    @{att_ports_gnb2_cell2}    Create List    ${att_port_1_gnb2_cell2_${tl}}    ${att_port_2_gnb2_cell2_${tl}}
    ...    ${att_port_3_gnb2_cell2_${tl}}    ${att_port_4_gnb2_cell2_${tl}}
    @{att_ports_gnb2_cell1}    Create List    ${att_port_1_gnb2_cell1_${tl}}    ${att_port_2_gnb2_cell1_${tl}}
    ...    ${att_port_3_gnb2_cell1_${tl}}    ${att_port_4_gnb2_cell1_${tl}}
    @{att_ports_enb_cell}    Run Keyword If    '${gnb_instance}'=='${gnb_id[0]}'
    ...    Create List    ${att_port_1_enb_cell_${tl}}

    ###create value list####
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    @{values_gnb2_cell2}    Create List    ${gnb2_cell2_value}    ${gnb2_cell2_value}    ${gnb2_cell2_value}    ${gnb2_cell2_value}
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}
    @{values_enb_cell}    Run Keyword If    '${gnb_instance}'=='${gnb_id[0]}'
    ...    Create List    ${enb_cell_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${att_port_1_gnb1_cell1_${tl}}    att_ipaddr=${att_ipaddr_gnb1_cell1_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell2}    values=${values_gnb2_cell2}
    ...    att_connection_port=${att_port_1_gnb2_cell2_${tl}}    att_ipaddr=${att_ipaddr_gnb2_cell2_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${att_port_1_gnb2_cell1_${tl}}    att_ipaddr=${att_ipaddr_gnb2_cell1_${tl}}
    Run Keyword If    '${gnb_instance}'=='${gnb_id[0]}'
    ...    Set the attenuation value    att_ports=${att_ports_enb_cell}    values=${values_enb_cell}
    ...    att_connection_port=${att_port_1_enb_cell_${tl}}    att_ipaddr=${att_ipaddr_enb_cell_${tl}}


Online modify NIDD on gnb
    [Arguments]    ${gnb_index}=${0}    ${Modify_Para_Online}='NULL'    ${Add_Para_Online}='NULL'
    ...    ${ParameterToDelete}='NULL'    ${Add_Mo_Online}='NULL'    ${Delete_Mo_Online}='NULL'
    Common Case TestLine Setup with singe BTS    gnb_index=${gnb_index}    ModifySCF_Aftercommission=True
    ...    Modify_Para_Online=${Modify_Para_Online}    Add_Para_Online=${Add_Para_Online}
    ...    ParameterToDelete=${ParameterToDelete}    Add_Mo_Online=${Add_Mo_Online}
    ...    Delete_Mo_Online=${Delete_Mo_Online}
    Wait until keyword succeeds    20 min    20s
        ...    Check the cells status on air    bts_host=${bts_host${gnb_index}}   connection=gnb${gnb_index}

Check the PM counter CB011016
    [Arguments]    ${counter_id}    ${dic_path}    ${value_min}    ${value_max}    ${gnb_index}=${0}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[${index}]}
        Should Be True    ${value_max} > ${counter_value[0]} > ${value_min}
    END
    [Teardown]    COAM Teardown gnb connections

Lock/Unlick LTE cell
    [Arguments]    ${value}=locked
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=${value}
    sleep    10s

Power UE Precondition
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    capatibility_index=${0}    reset_sol=none    detach_request=${true}
    run keyword if    '${gnb_instance}'=='${gnb_id[0]}'    Get all xiaomi11 pointer variable for 377
    ...    ELSE    Get all xiaomi11 pointer variable for 388

Get all xiaomi11 pointer variable for 377
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    940 1640
    Set Suite Variable    ${close_task}    540 2175
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    550 1700 550 1200
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    817 290
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960
    Set Suite Variable    ${start_call}    530 2260
    Set Suite Variable    ${stop_call}    540 2140
    Set Suite Variable    ${apn_muiltdrb}    36 850
    Set Suite Variable    ${apn_dxdata}    36 634

Get all xiaomi11 pointer variable for 388
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    1251 2208
    Set Suite Variable    ${close_task}    710 2766
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    1300 2700 1300 2700
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    1131 411
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960
    Set Suite Variable    ${start_call}    730 2990
    Set Suite Variable    ${stop_call}    712 2970
    Set Suite Variable    ${apn_muiltdrb}    142 1196
    Set Suite Variable    ${apn_dxdata}    142 886

Power UE Attach and Verify attach
    [Arguments]    ${4g_check}=False    ${gnb_index}=${0}
    unlock the screen and close all task    ue_index=${0}
     ${5Grach_ed}    power_ue.UE Attach    ue_type=xiaomi    ue_index=${0}    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=xiaomi    5Grach_ed=${5Grach_ed}    ue_index=${0}    gnb_index=${gnb_index}
    ...                       4G_check=${4g_check}    5Gstatus=PASS

unlock the screen and close all task
    [Documentation]   Check UE if need awake
    [Arguments]   ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}   ${connection}=cpc_${ue_index}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    csn.send_command   connection=${connection}
    ...   command=adb -s ${serial_number} shell dumpsys window | grep -E \"mAwake|isStatusBarKeyguard|mShowingLockscreen\"
    sleep   2s
    ${output}   csn.read_output   connection=${connection}
    Run Keyword If   ${output.lower().count('mawake=false')}>0
    ...   csn.send_command   command=adb -s ${serial_number} shell input keyevent 26   connection=${connection}
    sleep    1s
    csn.send_command   command=adb -s ${serial_number} shell input swipe 347 2514 715 400    connection=${connection}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3    connection=${connection}
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=${connection}
    sleep   4s
    #####Turn off all running tasks on the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=${connection}

Common UE teardown
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}

Get EnergySavingState
    [Arguments]    ${required_info}=energySavingState    ${status}=reducedEnergySaving    ${cell_index}=${3}    ${gnb_index}=${1}
    ${get_status}    get required cell info    required_info=${required_info}    cell_index=${cell_index}    gnb_index=${gnb_index}
    should be equal    ${get_status}    ${status}

Modify NIDD parameter online
    [Arguments]    ${parameters_to_update}    ${timeout}=${600}    ${gnb_index}=${1}
    Connect to gnb coam via ssl    gnb_index=${gnb_index}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update}    timeout=${timeout}
    sleep    5s
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections
