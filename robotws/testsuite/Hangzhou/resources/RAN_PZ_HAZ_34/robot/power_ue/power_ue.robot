*** Settings ***
Documentation    UE common keyword for normal L3 call, support to control Multi UE also.
...              Please do not modify the file without notification to author
...              Author: Civen Chen
...              Contact: civen.chen@nokia-sbell.com


# DEPRECATED: Below UEs are legacy without using taf.ul.power_ue
Resource    ./UEs/legacy/huawei.robot
Resource    ./UEs/legacy/qct_dx50.robot
Resource    ./UEs/legacy/qct_vran20.robot
Resource    ./UEs/legacy/samsung.robot
Resource    ./UEs/legacy/huawei_sigspark.robot
Resource    ./UEs/legacy/lg_v50.robot
Resource    ./UEs/legacy/mtk.robot
Resource    ./UEs/legacy/inseego.robot
Resource    ./UEs/legacy/xiaomi.robot
Resource    ./UEs/legacy/askey_sigspark.robot
Resource    ./UEs/legacy/askey.robot
Resource    ./UEs/legacy/oneplus.robot
Resource    ./UEs/legacy/nokia_cpe.robot
Resource    ./UEs/legacy/sigspark_multiUE.robot
Resource    ./UEs/legacy/samsung_vran20.robot
Resource    ./UEs/legacy/askey_vran20.robot
Resource    ./UEs/legacy/pioneer.robot
Resource    ./UEs/legacy/samsung_lte.robot
Resource    ./UEs/legacy/mtk_lte.robot
Resource    ./UEs/legacy/cpe_lte.robot
Resource    ./UEs/legacy/dingli_pioneer.robot
Resource    ./UEs/legacy/airphone.robot

# Latest with taf.ul.power_ue
Resource    ./UEs/nokia_fastmile.robot
Resource    ./UEs/harmony.robot
Resource    ./UEs/samsung_ue.robot
Resource    ./UEs/mtk_ue.robot
Resource    ./UEs/qualcomm.robot
Resource    ./UEs/xiaomi_ue.robot
Resource    ./UEs/huawei_android.robot

*** Variables ***
${prepare_use}    ${False}
${attach_use}    ${False}
${start_traffic_use}    ${False}
${check_tput_use}    ${False}
${stop_traffic_use}    ${False}
${detach_use}    ${False}

*** Keywords ***

################################## STEP1: Prepare UE for L3 call ##################################
power_ue.Prepare UE
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}    ${capatibility_index}=${0}
    ...            ${reset_sol}=${None}    ${detach_request}=${true}  ${power_reset}=False   ${ui_version}=default
    ...            ${is_need_to_kill_vysor}=${true}    ${multiue_traffic_config}=${None}    ${get_spark_license}=${true}
    ...            ${ue_num_input}=${None}    ${required_spark_license_time}=2    ${force_check_ue}=${False}    ${eq_index}=${None}
    [Documentation]    Prepare UE for L3 call test.
    ...  :param  ue_type: The type of target UE, given in lowercase. E.G  huawei / huawei_sigspark
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for reserve
    ...  :param  ue_alias: <str> store ue by ue_alias
    ...  :param  capatibility_index: The list index from ue.capabilities[], will use the index capability for reserve
    ...  :param reset_sol for qctdx50 ue has three choose (none, pc_reset, pb_reset):
    ...    none with default choose mean with no action when ue connect is missing.
    ...    pc_reset mean if ue connection nok, will try to reset the control pc to recover.
    ...    pb_reset mean if ue connection nok, will try to reset the ue with ue PB power off and on.
    ...  :param detach_request for qctdx50 ue has the choose for ue with detach status contain in prepare progress.
    ...   :param required_spark_license_time: extend spark license if remaining time less than it. unit: hours.
    ...   :param force_check_ue: True/False. Needed in huawei_sigspark. will verify ue imsi when connect to UE. Default is not to verify.
    ...           if verify ue failed, will continue to use UE 1 to continue the testing. This flag is used to keep the
    ...           original behavior, if you want to make sure UE is correctly used, please set it to True
    ...   :param eq_index: UE index start from 1. if None, will search one by one based on ue_num on spark.
    ...                     if not none, then will verify IMSI, if passed, will set ueindex to eq_index. If you would
    ...                     like to improve the efficiency for require_ue, you can directly specify this eq_index
    ${output}    run keyword    ${ue_type}.Prepare Ue    ue_index=${ue_index}
    ...                                                  capatibility_index=${capatibility_index}
    ...                                                  ue_alias=${ue_alias}
    ...                                                  reset_sol=${reset_sol}
    ...                                                  detach_request=${detach_request}
    ...                                                  power_reset=${power_reset}
    ...                                                  ui_version=${ui_version}
    ...                                                  is_need_to_kill_vysor=${is_need_to_kill_vysor}
    ...                                                  multiue_traffic_config=${multiue_traffic_config}
    ...                                                  get_spark_license=${get_spark_license}
    ...                                                  ue_num_input=${ue_num_input}
    ...                                                  required_spark_license_time=${required_spark_license_time}
    ...                                                  force_check_ue=${force_check_ue}    eq_index=${eq_index}

    [Return]    ${output}

