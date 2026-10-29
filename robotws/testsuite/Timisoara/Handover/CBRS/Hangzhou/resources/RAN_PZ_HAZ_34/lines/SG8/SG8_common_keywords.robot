*** Settings ***
Documentation    This is for SG8 common keywords
...              Author: lanwen.cai
...              Squard: HZ SG8

Library    testsuite.Timisoara.Handover.CBRS.Hangzhou.resources.RAN_PZ_HAZ_34.python.gnb_alarm.AlarmWatchdog    WITH NAME    AlarmWatchdog
Library    ../../../RAN_PZ_HAZ_34/robot/siso_common_case/lib/made_lib.py
Library    ../../../RAN_PZ_HAZ_34/robot/siso_common_case/lib/get_ru_variables.py
Resource   ../../../RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource   ../../../RAN_PZ_HAZ_34/robot/bts/common/btslog.robot
Resource   ../../../RAN_PZ_HAZ_34/robot/bts/common/csn.robot
Resource   ../../../RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource   ../../../RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_log.robot
Resource   ../../../RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot

Library    taf.selenium.sbts    WITH NAME    selenium_coam
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.ue    WITH NAME    taf_ue
Resource    ../../../RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    ../../../RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    ../../../RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource    ../../../RAN_PZ_HAZ_34/robot/aasyslog.robot
Library     ../../../RAN_PZ_HAZ_34/lines/SG8/SG8_common.py
Library    random

#*** Variables ***


*** Keywords ***
create lbpsPeriodList list
    [Arguments]    ${lbpsDayOfWeek}=Fri    ${lbpsDuration}=1440    ${lbpsStartTimeHour}=0    ${lbpsStartTimeMinute}=0
    ...    ${lbpsSuspended}=notSuspended
    log to console    start set lbps time duration:${lbpsDuration}, day:${lbpsDayOfWeek}, hour:${lbpsStartTimeHour}, min:${lbpsStartTimeMinute}
    ${tmp}    create dictionary
    ...    lbpsDayOfWeek    ${lbpsDayOfWeek}
    ...    lbpsDuration    ${lbpsDuration}
    ...    lbpsStartTimeHour    ${lbpsStartTimeHour}
    ...    lbpsStartTimeMinute    ${lbpsStartTimeMinute}
    ...    lbpsSuspended    ${lbpsSuspended}
    ${tmp}     Create List    ${tmp}
    [Return]    ${tmp}

Change lbpsPeriodList by Coam
    [Arguments]    ${NRPGRP_index}=1    ${lbpsDuration}=1440    ${lbpsSuspended}=notSuspended    ${connection}=GNB_OAM
    ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_week_and_time
    ${tmp}    create lbpsPeriodList list    lbpsDayOfWeek=${lbpsDayOfWeek}    lbpsDuration=${lbpsDuration}    lbpsStartTimeHour=${lbpsStartTimeHour}
    ...    lbpsStartTimeMinute=${lbpsStartTimeMinute}    lbpsSuspended=${lbpsSuspended}
    ${lbpsPeriodList}      create dictionary
    ...    dist_name    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_index}
    ...    parameter    lbpsPeriodList
    ...    value        ${tmp}
    ${parameters}    Create List    ${lbpsPeriodList}
    ${delta_file}=   coam_parameter.create_update_parameters_delta  parameters=${parameters}  connection=${connection}
    coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}    connection=${connection}

online change actNrLBmMimoRTXPowerSaving
    [Arguments]    ${actNrLBmMimoRTXPowerSaving}=false
    selenium login and disable screen lock
    ${old_value}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
	...    filter_param=Activate NR load-based mMIMO TX power saving
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate NR load-based mMIMO TX power saving    abbr=actNrLBmMimoRTXPowerSaving    new_value=${actNrLBmMimoRTXPowerSaving}
    selenium_coam.validate_plan
    Wait Until Keyword Succeeds    5x     20s    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=${300}
    Run Keyword If    '${old_value}'=='false' and '${actNrLBmMimoRTXPowerSaving}'=='true'
	...    Wait Until Keyword Succeeds    5min    30s    RU Should Be Offline    ru_index=${1}
	...    ELSE    Wait until keyword succeeds    1min    30s    verify all cells should be onair
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    [Teardown]    selenium logout and close browser

Recovery actNrLBmMimoRTXPowerSaving due to IWK
    Change lbpsPeriodList by Coam    lbpsDuration=1
    online change actNrLBmMimoRTXPowerSaving    actNrLBmMimoRTXPowerSaving=true

COAM get parameter value
    [Arguments]     ${class_name}    ${pattern}    ${cellID}=1    ${celltype}=nr    ${connection}=GNB_OAM
    ${MO_tmp}    coam.get_managed_objects    class_name=${class_name}    connection=${connection}
    ${distname_tmp}    Set variable    ${MO_tmp[0]['distName']}
    ${distname}    Run Keyword If   '${celltype}'=='nr'    get_nrcell_distname    dist_before=${distname_tmp}    cellid=${cellID}
    ...    ELSE    get_ltecell_distname_sg08    dist_before=${distname_tmp}    cellid=${cellID}
    ${dict_pattern}     coam.get_parameters    dist_name=${distname}    pattern=${pattern}    connection=${connection}
    ${pattern_value}    set variable     ${dict_pattern['${pattern}']}
    [Return]    ${pattern_value}

Check cell EnergySaving state via COAM
    [Arguments]     ${expect_energySavingState}=notEnergySaving    ${class_name}=NRCELL_R    ${cellID}=1    ${celltype}=nr
    ${energy_State}    SG8_common_keywords.COAM get parameter value    class_name=${class_name}    pattern=energySavingState    cellID=${cellID}
    ...    celltype=${celltype}
    Should Be Equal As Strings    ${energy_State}   ${expect_energySavingState}

Check keyword with retry
    [Arguments]    ${case_name}   &{kwargs}
    log to console    \n***${case_name} with retry***
    ${status}    set variable
    FOR  ${i}  IN RANGE  2
        ${status}   run keyword and return status    ${case_name}    &{kwargs}
        exit for loop if    ${status}
    END
    run keyword if      not ${status}    FAIL

Get the diff
    [Arguments]  ${num1}    ${num2}
    ${different}=   Run Keyword If    ${num1}>${num2}
	...    Evaluate    ${num1}-${num2}
    ...    ELSE    Evaluate    ${num2}-${num1}
    [Return]    ${different}

Get mrbtsID and lnbtsID via SCF
    [Arguments]    ${scf_path}
    ${lncell}    Run    cat ${scf_path} | grep -oE "MRBTS-[0-9]+/LNBTS-[0-9]+" | head -n 1
    ${mrbtsID}    Run    echo ${lncell}|grep -oE "MRBTS-[0-9]+"| awk -F '-' '{print $2}'
    ${lnbtsID}    Run    echo ${lncell}|grep -oE "LNBTS-[0-9]+"| awk -F '-' '{print $2}'
    [Return]    ${mrbtsID}    ${lnbtsID}

UE attach and start traffic
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]start UE attach and start traffic
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    [Arguments]  ${ue_index}=${0}    ${dl_tp}=300M    ${ul_tp}=100M    ${traffic_duration}=${1800}    ${protocol}=udp
    ...     ${iperf_type}=via_command    ${ui_version}=default    ${set_ue_technology}=${False}    ${pci}=${0}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    log to console    \n***Start UE attach***
    run keyword and ignore error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    ui_version=${ui_version}
    run keyword and ignore error    csn.disconnect    connection=ASIK Master
    run keyword if    '${set_ue_technology}'=='${True}'
    ...    taf_ue.set_access_technology    UE_${ue_index}    technology=NR5GSA    preferred=NR5GSA
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    pci=${pci}    timeout=900
    sleep    5s
    Connect to Common Unit Master    alias=ASIK MASTER
    connect to gnb coam via ssl    connection=GNB_OAM
#    ${cell_id}    wait until keyword succeeds   10min    5s    get_ue_attached_cell_id_from_log    log_path=/tmp/5Grach.txt
#        ...    alias=ASIK MASTER    connection=GNB_OAM
    ${iperf_type}     Run keyword if    '${ue_type}'=='huawei'     Set Variable    via_app
    log to console    \n***Start traffic***
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    throughput=${dl_tp}
    ...    duration=${traffic_duration}    protocol=${protocol}
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul    throughput=${ul_tp}
    ...    duration=${traffic_duration}    protocol=${protocol}    iperf_type=${iperf_type}

Stop Single UE L3 Call
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Stop Single UE L3 Call
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    [Arguments]  ${ue_index}=${0}
    log to console    \n***Stop Single UE L3 Call***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    run keyword and ignore error  power_ue.Stop traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl
    run keyword and ignore error  power_ue.Stop traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul
    ${status}  ${5Grach_ed}  run keyword and ignore error   power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

data_transfer_common
    [Documentation]    make call for all pointed cell.
    ...  :author  linjiangjing
    ...  :param  cell_id: if cell_id is not None, make call according cell_id list. E.G [1, 2]
    ...  :param  ru_index: if cell_id is None, and ru_index is not None, make call on cells under the pointed ru. E.G 1
    ...                    if both cell_id and ru_index are None, make call on all cells
    ...  :param  tput_from: if its value is tool, tput will be calculated by nrdim tool, otherwise, tput will get from dict
    ...                     tput_self_define defined in variable.py
    [Arguments]    ${tput_self_define}    ${ru_index}=${None}    ${cell_id}=${None}    ${target_avg_percent}=${None}    ${min_percent}=${None}
    ...    ${protocol}=udp    ${duration}=${600}    ${gnb_index}=0    ${du_index}=0    ${tput_from}=tool
    ...    ${loop_times}=${2}    ${alias}=ASIK MASTER    ${connection}=GNB_OAM    ${process_num_ul}=1    ${ui_version}=default
    ...    ${pci}=${0}    ${scf_name}=${None}    ${buffer_size}=1400B
#    ${ue_index_list}    create list
#    set test variable    ${ue_index_list}
    ${tput_self_define}    get_self_define_tput_by_release    tput_info=${tput_self_define}
    ${cell_list}    run keyword if    ${cell_id}!=${None}    set variable    ${cell_id}
    ...    ELSE    Get All Cell Id    ru_index=${ru_index}
    ${avg_expect_rate}    Run Keyword If    ${target_avg_percent}==${None}    get_avg_expect_rate    ELSE
    ...    set variable    ${target_avg_percent}
    ${min_expect_rate}    Run keyword If    ${min_percent}==${None}    get_min_expect_rate    ELSE
    ...    set variable    ${min_percent}
    FOR  ${i}  IN RANGE  ${loop_times}
        ${status}    run keyword and return status    make_call_and_check_tput_for_all_cells    tput_info=${tput_self_define}
        ...    cell_list=${cell_list}    tput_from=${tput_from}    protocol=${protocol}
        ...    duration=${duration}    gnb_index=${gnb_index}    du_index=${du_index}    target_avg_percent=${avg_expect_rate}
        ...    min_percent=${min_expect_rate}    alias=${alias}    connection=${connection}    process_num_ul=${process_num_ul}
        ...    ui_version=${ui_version}    pci=${pci}    scf_name=${scf_name}    buffer_size=${buffer_size}
        exit for loop if    ${status}
    END
    run keyword if      not ${status}    FAIL


data_transfer_common_lte
    [Arguments]    ${tput_self_define}    ${cell_id}    ${target_avg_percent}=${None}    ${min_percent}=${None}
    ...    ${duration}=${600}    ${omit_time}=10
    ${tput_self_define}    get_self_define_tput_by_release    tput_info=${tput_self_define}
    ${ue_index}    set variable    ${tput_self_define[${cell_id}]['ue_index']}
    ${ue_type_4G}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${throughput_dl}    set variable    ${tput_self_define[${cell_id}]['dl_tp']}
    ${throughput_ul}    set variable    ${tput_self_define[${cell_id}]['ul_tp']}
    ${target_throughput_dl}    set variable    ${tput_self_define[${cell_id}]['dl_exp']}
    ${target_throughput_ul}    set variable    ${tput_self_define[${cell_id}]['ul_exp']}
    ${avg_expect_rate}    Run Keyword If    ${target_avg_percent}==${None}    get_avg_expect_rate    ELSE
    ...    set variable    ${target_avg_percent}
    ${min_expect_rate}    Run keyword If    ${min_percent}==${None}    get_min_expect_rate    ELSE
    ...    set variable    ${min_percent}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}
    ...    ue_index=${ue_index}
    sleep    ${duration}s
    run keyword and ignore error    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${ue_index}
    check_tput_for_4G_call_config    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl}
    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${ue_index}    omit_time=${omit_time}
    ...    target_avg_percent=${avg_expect_rate}    min_percent=${min_expect_rate}
    [Teardown]    run keyword and ignore error    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${ue_index}

make_call_and_check_tput_for_all_cells
    [Documentation]    make call for all pointed cell.
    ...  :author  linjiangjing
    ...  :param  tput_info: E.G
    ...          {
    ...              1: {
    ...                  'dl_exp': 300,
    ...                  'dl_tp': '500M',
    ...                  'ul_exp': 20,
    ...                  'ul_tp': '50M',
    ...                  'ue_index': 0
    ...              },
    ...          }
    ...  :param  cell_list: E.G [1, 2]
    ...  :param  tput_from: if its value is tool, tput will be calculated by nrdim tool, otherwise, tput will get from dict
    ...                     tput_self_define defined in variable.py
    [Arguments]    ${tput_info}    ${cell_list}    ${tput_from}=tool    ${protocol}=udp    ${duration}=600
    ...    ${gnb_index}=0    ${du_index}=0    ${target_avg_percent}=0.98    ${min_percent}=0.85    ${check_source}=Aasyslog
    ...    ${alias}=ASIK MASTER    ${connection}=GNB_OAM    ${process_num_ul}=1    ${ui_version}=default
    ...    ${pci}=${0}    ${scf_name}=${None}    ${buffer_size}=1400B
    ${tput_info_total}    create dictionary
    FOR  ${cell_index}  IN  @{cell_list}
        ${ue_index}    set variable    ${tput_info[${cell_index}]['ue_index']}
        log to console    use ue${ue_index} to make call on cell${cell_index}
        ${tput_cell}    run keyword if    '${tput_from}'=='tool'    get_tput_info_by_tool
        ...    cell_id=${cell_index}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    scf_name=${scf_name}
        ...    duration=${duration}    connection=${connection}    ue_index=${ue_index}    ELSE    set variable    ${tput_info[${cell_index}]}
        log to console    tput info for cell ${cell_index} is: ${tput_cell}
        set to dictionary    ${tput_info_total}    ${cell_index}    ${tput_cell}
        make_call    tput_info=${tput_cell}    ue_index=${ue_index}    protocol=${protocol}
        ...    gnb_index=${gnb_index}    du_index=${du_index}    alias=${alias}    connection=${connection}
        ...    process_num_ul=${process_num_ul}    ui_version=${ui_version}    pci=${pci}    buffer_size=${buffer_size}
    END
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=${check_source}
    FOR  ${cell_index}  IN  @{cell_list}
        ${ue_index}    set variable    ${tput_info[${cell_index}]['ue_index']}
        check_tput_for_each_cell    tput_info=${tput_info_total}    cell_id=${cell_index}    ue_index=${ue_index}    tput_log=${tput_log}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    connection=${connection}
    END
    [Teardown]    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}    protocol=${protocol}

get_self_define_tput_by_release
    [Arguments]    ${tput_info}
    ${release}    Get program version based on gNB active version
    ${release}    run keyword if    '${release}'=='master'    set variable    SBTS00    ELSE
    ...    set variable    ${release}
    @{releases}    Get Dictionary Keys    ${tput_info}
    ${status}    check_whether_all_sbts_version    releases=${releases}
    return from keyword if    'common' not in @{releases} and '${status}'=='False'    ${tput_info}
    ${tput_info}    run keyword if    '${release}' in @{releases}    get from dictionary    ${tput_info}    ${release}
    ...    ELSE    get from dictionary    ${tput_info}    common
    [Return]    ${tput_info}

check_whether_all_sbts_version
    [Arguments]    ${releases}
    FOR    ${release}    IN    @{releases}
        log to console    ${release}
        ${all_start_with_SBTS}    Run Keyword And Return Status    Should start with    ${release}    SBTS
        return from keyword if    not ${all_start_with_SBTS}    ${all_start_with_SBTS}
    END
    [Return]    ${all_start_with_SBTS}

make_call
    [Documentation]    use pointed ue to make call
    ...  :author  linjiangjing
    ...  :param  tput_info: dict, should contain dl_tp and ul_tp. E.G
    ...          {
    ...              'dl_tp': '500M',
    ...              'ul_tp': '50M',
    ...          }
    [Arguments]    ${tput_info}    ${ue_index}=0    ${protocol}=udp    ${gnb_index}=0    ${du_index}=0
    ...    ${alias}=ASIK MASTER    ${duration_call}=${3600}    ${connection}=GNB_OAM    ${process_num_ul}=1    ${ui_version}=default
    ...    ${pci}=${0}    ${buffer_size}=1400B
    log to console    ${alias}
    log to console    ${connection}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    run keyword and ignore error    Wait Until Keyword Succeeds    8x     20s    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ...    ui_version=${ui_version}
    run keyword if    '${ue_type}'=='huawei_sigspark'   prepare_aasyslog_process    gnb_index=${gnb_index}    du_index=${du_index}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=5G_${gNb_CuType}    pci=${pci}    timeout=900
#    ${cell_id}    get_ue_attached_cell_id    ue_index=${ue_index}    alias=${alias}    connection=${connection}
    #log to console    ue attached to cell ${cell_id}
    ${status}    run keyword and return status     Get Length    ${ue_index_list}
    run keyword if    ${status}==False    create empty list
    Run Keyword If   ${ue_index} not in ${ue_index_list}    append to list    ${ue_index_list}    ${ue_index}
    ${iperf_type}  set variable if  '${ue_type}'=='huawei'    via_app    via_command
    ${dl_tp}    set variable    ${tput_info['dl_tp']}
    ${ul_tp}    set variable    ${tput_info['ul_tp']}
    ${tput_spark}    run keyword if    '${ue_type}'=='huawei_sigspark'    generate_tput_for_spark_ue    dl_tp=${dl_tp}    ul_tp=${ul_tp}
    ${dl_tp}    run keyword if    '${ue_type}'=='huawei_sigspark'    set variable     ${tput_spark[0]}   ELSE    set variable   ${dl_tp}
    ${ul_tp}    run keyword if    '${ue_type}'=='huawei_sigspark'    set variable    ${tput_spark[1]}    ELSE    set variable   ${ul_tp}
    ${process_num_dl}    set variable if      '${protocol}'=='udp'    ${1}    ${16}
    log to console    start dl traffic...
    Wait Until Keyword Succeeds    5x     20s    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
    ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    process_num=${process_num_dl}    ue_mode=${gNb_CuType}
    log to console    start ul traffic...
    Wait Until Keyword Succeeds    5x     20s    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
    ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    iperf_type=${iperf_type}
    ...    data_amount=2M    ue_mode=${gNb_CuType}    process_num=${process_num_ul}    buffer_size=${buffer_size}

create empty list
    ${ue_index_list}    create list
    set test variable    ${ue_index_list}

generate_tput_for_spark_ue
    [Documentation]    unit adaption of dl_tp and ul_tp for spark ue
    ...  :author  linjiangjing
    ...  :param   dl_tp:  500M, return 500M/sec
    ...  :param   ul_tp:  50M, return 50M/sec
    [Arguments]    ${dl_tp}    ${ul_tp}
    ${dl_tp}    Fetch From Left    ${dl_tp}    .
    ${ul_tp}    Fetch From Left    ${ul_tp}    .
    ${dl_tp}    run keyword if    '${dl_tp[-1]}'!='M'    set variable    ${dl_tp}M/sec    ELSE
    ...    set variable    ${dl_tp}/sec
    ${ul_tp}    run keyword if    '${ul_tp[-1]}'!='M'    set variable    ${ul_tp}M/sec    ELSE
    ...    set variable    ${ul_tp}/sec
    [Return]    ${dl_tp}  ${ul_tp}

check_tput_for_each_cell
    [Documentation]    check tput for pointed cell
    ...  :author  linjiangjing
    ...  :param  tput_info    dict, key is cell id. value should contain dl_exp and ul_exp. E.G
    ...          {
    ...              1: {
    ...                  'dl_exp': 300,
    ...                  'ul_exp': 20,
    ...              },
    ...          }
    ...  :param  cell_id E.G 1
    ...  :param  ue_index E.G 0
    ...  :param  tput_log  output of power_ue.Collect Tput
    [Arguments]    ${tput_info}    ${cell_id}    ${ue_index}    ${tput_log}    ${target_avg_percent}=0.98    ${min_percent}=0.85
    ...    ${duration}=600    ${connection}=GNB_OAM
    log to console    ${duration}
    ${dl_exp}    set variable    ${tput_info[${cell_id}]['dl_exp']}
    ${ul_exp}    set variable    ${tput_info[${cell_id}]['ul_exp']}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${connection}
    ${cell_id}    Convert To String    ${cell_mapping[${cell_id}]['nrCellIdentity']}
    ${cell_id}    Create List    ${cell_id}
    ${ue_type}    run keyword if    '${ue_type}'=='huawei_sigspark'    set variable    huawei    ELSE    set variable    ${ue_type}
    ${output}    power_ue.Check Bi Tput   ue_type=nokia_fastmile    log=${tput_log}    cells=${cell_id}    ultarget_throughput=${ul_exp}
    ...    dltarget_throughput=${dl_exp}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    set test variable    ${output}
    log to console    \n${output}

