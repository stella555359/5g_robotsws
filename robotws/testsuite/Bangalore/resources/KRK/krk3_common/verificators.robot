*** Settings ***
Documentation
...            Keywords for verifying test data
...            author:       Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com
...            maintainer:   Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com

Library    String
Library    Collections
Library    Process
Library    ta5g_tshark
Library     ./Python/utilities_obj.py
Resource    wts.robot

*** Keywords ***
Verify SA UE Traffic Using Bearer Stats
    [Documentation]    Verification of DL and UL traffic paramaters for SA UE via ``bearer_stats`` egate command.
    ...                Traffic must be running before calling this KW.
    ...                Percent of lost packets must not exceed specified threshold.
    ...                Average data throughput deviation must not exceed specified threshold.
    ...                - ``ue_id``: SA UE ID
    ...                - ``pdu_id``: PDU Session ID, Default: same as UE ID
    ...                - ``qfi``: QoS Flow ID, Default: 1
    ...                - ``dl_tput``: Expected DL throughput with unit (bps/kbps/mbps) or OFF, Default: 10mbps
    ...                - ``ul_tput``: Expected UL throughput with unit (bps/kbps/mbps) or OFF, Default: 10mbps
    ...                - ``wait``: Time to wait before getting bearer stats including unit, Default: 0s
    ...                - ``lost_packets_t``: Threshold of lost packets allowed in fraction of total traffic, Default: 10%
    ...                - ``avg_dev_t``: Threshold of allowed average throughput deviation, Default: 10%
    ...                - ``cont_on_fail``: Continue test execution on Fail: yes/no, Default: yes
    ...                - ``params``: Extra parameters for egate command
    [Arguments]    ${ue_id}    ${pdu_id}=${ue_id}    ${qfi}=1    ${dl_tput}=10mbps    ${ul_tput}=10mbps
    ...    ${wait}=0s    ${lost_packets_t}=10    ${avg_dev_t}=10    ${cont_on_fail}=yes    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    Should Be True    type(${pdu_id}) is int    msg=Invalid KW parameter: pdu_id
    Should Be True    type(${qfi}) is int    msg=Invalid KW parameter: qfi
    Should Match Regexp    ${dl_tput}    ^OFF$|^[1-9][0-9]*[km]?bps$    msg=Invalid KW parameter: dl_tput
    Should Match Regexp    ${ul_tput}    ^OFF$|^[1-9][0-9]*[km]?bps$    msg=Invalid KW parameter: ul_tput
    Should Be True    0 <= ${lost_packets_t} <= 100    msg=Invalid KW parameter: lost_packets_t
    Should Be True    0 <= ${avg_dev_t} <= 100    msg=Invalid KW parameter: avg_dev_t
    Should Be True    '${cont_on_fail}' in ('yes','no')    msg=Invalid KW parameter: cont_on_fail
    #---------------------------------------------------------------------------------------------------------------
    Run Keyword If    '${wait}' != '0s'    Run Keywords
    ...    Log To Console    Waiting ${wait} before getting traffic data...
    ...    AND    Sleep    ${wait}    Waiting for running traffic
    ${stats}    Get SA UE Bearer Stats From Egate    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi=${qfi}    &{params}
    ${run_mode}    Set Variable If    '${cont_on_fail}' == 'yes'    Run Keyword And Continue On Failure    Run Keyword
    Log To Console    Verifying traffic parameters for UE-${ue_id}
    Run Keyword If    '${dl_tput}' != 'OFF'    ${run_mode}    Verify Traffic For Direction From Bearer Stats
    ...    dir=DL    ue_id=${ue_id}    bearer_stats=${stats}    tput=${dl_tput}
    ...    lost_packets_t=${lost_packets_t}    avg_dev_t=${avg_dev_t}
    Run Keyword If    '${ul_tput}' != 'OFF'    ${run_mode}    Verify Traffic For Direction From Bearer Stats
    ...    dir=UL    ue_id=${ue_id}    bearer_stats=${stats}    tput=${ul_tput}
    ...    lost_packets_t=${lost_packets_t}    avg_dev_t=${avg_dev_t}