################################## STEP2: UE ATTACH ##################################
power_ue.UE Attach
    [Arguments]    ${ue_type}   ${attach_mode}=5G_SA   ${ue_index}=${0}    ${gnb_index}=${0}    ${du_index}=0    ${hwcheck_index}=${1}
    ...    ${ue_alias}=UE_${ue_index}   ${abil_index}=${1}    ${log_type}=Aasyslog    ${interval}=${1}    ${power_reset}=False   ${retry}=${2}
    ...    ${vdu_index}=0    ${pci}=${0}   ${cap_index}=${0}    ${timeout}=15m
    [Documentation]    Attach UE for L3 call test.
    ...  :param  ue_type: The type of target UE, given in lowercase. E.G  huawei / huawei_sigspark
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for attach
    ...  :param  ue_alias: <str> store ue by ue_alias
    ...  :param  power_reset: <str> used to choose whether use power on or not in huawei spark,
    ...                       if it set to true, ue attach will use power on
    ...  :param retry: retry times for ue attach.
    ${output}    run keyword    ${ue_type}.UE Attach   ue_index=${ue_index}
    ...                                                 gnb_index=${gnb_index}
    ...                                                 hwcheck_index=${hwcheck_index}
    ...                                                 ue_alias=${ue_alias}
    ...                                                 abil_index=${abil_index}
    ...                                                 du_index=${du_index}
	...                                                 vdu_index=${vdu_index}
    ...                                                 log_type=${log_type}
    ...                                                 attach_mode=${attach_mode}
    ...                                                 interval=${interval}
    ...                                                 power_reset=${power_reset}
    ...                                                 retry=${retry}
    ...                                                 pci=${pci}
    ...                                                 cap_index=${cap_index}
    ...                                                 timeout=${timeout}
    [Return]    ${output}

################################## STEP2.1: VERIFY ATTACH ##################################
power_ue.Verify attach
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${gnb_index}=${0}    ${du_index}=${0}    ${abil_index}=${1}
    ...            ${4G_check}=True    ${5Grach_ed}=${0}    ${5Gstatus}=PASS    ${cell_id}=${None}
    [Documentation]    Verify attach result when plugin self verify not suffient
    ...  :param  ue_type: The type of target UE, given in lowercase. E.G  huawei / huawei_sigspark
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for verify attach
    ...  :param cell_id: used for qualcomm CPE which use taf.ue.at. get_ue_info can get cell_id can't get pci when use taf.ue.at
    ${output}    run keyword    ${ue_type}.Verify attach    ue_index=${ue_index}
    ...                                                     gnb_index=${gnb_index}
    ...                                                     4G_check=${4G_check}
    ...                                                     5Grach_ed=${5Grach_ed}
    ...                                                     5Gstatus=${5Gstatus}
    ...                                                     abil_index=${abil_index}
    ...                                                     du_index=${du_index}
    ...                                                     cell_id=${cell_id}
    [Return]    ${output}

