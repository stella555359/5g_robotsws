*** Settings ***
Documentation     author: yifan hu
...                 contact: yifan.hu@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB007736

Library       OperatingSystem
Library       Collections
Library       taf.transport.ssh    WITH NAME    csn
Library       taf.config.scf    WITH NAME    scf
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource      taf/rfrl/common_resources/robot/coam_selenium.robot
Resource      taf/rfrl/common_resources/robot/connections.robot
Resource      taf/rfrl/common_resources/robot/gnb_classical.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library       taf.sbts.oam.coam.admin   WITH NAME    coam
Library    taf.analyzer.pcap   WITH NAME    parser
Library       taf.hw.rf_attenuator    WITH NAME    attenuator
#Library       sigspark.SigSpark    WITH NAME    spark
Library       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot


*** Variables ***
${ue_type}            ${tl.ues[0].capabilities[0]}
${LOCAL_MASTER_IP}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${PEER_MASTER_IP}     ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}         ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}          ${tl.gnbs[0].cu.oam_http_connection_details.password}
${distname_id_1}      MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}
${LOG_PATH}    /opt/workspace/CIT/Master/Case_Logs/
${TS_LOG_PATH_BASE}    /opt/workspace/CIT/Master/Case_Logs/
${gnb_addr}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${gnb_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${gnb_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${enb_address}     ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${enb_username}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
${enb_password}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
${gnb_instance}    ${tl.gnbs[0].instance_id}
${enb_instance}    ${tl.enbs[0].instance_id}

${att_api_port}         ${tl.attenuator[0].port}
${max_attenuation_value}     ${127}
${vendor}               ${tl.attenuator[0].vendor}
${5GRU_atten_ip_361}    ${tl.attenuator[0].ip_addr}
${5GRU_ANT_361_1}       ${tl.attenuator[0].attenuator_ports[1].port_no}
${5GRU_ANT_361_2}       ${tl.attenuator[0].attenuator_ports[2].port_no}
${5GRU2_ANT_361_1}      ${tl.attenuator[0].attenuator_ports[3].port_no}
${5GRU2_ANT_361_2}      ${tl.attenuator[0].attenuator_ports[4].port_no}
${5GRU3_ANT_361_1}      ${tl.attenuator[0].attenuator_ports[13].port_no}
${5GRU3_ANT_361_2}      ${tl.attenuator[0].attenuator_ports[14].port_no}
${5GRU4_ANT_361_1}      ${tl.attenuator[0].attenuator_ports[5].port_no}
${5GRU4_ANT_361_2}      ${tl.attenuator[0].attenuator_ports[6].port_no}
${5GRU_atten2_ip_361}   ${tl.attenuator[0].ip_addr}
${5GRU_ANT3_361}       ${tl.attenuator[0].attenuator_ports[15].port_no}
${5GRU_ANT4_361}       ${tl.attenuator[0].attenuator_ports[16].port_no}
${5GRU5_atten_ip_361}   ${tl.attenuator[0].ip_addr}
${5GRU5_ANT_361_1}       ${tl.attenuator[0].attenuator_ports[7].port_no}
${5GRU5_ANT_361_2}       ${tl.attenuator[0].attenuator_ports[8].port_no}

${5GRU_atten_ip_371}    ${tl.attenuator[0].ip_addr}
${5GRU_ANT_371_1}       ${tl.attenuator[0].attenuator_ports[1].port_no}
${5GRU_ANT_371_2}       ${tl.attenuator[0].attenuator_ports[2].port_no}
${5GRU2_ANT_371_1}      ${tl.attenuator[0].attenuator_ports[3].port_no}
${5GRU2_ANT_371_2}      ${tl.attenuator[0].attenuator_ports[4].port_no}
${5GRU3_ANT_371_1}      ${tl.attenuator[0].attenuator_ports[5].port_no}
${5GRU3_ANT_371_2}      ${tl.attenuator[0].attenuator_ports[6].port_no}
${5GRU4_ANT_371_1}      ${tl.attenuator[0].attenuator_ports[5].port_no}
${5GRU4_ANT_371_2}      ${tl.attenuator[0].attenuator_ports[6].port_no}
${5GRU_atten2_ip_371}   ${tl.attenuator[0].ip_addr}
${5GRU_ANT3_371}        ${tl.attenuator[0].attenuator_ports[15].port_no}
${5GRU_ANT4_371}        ${tl.attenuator[0].attenuator_ports[16].port_no}
${5GRU5_atten_ip_371}   ${tl.attenuator[0].ip_addr}
${5GRU5_ANT_371_1}      ${tl.attenuator[0].attenuator_ports[7].port_no}
${5GRU5_ANT_371_2}      ${tl.attenuator[0].attenuator_ports[8].port_no}

${5GRU_atten_ip_380}    ${tl.attenuator[0].ip_addr}
${5GRU_ANT_380_1}       ${tl.attenuator[0].attenuator_ports[1].port_no}
${5GRU_ANT_380_2}       ${tl.attenuator[0].attenuator_ports[2].port_no}
${5GRU_ANT_380_3}       ${tl.attenuator[0].attenuator_ports[3].port_no}
${5GRU_ANT_380_4}       ${tl.attenuator[0].attenuator_ports[4].port_no}
${5GRU2_ANT_380_1}      ${tl.attenuator[0].attenuator_ports[9].port_no}
${5GRU2_ANT_380_2}      ${tl.attenuator[0].attenuator_ports[10].port_no}
${5GRU2_ANT_380_3}      ${tl.attenuator[0].attenuator_ports[11].port_no}
${5GRU2_ANT_380_4}      ${tl.attenuator[0].attenuator_ports[12].port_no}
${5GRU4_ANT_380_1}      ${tl.attenuator[0].attenuator_ports[5].port_no}
${5GRU4_ANT_380_2}      ${tl.attenuator[0].attenuator_ports[6].port_no}
${5GRU4_ANT_380_3}      ${tl.attenuator[0].attenuator_ports[7].port_no}
${5GRU4_ANT_380_4}      ${tl.attenuator[0].attenuator_ports[8].port_no}
${5GRU5_atten_ip_380}   ${tl.attenuator[1].ip_addr}
${5GRU5_ANT_380_1}      ${tl.attenuator[1].attenuator_ports[5].port_no}
${5GRU5_ANT_380_2}      ${tl.attenuator[1].attenuator_ports[6].port_no}
${5GRU5_ANT_380_3}      ${tl.attenuator[1].attenuator_ports[7].port_no}
${5GRU5_ANT_380_4}      ${tl.attenuator[1].attenuator_ports[8].port_no}

${traffic_duration}    660
${Send_Tput_DL}    1500M
${Send_Tput_UL}    100M
${command_template_Y}       {tshark_path} -r {pcap_file} -Y  \"f1ap\"  -T pdml
${TIMER_FOR_CELL_ON_AIR}    8min
@{branch}    SBTS23R1_ENB_0000    SBTS23R2_ENB_0000    SBTS23R3_ENB_9999
*** Keywords ***
Common Suite Setup for COAM
    COAM Create log directory    is_set_to_test_case_level=${False}
    ${time_stamp}    DateTime.Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
    Create directory    ${epc_log_path}

Prepare with COAM classical BTS cell onair
    [Arguments]    ${scf_filename}=${tl_scf_filename}
    Perform full commission for COAM gnb    scf_filename=${scf_filename}
    Check gnb COAM classical start normally
    Check the gnb cell status onair

Perform full commission for COAM gnb
    [Arguments]    ${scf_filename}    ${is_pdl_checking_needed}=${False}
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${tl_scf_dir_path}${scf_filename}
    ...    is_pdl_checking_needed=${is_pdl_checking_needed}
    [Teardown]    COAM Teardown gnb connections

Check gnb COAM classical start normally
#    Check Airscale HW module status
    Check the gnb RU status ready

Check the gnb RU status ready
    Connect to gnb coam via ssl
    wait until keyword succeeds    10min   30s    COAM Check GNB RU status
    [Teardown]    COAM Teardown gnb connections

Check the gnb cell status onair
    Connect to gnb coam via ssl
    wait until keyword succeeds    5min   30s    COAM Check GNB cell on air
    [Teardown]    COAM Teardown gnb connections

Reset BTS and check gNB onair
    Reset site via webUI
    COAM Reset Site via webUI
    Check gnb COAM classical start normally
    Check the gnb cell status onair

Lock DSS cell on enb
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-${enb_tl}1    parameter=administrativeState
    ...    value=locked
    run keyword if    ${gnb_instance}==${BTSID}[0]    Lock or unlock DSS cell on enb_361    value=locked
    ...    ELSE IF    ${gnb_instance}==${BTSID}[2]    Lock or unlock DSS cell on enb_380    value=locked
    ...    ELSE    Lock or unlock DSS cell on enb_371    value=locked

Unlock DSS cell on enb
    run keyword if    ${gnb_instance}==${BTSID}[0]    Lock or unlock DSS cell on enb_361    value=unlocked
    ...    ELSE IF    ${gnb_instance}==${BTSID}[2]    Lock or unlock DSS cell on enb_380    value=unlocked
    ...    ELSE    Lock or unlock DSS cell on enb_371    value=unlocked

Lock or unlock DSS cell on enb
    [Arguments]    ${dist_name1}    ${dist_name2}    ${value}=locked
    Connect and Modify the parameter on enblte
    ...    dist_name=${dist_name1}    parameter=administrativeState     value=${value}
    Connect and Modify the parameter on enblte
    ...    dist_name=${dist_name2}    parameter=administrativeState     value=${value}

close DSS cell on gnb and delete XP
    env preparation    parameters_to_update=${PARAMETERS_TO_UPDATE_gnb_DSS_close}
    Delete NRREL online     parameters_to_update=${PARAMETERS_TO_UPDATE_XP_delete}
    run keyword if    ${gnb_instance}==${BTSID}[0]
    ...    env preparation    parameters_to_update=${PARAMETERS_TO_UPDATE_gnb_DSS_close_361}
    ...    ELSE IF    ${gnb_instance}==${BTSID}[2]
    ...    env preparation    parameters_to_update=${PARAMETERS_TO_UPDATE_gnb_DSS_close_380}
    ...    ELSE    env preparation    parameters_to_update=${PARAMETERS_TO_UPDATE_gnb_DSS_close_371}

open DSS cell on gnb
    env preparation    parameters_to_update=${PARAMETERS_TO_UPDATE_gnb_DSS_open}
    run keyword if    ${gnb_instance}==${BTSID}[0]
    ...    env preparation    parameters_to_update=${PARAMETERS_TO_UPDATE_gnb_DSS_open_361}
    ...    ELSE IF    ${gnb_instance}==${BTSID}[2]
    ...    env preparation    parameters_to_update=${PARAMETERS_TO_UPDATE_gnb_DSS_open_380}
    ...    ELSE    env preparation    parameters_to_update=${PARAMETERS_TO_UPDATE_gnb_DSS_open_371}

##################################################
Lock or unlock DSS cell on enb_361
    [Arguments]    ${value}=locked
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-${enb_tl}2    parameter=administrativeState     value=${value}
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-${enb_tl}4    parameter=administrativeState     value=${value}
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-${enb_tl}5    parameter=administrativeState     value=${value}

Lock or unlock DSS cell on enb_371
    [Arguments]    ${value}=locked
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-${enb_tl}2    parameter=administrativeState     value=${value}
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-${enb_tl}4    parameter=administrativeState     value=${value}
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-${enb_tl}5    parameter=administrativeState     value=${value}

Lock or unlock DSS cell on enb_380
    [Arguments]    ${value}=locked
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-${enb_tl}2    parameter=administrativeState     value=${value}
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-${enb_tl}4    parameter=administrativeState     value=${value}
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-${enb_tl}5    parameter=administrativeState     value=${value}

Lock&unlock DSS cell on enb_abil
    Connect and Modify the parameter on enblte    parameter=administrativeState     value=unlocked
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-${enb_tl}2
    Connect and Modify the parameter on enblte    parameter=administrativeState     value=locked
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-${enb_tl}4
    Connect and Modify the parameter on enblte    parameter=administrativeState     value=locked
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-${enb_tl}5

Lock&unlock DSS cell on enb_abio
    Connect and Modify the parameter on enblte    parameter=administrativeState     value=locked
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-${enb_tl}2
    Connect and Modify the parameter on enblte    parameter=administrativeState     value=unlocked
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-${enb_tl}4
    Connect and Modify the parameter on enblte    parameter=administrativeState     value=unlocked
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-${enb_tl}5

##########

Modify NIDD parameter online
    [Arguments]    ${parameters_to_update}
    Connect to gnb coam via ssl
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update}
    ...    timeout=300
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Modify parameters online with restart
    [Arguments]      ${parameters_to_update_via_webui}    ${download_dir}=${epc_log_path}
    ...       ${WEBUI_COAM}=${WEBUI_COAM}
    ...       ${is_need_to_check_validation_errors}=${False}
    ...       ${is_gnb_restrat_after_online_modify}=${True}
    COAM login page via webUI    download_dir=${download_dir}    WEBUI_COAM=${WEBUI_COAM}
    @{diff_para} =    create list
    FOR    ${cur_para_to_update}    IN    @{parameters_to_update_via_webui}
       ${cur_para_value}    selenium_coam.get_parameter_value
       ...    dist_name=${cur_para_to_update['dist_name']}
       ...    abbr=${cur_para_to_update['abbr']}
       ...    filter_param=${cur_para_to_update['filter_param']}
       Run keyword if    '${cur_para_value}'=='${cur_para_to_update['new_value']}'
       ...    Log to console    current value is ${cur_para_value}, no need to update
       ...    ELSE    run keywords
       ...    selenium_coam.set_parameter_value
       ...    dist_name=${cur_para_to_update['dist_name']}
       ...    abbr=${cur_para_to_update['abbr']}
       ...    filter_param=${cur_para_to_update['filter_param']}
       ...    new_value=${cur_para_to_update['new_value']}    AND
       ...    Append to list    ${diff_para}    ${cur_para_to_update}
    END
    Run keyword if    ${diff_para}    run keywords
    ...    selenium_coam.validate_plan    AND
    ...    COAM check validation errors from webui
    ...    is_need_to_check_validation_errors=${is_need_to_check_validation_errors}    AND
    ...    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    AND
    ...    COAM Verify gnb on air after activate plan via webUI    download_dir=${download_dir}
    ...    is_gnb_restrat_after_online_modify=${is_gnb_restrat_after_online_modify}
    [Teardown]    selenium_coam.logout

COAM login page via webUI
    [Arguments]  ${download_dir}=${TS_CASE_LOG_PATH}    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}
    ...                    username=${WEBUI_NAME}
    ...                    password=${WEBUI_PWD}
    ...                    download_dir=${download_dir}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.disable_message_box

