*** Settings ***
Documentation
...    author: Xiaodan Li
...    contact: xiaodan.li@nokia-sbell.com
...    squad group: SG_03


Library           taf.transport.ssh    WITH NAME    csn
Library           taf.config.scf    WITH NAME    scf
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Library      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/gnb_operations.py

*** Variables ***
${tl_scf_dir_path}     /opt/workspace/CRT/Master/SCF_file/
${epc_log_path}        /opt/workspace/CRT/Master/Case_Logs/
${TS_LOG_PATH_BASE}         /opt/workspace/CRT/Master/Case_Logs/
${test_pc}    ${tl.test_pc.default_ssh_connection_details.addr}
${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${gnb_index}    ${0}
${bts_host}    ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
@{gnb_list}    ${0}

*** Keywords ***
##cell status
Prepare the gNB cells onair status
    [Arguments]    ${gnb_index}=${0}    ${tl_scf_file_name}=${tl_scf_file_name}
    ${cell_status}    run keyword and return status    Prepare the gNB cells onair    gnb_index=${gnb_index}
    ...                 tl_scf_file_name=${tl_scf_file_name}
    set suite variable    ${cell_status}

Prepare the gNB cells onair
    [Arguments]    ${gnb_index}=${0}    ${tl_scf_file_name}=${tl_scf_file_name}    ${tl_scf_dir_path}=${tl_scf_dir_path}
    login and load scf    bts_host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}    connection=gnb${gnb_index}
    ...                   tl_scf_file_name=${tl_scf_file_name}    tl_scf_dir_path=${tl_scf_dir_path}
    sleep    2min
    wait until keyword succeeds    10 min    20 sec    Check the cells status on air
    ...                   bts_host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}    connection=gnb${gnb_index}

login and load scf
    [Arguments]     ${bts_host}    ${connection}    ${tl_scf_file_name}=${tl_scf_file_name}    ${tl_scf_dir_path}=${tl_scf_dir_path}
    Connect to gnb coam via ssl    connection=${connection}    bts_host=${bts_host}
    COAM Commission with scf file    scf_file_path=${tl_scf_dir_path}${tl_scf_file_name}    timeout=800    is_pdl_checking_needed=${False}
    ...    connection=${connection}
    [Teardown]    coam.teardown    connection=${connection}

Check the cells status on air
    [Arguments]     ${bts_host}=${bts_host}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}    bts_host=${bts_host}
    Verify all cells should be onair    connection=${connection}
    [Teardown]    coam.teardown    connection=${connection}

save scf to ute path
    [Arguments]    ${local_dir_path}    ${file_name}    ${timeout}=${300}    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    coam.get_current_scf_file    local_dir_path=${local_dir_path}    file_name=${file_name}    timeout=${timeout}
    ...    connection=GNB_OAM
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Online modify parmeters
    [Arguments]    ${parameters_to_update}    ${gnb_index}=${0}    ${skip_parameter_relation_errors}=True    ${timeout}=${600}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update}    timeout=${timeout}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Online delete parmeters
    [Arguments]    ${parameters_to_update}    ${gnb_index}=${0}    ${timeout}=${120}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM delete parameters via rest api    parameters_to_delete_via_api=${parameters_to_update}    timeout=${timeout}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Online delete objects
    [Arguments]    ${parameters_to_update}    ${gnb_index}=${0}    ${timeout}=${60}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM delete objects via rest api    objects_to_delete_via_api=${parameters_to_update}    timeout=${timeout}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

paras change on BTS
    [Arguments]    ${paras}    ${delta_file_name}    ${gnb_index}=${0}    ${skip_parameter_relation_errors}=False
    ...    ${connection}=GNB_OAM
    paras_convert_to_json_file    data=${paras}    json_path=${delta_file_name}
    recommission with delta file    delta_file_name=${delta_file_name}    gnb_index=${gnb_index}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}    connection=${connection}

