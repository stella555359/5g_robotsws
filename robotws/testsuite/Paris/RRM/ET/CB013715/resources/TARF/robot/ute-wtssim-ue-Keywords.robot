*** Settings ***
# https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=5GFTPARIS&title=ET+Coding+Rules
# --------------------------------------------------------------------------------------------------------------------------------------------------
Documentation     [SUITE PURPOSE]   Configuration related to ute_wtssim keywords
...               Prerequisite :
...               Scope : Common keywords for feature
#
...               Test Case Scenario author   :
...               Creation Date               : 2024-10-07
...               Modified Date               : 2024-10-07
#
...               Version    Date      Author                                Notes
# --------------------------------------------------------------------------------------------------------------------------------------------------

# Libraries
Library                                         BuiltIn
Library                                         DateTime
Library                                         OperatingSystem
Library                                         ute_wtssim
Library                                         taf.wts.runner    WITH NAME    wtsemu

# Libraries CB012738
Library                                         ../python/template_functions.py    WITH NAME       template
Library                                         ../python/Dev_lib.py
Library                                         ../python/egate_analyzer.py        WITH NAME       egate_analyzer
Library                                         ../python/tools.py                 WITH NAME       tools_py
Library                                         ../python/avg_dl_data.py
Library                                         ../python/avg_ul_data.py
Library                                         ../python/bearer_stats.py

# Resources CB012738
Resource                                        testline-Keywords.robot
Resource                                        testcase-Keywords.robot
Resource                                        Scenario-Common-Keywords.robot

*** Variables ***

${WTS_DIR}               /opt/wts/latest/

${run_script_log_set}    ${CURDIR}${/}../scripts/run_script_log_set.lua

*** Keywords ***
# robocop: off=unused-argument
# robocop: off=possible-variable-overwriting

# ------------------------------------------------------------------------------------------------------------------------------------
# Common Kw wts.ue based ute_wtssim
# ------------------------------------------------------------------------------------------------------------------------------------

Configure WTS with X2 link
    [Documentation]
    ...    Used for NSA Test Case
    ...
    ...    *Scope*   Internal
    ...
    ...    | cfg_file | path of wts config file to be used |
    ...
    [Arguments]    ${cfg_file}=${tl.core.cfg_filename}
    Config WTS for Airphone    pass_regexp=SystemInformationBlockType2 updated    cfg_file=${cfg_file}
    Setup X2 Link

Setup X2 Link
    [Documentation]
    ...     This KW calls egate cmd enb_x2_link_up for enb 1 with target 2 and verifies
    ...     'X2AP Link .* is up' is found in egate console output. An alias 'ap_egate' must exist.
    ...     Used for UTE Workaround keyword
    ...
    ...     *Scope*  Internal
    ...
    ute_wtssim.execute egate command and wait for data
    ...   cmd=enb_x2_link_up enb=1 target=2   pass_regexp=X2AP Link .* is up   alias=ap_egate

Setup Xp Link
    [Documentation]
    ...     This KW calls egate cmd enb_xp_link_up for enb 1 with target 2 and verifies
    ...     'X2AP Link .* is up' is found in egate console output. An alias 'ap_egate' must exist.
    ...     Used for UTE Workaround keyword
    ...
    ...     *Scope*  Internal
    ...
    ute_wtssim.execute egate command and wait for data
    ...   cmd=enb_xp_link_up enb=1 target=2   pass_regexp=XPAP Link .* is up   alias=ap_egate

Wait Xp link Up
    [Documentation]    [PRIVATE]    wait Xp link up
    [Arguments]                 ${alias}=ap_egate
    Wait Until Keyword Succeeds    2 min    20 sec    Xp link setup Up   alias=${alias}

Xp link Setup Up
    [Arguments]          ${timeout}=20       ${alias}=ap_egate
    Log to console  \n***Activate eNBSim with XpAp interface [eNBId=${Param.Context.eNBId} and gNBId=${Param.Context.gNBId}] with alias=${alias}***
    ute_wtssim.execute egate command    cmd=enb_xp_param id=${Param.Context.eNBId} ignore_xp=off xp_listening_socket=on    alias=${alias}
    ute_wtssim.execute egate command    cmd=enb_xp_param id=${Param.Context.eNBId} xp_peers=${Param.Context.gNBId}    alias=${alias}
    ${output}=    ute_wtssim.execute egate command and wait for data    cmd=enb_xp_link_up enb=${Param.Context.eNBId} target=${Param.Context.gNBId}
    ...                                            pass_regexp=(XpAP Link .* is up|Xp Link is already active)   timeout=${timeout}  alias=${alias}
    ${output}         Get Lines Matching Regexp    ${output}    XpAP Link .* is up   partial_match=${TRUE}
    Log to Console    ${output}
    ${output}         Get Lines Matching Regexp    ${output}    Xp Link is already active   partial_match=${TRUE}
    Log to Console    ${output}
    Traced sleep    10s
    Log to console  \n***Activate eNBSim with XpAp interface completed ***

Config WTS for Airphone
    [Documentation]
    ...     Configure WTS with default config file in __init__.py .
    ...     The parameter ``pass_regexp`` can be used to wait for a string in the egate log or ``timeout``.
    ...
    ...    | wts_alias  | alias name to handle egate for ute_wtssim |
    ...    | cfg_file   | path of wts config file to be used        |
    ...
    ...    *Example*
    ...    -  NSA TL
    ...    | wts_ue.Start WTS for Airphone |
    ...    | wts_ue.Config WTS for Airphone | pass_regexp=SystemInformationBlockType2 updated |
    ...    - SA TL
    ...    | wts_ue.Start WTS for Airphone |
    ...    | wts_ue.Config WTS for Airphone | pass_regexp=SystemInformationBlockType1-NR updated | timeout=600 |
    ...
    [Arguments]   ${pass_regexp}=${None}   ${timeout}=30   ${wts_alias}=ap_egate   ${cfg_file}=${tl.core.cfg_filename}
    ute_wtssim.execute egate command and wait for data   cmd=cfg file=${cfg_file}   pass_regexp=${pass_regexp}
    ...   timeout=${timeout}   alias=${wts_alias}

ute-wtssim-ue-Keywords.Send Egate Command and verify output
    [Documentation]
    ...    Same as keyword `ute_wtssim.execute`_ egate command and wait for data.
    ...
    ...    http://doc.ute.nsn-rdnet.net/packages/ute_wtssim/interfaces/ute_wtssim.html#execute-egate-command-and-wait-for-data
    ...
    ...    It sends the given ``cmd`` to egate execute.
    ...    ``timeout`` defines the  timeout for this operation.
    ...    ``return_output`` boolean ${False} or ${Ture} indicate whether egate log should be printed out.
    ...    If given regexp ``pass_regexp`` is found in the command response the KW passes whereas if
    ...    the given ``fail_regexp`` is found in the command output the KW fails. The first occurance decides the result.
    ...    If ``return_output`` is True the egate console output will be returned to the caller.
    ...
    ...    | cmd            | Command to execute                                                |
    ...    | timeout        | Timeout for this operation                                        |
    ...    | return_output  | boolean Flag indicating whether egate log should be printed out   |
    ...    | pass_regexp    | Regexp indicating that the command passed                         |
    ...    | fail_regexp    | Regexp indicating that the command failed                         |
    ...    | wts_alias      | alias name to handle egate for ute_wtssim                         |
    ...
    ...    *Example*
    ...    |  `Start WTS for Airphone` |
    ...    |  `Config WTS for Airphone` |
    ...    |    ute-wtssim-ue-Keywords.Send Egate Command and verify output | cmd=sim_state_disp | pass_regexp=The state is ACTIVE |
    ...
    ...    *Returns*   egate console output
    ...
    [Arguments]   ${cmd}   ${timeout}=10   ${return_output}=${True}   ${pass_regexp}=${None}   ${fail_regexp}=${None}
    ...   ${wts_alias}=ap_egate
    ${output}   ute_wtssim.execute egate command and wait for data
    ...   cmd=${cmd}   pass_regexp=${pass_regexp}   fail_regexp=${fail_regexp}
    ...   timeout=${timeout}   return_output=${return_output}   alias=${wts_alias}
    [Return]   ${output}

Force WTS To Init State
    [Documentation]
    ...    Used to bring WTS from e.g. ACTIVE to INIT state.
    ...
    ...    *Scope* Internal
    ...
    ...    | wts_alias      | alias name to handle egate for ute_wtssim     |
    ...
    [Arguments]   ${wts_alias}
    Run Keyword And Return Status
    ...   ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=re   pass_regexp=.*   wts_alias=${wts_alias}
    BuiltIn.Sleep   5s   Guard time until WTS reaches INIT state
    ${sim_status}   Run Keyword And Return Status
    ...   ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=sim_state_disp   pass_regexp=The state is INIT   wts_alias=${wts_alias}
    BuiltIn.Sleep   30s   Guard time until AP becomes idle
    [Return]    ${sim_status}

Start WTS for Airphone
    [Documentation]
    ...    Used for Precondition: GNB and Airphone, at Suite Setup or Testcase setup
    ...    Will setup egate alias ap_egate for keyword  `ute-wtssim-ue-Keywords.Send Egate Command and verify output` previous
    ...    WTS processes should be killed at earlier step, before TL reboot
    ...
    ...    | wts_alias      | alias name to handle egate for ute_wtssim     |
    ...    | edaemon_alias  | alias name to handle edaemon for ute_wtssim   |
    ...    | remove_logs    | remove existing wts logs                      |
    ...    | egate_port     | used egate port                               |
    ...    | edaemon_port   | used edaemon port                             |
    ...
    ...    *Example*
    ...    | ute-wtssim-ue-Keywords.Kill WTS Services |
    ...    | ute-wtssim-ue-Keywords.Start WTS for Airphone      | wts_alias=ap_egate        |
    ...
    [Arguments]   ${wts_alias}=ap_egate   ${edaemon_alias}=ap_edaemon   ${remove_logs}=${False}
    ...   ${egate_port}=${tl.core.egate_port}   ${edaemon_port}=${tl.core.edaemon_port}
    Ue-Wts-Commands-Keywords.Teardown Egate Connection for Airphone     wts_alias=${wts_alias}
    Ue-Wts-Commands-Keywords.Teardown Edaemon Connection for Airphone   edaemon_alias=${edaemon_alias}

    Run Keyword If   ${remove_logs}   OperatingSystem.Run   cd ${tl.core.dir_path} && sudo rm *log*

    ${edaemon_id}   OperatingSystem.Run   sudo pgrep -af 'edaemon.* --port ${edaemon_port}' | grep -v pgrep
    ${egate_id}     OperatingSystem.Run   sudo pgrep -af 'egate.* --port ${egate_port}' | grep -v pgrep

    Run Keyword If   '${edaemon_id}'=='${EMPTY}'   Run Keywords
    ...         OperatingSystem.Run   cd ${tl.core.dir_path} && sudo .\\/edaemon --port ${edaemon_port}
    ...   AND   BuiltIn.Sleep   2s   reason=wait for WTS edaemon startup

    # prevent egate lockup when being started via Run Kw
    Run Keyword If   '${egate_id}'=='${EMPTY}'   Run Keywords
    # ...         OperatingSystem.Run   cd ${tl.core.dir_path} && .\\/egate --port ${egate_port}
    ...         OperatingSystem.Run   cd ${tl.core.dir_path} && .\\/egate --port ${egate_port} > egate.out.${egate_port} 2>&1
    ...   AND   BuiltIn.Sleep   5s   reason=wait for WTS egate startup

    ute_wtssim.setup_egate   egate_port=${egate_port}   host_ip=${tl.core.default_ssh_connection_details.addr}
    ...   tool_dir=${tl.core.dir_path}   alias=${wts_alias}   save_egate=${True}
    ute_wtssim.setup_edaemon   edaemon_port=${edaemon_port}   host_ip=${tl.core.default_ssh_connection_details.addr}
    ...   tool_dir=${tl.core.dir_path}   alias=${edaemon_alias}
    ${wts_status}   Run Keyword And Return Status
    ...   ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=sim_info   pass_regexp=Process ID   wts_alias=${wts_alias}
    ${sim_status}   Run Keyword And Return Status
    ...   ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=sim_state_disp   pass_regexp=The state is INIT   wts_alias=${wts_alias}

    ${sim_status}   Run Keyword If  not $sim_status
    ...             Force WTS To Init State   wts_alias=${wts_alias}
    ...   ELSE      Set Variable    ${sim_status}

    ${ute_wtssim_interface}    Get Library Instance    ute_wtssim
    set suite variable     ${wtsObj}      ${ute_wtssim_interface}

    Run Keyword If   $wts_status==False or $sim_status==False   Fail   WTS is not correctly started
    # Run Keyword If   '${wts_status}'=='True' and '${sim_status}'=='True'     Ue-Wts-Commands-Keywords.Connect to running EGATE using wtsrunner


