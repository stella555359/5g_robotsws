*** Settings ***
Documentation
...   author: zheyuan.chen@nokia-sbell.com
...   contact: zheyuan.chen@nokia-sbell.com

Library    taf.transport.ssh            WITH NAME    ssh
Library    taf.collectors.core          WITH NAME    core
Library    taf.collectors.tcpdump       WITH NAME    tcpdump
Library    taf.analyzer.pdml            WITH NAME    cpdml
Library    taf.sbts.oam.coam.admin      WITH NAME    coam
Library    taf.collectors.btslog        WITH NAME    btslog
Library    taf.hw.rf_attenuator        WITH NAME       att
Library    String
Library    Collections
Library    OperatingSystem
Library    Process
Library    XML
Library    DateTime
Library    Telnet
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    ../../CB008434-SR/resources/variables_8434.robot
Resource    ../../CB008434-SR/resources/comm_8434.robot
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot

*** Variables ***
${att_ipaddr}    ${tl.attenuator.ip_addr}
${att_api_port}    ${tl.attenuator.port}
${model}                     ${tl.attenuator.model}
${att_port_1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_3}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${att_port_4}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${vendor}    HBTE
${max_att_value}    ${127}
@{ignore_active_fault}    ${4655}    ${61524}    ${4654}    ${61649}
${control_pc_addr}    ${tl.ues[0].ssh_connection_details.addr}
${control_pc_username}    ${tl.ues[0].ssh_connection_details.username}
${control_pc_password}    ${tl.ues[0].ssh_connection_details.password}
${UE0_SN}    ${tl.ues[0].serial_number}
${UE1_SN}    ${tl.ues[1].serial_number}
${home}    3
${airplane}    932 1633
${close_task}    710 2766
${Home_button}    3
${swipe}    1300 2700 1300 2700
${open_iperf_location}    500 2050
${iperf_button}    730 300
${iperf_space}    800 550
${5G}    900 960
${brand}     lge
${iperf_path}       /data/local/tmp/iperf

*** Keywords ***
Save Snapshot
    [Arguments]    ${connection}=cOAM    ${timeout}=10min
    log to console    Save Snapshot...
    run keyword and ignore error     coam.teardown    connection=${connection}
    Connect to gnb coam via ssl    bts_host=${ip_address}    username=${username}    password=${password} 
    ...    connection=${connection}
    ${snapshot_path}    coam.Get Snapshot From BTS    alias=${connection}    timeout=${timeout}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${snapshot_path}
    
Adjust HBTE Attenuation
    [Arguments]    ${port_value1}    ${port_value2}    ${port_value3}    ${port_value4}
    Log To Console    Adjust HBTE Attenuation
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}    max_attenuation=${max_att_value}    vendor=${vendor}
    ...    model=${model}
    att.set_attenuation    port=${att_port_1}    value=${port_value1}
    att.set_attenuation    port=${att_port_2}    value=${port_value2}
    att.set_attenuation    port=${att_port_3}    value=${port_value3}
    att.set_attenuation    port=${att_port_4}    value=${port_value4}

Activate TL3 Supercell And Add Channelgroup
    Log To Console    activate supercell parameter
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Activate super cell   new_value=true    abbr=actSuperCell
    Log To Console    add channelgroup
    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1    object_class_name=CHANNELGROUP
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1
    ...    include_subobject=${TRUE}    id_value=2
    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1    object_class_name=CHANNELGROUP
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1
    ...    include_subobject=${TRUE}    id_value=3
    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1    object_class_name=CHANNELGROUP
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1
    ...    include_subobject=${TRUE}    id_value=4
    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1    object_class_name=CHANNELGROUP
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-5/CHANNELGROUP-1
    ...    include_subobject=${TRUE}    id_value=5
    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1    object_class_name=CHANNELGROUP
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-6/CHANNELGROUP-1
    ...    include_subobject=${TRUE}    id_value=6