Verify NSA UE Traffic Using Bearer Stats
    [Documentation]    Verification of DL and UL traffic paramaters for NSA UE via ``bearer_stats`` egate command.
    ...                Traffic must be running before calling this KW.
    ...                Percent of lost packets must not exceed specified threshold.
    ...                Average data throughput deviation must not exceed specified threshold.
    ...                - ``ue_id``: NSA UE ID
    ...                - ``drb_id``: Data Radio Bearer ID, Default: 2
    ...                - ``dl_tput``: Expected DL throughput with unit (bps/kbps/mbps) or OFF, Default: 10mbps
    ...                - ``ul_tput``: Expected UL throughput with unit (bps/kbps/mbps) or OFF, Default: 10mbps
    ...                - ``wait``: Time to wait before getting bearer stats including unit, Default: 0s
    ...                - ``lost_packets_t``: Threshold of lost packets allowed in fraction of total traffic, Default: 10%
    ...                - ``avg_dev_t``: Threshold of allowed average throughput deviation, Default: 10%
    ...                - ``cont_on_fail``: Continue test execution on Fail: yes/no, Default: yes
    ...                - ``params``: Extra parameters for egate command
    [Arguments]    ${ue_id}    ${drb_id}=2    ${dl_tput}=10mbps    ${ul_tput}=10mbps    ${wait}=0s
    ...    ${lost_packets_t}=10    ${avg_dev_t}=10    ${cont_on_fail}=yes    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    Should Be True    type(${drb_id}) is int    msg=Invalid KW parameter: drb_id
    Should Match Regexp    ${dl_tput}    ^OFF$|^[1-9][0-9]*[km]?bps$    msg=Invalid KW parameter: dl_tput
    Should Match Regexp    ${ul_tput}    ^OFF$|^[1-9][0-9]*[km]?bps$    msg=Invalid KW parameter: ul_tput
    Should Be True    0 <= ${lost_packets_t} <= 100    msg=Invalid KW parameter: lost_packets_t
    Should Be True    0 <= ${avg_dev_t} <= 100    msg=Invalid KW parameter: avg_dev_t
    Should Be True    '${cont_on_fail}' in ('yes','no')    msg=Invalid KW parameter: cont_on_fail
    #---------------------------------------------------------------------------------------------------------------
    Run Keyword If    '${wait}' != '0s'    Run Keywords
    ...    Log To Console    Waiting ${wait} before getting traffic data...
    ...    AND    Sleep    ${wait}    Waiting for running traffic
    ${stats}    Get NSA UE Bearer Stats From Egate    ue_id=${ue_id}    drb_id=${drb_id}    &{params}
    ${run_mode}    Set Variable If    '${cont_on_fail}' == 'yes'    Run Keyword And Continue On Failure    Run Keyword
    Log To Console    Verifying traffic parameters for UE-${ue_id}
    Run Keyword If    '${dl_tput}' != 'OFF'    ${run_mode}    Verify Traffic For Direction From Bearer Stats
    ...    dir=DL    ue_id=${ue_id}    bearer_stats=${stats}    tput=${dl_tput}
    ...    lost_packets_t=${lost_packets_t}    avg_dev_t=${avg_dev_t}
    Run Keyword If    '${ul_tput}' != 'OFF'    ${run_mode}    Verify Traffic For Direction From Bearer Stats
    ...    dir=UL    ue_id=${ue_id}    bearer_stats=${stats}        tput=${ul_tput}
    ...    lost_packets_t=${lost_packets_t}    avg_dev_t=${avg_dev_t}

