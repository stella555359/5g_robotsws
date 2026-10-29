*** Settings ***
Documentation     author: ming.shi
...                 contact: ming.shi@nokia-sbell.com
...                 squad group: SG_03
...                 feature : SFE_TMO_Common_Keywords

Library     DateTime
Library     taf.analyzer.pcap    WITH NAME    cap
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Library     taf.hw.rf_attenuator    WITH NAME    atten
Library     taf.config.testline    WITH NAME    testline
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.sbts.oam.coam.admin   WITH NAME    coam
Library     taf.pdu  WITH NAME   pdu
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/get_counters_from_pm_file.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/stream_manager.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/eNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/Resources/SFE_TMO_Regression_Variables.py


*** Variables ***
${5Gcell1_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${5Gcell1_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${5Gcell1_ANT3}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${5Gcell1_ANT4}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${5Gcell2_ANT1}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${5Gcell2_ANT2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${5Gcell3_ANT1}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}
${5Gcell3_ANT2}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no}
${5Gcell4_ANT1}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}
${5Gcell4_ANT2}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}
${5Gcell5_ANT1}    ${tl.gnbs[1].dus[0].rus[1].attenuation_ports[0].port_no}
${5Gcell5_ANT2}    ${tl.gnbs[1].dus[0].rus[1].attenuation_ports[1].port_no}
${4Gcell1_ANT1}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[2].port_no}
${4Gcell1_ANT2}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[3].port_no}
${att_ipaddr}      ${tl.attenuator[0].ip_addr}
${att_api_port}    ${tl.attenuator[0].port}
${att_connection_port}       ${tl.attenuator.attenuation_port_numbers}
${att_api_model}    ${tl.attenuator[0].model}
${vendor}          HBTE
${max_attenuation_value}     ${127}


*** Keywords ***
Setup for Env cell on-air for multi gnb
    Setup for Env cell on-air    gnb_index=${0}    tl_scf_file_name=${tl_scf_file_name1}
    Setup for Env cell on-air    gnb_index=${1}    tl_scf_file_name=${tl_scf_file_name2}

Setup for Env cell on-air
    [Arguments]    ${gnb_index}=${0}    ${tl_scf_file_name}=${tl_scf_file_name}
    Prepare the gNB cells onair status    gnb_index=${gnb_index}    tl_scf_file_name=${tl_scf_file_name}
    RUN KEYWORD IF    '${cell_status}'=='False'    Prepare the gNB cells onair status
    ...    gnb_index=${gnb_index}    tl_scf_file_name=${tl_scf_file_name}
    should be equal    '${cell_status}'    'True'

change SFE TMO Ping Pang Paras
    [Arguments]    ${para}    ${para2}
    Online modify parmeters    parameters_to_update=${para}
    Online modify parmeters    parameters_to_update=${para2}    gnb_index=${1}




PA set all cells to max value except specified cell
    [Arguments]    ${cellid}    ${set_value}=${0}    ${total_cell}=${5}
    Change cell Attenuation value    cell=5Gcell${cellid}    value=${set_value}
    FOR  ${index}  IN RANGE   ${total_cell}
        ${cellnum} =    evaluate    ${index}+1
        run keyword if    '${cellid}'!='${cellnum}'    Change cell Attenuation value    cell=5Gcell${cellnum}    value=${127}
    END
    Change cell Attenuation value    cell=4Gcell1    value=${127}

PA set all cells to max value except specified cell with diff value
    [Arguments]    ${cellid}    ${set_value1}=${0}    ${set_value2}=${0}    ${total_cell}=${5}
    Change cell Attenuation diff value    cell=5Gcell${cellid}    value1=${set_value1}    value2=${set_value2}
    FOR  ${index}  IN RANGE   ${total_cell}
        ${cellnum} =    evaluate    ${index}+1
        run keyword if    '${cellid}'!='${cellnum}'    Change cell Attenuation value    cell=5Gcell${cellnum}    value=${127}
    END
    Change cell Attenuation value    cell=4Gcell1    value=${127}

