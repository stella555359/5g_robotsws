*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    ../resources/common_variables.robot
Resource    ../resources/common_configuration.robot
Library    ../resources/common_keywords.py
Library    keywords.py
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.l2stream3    WITH NAME    l2stream3
Library    taf.collectors.core    WITH NAME    core
Documentation
...    author: Mariusz Waczynski
...    maintainer: Mariusz Waczynski (mariusz.waczynski@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    release: 22R3

Test Setup      Run Keywords    Prepare Sa Test Environement And Reach Onair
    ...              perform_tl_reset=${RESET_TL}
    ...              cfg_filepath_fdd=${EPCSIM_CFG_PATH_SANSA_FDD}
    ...              cfg_filepath_tdd=${EPCSIM_CFG_PATH_SANSA_TDD}
    ...       AND    Set Internal Traffic Type To UEs

Test Teardown    Send Configuration ID To Scout
Suite Teardown    Run Keywords    Check For An Unexpected Alarm
...            AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${TRAFFIC_DURATION_SEC}=   10s

*** Test Cases ***
CNI-73221_Remove_message_ID_duplication_in_L2Log_interface_for_Sherpa_and_Component_trace
    Register Ue With Default Pdu Session
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=2
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=2
    Sleep    ${TRAFFIC_DURATION_SEC}
    Get Sherpa Traces For L2Hi Pdcp
    Get Sherpa Traces For L2Hi Rlc
    Get Component Traces For L2Hi Pdcp
    Get Component Traces For L2Hi Rlc

*** Keywords ***
Get Sherpa Traces For L2Hi Pdcp
    ${curl_options}=  Create Dictionary
    ...    up_sw=L2HiPdcp
    ...    trace_type=Sherpa
    @{curllist}    Create List    ${curl_options}
    Create Sbts L2stream Collector    ${curllist}
    check_file_size    expected_file_size_bytes=100000    trace_name=Sherpa_L2Hi_Pdcp
    ...    log_path=${OUTPUT_DIR}

Get Sherpa Traces For L2Hi Rlc
    @{nr_cell_dns}    Create List    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-1/NRCELL_R-1
    ${curl_options}=  Create Dictionary
    ...    up_sw=L2HiRlc
    ...    nr_cell_dns=${nr_cell_dns}
    ...    trace_type=Sherpa
    @{curllist}    Create List    ${curl_options}
    Create Sbts L2stream Collector    ${curllist}
    check_file_size    expected_file_size_bytes=100000    trace_name=Sherpa_L2Hi_Rlc
    ...    log_path=${OUTPUT_DIR}

Get Component Traces For L2Hi Pdcp
    ${curl_options}=  Create Dictionary
    ...    up_sw=L2HiPdcp
    @{curllist}    Create List    ${curl_options}
    Create Sbts L2stream Collector    ${curllist}
    check_file_size    expected_file_size_bytes=100000    trace_name=Component_L2Hi_Pdcp
    ...    log_path=${OUTPUT_DIR}

Get Component Traces For L2Hi Rlc
    @{nr_cell_dns}    Create List    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-1/NRCELL_R-1
    ${curl_options}=  Create Dictionary
    ...    up_sw=L2HiRlc
    ...    nr_cell_dns=${nr_cell_dns}
    @{curllist}    Create List    ${curl_options}
    Create Sbts L2stream Collector    ${curllist}
    check_file_size    expected_file_size_bytes=100000    trace_name=Component_L2Hi_Rlc
    ...    log_path=${OUTPUT_DIR}

create_sbts_l2stream_collector
    [Arguments]    ${curllist}
    ${executor}=  Create Dictionary
    ...    host=192.168.255.129
    ...    user=Nemuadmin
    ...    password=nemuuser
    ...    port=443
    tcpdump.create tcpdump collector
    ...    name=tcpdump
    ...    options=-i eth3 udp and src 10.0.1.2 and dst 10.0.1.1 and dst port 5678
    ...    sudo_password=ute
    l2stream3.create sbts l2stream collector
    ...    name=l2stream3
    ...    webservice=${executor}
    ...    dscp=15
    ...    source_ip_addr=10.0.1.2
    ...    destination_ip_addr=10.0.1.1
    ...    collector=tcpdump
    ...    l2_stream_configuration=${curllist}
    core.setup_collectors    names=l2stream3
    core.start_collectors    names=l2stream3
    sleep    10s
    core.stop_collectors    names=l2stream3
    core.collect_collectors    names=l2stream3
    core.teardown_collectors    names=l2stream3