Verify Traffic For Direction From Bearer Stats
    [Documentation]    Internal KW - not for use by users. Call only when ``tput`` > 0.
    [Arguments]    ${dir}    ${ue_id}    ${bearer_stats}    ${tput}    ${lost_packets_t}    ${avg_dev_t}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    '${dir}' in ('DL','UL')   msg=Invalid KW parameter: dir
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    Should Be True    type(${bearer_stats}) is dict    msg=Invalid KW parameter: bearer_stats
    ${match}    ${tput_val}    ${tput_unit}    Should Match Regexp    ${tput}    (^[1-9][0-9]*)([km]?bps$)
    ...    msg=Invalid KW parameter: tput
    Should Be True    0 <= ${lost_packets_t} <= 100    msg=Invalid KW parameter: lost_packets_t
    Should Be True    0 <= ${avg_dev_t} <= 100    msg=Invalid KW parameter: avg_dev_t
    #---------------------------------------------------------------------------------------------------------------
    ${denominator}    Set Variable If    '${tput_unit}' == 'mbps'    1000000
    ...                                  '${tput_unit}' == 'kbps'    1000
    ...                                  '${tput_unit}' == 'bps'     1
    ${avg_tput}      Split String    ${bearer_stats}[${dir}][Average data rate]
    ${avg_tput}      Evaluate    ${avg_tput}[0]/${denominator}
    ${total_sent}    Set Variable    ${bearer_stats}[${dir}][Total packets sent]
    ${total_recv}    Set Variable    ${bearer_stats}[${dir}][Total packets received]
    Should Be True    ${total_sent} > 0    msg=No ${dir} traffic was running for UE-${ue_id}: No packets sent.
    ${lost_packets_p}    Evaluate    abs((1 - (${total_recv}/${total_sent}))*100.0)
    ${avg_dev_p}         Evaluate    abs((1 - (${avg_tput}/${tput_val}))*100.0)
    #--------- Message building ------------------------------------------------------------------------------------
    ${msg_pack_lost}    Evaluate    "UE-${ue_id} ${dir} Packets Lost: %.1f" % ${lost_packets_p} + "%"
    ${msg_avg_tput}    Catenate    UE-${ue_id} ${dir} Average Throughput: %.1f ${tput_unit},
    ...    Throughput Deviation: %.1f%%
    ${msg_avg_tput}    Evaluate    "${msg_avg_tput}" % (${avg_tput},${avg_dev_p})
    ${msg_fail_prefix}    Set Variable    ${dir} traffic for UE-${ue_id} does not meet verification parameters:
    ${msg_fail_pack}    Set Variable    ${msg_fail_prefix} %.1f%% > ${lost_packets_t}%% of Packets Lost
    ${msg_fail_pack}    Evaluate    "${msg_fail_pack}" % ${lost_packets_p}
    ${msg_fail_tput}    Catenate    ${msg_fail_prefix}
    ...    %.1f%% (%.1f ${tput_unit}) > ${avg_dev_t}%% of
    ...    Expected Average Throughput (${tput_val} ${tput_unit}) Deviation
    ${msg_fail_tput}    Evaluate    "${msg_fail_tput}" % (${avg_dev_p},${avg_tput})
    #---------------------------------------------------------------------------------------------------------------
    Log to Console    ${msg_pack_lost}
    Log to Console    ${msg_avg_tput}
    Run Keyword And Continue On Failure
    ...    Should Be True    ${lost_packets_p} <= ${lost_packets_t}    msg=${msg_fail_pack}
    Should Be True    ${avg_dev_p} <= ${avg_dev_t}    msg=${msg_fail_tput}

Verify If Message Exists in GNB tcpdump
    [Documentation]    Verifies existence of a single message in GNB SCTP PCAP using specified tshark filter.
    ...                SCTP packets include SYSCOM/NGAP/X2AP/XnAP/E1AP/F1AP protocols.
    ...                Assumes that SCTP collection has been started and test variable TEST_tcpdump_gnb_path
    ...                was created.
    ...                - ``filter``: tshark filter for message
    [Arguments]    ${filter}
    Variable Should Exist    ${TEST_tcpdump_gnb_path}
    ...    msg=GNB SCTP tcpdump collection has not been started
    ta5g_tshark.verify_tshark_for_single_message
    ...    alias=tshark_gnb_sctp
    ...    pcap_file_path=${TEST_tcpdump_gnb_path}
    ...    packet_filter=${filter}

