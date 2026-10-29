*** Settings ***
Documentation
...    author: yayun zhang
...    contact: yayun.zhang@nokia-sbell.com
...    squad group: SG_03

Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn
Library    taf.config.scf    WITH NAME    scf
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.gnb.oam.commissioning   WITH NAME    commissioning
Library     taf.hw.rf_attenuator    WITH NAME    att
Library    taf.analyzer.pcap    WITH NAME    wireshark
Resource    taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000574/Resources/variables_cloudUTE.py
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000574/Resources/prarameters_variables_cloudUTE.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot

*** Variables ***
${TS_LOG_PATH_BASE}      ${OUTPUT DIR}/Case_Logs
${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${gnb1_asik_addr_noLMP}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gnb1_asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${gnb_path}    /tmp/
${iperf_path}    ${tl.ues[0].iperf_details.iperf_path}
${gnb_instance}     ${tl.gnbs[0].instance_id}
${cell1_distname}    MRBTS-${gnb_instance}/NRBTS-${gnb_instance}/NRCELL-1
${bts_distname}    MRBTS-${gnb_instance}/NRBTS-${gnb_instance}
${ALIAS_ASIK}    ASIK
${tshark_path}   /usr/bin/tshark
${command_template_X}    {tshark_path} -r {pcap_file} -Y  \"f1ap\"  -T pdml
${command_template_Y}    {tshark_path} -r {pcap_file} -Y \"x2ap\" -T pdml
${command_template_Z}    {tshark_path} -r {pcap_file} -Y  \"e1ap\"  -T pdml
######eNB parameter######
${eNB_cell1_distname}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
${eNB_parameter}    administrativeState
${eNB1_asik_addr}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${eNB2_asik_addr}    ${tl.enbs[1].airscale.common_units[0].lmp_connection.addr}
${gNB_master_log}    /ffs/run/config/toor4nsn

###TL362 PA ###
${vendor_10318}                     HBTE
${att_api_port_10318}               ${tl.attenuator[1].port}
${model_10318}                      ${tl.attenuator[1].model}
${att_ipaddr_10318}                 ${tl.attenuator[1].ip_addr}
${att_port_1_cell1_10318}         ${tl.attenuator[1].attenuator_ports[1]}
${att_port_2_cell1_10318}         ${tl.attenuator[1].attenuator_ports[2]}
${att_port_3_cell1_10318}         ${tl.attenuator[1].attenuator_ports[3]}
${att_port_4_cell1_10318}         ${tl.attenuator[1].attenuator_ports[4]}
${att_port_5_cell3_10318}         ${tl.attenuator[1].attenuator_ports[5]}
${att_port_6_cell3_10318}         ${tl.attenuator[1].attenuator_ports[6]}
${att_port_7_cell3_10318}         ${tl.attenuator[1].attenuator_ports[7]}
${att_port_8_cell3_10318}         ${tl.attenuator[1].attenuator_ports[8]}
${att_port_9_ENB1cell1_10318}       ${tl.attenuator[1].attenuator_ports[9]}
${att_port_10_ENB1cell1_10318}       ${tl.attenuator[1].attenuator_ports[10]}
${att_port_11_ENB2cell1_10318}       ${tl.attenuator[1].attenuator_ports[11]}
${att_port_12_ENB2cell1_10318}       ${tl.attenuator[1].attenuator_ports[12]}

###UE ###
${ue_type}    ${tl.ues[1].capabilities[0]}
${duration}    360
${deviation}    15
@{allow_fault_list}    7311    7107    4681
${sys_logs_path}    /tmp/btslog2/
${UTE_logs_path}    /home/ute/ERR_WRN_logs/

*** Keywords ***
SUITE SETUP FOR UTE
    [Documentation]    only used for cloud ute case
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup
    Generate Suite Log Path
    set suite variable    ${epc_log_path}    ${SUITE_LOG_PATH}
    set suite variable    ${TS_LOG_PATH_BASE}     ${SUITE_LOG_PATH}

## GNB BTS Precondition ##
Online modify NIDD on gnb1 and gnb2
    [Arguments]    ${Modify_Para_Online}='NULL'    ${Modify_Para_Online_GNB2}='NULL'
    ...    ${ModifySCF_Aftercommission}=False    ${ModifySCF_Aftercommission_for_GNB2}=False
    Common Case TestLine Setup    ModifySCF_Aftercommission=${ModifySCF_Aftercommission}
    ...    ModifySCF_Aftercommission_for_GNB2=${ModifySCF_Aftercommission_for_GNB2}
    ...    Modify_Para_Online=${Modify_Para_Online}    Modify_Para_Online_GNB2=${Modify_Para_Online_GNB2}
    sleep    5s

Load SCF for each TL
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'
    ...    Common Case TestLine Setup    is_commission=False     is_commission_for_second_gnb=True
    ...     golden_scf_name=${tl_36011_scf_gnb1}    golden_scf_name_gnb2=${tl_36012_scf_gnb2}    is_pdl_checking_needed=False
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
    ...    Common Case TestLine Setup    is_commission=False    is_commission_for_second_gnb=True
    ...     golden_scf_name=${tl_34711_scf_gnb1}    golden_scf_name_gnb2=${tl_34712_scf_gnb2}    is_pdl_checking_needed=False
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
    ...    Common Case TestLine Setup    is_commission=False     is_commission_for_second_gnb=True
    ...     golden_scf_name=${tl_23311_scf_gnb1}    golden_scf_name_gnb2=${tl_23312_scf_gnb2}    is_pdl_checking_needed=False

Change PA to Menb Handover
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'
    ...    Adjust the TL HBTE attenuation value    enb1_cell1_value=${10}   enb2_cell1_value=${0}
    ...    gnb2_cell1_value=${0}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
    ...    Adjust the TL HBTE attenuation value    enb1_cell1_value=${5}   enb2_cell1_value=${0}
    ...    gnb2_cell1_value=${0}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
    ...    Adjust the TL HBTE attenuation value    enb1_cell1_value=${5}   enb2_cell1_value=${0}
    ...    gnb2_cell1_value=${0}

Prepare the atten for each TL
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'
    ...    Adjust the TL HBTE attenuation value    enb1_cell1_value=${0}   gnb2_cell1_value=${0}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
    ...    Adjust the TL HBTE attenuation value    enb1_cell1_value=${0}   gnb2_cell1_value=${0}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
    ...    Adjust the TL HBTE attenuation value    enb1_cell1_value=${0}   gnb2_cell1_value=${0}



Adjust the TL HBTE attenuation value
    [Arguments]    ${enb1_cell1_value}=${127}    ${enb2_cell1_value}=${127}    ${gnb1_cell1_value}=${127}
    ...    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}
    ####create cell list#####
    @{att_ports_enb1_cell1}    Create List    ${att_port_1_}    ${att_port_2_}
    @{att_ports_enb2_cell1}    Create List    ${att_port_3_}    ${att_port_4_}
    @{att_ports_gnb1_cell1}    Create List    ${att_port_13_}    ${att_port_14_}
    ...    ${att_port_15_}    ${att_port_16_}
    @{att_ports_gnb1_cell2}    Create List    ${att_port_5_}    ${att_port_6_}
    ...    ${att_port_7_}    ${att_port_8_}
    @{att_ports_gnb2_cell1}    Create List    ${att_port_9_}    ${att_port_10_}
    ...    ${att_port_11_}    ${att_port_12_}

    ###create value list####
    @{values_enb1_cell1}    Create List    ${enb1_cell1_value}    ${enb1_cell1_value}
    @{values_enb2_cell1}    Create List    ${enb2_cell1_value}    ${enb2_cell1_value}
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_enb1_cell1}    values=${values_enb1_cell1}
    ...    att_connection_port=${att_port_1_}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_enb2_cell1}    values=${values_enb2_cell1}
    ...    att_connection_port=${att_port_1_}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${att_port_1_}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${att_port_1_}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${att_port_1_}    att_ipaddr=${att_ipaddr}