Get release info
    ${release_info}    Get sagnb release
    Set Suite Variable    ${release}    ${release_info}
    run keyword if    ${gnb_instance}==${BTSID}[0]    Run keywords
    ...    Set Suite Variable    ${tl_info}    361    AND
    ...    Set Suite Variable    ${enb_tl}    36    AND
    ...    Set Suite Variable    @{pci}    @{pci_361}
    ...    ELSE IF    ${gnb_instance}==${BTSID}[2]    Run keywords
    ...    Set Suite Variable    ${tl_info}    380    AND
    ...    Set Suite Variable    ${enb_tl}    38    AND
    ...    Set Suite Variable    @{pci}    @{pci_380}
    ...    ELSE    Run keywords
    ...    Set Suite Variable    ${tl_info}    371    AND
    ...    Set Suite Variable    ${enb_tl}    37    AND
    ...    Set Suite Variable    @{pci}    @{pci_371}

Get sagnb release
    [Arguments]   ${host}=${gnb_addr}   ${username}=${gnb_username}   ${password}=${gnb_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
    ${release_info}    set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info

gNB connections to ssh
    [Arguments]    ${connection}
    ...    ${hostname}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    ${password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    csn.Connect To    hostname=${hostname}
    ...               username=${username}
    ...               password=${password}
    ...               alias=${connection}

COAM Get nrcellid with lcrid
    [Arguments]   ${lcrid}    ${gnb_index}=${0}
    Connect to gnb coam via ssl
    ${cellgrp_index_list}    Get All Cell Group Id
    ${cell_info}   coam.get_subcells_info   timeout=20    connection=GNB_OAM
    FOR    ${index}    IN    @{cellgrp_index_list}
       ${cell_from_cellgrp}    Get from Dictionary    ${cell_info}    NRCELLGRP-${index}
       ${nrCellId}    Get nrcellid in all cellgroup with lcrid    cell_from_cellgrp=${cell_from_cellgrp}    lcrid=${lcrid}
       exit for loop if    '${nrCellId}'!='None'
    END
    [Return]    ${nrCellId}
    [Teardown]    COAM Teardown gnb connections

Get nrcellid in all cellgroup with lcrid
    [Arguments]   ${cell_from_cellgrp}    ${lcrid}
    ${cell_list}    Get Dictionary Keys    ${cell_from_cellgrp}
    FOR    ${cell}    IN    @{cell_list}
       ${eachcell}    Get from Dictionary    ${cell_from_cellgrp}    ${cell}
       ${lcrid_get} =    set variable    ${eachcell['NRCELL_L']['parameters']['lcrId']}
       ${nrCellIdentity}     run keyword if     '${lcrid_get}'=='${lcrid}'
       ...    set variable    ${eachcell['NRCELL_L']['parameters']['nrCellIdentity']}
    END
    [Return]    ${nrCellIdentity}

Tear down the connections
    Run keyword and ignore error    coam_gnb_classical.COAM Teardown gnb connections
    Run keyword and ignore error    csn.Disconnect    connection=enb
    Run keyword and ignore error    csn.Disconnect    connection=gnb
    Run keyword and ignore error    csn.Disconnect    connection=ASIK Master
    Run keyword and ignore error    csn.Disconnect    connection=BB1

Common Suite Teardown for COAM
    Connect to gnb coam via ssl
    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    [Teardown]    COAM Teardown gnb connections

### UE ###
Check phone attach successfully
    [Arguments]    ${5Gstatus}=PASS    ${abil}=asp1a
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False

### PA adjust ###
Adjust gNB_RU Attenuation for CA
    [Arguments]    ${att_ru1}=${0}    ${att_ru2}=${127}    ${att_ru4}=${127}    ${att_ru5}=${127}
    ...    ${combined_ant3}=${127}    ${combined_ant4}=${127}
    run keyword if    ${gnb_instance}==${BTSID}[2]    Adjust gNB_RU Attenuation for CA on 22R2
    ...    att_ru1=${att_ru1}    att_ru2=${att_ru2}    att_ru4=${att_ru4}    att_ru5=${att_ru5}
    ...    ELSE    Adjust gNB_RU Attenuation for CA on Trunk    att_ru1=${att_ru1}    att_ru2=${att_ru2}    att_ru4=${att_ru4}
    ...    att_ru5=${att_ru5}    combined_ant3=${combined_ant3}    combined_ant4=${combined_ant4}

Adjust gNB_RU Attenuation for CA on Trunk
    [Arguments]    ${att_ru1}=${0}    ${att_ru2}=${127}    ${att_ru4}=${127}    ${att_ru5}=${127}
    ...    ${combined_ant3}=${127}    ${combined_ant4}=${127}
    adjust the HBTE attenuation value    atten_ip=${5GRU_atten_ip_${tl_info}}
    ...    value_1=${att_ru1}    value_2=${att_ru1}    value_3=${att_ru2}    value_4=${att_ru2}
    ...    att_port_1=${5GRU_ANT_${tl_info}_1}    att_port_2=${5GRU_ANT_${tl_info}_2}
    ...    att_port_3=${5GRU2_ANT_${tl_info}_1}    att_port_4=${5GRU2_ANT_${tl_info}_2}
    adjust the HBTE attenuation value    atten_ip=${5GRU_atten_ip_${tl_info}}
    ...    value_1=${att_ru4}    value_2=${att_ru4}    value_3=${att_ru4}    value_4=${att_ru4}
    ...    att_port_1=${5GRU4_ANT_${tl_info}_1}    att_port_2=${5GRU4_ANT_${tl_info}_2}
    ...    att_port_3=${5GRU4_ANT_${tl_info}_1}    att_port_4=${5GRU4_ANT_${tl_info}_2}
    adjust the HBTE attenuation value    atten_ip=${5GRU_atten2_ip_${tl_info}}
    ...    value_1=${combined_ant3}    value_2=${combined_ant3}    value_3=${combined_ant4}    value_4=${combined_ant4}
    ...    att_port_1=${5GRU_ANT3_${tl_info}}    att_port_2=${5GRU_ANT3_${tl_info}}
    ...    att_port_3=${5GRU_ANT4_${tl_info}}    att_port_4=${5GRU_ANT4_${tl_info}}
    adjust the HBTE attenuation value    atten_ip=${5GRU5_atten_ip_${tl_info}}
    ...    value_1=${att_ru5}    value_2=${att_ru5}    value_3=${att_ru5}    value_4=${att_ru5}
    ...    att_port_1=${5GRU5_ANT_${tl_info}_1}    att_port_2=${5GRU5_ANT_${tl_info}_1}
    ...    att_port_3=${5GRU5_ANT_${tl_info}_2}    att_port_4=${5GRU5_ANT_${tl_info}_2}

Adjust gNB_RU Attenuation for CA on 22R2
    [Arguments]    ${att_ru1}=${0}    ${att_ru2}=${127}    ${att_ru4}=${127}    ${att_ru5}=${127}
    adjust the HBTE attenuation value    atten_ip=${5GRU_atten_ip_${tl_info}}
    ...    value_1=${att_ru1}    value_2=${att_ru1}    value_3=${att_ru1}    value_4=${att_ru1}
    ...    att_port_1=${5GRU_ANT_${tl_info}_1}    att_port_2=${5GRU_ANT_${tl_info}_2}
    ...    att_port_3=${5GRU_ANT_${tl_info}_3}    att_port_4=${5GRU_ANT_${tl_info}_4}
    adjust the HBTE attenuation value    atten_ip=${5GRU_atten_ip_${tl_info}}
    ...    value_1=${att_ru2}    value_2=${att_ru2}    value_3=${att_ru2}    value_4=${att_ru2}
    ...    att_port_1=${5GRU2_ANT_${tl_info}_1}    att_port_2=${5GRU2_ANT_${tl_info}_2}
    ...    att_port_3=${5GRU2_ANT_${tl_info}_3}    att_port_4=${5GRU2_ANT_${tl_info}_4}
    adjust the HBTE attenuation value    atten_ip=${5GRU_atten_ip_${tl_info}}
    ...    value_1=${att_ru4}    value_2=${att_ru4}    value_3=${att_ru4}    value_4=${att_ru4}
    ...    att_port_1=${5GRU4_ANT_${tl_info}_1}    att_port_2=${5GRU4_ANT_${tl_info}_2}
    ...    att_port_3=${5GRU4_ANT_${tl_info}_3}    att_port_4=${5GRU4_ANT_${tl_info}_4}
    adjust the HBTE attenuation value    atten_ip=${5GRU5_atten_ip_${tl_info}}
    ...    value_1=${att_ru5}    value_2=${att_ru5}    value_3=${att_ru5}    value_4=${att_ru5}
    ...    att_port_1=${5GRU5_ANT_${tl_info}_1}    att_port_2=${5GRU5_ANT_${tl_info}_2}
    ...    att_port_3=${5GRU5_ANT_${tl_info}_3}    att_port_4=${5GRU5_ANT_${tl_info}_4}

adjust the HBTE attenuation value
    [Arguments]     ${value_1}     ${value_2}     ${value_3}     ${value_4}
    ...             ${att_port_1}    ${att_port_2}     ${att_port_3}    ${att_port_4}     ${atten_ip}
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    attenuator.set_attenuation     port=${att_port_1}    value=${value_1}
    attenuator.set_attenuation     port=${att_port_2}    value=${value_2}
    attenuator.set_attenuation     port=${att_port_3}    value=${value_3}
    attenuator.set_attenuation     port=${att_port_4}    value=${value_4}
    ${value_port_1}    attenuator.read_attenuation    port=${att_port_1}
    should be equal    ${value_port_1}    ${value_1}
    ${value_port_2}    attenuator.read_attenuation    port=${att_port_2}
    should be equal    ${value_port_2}    ${value_2}
    ${value_port_3}    attenuator.read_attenuation    port=${att_port_3}
    should be equal    ${value_port_3}    ${value_3}
    ${value_port_4}    attenuator.read_attenuation    port=${att_port_4}
    should be equal    ${value_port_4}    ${value_4}
    sleep    5s

############### wireshark log #######################
Start Capture Wireshark Logs on ASIK
    [Arguments]     ${nglogname}    ${interface}    ${connection}
    gNB connections to ssh    connection=${connection}
    csn.send command    command=bsh 0:1 tcpdump -i ${interface} sctp -w ${gnb_path}/${nglogname}    connection=${connection}
    sleep    3s
    [Teardown]    csn.disconnect    connection=${connection}

Stop Capture Wireshark Logs on ASIK
    [Arguments]    ${nglogname}    ${connection}
    gNB connections to ssh    connection=${connection}
    csn.send command    command=bsh 0:1 killall tcpdump    connection=${connection}
    sleep    3s
    csn.download_file   remote_path=${gnb_path}/${nglogname}   local_path=${epc_log_path}${nglogname}
    ...    connection=${connection}
    sleep    3s
    [Teardown]    csn.disconnect    connection=${connection}

Start Capture Wireshark Logs on gNB
    [Arguments]     ${nglogname}    ${interface}    ${connection}
    gNB connections to ssh    connection=${connection}
    csn.send command    command=tcpdump -i ${interface} sctp -w ${gnb_path}/${nglogname}    connection=${connection}
    sleep    3s
    [Teardown]    csn.disconnect    connection=${connection}

Stop Capture Wireshark Logs on gNB
    [Arguments]    ${nglogname}    ${connection}
    gNB connections to ssh    connection=${connection}
    csn.send command    command=killall tcpdump    connection=${connection}
    sleep    3s
    csn.download_file   remote_path=${gnb_path}/${nglogname}   local_path=${epc_log_path}${nglogname}
    ...    connection=${connection}
    sleep    3s
    [Teardown]    csn.disconnect    connection=${connection}

Teardown Stop Capture Wireshark Logs on gNB
    [Arguments]    ${connection}=Local gnb1
    gNB connections to ssh    connection=${connection}
    csn.send command    command=command=killall tcpdump     connection=${connection}
    sleep    3
    [Teardown]    csn.disconnect    connection=${connection}

Check wireshark log for 2CC
    [Arguments]    ${logname}    ${expect_value}    ${attribute_name}=show
    ...    ${command_template}=${command_template_Y}
    ...    ${message_filter}=f1ap.procedureCode == 7 and nr-rrc.sCellToAddModList == 1
    ...    ${xpath_filter}=nr-rrc.physCellId
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ...    command_template=${command_template}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression}
    ${filtered_value}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//${xpath_filter}
    ...    attribute_name=${attribute_name}
    should be equal    ${filtered_value[0]}    ${expect_value}

Check wireshark log for 3CC
    [Arguments]    ${logname}    ${expect_value_1}    ${expect_value_2}    ${attribute_name}=show
    ...    ${command_template}=${command_template_Y}
    ...    ${message_filter}=f1ap.procedureCode == 7 and nr-rrc.sCellToAddModList == 2
    ...    ${xpath_filter}=nr-rrc.physCellId
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ...    command_template=${command_template}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression}
    ${filtered_value}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//${xpath_filter}
    ...    attribute_name=${attribute_name}
    should be equal    ${filtered_value[0]}    ${expect_value_1}
    should be equal    ${filtered_value[1]}    ${expect_value_2}

