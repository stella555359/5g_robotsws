*** Settings ***
Documentation
...    author: Anna Bien
...    maintainer:  Anna Bien
...    team: I_5G_SW_MMW_PLKRK_04
...    contact: I_5G_SW_MMW_PLKRK_04 <I_5G_SW_MMW_PLKRK_04@nokia.com>

Library    SSHLibrary
Library    OperatingSystem
Library    ute_wtssim
Library    ute_fsmaccess
Library    ta5g_ue_mobility
Library    ta5g_cell_operations


*** Variables ***
${EDAEMON_PORT}=  ${22222}
${EGATE_PORT}=  ${20000}
${EPCSIM_DIR}=  /opt/iphy/latest
${ALIAS_WTS}=  WTS_1
${REGEX_SIB_1_RECEPTION_PASS}=  (eNB 2 cell 1: SystemInformationBlockType1-NR updated)
${REGEX_PDU_SESSION_PASS}=  (Established PDU session ID=\\d+ using PDU Gateway ID=\\d+)
${REGEX_EGATE_ACTIVATED} =  (The state is ACTIVE)
${REGEX_UE_ATTACH_PASS} =  (UE with RAN UE NGAP ID \\d+ and AMF UE NGAP ID \\d+ is now Registered)
${REGEX_STOP_TRAFFIC} =  (UE \\d+: Traffic was stopped for \\d+ sessions and upf:\\d+)
&{REGEX_START_TRAFFIC}  ul=(UE\\d+: Started Uplink Internal traffic over UDP on Ue:\\d+)
...                     dl=(UE\\d+: Started Downlink Internal traffic over UDP on Ue:\\d+)
${REGEX_NG_CONNECTED}=  (NG Link to gNB=2 is now Active)
${REGEX_CONTEXT_SETUP_PASS}=  (Initial Context Setup Successful for UE with AMF UE ID \\d+ and RAN UE ID \\d+)

*** Keywords ***
Look for message in EGATE
    [Arguments]    ${msg}    ${msg_fail}=${None}    ${timeout}=10s    ${alias}=${ALIAS_WTS}
    Execute egate command
    ...    sim_state_disp
    ...    pass_regexp=${msg}
    ...    fail_regexp=${msg_fail}
    ...    timeout=${timeout}
    ...    alias=${alias}

Start WTS
    [Arguments]   ${cfg_file}=${OUTPUT DIR}/${TEST NAME}/wts/basic_config.cfg
    ...           ${start_wts_timeout}=60s    ${look_for_message_timeout}=120
    Setup egate
    ...    egate_port=${EGATE_PORT}
    ...    tool_dir=${EPCSIM_DIR}
    Start wts applications
    ...   egate_port=${EGATE_PORT}
    ...   edaemon_ports=${EDAEMON_PORT}
    ...   cfg_file=${cfg_file}
    ...   timeout=${start_wts_timeout}
    ...   tool_dir=${EPCSIM_DIR}
    ...   alias=${ALIAS_WTS}
    Log   Waiting for WTS to start properly    console=True
    Look for message in EGATE
    ...    msg=${REGEX_NG_CONNECTED}
    ...    timeout=${look_for_message_timeout}
    Look for message in EGATE
    ...    msg=${REGEX_SIB_1_RECEPTION_PASS}
    ...    timeout=${look_for_message_timeout}
    Log    WTS instance started properly    console=True

Stop WTS
    Stop and collect wts logs
    ...   alias=${ALIAS_WTS}
    ...   unzip=True
    ...   subdirectory=${OUTPUT_DIR}/${TEST_NAME}/wts
    Teardown Egate

Attach UE and establish pdu session
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${gw_id}=${ue_id}
    ta5g_ue_mobility.Attach UE    ue_id=${ue_id}    pass_regexp=${REGEX_UE_ATTACH_PASS}
    ta5g_ue_mobility.Establish pdu session
    ...    ue_id=${ue_id}
    ...    pdu_id=${pdu_id}
    ...    gw_id=${gw_id}
    ...    pass_regexp=${REGEX_PDU_SESSION_PASS}

Attach UE To ENB And Perform Sgnb Addition
    [Arguments]    ${ue_id}=1    ${target_gnb}=2    ${target_cells}=1    ${bearer}=2    ${dc_type}=split_scg
    [Documentation]      Attach UE to eNB and perform sgnb addition on NSA setup
    ...                  Creation Date: 14.10.2021
    ...                  Modified Date:
    ...                  Last Modified by: damian.piasecki@nokia.com

    ta5g_ue_mobility.Attach UE To ENB    ue_id=${ue_id}
    ta5g_ue_mobility.Start Gnb Addition Procedure
    ...    ue=${ue_id}
    ...    target_gnb=${target_gnb}
    ...    target_cells=${target_cells}
    ...    bearer=${bearer}
    ...    dc_type=${dc_type}

Wait for Initial Context Setup
    [Arguments]  ${alias}=${ALIAS_WTS}
    Look for message in EGATE
    ...    msg=${REGEX_CONTEXT_SETUP_PASS}
    ...    timeout=15
    ...    alias=${alias}

Enable internal traffic
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${gw_id}=1    ${log_stats}=on  ${alias}=${ALIAS_WTS}
    [Documentation]
    ...             Run this command before establishing PDU Session!

    Execute egate command
    ...    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal log_traffic_stats=${log_stats}
    ...    alias=${alias}

Setup UE For Traffic And Perform Attach
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    [Documentation]    Set trf_type to internal to enable starting traffic. Perform UE attach.
    ...                Creation Date: 28.07.2021
    ...                Modified Date:
    ...                Last Modified by: damian.piasecki@nokia.com
    Execute egate command
    ...    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Attach UE and establish pdu session     ue_id=${ue_id}    pdu_id=${pdu_id}