Trigger LTE dual connectivity and analyze Output
    [Documentation]
        ...    eNB command to trigger LTE-NR dual connectivity for bearers.
    ...
    ...    | ue_id          | ue_id configured in WTS configuration                 |
    ...    | bearer_id      | bearer id configured in WTS configuration (e.g. 9,8)  |
    ...    | target_gnb     | target gNB id                                         |
    ...    | target_cells   | target gNB cells                                      |
    ...    | type           | type of dual connectivity                             |
    ...
    ...    *Returns*   egate analysis accroding to parameters
    [Arguments]  ${ue_id}=11   ${bearer_id}=2   ${target_gnb}=2   ${target_cells}=1   ${type}=split_scg  ${target_path}=/tmp/egate_ouput.json
    ...    ${regex_search}=${EMPTY}
    ${status}  ${egate_output}   Run keyword and ignore Error  Trigger LTE-NR dual connectivity for bearers     ue_id=${ue_id}
    ...    bearer_id=${bearer_id}   target_gnb=${target_gnb}
    ...    target_cells=${target_cells}   type=${type}
    Analyze egate log  status=${status}  egate_output=${egate_output}    target_path=${target_path}    ue_id=${ue_id}  regex_search=${regex_search}
    [return]    ${egate_output}

Trigger LTE-NR dual connectivity for bearers
    [Documentation]
    ...    eNB command to trigger LTE-NR dual connectivity for bearers.
    ...
    ...    | ue_id          | ue_id configured in WTS configuration                 |
    ...    | bearer_id      | bearer id configured in WTS configsuration (e.g. 9,8)  |
    ...    | target_gnb     | target gNB id                                         |
    ...    | target_cells   | target gNB cells                                      |
    ...    | type           | type of dual connectivity                             |
    ...
    ...    *Returns*   egate console output
    ...
    [Arguments]   ${ue_id}=11   ${bearer_id}=2   ${target_gnb}=2   ${target_cells}=1   ${type}=split_scg
    ${output}   ute-wtssim-ue-Keywords.Send Egate Command and verify output
    ...   cmd=enb_ue_dc_start ue=${ue_id} bearer=${bearer_id} target_gnb=${target_gnb} target_cells=${target_cells} type=${type}
    ...   pass_regexp=reported successful RA
    BuiltIn.Log   LTE-NR dual connectivity of UE${ue_id} with bearer${bearer_id} to gNB${target_gnb} and cell${target_cells} is successful
    ...   console=${P_console}
    BuiltIn.Sleep   1s   reason=wait command to be executed
    [Return]   ${output}

Analyze egate log
    [Documentation]  Analyzes egate output and looks for messages with a given regular expression
    [Arguments]  ${status}  ${egate_output}  ${target_path}  ${ue_id}  ${regex_search}=${EMPTY}
    Run Keyword if  '${status}'=='FAIL'  BuiltIn.Log  ue_${ue_id} was not attached sucessfully.  level=Error  console=True
    ${regex_search}=  Run Keyword If  'not ${regex_search}'  Create List  eventId event[A,B]\\d  frequencyBandList
    egate_analyzer.analyze_egate_output  egate_output=${egate_output}  target_file_path=${target_path}  ue_id=${ue_id}
    ...  regex_search=${regex_search}

Trigger LTE-NR dual connectivity modification
    [Documentation]
    ...    Command to trigger LTE-NR dual connectivity modification.
    ...
    ...    | ue_id      | ue_id configured in WTS configuration         |
    ...    | bearer_id  | bearer id configured in WTS configuration     |
    ...    | reason     | reason to trigger SgNB modification           |
    ...    | by         | determines the initiator of the DC procedure  |
    ...    | cause      | cause for the DC procedure                    |
    ...    | type       | type of dual connectivity                     |
    ...
    [Arguments]   ${ue_id}   ${bearer_id}   ${reason}=bearer_to_add   ${by}=enb   ${cause}=RN_CauseRadioNetwork_unspecified
    ...   ${type}=split_scg
    ute-wtssim-ue-Keywords.Send Egate Command and verify output
    ...   cmd=enb_ue_dc_modify ue=${ue_id} ${reason}=${bearer_id} by=${by} cause=${cause} type=${type}
    ...   pass_regexp=SgNBReconfigurationComplete
    BuiltIn.Log   LTE-NR dual connectivity modification with reason ${reason} for bearer ${bearer_id} is successful   console=${P_console}


Set traffic type
    [Documentation]
    ...    Command to set traffic type ``trf_type`` for UE defined by ``ue_id`` and PDU Session Id by ``pdu_id``.
    ...    Parameter ``log_traffic_stats`` specifies if logging is needed on|off.
    ...
    ...    | ue_id:             | ue_id configured in WTS configuration         |
    ...    | pdu_id             | specified PDU session ID                      |
    ...    | trf_type:          | specified traffic type (internal|external)    |
    ...    | log_traffic_stats  | specified to log traffic stats (on|off)       |
    ...
    [Arguments]   ${ue_id}   ${pdu_id}   ${trf_type}=external   ${log_traffic_stats}=off
    ute-wtssim-ue-Keywords.Send Egate Command and verify output
    ...   cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=${trf_type} log_traffic_stats=${log_traffic_stats}
    BuiltIn.Log   Traffic type for UE${ue_id} and PDU${pdu_id} is set to ${trf_type}   console=${P_console}


UE PDU Session Modify
    [Documentation]
    ...    Added additional qos flows to pdu session of an UE. By default adds flows 2 and 3, which are pre-configured in
    ...    basic_setup.cfg and necessary for VoNR.
    ...
    ...    | ue_id              | Specified UE ID                                          |
    ...    | pdu                | PDU Session to be modified                               |
    ...    | list qos_flow_list | list of all the used qos_flows that should be added      |
    ...    | by                 | Device type initiating the procedure ue|amf              |
    ...    | pass_regexp        | regexp to pass the KW if found in egate command response |
    ...    | fail_regexp        | regexp to fail the KW if found in egate command response |
    ...
    [Arguments]   ${ue_id}   ${pdu}=1   ${qos_flow_list}=${NONE}   ${by}=amf   ${pass_regexp}=Added QosFlow with QFI   ${fail_regexp}=${None}
    ${default_qos_list}   Create List   ${2}   ${3}
    ${qos_flow_list}      Set Variable If   ${qos_flow_list}   ${qos_flow_list}   ${default_qos_list}

    FOR   ${qos_parameter}   IN   @{qos_flow_list}
        BuiltIn.Log   ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qos_parameter} by=${by}   console=${P_console}
        ute-wtssim-ue-Keywords.Send Egate Command and verify output
        ...   cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qos_parameter} by=${by}
        ...   pass_regexp=${pass_regexp}   fail_regexp=${fail_regexp}
    END


UE Register
    [Documentation]
    ...    Performs UE registration for the given ``ue_id``.
    ...
    ...    | ue_id          | Specified UE ID                                           |
    ...    | nwslice        | id of the Network Slice containing the requested NSSAI    |
    ...    | pass_regexp    | Regexp indicating that the command passed                 |
    ...    | kwargs         | Optional additional arguments                             |
    ...
    ...    *Returns*   egate console output
    ...
    [Arguments]   ${ue_id}=1   ${nwslice}=1   ${pass_regexp}=Received REGISTRATION COMPLETE   &{kwargs}
    ${command_args}   Convert Dictionary to Parameter String   &{kwargs}
    ${output}   ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=ue_register id=${ue_id} nwslice=${nwslice} ${command_args}
    ...   pass_regexp=${pass_regexp}
    BuiltIn.Log   UE${ue_id} registration is successful   console=${P_console}
    [Return]   ${output}

Update dual connectivity parameters
    [Documentation]
    ...
    ...    | id             | local identifier for eNodeB / gNodeB                                              |
    ...    | kwargs         | dictionary of pairs "parameter:value" (e.g. serving_cell_index_range_scg=5:31)    |
    ...
    [Arguments]   ${id}   &{kwargs}
    ${command_args}   Convert Dictionary to Parameter String   &{kwargs}
    ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=enb_endc_param id=${id}${command_args}
    BuiltIn.Sleep   1s   reason=wait command to be executed
    BuiltIn.Log   Dual connectivity with id=${id} is updated with${command_args}   console=${P_console}


UE Deregister
    [Documentation]
    ...
    ...    | ue_id              | Specified UE ID                                   |
    ...    | ue_deregister_type | Type of UE initiated deregister procedure         |
    ...    | by                 | Device type initiating the deregister procedure   |
    ...
    [Arguments]   ${ue_id}=1   ${ue_deregister_type}=switch_off   ${by}=ue
    ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=ue_deregister id=${ue_id} ue_deregister_type=${ue_deregister_type} by=${by}
    ...   pass_regexp=UE${ue_id}: detached
    BuiltIn.Log   UE${ue_id} deregistration is successful   console=${P_console}


UE Dual Connectivity Release
    [Documentation]
    ...    command to trigger LTE-NR dual connectivity release
    ...
    ...    | ue_id      | Specified UE ID                               |
    ...    | bearer     | Bearer ID List                                |
    ...    | by         | Determines the initiator of the DC procedure  |
    ...    | cause      | Cause for the DC procedure                    |
    ...
    [Arguments]   ${ue_id}=11   ${bearer}=2   ${by}=enb   ${cause}=off
    ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=enb_ue_dc_release ue=${ue_id} bearer=${bearer} by=${by} cause=${cause}
    ...   pass_regexp=Bearer-type change from SCG-split to MCG is successful
    BuiltIn.Log   UE${ue_id} Dual Connectivity Released   console=${P_console}


UE PDU Session Setup
    [Documentation]
    ...    Performs ue_pdu_session_setup and checks if given ``pass_regexp`` is found in egate console output.
    ...
    ...    | pdu            | PDU Session ID                                                                            |
    ...    | gw             | PDU Gateway ID. Specifies gateway to use for this PDU session                             |
    ...    | ue_id          | Specified UE ID                                                                           |
    ...    | nwslice        | Requested Network Slice for the PDU Session                                               |
    ...    | pass_regexp    | Initial Context Setup Successful (for 1st PDU session)                                    |
    ...    | ..             | Pdu Session.*successfully (for further PDU sessions in case of more than 1 PDU session)   |
    ...    | fail_regexp    | regexp to fail the KW if found in egate command response                                  |
    ...
    ...    *Returns*   ue ip    and    egate console output
    ...
    [Arguments]   ${ue_id}=1   ${pdu}=1   ${nwslice}=1   ${gw}=1   ${pass_regexp}=Initial Context Setup Successful   ${fail_regexp}=${None}
    ${output}   ute-wtssim-ue-Keywords.Send Egate Command and verify output
    ...   cmd=ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=${nwslice} gw=${gw}
    ...   pass_regexp=${pass_regexp}   fail_regexp=${fail_regexp}
    ${pattern}   Catenate   Allocated PduSessionFsm with PDU session ID:${pdu} .*
    ...   UE IP address:([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})
    ${ue_ip}   String.Get Regexp Matches   ${output}   ${pattern}   1
    BuiltIn.Log   UE${ue_id} PDU${pdu} session setup is successful   console=${P_console}
    [Return]   ${ue_ip[0]}    ${output}


