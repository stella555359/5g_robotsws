*** Settings ***
Documentation    Author: leo.y.wang@nokia-sbell.com
...              \n Please do not edit the existing keywords in this file without testing.
...              \n list of available keywords in CORE.
...              \n https://docs.taf.nsn-rdnet.net/taf.collectors.core/2.0.10/1/robot.collector_keywords/

Library     String
Library     Collections
Library     OperatingSystem
Library     Process
Library     taf.ul.parser.pcap    WITH NAME    PCAP
Library     taf.converters.eventdecoder    WITH NAME    EVENTDECODER
Library     ../../python/tak_gnb/tak_gnb/ttitrace.py     WITH NAME    GNB_TTI
Variables   ../../python/tak_log/log_directory.py

*** Variables ***
${TSHARK}            /usr/bin/tshark

*** Keywords ***
Get Field Value From BIP File By Xpath
    [Arguments]    ${pcap_file}    ${filter_expression}    ${xpath}
    ...    ${pdml_save_path}=${TEST_LOG_DIRECTORY()}
    [Documentation]    This keyword is to Get field value from BIP file by xpath
    ...    | Input Parameters | Man. | Description |
    ...    | ${pcap_file} | Y | pcap file |
    ...    | ${filter_expression} | Y | such as, x2ap.pLMN_Identity == 12:34:56 |
    ...    | ${xpath} | Y | such as, .//x2ap.GlobalGNB_ID_element/x2ap.pLMN_Identity |
    ...    | ${pdml_save_path} | N | pdml default save path, default TEST_LOG_DIRECTORY |
    ...    Examples:
    ...    | Get Field Value From BIP File By Xpath | tcpdumpL2L1_filtering_off.pcap |x2ap.pLMN_Identity == 12:34:56 |
    ...    .//x2ap.GlobalGNB_ID_element/x2ap.pLMN_Identity |
    @{f_name_list}    String.Split String From Right   ${pcap_file}    .    1
    @{f_names}    String.Split String From Right    ${f_name_list[0]}    /    1
    ${all_packs}=    PCAP.load_pcap_file    ${pcap_file}
    ...    command_template=${TSHARK} -r "${pcap_file}" -Y "${filter_expression}" -T pdml >${f_name_list[0]}.pdml
    File Should Not Be Empty     ${f_name_list[0]}.pdml
	run keyword and ignore error    OperatingSystem.run    cp ${f_name_list[0]}.pdml ${pdml_save_path}/${f_names[1]}_${f_name_list[1]}.pdml
    ${filtered_packs}=    PCAP.filter_packets_by_expression    ${all_packs}    ${filter_expression}
    ${value}=    PCAP.get_field_value_by_xpath    ${filtered_packs}    ${xpath}
    [Teardown]    PCAP.Teardown
    [Return]    ${value}

Get Field Value From BIP File By Name
    [Arguments]    ${pcap_file}    ${filter_expression}    ${field_name}
    ...    ${pdml_save_path}=${TEST_LOG_DIRECTORY()}
    [Documentation]    This keyword is to Get field value from BIP file by field name
    ...    | Input Parameters | Man. | Description |
    ...    | ${pcap_file} | Y | pcap file |
    ...    | ${filter_expression} | Y | such as, x2ap.pLMN_Identity == 12:34:56 |
    ...    | ${field_name} | Y | field name, such as, itf_l2_ps_peerctrl_ScellUeSchedulingReq.modifType.modifType_item_0 |
     ...    | ${pdml_save_path} | N | pdml default save path, default TEST_LOG_DIRECTORY |
    ...    Examples:
    ...    | Get Field Value From BIP File By Name | tcpdumpL2L1_filtering_off.pcap | itf_l2_ps_peerctrl_scellueschedulingreq |
    ...    itf_l2_ps_peerctrl_ScellUeSchedulingReq.modifType.modifType_item_0 |
    @{f_name_list}    String.Split String From Right    ${pcap_file}    .    1
    @{f_names}    String.Split String From Right    ${f_name_list[0]}    /    1
    ${all_packs}=    PCAP.load_pcap_file    ${pcap_file}
    ...    command_template=${TSHARK} -r "${pcap_file}" -Y "${filter_expression}" -T pdml >${f_name_list[0]}.pdml
    File Should Not Be Empty     ${f_name_list[0]}.pdml
	run keyword and ignore error    OperatingSystem.run    cp ${f_name_list[0]}.pdml ${pdml_save_path}/${f_names[1]}_${f_name_list[1]}.pdml
    ${filtered_packs}=    PCAP.filter_packets_by_expression    ${all_packs}    ${filter_expression}
    ${value}=    PCAP.get_field_value_by_name    ${filtered_packs}    ${field_name}
    [Teardown]    PCAP.Teardown
    [Return]    ${value}

