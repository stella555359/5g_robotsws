*** Settings ***

Documentation     Keywords related to CB013289
Library     ute_wtssim
Library     String
Library     OperatingSystem
Library     Collections
Library     ta5g_ue_measurements
Library     taf.config.wts        WITH NAME    wts_conf

Resource    ../../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot

*** Variables ***

@{pdu1_qos_list}  ${2}  ${3}
@{pdu_qos_list}  ${5}  ${6}
@{pdu_qos_list2}  ${5}  ${6}  ${7}
@{pdu2_qos_list}  ${4}
${carrier_freq_NR}    ${636576}
${carrier_freq_FDD_NR}    ${126530}
${carrier_freq_LTE}    ${2200}

*** Keywords ***
Case Precondition
    log to console    Case Precondition
    Common Test Setup For RRM
    Airphone Common Setup    local_wts_dir=${CURDIR}/config/basic_setup_118106.cfg
    ...                      iphy_path=${CURDIR}/config/iphy.xml
    ...                      scf_file_path=${CURDIR}/config/scf_118106.xml
    Airphone Execute Egate Command    cmd=set_log flush
    Airphone Execute Egate Command    cmd=state_sim_disp
    Start Btslog Collect    names=btslog1

Case Precondition for Emergency call
    log to console    Case Precondition
    Common Test Setup For RRM
    Airphone Common Setup    local_wts_dir=${CURDIR}/config/basic_setup_emergency.cfg
    ...                      iphy_path=${CURDIR}/config/iphy_emergency.xml
    ...                      scf_file_path=${CURDIR}/config/scf_emergency.xml
    Airphone Execute Egate Command    cmd=set_log flush
    Airphone Execute Egate Command    cmd=state_sim_disp
    Start Btslog Collect    names=btslog1

Case Precondition For Multi UE
    log to console    Case Precondition
    Common Test Setup For RRM
    Airphone Common Setup    local_wts_dir=${CURDIR}/config/basic_setup_118106_MUE.cfg
    ...                      iphy_path=${CURDIR}/config/iphy.xml
    ...                      scf_file_path=${CURDIR}/config/scf_118106.xml
    Airphone Execute Egate Command    cmd=set_log flush
    Airphone Execute Egate Command    cmd=state_sim_disp
    Start Btslog Collect    names=btslog1

Case Precondition For NSA call
    log to console    Case Precondition
    Common Test Setup For RRM
    Airphone Common Setup    local_wts_dir=${CURDIR}/config/basic_setup_NSA.cfg
    ...                      iphy_path=${CURDIR}/config/iphy_NSA.xml
    ...                      scf_file_path=${CURDIR}/config/scf_NSA1.xml
    Airphone Execute Egate Command    trace protocol=x2 enb=1 on
    Airphone Execute Egate Command    enb_x2_link_up enb=1 target=2    pass_regexp=is up    timeout=20s
    Airphone Execute Egate Command    trace protocol=x2 enb=11 on
    Airphone Execute Egate Command    enb_x2_link_up enb=11 target=2    pass_regexp=is up    timeout=20s
    Airphone Execute Egate Command    enb_endc_param id=1 keep_endc_on_ho=on
    Airphone Execute Egate Command    enb_endc_param id=11 keep_endc_on_ho=on
    Airphone Execute Egate Command    cmd=set_log flush
    Airphone Execute Egate Command    cmd=state_sim_disp
    Start Btslog Collect    names=btslog1

Case Postcondition
    log to console    Case Postcondition
    Run Keyword And Ignore Error    Stop data traffic on 2 PDU sessions    ue_id=1
    ${btslog_name1}    Stop Btslog Collect    names=btslog1
    Airphone Common Teardown
    Run Keyword If Test Failed    Run Keyword And Ignore Error    Collect Coam Snapshot
    ${DATE}=    Get Current Date    result_format=%Y%m%d_%H%M
    Wait Until Keyword Succeeds    3x    1min    COAM_Admin.Login    alias=SCF_backup
    Run Keyword And Ignore Error    COAM_Admin.BackupSCF    local_dir=${TEST_LOG_DIRECTORY}    file_name=SCF_${DATE}.xml
    ...    connection=SCF_backup
    Run Keyword And Ignore Error    COAM_Admin.Logout    connection=SCF_backup

UE Register And PDU Session Setup for NonGBR
    [Arguments]    ${ue_id}=1  ${gnb_id}=1  ${cell_id}=2   ${pass_regexp}=QoS Routing Table    ${ue_gw}=1
    Airphone Execute Egate Command    cmd=ue_change_location id=${ue_id} enb=${gnb_id} cell=${cell_id}
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}
    sleep    5s
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    sleep    5s
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=2 nwslice=1 gw=${ue_gw}    pass_regexp=${pass_regexp}
    sleep    5s

UE Register And PDU Session Setup
    [Arguments]    ${ue_id}=1  ${pass_regexp}=QoS Routing Table    ${ue_gw}=1
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}
    sleep    5s
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    sleep    5s
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_gw}    pass_regexp=${pass_regexp}
    sleep    5s

UE${ue_id:\d+} Register
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}
    sleep    5s

UE${ue_id:\d+} And PDU Session-${pdu_id:\d+} Gateway-${gw_id:\d+} Setup
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${gw_id}
    ...                                pass_regexp=QoS Routing Table
    sleep    5s

