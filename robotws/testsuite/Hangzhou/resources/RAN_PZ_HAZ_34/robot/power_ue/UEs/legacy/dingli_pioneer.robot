*** Settings ***
Documentation    UE common keyword for normal L3 call, support to control Multi UE also.
...              Please do not modify the file without notification to author
...              Author:  SKY
...              Contact: sky.mei@nokia-sbell.com
...              Already verified equipment: Huawei Meta20x

Resource    ../../Power_ue_supports/power_ue_throughput.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Throughput_checking_from_GNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Library     taf.ue.pioneer.client       WITH NAME           pclient
Library     taf.transport.ssh		WITH NAME	csn

*** Variables ***

*** Keywords ***

################################## STEP1: Prepare UE for L3 call ##################################
Prepare UE
    [Arguments]    ${ue_alias}   ${ue_index}=${0}   ${power_reset}=${true}  ${detach_request}=${true}    ${reset_sol}=${None}
    ...            ${get_spark_license}=${true}    &{kwargs}
    [Documentation]     Prepare UE for L3 call test.
    ...  :param   ue_alias: <str> store ue by ue_alias
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for reserve
    ${ue_index_list}    powerue_dingli_FormatToList    var=${ue_index}
    ${ue_alias_list}    powerue_dingli_FormatToList    var=${ue_alias}
    ${len}    Get Length    ${ue_index_list}

    FOR    ${i}    IN RANGE    ${len}
        ${ServerIPasAlias}    set variable    dingli_${tl.ues[${ue_index_list[${i}]}].ssh_connection_details.addr}
        #init the env is not inited.
        powerue_dingli_CheckVariableValid    var=${ServerIPasAlias}     default_value=not_inited
        run keyword if     '${${ServerIPasAlias}}'!='inited'
        ...            run keywords
        ...            powerue_dingli_processManagement    ue_index=${ue_index_list[${i}]}
        ...    AND     pclient.setup_service
        ...            host=${tl.ues[${ue_index_list[${i}]}].ssh_connection_details.addr}
        ...            port=30999
        ...            ssh_username=${tl.ues[${ue_index_list[${i}]}].ssh_connection_details.username}
        ...            ssh_password=${tl.ues[${ue_index_list[${i}]}].ssh_connection_details.password}
        ...            timeout=150
        ...            alias=${ServerIPasAlias}
        ...    AND     sleep    45s
        ...    AND     run keyword and ignore error   pclient.release_ues    service=${ServerIPasAlias}
        ...    AND     sleep    10s
        ...    AND     wait until keyword succeeds    5 min    60 sec     pclient.prepare_ues    service=${ServerIPasAlias}
        set suite variable     ${${ServerIPasAlias}}    inited
        powerue_dingli_CheckVariableValid    var=tl.ues[${ue_index_list[${i}]}].imei     default_value=None
        run keyword if    '${tl.ues[${ue_index_list[${i}]}].imei}'!='None'
        ...    wait until keyword succeeds    3 min    30 sec    pclient.require_ue    service=${ServerIPasAlias}
        ...    imei=${tl.ues[${ue_index_list[${i}]}].imei}    ue_alias=${ue_alias_list[${i}]}
        ...    ELSE
        ...    wait until keyword succeeds    3 min    30 sec    pclient.require_ue    service=${ServerIPasAlias}
        ...    imsi=${tl.ues[${ue_index_list[${i}]}].imsi}    ue_alias=${ue_alias_list[${i}]}
        ${is_kirin}     pclient.is_kirin_chip    ue=${ue_alias_list[${i}]}
        #run keyword if     '${reset_sol}'!='None'    pclient.restart_ue_manager    ue=${ue_alias_list[${i}]}
    END

    ${detach_request}    powerue_dingli_FormatToBool    var=${detach_request}
    ${power_reset}    powerue_dingli_FormatToBool    var=${power_reset}
    run keyword if    ${detach_request} and ${power_reset}    run keyword and ignore error
    ...    pclient.poweroff     ue=${ue_alias}    until_timeout=150
    ...    ELSE IF     ${detach_request} and ${power_reset}!=${True}    run keyword and ignore error
    ...    pclient.detach    ue=${ue_alias}    withpdu=1

    #return list, if multi ue for latter use, if single ue, ue_alias is used