################################## STEP3: START DATA TRANSFER ##################################
power_ue.Start traffic
    [Arguments]    ${ue_type}    ${direction}   ${throughput}=10   ${apn_address}=wap1nokiacom
    ...            ${duration}=10   ${protocol}=udp    ${ue_index}=${0}    ${ue_mode}=SA
    ...            ${cap_index}=${0}   ${dt_index}=${0}    ${iperf_port}=default
    ...            ${interval}=1    ${buffer_size}=1400B    ${dt_name}=DT_1
    ...            ${ue_alias}=UE_${ue_index}    ${multidrb_QoS_dest}=${None}    ${appserver}=APPserver    ${iperf_type}=via_app
    ...            ${data_amount}=1M    ${connection_type}=app    ${process_num}=default
    ...            ${seg_size}=1180    ${window}=2M    ${ip_filter}=${None}    ${apn}=${None}
    [Documentation]    Start data transfer for L3 call test.
    ...  :param  ue_type: The type of target UE, given in lowercase. E.G  huawei / huawei_sigspark
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  duration: Duration of traffic
    ...  :param  throughput: Throughput of new data transfer
    ...  :param  protocal: Traffic protocal type. E.G udp/tcp
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ...  :param  dt_index: The new data transfer index alias.
    ...  :param  iperf_port: port number used for traffic start via iperf.
    ...  :param  dt_name: alias name for created data transfer.
    ...  :param  ue_alias: <str> store ue by ue_alias
    ...  :param  multidrb_QoS_dest: <optional> default None,
    ...                             multidrb_QoS_dest is a optional input,
    ...                             Setup UL traffic dest ip address for multidrb testing,
    ...                             Normal UL traffic ignore this param.
    ...  :param  cap_index: The list index from ue.capabilities[], will use the index capability for reserve.
    ...  :param  iperf_type: Traffic use iperf command or iperf app type.
    ...  :param  connection_type: net connection type, "app" or "current", "app" default.
    ...  :param  process_num: the number of process which are used for tcp data transfer, the more the better.
    ...  :param  seg_size: set TCP maximum segment size (MTU - 40 bytes)
    ...  :param  window: set TCP window size. eg, default value is 2M
    ${direction}=    Convert To Lowercase    ${direction}
    # If process_num was given by user, use the users value.
    # If not given, set default value by protocal, udp -> ${1} | tcp -> ${5}
    ${process_num}    run keyword if
    ...               '${process_num}'!='default'    set variable    ${process_num}
    ...               ELSE                           set variable if
    ...                                              '${protocol.lower()}'=='udp'    ${1}
    ...                                                                              ${5}
    ${output}    run keyword    ${ue_type}.Start traffic    direction=${direction}
    ...                                                     ue_index=${ue_index}
    ...                                                     dt_index=${dt_index}
    ...                                                     duration=${duration}
    ...                                                     throughput=${throughput}
    ...                                                     protocol=${protocol}
    ...                                                     iperf_port=${iperf_port}
    ...                                                     interval=${interval}
    ...                                                     buffer_size=${buffer_size}
    ...                                                     dt_name=${dt_name}
    ...                                                     ue_alias=${ue_alias}
    ...                                                     multidrb_QoS_dest=${multidrb_QoS_dest}
    ...                                                     cap_index=${cap_index}
    ...                                                     ip_filter=${ip_filter}
    ...                                                     appserver=${appserver}
    ...                                                     iperf_type=${iperf_type}
    ...                                                     data_amount=${data_amount}
    ...                                                     apn_address=${apn_address}
    ...                                                     ue_mode=${ue_mode}
    ...                                                     connection_type=${connection_type}
    ...                                                     process_num=${process_num}
    ...                                                     seg_size=${seg_size}
    ...                                                     window=${window}
    ...                                                     apn=${apn}
    [Return]    ${output}

################################## STEP4: CHECK THROUGHPUT ##################################