UE PDU Session Setup and analyze output
    [Documentation]
    ...    Performs ue_pdu_session_setup and checks if given ``pass_regexp`` is found in egate console output.
    ...
    ...    | pdu            | PDU Session ID                                                                            |
    ...    | gw             | PDU Gateway ID. Specifies gateway to use for this PDU session                             |
    ...    | ue_id          | Specified UE ID                                                                           |
    ...    | nwslice        | Requested Network Slice for the PDU Session                                               |
    ...    | pass_regexp    | Initial Context Setup Successful (for 1st PDU session)                                    |
    ...    | ..             | Pdu Session.*successfully (for further PDU sessions in case of more than 1 PDU session)   |
    ...    | fail_regexp    | regexp to fail the KW if found in egate command response                                  |
    ...
    ...    *Returns*   ue ip    and    egate console output
    [Arguments]  ${ue_id}=1   ${pdu}=1   ${nwslice}=1   ${gw}=1   ${pass_regexp}=Initial Context Setup Successful
    ...  ${target_path}='/tmp/egate_ouput.json'    ${regex_search}=${EMPTY}
    ${status}  ${egate_output}   Run keyword and ignore Error  ute-wtssim-ue-Keywords.UE PDU Session Setup     ue_id=${ue_id}
    ...    pdu=${pdu}   nwslice=${nwslice}  gw=${gw}  pass_regexp=${pass_regexp}
    Analyze egate log  status=${status}  egate_output=${egate_output[${1}]}    target_path=${target_path}
    ...    ue_id=${ue_id}  regex_search=${regex_search}

Detach UE from LTE
    [Documentation]
    ...    Initiates UE or MME-initiated detach procedure from LTE cell for the given ``ue_id``.
    ...
    ...    | ue_id          | ue_id configured in WTS configuration             |
    ...    | device_type    | device type initiating the detach procedure       |
    ...    | type           | type of network initiated (MME) detach procedure  |
    ...    | ue_detach_type | type of UE initiated detach procedure             |
    ...
    [Arguments]   ${ue_id}   ${device_type}=ue   ${type}=not_specified   ${ue_detach_type}=automatic
    ute-wtssim-ue-Keywords.Send Egate Command and verify output
    ...   cmd=ue_detach id=${ue_id} ${device_type} type=${type} ue_detach_type=${ue_detach_type}
    ...   pass_regexp=UE${ue_id}: detached
    BuiltIn.Log   UE${ue_id} is detached from LTE   console=${P_console}

Attach UE to LTE
    [Documentation]
    ...    Initiates UE Attach procedure to LTE cell
    ...
    ...    | ue_id                  | ue_id configured in WTS configuration                         |
    ...    | emergency              | toggle for Emergency Attach (not applicable for NB-IoT UE)    |
    ...    | pdn_connectivity_type  | IP version of PDN connectivity                                |
    ...    | kwargs                 | dictionary of pairs "parameter:value"                         |
    ...
    ...    *Returns*   egate console output
    ...
    [Arguments]   ${ue_id}=11   ${emergency}=off   ${pdn_connectivity_type}=auto   &{kwargs}
    ${command_args}   Convert Dictionary to Parameter String   &{kwargs}
    ${output}   ute-wtssim-ue-Keywords.Send Egate Command and verify output
    ...   cmd=ue_attach id=${ue_id} emergency=${emergency} pdn_connectivity_type=${pdn_connectivity_type}${command_args}
    ...   pass_regexp=UE IS ACTIVE
    BuiltIn.Log    UE${ue_id} is attached to LTE    console=${P_console}
    [Return]   ${output}

Trigger RLF
    [Documentation]
    ...    Trigger a radio link failure with the given cause ``failure_type`` for UE ``ue_id`` in dual connectivity.
    ...
    ...    | ue_id          | specified UE id                                           |
    ...    | failure_type   | cause of radio link failure                               |
    ...    | at             | specifies where UE detected radio link failure (gnb|enb)  |
    ...
    [Arguments]   ${ue_id}   ${failure_type}   ${at}
    ...   ${pass_regexp}=Successfully reconfigured dual connectivity .* Bearer-type change .* is successful
    ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=ue_dc_rlf ue=${ue_id} failure_type=${failure_type} at=${at}
    ...   pass_regexp=${pass_regexp}
    BuiltIn.Sleep   1s   reason=wait command to be executed
    BuiltIn.Log   RLF for UE${ue_id} is triggered   console=${P_console}

Configure NR UL SINR testmode
    [Documentation]
    ...
    ...    | profile_id | test profile id                                                                   |
    ...    | kwargs     | dictionary of pairs "parameter:value" (e.g. sinr_target_pusch=100 pathloss=40)    |
    ...
    [Arguments]   ${profile_id}   &{kwargs}
    ${command_args}   Convert Dictionary to Parameter String   &{kwargs}
    ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=ul_sinr_testmode_nr profile_id=${profile_id}${command_args}
    ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=ul_sinr_testmode_nr profile_id=${profile_id}
    ...   pass_regexp=ul_sinr_testmode_nr Parameters
    BuiltIn.Log   NR UL SINR testmode for profile_id ${profile_id} and${command_args} is configured   console=${P_console}

Associate UEs to testmode
    [Documentation]
    ...
    ...    | ue_id          | specified UE ID                                                                           |
    ...    | scell          | carrier Aggregation serving cell (carrier component, CC). Primary is for scell index 0.   |
    ...    | ..             | Secondary is for scell indexes 1-7.                                                       |
    ...    | testmode       | testmode to be used                                                                       |
    ...    | profile_id     | test profile id                                                                           |
    ...    | action         | triggers the activation or the deactivation of the test mode (activate or deactivate)     |
    ...
    [Arguments]   ${ue_id}   ${testmode}   ${profile_id}   ${action}   ${scell}=0
    ${command}   Set Variable   ue_testmode_set_nr id=${ue_id} scell=${scell} testmode=${testmode} profile_id=${profile_id} action=${action}
    ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=${command}
    BuiltIn.Sleep   1s   reason=wait command to be executed
    BuiltIn.Log   ${action} testmode ${testmode} for UE${ue_id} scell=${scell} and profile_id ${profile_id}   console=${P_console}

Update UE Channel State Information
    [Documentation]
    ...
    ...    | profile_id     | specified profile_id                                          |
    ...    | kwargs         | dictionary of pairs "parameter:value" (e.g. cqi_mode=fixed)   |
    ...
    ...    Note: The profile_id used should be in active state and this could be achieved by the
    ...    keyword `Associate UEs to testmode` either before or after this keyword
    [Arguments]   ${profile_id}   &{kwargs}
    ${command_args}   Convert Dictionary to Parameter String   &{kwargs}
    ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=csi_override_testmode_nr profile_id=${profile_id}${command_args}
    ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=csi_override_testmode_nr profile_id=${profile_id}
    ...   pass_regexp=csi_override_testmode_nr Parameters
    BuiltIn.Log   Channel State Information for UE is updated with${command_args}   console=${P_console}

Update UE Radio Link Failure
    [Documentation]
    ...
    ...    | profile_id     | specified profile_id                                          |
    ...    | kwargs         | dictionary of pairs "parameter:value" (e.g. cqi_mode=fixed)   |
    ...
    ...    Note: The profile_id used should be in active state and this could be achieved by the
    ...    keyword `Associate UEs to testmode` either before or after this keyword
    [Arguments]   ${profile_id}   &{kwargs}
    ${command_args}   Convert Dictionary to Parameter String   &{kwargs}
    ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=rlf_testmode_nr profile_id=${profile_id}${command_args}
    ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=rlf_testmode_nr profile_id=${profile_id}
    ...   pass_regexp=rlf_testmode_nr Parameters
    BuiltIn.Log   Radio Link Failure for UE is updated with${command_args}   console=${P_console}


Start data traffic in egate
    [Documentation]
    ...    Start data traffic (NSA/SA)
    ...
    ...    | ue_id          | ue_id configured in WTS configuration                                         |
    ...    | direction:     | dl or ul traffic direction                                                    |
    ...    | protocol:      | L3 protocol type, e.g. udp|tcp|icmp                                           |
    ...    | ack_mode:      | toggle for receiver to generate an ack, e.g. on|off                           |
    ...    | trf_id:        | traffic id, e.g. 1                                                            |
    ...    | cl_trf_stats   | toggle for clear L3 statistics for the traffic instance, e.g. on|off          |
    ...    | kwargs:        | dictionary of pairs "parameter:value", e.g. id=2, mbps=5, rtp_codec=custom    |
    ...    | ..             | rtp_ps=32 or rtp_ts_step=1000                                                 |
    ...
    [Arguments]   ${ue_id}=${EMPTY}   ${direction}=${EMPTY}   ${protocol}=udp   ${ack_mode}=off   ${trf_id}=1
    ...   ${cl_trf_stats}=on    &{kwargs}
    ${command_args}   Convert Dictionary to Parameter String    &{kwargs}
    ${command}   Catenate
    ...   trf_data_start ue=${ue_id} dir=${direction} trf_id=${trf_id}
    ...   protocol=${protocol} ack_mode=${ack_mode} cl_trf_stats=${cl_trf_stats}${command_args}
    ${output}   ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=${command}   pass_regexp=TRF
    Validate if traffic has started on all UEs   ue_ids=${ue_id}   output=${output}   protocol=${protocol}   direction=${direction}
    ...  command_args=${command_args}


Stop data traffic in egate
    [Documentation]
    ...    Stop running data traffic (NSA/SA) for the given ``ue_id``.
    ...
    ...    | ue_id:     | ue_id configured in WTS configuration             |
    ...    | direction  | ul|dl|bi traffic direction                        |
    ...    | trf_id:    | traffic id, e.g. 1                                |
    ...    | kwargs:    | dictionary of pairs "parameter:value" (e.g. id=2) |
    ...
    [Arguments]   ${ue_id}   ${direction}   ${trf_id}=1   &{kwargs}
    ${command_args}   Convert Dictionary to Parameter String   &{kwargs}
    ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=trf_data_stop ue=${ue_id} dir=${direction} trf_id=${trf_id}${command_args}
    ...   pass_regexp=${direction.upper()} Traffic was stopped||Stopping .* traffic
    BuiltIn.Log   ${direction.upper()} data for UE${ue_id} and${command_args} is stopped   console=${P_console}

Validate if traffic has started on all UEs
    [Documentation]
    ...     Validates traffic start on single or multiple UEs
    ...
    ...     *Scope*  Internal
    ...
    [Arguments]   ${ue_ids}   ${output}   ${protocol}   ${direction}   ${command_args}
    ${ue_ids}   Convert To String   ${ue_ids}
    @{ue_ids_list}   String.Split String	${ue_ids}   ,
    FOR   ${UE_ID}   IN   @{ue_ids_list}
       ${matches}   BuiltIn.run_keyword_and_warn_on_failure   Should Match Regexp
       ...   ${output}   UE ${UE_ID}: ${protocol.upper()} ${direction.upper()} TRF
       Run Keyword If   '${matches[0]}'=='PASS'   BuiltIn.Log
       ...   ${direction.upper()} ${protocol.upper()} data for UE${UE_ID} and${command_args} is started   console=${P_console}
    END