Get Field Value From BIP Files By Xpath
    [Arguments]    ${pcap_file_patterns}    ${filter_expression}    ${xpath}
    ...    ${pdml_save_path}=${TEST_LOG_DIRECTORY()}
    [Documentation]    This keyword is to Get field value from BIP files by xpath
    ...    | Input Parameters | Man. | Description |
    ...    | ${pcap_file_patterns} | Y | pcap files patterns such as, /home/ute/tcpdumpL2L1_filtering_off.pcap* |
    ...    | ${filter_expression} | Y | such as, x2ap.pLMN_Identity == 12:34:56 |
    ...    | ${xpath} | Y | such as, .//x2ap.GlobalGNB_ID_element/x2ap.pLMN_Identity |
    ...    | ${pdml_save_path} | N | pdml default save path, default TEST_LOG_DIRECTORY |
    ...    Examples:
    ...    | Get Field Value From BIP Files By Xpath | ./tcpdumpL2L1_filtering_off.pcap* |x2ap.pLMN_Identity == 12:34:56 |
    ...    .//x2ap.GlobalGNB_ID_element/x2ap.pLMN_Identity |
    ${files}=    OperatingSystem.run    ls ${pcap_file_patterns}
    @{f_path_list}=    String.Split String    ${files}
    ${all_values}=    Create List    ${EMPTY}
    FOR    ${pcap_file}    IN    @{f_path_list}
        log    parse file ${pcap_file}
        ${field_values}    Get Field Value From BIP File By Xpath    ${pcap_file}    ${filter_expression}    ${xpath}
    ...    ${pdml_save_path}
        ${all_values}      Collections.Combine Lists    ${all_values}    ${field_values}
    END
    ${length}=    Get Length    ${all_values}
    ${values}=    Set Variable If    '${length}'=='1'    ${all_values}    ${all_values}[1:]
    [Return]    ${values}

Get Field Value From BIP Files By Name
    [Arguments]    ${pcap_file_patterns}    ${filter_expression}    ${field_name}
    ...    ${pdml_save_path}=${TEST_LOG_DIRECTORY()}
    [Documentation]    This keyword is to Get field value from BIP files by field name
    ...    | Input Parameters | Man. | Description |
    ...    | ${pcap_file_patterns} | Y | pcap files patterns such as, /home/ute/tcpdumpL2L1_filtering_off.pcap* |
    ...    | ${filter_expression} | Y | such as, x2ap.pLMN_Identity == 12:34:56 |
    ...    | ${field_name} | Y | field name, such as, itf_l2_ps_peerctrl_ScellUeSchedulingReq.modifType.modifType_item_0 |
    ...    | ${pdml_save_path} | N | pdml default save path, default TEST_LOG_DIRECTORY |
    ...    Examples:
    ...    | Get Field Value From BIP Files By Name | ./tcpdumpL2L1_filtering_off.pcap* | itf_l2_ps_peerctrl_scellueschedulingreq |
    ...    itf_l2_ps_peerctrl_ScellUeSchedulingReq.modifType.modifType_item_0 |
    ${files}=    OperatingSystem.run    ls ${pcap_file_patterns}
    @{f_path_list}=    String.Split String    ${files}
    ${all_values}=    Create List    ${EMPTY}
    FOR    ${pcap_file}    IN    @{f_path_list}
        log    parse file ${pcap_file}
        ${field_values}    Get Field Value From BIP File By Name    ${pcap_file}    ${filter_expression}    ${field_name}
    ...    ${pdml_save_path}
        ${all_values}      Collections.Combine Lists    ${all_values}    ${field_values}
    END
    ${length}=    Get Length    ${all_values}
    ${values}=    Set Variable If    '${length}'=='1'    ${all_values}    ${all_values}[1:]
    [Return]    ${values}