Check gnb COAM classical start normally
    sleep    1min
    wait until keyword succeeds    15min   20s    Check the gnb RU status ready


Check the gnb RU status ready
    Connect to gnb coam via ssl
    wait until keyword succeeds    15min   30s    COAM Check GNB RU status
    [Teardown]    COAM Teardown gnb connections

Check the gnb cell status onair
    [Arguments]    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${cell_status} =    selenium_coam.get_cell_info
    sleep    8s
    selenium_coam.logout
    Get info status check    info_status=${cell_status}

Wait the gNB cell onair
    [Arguments]    ${WEBUI_COAM}=${WEBUI_COAM}
    wait until keyword succeeds    15min   1min    Check the gnb cell status onair    WEBUI_COAM=${WEBUI_COAM}

Get info status check
    [Arguments]    ${info_status}
    ${status} =   get from dictionary    ${info_status}    Status
    ${opr_state} =   get from dictionary    ${status}    Operational state
    should be equal    ${opr_state}    Enabled
    ${avi_state} =   get from dictionary    ${status}   Availability status
    should be equal    ${avi_state}    Online
    ${adm_state} =   get from dictionary    ${status}    Administrative state
    should be equal    ${adm_state}    Unlocked

gNB connections
    [Arguments]    ${ip_addr}=${asik_addr}    ${gnb}=ASIK
    csn.connect To    hostname=${ip_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=${gnb}

Connect to ASIK slave
    [Arguments]    ${asik_slave}=${asik_slave}    ${proxy}=ASIK
    csn.Connect to    hostname=${fct_addr}    username=${asik_username}
    ...    password=${asik_password}    alias=${asik_slave}    proxy=${proxy}

Start To Capture Wireshark Logs
    [Arguments]    ${filename}
    ${release_info}    Get gnb release
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'    Start capture gNB log on master    filename=${filename}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'    Start capture gNB log on slave    filename=${filename}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'   Start capture gNB log on slave    filename=${filename}

Start capture gNB log on slave
    [Arguments]    ${filename}
    gNB connections
    Connect to ASIK slave
    csn.send command    command=tcpdump -i any sctp -w ./${filename}   connection=${asik_slave}

Stop and download Logs on gNB
    [Arguments]    ${filename}
    ${release_info}    Get gnb release
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'    Stop and download Logs on gNB on master    filename=${filename}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'    Stop and download the Logs on slave    filename=${filename}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'    Stop and download the Logs on slave     filename=${filename}


Stop and download the Logs on slave
    [Arguments]    ${filename}
    gNB connections
    Connect to ASIK slave
    csn.send command    command=killall tcpdump     connection=${asik_slave}
    sleep    3s
    csn.send command    command=cp ./${filename} ${gNB_master_log}/${filename}    connection=${asik_slave}
    sleep    10s
    csn.download_file   remote_path=${gNB_master_log}/${filename}   local_path=${epc_log_path}${filename}   connection=${ALIAS_ASIK}
    sleep    3s


Stop and download Logs on gNB on master
    [Arguments]    ${filename}
    wait until keyword succeeds    1min   10s    Stop and download the Logs    filename=${filename}

Unlock the gNB cell
    [Arguments]    ${cell_idx}=${1}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${cell_idx}  Convert To Integer    ${cell_idx}
    selenium_coam.unlock_cell    cell_idx=${cell_idx}
    Sleep  30 sec
    [Teardown]  Run keyword and ignore error    selenium_coam.logout

Check the bts counter ${counter_id} from ${counter_path} as ${expected_value}
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id}
    ...                 full_path=${counter_path}
    ${values}    get dictionary values   ${counters}
    should contain   ${values}    ${expected_value}

