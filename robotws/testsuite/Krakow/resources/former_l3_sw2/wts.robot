*** Settings ***
Documentation
...            Keywords for low-level operations related to Egate and WTS
...            https://confluence.ext.net.nokia.com/display/SIMMODE/Wraparound+Test+Solution
...            http://wts-documentation.dyn.nesc.nokia.net/egate/
...            author:       Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com
...            maintainer:   Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com

Library     String
Library     Collections
Library     OperatingSystem
Library     Process
Library     Telnet
Library     ute_wtssim
Resource    configurators.robot
Resource    verificators.robot

*** Keywords ***
Start WTS and Reach Onair
    [Documentation]    Starts WTS and reaches OnAir state on TL deployment with AirPhone.
    ...                Port to start edaemon is read from DAEMON_PORT variable in WTS config.
    ...                OnAir state is determined by receiving MIB and SIB1 from all NR cells defined in WTS config.
    ...                As final step X2 link between ENB-1 and GNB-2 is established.
    ...                - ``wts_cfg``: Path to WTS config file, Default: basic_setup.cfg
    ...                - ``log_dir``: Path to logs directory, Default: ``$\{OUTPUT DIR\}/Logs/Egate/``
    ...                - ``egate_port``: Port to start egate with, Default: 20000
    ...                - ``timeout``: Time to wait for cell setup, Default: 120s
    ...                - ``skip_x2_link``: If setting X2 link should be skipped, Default: no
    ...                - ``skip_confirmation``: If onAir verification should be skipped, Default: no
    [Arguments]    ${wts_cfg}=/opt/wts/latest/basic_setup.cfg    ${log_dir}=${OUTPUT DIR}/Logs/Egate/
    ...    ${egate_port}=20000    ${timeout}=120s    ${skip_x2_link}=no     ${skip_confirmation}=no
    #--------- Param check -----------------------------------------------------------------------------------------
    OperatingSystem.File Should Exist    ${wts_cfg}
    Should Be True    type(${egate_port}) is int    msg=Invalid KW parameter: egate_port
    Should Be True    '${skip_x2_link}' in ('yes','no')    msg=Invalid KW parameter: skip_x2_link
    Should Be True    '${skip_confirmation}' in ('yes','no','sib1')    msg=Invalid KW parameter: skip_confirmation
    #---------------------------------------------------------------------------------------------------------------
    Copy File    ${wts_cfg}    ${log_dir}/wts_setup.cfg
    ${cfg_content}    OperatingSystem.Get File    ${wts_cfg}
    ${match}    ${edaemon_port}    Should Match Regexp    ${cfg_content}    DAEMON_PORT="?(\\d+)"?
    ...    msg=Missing DAEMON_PORT variable in WTS config: ${wts_cfg}
    ${cell_ids}    Get Regexp Matches    ${cfg_content}
    ...    ${\n}set_cell(?=.*id=(\\d+))(?=.*gnb=(\\d+))(?!.*technology=lte)    2    1
    Should Not Be Empty    ${cell_ids}    msg=No NR Cells defined in WTS config: ${wts_cfg}
    Log to Console    Adding default IP addresses for WTS
    Add IP Addresses To Local Interfaces
    ...    eth3:10.0.1.131/24    eth3:10.0.1.132/24    eth3:10.0.1.133/24    eth3:10.0.1.134/24    eth3:10.0.1.135/24
    ...    eth3:10.0.1.136/24    eth3:10.0.1.137/24    ignore_existing=yes    silent=yes
    Log to Console    Starting WTS Applications
    ute_wtssim.start_wts_applications    egate_port=${egate_port}    edaemon_ports=${edaemon_port}
    ...    tool_dir=/opt/wts/latest
    @{wts_cells}    Create List
    FOR    ${id}    IN    @{cell_ids}
      ${alias}    Set Variable    cell_${id}[0]_${id}[1]
      ${dict}    Create Dictionary    alias=${alias}    gnb_id=${id}[0]    cell_id=${id}[1]
      Append To List    ${wts_cells}    ${dict}
      Telnet.Open Connection    host=localhost    port=${egate_port}    timeout=${timeout}    alias=${alias}
    END
    @{empty_list}    Create List
    ${wts_cells}    Set Variable If    '${skip_confirmation}' == 'yes'    ${empty_list}    ${wts_cells}
    Log to Console    Starting SimMode with config: ${wts_cfg}
    ute_wtssim.execute_egate_command    cmd=cfg file=${wts_cfg}    pass_regexp=SimMode is ready    timeout=30
    FOR    ${cell}    IN    @{wts_cells}
      Log to Console    Waiting for NR Cell ${cell}[gnb_id]\.${cell}[cell_id] Setup, MIB and SIB1
      Telnet.Switch Connection    ${cell}[alias]
      Telnet.Read Until Regexp    Established connection with proxy to eNB ${cell}[gnb_id] cell ${cell}[cell_id]
      Telnet.Read Until Regexp    eNB ${cell}[gnb_id] cell ${cell}[cell_id]: MasterInformationBlock-NR Updated
      Run Keyword If    '${skip_confirmation}' != 'sib1'
      ...    Telnet.Read Until Regexp    eNB ${cell}[gnb_id] cell ${cell}[cell_id]: SystemInformationBlockType1-NR updated
    END
    Run Keyword If    '${skip_x2_link}' == 'no'    Execute Egate Command Ext
    ...    cmd=enb_x2_link_up enb=1 target=2    pass_regexp=X2AP Link with GNB.*is up
    ...    log_msg=Starting X2 Link between ENB-1 and GNB-2
    ${link_status}    Set Variable If    '${skip_x2_link}' == 'no'    with active X2 link    without X2 link
    Run Keyword If    '${skip_confirmation}' != 'yes'    Log to Console    Reached OnAir state ${link_status}
    Set Egate Logs Dir    log_dir=${log_dir}
    [Teardown]    Telnet.Close All Connections

