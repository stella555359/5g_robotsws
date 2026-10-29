*** Settings ***
Documentation
...     [Maintenance]   "TRS I & V Tools Bangalore Team"


*** Variables ***
${tc_variables}     testcase_variables.json

*** Keywords ***

Setup Oamops on Chained Enb
    Setup Oamops
    Setup Oamops        bts_host=${Enb2_mplane_IP}    alias=enb2

Teardown Oamops on Chained Enb
    Teardown Oamops
    Teardown Oamops     alias=enb2

Get GPS staus details
    [Arguments]    ${key}    ${value}
    ${gps_info} =       Query Admin Infomodel        query=get object //GNSSE_R-*
    ${output}=     Get From Dictionary       ${gps_info}        ${key}
    Should Be Equal     ${output}       ${value}


Get Sync Info details
    [Arguments]    ${sync_key}    ${sync_value}
    ${sync_info} =       Get Sync Info
    ${output}=      Get From Dictionary     ${sync_info}        ${sync_key}
    Should Be Equal     ${output}      ${sync_value}

Get top info details
    [Documentation]   Veries Top master availability and usability staus
    [Arguments]    ${top_first_level_key}    ${top_second_level_key}    ${top_third_level_key}   ${top_status}    ${top_type}=TOPP
    ${top_info}=    Get Sync Info
    ${top_info}=    Get From Dictionary    ${top_info}   ${top_first_level_key}
    FOR    ${top_dict}    IN   @{top_Info}
        ${top_sync_type}=    Get From Dictionary    ${top_dict}   syncInputType
        Continue For Loop If    not '${top_sync_type}' == '${top_type}'
        ${top_info}=    Get From Dictionary    ${top_dict}   ${top_second_level_key}
        ${top_info}=    Get From Dictionary    ${top_info}   ${top_third_level_key}
        Exit For Loop IF    '${top_sync_type}' == '${top_type}'
    Should Be Equal    ${top_info}   ${top_status}
    END

Check Sync source empty
    ${output}=      Get Sync Info
    ${value}=       Get From Dictionary    ${output}       syncSourceInfo
    Should Be Empty     ${value}

Get TimeSource Info
    [Arguments]    ${key}    ${value}
    ${Time_info} =       Query Admin Infomodel        query=get object //TIME-1
    ${output}=     Get From Dictionary       ${Time_info}        ${key}
    Should Be Equal     ${output}       ${value}

Check top master active status
    [Documentation]   Veries Top master active staus
    [Arguments]    ${top_active_ip}    ${status}
    ${top_active_status}=    Set variable    "Inactive"
    ${top_Info}=    Query Admin Infomodel    query=get object //TOP-1
    ${keys}=    Get Dictionary Keys    ${top_info}
#    ${top_info}=    Get From Dictionary    ${top_info}   masters
    FOR    ${top_dict}    IN   @{top_Info}
        ${top_status}=    Get From Dictionary    ${top_dict}   activity
        ${top_ip}=    Get From Dictionary    ${top_dict}   clkIpAddr
        ${top_active_status}=    Run Keyword If    '${top_ip}' == '${top_active_ip}'    Set variable        ${top_status}
        Exit For Loop IF    '${top_ip}' == '${top_active_ip}'
    Should Be Equal    '${top_active_status}'    '${status}'
    END

Verify TOP mesages
    [Documentation]    Verfies PTP, announce and dealy request messages
    [Arguments]    ${capture_device}=bts
    Traffic Capture Start    capture_device=${capture_device}    alias=capture_bts_1    timeout=120
    Sleep 	120
    ${pcap_name_1}=    Traffic Capture Stop    alias=capture_bts_1
    Analyse Pcap	pcap_filename=${pcap_name_1}	 analysis=verify_ptp_messages     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap	pcap_filename=${pcap_name_1}	 analysis=verify_announce_messages    filter_file_name=${traffic_filter_file_name}
    Analyse Pcap	pcap_filename=${pcap_name_1}	 analysis=verify_delay_request_messages    filter_file_name=${traffic_filter_file_name}
    Analyse Pcap	pcap_filename=${pcap_name_1}	 analysis=verify_domain_number    filter_file_name=${traffic_filter_file_name}
    [Teardown]   Run Keyword And Ignore Error    Traffic Capture Stop    alias=capture_bts_1

Verify TOPF mesages
    [Documentation]    Verfies PTP, announce and dealy request messages
    Traffic Capture Start    capture_device=bts    alias=capture_bts_1    timeout=120
    Sleep 	120
    ${pcap_name_1}=    Traffic Capture Stop    alias=capture_bts_1
    Analyse Pcap	pcap_filename=${pcap_name_1}	 analysis=verify_ptp_messages     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap	pcap_filename=${pcap_name_1}	 analysis=verify_announce_messages    filter_file_name=${traffic_filter_file_name}
    Analyse Pcap	pcap_filename=${pcap_name_1}	 analysis=verify_domain_number    filter_file_name=${traffic_filter_file_name}
    Analyse Pcap	pcap_filename=${pcap_name_1}	 analysis=verify_clock_class    filter_file_name=${traffic_filter_file_name}
    [Teardown]   Run Keyword And Ignore Error    Traffic Capture Stop    alias=capture_bts_1

Read TOP IPaddresses
    [Documentation]   Raeds active and passive tomaster IP's
    ${top_Info}=    Query Admin Infomodel    query=get object //TOP-1
    ${keys}=    Get Dictionary Keys    ${top_info}
#   ${top_info}=    Get From Dictionary    ${top_info}   masters

Verify top info details
    [Documentation]   Verifies Top staus
    [Arguments]    ${moc}    ${decision_type}    ${top_first_level_key}    ${top_second_level_key}   ${top_status}    ${top_id}=1
    ${top_info} =    Query Admin Infomodel    query=get object ${moc}
    ${top_info}=    Get From Dictionary    ${top_info}   ${top_first_level_key}
    FOR    ${top_dict}    IN   @{top_Info}
        ${top_master_id}=    Get From Dictionary    ${top_dict}    ${decision_type}
        Continue For Loop If    not '${top_master_id}' == '${top_id}'
        ${top_info}=    Get From Dictionary    ${top_dict}   ${top_second_level_key}
        Exit For Loop IF    '${top_master_id}' == '${top_id}'
    Should Be Equal    ${top_info}   ${top_status}
   END

Verify top status details
    [Documentation]   Verifies Top active staus
#    [Arguments]    ${moc}    ${decision_type}    ${top_first_level_key}   ${top_status}    ${top_id}=1
    ${top_info} =    Query Admin Infomodel    query=get object ${moc}
    ${top_info}=    Get From Dictionary    ${top_info}   ${top_first_level_key}
    Should Be Equal    ${top_info}   ${top_status}