Check counter ${counter_id} as ${expected_value}
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id}
    ${values}    get dictionary values   ${counters}
    should contain   ${values}    ${expected_value}

Check counter ${counter_id} not be trigered
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id}
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}==0

Check the bts counters when actInterMeNBMobility equal to false
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    Check counter M55112C03501 as 1
    Check counter M55112C03502 not be trigered
    Check counter M55128C00503 not be trigered
    Check counter M55128C00504 not be trigered
    Check counter M55128C00502 not be trigered
    sleep    5s
    [Teardown]    Run keyword and ignore error   selenium_coam.logout

Check the bts counters when actInterMeNBMobility equal to true
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    Check counter M55112C03501 as 1
    Check counter M55112C03502 as 1
    Check counter M55128C00503 as 1
    Check counter M55128C00504 as 1
    Check counter M55128C00502 as 1
    sleep    5s
    [Teardown]    Run keyword and ignore error   selenium_coam.logout

Get gnb release
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
    ${release_info}     set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info
## huawei ##
huawei UE setup
    power_ue.Prepare UE    ue_type=${ue_type}

huawei UE teardown
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}

huawei UE attach
    [Arguments]    ${gnb_index}=${0}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}  gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=${ue_type}   gnb_index=${gnb_index}    4G_check=False    5Grach_ed=${5Grach_ed}

# Askey UE Inseego
Precondition for power UE
    [Arguments]    ${ue_type}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    capatibility_index=${0}    reset_sol=pc_reset    detach_request=${true}

Start UL data transfer
    [Arguments]    ${ul_throughput}    ${iperf_port}=default
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul   throughput=${ul_throughput}
    ...    duration=${duration}    iperf_port=${iperf_port}

Start DL date transfer
    [Arguments]    ${dl_throughput}    ${iperf_port}=default
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl   throughput=${dl_throughput}
    ...    duration=${duration}    iperf_port=${iperf_port}
Check the UL throughput
    [Arguments]    ${ul_expected_throughput}    ${cell_id}=${cell1_id}
    power_ue.Check throughput    ue_type=${ue_type}    direction=ul    throughput=${ul_expected_throughput}
    ...    deviation=${deviation}    cellid=${cell_id}

Check the DL throughput
    [Arguments]    ${dl_expected_throughput}        ${cell_id}=${cell1_id}
    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=${dl_expected_throughput}
    ...    deviation=${deviation}    cellid=${cell_id}

Start DL and UL data transfer
    [Arguments]    ${dl_throughput}    ${ul_throughput}
    log to console    \n *** Start DL & UL transmission
    Start DL date transfer    dl_throughput=${dl_throughput}
    Start UL data transfer    ul_throughput=${ul_throughput}

Check the DL and UL throughput
    [Arguments]    ${dl_expected_throughput}    ${ul_expected_throughput}
    Check the DL throughput    dl_expected_throughput=${dl_expected_throughput}
    Check the UL throughput    ul_expected_throughput=${ul_expected_throughput}

COAM get cell id
    [Arguments]    ${lcrid}
    ${cell1_id}    COAM Get nrcellid with the lcrid    lcrid=${lcrid}
    set suite variable    ${cell1_id}

## modify PA ##
Adjust Radiorack Attenuation
    [Arguments]      ${value_1}=${40}    ${att_port1}=${att_port_5}
    Log    \n *** Adjust Attenuation    console=yes
    att.setup_attenuator    ip_addr=${ATT_IPADDR}   port=${ATT_API_PORT}
    ...    attenuation_port_numbers=${att_port_1}    max_attenuation=${110}    vendor=${vendor}
    att.set_attenuation     port=${att_port_1}    value=${value_1}
    ${value_port1}    att.read_attenuation    port=${att_port1}
    should be equal    ${value_port1}    ${value_1}