## Deprecated! Please use collect_tput/check_tput ##
power_ue.Check throughput
    [Arguments]    ${ue_type}    ${direction}    ${throughput}=5    ${deviation}=10
    ...            ${ue_index}=${0}    ${dt_index}=${0}    ${ue_alias}=UE_${ue_index}    ${gnb_index}=${0}    ${du_index}=${0}
    ...            ${hw_slot}=${1}    ${sample}=${10}    ${start_offset}=${3}    ${sleep_time}=${5}    ${cellid}=${EMPTY}
    ...            ${log_type}=Aasyslog
    [Documentation]    Check throughput from started traffic.
    ...  :param  ue_type: The type of target UE, given in lowercase. E.G  huawei / huawei_sigspark
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  throughput: Throughput of new data transfer
    ...  :param  deviation: Aceptable deviation of target throughput
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for check throughput.
    ...  :param  dt_index: The new data transfer index alias.
    ...  :param  ue_alias: <str> store ue by ue_alias
    ...  :param  du_index: this du index can distinguish left or right of AMIA, 0 meas left, 1 means right
    ...  :param  hw_slot: abil index, In left of AMIA support slot 1, 2, 3. In right of AMIA support slot 5, 6, 7.
    ...  :param  sample: how many sample cut in l2lo for average caculate.
    ...  :param  start_offset: start from which line to caculate the throughput.
    ...  :param  sleep_time: with gnb l2lo log print is normal with 1 second/1 time, this default value is fine.
    ...  :param  cellid: with just 1 cell, use the default empty value, if has mutli cell, need add the cellid for each cell check.
    ${output}    run keyword    ${ue_type}.Check throughput    direction=${direction.lower()}
    ...                                                        ue_index=${ue_index}
    ...                                                        dt_index=${dt_index}
    ...                                                        throughput=${throughput}
    ...                                                        deviation=${deviation}
    ...                                                        ue_alias=${ue_alias}
    ...                                                        gnb_index=${gnb_index}
    ...                                                        du_index=${du_index}
    ...                                                        hw_slot=${hw_slot}
    ...                                                        sample=${sample}
    ...                                                        start_offset=${start_offset}
    ...                                                        sleep_time=${sleep_time}
    ...                                                        cellid=${cellid}
    ...                                                        log_type=${log_type}
    [Return]    ${output}

################################## STEP4.1: CHECK PEAK THROUGHPUT ##################################

## Deprecated! Please use collect_tput/check_tput ##
power_ue.Check peak throughput
    [Arguments]    ${ue_type}    ${theory_dl_peak}    ${theory_ul_peak}
    ...            ${total_time}=60    ${interval}=10s    ${duration_time_for_once}=200s
    ...            ${acceptable_tput_percentage}=0.95    ${nr_cell_index}=1    ${du_index}=0
    ...            ${gnb_ssl_connection}=GNB_OAM    ${is_need_to_capture_log}=${False}
    [Documentation]    Check throughput from started traffic.
    ...  :param  ue_type: The type of target UE, given in lowercase. E.G  huawei / qct_dx50
    ...  :param  theory_ul_peak: The theory peak value of UL traffic. Unit is Mbits/sec. E.G 11.8
    ...  :param  theory_dl_peak: The theory peak value of DL traffic. Unit is Mbits/sec  E.G 262.0
    ...  :param  total_time: is the duration time in which the throughput need to be checked. The time unit is second.
    ...  :param  interval: refers to the sleep time between tput checking, can be mins, hours, or secs
    ...  :param  duration_time_for_once: is the duration time for calculating average tput in one capturing
    ...  :param  acceptable_tput_percentage: The acceptable tput percentage of throughput.
    ...                                      Will check if Throughput > theory * acceptable_tput_percentage.
    ...  :param  is_need_to_capture_log: will capture event trace log if set to ${True}
    ${dl_tput}    ${ul_tput}    run keyword    ${ue_type}.Check peak throughput
    ...                                        total_time=${total_time}
    ...                                        theory_dl_peak=${theory_dl_peak}
    ...                                        theory_ul_peak=${theory_ul_peak}
    ...                                        interval=${interval}
    ...                                        duration_time_for_once=${duration_time_for_once}
    ...                                        nr_cell_index=${nr_cell_index}
    ...                                        acceptable_tput_percentage=${acceptable_tput_percentage}
    ...                                        is_need_to_capture_log=${is_need_to_capture_log}
    ...                                        du_index=${du_index}
    ...                                        gnb_ssl_connection=${gnb_ssl_connection}
    [Return]    ${dl_tput}    ${ul_tput}