Convert BIP To CSV
    [Documentation]    This keyword use tshark to convert wireshark log to csv
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${bip_file} | Yes | the source pcap log path |
    ...    | ${output_file} | Yes | the target csv path |
    ...    | ${filter} | Yes | the filter should be green on wireshark gui |
    ...    | ${csv_title_list} | Yes | use wireshark find target item, right click 'copy' and then 'Field Name' |
    ...
    ...    Examples:
	...    |  ${titles}   |  create list  |   3gpp.sfns  |  3gpp.slot |
    ...    | Convert BIP To CSV | ${CURDIR}/tcpdump.pacp | ${CURDIR}/tcpdump.csv |  
	...    | dldata_ssblocksendreq||dldata_pdschsendreq||dldata_csirssendreq    |  ${titles}  |
    ...
    [Arguments]    ${bip_file}    ${output_file}    ${filter}    ${csv_title_list}
    ${csv_title}=    Set Variable
    FOR    ${column}   IN    @{csv_title_list}
        ${csv_title}=    Set Variable    ${csv_title} -e ${column}
    END
    ${cmd}=    Catenate    tshark -r ${bip_file} -Y '${filter}' -T fields -e _ws.col.No. -e _ws.col.Info
    ...    ${csv_title} -E header=y -E separator=, -E quote=d -E occurrence=a > ${output_file}
    ${ret}    Process.Run Process     ${cmd}	   shell=True    stderr=STDOUT    stdout=STDOUT
    run keyword if      ${ret.rc}!=0     fail      ${ret.stderr}

Decoder Tttirace From Pcap To Csv
    [Arguments]    ${pcap_path}      ${output_path_with_tag}       ${decode_format}=excelCsv
    [Documentation]    This keyword will decode pcap file to csv.
    ...    | Input Parameters          | Man. | Description |
    ...    | ${pcap_path}              | Yes  | pcap file path. |
    ...    | ${output_path_with_tag}   | Yes  | Decode output file save path. |
    ...    | ${output_file_format}     |  No  | output file format can be "json", "legacyCsv" or "excelCsv", default is "excelCsv" |
    ...   Example:
    ...    | Start GNB Ttitrace With Streaming Mode | | |
    ...    | some action | | |
    ...    | ${pacp}=  |  Stop GNB Ttitrace With Streaming Mode  |  save_path=${TEST_LOG_DIRECTORY()} |
    ...    | Download Ttitrace Decode Tool  | | |
    ...    | Decoder Tttirace From Pcap To Csv  | pcap_path=${pacp} | output_path_with_tag=${TEST_LOG_DIRECTORY()}nsa_tti |
    EVENTDECODER.Create Eventdecoder Converter    name=converter    input_file_path=${pcap_path}    output_file_format=${decode_format}    
    ...    output_file_path=${output_path_with_tag}    excel_csv_options=-w
    EVENTDECODER.Convert    name=converter
    GNB_TTI.Is Csv File Generated     ${output_path_with_tag}
    ${path}    ${tag}    Split Path    ${output_path_with_tag}
    #GNB_TTI.Decode Ttitrace File    ${pcap_path}    ${output_path_with_tag}    ${output_file_format}    ${excel_csv_options}    ${conversion_filter}
    [Return]    ${path}