Check scell re-addition
    [Arguments]    ${nglogname}    ${scell1_pci}    ${scell2_pci}    ${interface}=${interface1}
    ...    ${att_ru1}=${20}    ${att_ru2}=${20}    ${att_ru4}=${127}    ${att_ru5}=${127}
    Start Capture Wireshark Logs on gNB    nglogname=${nglogname}    interface=${interface}    connection=Local gnb1
    Adjust gNB_RU Attenuation for CA    att_ru1=${att_ru1}    att_ru2=${att_ru2}    att_ru4=${att_ru4}
    ...    att_ru5=${att_ru5}    combined_ant3=${20}    combined_ant4=${20}
    sleep    5s
    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname}    connection=Local gnb1
    Check wireshark log for 3CC    logname=${nglogname}    expect_value_1=${scell1_pci}    expect_value_2=${scell2_pci}
    [Teardown]    Teardown Stop Capture Wireshark Logs on gNB

Check inter-F intra-gNB HO procedure
    [Arguments]    ${logname}    ${target_cellID}    ${attribute_name}=show
    ...    ${command_template}=${command_template_Y}
    ...    ${message_filter}=f1ap.procedureCode == 7 and nr-rrc.measResultNeighCellListNR == 1
    ...    ${xpath_filter}=.//nr-rrc.MeasResultNR_element/nr-rrc.physCellId
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ...    command_template=${command_template}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression}
    ${filtered_value}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//${xpath_filter}
    ...    attribute_name=${attribute_name}
    should be equal    ${filtered_value[0]}    ${target_cellID}

