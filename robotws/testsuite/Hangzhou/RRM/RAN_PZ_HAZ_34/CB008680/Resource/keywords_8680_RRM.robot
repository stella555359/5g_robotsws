*** Settings ***
Documentation     author: Yang Liqin
...               contact: liqin.yang@nokia-sbell.com
...               squad group: MMW_SG_05

Resource          ${CURDIR}/keywords_8680.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG1/L3Call.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/admin_sbts.robot
Library    taf.hw.rf_attenuator    WITH NAME    attenuator
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME
...    throughput_computation

*** Variables ***
${ultp0}          0.05
${dltp0}          0.05
${expected_ul_tp_cband_60M}    93M
${expected_dl_tp_cband_60M}    642M
${expected_ul_tp_cband_20M}    26M
${expected_dl_tp_cband_20M}    194M
${expected_ul_tp_cband_80M}    130M
${expected_dl_tp_cband_80M}    1188M
${expected_ul_tp_dband_30M}    45M
${expected_dl_tp_dband_30M}    297M
${expected_ul_tp_dband_20M}    26M
${expected_dl_tp_dband_20M}    255M
${expected_ul_tp_cband_40M}    58M
${expected_dl_tp_cband_40M}    559M
${expected_ul_tp_dband_40M}    58M
${expected_dl_tp_dband_40M}    556M

${expected_ul_256qam_cband_20M}    26M
${expected_dl_256qam_cband_20M}    257M
${expected_ul_256qam_cband_60M}    124M
${expected_dl_256qam_cband_60M}    861M
${expected_ul_256qam_dband_30M}    45M
${expected_dl_256qam_dband_30M}    393M
${expected_ul_256qam_cband_80M}    173M
${expected_dl_256qam_cband_80M}    1188M
${expected_ul_256qam_dband_40M}    77M
${expected_dl_256qam_dband_40M}    556M
${expected_ul_256qam_cband_40M}    79M
${expected_dl_256qam_cband_40M}    559M
${expected_ul_256qam_dband_20M}    34M
${expected_dl_256qam_dband_20M}    255M
${expected_ul_256qam_cband_100M}    165M
${expected_dl_256qam_cband_100M}    1503M

${ENB_PATH}  MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].global_bts_id}
${lnrel_dist}  ${ENB_PATH}/LNCEL-1
${lnrel_para}  defaultLnRelGnbCellId
${lnrel_para1}    administrativeState
${delta_64QAM_cband_20M}               ${CURDIR}/SCFs/delta_dl_64QAM_cband_20M.json
${delta_256QAM_cband_20M}               ${CURDIR}/SCFs/delta_256QAM_cband_20M.json
${delta_64QAM_dband_30M}               ${CURDIR}/SCFs/delta_64QAM_dband_30M.json
${delta_256QAM_dband_30M}               ${CURDIR}/SCFs/delta_256QAM_dband_30M.json
${delta_64QAM_cband_80M}               ${CURDIR}/SCFs/delta_64QAM_cband_80M.json
${delta_256QAM_cband_80M}               ${CURDIR}/SCFs/delta_256QAM_cband_80M.json
${delta_256QAM_dband_40M}               ${CURDIR}/SCFs/delta_tdLte_256QAM_dband_40M.json
${delta_64QAM_dband_40M}               ${CURDIR}/SCFs/delta_tdLte_64QAM_dband_40M.json
${delta_64QAM_cband_60M}  ${CURDIR}/SCFs/delta_tdLte_64QAM_cband_60M.json
${delta_64QAM_dband_20M}               ${CURDIR}/SCFs/delta_64QAM_dband_20M.json
${delta_256QAM_dband_20M}               ${CURDIR}/SCFs/delta_256QAM_dband_20M.json
${delta_256QAM_cband_40M}               ${CURDIR}/SCFs/delta_tdLte_256QAM_cband_40M.json
${delta_64QAM_cband_40M}               ${CURDIR}/SCFs/delta_tdLte_64QAM_cband_40M.json
${delta_256QAM_cband_100M}               ${CURDIR}/SCFs/delta_tdLte_256QAM_cband_100M.json
${delta_cband_100M_9755}                 ${CURDIR}/SCFs/delta_tdLte_cband_100M_9755.json
${delta_cband_60M_9755}                  ${CURDIR}/SCFs/delta_tdLte_cband_60M_9755.json
${dlMimoMode_16D}                        8x4 Closed Loop Spatial Multiplexing
${dlMimoMode_8D}                         4x4 or 4x2 Closed Loop Spatial Multiplexing
${WEBUI_COAM}                            https://${WEBUI_ADDR}
${SCF_PATH}       ${CURDIR}/SCFs