recommission with delta file
    [Arguments]
    ...    ${delta_file_name}
    ...    ${gnb_index}=${0}
    ...    ${skip_parameter_relation_errors}=False
    ...    ${connection}=GNB_OAM
    wait until keyword succeeds    10 min    20 sec
    ...    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}    connection=${connection}
    coam.perform_delta_recommissioning    delta_file=${delta_file_name}    timeout=${300}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}    connection=${connection}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Common Suite Setup for COAM
    robot_common_operations.Common Suite Setup
    COAM Create log directory    ${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
    Create directory    ${epc_log_path}
    Set Suite Variable    ${TS_CASE_LOG_PATH}    ${LOG_PATH}
    set_suite_documentation    doc=All test suite log will save in this VM IP:${test_pc} Path:${epc_log_path}
    ...    append=True

Common Suite Teardown for COAM
    [Arguments]    ${gnb_list}=${gnb_list}    ${log_path}=${epc_log_path}
    robot_common_operations.Common Suite Teardown
    Run keyword if    '${SUITE STATUS}' == 'FAIL'    Run keyword and continue on failure
    ...    COAM Save all gnb snapshot via api    gnb_list=${gnb_list}    log_path=${log_path}
    [Teardown]  Run keyword and ignore error    Tear down the all connections

Common Case Teardown for COAM
    [Arguments]    ${gnb_list}=${gnb_list}    ${log_path}=${epc_log_path}
    robot_common_operations.Common Case Teardown
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure
    ...    COAM Save all gnb snapshot via api    gnb_list=${gnb_list}    log_path=${log_path}
    Run keyword and ignore error    Tear down the all connections
    Run keyword and ignore error    CI_interface.Common Case Teardown

COAM Save all gnb snapshot via api
    [Arguments]    ${gnb_list}=${gnb_list}    ${log_path}=${epc_log_path}
    FOR    ${index}    IN    @{gnb_list}
        COAM Save snapshot via api    gnb_index=${index}    log_path=${log_path}
    END

COAM Save snapshot via api
    [Arguments]    ${gnb_index}=${0}    ${log_path}=${epc_log_path}
    Connect to gnb coam via ssl    connection=gnb${gnb_index}    bts_host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    COAM Save snapshot via rest api    connection=gnb${gnb_index}    log_path=${log_path}    timeout=900
    coam.teardown    connection=gnb${gnb_index}

Tear down the all connections
    Run keyword and ignore error    coam_gnb_classical.COAM Teardown gnb connections
    Run keyword and ignore error    csn.Disconnect    connection=enb
    Run keyword and ignore error    csn.Disconnect    connection=gnb
    Run keyword and ignore error    csn.Disconnect    connection=ASIK Master
    Run keyword and ignore error    csn.Disconnect    connection=BB1

Get completed release
    [Arguments]
    ...    ${bts_index}=${0}
    ...    ${bts_addr}=${tl.gnbs[${bts_index}].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    ${bts_username}=${tl.gnbs[${bts_index}].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    ${bts_password}=${tl.gnbs[${bts_index}].dus[0].airscale.common_units[0].lmp_connection.password}
    csn.Connect To   hostname=${bts_addr}   username=${bts_username}   password=${bts_password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
    ${Strip_info}     Strip String    ${info}
    ${release}     Split String    string=${Strip_info}    separator=_    max_split=1
    Set Suite Variable    ${release_info}    ${release}[1][:-4]
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info

Get sagnb release
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
    ${release_info}     set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
    set suite variable    ${release_info}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info

Get sagnb release title
    [Documentation]    the keyword return realse format : SBTS24R3_ENB_9999
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
    ${release_info}     set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3][0]}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info

Get sagnb version for selenium
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
    ${sw_version}     set variable    ${info.split('_')[1]}
    set suite variable    ${sw_version}
    [Return]    ${sw_version}
    [Teardown]   csn.Disconnect   connection=release_info

get_release_check_result
    [Arguments]    ${release_year_diff}=24    ${release_num_diff}=1
    ${release_info}=    Get sagnb release
    ${check_result}=    check_gnb_release_for_counter_path    release_info=${release_info}
    ...    release_year_diff=${release_year_diff}    release_num_diff=${release_num_diff}
    set suite variable    ${check_result}
    [Return]    ${check_result}

Check the COAM gnb RU status ready
    Connect to gnb coam via ssl
    wait until keyword succeeds    10min   30s    COAM Check GNB RU status
    [Teardown]    COAM Teardown gnb connections

COAM Get nrcellid with lcrid
    [Arguments]   ${lcrid}    ${gnb_index}=${0}
    Wait Until Keyword Succeeds    5m    10s    Connect to gnb coam via ssl    gnb_index=${gnb_index}
#    ${cell_info}   coam.get_subcells_info   timeout=20    connection=GNB_OAM
#    FOR    ${key}    IN    @{cell_info}
#        ${cell_from_cellgrp}    Get from Dictionary    ${cell_info}    ${key}
#        ${nrCellId}    Get nrcellid in all cellgroup with lcrid    cell_from_cellgrp=${cell_from_cellgrp}    lcrid=${lcrid}
#        exit for loop if    '${nrCellId}'!='None'
#    END
#    [Return]    ${nrCellId}
    @{paras}=    Create List    nrCellIdentity    lcrId
    @{paras_info}   coam.get_parameter_by_class   class_name=NRCELL    parameter_list=@{paras}    timeout=60    connection=GNB_OAM
    FOR    ${i}    IN    @{paras_info}
        IF    ${i}[parameters][lcrId] == ${lcrid}
            ${nrCellIdentity}=    Set Variable    ${i}[parameters][nrCellIdentity]
        END
    END
    [Return]    ${nrCellIdentity}
    [Teardown]    COAM Teardown gnb connections

get nrCellIdentity from coam_gnb_classical
    [Documentation]    yayun.zhang a additional method get nrCellIdentity
    [Arguments]    ${lcrid}=1    ${gnb_index}=${0}    #${connection}=GNB_OAM
    Wait Until Keyword Succeeds    5m    10s    Connect to gnb coam via ssl    gnb_index=${gnb_index}
    &{config_info}    Create dictionary
    &{NR_CELL_ID_MAPPING}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids    gnb_index=${gnb_index}
    ${nrCellIdentity}    set variable    ${NR_CELL_ID_MAPPING[${lcrid}]['nrCellIdentity']}
    [Return]    ${nrCellIdentity}
    [Teardown]    COAM Teardown gnb connections

Get nrcellid in all cellgroup with lcrid
    [Arguments]   ${cell_from_cellgrp}    ${lcrid}
    FOR  ${key}  IN   @{cell_from_cellgrp}
        ${eachcell}    Get from Dictionary    ${cell_from_cellgrp}    ${key}
        ${lcrid_get} =    set variable    ${eachcell['NRCELL_L']['parameters']['lcrId']}
        ${nrCellIdentity}     run keyword if     '${lcrid_get}'=='${lcrid}'
    ...    set variable    ${eachcell['NRCELL_L']['parameters']['nrCellIdentity']}
    END
    [Return]    ${nrCellIdentity}

COAM gNB Reset site via api
    [Arguments]   ${gnb_index}=${0}    ${is_need_check_cell_onair}=True    ${wait_for_reconnection}=True
    Connect to gnb coam via ssl    connection=coam_admin    gnb_index=${gnb_index}
    coam.reset_site    wait_for_reconnection=${wait_for_reconnection}    connection=coam_admin
    COAM Teardown gnb connections    connection=coam_admin
    Run Keyword If    ${is_need_check_cell_onair}==True    run keyword
    ...    Wait Until Keyword Succeeds    15min    30sec    Check the cells status on air    bts_host=${bts_host}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

NRCellid Set suit varaible
    [Arguments]    ${cellid}    ${gnb_index}=${0}
    ${nrcellid}    COAM Get nrcellid with the lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    set suite variable    ${nrcellid}
    [Return]    ${nrcellid}

Get physCellId from SCF
    [Arguments]       ${golden_scf_name}    ${gnb_index}=${0}    ${cell_index}=${1}    ${scf_path}=${tl_scf_dir_path}
    scf.Load scf    ${scf_path}/${golden_scf_name}
    ${physcellid}=    scf.get_value_from_scf
    ...    dist_name=MRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRCELL-${cell_index}
    ...    p_name=physCellId
    [Return]     ${physcellid}

Get value of parameter from SCF file
    [Documentation]    author: ming.shi@nokia-sbell.com
    [Arguments]       ${golden_scf_name}    ${dist_name}    ${p_name}    ${scf_path}=${tl_scf_dir_path}
    scf.Load scf    ${scf_path}/${golden_scf_name}
    ${value}=    scf.get_value_from_scf    dist_name=${dist_name}    p_name=${p_name}
    [Return]     ${value}

Get parameter by distname on site
    [Arguments]     ${dist_name}    ${parameter_list}='NULL'    ${gnb_index}=${0}    ${timeout}=300
    ...             ${detailed_output}=False    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    gnb_index=${gnb_index}    connection=${connection}
    ${parameters}    coam.get_parameter_by_distname    dist_name=${dist_name}    parameter_list=${parameter_list}     timeout=${timeout}
    ...                               detailed_output=${detailed_output}    connection=${connection}
    [Return]     ${parameters}
    [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections

Get Rmod Runtime index
    [Arguments]    ${gnb_index}=${0}    ${rmod_index}=${12}
    Connect to gnb coam via ssl    gnb_index=${gnb_index}    connection=coam_admin
    &{hw_info}       coam.get_detected_hw_info    connection=coam_admin
    ${rmod_info}    set variable    ${hw_info.radioModules.rmod}
    FOR  ${ru}  IN  @{rmod_info}
        ${ru_id_conf}  set variable  ${ru.id.configuration}
        ${ruRT_id_conf}  set variable  ${ru.id.internal}
        ${ru_index}    get regexp matches    ${ru_id_conf}    RMOD-(\\d+)    1
        ${ruRT_index}    get regexp matches    ${ruRT_id_conf}    RMOD_R-(\\d+)    1
        ${ruid_match}    Run Keyword And Return Status    should be equal    '${ru_index[0]}'   '${rmod_index}'
        ${rmod_rt_index}    Set Variable If    ${ruid_match}    ${ruRT_index[0]}
        Exit For Loop if    ${rmod_rt_index}!=${None}
    END
    [Return]    ${rmod_rt_index}

####counter
Prepare to caculate PM counter
    [Arguments]    ${period}=start    ${counter_time}=300    ${gnb_index}=${0}
#    ${utc0} =    Get Time    epoch
    ${utc0} =    Get gnb time    gnb_index=${gnb_index}
    ${utc} =    Evaluate    ${utc0}-${utc0}%${counter_time}
    ${utc} =    set variable if    '${period}'=='start'     ${utc+${counter_time}}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    ${counter_time}-${utc0}%${counter_time}
    sleep    ${left_timer}

Get gnb time
    [Arguments]     ${connection}=GNB_OAM    ${gnb_index}=${0}
    ...    ${hostname}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    csn.Connect To   hostname=${hostname}   username=${username}   password=${password}   alias=${connection}
    ${utc0} =    Get Time    epoch
    sleep    3s
    [Teardown]    csn.disconnect    connection=${connection}
    [Return]    ${utc0}

Get the PM counter
    [Arguments]    ${counter_id}    ${dic_path}    ${gnb_index}=${0}    ${timeout}=${300}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    ${counter_value_list}    Create List
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[${index}]}    timeout=${timeout}
        Append to List    ${counter_value_list}    ${counter_value[0]}
    END
    [Return]     ${counter_value_list}
    [Teardown]    COAM Teardown gnb connections

Check the PM counter should be value
    [Arguments]    ${counter_id}    ${dic_path}    ${value}    ${gnb_index}=${0}    ${date}=all
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[${index}]}    date=${date}
        Should contain    ${counter_value}    ${value[${index}]}
    END
    [Teardown]    COAM Teardown gnb connections

Check the PM counter should be greater than 1
    [Arguments]    ${counter_id}    ${dic_path}    ${value}    ${gnb_index}=${0}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[${index}]}
        Should Be True    ${counter_value[0]} > ${value[${index}]}
    END
    [Teardown]    COAM Teardown gnb connections