################################## STEP2: UE ATTACH ##################################
UE Attach
    [Arguments]    ${ue_alias}     ${power_reset}=${true}    ${attach_mode}=5G_SA    &{kwargs}
    [Documentation]    Attach UE for L3 call test.
    ...  :param  ue_alias: <str> store ue by ue_alias
    ...  :param  power_reset: <str> used to choose whether use power on or not in huawei spark,
    ...                       if it set to true, ue attach will use power on
    ${power_reset}    powerue_dingli_FormatToBool    var=${power_reset}
    ${attach_res}     run keyword if    ${power_reset}    pclient.poweron     ue=${ue_alias}    until_timeout=90
    ...    ELSE        pclient.attach   ue=${ue_alias}    uemode=${attach_mode}    until_timeout=90

    [Return]     ${attach_res}

################################## STEP2.1: VERIFY ATTACH ##################################
Verify attach
    [Arguments]    &{kwargs}
    [Documentation]    Verify attach result when plugin self verify not suffient
    Log    Already verified inside UE Attach.

################################## STEP3: START DATA TRANSFER ##################################
Start traffic
    [Arguments]    ${direction}    ${duration}   ${throughput}  ${ue_index}   ${apn_address}
    ...            ${ue_alias}     ${iperf_port}   ${protocol}=UDP  ${ue_mode}=5G_SA  ${multidrb_QoS_dest}=${None}
    ...            ${dt_name}=DT_1    ${connection_type}=app    ${buffer_size}=1024B    &{kwargs}
    [Documentation]    Start data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  duration: Duration of traffic
    ...  :param  throughput: Throughput of new data transfer
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ...  :param  iperf_port:  The port value of traffic, eg: 50001
    ...  :param  multidrb_QoS_dest: <optional> default None,
    ...                             multidrb_QoS_dest is a optional input,
    ...                             Setup UL traffic dest ip address for multidrb testing,
    ...                             Normal UL traffic ignore this param.
    ...  :param  connection_type: net connection type, "app" or "current", "app" default.

    ${default_port}    set variable    ${tl.ues[${ue_index}].iperf_details.port}
    ${iport}    set variable if   '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
    ${tput}     set variable    ${throughput.replace('Mbps/sec','').replace('M','')}
    ${proto}    Evaluate     '${protocol}'.upper()
    run keyword if    ${direction.count('dl')}>0
    ...    powerue_dingli_StartDLTraffic
    ...    ue_alias=${ue_alias}
    ...    ue_index=${ue_index}
    ...    apn_address=${apn_address}
    ...    duration=${duration}
    ...    iperf_port=${iport}
    ...    throughput=${tput}
    ...    protocol=${proto}
    ${tput}    run keyword if    ${direction.count('ul')}>0    Evaluate    ${tput}*1024
    ...    ELSE    set variable    ${tput}
    run keyword if    ${direction.count('ul')}>0
    ...    pclient.startultraffic
    ...    protocol=${proto}
    ...    address=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.addr}
    ...    port=${iport}
    ...    testtime=${duration}
    ...    bandwidth=${tput}
    ...    buffersize=1024
    ...    packetsize=${buffer_size.replace('B','')}
    ...    ue=${ue_alias}

    ${currentTime}    powerue_dingliGetCurrentTime
    set suite Variable    ${PowerUE_TrafficStartTime_${ue_alias}}    ${currentTime}

powerue_dingliGetCurrentTime
    ${current_time}        DateTime.Get Current Date
    ${current_time}        DateTime.convert date    ${current_time}    epoch
    [Return]    ${current_time}