################################## STEP4X COLLECT THROUGHPUT ##################################
power_ue.Collect Tput
    [Arguments]    ${ue_type}    ${gnb_index}=0    ${du_index}=0    ${duration}=10m    ${ignore_time}=1min    ${type}=MCU
    ...            ${filter}=${EMPTY}    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}    ${log_dir}=${OUTPUT_DIR}
    ...            ${Teardown_after_finished}=${True}    ${check_source}=spark    ${upload_duration}=${True}
    ...            ${alias}=log_0
    [Documentation]    Keep capturing Aasyslog for given duration.
    ...                As the moment traffic just started, throughput will be unstable (Acceptable and should be ignored)
    ...                Add Ignore time before and after throughput capturing.

    ...                :param ue_type: The type of target UE, given in lowercase. E.G  huawei / huawei_sigspark
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    ...                :param type: two paramater can choose[mcu,rt],the syslog with CCS_MCU contain L2LO and CCS_RT contain L2HI.
    ...                :param duration: duration of log capturing. E.G 10min / 1hour
    ...                :param ignore_time: how long will be ignored before and after capturing. E.G 10min / 1hour

    ...                Should be used between Start traffic and Stop traffic!!!
    ...                E.G    Single direction
    ...                Power_ue.Start Traffic
    ...                ${tput_log}    power_ue.Collect Tput
    ...                Power_ue.Stop Traffic

    ...                E.G    BI-direction
    ...                Power_ue.Start Traffic     direction=ul
    ...                Power_ue.Start Traffic     direction=dl
    ...                ${tput_log}    power_ue.Collect Tput
    ...                Power_ue.Stop Traffic
    ...                Power_ue.Stop Traffic
    ...                The tput_log will contain both direction throughput data.

    ${log_path}    run keyword    ${ue_type}.Collect Tput
    ...            gnb_index=${gnb_index}    du_index=${du_index}    check_source=${check_source}
    ...            type=${type}    duration=${duration}    ignore_time=${ignore_time}    log_dir=${log_dir}
    ...            filter=${filter}    ue_alias=${ue_alias}    Teardown_after_finished=${Teardown_after_finished}
    ...            upload_duration=${upload_duration}    ue_index=${ue_index}
    ...            alias=${alias}
    [Return]    ${log_path}

################################## STEP4X Standard Check single direction throughput ##################################
power_ue.Check Tput
    [Arguments]    ${ue_type}    ${direction}    ${target_throughput}    ${log}=${None}    ${cells}=${1}
    ...            ${target_avg_percent}=0.98    ${min_percent}=0.85    ${actCarrierAggregation}=${False}
    ...            ${customized_log_name}=${None}    ${check_source}=spark    ${ue_index}=${0}
    ...            ${cell_indiv_tput}=${None}   ${actImgGeneration}=${True}    ${upload_tp}=${True}    ${omit_time}=10
    ...            ${alias}=log_0
    [Documentation]    validate throughput in the aasyslog throughput log file from Collect Aasyslog Throughput.
    ...                Add both avraget throughput and minimum throughput check -- taking 95% and 85% as validate value.
    ...                :param ue_type: The type of target UE, given in lowercase. E.G  huawei / huawei_sigspark
    ...                :param direction: direction of the target traffic to be checked. E.G: UL/DL
    ...                :param log: log path of aasyslog throughput file.
    ...                            Suggest to use the path Power_ue.Collect Aasyslog Throughput Return
    ...                :param cells: list of target cells. E.G for 8CC CA traffic , all 8 cells IDs should be in list.
    ...                :param target_throughput: theory target throughput. Unit in Mbps.
    ...                                          Will be used in validation with target_avg_percent and minimum percent.
    ...                :param target_avg_percent: allowed avraget percentage. E.G 0.95 or 95%
    ...                                           Check_result > target_throughput * target_avg_percent
    ...                :param actCarrierAggregation: actCarrierAggregation is ${True} or ${False}.
    ...                :param cell_indiv_tput: dict {"cell_id": "target tput"}, only usable when actCarrierAggregation is True.
    ...                       when ca is True and this param given, will check each cell's target after checking them combined.

    ...                E.G    Single direction
    ...                Power_ue.Start Traffic
    ...                ${tput_log}    power_ue.Collect Tput
    ...                Power_ue.Stop Traffic
    ...                ${list_of_cell_ids}    Create list  16385
    ...                power_ue.Check Tput    direction=DL    cells=${list_of_cell_ids}    log=${tput_log}
    ...                                                      target_throughput=2048  # unit is Mbps
    ...                E.G    Bi-direction with individual check.
    ...                Power_ue.Start Traffic
    ...                Power_ue.Start Traffic
    ...                ${tput_log}    power_ue.Collect Tput
    ...                Power_ue.Stop Traffic
    ...                Power_ue.Stop Traffic
    ...                ${ul_cell}    Create list  16385
    ...                ${dl_cell}    Create list  16388
    ...                power_ue.Check Tput    direction=DL    cells=${ul_cell}    log=${tput_log}
    ...                                       target_throughput=2048  # unit is Mbps
    ...                power_ue.Check Tput    direction=UL    cells=${dl_cell}    log=${tput_log}
    ...                                       target_throughput=256  # unit is Mbps
    ...                # if you need to use the value.
    ...                ${ul}    Power_ue.Check Tput    xxxxxxxxxxxxxxxxxx
    ...                # For sigspark UE, cells is ue_alias

    ${output}    run keyword    ${ue_type}.Check Tput
    ...    direction=${direction}    log=${log}    cells=${cells}    check_source=${check_source}
    ...    target_throughput=${target_throughput}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${actCarrierAggregation}    min_percent=${min_percent}
    ...    customized_log_name=${customized_log_name}    ue_index=${ue_index}
    ...    actImgGeneration=${actImgGeneration}    upload_tp=${upload_tp}
    ...    alias=${alias}
    [Teardown]    Run Keyword If    ${cell_indiv_tput}
    ...    power_ue.__check_each_cell_indiv_tput
    ...    ue_type=${ue_type}    direction=${direction}    log=${log}
    ...    cell_indiv_tput=${cell_indiv_tput}    check_source=${check_source}
    ...    target_throughput=${target_throughput}    target_avg_percent=${target_avg_percent}
    ...    min_percent=${min_percent}    ue_index=${ue_index}    upload_tp=${upload_tp}    alias=${alias}
    [Return]    ${output}

