*** Settings ***
Documentation
...  author: Yang Di
...  contact: di.yang@nokia-sbell.com

Library         OperatingSystem
Library         ./test_specific_keywords.py          WITH NAME   python_570
Library         taf.sbts.oam.coam.admin      WITH NAME    coam
Library         taf.transport.ssh                    WITH NAME   ssh
Library         ../../outsides/resources_570/webUI_operations.py
Library         ../../outsides/resources_570/pm_counters.py
Library         ../../outsides/resources_2098/DeltaStore.py
Library         ../../outsides/resources_2098/counters/Counters.py
Resource        ../../outsides/resources_570/preconditions.robot
Resource        ../../outsides/resources_570/pm_counters/pm_counters.robot
Resource        ../../outsides/resources_2098/common_kw.robot
Resource        ../../../../resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource        ../../../../resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Variables ***
${PM counter interval}              300                 # time in sec
${DL_VOLUME_F1}                     M55323C0100         # counter id prefix; postfix (QoS) is added after UE attach
${DL_VOLUME_X2}                     M55313C0800
${MAX_DL_TPUT_F1}                   M55323C0700
${MAX_DL_TPUT_X2}                   M55313C1700
${UL_VOLUME_F1}                     M55323C0300
${UL_VOLUME_X2}                     M55313C1100
${MAX_UL_TPUT_F1}                   M55323C0900
${MAX_UL_TPUT_X2}                   M55313C1900
${dlDataSplitGainThreshold}         5                   # 5%
${dlDataSplitMode}                  2                   # dlOverF1UX2U
${dddsPeriodX2}                     10                  # 10ms
${minThFlowCtrlX2}                  1                   # 1Mbps
${maxTransferDelayX2}               20                  # 20ms
${vol_f1_counter_id}
${vol_x2_counter_id}
${max_tput_f1_counter_id}
${max_tput_x2_counter_id}
&{max dl over lte}                  SBTS22R2=18  SBTS22R1=18  SBTS21B=18  5G21A=8  5G20B=15
&{max ul over lte}                  SBTS22R2=15  SBTS22R1=15  SBTS21B=15  5G21A=8  5G20B=15
${GN_OAM_ADDR}                      ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
&{beamSet_list_params}              basicBeamSet=beamSetAbf_1A    leftEdgeAngle=90    rightEdgeAngle=90
@{ddds counters}                    M55313C22008  M55313C22001  M55313C22002
...                                 M55313C22003  M55313C22004  M55313C22005
...                                 M55313C22006  M55313C22007  M55313C22009
${max_dl_lte}                       18
${max_ul_lte}                       15
${UE_TYPE}                          samsung
${SW_VERSION}

*** Keywords ***
Test teardown
    Run Keyword And Ignore Error    power_ue.Stop traffic    direction=${direction}    ue_index=${0}    ue_type=${UE_TYPE}
    power_ue.UE Detach    ue_type=${UE_TYPE}
    Set Data Split Mode
    Stop tracing on SMOD

Set DL Flow Control Algorithm
    [Arguments]    ${value}
    Set_dlFlowControlAlgo_parameter_for_all_drbs   value=${value}
    Run Keyword If   '${value}' == 'nokiaFlowControl'
    ...         Set test variable   ${dlFlowControlAlgo}   0
    ...    ELSE
    ...         Set test variable   ${dlFlowControlAlgo}   1
    log to console   dlFlowControlAlgo is set to ${dlFlowControlAlgo} (${value}) for all DRBs

Set Data Split Mode
    [Arguments]    ${dl_split}=dlOverF1U
    ...            ${ul_split}=ulOverNr   ${ul_threshold}=infinity   ${ul_split_not_capable_ue}=${EMPTY}
    coam.Connect to         bts_host=${GN_OAM_ADDR}
    Set_data_split_mode_parameter_for_all_drbs
    ...            dl_split=${dl_split}
    ...            ul_split=${ul_split}
    ...            ul_threshold=${ul_threshold}
    ...            ul_split_not_capable_ue=${ul_split_not_capable_ue}
    Set test variable   ${dl_split}
    Set test variable   ${ul_split}

