*** Settings ***
Library    Collections
Library    OperatingSystem
Library    DateTime
Library    String
Library    taf.analyzer.pdml
Library    taf.transport.ssh  WITH NAME  ssh
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.outsides.resources_570.webui.WebuiInterface  WITH NAME  WebUI
Library    taf.converters.pcaptopdml   WITH NAME   pcaptopdml
Library    taf.hw.rf_attenuator    WITH NAME    att
Library    taf.collectors.tcpdump
Library    taf.collectors.core        WITH NAME    core
Library    taf.collectors.btslog  WITH NAME   btslog
Library    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/outsides/resources_2098/common.py
Library    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/outsides/resources_2098/AdminHelper.py
Resource   testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/outsides/resources_2098/pmcounters.robot
Resource   testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/outsides/resources_2098/math.robot
Resource   testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/outsides/resources_570/logs.robot
Library    ute_admin_infomodel
#Library        resources/Macro/Python/tput_logs_collecting.py
#Variables    ${tl.ues[0]}
Resource     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/outsides/resources_2098/common_keywords/ConnectivityKeywords.robot

*** Keywords ***

Check for alarms
    [Documentation]  Allow to check alarms also on eNB site
    [Arguments]  ${alias}
    ${active_alarms}=  coam.get active alarms  60  ${alias}
    ${len}=  Get length  ${active_alarms}
    FOR  ${index}  IN RANGE  ${len}
        ${alarm}=  Set variable  ${active_alarms}[${index}]
        ${alarm_severity}=  Set variable  ${alarm}[severity]
        BuiltIn.Should Not Be Equal  ${alarm_severity}  Major  Major alarm on BTS occured  ${False}
        BuiltIn.Should Not Be Equal  ${alarm_severity}  Critical  Critical alarm on BTS occured  ${False}
    END

Check if DSS connection is established
    Check for alarms  gNB
    Check for alarms  eNB
    ${XPIFREMOTE_R}  coam.get_managed_objects  XPIFREMOTE_R  connection=gNB
    ${xpLinkStatus}=  Set variable  ${XPIFREMOTE_R[0]['parameters']['xpLinkStatus']}
    log to console  __Checking xpLinkStatus gNB
    Should Be Equal  ${xpLinkStatus}  available
    ${XPIFREMOTE_R}  coam.get_managed_objects  XPIFREMOTE_R  connection=eNB
    ${xpLinkStatus}=  Set variable  ${XPIFREMOTE_R[0]['parameters']['xpLinkStatus']}
    log to console  __Checking xpLinkStatus eNB
    Should Be Equal  ${xpLinkStatus}  available

Verify eNB cells OnAir
    ${expected status}  Create dictionary
    ...                 administrativeState=Unlocked
    ...                 availabilityStatus=Online
    ...                 operationalState=Enabled
    ...                 usageState=Idle
    ...                 blockingState=Unblocked
    ${bts_info}=  coam.get bts info  60  eNB
    ${bts_info}=  Set variable  ${bts_info['cells']['lte']}
    FOR  ${cell}  IN  @{bts_info}
        Should be equal  ${expected status}  ${cell['status']}
    END

Prepare list with parameters for recommissioning
    [Documentation]  List preparation for use with coam.perform_object_recommissioning. Below you can find
    ...              exemplary usage.
#    ...    &{profile166_param} =  create dictionary  coresetCommon=${coresetCommon}
#    ...                                              searchSpaceCommon=${searchSpaceCommon}
#    ...    ${profile166_param} =  Prepare list with parameters for recommissioning  ${profile166_param}
#    ...    coam.perform_object_recommissioning  ${object}  ${profile166_param}  update  ${True}  ${True}  240  gNB
    [Arguments]  ${params}
    @{parameters_to_recommision}=  Create list
    FOR  ${param}  IN  @{params}
       &{dic}=  Create Dictionary  parameterName=${param}  operation=update  value=${params["${param}"]}
       Append To List  ${parameters_to_recommision}  ${dic}
    END
    [Return]    ${parameters_to_recommision}

Check active alarms
    coam.connect_to  name=coam
    ${alarms}  coam.Get Active Alarms  timeout=30s  connection=coam
    common.Check if no unexpected alarms  ${alarms}
    [Teardown]          coam.Teardown     connection=coam

