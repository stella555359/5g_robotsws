*** Settings ***
Documentation    This contains basic wts SA related keywords which are needed to run the Airphone TC.
...              :author Merin Varghese

Library    ute_wtssim
Library    OperatingSystem
Library    ../Python/sa_utilities.py    WITH NAME   sa
Library    ../Python/IperfUtilities.py    WITH NAME   iperf
Library    ../Python/LogStore.py   WITH NAME   log_store

Resource   ../Variables/Common_Variables.robot
Resource   log.robot
Resource   wts.robot


*** Variables ***
${NOKIA_PASS}              oZPS0POrRieRtu
${SIB1_updated}            SystemInformationBlockType1-NR updated
${UE_IP}                   1.2.4.2
${UE_NAT_IP}               72.23.0.1
${THROUGHPUT}              1M
${TRAFFIC_DURATION}        600s
${DL_IPERF_FILE}            /tmp/iperf_DL.txt
${UL_IPERF_FILE}            /tmp/iperf_UL.txt

*** Keywords ***
Start and configure WTS for SA
    [Arguments]    ${wts_cfg_path}=${SETUP_CFG_PATH}    ${edaemon_port}=${EDAEMON_PORT}    ${egate_port}=${EGATE_PORT}
    Start WTS Applications    cfg_file=${wts_cfg_path}    edaemon_ports=${edaemon_port}    egate_port=${egate_port}
    Sleep    10s    # waiting for uec and amf log to be updated
    sa.wait_until_NGLink_SIB_is_recieved
    Ensure Egate state

UE Register
    [Arguments]   ${ue_id}   ${pass_regexp}=REGISTRATION COMPLETE   ${timeout}=180
    ${output}    Execute Egate Command And Wait For Data    ue_register id\=${ue_id}    pass_regexp=${pass_regexp}    timeout=${timeout}
    Should Contain    ${output}    Initial UE Message Success    ignore_case=True

Establish PDU Session
    [Arguments]   ${ue_id}   ${pdu_id}   ${gw_id}=1    ${network_slice}=1
    ...    ${pass_regexp}=Initial Context Setup Successful   ${timeout}=180
    ${output}    Execute Egate Command And Wait For Data    ue_pdu_session_setup pdu\=${pdu_id} gw\=${gw_id} ue\=${ue_id} nwslice\=${network_slice}
    ...    pass_regexp=${pass_regexp}    timeout=${timeout}

UE Deregister
    [Arguments]   ${ue_id}    ${ue_deregister_type}=switch_off    ${pass_regexp}=UE Context Release Complete   ${timeout}=180
    ${output}    Execute Egate Command And Wait For Data    ue_deregister id\=${ue_id} ue_deregister_type\=${ue_deregister_type}
    ...    pass_regexp=${pass_regexp}    timeout=${timeout}

Start Downlink Data Transfer using Iperf
    [Arguments]    ${client_IP_DL}=${UE_IP}    ${throughput}=${THROUGHPUT}    ${duration}=${TRAFFIC_DURATION}
    ...    ${iperf_file}=${DL_IPERF_FILE}    ${port}=${port}
    ${proc_iperf_server_dl}    ${proc_iperf_client_dl}    iperf.start_iperf    client_ip=${client_IP_DL}
    ...   throughput=${throughput}    duration=${duration}    iperf_file=${iperf_file}    port=${port}
    [Return]    ${proc_iperf_server_dl}    ${proc_iperf_client_dl}

Start Downlink L4S Data Transfer using Iperf
    [Arguments]    ${client_IP_DL}=${UE_IP}    ${throughput}=${THROUGHPUT}    ${duration}=${TRAFFIC_DURATION}    ${iperf_file}=${DL_IPERF_FILE}
    ...    ${port}=${port}
    ${proc_iperf_server_dl}    ${proc_iperf_client_dl}    iperf.start_iperf_L4S    client_ip=${client_IP_DL}
    ...   throughput=${throughput}    duration=${duration}    iperf_file=${iperf_file}    port=${port}
    [Return]    ${proc_iperf_server_dl}    ${proc_iperf_client_dl}

Start Uplink Data Transfer using Iperf
    [Arguments]    ${client_IP_UL}=${UE_NAT_IP}    ${throughput}=${THROUGHPUT}    ${duration}=${TRAFFIC_DURATION}    ${iperf_file}=${UL_IPERF_FILE}
    ${proc_iperf_server_ul}    ${proc_iperf_client_ul}    iperf.start_iperf    client_ip=${client_IP_UL}
    ...    throughput=${throughput}    duration=${duration}    iperf_file=${iperf_file}    port=${port}
    Sleep    ${DEFAULT_DATATIMEOUT}
    Set Test Variable   ${proc_iperf_server_ul}
    Set Test Variable   ${proc_iperf_client_ul}

Verify if average DL iperf is correct
    [Arguments]    ${iperf_file}=${DL_IPERF_FILE}    ${throughput}=${THROUGHPUT}
    iperf.check_average_throughput_is_reached_in_DL    ${throughput}    ${iperf_file}

Verify if average UL iperf is correct
    [Arguments]    ${iperf_file}=${UL_IPERF_FILE}    ${throughput}=${THROUGHPUT}
    iperf.check_average_throughput_is_reached_in_UL    ${throughput}    ${iperf_file}

Get lowest bandwidth
    [Arguments]    ${iperf_file}=${IPERF_FILE}
    ${lowest_bandwidth}    iperf.get_lowest_bandwidth    ${iperf_file}
    [Return]    ${lowest_bandwidth}

Check average data transfer
    Verify if average DL iperf is correct
    Verify if average UL iperf is correct

Stop UL data transfer using Iperf
    iperf.stop_traffic    ${proc_iperf_server_ul}    ${proc_iperf_client_ul}

Stop DL data transfer using Iperf
    [Arguments]    ${proc_iperf_server_dl}    ${proc_iperf_client_dl}
    iperf.stop_traffic    ${proc_iperf_server_dl}    ${proc_iperf_client_dl}

Stop All Data Transfer
    Stop UL data transfer using Iperf
    Stop DL data transfer using Iperf

Copy UL and DL iperf file to testcase folder
    ${test_log_path}    log_store.get_test_log_folder
    Run And Expect Command To Pass    command=cp ${DL_IPERF_FILE} ${test_log_path}
    ...    msg=File copy
    Run And Expect Command To Pass    command=cp ${UL_IPERF_FILE} ${test_log_path}
    ...    msg=File copy
    File Should Exist    ${test_log_path}/iperf_DL.txt
    File Should Exist    ${test_log_path}/iperf_UL.txt

