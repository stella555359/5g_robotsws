*** Settings ***
Documentation
...    author: Liu Xu
...    contact: xu.2.liu@nokia-sbell.com
...    squad group: SG_03
...    feature : CB005739-AG

Library      OperatingSystem
Library      Process
Library      Collections
Library      String
Library      BuiltIn
Library      taf.collectors.btslog   WITH NAME   btslog
Library      taf.transport.ssh    WITH NAME    csn
Library    taf.analyzer.pcap   WITH NAME    cap
#Library    ../../../../../resources/python_libs/Attenuation.py
Variables    ../Resources/Case_commission_5739_AG/__init__.py
Library    taf.gnb.oam.commissioning    WITH NAME    commissioning
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource     taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library      taf.rfrl.common_resources.python.SWConfig    WITH NAME    swconf
Library     taf.hw.rf_attenuator    WITH NAME    att
Library     taf.config.testline    WITH NAME    testline
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py





*** Variables ***
${test_pc}    ${tl.test_pc.default_ssh_connection_details.addr}
${TS_LOG_PATH_BASE}      /opt/workspace/CIT/Master/Case_Logs
${tl_scf_dir_path}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_3_SG/7_5_UTE5G402T354/CB005739-AG/
${tl_scf_filename}    MRBTS_354_SCF_5739_AG.xml
${tl_scf_dir_path_20A}    /opt/workspace/SCF/CB005739-AG/
${tl_scf_filename_20A}    MRBTS_360_SCF_5739_AG.xml
${tl_scf_filename_enb}    TL360_enb_SCF.xml

${tl_scf_dir_path_20B}    /opt/workspace/SCF/CB005739-AG/
${tl_scf_filename_20B}    MRBTS_355_SCF_5739_AG.xml

${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${ENB_ADDRESS}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${enb_instance}     ${tl.enbs[0].instance_id}
${gnb_instance}     ${tl.gnbs[0].instance_id}

${att_ipaddr}                ${tl.attenuator[0].ip_addr}    #FOR TL354 PA ip other pa plz set in case level
${att_port_13}                ${tl.attenuator[0].attenuator_ports[9]}
${att_port_14}                ${tl.attenuator[0].attenuator_ports[10]}
${att_port_15}                ${tl.attenuator[0].attenuator_ports[11]}
${att_port_16}                ${tl.attenuator[0].attenuator_ports[12]}
${att_connection_port}       ${tl.attenuator[0].attenuator_ports[9]}

#TL355

${att_port_9}                ${tl.attenuator[0].attenuator_ports[13]}
${att_port_10}                ${tl.attenuator[0].attenuator_ports[14]}
${att_port_11}                ${tl.attenuator[0].attenuator_ports[15]}
${att_port_12}                ${tl.attenuator[0].attenuator_ports[16]}
${att_connection_port_20B}       ${tl.attenuator[0].attenuator_ports[13]}

# for TL360 PA configuration
${att_port_1}               ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2}               ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3}               ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4}               ${tl.attenuator[0].attenuator_ports[4]}
${att_connection_port_20A}      ${tl.attenuator[0].attenuator_ports[1]}

${att_api_port}              ${tl.attenuator[0].port}
${vendor}                    ${tl.attenuators[0].vendor}
${max_attenuation_value}     ${127}