Verify x2u Flow Control parameters in logs
    [Arguments]      ${filename}
    Connect to gnb coam via ssl
    ${SW_VERSION}    coam.get_sw_release_name    connection=GNB_OAM
    Check parameters in BearerSetupReq    ${filename}
    ...                                   ${dlFlowControlAlgo}
    ...                                   ${dlDataSplitGainThreshold}
    ...                                   ${dlDataSplitMode}
    ...                                   ${dddsPeriodX2}
    ...                                   ${minThFlowCtrlX2}
    ...                                   ${maxTransferDelayX2}
    ...                                   ${SW_VERSION}

Attach UE And Check QoS
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    power_ue.UE Detach    ue_type=${UE_TYPE}
    Start tracing on SMOD
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${UE_TYPE}    attach_mode=5G_NSA
    power_ue.Verify attach    ue_type=${UE_TYPE}    5Grach_ed=${5Grach_ed}    4G_check=False
    Sleep   60s
    ${log path}   Stop tracing and download logs from SMOD
    ${QoS}        Check QoS group   ${log path}
    Set Test Variable   ${QoS}

Start traffic
    [Arguments]  ${direction}  ${protocol}  ${duration}  ${tput}=None  ${tput_deviation}=20%
    Set Test Variable    ${direction}
    Set Test Variable    ${tput}
    Set Test Variable    ${duration}
    Set Test Variable    ${tput_deviation}

    ${tput_udp_kwargs_dict}  Create Dictionary  window=8M  throughput=${tput}M  buffer_size=1400B
    ${tput_tcp_kwargs_dict}  Create Dictionary  window=32M  seg_size=1450  process_num=4
    ${traffic duration}   Evaluate   ${duration} + 600
    ${dt_kwargs}  Set Variable If  '${protocol.lower()}' == 'udp'  ${tput_udp_kwargs_dict}  ${tput_tcp_kwargs_dict}
    ${time}   DateTime.Get Current Date   exclude_millis=True
    Log To Console       \n ${time}: To run traffic wait for next PM counter interval starts
    Run Keyword If   '${direction.upper()}' == 'DL'
    ...         power_ue.Start traffic    ue_index=${0}    direction=${direction.lower()}    duration=${traffic duration}s
    ...    ue_type=${UE_TYPE}    protocol=${protocol}    &{dt_kwargs}
    ...    ELSE
    ...         power_ue.Start traffic    ue_index=${0}    direction=${direction.lower()}    duration=${traffic duration}s
    ...    ue_type=${UE_TYPE}    protocol=${protocol}    &{dt_kwargs}    iperf_type=via_command
    Sync_to_reporting_interval   offset_s=1
    ${time}   DateTime.Get Current Date   exclude_millis=True
    Log To Console       ${time}: ${direction.upper()} ${protocol.upper()} traffic ${tput}Mbit/s started, duration ${duration} seconds
    Log To Console       In case of TCP it's expected value.
    _Prepare traffic counters id list   ${direction}

Verify traffic in each PM counter time period
    ${number of traffic period to check}   Evaluate   ${duration} / ${PM counter interval}
    Log To Console   Traffic will be checked in ${number of traffic period to check} PM counter interval(s), each ${PM counter interval}s
    Sleep   60s          Time to full throughput starts - longer than offset (s) to check counters
    FOR  ${index}  IN RANGE  ${number of traffic period to check}
        Sync_to_reporting_interval                   offset_s=45
        ${counters value}  _Get Traffic Counters Value
        ${time period}     Evaluate  ${index} + 1
        Run Keyword And Continue On Failure   Verify traffic volume in given time period   
        ...                                      ${time period}  ${direction}  ${counters value}  ${tput_deviation}
        Run Keyword And Continue On Failure   Verify max throughput in given time period   
        ...                                      ${time period}  ${direction}  ${counters value}  ${tput_deviation}
    END

Verify traffic in whole time period
    Run Keyword If   '${direction}' == 'dl'
    ...    Verify DDDS Counters exist

