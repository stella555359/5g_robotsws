*** Settings ***
Documentation
...         Editor: Wiktor Jarosinski
...         Edit Reason: Migration Robot5.0
...         Contact Person: Pawel Wisniewski
...         Commmon KW
Library    Collections
Library    OperatingSystem
Library    DateTime
Library    String
Library    SeleniumLibrary
Library    taf.analyzer.pdml
Library    taf.transport.ssh  WITH NAME  ssh
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    testsuite.Wroclaw.RRM.resources.webui.WebuiInterface  WITH NAME  WebUI
Library    taf.converters.pcaptopdml   WITH NAME   pcaptopdml
Library    taf.hw.rf_attenuator    WITH NAME    att
Library    taf.collectors.tcpdump
Library    taf.collectors.core        WITH NAME    core
Library    taf.collectors.btslog  WITH NAME   btslog
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/AdminHelper.py
Library    taf/rfrl/ue/logs/tput_logs_collecting.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pdu.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/SyslogAnalyzer.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/DeltaStore.py
Library    taf.sw.reporting_portal
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pmcounters.robot
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/math.robot
Resource   testsuite/Wroclaw/RRM/resources/logs.robot
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/ConnectivityKeywords.robot
Resource   taf/rfrl/common_resources/common_step/interface.robot

Variables  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/testline_mapping.py

*** Variables ***
${asik alias}            ASIK
${ENB_M_PLANE}           ${tl.enbs[0].m.v4}
${MRBTS_4G_ID}           ${tl.enbs[0].instance_id}
${MRBTS_5G_ID}           ${tl.gnbs[0].instance_id}
${GNB_CONNECTION_ALIAS}  gNB
${ENB_CONNECTION_ALIAS}  eNB
${SWCONFIG_PATH}         /home/ute/robotws/swconfigs_${SUITE_NAME}


*** Keywords ***

Connect with runtime release
    [Arguments]      ${alias}=coam
    coam.connect to  name=${alias}
    ${release}=   Wait Until Keyword Succeeds   5 min   1 min   common_kw.Get Software release name   ${alias}
    coam.teardown    connection=${alias}
    coam.connect_to  name=${alias}             release=${release}

Check for alarms
    [Documentation]  Allow to check alarms also on eNB site
    [Arguments]  ${alias}
    @{severities}  Create list  critical  major
    FOR  ${severity}  IN  @{severities}
      ${alarms}  coam.get active alarms  ${severity}  ${alias}  60
      ${len}=  Get length  ${alarms}
      Should Be Equal  ${len}  ${0}  ${severity} alarm on BTS occured  ${False}
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
    [Arguments]  ${administrativeState}=unlocked
#    ...          ${availabilityStatus}=Online
    ...          ${operationalState}=enabled
    ...          ${usageState}=Idle
    ...          ${blockingState}=Unblocked
    ${expected status}  Create dictionary
    ...                 administrativeState=${administrativeState}
#    ...                 availabilityStatus=${availabilityStatus}
    ...                 operationalState=${operationalState}
    ...                 usageState=${usageState}
    ...                 blockingState=${blockingState}
    ${bts_info}=  coam.get bts info  60  ${ENB_CONNECTION_ALIAS}
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
    Connect with runtime release     ${alias}
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
    Connect with runtime release     ${alias}
    ${object}           coam.Get bts info   connection=${alias}
    ${config_type}      Get from dictionary  ${object}  gNbCuType
    Log to console      Current config type: ${config_type}
    [Return]            ${config_type}
    [Teardown]          coam.Teardown     connection=${alias}

Upload scf and perform commissioning
    [Arguments]         ${scf_path}
    ...                 ${timeout}=600sec
    ...                 ${alias}=recommissioning
    Log to console      Upload SCF to the Test Line
    Connect with runtime release     ${alias}
    coam.Perform commissioning
    ...                 bts_id=${MRBTS_5G_ID}
    ...                 scf_file=${scf_path}
    ...                 skip_parameter_relation_errors=${FALSE}
    ...                 should_activate=${TRUE}
    ...                 timeout=${timeout}
    ...                 connection=${alias}
    Wait Until Sw Update Possible
    [Teardown]          coam.Teardown  connection=${alias}

Verify if all cells are onair
    Log To Console      Verify if all cells are onair
    [Arguments]    ${duration}=900 sec    ${interval}=60 sec
    Wait until keyword succeeds    ${duration}    ${interval}    Check cells are on air

Check cells are on air
    Connect with runtime release    coam
    ${c_info}    coam.get cells info    cell_type=nr    connection=coam
    verify cells statuses    ${c_info}
    [Teardown]    coam.teardown  connection=coam

Verify if BTS is Online
    [Arguments]    ${duration}=900 sec    ${interval}=60 sec
    Wait until keyword succeeds    ${duration}    ${interval}    BTS state Online
    Log To Console      Verify if BTS is Online
Wait for counters
    [Arguments]         ${sleep_timer}=5 min
    [Documentation]
    ...     This KW waits for counters and collects their values.
    Log to console      __Wait ${sleep_timer} for counters.
    BuiltIn.Sleep               ${sleep_timer}

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
    Run keyword If    not ${is_number_of_samples_in_range}
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
    Run keyword If    ${M55324C00000} != 0
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
    ${status}   Run Keyword And Return Status    Set attenuation and check    lines=${lines}    value=${0}
    Run Keyword If    '${status}' == 'False'      Run Keywords
    ...    Reset Attenuator     AND
    ...    Setup attenuators    AND
    ...    Set attenuation and check    lines=${lines}    value=${0}

Reset Attenuator
    log to console    __Something went wrong, attenuator reset ongoing...
    Open Browser      http://${tl.attenuator.ip_addr}/    headlesschrome
    BuiltIn.sleep  5s
    Click Element    xpath=/html/body/p[8]/font/input[3]
    BuiltIn.sleep  30s
    [Teardown]  Close Browser

Turn on attenuation
    ${lines}    Get dictionary keys     ${tl.attenuator.attenuator_ports}
    Set attenuation and check    lines=${lines}    value=${90}

