*** Settings ***
Documentation
...    author: Liu Xu
...    contact: xu.2.liu@nokia-sbell.com
...    squad group: SG_03
...    feature : 5GC002273-AJ

Library      OperatingSystem
Library      Process
Library      Collections
Library      String
Library      BuiltIn
Library      taf.collectors.btslog   WITH NAME   btslog
Library      taf.transport.ssh    WITH NAME    csn
Library    taf.analyzer.pcap   WITH NAME    cap
#Library    ../../../../../resources/python_libs/Attenuation.py
Variables    ../Resources/Case_commission_2273_AJ/__init__.py
Library    taf.gnb.oam.commissioning    WITH NAME    commissioning
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource     taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource     ../../libraries/biplog_capture/biplog_capture.robot
Library      taf.rfrl.common_resources.python.SWConfig    WITH NAME    swconf
Library     taf.hw.rf_attenuator    WITH NAME    att
Library     taf.config.testline    WITH NAME    testline
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot


*** Variables ***
${test_pc}    ${tl.test_pc.default_ssh_connection_details.addr}


${TS_LOG_PATH_BASE}      /opt/workspace/CIT/Master/Case_Logs
${tl_scf_dir_path}    /opt/workspace/SCF/5GC002273-AJ/

${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${ENB_ADDRESS}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}

${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}

${enb_instance}     ${tl.enbs[0].instance_id}
${gnb_instance}     ${tl.gnbs[0].instance_id}

${att_ipaddr}                ${tl.attenuator[0].ip_addr}    #FOR TL355/354 PA ip other pa plz set in case level
${att_port_9}                ${tl.attenuator[0].attenuator_ports[13]}
${att_port_10}                ${tl.attenuator[0].attenuator_ports[14]}
${att_port_11}                ${tl.attenuator[0].attenuator_ports[15]}
${att_port_12}                ${tl.attenuator[0].attenuator_ports[16]}
${att_connection_port}       ${tl.attenuator[0].attenuator_ports[13]}
#354 PA
${att_port_13}                ${tl.attenuator[0].attenuator_ports[9]}
${att_port_14}                ${tl.attenuator[0].attenuator_ports[10]}
${att_port_15}                ${tl.attenuator[0].attenuator_ports[11]}
${att_port_16}                ${tl.attenuator[0].attenuator_ports[12]}
${att_connection_port_1}       ${tl.attenuator[0].attenuator_ports[9]}
#360
${att_port_1}               ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2}               ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3}               ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4}               ${tl.attenuator[0].attenuator_ports[4]}
${att_connection_port_2}       ${tl.attenuator[0].attenuator_ports[1]}

${att_api_port}              ${tl.attenuator[0].port}
${vendor}                    ${tl.attenuators[0].vendor}
${max_attenuation_value}     ${127}

${enbx2_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-1
${enbx2_dist_trunk}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-2

${enbx2_para}    administrativeState
${lnrel_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-11
${lnrel_dist_trunk}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-12
#360 -ENB
${enbx2_dist_trunk1}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-0
${lnrel_dist_trunk1}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1

${lnrel_para}    defaultLnRelGnbCellId
${f1_sctp_port}    38472
${x2_sctp_port}    36422
${tshark_path}    /usr/bin/tshark
${LUA_SCRIPT_PATH}    /home/nokia/luashark/generated_luashark/luashark.lua
${command_template_with_Y}    {tshark_path} -r {pcap_file} -X lua_script:{luashark_path} -T pdml

${ENB_ADDRESS_0}            ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${distname_id_1}       MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}

*** Keywords ***
lock or unlock enb for sa set
    [Arguments]    ${cell_status}=locked    ${enb_cell_id}=${12}    ${enb_index}=${0}
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[${enb_index}].instance_id}/LNBTS-${tl.enbs[${enb_index}].instance_id}/LNCEL-${enb_cell_id}
    ...    parameter=administrativeState
    ...    value=${cell_status}
    sleep    10s