################################## STEP4: CHECK THROUGHPUT ##################################
Check throughput
    [Arguments]    ${ue_alias}    ${direction}    ${throughput}    &{kwargs}
    [Documentation]    Check throughput from started traffic on UE side.
    ...  :param  ue_alias: <str> store ue by ue_alias
    ${dl_throughput_dict}=      pclient.getparammac      ue=${ue_alias}
    ${tput}    run keyword if    '${direction}'=='ul'    Evaluate    ${dl_throughput_dict}[Param][MACUL] / 1024 / 1024
    ...               ELSE IF    '${direction}'=='dl'    Evaluate    ${dl_throughput_dict}[Param][MACDL] / 1024 / 1024
    should be true    ${tput} > ${throughput}
    [Return]    ${tput}

################################## STEP4.1: CHECK PEAK THROUGHPUT ##################################
Check peak throughput
    [Arguments]    ${theory_dl_peak}    ${theory_ul_peak}
    ...            ${total_time}=60    ${interval}=10s    ${duration_time_for_once}=200s
    ...            ${acceptable_tput_percentage}=0.95    ${nr_cell_index}=1    ${du_index}=0
    ...            ${gnb_ssl_connection}=GNB_OAM    ${is_need_to_capture_log}=${False}
    [Documentation]    Check throughput from started traffic.
    ...  :param  theory_ul_peak: The theory peak value of UL traffic. Unit is Mbits/sec. E.G 11.8
    ...  :param  theory_dl_peak: The theory peak value of DL traffic. Unit is Mbits/sec  E.G 262.0
    ...  :param  total_time: is the duration time in which the throughput need to be checked. The time unit is second.
    ...  :param  interval: refers to the sleep time between tput checking, can be mins, hours, or secs
    ...  :param  duration_time_for_once: is the duration time for calculating average tput in one capturing
    ...  :param  acceptable_tput_percentage: The acceptable tput percentage of throughput.
    ...                                      Will check if Throughput > theory * acceptable_tput_percentage.
    ...  :param  is_need_to_capture_log: will capture event trace log if set to ${True}
    ${real_dl_tput}    ${real_ul_tput}    Verify tput from GNB within duration and record data to csv
    ...                                   total_time=${total_time}
    ...                                   exp_dl_tput=${theory_dl_peak}
    ...                                   exp_ul_tput=${theory_ul_peak}
    ...                                   interval=${interval}
    ...                                   duration_time_for_once=${duration_time_for_once}
    ...                                   nr_cell_index=${nr_cell_index}
    ...                                   tput_percentage=${acceptable_tput_percentage}
    ...                                   is_need_to_capture_log=${is_need_to_capture_log}
    ...                                   du_index=${du_index}
    ...                                   gnb_ssl_connection=${gnb_ssl_connection}
    [Return]    ${real_dl_tput}    ${real_ul_tput}

################################## STEP4X COLLECT THROUGHPUT ##################################
Collect Tput
    [Arguments]    ${ue_alias}    ${check_source}=spark
    ...            ${gnb_index}=0    ${du_index}=0    ${duration}=10min    ${ignore_time}=1min    ${type}=MCU
    ...            ${filter}=${EMPTY}    ${Teardown_after_finished}=${True}    ${upload_duration}=${True}    &{kwargs}
    [Documentation]    Check throughput from started traffic on UE side.
    ...  :param  ue_alias: <str> store ue by ue_alias, used for sigspark ue throughput

    ...                :param gnb_index: the gnb index which config in tl.gnbs[]. from here used for aasyslog throughput
    ...                :param du_index: the du index mean the left or right board in AMIA
    ...                :type two paramater can choose[mcu,rt],the syslog with CCS_MCU contain L2LO and CCS_RT contain L2HI.
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
    ${currentTime}    powerue_dingliGetCurrentTime
    ${dtime}    Convert Time    ${duration}
    ${sTime}    Evaluate    ${dtime}+${PowerUE_TrafficStartTime_${ue_alias}}-${currentTime}
    ${sTime}    set variable if    ${sTime}>0    ${sTime}    1
    ${log}    run keyword if
    ...               '${check_source}'=='spark'    power_ue_throughput.__Standard Capturing Dingli Throughput
    ...                                  ue_alias=${ue_alias}    duration=${sTime}
    ...    ELSE IF    '${check_source}'=='aasyslog'    power_ue_throughput.__Standard Capturing Aasyslog Throughput
    ...            gnb_index=${gnb_index}    du_index=${du_index}
    ...            type=${type}    duration=${duration}    ignore_time=${ignore_time}
    ...            filter=${filter}    Teardown_after_finished=${Teardown_after_finished}
    ...            upload_duration=${upload_duration}
    [Return]    ${log}

