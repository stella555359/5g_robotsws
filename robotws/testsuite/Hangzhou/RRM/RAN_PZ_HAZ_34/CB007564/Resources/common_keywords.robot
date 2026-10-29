*** Settings ***
Documentation
...    author: Xing Jing
...    contact: jing.1.xing@nokia-sbell.com
...    squad group: SG_03


Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn
Library    taf.gnb.oam.commissioning   WITH NAME    commissioning
Library    taf.config.testline    WITH NAME    testline
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/ssh_pcf.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Library    ssh_pcf.pcf   WITH NAME    PCF
Library    taf.analyzer.pcap   WITH NAME    parser
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/eNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot

*** Variables ***
${TS_LOG_PATH_BASE}    /opt/workspace/CRT/Master/Case_Logs/
${TS_CASE_LOG_PATH}    /opt/workspace/CRT/Master/Case_Logs/
${tl_scf_file_name_gnb}    Configuration_scf_CNI75911.xml
${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${WEBUI_COAM}             https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}             ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}              ${tl.gnbs[0].cu.oam_http_connection_details.password}
${gnb_path}    /tmp/
${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
${enb_dist_name}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-3
${enb_para}    administrativeState
@{enb_value}    locked    unlocked
## Attenuator parameter ##
${att_ipaddr}    ${tl.attenuator[0].ip_addr}
${att_api_port}    ${tl.attenuator[0].port}
${att_connection_port}    ${tl.attenuator[0].attenuator_ports[1]}
${vendor}        ${tl.attenuator[0].vendor}
${max_attenuation_value}     ${120}
${att_port_1}    ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2}    ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3}    ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4}    ${tl.attenuator[0].attenuator_ports[4]}
${att_port_5}    ${tl.attenuator[0].attenuator_ports[5]}
${att_port_6}    ${tl.attenuator[0].attenuator_ports[6]}
${att_port_7}    ${tl.attenuator[0].attenuator_ports[7]}
${att_port_8}    ${tl.attenuator[0].attenuator_ports[8]}
${att_port_9}    ${tl.attenuator[0].attenuator_ports[9]}
${att_port_10}    ${tl.attenuator[0].attenuator_ports[10]}
${att_port_11}    ${tl.attenuator[0].attenuator_ports[11]}
${att_port_12}    ${tl.attenuator[0].attenuator_ports[12]}
${att_port_13}    ${tl.attenuator[0].attenuator_ports[13]}
${att_port_14}    ${tl.attenuator[0].attenuator_ports[14]}
${att_port_15}    ${tl.attenuator[0].attenuator_ports[15]}
${att_port_16}    ${tl.attenuator[0].attenuator_ports[16]}

*** Keywords ***
Set the deault PA
    Set the attenuation value    att_ports=${att_ports}    values=${values}

Prepare with PM counter time to caculate
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    300-${utc0}%300
    sleep    ${left_timer}

Check gnb counter as expected_value
    [Arguments]    ${counter_id}    ${dic_path}    ${expected_value}    ${gnb_id}=${1}    ${counter_end}=${1}    ${timeout}=${300}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].cu.oam_ssh_connection_details.addr}
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${dic_path}    timeout=${timeout}
    ${counter_latest}    get slice from list    ${counter_value}    0    ${counter_end}
#    should contain    '${counter_latest}'   ${expected_value}
    Should Be True    ${counter_latest}[0] >= ${expected_value}
    [Teardown]    COAM Teardown gnb connections

Lock the enb cell
    Modify the enblte parameter    dist_name=${enb_dist_name}    parameter=${enb_para}   value=${enb_value}[0]

Unlock the enb cell
    Modify the enblte parameter    dist_name=${enb_dist_name}    parameter=${enb_para}   value=${enb_value}[1]

Capture multi-RAT Bip File
    [Arguments]    ${log_name}
    Comment    ${log_name}
    Connect to gnb coam via ssl
    Bip Capture with gnbMirroring scripts with retry    syscom_mirroring=false    bb_slot_1=true    bb_slot_5=false
    Sleep    1 sec

Download multi-RAT Bip File
    [Arguments]    ${log_name}    ${asib_interface}=eths2
    ${bip_log_list}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC    log_prefix=${log_name}
    ...    asib_interface=${asib_interface}
    [Return]    ${bip_log_list}

Step1: UE attach
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${4G_check}=False
    Check UE device exist    ue_index=${ue_index}
    Huawei UE setup    ue_type=${ue_type}    ue_index=${ue_index}
    make WA with Samsung S21
    Attach and check power UE    ue_type=${ue_type}    ue_index=${ue_index}    4G_check=${4G_check}

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
