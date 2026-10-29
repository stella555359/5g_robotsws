*** Settings ***
Documentation     author: ming.shi & Zhang Yayun
...                 contact: ming.shi@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB008246
Library     DateTime
Library     taf.analyzer.pcap    WITH NAME    cap
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Library     taf.hw.rf_attenuator    WITH NAME    atten
Library     taf.config.testline    WITH NAME    testline
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.sbts.oam.coam.admin   WITH NAME    coam
Library     taf.pdu  WITH NAME   pdu
#Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008246/Resources/CB008246_keywords.py
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008246/Resources/get_pm_counters_from_compass.py
Library     get_pm_counters_from_compass.GetPmCounter    WITH NAME    GPC
Variables   testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008246/Resources/CB008246_variables.py
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008246/Resources/CB008246_common_keywords.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/get_counters_from_pm_file.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/capture_logs_via_gnb_logs_tool.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/stream_manager.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/eNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot

*** Variables ***
${scf_path}    /opt/workspace/CRT/Master/SCF_file/golden SCF/
${tl_scf_SBTS25R3_ENB_9999}    Trunk_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS25R2_ENB_9999}    Trunk_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS25R2_ENB_0000}    25R2_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS25R1_ENB_0000}    25R1_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS24R3_ENB_0000}    24R3_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS24R2_ENB_0000}    24R2_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS24R1_ENB_0000}    24R1_Configuration_scf_GNB1_CB008698.xml


${tl_scf2_SBTS25R3_ENB_9999}    Trunk_Configuration_scf_GNB2_CB008698.xml
${tl_scf2_SBTS25R2_ENB_9999}    Trunk_Configuration_scf_GNB2_CB008698.xml
${tl_scf2_SBTS25R2_ENB_0000}    25R2_Configuration_scf_GNB2_CB008698.xml
${tl_scf2_SBTS25R1_ENB_0000}    25R1_Configuration_scf_GNB2_CB008698.xml
${tl_scf2_SBTS24R3_ENB_0000}    24R3_Configuration_scf_GNB2_CB008698.xml
${tl_scf2_SBTS24R2_ENB_0000}    24R1_Configuration_scf_GNB2_CB008698.xml
${tl_scf2_SBTS24R1_ENB_0000}    24R1_Configuration_scf_GNB2_CB008698.xml


#${tl_scf_dir_path}    /opt/workspace/CRT/Master/SCF_file/golden SCF/
#${tl_scf_file_name1}    Configuration_scf_GNB1_CB008698.xml
#${tl_scf_file_name2}    Configuration_scf_GNB2_CB008698.xml
${gnb_path}    /tmp/
${connection}    gnb
${epc_log_path}    /tmp/
${tshark_path}      /usr/bin/tshark
${att_port_1_HBTE}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_2_HBTE}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_3_HBTE}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${att_port_4_HBTE}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${att_port_5_HBTE}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_6_HBTE}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_7_HBTE}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}
${att_port_8_HBTE}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no}
${att_ipaddr_HBTE}    ${tl.attenuator[0].ip_addr}
${asik_addr}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${asik_username}    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${asik_password}     ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${asik2_addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
${asik2_username}    ${tl.gnbs[1].cu.oam_ssh_connection_details.username}
${asik2_password}     ${tl.gnbs[1].cu.oam_ssh_connection_details.password}
${enb_address}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${enb_username}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
${enb_password}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
${vendor}                    ${tl.attenuator[0].vendor}
${SN}                       ${tl.ues[0].serial_number}
${ue_type}    ${tl.ues[2].capabilities[2]}
${ue_type1}    ${tl.ues[0].capabilities[2]}
${enb_instance}     ${tl.enbs[0].instance_id}
#@{gnb_list}    ${0}    ${1}
@{gnb_list}    ${0}
@{gnb_ips}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
@{diffTL_enb_ID}    36721    38221    911
#${DL_PORT}                  ${tl.ues[2].iperf_details.ssh_connection_details.port}
#${UL_PORT}                  ${tl.ues[2].iperf_details.port}
${UL_PORT}                  ${tl.ues[2].iperf_details.ssh_connection_details.port}
${DL_PORT}                  ${tl.ues[2].iperf_details.port}
@{PA_list}    ${0}    ${127}    ${10}    ${15}    ${20}    ${25}    ${30}    ${35}    ${40}    ${45}    ${50}
@{apn_location}    168 681    168 873    146 717    140 513    93 941    93 743    142 912    168 1073
${command_template_with_Y}    {tshark_path} -r {pcap_file} -Y  \"ngap or e1ap or f1ap or xnap or s1ap or x2ap\"  -T pdml
@{branch}    SBTS24R2_ENB_9999    SBTS24R2_ENB_0000    SBTS25R1_ENB_9999

${zzmdrb1_apn_name}    ${tl.ues[0].pdn[7]}
${wap2_apn_name}    ${tl.ues[0].pdn[0]}
${zzmdrb2_apn_name}    ${tl.ues[0].pdn[5]}
${zmdrb2_apn_name}    ${tl.ues[0].pdn[6]}
${ui_version}    emui 10.1.0


${sys_logs_path}    /tmp/btslog2/
${UTE_logs_path}    /home/ute/ERR_WRN_logs/
${testline_name}          null
${base_file}    None
@{filter_list}    None

${Test_PC_IP}          ${tl.test_pc.default_ssh_connection_details.addr}
${Test_PC_username}    ${tl.test_pc.default_ssh_connection_details.username}
${Test_PC_password}    ${tl.test_pc.default_ssh_connection_details.password}

${MRBTS_ID}    ${tl.gnbs[0].instance_id}

${case_logs_path}    /opt/workspace/CRT/Master/Case_Logs/
${CB008246_72a_to_72e_json_file_name}    CB008246_72a_to_72e.json

*** Keywords ***
####CB008246 common *** keywords ***
QCM UE setup VONR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+${phone_number}
    ...    connection=cygwin${ue_index}
    sleep   1s
    csn.disconnect      connection=cygwin${ue_index}

QCM UE hang up VONR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Wait Until Keyword Succeeds    3x    30sec
    ...    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cpc_${ue_index}
    sleep      5s
    csn.disconnect      connection=cpc_${ue_index}

QCM UE hang up EMC call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    csn.send_command    command=adb -s ${serial_number} shell input tap 538 2067    connection=cpc_${ue_index}
    sleep      5s
    csn.disconnect      connection=cpc_${ue_index}

QCM UE setup EMC call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=911
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####make EMC call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.DIAL -d tel:${phone_number}
    ...    connection=cpc_${ue_index}
    sleep    5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 66    connection=cpc_${ue_index}
    csn.disconnect      connection=cpc_${ue_index}

QCM UE Recover Detach
    [Arguments]     ${ue_index}=${0}    ${status}=${0}    ${ue_type}=${ue_type}
    QCM UE hang up VONR call    ue_index=${ue_index}
    check voice call status    ue_index=${ue_index}    status=${status}
    UE.UE Detach     ue_type=${ue_type}     ue_index=${ue_index}

Start only DL traffic and check tput
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${dl_throughput}=${Send_Tput_DL}    ${cellid}=${1}    ${gnb_index}=${0}
    ...    ${direction}=DL    ${tput_dl_cell}=${expected_tput_dl}    ${dl_port}=${DL_PORT}    ${duration}=${600}
    Power UE Start DL traffic    ue_index=${ue_index}    ue_type=${ue_type}    dl_throughput=${dl_throughput}    duration=${duration}
    ...    dl_port=${dl_port}
    sleep    15s
    ${nrcellid_cell}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    ${nrcellid_cell}    Create list  ${nrcellid_cell}
    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}    direction=${direction}    list_of_cell_ids=${nrcellid_cell}
    ...    expect_throughput=${tput_dl_cell}    gnb_index=${gnb_index}

Start only UL traffic and check tput
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${ul_throughput}=${Send_Tput_UL}    ${cellid}=${1}    ${gnb_index}=${0}
    ...    ${direction}=UL    ${tput_ul_cell}=${expected_tput_ul}    ${ul_port}=${UL_PORT}    ${duration}=${600}
    ...    ${iperf_type}=via_app
    Power UE Start UL traffic    ue_index=${ue_index}    ue_type=${ue_type}    ul_throughput=${ul_throughput}    duration=${duration}
    ...    ul_port=${ul_port}    iperf_type=${iperf_type}
    sleep    15s
    ${nrcellid_cell}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    ${nrcellid_cell}    Create list  ${nrcellid_cell}
    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}    direction=${direction}    list_of_cell_ids=${nrcellid_cell}
    ...    expect_throughput=${tput_ul_cell}    gnb_index=${gnb_index}

Stop DL or UL traffic
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${direction}=DL     ${protocol}=udp    ${iperf_port}=default
    power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}   direction=${direction}    protocol=${protocol}    iperf_port=${iperf_port}

Stop DL or UL IMS traffic
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${direction}=DL     ${protocol}=udp    ${iperf_port}=default
    power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}   direction=${direction}    protocol=${protocol}    iperf_port=${iperf_port}

Start DL traffic and check tput
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${dl_throughput}=${Send_Tput_DL}    ${cellid}=${1}    ${gnb_index}=${0}
    ...    ${direction}=DL    ${tput_dl_cell}=${expected_tput_dl}     ${protocol}=udp    ${dl_port}=${DL_PORT}    ${duration}=${600}
    Power UE Start DL traffic    ue_index=${ue_index}    ue_type=${ue_type}    dl_throughput=${dl_throughput}    duration=${duration}
    sleep    15s
    ${nrcellid_cell}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    ${nrcellid_cell}    Create list  ${nrcellid_cell}
    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}    direction=${direction}    list_of_cell_ids=${nrcellid_cell}
    ...    expect_throughput=${tput_dl_cell}    gnb_index=${gnb_index}
    power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}   direction=${direction}    protocol=${protocol}    iperf_port=${dl_port}

Start UL traffic and check tput
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${ul_throughput}=${Send_Tput_UL}    ${cellid}=${1}    ${gnb_index}=${0}
    ...    ${direction}=UL    ${tput_ul_cell}=${expected_tput_ul}     ${protocol}=udp    ${ul_port}=${UL_PORT}    ${duration}=${600}
    Power UE Start UL traffic    ue_index=${ue_index}    ue_type=${ue_type}    ul_throughput=${ul_throughput}    duration=${duration}
    sleep    15s
    ${nrcellid_cell}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    ${nrcellid_cell}    Create list  ${nrcellid_cell}
    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}    direction=${direction}    list_of_cell_ids=${nrcellid_cell}
    ...    expect_throughput=${tput_ul_cell}    gnb_index=${gnb_index}
    power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}   direction=${direction}    protocol=${protocol}    iperf_port=${ul_port}