Verify Message Count in PCAP
    [Documentation]    Verifies if specified number of filtered messages exist in PCAP file.
    ...                Supports ``>``,``<``,``>=``,``<=`` inequality symbols.
    ...                - ``pcap_filepath``: Path to input PCAP file
    ...                - ``filter``: tshark packet filter
    ...                - ``count``: Expected count of messages
    ...                - ``msg``: Custom fail message, Default: Standard message
    ...                - ``options``: List of extra tshark parameters, Default: None
    ...                Example:
    ...                | Verify Message Count in PCAP | pcap_filepath=file.pcap |
    ...                |  | filter=x2ap.procedureCode == 27 | count=2 |
    ...                | Verify Message Count in PCAP | pcap_filepath=file.pcap |
    ...                |  | filter=x2ap.X2AP_PDU == 1 | count=>0 | msg=No Successful Outcome messages. |
    [Arguments]    ${pcap_filepath}    ${filter}    ${count}    ${msg}=${Empty}    ${options}=@{Empty}
    #--------- Param check -----------------------------------------------------------------------------------------
    File Should Exist    ${pcap_filepath}
    ${match}    ${sign}    ${number}    Should Match Regexp    ${count}    ^([<>]?|>\=|<\=)(\\d+)$
    ...    msg=Invalid KW parameter: count
    #---------------------------------------------------------------------------------------------------------------
    ${result}    Run Process And Expect Success    tshark    @{options}    -Y    ${filter}    -r    ${pcap_filepath}
    ${message_count}    Get Line Count    ${result.stdout}
    ${sign}    Set Variable If    '${sign}' == ''    \==    ${sign}
    ${msg}    Set Variable If    '${msg}' == ''    Unexpected message count in file: ${pcap_filepath}    ${msg}
    ${msg}    Catenate    SEPARATOR=\n
    ...    ${msg}
    ...    Used filter: ${filter}
    ...    Expected count: ${count}
    ...    Actual count: ${message_count}
    Run Keyword And Continue On Failure
    ...    Should Be True    int('${message_count}') ${sign} int('${number}')    msg=${msg}
    [Return]    ${message_count}

Verify Message Count in PCAP 8176
    [Documentation]    Verifies if specified number of filtered messages exist in PCAP file.
    ...                Supports ``>``,``<``,``>=``,``<=`` inequality symbols.
    ...                - ``pcap_filepath``: Path to input PCAP file
    ...                - ``filter``: tshark packet filter
    ...                - ``count``: Expected count of messages
    ...                - ``msg``: Custom fail message, Default: Standard message
    ...                - ``options``: List of extra tshark parameters, Default: None
    ...                Example:
    ...                | Verify Message Count in PCAP | pcap_filepath=file.pcap |
    ...                |  | filter=x2ap.procedureCode == 27 | count=2 |
    ...                | Verify Message Count in PCAP | pcap_filepath=file.pcap |
    ...                |  | filter=x2ap.X2AP_PDU == 1 | count=>0 | msg=No Successful Outcome messages. |
    [Arguments]    ${pcap_filepath}    ${filter}    ${count}    ${msg}=${Empty}    ${options}=@{Empty}
    #--------- Param check -----------------------------------------------------------------------------------------
    File Should Exist    ${pcap_filepath}
    ${match}    ${sign}    ${number}    Should Match Regexp    ${count}    ^([<>]?|>\=|<\=)(\\d+)$
    ...    msg=Invalid KW parameter: count
    #---------------------------------------------------------------------------------------------------------------
    ${result}    Run Process And Expect Success    tshark    @{options}    -Y    ${filter}    -r    ${pcap_filepath}
    ${message_count}    Get Line Count    ${result.stdout}
    ${sign}    Set Variable If    '${sign}' == ''    \<=    ${sign}
    ${msg}    Set Variable If    '${msg}' == ''    Unexpected message count in file: ${pcap_filepath}    ${msg}
    ${msg}    Catenate    SEPARATOR=\n
    ...    ${msg}
    ...    Used filter: ${filter}
    ...    Expected count: ${count}
    ...    Actual count: ${message_count}
    Run Keyword And Continue On Failure
    ...    Should Be True    int('${message_count}') ${sign} int('${number}')    msg=${msg}
    [Return]    ${message_count}