Display bearer stats
    [Documentation]
    ...    Displays bearer statistics or per-traffic(s) statistics of the bearer.
    ...
    ...    | ue_id          | sets the ue_id configured in WTS configuration                                |
    ...    | type           | specify the statistics type                                                   |
    ...    | scell          | the carrier aggregation serving cell (carrier component, CC)                  |
    ...    | ..             | Primary is for scell index 0. Secondary is for scell indexes 1-7.             |
    ...    | format         | display format                                                                |
    ...    | size_unit      | unit of PDU/SDU/packets size                                                  |
    ...    | trf_id         | traffic id/ids (only for internal traffic. default=1). For 'l3_trf' type      |
    ...    | dc_cell_group  | displays the UE's MCG or SCG bearer statistics (appl. only for DC bearers)    |
    ...    | kwargs         | is an optional dictionary of pairs "parameter:value" (e.g. id=2 or pdu=1)     |
    ...
    ...    http://wts-documentation.dyn.nesc.nokia.net/wts-ci/eGate/WTS_2112_WK48_4.0.19019_3686685.2/html_files/html_cmd_files/bearer_stats.html
    ...
    ...    *Returns*   egate console output
    ...
    [Arguments]   ${ue_id}   ${direction}=bi   ${type}=l3   ${scell}=0   ${format}=short   ${size_unit}=auto
    ...   ${trf_id}=1   ${dc_cell_group}=all   &{kwargs}
    ${gNbCuType}   Get gNbCuType Info
    Run keyword If   '${gNbCuType}'=='NSA'   Set To Dictionary   ${kwargs}   dc_cell_group=${dc_cell_group}
    ${command_args}   Convert Dictionary to Parameter String   &{kwargs}
    ${str}   Catenate
    ...   bearer_stats ue=${ue_id} dir=${direction} type=${type} scell=${scell} format=${format} size_unit=${size_unit}
    ...   trf_id=${trf_id}${command_args}
    ${output}   ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=${str}
    ...   pass_regexp=Average data rate
    Log   Stats for UE${ue_id} and${command_args} are displayed   console=${P_console}
    [Return]   ${output}

Display bearer stats for multiple UE'S
    [Documentation]
    ...    Displays bearer statistics or per-traffic(s) statistics of the bearer.
    ...
    ...    | ue_id          | ue_id(s) configured in WTS configuration                                      |
    ...    | direction      | direction                                                                     |
    ...    | type           | statistics type                                                               |
    ...    | scell          | carrier aggregation serving cell (carrier component, CC). Primary is for      |
    ...    | ..             | scell index 0. Secondary is for scell indexes 1-7                             |
    ...    | format         | display Format                                                                |
    ...    | size_unit      | unit of PDU/SDU/packets size                                                  |
    ...    | trf_id         | traffic id/ids (only for internal traffic. For 'l3_trf' type                  |
    ...    | dc_cell_group  | displays the UE's MCG or SCG bearer statistics (appl. only for DC bearers)    |
    ...    | kwargs         | dictionary of pairs "parameter:value" (e.g. id=2 or pdu=1)                    |
    ...
    ...    http://wts-documentation.dyn.nesc.nokia.net/wts-ci/eGate/WTS_2112_WK48_4.0.19019_3686685.2/html_files/html_cmd_files/bearer_stats.html
    ...
    ...    *Returns*   egate console output
    ...
    [Arguments]   ${ue_id}   ${direction}=bi   ${type}=l3   ${scell}=0   ${format}=short   ${size_unit}=auto
    ...   ${trf_id}=1   ${dc_cell_group}=all   &{kwargs}
    ${gNbCuType}   testline-Keywords.Get gNbCuType Info
    Run keyword If   '${gNbCuType}' == 'NSA'   Set To Dictionary   ${kwargs}   dc_cell_group=${dc_cell_group}
    ${command_args}   Convert Dictionary to Parameter String   &{kwargs}
    ${str}   Catenate
    ...   bearer_stats ue=${ue_id} dir=${direction} type=${type} scell=${scell} format=${format} size_unit=${size_unit}
    ...   trf_id=${trf_id}${command_args}
    ${output}   ute-wtssim-ue-Keywords.Send Egate Command and verify output    cmd=${str}
    ...   pass_regexp=[0-9]{0,2}:
    BuiltIn.Log   Stats for UE${ue_id} and${command_args} are displayed   console=${P_console}
    [Return]   ${output}

Get Bearer Stats From Egate
    [Documentation]
    ...
    ...    Reads the output of bearer stats and returns the output as dict/int.
    ...    Output with ``only_average=${False}`` is a Dictionary containing ue_id, timestamp and all the gathered data.
    ...    If used with ``only_average=${True}`` it will return an integer value of the Average throughput of the first item in egate output.
    ...    This should not be used with more than one UE or direction.
    ...
    ...    | ue_id          | Id's of UE's in WTS                                                                                       |
    ...    | dir            | Direction (ul|dl|bi)                                                                                      |
    ...    | trf_id         | Id or Ids of Traffic                                                                                      |
    ...    | mode           | Defines the output you want. accepts "legacy", "only_average" and "all", which will return all data       |
    ...    | kwargs         | dictionary of pairs "parameter:value" (e.g. id=2 or pdu=1)                                                |
    ...
    ...    please refer to the egate documentation of bearer stats egate command too:
    ...    Description of all E Gate parameters can be found here: select 'bearer_stats' for bearer stats command description:
    ...
    ...    https://wts-ci-main.dyn.nesc.nokia.net/job/WTS.Documentation.Egate/E-Gate_20Documentation/
    ...
    ...    *Example*
    ...    | ${data_rate}= | wts_ue.Get Bearer Stats From Egate | ue_id=1,2,3 | id=2,3 | dir=dl | trf_id=1 |
    ...
    ...    *Returns*   traffic Int or Dict, depending on "mode" parameter. mode="only_average" -> INT; mode="legacy" -> Dict.
    ...                For mode="all" will return a dict as well, but with the key's named exactly like in the "bearer_stats" output.
    ...    If it fails, returns string.
    ...    | dict for mode "legacy" has the following structure (all throughput values in bps):
    ...    | {
    ...    |      "UE_101": "UL": {"Average_Throughput": 10000, "Current_Throughput": 12311},
    ...    |                "DL": {"Average_Throughput": 500000, "Current_Throughput": 123111}
    ...    |      "timestamp": "22.03.2022 12:22:13.413579"
    ...    | }
    ...    | dict for mode "all" hast the following structure:
    ...    |{
    ...    |    "UE_101": "UL": {'Timebase interval (msec)': 1000, 'Average window size (in timebases)': 10, 'Real average window size': 1,
    ...    |                       'Maximum data rate': 5100000, 'Minimum data rate': 5100000, 'Average data rate': 5100000},
    ...    |    "timestamp": "26.06.2023 15:32:36.257704"
    ...    |}
    ...    Multiple UE's may be present, but only 1 timestamp per call.
    ...
    ...    To access certain elemets inside the dictionary the following syntax can be used: (sample shows access to dict for mode "all")
    ...    ${ret_val}= |       Get Bearer Stats From Egate | ue_id=101 | dir=bi | trf_id=1
    ...    ${timestamp}= |     Set Variable | ${ret_val["timestamp"]}                         # timestamp shows string "26.06.2023 15:32:36.257704"
    ...    ${av_data_rate}= |  Set variable | ${ret_val["UE_101"]["DL"]["Average data rate"]} # av_data_rate shows integer value 5100000
    ...    ${ul_data_rates}= | Set Variable | ${info["UE_101"]["UL"]} # ul_data_rates shows (sub)dict of all UL data rates of UE_101
    ...    # i.e. {'Timebase interval (msec)': 1000, 'Average window size (in timebases)': 10,... , 'Average data rate': 5100000}
    ...
    [Arguments]   ${ue_id}   ${dir}=bi   ${trf_id}=all   ${mode}=legacy   &{kwargs}
    ${dc_cell_group}   Set Variable If   '${dir}'=='dl'   scg   all

    ${output}   Display bearer stats for multiple UE'S   ue_id=${ue_id}   direction=${dir}   trf_id=${trf_id}   type=l3
    ...   dc_cell_group=${dc_cell_group}   &{kwargs}

    ${result}   tools_py.get_all_parameters_from_bearer_stats_output   ${output}   mode=${mode}
    ${string_output}   Convert To String   ${result}
    Run Keyword If   "${string_output}"=="No Data Found In Output"   Fail   msg=bearer_stats failed. Output is empty.
    [Return]   ${result}

Display Qfi stats
    [Arguments]    ${ue_id}=1     ${pdu_id}=1     ${qfi_id}=1    ${trf_id}=1    ${w_display}=${False}
    ${cmd}=   Catenate       qfi_stats ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} trf_id=${trf_id} dir=bi
    ${output}   ute-wtssim-ue-Keywords.Send Egate Command and verify output    cmd=${cmd}    pass_regexp=Average packet interval
    run keyword if     ${w_display}    BuiltIn.Log     qfi_stats = ${output}     console=${P_console}
    [Return]   ${output}

Display PDSCH and PUSCH ue_stats_nr
    [arguments]     ${ue_id}=1    ${CallType}=NSA    ${DlTput}=0    ${UlTput}=0    ${alias}=ap_egate
    ${scell_idx}     set variable if    '${CallType}'=='NSA'   8
    ...                                                        0-10
    ${DLTput_unit}   set variable if    '${DlTput}'=='0'     Kbps
    ...                                                      Mbps
    ${ULTput_unit}   set variable if    '${UlTput}'=='0'     Kbps
    ...                                                      Mbps
    Run keyword and ignore error     ute-wtssim-ue-Keywords.Get PDSCH ue_stats_nr   ue_id=${ue_id}   scell_idx=${scell_idx}
    ...                                                                             unit=${DLTput_unit}    alias=${alias}
    Run keyword and ignore error     ute-wtssim-ue-Keywords.Get PUSCH ue_stats_nr   ue_id=${ue_id}   scell_idx=${scell_idx}
    ...                                                                             unit=${ULTput_unit}    alias=${alias}

Get PDSCH ue_stats_nr
    [arguments]     ${ue_id}=1    ${scell_idx}=8     ${unit}=Mbps    ${alias}=default
    ${Ue_Avg_PDSCH_Tput}=  ute-wtssim-ue-Keywords.Get AVG DL DATA TRAFFIC For Given CC    ue_id=${ue_id}    scell_idx=${scell_idx}
    ...                                                                                   unit=${unit}    alias=${alias}
    Dated log     =============> Ue_Avg_PDSCH_Tput=${consTraceColor}${Ue_Avg_PDSCH_Tput}${unit}${defColor} for ue_id=${ue_id}
    [return]   ${Ue_Avg_PDSCH_Tput}

Get PUSCH ue_stats_nr
    [arguments]     ${ue_id}=1    ${scell_idx}=8      ${unit}=Mbps    ${alias}=default
    ${Ue_Avg_PUSCH_Tput}=  ute-wtssim-ue-Keywords.Get AVG UL DATA TRAFFIC For Given CC   ue_id=${ue_id}    scell_idx=${scell_idx}
    ...                                                                                  unit=${unit}   alias=${alias}
    Dated log     =============> Ue_Avg_PUSCH_Tput=${consTraceColor}${Ue_Avg_PUSCH_Tput}${unit}${defColor} for ue_id=${ue_id}
    [return]   ${Ue_Avg_PUSCH_Tput}