lock amf for NSA attach
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    selenium_coam.disable_message_box
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.set_parameter_value    dist_name=${distname_id_1}/SERVEDAMF-1
    ...    filter_param=Administrative state
    ...    new_value=Locked
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=120
    selenium_coam.logout
    selenium_coam.disable_virtual_display

get CellID
    [Arguments]    ${lcrid}
    ${cell1_id}    COAM Get nrcellid with the lcrid    lcrid=${lcrid}
    set suite variable    ${cell1_id}

Update the swconfig file
    [Arguments]    ${localFilePath}
    run    command=cp ${localFilePath} ${epc_log_path}swconfig.txt
    wait until keyword succeeds    5min    10s    Connect to Common Unit Master   alias=ASIK
    swconf.Upload SwConfig File To Asik And Crasign     localFilePath=${epc_log_path}swconfig.txt    asik_alias=ASIK
    csn.disconnect     connection=ASIK

Get sagnb release
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
#    ${release_info}     set variable    ${info.split('_')[4]}
    ${release_info}     set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info

Modify scf file for case
    [Arguments]    ${modify_list}    ${tl_scf_file}=${tl_scf_filename}
    run keyword and continue on failure     commissioning.Modify Scf    input_scf=${tl_scf_dir_path}${tl_scf_file}
    ...            output_scf=${epc_log_path}${tl_scf_file}    parameters_lists=${modify_list}

Suite Recovery
    run keyword and ignore error  COAM Teardown gnb connections
    Connect and Modify the parameter on enblte   dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    run keyword and ignore error    csn.disconnect    connection=gnb
    run keyword and ignore error    csn.disconnect    connection=enb

Common Suite Setup for COAM
    COAM Create log directory    is_set_to_test_case_level=${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
    Create directory    ${epc_log_path}
    set_suite_documentation    doc=||| All test suite log will save in this VM IP:${test_pc} logPath:${epc_log_path}
    ...    append=True
Common Suite Teardown for COAM
    Connect to gnb coam via ssl
    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    [Teardown]    COAM Teardown gnb connections

Common Test Teardown for COAM
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    #Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    run keyword if test failed    Run Keyword And Ignore Error    Common Suite Teardown for COAM
    run keyword if test failed    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
Prepare with COAM classical BTS cell onair
    [Arguments]    ${ru_reset}=no    ${lnrel_value}=1    ${tl_scf_file}=${tl_scf_filename}
    Power reset For All RU    ru_reset=${RU_reset}
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=locked
    Perform full commission for COAM gnb    scf_filename=${tl_scf_file}
    Check gnb COAM classical start normally
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    Connect and Modify the parameter on enblte    dist_name=${lnrel_dist}    parameter=${lnrel_para}    value=${lnrel_value}
    Check the gnb cell status onair

Prepare with COAM classical BTS cell onair Trunk
    [Arguments]    ${ru_reset}=no    ${lnrel_value}=1    ${tl_scf_file}=${tl_scf_filename}
    Power reset For All RU    ru_reset=${RU_reset}
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist_trunk}    parameter=${enbx2_para}    value=locked
    Perform full commission for COAM gnb    scf_filename=${tl_scf_file}
    Check gnb COAM classical start normally
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist_trunk}    parameter=${enbx2_para}    value=unlocked
    Connect and Modify the parameter on enblte    dist_name=${lnrel_dist_trunk}    parameter=${lnrel_para}    value=${lnrel_value}
    Check the gnb cell status onair

Prepare with COAM classical BTS cell onair Trunk1
    [Arguments]    ${ru_reset}=no    ${lnrel_value}=3    ${tl_scf_file}=${tl_scf_filename}
    Power reset For All RU    ru_reset=${RU_reset}
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist_trunk1}    parameter=${enbx2_para}    value=locked
    Perform full commission for COAM gnb    scf_filename=${tl_scf_file}
    Check gnb COAM classical start normally
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist_trunk1}    parameter=${enbx2_para}    value=unlocked
    Connect and Modify the parameter on enblte    dist_name=${lnrel_dist_trunk1}    parameter=${lnrel_para}    value=${lnrel_value}
    Check the gnb cell status onair