Start UE DLUL UDP traffic and check tput
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${ul_throughput}=${ul_throughput}    ${cellid}=${1}    ${gnb_index}=${0}
    ...    ${tput_ul_cell}=${tput_ul_cell}     ${dl_throughput}=${dl_throughput}    ${tput_dl_cell}=${tput_dl_cell}
    ...    ${dl_port}=${DL_PORT}    ${ul_port}=${UL_PORT}    ${duration}=${600}
    Start UE DLUL UDP traffic    ue_index=${ue_index}    ue_type=${ue_type}    dl_port=${dl_port}
    ...    dl_throughput=${dl_throughput}    ul_throughput=${ul_throughput}    duration=${duration}
    sleep    15s
    ${nrcellid_cell}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    @{nrcellid_cells}    Create list  ${nrcellid_cell}
    Check Bi direction throughput    ue_index=${ue_index}    ue_type=${ue_type}    ultarget_throughput=${tput_ul_cell}
    ...    dltarget_throughput=${tput_dl_cell}    list_of_cell_ids=${nrcellid_cells}    gnb_index=${gnb_index}
    sleep    5s
    Stop UL DL data transfer    ue_index=${ue_index}    ue_type=${ue_type}    dl_port=${dl_port}    ul_port=${ul_port}

Start UE DLUL UDP traffic
    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_type}    ${dl_throughput}=${dl_throughput}    ${ul_throughput}=${ul_throughput}
    ...    ${dl_port}=${dl_port}    ${duration}=600
    Power UE Start DL traffic    ue_index=${ue_index}    ue_type=${ue_type}    dl_throughput=${dl_throughput}
    ...                          dl_port=${dl_port}    duration=${duration}
    Power UE Start UL traffic    ue_index=${ue_index}    ue_type=${ue_type}    ul_throughput=${ul_throughput}    duration=${duration}

###BTS keyword###
Setup for Env cell on-air for 2 gnb
    [Arguments]    ${is_commission}=True    ${is_commission_for_second_gnb}=True    ${tl_scf_file_name}=${tl_scf_file_name1}
    Common Case TestLine Setup    is_commission=${is_commission}    is_commission_for_second_gnb=${is_commission_for_second_gnb}
    ...    scf_path=${tl_scf_dir_path}    golden_scf_name=${tl_scf_file_name}    golden_scf_name_gnb2=${tl_scf_file_name2}
#    ${rc}    ${output}=    run and return rc and output    cd /opt/workspace/Tool/;./modify_numpy_version.sh

Setup for Env cell on-air
    [Arguments]    ${gnb_index}=${0}    ${tl_scf_file_name}=${tl_scf_file_name}
    Prepare the gNB cells onair status    gnb_index=${gnb_index}    tl_scf_file_name=${tl_scf_file_name}
    RUN KEYWORD IF    '${cell_status}'=='FAIL'    Prepare the gNB cells onair status
    should be equal    '${cell_status}'    'True'

Lock cell online coam
    [Arguments]    ${gnb_index}=${0}    ${cell_index}=${1}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    coam.lock
    ...    dist_name=MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRCELL-${cell_index}
    ...    connection=GNB_OAM    timeout=60
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Unlock cell online coam
    [Arguments]    ${gnb_index}=${0}    ${cell_index}=${1}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    coam.unlock
    ...    dist_name=MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRCELL-${cell_index}
    ...    connection=GNB_OAM    timeout=60
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Online add parmeters
    [Arguments]    ${parameters_to_update}    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM add several parameters via rest api    parameters_to_add_via_api=${parameters_to_update}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

online add list parameter
    [Arguments]    ${gnb_index}=${0}    ${skip_parameter_relation_errors}=True
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    online operate list parameter
    ...    parameters=${LIST_PARAM_ADD_gnb1_04444966}    operation=update    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    [Teardown]    COAM Teardown gnb connections

online update list parameter model
    [Arguments]    ${parameters}    ${gnb_index}=${0}    ${skip_parameter_relation_errors}=False
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    online operate list parameter
    ...    parameters=${parameters}    operation=update    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    [Teardown]    COAM Teardown gnb connections

online recover delete and add list parameter
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    online operate list parameter    parameters=${LIST_PARAM_RECOVER_DELETE_gnb1_04444966}    operation=delete
    COAM Wait for gnb ready and cell setup
    online operate list parameter    parameters=${LIST_PARAM_RECOVER_gnb1_04444966}    operation=update
    [Teardown]    COAM Teardown gnb connections

online operate list parameter
    [Documentation]    This keyword is used to operate list parameter from the gNB
    ...    Author: ming.shi@nokia-sbell.com
    [Arguments]
    ...    ${parameters}
    ...    ${operation}=update
    ...    ${skip_parameter_relation_errors}=True
    ...    ${timeout}=${300}
    ...    ${connection}=GNB_OAM
    coam.perform_parameter_recommissioning
    ...    dist_name=${parameters}[dist_name]    parameter=${parameters}[parameter]    operation=${operation}
    ...    value=${parameters}[value]    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    timeout=${timeout}    connection=${connection}

get_cell_id_multi_cell
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ${cell_list}=    coam.get_cell_list    connection=GNB_OAM
#    FOR     ${cell}    IN    @{cell_list['cells']['nr']}
#        @{cell_ids}=    set variable    ${cell['physicalCellId']}
#    END
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

get BTS parameter value
    [Arguments]    ${class_name}    ${Abbreviation}    ${gnb_index}=${0}    #${distname_id}=${1}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    sleep    2s
    @{MOs_a}    coam.get_managed_objects    class_name=${class_name}_A    connection=GNB_OAM
#    ${MO_ID}=    get_corresponding_mo_id    parameter_list=${MOs_a}    distname_id=${distname_id}
    &{dict_Abbreviation}     coam.get_parameters    dist_name=${MOs_a[${0}]['distName']}
    ...    pattern=${Abbreviation}    connection=GNB_OAM
    sleep    5
    [Return]    ${dict_Abbreviation['${Abbreviation}']}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

get parameter value
    [Arguments]    ${class_name}    ${Abbreviation}    ${gnb_index}=${0}    ${distname_id}=${1}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    sleep    2s
    @{MOs_a}    coam.get_managed_objects    class_name=${class_name}_A    connection=GNB_OAM
    ${MO_ID}=    get_corresponding_mo_id    parameter_list=${MOs_a}    distname_id=${distname_id}
    &{dict_Abbreviation}     coam.get_parameters    dist_name=${MOs_a[${MO_ID}]['distName']}
    ...    pattern=${Abbreviation}    connection=GNB_OAM
    sleep    5
    [Return]    ${dict_Abbreviation['${Abbreviation}']}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

check Redirect status
    [Arguments]    ${gnb_index}=${0}    ${distname_id}=${1}
    ${actRedirect_status}=    get BTS parameter value    class_name=NRBTS    Abbreviation=actRedirect    gnb_index=${gnb_index}
    ...    distname_id=${distname_id}
    Set Test Variable    ${actRedirect_status}    ${actRedirect_status}

get nrCellIdentity value
    [Arguments]    ${gnb_index}=${0}    ${distname_id}=${0}
    ${nrCellIdentity_value}=    get parameter value    class_name=NRCELL    Abbreviation=nrCellIdentity
    ...    gnb_index=${gnb_index}    distname_id=${distname_id}
    Set Test Variable    ${nrCellIdentity_value}    ${nrCellIdentity_value}

get required value of parameter
    [Arguments]    ${Abbreviation}    ${class_name}=NRCELL    ${gnb_index}=${0}    ${distname_id}=${0}
    ${parameter_value}=    get parameter value    class_name=${class_name}    Abbreviation=${Abbreviation}
    ...    gnb_index=${gnb_index}    distname_id=${distname_id}
    [Return]    ${parameter_value}

check cell on-air status
    [Arguments]    ${gnb_index}=${0}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}    connection=${connection}
    Wait until keyword succeeds    5m    10s    COAM Check GNB cell on air    connection=${connection}
    [Teardown]    COAM Teardown gnb connections    connection=${connection}

###enb parameter
Modify parameter on enb
    [Arguments]    ${dist_name}=${enb_dist_name}[0]    ${parameter}=${enb_para}[0]    ${value}=${enb_value}[0]
    Modify the enblte parameter    dist_name=${dist_name}    parameter=${parameter}    value=${value}

set enb cell
    [Arguments]    ${dist_name}=${enb_dist_name}[0]    ${parameter}=${enb_para}[0]    ${value}=${enb_value}[0]  #${dist_name1}=${enb_dist_name2}[0]
    Modify parameter on enb    dist_name=${dist_name}    parameter=${parameter}    value=${value}

set enb MME IP
    [Arguments]    ${dist_name}=${enb_dist_name}[1]    ${parameter}=${enb_para}[1]    ${value}=${enb_value}[2]
    Modify parameter on enb    dist_name=${dist_name}    parameter=${parameter}    value=${value}

recover enb mme ip
    [Arguments]    ${enb_index}=${0}    ${connection}=enblte    ${timeout}=${300}
    Connect to eNB via ssl    enb_index=${enb_index}    connection=${connection}
    coam.perform_parameter_recommissioning
    ...    dist_name=${PARAM_8246_recover_enb1_K_012}[0][dist_name]
    ...    parameter=${PARAM_8246_recover_enb1_K_012}[0][parameter]
    ...    operation=update
    ...    value=${PARAM_8246_recover_enb1_K_012}[0][value]
    ...    skip_parameter_relation_errors=False
    ...    timeout=${timeout}
    ...    connection=${connection}
    [Teardown]    enblte.teardown    connection=${connection}

###UE keywordWords###
Step1: UE attach
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${4G_check}=False    ${gnb_index}=${0}
    Check UE device exist    ue_index=${ue_index}
    Huawei UE setup    ue_type=${ue_type}    ue_index=${ue_index}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${ue_index}    4G_check=${4G_check}    gnb_index=${gnb_index}

Step2: UE setup VoNR call
    [Arguments]    ${ue_index}=${0}     ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    Make a VoNR call(+6688)    ue_index=${ue_index}    serial_number=${serial_number}    phone_number=${phone_number}

Step2: UE setup VoNR call on SDX70
    [Arguments]    ${ue_index}=${0}     ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    Make a VoNR call(+6688) on SDX70    ue_index=${ue_index}    serial_number=${serial_number}    phone_number=${phone_number}

Step2: UE setup VoNR call on SDX80
    [Arguments]    ${ue_index}=${0}     ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    Make a VoNR call(+6688) on SDX80    ue_index=${ue_index}    serial_number=${serial_number}    phone_number=${phone_number}

Step2: UE setup EMC call
    [Arguments]    ${ue_index}=${0}     ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=911
    Make EMC call on UE    ue_index=${ue_index}    serial_number=${serial_number}    phone_number=${phone_number}

Step3: UE hang up VoNR call
    [Arguments]    ${ue_index}=${0}
    hang up VoNR call    ue_index=${ue_index}

Step3: UE hang up EMC call
    [Arguments]    ${ue_index}=${0}
    hang up EMC call    ue_index=${ue_index}

Step4: Detach UE
    [Arguments]    ${ue_type}    ${ue_index}=${0}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    UE.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Common UE parameter setup
    [Arguments]  ${ue_index}=${0}
#    set suite variable    ${ue_type}    ${tl.ues[${ue_index}].capabilities[1]}
    set suite variable    ${serial_number}    ${tl.ues[${ue_index}].serial_number}
#    Setup Variable for attenuator
#    Setup Variable for cellID

Make a VoNR call(+6688)
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####Samsung S21 WA to click time cancel
    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cygwin${ue_index}
    sleep    2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+${phone_number}
    ...    connection=cygwin${ue_index}
    sleep   1s
    csn.disconnect      connection=cygwin${ue_index}

Make a VoNR call(+6688) on SDX70
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800    connection=cygwin${ue_index}
    sleep    2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+${phone_number}
    ...    connection=cygwin${ue_index}
    sleep   1s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