Download PMCounter File
    [Arguments]     ${PMfile_name}    ${gnb_index}=${0}    ${RD_PM}=RD
    csn.Connect to    hostname=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}    alias=GNB_OAM${gnb_index}
    sleep    3s
    csn.Send Command    command=ls -l /tmp/${RD_PM}.BTS-${gnb_instance${gnb_index}}* | tail -1 | head -1 | awk '{print $9}'
    ...    connection=GNB_OAM${gnb_index}
    ${report_xml}    Run Keyword And Ignore Error    csn.Read Output Until    raw.gz    timeout=5
    ...    connection=GNB_OAM${gnb_index}
    csn.Send Command    command=zcat ${report_xml[1]} >/tmp/${PMfile_name}
    ...    connection=GNB_OAM${gnb_index}
    csn.download_file   remote_path=/tmp/${PMfile_name}   local_path=${epc_log_path}${PMfile_name}
    ...    connection=GNB_OAM${gnb_index}
    sleep    3s
    csn.disconnect      connection=GNB_OAM${gnb_index}

Check the PM counter xml report
    [Arguments]    ${PMfile_name}    ${PM_counter}    ${value}    ${counter_index}   ${gnb_index}=${0}
    Download PMCounter File    PMfile_name=${PMfile_name}    gnb_index=${gnb_index}
    ${counter_lenth}    Get Length    ${PM_counter}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value}=    run
         ...    xmllint --format ${epc_log_path}${PMfile_name} | grep -w ${PM_counter[${index}]} | cut -d '<' -f 2 | cut -d '>' -f 2
        ${counter_value_list}=    String.Split String    ${counter_value}    \n
        should be equal    ${counter_value_list[${counter_index[${index}]}]}    ${value[${index}]}
    END

