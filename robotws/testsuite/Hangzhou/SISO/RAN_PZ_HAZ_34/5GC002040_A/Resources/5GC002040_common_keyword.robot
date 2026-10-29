*** Settings ***
Documentation
...    contact: cris.cai@nokia-sbell.com
Library    taf.pdu       WITH NAME    pdu
Library    taf.analyzer.pcap
Library    taf.rfrl.common_resources.python.SWConfig    WITH NAME    swconf
Library     ../../../../OAM/RAN_PZ_HAZ_34/libraries/get_bts_info.py   WITH NAME    lib
Library     taf.transport.ssh   WITH NAME   csn
Library     taf.ue    WITH NAME    ute_ue
Library     taf.hw.rf_attenuator    WITH NAME    att
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource    taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/check_android_ue_l3_call_process.robot
Resource    ./5GC002040_common_checkpoints.robot
Variables     ./2040_common_Variables.py
Variables   ../Testdata/2040_scf_modify.py
Variables   ../Testdata/2040_swconf_modify.py
Variables   ../Testdata/5GC002040_mcs_mapping_table.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

*** Variables ***
${ASIK_ALIAS}             ASIK Master
${BIP_ALIAS}             ASIK Master BIP
${att_ipaddr}                ${tl.attenuator.ip_addr}
${att_port_0}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${att_port_3}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${att_api_port}              ${tl.attenuator.port}
${mrbtsId}                   ${tl.gnbs[0].instance_id}
${nrbtsId}                   ${tl.gnbs[0].global_bts_id}
${UL_PORT}                   ${tl.ues[0].iperf_details.ssh_connection_details.port}
${DL_PORT}                   ${tl.ues[0].iperf_details.port}
${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
#${vendor}                    RADIORACK
${vendor}                    ${tl.attenuator.vendor}
${max_attenuation_value}     ${110}
${TS_LOG_PATH_BASE}      /home/ute/test_results/Logs/
${tmp_swconfig_dir}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/5GC002040
${SCF_TEMPLATE_PATH}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/5GC002040/2DL_2UL_SCF.xml
${SCF_TEMPLATE_PATH_029}    /home/ute/MN/UTE/robotws/commissionings/HGZ/7_5_UTE5G402T029/2DL_2UL_SCF.xml
${scripts_path}        ${CURDIR}
${LUA_SCRIPT_PATH}      /home/ute/Downloads/Lua/generated_luashark/luashark.lua
${LENGTH}              1400
${DURATION}               9999999
${PROGRAM}              5G19B
${ue_type}    huawei
${dl_direction}    dl
${ul_direction}    ul
${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}

*** Keywords ***

Get mrbtsId and nrbtsId
    COAM Navigate to login page via webUI
    ${commission_file}    selenium_coam.backup_bts_site_configuration
    Sleep   3 sec
    ${mrbtsId}    lib.Get_MRBTSID_cOAM    scf_path=${commission_file}
    ${nrbtsId}    lib.Get_NRBTSID_cOAM    scf_path=${commission_file}
    set test variable     ${mrbtsId}
    set test variable     ${nrbtsId}
    [Teardown]  selenium_coam.logout

Backup SCF file for COAM
	COAM Navigate to login page via webUI
    selenium_coam.save_bts_configuration    save_configuration_type=${1}
    [Teardown]  selenium_coam.logout

UE attach and make calls successful
    Log    \UE attach and make calls successful    console=yes
    Precondition for power UE    ue_type=huawei    ui_version=S20UI2.5
    Attach and check power UE    ue_type=huawei

Precondition for power UE
    [Arguments]    ${ue_type}    ${ui_version}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    capatibility_index=${0}    reset_sol=none    detach_request=${true}
    ...                    ui_version=${ui_version}

Attach and check power UE
    [Arguments]    ${ue_type}    ${5Gstatus}=PASS
     ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    5Gstatus=${5Gstatus}

Modify swconfig and Commission SCF
    [Arguments]    ${swconfig_modify}=${SWCONFIG_DEFAULT_FILE_PATH}     ${scf_modify}=${MODIFIED_SCF}
    ...    ${is_called_in_test_case_level}=${True}    ${swconfig_template_path}=${tmp_swconfig_dir}/swconfig_default.txt
    ...    ${scf_template_path}=${SCF_DEFAULT_FILE_PATH}    ${is_pdl_checking_needed}=${False}
    Log    \n *** Modify swconfig and Commission SCF
    Preparation with swconfig modification and comissioning    swconfig_modify=${swconfig_modify}
    ...    scf_modify=${scf_modify}    is_called_in_test_case_level=${is_called_in_test_case_level}
    ...    swconfig_template_path=${swconfig_template_path}    scf_template_path=${scf_template_path}
    ...    is_pdl_checking_needed=${is_pdl_checking_needed}
    Wait until cluster is on cell on air status
    sleep    10

Get release info
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
    ${release_info}     set variable    ${info.split('_')[1]}
    set suite variable  ${PROGRAM}    ${release_info}
    import library    5GC002040_TTI_Trace_Analysis_dl.TTI_Trace_analysis_dl    program=${PROGRAM}    WITH NAME    tti_dl
    [Teardown]   csn.Disconnect   connection=release_info

Adjust Radiorack Attenuation
    [Arguments]  ${attenuation_values_of_all_ports}=${ATTENUATION_VALUE_DEFAULT}
    Log    \n *** Adjust Attenuation    console=yes
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    FOR  ${port_num}    IN RANGE    0    4
        ${att_value}    set variable    ${attenuation_values_of_all_ports['atten_value_of_port${port_num}']}
        att.set_attenuation    port=${att_port_${port_num}}    value=${att_value}
        sleep    1s
    END

Start DL transmission
    log to console    \n *** Start DL transmission
    [Arguments]     ${dl_data_transfer}=${dl_data_transfer}
    power_ue.Start traffic    ue_type=${ue_type}    direction=${dl_direction}    duration=${DURATION}
    ...    throughput=${dl_data_transfer}    #contains get commerical ue ip via cygwin
    sleep    10s

Start UL transmission
    Log    \n *** Start UL transmission    console=yes
    [Arguments]    ${ul_data_transfer}=${ul_data_transfer}
    power_ue.Start traffic    ue_type=${ue_type}    direction=${ul_direction}    duration=${DURATION}
    ...    throughput=${ul_data_transfer}
   sleep    10s

Read BIP pcap files
    [Documentation]    Description: The BIP_log_name means:bip_log_folder+bip_log_name
    [Arguments]    ${filter}    ${BIP_log_name}    ${lua_script_path}=${LUA_SCRIPT_PATH}
    Wait until keyword succeeds    3 min     7 s    cap.Read cap
    ...    cap_file=${BIP_log_name}
    ...    X=lua_script:${lua_script_path}
    ...    display_filter=${filter}

Capture BIP Logs
    Connect to BB1 master    alias=ASIK Master
    Precondition For Bip Capture    L1_version=L1R52
    run keyword and ignore error    csn.Send command    command=rm -rf /tmp/bip_for_traffic*.pcap    connection=ASIK Master
    Start BIP Capture On ASIK    log_prefix=bip_for_traffic
    sleep    2 sec
    Stop BIP Capture On ASIK
    ${bip_log_list}    Download BIP Logs From ASIK To TestPC   log_prefix=bip_for_traffic
    Set suite variable    ${BIP_LOG_PATH}    ${bip_log_list}[0]

Case teardown
    [Arguments]       ${connection}=${BIP_ALIAS}
    Log    \n *** Case teardown
    Connect to BB1 master    alias=gNB
    Run      cp ${tmp_swconfig_dir}/swconfig_default.txt ${tmp_swconfig_dir}/swconfig.txt
    swconf.Upload swConfig file to asik and crasign
    ...             localFilePath=${tmp_swconfig_dir}/swconfig.txt
    ...             asik_alias=gNB
    run keyword and ignore error    COAM Teardown gnb connections
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul
    run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}
    run keyword and ignore error    Adjust Radiorack Attenuation    attenuation_values_of_all_ports=${ATTENUATION_VALUE_DEFAULT}
    Run keyword and ignore error    CI_interface.Common Case Teardown