Make a VoNR call(+6688) on SDX80
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800    connection=cygwin${ue_index}
    sleep    2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+${phone_number}
    ...    connection=cygwin${ue_index}
    sleep   1s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

hang up VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}
    sleep   1s
    csn.disconnect      connection=cygwin${ue_index}

Make EMC call on UE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=911
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Samsung S21 WA to click time cancel
    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cpc_${ue_index}
    sleep    2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:${phone_number}
    ...    connection=cpc_${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 538 1959
    ...    connection=cpc_${ue_index}
    csn.disconnect      connection=cpc_${ue_index}

hang up EMC call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Samsung S21 WA to click time cancel
    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cpc_${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 485 37    connection=cpc_${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 538 1959
    ...    connection=cpc_${ue_index}
    sleep    5s
    csn.disconnect      connection=cpc_${ue_index}

Set automatic rotation
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${commond}=shell content insert --uri content://settings/system --bind name:s:accelerometer_rotation --bind value:i:
    ...    ${rotation_value}=0
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} ${commond}${rotation_value}
    ...    connection=cygwin${ue_index}
    sleep    5s

Setup UE data status
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${status}=enable
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell svc data ${status}    connection=cygwin${ue_index}
    sleep   2s
    csn.disconnect      connection=cygwin${ue_index}

check voice call status
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${status}=${2}
    Wait Until Keyword Succeeds    3x    30sec
    ...    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    ##### check voice call enable  #####
    ##### 0: the phone is in standby state. 1: the call is not answered. 2: the phone is busy  #####
    csn.send_command    command=adb -s ${serial_number} shell dumpsys telephony.registry |grep mCallState
    ...    connection=cpc_${ue_index}
    sleep   2s
    ${result} =    csn.read output    connection=cpc_${ue_index}
    sleep    1s
    csn.disconnect      connection=cpc_${ue_index}
    should contain    ${result}    mCallState=${status}

choice required APN on UE
    [Arguments]    ${usedapn}    ${ue_type}    ${ue_index}=${0}    #${serial_number}=${tl.ues[${ue_index}].serial_number}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    set apn to wap2    usedapn=${usedapn}    ue_index=${ue_index}
    make airplane mode to enable    ue_index=${ue_index}

make WA with Samsung S21
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   2s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep   4s
    #####Samsung S21 WA to click time cancel
    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cygwin
    sleep    2s
    [Teardown]    csn.disconnect    connection=cygwin

UE attach with new method
    [Arguments]    ${ue_index}=${0}    ${gnb_index}=${0}
    ...    ${distname_id}=${0}    #${serial_number}=${tl.ues[${ue_index}].serial_number}
    Wait Until Keyword Succeeds    3x    10s    make sure airplane mode disable    ue_index=${ue_index}
    UE attach verify with adb command    ue_index=${ue_index}    gnb_index=${gnb_index}    distname_id=${distname_id}

UE attach verify with adb command
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${gnb_index}=${0}
    ...    ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${username}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${password}=${tl.ues[${ue_index}].ssh_connection_details.password}    ${distname_id}=${0}
    ${cell_id}=    get_attached_nr_cell_id_on_ue
    ...    host=${hostname}    username=${username}    password=${password}    sn=${serial_number}
    get nrCellIdentity value    gnb_index=${gnb_index}    distname_id=${distname_id}
    ${reslut}=    Run Keyword And Return Status    Should Be Equal As Strings    ${nrCellIdentity_value}    ${cell_id}
    Run Keyword If    '${reslut}'=='${True}'    Log to console    INFO:5G UE setup successfully.
    ...    ELSE IF    '${reslut}'=='${False}'    Fail    5G UE setup not successfully.

change UE 5G mode
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${system_and_udpate}=634 1984
    ...    ${swipe_indevelop}=500 2050 500 1800    ${develop_option}=500 1590    ${mode_tap}=500 2050    ${mode_selection}=SA
    ...    ${SA_tap}=500 1816    ${NSA_tap}=500 1667    ${USB_connection_mode_cancel}=584 2143
    Huawei UE setup    ue_type=${ue_type}    ue_index=${ue_index}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${passed}'=='${True}'
        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep    2s
    #####Press the Home button to open the screen#####
    Run Keyword and Ignore Error   Awake UE if Sleepy   ue_index=${ue_index}   serial_number=${serial_number}    connection=cygwin
    sleep    2s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep    2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=cygwin
    sleep    2s
    #####Turn off all running tasks on the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=cygwin
    sleep    4s
    csn.send_command    command=adb -s ${serial_number} shell am start com.android.settings    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${system_and_udpate}    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${develop_option}    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell dumpsys window | grep mCurrentFocus    connection=cygwin
    sleep   2s
    ${current_window} =    csn.read output    connection=cygwin
    Should Contain    ${current_window}    DevelopmentSettingsActivity
    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe_indevelop}    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${mode_tap}    connection=cygwin
    sleep    2s
    run keyword if    '${mode_selection}'=='SA'
    ...    csn.send_command    command=adb -s ${serial_number} shell input tap ${SA_tap}    connection=cygwin
    ...    ELSE IF    '${mode_selection}'=='NSA'
    ...    csn.send_command    command=adb -s ${serial_number} shell input tap ${NSA_tap}    connection=cygwin
    sleep    10s
    Check UE device exist    ue_index=${ue_index}
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command    command=adb -s ${serial_number} shell input tap ${USB_connection_mode_cancel}    connection=cygwin
    sleep    2s
    csn.send_command
    ...    command=adb -s ${serial_number} shell dumpsys telephony.registry | grep mServiceState    connection=cygwin
    ${nsaState}=    csn.read output    connection=cygwin
    ${regexp_result}=    find_string    string=${nsaState}    pattern=nsaState=\\d
    run keyword if    '${mode_selection}'=='SA'
    ...    Should Be Equal    ${regexp_result}[1]    nsaState=0
    ...    ELSE IF    '${mode_selection}'=='NSA'
    ...    Should Not Be Equal    ${regexp_result}[1]    nsaState=0
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    Wait Until Keyword Succeeds    3x    30s    make sure airplane mode enable    ue_index=${ue_index}
#    Connect to control pc via cygwin    ue_index=${ue_index}
#    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
#    ...    close_task=${close_task}
#    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
#    Should Be Equal    ${passed}    ${True}
    [Teardown]    Run Keyword and Ignore Error   csn.disconnect      connection=cygwin

make sure airplane mode enable
    [Arguments]    ${ue_index}=${0}    #${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${passed}'=='${False}'
        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    Should Be Equal    ${passed}    ${True}

make sure airplane mode disable
    [Arguments]    ${ue_index}=${0}    #${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${passed}'=='${True}'
        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    Should Be Equal    ${passed}    ${False}

check hanging resource for per UE on gnb
    [Arguments]    ${gnb_ips}    ${UE_Type_Index}=${2}
    ${ue_num}    get length    ${tl.ues}
#    set suite variable    ${ue_num}
    FOR  ${ue_index}    IN RANGE    ${ue_num}
        power_ue.Prepare UE    ue_type=${tl.ues[${ue_index}].capabilities[${UE_Type_Index}]}    ue_index=${ue_index}
        make airplane mode to enable    ue_index=${ue_index}
        ${passed} =    Check airplane mode status on    ue_index=${ue_index}
        Should Be Equal    ${passed}    ${True}
    END
    Check hanging resource for gnb    gnb_ips=${gnb_ips}

ue execute reboot via adb command
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    csn.send_command    command=adb -s ${serial_number} reboot    connection=cpc_${ue_index}
    sleep    5s
    [Teardown]    csn.disconnect      connection=cpc_${ue_index}

###check wireshark log###
Check EPSFB message on gnb
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    alias=test6
    ${Code26_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log    check PDUSessionResourceModifyRequest
    ${Code26_0_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code26_0}    pcap_parser=test6
    should be equal    ${Code26_0_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code26_0}    pcap_parser=test6
    ${ngap_fiveQI}=    get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
    Should Be Equal    ${ngap_fiveQI[0]}    1

    ${Code26_1} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log    check PDUSessionResourceModifyResponse
    ${Code26_1_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code26_1}    pcap_parser=test6
    should be equal    ${Code26_1_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code26_1}    pcap_parser=test6
    ${ngap_radioNetwork} =    get_field_value_by_xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${ngap_radioNetwork[0]}    36

    ${Code42} =    Catenate    ngap.procedureCode == 42
    Log    check UEContextReleaseRequest
    ${Code42_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code42}    pcap_parser=test6
    should be equal    ${Code42_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code42}    pcap_parser=test6
    ${ngap_radioNetwork} =    get_field_value_by_xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Contain    ${ngap_radioNetwork}    41
    ${Code41} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 41
    Log    check UEContextReleaseComplete
    ${Code41_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code41}    pcap_parser=test6
    should be equal    ${Code41_status}    ${True}

Check EPSFB mesage on enb
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    alias=test6
    ${Code0_12} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 12
    Log    check InitialUEMessage
    ${Code0_12_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_12}    pcap_parser=test6
    should be equal    ${Code0_12_status}    ${True}

    ${Code0_9} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 9
    Log    check InitialContextSetupRequest
    ${Code0_9_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_9}    pcap_parser=test6
    should be equal    ${Code0_9_status}    ${True}

    ${Code0_5} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 5 and nas_eps.nas_msg_esm_type == 0xc5
    Log    check E_RABSetupRequest
    ${Code0_5_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_5}    pcap_parser=test6
    should be equal    ${Code0_5_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code0_5}    pcap_parser=test6

    ${Code0_13_c6} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 13 and nas_eps.nas_msg_esm_type == 0xc6
    Log    check UplinkNASTransport
    ${Code0_13_c6_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression     filter_expression=${Code0_13_c6}    pcap_parser=test6
    should be equal    ${Code0_13_c6_status}    ${True}

    ${Code0_7} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 7
    Log    check E_RABReleaseCommand
    ${Code0_7_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_7}    pcap_parser=test6
    should be equal    ${Code0_7_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code0_7}    pcap_parser=test6
    ${s1ap_nas} =    get_field_value_by_xpath    xpath=.//s1ap.nas    pcap_parser=test6
    Should Be Equal    ${s1ap_nas[0]}    0

    ${Code0_13_ce} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 13 and nas_eps.nas_msg_esm_type == 0xce
    Log    check UplinkNASTransport
    ${Code0_13_ce_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_13_ce}    pcap_parser=test6
    should be equal    ${Code0_13_ce_status}    ${True}

Check EMC fallback message on gnb
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    alias=test6
    ${Code26_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log    check PDUSessionResourceModifyRequest
    ${Code26_0_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code26_0}    pcap_parser=test6
    should be equal    ${Code26_0_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code26_0}    pcap_parser=test6
    ${ngap_fiveQI}=    get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
    Should Be Equal    ${ngap_fiveQI[0]}    1

    ${Code26_1} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log    check PDUSessionResourceModifyResponse
    ${Code26_1_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code26_1}    pcap_parser=test6
    should be equal    ${Code26_1_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code26_1}    pcap_parser=test6
    ${ngap_radioNetwork} =    get_field_value_by_xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${ngap_radioNetwork[0]}    36

    ${Code42} =    Catenate    ngap.procedureCode == 42
    Log    check UEContextReleaseRequest
    ${Code42_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code42}    pcap_parser=test6
    should be equal    ${Code42_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code42}    pcap_parser=test6
    ${ngap_radioNetwork} =    get_field_value_by_xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Contain    ${ngap_radioNetwork}    41
    ${Code41} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 41
    Log    check UEContextReleaseComplete
    ${Code41_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code41}    pcap_parser=test6
    should be equal    ${Code41_status}    ${True}

Check EMC fallback message on enb
    [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    alias=test6
    ${Code0_12} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 12
    Log    check InitialUEMessage
    ${Code0_12_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_12}    pcap_parser=test6
    should be equal    ${Code0_12_status}    ${True}

    ${Code0_9} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 9
    Log    check InitialContextSetupRequest
    ${Code0_9_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_9}    pcap_parser=test6
    should be equal    ${Code0_9_status}    ${True}

    ${Code0_5} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 5 and nas_eps.nas_msg_esm_type == 0xc5
    Log    check E_RABSetupRequest
    ${Code0_5_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_5}    pcap_parser=test6
    should be equal    ${Code0_5_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code0_5}    pcap_parser=test6

    ${Code0_13_c6} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 13 and nas_eps.nas_msg_esm_type == 0xc6
    Log    check UplinkNASTransport
    ${Code0_13_c6_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression     filter_expression=${Code0_13_c6}    pcap_parser=test6
    should be equal    ${Code0_13_c6_status}    ${True}

    ${Code0_7} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 7
    Log    check E_RABReleaseCommand
    ${Code0_7_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_7}    pcap_parser=test6
    should be equal    ${Code0_7_status}    ${True}
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code0_7}    pcap_parser=test6
    ${s1ap_nas} =    get_field_value_by_xpath    xpath=.//s1ap.nas    pcap_parser=test6
    Should Be Equal    ${s1ap_nas[0]}    0

    ${Code0_13_ce} =    Catenate    s1ap.S1AP_PDU == 0 and s1ap.procedureCode == 13 and nas_eps.nas_msg_esm_type == 0xce
    Log    check UplinkNASTransport
    ${Code0_13_ce_status} =    run_keyword_and_return_status
    ...    filter_packets_by_expression    filter_expression=${Code0_13_ce}    pcap_parser=test6
    should be equal    ${Code0_13_ce_status}    ${True}

Get RAN-UE-NGAP-ID message
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ####InitialUEMessage, Registration request, Registration request
    ${Registration_request}=     Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 15
    ${Registration_request_packets}=    cap.filter_packets_by_expression    filter_expression=${Registration_request}
    ${RAN_UE_NGAP_ID}=     cap.get_field_value_by_xpath    pdml_list=${Registration_request_packets}
    ...                                                xpath=.//ngap.RAN_UE_NGAP_ID
    [Return]    ${RAN_UE_NGAP_ID}[0]

Get HO-RAN-UE-NGAP-ID message
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ####gnb1 PathSwitchRequest
    ${PathSwitch_request}=     Catenate    ngap.procedureCode == 25 and ngap.NGAP_PDU == 0
    ${PathSwitch_request_packets}=    cap.filter_packets_by_expression    filter_expression=${PathSwitch_request}
    ${RAN_UE_NGAP_ID}=     cap.get_field_value_by_xpath    pdml_list=${PathSwitch_request_packets}
    ...                                                xpath=.//ngap.RAN_UE_NGAP_ID
    [Return]    ${RAN_UE_NGAP_ID}[0]

Get NGHO-RAN-UE-NGAP-ID message
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ####gnb1 HandoverRequestAckknowledge
    ${HandoverRequestAckknowledge}=     Catenate    ngap.procedureCode == 13 and ngap.NGAP_PDU == 1
    ${HandoverRequestAckknowledge_packets}=    cap.filter_packets_by_expression    filter_expression=${HandoverRequestAckknowledge}
    ${RAN_UE_NGAP_ID}=     cap.get_field_value_by_xpath    pdml_list=${HandoverRequestAckknowledge_packets}
    ...                                                xpath=.//ngap.RAN_UE_NGAP_ID
    [Return]    ${RAN_UE_NGAP_ID}[0]

Get SgNB_UE_X2AP_ID message
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ####SgNBAdditionRequestAcknowledge, RRC Reconfiguration
    ${SgNBAdditionRequestAcknowledge}=     Catenate    x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 27
    ${SgNBAdditionRequestAcknowledge_packets}=    cap.filter_packets_by_expression    filter_expression=${SgNBAdditionRequestAcknowledge}
    ${SgNB_UE_X2AP_ID}=     cap.get_field_value_by_xpath    pdml_list=${SgNBAdditionRequestAcknowledge_packets}
    ...                                                xpath=.//x2ap.SgNB_UE_X2AP_ID
    [Return]    ${SgNB_UE_X2AP_ID}[0]

Get drb id with attach
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ${BCSR_filter}=    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 8
    Log To Console    BearerContextSetupRequest
    ${BCSR_packets}=    cap.filter_packets_by_expression    filter_expression=${BCSR_filter}
    ${e1ap_dRB_ID_1}=     cap.get_field_value_by_xpath    pdml_list=${BCSR_packets}
    ...                                                xpath=.//e1ap.dRB_ID
    ${BCMR_filter}=    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 9
    Log To Console    BearerContextModificationRequest
    ${BCMR_packets}=    cap.filter_packets_by_expression    filter_expression=${BCMR_filter}
    ${e1ap_dRB_ID_2}=     cap.get_field_value_by_xpath    pdml_list=${BCMR_packets}
    ...                                                xpath=.//e1ap.dRB_ID
    ${id_list}=    Combine Lists    ${e1ap_dRB_ID_1}    ${e1ap_dRB_ID_2}
    ${drb_id_list}=    Remove Duplicates    ${id_list}
    [Return]    ${drb_id_list}

Get fiveqi id with attach
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ${ICSR_filter}=    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 14
    Log To Console    InitialContextSetupRequest
    ${ICSR_packets}=    cap.filter_packets_by_expression    filter_expression=${ICSR_filter}
    ${ngap_fiveQI_1}=     cap.get_field_value_by_xpath    pdml_list=${ICSR_packets}
    ...                                                xpath=.//ngap.fiveQI
    ${PSRSR_filter}=    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 29
    Log To Console    PDUSessionResourceSetupRequest
    ${PSRSR_packets}=    cap.filter_packets_by_expression    filter_expression=${PSRSR_filter}
    ${ngap_fiveQI_2}=     cap.get_field_value_by_xpath    pdml_list=${PSRSR_packets}
    ...                                                xpath=.//ngap.fiveQI
    ${id_list}=    Combine Lists    ${ngap_fiveQI_1}    ${ngap_fiveQI_2}
    ${fiveqi_id_list}=    Remove Duplicates    ${id_list}
    [Return]    ${fiveqi_id_list}

Get priorityLevelARP id with attach
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
    ${ICSR_filter}=    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 14
    Log To Console    InitialContextSetupRequest
    ${ICSR_packets}=    cap.filter_packets_by_expression    filter_expression=${ICSR_filter}
    ${ngap_priorityLevelARP_1}=     cap.get_field_value_by_xpath    pdml_list=${ICSR_packets}
    ...                                                xpath=.//ngap.priorityLevelARP
    ${PSRSR_filter}=    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 29
    Log To Console    PDUSessionResourceSetupRequest
    ${PSRSR_packets}=    cap.filter_packets_by_expression    filter_expression=${PSRSR_filter}
    ${ngap_priorityLevelARP_2}=     cap.get_field_value_by_xpath    pdml_list=${PSRSR_packets}
    ...                                                xpath=.//ngap.priorityLevelARP
    ${id_list}=    Combine Lists    ${ngap_priorityLevelARP_1}    ${ngap_priorityLevelARP_2}
    ${priorityLevelARP_id_list}=    Remove Duplicates    ${id_list}
    [Return]    ${priorityLevelARP_id_list}

Check intergNB_NGAP HO process on source gNB
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    alias=test6
#    ####PDUSessionResourceModifyRequest
#    Log To Console     PDUSessionResourceModifyRequest
#    ${5QI_1_filter}=     Catenate    ngap.procedureCode == 26 and ngap.fiveQI == 1
#    ${5QI_1_packets}=    cap.filter_packets_by_expression    filter_expression=${5QI_1_filter}    pcap_parser=test6
#    ${ngap_fiveQI}=     cap.get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
#    Should Be Equal    ${ngap_fiveQI[0]}    1
    ####HandoverRequired(NGAP)
    Log To Console    HandoverRequired
    ${HO_req_filter}=     Catenate    ngap.procedureCode == 12 and ip.src == ${asik2_addr}
    ${HO_req_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_filter}    pcap_parser=test6
    ${HO_req}=     cap.get_field_value_by_xpath    xpath=.//ngap.procedureCode    pcap_parser=test6
    Should Be Equal    ${HO_req[0]}    12
    ####HandoverCommand(NGAP)
    Log To Console    HandoverCommand
    ${HandoverCommand_filter}=     Catenate    ngap.procedureCode == 12 and ip.dst == ${asik2_addr}
    ${HandoverCommand_packets}=    cap.filter_packets_by_expression    filter_expression=${HandoverCommand_filter}    pcap_parser=test6
    ${HO_Com}=     cap.get_field_value_by_xpath    xpath=.//ngap.procedureCode     pcap_parser=test6
    Should Be Equal    ${HO_Com[0]}    12
    ###UEContextRelease
#    Log To Console    UEContextRelease
#    ${UE_rel_filter}=     Catenate    xnap.procedureCode == 6
#    ${UE_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_filter}    pcap_parser=test6
#    ${UE_rel}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
#    Should Be Equal    ${UE_rel[0]}    6
    ###UEContextReleaseCommand(NGAP)
    Log To Console    UEContextReleaseCommand
    ${UE_rel_filter}=     Catenate    ngap.procedureCode == 41 and ngap.radioNetwork == 2
    ${UE_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_filter}    pcap_parser=test6
    ${UE_rel}=     cap.get_field_value_by_xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${UE_rel[0]}    2
    ###UEContextReleaseComplete(NGAP)
    Log To Console    UEContextReleaseComplete
    ${UE_rel_filter}=     Catenate    ngap.procedureCode == 41 and ngap.NGAP_PDU == 1
    ${UE_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_filter}    pcap_parser=test6
    ${UE_rel}=     cap.get_field_value_by_xpath    xpath=.//ngap.NGAP_PDU    pcap_parser=test6
    Should Be Equal    ${UE_rel[0]}    1
    ####RRC ReConfiguration(eventA3)
    ####RRC ReConfiguration(eventA3)
    ####UEContextReleaseCommand
    ####UEContextReleaseComplete

Check intergNB_NGAP HO process on target gNB
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    alias=test6
    ####HandoverRequest(NGAP)
    Log To Console    HandoverRequest
    ${HO_req_filter}=     Catenate    ngap.procedureCode == 13 and ip.dst == ${asik_addr}
    ${HO_req_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_filter}    pcap_parser=test6
    ${HO_req}=     cap.get_field_value_by_xpath    xpath=.//ngap.procedureCode    pcap_parser=test6
    Should Be Equal    ${HO_req[0]}    13
    ####HandoverRequestAckonwledge(NGAP)
    Log To Console    HandoverRequestAckonwledge
    ${HO_req_ACK_filter}=     Catenate    ngap.procedureCode == 13 and ip.src == ${asik_addr}
    ${HO_req_ACK_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_ACK_filter}    pcap_parser=test6
    ${HO_req_ACK}=     cap.get_field_value_by_xpath    xpath=.//ngap.procedureCode    pcap_parser=test6
    Should Be Equal    ${HO_req_ACK[0]}    13
    ####HandoverNotify(NGAP)
    Log To Console    HandoverNotify
    ${UE_HandoverNotify_filter}=     Catenate     ngap.procedureCode == 11 and ngap.NGAP_PDU == 0
    ${UE_HandoverNotify_packets}=    cap.Filter Packets By Expression    filter_expression=${UE_HandoverNotify_filter}    pcap_parser=test6
    ${UE_HandoverNotify}=     cap.Get Field Value By Xpath    xpath=.//ngap.procedureCode    pcap_parser=test6
    Should Be Equal    ${UE_HandoverNotify[0]}    11
    ####UEContextReleaseReq
    Log To Console    UEContextReleaseReq
    ${UE_contextreleasereq_filter}=     Catenate    ngap.procedureCode == 42 and ngap.radioNetwork == 0
    ${UE_contextreleasereq_packets}=    cap.Filter Packets By Expression    filter_expression=${UE_contextreleasereq_filter}    pcap_parser=test6
    ${UE_contextreleasereq}=     cap.Get Field Value By Xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    should not contain    ${UE_contextreleasereq}    0

Check L3 Call intergNB HO process on source gNB
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    alias=test6
    ####HandoverRequest
    Log To Console    HandoverRequest
    ${HO_req_filter}=     Catenate    xnap.procedureCode == 0 and ip.src == ${asik2_addr}
    ${HO_req_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_filter}    pcap_parser=test6
    ${HO_req}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${HO_req[0]}    0
    ####HandoverRequestAckonwledge
    Log To Console    HandoverRequestAckonwledge
    ${HO_req_ACK_filter}=     Catenate    xnap.procedureCode == 0 and ip.src == ${asik_addr}
    ${HO_req_ACK_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_ACK_filter}    pcap_parser=test6
    ${HO_req_ACK}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode     pcap_parser=test6
    Should Be Equal    ${HO_req_ACK[0]}    0
    ####UEContextRelease
    Log To Console    UEContextRelease
    ${UE_rel_filter}=     Catenate    xnap.procedureCode == 6
    ${UE_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_filter}    pcap_parser=test6
    ${UE_rel}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${UE_rel[0]}    6
    ####HandoverCancel
    Log To Console    HandoverCancel
    ${HO_Cancel_filter}=     Catenate     xnap.procedureCode == 2 and xnap.XnAP_PDU == 0
    ${HO_Cancel_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_Cancel_filter}    pcap_parser=test6
    ${HO_Cancel}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    should not contain    ${HO_Cancel}    2
    ####UEContextReleaseCommand
    Log To Console    UEContextReleaseCommand
    ${UE_Cont_rel_filter}=     Catenate    f1ap.procedureCode == 6 and f1ap.radioNetwork == 10
    ${UE_Cont_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_Cont_rel_filter}    pcap_parser=test6
    ${UE_Cont_rel}=     cap.get_field_value_by_xpath    xpath=.//f1ap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${UE_Cont_rel[0]}    10
    ####UEContextReleaseCompleted
    Log To Console    UEContextReleaseCompleted
    ${UE_Cont_relC_filter}=     Catenate     f1ap.procedureCode == 6 and f1ap.F1AP_PDU == 1
    ${UE_Cont_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_Cont_relC_filter}    pcap_parser=test6
    ${UE_Cont_relC}=     cap.get_field_value_by_xpath    xpath=.//f1ap.F1AP_PDU    pcap_parser=test6
    should contain    ${UE_Cont_relC}    1

Check L3 Call intergNB HO process on target gNB
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    alias=test6
    ####HandoverRequest
    Log To Console    HandoverRequest
    ${HO_req_filter}=     Catenate    xnap.procedureCode == 0 and ip.dst == ${asik_addr}
    ${HO_req_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_filter}    pcap_parser=test6
    ${HO_req}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${HO_req[0]}    0
    ####HandoverRequestAckonwledge
    Log To Console    HandoverRequestAckonwledge
    ${HO_req_ACK_filter}=     Catenate    xnap.procedureCode == 0 and ip.src == ${asik_addr}
    ${HO_req_ACK_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_ACK_filter}    pcap_parser=test6
    ${HO_req_ACK}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${HO_req_ACK[0]}    0
    ####PathSwitchRequest
    Log To Console    PathSwitchRequest
    ${PathS_req_filter}=     Catenate    ngap.procedureCode == 25 and ip.src == ${asik_addr}
    ${PathS_req_packets}=    cap.filter_packets_by_expression    filter_expression=${PathS_req_filter}    pcap_parser=test6
    ${PathS_req}=     cap.get_field_value_by_xpath    xpath=.//ngap.procedureCode    pcap_parser=test6
    Should Be Equal    ${PathS_req[0]}    25
    ####PathSwitchRequestAckonwledge
    Log To Console    PathSwitchRequestAckonwledge
    ${PathS_ACK_filter}=     Catenate    ngap.procedureCode == 25 and ip.dst == ${asik_addr}
    ${PathS_ACK_packets}=    cap.filter_packets_by_expression    filter_expression=${PathS_ACK_filter}    pcap_parser=test6
    ${PathS_ACK}=     cap.get_field_value_by_xpath    xpath=.//ngap.procedureCode     pcap_parser=test6
    Should Be Equal    ${PathS_ACK[0]}    25
    ####UEContextRelease
    Log To Console    UEContextRelease
    ${UE_rel_filter}=     Catenate    xnap.procedureCode == 6
    ${UE_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_filter}    pcap_parser=test6
    ${UE_rel}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${UE_rel[0]}    6
    ####UEContextReleaseReq
    Log To Console    UEContextReleaseReq
    ${UE_contextreleasereq_filter}=     Catenate    ngap.procedureCode == 42 and ngap.radioNetwork == 0
    ${UE_contextreleasereq_packets}=    cap.Filter Packets By Expression    filter_expression=${UE_contextreleasereq_filter}    pcap_parser=test6
    ${UE_contextreleasereq}=     cap.Get Field Value By Xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    should not contain    ${UE_contextreleasereq}    0

Check intergNB HO process on source gNB
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    alias=test6
    ####HandoverRequest
    Log To Console    HandoverRequest
    ${HO_req_filter}=     Catenate    xnap.procedureCode == 0 and ip.src == ${asik2_addr}
    ${HO_req_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_filter}    pcap_parser=test6
    ${HO_req}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${HO_req[0]}    0
    ####HandoverRequestAckonwledge
    Log To Console    HandoverRequestAckonwledge
    ${HO_req_ACK_filter}=     Catenate    xnap.procedureCode == 0 and ip.src == ${asik_addr}
    ${HO_req_ACK_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_ACK_filter}    pcap_parser=test6
    ${HO_req_ACK}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode     pcap_parser=test6
    Should Be Equal    ${HO_req_ACK[0]}    0
    ####UEContextRelease
    Log To Console    UEContextRelease
    ${UE_rel_filter}=     Catenate    xnap.procedureCode == 6
    ${UE_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_filter}    pcap_parser=test6
    ${UE_rel}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${UE_rel[0]}    6
    ####HandoverCancel
    Log To Console    HandoverCancel
    ${HO_Cancel_filter}=     Catenate     xnap.procedureCode == 2 and xnap.XnAP_PDU == 0
    ${HO_Cancel_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_Cancel_filter}    pcap_parser=test6
    ${HO_Cancel}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    should not contain    ${HO_Cancel}    2
    ####UEContextReleaseCommand
    Log To Console    UEContextReleaseCommand
    ${UE_Cont_rel_filter}=     Catenate    f1ap.procedureCode == 6 and f1ap.radioNetwork == 10
    ${UE_Cont_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_Cont_rel_filter}    pcap_parser=test6
    ${UE_Cont_rel}=     cap.get_field_value_by_xpath    xpath=.//f1ap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${UE_Cont_rel[0]}    10
    ####UEContextReleaseCompleted
    Log To Console    UEContextReleaseCompleted
    ${UE_Cont_relC_filter}=     Catenate     f1ap.procedureCode == 6 and f1ap.F1AP_PDU == 1
    ${UE_Cont_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_Cont_relC_filter}    pcap_parser=test6
    ${UE_Cont_relC}=     cap.get_field_value_by_xpath    xpath=.//f1ap.F1AP_PDU    pcap_parser=test6
    should contain    ${UE_Cont_relC}    1

Check intergNB HO process on target gNB
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    alias=test6
    ####HandoverRequest
    Log To Console    HandoverRequest
    ${HO_req_filter}=     Catenate    xnap.procedureCode == 0 and ip.dst == ${asik_addr}
    ${HO_req_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_filter}    pcap_parser=test6
    ${HO_req}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${HO_req[0]}    0
    ####HandoverRequestAckonwledge
    Log To Console    HandoverRequestAckonwledge
    ${HO_req_ACK_filter}=     Catenate    xnap.procedureCode == 0 and ip.src == ${asik_addr}
    ${HO_req_ACK_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_ACK_filter}    pcap_parser=test6
    ${HO_req_ACK}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${HO_req_ACK[0]}    0
    ####PathSwitchRequest
    Log To Console    PathSwitchRequest
    ${PathS_req_filter}=     Catenate    ngap.procedureCode == 25 and ip.src == ${asik_addr}
    ${PathS_req_packets}=    cap.filter_packets_by_expression    filter_expression=${PathS_req_filter}    pcap_parser=test6
    ${PathS_req}=     cap.get_field_value_by_xpath    xpath=.//ngap.procedureCode    pcap_parser=test6
    Should Be Equal    ${PathS_req[0]}    25
    ####PathSwitchRequestAckonwledge
    Log To Console    PathSwitchRequestAckonwledge
    ${PathS_ACK_filter}=     Catenate    ngap.procedureCode == 25 and ip.dst == ${asik_addr}
    ${PathS_ACK_packets}=    cap.filter_packets_by_expression    filter_expression=${PathS_ACK_filter}    pcap_parser=test6
    ${PathS_ACK}=     cap.get_field_value_by_xpath    xpath=.//ngap.procedureCode     pcap_parser=test6
    Should Be Equal    ${PathS_ACK[0]}    25
    ####UEContextRelease
    Log To Console    UEContextRelease
    ${UE_rel_filter}=     Catenate    xnap.procedureCode == 6
    ${UE_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_filter}    pcap_parser=test6
    ${UE_rel}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${UE_rel[0]}    6
    ####UEContextReleaseReq
    Log To Console    UEContextReleaseReq
    ${UE_contextreleasereq_filter}=     Catenate    ngap.procedureCode == 42 and ngap.radioNetwork == 0
    ${UE_contextreleasereq_packets}=    cap.Filter Packets By Expression    filter_expression=${UE_contextreleasereq_filter}    pcap_parser=test6
    ${UE_contextreleasereq}=     cap.Get Field Value By Xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    should not contain    ${UE_contextreleasereq}    0

Check intragNB interFre HO process on gNB
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    alias=test6
    ####UEContextModificationRequest,RRC Reconfiguration
    Log To Console    RRC Reconfiguration
    ${RRC_Reconfiguration_filter}=     Catenate    f1ap.procedureCode == 7 and f1ap.F1AP_PDU == 0 and nr-rrc.criticalExtensions == 0
    ${RRC_Re_packets}=    cap.filter_packets_by_expression    filter_expression=${RRC_Reconfiguration_filter}    pcap_parser=test6
    ${RRC_Re}=     cap.get_field_value_by_xpath    xpath=.//nr-rrc.criticalExtensions    pcap_parser=test6
    should contain    ${RRC_Re}    0
    Log To Console    RRC Reconfiguration Completed
    ${RRC_Reconfiguration_filter}=     Catenate
    ...    f1ap.procedureCode == 13 and nr-rrc.criticalExtensions == 0 and f1ap.F1AP_PDU == 0
    ${RRC_Re_packets}=    cap.filter_packets_by_expression    filter_expression=${RRC_Reconfiguration_filter}    pcap_parser=test6
    ${RRC_ReC}=     cap.get_field_value_by_xpath    xpath=.//nr-rrc.criticalExtensions    pcap_parser=test6
    should contain    ${RRC_ReC}    0

Check VONR Normal release
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    ngap.nas == 0 and ngap.procedureCode == 26
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_nas}=     cap.Get Field Value By Xpath    xpath=.//ngap.nas    pcap_parser=test6
    Should Be Equal    ${ngap_nas[0]}    0

Check the Two VONR Normal release
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    ngap.nas == 0 and ngap.procedureCode == 26
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_nas}=     cap.Get Field Value By Xpath    xpath=.//ngap.nas    pcap_parser=test6
#    Should Be Equal    ${ngap_nas[0]}    0
    should contain x times    ${ngap_nas}    0    2

Check wireshark log for ECC release
    [Arguments]    ${logname}
    Check wireshark log for ECC    logname=${logname}
    ...    message_filter=ngap.procedureCode == 28 and ngap.nas == 0
    ...    xpath_filter=ngap.nas    expect_value=0
    Check wireshark log for ECC    logname=${logname}
    ...    message_filter=ngap.procedureCode == 28
    ...    xpath_filter=ngap.PDUSessionResourceReleaseResponse_element
    ...    expect_value=PDUSessionResourceReleaseResponse
    ...    attribute_name=showname

Check wireshark log for ECC
    [Arguments]    ${logname}    ${message_filter}    ${xpath_filter}    ${expect_value}    ${attribute_name}=show
#    ...    ${command_template}=${command_template_with_Y}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.Filter Packets By Expression
    ...    filter_expression=${filter_expression}    pcap_parser=test6
    ${filtered_value}=     cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//${xpath_filter}
    ...    attribute_name=${attribute_name}    pcap_parser=test6
    should be equal    ${filtered_value[0]}    ${expect_value}

Check VoNR release success message
    [Arguments]    ${logname}
    Analysis wireshark log for VoNR success release    logname=${logname}

Analysis wireshark log for VoNR success release
     [Arguments]    ${logname}
    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}    alias=test6
    Log To Console    check release value on PDUSessionResourceModifyRequest message
    ${Code26_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26 and ngap.nas==0
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Code26_0}    pcap_parser=test6
    ${ngap_nas} =    get_field_value_by_xpath    xpath=.//ngap.nas    pcap_parser=test6
    Should Be Equal    ${ngap_nas[0]}    0

    ${PDUSessionResourceModifyResponse} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check release value on PDUSessionResourceModifyResponse
    ${filtered_packets}=
    ...    filter_packets_by_expression    filter_expression=${PDUSessionResourceModifyResponse}    pcap_parser=test6
    ${ngap_id} =    get_field_value_by_xpath    xpath=.//ngap.criticality    pcap_parser=test6
    Should Be Equal    ${ngap_id[0]}    0

###PM counter
Prepare with PM counter time to caculate
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    300-${utc0}%300
    sleep    ${left_timer}

Check gnb counter as expected_value
    [Arguments]    ${counter_id}    ${dic_path}    ${expected_value}    ${gnb_id}=${1}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].cu.oam_ssh_connection_details.addr}
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${dic_path}
    should be true   ${counter_value[0]}==${expected_value}
    [Teardown]    COAM Teardown gnb connections