Stop and Teardown WTS
    [Documentation]    Flushes logs to file and stops WTS simulation and processes.
    ...                - ``log_dir``: Directory for logs, Default: ``$\{OUTPUT DIR\}/Logs/Egate/``
    [Arguments]    ${log_dir}=${OUTPUT DIR}/Logs/Egate/
    Log to Console    Stopping WTS applications
    Create Directory    ${log_dir}
    Flush Egate Logs
    ute_wtssim.stop_and_collect_wts_logs
    Copy Files    /opt/wts/latest/*.log*    ${log_dir}

Teardown Egate If Running
    [Documentation]    Teardowns WTS if egate is running.
    ...                - ``log_dir``: Directory for logs, Default: ``$\{OUTPUT DIR\}/Logs/Egate/``
    [Arguments]    ${log_dir}=${OUTPUT DIR}/Logs/Egate/
    ${egate_running}    Check If Egate Is Running
    Run Keyword If    ${egate_running}    Stop and Teardown WTS    log_dir=${log_dir}

Flush Egate Logs
    [Documentation]    Flushes buffered egate logs to egate_console.log
    ute_wtssim.execute_egate_command    cmd=set_log flush

Execute Egate Command Ext
    [Documentation]    Wrapper KW for ``ute_wtssim.execute_egate_command`` with extended functionality.
    ...                - ``cmd``: Egate command to execute
    ...                - ``pass_regexp``: Regexp indicating that the command passed, Default: None
    ...                - ``fail_regexp``: Regexp indicating that the command failed, Default: None
    ...                - ``timeout``: Timeout for finding ``pass_regexp``, Default: 10s
    ...                - ``should_contain``: List or single regexp pattern that command output should contain,\
    ...                Default: None
    ...                - ``should_not_contain``: List or single regexp pattern that command output should not contain,\
    ...                Default: None
    ...                - ``log_msg``: Console log message, Default: Executed command
    ...                - ``cmd_params``: Extra egate command parameters
    [Arguments]    ${cmd}    ${pass_regexp}=${None}    ${fail_regexp}=${None}    ${timeout}=10s
    ...    ${should_contain}=@{Empty}    ${should_not_contain}=@{Empty}    ${log_msg}=${Empty}    &{cmd_params}
    FOR    ${param}    IN    @{cmd_params}
        ${cmd}    Set Variable    ${cmd} ${param}\=${cmd_params}[${param}]
    END
    ${log_msg}    Set Variable If    '${log_msg}' == ''    Executing egate command: ${cmd}    ${log_msg}
    Log To Console    ${log_msg}
    ${output}    ute_wtssim.execute_egate_command
    ...    cmd=${cmd}    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}    timeout=${timeout}
    ${is_string}    Run Keyword And Return Status    Should Be String    ${should_contain}
    ${should_contain}    Run Keyword If    ${is_string}
    ...    Create List    ${should_contain}    ELSE    Set Variable    ${should_contain}
    ${is_string}    Run Keyword And Return Status    Should Be String    ${should_not_contain}
    ${should_not_contain}    Run Keyword If    ${is_string}
    ...    Create List    ${should_not_contain}    ELSE    Set Variable    ${should_not_contain}
    FOR    ${pattern}    IN    @{should_contain}
      Should Match Regexp    ${output}    ${pattern}    values=${False}
      ...    msg=Output of egate command does not contain pattern: ${pattern}${\n}cmd: ${cmd}${\n}output:${\n}${output}
    END
    FOR    ${pattern}    IN    @{should_not_contain}
      Should Not Match Regexp    ${output}    ${pattern}    values=${False}
      ...    msg=Output of egate command contains forbidden pattern: ${pattern}${\n}cmd: ${cmd}${\n}output:${\n}${output}
    END
    [Return]    ${output}

Get Configured Nodes From Egate
    [Documentation]    Returns output of ``enb_disp`` command as dictionary with Node-ID as key.
    ...                Only static fields are returned.
    ...                Example output:
    ...                | {1:{RAN Type:'ENB', RAN ID:'0x12346', Address:'10.0.1.136', Type:'simulated:macro'}
    ...                | 2:{RAN Type:'GNB', RAN ID:'0x01', Address:'10.0.1.112', Type:'external'}}
    ${cmd}    Set Variable    enb_disp
    ${out}    ute_wtssim.execute_egate_command    cmd=${cmd}    pass_regexp=---.*===
    ${filtered}    Get Lines Matching Regexp    ${out}    ^[0-9].*
    @{lines}    Split To Lines    ${filtered}
    &{nodes}    Create Dictionary
    FOR    ${line}    IN    @{lines}
      ${values}    Split String    ${line}
      Length Should Be    ${values}    6
      ...    msg=Error when splitting values. Command possibly changed format: ${cmd}
      &{node}    Create Dictionary
      ...    RAN Type=${values}[1]
      ...    RAN ID=${values}[2]
      ...    Address=${values}[3]
      ...    Type=${values}[4]
      Set To Dictionary    ${nodes}    ${values}[0]    ${node}
    END
    [Return]    ${nodes}

Get Configured UEs From Egate
    [Documentation]    Returns output of ``ue_disp`` command as dictionary with UE-ID as key.
    ...                Only static fields and initial location are returned.
    ...                Example output:
    ...                | {1:{Type:'INT', Location:'2.1', MME:'1', UEC:'1'}
    ...                | 11:{Type:'INT', Location:'1.1', MME:'1', UEC:'1'}}
    ${cmd}    Set Variable    ue_disp
    ${out}    ute_wtssim.execute_egate_command    cmd=${cmd}    pass_regexp=---.*===
    ${filtered}    Get Lines Matching Regexp    ${out}    ^[0-9].*
    @{lines}    Split To Lines    ${filtered}
    &{ues}    Create Dictionary
    FOR    ${line}    IN    @{lines}
      ${values}    Split String    ${line}
      Length Should Be    ${values}    10
      ...    msg=Error when splitting values. Command possibly changed format: ${cmd}
      &{ue}    Create Dictionary
      ...    Type=${values}[1]
      ...    Location=${values}[5]
      ...    MME=${values}[6]
      ...    UEC=${values}[7]
      ${node_id}    ${cell_id}    Split String    ${values}[5]    separator=.
      Set To Dictionary    ${ue}    Node    ${node_id}
      Set To Dictionary    ${ues}    ${values}[0]    ${ue}
    END
    [Return]    ${ues}

Get IDs of Attached UEs From Egate
    [Documentation]    Returns a list of UE IDs that are not in OFF state.
    ${cmd}    Set Variable    ue_disp state=ACTIVE,ACTIVATING,DEACTIVATING,IDLE,IM_ENTERING,IM_EXITING
    ${out}    ute_wtssim.execute_egate_command    cmd=${cmd}    pass_regexp=---.*===
    ${filtered}    Get Lines Matching Regexp    ${out}    ^[0-9]+.*INT.*
    @{lines}    Split To Lines    ${filtered}
    @{ue_ids}    Create List
    Return From Keyword If    ${lines} == []    ${ue_ids}
    FOR    ${line}    IN    @{lines}
      ${values}    Split String    ${line}
      Append To List    ${ue_ids}    ${values}[0]
    END
    [Return]    ${ue_ids}

Get SA UE Bearer Stats From Egate
    [Documentation]    Returns bearer stats for SA UE as dictionary with separate items for DL and UL.
    ...                - ``ue_id``: SA UE ID
    ...                - ``pdu_id``: PDU Session ID, Default: same as UE ID
    ...                - ``qfi``: QoS Flow ID, Default: 1
    ...                - ``params``: Extra parameters for egate command
    [Arguments]    ${ue_id}    ${pdu_id}=${ue_id}    ${qfi}=1    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    Should Be True    type(${pdu_id}) is int    msg=Invalid KW parameter: pdu_id
    Should Be True    type(${qfi}) is int    msg=Invalid KW parameter: qfi
    #---------------------------------------------------------------------------------------------------------------
    &{bearer_stats}    Create Dictionary
    ${stats_dl}    Get Bearer Stats From Egate    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi}    dir=dl    &{params}
    Set To Dictionary    ${bearer_stats}    DL    ${stats_dl}
    ${stats_ul}    Get Bearer Stats From Egate    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi}    dir=ul    &{params}
    Set To Dictionary    ${bearer_stats}    UL    ${stats_ul}
    [Return]    ${bearer_stats}

Get NSA UE Bearer Stats From Egate
    [Documentation]    Returns bearer stats for NSA UE as dictionary with separate items for DL and UL.
    ...                - ``ue_id``: NSA UE ID
    ...                - ``drb_id``: Data Radio Bearer ID, Default: 2
    ...                - ``params``: Extra parameters for egate command
    [Arguments]    ${ue_id}    ${drb_id}=2    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    Should Be True    type(${drb_id}) is int    msg=Invalid KW parameter: drb_id
    #---------------------------------------------------------------------------------------------------------------
    &{bearer_stats}    Create Dictionary
    ${stats_dl}    Get Bearer Stats From Egate    ue_id=${ue_id}    id=${drb_id}    dir=dl    &{params}
    Set To Dictionary    ${bearer_stats}    DL    ${stats_dl}
    ${stats_ul}    Get Bearer Stats From Egate    ue_id=${ue_id}    id=${drb_id}    dir=ul    &{params}
    Set To Dictionary    ${bearer_stats}    UL    ${stats_ul}
    [Return]    ${bearer_stats}

Get Bearer Stats From Egate
    [Documentation]    Returns output of ``bearer_stats`` command as dictionary.
    ...                - ``ue_id``: UE ID
    ...                - ``params``: Parameters and their values for command
    ...                Example:
    ...                | Get Bearer Stats From Egate | ue_id=1 | pdu=1 | qfi=1 | dir=dl |
    [Arguments]    ${ue_id}    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    #---------------------------------------------------------------------------------------------------------------
    ${cmd}    Set Variable    bearer_stats ue=${ue_id}
    ${pass_regexp}    Set Variable    ---.*===
    ${output}    Execute Egate Command Ext    cmd=${cmd}    pass_regexp=${pass_regexp}    &{params}
    ${header}    Get Lines Matching Regexp    ${output}    Parameter.*Value.*
    Should Not Be Empty    ${header}    msg=Failed to find header line in bearer_stats output.
    ${chars}    Split String To Characters    ${header}
    ${index}    Get Index From List    ${chars}    V
    ${filtered}    Remove String Using Regexp    ${output}
    ...    UE.*traffic    Parameter.*Value    EGATE    UEs.*configured    Session    Copyright
    ${matches}    Get Lines Matching Regexp    ${filtered}    ^[A-Z].*
    @{lines}    Split To Lines    ${matches}
    &{bearer_stats}    Create Dictionary
    FOR    ${line}    IN    @{lines}
       ${key}      Get Substring    ${line}    start=0    end=${index}
       ${value}    Get Substring    ${line}    start=${index}
       Should Match Regexp    ${key}    ^[A-Z].*\\s$
       ${key}      Strip String    ${key}
       ${value}    Strip String    ${value}
       Set To Dictionary    ${bearer_stats}    ${key}    ${value}
    END
    Run Keyword If    len(${bearer_stats}) != 56
    ...    Log    Error processing egate output from bearer_stats: Unexpected number of items.    level=ERROR
    [Return]    ${bearer_stats}

Get UE Stats From Egate
    [Documentation]    Returns output of ``ue_stats_nr`` command as dictionary of scells.
    ...                Reimplements ``size_unit`` parameter of egate command for proper conversion to numbers.
    ...                Display format of egate command set to short.
    ...                - ``ue_id``: UE ID
    ...                - ``size_unit``: Format of traffic values: auto / bps / kbps / mbps, Default: auto
    ...                - ``format``: Egate command display format, Default: short (only option)
    ...                - ``params``: Parameters and their values for command
    ...                Example:
    ...                | &\{stats\} | Get UE Stats From Egate | ue_id=1 | scell=0-6 | type=pdsch | size_unit=kbps |
    [Arguments]    ${ue_id}    ${size_unit}=auto    ${format}=short    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    Should Be True    '${format}' == 'short'    msg=Invalid KW parameter: Only short format allowed
    Should Be True    '${size_unit}' in ('auto','mbps','kbps','bps')    msg=Invalid KW parameter: size_unit
    #---------------------------------------------------------------------------------------------------------------
    ${cmd}    Set Variable    ue_stats_nr id=${ue_id}
    ${pass_regexp}    Set Variable    ---.*===
    ${output}    Execute Egate Command Ext    cmd=${cmd}    pass_regexp=${pass_regexp}    &{params}
    ${matches}    Get Lines Matching Regexp    ${output}    ^CellIndex-.*
    @{lines}    Split To Lines    ${matches}
    Should Be True    len(${lines}) > 0    msg=Egate command ue_stats_nr returned no data
    &{ue_stats}    Create Dictionary
    FOR    ${line}    IN    @{lines}
      ${match}    ${scell}    ${cur}    ${min}    ${max}    ${avg}    Should Match Regexp    ${line}
      ...    (CellIndex-\\d+)\\s+(0|\\d+.\\d .bps)\\s+(0|\\d+.\\d .bps)\\s+(0|\\d+.\\d .bps)\\s+(0|\\d+.\\d .bps)
      ${cur}    ${min}    ${max}    ${avg}    Run Keyword If    '${size_unit}' != 'auto'
      ...    Convert Traffic Strings to Unit    ${cur}    ${min}    ${max}    ${avg}    output_unit=${size_unit}
      ...    ELSE    Create List    ${cur}    ${min}    ${max}    ${avg}
      &{scell_stats}    Create Dictionary    Current=${cur}    Minimum=${min}    Maximum=${max}    Average=${avg}
      Set To Dictionary    ${ue_stats}    ${scell}    ${scell_stats}
    END
    [Return]    ${ue_stats}

Get Next Meas ID From Egate
    [Documentation]    Returns current Measurement ID of A1-6/B1-2 event for UE from ``ue_meas_cfg_disp`` command
    ...                and fails when no ID can be found.
    ...                Measurement ID is a required input for ``ue_measurement_send_nr`` command.
    ...                RAT type EUTRA can be used in case of UE NR REPORT CONFIGURATIONS and
    ...                EUTRAN in case of UE EUTRA MEASUREMENT OBJECTS.
    ...                - ``ue_id``: UE ID
    ...                - ``event``: Measurement Event
    ...                - ``rat``: Radio Access Tech - NR, EUTRA or EUTRAN, Default: NR
    ...                - ``target_ssb``: SSB ARFCN of target cell (NIDD param: arfcnSsbPbch), Default: Not used
    ...                Example:
    ...                | Get Next Meas ID From Egate | ue_id=1 | event=A3 |
    [Arguments]    ${ue_id}    ${event}    ${rat}=NR    ${target_ssb}=${Empty}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    Should Match Regexp    ${event}    ^(A[1-6]|B[12])$    msg=Invalid KW parameter: event
    Should Be True    '${rat}' in ('NR','EUTRA','EUTRAN')    msg=Invalid KW parameter: rat
    #---------------------------------------------------------------------------------------------------------------
    ${cmd}    Set Variable    ue_meas_cfg_disp id=${ue_id}
    ${out}    ute_wtssim.execute_egate_command    cmd=${cmd}    pass_regexp=NR MEASUREMENT IDENTITIES.*---.*===
    ${match}    ${object_id}    Run Keyword If    '${target_ssb}' != ''
    ...    Should Match Regexp    ${out}    (?m)^.*?(\\d+)\\s+${rat}\\s+${target_ssb}
    ...    msg=No Object configuration for CarrierFreq ${target_ssb} for UE-${ue_id}.
    ...    ELSE    Create List    not_used    \\d+
    ${match}    ${report_cfg_id}    Should Match Regexp    ${out}    (?m)^.*?(\\d+)\\s+${rat}\\s+Event${event}
    ...    msg=No ${event} Event configuration for UE-${ue_id}. Check if ENB/GNB sent measurement configuration to UE.
    ${match}    ${meas_id}    Should Match Regexp    ${out}    (?m)^.*?(\\d+)\\s+${object_id}\\s+${report_cfg_id}\\s+$
    ...    msg=Unable to find ReportCfgId/ObjectId to MeasId mapping for ${event} Event.
    [Return]    ${meas_id}

Update UE Parameters
    [Documentation]    Updates parameters of UE via ``ue_param`` command.
    ...                - ``ue_id``: UE ID
    ...                - ``reset``: Reset to default values or RRC Reconfiguration rules, Default: no
    ...                - ``params``: Parameters and their values for command
    ...                Example:
    ...                | Update UE Parameters | id=1 | ue_nr_capabilities=$VAR_FROM_WTS |
    [Arguments]    ${ue_id}    ${reset}=no    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    Should Be True    '${reset}' in ('yes','no','rrc_reconf_rules')    msg=Invalid KW parameter: reset
    #---------------------------------------------------------------------------------------------------------------
    ${cmd}    Set Variable    ue_param id=${ue_id}
    ${cmd}    Set Variable If
    ...    '${reset}' == 'yes'                 ${cmd} reset
    ...    '${reset}' == 'rrc_reconf_rules'    ${cmd} reset_rrc_reconf_rules    ${cmd}
    ${log_msg}    Set Variable    Updating UE-${ue_id} parameters
    Execute Egate Command Ext   cmd=${cmd}    log_msg=${log_msg}    &{params}

Update Sim GNB Parameters
    [Documentation]    Updates parameters of Simulated GNB via ``gnb_param`` command.
    ...                - ``id``: Simulated GNB instance ID
    ...                - ``reset``: Reset to default values, Default: no
    ...                - ``params``: Parameters and their values for command
    ...                Example:
    ...                | Update Sim GNB Parameters | id=3 | sa_ho=xn_based | ciphering_disabled=5:on |
    ...                | Update Sim GNB Parameters  | id=3 | reset=yes |
    [Arguments]    ${id}    ${reset}=no    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${id}) is int    msg=Invalid KW parameter: id
    Should Be True    '${reset}' in ('yes','no')    msg=Invalid KW parameter: reset
    #---------------------------------------------------------------------------------------------------------------
    ${cmd}    Set Variable    gnb_param id=${id}
    ${cmd}    Set Variable If    '${reset}' == 'yes'    ${cmd} reset    ${cmd}
    ${log_msg}    Set Variable    Updating Sim GNB-${id} parameters
    Execute Egate Command Ext   cmd=${cmd}    log_msg=${log_msg}    &{params}

Update Sim ENB Parameters
    [Documentation]    Updates parameters of Simulated ENB via ``enb_param`` command.
    ...                - ``id``: Simulated ENB instance ID
    ...                - ``reset``: Reset to default values, Default: no
    ...                - ``params``: Parameters and their values for command
    ...                Example:
    ...                | Update Sim ENB Parameters | id=1 | x2_force_reject_ho_req_with_cause=RN_tDCoverall_expiry |
    ...                | Update Sim ENB Parameters  | id=1 | reset=yes |
    [Arguments]    ${id}    ${reset}=no    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${id}) is int    msg=Invalid KW parameter: id
    Should Be True    '${reset}' in ('yes','no')    msg=Invalid KW parameter: reset
    #---------------------------------------------------------------------------------------------------------------
    ${cmd}    Set Variable    enb_param id=${id}
    ${cmd}    Set Variable If    '${reset}' == 'yes'    ${cmd} reset    ${cmd}
    ${log_msg}    Set Variable    Updating Sim ENB-${id} parameters
    Execute Egate Command Ext   cmd=${cmd}    log_msg=${log_msg}    &{params}

Update Sim ENB EN-DC Parameters
    [Documentation]    Updates parameters of Simulated ENB related to LTE-NR Dual Connectivity
    ...                via ``enb_endc_param`` command.
    ...                - ``id``: Simulated ENB instance ID
    ...                - ``reset``: Reset to default values, Default: no
    ...                - ``params``: Parameters and their values for command
    ...                Example:
    ...                | Update Sim ENB EN-DC Parameters | id=1 | menb_failure_scenario=dont_send_sgnb_reconf_complete |
    ...                | Update Sim ENB EN-DC Parameters | id=1 | reset=yes |
    [Arguments]    ${id}    ${reset}=no    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${id}) is int    msg=Invalid KW parameter: id
    Should Be True    '${reset}' in ('yes','no')    msg=Invalid KW parameter: reset
    #---------------------------------------------------------------------------------------------------------------
    ${cmd}    Set Variable    enb_endc_param id=${id}
    ${cmd}    Set Variable If    '${reset}' == 'yes'    ${cmd} reset    ${cmd}
    ${log_msg}    Set Variable    Updating Sim ENB-${id} EN-DC parameters
    Execute Egate Command Ext   cmd=${cmd}    log_msg=${log_msg}    &{params}

Set Egate Logs Dir
    [Documentation]    Redirects egate console log to new directory via ``sim_log_set`` command.
    ...                Directory path must not contain spaces or hash character.
    ...                - ``log_dir``: New log directory
    ...                - ``log_name``: Name of log file, Default: egate_console.log
    [Arguments]    ${log_dir}    ${log_name}=egate_console.log
    Should Match Regexp    ${log_dir}    ^[^# ]+$
    ...    msg=Log directory path must not contain spaces or hash character.
    Should Match Regexp    ${log_name}    ^[^# ]+$
    ...    msg=Log filename must not contain spaces or hash character.
    Create Directory    ${log_dir}
    ute_wtssim.execute_egate_command    cmd=sim_log_set file=${log_dir}/${log_name}

Check Xn Link is Up
    [Documentation]    Checks if Xn-link between GNBs is Up via ``gnb_xn_link_up`` command.
    ...                - ``sim_gnb_id``: ID of Simulated GNB
    ...                - ``ext_gnb_id``: ID of External GNB
    [Arguments]    ${sim_gnb_id}    ${ext_gnb_id}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${sim_gnb_id}) is int    msg=Invalid KW parameter: sim_gnb_id
    Should Be True    type(${ext_gnb_id}) is int    msg=Invalid KW parameter: ext_gnb_id
    #---------------------------------------------------------------------------------------------------------------
    ${cmd}    Set Variable    gnb_xn_link_up gnb=${sim_gnb_id} target=${ext_gnb_id}
    ${pass_regexp}    Set Variable    XnAP Link.*is up
    ute_wtssim.execute_egate_command    cmd=${cmd};${cmd}    pass_regexp=${pass_regexp}

Start X2 Link
    [Documentation]    Starts X2 Link between ENB and GNB via ``enb_x2_link_up`` command.
    ...                - ``enb_id``: ID of Simulated ENB
    ...                - ``target_gnb_id``: ID of target GNB
    [Arguments]    ${enb_id}=1    ${target_gnb_id}=2
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${enb_id}) is int    msg=Invalid KW parameter: enb_id
    Should Be True    type(${target_gnb_id}) is int    msg=Invalid KW parameter: target_gnb_id
    #---------------------------------------------------------------------------------------------------------------
    ${cmd}    Set Variable    enb_x2_link_up enb=${enb_id} target=${target_gnb_id}
    ${pass_regexp}    Set Variable    ENB-${enb_id}: X2AP Link with GNB-${target_gnb_id}.*is up
    Log to Console    Establishing X2-Link from ENB-${enb_id} to GNB-${target_gnb_id}...    no_newline=${True}
    ute_wtssim.execute_egate_command    cmd=${cmd}    pass_regexp=${pass_regexp}
    Log to Console    OK

Collect AP SosReport
    [Documentation]    Collects SosReport with AP Snapshot. Supports user flag ``skip:sos`` for skipping collection.
    ...                - ``log_dir``: Report directory, Default: ``$\{TEST_log_dir\}/SosReport/``
    ...                - ``params``: Extra parameters for sosReport.sh script
    ...                Example:
    ...                | Collect AP SosReport | -c |
    ...                | robot -v skip:sos test_suite.robot
    [Arguments]    @{params}    ${log_dir}=${TEST_log_dir}/SosReport/
    ${unit}    Get Variable Value    ${tl.ues[0].l1.common_units[0].hardware_type}    ASIL
    ${flags}    Get Variable Value    ${skip}
    ${skip_sos}    Set Variable If    'sos' in '${flags}'    ${True}    ${False}
    Run Keyword If    ${skip_sos}    Run Keywords
    ...    Log to Console    Skipping AP SosReport collection
    ...    AND    Return From Keyword
    Create Directory    ${log_dir}
    Run Keyword If    '${unit}' == 'ASIK'    Append To List    ${params}    -nr
    Log to Console    Collecting AP over ${unit} SosReport
    ${result}    Run Process And Expect Success    /opt/wts/latest/sosReport_ASIL/sosReport_ASIL.sh    @{params}
    ...    cwd=/opt/wts/latest/sosReport_ASIL/    stdout=${log_dir}sosreport_stdout.txt    msg=Error when collecting AP SosReport
    ${match}    Should Match Regexp in Files    SosReport.*tgz created    ${log_dir}sosreport_stdout.txt
    ${filename}    Should Match Regexp    ${match}    SosReport.*tgz
    Move File    /opt/wts/latest/sosReport_ASIL/${filename}    ${log_dir}/${filename}
    Log to Console    Collected AP SosReport to file ${filename}