Record the counter action timer
    @{utc0} =    Get Time    hour min sec    UTC
    ${utc0_min} =    convert to integer  ${utc0}[1]
    ${utc_min} =    Evaluate    ${utc0_min}%5
    Run Keyword If    ${utc_min}>3    Record time again
    ${utc_left} =    Evaluate    5-${utc_min}
    set test variable    ${utc_left}

Record time again
    sleep    1min
    @{utc0} =    Get Time    hour min sec    UTC
    ${utc0_min} =    convert to integer  ${utc0}[1]
    ${utc_min} =    Evaluate    ${utc0_min}%5
    Set Suite Variable    ${utc_min}

Get RMOD Realtime Measurements
    [Arguments]    ${gnb_index}=${0}    ${RU_index}=${1}
    Connect to gnb coam via ssl    connection=coam_admin    gnb_index=${gnb_index}
    ${rmod_measurements}    Create Dictionary
    ${measurements}    coam.get_measurements    connection=coam_admin
    FOR  ${measurement}  IN  @{measurements}
        ${object}    Get Dictionary Keys   ${measurement}
        ${object}    Set Variable   ${object[0]}
        ${is_rmod}    Run Keyword And Return Status    Should Match Regexp    '${object}'   ENERGY_EFFICIENCY/RMOD/RMOD_R-${RU_index}
        ${power}    Set Variable If    ${is_rmod}    ${measurement['${object}']['power']}
        Exit For Loop If    ${is_rmod}
    END
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections
    [Return]    ${power}

