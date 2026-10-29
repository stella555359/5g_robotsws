*** Settings ***
Documentation
...            Keywords for converting files and data
...            author:       Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com
...            maintainer:   Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com

Library    OperatingSystem
Library    Process
Library    String
Library    Collections
Library    taf.converters.sherpa          WITH NAME    csherpa
Library    taf.converters.eventdecoder    WITH NAME    ctti
Library     ./Python/utilities_obj.py

Resource    utilities.robot

*** Keywords ***
Convert Sherpa Trace PCAP to CSV
    [Documentation]    Converts PCAP with Sherpa Trace to CSV files using Sherpa 5G tool.
    ...                Returns dictionary with name:path items for all generated CSV files.
    ...                - ``pcap_filepath``: Path to input PCAP file
    ...                - ``csv_dirpath``: Path to output directory for CSV files, Default: Same as input file
    ...                - ``duration``: Limit in seconds on duration to convert, Default: 0 (no limit)
    ...                - ``macro``: Period of Macro mode in miliseconds, Default: 1000
    ...                Example:
    ...                | $\{csv_files\} | Convert Sherpa Trace PCAP to CSV |
    ...                |  | pcap_filepath=tcpdump.pcap | csv_dirpath=$\{TEST_log_dir\}/Sherpa_CSV/ |
    ...                | Analyze CSV | filepath=$\{csv_files.micro__l1l2Trace\} |
    [Arguments]    ${pcap_filepath}    ${csv_dirpath}=${Empty}    ${duration}=0    ${macro}=1000
    #--------- Param check -----------------------------------------------------------------------------------------
    File Should Exist    ${pcap_filepath}
    ${match}    ${dir}    @{rest}    Should Match Regexp    ${pcap_filepath}    ^(.*/)([^/]+)\\.pcap$
    ...    msg=Invalid KW parameter: pcap_filepath
    #---------------------------------------------------------------------------------------------------------------
    ${output_dir}    Set Variable If    '${csv_dirpath}' == ''    ${dir}    ${csv_dirpath}
    Create Directory    ${output_dir}
    csherpa.create_sherpa_converter
    ...    name=sherpa_converter
    ...    file_path_pattern=${pcap_filepath}
    ...    output_path=${output_dir}
    ...    sherpa_command_duration=${duration}
    ...    sherpa_command_macro_period=${macro}
    Log to Console    Converting Sherpa Trace PCAP to CSV
    csherpa.setup    sherpa_converter
    Check Available Memory on VM
    csherpa.convert    sherpa_converter
    ${files}    Find Files    ${output_dir}   -name    '*.csv'    fail_on_empty=yes    return=dict
    [Teardown]    csherpa.teardown    sherpa_converter
    [Return]    ${files}

Decode TTI Traces from PCAP or BIN
    [Documentation]    Decodes TTI Traces from PCAP or BIN file to output files in CSV or JSON format.
    ...                Program ``/opt/tti-dec/tti-dec-bin/bin/eventDecoder`` is used for legacyCsv and json conversion.
    ...                Script ``/opt/tti-dec/tti-dec-bin/outputGenerator/excelCsv/ExcelCsvGenerator.py`` is used for
    ...                excelCsv conversion.
    ...                - ``input_filepath``: Path to input PCAP or BIN file
    ...                - ``output_dir``: Path to output directory, Default: Same as input file
    ...                - ``output_name``: Prefix name of the output files, Default: ttitrace
    ...                - ``format``: json, legacyCsv or excelCsv, Default: legacyCsv
    ...                - ``conversion_filter``: Regular expression for filtering TTI event type, Default: None
    ...                - ``excel_csv_options``: Options for ExcelCsvGenerator.py script, Default: None
    [Arguments]    ${input_filepath}    ${output_dir}=${Empty}    ${output_name}=ttitrace    ${format}=legacyCsv
    ...    ${conversion_filter}=${None}    ${excel_csv_options}=${None}
    #--------- Param check -----------------------------------------------------------------------------------------
    File Should Exist    ${input_filepath}
    ${match}    ${dir}    @{rest}    Should Match Regexp    ${input_filepath}    ^(.*/)([^/]+)\\.(pcap|bin)$
    ...    msg=Invalid KW parameter: input_filepath
    Should Be True    '${format}' in ('json','legacyCsv','excelCsv')    msg=Invalid KW parameter: format
    #---------------------------------------------------------------------------------------------------------------
    ${output_dir}    Set Variable If    '${output_dir}' == ''    ${dir}    ${output_dir}
    ${output_file_path}    Set Variable    ${output_dir}/${output_name}
    ctti.create_eventdecoder_converter
    ...    name=tti_converter
    ...    input_file_path=${input_filepath}
    ...    output_file_path=${output_file_path}
    ...    output_file_format=${format}
    ...    conversion_filter=${conversion_filter}
    ...    excel_csv_options=${excel_csv_options}
    Log to Console    Decoding TTI Traces...
    ${status}    ${msg}    Run Keyword And Ignore Error    ctti.convert    tti_converter
    Run Keyword If    '${status}' == 'FAIL'    Fail
    ...    Error decoding TTI Traces. Ensure the decoder version matches the BTS build version.${\n}${msg}
    ${ext}    Set Variable If    'Csv' in '${format}'    csv    json
    ${files}    Find Files    ${output_dir}   -name    '*.${ext}'    fail_on_empty=yes    return=dict
    [Return]    ${files}