Delete TL3 Nrcells Data
    Log To Console    delete nrcell
    selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-4
    selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-5
    selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-6
    selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-1
    selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-2
    selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-3
    selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-4
    selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-5
    selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2
    selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3
    selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4
    selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-5
    selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-6
    selenium_coam.remove_element   dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group    node_index=${1}    abbr=refNrCellGroup
    selenium_coam.remove_element   dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group    node_index=${2}    abbr=refNrCellGroup
    selenium_coam.remove_element   dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group    node_index=${3}    abbr=refNrCellGroup
    selenium_coam.remove_element   dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group    node_index=${4}    abbr=refNrCellGroup
    selenium_coam.remove_element   dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group    node_index=${5}    abbr=refNrCellGroup

Check History And Active Alarm
    SBTS Login
    Check if Unexpected History Alarm Exist
    ${faultid_list}    Get Active Alarm List
    ${ignore_fault}    set variable    ${ignore_active_fault}
    FOR    ${item}    IN    @{faultid_list}
        run keyword and continue on failure    list should contain value    ${ignore_fault}    ${item}
    END
    [Teardown]    SBTS Logout

Check Unexpected Active Alarm
    SBTS Login
    ${faultid_list}    Get Active Alarm List
    ${ignore_fault}    set variable    ${ignore_active_fault}
    FOR    ${item}    IN    @{faultid_list}
        run keyword and continue on failure    list should contain value    ${ignore_fault}    ${item}
    END
    [Teardown]    SBTS Logout

Check if Unexpected Active Alarm Without Login
    ${faultid_list}    Get Active Alarm List
    ${ignore_fault}    set variable    ${ignore_active_fault}
    FOR    ${item}    IN    @{faultid_list}
        run keyword and continue on failure    list should contain value    ${ignore_fault}    ${item}
    END

Delete TL3 Channelgroup
    [Arguments]    ${channelgrp_list}    ${LCELNR_idx}=${1}
    WEBUI Login
    Log To Console    delete channelgroup
    FOR    ${item}    IN    @{channelgrp_list}
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR_idx}/CHANNELGROUP-${item}
    END
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    Log To Console    Activate plan
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    [Teardown]    WEBUI Logout

Add TL3 Channelgroup
    [Arguments]    ${channelgrp_list}    ${LCELNR_idx}=${1}
    WEBUI Login
    Log To Console    add channelgroup
    FOR    ${item}    IN    @{channelgrp_list}
        selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR_idx}
        ...    object_class_name=CHANNELGROUP    id_value=${item}    is_load_default_values=${TRUE}
        _set_testline3_channelgroup_parameter    grp_index=${item}    LCELNR_idx=${LCELNR_idx}
    END
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    Log To Console    Activate plan
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    [Teardown]    WEBUI Logout

_set_testline3_channelgroup_parameter
    [Arguments]    ${grp_index}    ${LCELNR_idx}
    Log To Console    set channelgrp parameter
    @{antl_value_list}    create list    ${1}    ${1}    ${2}    ${2}    ${3}    ${3}    ${4}    ${4}
    FOR    ${item}    IN RANGE    ${8}
        ${result}    evaluate    ${item} % ${2}
        ${direction}     set variable if    ${result} == ${0}    TX    RX
        ${index}    evaluate    ${item} + 1
        ${antlDN_value}    set variable    MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${grp_index}/ANTL-${antl_value_list}[${item}]
        selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR_idx}/CHANNELGROUP-${grp_index}
        ...    object_class_name=CHANNEL    id_value=${index}    is_load_default_values=${TRUE}
        selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR_idx}/CHANNELGROUP-${grp_index}/CHANNEL-${index}
        ...    filter_param=Distinguished Name of antenna line   new_value=${antlDN_value}    abbr=antlDN
        selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR_idx}/CHANNELGROUP-${grp_index}/CHANNEL-${index}
        ...    filter_param=Direction of the channel   new_value=${direction}    abbr=direction
    END

Reset BBMOD
    [Arguments]    ${BBMOD_idx}    ${connection}=default
    Log To Console    Reset BBMOD
    coam.reset_unit    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${BBMOD_idx}    reset_type=Warm    force_radio_reset=${True}
    ...    timeout=600s    connection=${connection}
    sleep    3s