Get list of specific object dist name
    [Documentation]     This KW returns the list of dist names of specific object for commissioning
    ...                 based on specific "_A" class name.
    ...                 Argument    |   Value
    ...                 ---------------------------------
    ...                 alias       |   [string]
    [Arguments]         ${class_name}  ${alias}=cOAM
    ${dist_names}       Create list
    coam.Connect to     name=${alias}
    ${objects}          coam.Get managed objects    class_name=${class_name}   connection=${alias}
    FOR    ${object}   IN    @{objects}
       ${dist_name_a}  Fetch from right    ${object['distName']}    SCF-1/
       ${dist_name}    Remove string  ${dist_name_a}  _A
       Append to list  ${dist_names}  ${dist_name}
    END
    [Teardown]          coam.Teardown     connection=${alias}
    [Return]            ${dist_names}

Check config type
    [Arguments]         ${alias}=coam
    [Documentation]
    ...   This KW gets a BTS info and returns the gNbCuType parameter value.
    ...   Returns:
    ...   string: 'SA' or 'NSA'
    coam.Connect to     name=${alias}
    ${object}           coam.Get bts info   connection=${alias}
    ${config_type}      Get from dictionary  ${object}  gNbCuType
    Log to console      Current config type: ${config_type}
    [Return]            ${config_type}
    [Teardown]          coam.Teardown     connection=${alias}

Upload scf and perform commissioning
    [Arguments]         ${scf_path}
    ...                 ${timeout}=240sec
    ...                 ${alias}=recommissioning
    Log to console      Upload SCF to the Test Line
    coam.Connect to     name=${alias}
    coam.Perform commissioning
    ...                 scf_file=${scf_path}
    ...                 skip_parameter_relation_errors=${FALSE}
    ...                 should_activate=${TRUE}
    ...                 timeout=${timeout}
    ...                 connection=${alias}
    Check calculation ready
    #temporary solution for BTS bussy
    sleep   12 min
    [Teardown]          coam.Teardown  connection=${alias}

Verify if all cells are onair
    [Arguments]    ${duration}=900 sec    ${interval}=60 sec
    Wait until keyword succeeds    ${duration}    ${interval}    Verify all cells are onair with admin

Verify if BTS is Online
    [Arguments]    ${duration}=900 sec    ${interval}=60 sec
    Wait until keyword succeeds    ${duration}    ${interval}    BTS state Online

Wait for counters
    [Arguments]         ${sleep_timer}=5 min
    [Documentation]
    ...     This KW waits for counters and collects their values.
    Log to console      __Wait ${sleep_timer} for counters.
    Sleep               ${sleep_timer}

Get global cell id of first cell
    ${cell_dists}       Get cells distname list
    ${first_cell_dist}  Get from list  ${cell_dists}  0
    ${first_cell_id}    Fetch from right  ${first_cell_dist}  -
    [Return]            ${first_cell_id}

Get pm counters values
    [Arguments]         @{counters}
    [Documentation]
    ...   This KW takes list of wanted counters and returns their values as test variables.
    ...   For example:
    ...   @{counters}  =  M55324C00000  M55324C00101
    ...   Returns:
    ...   ${M55324C00000} = 3000
    ...   ${M55324C00101} = 28783123
    ${counter_values}  Get last counter values  @{counters}
    ${first_cell_id}    Get global cell id of first cell
    FOR  ${counter}   IN   @{counters}
       ${val_1}  get from dictionary  ${counter_values}  ${counter}
       ${val_2}  get from dictionary  ${val_1}  ${first_cell_id}
       Set test variable  ${${counter}}  ${val_2}
    END
    ${is_number_of_samples_in_range}  Is greater than zero  ${M55324C00000}
    run keyword if  not ${is_number_of_samples_in_range}
    ...                 Fail  msg=Number of samples (${M55324C00000}) is not greater than 0.