Check gnb counter greater expected_value
    [Arguments]    ${counter_id}    ${dic_path}    ${expected_value}    ${gnb_id}=${1}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].cu.oam_ssh_connection_details.addr}
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${dic_path}
    should be true   ${counter_value[0]}>=${expected_value}
    [Teardown]    COAM Teardown gnb connections

Check gnb counter contain expected_value
    [Arguments]    ${counter_id}    ${dic_path}    ${gnb_id}=${1}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].cu.oam_ssh_connection_details.addr}
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${dic_path}
    should contain any    ${counter_value}    ${1}    ${2}
    [Teardown]    COAM Teardown gnb connections


get version via coam
    [Arguments]    ${gnb_index}=${0}    ${timeout}=${300}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}    connection=${connection}
    ${compass_version}=    coam.get_sw_version    timeout=${timeout}    connection=${connection}
    Set Test Variable    ${compass_version}
    [Teardown]    COAM Teardown gnb connections    connection=${connection}
    [Return]    ${compass_version}

Get report name
    [Arguments]    ${report_name}
    ${current_time}=    Get Time    epoch
    ${compass_report}=    Catenate    SEPARATOR=_    ${report_name}    ${current_time}
    Set Test Variable    ${compass_report}

Generate kpi report on compass
    [Arguments]    ${template_id}    ${template_name}    ${test_line}    ${start_time}    ${end_time}
    ${compass_report_result}=    GPC.generate_new_report    package_version=${compass_version}    template_id=${template_id}
    ...    template_name=${template_name}    report_name=${compass_report}    test_line=${test_line}
    ...    start_time=${start_time}    end_time=${end_time}
    Set Test Variable    ${compass_report_result}
    [Return]    ${compass_report_result}