_Prepare traffic counters id list
    [Arguments]  ${direction}

    ${vol_f1_counter_id}  Set Variable If  '${direction}' == 'dl'  ${DL_VOLUME_F1}${QoS}  ${UL_VOLUME_F1}${QoS}
    Set Test Variable     ${vol_f1_counter_id}
    ${vol_x2_counter_id}  Set Variable If  '${direction}' == 'dl'  ${DL_VOLUME_X2}${QoS}  ${UL_VOLUME_X2}${QoS}
    Set Test Variable     ${vol_x2_counter_id}
    ${max_tput_f1_counter_id}  Set Variable If  '${direction}' == 'dl'  ${MAX_DL_TPUT_F1}${QoS}  ${MAX_UL_TPUT_F1}${QoS}
    Set Test Variable     ${max_tput_f1_counter_id}
    ${max_tput_x2_counter_id}  Set Variable If  '${direction}' == 'dl'  ${MAX_DL_TPUT_X2}${QoS}  ${MAX_UL_TPUT_X2}${QoS}
    Set Test Variable     ${max_tput_x2_counter_id}

    @{counter ids list}   Create List   ${vol_f1_counter_id}  ${max_tput_f1_counter_id}
    ...                                 ${vol_x2_counter_id}  ${max_tput_x2_counter_id}
    Set Test Variable     ${counter ids list}

_Get Traffic Counters Value
    pm_counters.Collect counters
    ${counters value}     pm_counters.Get last counter values   @{counter ids list}
    [Return]   ${counters value}

Verify DDDS Counters exist
    [Arguments]             ${alias}=coam
    coam.Connect to         bts_host=${GN_OAM_ADDR}         name=${alias}
    ${counter_dist_name}  Set variable  BTS/NRBTS-${bts_id}/NX2UB
    Log to console          Check if ddds counter value is 0
    FOR  ${counter_id}  IN  @{ddds counters}
       ${counters}  Get counter values  dist_name=${counter_dist_name}  counter_id=${counter_id}  connection=${alias}  timeout=300
       ${dates}                Get dictionary keys    ${counters}
       Sort list               ${dates}
       Reverse list            ${dates}
       ${newest_counter_value}     Get from dictionary    ${counters}    ${dates[0]}
       Run Keyword If   '${newest_counter_value}' != '0'     Exit For Loop
    END
    Should not be equal as integers   ${newest_counter_value}    0    msg=Counter value equal 0    values=${False}
    Log to console          DDDS counter value: ${newest_counter_value} is greater than 0

Verify DDDS messages exist in traces
    [Arguments]      ${time period}   ${filename}=${LOG_PATH}/${test_name}_${log_index}
    Start tracing on Sniffer
    Sleep   10s      Time period to capture gtp packets
    Stop tracing and download logs from Sniffer
    Check GTP packets     ${filename}.pcap   ${time period}

Connect to Sniffer
    [Documentation]     Create connection to Sniffer for TL01, TL02 and TL20 TLs
    [Arguments]       ${alias}=sniffer
    ssh.Connect To      ${tl.test_pcs[1].default_ssh_connection_details.addr}
    ...                 ${tl.test_pcs[1].default_ssh_connection_details.username}
    ...                 ${tl.test_pcs[1].default_ssh_connection_details.password}
    ...                 alias=${alias}
    [Return]          ${alias}

Close connection to Sniffer
    [Arguments]       ${alias}=sniffer
    ssh.disconnect    connection=${alias}

Start tracing on Sniffer
    [Arguments]       ${filename}=${test_name}_${log_index}  ${interface}=eth7   ${filter}=-c 1000
    ${sniffer alias}=    Connect to Sniffer
    ssh.send_command  command=sudo tcpdump -i ${interface} -w "/tmp/${filename}.pcap" ${filter}
    ...               connection=${sniffer alias}