##### udp tput #####
Start UE DLUL traffic
    [Arguments]
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${Send_Tput_DL}
    ...    duration=${traffic_duration}    ue_index=${0}    protocol=udp
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${Send_Tput_UL}
    ...    duration=${traffic_duration}    ue_index=${0}    protocol=udp

Stop UE DLUL traffic
    [Arguments]
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul

Check 2CC DLUL tput
    [Arguments]    ${pcellid}=1    ${scellid}=3
    ${nrcellid_pcell}    COAM Get nrcellid with lcrid    lcrid=${pcellid}
    ${nrcellid_scell}    COAM Get nrcellid with lcrid    lcrid=${scellid}
    ${nrcellid_pcell}    Create list  ${nrcellid_pcell}
    ${nrcellid_scell}    Create list  ${nrcellid_scell}
    ${tput_log}    power_ue.Collect Tput    duration=30s    ignore_time=0s    ue_type=${ue_type}
    power_ue.Check Tput    direction=DL    cells=${nrcellid_pcell}    log=${tput_log}    ue_type=${ue_type}
    ...    target_throughput=${expected_tput_dl}
    power_ue.Check Tput    direction=DL    cells=${nrcellid_scell}    log=${tput_log}    ue_type=${ue_type}
    ...    target_throughput=${expected_tput_dl}
    power_ue.Check Tput    direction=UL    cells=${nrcellid_pcell}    log=${tput_log}    ue_type=${ue_type}
    ...    target_throughput=${expected_tput_ul}