*** Keywords ***
Check alarm
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    ${exist_fault}    coam_gnb_classical.COAM Get active alarms
    Set test variable    ${exist_fault}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${exist_fault}    file_path=${TS_CASE_LOG_PATH}
    [Teardown]  Run Keyword And Ignore Error  COAM Teardown gnb connections

Peak throughput with different Modulation on different bandwidth
    [Arguments]  ${file}=${delta_64QAM_cband_20M}  ${direction}=dl  ${attach_mode}=5G_SA
    ...  ${cell_id}=0  ${physCellId}=${physical_${cell_id}}
    ...  ${protocol}=udp  ${duration_time}=5m
    Run Keyword If  ${release}  Add New PARAMS to json  ${file}
    scf.Modify json file before testing  json_file=${file}
    Modify dlMimoMode for 9755  ${file}
    Modify numberOfRxBeamforming for 10889  ${file}
    scf.Activate or Deactivate feature    delta_file=${file}  timeout=600
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    15min    15s    CI_commssion.Verify all cells should be Online
    ${nrcell_id}  Set Variable If  ${cell_id}==0  1  2
    ${cell_idx}  Set Variable If  ${cell_id}==0  ${2}  ${1}
    ${cell_list}    Get All Cell Id    ru_index=${1}
    FOR     ${cell}    IN     @{cell_list}
        run keyword if  ${cell}!=${nrcell_id}    Barred nr cell  cell_idx=${cell}
    END
    Get full SCF
    Get The NR Cell ID  cell_idx=${nrcell_id}
    Run Keyword If  '${attach_mode}'=='5G_NSA'  Run Keywords  Convert BTS Mode To NSA
    ...  AND  Run keyword and ignore error  Connect and Modify the parameter on enblte  dist_name=${lnrel_dist}  parameter=${lnrel_para}
    ...  value=${nrcell_id}
	...  AND  AlarmWatchdog.add_allow_alarms    fault_id=7107
    ...  ELSE  Connect and Modify the parameter on enblte  dist_name=${lnrel_dist}  parameter=${lnrel_para1}   value=locked
    ${dl_throughput}  ${ul_throughput}  Get Theoretical Throughput  cellid=${nrcell_id}  attach_mode=${attach_mode}
    Wait Until Keyword Succeeds    3x    10s    UE Attach and Check peak traffic  attach_mode=${attach_mode}
    ...    cell_id=${cell_id}
    ...    physCellId=${physCellId}  ul_throughput=${ul_throughput}  duration_time=${duration_time}
    ...  dl_throughput=${dl_throughput}  direction=${direction}  protocol=${protocol}
    ${cell_idx}  Set Variable If  ${cell_id}==0  ${2}  ${1}
    [Teardown]  Run Keywords  Run keyword and ignore error  Unbarred Other nr cells  cell_id=${nrcell_id}  AND
    ...  Run keyword and ignore error  Connect and Modify the parameter on enblte
    ...  dist_name=${lnrel_dist}  parameter=${lnrel_para1}   value=unlocked   AND  Run keyword and ignore error  Convert BTS Mode To SA
    ...  AND  Run Keyword If  ${release}  Delete New PARAMS from json  ${file}
    ...  AND  scf.Modify json file after testing  json_file=${file}  AND  run keyword and ignore error    COAM Teardown gnb connections

Get expected ul TP
  [Arguments]  ${tp}  ${attach_mode}==5G_NSA
  ${expected_TP_tmp}    String.Replace String Using Regexp    ${tp}  M  ${EMPTY}
  ${ul_throughput_tmp}  Run Keyword If  '${attach_mode}'=='5G_NSA'  Evaluate  0.5*${expected_TP_tmp}
  ...  ELSE  Evaluate  ${expected_TP_tmp}
  ${ul_throughput}  convert to integer  ${ul_throughput_tmp}
  ${ul_throughput}  Catenate  SEPARATOR=  ${ul_throughput}  M
  [Return]  ${ul_throughput}