################################## STEP4X Standard Check single direction throughput ##################################
Check Tput
    [Arguments]    ${direction}    ${log}    ${cells}    ${target_throughput}
    ...            ${target_avg_percent}=0.95    ${min_percent}=0.85    ${actCarrierAggregation}=${False}
    ...            ${customized_log_name}=${None}    ${check_source}=spark    &{kwargs}
    [Documentation]    validate throughput in the aasyslog throughput log file from Collect Aasyslog Throughput.
    ...                Add both avraget throughput and minimum throughput check -- taking 95% and 85% as validate value.
    ...                :param direction: direction of the target traffic to be checked. E.G: UL/DL
    ...                :param log: log path of aasyslog throughput file.
    ...                            Suggest to use the path Power_ue.Collect Aasyslog Throughput Return
    ...                :param cells: ue_alias in sigspark.
    ...                :param target_throughput: theory target throughput. Unit in Mbps.
    ...                                          Will be used in validation with target_avg_percent and minimum percent.
    ...                :param target_avg_percent: allowed avraget percentage. E.G 0.95 or 95%
    ...                                           Check_result > target_throughput * target_avg_percent

    ...                :param direction: direction of the target traffic to be checked. E.G: UL/DL  From here for aasyslog throughput
    ...                :param log: log path of aasyslog throughput file.
    ...                            Suggest to use the path Power_ue.Collect Aasyslog Throughput Return
    ...                :param cells: list of target cells. E.G for 8CC CA traffic , all 8 cells IDs should be in list.
    ...                :param target_throughput: theory target throughput. Unit in Mbps.
    ...                                          Will be used in validation with target_avg_percent and minimum percent.
    ...                :param target_avg_percent: allowed avraget percentage. E.G 0.95 or 95%
    ...                                           Check_result > target_throughput * target_avg_percent
    ...                :param actCarrierAggregation: actCarrierAggregation is ${True} or ${False}.

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
    ...                Power_ue.power_ue.Check Tput    direction=DL    cells=${ul_cell}    log=${tput_log}
    ...                                                target_throughput=2048  # unit is Mbps
    ...                Power_ue.power_ue.Check Tput    direction=DL    cells=${dl_cell}    log=${tput_log}
    ...                                                target_throughput=256  # unit is Mbps

    ${throughput_result}    run keyword if
    ...    '${check_source}'=='spark'    power_ue_throughput.__Standard Check Sigspark Throughput
    ...    ue_alias=${cells}    tput_output=${log}    direction=${direction}
    ...    target_throughput=${target_throughput}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}

    ...    ELSE IF    '${check_source}'=='aasyslog'    power_ue_throughput.__Standard Check Aasyslog Throughput
    ...    direction=${direction}    log=${log}    cells=${cells}
    ...    target_throughput=${target_throughput}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${actCarrierAggregation}    min_percent=${min_percent}
    ...    customized_log_name=${customized_log_name}
    [Return]    ${throughput_result}