Change cell Attenuation value
    [Arguments]    ${cell}    ${value}
    Set the Attenuation Value    ports=${${cell}_ANT1}    value=${value}
    Set the Attenuation Value    ports=${${cell}_ANT2}    value=${value}

Change cell Attenuation diff value
    [Arguments]    ${cell}    ${value1}    ${value2}
    Set the Attenuation Value    ports=${${cell}_ANT1}    value=${value1}
    Set the Attenuation Value    ports=${${cell}_ANT2}    value=${value2}

Set the Attenuation Value
    [Arguments]    ${ports}    ${value}
    atten.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${ports}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${att_api_model}
    atten.set_attenuation     port=${ports}    value=${value}

add cell attenuation for 1db
    [Arguments]    ${port1}    ${port2}    ${origin_value}    ${target_value}
    atten.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${port1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${att_api_model}
    atten.set_attenuation     port=${port1}    value=${origin_value}
    atten.set_attenuation     port=${port2}    value=${origin_value}
    FOR  ${origin_value}  IN RANGE   ${target_value}
       ${origin_value}    evaluate     ${origin_value}+1
       atten.set_attenuation     port=${port1}    value=${origin_value}
       atten.set_attenuation     port=${port2}    value=${origin_value}
       sleep    1s
    END

add cell attenuation for 5db
    [Arguments]    ${port1}    ${port2}    ${origin_value}    ${target_value}
    atten.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${port1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${att_api_model}
    atten.set_attenuation     port=${port1}    value=${origin_value}
    atten.set_attenuation     port=${port2}    value=${origin_value}
    ${origin}    Set Variable    ${0}
    ${times}    Evaluate    ${target_value}/${5}
    FOR  ${value}  IN RANGE   ${times}
       ${origin}    evaluate     ${origin}+${5}
       atten.set_attenuation     port=${port1}    value=${origin}
       atten.set_attenuation     port=${port2}    value=${origin}
       sleep    1s
    END






make WA for Samsung S21
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

Step: UE attach
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${4G_check}=False
    Check UE device exist    ue_index=${ue_index}
    Run Keyword If    '${ue_type}' != 'qct_dx50'    Huawei UE setup    ue_type=${ue_type}    ue_index=${ue_index}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${ue_index}    4G_check=${4G_check}

Step: Detach UE
    [Arguments]    ${ue_type}    ${ue_index}=${0}
    UE.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Start only DL traffic and check tput
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${dl_throughput}=${Send_Tput_DL}    ${cellid}=${1}    ${gnb_index}=${0}
    ...    ${direction}=DL    ${tput_dl_cell}=${expected_tput_dl}     ${protocol}=udp    ${dl_port}=${DL_PORT}    ${duration}=${600}
    Power UE Start DL traffic    ue_index=${ue_index}    ue_type=${ue_type}    dl_throughput=${dl_throughput}    duration=${duration}
    sleep    15s
    ${nrcellid_cell}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    ${nrcellid_cell}    Create list  ${nrcellid_cell}
    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}    direction=${direction}    list_of_cell_ids=${nrcellid_cell}
    ...    expect_throughput=${tput_dl_cell}    gnb_index=${gnb_index}

Start only UL traffic and check tput
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${ul_throughput}=${Send_Tput_UL}    ${cellid}=${1}    ${gnb_index}=${0}
    ...    ${direction}=UL    ${tput_ul_cell}=${expected_tput_ul}     ${protocol}=udp    ${ul_port}=${UL_PORT}    ${duration}=${600}
    Power UE Start UL traffic    ue_index=${ue_index}    ue_type=${ue_type}    ul_throughput=${ul_throughput}    duration=${duration}
    sleep    15s
    ${nrcellid_cell}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    ${nrcellid_cell}    Create list  ${nrcellid_cell}
    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}    direction=${direction}    list_of_cell_ids=${nrcellid_cell}
    ...    expect_throughput=${tput_ul_cell}    gnb_index=${gnb_index}