UE Attach and Check peak traffic
    [Arguments]    ${attach_mode}=5G_NSA
    ...    ${cell_id}=0
    ...    ${physCellId}=${physical_${cell_id}}  ${ul_throughput}=${expected_ul_tp_cband_60M}  ${10M_true}=${false}
    ...    ${dl_throughput}=${expected_dl_tp_cband_60M}  ${direction}=both  ${protocol}=udp  ${duration_time}=5m
    ${all_tp}  UE Attach and Start peak traffic  attach_mode=${attach_mode}  duration_time=${duration_time}
    ...  ul_throughput=${ul_throughput}  dl_throughput=${dl_throughput}  direction=${direction}  cell_id=${cell_id}
    ...  protocol=${protocol}  physCellId=${physCellId}  10M_true=${10M_true}
    ${ul_average}  ${dl_average}  Get UL and DL Average Value  all_tp=${all_tp}
    ${ul_min}  ${dl_min}  Get UL and DL Average Value  all_tp=${all_tp}  flag=minimum
    Run Keyword And Continue On Failure  Check TP Rate    actual_TP=${ul_average}  direction=ul
    Run Keyword And Continue On Failure  Check TP Rate    actual_TP=${dl_average}  direction=dl
    Run Keyword And Continue On Failure  Check TP Rate    actual_TP=${ul_min}  direction=ul
    ...  expected_all_TP_ratio=0.8  flag=minimum
    Run Keyword And Continue On Failure  Check TP Rate    actual_TP=${dl_min}  direction=dl
    ...  expected_all_TP_ratio=0.8  flag=minimum

Get full SCF
    taf_coam.COAM Login
    taf_coam.COAM Backup Full SCF  local_dir=${TS_CASE_LOG_PATH}
    [Teardown]   Run Keyword And Ignore Error   COAM Logout

Barred nr cell
    [Arguments]  ${cell_idx}=${2}
    Log To Console    Set cellBarred to Barred for cell-${cell_idx}
    scf.Activate Parameter Value
    ...  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_idx}    p_name=cellBarred  new_value=barred

Unbarred nr cell
    [Arguments]  ${cell_idx}=${2}
    Log To Console    Set cellBarred to notBarred for cell-${cell_idx}
    scf.Activate Parameter Value
    ...  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_idx}    p_name=cellBarred  new_value=notBarred