Check if eirp counter value equals zero
    Log to console      __Check if value of EIRP counter is equal to zero.
    @{counters}  Create list  M55324C00000
    ${eirp_counter_value}  Get last counter values  @{counters}
    ${first_cell_id}    Get global cell id of first cell
    log to console  __Dictionary is ${eirp_counter_value}
    ${M55324C00000}  get from dictionary  ${eirp_counter_value}  M55324C00000
    ${val_000}  get from dictionary  ${M55324C00000}  ${first_cell_id}
    Set test variable  ${M55324C00000}  ${val_000}
    run keyword if  not ${M55324C00000} == 0
    ...                 Fail  msg=Number of samples (${M55324C00000}) is not equal to zero.

Count power value from given samples
    [Arguments]   ${samples_value}  ${sum_of_milliwatts}
    ${milliwatts_value}  Evaluate  ${sum_of_milliwatts}/${samples_value}
    [Return]  ${milliwatts_value}

Get power value from counter
    [Arguments]     ${counter}
    [Documentation]  This KW returns power value from given counter in dBm
    ${pmcounter_cell_power_mw}     Count power value from given samples  ${M55324C00000}  ${counter}
    ${pmcounter_power_dbm}     Convert mW To dbm  ${pmcounter_cell_power_mw}
    [Return]  ${pmcounter_power_dbm}

Compare power values from pm counters
    [Arguments]     ${counter}  ${expected_value}    ${range}
    ${pmcounter_power_dbm}     Get power value from counter  ${counter}
    ${lower_range}      Evaluate   ${expected_value}-${range}
    ${upper_range}      Evaluate    ${expected_value}+${range}
    ${result}   Is in interval    ${pmcounter_power_dbm}   ${lower_range}     ${upper_range}
    Should Be True   ${result}

Set attenuation and check
    [Arguments]      ${lines}    ${value}
    FOR    ${line}    IN    @{lines}
        att.Set attenuation     port=${${line}}     value=${${value}}
        ${value_port}    att.Read attenuation    port=${${line}}
        Should be equal    ${value_port}    ${${value}}
    END

Turn off attenuation
    ${lines}    Get dictionary keys     ${tl.attenuator.attenuator_ports}
    Set attenuation and check    lines=${lines}    value=${0}

Compare power values from pm counters and ru
    [Arguments]         @{counters}
    ${margin_of_error}  Set variable    2
    ${pmcounter_cell_power_dbm}     Get cell power from pm counters  @{counters}
    ${ru_cell_power_dbm}            Get cell power from ru
    Check if values are within the margin of error
    ...                 ${pmcounter_cell_power_dbm}
    ...                 ${ru_cell_power_dbm}
    ...                 ${margin_of_error}

Get cell ids
    [Arguments]     ${alias}=cOAM
    ${ids}     Create list
    coam.Connect to    bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}    name=${alias}
    ${cells}    coam.Get managed objects    class_name=NRCELL_A   connection=${alias}
    FOR    ${cell_id}    IN    @{cells}
        ${id}    Fetch from right    ${cell_id['distName']}    NRCELL_A-
        Append to list    ${ids}    ${id}
    END
    [Teardown]    coam.Teardown     connection=${alias}
    [Return]    ${ids}

Attach ue to lte cell
    [Arguments]         ${ue_alias}=AT_BASED_UE_1
    Log to console      Attach ${ue_capabilities} to cell
    Attach ue           ${ue_alias}
    Sleep               10sec

Detach ue from cell
    [Arguments]             ${ue_alias}=AT_BASED_UE_1
    Log to console      Detach UE
    Detach ue           ${ue_alias}