Commission SCF to eNB
    [Arguments]    ${eNB_asik_addr}    ${connection}    ${scf_file}
    enblte.connect_to    bts_host=${eNB_asik_addr}
    ...    bts_port=443  use_ssl=True    name=${connection}
    enblte.perform_commissioning    scf_file=${tl_scf_dir_path}${scf_file}    skip_parameter_relation_errors=${True}
    ...     should_activate=${True}    connection=${connection}    timeout=300

Power reset For All RU
    [Arguments]    ${ru_reset}=no
    Run Keyword If   '${ru_reset}'!='yes'  return from keyword   ${ru_reset}
    ${ru_num}    get length    ${tl.gnbs[0].dus[0].rus}
    FOR    ${index}    IN RANGE    ${ru_num}
        ${index}    Evaluate    ${index}+${1}
        ${status}    Run Keyword And Return Status     Perform RU Power Off    ru_index=${index}
        run keyword if  not ${status}    Log    Power Off RU_${index}  failed.
        sleep   3s
        ${status}    Run Keyword And Return Status     Perform RU Power On    ru_index=${index}
        run keyword if  not ${status}    Log    Power On RU_${index}  failed.
    END
    [Return]    ${ru_reset}

Perform full commission for COAM gnb
    [Arguments]    ${scf_filename}    ${is_pdl_checking_needed}=${False}
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${epc_log_path}${scf_filename}    is_pdl_checking_needed=${is_pdl_checking_needed}
    [Teardown]    COAM Teardown gnb connections

Check gnb COAM classical start normally
#    Check Airscale HW module status
    Check the gnb RU status ready
#    wait until keyword succeeds    10min   30s    Check the sctp port UP    port_num=${x2_sctp_port}

Check the sctp port UP
    [Arguments]    ${port_num}
    Connect to BB1 master    alias=BB1
    csn.send command    command=netstat -anl |grep sctp    connection=BB1
    sleep    3s
    ${sctp_status} =    csn.read output    connection=BB1
    csn.disconnect     connection=BB1
    should contain     ${sctp_status}     ${port_num}

Check the gnb RU status ready
    Connect to gnb coam via ssl
    wait until keyword succeeds    10min   30s    COAM Check GNB RU status
    [Teardown]    COAM Teardown gnb connections

Check the gnb cell status onair
    Connect to gnb coam via ssl
    wait until keyword succeeds    5min   30s    COAM Check GNB cell on air
    [Teardown]    COAM Teardown gnb connections

Adjust the HBTE attenuation value
    [Arguments]      ${value_9}    ${value_10}    ${value_11}    ${value_12}
    [Documentation]    Auther:cris.cai@nokia-sbell.com
    ...                modify HBTE PA 4 port value default value[0-63db] if not set the max_attenuation value below
    ...                for value and not default port 1234, plz set in your case level. setup connection only port1
    ...                if connect on local plz disconnect firstly
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    att.set_attenuation     port=${att_port9}    value=${value_9}
    att.set_attenuation     port=${att_port10}    value=${value_10}
    att.set_attenuation     port=${att_port11}    value=${value_11}
    att.set_attenuation     port=${att_port12}    value=${value_12}
    ${value_port9}    att.read_attenuation    port=${att_port9}
    should be equal    ${value_port9}    ${value_9}
    ${value_port10}    att.read_attenuation    port=${att_port10}
    should be equal    ${value_port10}    ${value_10}
    ${value_port11}    att.read_attenuation    port=${att_port11}
    should be equal    ${value_port11}    ${value_11}
    ${value_port12}    att.read_attenuation    port=${att_port12}
    should be equal    ${value_port_12}    ${value_12}