Get RMOD Realtime Measurements For Real Ruindex
    [Arguments]    ${gnb_index}=${0}    ${RU_index}=${1}
    Connect to gnb coam via ssl    connection=coam_admin    gnb_index=${gnb_index}
    ${rmod_rt_index}    Get Rmod Runtime index    rmod_index=${RU_index}
    ${rmod_measurements}    Create Dictionary
    ${measurements}    coam.get_measurements    connection=coam_admin
    FOR  ${measurement}  IN  @{measurements}
        ${object}    Get Dictionary Keys   ${measurement}
        ${object}    Set Variable   ${object[0]}
        ${is_rmod}    Run Keyword And Return Status    should be equal    '${object}'   'ENERGY_EFFICIENCY/RMOD/RMOD_R-${rmod_rt_index}'
        ${power}    Set Variable If    ${is_rmod}    ${measurement['${object}']['power']}
        Exit For Loop If    ${is_rmod}
    END
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections
    [Return]    ${power}

get cell status to check
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ${cells_info}=    coam.get_cells_info    connection=GNB_OAM
    sleep    2s
    [Return]    ${cells_info}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

check operationalState of required cell
    [Arguments]    ${cells_info}    ${required_cell}    ${state}
    FOR    ${index}    ${cell_info}    IN ENUMERATE    @{cells_info}
        IF    '${cell_info}[id][configuration]' == '${required_cell}'
            ${operationalState}=    Set Variable    ${cell_info}[status][operationalState]
        END
    END
    Should Be True    '${operationalState}' == '${state}'

get and check operationalState of required cells
    [Arguments]    ${cells}    ${states}    ${gnb_index}=${0}
    ${cells_info}=    get cell status to check     gnb_index=${gnb_index}
    FOR    ${cell}    ${state}    IN ZIP    ${cells}    ${states}
        check operationalState of required cell    cells_info=${cells_info}    required_cell=${cell}    state=${state}
    END