Get cell power from ru
    [Arguments]         ${asik_connection}=asik  ${ru_connection}=ru   ${radio}=1
    ...                 ${alias}=cOAM
    [Documentation]     This KW returns the power of radio unit with speceific id
    ...                 Argument            |   Value
    ...                 ---------------------------------
    ...                 asik_connection     |   [string
    ...                 ---------------------------------
    ...                 ru_connection       |   [string]
    ...                 ---------------------------------
    ...                 radio               |   [integer]
    Log to console      __Get cell power value from RU.
    Connect to asik     ${asik_connection}
    ${ssh_command}      Set variable  cat /rom/config/FRIps.txt
    ${output}           ssh.Execute   command=${ssh_command}  connection=${asik_connection}
    ${list_output}      Set variable  ${output.split(';')}
    ${ru_serial_nr}     Get rmod serial number       rmod_id=1
    ${ru_hw_index}      Get Index From List    ${list_output}    ${ru_serial_nr}
    coam.Connect to     name=${alias}
    ${ver}              coam.Get sw release name   connection=${alias}
    Set test variable    ${ru_ip_addr}    ${list_output[${ru_hw_index-1}]}
    Connect to RU via Asik    RU_IP=${ru_ip_addr}
    ...                       username=root
    ${ant2_tx_power}    Get output tx power from ant  2  ${ru_connection}
    ${ant4_tx_power}    Get output tx power from ant  4  ${ru_connection}
    ${ant2_tx_power_mw}     Convert dbm To mW  ${ant2_tx_power}
    ${ant4_tx_power_mw}     Convert dbm To mW  ${ant4_tx_power}
    ${cell_power_mw}    Evaluate  (${ant2_tx_power_mw}+${ant4_tx_power_mw})*2
    ${ru_cell_power_dbm}    Convert mw to dbm  ${cell_power_mw}
    Log to console      ____Power value from RU: ${ru_cell_power_dbm} dBm
    [Return]            ${ru_cell_power_dbm}
    [Teardown]          Run keywords     ssh.disconnect    connection=${ru_connection}    AND
    ...                                  ssh.disconnect    connection=${asik_connection}  AND
    ...                                  coam.Teardown    connection=${alias}

Get cell power from pm counters
    [Arguments]     @{counters}
    Log to console      __Get cell power value from PM counters.
    ${pm_files_path}    Get pm counters values  @{counters}
    ${pmcounter_cell_power_mw}      Count power value from given samples  ${M55324C00000}  ${M55324C00400}
    ${pmcounter_cell_power_dbm}     Convert mW To dbm  ${pmcounter_cell_power_mw}
    Log to console      ____Power value from PM counters: ${pmcounter_cell_power_dbm} dBm
    [Return]            ${pmcounter_cell_power_dbm}

Unlock nrcell
    [Arguments]         ${alias}=cOAM
    Log to console      __Unlock NRCELL.
    coam.Connect to     bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}  name=${alias}
    coam.Unlock cell
    ...   dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-${tl.gnbs[0].global_bts_id}/NRCELL_R-1
    ...   connection=${alias}
    ${cell_info}        coam.Get cell specific info
    ...   cell_id=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-${tl.gnbs[0].global_bts_id}/NRCELL_R-1
    ...   connection=${alias}
    ${cell_status}      Get from dictionary  ${cell_info}  status
    Sleep               60 sec
    Dictionary should contain item  ${cell_status}  administrativeState  Unlocked
    Verify if all cells are onair
    [Teardown]          coam.Teardown  connection=${alias}

Lock nrcell
    [Arguments]         ${alias}=cOAM
    Log to console      __Lock NRCELL.
    coam.Connect to     bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}  name=${alias}
    coam.Lock cell
    ...   dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-${tl.gnbs[0].global_bts_id}/NRCELL_R-1
    ...   connection=${alias}
    Sleep               60 sec
    ${cell_info}        coam.Get cell specific info
    ...   cell_id=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-${tl.gnbs[0].global_bts_id}/NRCELL_R-1
    ...   connection=${alias}
    ${cell_status}      Get from dictionary  ${cell_info}  status
    Dictionary should contain item  ${cell_status}  administrativeState  Locked
    [Teardown]          coam.Teardown  connection=${alias}

Start ULDL

    [Documentation]  Used Only by max tputu testing
    [Arguments]  ${protocol}
    ...          ${ue_alias}=AT_BASED_UE_1
    ...          ${tput_duration}=60s
    ...          ${tput_DL_bandwidth}=1350 Mbits/sec
    ...          ${tput_UL_bandwidth}=1350 Mbits/sec
    ...          ${packet_size}=1400
    ute_ue.Start Data Transfer  dt_name=DT_DL  ue_alias=${ue_alias}  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwidth}              protocol=${protocol}       packet_size=${packet_size}
    ...                  max_segment_size=1024
    ute_ue.Start Data Transfer   dt_name=DT_UL   ue_alias=${ue_alias}   direction=ul   duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwidth}              protocol=${protocol}    packet_size=${packet_size}
    ...                  max_segment_size=536
    Sleep                30s
    tput_logs_collecting.Collect Logs During Data Transfer   direction=BOTH
    tput_logs_collecting.Download Logs From GNB    sub_dir=${OUTPUTDIR}/logs