Stop DL or UL traffic
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${direction}=DL     ${protocol}=udp
    power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}   direction=${direction}    protocol=${protocol}

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
    ...    ${protocol}=udp    ${dl_port}=${DL_PORT}    ${ul_port}=${UL_PORT}    ${duration}=${600}
    Start UE DLUL UDP traffic    ue_index=${ue_index}    ue_type=${ue_type}    dl_port=${dl_port}
    ...    dl_throughput=${dl_throughput}    ul_throughput=${ul_throughput}    duration=${duration}
    sleep    15s
    ${nrcellid_cell}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    @{nrcellid_cell}    Create list  ${nrcellid_cell}
    Check Bi direction throughput    ue_index=${ue_index}    ue_type=${ue_type}    ultarget_throughput=${tput_ul_cell}
    ...    dltarget_throughput=${tput_dl_cell}    list_of_cell_ids=${nrcellid_cell}    gnb_index=${gnb_index}
    sleep    5s
    Stop UL DL data transfer    ue_index=${ue_index}    ue_type=${ue_type}    dl_port=${dl_port}    ul_port=${ul_port}

Start UE DLUL UDP traffic
    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_type}    ${dl_throughput}=${dl_throughput}    ${ul_throughput}=${ul_throughput}
    ...    ${dl_port}=${dl_port}    ${duration}=600
    Power UE Start DL traffic    ue_index=${ue_index}    ue_type=${ue_type}    dl_throughput=${dl_throughput}
    ...                          dl_port=${dl_port}    duration=${duration}
    Power UE Start UL traffic    ue_index=${ue_index}    ue_type=${ue_type}    ul_throughput=${ul_throughput}    duration=${duration}





Prepare PM counter sleep time
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    300-${utc0}%300
    sleep    ${left_timer}

Prepare PM counter sleep time 1 min
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%60
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    60-${utc0}%60
    sleep    ${left_timer}

get list of dict kpi from pm files
    [Arguments]    ${index}=${0}    ${bts_ip}=${tl.gnbs[${index}].cu.oam_ssh_connection_details.addr}
    ...    ${bts_username}=${tl.gnbs[${index}].cu.oam_ssh_connection_details.username}
    ...    ${bts_password}=${tl.gnbs[${index}].cu.oam_ssh_connection_details.password}
    ...    ${kpi_path}=${CURDIR}
    ...    ${KPI_file}=SFE_TMO_kpi_pingpang_HO.txt
    ...    ${para_index}=${2}
    ...    ${xml_num}=${10}
    ${newest_xml_file_list}=    get_period_of_time_pm_xml_files    ip=${bts_ip}    username=${bts_username}    password=${bts_password}
    ...    connection=gNB${index}    local_path=${epc_log_path}    num=${xml_num}
    ${list_kpi_keys_values}=    Create List
    FOR    ${newest_xml_file}    IN    @{newest_xml_file_list}
        ${dict_kpi_value}=    calculate_dict_kpis_from_pm_file    pm_xml_file=${newest_xml_file}
        ...    kpi_file=${kpi_path}/${KPI_file}    para_index=${para_index}
        Append To List    ${list_kpi_keys_values}    ${dict_kpi_value}
    END
    [Return]    ${list_kpi_keys_values}

get dict kpi from pm file
    [Arguments]    ${index}=${0}    ${bts_ip}=${tl.gnbs[${index}].cu.oam_ssh_connection_details.addr}
    ...    ${bts_username}=${tl.gnbs[${index}].cu.oam_ssh_connection_details.username}
    ...    ${bts_password}=${tl.gnbs[${index}].cu.oam_ssh_connection_details.password}
    ...    ${kpi_path}=${CURDIR}
    ...    ${KPI_file}=SFE_TMO_kpi_pingpang_HO.txt
    ...    ${para_index}=${2}
    ${newest_xml_file}=    get_newest_pm_xml_file    ip=${bts_ip}    username=${bts_username}    password=${bts_password}
    ...    connection=gNB${index}    local_path=${epc_log_path}
    ${dict_kpi_value}=    calculate_dict_kpis_from_pm_file    pm_xml_file=${newest_xml_file}
    ...    kpi_file=${kpi_path}/${KPI_file}    para_index=${para_index}
    [Return]    ${dict_kpi_value}