Slow attenuate cell from min to max
    [Arguments]  ${for_port}    ${min_value}   ${max_value}    ${step}
    FOR  ${att_current_value}  IN RANGE  ${min_value}  ${max_value}  ${step}
        set attenuation and check   ${for_port}  value=${att_current_value}
        BuiltIn.Sleep   2s
    END

Get cell ids
    [Arguments]     ${alias}=cOAM    ${adminState}=all
    ${ids}     Create list
    Connect with runtime release    ${alias}
    ${cells}    coam.Get managed objects    class_name=NRCELL_A   connection=${alias}
    FOR    ${cell_id}    IN    @{cells}
        Run keyword if    '${adminState}'!='all'
        ...           Continue for loop if    '${cell_id['parameters']['administrativeState']}'!='${adminState}'
        ${id}    Fetch from right    ${cell_id['distName']}    NRCELL_A-
        Append to list    ${ids}    ${id}
    END
    [Teardown]    coam.Teardown     connection=${alias}
    [Return]    ${ids}

Attach ue to lte cell
    [Arguments]         ${ue_alias}=AT_BASED_UE_1
    Log to console      Attach ${ue_capabilities} to cell
    Attach ue           ${ue_alias}
    BuiltIn.Sleep               10sec

Detach ue from cell
    [Arguments]             ${ue_alias}=AT_BASED_UE_1
    Log to console      Detach UE
    Detach ue           ${ue_alias}


Get cell power from pm counters
    [Arguments]     @{counters}
    Log to console      __Get cell power value from PM counters.
    ${pm_files_path}    Get pm counters values  @{counters}
    ${pmcounter_cell_power_mw}      Count power value from given samples  ${M55324C00000}  ${M55324C00400}
    ${pmcounter_cell_power_dbm}     Convert mW To dbm  ${pmcounter_cell_power_mw}
    Log to console      ____Power value from PM counters: ${pmcounter_cell_power_dbm} dBm
    [Return]            ${pmcounter_cell_power_dbm}
    Log To Console      ${pm_files_path}

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
    BuiltIn.Sleep               60 sec
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
    BuiltIn.Sleep               60 sec
    ${cell_info}        coam.Get cell specific info
    ...   cell_id=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-${tl.gnbs[0].global_bts_id}/NRCELL_R-1
    ...   connection=${alias}
    ${cell_status}      Get from dictionary  ${cell_info}  status
    Dictionary should contain item  ${cell_status}  administrativeState  Locked
    [Teardown]          coam.Teardown  connection=${alias}

Start ULDL
    [Arguments]  ${protocol}=tcp
    ...          ${ue_alias}=AT_BASED_UE_1
    ...          ${tput_duration}=60s
    ...          ${tput_DL_bandwidth}=1350 Mbits/sec
    ...          ${tput_UL_bandwidth}=1350 Mbits/sec
    ...          ${packet_size}=1400
    taf.ue.Start Data Transfer  dt_name=DT_DL  ue_alias=${ue_alias}  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwidth}              protocol=${protocol}     packet_size=${packet_size}
    ...    parallel_streams=2    buffer=3M      max_segment_size=1024
    BuiltIn.Sleep    10s
    taf.ue.Start Data Transfer   dt_name=DT_UL   ue_alias=${ue_alias}   direction=ul   duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwidth}              protocol=${protocol}    packet_size=${packet_size}
    ...    parallel_streams=2    buffer=2M     max_segment_size=1024
    BuiltIn.Sleep    30s

Start ULDL2
    [Documentation]
    [Arguments]  ${protocol}
    ...          ${ue_alias}=AT_BASED_UE_1
    ...          ${tput_duration}=30s
    ...          ${tput_DL_bandwidth}=100 Mbits/sec
    ...          ${tput_UL_bandwidth}=40 Mbits/sec
    ...          ${packet_size}=1400
    taf.ue.Start Data Transfer  dt_name=DT_DL  ue_alias=${ue_alias}  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwidth}              protocol=${protocol}	   packet_size=${packet_size}
    taf.ue.Start Data Transfer  dt_name=DT_UL  ue_alias=${ue_alias}  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwidth}              protocol=${protocol}   packet_size=${packet_size}
    BuiltIn.Sleep                10s


Start UL
    [Documentation]
    [Arguments]  ${protocol}
    ...          ${ue_alias}=UE
    ...          ${tput_duration}=60s
    ...          ${tput_UL_bandwidth}=1350 Mbits/sec
    ...          ${packet_size}=1400
    taf.ue.Start Data Transfer  dt_name=DT_UL  ue_alias=${ue_alias}  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwidth}              protocol=${protocol}    packet_size=${packet_size}
    BuiltIn.Sleep                2s
    taf.ue.Check Data Transfer Is Alive               DT_UL

Start Max ULDL TCP
    [Documentation]  Used Only by max tputu testing
    [Arguments]  ${protocol}=tcp
    ...          ${ue_alias}=AT_BASED_UE_1
    ...          ${tput_duration}=300s
    ...          ${tput_DL_bandwidth}=1350 Mbits/sec
    ...          ${tput_UL_bandwidth}=1350 Mbits/sec
    ...          ${packet_size}=1400
    taf.ue.Start Data Transfer  dt_name=DT_DL  ue_alias=${ue_alias}  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwidth}              protocol=${protocol}     packet_size=${packet_size}
#    ...    parallel_streams=2    buffer=3M      max_segment_size=1024
    BuiltIn.Sleep    10s
    taf.ue.Start Data Transfer   dt_name=DT_UL   ue_alias=${ue_alias}   direction=ul   duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwidth}              protocol=${protocol}    packet_size=${packet_size}
    ...    parallel_streams=2    buffer=2M
#    ...    max_segment_size=1024
    BuiltIn.Sleep    15s
    # We need to find another method
    #tput_logs_collecting.Collect Logs During Data Transfer   direction=BOTH
    #tput_logs_collecting.Download Logs From GNB    sub_dir=${OUTPUTDIR}/logs