Check 3CC DLUL tput
    [Arguments]    ${scellid1}=1    ${scellid2}=11    ${pcellid}=2
    ...    ${tput_dl_pcell}=${expected_tput_dl}    ${tput_dl_scell1}=${expected_tput_dl}
    ...    ${tput_dl_scell2}=${expected_tput_dl}    ${tput_ul}=${expected_tput_ul}
    ${nrcellid_pcell}    COAM Get nrcellid with lcrid    lcrid=${pcellid}
    ${nrcellid_scell1}    COAM Get nrcellid with lcrid    lcrid=${scellid1}
    ${nrcellid_scell2}    COAM Get nrcellid with lcrid    lcrid=${scellid2}
    ${nrcellid_pcell}    Create list  ${nrcellid_pcell}
    ${nrcellid_scell1}    Create list  ${nrcellid_scell1}
    ${nrcellid_scell2}    Create list  ${nrcellid_scell2}
    ${tput_log}    power_ue.Collect Tput    duration=30s    ignore_time=0s    ue_type=${ue_type}
    power_ue.Check Tput    direction=DL    cells=${nrcellid_pcell}    log=${tput_log}    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_pcell}
    power_ue.Check Tput    direction=DL    cells=${nrcellid_scell1}    log=${tput_log}    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_scell1}
    power_ue.Check Tput    direction=DL    cells=${nrcellid_scell2}    log=${tput_log}    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_scell2}
    power_ue.Check Tput    direction=UL    cells=${nrcellid_pcell}    log=${tput_log}    ue_type=${ue_type}
    ...    target_throughput=${tput_ul}

Check 3CC DL tput
    [Arguments]    ${scellid1}=1    ${scellid2}=2    ${pcellid}=3
    ...    ${tput_dl_pcell}=${expected_tput_dl}    ${tput_dl_scell1}=${expected_tput_dl}
    ...    ${tput_dl_scell2}=${expected_tput_dl}
    ${nrcellid_pcell}    COAM Get nrcellid with lcrid    lcrid=${pcellid}
    ${nrcellid_scell1}    COAM Get nrcellid with lcrid    lcrid=${scellid1}
    ${nrcellid_scell2}    COAM Get nrcellid with lcrid    lcrid=${scellid2}
    ${nrcellid_pcell}    Create list  ${nrcellid_pcell}
    ${nrcellid_scell1}    Create list  ${nrcellid_scell1}
    ${nrcellid_scell2}    Create list  ${nrcellid_scell2}
    ${tput_log}    power_ue.Collect Tput    duration=30s    ignore_time=0s    ue_type=${ue_type}
    power_ue.Check Tput    direction=DL    cells=${nrcellid_pcell}    log=${tput_log}    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_pcell}
    power_ue.Check Tput    direction=DL    cells=${nrcellid_scell1}    log=${tput_log}    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_scell1}
    power_ue.Check Tput    direction=DL    cells=${nrcellid_scell2}    log=${tput_log}    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_scell2}

