*** Settings ***
Documentation       :copyright:     Nokia
...                 :This contains pcap or tshark realted keywords required for our featurs
Variables        ta5g_global_var
Variables       ../PythonLib/tshark_filters
Library         ta5g_tshark
Library          String
Library          Collections
Library          OperatingSystem
Library          XML    use_lxml=true
Library         ute_tshark
Library         ute_wtssim
Library         ute_fsmaccess
Library         ta5g_syslog
Library         ta5g_ue_mobility
Library         ta5g_egate
Library         ta5g_commissioning
Library         ta5g_admin_operations
Library         taf.hw.pdu
Library         ta5g_setups_and_teardowns
Library         Process
*** Keywords ***
Start  Pcap on wts
    [Arguments]         ${log_filename}=eth3_tcp.pcap           ${eth_interface}=eth3
    ...                 ${capture_filter}='tcp'                 ${log_dirpath}=${OUTPUT_DIR}/${TEST_NAME}
    ...                 ${alias}=tcp_pcap
    log to console      start PCAP capture on WTS
    Start tshark
    ...    log_filename=${log_filename}
    ...    eth_interface=${eth_interface}
    ...    capture_filter=${capture_filter}
    ...    log_dirpath=${log_dirpath}
    ...    alias=${alias}

Stop Pcap on wts
    [Arguments]         ${alias}=tcp_pcap
    log to console      stop PCAP capture on WTS
    Stop tshark         alias=${alias}

Verify Tcp
    [Arguments]         ${packet_filter}        ${number_of_messages}=1         ${pcap_file_path}=${None}
    ...                 ${timeout}=16           ${relation_symbol}= ==
    ...                 ${alias}=tcp_pcap       ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}