Setup WTS instance
    [Arguments]    ${wts_config_file_path}=/opt/iphy/latest/basic_l1bypass_sa_call_tdd_cmwv_6UEs.cfg
    ...            ${alias}=${ALIAS_WTS}
    ute_wtssim.setup_egate
    ...    egate_port=${EGATE_PORT}
    ...    tool_dir=/opt/iphy/latest
    ...    save_egate=True
    ute_wtssim.start_wts_applications
    ...    egate_port=${EGATE_PORT}
    ...    edaemon_ports=${EDAEMON_PORT}
    ...    cfg_file=${wts_config_file_path}
    ...    timeout=60s
    ...    tool_dir=/opt/iphy/latest
    ...    alias=${alias}
    Log    \nWaiting for WTS to start properly    console=True
    Wait Until Keyword Succeeds    5min    30sec    Check if EGATE state is ACTIVE
    ...    msg=${REGEX_EGATE_ACTIVATED}
    Wait Until Keyword Succeeds     5min     30sec     ta5g_cell_operations.Check All Cells Are Configured
    Log    WTS instance started properly    console=True

Check if EGATE state is ACTIVE
    [Arguments]    ${msg}    ${msg_fail}=${None}    ${timeout}=10s
    Execute egate command
    ...    sim_state_disp
    ...    pass_regexp=${msg}
    ...    fail_regexp=${msg_fail}
    ...    timeout=${timeout}

Stop WTS instance
    [Arguments]    ${alias}=${ALIAS_WTS}
    Stop and collect wts logs  alias=${alias}
    Teardown Egate

Start traffic in egate
    [Arguments]    ${ue_id}   ${trf_id}   ${direction}    ${pdu_id}=1   ${mbps}=2    ${size}=500    ${protocol}=udp
    ${regex}=    Get From Dictionary    ${REGEX_START_TRAFFIC}    ${direction}
    Log    Starting traffic for UE${ue_id}    console=True
    Execute egate command
    ...  cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 trf_id=${trf_id} mbps=${mbps} size=${size} dir=${direction}
    ...  pass_regex=${regex}

Stop traffic in egate
    [Arguments]    ${ue_id}    ${trf_id}    ${pdu_id}=1
    Log    Stopping traffic for UE${ue_id}    console=True
    Execute egate command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} trf_id=${trf_id}
    ...    pass_regex=${REGEX_STOP_TRAFFIC}
    Release Pdu Session
    ...    ue_id=${ue_id}    pdu_id=${pdu_id}    initiator=amf    pass_regexp=None

Register 2 UEs And Test Traffic
    [Arguments]    ${first_ue_id}    ${second_ue_id}   ${traffic_time}=30s   ${alias}=${ALIAS_WTS}
    [Documentation]      Perform PM counter verification
    ...                  Creation Date:
    ...                  Modified Date: 14.07.2021
    ...                  Last Modified by: anna.bien@nokia.com

    Execute egate command
    ...    cmd=set_pdu_param ue=${first_ue_id} pdu=1 trf_type=internal
    ...    alias=${alias}
    Execute egate command
    ...    cmd=set_pdu_param ue=${second_ue_id} pdu=1 trf_type=internal
    ...    alias=${alias}
    Attach UE and establish pdu session    ue_id=${first_ue_id}   gw_id=${first_ue_id}
    Attach UE and establish pdu session    ue_id=${second_ue_id}   gw_id=${second_ue_id}

    Start traffic in egate    ue_id=${first_ue_id}    trf_id=1    direction=ul    mbps=2
    Start traffic in egate    ue_id=${first_ue_id}    trf_id=1    direction=dl    mbps=50
    Start traffic in egate    ue_id=${second_ue_id}    trf_id=1    direction=ul    mbps=2
    Start traffic in egate    ue_id=${second_ue_id}    trf_id=1    direction=dl    mbps=50
    Sleep    ${traffic_time}
    Stop traffic in egate    ue_id=${first_ue_id}    trf_id=1
    Stop traffic in egate    ue_id=${second_ue_id}    trf_id=1

Establish X2 Link
    [Arguments]    ${enb_id}=1    ${gnb_id}=2
    [Documentation]      Establish x2 link for NSA deployment type
    ...                  Creation Date: 14.10.2021
    ...                  Modified Date:
    ...                  Last Modified by: damian.piasecki@nokia.com

    ta5g_ue_mobility.Setup X2 Link
    ...    initiator_device=${enb_id}
    ...    complementary_device=${gnb_id}

Complete inter gNB handover history
    [Arguments]      ${ue_id}=1
    [Documentation]      Fill UE inter gNB handover history
    ...                  Creation Date: 05.11.2021
    ...                  Modified Date:
    ...                  Last Modified by: damian.piasecki@nokia.com

    Execute Egate Command
    ...    cmd=ue_history_information_list_add_ngran id=${ue_id} gnb_id\=2 cell_type=large nrcgi\=311:489|0x01 time_ue_stayed_in_cell\=97
    Execute Egate Command
    ...    cmd=ue_history_information_list_add_ngran id=${ue_id} gnb_id\=3 cell_type=large nrcgi\=311:489|0x1 time_ue_stayed_in_cell\=98
    Execute Egate Command
    ...    cmd=ue_history_information_list_add_ngran id=${ue_id} gnb_id\=2 cell_type=large nrcgi\=311:489|0x01 time_ue_stayed_in_cell\=99
    Execute Egate Command    cmd=ue_history_information_list id=${ue_id} action=commit
    Execute Egate Command    cmd=ue_enb_param id=${ue_id} ue_history_list=${ue_id}