${enbx2_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-2
${enbx2_dist_20A}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-0
${enbx2_dist_20B}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-1
${enbx2_para}    administrativeState
${lnrel_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-12
${lnrel_dist_20B}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-11
${lnrel_dist_20A}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
${lnrel_para}    defaultLnRelGnbCellId
${f1_sctp_port}    38472
${x2_sctp_port}    29211
${x2_sctp_port_TRUNK}    36422
${tshark_path}    /usr/bin/tshark
${LUA_SCRIPT_PATH}    /home/nokia/luashark/generated_luashark/luashark.lua

${asik_addr_0}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${distname_id_1}            MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}
*** Keywords ***


#Get sagnb release
#    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
#    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
#    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
#    ${release_info}     set variable    ${info.split('_')[1]}
#    [Return]    ${release_info}
#    [Teardown]   csn.Disconnect   connection=release_info

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

Update the swconfig file
    [Arguments]    ${localFilePath}
    run    command=cp ${localFilePath} ${epc_log_path}swconfig.txt
    wait until keyword succeeds    5min    10s    Connect to Common Unit Master   alias=ASIK
    swconf.Upload SwConfig File To Asik And Crasign     localFilePath=${epc_log_path}swconfig.txt    asik_alias=ASIK
    csn.disconnect     connection=ASIK

Modify scf file for case
    [Arguments]    ${modify_list}    ${tl_scf_file}=${tl_scf_filename}
    run keyword and continue on failure     commissioning.Modify Scf    input_scf=${tl_scf_dir_path}${tl_scf_file}
    ...            output_scf=${epc_log_path}${tl_scf_file}    parameters_lists=${modify_list}

Modify scf file for case 20B
    [Arguments]    ${modify_list}    ${tl_scf_file}=${tl_scf_filename_20B}
    run keyword and continue on failure     commissioning.Modify Scf    input_scf=${tl_scf_dir_path_20B}${tl_scf_file}
    ...            output_scf=${epc_log_path}${tl_scf_file}    parameters_lists=${modify_list}

Modify scf file for case 20A
    [Arguments]    ${modify_list}    ${tl_scf_file}=${tl_scf_filename_20A}
    run keyword and continue on failure     commissioning.Modify Scf    input_scf=${tl_scf_dir_path_20A}${tl_scf_file}
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
    [Arguments]    ${dist}=${enbx2_dist}
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    Connect and Modify the parameter on enblte    dist_name=${dist}    parameter=${enbx2_para}    value=unlocked
    lock or unlock enb for sa set    cell_status=unlocked    enb_cell_id=${11}
    Run Keyword And Ignore Error    Common Suite Teardown for COAM
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

Prepare with COAM classical BTS cell onair
    [Arguments]    ${ru_reset}=no    ${lnrel_value}=1    ${tl_scf_file}=${tl_scf_filename}
    Power reset For All RU    ru_reset=${RU_reset}
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=locked
    Perform full commission for COAM gnb    scf_filename=${tl_scf_file}
    Check gnb COAM classical start normally_trunk
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    Connect and Modify the parameter on enblte    dist_name=${lnrel_dist}    parameter=${lnrel_para}    value=${lnrel_value}
    Check the gnb cell status onair


Prepare with COAM classical BTS cell onair 20A
    [Arguments]    ${ru_reset}=no    ${lnrel_value}=3    ${scf_filename}=${tl_scf_filename}
    Power reset For All RU    ru_reset=${RU_reset}
    Perform full commission for COAM gnb    scf_filename=${scf_filename}
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist_20A}    parameter=${enbx2_para}    value=locked
    Check gnb COAM classical start normally
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist_20A}    parameter=${enbx2_para}    value=unlocked
    Connect and Modify the parameter on enblte    dist_name=${lnrel_dist_20A}    parameter=${lnrel_para}    value=${lnrel_value}
    Check the gnb cell status onair

Prepare with COAM classical BTS cell onair 20B
    [Arguments]    ${ru_reset}=no    ${lnrel_value}=1    ${tl_scf_file}=${tl_scf_filename_20B}
    Power reset For All RU    ru_reset=${RU_reset}
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist_20B}    parameter=${enbx2_para}    value=locked
    Perform full commission for COAM gnb    scf_filename=${tl_scf_file}
    Check gnb COAM classical start normally_trunk
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist_20B}    parameter=${enbx2_para}    value=unlocked
    Connect and Modify the parameter on enblte    dist_name=${lnrel_dist_20B}    parameter=${lnrel_para}    value=${lnrel_value}
    Check the gnb cell status onair