Get KPI name and value with known info
    [Arguments]    ${file_path}    ${report_name}    ${package_version}
    ${dict_kpi_name_value}    ${dict_kpi_name_start_range}    ${dict_kpi_name_end_range}=
    ...    Run Keyword If    '${compass_report_result}' == 'True'     GPC.get_kpi_report_detail
    ...    report_name=${report_name}    package_version=${package_version}    file_path=${file_path}
    Set Test Variable    ${dict_kpi_name_value}
    Set Test Variable    ${dict_kpi_name_start_range}
    Set Test Variable    ${dict_kpi_name_end_range}
    [Return]    ${dict_kpi_name_value}    ${dict_kpi_name_start_range}    ${dict_kpi_name_end_range}

Check KPI with target value of compass
    ${KPI_name_list}=    Get Dictionary Keys    ${dict_kpi_name_value}
    FOR    ${KPI_name}    IN    @{KPI_name_list}
        Run Keyword If    ${dict_kpi_name_start_range}[${KPI_name}] == 0 and ${dict_kpi_name_end_range}[${KPI_name}] == 0
        ...    Should Be True    ${dict_kpi_name_value}[${KPI_name}] = 0
        ...    ELSE IF    ${dict_kpi_name_start_range}[${KPI_name}] == null or ${dict_kpi_name_end_range}[${KPI_name}] == null
        ...    Should Be True    ${dict_kpi_name_value}[${KPI_name}] > 0
        ...    ELSE    Run Keywords
        ...    Should Be True    ${dict_kpi_name_value}[${KPI_name}] > ${dict_kpi_name_start_range}[${KPI_name}]
        ...    AND    Should Be True    ${dict_kpi_name_value}[${KPI_name}] < ${dict_kpi_name_end_range}[${KPI_name}]
    END

