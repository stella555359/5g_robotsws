*** Settings ***
Documentation
...    :copyright: Nokia
...    :contact: I_EXT_MN_RAN_VRF_WRO2_7_T03@internal.nsn.com

Library     ta5g_testline_management

*** Keywords ***
Remove Existing Xn Link If Exists
    ${local_skip}    Get Variable Value    ${skip}
    ${skip_config}    Set Variable If    'config' in '${local_skip}'    ${True}    ${False}
    Run Keyword If    ${skip_config}    Return From Keyword
    Log to Console    Removing existing Xn Link if exists
    ${connection}    coam_admin.setup_admin
    ${status}    ${msg}    Run Keyword And Ignore Error    coam_admin.perform_object_recommissioning
    ...    dist_name=MRBTS-1/NRBTS-1/XNLINK-1    parameter=@{Empty}    operation=delete    connection=${connection}
    ${not_exist}    Run Keyword And Return Status    Should Contain    ${msg}    object not exist
    Run Keyword If  not (${not_exist} or ${status} == 'PASS')  Fail  ${msg}
    [Teardown]    coam_admin.teardown_admin    connection=${connection}

Get Message Timestamp From Pcap
    [Arguments]    ${filter}=f1ap.UEContextSetupRequest_element    ${pcap_filepath}=${TEST_tcpdump_gnb_path}
    ...    ${which_message}=-1
    @{messages_timestamp}    Get Message Field Values from PCAP
    ...    pcap_filepath=${pcap_filepath}
    ...    field_name=frame.time_epoch
    ...    filter=${filter}
    ...    options=${tshark_options}
    ${date}    Convert To String    ${messages_timestamp}[${which_message}]
    ${splitted_date}    Split String    ${date}    separator=.
    Log to console    ${splitted_date}
    [Return]    ${splitted_date}[0]

Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:GNB3_NG_ADDR    ip_with_mask=10.0.1.3/24
    Start Vm Ethernet Interface    if_name=eth3:GNB3_XN_ADDR    ip_with_mask=10.0.1.4/24

Stop Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:GNB3_NG_ADDR    ip_with_mask=10.0.1.3/24
    Stop Vm Ethernet Interface    if_name=eth3:GNB3_XN_ADDR    ip_with_mask=10.0.1.4/24