Power reset For All RU
    [Arguments]    ${ru_reset}=no
    Run Keyword If   '${ru_reset}'!='yes'  return from keyword   ${ru_reset}
    ${ru_num}    get length    ${tl.gnbs[0].dus[0].rus}
    FOR  ${index}    IN RANGE    ${ru_num}
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
    COAM Commission with scf file    scf_file_path=${tl_scf_dir_path_20A}${scf_filename}    is_pdl_checking_needed=${is_pdl_checking_needed}
    [Teardown]    COAM Teardown gnb connections

Check gnb COAM classical start normally
#    Check Airscale HW module status
#    ${res} =    Feature 1514 Enabled
#    run keyword if    ${res}==${False}    wait until keyword succeeds    10min   30s    Check the sctp port UP    port_num=${f1_sctp_port}
    Check the gnb RU status ready
#    wait until keyword succeeds    10min   30s    Check the sctp port UP    port_num=${x2_sctp_port}

Check gnb COAM classical start normally_trunk
#    Check Airscale HW module status
#    ${res} =    Feature 1514 Enabled
#    run keyword if    ${res}==${False}    wait until keyword succeeds    10min   30s    Check the sctp port UP    port_num=${f1_sctp_port}
    Check the gnb RU status ready
#    wait until keyword succeeds    10min   30s    Check the sctp port UP    port_num=${x2_sctp_port_TRUNK}

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
    [Arguments]      ${value_13}    ${value_14}    ${value_15}    ${value_16}
    [Documentation]    Auther:cris.cai@nokia-sbell.com
    ...                modify HBTE PA 4 port value default value[0-63db] if not set the max_attenuation value below
    ...                for value and not default port 1234, plz set in your case level. setup connection only port1
    ...                if connect on local plz disconnect firstly
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    att.set_attenuation     port=${att_port13}    value=${value_13}
    att.set_attenuation     port=${att_port14}    value=${value_14}
    att.set_attenuation     port=${att_port15}    value=${value_15}
    att.set_attenuation     port=${att_port16}    value=${value_16}
    ${value_port13}    att.read_attenuation    port=${att_port13}
    should be equal    ${value_port13}    ${value_13}
    ${value_port14}    att.read_attenuation    port=${att_port14}
    should be equal    ${value_port14}    ${value_14}
    ${value_port15}    att.read_attenuation    port=${att_port15}
    should be equal    ${value_port15}    ${value_15}
    ${value_port16}    att.read_attenuation    port=${att_port16}
    should be equal    ${value_port16}    ${value_16}

Adjust the HBTE attenuation value 20B
    [Arguments]      ${value_9}    ${value_10}    ${value_11}    ${value_12}
    [Documentation]    Auther:cris.cai@nokia-sbell.com
    ...                modify HBTE PA 4 port value default value[0-63db] if not set the max_attenuation value below
    ...                for value and not default port 1234, plz set in your case level. setup connection only port1
    ...                if connect on local plz disconnect firstly
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port_20B}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
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

Adjust the HBTE attenuation value 20A
    [Arguments]      ${value_1}    ${value_2}    ${value_3}    ${value_4}
    [Documentation]    Auther:cris.cai@nokia-sbell.com
    ...                modify HBTE PA 4 port value default value[0-63db] if not set the max_attenuation value below
    ...                for value and not default port 1234, plz set in your case level. setup connection only port1
    ...                if connect on local plz disconnect firstly
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port_20A}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
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

Make UL data transfer and verify Tput
    [Arguments]    ${ulexpect_tp}    ${retry}=${1}
    FOR   ${index}    IN RANGE    ${retry}
        ${PT_status}    run keyword and return status    L3 call with UL TP check
    ...    ulexpect_tp=${ulexpect_tp}
        exit for loop if   ${PT_status}
    END

Make DL data transfer and verify Tput
    [Arguments]    ${dlexpect_tp}    ${retry}=${1}
    FOR   ${index}    IN RANGE    ${retry}
        ${PT_status}    run keyword and return status    L3 call with DL TP check
    ...    dlexpect_tp=${dlexpect_tp}
        exit for loop if   ${PT_status}
    END