################################## STEP4X CHECK BI DIRECTION THROUGHPUT ##################################
power_ue.Check Bi Tput
    [Arguments]    ${ue_type}    ${log}=${None}    ${cells}=${1}    ${ultarget_throughput}=5    ${dltarget_throughput}=5
    ...            ${target_avg_percent}=0.98    ${min_percent}=0.85    ${actCarrierAggregation}=${False}
    ...            ${customized_log_name}=${None}    ${check_source}=spark    ${ue_index}=${0}    ${actImgGeneration}=${True}
    ...            ${upload_tp}=${True}    ${alias}=log_0
    [Documentation]    validate throughput in the aasyslog throughput log file from Collect Aasyslog Throughput.
    ...                Add both avraget throughput and minimum throughput check -- taking 95% and 85% as validate value.
    ...                :param ue_type: The type of target UE, given in lowercase. E.G  huawei / huawei_sigspark
    ...                :param log: log path of aasyslog throughput file.
    ...                            Suggest to use the path Power_ue.Collect Aasyslog Throughput Return
    ...                :param cells: list of target cells. E.G for 8CC CA traffic , all 8 cells IDs should be in list.
    ...                :param ultarget_throughput: theory ul traffic target throughput. Unit in Mbps.
    ...                                          Will be used in validation with target_avg_percent and minimum percent.
    ...                :param dltarget_throughput: theory ul traffic target throughput. Unit in Mbps.
    ...                                          Will be used in validation with target_avg_percent and minimum percent.
    ...                :param target_avg_percent: allowed avraget percentage. E.G 0.95 or 95%
    ...                                           Check_result > target_throughput * target_avg_percent
    ...                :param actCarrierAggregation: actCarrierAggregation is ${True} or ${False}.

    ...                E.G
    ...                Power_ue.Start Traffic
    ...                Power_ue.Start Traffic
    ...                ${tput_log}    power_ue.Collect Tput
    ...                Power_ue.Stop Traffic
    ...                Power_ue.Stop Traffic
    ...                ${list_of_cell_ids}    Create list    16385    16388
    ...                Power_ue.Check Bi Tput    cells=${list_of_cell_ids}    log=${tput_log}
    ...                                          ultarget_throughput=2048    dltarget_throughput=256   # unit is Mbps
    ...                # if you need to use the value.
    ...                ${ul}    ${dl}    Power_ue.Check Bi Tput    xxxxxxxxxxxxxxxxxx

    ${output}    run keyword    ${ue_type}.Check Bi Tput
    ...    log=${log}    cells=${cells}    min_percent=${min_percent}    check_source=${check_source}
    ...    ultarget_throughput=${ultarget_throughput}    dltarget_throughput=${dltarget_throughput}
    ...    target_avg_percent=${target_avg_percent}    actCarrierAggregation=${actCarrierAggregation}
    ...    customized_log_name=${customized_log_name}    ue_index=${ue_index}
    ...    actImgGeneration=${actImgGeneration}    upload_tp=${upload_tp}
    ...    alias=${alias}
    [Return]    ${output}