check KPI with required name
    [Arguments]    ${KPI_name_list}    ${check_field}
    FOR    ${KPI_name}    IN    @{KPI_name_list}
        Run Keyword IF    ${check_field} == in_range    Run Keywords
        ...    Should Be True    ${dict_kpi_name_value}[${KPI_name}] > ${dict_kpi_name_start_range}[${KPI_name}]
        ...    AND    Should Be True    ${dict_kpi_name_value}[${KPI_name}] < ${dict_kpi_name_end_range}[${KPI_name}]
        ...    ELSE IF    ${check_field} == zero
        ...    Should Be True    ${dict_kpi_name_value}[${KPI_name}] = ${0}
        ...    ELSE IF    ${check_field} == larger_zero
        ...    Should Be True    ${dict_kpi_name_value}[${KPI_name}] > ${0}
    END
    Run Keyword If    ${check_field} == one_value
    ...    check if one of the counters has a value    KPI_name_list=${KPI_name_list}

check if one of the counters has a value
    [Arguments]    ${KPI_name_list}
    ${list_check_boolean}    Create List
    FOR    ${KPI}    IN     @{KPI_name_list}
        ${check_boolean}=    Run Keyword And Return Status    Should Be True    ${dict_kpi_name_value}[${KPI}] > ${0}
        Append To List    ${list_check_boolean}    ${check_boolean}
    END
    Should Contain    ${list_check_boolean}    True

check KPI with required name from pm file
    [Arguments]    ${KPI_name_list}    ${check_field}    ${dict_kpi_get}    ${dict_kpi_compare_start}=default
    ...    ${dict_kpi_compare_end}=default
    FOR    ${KPI_name}    IN    @{KPI_name_list}
        Run Keyword IF    '${check_field}' == 'in_range'    Run Keywords
        ...    Should Be True    ${dict_kpi_get}[${KPI_name}] > ${dict_kpi_compare_start}[${KPI_name}]
        ...    AND    Should Be True    ${dict_kpi_get}[${KPI_name}] < ${dict_kpi_compare_end}[${KPI_name}]
        ...    ELSE IF    '${check_field}' == 'zero'
        ...    Should Be True    ${dict_kpi_get}[${KPI_name}] = ${0}
        ...    ELSE IF    '${check_field}' == 'larger_zero'
        ...    Should Be True    ${dict_kpi_get}[${KPI_name}] > ${0}
    END
    Run Keyword If    '${check_field}' == 'one_value'
    ...    check if one of the counters has a value from pm file    KPI_name_list=${KPI_name_list}
    ...    dict_kpi_get=${dict_kpi_get}

check if one of the counters has a value from pm file
    [Arguments]    ${KPI_name_list}    ${dict_kpi_get}
    ${list_check_boolean}    Create List
    FOR    ${KPI}    IN     @{KPI_name_list}
        ${check_boolean}=    Run Keyword And Return Status    Should Be True    ${dict_kpi_get}[${KPI}] > ${0}
        Append To List    ${list_check_boolean}    ${check_boolean}
    END
    Should Contain    ${list_check_boolean}    True

#check required KPI via pm file
#    [Arguments]    ${KPI_name_list}    ${check_field}    ${dict_kpi_get}    ${specfied}=${0.011}
#    FOR    ${KPI_name}    IN    @{KPI_name_list}
#        Run Keyword IF    '${check_field}' == 'zero'
#        ...    Should Be True    &{dict_kpi_get}[${KPI_name}] == ${0}
#        ...    ELSE IF    '${check_field}' == 'larger_zero'
#        ...    Should Be True    &{dict_kpi_get}[${KPI_name}] > ${0}
#        ...    ELSE IF    '${check_field}' == 'specified_value'
#        ...    Should Be True    &{dict_kpi_get}[${KPI_name}] < ${specfied}
#    END