Get AVG DL DATA TRAFFIC For Given CC
    [Arguments]    ${ue_id}=1    ${scell_idx}=0     ${unit}=Mbps     ${alias}=default
    ${pdsch_ue_stats}    ute-wtssim-ue-Keywords.Get PDSCH UE Stats for Given CC    ${ue_id}    ${scell_idx}    ${alias}
    ${variable_exists}=    Run Keyword And Return Status    Variable Should Exist    ${resultFile}
    ${isEmpty}             Run Keyword And Return Status    Should Be Empty          ${resultFile}
    run keyword if   ${variable_exists} and not ${isEmpty}  Append To File   ${resultFile}
    ...                                                                      \n\t\tGet PDSCH UE Stats for Given CC =\n ${pdsch_ue_stats}\n
	nps_trf_tools.log_to_console_with_time_prefix     ue_stats_nr for UedId=${ue_id}   level=INFO
	bearer_stats.get_tput_from_ue_stats    ue_stats_str=${pdsch_ue_stats}     UeId=${ue_id}    dir=PDSCH
	${avg_tput}   avg_dl_data.get_avg_dl_data_traffic    ${pdsch_ue_stats}    unit=${unit}
	# Log to Console    ${avg_tput}
    [Return]      ${avg_tput}

Get AVG UL DATA TRAFFIC For Given CC
    [Arguments]    ${ue_id}=1    ${scell_idx}=0     ${unit}=Mbps       ${alias}=default
    ${pusch_ue_stats}    ute-wtssim-ue-Keywords.Get PUSCH UE Stats for Given CC   ${ue_id}    ${scell_idx}    ${alias}
    ${variable_exists}=    Run Keyword And Return Status    Variable Should Exist    ${resultFile}
    ${isEmpty}             Run Keyword And Return Status    Should Be Empty          ${resultFile}
    run keyword if   ${variable_exists} and not ${isEmpty}  Append To File   ${resultFile}
    ...                                                                      \n\t\tGet PUSCH UE Stats for Given CC =\n ${pusch_ue_stats}\n
	nps_trf_tools.log_to_console_with_time_prefix     ue_stats_nr for UedId=${ue_id}   level=INFO
	bearer_stats.get_tput_from_ue_stats    ue_stats_str=${pusch_ue_stats}     UeId=${ue_id}    dir=PUSCH
	${avg_tput}   avg_ul_data.get_avg_ul_data_traffic    ${pusch_ue_stats}    unit=${unit}
	# Log to Console    ${avg_tput}
    [Return]      ${avg_tput}

Get PDSCH UE Stats for Given CC
    [Arguments]    ${ue_id}=1    ${scell_idx}=0    ${alias}=ap_egate
    # Log to Console    PDSCH UE stats for given CC
    ${cmd}=   Catenate   ue_stats_nr id=${ue_id} type=pdsch scell=${scell_idx} size_unit=bytes
    # ${pattern}     Set Variable        CellIndex-${scell_idx}
    ${pattern}     Set Variable        CellIndex-.*
    ${output}    ute-wtssim-ue-Keywords.Send Egate Command and verify output       cmd=${cmd}
    ...    pass_regexp=${pattern}    timeout=5
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    # Dated log        ${cmd}
    # Log To Console    \n${output}
    [Return]      ${output}

Get PUSCH UE Stats for Given CC
    [Arguments]    ${ue_id}=1    ${scell_idx}=0   ${alias}=ap_egate
    # Log to Console    PUSCH UE stats for given CC
    ${cmd}=   Catenate   ue_stats_nr id=${ue_id} type=pusch scell=${scell_idx} size_unit=bytes
    # ${pattern}     Set Variable        CellIndex-${scell_idx}
    ${pattern}     Set Variable        CellIndex-.*
    ${output}    ute-wtssim-ue-Keywords.Send Egate Command and verify output    cmd=${cmd}
    ...    pass_regexp=${pattern}    timeout=5
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    # Dated log        ${cmd}
    # Log To Console    \n${output}
    [Return]      ${output}

Set timing adjustment
    [Documentation]
    ...   Set the test mode parameters given by ``kwargs`` dictionary for a ``profile_id``.
    ...
    ...   | profile_id      | test profile id                                                               |
    ...   | kwargs          | dictionary of pairs "parameter:value" (e.g. nb_reps_ta_sim=255 ue_speed=70)   |
    ...
    [Arguments]   ${profile_id}   &{kwargs}
    ${command_args}   Convert Dictionary to Parameter String   &{kwargs}
    ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=ue_ta_nr profile_id=${profile_id}${command_args}
    BuiltIn.Sleep   1s   reason=wait command to be executed
    BuiltIn.Log   Timing adjustment for profile_id ${profile_id} and${command_args} is set   console=${P_console}

Collect egate log files
    [Documentation]
    ...     With this KW the egate log files will be collected and stored in ``target_dir``.
    ...     Run this keyword before egate teardown.
    ...
    ...    | target_dir | directory to store the egate log files    |
    ...    | wts_alias  | alias name to handle egate for ute_wtssim |
    ...
    [Arguments]   ${target_dir}=${None}   ${wts_alias}=ap_egate
    ${target_dir}   Run Keyword If   '${target_dir}'=='${None}'   testcase-Keywords.Get Testcase Log Directory
    ...   ELSE      Set Variable    ${target_dir}
    ute_wtssim.collect_egate_log_files   unzip=${False}   subdirectory=${target_dir}   alias=${wts_alias}

Collect edaemon log files
    [Documentation]
    ...     With this KW the edaemon log files will be collected and stored in ``target_dir``.
    ...     Run keyword before edaemon teardown.
    ...
    ...    | target_dir     | directory to store the edaemon log files      |
    ...    | edaemon_alias  | alias name to handle edaemon for ute_wtssim   |
    ...
    [Arguments]   ${target_dir}=${None}   ${edaemon_alias}=ap_edaemon
    ${target_dir}   Run Keyword If   '${target_dir}'=='${None}'   testcase-Keywords.Get Testcase Log Directory
    ...   ELSE      Set Variable     ${target_dir}
    ute_wtssim.collect edaemon log files   unzip=${False}   subdirectory=${target_dir}   alias=${edaemon_alias}

Start RRC Log
    [Arguments]    ${tag}=${EMPTY}
    OperatingSystem.Run     command=rm -rf ${WTS_DIR}/rrc*.log
    Run Keyword And Ignore Error     ute-wtssim-ue-Keywords.Send Egate Command and verify output     cmd=sim_trace uec=1 protocol=rrc on
    # detailed ue capability information will not print if no this command
    # Run Keyword And Ignore Error     wtsemu.sim_tracefilter    protocol=rrc    clear
    ute-wtssim-ue-Keywords.Send Egate Command and verify output     cmd=script file=${run_script_log_set} entry=sim_tracefilter_rrc_clear()
    ${rrc_name}=    Set Variable If    ${tag.__len__()}==0     rrc.log
    ...                                                        rrc_${tag}.log
    # Run Keyword And Ignore Error     wtsemu.set_log     flush
    ${status}  ${TAIL_PID}    Run Keyword And Ignore Error    Dev_lib.Tail Log     ${WTS_DIR}/egate_console.log
    ...                                                                            ${WTS_DIR}/${rrc_name}
    Set Suite Variable  ${TAIL_PID}
    BuiltIn.Sleep  2s  #avoid missing the previous logs of the egate command immediated being executed

Stop RRC Log
    # Run Keyword And Ignore Error    wtsemu.sim_log_set    flush
    ute-wtssim-ue-Keywords.Send Egate Command and verify output     cmd=script file=${run_script_log_set} entry=sim_log_set_flush()
    Run Keyword And Ignore Error    Dev_lib.Kill Linux Process    ${TAIL_PID}
    Run Keyword And Ignore Error    OperatingSystem.Run     command=cp ${WTS_DIR}/rrc*.log ${testCaseDir}

UE Idle via NAS Release
    [Arguments]   ${ue_id}=1
    ute-wtssim-ue-Keywords.Send Egate Command and verify output  ue_ng_ctx_release id=${ue_id} cause=NAS_normal_release
    ...    pass_regexp=Received UE Context Release Complete from GNB   timeout=30s

Paging from AMF on UE
    [Arguments]    ${ue_id}    ${loop_number}
    ${cmd}    Catenate    amf_paging_start id\=1 ue\=${ue_id}
    FOR    ${loop}    IN RANGE    ${loop_number}
        ${status}=    run keyword and return status     Make UE to idle    ${ue_id}
        BuiltIn.sleep   0.5s
        run keyword if    ${status}    BuiltIn.Log   IDLE OK   console=${P_console}
        ...    ELSE                    BuiltIn.Log   IDLE FAILED   console=${P_console}
        run keyword if    ${status}    BuiltIn.Log   Start to paging   console=${P_console}
        run keyword if    ${status}    ute-wtssim-ue-Keywords.Send Egate Command and verify output   ${cmd}    pass_regexp=reestablishment complete
        BuiltIn.sleep   0.5s
    END

Make UE to idle
    [Arguments]    ${ue_id}
    BuiltIn.Log       NAS normal release in progress     console=${P_console}
    ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=amf_paging_param id\=1 default_drx=128 max_paging_retries\=1
    ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=ue_ng_ctx_release id\=${ue_id} cause\=NAS_normal_release
    ...                                                           pass_regexp=: IS IDLE

ue_rrc_reestablish on UE
    [Arguments]    ${ue_id}   ${cell_id}    ${loop_number}
    ${cmd}    Catenate    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id}
    FOR    ${loop}    IN RANGE    ${loop_number}
        BuiltIn.Log   Start: ue_rrc_reestablish id=${ue_id} cell=${cell_id}   console=${P_console}
        ute-wtssim-ue-Keywords.Send Egate Command and verify output      ${cmd}
        sleep  1s
    END

Start ue_rrc_reestablish
    [Arguments]  ${cell_id}
    ${attached_ues_dict}=  Get Attach List per Cell    scenario_name=${scenario_name}    ue_type=all    with_auto_attach=${TRUE}
    FOR  ${ue_id}  IN  @{attached_ues_dict['${cell_id}']}
        log to console    Start: ue_rrc_reestablish id=${ue_id} cell=${cell_id}
        ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id}
        sleep  1s

Configure NR BLER testmode
    [Documentation]
    ...
    ...    | profile_id | test profile id                                                                       |
    ...    | kwargs     | dictionary of pairs "parameter:value" (e.g. dl_bler=100,600,700,800,200,300,400,500)  |
    ...
    [Arguments]   ${profile_id}   &{kwargs}
    ${command_args}   Convert Dictionary to Parameter String   &{kwargs}
    ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=bler_testmode_nr profile_id=${profile_id}${command_args}
    Sleep   1s   reason=wait command to be executed
    BuiltIn.Log   NR BLER testmode for profile_id ${profile_id} and${command_args} is configured   console=${P_console}


Configure NR Advanced BLER testmode
    [Documentation]
    ...
    ...    | profile_id | test profile id                                                                             |
    ...    | kwargs | dictionary of pairs "parameter:value" (e.g. target_bler, retx_target_bler1, target_mcs, rank...)|
    ...    | please find more details --> https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1743587025|
    ...
    [Arguments]   ${profile_id}   &{kwargs}
    ${command_args}   Convert Dictionary to Parameter String   &{kwargs}
    ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=adv_bler profile_id=${profile_id}${command_args}
    ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=adv_bler profile_id=${profile_id}
    ...   pass_regexp=adv_bler_testmode_nr Parameters
    BuiltIn.Log   NR Advanced BLER testmode for profile_id ${profile_id} and${command_args} is configured   console=${P_console}


Check Current Egate Console Status
    [Documentation]
    ...    flush the egate log to update egate_console.log then check for the query
    ...    should be used for triggerless/async events e.g. NG Link, SIB, MIB, Cell Setup for SA
    ...
    ...    | query          | Specific log in egate console     |
    ...
    ...    *Example*
    ...    | Check Current Egate Console Status | NG link is Up |
    ...
    [Arguments]   ${query}
    ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=sim_log_set flush

    ${egate_log}   OperatingSystem.Run   grep -i '${query}' ${tl.core.dir_path}/egate_console.log
    Should Contain   ${egate_log}   ${query}   ignore_case=True


