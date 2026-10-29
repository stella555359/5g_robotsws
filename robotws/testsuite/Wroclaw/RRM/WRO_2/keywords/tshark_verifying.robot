*** Settings ***
Documentation   :copyright: Nokia
...             :authors: Mikołaj Kasian
...             :contact: kasian.mikolaj@nokia.com

Library      ta5g_tshark
Library      ute_tshark
Library      ta5g_file_system
Library      taf.ul.ettf.retry_context
Variables    ta5g_global_var
Variables    taf/rfrl/common_resources/tshark_filters/

*** Keywords ***
Verify Tcpdump Log
    [Arguments]    ${packet_filter}    ${number_of_messages}=1    ${pcap_file_path}=default    ${timeout}=16    ${relation_symbol}= ==
    ...            ${alias}=${DEFAULT_TCPDUMP_ALIAS}    ${continue_on_failure}=${False}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}

Verify Ngap Messages
    [Documentation]    Verification of captured messages transfered with NGAP protocol (NG interface: between GnB and AMF, WTS eth3).
    ...                By default keyword validates exact one occurrence of message.
    [Arguments]     ${packet_filter}    ${number_of_messages}=1    ${pcap_file_path}=${None}    ${timeout}=16    ${relation_symbol}= ==
    ...            ${alias}=${DEFAULT_NG_XN_TSHARK_ALIAS}    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}

Verify Uu Messages
    [Documentation]  Verification of messages captured on UU interface (between GnB and UE, WTS eth4).
    ...              By default keyword validates exact one occurrence of message.
    [Arguments]     ${packet_filter}    ${number_of_messages}=1    ${pcap_file_path}=${None}    ${timeout}=16    ${relation_symbol}= ==
    ...            ${alias}=${DEFAULT_UU_TSHARK_ALIAS}    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}

Verify Loopback Messages
    [Documentation]    Verification of messages captured with tcpdump tool on Loopback (WTS lo) interface.
    ...                By default keyword validates exact one occurrence of message.
    [Arguments]    ${packet_filter}    ${number_of_messages}=1    ${pcap_file_path}=${None}    ${timeout}=16    ${relation_symbol}= ==
    ...            ${alias}=${DEFAULT_LOOPBACK_ALIAS}    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria= ${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}


Enable Tshark Verification
    [Arguments]    ${logs_path}=${OUTPUT_DIR}/${TSHARK_SUBDIR}
    With Teardownable
    ...    keyword=_Start Tsharks logs_path=${logs_path}
    ...    teardown=_Stop Tsharks logs_path=${logs_path}


_Start Tsharks
    [Arguments]    ${logs_path}
    Start Default Tshark On S1 Mme And Uu Interfaces    log_dirpath=${logs_path}
    Start Tcpdump On Remote Interface    log_filename_prefix=gnb_F1_E1_RRC    log_dirpath=${logs_path}    alias=default_tcpdump_alias

_Stop Tsharks
    [Arguments]    ${logs_path}
    Teardown All Aliases For Tshark
    Stop Tcpdump On Remote Interface
    Rename Tcpdump File    ${logs_path}

Enable F1_E1_RRC Verification
    [Arguments]    ${logs_path}=${OUTPUT_DIR}/${TSHARK_SUBDIR}
    With Teardownable
    ...    keyword=_Start F1_E1_RRC logs_path=${logs_path}
    ...    teardown=_Stop F1_E1_RRC logs_path=${logs_path}

_Start F1_E1_RRC
    [Arguments]    ${logs_path}
    Start Tcpdump On Remote Interface    log_filename_prefix=gnb_F1_E1_RRC    log_dirpath=${logs_path}    alias=default_tcpdump_alias

_Stop F1_E1_RRC
    [Arguments]    ${logs_path}
    Teardown All Aliases For Tshark
    Stop Tcpdump On Remote Interface
    Rename Tcpdump File    ${logs_path}

Rename Tcpdump File
    [Arguments]    ${logs_path}
    ${tcpdump_path}=    Set Variable    ${logs_path}/gnb_F1_E1_RRC.pcap
    ${tcpdump_path_with_timestamp}=    Join Path With Timestamp Suffix    ${tcpdump_path}
    Move File    ${tcpdump_path}    ${tcpdump_path_with_timestamp}