check_tput_for_each_cell_for_config
    [Documentation]    check tput for pointed cell
    ...  :author  linjiangjing
    ...  :param  cell_id E.G 1
    ...  :param  ue_index E.G 0
    ...  :param  tput_log  output of power_ue.Collect Tput
    [Arguments]    ${cell_id}    ${ue_index}    ${tput_log}    ${target_avg_percent}=0.98    ${min_percent}=0.85
    ...    ${connection}=GNB_OAM
    ${tput_info}    get_tput_info_by_tool    cell_id=${cell_id}
    ${dl_exp}    set variable    ${tput_info['dl_exp']}
    ${ul_exp}    set variable    ${tput_info['ul_exp']}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${connection}
    ${cell_id}    Convert To String    ${cell_mapping[${cell_id}]['nrCellIdentity']}
    ${cell_id}    Create List    ${cell_id}
    ${ue_type}    run keyword if    '${ue_type}'=='huawei_sigspark'    set variable    huawei    ELSE    set variable    ${ue_type}
    ${output}    power_ue.Check Bi Tput   ue_type=nokia_fastmile    log=${tput_log}    cells=${cell_id}    ultarget_throughput=${ul_exp}
    ...    dltarget_throughput=${dl_exp}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    set test variable    ${output}
    log to console    \n${output}

traffic_stop_and_detach_ue
    [Documentation]    stop traffic and detach ue
    ...  :author  linjiangjing
    ...  :param  ue_index_list E.G [0], [0,1]
    [Arguments]    ${ue_index_list}    ${protocol}=udp
    FOR  ${ue_index}  IN    @{ue_index_list}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        ${iperf_type}  set variable if  '${ue_type}'=='huawei'    via_app    via_command
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
        ...    iperf_type=${iperf_type}    protocol=${protocol}
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
        ...    protocol=${protocol}
        run keyword and ignore error    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    END

prepare_aasyslog_process
    [Documentation]    kill the old aaslog progress, and start a new one
    ...  :author  linjiangjing
    [Arguments]    ${gnb_index}=0    ${du_index}=0
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2   log_name=5Grach.txt

get_ue_attached_cell_id
    [Documentation]    get ue attached cell id from aaslog log generated after the attach operation
    ...  :author  linjiangjing
    [Arguments]    ${ue_index}=0    ${alias}=ASIK MASTER    ${connection}=GNB_OAM
    Connect to Common Unit Master  alias=${alias}
    Wait Until Keyword Succeeds    5min    30s    connect to gnb coam via ssl    connection=${connection}
    ${time}  get time  epoch
    ${attach_log}    set variable    /tmp/5Grach.txt
    ${local_dir}    set variable    ${SAVE LOG DIRECTORY}/attach_ue_${ue_index}/${time}
    run keyword and ignore error    run keywords    Create directory    ${local_dir}    AND
    ...    csn.download file    remote_path=${attach_log}    local_path=${local_dir}/5Grach.txt   connection=${alias}
    ${cell_id}    wait until keyword succeeds   10min    5s    get_ue_attached_cell_id_from_log    log_path=${attach_log}
    ...    alias=${alias}    connection=${connection}
    log to console    ue attached to cell ${cell_id}
    run keyword and ignore error    csn.Execute    rm ${attach_log}   connection=${alias}
    [Return]    ${cell_id}

get_tput_info_by_tool
    [Documentation]    return the tput calculated by nrdim tool
    ...  :author  linjiangjing
    [Arguments]    ${cell_id}=1    ${target_avg_percent}=0.98    ${min_percent}=0.85    ${duration}=600
    ...    ${connection}=GNB_OAM    ${ue_index}=${0}    ${scf_name}=${None}
    ${release}    Get program version based on gNB active version
    ${scf_path}    download scf download via rest api    scf_dir_path=${SAVE LOG DIRECTORY}    connection=${connection}
    ${nband}    Get Cell Nband    cell_id=${cell_id}    connection=${connection}
    ${bbname}    Get bbmod name    cell_id=${cell_id}    connection=${connection}
    ${bbname}    set variable if    '${bbname}'=='${None}'    ABIO AirScale Capacity    ${bbname}
    ${testline_name}    Get Testline Name
    ${ue_ul_layer}    get_ue_ul_layer_from_ue_mapping_file    testline_name=${testline_name}
    ...    scf_name=${scf_name}    ue_index=${ue_index}
    ${ue_dl_layer}    get_ue_dl_layer_from_ue_mapping_file    testline_name=${testline_name}
    ...    scf_name=${scf_name}    ue_index=${ue_index}
    ${tput_info}    generate_real_peak_info    cell_id=${cell_id}    scf_path=${scf_path}   ue_ul_layer=${ue_ul_layer}
    ...     avg_expect_rate=${target_avg_percent}    min_expect_rate=${min_percent}    duration=${duration}
    ...    nband=${nband}    productName=${bbname}    release=${release}    ue_dl_layer=${ue_dl_layer}
    [Return]    ${tput_info}

get_avg_expect_rate
    [Documentation]    get target average percent of tput. if rate_for_stream is not defined in variable.py, the default value is 0.98
    ...  :author  linjiangjing
    ${release}    Get program version based on gNB active version
    ${status}    run keyword and return status    variable should exist    ${rate_for_stream}
    @{dict_keys}    run keyword if    ${status}    Get Dictionary Keys    ${rate_for_stream}
    ${rate_avg}    run keyword if    '${release}' in @{dict_keys}    get from dictionary    ${rate_for_stream}    ${release}
    ...    ELSE    set variable    ${0.98}
    ${rate_avg}    run keyword if   '${rate_avg}'=='peak'    set variable    ${0.98}
    ...    ELSE    set variable    ${rate_avg}
    [Return]    ${rate_avg}

get_min_expect_rate
    [Documentation]    get min percent of tput. if rate_for_stream_min is not defined in variable.py, the default value is 0.85
    ...  :author  linjiangjing
    ${release}    Get program version based on gNB active version
    ${status}    run keyword and return status    variable should exist    ${rate_for_stream_min}
    @{dict_keys}    run keyword if    ${status}    Get Dictionary Keys    ${rate_for_stream_min}
    ${rate_min}    run keyword if    '${release}' in @{dict_keys}    get from dictionary    ${rate_for_stream_min}    ${release}
    ...    ELSE    set variable    ${0.85}
    [Return]    ${rate_min}

Get LTE Cell Status
    [Arguments]  ${cell_idx}=${1}    ${connection}=GNB_OAM
    ${cell_idx}   Convert To Integer   ${cell_idx}
    ${cells_info}    coam.get_cells_info   cell_type=lte    connection=${connection}
    ${cells_num}    Get Length    ${cells_info}
    ${cell_status}    create dictionary
    FOR    ${index}    IN RANGE    ${cells_num}
        ${cell_info}    set variable    ${cells_info}[${index}]
        ${cell_id}    set variable    ${cell_info['globalCellId']}
        Exit For Loop If    ${cell_id}==${cell_idx}
    END
    ${operationalState}    set variable    ${cell_info['status']['operationalState']}
    Set to Dictionary    ${cell_status}    operationalState    ${operationalState}
    ${administrativeState}    set variable    ${cell_info['status']['administrativeState']}
    Set to Dictionary    ${cell_status}    administrativeState    ${administrativeState}
    ${blockingState}    set variable    ${cell_info['status']['blockingState']}
    Set to Dictionary    ${cell_status}    blockingState    ${blockingState}
#    ${availabilityStatus}    set variable    ${cell_info['status']['availabilityStatus']}
#    Set to Dictionary    ${cell_status}    availabilityStatus    ${availabilityStatus}
    [Return]   ${cell_status}

Get LTE Cell Numbers
    [Arguments]    ${connection}=GNB_OAM
    ${cells_info}    coam.get_cells_info   cell_type=lte    connection=${connection}
    ${cells_num}    Get Length    ${cells_info}
    [Return]    ${cells_num}

LTE Cell Should Be Blocked
    [Arguments]  ${cell_idx}=${1}    ${connection}=GNB_OAM
    ${cell_status}    Get LTE Cell Status    cell_idx=${cell_idx}    connection=${connection}
    Should Be Equal As Strings  ${cell_status["operationalState"]}    disabled
    Should Be Equal As Strings  ${cell_status["administrativeState"]}    unlocked
    Should Be Equal As Strings  ${cell_status["blockingState"]}    Blocked
#    Should Be Equal As Strings  ${cell_status["availabilityStatus"]}    off line

LTE Cell Should Be UnBlocked
    [Arguments]  ${cell_idx}=${1}    ${connection}=GNB_OAM
    ${cell_status}    Get LTE Cell Status    cell_idx=${cell_idx}    connection=${connection}
    Should Be Equal As Strings  ${cell_status["operationalState"]}    enabled
    Should Be Equal As Strings  ${cell_status["administrativeState"]}    unlocked
    Should Be Equal As Strings  ${cell_status["blockingState"]}    Unblocked

Block LTE cells and check status
    [Arguments]  ${block_list}    ${connection}=GNB_OAM
    connect to gnb coam via ssl    connection=${connection}
    log to console  \n***Block lte cells and check status***
    FOR    ${idx}  IN  @{block_list}
        selenium_coam.block_cell    cell_idx=${idx}    technology=LTE
        Wait Until Keyword Succeeds   3 min  10 sec   LTE Cell Should Be Blocked   cell_idx=${idx}
    END

UnBlock LTE cells and check status
    [Arguments]  ${block_list}    ${connection}=GNB_OAM
    connect to gnb coam via ssl    connection=${connection}
    log to console  \n***UnBlock lte cells and check status***
    FOR    ${idx}  IN  @{block_list}
        selenium_coam.unblock_cell    cell_idx=${idx}    technology=LTE
        Wait Until Keyword Succeeds   3 min  10 sec   LTE Cell Should Be UnBlocked   cell_idx=${idx}
    END

NR RAT Reset
    [Arguments]    ${connection}=GNB_OAM
    selenium_coam.reset_nr
    sleep    180s
    Wait Until Keyword Succeeds    20 min    10 sec    Verify all cells should be onair    connection=${connection}

LTE RAT Reset
    [Arguments]    ${connection}=GNB_OAM
    selenium_coam.reset_lte
    sleep    180s
    Wait Until Keyword Succeeds    20 min    10 sec    Verify all lte cells should be onair    connection=${connection}

Verify all lte cells should be disabled
    [Arguments]    ${cell_type}=lte  ${connection}=GNB_OAM
    Log to console    Verify all lte cells should be disabled
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        Should Be Equal As Strings    ${cell['status']['administrativeState']}     unlocked
        Should be equal as Strings    ${cell['status']['operationalState']}    disabled
        Should Be Equal As Strings    ${cell['status']['blockingState']}    Unblocked
    END

Verify all lte cells should be onair
    [Arguments]    ${cell_type}=lte  ${connection}=GNB_OAM
    Log to console    Verify all lte cells are on air
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        Should Be Equal As Strings    ${cell['status']['administrativeState']}     unlocked
        Should be equal as Strings    ${cell['status']['operationalState']}    enabled
        Should Be Equal As Strings    ${cell['status']['blockingState']}    Unblocked
    END

make_call_4G
    [Arguments]  ${ue_type_4G}    ${throughput_dl}    ${throughput_ul}    ${duration_call}=${3600}    ${ue_index}=${0}    ${process_num_ul}=1
    run keyword and ignore error    power_ue.Prepare UE    ue_type=${ue_type_4G}    ue_index=${ue_index}
    taf_ue.set_access_technology    UE_${ue_index}    technology=LTE    preferred=LTE
    ${log_type}    run keyword if    '${ue_type_4G}'=='nokia_fastmile'    set variable    Iperf
    ...    ELSE    set variable    Aasyslog
    power_ue.UE Attach    ue_type=${ue_type_4G}    ue_index=${ue_index}    log_type=${log_type}    timeout=900
    power_ue.Start traffic    ue_type=${ue_type_4G}    direction=dl    throughput=${throughput_dl}
    ...    duration=${duration_call}    ue_index=${ue_index}
    log to console    4G call dl start ...
    power_ue.Start traffic    ue_type=${ue_type_4G}    direction=ul    throughput=${throughput_ul}
    ...    duration=${duration_call}    ue_index=${ue_index}    process_num=${process_num_ul}
    log to console    4G call ul start ...

detach_for_4G_call
    [Arguments]  ${ue_type_4G}    ${ue_index}=${0}
    power_ue.UE Detach  ue_type=${ue_type_4G}    ue_index=${ue_index}

stop_traffic_for_4G_call
    [Arguments]  ${ue_type_4G}    ${ue_index}=${0}
    run keywords    power_ue.Stop traffic    ue_type=${ue_type_4G}    direction=ul
    ...    ue_index=${ue_index}    AND    power_ue.Stop traffic    ue_type=${ue_type_4G}    direction=dl    ue_index=${ue_index}

stop_traffic_and_detach_for_4G_call
    [Arguments]  ${ue_type_4G}    ${ue_index}=${0}
    run keywords    power_ue.Stop traffic    ue_type=${ue_type_4G}    direction=ul
    ...    ue_index=${ue_index}    AND    power_ue.Stop traffic    ue_type=${ue_type_4G}    direction=dl    ue_index=${ue_index}
    power_ue.UE Detach  ue_type=${ue_type_4G}    ue_index=${ue_index}
    sleep    5s

check_tput_for_4G_call
    [Arguments]  ${ue_type_4G}    ${target_throughput_dl}    ${target_throughput_ul}    ${log_dir}=${TS_CASE_LOG_PATH}    ${ue_index}=${0}
    ...    ${duration}=10m    ${target_avg_percent}=0.98    ${min_percent}=0.85    ${ignore_time}=10    ${stop_mtk}=True    ${stop_cpe}=False
    log to console    collect tput for 4G call ...
    Run Keyword and Ignore Error    _Prepare Variables    ue_index=${ue_index}
    ${log_type}    run keyword if    '${ue_type_4G}'=='nokia_fastmile'    set variable    Iperf
    ...    ELSE    set variable    Aasyslog
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type_4G}    log_dir=${log_dir}    ue_index=${ue_index}    duration=${duration}
    ...    check_source=${log_type}    ignore_time=${ignore_time}
    Run keyword and ignore error     run keyword if    '${ue_type_4G}'=='mtk_lte' and '${stop_mtk}'=='True'    stop_traffic_for_4G_call
    ...    ue_type_4G=${ue_type_4G}    ue_index=${ue_index}
    Run keyword and ignore error     run keyword if    '${ue_type_4G}'=='nokia_fastmile' and '${stop_cpe}'=='True'    stop_traffic_for_4G_call
    ...    ue_type_4G=${ue_type_4G}    ue_index=${ue_index}
    log to console    check 4G dl tput ...
    power_ue.Check Tput    ue_type=${ue_type_4G}    direction=dl    target_throughput=${target_throughput_dl}
    ...    log=${log_path}    ue_index=${ue_index}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    omit_time=${ignore_time}
    log to console    check 4G ul tput ...
    power_ue.Check Tput    ue_type=${ue_type_4G}    direction=ul    target_throughput=${target_throughput_ul}
    ...    log=${log_path}    ue_index=${ue_index}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    omit_time=${ignore_time}

check_tput_for_4G_call_config
    [Arguments]  ${ue_type_4G}    ${target_throughput_dl}    ${target_throughput_ul}    ${ue_index}=${0}
    ...    ${target_avg_percent}=0.98    ${min_percent}=0.85    ${omit_time}=10
    Set Test Variable    ${omit_time}
    Run Keyword and Ignore Error    _Prepare Variables    ue_index=${ue_index}
    log to console    check 4G dl tput ...
    power_ue.Check Tput    ue_type=${ue_type_4G}    direction=dl    target_throughput=${target_throughput_dl}
    ...    log=${log_path}    ue_index=${ue_index}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    omit_time=${omit_time}
    log to console    check 4G ul tput ...
    power_ue.Check Tput    ue_type=${ue_type_4G}    direction=ul    target_throughput=${target_throughput_ul}
    ...    log=${log_path}    ue_index=${ue_index}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    omit_time=${omit_time}

Suite Teardown For Config Recovery
    [Arguments]    ${gnb_index}=0
    log to console    \n***SISO Coam Suite Teardown***
    robot_common_operations.CommonSuiteTeardown
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status    connection=${connection}
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair    connection=${connection}
    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
    COAM Teardown gnb connections    connection=${connection}
    Run Keyword And Ignore Error    process.Terminate All Processes    kill=True

5GC000560_eLLF_PTP_Failure_with_call
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test is to verify when set wrong input sync for RAU
    ...    the syncstatus and lockstatus changed right both on webUI and RU soap log
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 30.9.2020 - - Created
    ...    *******************
    ...    melinda.gao@nokia-sbell.com
    [Arguments]    ${tput_define}    ${cell_id}
    ${sync_old}    get sync info of GNB
    set suite variable  ${sync_old}
    set sync info of GNB
    check sync status change of GNB
    Wait For Expect Fault Present    faultId=${16}    timeout=1200
    Wait For Expect Fault Present    faultId=${4298}    timeout=1200
    check sync info of RU    status='abnormal'
    set sync info of GNB    syncinput=${sync_old['syncinput']}    acceptclock=${sync_old['acceptclock']}
    Wait For Expect Fault To Disappear    faultId=${16}    timeout=1200
    Wait For Expect Fault To Disappear    faultId=${4298}    timeout=1200
    check sync info of RU    status='normal'
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    data_transfer_common    tput_self_define=${tput_define}    cell_id=${cell_id}    loop_times=${1}    duration=${300}

reboot_asky_or_cpe_ue
    [Documentation]  Use adb command to reboot askey and cpe ue
    [Arguments]    ${ue_index}=${0}
    _Prepare Variables    ue_index=${ue_index}
    csn.connect to    hostname=${cpc_ip}    username=${cpc_username}    password=${cpc_password}  alias=cpc_${ue_index}    look_for_keys=False
    csn.execute    command=adb -s ${serial} reboot   connection=cpc_${ue_index}
    sleep    45s
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}

reboot_ue_except_askey_and_cpe
    [Documentation]  Use adb command to reboot ue except askey and cpe
    [Arguments]    ${ue_index}=${0}
    ...    ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${username}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${password}=${tl.ues[${ue_index}].ssh_connection_details.password}
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.connect to    hostname=${hostname}    username=${username}    password=${password}  alias=cpc_${ue_index}    look_for_keys=False
    csn.execute    command=adb -s ${serial_number} reboot    connection=cpc_${ue_index}
    sleep    45s
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}

Set Whole Attenuator Ports
    [Documentation]    setting ports value for matrix pa
    [Arguments]    ${attenuator_out_ports}    ${attenuator_rows}    ${exp_pa_value}=${127}
    Connect to Attenuator
    Log to console    start to set whole PA ports, out_ports:${attenuator_out_ports}, rows:${attenuator_rows}, exp value:${exp_pa_value}
    FOR    ${out_port}    IN    @{attenuator_out_ports}
       _set PA value each attenuator line    out_port=${out_port}    attenuator_rows=${attenuator_rows}    exp_pa_value=${exp_pa_value}
    END

Connect to Attenuator
    [Arguments]    ${attenuation_port_numbers}=${1}    ${attenuator_index}=${0}    ${alias}=ATTEN_${attenuator_index}
    ${attenuator_addr}    set variable    ${tl.attenuators[${attenuator_index}].ip_addr}
    ${attenuator_api_port}    set variable    ${tl.attenuators[${attenuator_index}].port}
    ${vendor}    set variable    ${tl.attenuators[${attenuator_index}].__class__.__name__}
    ${model}    set variable    ${tl.attenuators[${attenuator_index}].model}
    Wait Until Keyword Succeeds    90 sec    3 sec    attenuator.setup_attenuator
    ...    ip_addr=${attenuator_addr}
    ...    port=${attenuator_api_port}
    ...    attenuation_port_numbers=${attenuation_port_numbers}
    ...    vendor=${vendor}
    ...    alias=${alias}
    ...    model=${model}

_set PA value each attenuator line
    [Documentation]    setting ports value for matrix pa
    [Arguments]   ${out_port}    ${attenuator_rows}    ${exp_pa_value}
    FOR    ${row_index}    IN RANGE    ${1}    ${attenuator_rows}+1
        ${atten_port}    evaluate    (${out_port}-1)*${attenuator_rows}+${row_index}
        wait until keyword succeeds    5    1s    attenuator.set_attenuation    port=${atten_port}    value=${exp_pa_value}
        ...                                                confirm=${True}    attenuator_device=ATTEN_0
    END

Set PA Value For Pointed Port
    [Arguments]    ${PA_Port_List}    ${attenuator_index}=${0}    ${value}=${127}    ${alias}=ATTEN_${attenuator_index}
    ${PA}    attenuator.setup_attenuator    attenuator=${tl.attenuators[${attenuator_index}]}    alias=${alias}
    FOR    ${port}    IN    @{PA_Port_List}
        ${port}  Evaluate  int(${port})
        attenuator.set_attenuation    port=${port}    value=${value}    attenuator_device=${PA}
    END

Get PA Ports For each RU
    [Arguments]    ${ru_index}
    ${PA_RU}    gnb_classical_hangzhou.Get Attenuation Channels For RU    RU_id=${ru_index}
    [Return]    ${PA_RU}

Get values from specified List
    [Arguments]    ${origin_list}    ${index_start}    ${index_end}
    ${result_list}    create list
    FOR    ${i}    IN RANGE    ${index_start}    ${index_end}
        Append To List   ${result_list}      ${origin_list}[${i}]
    END
    [Return]    ${result_list}