Adjust the TopYong Attenuation Value
    [Arguments]     ${ports}    ${value}    ${attenuation_port_numbers_oneport}=${ports}
    ...     ${atten_ip}=${att_ipaddr_1}    ${att_api_port}=${HBTE_att_api_port}    #${vendor}=${vendor_344}
    @{attenuation_port_numbers_oneport}    create list    ${attenuation_port_numbers_oneport}
    att.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${attenuation_port_numbers_oneport}   max_attenuation=${max_attenuation_value}
    ...    vendor=${vendor_344}
    att.set_attenuation     port=${ports}    value=${value}
    ${value_port_1}    att.read_attenuation    port=${ports}
    should be equal    ${value_port_1}    ${value}
    sleep    5s

Set the Attenuation as default value
    ${release_info}    Get gnb release
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'    run keywords    Adjust the TopYong Attenuation Value
    ...    ports=${TOPYONG_ANT2}    value=${30}    AND    Adjust the TopYong Attenuation Value    ports=${TOPYONG_ANT13}
    ...    value=${5}    AND    Adjust the TopYong Attenuation Value    ports=${TOPYONG_ANT14}    value=${5}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'    run keywords    Adjust Radiorack Attenuation   AND
    ...    Adjust the HBTE attenuation value    value_1=${20}    value_2=${20}    value_3=${20}    value_4=${20}
    ...    att_port1=${att_port_1}    att_port2=${att_port_2}    att_port3=${att_port_3}    att_port4=${att_port_4}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'    Adjust the TopYong Attenuation Value
    ...    ports=${TOPYONG_ANT1}    value=${30}


Set the Attenuation as max value
    ${release_info}    Get gnb release
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'    Adjust the TopYong Attenuation Value
    ...    ports=${TOPYONG_ANT2}    value=${110}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'    Adjust Radiorack Attenuation    value_1=${110}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'    Adjust the TopYong Attenuation Value
    ...    ports=${TOPYONG_ANT1}    value=${110}

Change the Attenuation value
    ${release_info}    Get gnb release
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'    Adjust the TopYong Attenuation Value
    ...    ports=${TOPYONG_ANT2}    value=${0}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'    Adjust Radiorack Attenuation    value_1=${10}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'    Adjust the TopYong Attenuation Value
    ...    ports=${TOPYONG_ANT1}    value=${0}