################################## STEP5: STOP DATA TRANSFER ##################################
power_ue.Stop traffic
    [Arguments]    ${ue_type}    ${direction}    ${ue_index}=${0}    ${dt_index}=${0}
    ...            ${dt_name}=DT_1    ${ue_alias}=UE_${ue_index}    ${iperf_port}=default    ${appserver}=APPserver    ${iperf_type}=via_app
    ...            ${protocol}=udp   ${apn_address}=wap1nokiacom      ${ue_mode}=SA
    [Documentation]    Stop data transfer for L3 call test.
    ...  :param  ue_type: The type of target UE, given in lowercase. E.G  huawei / huawei_sigspark
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ...  :param  dt_index: The new data transfer index alias.
    ...  :param  dt_name: alias name for created data transfer.
    ...  :param  ue_alias: <str> store ue by ue_alias
    ...  :param  protocal: Traffic protocal type. E.G udp/tcp
    ...  :param  iperf_type: Traffic use iperf command or iperf app type.
    ${direction}=    Convert To Lowercase    ${direction}
    ${output}    run keyword    ${ue_type}.Stop traffic    direction=${direction}
    ...                                                    ue_index=${ue_index}
    ...                                                    dt_index=${dt_index}
    ...                                                    dt_name=${dt_name}
    ...                                                    ue_alias=${ue_alias}
    ...                                                    iperf_port=${iperf_port}
    ...                                                    appserver=${appserver}
    ...                                                    iperf_type=${iperf_type}
    ...                                                    apn_address=${apn_address}
    ...                                                    ue_mode=${ue_mode}
    ...                                                    protocol=${protocol}
    [Return]    ${output}

################################## STEP6: UE DETACH ##################################
power_ue.UE Detach
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}    ${power_reset}=False
    [Documentation]    Detach UE for L3 call test.
    ...  :param  ue_type: The type of target UE, given in lowercase. E.G  huawei / huawei_sigspark
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for detach
    ...  :param  ue_alias: <str> store ue by ue_alias
    ...  :param  power_reset: <str> used to choose whether use power off or not in huawei spark,
    ...                       if it set to true, ue detach will use power off
    ${output}    run keyword    ${ue_type}.UE Detach    ue_index=${ue_index}
    ...                                                 ue_alias=${ue_alias}
    ...                                                 power_reset=${power_reset}
    [Return]    ${output}

################################## STEP7: TEARDOWN UE ##################################
power_ue.Teardown UE
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    [Documentation]    Teardown UE after test finished.
    ${output}    run keyword    ${ue_type}.Teardown UE    ue_index=${ue_index}
    ...                                                   ue_alias=${ue_alias}
    [Return]    ${output}

################################## GET Setup Complete EVENT ##################################
power_ue.Get SA RRC Setup Complete Time
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    [Documentation]    Get SA RRC Setup Complete Time
    ...    :param index: ue number
    ...    :return setup complete time
    ${output}    run keyword    ${ue_type}.Get SA RRC Setup Complete Time    index=${ue_index}    ue_alias=${ue_alias}
    [Return]    ${output}

################################## WARPPER FOR LOOP CELL CHECKING ##################################
power_ue.__check_each_cell_indiv_tput
    [Arguments]    ${ue_type}    ${direction}    ${target_throughput}    ${log}=${None}
    ...            ${target_avg_percent}=0.98    ${min_percent}=0.85    ${actCarrierAggregation}=${False}
    ...            ${customized_log_name}=${None}    ${check_source}=spark    ${ue_index}=${0}
    ...            ${cell_indiv_tput}=${None}   ${actImgGeneration}=${False}    ${upload_tp}=${True}    ${omit_time}=10
    ...            ${alias}=log_0
    FOR    ${cell}    IN    @{cell_indiv_tput.keys()}
        ${cells} =    Create List    ${cell}
        run keyword    ${ue_type}.Check Tput
        ...    direction=${direction}    log=${log}    cells=${cells}    check_source=${check_source}
        ...    target_throughput=${cell_indiv_tput["${cell}"]}    target_avg_percent=${target_avg_percent}
        ...    actCarrierAggregation=${actCarrierAggregation}    min_percent=${min_percent}
        ...    customized_log_name=${customized_log_name}    ue_index=${ue_index}
        ...    actImgGeneration=${actImgGeneration}    upload_tp=${upload_tp}
        ...    alias=${alias}
    END