Start Max ULDL TCP SFE
    [Documentation]  Used Only by max tputu testing
    [Arguments]  ${protocol}=tcp
    ...          ${ue_alias}=AT_BASED_UE_1
    ...          ${tput_duration}=10m
    ...          ${tput_DL_bandwidth}=2 Gbits/sec
    ...          ${tput_UL_bandwidth}=1350 Mbits/sec
    ...          ${packet_size}=1400
    taf.ue.Start Data Transfer  dt_name=DT_DL  ue_alias=${ue_alias}  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwidth}              protocol=${protocol}     packet_size=${packet_size}
    BuiltIn.Sleep    10s
    taf.ue.Start Data Transfer   dt_name=DT_UL   ue_alias=${ue_alias}   direction=ul   duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwidth}              protocol=${protocol}    packet_size=${packet_size}
    BuiltIn.Sleep    30s

Start Max ULDL UDP
    [Documentation]  Used Only by max tputu testing
    [Arguments]  ${protocol}=udp
    ...          ${ue_alias}=AT_BASED_UE_1
    ...          ${tput_duration}=300s
    ...          ${tput_DL_bandwidth}=1350 Mbits/sec
    ...          ${tput_UL_bandwidth}=1350 Mbits/sec
    ...          ${packet_size}=1200
    ...          ${dt_DL_name}=DT_DL
    ...          ${dt_UL_name}=DT_UL
    taf.ue.Start Data Transfer  dt_name=${dt_DL_name}  ue_alias=${ue_alias}  direction=dl  duration=${tput_duration}
    ...    throughput=${tput_DL_bandwidth}              protocol=${protocol}    packet_size=${packet_size}
    ...    buffer=1M    max_segment_size=512
    BuiltIn.Sleep    10

    taf.ue.Start Data Transfer   dt_name=${dt_UL_name}   ue_alias=${ue_alias}   direction=ul   duration=${tput_duration}
    ...    throughput=${tput_UL_bandwidth}              protocol=${protocol}    packet_size=${packet_size}
    ...    buffer=1M    max_segment_size=512
    BuiltIn.Sleep    15s

Stop ULDL
    [Arguments]     ${dt_DL_name}=DT_DL
    ...             ${dt_UL_name}=DT_UL
    taf.ue.Stop Data Transfer  dt_name=${dt_UL_name}
    taf.ue.Stop Data Transfer  dt_name=${dt_DL_name}

Perform commissioning for specific TL
    [Arguments]         ${scf_path_branch}    ${scf_path_trunk}    ${alias}=ASIK
    Connect with runtime release     ${alias}
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

#X2 link KW


Check X2 link Up
    Connect with runtime release  coam
    ${get_lteenb}    coam.get_managed_objects    LTEENB_R    timeout=10    connection=coam
    Run keyword and continue on failure  Should Be Equal As Strings    ${get_lteenb[0]["parameters"]["x2LinkStatus"]}    available
    [Teardown]  coam.Teardown  connection=coam

Break X2 connection
    Connect with runtime release   coam
    ${x2_param}  coam.get_managed_objects    LTEENB_R    timeout=10    connection=coam
    ${x2_param}  Set variable  ${x2_param[0]['parameters']}
    ${x2_ip}  Set variable  ${x2_param['ipAddr']}
    Connect to ASIK   alias=asik
    ssh.send_command  command=iptables -I INPUT 1 -s ${x2_ip} -j DROP  connection=asik
    [Teardown]  coam.Teardown  connection=coam

Alarm active
    [Arguments]    ${alarm}
    Connect with runtime release    coam
    coam.Assert Alarm Active   parameters=faultId=${alarm}  connection=coam
    [Teardown]    coam.Teardown     connection=coam

Check NGLink
    Connect with runtime release  coam
    ${ng_param}  coam.get_parameters  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-${bts_id}/SERVEDAMF_R-1  connection=coam
    ${nglinkstatus}  Set variable  ${ng_param['ngLinkStatus']}
    should be equal as strings  Active  ${nglinkstatus}
    [Teardown]  coam.Teardown  connection=coam

Break AMF connection
    Connect with runtime release  coam
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
    Connect with runtime release    coam
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
    ...                                      15MHz=6   20MHz=12
    ${msg1Freq}         Create dictionary    10MHz=9
    ...                                      15MHz=9   20MHz=9
    ${nrbts_dist}      Get list of specific object dist name  class_name=NRBTS_A
    ${nrbts_path}      Get from list   ${nrbts_dist}   0
    ${cell_dists}       Get cells distname list
    Log to console   __Cell setup ${bandwidth}
    Initialise Delta Store   name=config_${bandwidth}
    ${cell_dists}       Get cells distname list
    ${check_release}    common.Check Release Is Higher Than   SBTS24R2
    FOR    ${cell}    IN    @{cell_dists}
        ${cell_dist}         Set variable    ${nrbts_path}/${cell}
        run keyword if     ${check_release}
        ...    Add param to delta   ${cell_dist}                actPdschAllocAroundSsb           value=true
        Add param to delta   ${cell_dist}                actPdschAllocAroundSsb           value=true
        Add param to delta   ${cell_dist}                actPdschAtSsbSlots               value=true
        Add param to delta   ${cell_dist}                msg1FrequencyStart               value=${msg1Freq['${bandwidth}']}
        Add param to delta   ${cell_dist}                type0CoresetConfigurationIndex   value=${coreset_index['${bandwidth}']}
        Add param to delta   ${cell_dist}                reqMinNumPuschPrb                value=19
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
        Add param to delta   ${cell_dist}                actPdschAllocAroundSsb           value=false
        Add param to delta   ${cell_dist}                actPdschAtSsbSlots               value=false
        Add param to delta   ${cell_dist}                type0CoresetConfigurationIndex   value=0
        Add param to delta   ${cell_dist}                reqMinNumPuschPrb                value=17
        Add param to delta   ${cell_dist}/NRCELL_FDD-1   chBwDl                           value=5MHz
        Add param to delta   ${cell_dist}/NRCELL_FDD-1   chBwUl                           value=5MHz
    END
    ${delta}            Collect delta store
    AdminHelper.Recommission with delta from admin   ${delta}
    Verify if all cells are onair
    Log to console      __Cell setup ended