Should Match Regexp in Files
    [Documentation]    Fails if a regular expression is not found in a single or more files using grep.
    ...                For multi-line regexp use -z option together with pattern starting with (?s)
    ...                and wrapped in single-quotes. WARNING: Using -z option is not recommended for large files and
    ...                may cause test freeze.
    ...                Returns string with lines that match.
    ...                - ``pattern``: Perl Compatible Regular expression
    ...                - ``paths``: Unpacked list of paths to the files
    ...                - ``options``: String with extra options for grep, -P supplied by default
    ...                - ``msg``: Alternative fail message
    [Arguments]    ${pattern}    @{paths}    ${options1}=${Empty}    ${msg}=${Empty}
    Should Not Be Empty    ${paths}
    @{options}    Split String    ${options1}
    FOR    ${file}    IN    @{paths}
      File Should Exist    ${file}
    END
    ${default_msg}    Catenate    Could not find regexp    ${pattern}    in    @{paths}
    ${msg}    Set Variable If    '${msg}' == ''    ${default_msg}    ${msg}
    ${result}    Run Process And Expect Success    grep    -P    @{options}    ${pattern}    @{paths}    msg=${msg}
    [Return]    ${result.stdout}

Wait for Regexp in File
    [Documentation]    Fails if a regular expression is not found in a file before timeout.
    ...                For multi-line regexp use option -z together with pattern starting with (?s)
    ...                and wrapped in single-quotes.
    ...                WARN: Not recommended to use with egate_console.log because that file does not update
    ...                without flushing.
    ...                - ``path``: Path to the file
    ...                - ``pattern``: Perl Compatible Regular expression
    ...                - ``timeout``: Timeout in Robot time format, Default: 10s
    ...                - ``options``: String with extra options for grep, -P supplied by default
    ...                - ``msg``: Alternative fail message
    [Arguments]    ${path}    ${pattern}    ${timeout}=10s    ${options1}=${Empty}    ${msg}=${Empty}
    File Should Exist    ${path}
    @{options}    Split String    ${options1}
    ${default_msg}    Catenate    Timeout (${timeout}) waiting for regexp    ${pattern}    in    ${path}
    ${msg}    Set Variable If    '${msg}' == ''    ${default_msg}    ${msg}
    Wait Until Process Succeeds    grep    -P    @{options}    ${pattern}    ${path}    timeout=${timeout}    msg=${msg}

Verify PCMD Record in Collection
    [Documentation]    Verifies if specified PCMD record is present in the collection and if provided fields
    ...                have specified values. Record name is treated as substring and field names and their values
    ...                are treated as regexp patterns.
    ...                - ``collected_records``: Output of KW ``Get PCMD Records from PCAP``
    ...                - ``record_name``: Name of PCMD Record
    ...                - ``strict_fields_check``: Checks that no extra fields beyond expected are present, Default: no
    ...                - ``fields``: Optional fields and their expected values as regexp patterns
    ...                Example:
    ...                | $\{records\} | Get PCMD Records from PCAP | pcap_filepath=file.pcap |
    ...                | Verify PCMD Record in Collection | $\{records\} | ueInfoRecord |
    ...                |  | drxConfiguration=0 | xddCapability=\\d+ |
    [Arguments]    ${collected_records}    ${record_name}    ${strict_fields_check}=no    &{fields}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    isinstance(${collected_records}, list)   msg=Invalid KW parameter: collected_records
    Should Not Be Empty    ${collected_records}   msg=Invalid KW parameter: collected_records
    Should Be True    '${strict_fields_check}' in ('yes','no')    msg=Invalid KW parameter: strict_fields_check
    #---------------------------------------------------------------------------------------------------------------
    &{element}    Create Dictionary    record_name=${record_name}    &{fields}
    @{sequence}    Create List    ${element}
    Verify JSON Message Sequence in Collection
    ...    collection_json=${collected_records}    name_field=record_name    sequence=${sequence}
    ...    strict_fields_check=${strict_fields_check}    collection_name=PCMD records