SA L3 call with DLUL data and check peak
    [Arguments]    ${nglogname}    ${scell_pci}    ${scellid}    ${pcellid}=1    ${ue_index}=${0}    ${interface}=${interface1}
    ...    ${att2}=${127}    ${att3}=${20}
    Adjust gNB_RU Attenuation for CA    att_ru1=${20}    att_ru2=${127}    att_ru4=${127}
    Start Capture Wireshark Logs on gNB    nglogname=${nglogname}    interface=${interface}    connection=Local gnb1
    Wait until keyword succeeds    3X    10s    Check phone attach successfully
    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname}    connection=Local gnb1
    Check wireshark log for 2CC    logname=${nglogname}    expect_value=${scell_pci}
    Adjust gNB_RU Attenuation for CA    att_ru1=${20}    att_ru2=${att2}    att_ru4=${127}
    ...    combined_ant3=${20}    combined_ant4=${20}
    Start UE DLUL traffic
    Check 2CC DLUL tput    pcellid=${pcellid}    scellid=${scellid}
    Stop UE DLUL traffic
    [Teardown]    Teardown Stop Capture Wireshark Logs on gNB

SA L3 call with DLUL data and check peak_ABIO
    [Arguments]    ${nglogname}    ${scell_pci}    ${scellid}    ${pcellid}=5    ${ue_index}=${0}
    ...    ${att4}=${20}    ${interface}=${interface1}
    Adjust gNB_RU Attenuation for CA    att_ru1=${127}    att_ru2=${127}    att_ru4=${127}
    ...    att_ru5=${20}
    Start Capture Wireshark Logs on gNB    nglogname=${nglogname}    interface=${interface}    connection=Local gnb1
    Wait until keyword succeeds    3X    10s    Check phone attach successfully
    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname}    connection=Local gnb1
    Check wireshark log for 2CC    logname=${nglogname}    expect_value=${scell_pci}
    Adjust gNB_RU Attenuation for CA    att_ru1=${127}    att_ru2=${127}    att_ru4=${att4}
    ...    att_ru5=${20}    combined_ant3=${20}    combined_ant4=${20}
    Start UE DLUL traffic
    Check 2CC DLUL tput    pcellid=${pcellid}    scellid=${scellid}
    Stop UE DLUL traffic
    [Teardown]    Teardown Stop Capture Wireshark Logs on gNB

Start DL traffic and check 3CC tput
    [Arguments]    ${scellid1}=1    ${scellid2}=2    ${pcellid}=3    ${ue_index}=${0}
    ...    ${att_ru1}=${20}    ${att_ru2}=${20}    ${att_ru4}=${127}    ${att_ru5}=${127}
    ...    ${tput_dl_pcell}=${expected_tput_dl}    ${tput_dl_scell1}=${expected_tput_dl}
    ...    ${tput_dl_scell2}=${expected_tput_dl}
    Adjust gNB_RU Attenuation for CA    att_ru1=${att_ru1}    att_ru2=${att_ru2}    att_ru4=${att_ru4}
    ...    att_ru5=${att_ru5}    combined_ant3=${20}    combined_ant4=${20}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${Send_Tput_DL}
    ...    duration=${traffic_duration}    ue_index=${ue_index}    protocol=udp
    Check 3CC DL tput    scellid1=${scellid1}    scellid2=${scellid2}    pcellid=${pcellid}
    ...    tput_dl_pcell=${tput_dl_pcell}    tput_dl_scell1=${tput_dl_scell1}    tput_dl_scell2=${tput_dl_scell2}

Start DLUL traffic and check 3CC tput
    [Arguments]    ${scellid1}=1    ${scellid2}=11    ${pcellid}=2
    ...    ${att_ru1}=${20}    ${att_ru2}=${20}    ${att_ru4}=${127}    ${att_ru5}=${127}
    ...    ${tput_dl_pcell}=${expected_tput_dl}    ${tput_dl_scell1}=${expected_tput_dl}
    ...    ${tput_dl_scell2}=${expected_tput_dl}    ${tput_ul}=${expected_tput_ul}
    Adjust gNB_RU Attenuation for CA    att_ru1=${att_ru1}    att_ru2=${att_ru2}    att_ru4=${att_ru4}
    ...    att_ru5=${att_ru5}    combined_ant3=${20}    combined_ant4=${20}
    Start UE DLUL traffic
    sleep    10s
    Check 3CC DLUL tput    scellid1=${scellid1}    scellid2=${scellid2}    pcellid=${pcellid}
    ...    tput_dl_pcell=${tput_dl_pcell}    tput_dl_scell1=${tput_dl_scell1}
    ...    tput_dl_scell2=${tput_dl_scell2}    tput_ul=${tput_ul}

Tear down UE traffic and detach
    run keywords
    ...    run keyword and ignore error    Stop UE DLUL traffic    AND
    ...    power_ue.UE Detach  ue_type=${ue_type}

########################### NRREL ##############################
Add NRREL MO by rest api and wait onair
    [Documentation]   author: Wang Yixiang
    ...    Modify Nidd parameter and wait onair
    [Arguments]     ${parameters}    ${timeout}=120    ${NSA_SA}=SA
    ${is_enb_status_check_needed}     set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    ${is_x2_check_from_enb_needed}    set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    COAM add several MOs via rest api     objects_to_add_via_api=${parameters}    timeout=${timeout}
#    Wait until cluster is on cell on air status    timeout=${TIMER_FOR_CELL_ON_AIR}
#    ...    is_enb_status_check_needed=${is_enb_status_check_needed}    is_x2_check_from_enb_needed=${is_x2_check_from_enb_needed}

Remove NRREL MO by rest api and wait onair
    [Documentation]   author: Wang Yixiang
    ...    Modify Nidd parameter and wait onair
    [Arguments]     ${parameters}    ${timeout}=120    ${NSA_SA}=SA
    ${is_enb_status_check_needed}     set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    ${is_x2_check_from_enb_needed}    set variable if    '${NSA_SA}'=='SA'    ${False}    ${True}
    COAM delete objects via rest api    objects_to_delete_via_api=${parameters}    timeout=${timeout}
    Wait until cluster is on cell on air status    timeout=${TIMER_FOR_CELL_ON_AIR}
    ...    is_enb_status_check_needed=${is_enb_status_check_needed}    is_x2_check_from_enb_needed=${is_x2_check_from_enb_needed}

Add NRREL online
    [Arguments]    ${parameters_to_update}
    Connect to gnb coam via ssl
    Add NRREL MO by rest api and wait onair    parameters=${parameters_to_update}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Delete NRREL online
    [Arguments]    ${parameters_to_update}
    Connect to gnb coam via ssl
    Remove NRREL MO by rest api and wait onair    parameters=${parameters_to_update}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

ADD cell1 NRREL to cell3
    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_A_B3_NRREL1}

ADD cell2 NRREL to cell1&cell11
    run keyword if    '${release}' == '${branch}[0]'    run keywords
    ...    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AB_B3_NRREL21}
    ...    AND    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AB_B3_NRREL22}
    ...    ELSE IF    '${release}' == '${branch}[1]'    run keywords
    ...    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AB_B3_NRREL21_23R2}
    ...    AND    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AB_B3_NRREL22_23R2}
    ...    ELSE    run keywords    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AB_B3_NRREL21_trunk}
    ...    AND     Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AB_B3_NRREL22_trunk}