Adjust the HBTE attenuation value Trunk
    [Arguments]      ${value_13}    ${value_14}    ${value_15}    ${value_16}
    [Documentation]    Auther:cris.cai@nokia-sbell.com
    ...                modify HBTE PA 4 port value default value[0-63db] if not set the max_attenuation value below
    ...                for value and not default port 1234, plz set in your case level. setup connection only port1
    ...                if connect on local plz disconnect firstly
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port_1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    att.set_attenuation     port=${att_port13}    value=${value_13}
    att.set_attenuation     port=${att_port14}    value=${value_14}
    att.set_attenuation     port=${att_port15}    value=${value_15}
    att.set_attenuation     port=${att_port16}    value=${value_16}
    ${value_port13}    att.read_attenuation    port=${att_port13}
    should be equal    ${value_port13}    ${value_13}
    ${value_port14}    att.read_attenuation    port=${att_port14}
    should be equal    ${value_port14}    ${value_14}
    ${value_port15}    att.read_attenuation    port=${att_port14}
    should be equal    ${value_port14}    ${value_14}
    ${value_port16}    att.read_attenuation    port=${att_port15}
    should be equal    ${value_port_15}    ${value_15}


Adjust the HBTE attenuation value Trunk1
    [Arguments]      ${value_1}    ${value_2}    ${value_3}    ${value_4}
    [Documentation]    Auther:cris.cai@nokia-sbell.com
    ...                modify HBTE PA 4 port value default value[0-63db] if not set the max_attenuation value below
    ...                for value and not default port 1234, plz set in your case level. setup connection only port1
    ...                if connect on local plz disconnect firstly
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port_2}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    att.set_attenuation     port=${att_port1}    value=${value_1}
    att.set_attenuation     port=${att_port2}    value=${value_2}
    att.set_attenuation     port=${att_port3}    value=${value_3}
    att.set_attenuation     port=${att_port4}    value=${value_4}
    ${value_port1}    att.read_attenuation    port=${att_port1}
    should be equal    ${value_port1}    ${value_1}
    ${value_port2}    att.read_attenuation    port=${att_port2}
    should be equal    ${value_port2}    ${value_2}
    ${value_port3}    att.read_attenuation    port=${att_port3}
    should be equal    ${value_port3}    ${value_4}
    ${value_port4}    att.read_attenuation    port=${att_port4}
    should be equal    ${value_port_4}    ${value_4}

COAM get cell id
    selenium_coam.login    ${WEBUI_COAM}    ${WEBUI_NAME}    ${WEBUI_PWD}
    ${info_cell1}    selenium_coam.get_cell_info    cell_idx=${1}
#    ${info_cell2}    selenium_coam.get_cell_info    cell_idx=${2}
    set suite variable    ${cell1_id}    ${info_cell1['NR cell ID']}
#    set suite variable    ${cell2_id}    ${info_cell2['NR cell ID']}
    selenium_coam.logout

#COM based
Make UL data transfer and verify Tput
    [Arguments]    ${ulexpect_tp}    ${retry}=${1}
    FOR   ${index}    IN RANGE    ${retry}
        ${PT_status}    run keyword and return status    L3 call with UL TP check
    ...    ulexpect_tp=${ulexpect_tp}
        exit for loop if   ${PT_status}
    END
    should be true    ${PT_status}

Make DL data transfer and verify Tput
    [Arguments]    ${dlexpect_tp}    ${throughput}=${800}    ${retry}=${1}
    FOR   ${index}    IN RANGE    ${retry}
        ${PT_status}    run keyword and return status    L3 call with DL TP check
    ...    dlexpect_tp=${dlexpect_tp}    throughput=${throughput}
        exit for loop if   ${PT_status}
    END
    should be true    ${PT_status}
L3 call with UL TP check
    [Arguments]    ${ulexpect_tp}    ${cell_id}=${cell1_id}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}   ue_index=${ue_index}    gnb_index=${0}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}    4G_check=False
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=100M
    ...    duration=300s    iperf_port=${ul_port}    ue_index=${ue_index}
    wait until keyword succeeds    2min   30s    power_ue.Check throughput    direction=ul    throughput=${ulexpect_tp}
    ...    ue_type=${ue_type}   ue_index=${ue_index}    cellid=${cell_id}
    [Teardown]    run keywords