Convert PCAP to JSON
    [Documentation]    Converts PCAP file to JSON format. See ``Convert PCAP to FORMAT`` for documentation.
    [Arguments]    ${input_filepath}    ${output_filepath}=${Empty}    ${filter}=${Empty}    ${options}=@{Empty}
    ${output_filepath}    Convert PCAP to FORMAT    format=json
    ...    input_filepath=${input_filepath}    output_filepath=${output_filepath}
    ...    filter=${filter}    options=${options}
    [Return]    ${output_filepath}

Convert PCAP to PDML
    [Documentation]    Converts PCAP file to PDML format. See ``Convert PCAP to FORMAT`` for documentation.
    [Arguments]    ${input_filepath}    ${output_filepath}=${Empty}    ${filter}=${Empty}    ${options}=@{Empty}
    ${output_filepath}    Convert PCAP to FORMAT    format=pdml
    ...    input_filepath=${input_filepath}    output_filepath=${output_filepath}
    ...    filter=${filter}    options=${options}
    [Return]    ${output_filepath}

Convert PCAP to FORMAT
    [Documentation]    Converts PCAP to selected plain text format - JSON or PDML. Returns path to new file.
    ...                - ``format``: json or pdml
    ...                - ``input_filepath``: Path to input PCAP file
    ...                - ``output_filepath``: Path to output file, Default: Same name and location as input file
    ...                - ``filter``: Optional tshark packet filter, Default: None
    ...                - ``options``: List of extra tshark parameters, Default: None
    [Arguments]    ${format}    ${input_filepath}    ${output_filepath}=${Empty}
    ...    ${filter}=${Empty}    ${options}=@{Empty}
    #--------- Param check -----------------------------------------------------------------------------------------
    File Should Exist    ${input_filepath}
    Should Be True    '${format}' in ('json','pdml')    msg=Invalid KW parameter: format
    ${match}    ${filename}    Should Match Regexp    ${input_filepath}    ^(.*/[^/]+)\\.pcap$
    ...    msg=Invalid KW parameter: input_filepath
    Should Be True    isinstance(${options}, list)    msg=Invalid KW parameter: options
    #---------------------------------------------------------------------------------------------------------------
    ${output_filepath}    Set Variable If    '${output_filepath}' == ''    ${filename}.${format}    ${output_filepath}
    Log to Console    Converting PCAP to ${format}: ${input_filepath}
    ${result}    Run Process And Expect Success    tshark    @{options}    -Y    ${filter}
    ...    -T    ${format}    -r    ${input_filepath}
    ...    stdout=${output_filepath}    msg=Error converting PCAP to ${format}: ${input_filepath}
    [Return]    ${output_filepath}