UE Attach and Start peak traffic
    [Arguments]    ${duration}=1200    ${attach_mode}=5G_NSA
    ...    ${cell_id}=0  ${ue_index}=${0}    ${duration_time}=5m
    ...    ${actCarrierAggregation}=${False}    ${physCellId}=${physical_${cell_id}}  ${ul_throughput}=${expected_ul_tp_cband_60M}
    ...  ${dl_throughput}=${expected_dl_tp_cband_60M}  ${direction}=both  ${protocol}=udp  ${10M_true}=${false}
    # ${status}  Run Keyword And Return Status  Should Contain  ${stream}  SBTS25R2
    # ${dl_throughput}   Run Keyword If  ${dl_throughput}>1500 and ${status}  Evaluate   ${dl_throughput}-17
	# ...  ELSE    set variable   ${dl_throughput}
    ${dl_tput}   Run Keyword If  '${10M_true}'=='true'  Evaluate   int(${dl_throughput})
	...  ELSE    Evaluate   int(${dl_throughput})+1
    ${ul_tput}   Evaluate   int(${ul_throughput})+1
    log to console  UE Attach and Start traffic
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}    ue_index=${ue_index}
    Reboot UE If no UE IP
    ${iperf_type}  Set Variable If  '${direction}'=='ul' and '${ue_type}'!='huawei'  via_command  via_app
    ${seg_size}  Set Variable If  '${protocol}'!='udp'  1350  1180
    ${window}  Set Variable If  '${protocol}'!='udp'  16M  2M
    Wait until keyword succeeds    2X  150s  Verify attach by adb    physCellId=${physCellId}    attach_mode=${attach_mode}
    ...    ue_index=${ue_index}  5G_check=True
    sleep  2
    Connect to gnb coam via ssl
    ${list_of_cell_ids}  Get List of NR Cell ID
    ${cell_list}  create list
    Run keyword If  ${actCarrierAggregation} == ${False}  Run keywords
    ...  Append To List  ${cell_list}  ${cell_id_nr}  AND
    ...  set suite variable  ${list_of_cell_ids}  ${cell_list}
    Run Keyword If  '${attach_mode}'=='5G_SA'  Get nrCellIdentity for SA UE  nrCId=${list_of_cell_ids}[0]
    Run Keyword If  '${direction}'=='both'  Run Keywords  power_ue.Start traffic     ue_type=${ue_type}     direction=dl
    ...    throughput=${dl_tput}M     duration=${duration}
    ...    ue_index=${ue_index}  protocol=${protocol}  seg_size=${seg_size}  window=${window}
    ...    AND  sleep  2
    ...    AND  power_ue.Start traffic  ue_type=${ue_type}  direction=ul  throughput=${ul_tput}M
    ...    duration=${duration}  ue_index=${ue_index}  iperf_type=${iperf_type}  protocol=${protocol}  seg_size=${seg_size}  window=${window}
    ...    ELSE  power_ue.Start traffic     ue_type=${ue_type}  direction=${direction}
    ...    throughput=${${direction}_tput}M     duration=${duration}
    ...    ue_index=${ue_index}  iperf_type=${iperf_type}  protocol=${protocol}  seg_size=${seg_size}  window=${window}

    ${log}    power_ue.Collect Tput    ue_type=${ue_type}  duration=${duration_time}  filter=L2Lo  ue_index=${ue_index}
    ...  ignore_time=1min  check_source=aasyslog
    ${direction1}  String.Convert To Upper Case  ${direction}
    Set Test Variable  ${expected_dl}    ${dl_throughput}
    Set Test Variable  ${expected_ul}    ${ul_throughput}
    ${all_tp}  Run Keyword If  '${direction}'=='both'
    ...        power_ue.Check Bi Tput  ue_type=${ue_type}    log=${log}
    ...                                cells=${list_of_cell_ids}  ultarget_throughput=${expected_ul}  dltarget_throughput=${expected_dl}
    ...                                actCarrierAggregation=${actCarrierAggregation}    min_percent=0.8  target_avg_percent=0.98
    ...        ELSE    power_ue.Check Tput    ue_type=${ue_type}    direction=${direction1}    log=${log}
    ...        cells=${list_of_cell_ids}    target_throughput=1    actCarrierAggregation=${actCarrierAggregation}  min_percent=0
    # Connect To BTS Csn Via Lmp
    # ${ul_tp}    Calculate UL Throughoutput Re    alias=ASIK Master    sample=10    start_offset=3
    # ...    sleep_time=5    cellid=${list_of_cell_ids}    log_type=Aasyslog
    # ${dl_tp}    Calculate DL Throughoutput Re    alias=ASIK Master    sample=10    start_offset=3
    # ...    sleep_time=5    cellid=${list_of_cell_ids}    log_type=Aasyslog
    [Return]  ${all_tp}
    [Teardown]  Run Keywords  Run Keyword And Ignore Error  COAM Teardown gnb connections
    # ...  AND  Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    ...  AND  Run Keyword And Ignore Error  UE Dettach and Stop traffic  ue_index=${0}  protocol=${protocol}  direction=${direction}

Check TP Rate
    [Arguments]  ${actual_TP}  ${direction}=dl  ${expected_peak_TP}=${expected_${direction}}  ${expected_all_TP_ratio}=0.98  ${flag}=average
    ${TP_change}    Evaluate  ${actual_TP}/${expected_peak_TP}
  log to console  The actual ${direction} ${flag} TP is ${actual_TP}M,expected_TP is ${expected_peak_TP}M
  log to console  The actual ${direction} ${flag} TP percent is ${TP_change}
    Should Be True    ${TP_change}>${expected_all_TP_ratio}

Modify attenuator value by port
    [arguments]    ${port}   ${value}  ${vender}=HBTE
    attenuator.set_attenuation
    ...      port=${tl.attenuator.attenuator_ports[${port}]}
    ...      value=${value}
    ...      attenuator_device=${vender}
    ${value1}  Get value from Attenuator  port=${port}