################################## STEP4X CHECK BI DIRECTION THROUGHPUT ##################################
Check Bi Tput
    [Arguments]    ${log}    ${cells}    ${ultarget_throughput}    ${dltarget_throughput}
    ...            ${target_avg_percent}=0.95    ${min_percent}=0.85    ${actCarrierAggregation}=${False}
    ...            ${customized_log_name}=${None}    ${check_source}=spark    &{kwargs}
    [Documentation]    validate throughput in the aasyslog throughput log file from Collect Aasyslog Throughput.
    ...                Add both avraget throughput and minimum throughput check -- taking 95% and 85% as validate value.
    ...                :param log: log path of aasyslog throughput file.
    ...                            Suggest to use the path Power_ue.Collect Aasyslog Throughput Return
    ...                :param cells: list of target cells. E.G for 8CC CA traffic , all 8 cells IDs should be in list.
    ...                :param ultarget_throughput: theory ul traffic target throughput. Unit in Mbps.
    ...                                          Will be used in validation with target_avg_percent and minimum percent.
    ...                :param dltarget_throughput: theory ul traffic target throughput. Unit in Mbps.
    ...                                          Will be used in validation with target_avg_percent and minimum percent.
    ...                :param target_avg_percent: allowed avraget percentage. E.G 0.95 or 95%
    ...                                           Check_result > target_throughput * target_avg_percent

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

    ${throughput_result}    run keyword if
    ...    '${check_source}'=='spark'    power_ue_throughput.__Standard Check Bi Sigspark Throughput
    ...    ue_alias=${cells}    tput_output=${log}
    ...    ultarget_throughput=${ultarget_throughput}    dltarget_throughput=${dltarget_throughput}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}

    ...    ELSE IF    '${check_source}'=='aasyslog'    power_ue_throughput.__Standard Check Bi Aasyslog Throughput
    ...    log=${log}    cells=${cells}    min_percent=${min_percent}
    ...    ultarget_throughput=${ultarget_throughput}    dltarget_throughput=${dltarget_throughput}
    ...    target_avg_percent=${target_avg_percent}    actCarrierAggregation=${actCarrierAggregation}
    ...    customized_log_name=${customized_log_name}
    [Return]    ${throughput_result}

################################## STEP5: STOP DATA TRANSFER ##################################
Stop traffic
    [Arguments]    ${direction}    ${ue_alias}    ${dt_name}   ${ue_index}
    ...            ${iperf_port}   ${apn_address}   ${ue_mode}   &{kwargs}
    [Documentation]    Stop data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  ue_alias: <str> store ue by ue_alias
    ...  :param  dt_name: <str> store traffic by ue_alias
    ...  :param  iperf_port:  The port value of traffic, only used in stop DL traffic eg: 50001
    ${default_port}    set variable    ${tl.ues[${ue_index}].iperf_details.port}
    ${port}    set variable if   '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
    run keyword if    ${direction.count('dl')}>0
    ...    powerue_dingli_StopDLTraffic
    ...    ue_alias=${ue_alias}
    ...    ue_index=${ue_index}

    run keyword if    ${direction.count('ul')}>0
    ...    pclient.stopultraffic    ue=${ue_alias}

################################## STEP6: UE DETACH ##################################
UE Detach
    [Arguments]    ${ue_alias}    ${power_reset}=${true}    &{kwargs}
    [Documentation]    Detach UE for L3 call test.
    ...  :param  ue_alias: <str> store ue by ue_alias
    ...  :param  power_reset: <str> used to choose whether use power off or not in huawei spark,
    ...                       if it set to true, ue attach will use power off
    ${power_reset}    powerue_dingli_FormatToBool    var=${power_reset}
    run keyword if    ${power_reset}    run keyword and ignore error
    ...           pclient.poweroff     ue=${ue_alias}    until_timeout=150
    ...    ELSE   pclient.detach       ue=${ue_alias}    withpdu=1

################################## STEP7: TEARDOWN UE ##################################
Teardown UE
    [Arguments]    ${ue_index}    ${ue_alias}=None   &{kwargs}
    [Documentation]    Teardown UE after test finished. for spark, it should release spark license
    #spark.release_spark_license   ue_alias=${ue_alias}
    ${ue_index_list}    powerue_dingli_FormatToList    var=${ue_index}
    ${len}    Get Length    ${ue_index_list}
    FOR    ${i}    IN RANGE    ${len}
        ${ServerIPasAlias}    set variable    dingli_${tl.ues[${ue_index_list[${i}]}].ssh_connection_details.addr}
        run keyword and ignore error    pclient.release_ues    service=${ServerIPasAlias}
    END
    log     nop