Xiaomi_UE_Attach
    [Arguments]    ${ue_sn}    ${ue_index}=${0}
    Log To Console    Single UE Attach
    run keyword and ignore error    ssh.disconnect    connection=cygwin
    sleep    5s
    wait until keyword succeeds    3min    30s    ssh.Connect to    hostname=${control_pc_addr}    username=${control_pc_username}
    ...    password=${control_pc_password}    alias=cygwin
    ssh.send_command   connection=cygwin
    ...   command=adb -s ${ue_sn} shell dumpsys window | grep -E \"mAwake|isStatusBarKeyguard|mShowingLockscreen\"
    sleep   2s
    ${output}   ssh.read_output   connection=cygwin
    Run Keyword If   ${output.lower().count('mawake=false')}>0
    ...   ssh.send_command   command=adb -s ${ue_sn} shell input keyevent 26   connection=cygwin
    ssh.send_command   command=adb -s ${ue_sn} shell input swipe 347 2514 715 400    connection=cygwin
    sleep    2s
    ssh.send_command    command=adb -s ${ue_sn} shell input keyevent 3    connection=cygwin
    sleep   2s
    ssh.send_command    command=adb -s ${ue_sn} shell input keyevent 187    connection=cygwin
    sleep   4s
    ssh.send_command    command=adb -s ${ue_sn} shell input tap ${close_task}    connection=cygwin
    Commercial_mobile_phone_adb_common_keywords.Commercial UE click AIRPLANE once    serial_number=${ue_sn}
    ...    Home_button=${Home_button}     swipe=${swipe}    airplane=${airplane}    close_task=${close_task}    ue_index=${ue_index}

Xiaomi_Start Traffic And Check TP
    [Arguments]    ${ue_sn}    ${tp_ul}    ${tp_dl}    ${target_tp_ul}    ${target_tp_dl}    ${duration}=600    ${ue_mode}=SA
    ...    ${ue_index}=${0}    ${port}=${0}    ${nrcell_id}=${nrcell_id}    ${iperf_type_dl}=via_command    ${target_avg_percent}=${0.95}
    ...    ${ul_port}=${IPERF_portlist}[1]
    Log To Console    Start Traffic
    sleep    10s
    ssh.Connect to    hostname=${control_pc_addr}    username=${control_pc_username}
    ...    password=${control_pc_password}    alias=cygwin
    sleep    10s
    run keyword and continue on failure    ssh.send_command
    ...   command=adb -s ${ue_sn} shell ${iperf_path} -u -t ${duration} -i 1 -p ${ul_port} -P 1 -f m -b ${tp_ul} -l 1400B -T 64 -c ${appserver_addr}
    ...   connection=cygwin
    ssh.Disconnect    connection=cygwin
    Log To Console    UE udp ul iperf start
    sleep    5s
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl   throughput=${tp_dl}    ue_index=${ue_index}
    ...    duration=${duration}    ue_mode=${ue_mode}    iperf_port=${IPERF_portlist}[${port}]    iperf_type=${iperf_type_dl}    process_num=${3}
    sleep    30s
    Log To Console    check throughput
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    duration=60s    ignore_time=5s
    ${cell_list}    create list    ${nrcell_id}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=ul    log=${log_path}
    ...    cells=${cell_list}    target_avg_percent=${target_avg_percent}    target_throughput=${target_tp_ul}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    log=${log_path}
    ...    cells=${cell_list}    target_throughput=${target_tp_dl}

Check Number Of Subcell
    [Arguments]    ${expected_numofsubcells}    ${connection}=default    ${cell_idx}=${1}
    Log To Console    check number of subcell
    SBTS Login
    ${nrcell_status}     coam.get_parameters
    ...   dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-${NRBTS_ID}/NRCELL_R-${cell_idx}    connection=${connection}
    ${num_subcells}    get from dictionary    ${nrcell_status}     numOfSuperSubCells
    should be equal    ${num_subcells}    ${expected_numofsubcells}
    [Teardown]    SBTS Logout