Save Current Egate Console Log
    [Documentation]
    ...    for post analysis of egate_console.log per testcase
    ...    flushes the egate log to update egate_console.log then save to target directory
    ...
    ...    | target_dir     | Directory to store the egate_console.log file |
    ...    | target_name    | filename to save the file                     |
    ...
    ...    *Returns*   path to the stored egate log
    ...
    [Arguments]   ${target_dir}=${None}   ${target_name}=egate_console.log
    ${target_dir}   Run Keyword If   '${target_dir}'=='${None}'   testline.Get Testcase Log Directory
    ...   ELSE      Set Variable     ${target_dir}

    ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=sim_log_set flush

    OperatingSystem.Run   cp ${tl.core.dir_path}/egate_console.log ${target_dir}/${target_name}
    [Return]   ${target_dir}/${target_name}

Configure Beam Control Testmode
    [Documentation]
    ...
    ...    | profile_id | test profile id                                                                                   |
    ...    | kwargs     | dictionary of pairs "parameter:value" (e.g. ueBeamIndexInitial=0,1,2,3,4,5 ssbeam_bestbeam=0 ...) |
    ...
    [Arguments]   ${profile_id}   &{kwargs}
    ${command_args}   Convert Dictionary to Parameter String   &{kwargs}
    ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=beam_control_testmode_nr profile_id=${profile_id}${command_args}
    Sleep   1s   reason=wait command to be executed
    BuiltIn.Log   ${\n}Beam Control testmode for profile_id ${profile_id} and${command_args} is configured   console=${P_console}


Delete NR UL SINR testmode
    [Documentation]
    ...
    ...    | profile_id | test profile id                                                                   |
    ...
    [Arguments]   ${profile_id}
    ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=ul_sinr_testmode_nr profile_id=${profile_id} delete=true
    ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=ul_sinr_testmode_nr profile_id=${profile_id}
    ...   pass_regexp=UlSinr TestMode not configured
    BuiltIn.Log   ${\n}NR UL SINR testmode for profile_id ${profile_id} is deleted   console=${P_console}

Change ue Timing Advance on Airphone to ${delay_initial} for ue ${ueid}
    ${profile_id}=     Evaluate    ${ueid}+${4}
    ute-wtssim-ue-Keywords.Send Egate Command and verify output
    ...  cmd=ue_ta_nr profile_id=${profile_id} ue_p_delay_initial=${delay_initial}
    # ute-wtssim-ue-Keywords.Send Egate Command and verify output
    #     ...  cmd=ue_testmode_set_nr id=${ueid} testmode=ta action=activate profile_id=${ueid}+${4}
    ute-wtssim-ue-Keywords.Associate UEs to testmode  ue_id=${ueid}  testmode=ta  profile_id=${profile_id}  action=activate

Set UE-${ueid} as ${speed} Speed UE ${speed_direction} gNB
    ${profile_id}=     Evaluate    ${ueid}+${4}
    Run Keyword If      '${speed}' == "low" and '${speed_direction}' == "approaching"
    ...                  Set UE as low speed and approaching gNB    ${ueid}
    Run Keyword If      '${speed}' == "low" and '${speed_direction}' == "leaving"
    ...                  Set UE as low speed and leaving gNB    ${ueid}
    Run Keyword If      '${speed}' == "high" and '${speed_direction}' == "approaching"
    ...                  Set UE as high speed and approaching gNB    ${ueid}
    Run Keyword If      '${speed}' == "high" and '${speed_direction}' == "leaving"
    ...                  Set UE as high speed and leaving gNB    ${ueid}
    ute-wtssim-ue-Keywords.Associate UEs to testmode  ue_id=${ueid}  testmode=ta  profile_id=${profile_id}  action=activate

Configure testmode for UE-${ueid} with ${ue_fo_velocity}
    ${profile_id}=     Evaluate    ${ueid}+${4}
    ute-wtssim-ue-Keywords.Send Egate Command and verify output
    ...  cmd=ue_ta_nr profile_id=${profile_id} ue_fo_velocity=${ue_fo_velocity}

Set UE as low speed and leaving gNB
    [Arguments]    ${ueid}
    Configure testmode for UE-${ueid} with VELOCITY_LEAVING_GNB_AT_100KMPH

Set UE as high speed and leaving gNB
    [Arguments]    ${ueid}
    Configure testmode for UE-${ueid} with VELOCITY_LEAVING_GNB_AT_350KMPH

Set UE as low speed and approaching gNB
    [Arguments]    ${ueid}
    Configure testmode for UE-${ueid} with VELOCITY_APPROACHING_GNB_AT_100KMPH

Set UE as high speed and approaching gNB
    [Arguments]    ${ueid}
    Configure testmode for UE-${ueid} with VELOCITY_APPROACHING_GNB_AT_350KMPH

Changing cell Noise level for all cells
    [Arguments]  ${noise}   ${cell_id}
    ute-wtssim-ue-Keywords.Send Egate Command and verify output
    ...      cmd=ul_cell_noise_testmode_nr profile_id=2 noise_pucch=${noise} noise_prach=${noise} noise_pusch=${noise} noise_srs=${noise}
    ute-wtssim-ue-Keywords.Send Egate Command and verify output
    ...      cmd=ul_cell_noise_testmode_nr profile_id=2
    ute-wtssim-ue-Keywords.Send Egate Command and verify output
    ...      cmd=cell_testmode_set_nr cell_id=${cell_id} gnb=2 testmode=ul_cell_noise profile_id=2 action=activate


Changing UE Pathloss level for all UEs
    [Arguments]  ${non_attached_ues_list}   ${pathloss_value}
    ute-wtssim-ue-Keywords.Send Egate Command and verify output
    ...      cmd=ul_sinr_testmode_nr profile_id=9 pathloss=${pathloss_value}
    ute-wtssim-ue-Keywords.Send Egate Command and verify output
    ...      cmd=ul_sinr_testmode_nr profile_id=9
    FOR  ${id}  IN  @{non_attached_ues_list}
        ute-wtssim-ue-Keywords.Send Egate Command and verify output
        ...      cmd=ue_testmode_set_nr id=${id} scell=0 testmode=ul_sinr profile_id=9 action=activate
    END

Simulate Pathloss
    [Arguments]    ${pathloss_start_dB}=75    ${pathloss_end_dB}=129    ${pathloss_step_dB}=1
    FOR    ${pathloss}    IN RANGE    ${pathloss_start_dB}    ${pathloss_end_dB}    ${pathloss_step_dB}
        ute-wtssim-ue-Keywords.Configure NR UL SINR testmode    profile_id=9    pathloss=${pathloss}
        BuiltIn.sleep     1s
    END

Simulate Pathloss and ue Paging
    [Arguments]    ${pathloss_start_dB}=75    ${pathloss_end_dB}=129    ${pathloss_step_dB}=1    ${ue_id}=1
    FOR    ${pathloss}    IN RANGE    ${pathloss_start_dB}    ${pathloss_end_dB}    ${pathloss_step_dB}
        ute-wtssim-ue-Keywords.Configure NR UL SINR testmode    profile_id=9    pathloss=${pathloss}
        BuiltIn.sleep     1s
        ute-wtssim-ue-Keywords.Paging from AMF on UE    ue_id=${ue_id}    loop_number=1
    END

get and display ue_summary
    [Arguments]          ${testParam}=Param    ${alias}=default
    ...                  ${wtsObj}=wts
    ${cmd}=     catenate    ue_summary
    ${output}    Call Method    ${wtsObj}   execute_egate_command_and_wait_for_data      cmd=${cmd}    alias=${alias}
    Log to console    ue_summary=${output}