ADD cell5 NRREL to cell1&cell11
    run keyword if    '${release}' == '${branch}[0]'    run keywords
    ...    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AB_B3_NRREL51}
    ...    AND    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AB_B3_NRREL52}
    ...    ELSE IF    '${release}' == '${branch}[1]'    run keywords
    ...    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AB_B3_NRREL51_23R2}
    ...    AND    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AB_B3_NRREL52_23R2}
    ...    ELSE    run keywords    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AB_B3_NRREL51_trunk}
    ...    AND    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AB_B3_NRREL52_trunk}

Add cell1 NRREL to cell2&cell3
    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AB_B1_NRREL1}
    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AB_B1_NRREL2}

ADD cell3 NRREL to cell1&cell2
    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AB_B2_NRREL1}
    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AB_B2_NRREL2}

HO preparation
    run keyword if    '${release}' == '${branch}[0]'
    ...    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AB_B3_NRREL23_HO}
    ...    ELSE IF    '${release}' == '${branch}[1]'
    ...    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AB_B3_NRREL23_HO_23R2}
    ...    ELSE    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AB_B3_NRREL23_HO_trunk}

ADD cell5 NRREL to cell4
    run keyword if    ${gnb_instance}==${BTSID}[2]
    ...    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AC_B3_NRREL1_trunk}
#    ...    ELSE IF    '${release}' == '@{branch}[1]'
#    ...    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AC_B3_NRREL1_23R2}
    ...    ELSE    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AC_B3_NRREL1}

Add cell4 NRREL to cell5&cell14_blind
    run keyword if    ${gnb_instance}==${BTSID}[2]    run keywords
    ...    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AD_B1_NRREL1_trunk}
    ...    AND    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AD_B1_NRREL2_trunk}
    ...    ELSE    run keywords    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AD_B1_NRREL1}
    ...    AND    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AD_B1_NRREL2}

ADD cell5 NRREL to cell4&cell14
    run keyword if    ${gnb_instance}==${BTSID}[2]    run keywords
    ...    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AD_B2_NRREL1_trunk}
    ...    AND    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AD_B2_NRREL2_trunk}
    ...    ELSE    run keywords    parameters_to_update=${PARAMETERS_TO_UPDATE_AD_B2_NRREL1}
    ...    AND    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AD_B2_NRREL2}

ADD cell4 NRREL to cell5&cell14
    run keyword if    ${gnb_instance}==${BTSID}[2]    run keywords
    ...    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AD_B3_NRREL41_trunk}
    ...    AND    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AD_B3_NRREL42_trunk}
    ...    ELSE    run keywords    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AD_B3_NRREL41}
     ...    AND   Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AD_B3_NRREL42}

ADD cell1 NRREL to cell4
    run keyword if    '${release}' == '${branch}[0]'
    ...    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AE_B3_NRREL1}
    ...    ELSE IF    '${release}' == '${branch}[1]'
    ...    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AE_B3_NRREL1_23R2}
    ...    ELSE    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AE_B3_NRREL1_trunk}

ADD cell1 NRREL to cell2
    run keyword if    ${gnb_instance}==${BTSID}[2]
    ...    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AE_B3_NRREL2_trunk}
    ...    ELSE    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AE_B3_NRREL2}

#ADD cell4 NRREL to cell1
#    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AE_B3_02_NRREL1}

ADD cell1 NRREL to cell14
    run keyword if    '${release}' == '${branch}[0]'
    ...    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AE_B3_02_NRREL2}
    ...    ELSE IF    '${release}' == '${branch}[1]'
    ...    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AE_B3_02_NRREL2_23R2}
    ...    ELSE    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AE_B3_02_NRREL2_trunk}

#ADD cell2 NRREL to cell1&cell3
#    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AB_B1_03_NRREL1}
#    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AB_B1_03_NRREL2}

ADD cell5 NRREL to cell4&cell14_dss
    run keyword if    '${release}' == '${branch}[0]'   run keywords
    ...    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AD_B1_03_NRREL1}
    ...    AND    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AD_B1_03_NRREL2}
    ...    ELSE IF    '${release}' == '${branch}[1]'    run keywords
    ...    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AD_B1_03_NRREL1_23R2}
    ...    AND    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AD_B1_03_NRREL2_23R2}
    ...    ELSE    run keywords
    ...    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AD_B1_03_NRREL1_trunk}
    ...    AND    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_AD_B1_03_NRREL2_trunk}

ADD cell1 NRREL to cell2&cell4
    run keyword if    '${release}' == '${branch}[0]'   run keywords
    ...    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_DMRS_NRREL12}
    ...    AND    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_DMRS_NRREL14}
    ...    ELSE IF    '${release}' == '${branch}[1]'    run keywords
    ...    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_DMRS_NRREL12_23R2}
    ...    AND    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_DMRS_NRREL14_23R2}
    ...    ELSE    run keywords
    ...    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_DMRS_NRREL12_trunk}
    ...    AND    Add NRREL online    parameters_to_update=${PARAMETERS_TO_UPDATE_DMRS_NRREL14_trunk}
####################### SISO ###############################
Lock Unlock cell1&cell11
    cell lock unlock for gnbBts    cell_idx=${1}    cell_group_idx=${0}
    ...    para_lock=${PARAMETERS_TO_UPDATE_AB_B2_LOCKG1}    para_unlock=${PARAMETERS_TO_UPDATE_AB_B2_UNLOCKG1}
    cell lock unlock for gnbBts    cell_idx=${11}    cell_group_idx=${11}
    ...    para_lock=${PARAMETERS_TO_UPDATE_AB_B2_LOCKG2}    para_unlock=${PARAMETERS_TO_UPDATE_AB_B2_UNLOCKG2}

Lock Unlock cell4&cell14
    cell lock unlock for gnbBts    cell_idx=${4}    cell_group_idx=${3}
    ...    para_lock=${PARAMETERS_TO_UPDATE_AD_B2_LOCKG1}    para_unlock=${PARAMETERS_TO_UPDATE_AD_B2_UNLOCKG1}
    cell lock unlock for gnbBts    cell_idx=${14}    cell_group_idx=${14}
    ...    para_lock=${PARAMETERS_TO_UPDATE_AD_B2_LOCKG2}    para_unlock=${PARAMETERS_TO_UPDATE_AD_B2_UNLOCKG2}

cell lock unlock for gnbBts
    [Arguments]    ${para_lock}    ${para_unlock}    ${cell_idx}    ${cell_group_idx}
    Modify NIDD parameter online    parameters_to_update=${para_lock}
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    180 sec    30 sec    Cell Should Be Locked
    ...    cell_idx=${cell_idx}    cell_group_idx=${cell_group_idx}
    Modify NIDD parameter online    parameters_to_update=${para_unlock}
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    5 min    30 sec     Cell Should Be Unlocked
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Restart ABIL via WEBUI
    Reset ABIL Selenium
    Check the gnb cell status onair