Start ULDL2
    [Documentation]
    [Arguments]  ${protocol}
    ...          ${ue_alias}=AT_BASED_UE_1
    ...          ${tput_duration}=30s
    ...          ${tput_DL_bandwidth}=100 Mbits/sec
    ...          ${tput_UL_bandwidth}=40 Mbits/sec
    ...          ${packet_size}=1400
    ute_ue.Start Data Transfer  dt_name=DT_DL  ue_alias=${ue_alias}  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwidth}              protocol=${protocol}	   packet_size=${packet_size}
    ute_ue.Start Data Transfer  dt_name=DT_UL  ue_alias=${ue_alias}  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwidth}              protocol=${protocol}   packet_size=${packet_size}
    Sleep                10s


Start UL
    [Documentation]
    [Arguments]  ${protocol}
    ...          ${ue_alias}=AT_BASED_UE_1
    ...          ${tput_duration}=60s
    ...          ${tput_UL_bandwidth}=1350 Mbits/sec
    ...          ${packet_size}=1400
    ute_ue.Start Data Transfer  dt_name=DT_UL  ue_alias=${ue_alias}  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwidth}              protocol=${protocol}    packet_size=${packet_size}
    Sleep                2s
    ute_ue.Check Data Transfer Is Alive               DT_UL

Start Max ULDL TCP

    [Documentation]  Used Only by max tputu testing
    [Arguments]  ${protocol}=tcp
    ...          ${ue_alias}=AT_BASED_UE_1
    ...          ${tput_duration}=60s
    ...          ${tput_DL_bandwidth}=1350 Mbits/sec
    ...          ${tput_UL_bandwidth}=1350 Mbits/sec
    ...          ${packet_size}=1400
    ute_ue.Start Data Transfer  dt_name=DT_DL  ue_alias=${ue_alias}  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwidth}              protocol=${protocol}     packet_size=${packet_size}
    ...    parallel_streams=2    packet=1024B    buffer=1M    ttl=64    max_segment_size=1400    linux_congestion=cubic

    ute_ue.Start Data Transfer   dt_name=DT_UL   ue_alias=${ue_alias}   direction=ul   duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwidth}              protocol=${protocol}    packet_size=${packet_size}
    ...    parallel_streams=2    packet=1024B    buffer=1M    ttl=64    max_segment_size=1400    linux_congestion=cubic
    Sleep                30s
    tput_logs_collecting.Collect Logs During Data Transfer   direction=BOTH
    tput_logs_collecting.Download Logs From GNB    sub_dir=${OUTPUTDIR}/logs


Start Max ULDL UDP

    [Documentation]  Used Only by max tputu testing
    [Arguments]  ${protocol}=udp
    ...          ${ue_alias}=AT_BASED_UE_1
    ...          ${tput_duration}=60s
    ...          ${tput_DL_bandwidth}=1350 Mbits/sec
    ...          ${tput_UL_bandwidth}=1350 Mbits/sec
    ...          ${packet_size}=1400
    ute_ue.Start Data Transfer  dt_name=DT_DL  ue_alias=${ue_alias}  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwidth}              protocol=${protocol}     packet_size=${packet_size}
    ute_ue.Start Data Transfer   dt_name=DT_UL   ue_alias=${ue_alias}   direction=ul   duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwidth}              protocol=${protocol}    packet_size=${packet_size}
    Sleep                30s
    tput_logs_collecting.Collect Logs During Data Transfer   direction=BOTH
    tput_logs_collecting.Download Logs From GNB    sub_dir=${OUTPUTDIR}/logs

Perform commissioning for specific TL
    [Arguments]         ${scf_path_branch}    ${scf_path_trunk}    ${alias}=ASIK
    coam.Connect to     name=${alias}
    ${full_ver}         coam.Get sw version   connection=${alias}
    ${ver}              Fetch from left    ${full_ver}    _
    Log to console      __Get SCF and perform commissioning for specific TL. SW release installed on TL: ${ver}.
    Run keyword if      '${ver}'=='5G19A' or '${ver}'=='5G19B' or '${ver}'=='5G20A'
    ...                 coam.Perform commissioning  scf_file=${scf_path_branch}
    ...                                             skip_parameter_relation_errors=${TRUE}
    ...                                             should_activate=${TRUE}
    ...                                             connection=${alias}
    ...  ELSE IF        '${ver}'=='5G20B'
    ...                 coam.Perform commissioning  scf_file=${scf_path_trunk}
    ...                                             skip_parameter_relation_errors=${TRUE}
    ...                                             should_activate=${TRUE}
    ...                                             connection=${alias}
    Verify if all cells are onair
    [Teardown]          coam.Teardown    connection=${alias}