DSS_CRM_Cell_Setup_Phase3_TO REMOVE
#     [Arguments]                 ${testParam}=Param    ${alias}=default
     [Arguments]                 ${alias}=default

    Log to console   \n${blue}***DSS ${Param.Context.DSS_Phase} CRM CellSetup BW=${Param.seq.bandwidth} with alias=${alias}*** ${normal}

    ute_wtssim.execute egate command    cmd=enb_dss_param id=${Param.Context.eNBId} feature_flag=on message_sets=DMS3    alias=${alias}
    Sleep   2
    ${antenna_ports_num}   run Keyword if   '${Param.Context.nrCellType}'=='4DL4UL'
    ...                       set variable    4
    ...           ELSE        set variable    2
    ute_wtssim.execute egate command
    ...                 cmd=enb_cell_param enb=${Param.Context.eNBId} id=1 lte_nr_dss_mode=DSS_PHASE_3 antenna_ports_num=${antenna_ports_num}
    ...                              alias=${alias}
    Sleep   2
    ute_wtssim.execute egate command    cmd=enb_cell_dss_feature enb=${Param.Context.eNBId} id=1 nr_dl_peak_rate_increase=on    alias=${alias}
    Sleep   2
    ${superfast_allocation}   run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssFastAlloc}'=='true'    set variable    on
    ...           ELSE        set variable    off
    ${cmd}=    Catenate   enb_cell_dss_feature enb=${Param.Context.eNBId} id=1 superfast_allocation=${superfast_allocation}
    ute_wtssim.execute egate command    cmd=${cmd}    alias=${alias}
    Sleep   2
    ${dl_resource_sharing_algo}   run Keyword if   '${Param.scfFile.lteNrDssDlRatio.dlResourceSharingAlgo}'=='DL buffer level based'
    ...                       set variable    dl_buffer_level_based
    ...           ELSE        set variable    dl_prb_load_based
    ${cmd}    Catenate          enb_dss_cell_param enb=${Param.Context.eNBId} id=1 dl_resource_sharing_algo=${dl_resource_sharing_algo}
    ute_wtssim.execute egate command    cmd=${cmd}    alias=${alias}
    Sleep   2
    # for CatM
    run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssLteCatM}'=='true'    Set enb dss cell param for CatM
    ...                                                                                      testParam=${Param}
    ...                                                                                      alias=${alias}
    # end for CatM

    # for superfast_reduction_excess_msg
    run Keyword if   '${Param.scfFile.nrdsslte.lteNrDssFastAllocPerfEnh}'=='exc_msg_reduction_static'
    ...                                                                       Set enb dss cell param for superfast_reduction_excess_msg
    ...                                                                                      testParam=${Param}
    ...                                                                                      alias=${alias}
    # end for superfast_reduction_excess_msg

    # for superfast_allocation
    run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssFastAlloc}'=='true'    Set enb dss cell param for actLteNrDssFastAlloc
    ...                                                                                      testParam=${Param}
    ...                                                                                      alias=${alias}
    # end for superfast_allocation

    wts.execute egate command    cmd=enb_dss_configure_partnership enb=${Param.Context.eNBId} cell=1 dss_peer=${Param.Context.gNBId}:1
    ...                                    alias=${alias}
    sleep   2

    ${cmd}    Catenate    enb_crm_cell_resource_reservation enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1
    ...         assigned_dl_minimum_share_to_nr=${Param.seq.assigned_dl_minimum_share_to_nr}
    ...         assigned_dl_maximum_share_to_nr=${Param.seq.assigned_dl_maximum_share_to_nr} assigned_dl_minimum_share_to_lte=15
    ...         assigned_dl_maximum_share_to_lte=70 assigned_ul_minimum_share_to_nr=20 assigned_ul_maximum_share_to_nr=70

    ute_wtssim.execute egate command      cmd=${cmd}    alias=${alias}

    # to simulate the EN DSS UL QoS LOAD INDICATION Timer = 80ms sent into DL coord rsp
    ${cmd}    Catenate    enb_crm_param id=${Param.Context.eNBId} ul_qos_load_meas_timer=${Param.seq.ul_qos_load_meas_timer}
    ...                                      dl_qos_load_meas_timer=${Param.seq.dl_qos_load_meas_timer}
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    wts.execute egate command      cmd=sim_trace enb=${Param.Context.eNBId} protocol=xp on      alias=${alias}

    sleep    30
    ${pattern}    Set Variable    EN DSS UL Cell Subcarrier Resource Coordination success on remote NE
    ${cmd}      Catenate       enb_dss_establish_partnership enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1
    ${output}    wts.Execute Egate Command And Wait For Data    cmd=${cmd}
    ...    pass_regexp=${pattern}    timeout=30     alias=${alias}
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}

    sleep   10

    common_Dss_CellSetup.Reset DL Reservation    alias=${alias}
    Sleep    2s    reason=make sure the cmd take affect
    common_Dss_CellSetup.Reset UL Reservation    alias=${alias}
    Sleep    2s    reason=make sure the cmd take affect

    ${prb_area_list}=  run Keyword if  '${Param.scfFile.nrdsslte.actLteNrDssLteCatM}'=='true' and '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'
    ...           Catenate   SEPARATOR=      ${Param.seq.CatMinfo.prb_area_reservation_list}
    ...   ELSE     run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssLteCatM}'=='true'
    ...           Catenate   SEPARATOR=      ${Param.seq.CatMinfo.prb_area_reservation_list}
    ...                                     ${Param.seq.CatMinfo.prb_area_reservation_list_2}
    ...   ELSE    Set variable        0,0,0-10-none+0,0,5-10-none+0,0,9-10-none
    ${prb_area_reservation_list}=        run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssLteCatM}'=='true'
    ...                             set variable      ${prb_area_list}
    ...            ELSE             set variable      0,0,0-10-none+0,0,5-10-none+0,0,9-10-none
    ${cmd}    Catenate    enb_dss_dl_resource_cell_reservation cell=1 enb=${Param.Context.eNBId}
    ...                                           prb_area_reservation_list=${prb_area_reservation_list}
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    # CatM case
    run Keyword if   '${Param.scfFile.nrdsslte.actLteNrDssLteCatM}'=='true'   Set enb dss dl resource cell reservation for CatM
    ...                                                                                      testParam=${Param}
    ...                                                                                      alias=${alias}
    # end CatM case

    ${cmd}    Catenate    enb_dss_dl_resource_cell_reservation cell=1 enb=${Param.Context.eNBId}
    ...                     reserved_fixed_normal_subframes=0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    ${cmd}    Catenate    enb_dss_dl_resource_cell_reservation cell=1 enb=${Param.Context.eNBId} min_lte_nr_dss_ratio=30 max_lte_nr_dss_ratio=100
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    ${cmd}    Catenate    enb_crm_param id=${Param.Context.eNBId} ul_qos_load_meas_timer=${Param.seq.ul_qos_load_meas_timer}
    ...                                      dl_qos_load_meas_timer=${Param.seq.dl_qos_load_meas_timer}
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    ${cmd}    Catenate    enb_dss_cell_resource_coordination enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1 dir=DL
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    ${cmd}    Catenate    enb_dss_ul_resource_cell_reservation cell=1 enb=${Param.Context.eNBId} minimum_prb_share=30 maximum_prb_share=70
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    ${cmd}    Catenate    enb_dss_cell_resource_coordination enb=${Param.Context.eNBId} cell=1 tgt_enb=${Param.Context.gNBId} tgt_cell=1 dir=UL
    Dated Log New Line       ${cmd}
    wts.execute egate command      cmd=${cmd}      alias=${alias}

    Sleep    2s    reason=make sure the cmd take affect

    ${output}    wts.execute egate command and wait for data      cmd=enb_crm_status enb=${Param.Context.eNBId} cell=1       alias=${alias}
    Log To Console    \n${output}

    Sleep    2s    reason=make sure the cmd take affect

    # CASE WO PRB BLANKING
    # ${dl_prb_area_allocation_list}=    Catenate    SEPARATOR=    0:0,52+1:0,0+2:0,52+3:0,52+4:0,52+5:0,52+6:0,52+7:0,52+8:0,52+9:0,52+10:0,52+11:0,
    # ...    52+12:0,52+13:0,52+14:0,52+15:0,52+16:0,52+17:0,52+18:0,52+19:0,52+20:0,52+21:0,0+22:0,52+23:0,52+24:0,52+25:0,52+26:0,52+27:0,52+52:0,
    # ...    52+29:0,52+30:0,52+31:0,52+32:0,52+33:0,52+34:0,52+35:0,52+36:0,52+37:0,52+38:0,52+39:0,52+40:0,52+41:0,0+42:0,52+43:0,52+44:0,52+45:0,
    # ...    52+46:0,52+47:0,52+48:0,52+49:0,52+50:0,52+51:0,52+52:0,52+53:0,52+54:0,52+55:0,52+56:0,52+57:0,52+58:0,52+59:0,52+60:0,52+61:0,0+62:0,
    # ...    52+63:0,52+64:0,52+65:0,52+66:0,52+67:0,52+68:0,52+69:0,52+70:0,52+71:0,52+72:0,52+73:0,52+74:0,52+75:0,52+76:0,52+77:0,52+78:0,52+79:0
    # ...    ,52

    # CSAMSON : TO IMPROVE LATER ..... START PRB = 4 IN CASE OF PRB BLE = 3prb
    # ${dl_prb_area_allocation_list}=    Catenate    SEPARATOR=
    # ...    0:4,52+1:4,0+2:4,52+3:4,52+4:4,52+5:4,52+6:4,52+7:4,52+8:4,52+9:4,52+10:4,52+11:4,52+12:4,52+13:4,52+14:4,52+15:4,52+16:4,52+17:4,52+
    # ...    18:4,52+19:4,52+20:4,52+21:4,0+22:4,52+23:4,52+24:4,52+25:4,52+26:4,52+27:4,52+52:4,52+29:4,52+30:4,52+31:4,52+32:4,52+33:4,52+34:4,52+
    # ...    35:4,52+36:4,52+37:4,52+38:4,52+39:4,52+40:4,52+41:4,0+42:4,52+43:4,52+44:4,52+45:4,52+46:4,52+47:4,52+48:4,52+49:4,52+50:4,52+51:4,52+
    # ...    52:4,52+53:4,52+54:4,52+55:4,52+56:4,52+57:4,52+58:4,52+59:4,52+60:4,52+61:4,0+62:4,52+63:4,52+64:4,52+65:4,52+66:4,52+67:4,52+68:4,52+
    # ...    69:4,52+70:4,52+71:4,52+72:4,52+73:4,52+74:4,52+75:4,52+76:4,52+77:4,52+78:4,52+79:4,52

    # ${dl_prb_area_allocation_list}=    Catenate    SEPARATOR=
    # ...    0:3,48+1:3,0+2:3,48+3:3,48+4:3,48+5:3,48+6:3,48+7:3,48+8:3,48+9:3,48+10:3,48+11:3,48+12:3,48+13:3,48+14:3,48+15:3,48+16:3,48+17:3,48+
    # ...    18:3,48+19:3,48+20:3,48+21:3,0+22:3,48+23:3,48+24:3,48+25:3,48+26:3,48+27:3,48+52:3,48+29:3,48+30:3,48+31:3,48+32:3,48+33:3,48+34:3,48+
    # ...    35:3,48+36:3,48+37:3,48+38:3,48+39:3,48+40:3,48+41:3,0+42:3,48+43:3,48+44:3,48+45:3,48+46:3,48+47:3,48+48:3,48+49:3,48+50:3,48+51:3,48+
    # ...    52:3,48+53:3,48+54:3,48+55:3,48+56:3,48+57:3,48+58:3,48+59:3,48+60:3,48+61:3,0+62:3,48+63:3,48+64:3,48+65:3,48+66:3,48+67:3,48+68:3,48+
    # ...    69:3,48+70:3,48+71:3,48+72:3,48+73:3,48+74:3,48+75:3,48+76:3,48+77:3,48+78:3,48+79:3,48

    # 3 PRB blanked Low Edge
    # ${dl_prb_area_allocation_list}=    Catenate    SEPARATOR=    0:0,49+1:0,0+2:0,49+3:0,49+4:0,49+5:0,49+6:0,49+7:0,49+8:0,49+9:0,49+10:0,49+11:0,
    # ...    52+12:0,49+13:0,49+14:0,49+15:0,49+16:0,49+17:0,49+18:0,49+19:0,49+20:0,49+21:0,0+22:0,49+23:0,49+24:0,49+25:0,49+26:0,49+27:0,49+52:0,
    # ...    52+29:0,49+30:0,49+31:0,49+32:0,49+33:0,49+34:0,49+35:0,49+36:0,49+37:0,49+38:0,49+39:0,49+40:0,49+41:0,0+42:0,49+43:0,49+44:0,49+45:0,
    # ...    52+46:0,49+47:0,49+48:0,49+49:0,49+50:0,49+51:0,49+52:0,49+53:0,49+54:0,49+55:0,49+56:0,49+57:0,49+58:0,49+59:0,49+60:0,49+61:0,0+62:0,
    # ...    52+63:0,49+64:0,49+65:0,49+66:0,49+67:0,49+68:0,49+69:0,49+70:0,49+71:0,49+72:0,49+73:0,49+74:0,49+75:0,49+76:0,49+77:0,49+
    # ...    78:0,49+79:0,52

    # CASE 10MHz/15MHz/20MHz w/o PRB BLANKING
    ${dl_prb_area_allocation_list}=   run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'
    ...       Catenate    SEPARATOR=    0:0,52+1:0,0+2:0,52+3:0,52+4:0,52+5:0,52+6:0,52+7:0,52+8:0,52+9:0,52+10:0,52+11:0,
    ...    52+12:0,52+13:0,52+14:0,52+15:0,52+16:0,52+17:0,52+18:0,52+19:0,52+20:0,52+21:0,0+22:0,52+23:0,52+24:0,52+25:0,52+26:0,52+27:0,52+52:0,
    ...    52+29:0,52+30:0,52+31:0,52+32:0,52+33:0,52+34:0,52+35:0,52+36:0,52+37:0,52+38:0,52+39:0,52+40:0,52+41:0,0+42:0,52+43:0,52+44:0,52+45:0,
    ...    52+46:0,52+47:0,52+48:0,52+49:0,52+50:0,52+51:0,52+52:0,52+53:0,52+54:0,52+55:0,52+56:0,52+57:0,52+58:0,52+59:0,52+60:0,52+61:0,0+62:0,
    ...    52+63:0,52+64:0,52+65:0,52+66:0,52+67:0,52+68:0,52+69:0,52+70:0,52+71:0,52+72:0,52+73:0,52+74:0,52+75:0,52+76:0,52+77:0,52+78:0,52+79:0
    ...    ,52
    ...   ELSE    run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'
    ...       Catenate    SEPARATOR=    0:0,52+1:0,0+2:0,52+3:0,52+4:0,52+5:0,52+6:0,52+7:0,52+8:0,52+9:0,52+10:0,52+11:0,
    ...    52+12:0,52+13:0,52+14:0,52+15:0,52+16:0,52+17:0,52+18:0,52+19:0,52+20:0,52+21:0,0+22:0,52+23:0,52+24:0,52+25:0,52+26:0,52+27:0,52+52:0,
    ...    52+29:0,52+30:0,52+31:0,52+32:0,52+33:0,52+34:0,52+35:0,52+36:0,52+37:0,52+38:0,52+39:0,52+40:0,52+41:0,0+42:0,52+43:0,52+44:0,52+45:0,
    ...    52+46:0,52+47:0,52+48:0,52+49:0,52+50:0,52+51:0,52+52:0,52+53:0,52+54:0,52+55:0,52+56:0,52+57:0,52+58:0,52+59:0,52+60:0,52+61:0,0+62:0,
    ...    52+63:0,52+64:0,52+65:0,52+66:0,52+67:0,52+68:0,52+69:0,52+70:0,52+71:0,52+72:0,52+73:0,52+74:0,52+75:0,52+76:0,52+77:0,52+78:0,52+79:0
    ...    ,52
    ...    ELSE    Catenate    SEPARATOR=    0:0,106+1:0,0+2:0,106+3:0,106+4:0,106+5:0,106+6:0,106+7:0,106+8:0,106+9:0,106+
    ...    10:0,106+11:0,106+12:0,106+13:0,106+14:0,106+15:0,106+16:0,106+17:0,106+18:0,106+19:0,106+20:0,106+21:0,0+22:0,106+23:0,106+24:0,106+
    ...    25:0,106+26:0,106+27:0,106+28:0,106+29:0,106+30:0,106+31:0,106+32:0,106+33:0,106+34:0,106+35:0,106+36:0,106+37:0,106+38:0,106+39:0,106+
    ...    40:0,106+41:0,0+42:0,106+43:0,106+44:0,106+45:0,106+46:0,106+47:0,106+48:0,106+49:0,106+50:0,106+51:0,106+52:0,106+53:0,106+54:0,106+
    ...    55:0,106+56:0,106+57:0,106+58:0,106+59:0,106+60:0,106+61:0,0+62:0,106+63:0,106+64:0,106+65:0,106+66:0,106+67:0,106+68:0,106+69:0,106+
    ...    70:0,106+71:0,106+72:0,106+73:0,106+74:0,106+75:0,106+76:0,106+77:0,106+78:0,106+79:0,106

    # to manage DL PRB BLANKING case
    ${nbrOfBlankedPRBsHighEdgeDL}   set variable   ${Param.scfFile.BlankedPRBs.nbrOfBlankedPRBsHighEdgeDL}
    ${nbrOfBlankedPRBsLowEdgeDL}   set variable    ${Param.scfFile.BlankedPRBs.nbrOfBlankedPRBsLowEdgeDL}
    ${max_prb}      run Keyword if     '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'      set variable    52
    ...    ELSE IF                     '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'      set variable    79
    ...    ELSE                                                                          set variable    106
    ${dl_prb}    run Keyword if   '${Param.scfFile.nrcell.actPRBBlanking}'=='true'
    ...        Evaluate    ${max_prb}-${nbrOfBlankedPRBsHighEdgeDL}-${nbrOfBlankedPRBsLowEdgeDL}
    ...   ELSE    set variable    ${max_prb}
    ${msg}=   Catenate    max_dl_prb=${dl_prb} for dl_prb_area_allocation_list with
    ...                   actPRBBlanking=${Param.scfFile.nrcell.actPRBBlanking}
    ...                   nbrOfBlankedPRBsHighEdgeDL=${Param.scfFile.BlankedPRBs.nbrOfBlankedPRBsHighEdgeDL}
    ...                   nbrOfBlankedPRBsLowEdgeDL=${Param.scfFile.BlankedPRBs.nbrOfBlankedPRBsLowEdgeDL}
    dated Log     ----------> ${msg}
    ${DL_StartPrb}    run Keyword if   '${Param.scfFile.nrcell.actPRBBlanking}'=='true'
    ...        Evaluate    ${nbrOfBlankedPRBsLowEdgeDL}
    ...   ELSE    set variable    0
    ${dl_prb_area_allocation_list}=
    ...   Catenate    SEPARATOR=   0:${DL_StartPrb},${dl_prb}+1:${DL_StartPrb},${dl_prb}+2:${DL_StartPrb},${dl_prb}+3:${DL_StartPrb},${dl_prb}+
    ...     4:${DL_StartPrb},${dl_prb}+5:${DL_StartPrb},${dl_prb}+6:${DL_StartPrb},${dl_prb}+7:${DL_StartPrb},${dl_prb}+
    ...     8:${DL_StartPrb},${dl_prb}+9:${DL_StartPrb},${dl_prb}+10:${DL_StartPrb},${dl_prb}+11:${DL_StartPrb},${dl_prb}+
    ...     12:${DL_StartPrb},${dl_prb}+13:${DL_StartPrb},${dl_prb}+14:${DL_StartPrb},${dl_prb}+15:${DL_StartPrb},${dl_prb}+
    ...     16:${DL_StartPrb},${dl_prb}+17:${DL_StartPrb},${dl_prb}+18:${DL_StartPrb},${dl_prb}+19:${DL_StartPrb},${dl_prb}+
    ...     20:${DL_StartPrb},${dl_prb}+21:${DL_StartPrb},${dl_prb}+22:${DL_StartPrb},${dl_prb}+23:${DL_StartPrb},${dl_prb}+
    ...     24:${DL_StartPrb},${dl_prb}+25:${DL_StartPrb},${dl_prb}+26:${DL_StartPrb},${dl_prb}+27:${DL_StartPrb},${dl_prb}+
    ...     28:${DL_StartPrb},${dl_prb}+29:${DL_StartPrb},${dl_prb}+30:${DL_StartPrb},${dl_prb}+31:${DL_StartPrb},${dl_prb}+
    ...     32:${DL_StartPrb},${dl_prb}+33:${DL_StartPrb},${dl_prb}+34:${DL_StartPrb},${dl_prb}+35:${DL_StartPrb},${dl_prb}+
    ...     36:${DL_StartPrb},${dl_prb}+37:${DL_StartPrb},${dl_prb}+38:${DL_StartPrb},${dl_prb}+39:${DL_StartPrb},${dl_prb}+
    ...     40:${DL_StartPrb},${dl_prb}+41:${DL_StartPrb},${dl_prb}+42:${DL_StartPrb},${dl_prb}+43:${DL_StartPrb},${dl_prb}+
    ...     44:${DL_StartPrb},${dl_prb}+45:${DL_StartPrb},${dl_prb}+46:${DL_StartPrb},${dl_prb}+47:${DL_StartPrb},${dl_prb}+
    ...     48:${DL_StartPrb},${dl_prb}+49:${DL_StartPrb},${dl_prb}+50:${DL_StartPrb},${dl_prb}+51:${DL_StartPrb},${dl_prb}+
    ...     52:${DL_StartPrb},${dl_prb}+53:${DL_StartPrb},${dl_prb}+54:${DL_StartPrb},${dl_prb}+55:${DL_StartPrb},${dl_prb}+
    ...     56:${DL_StartPrb},${dl_prb}+57:${DL_StartPrb},${dl_prb}+58:${DL_StartPrb},${dl_prb}+59:${DL_StartPrb},${dl_prb}+
    ...     60:${DL_StartPrb},${dl_prb}+61:${DL_StartPrb},${dl_prb}+62:${DL_StartPrb},${dl_prb}+63:${DL_StartPrb},${dl_prb}+
    ...     64:${DL_StartPrb},${dl_prb}+65:${DL_StartPrb},${dl_prb}+66:${DL_StartPrb},${dl_prb}+67:${DL_StartPrb},${dl_prb}+
    ...     68:${DL_StartPrb},${dl_prb}+69:${DL_StartPrb},${dl_prb}+70:${DL_StartPrb},${dl_prb}+71:${DL_StartPrb},${dl_prb}+
    ...     72:${DL_StartPrb},${dl_prb}+73:${DL_StartPrb},${dl_prb}+74:${DL_StartPrb},${dl_prb}+75:${DL_StartPrb},${dl_prb}+
    ...     76:${DL_StartPrb},${dl_prb}+77:${DL_StartPrb},${dl_prb}+78:${DL_StartPrb},${dl_prb}+79:${DL_StartPrb},${dl_prb}

    dated Log     ----------> dl_prb_area_allocation_list = ${dl_prb_area_allocation_list}

    # 20MHz case
    # ${dl_prb_area_allocation_list}=    Catenate    SEPARATOR=    0:0,106+1:0,0+2:0,106+3:0,106+4:0,106+5:0,106+6:0,106+7:0,106+8:0,106+9:0,106+
    # ...    10:0,106+11:0,52+12:0,106+13:0,106+14:0,106+15:0,106+16:0,106+17:0,106+18:0,106+19:0,106+20:0,106+21:0,0+22:0,106+23:0,106+24:0,106+
    # ...    25:0,106+26:0,106+27:0,106+28:0,106+29:0,106+30:0,106+31:0,106+32:0,106+33:0,106+34:0,106+35:0,106+36:0,106+37:0,106+38:0,106+39:0,106+
    # ...    40:0,106+41:0,0+42:0,106+43:0,106+44:0,106+45:0,106+46:0,106+47:0,106+48:0,106+49:0,106+50:0,106+51:0,106+52:0,106+53:0,106+54:0,106+
    # ...    55:0,106+56:0,106+57:0,106+58:0,106+59:0,106+60:0,106+61:0,0+62:0,106+63:0,106+64:0,106+65:0,106+66:0,106+67:0,106+68:0,106+69:0,106+
    # ...    70:0,106+71:0,106+72:0,106+73:0,106+74:0,106+75:0,106+76:0,106+77:0,106+78:0,106+79:0,106

    # ${dl_pattern}=      Catenate       1011111111-1111111111-1011111111-1111111111-1011111111-1111111111-1011111111-1111111111
    # ${dl_pattern}=      Catenate         0001100010-0111101110-0011100010-0111101110-0011100010-0111101110-0011100010-0111101110
    # ${dl_pattern}=      Catenate         0011101110-0011101110-0011101110-0011101110-0011101110-0011101110-0011101110-0011101110
    ${dl_pattern}=      Catenate       ${Param.seq.dl_allocated_normal_subframes}
    common_Dss_CellSetup.DSS DL Cell Resource Allocation Phase3   dl_allocated_normal_subframes=${dl_pattern}
    ...                                                         dl_prb_area_allocation_list=${dl_prb_area_allocation_list}
    ...                                                         alias=${alias}

    # 3 PRB area defined because of longPUCCH
    ${prb_nr_pusch_area}=    set variable    ${Param.scfFile.nrcell.msg1FrequencyStart},${Param.seq.ULNbrOfPrb}
    ${prb_area_list}=  run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='10MHz'    set variable   0,3|${prb_nr_pusch_area}|49,3
    ...  ELSE    run Keyword if   '${Param.scfFile.nrcellfdd.chBwDl}'=='15MHz'          set variable   0,3|${prb_nr_pusch_area}|76,3
    ...  ELSE                                                                           set variable   0,3|${prb_nr_pusch_area}|103,3

    # Param variable is visible under the test suite
    # common_Dss_CellSetup.DSS UL Cell Resource Allocation Phase3     ULNbrOfPrb=${Param.seq.ULNbrOfPrb}    msg1FrequencyStart=1   alias=${alias}
    common_Dss_CellSetup.DSS UL Cell Resource Allocation Phase3         prb_area_list=${prb_area_list}
    ...                                                                 alias=${alias}

    sleep    2s    reason=make sure the cmd take affect

    log to console   \n${blue}***DSS CRM CELLSETUP BW=${Param.seq.bandwidth} completed*** ${normal}

    ${output}    wts.execute egate command and wait for data      cmd=enb_crm_status enb=${Param.Context.eNBId} cell=1       alias=${alias}
    Log To Console    \n*** enb_crm_status enb=${Param.Context.eNBId} cell=1
    Log To Console    \n${output}

# ------------------------------------------------------------------------------------------------------------------------------------
# End Of Common Kw
# ------------------------------------------------------------------------------------------------------------------------------------