Start ${traffic_rate:\d+}Mbps Traffic On PDU Session-${pdu_id:\d+} QFI-${qfi_id:\d+} ${direction:(ul|dl)} for UE${ue_id:\d+}
    Airphone Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=${direction} Mbps=${traffic_rate}
    sleep    5s

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
    [Arguments]   ${ue_id}   ${pdu}=1   ${qos_flow_list}=${NONE}   ${by}=amf   ${pass_regexp}=QosFlow with QFI
    ${default_qos_list}   Create List   ${2}   ${3}
    ${qos_flow_list}      Set Variable If   ${qos_flow_list}   ${qos_flow_list}   ${default_qos_list}

    FOR   ${qos_parameter}   IN   @{qos_flow_list}
        ${cmd1}    Catenate    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qos_parameter} by=${by}
        Airphone Execute Egate Command    cmd=${cmd1}    pass_regexp=${pass_regexp}
        sleep    10s
    END
    sleep    10s

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
    [Arguments]   ${ue_id}=1   ${pdu}=1   ${nwslice}=1   ${gw}=1   ${pass_regexp}=Initial Context Setup Successful
    ${cmd1}    Catenate    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=${nwslice} gw=${gw}
#    Airphone Execute Egate Command    cmd=${cmd1}    pass_regexp=${pass_regexp}
    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${cmd1}
    ...                   pass_regexp=${pass_regexp}
    ...                   timeout=100s
    sleep    5s

Send Egate Command and verify output
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
    ...    | wts_ue.Send Egate Command and verify output | cmd=sim_state_disp | pass_regexp=The state is ACTIVE |
    ...
    ...    *Returns*   egate console output
    ...
    [Arguments]   ${cmd}   ${timeout}=10   ${return_output}=${True}   ${pass_regexp}=${None}   ${fail_regexp}=${None}
    ${output}   ute_wtssim.execute egate command and wait for data
    ...   cmd=${cmd}   pass_regexp=${pass_regexp}   fail_regexp=${fail_regexp}
    ...   timeout=${timeout}   return_output=${return_output}
    [Return]   ${output}

Trigger UE Setup Normal VoNR call with PDU
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${nwslice}=2    ${gw}=1    ${request_type}=initial-request    ${fiveQI}=5
    ...    ${cipheringAlgorithm}=nea2
    Set qosflow priority and Reset smf param     priority=15
    Airphone Execute Egate Command    ue_register id=${ue_id}
    sleep    5s
    ${ret1}=    Send Egate Command and verify output
    ...    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice} gw=${gw} request_type=${request_type}
    ...    pass_regexp=QoS Routing Table

    Should Contain    ${ret1}    securityModeCommand    Should Contain    ${ret1}    Initial Context Setup Successful

    Should Contain    ${ret1}    cipheringAlgorithm ${cipheringAlgorithm}
    Should Contain    ${ret1}    Initial Context Setup Successful for UE with AMF UE
    Should Contain    ${ret1}    Setup QosFlow with QFI:1 5QI:${fiveQI}

Trigger UE 5QI5 and 5QI1 Emergency call setup successfully
    [Arguments]    ${priority}=1    ${ue_id}=1    ${pdu_id}=2    ${nwslice}=2    ${gw}=2    ${request_type}=initial-emergency-request
    Set qosflow priority and Reset smf param    ${priority}
    Airphone Execute Egate Command
    ...    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice} gw=${gw} request_type=${request_type}
    ...    pass_regexp=Pdu Session Resource Setup Response Message
    sleep    10s
    ${ret1}=    Send Egate Command and verify output
    ...    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=2 by=amf
    ...    pass_regexp=Added QosFlow with QFI:2 fiveQI:1
    Should Contain    ${ret1}    rrcReconfiguration
    Should Contain    ${ret1}    Added QosFlow with QFI:2 5QI:1

Get aashell command output
    cli.create_aashell_cli    name=aashell
    cli.setup    aashell
    ${command_output}=    cli.execute_aashell_command    aashell    command=getResourcesUsage -l @Cprt #0x2515    timeout=10
    log to console   ${command_output}
    [Teardown]    cli.teardown   aashell

Set qosflow priority and Reset smf param
    [Arguments]    ${priority}=1
    Airphone Execute Egate Command   qosflow_modify qos_flow=1 priority=${priority}
    Airphone Execute Egate Command   qosflow_modify qos_flow=2 priority=${priority}
    Airphone Execute Egate Command    qosflow_modify qos_flow=3 priority=${priority}
    Airphone Execute Egate Command    qosflow_modify qos_flow=4 priority=${priority}
    Airphone Execute Egate Command    smf_param id=1 reset

UE Register And Setup One PDU Session
    [Arguments]    ${ue_id}=1    ${pass_regexp}=QoS Routing Table    ${ue_gw}=1
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}
    sleep    5s
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    sleep    5s
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_gw}    pass_regexp=${pass_regexp}
    sleep    5s

Nsa Attach Ue ${UE_ID}
    Airphone Execute Egate Command    ue_attach id=${UE_ID}    pass_regexp=UE IS ACTIVE
    Airphone Execute Egate Command    ue_dc_enb_start ue=${UE_ID} target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...    pass_regexp=reported successful RA

UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Airphone Execute Egate Command   cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off
    sleep   15s

Multi UE Detach
   [Arguments]    ${ue_id}=1   ${num}=6
   sleep  5s
   FOR  ${ue_id}    IN RANGE    1    ${num}
        UE Deregister From gNB    ue_id=${ue_id}
   END