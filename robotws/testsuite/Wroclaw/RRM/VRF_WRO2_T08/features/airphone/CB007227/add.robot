*** Settings ***
Documentation
...            title:        CB008187-SR   PCMD/call trace RAN UE ID
...            author:       Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com
...            maintainer:   Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com

Resource    ../../../../sim_resources/Krk_regression/ran_L3_SW2_resources/KRK3_resources/krk3_common/main_cls.robot

*** Variables ***
@{TSHARK_NSETAPX}       -o    ntrstr.defragment:TRUE     -o    ntrstr.port:49148

*** Keywords ***
Perform NSA Handover To Target PCI
    [Arguments]    ${ue_id}    ${target_pci}    ${event}    ${pass_regexp}=${Empty}
    ${out}    Perform Intra-GNB X2 NSA Handover To Target PCI
    ...    ue_id=${ue_id}    target_pci=${target_pci}    event=${event}    pass_regexp=${pass_regexp}
    RETURN    ${out}

Perform SA Inter-RAT HO
    [Arguments]    ${ue_id}      ${target_pci}
    ${out}    Perform Inter-RAT SA Handover To Target PCI    ue_id=${ue_id}    target_pci=${target_pci}    event=B2
    RETURN    ${out}

Get UE RAN IDs from PCAP
    [Documentation]    Extracts UE RAN IDs field values from StartRecordingSession messages and returns values
    ...                converted to DEC. Verifies expected ``$\{sessions\}`` number.
    [Arguments]    ${pcap_filepath}    ${sessions}
    @{options}    Create List    -o    ntrstr.defragment:TRUE     -o    ntrstr.port:49148
    ...    -e    nsetapx.TraceMessage    -E    separator\=';'
    ${fields}    Get Message Field Values from PCAP
    ...    pcap_filepath=${pcap_filepath}    options=${options}
    ...    field_name=nsetapx.ranUeId    filter=nsetapx.TraceMessage == 4
    Length Should Be    ${fields}    ${sessions}
    ...    msg=Unexpected number of StartRecordingSession messages with ranUeId field.
    ${dec_ids}    Create List
    FOR    ${string}    IN    @{fields}
      ${msg_type}    ${ids}    Split String    ${string}    ;
      ${types_list}    Split String    ${msg_type}    ,
      ${ids_list}    Split String    ${ids}    ,
      ${start_ind}    Get Index From List    ${types_list}    4
      ${dec_id}    Evaluate    str(int("${ids_list}[${start_ind}]", 16))
      Append To List    ${dec_ids}    ${dec_id}
    END
    RETURN    ${dec_ids}

Verify UE RAN IDs in StopRecordingSession in PCAP
    [Arguments]    ${pcap_filepath}    ${sessions}    ${ran_ue_ids}
    @{options}    Create List    -o    ntrstr.defragment:TRUE     -o    ntrstr.port:49148
    ...    -e    _ws.col.Info    -E    separator\=';'
    ${fields}    Get Message Field Values from PCAP
    ...    pcap_filepath=${pcap_filepath}    options=${options}
    ...    field_name=nsetapx.ranUeId    filter=nsetapx.TraceMessage == 5
    Length Should Be    ${fields}    ${sessions}
    ...    msg=Unexpected number of StopRecordingSession messages with ranUeId field.
    FOR    ${ran_ue_id}    ${string}    IN ZIP    ${ran_ue_ids}    ${fields}
      ${info}    ${ids}    Split String    ${string}    ;
      ${info_list}    Split String    ${info}
      ${ids_list}    Split String    ${ids}    ,
      ${start_ind}    Get Index From List    ${info_list}    StopRecordingSession
      Should Be True    int("${ids_list}[${start_ind}]", 16) == int("${ran_ue_id}")
      ...    msg=UE RAN ID from StartRecordingSession does not match StopRecordingSession message.
    END

Start NSA L3 Call to Sim GNB
    [Arguments]    ${ue_id}    ${target_gnb_cell}=1    ${dl_tput}=10mbps    ${ul_tput}=10mbps
    Start NSA L3 Call    ue_id=${ue_id}    target_gnb=3    target_gnb_cell=${target_gnb_cell}
    ...    dl_tput=${dl_tput}    ul_tput=${ul_tput}