################################## GET Setup Complete EVENT ##################################
Get SA RRC Setup Complete Time
    [Arguments]    ${ue_alias}    ${ue_index}=1
    [Documentation]    Get SA RRC Setup Complete Time
    ...    :param index: ue number
    ...    :return setup complete time
    BuiltIn.log  not impletement
    #${output}    spark.get_SA_RRC_setup_complete_time_on_ue    index=${ue_index}    ue_alias=${ue_alias}
    [Return]    not impletement

powerue_dingli_CheckVariableValid
    [Arguments]    ${var}    ${default_value}    ${is_digit}=False
    ${res}    run keyword and ignore error   log    ${${var}}
    Run Keyword If   '${res[0]}'=='FAIL'   set suite variable    ${${var}}    ${default_value}
    ${NewValue}    Run Keyword If   '${is_digit}'=='True'    Evaluate  ${${var}}+0
    Run Keyword If   '${is_digit}'=='True'    set suite variable    ${${var}}    ${NewValue}

powerue_dingli_StartDLTraffic
    [Documentation]
	[Arguments]    ${ue_alias}    ${ue_index}    ${apn_address}    ${duration}    ${iperf_port}    ${throughput}    ${protocol}   ${dl_length}=1024B
	Log to Console    Get UE_${ue_index} ip
	${ue_ip_dict}    pclient.getpduinfo    apn=${apn_address}    ue=${ue_alias}
	${ue_ip}    set Variable    ${ue_ip_dict}[Param][IP]
	log to console    ${ue_ip}
	set suite variable    ${${ue_index}_UEIP}    ${ue_ip}
	wait until keyword succeeds    1 min    10 sec    csn.Connect to    hostname=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.addr}
    ...               username=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.username}
    ...               password=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.password}
    ...               alias=powerdingli_appserver

    run keyword if    '${protocol}'=='UDP'    csn.send command
    ...    command=iperf -c ${ue_ip} -u -t ${duration} -i 1 -p ${iperf_port} -P ${1} -f m -b ${throughput}M -l ${dl_length} -T 64 &
    ...    connection=powerdingli_appserver
#    ...    ELSE IF    '${protocol}'=='tcp'    Start the tcp DL data via iperf    ue_index=${ue_index}
#    ...    dl_time=${dl_time}    ue_addr=${ue_addr}    dl_port=${dl_port}    process_num=${process_num}    seg_size=${seg_size}
#    ...    window=${window}
    sleep    5s
    run keyword and ignore error    Wait Until Keyword Succeeds    3min    10sec    powerue_dingli_CheckPresent    alias=powerdingli_appserver
    ...    cmd=ps -ef|grep iperf|grep -v grep|grep ${ue_ip}       checkpoint=${ue_ip}
    #Check the iperf progress exist    connection=powerdingli_appserver    port=${iperf_port}

	[Teardown]    run keyword and ignore error    csn.disconnect    connection=powerdingli_appserver

powerue_dingli_StopDLTraffic
    [Documentation]
    [Arguments]    ${ue_alias}    ${ue_index}
    wait until keyword succeeds    1 min    10 sec    csn.Connect to    hostname=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.addr}
    ...               username=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.username}
    ...               password=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.password}
    ...               alias=powerdingli_appserver
    powerue_dingli_CheckVariableValid    var=${ue_index}_UEIP      default_value=noneips
    csn.execute    command=ps aux |grep iperf |grep ${${ue_index}_UEIP} |awk '{print $2}' | xargs kill -9
    ...    connection=powerdingli_appserver
    [Teardown]    run keyword and ignore error    csn.disconnect    connection=powerdingli_appserver