Stop tracing and download logs from Sniffer
    [Arguments]       ${filename}=${test_name}_${log_index}
    ${sniffer alias}=    Connect to Sniffer
    ssh.execute          command=killall tcpdump
    ...                  connection=${sniffer alias}
    ssh.execute          command=sudo chmod 777 /tmp/${filename}.pcap
    ...                  connection=${sniffer alias}
    ssh.download_file    /tmp/${filename}.pcap
    ...                  ${LOG_PATH}/${filename}.pcap
    ...                  connection=${sniffer alias}
    ssh.execute          command=sudo rm "/tmp/${filename}.pcap"
    ...                  connection=${sniffer alias}
    Close connection to Sniffer

Configuring_3gpp_Case_Steps
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    power_ue.UE Detach    ue_type=${UE_TYPE}
    Set Data Split Mode             dl_split=dlOverF1UX2U
    Set DL Flow Control Algorithm   3gppFlowControl
    Start tracing on SMOD
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${UE_TYPE}    attach_mode=5G_NSA
    power_ue.Verify attach    ue_type=${UE_TYPE}    5Grach_ed=${5Grach_ed}    4G_check=False
    sleep   60s
    ${log path}    Stop tracing and download logs from SMOD
    Verify x2u Flow Control parameters in logs    ${log path}

Max_Uplink_sent_Case_Steps
    Set Data Split Mode      ul_split=ulOverLte
    Attach UE And Check QoS
    keywords.Start traffic    direction=ul  protocol=udp  duration=1800  tput=${max_ul_lte}
    Verify traffic in each PM counter time period
    Verify traffic in whole time period

Get Realease Name
    coam.connect to     bts_host=${GN_OAM_ADDR}
    ${sw release name}    coam.get_sw_release_name
    Set suite variable        ${sw release name}

Perform commissioning 5GC000570
    [Arguments]             ${numberOfTransmittedSsBlocks}=1 beam
    ...                     ${alias}=coam
    Log to console          Perform commissioning with given parameters.
    ${cell_ids}    Get cell ids
    Initialise delta store
    ${nrcellgrp_path}       Set variable    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELLGRP-
    ${nrcell_path}          Set variable    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-
    coam.Connect to         bts_host=${GN_OAM_ADDR}      name=${alias}
    ${nrcellgrp_objects}    coam.Get managed objects     class_name=NRCELLGRP_A   connection=${alias}
    FOR  ${nrcellgrp}  IN  @{nrcellgrp_objects}
       ${index}            Fetch from right  ${nrcellgrp['distName']}  -
       Add param to delta  ${nrcellgrp_path}${index}    numberOfTransmittedSsBlocks         value=${numberOfTransmittedSsBlocks}
    END
    ${nrcell_objects}        coam.Get managed objects    class_name=NRCELL_A   connection=${alias}
    FOR  ${nrcell}  IN  @{nrcell_objects}
       ${index}            Fetch from right  ${nrcell['distName']}  -
       Add List Parameters To Delta  ${nrcell_path}${index}       beamSet                   &{beamSet_list_params}
    END
    ${delta}                Collect delta store
    Recommission with delta from admin  ${delta}
    Wait until keyword succeeds    900 sec    60 sec    Verify all cells are onair with admin
    [Teardown]              coam.Teardown     connection=${alias}

Download Luashark File
    [Documentation]                    Download luashark file
    Get The SW
    Run    sudo rm -rf /home/ute/luashark
    OperatingSystem.Create Directory    /home/ute/luashark
    OperatingSystem.List Files In Directory    /home/ute    *luashark*
    OperatingSystem.Remove Files    /home/ute/*luashark.zip*
    OperatingSystem.Remove Files    /home/ute/luashark*.zip*
    OperatingSystem.List Files In Directory    /home/ute    *luashark*
    ${files}    get_file_for_Load    ${SW_Version}
    run keyword if  not 'No' in '${files}'    unzip_file    ${files}
    OperatingSystem.Directory Should Not Be Empty      /home/ute/luashark/generated_luashark

Get the SW
    coam.Connect to         bts_host=${GN_OAM_ADDR}
    ${SW_Version}=          coam.get_sw_version
    set suite variable      ${SW_Version}