Verify PCMD Records Sequence in Collection
    [Documentation]    Verifies if provided PCMD records sequence of record names and their fields is present
    ...                in the collection. Record name is treated as substring and field names and their values
    ...                are treated as regexp patterns.
    ...                Verifies the order of the sequence and ignores all other records in the collection.
    ...                - ``collected_records``: Output of KW ``Get PCMD Records from PCAP``
    ...                - ``record_seq``: List of dictionaries with mandatory key ``record_name`` and optional\
    ...                record fields with their expected values as regexp patterns
    ...                - ``strict_fields_check``: Checks that no extra fields beyond expected are present, Default: no
    ...                Example:
    ...                | ***** Variables ***** |
    ...                | &\{UE1_Info\} | record_name=ueInfoRecord | drxConfiguration=0 | xddCapability=\\d+ |
    ...                | &\{UE2_Info\} | record_name=ueInfoRecord | drxConfiguration=0 | xddCapability=\\d+ |
    ...                | @\{PCMD_Seq\} | $\{UE1_Info\} | $\{UE2_Info\} |
    ...                | ***** Test Cases ***** |
    ...                | Example_test |
    ...                |  | $\{records\} | Get PCMD Records from PCAP | pcap_filepath=file.pcap |
    ...                |  | Verify PCMD Records Sequence in Collection | $\{records\} | $\{PCMD_Seq\} |
    [Arguments]    ${collected_records}    ${record_seq}    ${strict_fields_check}=no
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    isinstance(${collected_records}, list)   msg=Invalid KW parameter: collected_records
    Should Be True    isinstance(${record_seq}, list)   msg=Invalid KW parameter: record_seq
    Should Not Be Empty    ${collected_records}   msg=Invalid KW parameter: collected_records
    Should Not Be Empty    ${record_seq}   msg=Invalid KW parameter: record_seq
    Should Be True    '${strict_fields_check}' in ('yes','no')    msg=Invalid KW parameter: strict_fields_check
    #---------------------------------------------------------------------------------------------------------------
    Verify JSON Message Sequence in Collection
    ...    collection_json=${collected_records}    name_field=record_name    sequence=${record_seq}
    ...    strict_fields_check=${strict_fields_check}    collection_name=PCMD records

Verify Cell Trace in Collection
    [Documentation]    Verifies if specified Cell Trace message is present in the collection and if provided fields
    ...                have specified values. Field names and their values are treated as regexp patterns.
    ...                - ``collected_traces``: Output of KW ``Get Cell Traces from PCAP``
    ...                - ``trace_name``: nr-rrc / ngap / x2ap / xnap for top-level collection
    ...                - ``fields``: Optional fields and their expected values as regexp patterns
    ...                Example:
    ...                | $\{traces\} | Get Cell Traces from PCAP | pcap_filepath=file.pcap |
    ...                | Verify Cell Trace in Collection | $\{traces\} | x2ap | procedureCode=27 | UE_X2AP_ID=\\d+ |
    [Arguments]    ${collected_traces}    ${trace_name}    &{fields}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    isinstance(${collected_traces}, list)   msg=Invalid KW parameter: collected_traces
    Should Not Be Empty    ${collected_traces}   msg=Invalid KW parameter: collected_traces
    #---------------------------------------------------------------------------------------------------------------
    &{element}    Create Dictionary    trace_name=${trace_name}    &{fields}
    @{sequence}    Create List    ${element}
    Verify JSON Message Sequence in Collection
    ...    collection_json=${collected_traces}    name_field=trace_name    sequence=${sequence}
    ...    collection_name=Cell Traces