Clear tmp files for ELT
    [Arguments]    ${ELT_install_path}    ${ue_index}=0    ${cpc_alias}=cpc_${ue_index}
    Wait until keyword succeeds    1 min    2 sec    Connect to ue control pc    ue_index=${ue_index}    cpc_alias=${cpc_alias}
    ${output}    csn.send command    command=rm -rf ${ELT_install_path}/*.tmp   connection=${cpc_alias}
    [Teardown]    Run keyword and ignore error    ssh.disconnect    connection=${cpc_alias}

check and power on or off enb
    [Arguments]    ${enb_index}=${0}    ${unit_index}=${0}    ${powerStatus}=on
    ${enb_model}    set variable    ${tl.enbs[${enb_index}].airscale.common_units[${unit_index}].pdu_port.pdu.__class__.__name__}
    ${enb_pdu_ip}    set variable  ${tl.enbs[${enb_index}].airscale.common_units[${unit_index}].pdu_port.pdu.addr}
    ${enb_pdu_port}    set variable  ${tl.enbs[${enb_index}].airscale.common_units[${unit_index}].pdu_port.port_no}
    log to console    model is ${enb_model}, enb_pdu_ip is ${enb_pdu_ip}, enb_pdu_port is ${enb_pdu_port}
    pdu.Setup Pdu    model=${enb_model}   host=${enb_pdu_ip}    alias=enb_pdu
    ${port_status}    pdu.Get Port Status    port=${enb_pdu_port}    pdu_device=enb_pdu
    log to console    port status of enb pdu is ${port_status}
    run keyword if    '${port_status}'=='off' and '${powerStatus}'=='on'    pdu.power on    port=${enb_pdu_port}    pdu_device=enb_pdu
    ...    ELSE IF    '${port_status}'=='on' and '${powerStatus}'=='off'    pdu.power off    port=${enb_pdu_port}    pdu_device=enb_pdu

check and power on gnb
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${unit_index}=${0}
    ${gnb_model}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${unit_index}].pdu_port.pdu.__class__.__name__}
    ${gnb_pdu_ip}    set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${unit_index}].pdu_port.pdu.addr}
    ${gnb_pdu_port}    set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${unit_index}].pdu_port.port_no}
    log to console    model is ${gnb_model}, gnb_pdu_ip is ${gnb_pdu_ip}, gnb_pdu_port is ${gnb_pdu_port}
    pdu.Setup Pdu    model=${gnb_model}   host=${gnb_pdu_ip}    alias=gnb_pdu
    ${port_status}    pdu.Get Port Status    port=${gnb_pdu_port}    pdu_device=gnb_pdu
    log to console    port status of gnb pdu is ${port_status}
    run keyword if    '${port_status}'=='off'    pdu.power on    port=${gnb_pdu_port}    pdu_device=gnb_pdu

check and power on rus
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}
    ${ru_numbers}    get length    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus}
    log to console    ru_numbers: ${ru_numbers}
    FOR    ${index}    IN RANGE    0    ${ru_numbers}
        ${model}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${index}].pdu_port.pdu.__class__.__name__}
        ${address}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${index}].pdu_port.pdu.addr}
        ${port}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${index}].pdu_port.port_no}
        ${ru_index}    evaluate    ${index}+1
        log to console    for ru ${ru_index}, model is ${model}, pb ip is ${address}, pb port is ${port}
        pdu.Setup Pdu    model=${model}   host=${address}    alias=pdu_ru_${ru_index}
        ${port_status}    pdu.Get Port Status    port=${port}    pdu_device=pdu_ru_${ru_index}
        log to console    port status of ru ${ru_index} is ${port_status}
        run keyword if    '${port_status}'=='off'    pdu.power on    port=${port}    pdu_device=pdu_ru_${ru_index}
    END

check and power on gnb and rus
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${unit_index}=${0}
    check and power on gnb    gnb_index=${gnb_index}    du_index=${du_index}    unit_index=${unit_index}
    check and power on rus    gnb_index=${gnb_index}    du_index=${du_index}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair
    [Teardown]    COAM Teardown gnb connections

power off and on rus
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}
    ${ru_numbers}    get length    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus}
    log to console    ru_numbers: ${ru_numbers}
    FOR    ${index}    IN RANGE    0    ${ru_numbers}
        ${model}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${index}].pdu_port.pdu.__class__.__name__}
        ${address}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${index}].pdu_port.pdu.addr}
        ${port}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${index}].pdu_port.port_no}
        ${ru_index}    evaluate    ${index}+1
        log to console    for ru ${ru_index}, model is ${model}, pb ip is ${address}, pb port is ${port}
        pdu.Setup Pdu    model=${model}   host=${address}    alias=pdu_ru_${ru_index}
        ${port_status}    pdu.Get Port Status    port=${port}    pdu_device=pdu_ru_${ru_index}
        log to console    port status of ru ${ru_index} is ${port_status}
        run keyword if    '${port_status}'=='on'    pdu.power off    port=${port}    pdu_device=pdu_ru_${ru_index}
        sleep    5s
        run keyword if    '${port_status}'=='off'    pdu.power on    port=${port}    pdu_device=pdu_ru_${ru_index}
        sleep    5s
    END

update_parameter_value
    [Arguments]    ${dist_name}    ${parameter_name}    ${value}
    coam.perform_parameter_recommissioning        dist_name=${dist_name}
    ...                                            parameter=${parameter_name}
    ...                                            value=${value}
    ...                                            operation=update
    ...                                            connection=GNB_OAM
    sleep    5s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair

Modify File Of Swconfig
    [Arguments]    ${swconfig_path}    ${asik_alias}=ASIK Master
    Connect to Common Unit Master    alias=${asik_alias}
    Upload Swconfig File    swconfig_path=${swconfig_path}
    run keyword and ignore error    COAM Teardown gnb connections
    Connect to gnb coam via ssl
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    [Teardown]    run keyword and ignore error    csn.Disconnect   connection=${asik_alias}

Upload File Of Swconfig
    [Arguments]    ${swconfig_path}    ${asik_alias}=ASIK Master
    ${swconfig_file_name}    Fetch from right    ${swconfig_path}    /
    log to console    upload swconfig file
    csn.Upload File    local_path=${swconfig_path}    remote_path=/ffs/run/swconfig.txt    connection=${asik_alias}
    sleep    1s
    log to console    rename uploaded new swconfig file
    csn.execute    mv /ffs/run/${swconfig_file_name} /ffs/run/swconfig.txt    connection=${asik_alias}
    sleep    1s
    log to console    crasign...
    csn.execute    crasign /ffs/run/swconfig.txt    connection=${asik_alias}
    sleep    1s
    log to console    craverify...
    csn.execute    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7    connection=${asik_alias}
    sleep    1s
    log to console    reboot testline...
    Connect to gnb coam via ssl
    coam.reset_site    connection=GNB_OAM
    sleep    120s
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

kill python process on control pc
    [Arguments]    ${ue_index}=${0}
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command    command=ps -ef|grep python|grep -v grep|awk '{print $2}'|xargs kill -9    connection=cygwin
    sleep   3s
    ${python_pid}    csn.execute    command=ps -ef|grep python|grep -v grep|awk '{print $2}'   connection=cygwin
    should be empty  ${python_pid}
    [Teardown]    csn.disconnect      connection=cygwin

General_SiSo_RU_lock_unlock_SG08
    [Arguments]  ${tput_self_define}    ${with_call}=${True}    ${special_ru}=AVQL
    ...    ${target_avg_percent}=${None}    ${min_percent}=${None}
    ...    ${protocol}=udp    ${duration}=${600}    ${gnb_index}=0    ${du_index}=0    ${tput_from}=tool
    ...    ${loop_times}=${2}    ${alias}=ASIK MASTER    ${connection}=GNB_OAM    ${process_num_ul}=1    ${ui_version}=default
    ...    ${pci}=${0}    ${scf_name}=${None}
    Selenium Login And Disable Screen Lock
    Get X2 link shutdown waiting time
    ${ru_index_list}    Get All RU Index
    ${cell_list}    Get All Cell Id
    ${cell_num}    get length  ${cell_list}
    sort list    ${cell_list}
    Lock all RUs and check all status_SG08    ru_index_list=${ru_index_list}
    ...    cell_list=${cell_list}    gnb_type='${gNb_CuType}'    with_call=${with_call}    special_ru=${special_ru}
    ...    tput_self_define=${tput_self_define}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    protocol=${protocol}    duration=${duration}    gnb_index=${gnb_index}    du_index=${du_index}    tput_from=${tput_from}
    ...    loop_times=${loop_times}    alias=${alias}    connection=${connection}    process_num_ul=${process_num_ul}    ui_version=${ui_version}
    ...    pci=${pci}    scf_name=${scf_name}
    run keyword and ignore error    Selenium Logout And Close Browser
    Selenium Login And Disable Screen Lock
    Close Start Up View    timeout=60
    UnLock all RUs and check all status_SG08    ru_index_list=${ru_index_list}    cell_list=${cell_list}
    ...    gnb_type='${gNb_CuType}'    with_call=${with_call}    special_ru=${special_ru}
    ...    tput_self_define=${tput_self_define}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    protocol=${protocol}    duration=${duration}    gnb_index=${gnb_index}    du_index=${du_index}    tput_from=${tput_from}
    ...    loop_times=${loop_times}    alias=${alias}    connection=${connection}    process_num_ul=${process_num_ul}    ui_version=${ui_version}
    ...    pci=${pci}    scf_name=${scf_name}
    run keyword if    ${with_call}==${True}    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_list}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    protocol=${protocol}    duration=${duration}    gnb_index=${gnb_index}    du_index=${du_index}    tput_from=${tput_from}
    ...    loop_times=${loop_times}    alias=${alias}    connection=${connection}    process_num_ul=${process_num_ul}
    ...    ui_version=${ui_version}    pci=${pci}    scf_name=${scf_name}
    [Teardown]    Run Keywords    excute ru unlock    ru_index_list=${ru_index_list}    AND
    ...    Selenium Logout And Close Browser

Lock all RUs and check all status_SG08
    [Arguments]  ${tput_self_define}     ${ru_index_list}    ${cell_list}    ${gnb_type}='${gNb_CuType}'
    ...    ${check_alarm}=${True}    ${with_call}=${True}    ${special_ru}=AVQL
    ...    ${target_avg_percent}=${None}    ${min_percent}=${None}
    ...    ${protocol}=udp    ${duration}=${600}    ${gnb_index}=0    ${du_index}=0    ${tput_from}=tool
    ...    ${loop_times}=${2}    ${alias}=ASIK MASTER    ${connection}=GNB_OAM    ${process_num_ul}=1    ${ui_version}=default
    ...    ${pci}=${0}    ${scf_name}=${None}
    log to console  \n**Lock all RUs and check all status***
    ${led_status_list_lock}    create list    YELLOW YELLOW
    ${cell_list_new}    samelist    ${cell_list}
    ${ru_index_type_mapping}    Get All RU Type Mapping Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Create file in RU    ru_index=${ru_index}
        Collect RF Logs To TestPC    log_name=before_ru${ru_index}_lock    ru_index=${ru_index}
        ${status}    run keyword and return status    Should Be Equal    ${ru_index_type_mapping['${ru_index}']}    ${special_ru}
        ${mathes}    ${new_timestamp}    Run Keyword If    '${status}'=='${False}'    Get Last LED Timestamp and Status
        ...    log_name=before_ru${ru_index}_lock
        selenium_coam.lock_ru    ru_index=${ru_index}
        sleep  15
        wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${ru_index}
        Run Keyword If    '${status}'=='${False}'    Check LED Status In RU Log    led_status_list=${led_status_list_lock}
        ...    log_name=after_ru${ru_index}_lock    ru_index=${ru_index}
        ...    timestamp=${new_timestamp}    exclude_led_status=GREEN GREEN
        Download Soap and Check Ru Lock Unlock Message    type=lock    ru_index=${ru_index}
        ${cell_id_ru}    Get All Cell Id    ru_index=${ru_index}
        wait until keyword succeeds    5min    20sec    Cell status Should Be Disabled    cell_list=${cell_id_ru}
        ${flag}    ${cell_list_new}    getusefulid    ${cell_id_ru}    ${cell_list_new}
        sort list    ${cell_list_new}
        run keyword if    ${with_call}==${True}    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_list_new}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
        ...    protocol=${protocol}    duration=${duration}    gnb_index=${gnb_index}    du_index=${du_index}    tput_from=${tput_from}
        ...    loop_times=${loop_times}    alias=${alias}    connection=${connection}    process_num_ul=${process_num_ul}
        ...    ui_version=${ui_version}    pci=${pci}    scf_name=${scf_name}
    END
    Connect to gnb coam via ssl
    FOR  ${ru_index}  IN  @{ru_index_list}
        wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${ru_index}
    END
    wait until keyword succeeds    5min    20sec    Cell status Should Be Disabled    cell_list=${cell_list}
    run keyword if    ${check_alarm}==${True} and ${gnb_type}=='NSA'    sleep    ${X2_link_shutdown_time}min
    run keyword if    ${check_alarm}==${True} and ${gnb_type}=='NSA'
    ...    Wait until keyword succeeds    2min    20sec    Expect Fault Should Present    faultId=7300

UnLock all RUs and check all status_SG08
    [Arguments]    ${ru_index_list}    ${cell_list}    ${gnb_type}='${gNb_CuType}'
    ...   ${check_alarm}=${True}    ${with_call}=${True}    ${special_ru}=AVQL
    ...    ${target_avg_percent}=${None}    ${min_percent}=${None}
    ...    ${protocol}=udp    ${duration}=${600}    ${gnb_index}=0    ${du_index}=0    ${tput_from}=tool
    ...    ${loop_times}=${2}    ${alias}=ASIK MASTER    ${connection}=GNB_OAM    ${process_num_ul}=1    ${ui_version}=default
    ...    ${pci}=${0}    ${scf_name}=${None}    ${tput_self_define}=${None}
    log to console  \n**UnLock all RUs and check all status***
    ${ru_index_type_mapping}    Get All RU Type Mapping Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Collect RF Logs To TestPC    log_name=before_ru${ru_index}_unlock    ru_index=${ru_index}
        ${status_compare}    run keyword and return status    Should Be Equal    ${ru_index_type_mapping['${ru_index}']}    ${special_ru}
        ${mathes}    ${new_timestamp}    Run Keyword If    '${status_compare}'=='${False}'    Get Last LED Timestamp and Status
        ...    log_name=before_ru${ru_index}_unlock
        ${power_state}    Get RU Power State    ru_index=${ru_index}
        ${led_status_list}    run keyword if    '${power_state}'!='SLEEP'    create list   GREEN GREEN    ELSE
        ...    create list    YELLOW OFF  GREEN GREEN
        ${status}    run keyword and return status  Expect Fault Should Present    faultId=4687
        run keyword and ignore error    selenium_coam.unlock_ru    ru_index=${ru_index}
        sleep  15
        Run Keyword If  ${status}==${True}    wait until keyword succeeds    10min    20sec    RU Should Be Offline    ru_index=${ru_index}
        wait until keyword succeeds    10min    20sec    RU Should Be Online    ru_index=${ru_index}
        Run Keyword If  ${status}==${False} and '${status_compare}'=='${False}'    Check LED Status In RU Log
        ...    led_status_list=${led_status_list}    log_name=after_ru${ru_index}_unlock
        ...    ru_index=${ru_index}    timestamp=${new_timestamp}    exclude_led_status=YELLOW YELLOW
        Download Soap and Check Ru Lock Unlock Message    type=unlock    ru_index=${ru_index}
        Run Keyword If  ${status}==${False} and '${power_state}'!='SLEEP'    Check file Exist in RU    ru_index=${ru_index}
        ${cell_id_ru}    Get All Cell Id    ru_index=${ru_index}
        sort list    ${cell_id_ru}
        run keyword if    ${with_call}==${True}    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_id_ru}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
        ...    protocol=${protocol}    duration=${duration}    gnb_index=${gnb_index}    du_index=${du_index}    tput_from=${tput_from}
        ...    loop_times=${loop_times}    alias=${alias}    connection=${connection}    process_num_ul=${process_num_ul}
        ...    ui_version=${ui_version}    pci=${pci}    scf_name=${scf_name}
    END
    Connect to gnb coam via ssl
    FOR  ${ru_index}  IN  @{ru_index_list}
        wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${ru_index}
    END
    wait until keyword succeeds    5min    20sec    Cell status Should Be enabled    cell_list=${cell_list}
    run keyword if    ${check_alarm}==${True} and ${gnb_type}=='NSA'
    ...  Wait until keyword succeeds  5min  20sec  Expect Fault Should Absent    faultId=7300

General_SiSo_Cell_lock_and_unlock_SG08
    [Arguments]  ${tput_self_define}    ${with_call}=${True}    ${target_avg_percent}=${None}    ${min_percent}=${None}
    ...    ${protocol}=udp    ${duration}=${600}    ${gnb_index}=0    ${du_index}=0    ${tput_from}=tool
    ...    ${loop_times}=${2}    ${alias}=ASIK MASTER    ${connection}=GNB_OAM    ${process_num_ul}=1    ${ui_version}=default
    ...    ${pci}=${0}    ${scf_name}=${None}
    Get X2 link shutdown waiting time
    ${cell_id_list}  Get All Cell Id
    ${cell_num}    get length  ${cell_id_list}
    Lock and Unlock Cells or Groups and L3_SG08  lock_list=${cell_id_list}  is_group=${False}  with_call=${with_call}
    ...    tput_self_define=${tput_self_define}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    protocol=${protocol}    duration=${duration}    gnb_index=${gnb_index}    du_index=${du_index}    tput_from=${tput_from}
    ...    loop_times=${loop_times}    alias=${alias}    connection=${connection}    process_num_ul=${process_num_ul}    ui_version=${ui_version}
    ...    pci=${pci}    scf_name=${scf_name}
    Connect to gnb coam via ssl
    ${cellgrp_id_list}  Get All Cell Group Id
    ${cellgrp_num}    get length  ${cellgrp_id_list}
#    Lock and Unlock Cells or Groups and L3_SG08  lock_list=${cellgrp_id_list}  is_group=${True}  with_call=${with_call}
#    ...    tput_self_define=${tput_self_define}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
#    ...    protocol=${protocol}    duration=${duration}    gnb_index=${gnb_index}    du_index=${du_index}    tput_from=${tput_from}
#    ...    loop_times=${loop_times}    alias=${alias}    connection=${connection}    process_num_ul=${process_num_ul}    ui_version=${ui_version}
#    ...    pci=${pci}    scf_name=${scf_name}
    run keyword if  ${cell_num}>1  Lock and Unlock all Cells or Groups  lock_list=${cell_id_list}  is_group=${False}
#    run keyword if  ${cellgrp_num}>1  Lock and Unlock all Cells or Groups  lock_list=${cellgrp_id_list}  is_group=${True}

Lock and Unlock Cells or Groups and L3_SG08
    [Arguments]  ${lock_list}  ${tput_self_define}    ${is_group}=${True}  ${with_call}=${False}    ${target_avg_percent}=${None}
    ...    ${min_percent}=${None}    ${protocol}=udp    ${duration}=${600}    ${gnb_index}=0    ${du_index}=0    ${tput_from}=tool
    ...    ${loop_times}=${2}    ${alias}=ASIK MASTER    ${connection}=GNB_OAM    ${process_num_ul}=1    ${ui_version}=default
    ...    ${pci}=${0}    ${scf_name}=${None}
    ${lock_num}    get length  ${lock_list}
    FOR  ${lock_id}  IN  @{lock_list}
        ${check_alarm}  set variable if  ${lock_num}==1  ${True}  ${False}
        ${other_cells}  Get Other Ids    id_list=${lock_list}    given_id=${lock_id}
        ${check_cell}  create list  ${lock_id}
        ${operate_list}    set variable if  ${lock_num}==1  ${check_cell}  ${other_cells}
        ${cell_list}    run keyword if  ${is_group}    Get Cell From Cell Group  cellgrp_id=${lock_id}
        ...    ELSE   set variable  ${check_cell}
        Lock cells or groups and check status  lock_list=${operate_list}  is_group=${is_group}  check_alarm=${check_alarm}
        ...    gnb_type='${gNb_CuType}'
        run keyword if  ${lock_num}!=1 and ${with_call}
        ...    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_list}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
        ...    protocol=${protocol}    duration=${duration}    gnb_index=${gnb_index}    du_index=${du_index}    tput_from=${tput_from}
        ...    loop_times=${loop_times}    alias=${alias}    connection=${connection}    process_num_ul=${process_num_ul}
        ...    ui_version=${ui_version}    pci=${pci}    scf_name=${scf_name}
        Unlock cells or groups and check status  lock_list=${operate_list}  is_group=${is_group}  check_alarm=${check_alarm}
        ...    gnb_type='${gNb_CuType}'
        run keyword if  ${lock_num}==1 and ${with_call}
        ...    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_list}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
        ...    protocol=${protocol}    duration=${duration}    gnb_index=${gnb_index}    du_index=${du_index}    tput_from=${tput_from}
        ...    loop_times=${loop_times}    alias=${alias}    connection=${connection}    process_num_ul=${process_num_ul}
        ...    ui_version=${ui_version}    pci=${pci}    scf_name=${scf_name}
    END

E2E_SiSo_Cell_block_and_unblock_gNB_SG08
    [Arguments]  ${tput_self_define}    ${with_call}=${True}    ${ue_num_each_call}=1    ${target_avg_percent}=${None}
    ...    ${min_percent}=${None}    ${protocol}=udp    ${duration}=${600}    ${gnb_index}=0    ${du_index}=0    ${tput_from}=tool
    ...    ${loop_times}=${2}    ${alias}=ASIK MASTER    ${connection}=GNB_OAM    ${process_num_ul}=1    ${ui_version}=default
    ...    ${pci}=${0}    ${scf_name}=${None}
    log to console    ${ue_num_each_call}
    Get X2 link shutdown waiting time
    Selenium Login And Disable Screen Lock
    ${cell_id_list}  Get All Cell Id
    ${cell_num}    get length  ${cell_id_list}
    ${check_alarm}  set variable if  ${cell_num}==1  ${True}  ${False}
    FOR  ${block_id}  IN  @{cell_id_list}
        ${operate_list}    create list    ${block_id}
        run keyword if  ${with_call}    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${operate_list}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
        ...    protocol=${protocol}    duration=${duration}    gnb_index=${gnb_index}    du_index=${du_index}    tput_from=${tput_from}
        ...    loop_times=${loop_times}    alias=${alias}    connection=${connection}    process_num_ul=${process_num_ul}
        ...    ui_version=${ui_version}    pci=${pci}    scf_name=${scf_name}
        Block cells and check status   block_list=${operate_list}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
        UnBlock Cells and check status   block_list=${operate_list}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
        run keyword if  ${with_call}     data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${operate_list}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
        ...    protocol=${protocol}    duration=${duration}    gnb_index=${gnb_index}    du_index=${du_index}    tput_from=${tput_from}
        ...    loop_times=${loop_times}    alias=${alias}    connection=${connection}    process_num_ul=${process_num_ul}
        ...    ui_version=${ui_version}    pci=${pci}    scf_name=${scf_name}
    END
    ${check_cell}    run keyword if    ${with_call} and ${cell_num}>1    Get Ues Attached Cell    ue_num_each_call=1
    ${check_list}    create list    ${check_cell}
    ${other_cells}    Get Other Ids    id_list=${cell_id_list}    given_id=${check_cell}
    run keyword if    ${with_call} and ${cell_num}>1    run keywords    Block cells and check status   block_list=${other_cells}
    ...    check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'    AND
    ...    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${check_list}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    protocol=${protocol}    duration=${duration}    gnb_index=${gnb_index}    du_index=${du_index}    tput_from=${tput_from}
    ...    loop_times=${loop_times}    alias=${alias}    connection=${connection}    process_num_ul=${process_num_ul}
    ...    ui_version=${ui_version}    pci=${pci}    scf_name=${scf_name}    AND
    ...    UnBlock Cells and check status   block_list=${other_cells}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
    run keyword if  ${cell_num}>1    Block and UnBlock Cells    block_list=${cell_id_list}
    run keyword if  ${cell_num}>1 and ${with_call}    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_id_list}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    protocol=${protocol}    duration=${duration}    gnb_index=${gnb_index}    du_index=${du_index}    tput_from=${tput_from}
    ...    loop_times=${loop_times}    alias=${alias}    connection=${connection}    process_num_ul=${process_num_ul}
    ...    ui_version=${ui_version}    pci=${pci}    scf_name=${scf_name}
    [Teardown]   Selenium Logout And Close Browser

BIP Log Capture
    [Arguments]    ${duration}    ${ue_index}=${0}    ${gnb_index}=${0}     ${tool_log_name}=tool.log    ${gnb_tool_path}=/home/ute
    log to console    ${ue_index}
    log to console    clear existed *_BIP.zip file under ${gnb_tool_path}/gnb_logs/
    Run keyword and ignore error    OperatingSystem.Run    command=rm -rf ${gnb_tool_path}/gnb_logs/*_BIP.zip
    Run keyword and ignore error    OperatingSystem.Run    command=rm -rf ${gnb_tool_path}/gnb_logs/BTS-*_BIP
    Run keyword and ignore error    OperatingSystem.Run    command=rm -rf ${gnb_tool_path}/gnb_logs/${tool_log_name}
    Run keyword and ignore error    OperatingSystem.Run    command=rm -rf ${gnb_tool_path}/gnb_logs/nohup_bip.out
    sleep    2s
    log to console    send command to start bip log capture...
    ${gnb_ip}    set variable    ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    log to console    cd ${gnb_tool_path}/gnb_logs;nohup ./gnb_logs ${gnb_ip} -b ${duration} >./nohup_bip.out 2>&1 &
    OperatingSystem.Run    command=cd ${gnb_tool_path}/gnb_logs;nohup ./gnb_logs ${gnb_ip} -b ${duration} >./nohup_bip.out 2>&1 &

TTI Log Capture
    [Arguments]    ${duration}    ${ue_index}=${0}    ${gnb_index}=${0}    ${tool_log_name}=tool.log    ${gnb_tool_path}=/home/ute
    log to console    ${ue_index}
    log to console    clear existed *_TTI.zip file under ${gnb_tool_path}/gnb_logs/
    Run keyword and ignore error    OperatingSystem.Run    command=rm -rf ${gnb_tool_path}/gnb_logs/*_TTI.zip
    Run keyword and ignore error    OperatingSystem.Run    command=rm -rf ${gnb_tool_path}/gnb_logs/BTS-*_TTI
    Run keyword and ignore error    OperatingSystem.Run    command=rm -rf ${gnb_tool_path}/gnb_logs/${tool_log_name}
    Run keyword and ignore error    OperatingSystem.Run    command=rm -rf ${gnb_tool_path}/gnb_logs/nohup_tti.out
    sleep    2s
    log to console    send command to start tti log capture...
    ${gnb_ip}    set variable    ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    log to console    cd ${gnb_tool_path}/gnb_logs;nohup ./gnb_logs ${gnb_ip} -T ${duration} >./nohup_tti.out 2>&1 &
    OperatingSystem.Run    command=cd ${gnb_tool_path}/gnb_logs;nohup ./gnb_logs ${gnb_ip} -T ${duration} >./nohup_tti.out 2>&1 &

BIP And TTI Log Capture Together
    [Arguments]    ${duration}    ${ue_index}=${0}    ${gnb_index}=${0}    ${tool_log_name}=tool.log    ${gnb_tool_path}=/home/ute
    log to console    ${ue_index}
    log to console    clear existed *_m.zip file under ${gnb_tool_path}/gnb_logs/
    Run keyword and ignore error    OperatingSystem.Run    command=rm -rf ${gnb_tool_path}/gnb_logs/*_m.zip
    Run keyword and ignore error    OperatingSystem.Run    command=rm -rf ${gnb_tool_path}/gnb_logs/BTS-*_m
    Run keyword and ignore error    OperatingSystem.Run    command=rm -rf ${gnb_tool_path}/gnb_logs/${tool_log_name}
    Run keyword and ignore error    OperatingSystem.Run    command=rm -rf ${gnb_tool_path}/gnb_logs/nohup_bip_tti.out
    sleep    2s
    log to console    send command to start bip and tti log capture...
    ${gnb_ip}    set variable    ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    log to console    cd ${gnb_tool_path}/gnb_logs;nohup ./gnb_logs ${gnb_ip} -T -b ${duration} >./nohup_bip_tti.out 2>&1 &
    OperatingSystem.Run    command=cd ${gnb_tool_path}/gnb_logs;nohup ./gnb_logs ${gnb_ip} -T -b ${duration} >./nohup_bip_tti.out 2>&1 &

CP Log Capture
    [Arguments]    ${duration}    ${ue_index}=${0}    ${gnb_index}=${0}    ${tool_log_name}=tool.log    ${gnb_tool_path}=/home/ute
    log to console    ${ue_index}
    log to console    clear existed *_CP.zip file under ${gnb_tool_path}/gnb_logs/
    Run keyword and ignore error    OperatingSystem.Run    command=rm -rf ${gnb_tool_path}/gnb_logs/*_CP.zip
    Run keyword and ignore error    OperatingSystem.Run    command=rm -rf ${gnb_tool_path}/gnb_logs/BTS-*_CP
    Run keyword and ignore error    OperatingSystem.Run    command=rm -rf ${gnb_tool_path}/gnb_logs/${tool_log_name}
    Run keyword and ignore error    OperatingSystem.Run    command=rm -rf ${gnb_tool_path}/gnb_logs/nohup_cp.out
    sleep    2s
    log to console    send command to start cp log capture...
    ${gnb_ip}    set variable    ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    log to console    cd ${gnb_tool_path}/gnb_logs;nohup ./gnb_logs ${gnb_ip} -cp ${duration} >./nohup_cp.out 2>&1 &
    OperatingSystem.Run    command=cd ${gnb_tool_path}/gnb_logs;nohup ./gnb_logs ${gnb_ip} -cp ${duration} >./nohup_cp.out 2>&1 &

Check Gnb Log Created
    [Arguments]    ${tool_log_name}=tool.log    ${gnb_tool_path}=/home/ute
    ${output}    OperatingSystem.Run    command=cat ${gnb_tool_path}/gnb_logs/${tool_log_name}
    Should Contain    ${output}    Duration seconds

Check tti Log Started Capture
    [Arguments]    ${tool_log_name}=tool.log     ${gnb_tool_path}=/home/ute
    ${output}    OperatingSystem.Run    command=cat ${gnb_tool_path}/gnb_logs/${tool_log_name}
    Should Contain    ${output}    monitoring starting: ttiTrace

Check CP Log Started Capture
    [Arguments]    ${tool_log_name}=tool.log     ${gnb_tool_path}=/home/ute
    ${output}    OperatingSystem.Run    command=cat ${gnb_tool_path}/gnb_logs/${tool_log_name}
    Should Contain    ${output}    monitoring starting: CPlane_

Get BIP Log Name
    [Arguments]    ${tool_log_name}=tool.log    ${gnb_tool_path}=/home/ute
    Wait Until Keyword Succeeds   10 min    2 sec    Check Gnb Log Created    tool_log_name=${tool_log_name}
    ${bip_log_name}     OperatingSystem.Run    command=cd ${gnb_tool_path}/gnb_logs && ls *_BIP.zip
    ${bip_log_name}    Remove String    ${bip_log_name}    \n
    log to console    ${bip_log_name}
    set test variable    ${bip_log_name}

Get TTI Log Name
    [Arguments]    ${tool_log_name}=tool.log    ${gnb_tool_path}=/home/ute
    Wait Until Keyword Succeeds   10 min    2 sec    Check Gnb Log Created    tool_log_name=${tool_log_name}
    ${tti_log_name}     OperatingSystem.Run    command=cd ${gnb_tool_path}/gnb_logs && ls *_TTI.zip
    ${tti_log_name}    Remove String    ${tti_log_name}    \n
    log to console    ${tti_log_name}
    set test variable    ${tti_log_name}

Get TTI mixed BIP Log Name
    [Arguments]    ${tool_log_name}=tool.log    ${gnb_tool_path}=/home/ute
    Wait Until Keyword Succeeds   10 min    2 sec    Check Gnb Log Created    tool_log_name=${tool_log_name}
    ${bip_mixed_tti_log_name}     OperatingSystem.Run    command=cd ${gnb_tool_path}/gnb_logs && ls *_m.zip
    ${bip_mixed_tti_log_name}    Remove String    ${bip_mixed_tti_log_name}    \n
    log to console    ${bip_mixed_tti_log_name}
    set test variable    ${bip_mixed_tti_log_name}

Get CP Log Name
    [Arguments]    ${tool_log_name}=tool.log    ${gnb_tool_path}=/home/ute
    Wait Until Keyword Succeeds   10 min    2 sec    Check Gnb Log Created   tool_log_name=${tool_log_name}
    ${cp_log_name}     OperatingSystem.Run    command=cd ${gnb_tool_path}/gnb_logs && ls *_CP.zip
    ${cp_log_name}    Remove String    ${cp_log_name}    \n
    log to console    ${cp_log_name}
    set test variable    ${cp_log_name}

BIP Log Unzip
    [Arguments]    ${bip_log_name}    ${gnb_tool_path}=/home/ute    ${bip_log_path}=${gnb_tool_path}/gnb_logs
    log to console    begin to unzip ${bip_log_path}/${bip_log_name}
    OperatingSystem.Run    command=unzip ${bip_log_path}/${bip_log_name} -d ${bip_log_path}
    ${unzip_dir}      set variable    ${bip_log_name.split(".zip")[0]}
    ${log_dir_unzip}    set variable    ${bip_log_path}/${unzip_dir}/bip
    log to console    have unziped to ${log_dir_unzip}
    ${output}    OperatingSystem.Run    command=ls -al ${log_dir_unzip}|grep .pcap|awk '{print $9}'
    ${bip_log_unzip_full_path}    set variable    ${log_dir_unzip}/${output}
    set test variable    ${bip_log_unzip_full_path}
    log to console    ${bip_log_unzip_full_path}

TTI Log Unzip
    [Arguments]    ${tti_log_name}    ${gnb_tool_path}=/home/ute    ${tti_log_path}=${gnb_tool_path}/gnb_logs
    log to console    begin to unzip ${tti_log_path}/${tti_log_name}...
    OperatingSystem.Run   command=unzip ${tti_log_path}/${tti_log_name} -d ${tti_log_path}
    ${unzip_dir}      set variable    ${tti_log_name.split(".zip")[0]}
    ${log_dir_unzip}    set variable    ${tti_log_path}/${unzip_dir}/tti_packed
    ${command}    set variable    ls -al ${log_dir_unzip}|grep _ttiTrace|grep d|awk '{print $9}'
    ${output}    OperatingSystem.Run    command=${command}
    log to console    ${output}
    ${output}    set variable    ${output.split("\n")}
    ${tti_log_unzip_full_path}    Create List
    FOR    ${item}    IN    @{output}
        ${sub_dir_unzip}    set variable    ${log_dir_unzip}/${item}
        log to console    have unziped to ${log_dir_unzip}
#        ${filename}    OperatingSystem.Run    command=ls -al ${sub_dir_unzip}|grep dlAndUl__all.csv|awk '{print $9}'
        ${filename}    OperatingSystem.Run    command=ls -al ${sub_dir_unzip}|grep dl__all.csv|awk '{print $9}'
        ${full_path}    set variable    ${sub_dir_unzip}/${filename}
        Append To List    ${tti_log_unzip_full_path}    ${full_path}
    END
    log to console    ${tti_log_unzip_full_path}
    set test variable    ${tti_log_unzip_full_path}


BIP Mixed TTI Log Unzip
    [Arguments]    ${bip_mixed_tti_log_name}    ${gnb_tool_path}=/home/ute    ${bip_mixed_tti_log_path}=${gnb_tool_path}/gnb_logs
    log to console    begin to unzip ${bip_mixed_tti_log_path}/${bip_mixed_tti_log_name}...
    OperatingSystem.Run   command=unzip ${bip_mixed_tti_log_path}/${bip_mixed_tti_log_name} -d ${bip_mixed_tti_log_path}
    ${unzip_dir}      set variable    ${bip_mixed_tti_log_name.split(".zip")[0]}
    ${bip_log_dir_unzip}    set variable    ${bip_mixed_tti_log_path}/${unzip_dir}/bip
    ${output}    OperatingSystem.Run    command=ls -al ${bip_log_dir_unzip}|grep .pcap|awk '{print $9}'
    ${bip_log_list}    set variable    ${output.split("\n")}
    ${bip_log_unzip_full_path}    Create List
    FOR    ${item}    IN    @{bip_log_list}
        ${item}    set variable    ${bip_log_dir_unzip}/${item}
        Append To List    ${bip_log_unzip_full_path}    ${item}
    END
    set test variable    ${bip_log_unzip_full_path}
    log to console    ${bip_log_unzip_full_path}
    ${tti_log_dir_unzip}    set variable    ${bip_mixed_tti_log_path}/${unzip_dir}/tti_packed
    ${command}    set variable    ls -al ${tti_log_dir_unzip}|grep _ttiTrace|grep d|awk '{print $9}'
    ${output}    OperatingSystem.Run    command=${command}
    log to console    ${output}
    ${tti_log_dir_unzip}    set variable    ${tti_log_dir_unzip}/${output}
    ${output}    OperatingSystem.Run    command=ls -al ${tti_log_dir_unzip}|grep dlAndUl__all.csv|awk '{print $9}'
    ${tti_log_unzip_full_path}    set variable    ${tti_log_dir_unzip}/${output}
    set test variable    ${tti_log_unzip_full_path}
    log to console    ${tti_log_unzip_full_path}

CP Log Unzip
    [Arguments]    ${cp_log_name}    ${gnb_tool_path}=/home/ute    ${cp_log_path}=${gnb_tool_path}/gnb_logs
    log to console    begin to unzip ${cp_log_path}/${cp_log_name}...
    OperatingSystem.Run   command=unzip ${cp_log_path}/${cp_log_name} -d ${cp_log_path}
    ${unzip_dir}    set variable    ${cp_log_name.split(".zip")[0]}
    ${cp_log_unzip_full_path}    set variable    ${cp_log_path}/${unzip_dir}/CPlane_E1F1.pcap
    set test variable    ${cp_log_unzip_full_path}
    log to console    ${cp_log_unzip_full_path}

Spark Ue log capture
    [Arguments]    ${msg}    ${expression}     ${type}='last'    ${ue_type}=huawei_sigspark    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    ...    ${dl_throughput}=5MKbits/sec    ${duration}=60    ${apn_address}=dxdata1
    ...    ${ue_mode}=NSA    ${gnb_tool_path}=/home/ute    ${log_name}=${gnb_tool_path}/sparklog/sigspark_UE${ue_index}.xml
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    spark.start_log    ue_alias=${ue_alias}
    sleep    5s
    spark.power_off    ue_alias=${ue_alias}
    Sleep    30s
    spark.power_on    ue_alias=${ue_alias}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}
    ...    duration=${duration}    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    dt_name=DT_dl    apn_address=${apn_address}    ue_mode=${ue_mode}
    spark.stop_log    ue_alias=${ue_alias}    logname=${log_name}    filter=test
    spark.read_log    logname=${log_name}
    ${result}    spark.get_expected_val    msg=${msg}    expression=${expression}    type=${type}
    log to console    ${result}

Set RU Eth On For LMI
    [Arguments]    ${ru_index_list}=${None}
    ${ru_index_list}    run keyword if    ${ru_index_list}!=${None}    set variable    ${ru_index_list}
    ...    ELSE    Get All RU Index
    Connect to Common Unit Master
    FOR    ${ru_index}    IN    @{ru_index_list}
        Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
        csn.execute     sudo lmi-eth on    connection=RU_${ru_index}    timeout=300
        sleep    1s
        csn.Disconnect  connection=RU_${ru_index}
    END
    [Teardown]  csn.Disconnect  connection=ASIK Master

get gnb_logs_tool from git
    [Arguments]    ${gnb_tool_path}=/home/ute
    Run keyword and ignore error    OperatingSystem.Run    command=rm -rf /tmp/gnb_logs-tool
    Run keyword and ignore error    OperatingSystem.Run    command=rm -rf ${gnb_tool_path}/gnb_logs
    OperatingSystem.Run    command=cd /tmp;git clone https://gitlabe1.ext.net.nokia.com/p5li/gnb_logs-tool
    OperatingSystem.Run    command=cd /tmp/gnb_logs-tool;unzip gnb_logs.zip -d ${gnb_tool_path}
    OperatingSystem.Run    command=sudo chmod -R 777 ${gnb_tool_path}/gnb_logs

Expect Fault Should Present With Absolute Source
    [Documentation]    Auther: stella.lin@nokia-sbell.com
    ...               Description: check expect alarm exist,add severity checkpoint by journey.jin@nokia-sbell.com
    ...               :param severity<str>: optional,value:Critical,Major,Minor,Warning
    ...               add checkpoint alarm id and fault id should be mapped by zheng.4.liu@nokia-sbell.com
    ...               add ${alarm['configObjectName']} due to some object don't have runtime object by zheng.4.liu@nokia-sbell.com
    ...               add ${alarm['supplAlarmInfo']} for checking supplAlarmInfo by catherine.cheng@nokia-sbell.com
    ...               add ${supplementary_not_contain} for checking supplAlarmInfo by catherine.cheng@nokia-sbell.com
    [Arguments]    ${faultId}    ${source}=${None}    ${connection}=GNB_OAM    ${severity}=${None}    ${alarmId}=${None}
    ...            ${configObjectName}=${None}     ${supplementary}=${None}    ${supplementary_not_contain}=${None}
    ...            ${du_index}=0    ${is_need_to_setup_gnb_connection}=${True}    ${timeout}=10
    ${faultId}    Convert To Integer    ${faultId}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    ${connection}    Set variable if  '${du_index}'=='0'    ${connection}    ${connection}_du${du_index}
    Run keyword if    ${has_cbts} and ${is_need_to_setup_gnb_connection}
    ...    Cloud DU connect to gnb coam via ssl
    ...        connection=${connection}    du_index=${du_index}
    ...    ELSE IF    '${has_cbts}'=='${False}' and ${is_need_to_setup_gnb_connection}
    ...      Connect to gnb coam via ssl    connection=${connection}
    @{alarms}    coam.get_active_alarms    connection=${connection}    timeout=${timeout}
    ${alarm_num}    Get Length    ${alarms}
    ${present_status}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{alarms}
       Exit For Loop If    ${alarm_num}==${0}
       ${present_status}    Run Keyword And Return Status    Run Keywords
                  ...                      Dictionary Should Contain Item    ${alarm}    faultId    ${faultId}    AND
                  ...                      Run Keyword If    '${source}'!='${None}'
                  ...                      Should Be equal     ${alarm['notifier']}    ${source}    AND
                  ...                      Run Keyword If    '${severity}'!='${None}'
                  ...                      Should Contain     ${alarm['severity']}   ${severity}    case_insensitive=True    AND
                  ...                      Run Keyword If    '${alarmId}'!='${None}'
                  ...                      Should Be Equal As Strings    ${alarm['alarmId']}    ${alarmId}    AND
                  ...                      Run Keyword If    '${config_object_name}'!='${None}'
                  ...                      Should Contain    ${alarm['configObjectName']}    ${config_object_name}    AND
                  ...                      Run Keyword If    '${Supplementary}'!='${None}'
                  ...                      Should Contain   ${alarm['supplAlarmInfo']}    ${Supplementary}    AND
                  ...                      Run Keyword If    '${supplementary_not_contain}'!='${None}'
                  ...                      Should not Contain   ${alarm['supplAlarmInfo']}    ${supplementary_not_contain}
      Exit For Loop If    ${present_status}
    END
    Run Keyword If    ${present_status}==${False}    Fail    faultId ${faultId} reported by source ${source} is not present on gnb.

Expect Fault Should Absent With Absolute Source
    [Documentation]    Auther: stella.lin@nokia-sbell.com
    [Arguments]   ${faultId}   ${source}=${None}   ${connection}=GNB_OAM
    ...    ${du_index}=0    ${is_need_to_setup_gnb_connection}=${True}    ${timeout}=10
    ${status}    Run Keyword And Return Status   Expect Fault Should Present With Absolute Source   faultId=${faultId}
    ...                                                                        source=${source}
    ...                                                                        connection=${connection}
    ...                                                                        du_index=${du_index}
    ...                                                                        is_need_to_setup_gnb_connection=${is_need_to_setup_gnb_connection}
    ...                                                                        timeout=${timeout}
    Run Keyword If  ${status}==${True}   Fail   faultId ${faultId} reported by source ${source} is still present on gnb.


Get All Nr Cells
    [Arguments]    ${connection}=GNB_OAM
    ${cells_nr}    coam.get_cells_info    cell_type=nr    connection=${connection}
    ${nr_cell_all}    create list
    FOR  ${cell}  IN  @{cells_nr}
        append to list  ${nr_cell_all}  ${cell['globalCellId']}
    END
    Sort List   ${nr_cell_all}
    set test variable    ${nr_cell_all}
    [Return]    ${nr_cell_all}

Get All Lte Cells
    [Arguments]    ${connection}=GNB_OAM
    ${cells_lte}    coam.get_cells_info    cell_type=lte    connection=${connection}
    ${lte_cell_all}    create list
    FOR  ${cell}  IN  @{cells_lte}
        append to list  ${lte_cell_all}  ${cell['globalCellId']}
    END
    Sort List   ${lte_cell_all}
    set test variable    ${lte_cell_all}
    [Return]    ${lte_cell_all}

#Set qRxLevMin For Nr Call
#    [Arguments]    ${mrbtsId}    ${nrbtsId}    ${nr_cell_all}    ${cell_id_call}    ${qRxLevMin_call}=${-65}    ${check_on_air}=${True}
#    ...    ${qRxLevMin_other}=${-22}    ${connection}=GNB_OAM
#    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
#    ${nr_cell_num}    Get Length    ${nr_cell_all}
#    FOR    ${cell_id}    IN RANGE    1    ${nr_cell_num}+1
#        run keyword If    '${cell_id}'!='${cell_id_call}'    wait until keyword succeeds    3x    30s    coam.perform_parameter_recommissioning
#        ...    parameter=qRxLevMin    value=${qRxLevMin_other}    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_id}
#        ...    operation=update    connection=${connection}
#        ...    ELSE    wait until keyword succeeds    3x    30s    coam.perform_parameter_recommissioning
#        ...    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_id}    parameter=qRxLevMin    value=${qRxLevMin_call}
#        ...    operation=update    connection=${connection}
#        Sleep    5s
#    END
#    run keyword if    ${check_on_air}==${True}    Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    ELSE
#    ...    sleep    60s
#    sleep    10s
#    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser

Set qRxLevMin For Nr Call
    [Arguments]    ${mrbtsId}    ${nrbtsId}    ${nr_cell_all}    ${cell_id_call}    ${qRxLevMin_call}=${-65}    ${check_on_air}=${True}
    ...    ${qRxLevMin_other}=${-22}    ${connection}=GNB_OAM
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    FOR    ${cell_id}    IN    @{nr_cell_all}
        run keyword If    '${cell_id}'!='${cell_id_call}'    wait until keyword succeeds    3x    30s    coam.perform_parameter_recommissioning
        ...    parameter=qRxLevMin    value=${qRxLevMin_other}    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_id}
        ...    operation=update    connection=${connection}
        ...    ELSE    wait until keyword succeeds    3x    30s    coam.perform_parameter_recommissioning
        ...    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_id}    parameter=qRxLevMin    value=${qRxLevMin_call}
        ...    operation=update    connection=${connection}
        Sleep    5s
    END
    run keyword if    ${check_on_air}==${True}    Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    ELSE
    ...    sleep    60s
    sleep    10s
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser

Set qRxLevMin For Lte Call
    [Arguments]    ${mrbtsId}    ${lnBtsId}    ${lte_cell_all}    ${cell_id_call}    ${qRxLevMin_call}=${-130}    ${check_on_air}=${True}
    ...    ${qRxLevMin_other}=${-44}    ${connection}=GNB_OAM
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    ${modify_params}  create list
    set test variable    ${modify_params}
    FOR    ${lte_cell_id}    IN    @{lte_cell_all}
        run keyword If    '${lte_cell_id}'!='${cell_id_call}'    add lte cell modify params to list   lte_cell_id=${lte_cell_id}
        ...    value=${qRxLevMin_other}    mrbtsId=${mrbtsId}    lnBtsId=${lnBtsId}    ELSE    run keyword    add lte cell modify params to list
        ...    lte_cell_id=${lte_cell_id}    value=${qRxLevMin_call}    mrbtsId=${mrbtsId}    lnBtsId=${lnBtsId}
    END
    FOR    ${item}    IN    @{modify_params}
        selenium_coam.Set Parameter Value    dist_name=${item}[dist_name]    filter_param=${item}[filter_param]    abbr=${item}[p_name]
        ...    new_value=${item}[value]
    END
    selenium_coam.Validate Plan
    selenium_coam.Activate Plan    activate_plan_despite_errors=${true}    execute=${true}
    run keyword if    ${check_on_air}==${True}    Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair
    ...    connection=${connection}    ELSE
    ...    sleep    60s
    sleep    10s
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser

add lte cell modify params to list
    [Arguments]    ${lte_cell_id}    ${value}    ${mrbtsId}    ${lnBtsId}    ${connection}=GNB_OAM
    log to console    ${connection}
    ${item}    create dictionary    dist_name=MRBTS-${mrbtsId}/LNBTS-${lnBtsId}/LNCEL-${lte_cell_id}/SIB-0
    ...    filter_param=Minimum required RX level in cell    p_name=qRxLevMin    value=${value}
    append to list    ${modify_params}    ${item}

Get Nr And Lte Cells For RU
    [Arguments]    ${ru_index}    ${connection}=GNB_OAM
    ${cells_nr}    coam.get_cells_info    cell_type=nr    connection=${connection}
    ${cells_lte}    coam.get_cells_info    cell_type=lte    connection=${connection}
    ${cell_list_nr}    create list
    ${cell_list_lte}    create list
    FOR  ${cell}  IN  @{cells_nr}
        ${carrier}    set variable  ${cell['carrierList'][0]}
        ${status}    run keyword and return status    should contain  ${carrier['antennaLineId']['configuration']}    RMOD-${ru_index}
        run keyword if    ${status}    append to list  ${cell_list_nr}  ${cell['globalCellId']}
    END
    FOR  ${cell}  IN  @{cells_lte}
        ${carrier}    set variable  ${cell['carrierList'][0]}
        ${status}    run keyword and return status    should contain  ${carrier['antennaLineId']['configuration']}    RMOD-${ru_index}
        run keyword if    ${status}    append to list  ${cell_list_lte}  ${cell['globalCellId']}
    END
    Sort List   ${cell_list_nr}
    Sort List    ${cell_list_lte}
    ${cells_under_ru}    create dictionary
    set to dictionary    ${cells_under_ru}    nr    ${cell_list_nr}
    set to dictionary    ${cells_under_ru}    lte    ${cell_list_lte}
    [Return]    ${cells_under_ru}

Get Ru and Cells Mapping
    [Arguments]    ${connection}=GNB_OAM
    ${ru_cells_mapping_all}    create dictionary
    ${ru_index_list}    Get All RU Index    connection=${connection}
    FOR    ${ru_index}  IN  @{ru_index_list}
        ${cells_under_ru}    Get Nr And Lte Cells For RU    ru_index=${ru_index}
        set to dictionary    ${ru_cells_mapping_all}    ${ru_index}    ${cells_under_ru}
    END
    [Return]    ${ru_cells_mapping_all}

Get Ru and Cells Mapping With Call
    [Arguments]    ${tput_define_nr}=${None}    ${tput_define_lte}=${None}
    log to console    get all nr cells
    Get All Nr Cells
    log to console    ${nr_cell_all}
    log to console    get all lte cells
    Get All Lte Cells
    log to console    ${lte_cell_all}
    @{empty_list}       create list
    ${nr_cell_id_used}    Run keyword If    ${tput_define_nr}!=${None}    get_cell_with_call    tput_define=${tput_define_nr}    ELSE
    ...    set variable    ${empty_list}
    ${nr_cell_id_unused}   Evaluate   list(set(${nr_cell_all})-set(${nr_cell_id_used}))
    # *********************************************************************************
    ${lte_cell_id_used}    Run keyword If    ${tput_define_lte}!=${None}    get_cell_with_call    tput_define=${tput_define_lte}    ELSE
    ...    set variable    ${empty_list}
    ${lte_cell_id_unused}   Evaluate   list(set(${lte_cell_all})-set(${lte_cell_id_used}))
    # *********************************************************************************
    log to console    get ru-cell mapping (remove ru/cell without ue)
    ${ru_cells_mapping_all}       Get Ru and Cells Mapping
    ${ru_cells_mapping_with_call}    get_ru_cell_mapping_with_call    ru_cell_all=${ru_cells_mapping_all}
    ...    nr_not_used=${nr_cell_id_unused}    lte_not_used=${lte_cell_id_unused}
    log to console    ${ru_cells_mapping_with_call}
    set test variable    ${ru_cells_mapping_with_call}
    [Return]    ${ru_cells_mapping_with_call}

Get Random Cell For Call From RU
    [Arguments]    ${ru_cells_mapping_with_call}    ${ru_index}    ${connection}=GNB_OAM
    log to console    ${connection}
    ${cells_call_under_ru}    set variable    ${ru_cells_mapping_with_call}[${ru_index}]
    ${cells_call}    get_cell_for_call_from_ru    cells_all_info=${cells_call_under_ru}
    [Return]    ${cells_call}

Make Call For Cells Random Selected From RU
    [Arguments]    ${cells_call}    ${mrbtsId}    ${nrbtsId}    ${nr_cell_all}    ${lte_cell_all}    ${lnBtsId}=${None}
    ...    ${tput_define_nr}=${None}    ${tput_define_lte}=${None}    ${qRxLevMin_call_nr}=${-65}    ${qRxLevMin_other_nr}=${-22}
    ...    ${qRxLevMin_call_lte}=${-130}    ${qRxLevMin_other_lte}=${-44}    ${target_avg_percent_nr}=${None}    ${min_percent_nr}=${None}
    ...    ${target_avg_percent_lte}=${None}    ${min_percent_lte}=${None}    ${protocol}=udp    ${duration}=${600}    ${tput_from}=tool
    ...    ${loop_times}=${2}    ${process_num_ul}=1    ${ui_version}=default    ${scf_name}=${None}    ${omit_time_lte}=10
    ...    ${connection}=GNB_OAM    ${pa_call_default}=${None}    ${check_on_air}=${True}
    @{cell_types}    Get Dictionary Keys    ${cells_call}
    ${length}    get length    ${cell_types}
    ${type}    set variable    ${cell_types[0]}
    ${cell_id_call}    get from dictionary    ${cells_call}    ${type}
    ${cell_id_call_list}    Create List    ${cell_id_call}
    Run keyword if    ${length}==2    run keywords    Set qRxLevMin For Nr Call     mrbtsId=${mrbtsId}    nrbtsId=${nrbtsId}
    ...    nr_cell_all=${nr_cell_all}    cell_id_call=${cells_call['nr']}    qRxLevMin_call=${qRxLevMin_call_nr}
    ...    qRxLevMin_other=${qRxLevMin_other_nr}    connection=${connection}    check_on_air=${check_on_air}    AND
    ...    Set qRxLevMin For Lte Call     mrbtsId=${mrbtsId}
    ...    lnBtsId=${lnBtsId}    lte_cell_all=${lte_cell_all}    cell_id_call=${cells_call['lte']}    qRxLevMin_call=${qRxLevMin_call_lte}
    ...    qRxLevMin_other=${qRxLevMin_other_lte}    connection=${connection}    check_on_air=${check_on_air}    AND
    ...    data_transfer_for_nr_and_lte_cell    cells_call=${cells_call}
    ...    tput_define_nr=${tput_define_nr}    tput_define_lte=${tput_define_lte}    target_avg_percent_nr=${target_avg_percent_nr}
    ...    min_percent_nr=${min_percent_nr}    target_avg_percent_lte=${target_avg_percent_lte}    min_percent_lte=${min_percent_lte}
    ...    duration=${duration}    tput_from=${tput_from}    omit_time_lte=${omit_time_lte}    scf_name=${scf_name}    connection=${connection}
    ...    process_num_ul=${process_num_ul}    ui_version=${ui_version}    pa_call_default=${pa_call_default}
    ...    ELSE IF    '${type}'=='nr'    run keywords    Set qRxLevMin For Nr Call     mrbtsId=${mrbtsId}    nrbtsId=${nrbtsId}
    ...    nr_cell_all=${nr_cell_all}    cell_id_call=${cell_id_call}    qRxLevMin_call=${qRxLevMin_call_nr}    qRxLevMin_other=${qRxLevMin_other_nr}
    ...    connection=${connection}    check_on_air=${check_on_air}    AND    Init PA Value for All Ports    scf_name=${scf_name}    AND
    ...    Set PA Value For Cell    cell_type=nr
    ...    cell_id=${cell_id_call}    pa_call_default=${pa_call_default}    scf_name=${scf_name}    AND    data_transfer_common
    ...    tput_self_define=${tput_define_nr}    cell_id=${cell_id_call_list}    target_avg_percent=${target_avg_percent_nr}
    ...    min_percent=${min_percent_nr}    protocol=${protocol}    duration=${duration}    tput_from=${tput_from}    loop_times=${loop_times}
    ...    process_num_ul=${process_num_ul}    ui_version=${ui_version}    scf_name=${scf_name}    connection=${connection}
    ...    ELSE    run keywords    Set qRxLevMin For Lte Call     mrbtsId=${mrbtsId}    lnBtsId=${lnBtsId}
    ...    lte_cell_all=${lte_cell_all}    cell_id_call=${cell_id_call}    qRxLevMin_call=${qRxLevMin_call_lte}
    ...    qRxLevMin_other=${qRxLevMin_other_lte}    connection=${connection}    check_on_air=${check_on_air}    AND
    ...    Init PA Value for All Ports    scf_name=${scf_name}        AND
    ...    Set PA Value For Cell    cell_type=lte    cell_id=${cell_id_call}    scf_name=${scf_name}
    ...    pa_call_default=${pa_call_default}    AND    data_transfer_common_lte
    ...    tput_self_define=${tput_define_lte}    cell_id=${cell_id_call}    target_avg_percent=${target_avg_percent_lte}
    ...    min_percent=${min_percent_lte}    duration=${duration}    omit_time=${omit_time_lte}

data_transfer_for_nr_and_lte_cell
    [Arguments]    ${cells_call}    ${tput_define_nr}=${None}    ${tput_define_lte}=${None}    ${target_avg_percent_nr}=${None}
    ...    ${min_percent_nr}=${None}    ${target_avg_percent_lte}=${None}    ${min_percent_lte}=${None}    ${duration}=${600}
    ...    ${tput_from}=tool    ${omit_time_lte}=10    ${scf_name}=${None}    ${process_num_ul}=1    ${ui_version}=default
    ...    ${connection}=GNB_OAM    ${pa_call_default}=${None}
    ${tput_define_nr}    get_self_define_tput_by_release    tput_info=${tput_define_nr}
    ${tput_define_lte}    get_self_define_tput_by_release    tput_info=${tput_define_lte}
    ${target_avg_percent_nr}    Run Keyword If    ${target_avg_percent_nr}==${None}    get_avg_expect_rate    ELSE
    ...    set variable    ${target_avg_percent_nr}
    ${min_percent_nr}    Run keyword If    ${min_percent_nr}==${None}    get_min_expect_rate    ELSE
    ...    set variable    ${min_percent_nr}
    ${target_avg_percent_lte}    Run Keyword If    ${target_avg_percent_lte}==${None}    get_avg_expect_rate    ELSE
    ...    set variable    ${target_avg_percent_lte}
    ${min_percent_nr}    Run keyword If    ${min_percent_lte}==${None}    get_min_expect_rate    ELSE
    ...    set variable    ${min_percent_lte}
    ${cell_id_nr}    get from dictionary    ${cells_call}    nr
    ${cell_id_lte}    get from dictionary    ${cells_call}    lte
    log to console    make call for nr cell ${cell_id_nr}
    ${ue_index_nr}    set variable    ${tput_define_nr[${cell_id_nr}]['ue_index']}
    ${ue_index_lte}    set variable    ${tput_define_lte[${cell_id_lte}]['ue_index']}
    ${ue_type_4G}     translate_power_ue_type_from_testline    ue_index=${ue_index_lte}
    ${tput_cell}    run keyword if    '${tput_from}'=='tool'    get_tput_info_by_tool
    ...    cell_id=${cell_id_nr}    target_avg_percent=${target_avg_percent_nr}    min_percent=${min_percent_nr}    scf_name=${scf_name}
    ...    duration=${duration}    ue_index=${ue_index_nr}    connection=${connection}    ELSE    set variable    ${tput_define_nr[${cell_id_nr}]}
    log to console    set all PA port to 127
    Init PA Value for All Ports    scf_name=${scf_name}
    log to console    set PA for nr cell ${cell_id_nr}
    Set PA Value For Cell    scf_name=${scf_name}    cell_id=${cell_id_nr}    pa_call_default=${pa_call_default}    cell_type=nr
    log to console    set PA for lte cell ${cell_id_lte}
    Set PA Value For Cell    scf_name=${scf_name}    cell_id=${cell_id_lte}    pa_call_default=${pa_call_default}    cell_type=lte
    make_call    tput_info=${tput_cell}    ue_index=${ue_index_nr}    process_num_ul=${process_num_ul}    ui_version=${ui_version}
    log to console    make call for lte cell ${cell_id_lte}
    ${throughput_dl}    set variable    ${tput_define_lte[${cell_id_lte}]['dl_tp']}
    ${throughput_ul}    set variable    ${tput_define_lte[${cell_id_lte}]['ul_tp']}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}    ue_index=${ue_index_lte}
    log to console    collect tput for nr cell ${cell_id_nr}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    log to console    stop traffic and_detach for lte call
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${ue_index_lte}
    log to console    check tput for lte cell ${cell_id_lte}
    ${target_throughput_dl}    set variable    ${tput_define_lte[${cell_id_lte}]['dl_exp']}
    ${target_throughput_ul}    set variable    ${tput_define_lte[${cell_id_lte}]['ul_exp']}
    check_tput_for_4G_call_config    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl}
    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${ue_index_lte}    omit_time=${omit_time_lte}
    ...    target_avg_percent=${target_avg_percent_lte}    min_percent=${min_percent_lte}
    log to console    check tput for nr cell ${cell_id_nr}
    ${tput_define_nr_new}    create dictionary
    set to dictionary    ${tput_define_nr_new}    ${cell_id_nr}    ${tput_cell}
    check_tput_for_each_cell    tput_info=${tput_define_nr_new}    cell_id=${cell_id_nr}    ue_index=${ue_index_nr}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent_nr}    min_percent=${min_percent_nr}
    log to console    detch for nr call
    [Teardown]    run keywords    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}    AND
    ...    run keyword and ignore error    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${ue_index_lte}

lock ru and make call under another ru
    [Arguments]    ${mrbtsId}    ${nrbtsId}    ${lnBtsId}=${None}    ${tput_define_nr}=${None}    ${tput_define_lte}=${None}
    ...    ${qRxLevMin_call_nr}=${-65}    ${qRxLevMin_other_nr}=${-22}        ${qRxLevMin_call_lte}=${-130}    ${qRxLevMin_other_lte}=${-44}
    ...    ${target_avg_percent_nr}=${None}    ${min_percent_nr}=${None}    ${target_avg_percent_lte}=${None}    ${min_percent_lte}=${None}
    ...    ${protocol}=udp    ${duration}=${600}    ${tput_from}=tool    ${loop_times}=${2}    ${process_num_ul}=1    ${ui_version}=default
    ...    ${scf_name}=${None}    ${omit_time_lte}=10    ${connection}=GNB_OAM    ${pa_call_default}=${None}    ${check_on_air}=${False}
    ${ru_cells_mapping_with_call}    Get Ru and Cells Mapping With Call    tput_define_nr=${tput_define_nr}    tput_define_lte=${tput_define_lte}
    @{ru_ids}    Get Dictionary Keys    ${ru_cells_mapping_with_call}
    ${ru_lock_index}    evaluate   random.choice(@{ru_ids})   random
    log to console    lock ru${ru_lock_index}
    coam.lock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_lock_index}    connection=${connection}    timeout=180
    sleep    5s
    wait until keyword succeeds    5min    5sec    RU Should Be Locked    ru_index=${ru_lock_index}
    @{ru_ids_copy}    copy list    ${ru_ids}
    Remove Values From List    ${ru_ids_copy}    ${ru_lock_index}
    ${ru_call_index}    evaluate   random.choice(@{ru_ids_copy})   random
    log to console    make call under ru${ru_call_index}
    ${cells_call}    Get Random Cell For Call From RU    ru_cells_mapping_with_call=${ru_cells_mapping_with_call}    ru_index=${ru_call_index}
    Make Call For Cells Random Selected From RU    cells_call=${cells_call}      mrbtsId=${mrbtsId}     nrbtsId=${nrbtsId}
    ...    lnBtsId=${lnBtsId}    nr_cell_all=${nr_cell_all}    lte_cell_all=${lte_cell_all}    tput_define_nr=${tput_define_nr}
    ...    tput_define_lte=${tput_define_lte}    qRxLevMin_call_nr=${qRxLevMin_call_nr}    qRxLevMin_other_nr=${qRxLevMin_other_nr}
    ...    qRxLevMin_call_lte=${qRxLevMin_call_lte}    qRxLevMin_other_lte=${qRxLevMin_other_lte}    target_avg_percent_nr=${target_avg_percent_nr}
    ...    min_percent_nr=${min_percent_nr}    target_avg_percent_lte=${target_avg_percent_lte}    min_percent_lte=${min_percent_lte}
    ...    protocol=${protocol}    duration=${duration}    tput_from=${tput_from}    loop_times=${loop_times}     process_num_ul=${process_num_ul}
    ...    ui_version=${ui_version}    scf_name=${scf_name}   omit_time_lte=${omit_time_lte}    connection=${connection}
    ...    pa_call_default=${pa_call_default}    check_on_air=${check_on_air}
    log to console    unlock ru${ru_lock_index}
    coam.unlock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_lock_index}    connection=${connection}    timeout=180s
    sleep    5s
    wait until keyword succeeds    10min    5sec    RU Should Be Online    ru_index=${ru_lock_index}
    All SMODs BBMODs RMODs and Cells should be onair
    log to console    make call under ru${ru_lock_index}
    ${cells_call}    Get Random Cell For Call From RU    ru_cells_mapping_with_call=${ru_cells_mapping_with_call}    ru_index=${ru_lock_index}
    Make Call For Cells Random Selected From RU    cells_call=${cells_call}      mrbtsId=${mrbtsId}     nrbtsId=${nrbtsId}
    ...    lnBtsId=${lnBtsId}    nr_cell_all=${nr_cell_all}    lte_cell_all=${lte_cell_all}    tput_define_nr=${tput_define_nr}
    ...    tput_define_lte=${tput_define_lte}    qRxLevMin_call_nr=${qRxLevMin_call_nr}    qRxLevMin_other_nr=${qRxLevMin_other_nr}
    ...    qRxLevMin_call_lte=${qRxLevMin_call_lte}    qRxLevMin_other_lte=${qRxLevMin_other_lte}
    ...    target_avg_percent_nr=${target_avg_percent_nr}    min_percent_nr=${min_percent_nr}    target_avg_percent_lte=${target_avg_percent_lte}
    ...    min_percent_lte=${min_percent_lte}    protocol=${protocol}    duration=${duration}
    ...    tput_from=${tput_from}    loop_times=${loop_times}     process_num_ul=${process_num_ul}    ui_version=${ui_version}
    ...    scf_name=${scf_name}   omit_time_lte=${omit_time_lte}    connection=${connection}    pa_call_default=${pa_call_default}
    ...    check_on_air=${check_on_air}

lock unlock ru and make call under this ru
    [Arguments]    ${mrbtsId}    ${nrbtsId}    ${lnBtsId}=${None}    ${tput_define_nr}=${None}    ${tput_define_lte}=${None}
    ...    ${qRxLevMin_call_nr}=${-65}    ${qRxLevMin_other_nr}=${-22}    ${qRxLevMin_call_lte}=${-130}    ${qRxLevMin_other_lte}=${-44}
    ...    ${target_avg_percent_nr}=${None}    ${min_percent_nr}=${None}    ${target_avg_percent_lte}=${None}    ${min_percent_lte}=${None}
    ...    ${protocol}=udp    ${duration}=${600}    ${tput_from}=tool    ${loop_times}=${2}    ${process_num_ul}=1    ${ui_version}=default
    ...    ${scf_name}=${None}    ${omit_time_lte}=10    ${connection}=GNB_OAM    ${pa_call_default}=${None}    ${check_on_air}=${True}
    ${ru_cells_mapping_with_call}    Get Ru and Cells Mapping With Call    tput_define_nr=${tput_define_nr}    tput_define_lte=${tput_define_lte}
    @{ru_ids}    Get Dictionary Keys    ${ru_cells_mapping_with_call}
    ${ru_lock_index}    evaluate   random.choice(@{ru_ids})   random
    log to console    lock ru${ru_lock_index}
    coam.lock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_lock_index}    connection=${connection}    timeout=60s
    sleep    5s
    wait until keyword succeeds    5min    5sec    RU Should Be Locked    ru_index=${ru_lock_index}
    log to console    unlock ru${ru_lock_index}
    coam.unlock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_lock_index}    connection=${connection}    timeout=60s
    sleep    5s
    wait until keyword succeeds    10min    5sec    RU Should Be Online    ru_index=${ru_lock_index}
    All SMODs BBMODs RMODs and Cells should be onair
    log to console    make call under ru${ru_lock_index}
    ${cells_call}    Get Random Cell For Call From RU    ru_cells_mapping_with_call=${ru_cells_mapping_with_call}    ru_index=${ru_lock_index}
    Make Call For Cells Random Selected From RU    cells_call=${cells_call}      mrbtsId=${mrbtsId}     nrbtsId=${nrbtsId}
    ...   lnBtsId=${lnBtsId}    nr_cell_all=${nr_cell_all}    lte_cell_all=${lte_cell_all}    tput_define_nr=${tput_define_nr}
    ...   tput_define_lte=${tput_define_lte}    qRxLevMin_call_nr=${qRxLevMin_call_nr}    qRxLevMin_other_nr=${qRxLevMin_other_nr}
    ...   qRxLevMin_call_lte=${qRxLevMin_call_lte}    qRxLevMin_other_lte=${qRxLevMin_other_lte}
    ...   target_avg_percent_nr=${target_avg_percent_nr}    min_percent_nr=${min_percent_nr}    target_avg_percent_lte=${target_avg_percent_lte}
    ...   min_percent_lte=${min_percent_lte}    protocol=${protocol}    duration=${duration}    tput_from=${tput_from}
    ...   process_num_ul=${process_num_ul}    ui_version=${ui_version}    loop_times=${loop_times}    scf_name=${scf_name}
    ...   omit_time_lte=${omit_time_lte}    connection=${connection}    pa_call_default=${pa_call_default}    check_on_air=${check_on_air}

cell_block_unblock_with_two_random_cells
    [Arguments]    ${cell_lists}    ${mrbtsId}    ${nrbtsId}    ${tput_define_nr}    ${tput_define_lte}    ${lnBtsId}=${None}
    ...    ${qRxLevMin_call_nr}=${-65}    ${qRxLevMin_other_nr}=${-22}    ${qRxLevMin_call_lte}=${-130}    ${qRxLevMin_other_lte}=${-44}
    ...    ${target_avg_percent_nr}=${None}    ${min_percent_nr}=${None}    ${target_avg_percent_lte}=${None}    ${min_percent_lte}=${None}
    ...    ${protocol}=udp    ${duration}=${600}    ${tput_from}=tool    ${loop_times}=${2}    ${process_num_ul}=1    ${ui_version}=default
    ...    ${scf_name}=${None}    ${omit_time_lte}=10    ${connection}=GNB_OAM    ${pa_call_default}=${None}    ${check_on_air}=${False}
    log to console    ${protocol}
    log to console    ${loop_times}
    ${cell_a_index}    evaluate   random.choice(${cell_lists})   random
    ${cell_a_type}    set variable    ${cell_a_index.split("_")[0]}
    ${cell_a_index}    set variable    ${cell_a_index.split("_")[1]}
    log to console    random select cell ${cell_a_index}
    ${cell_a_index}    Convert To Integer    ${cell_a_index}
    @{cell_lists_copy}    copy list    ${cell_lists}
    Remove Values From List    ${cell_lists_copy}    ${cell_a_type}_${cell_a_index}
    ${cell_b_index}    evaluate   random.choice(${cell_lists_copy})   random
    ${cell_b_type}    set variable    ${cell_b_index.split("_")[0]}
    ${cell_b_index}    set variable    ${cell_b_index.split("_")[1]}
    log to console    random select cell ${cell_b_index}
    ${cell_b_index}    Convert To Integer    ${cell_b_index}
    run keyword if   '${cell_a_type}'=='nr' and '${cell_b_type}'=='nr'    cell_block_unblock_nr_nr    tput_self_define=${tput_define_nr}
    ...    cell_id_a=${cell_a_index}    cell_id_b=${cell_b_index}    target_avg_percent=${target_avg_percent_nr}    min_percent=${min_percent_nr}
    ...    duration=${duration}    tput_from=${tput_from}    process_num_ul=${process_num_ul}    ui_version=${ui_version}    scf_name=${scf_name}
    ...    connection=${connection}    qRxLevMin_call=${qRxLevMin_call_nr}    qRxLevMin_other=${qRxLevMin_other_nr}
    ...    mrbtsId=${mrbtsId}    nrbtsId=${nrbtsId}    pa_call_default=${pa_call_default}    check_on_air=${check_on_air}
    ...    ELSE IF    '${cell_a_type}'=='nr' and '${cell_b_type}'=='lte'    cell_block_unblock_nr_lte    cell_id_a=${cell_a_index}
    ...    cell_id_b=${cell_b_index}    target_avg_percent_nr=${target_avg_percent_nr}    min_percent_nr=${min_percent_nr}
    ...    target_avg_percent_lte=${target_avg_percent_lte}    min_percent_lte=${min_percent_lte}    tput_define_nr=${tput_define_nr}
    ...    tput_define_lte=${tput_define_lte}    duration=${duration}    tput_from=${tput_from}    process_num_ul=${process_num_ul}
    ...    ui_version=${ui_version}    scf_name=${scf_name}    qRxLevMin_call_nr=${qRxLevMin_call_nr}    qRxLevMin_other_nr=${qRxLevMin_other_nr}
    ...    qRxLevMin_call_lte=${qRxLevMin_call_lte}    qRxLevMin_other_lte=${qRxLevMin_other_lte}    omit_time_lte=${omit_time_lte}
    ...    connection=${connection}    mrbtsId=${mrbtsId}    nrbtsId=${nrbtsId}    lnBtsId=${lnBtsId}    pa_call_default=${pa_call_default}
    ...    check_on_air=${check_on_air}
    ...    ELSE IF    '${cell_a_type}'=='lte' and '${cell_b_type}'=='nr'    cell_block_unblock_lte_nr   cell_id_a=${cell_a_index}
    ...    cell_id_b=${cell_b_index}    target_avg_percent_nr=${target_avg_percent_nr}    min_percent_nr=${min_percent_nr}
    ...    target_avg_percent_lte=${target_avg_percent_lte}    min_percent_lte=${min_percent_lte}    tput_define_nr=${tput_define_nr}
    ...    tput_define_lte=${tput_define_lte}    duration=${duration}    tput_from=${tput_from}    process_num_ul=${process_num_ul}
    ...    ui_version=${ui_version}    scf_name=${scf_name}    qRxLevMin_call_nr=${qRxLevMin_call_nr}    qRxLevMin_other_nr=${qRxLevMin_other_nr}
    ...    qRxLevMin_call_lte=${qRxLevMin_call_lte}    qRxLevMin_other_lte=${qRxLevMin_other_lte}    omit_time_lte=${omit_time_lte}
    ...    connection=${connection}    mrbtsId=${mrbtsId}    nrbtsId=${nrbtsId}    lnBtsId=${lnBtsId}    pa_call_default=${pa_call_default}
    ...    check_on_air=${check_on_air}
    ...    ELSE    cell_block_unblock_lte_lte    tput_self_define=${tput_define_lte}    cell_id_a=${cell_a_index}    cell_id_b=${cell_b_index}
    ...    target_avg_percent=${target_avg_percent_lte}    min_percent=${min_percent_lte}    duration=${duration}    scf_name=${scf_name}
    ...    omit_time=${omit_time_lte}    qRxLevMin_call=${qRxLevMin_call_lte}    qRxLevMin_other=${qRxLevMin_other_lte}
    ...    mrbtsId=${mrbtsId}    lnBtsId=${lnBtsId}    pa_call_default=${pa_call_default}    check_on_air=${check_on_air}

cell_block_unblock_nr_nr
    [Arguments]    ${mrbtsId}    ${nrbtsId}    ${tput_self_define}    ${cell_id_a}    ${cell_id_b}    ${target_avg_percent}=${None}
    ...    ${min_percent}=${None}    ${duration}=${600}    ${tput_from}=tool    ${process_num_ul}=1    ${ui_version}=default    ${scf_name}=${None}
    ...    ${qRxLevMin_call}=${-65}    ${qRxLevMin_other}=${-22}    ${connection}=GNB_OAM    ${pa_call_default}=${None}    ${check_on_air}=${False}
    ${target_avg_percent}    Run Keyword If    ${target_avg_percent}==${None}    get_avg_expect_rate    ELSE
    ...    set variable    ${target_avg_percent}
    ${min_percent}    Run keyword If    ${min_percent}==${None}    get_min_expect_rate    ELSE
    ...    set variable    ${min_percent}
    ${ue_index_a}    set variable    ${tput_self_define[${cell_id_a}]['ue_index']}
    ${tput_cell_a}    run keyword if    '${tput_from}'=='tool'    get_tput_info_by_tool
    ...    cell_id=${cell_id_a}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    scf_name=${scf_name}
    ...    duration=${duration}    ue_index=${ue_index_a}    connection=${connection}    ELSE    set variable    ${tput_self_define[${cell_id_a}]}
    ${tput_define_a}    create dictionary
    set to dictionary    ${tput_define_a}    ${cell_id_a}    ${tput_cell_a}
    ########################################################################
    ${ue_index_b}    set variable    ${tput_self_define[${cell_id_b}]['ue_index']}
    ${tput_cell_b}    run keyword if    '${tput_from}'=='tool'    get_tput_info_by_tool
    ...    cell_id=${cell_id_b}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    scf_name=${scf_name}
    ...    duration=${duration}    ue_index=${ue_index_b}    connection=${connection}    ELSE    set variable    ${tput_self_define[${cell_id_b}]}
    ${tput_define_b}    create dictionary
    set to dictionary    ${tput_define_b}    ${cell_id_b}    ${tput_cell_b}
    ########################################################################
    log to console    set all PA port to 127
    Init PA Value for All Ports    scf_name=${scf_name}
    log to console    set PA for nr cell ${cell_id_a}
    Set PA Value For Cell    scf_name=${scf_name}    cell_id=${cell_id_a}    pa_call_default=${pa_call_default}    cell_type=nr
    ########################################################################
    log to console    make call for cell ${cell_id_a}
    Set qRxLevMin For Nr Call    mrbtsId=${mrbtsId}    nrbtsId=${nrbtsId}    nr_cell_all=${nr_cell_all}    cell_id_call=${cell_id_a}
    ...    qRxLevMin_call=${qRxLevMin_call}    qRxLevMin_other=${qRxLevMin_other}    connection=${connection}    check_on_air=${check_on_air}
    make_call    tput_info=${tput_cell_a}    ue_index=${ue_index_a}    process_num_ul=${process_num_ul}    ui_version=${ui_version}
    log to console    block cell ${cell_id_b}
    coam.block_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id_b}    connection=${connection}    timeout=60s
    sleep    5s
    Wait Until Keyword Succeeds    5min    5s    Check single NR cell status    cell_idx=${cell_id_b}
    ...    operationalState=disabled     usageState=idle    blockState=blocked
    log to console    collect tput for cell ${cell_id_a}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    log to console    check tput for cell ${cell_id_a}
    check_tput_for_each_cell    tput_info=${tput_define_a}    cell_id=${cell_id_a}    ue_index=${ue_index_a}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    connection=${connection}
    log to console    unblock cell ${cell_id_b}
    coam.unblock_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id_b}    connection=${connection}    timeout=60s
    sleep    5s
    Wait Until Keyword Succeeds    5min    5s    Check single NR cell status    cell_idx=${cell_id_b}
    log to console    collect tput for cell ${cell_id_a}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    log to console    check tput for cell ${cell_id_a}
    check_tput_for_each_cell    tput_info=${tput_define_a}    cell_id=${cell_id_a}    ue_index=${ue_index_a}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    connection=${connection}
    log to console    stop and detch ue for cell ${cell_id_a}
    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    ########################################################################
    log to console    set all PA port to 127
    Init PA Value for All Ports    scf_name=${scf_name}
    log to console    set PA for nr cell ${cell_id_b}
    Set PA Value For Cell    scf_name=${scf_name}    cell_id=${cell_id_b}    pa_call_default=${pa_call_default}    cell_type=nr
    ########################################################################
    log to console    make call for cell ${cell_id_b}
    Set qRxLevMin For Nr Call    mrbtsId=${mrbtsId}    nrbtsId=${nrbtsId}    nr_cell_all=${nr_cell_all}    cell_id_call=${cell_id_b}
    ...    qRxLevMin_call=${qRxLevMin_call}    qRxLevMin_other=${qRxLevMin_other}    connection=${connection}    check_on_air=${check_on_air}
    make_call    tput_info=${tput_cell_b}    ue_index=${ue_index_b}    process_num_ul=${process_num_ul}    ui_version=${ui_version}
    log to console    block cell ${cell_id_a}
    coam.block_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id_a}    connection=${connection}    timeout=60s
    sleep    5s
    Wait Until Keyword Succeeds    5min    5s    Check single NR cell status    cell_idx=${cell_id_a}
    ...    operationalState=disabled     usageState=idle    blockState=blocked
    log to console    collect tput for cell ${cell_id_b}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    log to console    check tput for cell ${cell_id_b}
    check_tput_for_each_cell    tput_info=${tput_define_b}    cell_id=${cell_id_b}    ue_index=${ue_index_b}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    connection=${connection}
    log to console    unblock cell ${cell_id_a}
    coam.unblock_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id_a}    connection=${connection}    timeout=60s
    sleep    5s
    Wait Until Keyword Succeeds    5min    5s    Check single NR cell status    cell_idx=${cell_id_a}
    log to console    collect tput for cell ${cell_id_b}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    log to console    check tput for cell ${cell_id_b}
    check_tput_for_each_cell    tput_info=${tput_define_b}    cell_id=${cell_id_b}    ue_index=${ue_index_b}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    connection=${connection}
    log to console    stop and detch ue for cell ${cell_id_b}
    [Teardown]    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}


cell_block_unblock_nr_lte
    [Arguments]    ${mrbtsId}    ${nrbtsId}    ${cell_id_a}    ${cell_id_b}    ${target_avg_percent_nr}=${None}    ${lnBtsId}=${None}
    ...    ${min_percent_nr}=${None}    ${target_avg_percent_lte}=${None}    ${min_percent_lte}=${None}    ${tput_define_nr}=${None}
    ...    ${tput_define_lte}=${None}    ${duration}=${600}    ${tput_from}=tool    ${process_num_ul}=1    ${ui_version}=default
    ...    ${scf_name}=${None}    ${omit_time_lte}=10    ${qRxLevMin_call_nr}=${-65}    ${qRxLevMin_other_nr}=${-22}
    ...    ${qRxLevMin_call_lte}=${-130}    ${qRxLevMin_other_lte}=${-44}    ${connection}=GNB_OAM    ${pa_call_default}=${None}
    ...    ${check_on_air}=${False}
    ${target_avg_percent_nr}    Run Keyword If    ${target_avg_percent_nr}==${None}    get_avg_expect_rate    ELSE
    ...    set variable    ${target_avg_percent_nr}
    ${min_percent_nr}    Run keyword If    ${min_percent_nr}==${None}    get_min_expect_rate    ELSE
    ...    set variable    ${min_percent_nr}
    ${target_avg_percent_lte}    Run Keyword If    ${target_avg_percent_lte}==${None}    get_avg_expect_rate    ELSE
    ...    set variable    ${target_avg_percent_lte}
    ${min_percent_lte}    Run keyword If    ${min_percent_lte}==${None}    get_min_expect_rate    ELSE
    ...    set variable    ${min_percent_lte}
    ${ue_index_a}    set variable    ${tput_define_nr[${cell_id_a}]['ue_index']}
    ${tput_cell_a}    run keyword if    '${tput_from}'=='tool'    get_tput_info_by_tool
    ...    cell_id=${cell_id_a}    target_avg_percent=${target_avg_percent_nr}    min_percent=${min_percent_nr}    scf_name=${scf_name}
    ...    duration=${duration}    ue_index=${ue_index_a}    connection=${connection}    ELSE    set variable    ${tput_define_nr[${cell_id_a}]}
    ${tput_define_a}    create dictionary
    set to dictionary    ${tput_define_a}    ${cell_id_a}    ${tput_cell_a}
    #################################################################################################################
    ${ue_index_b}    set variable    ${tput_define_lte[${cell_id_b}]['ue_index']}
    ${ue_type_4G}    translate_power_ue_type_from_testline    ue_index=${ue_index_b}
    ${throughput_dl}    set variable    ${tput_define_lte[${cell_id_b}]['dl_tp']}
    ${throughput_ul}    set variable    ${tput_define_lte[${cell_id_b}]['ul_tp']}
    ${target_throughput_dl}    set variable    ${tput_define_lte[${cell_id_b}]['dl_exp']}
    ${target_throughput_ul}    set variable    ${tput_define_lte[${cell_id_b}]['ul_exp']}
    #################################################################################################################
    log to console    set all PA port to 127
    Init PA Value for All Ports    scf_name=${scf_name}
    log to console    set PA for nr cell ${cell_id_a}
    Set PA Value For Cell     scf_name=${scf_name}    cell_id=${cell_id_a}    pa_call_default=${pa_call_default}    cell_type=nr
    #################################################################################################################
    log to console    make call for cell ${cell_id_a}
    Set qRxLevMin For Nr Call    mrbtsId=${mrbtsId}    nrbtsId=${nrbtsId}    nr_cell_all=${nr_cell_all}    cell_id_call=${cell_id_a}
    ...    qRxLevMin_call=${qRxLevMin_call_nr}    qRxLevMin_other=${qRxLevMin_other_nr}    connection=${connection}    check_on_air=${check_on_air}
    make_call    tput_info=${tput_cell_a}    ue_index=${ue_index_a}    process_num_ul=${process_num_ul}    ui_version=${ui_version}
    log to console    block cell ${cell_id_b}
    coam.block_cell    dist_name=MRBTS-${mrbtsID}/LNBTS-${lnBtsId}/LNCEL-${cell_id_b}    connection=${connection}    timeout=60s
    sleep    5s
    Wait Until Keyword Succeeds    5min    5s    Check single LTE cell status    cell_idx=${cell_id_b}
    ...    operationalState=disabled     blockState=blocked
    log to console    collect tput for cell ${cell_id_a}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    log to console    check tput for cell ${cell_id_a}
    check_tput_for_each_cell    tput_info=${tput_define_a}    cell_id=${cell_id_a}    ue_index=${ue_index_a}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent_nr}    min_percent=${min_percent_nr}    connection=${connection}
    log to console    unblock cell ${cell_id_b}
    coam.unblock_cell    dist_name=MRBTS-${mrbtsID}/LNBTS-${lnBtsId}/LNCEL-${cell_id_b}    connection=${connection}    timeout=60s
    sleep    5s
    Wait Until Keyword Succeeds    5min    5s    Check single LTE cell status    cell_idx=${cell_id_b}
    log to console    collect tput for cell ${cell_id_a}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    log to console    check tput for cell ${cell_id_a}
    check_tput_for_each_cell    tput_info=${tput_define_a}    cell_id=${cell_id_a}    ue_index=${ue_index_a}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent_nr}    min_percent=${min_percent_nr}    connection=${connection}
    log to console    stop and detch ue for cell ${cell_id_a}
    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    #################################################################################################################
    log to console    set all PA port to 127
    Init PA Value for All Ports    scf_name=${scf_name}
    log to console    set PA for lte cell ${cell_id_b}
    Set PA Value For Cell    scf_name=${scf_name}    cell_id=${cell_id_b}    pa_call_default=${pa_call_default}    cell_type=lte
    #################################################################################################################
    log to console    make call for cell ${cell_id_b}
    Set qRxLevMin For Lte Call    mrbtsId=${mrbtsId}    lnBtsId=${lnBtsId}    lte_cell_all=${lte_cell_all}    cell_id_call=${cell_id_b}
    ...    qRxLevMin_call=${qRxLevMin_call_lte}   qRxLevMin_other=${qRxLevMin_other_lte}    connection=${connection}    check_on_air=${check_on_air}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}    ue_index=${ue_index_b}
    log to console    block cell ${cell_id_a}
    coam.block_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id_a}    connection=${connection}    timeout=60s
    sleep    5s
    Wait Until Keyword Succeeds    5min    5s    Check single NR cell status    cell_idx=${cell_id_a}
    ...    operationalState=disabled     usageState=idle    blockState=blocked
#    log to console    collect tput for cell ${cell_id_b}
#    sleep    ${duration}s
#    log to console    stop traffic for cell ${cell_id_b}
#    run keyword and ignore error    stop_traffic_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${ue_index_b}
#    log to console    check tput for cell ${cell_id_b}
#    check_tput_for_4G_call_config    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl}
#    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${ue_index_b}    omit_time=${omit_time_lte}
#    ...    target_avg_percent=${target_avg_percent_lte}    min_percent=${min_percent_lte}
#    power_ue.Start traffic    ue_type=${ue_type_4G}    direction=dl    throughput=${throughput_dl}
#    ...    duration=${3600}    ue_index=${ue_index_b}
#    power_ue.Start traffic    ue_type=${ue_type_4G}    direction=ul    throughput=${throughput_ul}
#    ...    duration=${3600}    ue_index=${ue_index_b}
    log to console    unblock cell ${cell_id_a}
    coam.unblock_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id_a}    connection=${connection}    timeout=60s
    sleep    5s
    Wait Until Keyword Succeeds    5min    5s    Check single NR cell status    cell_idx=${cell_id_a}
    log to console    collect tput for cell ${cell_id_b}
    sleep    ${duration}s
    log to console    stop traffic for cell ${cell_id_b}
    run keyword and ignore error    stop_traffic_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${ue_index_b}
    log to console    check tput for cell ${cell_id_b}
    check_tput_for_4G_call_config    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl}
    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${ue_index_b}    omit_time=${omit_time_lte}
    ...    target_avg_percent=${target_avg_percent_lte}    min_percent=${min_percent_lte}
    log to console    detach ue from cell ${cell_id_b}
    [Teardown]    run keywords    run keyword and ignore error    stop_traffic_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${ue_index_b}
    ...    AND    run keyword and ignore error    detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${ue_index_b}    AND
    ...    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}

cell_block_unblock_lte_nr
    [Arguments]    ${mrbtsId}    ${nrbtsId}    ${cell_id_a}    ${cell_id_b}    ${target_avg_percent_nr}=${None}    ${lnBtsId}=${None}
    ...    ${min_percent_nr}=${None}    ${target_avg_percent_lte}=${None}    ${min_percent_lte}=${None}    ${tput_define_nr}=${None}
    ...    ${tput_define_lte}=${None}    ${duration}=${600}    ${tput_from}=tool    ${process_num_ul}=1    ${ui_version}=default
    ...    ${scf_name}=${None}    ${omit_time_lte}=10    ${qRxLevMin_call_nr}=${-65}    ${qRxLevMin_other_nr}=${-22}
    ...    ${qRxLevMin_call_lte}=${-130}    ${qRxLevMin_other_lte}=${-44}    ${connection}=GNB_OAM    ${pa_call_default}=${None}
    ...    ${check_on_air}=${False}
    ${target_avg_percent_nr}    Run Keyword If    ${target_avg_percent_nr}==${None}    get_avg_expect_rate    ELSE
    ...    set variable    ${target_avg_percent_nr}
    ${min_percent_nr}    Run keyword If    ${min_percent_nr}==${None}    get_min_expect_rate    ELSE
    ...    set variable    ${min_percent_nr}
    ${target_avg_percent_lte}    Run Keyword If    ${target_avg_percent_lte}==${None}    get_avg_expect_rate    ELSE
    ...    set variable    ${target_avg_percent_lte}
    ${min_percent_lte}    Run keyword If    ${min_percent_lte}==${None}    get_min_expect_rate    ELSE
    ...    set variable    ${min_percent_lte}
    ${ue_index_a}    set variable    ${tput_define_lte[${cell_id_a}]['ue_index']}
    ${ue_type_4G}    translate_power_ue_type_from_testline    ue_index=${ue_index_a}
    ${throughput_dl}    set variable    ${tput_define_lte[${cell_id_a}]['dl_tp']}
    ${throughput_ul}    set variable    ${tput_define_lte[${cell_id_a}]['ul_tp']}
    ${target_throughput_dl}    set variable    ${tput_define_lte[${cell_id_a}]['dl_exp']}
    ${target_throughput_ul}    set variable    ${tput_define_lte[${cell_id_a}]['ul_exp']}
    #################################################################################################################
    ${ue_index_b}    set variable    ${tput_define_nr[${cell_id_b}]['ue_index']}
    ${tput_cell_b}    run keyword if    '${tput_from}'=='tool'    get_tput_info_by_tool
    ...    cell_id=${cell_id_b}    target_avg_percent=${target_avg_percent_nr}    min_percent=${min_percent_nr}    scf_name=${scf_name}
    ...    duration=${duration}    ue_index=${ue_index_b}    connection=${connection}    ELSE    set variable    ${tput_define_nr[${cell_id_b}]}
    ${tput_define_b}    create dictionary
    set to dictionary    ${tput_define_b}    ${cell_id_b}    ${tput_cell_b}
    #################################################################################################################
    log to console    set all PA port to 127
    Init PA Value for All Ports    scf_name=${scf_name}
    log to console    set PA for lte cell ${cell_id_a}
    Set PA Value For Cell    scf_name=${scf_name}    cell_id=${cell_id_a}    pa_call_default=${pa_call_default}    cell_type=lte
    #################################################################################################################
    log to console    make call for cell ${cell_id_a}
    Set qRxLevMin For Lte Call    mrbtsId=${mrbtsId}    lnBtsId=${lnBtsId}    lte_cell_all=${lte_cell_all}    cell_id_call=${cell_id_a}
    ...    qRxLevMin_call=${qRxLevMin_call_lte}   qRxLevMin_other=${qRxLevMin_other_lte}    connection=${connection}    check_on_air=${check_on_air}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}
    ...    ue_index=${ue_index_a}
    log to console    block cell ${cell_id_b}
    coam.block_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id_b}    connection=${connection}    timeout=60s
    sleep    5s
    Wait Until Keyword Succeeds    5min    5s    Check single NR cell status    cell_idx=${cell_id_b}
    ...    operationalState=disabled     usageState=idle    blockState=blocked
#    log to console    collect tput for cell ${cell_id_a}
#    sleep    ${duration}s
#    log to console    stop traffic for cell ${cell_id_a}
#    run keyword and ignore error    stop_traffic_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${ue_index_a}
#    log to console    check tput for cell ${cell_id_a}
#    check_tput_for_4G_call_config    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl}
#    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${ue_index_a}    omit_time=${omit_time_lte}
#    ...    target_avg_percent=${target_avg_percent_lte}    min_percent=${min_percent_lte}
#    power_ue.Start traffic    ue_type=${ue_type_4G}    direction=dl    throughput=${throughput_dl}
#    ...    duration=${3600}    ue_index=${ue_index_a}
#    power_ue.Start traffic    ue_type=${ue_type_4G}    direction=ul    throughput=${throughput_ul}
#    ...    duration=${3600}    ue_index=${ue_index_a}
    log to console    unblock cell ${cell_id_b}
    coam.unblock_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id_b}    connection=${connection}    timeout=60s
    sleep    5s
    Wait Until Keyword Succeeds    5min    5s    Check single NR cell status    cell_idx=${cell_id_b}
    log to console    collect tput for cell ${cell_id_a}
    sleep    ${duration}s
    log to console    stop traffic for cell ${cell_id_a}
    run keyword and ignore error    stop_traffic_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${ue_index_a}
    log to console    check tput for cell ${cell_id_a}
    check_tput_for_4G_call_config    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl}
    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${ue_index_a}    omit_time=${omit_time_lte}
    ...    target_avg_percent=${target_avg_percent_lte}    min_percent=${min_percent_lte}
    log to console    detach ue from cell ${cell_id_a}
    run keyword and ignore error    detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${ue_index_a}
    #################################################################################################################
    log to console    set all PA port to 127
    Init PA Value for All Ports    scf_name=${scf_name}
    log to console    set PA for nr cell ${cell_id_b}
    Set PA Value For Cell    scf_name=${scf_name}    cell_id=${cell_id_b}    pa_call_default=${pa_call_default}    cell_type=nr
    #################################################################################################################
    log to console    make call for cell ${cell_id_b}
    Set qRxLevMin For Nr Call    mrbtsId=${mrbtsId}    nrbtsId=${nrbtsId}    nr_cell_all=${nr_cell_all}    cell_id_call=${cell_id_b}
    ...    qRxLevMin_call=${qRxLevMin_call_nr}    qRxLevMin_other=${qRxLevMin_other_nr}    connection=${connection}    check_on_air=${check_on_air}
    make_call    tput_info=${tput_cell_b}    ue_index=${ue_index_b}    process_num_ul=${process_num_ul}    ui_version=${ui_version}
    log to console    block cell ${cell_id_a}
    coam.block_cell    dist_name=MRBTS-${mrbtsID}/LNBTS-${lnBtsId}/LNCEL-${cell_id_a}    connection=${connection}    timeout=60s
    sleep    5s
    Wait Until Keyword Succeeds    5min    5s    Check single LTE cell status    cell_idx=${cell_id_a}
    ...    operationalState=disabled     blockState=blocked
    log to console    collect tput for cell ${cell_id_b}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    log to console    check tput for cell ${cell_id_b}
    check_tput_for_each_cell    tput_info=${tput_define_b}    cell_id=${cell_id_b}    ue_index=${ue_index_b}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent_nr}    min_percent=${min_percent_nr}    connection=${connection}
    log to console    unblock cell ${cell_id_a}
    coam.unblock_cell    dist_name=MRBTS-${mrbtsID}/LNBTS-${lnBtsId}/LNCEL-${cell_id_a}    connection=${connection}    timeout=60s
    sleep    5s
    Wait Until Keyword Succeeds    5min    5s    Check single LTE cell status    cell_idx=${cell_id_a}
    log to console    collect tput for cell ${cell_id_b}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    log to console    check tput for cell ${cell_id_b}
    check_tput_for_each_cell    tput_info=${tput_define_b}    cell_id=${cell_id_b}    ue_index=${ue_index_b}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent_nr}    min_percent=${min_percent_nr}    connection=${connection}
    log to console    stop and detch ue for cell ${cell_id_b}
    [Teardown]    run keywords        run keyword and ignore error    stop_traffic_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${ue_index_a}
    ...    AND    run keyword and ignore error    detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${ue_index_a}    AND
    ...    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}

cell_block_unblock_lte_lte
    [Arguments]    ${mrbtsId}    ${tput_self_define}    ${cell_id_a}    ${cell_id_b}    ${target_avg_percent}=${None}    ${lnBtsId}=${None}
    ...    ${min_percent}=${None}    ${duration}=${600}    ${omit_time}=10    ${qRxLevMin_call}=${-130}    ${qRxLevMin_other}=${-44}
    ...    ${pa_call_default}=${None}    ${check_on_air}=${False}    ${connection}=GNB_OAM    ${scf_name}=${None}
    ...    ${log_dir}=${TS_CASE_LOG_PATH}
    ${target_avg_percent}    Run Keyword If    ${target_avg_percent}==${None}    get_avg_expect_rate    ELSE
    ...    set variable    ${target_avg_percent}
    ${min_percent}    Run keyword If    ${min_percent}==${None}    get_min_expect_rate    ELSE
    ...    set variable    ${min_percent}
    ${ue_index_a}    set variable    ${tput_self_define[${cell_id_a}]['ue_index']}
    ${ue_type_4G_a}    translate_power_ue_type_from_testline    ue_index=${ue_index_a}
    ${throughput_dl_a}    set variable    ${tput_self_define[${cell_id_a}]['dl_tp']}
    ${throughput_ul_a}    set variable    ${tput_self_define[${cell_id_a}]['ul_tp']}
    ${target_throughput_dl_a}    set variable    ${tput_self_define[${cell_id_a}]['dl_exp']}
    ${target_throughput_ul_a}    set variable    ${tput_self_define[${cell_id_a}]['ul_exp']}
    ########################################################################################
    ${ue_index_b}    set variable    ${tput_self_define[${cell_id_b}]['ue_index']}
    ${ue_type_4G_b}    translate_power_ue_type_from_testline    ue_index=${ue_index_b}
    ${throughput_dl_b}    set variable    ${tput_self_define[${cell_id_b}]['dl_tp']}
    ${throughput_ul_b}    set variable    ${tput_self_define[${cell_id_b}]['ul_tp']}
    ${target_throughput_dl_b}    set variable    ${tput_self_define[${cell_id_b}]['dl_exp']}
    ${target_throughput_ul_b}    set variable    ${tput_self_define[${cell_id_b}]['ul_exp']}
    ########################################################################################
    log to console    set all PA port to 127
    Init PA Value for All Ports    scf_name=${scf_name}
    log to console    set PA for lte cell ${cell_id_a}
    Set PA Value For Cell    scf_name=${scf_name}    cell_id=${cell_id_a}    pa_call_default=${pa_call_default}    cell_type=lte
    #################################################################################################################
    log to console    make call for cell ${cell_id_a}
    Set qRxLevMin For Lte Call    mrbtsId=${mrbtsId}    lnBtsId=${lnBtsId}    lte_cell_all=${lte_cell_all}    cell_id_call=${cell_id_a}
    ...    qRxLevMin_call=${qRxLevMin_call}   qRxLevMin_other=${qRxLevMin_other}    connection=${connection}    check_on_air=${check_on_air}
    make_call_4G    ue_type_4G=${ue_type_4G_a}    throughput_dl=${throughput_dl_a}    throughput_ul=${throughput_ul_a}
    ...    ue_index=${ue_index_a}
    log to console    block cell ${cell_id_b}
    coam.block_cell    dist_name=MRBTS-${mrbtsID}/LNBTS-${lnBtsId}/LNCEL-${cell_id_b}    connection=${connection}    timeout=60s
    sleep    5s
    Wait Until Keyword Succeeds    5min    5s    Check single LTE cell status    cell_idx=${cell_id_b}
    ...    operationalState=disabled     blockState=blocked
#    log to console    collect tput for cell ${cell_id_a}
#    sleep    ${duration}s
#    log to console    stop traffic for cell ${cell_id_a}
#    run keyword and ignore error    stop_traffic_for_4G_call    ue_type_4G=${ue_type_4G_a}    ue_index=${ue_index_a}
#    log to console    check tput for cell ${cell_id_a}
#    check_tput_for_4G_call_config    ue_type_4G=${ue_type_4G_a}    target_throughput_dl=${target_throughput_dl_a}
#    ...    target_throughput_ul=${target_throughput_ul_a}    ue_index=${ue_index_a}    omit_time=${omit_time}
#    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
#    power_ue.Start traffic    ue_type=${ue_type_4G}    direction=dl    throughput=${throughput_dl_a}
#    ...    duration=${3600}    ue_index=${ue_index_a}
#    power_ue.Start traffic    ue_type=${ue_type_4G}    direction=ul    throughput=${throughput_ul_a}
#    ...    duration=${3600}    ue_index=${ue_index_a}
    log to console    unblock cell ${cell_id_b}
    coam.unblock_cell    dist_name=MRBTS-${mrbtsID}/LNBTS-${lnBtsId}/LNCEL-${cell_id_b}    connection=${connection}    timeout=60s
    sleep    5s
    Wait Until Keyword Succeeds    5min    5s    Check single LTE cell status    cell_idx=${cell_id_b}
    log to console    collect tput for cell ${cell_id_a}
#    sleep    ${duration}s
    ${log_type}    run keyword if    '${ue_type_4G_a}'=='nokia_fastmile'    set variable    Iperf
    ...    ELSE    set variable    Aasyslog
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type_4G_a}    log_dir=${log_dir}    ue_index=${ue_index_a}    duration=${duration}
    ...    check_source=${log_type}    ignore_time=${omit_time}
    log to console    stop traffic for cell ${cell_id_a}
    run keyword and ignore error    stop_traffic_for_4G_call    ue_type_4G=${ue_type_4G_a}    ue_index=${ue_index_a}
    log to console    check tput for cell ${cell_id_a}
    check_tput_for_4G_call_config    ue_type_4G=${ue_type_4G_a}    target_throughput_dl=${target_throughput_dl_a}
    ...    target_throughput_ul=${target_throughput_ul_a}    ue_index=${ue_index_a}    omit_time=${omit_time}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    log to console    detach ue from cell ${cell_id_a}
    run keyword and ignore error    detach_for_4G_call    ue_type_4G=${ue_type_4G_a}    ue_index=${ue_index_a}
    #################################################################################################################
    log to console    set all PA port to 127
    Init PA Value for All Ports    scf_name=${scf_name}
    log to console    set PA for lte cell ${cell_id_b}
    Set PA Value For Cell    scf_name=${scf_name}    cell_id=${cell_id_b}    pa_call_default=${pa_call_default}    cell_type=lte
    #################################################################################################################
    log to console    make call for cell ${cell_id_b}
    Set qRxLevMin For Lte Call    mrbtsId=${mrbtsId}    lnBtsId=${lnBtsId}    lte_cell_all=${lte_cell_all}    cell_id_call=${cell_id_b}
    ...    qRxLevMin_call=${qRxLevMin_call}   qRxLevMin_other=${qRxLevMin_other}    connection=${connection}    check_on_air=${check_on_air}
    make_call_4G    ue_type_4G=${ue_type_4G_b}    throughput_dl=${throughput_dl_b}    throughput_ul=${throughput_ul_b}
    ...    ue_index=${ue_index_b}
    log to console    block cell ${cell_id_a}
    coam.block_cell    dist_name=MRBTS-${mrbtsID}/LNBTS-${lnBtsId}/LNCEL-${cell_id_a}    connection=${connection}    timeout=60s
    sleep    5s
    Wait Until Keyword Succeeds    5min    5s    Check single LTE cell status    cell_idx=${cell_id_a}
    ...    operationalState=disabled     blockState=blocked
#    log to console    collect tput for cell ${cell_id_b}
#    sleep    ${duration}s
#    log to console    stop traffic for cell ${cell_id_b}
#    run keyword and ignore error    stop_traffic_for_4G_call    ue_type_4G=${ue_type_4G_b}    ue_index=${ue_index_b}
#    log to console    check tput for cell ${cell_id_b}
#    check_tput_for_4G_call_config    ue_type_4G=${ue_type_4G_b}    target_throughput_dl=${target_throughput_dl_b}
#    ...    target_throughput_ul=${target_throughput_ul_b}    ue_index=${ue_index_b}    omit_time=${omit_time}
#    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
#    power_ue.Start traffic    ue_type=${ue_type_4G}    direction=dl    throughput=${throughput_dl_b}
#    ...    duration=${3600}    ue_index=${ue_index_b}
#    power_ue.Start traffic    ue_type=${ue_type_4G}    direction=ul    throughput=${throughput_ul_b}
#    ...    duration=${3600}    ue_index=${ue_index_b}
    log to console    unblock cell ${cell_id_a}
    coam.unblock_cell    dist_name=MRBTS-${mrbtsID}/LNBTS-${lnBtsId}/LNCEL-${cell_id_a}    connection=${connection}    timeout=60s
    sleep    5s
    Wait Until Keyword Succeeds    5min    5s    Check single LTE cell status    cell_idx=${cell_id_a}
    log to console    collect tput for cell ${cell_id_b}
#    sleep    ${duration}s
    ${log_type}    run keyword if    '${ue_type_4G_b}'=='nokia_fastmile'    set variable    Iperf
    ...    ELSE    set variable    Aasyslog
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type_4G_b}    log_dir=${log_dir}    ue_index=${ue_index_b}    duration=${duration}
    ...    check_source=${log_type}    ignore_time=${omit_time}
    log to console    stop traffic for cell ${cell_id_b}
    run keyword and ignore error    stop_traffic_for_4G_call    ue_type_4G=${ue_type_4G_b}    ue_index=${ue_index_b}
    log to console    check tput for cell ${cell_id_b}
    check_tput_for_4G_call_config    ue_type_4G=${ue_type_4G_b}    target_throughput_dl=${target_throughput_dl_b}
    ...    target_throughput_ul=${target_throughput_ul_b}    ue_index=${ue_index_b}    omit_time=${omit_time}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    log to console    detach ue from cell ${cell_id_b}
    [Teardown]    run keywords    run keyword and ignore error    stop_traffic_for_4G_call    ue_type_4G=${ue_type_4G_b}    ue_index=${ue_index_b}
    ...    AND    run keyword and ignore error    detach_for_4G_call    ue_type_4G=${ue_type_4G_b}    ue_index=${ue_index_b}

cell_block_unblock_nr
    [Arguments]    ${tput_self_define}    ${mrbtsId}    ${nrbtsId}    ${cell_id}    ${target_avg_percent}=${None}
    ...    ${min_percent}=${None}    ${protocol}=udp    ${duration}=${600}    ${tput_from}=tool
    ...    ${loop_times}=${2}    ${connection}=GNB_OAM    ${process_num_ul}=1    ${ui_version}=default
    ...    ${scf_name}=${None}    ${pa_call_default}=${None}
    log to console    block cell ${cell_id}
    coam.block_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}    connection=${connection}    timeout=60s
    sleep    5s
    Wait Until Keyword Succeeds    5min    5s    Check single NR cell status    cell_idx=${cell_id}
    ...    operationalState=disabled     usageState=idle    blockState=blocked
    log to console    unblock cell ${cell_id}
    coam.unblock_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}    connection=${connection}    timeout=60s
    sleep    5s
    Wait Until Keyword Succeeds    5min    5s    Check single NR cell status    cell_idx=${cell_id}
    All SMODs BBMODs RMODs and Cells should be onair
    log to console    make call and check tput for cell ${cell_id}
    log to console    set all PA port to 127
    Init PA Value for All Ports    scf_name=${scf_name}
    log to console    set PA for nr cell ${cell_id}
    Set PA Value For Cell    scf_name=${scf_name}    cell_id=${cell_id}    pa_call_default=${pa_call_default}    cell_type=nr
    ${cell_id}    Convert To Integer    ${cell_id}
    ${cell_id_list}    Create List    ${cell_id}
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_id_list}    target_avg_percent=${target_avg_percent}
    ...    min_percent=${min_percent}    protocol=${protocol}    duration=${duration}
    ...    tput_from=${tput_from}    loop_times=${loop_times}    process_num_ul=${process_num_ul}    ui_version=${ui_version}
    ...    scf_name=${scf_name}    connection=${connection}

cell_block_unblock_lte
    [Arguments]    ${tput_self_define}    ${mrbtsId}    ${cell_id}    ${target_avg_percent}=${None}    ${min_percent}=${None}    ${lnBtsId}=${None}
    ...    ${duration}=${600}    ${omit_time}=10    ${pa_call_default}=${None}    ${scf_name}=${None}    ${connection}=GNB_OAM
    ${target_avg_percent}    Run Keyword If    ${target_avg_percent}==${None}    get_avg_expect_rate    ELSE
    ...    set variable    ${target_avg_percent}
    ${min_percent}    Run keyword If    ${min_percent}==${None}    get_min_expect_rate    ELSE
    ...    set variable    ${min_percent}
    log to console    block cell ${cell_id}
    coam.block_cell    dist_name=MRBTS-${mrbtsID}/LNBTS-${lnBtsId}/LNCEL-${cell_id}    connection=${connection}    timeout=60s
    sleep    5s
    Wait Until Keyword Succeeds    5min    5s    Check single LTE cell status    cell_idx=${cell_id}
    ...    operationalState=disabled     blockState=blocked
    log to console    unblock cell ${cell_id}
    coam.unblock_cell    dist_name=MRBTS-${mrbtsID}/LNBTS-${lnBtsId}/LNCEL-${cell_id}    connection=${connection}    timeout=60s
    sleep    5s
    Wait Until Keyword Succeeds    5min    5s    Check single LTE cell status    cell_idx=${cell_id}
    All SMODs BBMODs RMODs and Cells should be onair
    log to console    make call and check tput for cell ${cell_id}
    log to console    set all PA port to 127
    Init PA Value for All Ports    scf_name=${scf_name}
    log to console    set PA for lte cell ${cell_id}
    Set PA Value For Cell    scf_name=${scf_name}    cell_id=${cell_id}    pa_call_default=${pa_call_default}    cell_type=lte
    data_transfer_common_lte       tput_self_define=${tput_self_define}     cell_id=${cell_id}    target_avg_percent=${target_avg_percent}
    ...    min_percent=${min_percent}    duration=${duration}    omit_time=${omit_time}

Set PA Value For Cell
    [Arguments]    ${cell_type}    ${cell_id}     ${gnb_index}=${0}    ${du_index}=${0}    ${pa_call_default}=${None}
    ...    ${scf_name}=${None}
    ${cells_info}    coam.get_cells_info    cell_type=${cell_type}    connection=GNB_OAM
    FOR    ${cell}    IN    @{cells_info}
        exit for loop if    ${cell['globalCellId']}==${cell_id}
    END
    ${carrierList}    set variable    ${cell['carrierList']}
    ${rus_config_info}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus}
    ${attenuator}   get_attenuator    carrierList=${carrierList}    rus_config_info=${rus_config_info}
    ${port_list}    Get PA Port For Cell    cell_id=${cell_id}    scf_name=${scf_name}
    ${pa_value}    Get PA Value For Cell    cell_id=${cell_id}    pa_call_default=${pa_call_default}    scf_name=${scf_name}
    ${port_number}    get length    ${port_list}
    ${pa_value}    pa_value_convert    pa_value=${pa_value}    port_list=${port_list}
    ${PA}    attenuator.setup_attenuator    attenuator=${attenuator}
    FOR    ${index}    IN RANGE    0    ${port_number}
        ${port}  Evaluate  int(${port_list[${index}]})
        attenuator.set_attenuation    port=${port}    value=${pa_value[${index}]}    attenuator_device=${PA}
    END

Init PA Value for All Ports
    [Arguments]    ${value}=${127}    ${scf_name}=${None}    ${attenuator_index}=${0}
    ${ports_all}    Create List
    ${nr_cells}    Get All Nr Cells
    FOR    ${cell_id}    IN    @{nr_cells}
        ${ports}    Get PA Port For Cell    cell_id=${cell_id}    scf_name=${scf_name}
        @{ports_all}    Evaluate    @{ports_all}+@{ports}
    END
    ${lte_cells}    Get All Lte Cells
    FOR    ${cell_id}    IN    @{lte_cells}
        ${ports}    Get PA Port For Cell    cell_id=${cell_id}    scf_name=${scf_name}
        @{ports_all}    Evaluate    @{ports_all}+@{ports}
    END
    ${ports_all}    remove duplicates    ${ports_all}
    ${PA}    attenuator.setup_attenuator    attenuator=${tl.attenuators[${attenuator_index}]}
    FOR    ${port}    IN    @{ports_all}
        attenuator.set_attenuation    port=${port}    value=${value}    attenuator_device=${PA}
    END

Get PA Value For Cell
    [Arguments]    ${cell_id}    ${pa_call_default}=${None}    ${scf_name}=${None}
    return from keyword if    ${pa_call_default}!=${None}      ${pa_call_default}
    ${Golden_SCF_NAME}    set variable    ${Golden_SCF_PATH.split("/")[-1]}
    ${scf_name}    run keyword if    '${scf_name}'=='${None}'    set variable    ${Golden_SCF_NAME}    ELSE    set variable    ${scf_name}
    ${testline_name}    Get Testline Name
    ${pa_call}    get_cell_pa_values    testline_name=${testline_name}    cell_id=${cell_id}    scf_name=${scf_name}
    [Return]    ${pa_call}

Get PA Port For Cell
    [Arguments]    ${cell_id}    ${scf_name}=${None}
    ${Golden_SCF_NAME}    set variable    ${Golden_SCF_PATH.split("/")[-1]}
    ${scf_name}    run keyword if    '${scf_name}'=='${None}'    set variable    ${Golden_SCF_NAME}    ELSE    set variable    ${scf_name}
    ${testline_name}    Get Testline Name
    ${pa_ports}    get_cell_pa_ports    testline_name=${testline_name}    cell_id=${cell_id}    scf_name=${scf_name}
    [Return]    ${pa_ports}

Set PA Port To Pointed Value For All RUs
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${value}=${127}
    ${ru_id_list}    Get All RU Index
    FOR    ${ru_id}  IN  @{ru_id_list}
        Set PA Port To Pointed Value For RU    ru_index=${ru_id}-1    gnb_index=${gnb_index}    du_index=${du_index}    value=${value}
    END

Set PA Port To Pointed Value For RU
    [Arguments]    ${ru_index}    ${gnb_index}=${0}    ${du_index}=${0}    ${value}=${127}
    ${port_list}    Create List
    ${attenuator}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].attenuation_ports[0].attenuator}
    ${attenuation_ports}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].attenuation_ports}
    FOR    ${attenuation_port}    IN    @{attenuation_ports}
        Append To List   ${port_list}      ${attenuation_port.port_no}
    END
    ${PA}    attenuator.setup_attenuator    attenuator=${attenuator}
    FOR    ${port}    IN    @{port_list}
        ${port}  Evaluate  int(${port})
        attenuator.set_attenuation    port=${port}    value=${value}    attenuator_device=${PA}
    END

Unexpect History Alarm Should Not Exist With Event Time
    [Documentation]   Auther: zhihao.shi@nokia-sbell.com
    ...               Description: check unexpect history alarm exist or not ,if yes, save it to file
    ...               :param allowed_faults<list>: list contains dictionary, dict keys can be only faultId or faultId with source
    ...                    eg. [{"faultId":7300}]
    ...                        [{"faultId":61524,"source":"/SMOD_R-1"}]
    ...                        [{"faultId":61524,"source":"CABINET-1/SMOD_R-1"},{"faultId":7300}]
    ...               :param log_path<str>: saved alarm to path , default is testcase log path.
    ...               :param connection<str>：coam admin connection , default is GNB_OAM
    [Arguments]   ${case_start_timestamp}
    ...           ${allowed_faults}
    ...           ${file_path}=${TS_CASE_LOG_PATH}
    ...           ${connection}=GNB_OAM
    ${history_alarms_list}    coam.get_historic_alarms    connection=${connection}    timeout=100    load_history=${True}
    ${history_alarms_num}     Get Length    ${history_alarms_list}
    ${unexpect_alarms}    Create List
    FOR  ${alarm}  IN  @{history_alarms_list}
       Exit For Loop If   ${history_alarms_num}==${0}
       ${status}   Run Keyword And Return Status   Check Alarm Is Allowed
       ...                                         allowed_alarm_list=${allowed_faults}
       ...                                         check_alarm=${alarm}
       log to console    ${alarm['eventTime']}
       Run keyword if     ${status}==${False} and ${alarm['eventTime']}>${case_start_timestamp}    run keywords
       ...    Append To List    ${unexpect_alarms}   ${alarm}    AND
       ...    Log to console    Unexpect History Alarm : ${alarm['faultId']}
    END
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${unexpect_alarm_file}    Set variable    ${file_path}/unexpect_history_alarms_${timestamp}.txt
    ${alarm_num}   Get Length   ${unexpect_alarms}
    Run Keyword If  ${alarm_num}!=${0}    Run   command=echo "unexpect alarm number:${alarm_num}">${unexpect_alarm_file}
    FOR  ${alarm}  IN  @{unexpect_alarms}
        Exit For Loop If  ${alarm_num}==${0}
        run    command=echo "${alarm}">>${unexpect_alarm_file}
    END
    Run Keyword If   ${alarm_num}!=${0}   fail   ${alarm_num} alarms are not allowed, details in log: ${unexpect_alarm_file}

Get lnbtsID via SCF
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}    connection=GNB_OAM
    ${lncell}    Run    cat ${scf_path} | grep -oE "MRBTS-[0-9]+/LNBTS-[0-9]+" | head -n 1
    ${lnbtsID}    Run    echo ${lncell}|grep -oE "LNBTS-[0-9]+"| awk -F '-' '{print $2}'
    set suite variable    ${lnbtsID}
    [Return]    ${lnbtsID}

Unblock NR Cells By Coam
    [Arguments]    ${mrbtsID}    ${nrbtsID}    ${cell_list}    ${connection}=GNB_OAM
    FOR    ${cell_id}    IN    @{cell_list}
        coam.unblock_cell    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}    connection=${connection}    timeout=60s
    END


Unblock LTE Cells By Coam
    [Arguments]    ${mrbtsID}    ${lnBtsId}    ${cell_list}    ${connection}=GNB_OAM
    FOR    ${cell_id}    IN    @{cell_list}
        coam.unblock_cell    dist_name=MRBTS-${mrbtsID}/LNBTS-${lnBtsId}/LNCEL-${cell_id}    connection=${connection}    timeout=60s
    END

Unlock RUs By Coam
    [Arguments]      ${mrbtsID}    ${ru_list}    ${connection}=GNB_OAM
    FOR    ${ru_id}    IN    @{ru_list}
        coam.unlock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_id}    connection=${connection}    timeout=60s
    END

modify fault snapshot triggers
    [Arguments]    ${operation}=add    ${modify_trigger}=None
    ${MO_A}    coam.get_managed_objects    class_name=TRBLCADM_A    connection=GNB_OAM
    ${values}    Set variable    ${MO_A[0]['parameters']['faultSnapshotTriggers']}
	${values}    generate_new_fault_trigger    original_trigger=${values}    operation=${operation}    modify_trigger=${modify_trigger}
    ${faultSnapshotTriggers}      create dictionary
    ...    operation    update
    ...    parameterName    faultSnapshotTriggers
    ...    value    ${values}
    ${parameters}    Create List    ${faultSnapshotTriggers}
    ${faultSnapshotTriggers}      create dictionary
    ...    distName    MRBTS-${mrbtsID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    parameters    ${parameters}
    ...    operation    update
    ${triggers_list}    Create List    ${faultSnapshotTriggers}
    ${triggers}     convert to string  ${triggers_list}
    ${triggers}    Replace String    ${triggers}    '    "
    ${triggers}    Replace String    ${triggers}    None    ""
    log to console    ${triggers}
    coam.perform_delta_recommissioning    delta_file=${triggers}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM

Get btsName by scf
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
	${btsName}    selenium_coam.get_bts_name
    Set Test Variable    ${btsName}
    [Teardown]    Selenium Logout And Close Browser

get fault triggered snapshot file name
    Get btsName by scf
    ${snapshot_filename_start}    set variable    Snapshot_MRBTS-${mrbtsID}_${btsName}_${Active_SW_version}
    [Return]    ${snapshot_filename_start}

delete older fault triggered snapshot file with same software release
    ${snapshot_filename_start}    get fault triggered snapshot file name
    OperatingSystem.Run    command=sudo rm -rf /home/coam/${snapshot_filename_start}*

check whether new fault triggered snapshot file exists
    sleep    30s
    ${snapshot_filename_start}    get fault triggered snapshot file name
    ${number}    OperatingSystem.Run    command=sudo ls -l /home/coam |grep ${snapshot_filename_start} | wc -l
    run keyword if    ${number}==0    Run Keyword And Return    log to console    no fault triggered snapshot file find under /home/coam
    ${file_names}    OperatingSystem.Run    command=sudo ls -l /home/coam |grep ${snapshot_filename_start} |awk '{print $9}'
    ${file_names}    Split String    ${file_names}    \n
    FOR   ${file_name}    IN    @{file_names}
        OperatingSystem.Run    command=sudo zip -r /home/coam/${file_name}.zip /home/coam/${file_name}
        sleep    10s
        OperatingSystem.Run    command=sudo mv /home/coam/${file_name}.zip /${TS_CASE_LOG_PATH}/${file_name}.zip
        sleep    10s
    END
    Run keywords    log to console    unexpect fault triggered snapshot capture    AND    Fail

SG08 Common Test Setup
    [Arguments]    ${gnb_index}=0    ${fail_with_alarms}=${False}    ${enable_watchdog}=${True}
    ...            ${is_ru_log_collecting_enable}=${False}
    log to console    ${is_ru_log_collecting_enable}
    robot_common_operations.Common Case Setup
    log to console    \n***SISO Coam Test Setup***
    log to console    gNB CU type:${gNb_CuType}
    log to console    Active_SW_version(gNB):${Active_SW_version}
    run keyword if    '${gNb_CuType}'=='NSA' or '${gNb_CuType}'=='SA+NSA'
    ...    Run Keyword And Ignore Error    Log to console    Active_SW_version(eNB):${enb_active_version}
    Generate test case log path
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    log to console  case log path:${TS_CASE_LOG_PATH}
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    ${ru_info}    COAM get all ru detail info    connection=${connection}
    ${ru_value}    get dictionary values    ${ru_info}
    ${ru_info}    Set variable    ${ru_value}[0]
    run keyword and ignore error  should contain  ${TEST_NAME}  ${ru_info}[productName]
    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status    connection=${connection}
    ${cell_status}    Run Keyword And Return Status    Check all cells info should be onair    connection=${connection}
    ${Status}    ${key}   run keyword and ignore error   get specified scf
    ${SCF_Path}    set variable if      '${Status}'=='PASS'    ${key}[0]    ${Golden_SCF_Path}
    ${SCF_Status}    set variable if      '${Status}'=='PASS'    ${key}[1]    ${False}
    Set Test Variable    ${Case_SCF_Path}    ${SCF_Path}
    run keyword if    ${enable_watchdog}    AlarmWatchdog.init_watchdog
    ...    interval=5 sec
    ...    bts_config=${tl.gnbs[${gnb_index}]}
    ...    fail_with_alarms=${fail_with_alarms}
    Run Keyword If    ${ru_status}==${False} or ${cell_status}==${False} or ${SCF_Status}==${True} and ${gnb_index}==0
    ...    Commissioning SCF And Check On Air      scf_path=${SCF_Path}
    Start Btslog With Path Check
    Run Keyword And Ignore Error    Config load RMOD Serial log by Common KW
    Run Keyword And Ignore Error    selenium_coam.close_browser
    ${ue_reboot_dict}    create dictionary
    set test variable    ${ue_reboot_dict}
    delete older fault triggered snapshot file with same software release

SG08 Common Test Teardown
    [Arguments]    ${gnb_index}=0    ${is_case_teardown}=${True}    ${is_check_historyalarm}=${False}
    ...    ${perform_case_scf}=${False}    ${enable_watchdog}=${True}
    log to console    \n***SISO Coam Test Teardown***
    check whether new fault triggered snapshot file exists
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    ${ru_status}   run keyword and ignore error   COAM Check GNB RU status    connection=${connection}
    log to console  RU status: ${ru_status}
    ${cell_status}    Run Keyword And Return Status    Check all cells info should be onair    connection=${connection}
    should be true    ${cell_status}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...    connection=${connection}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=${connection}
    run keyword if    ${is_check_historyalarm}    should be true    ${history_alarm_status}
    Stop Btslog With Path Check    target_dir=${SAVE LOG DIRECTORY}
    Run Keyword And Ignore Error    Get RMOD Serial log download by Common KW
    ...    rmod_serial_config_load=${RMOD_SERIAL_INFO}    target_dir=${SAVE LOG DIRECTORY}
    ${test_fail_flag}    run keyword if    ${is_case_teardown}    run keyword if test failed
    ...    set variable    ${True}
    ${test_fail_flag}    set variable if    ${test_fail_flag}    ${True}    ${False}
    run keyword if    ${enable_watchdog}    AlarmWatchdog.teardown_watchdog
    run keyword if    ${save_snapshot} and ${test_fail_flag}    run keywords
    ...    Capture RU logs    target_dir=${SAVE LOG DIRECTORY}    connection=${connection}     gnb_index=${gnb_index}    AND
    ...    Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=${connection}    AND
    ...    Save Coam im snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=${connection}
    ...    ELSE
    ...    log to console    don't collect snapshot in test teardown!!!
    robot_common_operations.Common Case Teardown
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    Run Keyword If    ${perform_case_scf} and ${gnb_index}==0
    ...    Commissioning SCF And Check On Air      scf_path=${Case_SCF_Path}
    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    run keyword and ignore error    csn.Disconnect    connection=ASIK Master
    CI_interface.Common Case Teardown
    log to console   \nget ue reboot dict:${ue_reboot_dict}

make_call_ul_only
    [Documentation]    use pointed ue to make call
    ...  :author  linjiangjing
    ...  :param  tput_info: dict, should contain dl_tp and ul_tp. E.G
    ...          {
    ...              'ul_tp': '50M',
    ...          }
    [Arguments]    ${tput_info}    ${ue_index}=0    ${protocol}=udp    ${gnb_index}=0    ${du_index}=0
    ...    ${alias}=ASIK MASTER    ${duration_call}=${3600}    ${connection}=GNB_OAM    ${process_num_ul}=1    ${ui_version}=default
    ...    ${pci}=${0}    ${buffer_size}=1400B
    log to console    ${alias}
    log to console    ${connection}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    run keyword and ignore error    Wait Until Keyword Succeeds    8x     20s    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ...    ui_version=${ui_version}
    run keyword if    '${ue_type}'=='huawei_sigspark'   prepare_aasyslog_process    gnb_index=${gnb_index}    du_index=${du_index}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=5G_${gNb_CuType}    pci=${pci}    timeout=900
    ${status}    run keyword and return status     Get Length    ${ue_index_list}
    run keyword if    ${status}==False    create empty list
    Run Keyword If   ${ue_index} not in ${ue_index_list}    append to list    ${ue_index_list}    ${ue_index}
    ${iperf_type}  set variable if  '${ue_type}'=='huawei'    via_app    via_command
    ${ul_tp}    set variable    ${tput_info['ul_tp']}
    ${tput_spark}    run keyword if    '${ue_type}'=='huawei_sigspark'    generate_tput_for_spark_ue    dl_tp=${dl_tp}    ul_tp=${ul_tp}
    ${ul_tp}    run keyword if    '${ue_type}'=='huawei_sigspark'    set variable    ${tput_spark[1]}    ELSE    set variable   ${ul_tp}
    log to console    start ul traffic...
    Wait Until Keyword Succeeds    5x     20s    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
    ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    iperf_type=${iperf_type}
    ...    data_amount=2M    ue_mode=${gNb_CuType}    process_num=${process_num_ul}    buffer_size=${buffer_size}