Start tcpdump on gnb ASIK master
    [Arguments]      ${name}=master    ${options}=-i any sctp
    &{vm_config}=    create dictionary     host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...                                    user=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...                                    password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    taf.collectors.tcpdump.create tcpdump collector       name=${name}   options=${options}   executor=${vm_config}
    taf.collectors.tcpdump.set test alias                 ${name}
    core.setup collectors                  names=${name}
    core.start collectors                  names=${name}

Stop pcap collection in gNB ASIK master
    [Arguments]    ${name}=master    ${pcap_path}=/tmp
    core.Stop collectors    names=${name}
    core.Collect collectors    names=${name}    target_dir=${pcap_path}
    core.Teardown collectors    names=${name}
    ${pcap_file}    Join Path    ${pcap_path}    ${name}    ${name}.pcap
    [Return]    ${pcap_file}

#X2 link KW


Check X2 link Up
    coam.Connect to  name=coam
    ${get_lteenb}    coam.get_managed_objects    LTEENB_R    timeout=10    connection=coam
    Run keyword and continue on failure  Should Be Equal As Strings    ${get_lteenb[0]["parameters"]["x2LinkStatus"]}    available
    [Teardown]  coam.Teardown  connection=coam

Break X2 connection
    coam.Connect to   name=coam
    ${x2_param}  coam.get_managed_objects    LTEENB_R    timeout=10    connection=coam
    ${x2_param}  Set variable  ${x2_param[0]['parameters']}
    ${x2_ip}  Set variable  ${x2_param['ipAddr']}
    Connect to ASIK   alias=asik
    ssh.send_command  command=iptables -I INPUT 1 -s ${x2_ip} -j DROP  connection=asik
    [Teardown]  coam.Teardown  connection=coam

Alarm active
    [Arguments]    ${alarm}
    coam.Connect to    name=coam
    coam.Assert Alarm Active   parameters=faultId=${alarm}  connection=coam
    [Teardown]    coam.Teardown     connection=coam

Check NGLink
    coam.Connect to  name=coam
    ${ng_param}  coam.get_parameters  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-${bts_id}/SERVEDAMF_R-1  connection=coam
    ${nglinkstatus}  Set variable  ${ng_param['ngLinkStatus']}
    should be equal as strings  Active  ${nglinkstatus}
    [Teardown]  coam.Teardown  connection=coam

Break AMF connection
    coam.Connect to  name=coam
    ${ip}  coam.get_parameters  /MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-1/SCF-1/MRBTS_A-${bts_id}/NRBTS_A-${bts_id}/SERVEDAMF_A-1  connection=coam
    ${amf_ip}  set variable   ${ip['amfIPAddress']}
    Connect to ASIK  alias=asik
    ssh.send_command  command=iptables -I INPUT 1 -s ${amf_ip} -j DROP connection=asik
    [Teardown]  coam.Teardown  connection=coam

Bring Up connection
    Connect to ASIK  alias=asik
    ssh.send_command  command=iptables -D INPUT 1  connection=asik

Alarm not active
    [Arguments]    ${alarm}
    coam.Connect to    name=coam
    coam.Assert Alarm inactive   parameters=faultId=${alarm}  connection=coam
    [Teardown]    coam.Teardown     connection=coam

Get sm
    [Arguments]    ${alias}=coam
    coam.connect_to  name=${alias}
    ${hw_info}    coam.get_detected_hw_info     connection=${alias}
    [Return]      ${hw_info['systemModules'][0]['productName'][:4]}
    [Teardown]    coam.teardown    connection=${alias}

#MAX_tput_commissoning