powerue_dingli_FormatToList
    [Arguments]   ${var}
    ${varType}=    run keyword and ignore error    Evaluate    type(${var})
    ${typeString}=   run keyword and ignore error       Evaluate         type(${var}).__name__
    log    ${varType}
    ${var}    Run Keyword If   '${varType[0]}'=='FAIL' or ${typeString.count("int")}>0    create list    ${var}
    ...    ELSE    set variable    ${var}
    log    ${var}
    [Return]  ${var}

powerue_dingli_FormatToBool
    [Arguments]   ${var}
     ${ret}    Evaluate     '${var}'.lower()
     ${ret}    set variable if     '${ret}'=='true'    ${True}    ${False}
    [Return]  ${ret}

powerue_dingli_processManagement
    [Arguments]   ${ue_index}
    wait until keyword succeeds    1 min    10 sec    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...               username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...               password=${tl.ues[${ue_index}].ssh_connection_details.password}
    ...               alias=powerdingli_contolpc
    #make sure sense is started
    ${defaultssclientPath}    set variable    "C:/Program Files (x86)/senseshield/ss/Tools/ssclient.exe"
    ${ret}    csn.execute    command=tasklist | findstr "ssclient.exe"    connection=powerdingli_contolpc
    run keyword if    ${ret.count('ssclient')==0}      run keywords
    ...           csn.execute    command=taskkill /f /im Pioneer.exe    connection=powerdingli_contolpc
    ...    AND    csn.execute    command=schtasks /create /tn ssclient /sc once /tr '${defaultssclientPath}' /st 00:00 /RL highest /f
    ...                          connection=powerdingli_contolpc
    ...    AND    sleep    3s
    ...    AND    csn.execute    command=schtasks /run /tn ssclient    connection=powerdingli_contolpc
    ...    AND    Wait Until Keyword Succeeds    4min    10sec    powerue_dingli_CheckPresent    alias=powerdingli_contolpc
    ...    cmd=tasklist | findstr "ssclient.exe"       checkpoint=ssclient

    #make sure poineer service is started
    ${ret}    csn.execute    command=netstat -ano|findstr "30999"    connection=powerdingli_contolpc
    run keyword if    ${ret.count('30999')==0}      run keywords
    ...           csn.execute    command=taskkill /f /im Pioneer.exe    connection=powerdingli_contolpc
    ...    AND    csn.execute    command=net stop PioneerService    connection=powerdingli_contolpc
    ...    AND    csn.execute    command=net start PioneerService    connection=powerdingli_contolpc
    ...    AND    Wait Until Keyword Succeeds    4min    10sec    powerue_dingli_CheckPresent    alias=powerdingli_contolpc
    ...    cmd=netstat -ano|findstr "30999"       checkpoint=30999

    #make sure poineer app is started
    ${ret}    csn.execute    command=tasklist | findstr Pioneer    connection=powerdingli_contolpc
    run keyword if    ${ret.count('Pioneer')==0}      run keywords
    ...           csn.execute    command=schtasks /end /tn Pioneer    connection=powerdingli_contolpc
    ...    AND    csn.execute    command=schtasks /delete /tn Pioneer /f    connection=powerdingli_contolpc
    ...    AND    csn.execute    command=schtasks /create /tn Pioneer /sc once /tr '"${tl.ues[${ue_index}].server_dir}"' /st 00:00 /RL highest /f
    ...                          connection=powerdingli_contolpc
    ...    AND    sleep    3s
    ...    AND    csn.execute    command=schtasks /run /tn Pioneer    connection=powerdingli_contolpc
    ...    AND    Wait Until Keyword Succeeds    4min    10sec    powerue_dingli_CheckPresent    alias=powerdingli_contolpc
    ...    cmd=tasklist | findstr Pioneer        checkpoint=Pioneer
    ...    AND    sleep    30s

    [teardown]    run keyword and ignore error    ssh.disconnect    connection=powerdingli_contolpc

powerue_dingli_CheckPresent
    [Arguments]     ${alias}    ${cmd}    ${checkpoint}
    ${res}    ssh.execute    command=${cmd}    connection=${alias}
    Should Contain    ${res}    ${checkpoint}