L3 call with UL TP check
    [Arguments]    ${ulexpect_tp}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}   ue_index=${ue_index}    gnb_index=${0}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}    4G_check=False
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=100M
    ...    duration=600s    iperf_port=${ul_port}    ue_index=${ue_index}
#    wait until keyword succeeds    2min   30s    power_ue.Check throughput    direction=ul    throughput=${ulexpect_tp}
#    ...    ue_type=${ue_type}   ue_index=${ue_index}
    ${release_info}    Get sagnb release
    ${list_of_cell_ids}    run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'    Create list    17825791
    ...    ELSE IF   '${release_info}' == 'SBTS22R1_ENB_9999'    Create list    5816319
    ...    ELSE    Create list    5816321
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1m
    Power_ue.Check Tput    ue_type=${ue_type}    direction=UL    log=${tput_log}    cells=${list_of_cell_ids}
    ...    target_throughput=${ulexpect_tp}
    [Teardown]    run keywords


L3 call with DL TP check
    [Arguments]    ${dlexpect_tp}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}   ue_index=${ue_index}    gnb_index=${0}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}    4G_check=False
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=800M
    ...    duration=600s    iperf_port=${dl_port}    ue_index=${ue_index}
#    wait until keyword succeeds    2min   30s    power_ue.Check throughput    direction=dl    throughput=${dlexpect_tp}
#    ...    ue_type=${ue_type}   ue_index=${ue_index}
    ${release_info}    Get sagnb release
    ${list_of_cell_ids}    run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'    Create list    17825791
    ...    ELSE IF   '${release_info}' == 'SBTS22R1_ENB_9999'    Create list    5816319
    ...    ELSE    Create list    5816321
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1m
    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${tput_log}    cells=${list_of_cell_ids}
    ...    target_throughput=${dlexpect_tp}
    [Teardown]    run keywords

Get sagnb release
    [Arguments]   ${host}=${asik_addr_0}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
#    ${release_info}     set variable    ${info.split('_')[4]}
#    ${release_info}     set variable    ${info.split('_')[1]}
    ${release_info}     set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info

Get the Counter value from COAM
    [Arguments]    ${counter_id}    ${dic_path}=full    ${date}=all    ${min_len}=1
    Connect to gnb coam via ssl
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${dic_path}    date=${date}
    ${len}    get length  ${counter_value}
    should be true  ${len} > ${min_len}
    [Return]    ${counter_value[0]}
    [Teardown]    COAM Teardown gnb connections

Start Capture Classical enb x2 Logs
    [Arguments]    ${x2logname}
    RUN KEYWORD AND IGNORE ERROR    enb connections
    Start To Capture Wireshark Logs    filename=${x2logname}    connection=enb    interface=br1
    sleep    3s

Start To Capture Wireshark Logs
    [Arguments]     ${filename}    ${connection}    ${interface}
    gnb connections
    csn.send command    command=tcpdump sctp -i ${interface} -w ${gnb_path}${filename}   connection=${connection}

Stop and Save classical enb x2 Logs
    [Arguments]    ${x2logname}
    enb connections
    Stop and download Logs    logname=${x2logname}    connection=enb

Stop and download Logs
    [Arguments]    ${logname}    ${connection}
    gnb connections
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file   remote_path=${gnb_path}${logname}   local_path=${epc_log_path}${logname}   connection=${connection}
    sleep    3

enb connections
    csn.Connect To    hostname=${ENB_ADDRESS}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=enb

gnb connections
    csn.Connect To    hostname=${asik_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=gnb

Perform full commission for COAM enb BTS
    [Arguments]    ${ENB_ADDRESS}=${ENB_ADDRESS}    ${scf_file_path_enb}=${tl_scf_dir_path_20A}${tl_scf_filename_enb}
    Connect to gnb coam via ssl    connection=enblte    bts_host=${ENB_ADDRESS}
    COAM Commission with scf file    scf_file_path=${scf_file_path_enb}    timeout=600    connection=enblte
    [Teardown]    COAM Teardown gnb connections    connection=enblte