Cells setup with given parameters
    [Arguments]     ${bandwidth}
    ${coreset_index}    Create dictionary    10MHz=6
    ...                                      15MHz=6   20MHz=6
    ${msg1Freq}         Create dictionary    10MHz=5
    ...                                      15MHz=7   20MHz=7
    ${nrbts_dist}      Get list of specific object dist name  class_name=NRBTS_A
    ${nrbts_path}      Get from list   ${nrbts_dist}   0
    ${cell_dists}       Get cells distname list
    Log to console   __Cell setup ${bandwidth}
    Initialise Delta Store   name=config_${bandwidth}
    ${cell_dists}       Get cells distname list
    FOR    ${cell}    IN    @{cell_dists}
        ${cell_dist}         Set variable    ${nrbts_path}/${cell}
        Add param to delta   ${cell_dist}                actPdschAtSsbSlots               value=true
        Add param to delta   ${cell_dist}                msg1FrequencyStart               value=${msg1Freq['${bandwidth}']}
        Add param to delta   ${cell_dist}                type0CoresetConfigurationIndex   value=${coreset_index['${bandwidth}']}
        Add param to delta   ${cell_dist}/NRCELL_FDD-1   chBwDl                           value=${bandwidth}
        Add param to delta   ${cell_dist}/NRCELL_FDD-1   chBwUl                           value=${bandwidth}
    END
    ${delta}            Collect delta store
    AdminHelper.Recommission with delta from admin   ${delta}
    Verify if all cells are onair
    Log to console      __Cell setup ended


Cells setup with given parameters 5Mhz
    ${nrbts_dist}      Get list of specific object dist name  class_name=NRBTS_A
    ${nrbts_path}   Get from list  ${nrbts_dist}   0
    ${cell_dists}       Get cells distname list
    Initialise Delta Store    name=config_5Mhz
    FOR    ${cell}    IN    @{cell_dists}
        ${cell_dist}         Set variable    ${nrbts_path}/${cell}
        Add param to delta   ${cell_dist}                actPdschAtSsbSlots               value=false
        Add param to delta   ${cell_dist}                type0CoresetConfigurationIndex   value=0
        Add param to delta   ${cell_dist}/NRCELL_FDD-1   chBwDl                           value=5MHz
        Add param to delta   ${cell_dist}/NRCELL_FDD-1   chBwUl                           value=5MHz
    END
    ${delta}            Collect delta store
    AdminHelper.Recommission with delta from admin   ${delta}
    Verify if all cells are onair
    Log to console      __Cell setup ended

#WA for BTS Bussy


Check calculation ready
#This KW check if all calculations by dcs are done
    ${info_model}  Catenate   SEPARATOR=      /MRBTS-*/RAT-*/DCS-*/CALCULATION_GROUP-*/CALCULATE_UPLANE_DEPLOYMENT_TASK-*
                ...     /CALCULATE_UPLANE_DEPLOYMENT_RESULT-* is [result=Success]
    Setup Infomodel     alias=${asik alias}
    Connect Infomodel    alias=${asik alias}
    Wait until keyword succeeds   900   60   Query Infomodel  every ${info_model}      alias=${asik alias}
   [Teardown]   Teardown Infomodel    alias=${asik alias}


Res UE
    [Arguments]   ${serial}=${UE_POOLS['AndroidUePool']['inline_config']['UE_1']['CONSTRUCTOR_PARAMETERS']['serial_number']}
    ...           ${ue_ps_ip}=${UE_POOLS['AndroidUePool']['inline_config']['UE_1']['CONSTRUCTOR_PARAMETERS']['configuration']['ue_pc_ip']}
    ...           ${ue_pc_user}=${UE_POOLS['AndroidUePool']['inline_config']['UE_1']['CONSTRUCTOR_PARAMETERS']['configuration']['login']}
    ...           ${ue_pc_pass}=${UE_POOLS['AndroidUePool']['inline_config']['UE_1']['CONSTRUCTOR_PARAMETERS']['configuration']['password']}
    ...           ${timeout}=240s
    ssh.Connect to   ${ue_ps_ip}    ${ue_pc_user}    ${ue_pc_pass}    alias=uepc_conn
    ${cmd}    Set Variable    adb -s ${serial} reboot
    ssh.Send Command    ${cmd}    connection=uepc_conn
    sleep    ${timeout}