Verify Cell Trace Sequence in Collection
    [Documentation]    Verifies if specified Cell Trace sequence of messages and their fields is present
    ...                in the collection. Field names and their values are treated as regexp patterns.
    ...                Verifies the order of the sequence and ignores all other messages in the collection.
    ...                - ``collected_traces``: Output of KW ``Get Cell Traces from PCAP``
    ...                - ``trace_seq``: List of dictionaries with mandatory key ``trace_name`` and optional\
    ...                message fields with their expected values as regexp patterns
    ...                Example:
    ...                | ***** Variables ***** |
    ...                | &\{SgNBAddReq\} | trace_name=x2ap | SgNBAdditionRequest=.* | UE_X2AP_ID=\\d+ |
    ...                | &\{SgNBAddReqAck\} | trace_name=x2ap | SgNBAdditionRequestAcknowledge=.* | SgNB_UE_X2AP_ID=\\d+ |
    ...                | @\{Trace_Seq\} | $\{SgNBAddReq\} | $\{SgNBAddReqAck\} |
    ...                | ***** Test Cases ***** |
    ...                | Example_test |
    ...                |  | $\{traces\} | Get Cell Traces from PCAP | pcap_filepath=file.pcap |
    ...                |  | Verify Cell Trace Sequence in Collection | $\{traces\} | $\{Trace_Seq\} |
    [Arguments]    ${collected_traces}    ${trace_seq}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    isinstance(${collected_traces}, list)   msg=Invalid KW parameter: collected_traces
    Should Be True    isinstance(${trace_seq}, list)   msg=Invalid KW parameter: trace_seq
    Should Not Be Empty    ${collected_traces}   msg=Invalid KW parameter: collected_traces
    Should Not Be Empty    ${trace_seq}   msg=Invalid KW parameter: trace_seq
    #---------------------------------------------------------------------------------------------------------------
    Verify JSON Message Sequence in Collection
    ...    collection_json=${collected_traces}    name_field=trace_name    sequence=${trace_seq}
    ...    collection_name=Cell Traces