check required KPI via pm file
    [Arguments]    ${KPI_name_list}    ${check_field}    ${dict_kpi_get}
    ...    ${equal_specfied}=${0}    ${larger_specfied}=${0}    ${less_specfied}=${0.011}    ${greater_than_or_equal_specfied}=${0}
    FOR    ${KPI_name}    IN    @{KPI_name_list}
        Run Keyword IF    '${check_field}' == 'equal_specified_value'
        ...    Should Be True    ${dict_kpi_get}[${KPI_name}] == ${equal_specfied}
        ...    ELSE IF    '${check_field}' == 'larger_specified_value'
        ...    Should Be True    ${dict_kpi_get}[${KPI_name}] > ${larger_specfied}
        ...    ELSE IF    '${check_field}' == 'less_specified_value'
        ...    Should Be True    ${dict_kpi_get}[${KPI_name}] < ${less_specfied}
        ...    ELSE IF    '${check_field}' == 'greater_than_or_equal_specified_value'
        ...    Should Be True    ${dict_kpi_get}[${KPI_name}] >= ${greater_than_or_equal_specfied}
    END

get kpi from per pm file
    [Arguments]    ${index}=${0}    ${bts_ip}=${tl.gnbs[${index}].cu.oam_ssh_connection_details.addr}
    ...    ${bts_username}=${tl.gnbs[${index}].cu.oam_ssh_connection_details.username}
    ...    ${bts_password}=${tl.gnbs[${index}].cu.oam_ssh_connection_details.password}
    ...    ${kpi_path}=${CURDIR}/Resources
    ...    ${KPI_file}=CB008246_E_006_KPI.txt
    ...    ${para_index}=${2}
    ${newest_xml_file}=    get_newest_pm_xml_file    ip=${bts_ip}    username=${bts_username}    password=${bts_password}
    ...    connection=gNB${index}    local_path=${epc_log_path}
    ${kpi_value}=    calculate_kpi_from_pm_file    pm_xml_file=${newest_xml_file}
    ...    kpi_file=${kpi_path}/${KPI_file}    para_index=${para_index}
    [Return]    ${kpi_value}

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

check formula_established with required KPI via pm file
    Should Be True    ${1}=${1}

Adjust HBTE gNB_eNB_RU Attenuation
    [Arguments]    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}    ${enb_cell1_value}=${127}
    Adjust the tl HBTE attenuation value    #tl=@{diffTL_enb_ID}[0]
    ...    gnb1_cell1_value=${gnb1_cell1_value}    gnb1_cell2_value=${gnb1_cell2_value}
    ...    gnb2_cell1_value=${gnb2_cell1_value}    enb_cell1_value=${enb_cell1_value}

Adjust the tl HBTE attenuation value
    [Arguments]     ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}
    ...    ${enb_cell1_value}=${127}
    ####create cell list#####
    @{att_ports_gnb1_cell1}    Create List    ${att_port_1_HBTE}     ${att_port_2_HBTE}
    @{att_ports_gnb1_cell2}    Create List    ${att_port_3_HBTE}     ${att_port_4_HBTE}
    @{att_ports_gnb2_cell1}    Create List    ${att_port_5_HBTE}     ${att_port_6_HBTE}
    @{att_ports_enb_cell1}     Create List    ${att_port_7_HBTE}     ${att_port_8_HBTE}

    ###create value list####
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}
    @{values_enb_cell1}     Create List    ${enb_cell1_value}     ${enb_cell1_value}     ${enb_cell1_value}     ${enb_cell1_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}
    Set the attenuation value    att_ports=${att_ports_enb_cell1}     values=${values_enb_cell1}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}

COAM Save snapshot
    get gnb snapshot    gnb_index=${0}
#    get gnb snapshot    gnb_index=${1}

get gnb snapshot
    [Arguments]     ${gnb_index}=${0}
    Connect to gnb coam via ssl    gnb_index=${gnb_index}
#    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    [Teardown]    COAM Teardown gnb connections

Online modify parmeters enb
    [Arguments]    ${parameters_to_update}    ${enb_index}=${0}    ${skip_parameter_relation_errors}=True
    Connect to gnb coam via ssl    bts_host=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update}    timeout=${300}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

add or delete 5QI via npc dynamic rule
    [Arguments]    ${imsi}    ${rule}
    ${return_code}    ${return_result}    dynamic rule submit    imsi=${imsi}    rule=${rule}
    run keyword if    '${return_result}' == 'Success'    run keywords
    ...    log    ${rule} operate Success!
    ...    AND    log to console    ${rule} operate Success!
    ...    ELSE    run keywords
    ...    log    ${rule} operate Failed!
    ...    AND    log to console    ${rule} operate Failed!
    ...    AND    fail    msg=need to check on SRN CHINA web page

get logs from gnb_logs folder
    [Arguments]    ${tool_download_path}    ${tool_path}=${tool_download_path}/gnb_logs
#    ...    ${gnb_index}=${0}    ${gnb_ip}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${type}=tti_packed
    ${get_log_name_command}    catenate    cd ${tool_path};ls -l | grep BTS | awk '{print $9}'
    ${rc}    ${output}    run and return rc and output    command=${get_log_name_command}
    should be equal as integers    ${rc}    0
    ${output}     strip string    ${output}
    ${log_name}    ${ext_name}=    split extension    path=${output}
#    @{log_name_list}    split string    ${output}    .
#    @{log_type_list}    split string    @{log_name_list}[0]    _
    ${rc}    run and return rc    command=cd ${tool_path};unzip ${output}
    should be equal as integers    ${rc}    0
    ${rc}    run and return rc    command=cd ${tool_path};rm -rf ${output}
    should be equal as integers    ${rc}    0