#WA for BTS Bussy

Wait Until Sw Update Possible
    [Arguments]    ${bts_ready}=${True}
    ...            ${readiness_timeout}=3600
    ...            ${timeout}=3600
    Connect with runtime release    bts_r
    ${result}     coam.Wait Sw Update Possible
    ...    bts_ready=${bts_ready}
    ...    readiness_timeout=${readiness_timeout}
    ...    timeout=${timeout}
    ...    connection=bts_r
    [Teardown]    coam.Teardown     connection=bts_r
    Log To Console  ${result}


Res UE
    import variables    ${tl.ues[0]}
    ${serial}  set variable
    ...  ${UE_POOLS['AndroidUePool']['inline_config']['UE_1']['CONSTRUCTOR_PARAMETERS']['serial_number']}
    ${ue_ps_ip}  set variable
    ...  ${UE_POOLS['AndroidUePool']['inline_config']['UE_1']['CONSTRUCTOR_PARAMETERS']['configuration']['ue_pc_ip']}
    ${ue_pc_user}  set variable
    ...  ${UE_POOLS['AndroidUePool']['inline_config']['UE_1']['CONSTRUCTOR_PARAMETERS']['configuration']['login']}
    ${ue_pc_pass}  set variable
    ...  ${UE_POOLS['AndroidUePool']['inline_config']['UE_1']['CONSTRUCTOR_PARAMETERS']['configuration']['password']}
    ${timeout}  set variable  240s

    ssh.Connect to   ${ue_ps_ip}    ${ue_pc_user}    ${ue_pc_pass}    alias=uepc_conn
    ${cmd}    Set Variable    adb -s ${serial} reboot
    ssh.Send Command    ${cmd}    connection=uepc_conn
    BuiltIn.sleep    ${timeout}

Reset UEs
    [Arguments]  ${ue_aliases}  ${time_for_reboot}=60s
    ${ue_ps_ip}  ${ue_pc_user}  ${ue_pc_pass}  Get connection to UEPC
    @{serials}  Create list
    FOR  ${UE_alias}  IN  @{ue_aliases}
        ${serial}  taf.ue.get tool specific Ue Id  ${UE_alias}
        Append to list  ${serials}  ${serial}
        Log to console  UE ${serial} going to be reseted
    END
    ssh.Connect to   ${ue_ps_ip}    ${ue_pc_user}    ${ue_pc_pass}    alias=uepc_conn
    FOR  ${serial}  IN  @{serials}
        ${cmd}    Set Variable    adb -s ${serial} reboot
        ssh.Send Command    ${cmd}    connection=uepc_conn
        BuiltIn.sleep  5s
    END
    ssh.disconnect  connection=uepc_conn
    Log to console  Wait for UEs reboot
    BuiltIn.sleep  ${time_for_reboot}

Delete pyro_server UEPC
    [Documentation]
    ...    Because of migration to `taf.ue` deleting pyro server fails. Body of this keyword was moved
    ...    to `Delete pyro_server UEPC body` keyword to wrap it into `Run Keyword ANd Ignore Error`. Thanks to this
    ...    solution we can still use our legacy code and we don't have to remove this keyword.

    Run Keyword And Ignore Error    Delete pyro_server UEPC body
    Log To Console  Delete pyro_server UEPC

Delete pyro_server UEPC body
    [Documentation]
    ...    Use this keyword only in `Delete pyro_server UEPC`.

    ${ue_ps_ip}  ${ue_pc_user}  ${ue_pc_pass}  Get connection to UEPC
    ssh.Connect to   ${ue_ps_ip}    ${ue_pc_user}    ${ue_pc_pass}    alias=uepc_conn
    ${cmd}    Set Variable    rm -rf /cygdrive/c/pyro_server
    ssh.Send Command    ${cmd}    connection=uepc_conn
    ssh.disconnect  connection=uepc_conn

Delete UE logs from UEPC
    ${ue_ps_ip}  ${ue_pc_user}  ${ue_pc_pass}  Get connection to UEPC
    ssh.Connect to   ${ue_ps_ip}    ${ue_pc_user}    ${ue_pc_pass}    alias=uepc_conn
    ${cmd}    Set Variable    rm -rf /cygdrive/c/auto/ue_logs.hdf
    ssh.Send Command    ${cmd}    connection=uepc_conn
    ${cmd}    Set Variable    rm -rf /cygdrive/c/auto/ue_logs.txt
    ssh.Send Command    ${cmd}    connection=uepc_conn
    ssh.disconnect  connection=uepc_conn
    Log to console  UE logs deleted from UEPC

Get connection to UEPC
    import variables    ${tl.ues[0]}
    ${ue_ps_ip}  set variable
    ...  ${UE_POOLS['AndroidUePool']['inline_config']['UE_1']['CONSTRUCTOR_PARAMETERS']['configuration']['ue_pc_ip']}
    ${ue_pc_user}  set variable
    ...  ${UE_POOLS['AndroidUePool']['inline_config']['UE_1']['CONSTRUCTOR_PARAMETERS']['configuration']['login']}
    ${ue_pc_pass}  set variable
    ...  ${UE_POOLS['AndroidUePool']['inline_config']['UE_1']['CONSTRUCTOR_PARAMETERS']['configuration']['password']}
    [Return]  ${ue_ps_ip}  ${ue_pc_user}  ${ue_pc_pass}

Delete UE logs from VM
    Run  rm /home/ute/robotws/ue_logs.txt
    Run  rm /home/ute/robotws/5g_dl.txt
    Run  rm /home/ute/robotws/5g_ul.txt
    Run  rm /home/ute/robotws/lte_dl.txt
    Run  rm /home/ute/robotws/lte_ul.txt
    Log to console  UE logs deleted from VM