Get value from Attenuator
    [arguments]    ${port}    ${vender}=HBTE
    ${value}    attenuator.read_attenuation
    ...      port=${tl.attenuator.attenuator_ports[${port}]}    attenuator_device=${vender}
    [Return]      ${value}

Get wait value minutes
    [Arguments]    ${interval}
    Connect to Common Unit Master
    ${interval_seconds}    Get Interval Seconds    ${interval}
    ${interval_minutes}    evaluate    ${interval_seconds}/60
    ${origin_time}    Get time from GNB
    ${origin_time}    robot.libraries.DateTime.convert_date    ${origin_time}   datetime
    ${minutes}    set variable    ${origin_time.minute}
    ${wait_time}    evaluate    ${interval_minutes}-${minutes}%${interval_minutes}
    [Return]    ${wait_time}

Wait for New Interval BTS counters Generate
    [Arguments]  ${interval}
    log to console  \nWait for New Interval BTS counters Generate
    ${wait_time}    Get wait value minutes    ${interval}
    sleep    ${wait_time}min
    sleep    30

Add New PARAMS to json
    [Arguments]  ${file}=${delta_64QAM_cband_20M}
    OperatingSystem.Run    sed -i 's/"cSRS"/"comb": "comb2",\\\n\\t\\t\\t\\"cSRS"/' ${file}
	OperatingSystem.Run
    ...  sed -i 's/"srsTypeAllocForDlBm"/"srsPowerThresholdForUlBm": "-1320",\\\n\\t\\t\\t\\"srsTypeAllocForDlBm"/' ${file}
    OperatingSystem.Run    sed -i 's/"bwpDN"/"actPdcchCceFragmentControl": "false",\\\n\\t\\t\\t\\"bwpDN"/' ${file}
    OperatingSystem.Run    sed -i 's/"cellBwpId"/"pdcchResourcePreference": "peakRate",\\\n\\t\\t\\t\\"cellBwpId"/' ${file}
    OperatingSystem.Run    sed -i 's/"bwpDN"/"actUpperThrAckNackFiltering": "false",\\\n\\t\\t\\t\\"bwpDN"/' ${file}
    OperatingSystem.Run    sed -i 's/"cellBwpId"/"actUpperThrAckNackHrFiltering": "false",\\\n\\t\\t\\t\\"cellBwpId"/' ${file}
    ${result}    run keyword and return status    should contain any    ${stream}    24R3    25R1    25R2
    run keyword if  not ${result}  run keywords
    ...  OperatingSystem.Run    sed -i 's/"bSRS"/"srsDlBeamFallbackOption": "fallback once",\\\n\\t\\t\\t\\"bSRS"/' ${file}
	...  AND  OperatingSystem.Run    sed -i 's/"cSRS"/"srsUlBeamFallbackOption": "fallback once",\\\n\\t\\t\\t\\"cSRS"/' ${file}


Delete New PARAMS from json
    [Arguments]  ${file}=${delta_64QAM_cband_20M}
    Run Keyword And Ignore Error  OperatingSystem.Run  sed -i '/"comb": "comb2",/d' ${file}
    Run Keyword And Ignore Error  OperatingSystem.Run  sed -i '/"srsPowerThresholdForUlBm": "-1320",/d' ${file}
    Run Keyword And Ignore Error  OperatingSystem.Run  sed -i '/"actPdcchCceFragmentControl": "false",/d' ${file}
    Run Keyword And Ignore Error  OperatingSystem.Run  sed -i '/"pdcchResourcePreference": "peakRate",/d' ${file}
    Run Keyword And Ignore Error  OperatingSystem.Run  sed -i '/"actUpperThrAckNackFiltering": "false",/d' ${file}
    Run Keyword And Ignore Error  OperatingSystem.Run  sed -i '/"actUpperThrAckNackHrFiltering": "false",/d' ${file}

Select json file
    [Arguments]  ${file}=${delta_64QAM_cband_20M}  ${file_9755}=${delta_cband_100M_9755}
    ${json_file}  Set Variable If
    ...  'SBTS23R2' in '${Active_SW_version}' or 'SBTS23R3' in '${Active_SW_version}' or 'SBTS23R4' in '${Active_SW_version}'
    ...  ${file}  ${file_9755}
  [Return]  ${json_file}

