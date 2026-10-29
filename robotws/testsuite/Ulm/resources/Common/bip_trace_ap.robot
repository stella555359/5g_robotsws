*** Settings ***

Documentation
...   This robot resource file contains KWs for BIP trace collection on airphone.

Library    String
Library    OperatingSystem
Library    DateTime

Library    taf.collectors.l1l2bip      WITH NAME   l1l2bip
Library    taf.collectors.tcpdump      WITH NAME   tcpdump
Library    taf.collectors.core         WITH NAME   core
Library    taf.transport.ssh           WITH NAME   ssh


Resource   connect.robot

*** Variables ***
&{RUNNING_AP_BIP_TRACE}


*** Keywords ***
Start Airphone BIP Traces
    [Arguments]    ${ue_id}=0    ${comu_id}=0   ${option}=${EMPTY}    ${collector}=ue${ue_id}_bip_trace
    ${ap_bip_collector_alias}=   Create AP BIP Collectors   ue_id=${ue_id}
    ...                                                     comu_id=${comu_id}
    ...                                                     option=${option}
    ...                                                     collector_alias=${collector}

    Remember Start Time For AP BIP Trace    alias=${ap_bip_collector_alias}

    core.Setup Collectors    names=${ap_bip_collector_alias}
    core.Start Collectors    names=${ap_bip_collector_alias}


Stop Airphone BIP Traces
    [Documentation]
    ...
    ...    Logs are stored in Testcase Log directory by default
    ...
    ...    | ue_id |   Id/Number of UE |
    ...    | collector |   Name of collector like used in start command |
    ...    | target_dir |  Directory to store the pcap file |
    ...
    ...     *Returns* Path to pcap file incl. filename
    ...
    [Arguments]    ${ue_id}=${0}    ${collector}=ue${ue_id}_bip_trace    ${target_dir}=${None}

    Warn On AP Reset During Trace Collection   alias=${collector}

    IF   '${target_dir}'=='${None}'
        ${target_dir}   testline.Get Testcase Log Directory
    END

    l1l2bip.Stop Collectors        names=${collector}
    l1l2bip.Collect Collectors     names=${collector}   target_dir=${target_dir}
    l1l2bip.Teardown Collectors    names=${collector}

    RETURN    ${target_dir}/${collector}/tcpdump_ue${ue_id}_bip.pcap


Get Airphone BIP Trace Capture Interface
    [Documentation]
    ...
    ...     *Scope*  Internal
    ...
    [Arguments]    ${ue_id}=${0}    ${comu_id}=${0}
    ${comu_type}=        testline.Get Airphone Common Unit Type    ue_id=${ue_id}    comu_id=${comu_id}
    ${interface}=    Set Variable If
    ...    "${comu_type}"=="ASIL"    etha01.309
    RETURN    ${interface}


Create AP BIP Collectors
    [Arguments]    ${ue_id}=${0}    ${comu_id}=${0}  ${option}=${EMPTY}   ${collector_alias}=ue${ue_id}_bip_trace
    &{executor_airphone}=  Create Dictionary
    ...  host=192.168.200.129
    ...  user=toor4nsn
    ...  password=oZPS0POrRieRtu

    ${interface}    Get Airphone BIP Trace Capture Interface   ue_id=${ue_id}   comu_id=${comu_id}
    ${tcpdump_alias}    Set Variable   tcpdump_ue${ue_id}_bip

    tcpdump.Create Tcpdump Collector
    ...     name=${tcpdump_alias}
    ...     options=-i ${interface} ${option}
    ...     executor=${executor_airphone}

    core.Set Suite Alias     ${tcpdump_alias}

    Create AP ASIL BIP Collectors       tcpdump_alias=${tcpdump_alias}
    ...                                 collector_alias=${collector_alias}
    ...                                 executor_airphone=${executor_airphone}

    RETURN   ${collector_alias}


Create AP ASIL BIP Collectors
    [Arguments]   ${tcpdump_alias}   ${collector_alias}  ${executor_airphone}

    ${script_path}     Create List
    ...           /opt/wts/latest/sosReport_ASIL/airphone_mirror.sh
    ...           /opt/wts/latest/sosReport_ASIL/gnbMirroring.py

    &{remote_context_commands}   Create Dictionary  setup=./airphone_mirror.sh    teardown=./airphone_mirror.sh --stop

    l1l2bip.Create Airphone L1l2bip Collector
    ...     name=${collector_alias}
    ...     collector=${tcpdump_alias}
    ...     executor=${executor_airphone}
    ...     script_paths=${script_path}
    ...     command_line=${remote_context_commands}
    core.Set Suite Alias     ${collector_alias}

    RETURN    ${collector_alias}


Remember Start Time For AP BIP Trace
    [Arguments]   ${alias}

    Run Keyword And Warn On Failure
    ...    Dictionary Should Not Contain Key    ${RUNNING_AP_BIP_TRACE}    ${alias}
    ...    BIP Trace with alias ${alias} already started: ${RUNNING_AP_BIP_TRACE}!!

    ${start_time}=    DateTime.Get Current Date     result_format=%Y-%m-%d %H:%M:%S
    Set To Dictionary    ${RUNNING_AP_BIP_TRACE}   ${alias}     ${start_time}

Warn On AP Reset During Trace Collection
    [Arguments]    ${alias}

    Run Keyword And Warn On Failure
    ...    Dictionary Should Contain Key    ${RUNNING_AP_BIP_TRACE}    ${alias}
    ...    BIP Trace with alias ${alias} was not started!!

    ${stop_time}=         DateTime.Get Current Date     result_format=%Y-%m-%d %H:%M:%S
    ${start_time}=        Get From Dictionary   ${RUNNING_AP_BIP_TRACE}   ${alias}
    Remove From Dictionary    ${RUNNING_AP_BIP_TRACE}   ${alias}

    ${trace_duration_seconds}=    DateTime.Subtract Date From Date    ${stop_time}    ${start_time}  result_format=number

    ${ap_runtime}=    Get AP Runtime

    ${runtime_is_shorter_than_trace_duration}=    Evaluate   ${ap_runtime} < ${trace_duration_seconds}
    IF   ${runtime_is_shorter_than_trace_duration}
    ...   Log   There appears to be a reboot/reset of airphone during bip collection!   level=WARN

Get AP Runtime
    [Documentation]
    ...    *Scope*  Internal

    ${ap_ssh_connection}=    connect.Connect To Airphone Common Unit

    ${ap_uptime_string}=     ssh.Execute    cat /proc/uptime | awk '{print $1}'     connection=${ap_ssh_connection}

    ${ap_uptime}=   Convert To Number   ${ap_uptime_string}

    RETURN   ${ap_uptime}