Get technology cell distname list
    [Arguments]    ${technology}=FDD
    Connect with runtime release    dist
    ${ids}    get_nrcell_r_distname_list
    ${cell_list}   Create list
    FOR  ${id}  IN   @{ids}
        ${celka}  coam.get_cell_specific_info  ${id}    connection=dist
        ${dist}  set variable   ${celka['id']['configuration']}
        ${tech}  set variable  ${celka['technology']}
        Run keyword if  '${tech}'=='${technology}'   Append to list  ${cell_list}   ${dist}
    END
    Set test variable   ${cell_list}
    [Teardown]    coam.Teardown     connection=dist


Set attenuation
    [Arguments]      ${lines}    ${value}
    FOR    ${line}    IN    @{lines}
        att.Set attenuation     port=${${line}}     value=${${value}}
    END
    Log To Console  Set attenuation

Interval attenuation
    [Arguments]      ${lines}    ${attenuation}=strengthen    ${min}=0    ${max}=90
    ...              ${interval_time}=0.2
    ${add_or_sub}    Set variable if    '${attenuation}'=='strengthen'    1    -1
    ${value}    Set variable if    '${attenuation}'=='strengthen'    ${min}    ${max}
    FOR    ${iteration}    IN RANGE    ${min}    ${max}
        log    ${iteration}    level=TRACE
        ${value}    Evaluate    ${value}+${add_or_sub}
        Set attenuation     lines=${lines}    value=${${value}}
        BuiltIn.Sleep    ${interval_time}
    END

Get counters
    [Arguments]  ${counters_to_get}
    Connect with runtime release   counter
    &{results}    coam.get pm counters    ${counters_to_get}   connection=counter  timeout=300
    coam.teardown   connection=counter
    [Return]  &{results}

Get counters from dictionary
    [Arguments]   ${dict}   @{list}
    FOR  ${counter}   IN   @{list}
        ${val}  get from dictionary  ${dict}  ${counter}
        Set test variable  ${${counter}}  ${val}
    END

Setup attenuators
    [Arguments]    ${atten_ip}=${tl.attenuator.ip_addr}
    ...            ${att_api_port}=${tl.attenuator.port}
    ...            ${atten_ports}=${tl.attenuator.attenuator_ports}
    ...            ${max_attenuation_value}=${90}
    ...            ${atten_vendor}=TopYoung
    ...            ${atten_model}=${tl.attenuator.model}
    ${status}   Run Keyword And Return Status    att.Setup attenuator
    ...    ip_addr=${atten_ip}
    ...    port=${att_api_port}
    ...    attenuation_port_numbers=${atten_ports}
    ...    max_attenuation=${max_attenuation_value}
    ...    vendor=${atten_vendor}
    ...    model=${atten_model}
    Run Keyword If    '${status}' == 'False'      Run Keywords
    ...    Reset Attenuator    AND
    ...    att.Setup attenuator
    ...    ip_addr=${atten_ip}
    ...    port=${att_api_port}
    ...    attenuation_port_numbers=${atten_ports}
    ...    max_attenuation=${max_attenuation_value}
    ...    vendor=${atten_vendor}
    ...    model=${atten_model}

Set administrativeState for all gNB cells
    [Arguments]     ${alias}=coam  ${status}=Unlocked
    Log to console  Setting administrativeState for all cells to ${status}
    ${cells_info}=  coam.get cells info  nr  60  ${alias}
    FOR  ${cell}  IN  @{cells_info}
      ${object}  Set Variable  ${cell['id']['configuration']}
      coam.perform_parameter_recommissioning  ${object}  administrativeState  update  ${status}  ${True}  ${True}  240  ${alias}
      BuiltIn.sleep  5s
    END

Bar all gNB cells
    [Arguments]     ${alias}=${GNB_CONNECTION_ALIAS}
    ${cells_info}=  coam.get cells info  nr  60  ${alias}
    FOR  ${cell}  IN  @{cells_info}
      ${object}  Set Variable  ${cell['id']['configuration']}
      coam.perform_parameter_recommissioning  ${object}  cellBarred  update  barred  ${True}  ${True}  240  ${alias}
      BuiltIn.sleep  5s
    END

Bar specific gNB cells
    [Arguments]     ${IDs_list}  ${alias}=${GNB_CONNECTION_ALIAS}
    log to console  Barring ${IDs_list} 5G cells
    FOR  ${ID}  IN  @{IDs_list}
      ${object}  Set Variable  MRBTS-${MRBTS_5G_ID}/NRBTS-${MRBTS_5G_ID}/NRCELL-${ID}
      coam.perform_parameter_recommissioning  ${object}  cellBarred  update  barred  ${True}  ${True}  240  ${alias}
      BuiltIn.sleep  5s
    END

Bar all eNB cells
    [Arguments]     ${alias}=${ENB_CONNECTION_ALIAS}
    ${cells_info}=  coam.get cells info  lte  60  ${alias}
    FOR  ${cell}  IN  @{cells_info}
      ${object}  Set Variable  ${cell['id']['configuration']}/SIB-0
      coam.perform_parameter_recommissioning  ${object}  cellBarred  update  barred  ${True}  ${True}  240  ${alias}
      BuiltIn.sleep  5s
    END

Bar specific eNB cells
    [Arguments]     ${IDs_list}  ${alias}=${ENB_CONNECTION_ALIAS}
    log to console  Barring ${IDs_list} LTE cells
    FOR  ${ID}  IN  @{IDs_list}
      ${object}  Set Variable  MRBTS-${MRBTS_4G_ID}/LNBTS-${MRBTS_4G_ID}/LNCEL-${ID}/SIB-0
      coam.perform_parameter_recommissioning  ${object}  cellBarred  update  barred  ${True}  ${True}  240  ${alias}
      BuiltIn.sleep  5s
    END

Unbar all gNB cells
    [Arguments]     ${alias}=${GNB_CONNECTION_ALIAS}
    ${cells_info}=  coam.get cells info  nr  60  ${alias}
    FOR  ${cell}  IN  @{cells_info}
      ${object}  Set Variable  ${cell['id']['configuration']}
      coam.perform_parameter_recommissioning  ${object}  cellBarred  update  notBarred  ${True}  ${True}  240  ${alias}
      BuiltIn.sleep  5s
    END