Get parameter value
    [Arguments]    ${dis_name}    ${filter_name}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    ${value}=    selenium_coam.get_parameter_value    dist_name=${dis_name}
    ...    filter_param=${filter_name}
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display
    [return]    ${value}

get nrCellid
    [Arguments]    ${cellid}     ${nrbtsid}=1
    ${value}=    Get parameter value    dis_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${nrbtsid}/NRCELL-${cellid}
    ...    filter_name=NR Cell Identity
    [Return]    ${value}

Check UL and DL TP
    [Arguments]    ${dl_expect_throughput}=${expect_dl_tput}    ${ul_expect_throughput}=${expect_ul_tput}
    ${nrcell_id}    get nrCellid    cellid=1    nrbtsid=${tl.gnbs[0].instance_id}
    ${list_of_cell_ids}    Create list    ${nrcell_id}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m
    Power_ue.Check Tput    ue_type=${ue_type}    direction=UL    log=${tput_log}    cells=${list_of_cell_ids}
    ...    target_throughput=${ul_expect_throughput}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m
    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${tput_log}    cells=${list_of_cell_ids}
    ...    target_throughput=${dl_expect_throughput}

Adjust Attenuation to Get Peak UL and DL TP
    [Arguments]    ${dl_expect_throughput}=${expect_dl_tput}    ${ul_expect_throughput}=${expect_ul_tput}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    FOR  ${i}    IN RANGE    1    5
        log to console    \nBegin to adjust the attenuation
	    ${att_value}    Evaluate    1+5*${i}
        att.set_attenuation    port=${att_port_0}      value=${att_value}
        sleep    2s
        att.set_attenuation    port=${att_port_1}      value=${att_value}
        sleep    2s
     	att.set_attenuation    port=${att_port_2}      value=${att_value}
        sleep    2s
     	att.set_attenuation    port=${att_port_3}      value=${att_value}
        sleep    5s
	    ${passed}=   run_keyword_and_return_status    Check UL and DL TP    dl_expect_throughput=${dl_expect_throughput}
	...    ul_expect_throughput=${ul_expect_throughput}
	    Run Keyword If    ${passed}    Exit For Loop
    END
	should be true    ${passed}
    #Check UL and DL TP    above exists why list here