Modify dlMimoMode for 9755
    [Arguments]  ${file}=${delta_64QAM_cband_20M}
    Run Keyword if    'SBTS23R2' in '${Active_SW_version}' or 'SBTS23R3' in '${Active_SW_version}' or 'SBTS23R4' in '${Active_SW_version}'
    ...    Log To Console  No need modify dlMimoMode    ELSE    Run Keyword And Ignore Error
    ...    scf.Modify json file  json_file=${file}
    ...    old_string=${dlMimoMode_8D}  new_string=${dlMimoMode_16D}

Get Theoretical Throughput
    [Arguments]     ${cellid}=1  ${attach_mode}=5G_SA  ${SCF}=${TS_CASE_LOG_PATH}/full_commission.xml
    ...    &{modified_parameters}
    #https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/merge_requests/186981/diffs#note_5283232
    Connect to gnb coam via ssl
    ${cur_scf_file}    coam_gnb_classical.COAM Download scf from cluster
    ...    scf_dir_path=${TS_CASE_LOG_PATH}    connection=GNB_OAM
    log to console    ${SCF} not used and will use ${cur_scf_file} for nrdim
    ${ue_ul_layer}  Set Variable If  '${attach_mode}'=='5G_NSA'  1  2
    ${ue_ul_layer}   convert to integer    ${ue_ul_layer}
    ${theoretical_dl}    ${theoretical_ul}    throughput_computation.get_theoretical_throughput    scf_path=${cur_scf_file}
    ...        cell_id=${cellid}    ue_dl_layer=4    ue_ul_layer=${ue_ul_layer}    mod_params=${modified_parameters}
    [Return]  ${theoretical_dl}    ${theoretical_ul}

Modify numberOfRxBeamforming for 10889
    [Arguments]  ${file}=${delta_cband_100M_9755}
    Run Keyword if    'SBTS24R1' in '${Active_SW_version}' or '${MRBTS_ID}'=='1914' or '${MRBTS_ID}'=='2008'
    ...    Log To Console  No need modify numberOfRxBeamforming    ELSE    Run Keyword And Ignore Error
    ...    scf.Modify json file  json_file=${file}    old_string=4Rx    new_string=8Rx

Get The NR Cell ID
    [Arguments]    ${cell_idx}=${1}
    selenium login and disable screen lock
    ${info_cell}    selenium_coam.get_cell_info    cell_idx=${cell_idx}
    set test variable    ${cell_id_nr}    ${info_cell['NR cell ID']}
    [teardown]    Run Keyword And Ignore Error    selenium logout and close browser

Unbarred Other NR Cells
    [Arguments]  ${cell_id}=1  ${ru_index}=1
    Connect to gnb coam via ssl
    ${cell_list}    Get All Cell Id    ru_index=${ru_index}
    FOR     ${cell}    IN     @{cell_list}
        run keyword if  ${cell}!=${cell_id}    Unbarred nr cell  cell_idx=${cell}
    END

scf commission and wait for on-air RRM
    ${var_status}    ${ci_var_dict}    run keyword and ignore error    CI_commssion._Set Variables For Test
    ...    gnb_index=${0}   du_index=${0}    common_unit_index=${0}

    run keyword if      '${ci_var_dict}[testline]'=='7_5_UTE5G402T1913'
    ...    scf commission New  scf_name=SCF_SBTS00_1913.xml
    ...    ELSE IF   '${ci_var_dict}[testline]'=='7_5_UTE5G402T1914'
    ...    scf commission New  scf_name=SCF_SBTS24R1_1914.xml
    ...    ELSE IF   '${ci_var_dict}[testline]'=='7_5_UTE5G402T2008'
    ...    scf commission New  scf_name=SCF_SBTS24R3_2008.xml



scf commission New
    [Arguments]    ${scf_name}
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${SCF_PATH}/${scf_name}    timeout=${600}    is_pdl_checking_needed=${False}
    sleep    3min
    Wait Until Keyword Succeeds    15min    20s    COAM Check GNB cell on air
    COAM Teardown gnb connections