Unbar all eNB cells
    [Arguments]     ${alias}=${ENB_CONNECTION_ALIAS}
    ${cells_info}=  coam.get cells info  lte  60  ${alias}
    FOR  ${cell}  IN  @{cells_info}
      ${object}  Set Variable  ${cell['id']['configuration']}/SIB-0
      coam.perform_parameter_recommissioning  ${object}  cellBarred  update  notBarred  ${True}  ${True}  240  ${alias}
      BuiltIn.sleep  5s
    END

Check coreRestartCounter
    [Documentation]  This kw checks coreRestartCounter value. If coreRestartCounter value is >0
    ...             means SMOD had more resets. KW will work for fullrack.
    [Arguments]    ${acceptable_number_of_resets}=0   ${connection}=core
    Connect with runtime release    ${connection}
    ${SMOD}    coam.Get managed objects    class_name=SMOD_L   connection=${connection}
    FOR    ${id}    IN    @{SMOD}
        ${core}    Set variable    ${id['parameters']['coreRestartCounter']}
        Run keyword if    ${core}==${acceptable_number_of_resets}   Log to console  coreRestartCounter not incremented
        ...               ELSE   FAIL  coreRestartCounter incremented! Please check logs.
    END
    [Teardown]    coam.Teardown     connection=${connection}

Connect to gNB and eNB
    [Arguments]  ${gnb_alias}=${GNB_CONNECTION_ALIAS}  ${enb_alias}=${ENB_CONNECTION_ALIAS}
    Connect with runtime release  ${gnb_alias}
    coam.connect_to          name=${enb_alias}  bts_host=${ENB_M_PLANE}

Get Software release name
    [Arguments]   ${alias}
    ${release}       coam.Get sw release name  connection=${alias}
    Should not be empty   ${release}
    [Return]   ${release}

Check tput drops from syslog
    [Arguments]  ${path_to_syslog}
    ${dl}    get_L2Hi_DL_tput  ${path_to_syslog}
    ${ul}    get_L2Hi_UL_tput  ${path_to_syslog}
    check tput drops    ${dl[3]}    downlink
    check tput drops    ${ul[3]}    uplink