Reset ABIL Selenium
    [Documentation]         Perform Reset on ABIL based on coam Selenium Web driving
    [Arguments]   ${download_dir}=${epc_log_path}
    COAM Navigate to login page via webUI   download_dir=${download_dir}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.reset_abil
    sleep               200s
    [Teardown]    COAM selenium logout

Restart ABIO via WEBUI
    Reset ABIO Selenium
    Check the gnb cell status onair

Reset ABIO Selenium
    [Documentation]         Perform Reset on ABIL based on coam Selenium Web driving
    [Arguments]   ${download_dir}=${epc_log_path}
    COAM Navigate to login page via webUI   download_dir=${download_dir}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.reset_abil    abil_index=3
    sleep               200s
    [Teardown]    COAM selenium logout

Restart gNB
    [Arguments]    ${connection}=GNB_OAM
    gNB connections to ssh    connection=${connection}
    csn.send command    command=system-module-reboot    connection=${connection}
    sleep    90s
    [Teardown]    csn.disconnect    connection=${connection}

Check only default Fault Present
    Connect to gnb coam via ssl
    @{alarm_list}    COAM Get active alarms
    FOR    ${alarms}    IN    @{alarm_list}
       ${alarms_tmp}    Convert To String    ${alarms}[additionalFaultID]
       List Should Contain Value    ${ALLOWED_FAULT}    ${alarms_tmp}
    END
    [Teardown]  COAM Teardown gnb connections

Check expect Fault Present
    [Arguments]    ${expect_alarm}
    ${ALLOWED_FAULT_expect}     set variable    ${ALLOWED_FAULT}
    append to list    ${ALLOWED_FAULT_expect}    ${expect_alarm}
    Connect to gnb coam via ssl
    @{alarm_list}    COAM Get active alarms
    ${current_faultid}    Create List
    FOR    ${alarms}    IN    @{alarm_list}
        ${alarm_tmp}    Convert To String    ${alarms}[additionalFaultID]
        append to list    ${current_faultid}    ${alarm_tmp}
        List Should Contain Value    ${ALLOWED_FAULT_expect}    ${alarm_tmp}
    END
    List Should Contain Value    ${current_faultid}    ${expect_alarm}
    [Teardown]  COAM Teardown gnb connections

### counter ###
Check the PM counter shuould be specific value
    [Arguments]    ${counter_id}    ${dic_path}    ${value}
    ${counter_lenth}    Get Length    ${counter_id}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[${index}]}
        Should be equal    ${counter_value[0]}    ${value}
    END
    [Teardown]    COAM Teardown gnb connections

Check the PM counter should not be zero
    [Arguments]    ${counter_id}    ${dic_path}
    ${counter_result_value}    Create List
    ${counter_result}    Create List
    ${counter_lenth}    Get Length    ${counter_id}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[${index}]}
        ${counter_dict}    Create Dictionary    ${counter_id[${index}]}=${counter_value[0]}
        append to list    ${counter_result_value}    ${counter_value[0]}
        append to list    ${counter_result}    ${counter_dict}
    END
    ${counter_result_lenth}    Get Length    ${counter_result_value}
    Should be equal    ${counter_lenth}    ${counter_result_lenth}
    Should not contain    ${counter_result_value}    ${0}    msg=check counter fail
    [Teardown]    COAM Teardown gnb connections

Record the counter action timer
    @{utc0} =    Get Time    hour min sec    UTC
    ${utc0_min} =    convert to integer  ${utc0}[1]
    ${utc_min} =    Evaluate    ${utc0_min}%5
    Run Keyword If    ${utc_min}>3    Record time again
#    ${utc_left} =    Evaluate    5-${utc_min}+1
    ${utc_left} =    Evaluate    5-${utc_min}
    set test variable    ${utc_left}

Record time again
    sleep    1min
    @{utc0} =    Get Time    hour min sec    UTC
    ${utc0_min} =    convert to integer  ${utc0}[1]
    ${utc_min} =    Evaluate    ${utc0_min}%5
    Set Suite Variable    ${utc_min}

################### others ################
env preparation
    [Arguments]    ${parameters_to_update}
    Modify NIDD parameter online    parameters_to_update=${parameters_to_update}
    Check the gnb cell status onair

Case Teardown
    [Arguments]    ${parameters}
    Run Keyword And Ignore Error    Delete NRREL online    parameters_to_update=${parameters}
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
    Run Keyword And Ignore Error    Tear down the connections

Case Teardown_AE
    [Arguments]    ${parameters1}    ${parameters2}
    Run Keyword And Ignore Error    Delete NRREL online    parameters_to_update=${parameters1}
    Run Keyword And Ignore Error    Delete NRREL online    parameters_to_update=${parameters2}
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
    Run Keyword And Ignore Error    Tear down the connections

UE attach and check CA relation_3CC
    [Arguments]    ${nglogname}    ${scell1_pci}    ${scell2_pci}    ${ue_index}=${0}    ${interface}=${interface1}
    ...    ${att_ru1}=${127}    ${att_ru2}=${127}    ${att_ru4}=${127}    ${att_ru5}=${127}
    Adjust gNB_RU Attenuation for CA    att_ru1=${att_ru1}    att_ru2=${att_ru2}    att_ru4=${att_ru4}
    ...    att_ru5=${att_ru5}
    Start Capture Wireshark Logs on gNB    nglogname=${nglogname}    interface=${interface}    connection=Local gnb1
    Wait until keyword succeeds    3X    10s    Check phone attach successfully
    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname}    connection=Local gnb1
    Check wireshark log for 3CC    logname=${nglogname}    expect_value_1=${scell1_pci}    expect_value_2=${scell2_pci}
    [Teardown]    Teardown Stop Capture Wireshark Logs on gNB

UE attach and check CA relation_2CC
    [Arguments]    ${nglogname}    ${scell_pci}    ${ue_index}=${0}    ${interface}=${interface1}
    ...    ${att_ru1}=${127}    ${att_ru2}=${127}    ${att_ru4}=${127}    ${att_ru5}=${127}
    Adjust gNB_RU Attenuation for CA    att_ru1=${att_ru1}    att_ru2=${att_ru2}    att_ru4=${att_ru4}
    ...    att_ru5=${att_ru5}
    Start Capture Wireshark Logs on gNB    nglogname=${nglogname}    interface=${interface}    connection=Local gnb1
    Wait until keyword succeeds    3X    10s    Check phone attach successfully
    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname}    connection=Local gnb1
    Check wireshark log for 2CC    logname=${nglogname}    expect_value=${scell_pci}
    [Teardown]    Teardown Stop Capture Wireshark Logs on gNB