L3 call with DL TP check
    [Arguments]    ${throughput}   ${dlexpect_tp}    ${cell_id}=${cell1_id}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}   ue_index=${ue_index}    gnb_index=${0}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}    4G_check=False
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${throughput}M
    ...    duration=300s    iperf_port=${dl_port}    ue_index=${ue_index}
    wait until keyword succeeds    2min   30s    power_ue.Check throughput    direction=dl    throughput=${dlexpect_tp}
    ...    ue_type=${ue_type}   ue_index=${ue_index}    cellid=${cell_id}
    [Teardown]    run keywords


Catch Bip log on ASIB
    [Arguments]     ${biplog}    ${connection}=ABIL Master    ${gnb_index}=${0}    ${mirror_mode}=local
    ...            ${bip_interface}=ethbp1    ${bip_time}=${3}    ${HW_TYPE}=ASIB    ${hw_slot}=${1}
    Preconfdition for Bip Capture trunk      mirror_mode=${mirror_mode}    HW_TYPE=${HW_TYPE}
    sleep    3s
    Connect to Capacity Unit Master with hostname     gnb_index=${gnb_index}     hw_slot=${hw_slot}
    sleep    3s
    Run keyword if    '${bip_time}'=='infinity'
    ...    csn.Execute    command=tcpdump -i ${bip_interface} -w ${gnb_path}${biplog} -vv
    ...           connection=${connection}
    ...    ELSE    csn.Execute    command=timeout ${bip_time} tcpdump -i ${bip_interface} -C 50M -w ${gnb_path}${biplog} -vv
    ...         connection=${connection}

Preconfdition for Bip Capture trunk
    [Arguments]     ${mirror_mode}     ${hw_slot}=${1}    ${HW_TYPE}=ASIB
    Connect to Capacity Unit Loner with hostname    alias=ABIL Loner    hw_slot=${hw_slot}
    ${hwindex_asib}=    HW slot for asib capture    hw_slot=${hw_slot}
    detectHwAndStartMirroring    asik_alias=Common Master    loner_alias=ABIL Loner   mirror_mode=${mirror_mode}
    ...    sw_release=${HW_TYPE}    hw_index=${hwindex_asib}

BIP logs download from ASIB to UTE
    [Arguments]    ${logname}     ${gnb_index}=${0}    ${connection}=ABIL Master    ${hw_slot}=${1}
    Connect to Capacity Unit Master with hostname    gnb_index=${gnb_index}    hw_slot=${hw_slot}
    sleep    5s
    csn.download_file   remote_path=${gnb_path}${logname}   local_path=${epc_log_path}${logname}   connection=${connection}


Catch Bip log on trunk
    [Arguments]    ${script_path}    ${capturing_time_seconds}=3    ${gnb_index}=${0}
    Connect to Classical Common Unit Master gnb    gnb_index=${gnb_index}
    Precondition for bip capture with gnbMirroring scripts    script_path=${script_path}
    Bip Capture with gnbMirroring scripts 1856    gnb_index=${gnb_index}    capturing_time_seconds=${capturing_time_seconds}

Bip Capture with gnbMirroring scripts 1856
    [Arguments]    ${gnb_index}=${0}    ${connection}=ASIK Master    ${gnb_mirroring}=gnbMirroring.sh
    ...            ${capturing_time_seconds}=infinite
    Connect to Classical Common Unit Master gnb    gnb_index=${gnb_index}
    ${cmd_local}    catenate    sh /ffs/run/config/scripts/${gnb_mirroring} --capturing_time_seconds=${capturing_time_seconds}
    csn.send_command    command=${cmd_local}    connection=${connection}
#    csn.send_command
#    ...    command=cd ${AT_script_path} && python ATcommand.py -p com${COM_port} -c "${command}"
#    ...    connection=cygwin${ue_index}
    ${output}    csn.Read Output    connection=${connection}
    sleep    3s
    should contain    ${output}    Dump files in /tmp/ folder

Connect to Classical Common Unit Master gnb
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${alias}=ASIK Master
    ${gnbs}    testline_info.get_classicalbts_gnbs    tl=${tl}
    ssh.Connect to    hostname=${gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...               username=${gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=${alias}