Get max DLUL from syslog
    [Arguments]  ${path_to_syslog}=${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/SYSLOG.LOG
#    ${max_dl}    get_L2Hi_DL_tput  ${path_to_syslog}  # TODO: FORMER SOLUTION
#    ${max_ul}    get_L2Hi_UL_tput  ${path_to_syslog}  # TODO: FORMER SOLUTION
    ${max_dl}    get_L2Hi_DL_tput_with_time  ${path_to_syslog}
    ${max_ul}    get_L2Hi_UL_tput_with_time  ${path_to_syslog}
    ${max_dl}    Evaluate  int(${max_dl[2]})/1000
    ${max_ul}    Evaluate  int(${max_ul[2]})/1000
    [Return]  ${max_dl}  ${max_ul}

Get min DLUL from syslog
    [Arguments]  ${path_to_syslog}=${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/SYSLOG.LOG
#    ${min_dl}    get_L2Hi_DL_tput  ${path_to_syslog}  # TODO: FORMER SOLUTION
#    ${min_ul}    get_L2Hi_UL_tput  ${path_to_syslog}  # TODO: FORMER SOLUTION
    ${min_dl}    get_L2Hi_DL_tput_with_time  ${path_to_syslog}
    ${min_ul}    get_L2Hi_UL_tput_with_time  ${path_to_syslog}
    ${min_dl}    Evaluate  int(${min_dl[1]})/1000
    ${min_ul}    Evaluate  int(${min_ul[1]})/1000
    [Return]  ${min_dl}  ${min_ul}

Get avg DLUL from syslog
    [Arguments]  ${path_to_syslog}=${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/SYSLOG.LOG
#    ${avg_dl}    get_L2Hi_DL_tput  ${path_to_syslog}  # TODO: FORMER SOLUTION
#    ${avg_ul}    get_L2Hi_UL_tput  ${path_to_syslog}  # TODO: FORMER SOLUTION
    ${avg_dl}    get_L2Hi_DL_tput_with_time  ${path_to_syslog}
    ${avg_ul}    get_L2Hi_UL_tput_with_time  ${path_to_syslog}
    ${avg_dl}    Evaluate  int(${avg_dl[0]})/1000
    ${avg_ul}    Evaluate  int(${avg_ul[0]})/1000
    [Return]  ${avg_dl}  ${avg_ul}

Fast L3Call Check
    [Arguments]    ${ue}=UE
    taf.ue.attach Ue   ${ue}
    BuiltIn.sleep  3s
    Start Max ULDL TCP    ue_alias=${ue}
    BuiltIn.sleep    10s
    Stop ULDL
    BuiltIn.sleep  10s

Setup tcpdump collector
    Set suite variable    ${tcpdump_collector_name}    vm_tti_trace
    ${interface}=  set variable   eth0
    ${port}=    set variable    5678

    tcpdump.Create tcpdump collector
    ...     name=${tcpdump_collector_name}
    ...     options=-i ${interface} port ${port}
    ...     capture_locally=true

    core.Setup collectors    ${tcpdump_collector_name}
    core.Set Suite Alias     ${tcpdump_collector_name}

Start tcpdump collector
    core.Start collectors    ${tcpdump_collector_name}
    Log To Console           Start tcpdump collector

Stop tcpdump collector
    [Arguments]    ${feature}
    ${log_dir}=  Set variable   ${OUTPUTDIR}/testsuite/Wroclaw/RRM/VRF_WRO2_T01/${feature}/resources
    core.Stop collectors      ${tcpdump_collector_name}
    core.Collect collectors   ${tcpdump_collector_name}    target_dir=${log_dir}

Setup TTI Trace Collection
    ${source_ip_v}=  l2_trace.get source ip
    set suite variable    ${source_ip}    ${source_ip_v}

Enable TTI Trace
    [Arguments]   ${nr_cell_dns}=None
    Run keyword if   ${nr_cell_dns} == None   Get nr cell dns for PS
    l2_trace.start l2 trace
    ...               interface_ip=${source_ip}
    ...               vm_ip=${tl.test_pc.default_ssh_connection_details.addr}
    ...               cell_dns=${nr_cell_dns}

Get nr cell dns for PS
    coam.connect to
    ${a}     coam.get cell list
    ${a_list}   Set variable   ${a['cells']['nr']}
    ${length}=   Get Length   ${a_list}
    ${cell_list}=  create list
    FOR  ${i}   IN RANGE   ${length}
        Append To List   ${cell_list}   ${a_list[${i}]['id']['internal']}
    END
    Sort List   ${cell_list}
    coam.teardown
    ${first_cell}=      Create list     ${cell_list[0]}
    set suite variable    ${nr_cell_dns}    ${first_cell}

Disable TTI Trace
    l2_trace.stop l2 trace
    Log To Console        Disable TTI Trace

Update mo and parameter to delta
    [Arguments]    ${nrbts_distname}    &{kwargs}
    add managed object and parameter to delta    dist_name=${nrbts_distname}    &{kwargs}
    Log To Console        Update mo and parameter to delta

Create output channels lists
    [Arguments]   ${att}   ${phase}
    FOR   ${i}   IN RANGE   16
        Set suite variable   ${att_B${i}}   ${att}[${i}]
        Set suite variable   ${phase_B${i}}   ${phase}[${i}]
    END

Update attenuations
    [Arguments]   ${length}
    FOR   ${i}   IN RANGE  0  ${length}
        MCS.set attenuation   ${att_B0}[${i}]   ${i+1}    ${1}   MCS_0
        MCS.set attenuation   ${att_B1}[${i}]   ${i+1}    ${2}   MCS_0
        MCS.set attenuation   ${att_B2}[${i}]   ${i+1}    ${3}   MCS_0
        MCS.set attenuation   ${att_B3}[${i}]   ${i+1}    ${4}   MCS_0
        MCS.set attenuation   ${att_B4}[${i}]   ${i+1}    ${5}   MCS_0
        MCS.set attenuation   ${att_B5}[${i}]   ${i+1}    ${6}   MCS_0
        MCS.set attenuation   ${att_B6}[${i}]   ${i+1}    ${7}   MCS_0
        MCS.set attenuation   ${att_B7}[${i}]   ${i+1}    ${8}   MCS_0
        MCS.set attenuation   ${att_B8}[${i}]   ${i+1}    ${9}   MCS_0
        MCS.set attenuation   ${att_B9}[${i}]   ${i+1}    ${10}   MCS_0
        MCS.set attenuation   ${att_B10}[${i}]   ${i+1}    ${11}   MCS_0
        MCS.set attenuation   ${att_B11}[${i}]   ${i+1}    ${12}   MCS_0
        MCS.set attenuation   ${att_B12}[${i}]   ${i+1}    ${13}   MCS_0
        MCS.set attenuation   ${att_B13}[${i}]   ${i+1}    ${14}   MCS_0
        MCS.set attenuation   ${att_B14}[${i}]   ${i+1}    ${15}   MCS_0
        MCS.set attenuation   ${att_B15}[${i}]   ${i+1}    ${16}   MCS_0
    END

Update phases
    [Arguments]   ${length}
    FOR   ${i}   IN RANGE  0  ${length}
        MCS.set phase   ${phase_B0}[${i}]   ${i+1}    ${1}   MCS_0
        MCS.set phase   ${phase_B1}[${i}]   ${i+1}    ${2}   MCS_0
        MCS.set phase   ${phase_B2}[${i}]   ${i+1}    ${3}   MCS_0
        MCS.set phase   ${phase_B3}[${i}]   ${i+1}    ${4}   MCS_0
        MCS.set phase   ${phase_B4}[${i}]   ${i+1}    ${5}   MCS_0
        MCS.set phase   ${phase_B5}[${i}]   ${i+1}    ${6}   MCS_0
        MCS.set phase   ${phase_B6}[${i}]   ${i+1}    ${7}   MCS_0
        MCS.set phase   ${phase_B7}[${i}]   ${i+1}    ${8}   MCS_0
        MCS.set phase   ${phase_B8}[${i}]   ${i+1}    ${9}   MCS_0
        MCS.set phase   ${phase_B9}[${i}]   ${i+1}    ${10}   MCS_0
        MCS.set phase   ${phase_B10}[${i}]   ${i+1}    ${11}   MCS_0
        MCS.set phase   ${phase_B11}[${i}]   ${i+1}    ${12}   MCS_0
        MCS.set phase   ${phase_B12}[${i}]   ${i+1}    ${13}   MCS_0
        MCS.set phase   ${phase_B13}[${i}]   ${i+1}    ${14}   MCS_0
        MCS.set phase   ${phase_B14}[${i}]   ${i+1}    ${15}   MCS_0
        MCS.set phase   ${phase_B15}[${i}]   ${i+1}    ${16}   MCS_0
    END

Stop Scout LMP Dockers
    run    sudo docker ps | awk '{print $1}' | awk '(NR>1)' | xargs sudo docker stop
    Log To Console      Stop Scout LMP Dockers

Start Scout LMP Dockers
    run    sudo docker ps -a | awk '{print $1}' | awk '(NR>1)' | xargs sudo docker start
    Log To Console      Start Scout LMP Dockers
Set Scout Configuration ID
    ${scout_config_id}  fetch_scout_id  testline_name=${TL_NAME_SCOUT}
    run keyword if  '${scout_config_id}'!='None'  add to test data  data={"tc_execution_id": "${scout_config_id}"}

Attach attempt mutiple times
    [Arguments]  ${ue_alias}   ${attempt_times}=5
    FOR  ${i}  IN RANGE  ${attempt_times}
        taf.ue.Attach ue  ${ue_alias}
        BuiltIn.sleep  5s
        ${ue_info}  taf.ue.get ue info  ${ue_alias}  CELL_INFO
        Exit For Loop IF  '${ue_info['cellType']}' != 'LTE'
        run keyword if  '${i}' == '${${attempt_times}-1}'  Fail  Can't attach to NR Cell
        taf.ue.detach ue  ${ue_alias}
        taf.ue.reboot ue  ${ue_alias}  timeout=180
    END

Edit and upload swconfig
    [Documentation]  Download origin swconfig.txt and add extra flags to existing one
    ...    conn_alias -    gNB / eNB (only to log to console and inform tester)
    ...    mplane -        for gNB - 192.168.255.129, for eNB - ${tl.enbs[0].m.v4}
    ...    flags -         new line sign ${\n} and your flag
    [Arguments]
    ...    ${conn_alias}=gNB
    ...    ${mplane}=192.168.255.129
    ...    ${flags}=${\n}
    Log To Console   __Editing swconfig.txt on ${conn_alias} site ongoing...
    Get Swconfig  origin_swconfig  ${SWCONFIG_PATH}  ${mplane}
    ${bts}    coam.connect to   bts_host=${mplane}
    Add Flags To Swconfig  ${SWCONFIG_PATH}    ${mplane}     ${flags}
    coam.Reset Site    connection=${bts}
    Log To Console    __Uploading swconfig.txt on ${conn_alias} site ongoing...
    Verify if all cells are onair
    [Teardown]   coam.teardown

Restore swconfig to default
    [Documentation]  Restore origin swconfig.txt
    [Arguments]
    ...    ${conn_alias}=gNB
    ...    ${mplane}=192.168.255.129
    ${bts}    coam.connect to   bts_host=${mplane}
    Restore Original Swconfig  ${SWCONFIG_PATH}    ${mplane}
    coam.Reset Site    connection=${bts}
    Log To Console    __Restoring swconfig.txt on ${conn_alias} site ongoing...
    Verify if all cells are onair
    [Teardown]   coam.teardown

Lock specific type cells
    [Documentation]    KW locks cell if its type is equal to the type given as argument: FDD or TDD
    [Arguments]    ${type}     ${alias}=cOAM
    log to console    __Locking ${type} cells
    Connect with runtime release    ${alias}
    ${ENABLE_CELLS}    Create List
    Set Suite Variable    ${ENABLE_CELLS}
    ${ids}  get_nrcell_r_distname_list
    FOR    ${cell_id}    IN    @{ids}
        ${cell_info}    coam.get_cell_specific_info    cell_id=${cell_id}    connection=${alias}
        Run keyword if    '${cell_info['technology']}'=='${type}'
        ...               coam.lock  ${cell_id}  timeout=60s  connection=${alias}
        ...               ELSE      Append To Enable Cells List  cell_id=${cell_id}
    END
    Set Suite Variable    ${ENABLE_CELLS}
    Log    <h1>ENABLE_CELLS = ${ENABLE_CELLS}</h1>    html=yes
    log to console    __The ${type} cells are locked
    [Teardown]    coam.Teardown     connection=${alias}

Append To Enable Cells List
    [Documentation]  Append 'NRCELL-*' to the ENABLE_CELLS list if cell shoud not be locked
    [Arguments]    ${cell_id}    ${alias}=cOAM
    ${active_cellID}     Fetch from right    ${cell_id}    NRBTS_R-${BTS_ID}/
    ${active_cellID}     Replace String    ${active_cellID}    _R-    -
    Append To List   ${ENABLE_CELLS}   ${active_cellID}
    Log To Console   ${alias}

Wait until specific cells are onair
    [Documentation]    Wait until 'Check specific cells are on air' be passed
    [Arguments]    ${type}=TDD
    Wait until keyword succeeds    900 sec    60 sec
    ...    Check specific cells are on air    type=${type}
    Log To Console     Wait until specific cells are onair`

Check specific cells are on air
    [Documentation]    Verify if specific TDD or FDD cells are 'enabled'
    [Arguments]    ${type}
    Connect with runtime release    coam
    ${c_info}    coam.get cells info    cell_type=nr    connection=coam
    ${type_list}    Create List
    FOR    ${cell}    IN    @{c_info}
        Run Keyword If    '${cell['technology']}' == '${type}'
        ...    Append to list    ${type_list}    ${cell['status']['operationalState']}
    END
    FOR    ${elem}    IN    @{type_list}
        Should be equal    ${elem}    enabled    operationalState for specific cell is not 'enabled'
    END
    [Teardown]    coam.Teardown     connection=coam

Strengthen And Weaken Attenuation
    [Documentation]
    ...    Keyword adapted from 1013

    [Arguments]
    ...    ${cell_lines}
    ...    ${min}
    ...    ${max}

    Interval attenuation    lines=${cell_lines}    attenuation=strengthen
    ...                     min=${min}     max=${max}
    Interval attenuation    lines=${cell_lines}    attenuation=weaken
    ...                     min=${min}     max=${max}

Lock FDD/TDD cells
    [Documentation]
    ...    Keyword adapted from 8204 - created by Maciek.
    ...    Keyword locks cell if its type is equal to the type given as argument

    [Arguments]
    ...    ${type}
    ...    ${alias}=cOAM

    Log To Console    __Locking ${type} cells
    Connect With Runtime Release    ${alias}
    ${ids}  get_nrcell_r_distname_list
    FOR    ${cell_id}    IN    @{ids}
        ${cell_info}    coam.get_cell_specific_info    cell_id=${cell_id}    connection=${alias}
        Run keyword if    '${cell_info['technology']}'=='${type}'
        ...               coam.lock  ${cell_id}  timeout=60s  connection=${alias}
        ...               ELSE      Set Active Cell ID  cell_id=${cell_id}
    END
    Log To Console    __The ${type} cells are locked
    [Teardown]    coam.Teardown     connection=${alias}

Set Active Cell ID
    [Arguments]    ${cell_id}      ${alias}=cOAM
    ${active_cellID}     Fetch from right    ${cell_id}    NRCELL_R-
    Set suite variable      ${ACTIVE_CELL_ID}
    Log To Console          ${alias}