Adjust the HBTE attenuation value
    [Arguments]      ${value_1}=${127}    ${value_2}=${127}   ${value_3}=${0}   ${value_4}=${0}   ${att_port1}=${HBTE_att_port_1}
    ...    ${att_port2}=${HBTE_att_port_2}    ${att_port3}=${HBTE_att_port_3}    ${att_port4}=${HBTE_att_port_4}
    [Documentation]    Auther:cris.cai@nokia-sbell.com
    ...                modify HBTE PA 4 port value default value[0-63db] if not set the max_attenuation value below
    ...                for value and not default port 1234, plz set in your case level. setup connection only port1
    ...                if connect on local plz disconnect firstly
    att.setup_attenuator    ip_addr=${HBTE_att_ipaddr}    port=${HBTE_att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${HBTE_max_attenuation_value}    vendor=${vendor_344}
    att.set_attenuation     port=${att_port1}    value=${value_1}
    att.set_attenuation     port=${att_port2}    value=${value_2}
    att.set_attenuation     port=${att_port3}    value=${value_3}
    att.set_attenuation     port=${att_port4}    value=${value_4}
    ${value_port1}    att.read_attenuation    port=${att_port1}
    should be equal    ${value_port1}    ${value_1}
    ${value_port2}    att.read_attenuation    port=${att_port2}
    should be equal    ${value_port2}    ${value_2}
    ${value_port3}    att.read_attenuation    port=${att_port3}
    should be equal    ${value_port3}    ${value_3}
    ${value_port4}    att.read_attenuation    port=${att_port4}
    should be equal    ${value_port4}    ${value_4}

Unlock eNB and wait cell onair
    Unlock the eNB cell
    Wait until enb cell on air status

Commit SCF to eNB
    [Arguments]    ${eNB_asik_addr}    ${connection}    ${scf_file}
    enblte.connect_to    bts_host=${eNB_asik_addr}
    ...    bts_port=443  use_ssl=True    name=${connection}
    enblte.perform_commissioning    scf_file=${tl_scf_dir_path}${scf_file}    skip_parameter_relation_errors=${True}
    ...     should_activate=${True}    connection=${connection}    timeout=300

Lock the eNB cell
    Connect and Modify the parameter on enblte    dist_name=${eNB_cell1_distname}   parameter=${eNB_parameter}     value=locked

Unlock the eNB cell
    Connect and Modify the parameter on enblte    dist_name=${eNB_cell1_distname}   parameter=${eNB_parameter}     value=unlocked


connect to eNB2
    [Arguments]    ${alias}=ENB2
    csn.Connect to    hostname=${tl.enbs[1].airscale.common_units[0].lmp_connection.addr}
    ...    username=${tl.enbs[1].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.enbs[1].airscale.common_units[0].lmp_connection.password}    alias=${alias}

#####Analyze log####
Case recover
    Run Keyword And Ignore Error    Stop and download Logs on eNB    log_name=${eNB1_x2_log}
    Run Keyword And Ignore Error    Stop and download Logs on eNB2    log_name=${eNB2_x2_log}
    Run Keyword And Ignore Error    Stop and download Logs on gNB    filename=${gNB_x2_log}
    Run Keyword And Ignore Error    huawei UE teardown
    Run Keyword And Ignore Error    Set the Attenuation as max value
    Run keyword and ignore error    CI_interface.Common Case Teardown

Check the X2log on Target eNB when actInterMeNBMobility equal to false
    [Arguments]    ${input_file}
    ${all_packets}    wireshark.load_pcap_file    pcap_file=${epc_log_path}${input_file}
    ...   tshark_path=${tshark_path}   command_template=${command_template_Y}
    ${handover_request}=     Catenate    x2ap.id == 254
    ${handover_packets}=    wireshark.filter_packets_by_expression    filter_expression=${handover_request}
    ${handover_value}=    wireshark.get_field_value_by_xpath    pdml_list=${handover_packets}
    ...    xpath=.//x2ap.id
    should contain     ${handover_value}    254
    ${SgNB_Addition_Request}=    Catenate    nr-rrc.allowedBC_ListMRDC == 1 && x2ap.SGNB_Addition_Trigger_Ind == 1 && x2ap.procedureCode == 27
    ${SgNB_Addition_packets}=    wireshark.filter_packets_by_expression    filter_expression=${SgNB_Addition_Request}
    ${sg_add_req_val}=    wireshark.get_field_value_by_xpath    pdml_list=${SgNB_Addition_packets}   xpath=.//x2ap.id
    should contain    ${sg_add_req_val}    111
    should contain    ${sg_add_req_val}    207
    should contain    ${sg_add_req_val}    248
    should contain    ${sg_add_req_val}    204
    should contain    ${sg_add_req_val}    203
    ${sg_add_req_val}=    wireshark.get_field_value_by_xpath    pdml_list=${SgNB_Addition_packets}   xpath=.//nr-rrc.allowedBC_ListMRDC
    should not be empty    ${sg_add_req_val}
    ${sg_add_req_val}=    wireshark.get_field_value_by_xpath    pdml_list=${SgNB_Addition_packets}   xpath=.//x2ap.SGNB_Addition_Trigger_Ind
    should contain    ${sg_add_req_val}    1
    ${SgNB_Addition_Request_Rej}=    Catenate    x2ap.radioNetwork == 21
    ${SgNB_Addition_Rej_packets}=    wireshark.filter_packets_by_expression
    ...    filter_expression=${SgNB_Addition_Request_Rej}
    ${SgNB_Addition_Request_Rej_val}    wireshark.get_field_value_by_xpath    pdml_list=${SgNB_Addition_Rej_packets}   xpath=.//x2ap.radioNetwork
    should contain    ${SgNB_Addition_Request_Rej_val}    21
    ${handover_ack}=     Catenate    x2ap.E_RABs_Admitted_List
    ${handover_ack_packets}    wireshark.filter_packets_by_expression    filter_expression=${handover_ack}
    ${handover_ack_value}    wireshark.get_field_value_by_xpath    pdml_list=${handover_ack_packets}   xpath=.//x2ap.E_RABs_Admitted_List
    should not be empty    ${handover_ack_value}
    ${Sec_sg_add_req}=    Catenate    x2ap.procedureCode == 27 && ip.src == ${eNB_asik_addr_2}
    ${Sec_sg_add_req_packets}    wireshark.filter_packets_by_expression    filter_expression=${Sec_sg_add_req}
    ${Sec_sg_add_req_value}    wireshark.get_field_value_by_xpath    pdml_list=${Sec_sg_add_req_packets}   xpath=.//x2ap.procedureCode
    ${len}    get length    ${Sec_sg_add_req_value}
    should be equal    '${len}'    '2'

Check the X2log on gNB when actInterMeNBMobility equal to false
    [Arguments]    ${input_file}
    ${all_packets}    wireshark.load_pcap_file    pcap_file=${epc_log_path}${input_file}
    ...   tshark_path=${tshark_path}   command_template=${command_template_Y}
    ${Sgb_release_req}=    Catenate    x2ap.procedureCode == 31 && x2ap.radioNetwork == 46
    ${Sgb_release_req_packets}=    wireshark.filter_packets_by_expression    filter_expression=${Sgb_release_req}
    ${Sgb_release_req_value}=    wireshark.get_field_value_by_xpath    pdml_list=${Sgb_release_req_packets}    xpath=.//x2ap.radioNetwork
    should contain    ${Sgb_release_req_value}    46
    ${Sgb_release_ack}=    Catenate    ip.src == ${asik_addr} && x2ap.procedureCode == 31
    ${Sgb_release_ack_packets}=    wireshark.filter_packets_by_expression    filter_expression=${Sgb_release_ack}
    ${Sgb_release_ack_value}=    wireshark.get_field_value_by_xpath    pdml_list=${Sgb_release_ack_packets}    xpath=.//x2ap.procedureCode
    should contain    ${Sgb_release_ack_value}    31

Check the X2log on source eNB
    [Arguments]    ${input_file}
    ${all_packets}    wireshark.load_pcap_file    pcap_file=${epc_log_path}${input_file}
    ...   tshark_path=${tshark_path}   command_template=${command_template_Y}
    ${RRC_Reconfig}    Catenate    x2ap.procedureCode == 27 && ip.dst == ${eNB2_asik_addr}
    ${RRC_Reconfig_packets}    wireshark.filter_packets_by_expression    filter_expression=${RRC_Reconfig}
    ${SgNB_UE_X2AP_ID_0}=    wireshark.get_field_value_by_xpath    pdml_list=${RRC_Reconfig_packets}   xpath=.//x2ap.SgNB_UE_X2AP_ID
    ${UE_release}    Catenate    x2ap.procedureCode == 5 && ip.src == ${eNB2_asik_addr}
    ${UE_release_packets}    wireshark.filter_packets_by_expression    filter_expression=${UE_release}
    ${UE_release_value}    wireshark.get_field_value_by_xpath    pdml_list=${UE_release_packets}   xpath=.//x2ap.UE_X2AP_ID
    Set Suite Variable    ${source_MME_SgNB_UE_X2AP_ID}    ${SgNB_UE_X2AP_ID_0[-1]}

Check the X2log on Target eNB
    [Arguments]    ${input_file}
    ${all_packets}    wireshark.load_pcap_file    pcap_file=${epc_log_path}${input_file}
    ...   tshark_path=${tshark_path}   command_template=${command_template_Y}
    ${handover_request}=     Catenate    x2ap.id == 254
    ${handover_packets}=    wireshark.filter_packets_by_expression    filter_expression=${handover_request}
    ${handover_value}=    wireshark.get_field_value_by_xpath    pdml_list=${handover_packets}
    ...    xpath=.//x2ap.id
    should contain     ${handover_value}    254
    ${SgNB_Addition_Request}=    Catenate    x2ap.SGNB_Addition_Trigger_Ind == 1 && x2ap.procedureCode == 27
    ${SgNB_Addition_packets}=    wireshark.filter_packets_by_expression    filter_expression=${SgNB_Addition_Request}
    ${SgNB_UE_X2AP_ID}=    wireshark.get_field_value_by_xpath    pdml_list=${SgNB_Addition_packets}   xpath=.//x2ap.SgNB_UE_X2AP_ID
    ${UL_GTP_TEID}    wireshark.get_field_value_by_xpath    pdml_list=${SgNB_Addition_packets}
    ...    xpath=.//x2ap.s1_UL_GTPtunnelEndpoint_element//x2ap.gTP_TEID
    ${UL_transportLayerAddressIPv4}    wireshark.get_field_value_by_xpath    pdml_list=${SgNB_Addition_packets}
    ...    xpath=.//x2ap.s1_UL_GTPtunnelEndpoint_element//x2ap.transportLayerAddressIPv4
    ${UL_transportLayerAddress}    wireshark.get_field_value_by_xpath    pdml_list=${SgNB_Addition_packets}
    ...    xpath=.//x2ap.s1_UL_GTPtunnelEndpoint_element//x2ap.transportLayerAddress
    ${DL_GTP_TEID}    wireshark.get_field_value_by_xpath    pdml_list=${SgNB_Addition_packets}
    ...    xpath=.//x2ap.meNB_DL_GTP_TEIDatMCG_element//x2ap.gTP_TEID
    ${DL_transportLayerAddressIPv4}    wireshark.get_field_value_by_xpath    pdml_list=${SgNB_Addition_packets}
    ...    xpath=.//x2ap.meNB_DL_GTP_TEIDatMCG_element//x2ap.transportLayerAddressIPv4
    ${DL_transportLayerAddress}    wireshark.get_field_value_by_xpath    pdml_list=${SgNB_Addition_packets}
    ...    xpath=.//x2ap.meNB_DL_GTP_TEIDatMCG_element//x2ap.transportLayerAddress
    ${sg_add_req_val}=    wireshark.get_field_value_by_xpath    pdml_list=${SgNB_Addition_packets}   xpath=.//nr-rrc.allowedBC_ListMRDC
    should not be empty    ${sg_add_req_val}
    ${sg_add_req_Trig_val}=    wireshark.get_field_value_by_xpath    pdml_list=${SgNB_Addition_packets}   xpath=.//x2ap.SGNB_Addition_Trigger_Ind
    should contain    ${sg_add_req_Trig_val}    1
    ${handover_ack}=     Catenate    x2ap.E_RABs_Admitted_List
    ${handover_ack_packets}    wireshark.filter_packets_by_expression    filter_expression=${handover_ack}
    ${handover_ack_value}    wireshark.get_field_value_by_xpath    pdml_list=${handover_ack_packets}   xpath=.//x2ap.E_RABs_Admitted_List
    should not be empty    ${handover_ack_value}
    ${rrc_reconfig}    Catenate    nr-rrc.keyToUse == 1 && ip.dst == ${eNB1_asik_addr} && ip.src == ${gnb1_asik_addr_noLMP}
    ${rrc_reconfig_packets}    wireshark.filter_packets_by_expression    filter_expression=${rrc_reconfig}
    ${rrc_reconfig_value}    wireshark.get_field_value_by_xpath    pdml_list=${rrc_reconfig_packets}   xpath=.//nr-rrc.keyToUse
    should contain    ${rrc_reconfig_value}    1
    ${rrc_reconfig_S}    Catenate    nr-rrc.keyToUse == 1 && ip.dst == ${eNB2_asik_addr} && ip.src == ${eNB1_asik_addr}
    ${rrc_reconfig_S_packets}    wireshark.filter_packets_by_expression    filter_expression=${rrc_reconfig_S}
    ${rrc_reconfig_S_value}    wireshark.get_field_value_by_xpath    pdml_list=${rrc_reconfig_S_packets}   xpath=.//nr-rrc.keyToUse
    should contain    ${rrc_reconfig_S_value}    1
    ${rrc_config_complete}    Catenate    x2ap.procedureCode == 28 && ip.src == ${eNB1_asik_addr}
    ${rrc_config_complete_packets}    wireshark.filter_packets_by_expression    filter_expression=${rrc_config_complete}
    ${rrc_config_complete_value}    wireshark.get_field_value_by_xpath    pdml_list=${rrc_config_complete_packets}   xpath=.//x2ap.procedureCode
    should contain    ${rrc_config_complete_value}    28
    ${UE_release}     Catenate    x2ap.procedureCode == 5 && ip.dst == ${eNB2_asik_addr}
    ${UE_release_packets}    wireshark.filter_packets_by_expression    filter_expression=${UE_release}
    ${UE_release_value}    wireshark.get_field_value_by_xpath    pdml_list=${UE_release_packets}   xpath=.//x2ap.procedureCode
    should contain    ${UE_release_value}    5
    Set Suite Variable    ${Target_MME_SgNB_UE_X2AP_ID}    ${SgNB_UE_X2AP_ID[-1]}
    Set Suite Variable    ${Target_MME_UL_GTP_TEID}    ${UL_GTP_TEID[-1]}
    Set Suite Variable    ${Target_MME_UL_transportLayerAddress}    ${UL_transportLayerAddress[-1]}

Check the e1ap log on gNB
    [Arguments]    ${input_file}
    ${all_packets}    wireshark.load_pcap_file    pcap_file=${epc_log_path}${input_file}
    ...   tshark_path=${tshark_path}   command_template=${command_template_Z}
    ${bear_setup}    Catenate    e1ap.procedureCode == 8
    ${bear_setup_packets}    wireshark.filter_packets_by_expression    filter_expression=${bear_setup}
    ${bear_setup_gTP_TEID}    wireshark.get_field_value_by_xpath    pdml_list=${bear_setup_packets}
    ...    xpath=.//e1ap.s1_UL_UP_TNL_Information//e1ap.gTP_TEID
    ${bear_setup_transportLayerAddress}    wireshark.get_field_value_by_xpath    pdml_list=${bear_setup_packets}
    ...    xpath=.//e1ap.s1_UL_UP_TNL_Information//e1ap.transportLayerAddress
    ${Bear_modify_req}=     Catenate    e1ap.id == 18
    ${Bear_modify_req_packets}    wireshark.filter_packets_by_expression    filter_expression=${Bear_modify_req}
    ${Bear_modify_req_value}    wireshark.get_field_value_by_xpath    pdml_list=${Bear_modify_req_packets}   xpath=.//e1ap.gTP_TEID
    ${Bear_modify_req_dl_TX_value}    wireshark.get_field_value_by_xpath    pdml_list=${Bear_modify_req_packets}   xpath=.//e1ap.dL_TX_Stop
    ${Bear_modify_res}=     Catenate    e1ap.id == 19
    ${Bear_modify_res_packets}    wireshark.filter_packets_by_expression    filter_expression=${Bear_modify_req}
    ${Bear_modify_res_value}    wireshark.get_field_value_by_xpath    pdml_list=${Bear_modify_req_packets}   xpath=.//e1ap.gTP_TEID
    should not be empty    ${Bear_modify_req_value}
    should contain    ${Bear_modify_req_dl_TX_value}    1
    should not be empty    ${Bear_modify_res_value}
    Set Suite Variable    ${gNB_bear_setup_gTP_TEID}    ${bear_setup_gTP_TEID[-1]}
    Set Suite Variable    ${gNB_bear_setup_transportLayerAddress}    ${bear_setup_transportLayerAddress[-1]}

Check the f1ap log on gNB
    [Arguments]    ${input_file}
    ${all_packets}    wireshark.load_pcap_file    pcap_file=${epc_log_path}${input_file}
    ...   tshark_path=${tshark_path}   command_template=${command_template_X}
    ${Bear_modify}=     Catenate    f1ap.procedureCode == 7 && f1ap.gTP_TEID
    ${Bear_modify_packets}    wireshark.filter_packets_by_expression    filter_expression=${Bear_modify}
    ${Bear_modify_value}    wireshark.get_field_value_by_xpath    pdml_list=${Bear_modify_packets}   xpath=.//f1ap.gTP_TEID
    should not be empty    ${Bear_modify_value}

Check the X2log on gNB
    [Arguments]    ${input_file}
    ${all_packets}    wireshark.load_pcap_file    pcap_file=${epc_log_path}${input_file}
    ...   tshark_path=${tshark_path}   command_template=${command_template_Y}
    ${Sgb_release_req}=    Catenate    x2ap.procedureCode == 31 && x2ap.radioNetwork == 46
    ${Sgb_release_req_packets}=    wireshark.filter_packets_by_expression    filter_expression=${Sgb_release_req}
    ${Sgb_release_req_value}=    wireshark.get_field_value_by_xpath    pdml_list=${Sgb_release_req_packets}    xpath=.//x2ap.radioNetwork
    should contain    ${Sgb_release_req_value}    46
    ${Sgb_release_req_UE}=    wireshark.get_field_value_by_xpath    pdml_list=${Sgb_release_req_packets}    xpath=.//x2ap.UE_ContextKeptIndicator
    should contain    ${Sgb_release_req_UE}    0
    ${CFRA_preamble_index}=    Catenate    nr-rrc.ra_PreambleIndex == 32 && x2ap.X2AP_PDU == 1
    ${CFRA_preamble_index_packets}=    wireshark.filter_packets_by_expression
    ...    filter_expression=${CFRA_preamble_index}
    ${CFRA_preamble_index_value}=    wireshark.get_field_value_by_xpath    pdml_list=${CFRA_preamble_index_packets}
    ...    xpath=.//nr-rrc.ra_PreambleIndex
    should contain    ${CFRA_preamble_index_value}    32
    ${Sgb_release_ack}=    Catenate    ip.src == ${asik_addr} && x2ap.procedureCode == 31
    ${Sgb_release_ack_packets}=    wireshark.filter_packets_by_expression    filter_expression=${Sgb_release_ack}
    ${Sgb_release_ack_value}=    wireshark.get_field_value_by_xpath    pdml_list=${Sgb_release_ack_packets}    xpath=.//x2ap.procedureCode
    should contain    ${Sgb_release_ack_value}    31

Check the X2log on gNB for 1200
    [Arguments]    ${input_file}
    ${all_packets}    wireshark.load_pcap_file    pcap_file=${epc_log_path}${input_file}
    ...   tshark_path=${tshark_path}   command_template=${command_template_Y}
    ${Sgb_release_req}=    Catenate    x2ap.procedureCode == 31 && x2ap.radioNetwork == 46
    ${Sgb_release_req_packets}=    wireshark.filter_packets_by_expression    filter_expression=${Sgb_release_req}
    ${Sgb_release_req_value}=    wireshark.get_field_value_by_xpath    pdml_list=${Sgb_release_req_packets}    xpath=.//x2ap.radioNetwork
    should contain    ${Sgb_release_req_value}    46
    ${Sgb_release_req_UE}=    wireshark.get_field_value_by_xpath    pdml_list=${Sgb_release_req_packets}    xpath=.//x2ap.UE_ContextKeptIndicator
    should contain    ${Sgb_release_req_UE}    0
    ${Sgb_release_ack}=    Catenate    ip.src == ${gnb1_asik_addr_noLMP} && x2ap.procedureCode == 31
    ${Sgb_release_ack_packets}=    wireshark.filter_packets_by_expression    filter_expression=${Sgb_release_ack}
    ${Sgb_release_ack_value}=    wireshark.get_field_value_by_xpath    pdml_list=${Sgb_release_ack_packets}    xpath=.//x2ap.procedureCode
    should contain    ${Sgb_release_ack_value}    31

Check the logs when actInterMeNBMobility equal to true
    [Arguments]    ${eNB1_x2_log}    ${eNB2_x2_log}    ${gNB_x2_log}
    Check the X2log on Target eNB    input_file=${eNB1_x2_log}
    Check the X2log on source eNB    input_file=${eNB2_x2_log}
    Check the X2log on gNB    input_file=${gNB_x2_log}
    Check the e1ap log on gNB    input_file=${gNB_x2_log}
    Check the f1ap log on gNB    input_file=${gNB_x2_log}
    should be equal    ${Target_MME_SgNB_UE_X2AP_ID}    ${source_MME_SgNB_UE_X2AP_ID}
    should be equal    ${Target_MME_UL_GTP_TEID}    ${gNB_bear_setup_gTP_TEID}
    should be equal    ${Target_MME_UL_transportLayerAddress}    ${gNB_bear_setup_transportLayerAddress}

Check the logs when actInterMeNBMobility equal to true for 1200
    [Arguments]    ${eNB1_x2_log}    ${eNB2_x2_log}    ${gNB_x2_log}
    Check the X2log on Target eNB    input_file=${eNB1_x2_log}
    Check the X2log on source eNB    input_file=${eNB2_x2_log}
    Check the X2log on gNB for 1200    input_file=${gNB_x2_log}
    Check the e1ap log on gNB    input_file=${gNB_x2_log}
    Check the f1ap log on gNB    input_file=${gNB_x2_log}
    should be equal    ${Target_MME_SgNB_UE_X2AP_ID}    ${source_MME_SgNB_UE_X2AP_ID}
    should be equal    ${Target_MME_UL_GTP_TEID}    ${gNB_bear_setup_gTP_TEID}
    should be equal    ${Target_MME_UL_transportLayerAddress}    ${gNB_bear_setup_transportLayerAddress}

get and analysis syslog
    Check ERR Or WRN From Syslog
    ...    sys_logs_path=${sys_logs_path}      Expected_ERR_WRN_deviation=0.2
    ...    Expected_ERR_WRN_diff_number=0
    ...    UTE_logs_path=${UTE_logs_path}      testline=${testline_name}
    ...    base_file=None     Fail_Case=False       Clear_log=True     remove_ERR_WRN_excel=True
    ...    filter_list=None      ignore_list=None      Delete_old_ERR_WRN=1
    ...    FilesSystem=/dev/vda2      Max_used_space_ratio=0.75      check_diff=True
    ...    timeout=30 minutes      Expected_ERR_WRN_number=0

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