Get PCMD Records from PCAP
    [Documentation]    Returns PCMD records extracted from specified PCAP file as list.
    ...                - ``pcap_filepath``: Path to input PCAP file
    ...                - ``pattern``: Regexp pattern used to find PCMD records, Default: nsetapx.*Record_tree
    ...                - ``filter``: tshark packet filter, Default: nsetapx
    ...                - ``tce_port``: Configured port number of Trace Controller Entity, Default: 49148
    ...                - ``save_to_file``: Optional path to output JSON file with records, Default: None
    [Arguments]    ${pcap_filepath}    ${pattern}=nsetapx.*Record_tree    ${filter}=nsetapx
    ...    ${tce_port}=49148    ${save_to_file}=${Empty}
    @{options}    Create List    -o    ntrstr.defragment:TRUE     -o    ntrstr.port:${tce_port}    -J    nsetapx
    Log To Console    Searching for PCMD records in ${pcap_filepath}
    ${records}    Get Items Matching Regexp From PCAP    pcap_filepath=${pcap_filepath}
    ...    pattern=${pattern}    filter=${filter}    options=${options}
    ...    search_for="nsetapx": {    replace_with="nsetapx_$": {    remove_per=yes
    ...    save_to_file=${save_to_file}
    Should Not Be Empty    ${records}    msg=No PCMD records present in ${pcap_filepath}
    [Return]    ${records}

Get Cell Traces from PCAP
    [Documentation]    Returns Cell Traces extracted from specified PCAP file as list.
    ...                - ``pcap_filepath``: Path to input PCAP file
    ...                - ``pattern``: Regexp pattern used to find Cell Traces, Default: ^nr-rrc$|^ngap$|^x2ap$|^xnap$
    ...                - ``filter``: tshark packet filter, Default: nsetapx
    ...                - ``tce_port``: Configured port number of Trace Controller Entity, Default: 49148
    ...                - ``save_to_file``: Optional path to output JSON file with traces, Default: None
    [Arguments]    ${pcap_filepath}    ${pattern}=^nr-rrc$|^ngap$|^x2ap$|^xnap$    ${filter}=nsetapx
    ...    ${tce_port}=49148    ${save_to_file}=${Empty}
    @{options}    Create List    -o    ntrstr.defragment:TRUE     -o    ntrstr.port:${tce_port}    -J    nsetapx
    Log To Console    Searching for Cell Traces in ${pcap_filepath}
    ${traces}    Get Items Matching Regexp From PCAP    pcap_filepath=${pcap_filepath}
    ...    pattern=${pattern}    filter=${filter}    options=${options}
    ...    search_for="nsetapx": {    replace_with="nsetapx_$": {    remove_per=yes
    ...    save_to_file=${save_to_file}
    Should Not Be Empty    ${traces}    msg=No Cell Traces present in ${pcap_filepath}
    [Return]    ${traces}

Get Message Field Values from PCAP
    [Documentation]    Returns a list of values for specified message field from optionally filtered PCAP file.
    ...                - ``pcap_filepath``: Path to input PCAP file
    ...                - ``field_name``: Message field name
    ...                - ``filter``: Optional tshark packet filter, Default: None
    ...                - ``options``: List of extra tshark parameters, Default: None
    ...                Example:
    ...                | $\{values\} | Get Message Field Values from PCAP | pcap_filepath=file.pcap |
    ...                |  | field_name=nsetapx.nodeType | filter=nsetapx.TraceMessage == 4 |
    [Arguments]    ${pcap_filepath}    ${field_name}    ${filter}=${Empty}    ${options}=@{Empty}
    File Should Exist    ${pcap_filepath}
    ${result}    Run Process And Expect Success    tshark    @{options}    -Y    ${filter}    -r    ${pcap_filepath}
    ...    -T    fields    -e    ${field_name}
    ${values}    Split To Lines    ${result.stdout}
    [Return]    ${values}

Get Items Matching Regexp From PCAP
    [Documentation]    Converts filtered PCAP file to JSON and returns a list of uppermost items matching regexp pattern.
    ...                In case of conversion to invalid JSON, string replacement operation can be performed.
    ...                - ``pcap_filepath``: Path to input PCAP file
    ...                - ``pattern``: Regexp pattern to match uppermost items
    ...                - ``filter``: Optional tshark packet filter, Default: None
    ...                - ``options``: List of extra tshark parameters, Default: None
    ...                - ``search_for``: Pattern of repeating items in invalid JSON, Default: None
    ...                - ``replace_with``: Pattern of replacement containing ``$`` in invalid JSON, Default: None
    ...                - ``remove_per``: If fields with Packet Encoding Rules should be removed, Default: no
    ...                - ``save_to_file``: Optional path to output JSON file with items, Default: None
    [Arguments]    ${pcap_filepath}    ${pattern}    ${filter}=${Empty}    ${options}=@{Empty}
    ...    ${search_for}=${Empty}    ${replace_with}=${Empty}    ${remove_per}=no    ${save_to_file}=${Empty}
    #--------- Param check -----------------------------------------------------------------------------------------
    File Should Exist    ${pcap_filepath}
    Should Be True    '${remove_per}' in ('yes','no')    msg=Invalid KW parameter: remove_per
    #---------------------------------------------------------------------------------------------------------------
    ${json_file}    Convert PCAP to JSON
    ...    input_filepath=${pcap_filepath}    filter=${filter}    options=${options}
    ${json_string}    Get File    ${json_file}
    ${json_string}    Run Keyword If    '${search_for}' != ''
    ...    replace_string_incrementally    ${json_string}    ${search_for}    ${replace_with}
    ...    ELSE    Set Variable    ${json_string}
    ${json_obj}    json.loads    ${json_string}
    ${items}    find_nodes_matching_regexp    ${json_obj}    ${pattern}
    ${items}    Run Keyword If    '${remove_per}' == 'yes'    remove_nodes_matching_regexp    ${items}    ^per\\..*
    ...         ELSE    Set Variable    ${items}
    Run Keyword Unless    '${save_to_file}' == ''    Save Data as JSON File    data=${items}    filepath=${save_to_file}
    [Return]    ${items}

Filter PCMD Records in Collection
    [Documentation]    Filter PCMD records collection based on field values. Used in case where initial filtering from
    ...                KW ``Get PCMD Records from PCAP`` is imperfect due to PCMD records clumping in single TCP packet.
    ...                Each PCMD record passes the filter if it contains at least one matching field/value pair.
    ...                Returns a new filtered collection.
    ...                - ``collected_records``: Output of KW ``Get PCMD Records from PCAP``
    ...                - ``save_to_file``: Optional path to output JSON file with records, Default: None
    ...                - ``fields``: Record field names with their expected values as regexp patterns
    ...                Example:
    ...                | $\{filtered_records\} | Filter PCMD Records in Collection | $\{records\} | nrci=00:00:04:00:30 |
    [Arguments]     ${collected_records}    ${save_to_file}=${Empty}    &{fields}
    ${new_collection}    Create List
    FOR    ${record}    IN    @{collected_records}
      ${saved_record}    Copy Dictionary    ${record}
      ${passed}    Check PCMD Record for Regexp Matches    ${record}    &{fields}
      Run Keyword If    ${passed}    Append To List    ${new_collection}    ${saved_record}
    END
    Run Keyword Unless    '${save_to_file}' == ''    Save Data as JSON File    data=${new_collection}    filepath=${save_to_file}
    [Return]    ${new_collection}

Check PCMD Record for Regexp Matches
    [Documentation]    Internal KW used in ``Filter PCMD Records in Collection``. Returns True if record contains
    ...                at least one matching regexp of field name and value.
    [Arguments]     ${record}    &{fields}
    ${flat_data}    flatten_obj    ${record}
    FOR    ${field}    IN    @{fields}
      ${ret}    find_node_matching_regexp    ${flat_data}    ${field}
      Return From Keyword If    not isinstance(${ret}, tuple)    ${false}
      ${passed}    Run Keyword And Return Status    Should Match Regexp    ${ret}[1]    ^${fields}[${field}]$    values=${False}
      Return From Keyword If    not ${passed}    ${false}
    END
    [Return]    ${true}