#    ${rc}    run and return rc    command=cd ${tool_path}/${log_name}/${type}
    ${fsp_folder}    list directories in directory    path=${tool_path}/${log_name}/${type}
    ${log_files}    run keyword if    '${type}' == 'tti_packed'
    ...    list files in directory    path=${tool_path}/${log_name}/${type}/${fsp_folder}[0]     pattern=*.csv
    ...    ELSE    list files in directory    path=${tool_path}/${log_name}/${type}
    ${current_time}=    get current date    result_format=%Y%m%d%H%M%S
    create directory    path=${epc_log_path}/${current_time}
    directory should exist    path=${epc_log_path}/${current_time}
    ${rc}    ${output}    run keyword if    '${type}' == 'tti_packed'
    ...    run and return rc and output    command=cp -r ${tool_path}/${log_name}/${type}/${fsp_folder}[0]/* ${epc_log_path}/${current_time}
#    ...    copy files    source=${tool_path}/${log_name}/${type}/${fsp_folder}[0]/*    destination=${epc_log_path}/${current_time}
#    ...    ELSE    copy files    source=${tool_path}/${log_name}/${type}/*    destination=${epc_log_path}/${current_time}
    ...    ELSE    run and return rc and output    command=cp -r ${tool_path}/${log_name}/${type}/* ${epc_log_path}/${current_time}
#    [Teardown]    run keywords
#    ...    run    command=cd ${tool_path};rm -rf ${log_name}
#    ...    AND    directory should not exist    path=${tool_path}/${log_name}
    [Return]    ${log_files}    ${current_time}

get logs from gnb_logs folder from v2.67
    [Arguments]    ${tool_download_path}    ${tool_path}=${tool_download_path}/gnb_logs
    ...    ${gnb_index}=${0}    #${gnb_ip}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${type}=tti    ${lcrid}=${1}    #${distname_id}=${0}
    ${get_log_name_command}    catenate    cd ${tool_path};ls -l | grep BTS | awk '{print $9}'
    ${rc}    ${output}    run and return rc and output    command=${get_log_name_command}
    should be equal as integers    ${rc}    0
    ${output}     strip string    ${output}
    ${log_name}    ${ext_name}=    split extension    path=${output}
    ${rc}    run and return rc    command=cd ${tool_path};unzip ${output}
    should be equal as integers    ${rc}    0
    ${rc}    run and return rc    command=cd ${tool_path};rm -rf ${output}
    should be equal as integers    ${rc}    0
#    ${nrCellIdentity}=    get required value of parameter
#    ...    Abbreviation=nrCellIdentity    gnb_index=${gnb_index}    distname_id=${distname_id}
    ${nrCellIdentity}=    COAM Get nrcellid with lcrid    lcrid=${lcrid}    gnb_index=${gnb_index}
    ${l2_num}=    return_l2_num_from_gnb_logs_tool_log    gnb_logs_tool_path=${tool_path}    log_folder=${log_name}
    ...    nrCellIdentity=${nrCellIdentity}
    ${log_files}    run keyword if    '${type}' == 'tti'
    ...    list files in directory    path=${tool_path}/${log_name}/${type}/${l2_num}_ttiTrace     pattern=*.csv
    ...    ELSE    list files in directory    path=${tool_path}/${log_name}/${type}
    ${current_time}=    get current date    result_format=%Y%m%d%H%M%S
    create directory    path=${epc_log_path}/${current_time}
    directory should exist    path=${epc_log_path}/${current_time}
    ${rc}    ${output}    run keyword if    '${type}' == 'tti'
    ...    run and return rc and output    command=cp -r ${tool_path}/${log_name}/${type}/${l2_num}_ttiTrace/* ${epc_log_path}/${current_time}
    ...    ELSE    run and return rc and output    command=cp -r ${tool_path}/${log_name}/${type}/* ${epc_log_path}/${current_time}
#    [Teardown]    run keywords
#    ...    run    command=cd ${tool_path};rm -rf ${log_name}
#    ...    AND    directory should not exist    path=${tool_path}/${log_name}
    [Return]    ${log_files}    ${current_time}    ${tool_path}/${log_name}/${type}/${l2_num}_ttiTrace

Adjust Signal HBTE gNB_eNB_RU Attenuation
    [Arguments]    ${gnb1_cell1_p1_value}=${127}    ${gnb1_cell1_p2_value}=${127}    ${gnb1_cell2_p3_value}=${127}    ${gnb1_cell2_p4_value}=${127}
    ...    ${gnb2_cell1_p5_value}=${127}    ${gnb2_cell1_p6_value}=${127}    ${enb_cell1_p7_value}=${127}    ${enb_cell1_p8_value}=${127}
    Adjust the tl Signal HBTE attenuation value    #tl=@{diffTL_enb_ID}[0]
    ...    gnb1_cell1_p1_value=${gnb1_cell1_p1_value}    gnb1_cell1_p2_value=${gnb1_cell1_p2_value}
    ...    gnb1_cell2_p3_value=${gnb1_cell2_p3_value}    gnb1_cell2_p4_value=${gnb1_cell2_p4_value}
    ...    gnb2_cell1_p5_value=${gnb2_cell1_p5_value}    gnb2_cell1_p6_value=${gnb2_cell1_p6_value}
    ...    enb_cell1_p7_value=${enb_cell1_p7_value}      enb_cell1_p8_value=${enb_cell1_p8_value}

Adjust the tl Signal HBTE attenuation value
    [Arguments]     ${gnb1_cell1_p1_value}=${127}    ${gnb1_cell1_p2_value}=${127}    ${gnb1_cell2_p3_value}=${127}    ${gnb1_cell2_p4_value}=${127}
    ...    ${gnb2_cell1_p5_value}=${127}    ${gnb2_cell1_p6_value}=${127}    ${enb_cell1_p7_value}=${127}    ${enb_cell1_p8_value}=${127}
    ####create cell list#####
    @{att_ports_gnb1_cell1}    Create List    ${att_port_1_HBTE}     ${att_port_2_HBTE}
    @{att_ports_gnb1_cell2}    Create List    ${att_port_3_HBTE}     ${att_port_4_HBTE}
    @{att_ports_gnb2_cell1}    Create List    ${att_port_5_HBTE}     ${att_port_6_HBTE}
    @{att_ports_enb_cell1}     Create List    ${att_port_7_HBTE}     ${att_port_8_HBTE}

    ###create value list####
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_p1_value}    ${gnb1_cell1_p2_value}
    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_p3_value}    ${gnb1_cell2_p4_value}
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_p5_value}    ${gnb2_cell1_p6_value}
    @{values_enb_cell1}     Create List    ${enb_cell1_p7_value}     ${enb_cell1_p8_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}
    Set the attenuation value    att_ports=${att_ports_enb_cell1}     values=${values_enb_cell1}
    ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}

Switch QCOM APN to muti DRB
    [Arguments]    ${apn_name}    ${ue_index}=${0}    ${ue_type}=${ue_type1}
    Get all X70 pointer variable
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${passed}'=='${True}'
        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}
    CB008246_common_keywords.Android UE SwitchApn    ue_index=${ue_index}    apn_name=${apn_name}    #ui_version=${ui_version}
    UE.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Switch APN to muti DRB
    [Arguments]    ${apn_name}    ${ui_version}    ${ue_index}=${0}    ${ue_type}=${ue_type1}
    Run Keyword And Ignore Error    Attach and check power UE   ue_type=${ue_type}
    CB008246_common_keywords.Android UE SwitchApn    ue_index=${ue_index}    apn_name=${apn_name}    ui_version=${ui_version}
    run keyword and ignore error    UE.UE Detach    ue_type=${ue_type}

Android UE SwitchApn
    [Documentation]
    ...    Note: Use the keyword must be ensure that UE UI Menu is English language
    ...    str ui_version: mobile ui version.
    ...        e.g Magic UI 3.1.1, have tested on honor CDY-AN90 1080x2400,
    ...            EMUI 10.1.0, have tested on huawei mate30 LIO-AN00 1176x2400.
    ...            Qualcomm qti lahaina for arm64 ue do not have UI, so this field equal to '' or ${None}
    ...           if mobile is mtk peturs, pass 'petrus' as ui_version.
    [Arguments]       ${ue_index}=${0}    ${host}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${username}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${password}=${tl.ues[${ue_index}].ssh_connection_details.password}     ${ui_version}=${None}
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${apn_name}=mdrb    ${ue_alias}=UE_${ue_index}
    android_mobile.setup
    ...               ui_version=${ui_version}    host=${host}    username=${username}
    ...               password=${password}    port=22     serial_number=${serial_number}    alias=${UE_alias}
    run keyword and ignore error    android_mobile.switch_apn       apn_name=${apn_name}   mobile=${UE_alias}
    android_mobile.teardown       mobile=${UE_alias}

Get all X70 pointer variable
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    953 1385
    Set Suite Variable    ${close_task}    523 272
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    480 860
    Set Suite Variable    ${iperf_button}    720 312
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${brand}    qti

operate data button on SDX70
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${status}=enable
    Sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell svc data ${status}    connection=cygwin

airplane enable disable
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 943 1393    connection=cygwin

pdu session setup on ue
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    sleep   3s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
    ...    connection=cygwin
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell am start com.android.settings/com.android.settings.Settings    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 479 950    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 943 1393    connection=cygwin

Get gnb release info
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}

#Capture Ttitrace tti from WEBUI
#    [Arguments]    ${names}    ${nr_phy_cell_ids}
#    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'
#    ...    Capture Ttitrace With Admin Mode and Convert format    names=${names}    nr_phy_cell_ids=${nr_phy_cell_ids}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'
#    ...    Capture Ttitrace With Admin Mode and Convert format    names=${names}    nr_phy_cell_ids=${nr_phy_cell_ids}
#    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'
#    ...    Capture Ttitrace With Admin Mode and Convert format    names=${names}    nr_phy_cell_ids=${nr_phy_cell_ids}

Capture Ttitrace tti from WEBUI
    [Arguments]    ${names}    ${nr_phy_cell_ids}    ${capture_time}=5s
    Capture Ttitrace With Admin Mode and Convert format    names=${names}    nr_phy_cell_ids=${nr_phy_cell_ids}    capture_time=${capture_time}

Switch QCOM airplane mode status on
    [Arguments]     ${ue_index}=${0}    ${airplane_enable}=${False}
    Get all X70 pointer variable
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${passed}'=='${airplane_enable}'
        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}

get and analysis syslog
    Check ERR Or WRN From Syslog
    ...    sys_logs_path=${sys_logs_path}      Expected_ERR_WRN_deviation=0.2
    ...    Expected_ERR_WRN_diff_number=0
    ...    UTE_logs_path=${UTE_logs_path}      testline=${testline_name}
    ...    base_file=None     Fail_Case=False       Clear_log=False     remove_ERR_WRN_excel=True
    ...    filter_list=None      ignore_list=None      Delete_old_ERR_WRN=20
    ...    FilesSystem=/dev/vda2      Max_used_space_ratio=0.9      check_diff=True
    ...    timeout=30 minutes      Expected_ERR_WRN_number=0
#    ...    Check_RF_Log=True

Start capture syslog via btslog on ute
    Start BTSlogs Collection In Log Server
    ...    Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...    Test_PC_password=${Test_PC_password}
    ...    btslog_path=/tmp/btslog2    btslog_launcher=/opt/btslog/btslog_launcher
    ...    btslog_launcher_path=/opt/btslog/btslog
    ...    Login_UTE=False

Stop capture syslog via btslog on ute
    Stop BTSlogs Collection And Download Logs To Log Server
    ...    UTE_syslogs_path=/home/ute/BTS_logs    btslog_path=/tmp/btslog2
    ...    btslog_launcher=/opt/btslog/btslog_launcher    btslog_launcher_path=/opt/btslog/btslog
    ...    Login_UTE=${False}

Get all X80 pointer variable
    Set Suite Variable    ${home}    82
    Set Suite Variable    ${airplane}    1279 1635
    Set Suite Variable    ${close_task}    275 1460
    Set Suite Variable    ${swipe}    500 2050 500 800

choice required APN on QCOM SDX80 UE
    [Arguments]    ${usedapn}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Get all X80 pointer variable
    Connect to control pc via cygwin    ue_index=${ue_index}    alias=cygwin
    set Qcom apn to usedapn    usedapn=${usedapn}    ue_index=${ue_index}
    #### KEYCODE_APP_SWITCH,recent APP application
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=cygwin
    #### clear all KEYCODE_APP_SWITCH,recent APP application
    FOR  ${i}    IN RANGE    ${9}
        csn.send_command    command=adb -s ${serial_number} shell input swipe 100 1300 900 1300    connection=cygwin
        sleep    1s
    END
    sleep    2s
    FOR  ${i}    IN RANGE    ${2}
        csn.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=cygwin
        sleep   1s
    END
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.settings.AIRPLANE_MODE_SETTINGS    connection=cygwin
    sleep   4s
    #####Tap the airplane mode switch to enable airplane mode#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${airplane}    connection=cygwin
    Sleep    2s
    [Teardown]    csn.disconnect    connection=cygwin

set Qcom apn to usedapn
    [Arguments]    ${usedapn}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Sleep    2s
    # 1. check airplane status
    csn.send_command     command=adb -s ${serial_number} shell settings get global airplane_mode_on    connection=cygwin
    sleep    3s
    ${airplane_status} =    csn.Read Output    connection=cygwin
    @{airmode_status}    split string    ${airplane_status}    \r\n
    ${status}    set variable if    '${airmode_status[0]}'=='0'    ${False}    ${True}
    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${home}    connection=cygwin
    sleep   4s
    #####Swipe up to unlock the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep   4s
    #### KEYCODE_APP_SWITCH,recent APP application
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=cygwin
    #### clear all KEYCODE_APP_SWITCH,recent APP application
    FOR  ${i}    IN RANGE    ${9}
        csn.send_command    command=adb -s ${serial_number} shell input swipe 100 1300 900 1300    connection=cygwin
        sleep    1s
    END
    sleep    2s
    FOR  ${i}    IN RANGE    ${2}
        csn.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=cygwin
        sleep   1s
    END
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.settings.AIRPLANE_MODE_SETTINGS    connection=cygwin
    sleep   4s
    IF    '${status}' == '${True}'
        #####Tap the airplane mode switch to enable airplane mode#####
        csn.send_command    command=adb -s ${serial_number} shell input tap ${airplane}    connection=cygwin
        Sleep    2s
    END
    ####1.3 SIMs
    csn.send_command    command=adb -s ${serial_number} shell input tap 390 1390    connection=cygwin
    sleep   2s
    ####1.4 T-Mobile
    csn.send_command    command=adb -s ${serial_number} shell input tap 390 836    connection=cygwin
    sleep   2s
    ####1.5 swipe Access Point Names
    FOR  ${i}    IN RANGE    ${4}
        csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800    connection=cygwin
        sleep    1s
    END
    ####1.6 click Access Point Names
    csn.send_command    command=adb -s ${serial_number} shell input tap 390 2204    connection=cygwin
    sleep   2s
    ####1.6 switch Access Point Names
    csn.send_command    command=adb -s ${serial_number} shell input tap ${usedapn}    connection=cygwin
    sleep   2s

Switch QCOM SDX80 airplane mode status on
    [Arguments]     ${ue_index}=${0}    ${airplane_enable}=${False}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Get all X80 pointer variable
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    Connect to control pc via cygwin    ue_index=${ue_index}
    IF    '${passed}' == '${airplane_enable}'
        csn.send_command    command=adb -s ${serial_number} shell input keyevent ${home}    connection=cygwin
        sleep   4s
        #####Swipe up to unlock the phone#####
        csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
        sleep   4s
        #### KEYCODE_APP_SWITCH,recent APP application
        csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=cygwin
        #### clear all KEYCODE_APP_SWITCH,recent APP application
        FOR  ${i}    IN RANGE    ${9}
            csn.send_command    command=adb -s ${serial_number} shell input swipe 100 1300 900 1300    connection=cygwin
            sleep    1s
        END
        sleep    2s
        FOR  ${i}    IN RANGE    ${2}
            csn.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=cygwin
            sleep   1s
        END
        csn.send_command    command=adb -s ${serial_number} shell am start -a android.settings.AIRPLANE_MODE_SETTINGS    connection=cygwin
        sleep   4s
        #####Tap the airplane mode switch to enable airplane mode#####
        csn.send_command    command=adb -s ${serial_number} shell input tap ${airplane}    connection=cygwin
        Sleep    2s
    END
    [Teardown]    csn.disconnect    connection=cygwin

recommission for 72a to 72e
    [Arguments]
    ...    ${json_file}=${CURDIR}/CB012149_72a_to_72e_parameters_recommission.json
    ...    ${gnb_index}=${0}
    ...    ${skip_parameter_relation_errors}=True
    ...    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}    connection=${connection}
    coam.perform_delta_recommissioning    delta_file=${json_file}    timeout=${300}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}    connection=${connection}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