Verify JSON Message Sequence in Collection
    [Documentation]    Verifies if specified message sequence is present in the collection.
    ...                Field names and their values are treated as regexp patterns.
    ...                Verifies the order of the sequence and ignores all other messages in the collection.
    ...                - ``collection_json``: JSON collection of messages to verify
    ...                - ``name_field``: Name of key in sequence that contains message name
    ...                - ``sequence``: List of dictionaries with mandatory key named in ``name_field`` parameter\
    ...                and optional field name and value pairs as regexp patterns
    ...                - ``strict_fields_check``: Checks that no extra fields beyond expected are present, Default: no
    ...                - ``collection_name``: Optional name of collection used in Robot messages, Default: Traces
    [Arguments]    ${collection_json}    ${name_field}    ${sequence}    ${strict_fields_check}=no
    ...    ${collection_name}=Traces
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    isinstance(${collection_json}, list)   msg=Invalid KW parameter: collection_json
    Should Be True    isinstance(${sequence}, list)   msg=Invalid KW parameter: sequence
    Should Not Be Empty    ${collection_json}   msg=Invalid KW parameter: collection_json
    Should Not Be Empty    ${sequence}   msg=Invalid KW parameter: sequence
    Should Be True    '${strict_fields_check}' in ('yes','no')    msg=Invalid KW parameter: strict_fields_check
    #---------------------------------------------------------------------------------------------------------------
    ${seq_len}    Get Length    ${sequence}
    Log to Console    Verifying sequence of ${seq_len} ${collection_name}
    ${msg_found}    Set Variable    ${False}
    ${sequence}    Copy List    ${sequence}    deepcopy=${True}
    ${msg_from_seq}    Remove From List    ${sequence}    0
    ${msg_from_seq}    Copy Dictionary    ${msg_from_seq}    deepcopy=${True}
    Log to Console    Verifying ${collection_name} message: ${msg_from_seq}[${name_field}]
    FOR    ${message}    IN    @{collection_json}
      ${key}    Get Dictionary Keys    ${message}
      ${key}    Set Variable    ${key}[0]
      ${msg_found}     Set Variable If    '${msg_from_seq}[${name_field}]' in '${key}'    ${True}
      ${msg_name}    Set Variable If    ${msg_found}    ${msg_from_seq}[${name_field}]
      Run Keyword If    ${msg_found}    Remove From Dictionary    ${msg_from_seq}    ${name_field}
      Run Keyword If    ${msg_found}
      ...    Flatten And Verify JSON Message Fields    msg_json=${message}    msg_name=${msg_name}
      ...    strict_fields_check=${strict_fields_check}    &{msg_from_seq}
      Exit For Loop If    ${msg_found} and ${sequence} == []
      ${next}    Set Variable If    ${msg_found} and ${sequence} != []    ${True}    ${False}
      ${msg_from_seq}    Run Keyword If    ${next}    Remove From List    ${sequence}    0
      ...    ELSE    Set Variable    ${msg_from_seq}
      ${msg_from_seq}    Run Keyword If    ${next}    Copy Dictionary    ${msg_from_seq}    deepcopy=${True}
      ...    ELSE    Set Variable    ${msg_from_seq}
      Run Keyword If    ${next}    Log to Console    Verifying ${collection_name} message: ${msg_from_seq}[${name_field}]
      ${msg_found}    Set Variable If    ${next}    ${False}
    END
    Run Keyword If     not ${msg_found}    Run Keyword And Continue On Failure
    ...    Fail    msg=No ${msg_from_seq}[${name_field}] message found in ${collection_name} collection.

Flatten And Verify JSON Message Fields
    [Documentation]    Flattens provided JSON message object into single-level dictionary and verifies presence of
    ...                fields provided as name and value regexp patterns.
    ...                - ``msg_json``: Message as JSON object
    ...                - ``msg_name``: Name of verified message
    ...                - ``strict_fields_check``: Checks that no extra fields beyond expected are present, Default: no
    ...                - ``fields``: Field name and value pairs as regexp patterns
    ...                Example:
    ...                | Flatten And Verify JSON Message Fields | msg_json=$\{msg\} | msg_name=sgnbAdditionRecord |
    ...                |  | sgnb_ue_x2ap_Id=3 | sgnbAdditionReqAckSndTime.*seconds=\\d{10} |
    [Arguments]    ${msg_json}    ${msg_name}    ${strict_fields_check}=no    &{fields}
    ${flat_data}    flatten_obj    ${msg_json}
    ${msg_copy}    Copy Dictionary    ${flat_data}
    FOR    ${field}    IN    @{fields}
      ${ret}    find_node_matching_regexp    ${flat_data}    ${field}
      Run Keyword If    not isinstance(${ret}, tuple)    Run Keywords
      ...    Run Keyword And Continue On Failure
      ...    Fail    msg=No field in ${msg_name} message matching pattern: ${field}${\n}Message data:${\n}${msg_copy}
      ...    AND    Continue For Loop
      Run Keyword And Continue On Failure    Should Match Regexp    ${ret}[1]    ^${fields}[${field}]$    values=${False}
      ...    msg=Field ${field} in ${msg_name} message with value "${ret}[1]" does not match pattern: ${fields}[${field}]
      Remove From Dictionary    ${flat_data}    ${ret}[0]
    END
    Run Keyword If    '${strict_fields_check}' == 'yes'    Run Keyword And Continue On Failure
    ...    Should Be Empty    ${flat_data}    msg=Unexpected fields in ${msg_name} message: ${flat_data}
