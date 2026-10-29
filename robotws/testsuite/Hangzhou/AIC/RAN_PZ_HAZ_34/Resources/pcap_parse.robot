*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   pcap_parse.robot



*** Variables ***



*** Keywords ***
Load Pcap File
    [Arguments]   ${log_file_path}   ${display_filter}=${None}   ${extension}=${None}   ${override_preference_setting}=${None}
    ...           ${disable_all_name_resolutions}=${None}   ${flush_standard_output}=${None}
    ...           ${tshark_path}=${None}    ${alias}=${None}
    [Documentation]  Setup pcap_parser with tshark command options
    ...    *Author:* lingting.sun@nokia-sbell.com
    ...    *Change History*
    ...    | date | who | waht or how |
    ...    | 2022-3-03 | lingtsun | init create |
    ...    *Arguments Description*
    ...    | Input Parameters | Man. | Description |
    ...    | log_file_path | Yes | str, tcpdump file path |
    ...    | display filter | No | str, packet display filter in wireshark, e.g f1ap |
    ...    | extension | No | str, extension options, e.g "lua_script:generated_luashark/luashark.lua" |
    ...    | override_preference_setting | No | dict, override preference setting, e.g {“esp.enable_encryption_decode”: true}|
    ...    | disable_all_name_resolutions | No | bool, disable all name resolutions, default is True |
    ...    | flush_standard_output | No | bool, flush standard output after each packetd, default is True |
    ...    | tshark_path | No | str, specified tshark path |
    ...    | alias | No | str, pcap parser alias name |
    ...    *Example*
    ...    | Load Pcap File| log_file_path=/home/ute/SLT/pcap/F1_160.pcap | display_filter=f1ap |
    ...    *Return*
    ...    - instance, pcap_parser
    ${pcap_parser}   pcap.setup
    ...              infile=${log_file_path}
    ...              display_filter=${display_filter}
    ...              extension=${extension}
    ...              override_preference_setting=${override_preference_setting}
    ...              disable_all_name_resolutions=${disable_all_name_resolutions}
    ...              flush_standard_output=${flush_standard_output}
    ...              tshark_path=${tshark_path}
    ...              alias=${alias}
    [return]   ${pcap_parser}



Get Field Value By XPath
    [Arguments]   ${xpath}   ${attribute_name}=show   ${pcap_parser}=${None}
    [Documentation]  Return attribute values for the specified field xpath
    ...    *Author:* lingting.sun@nokia-sbell.com
    ...    *Change History*
    ...    | date | who | waht or how |
    ...    | 2022-3-03 | lingtsun | init create |
    ...    *Arguments Description*
    ...    | Input Parameters | Man. | Description |
    ...    | xpath | Yes | str, field xpath in a packet |
    ...    | attribute_name | No | str, return value format, default is “show” e.g “show”, “value” and “showname” |
    ...    | pcap_parser | No | str, pcap parser alias name |
    ...    *Example*
    ...    | ${pcap_parser} | Load Pcap File| log_file_path=/home/ute/SLT/pcap/F1_160.pcap | display_filter=f1ap |
    ...    | ${field_value_list} |  Get Field Value By XPath | xpath=.//x2ap.GlobalGNB_ID_element/x2ap.pLMN_Identity
    ...    | attribute_name=showname | pcap_parser=${pcap_parser} |
    ...    *Return*
    ...    - field value list of filtered packets
    ${field_value_list}   pcap.get_field_value_by_xpath
    ...   xpath=${xpath}   attribute_name=${attribute_name}   pcap_parser=${pcap_parser}
    [return]   ${field_value_list}


Filter Packets By Expression
    [Arguments]   ${filter_expression}   ${pcap_parser}=${None}
    [Documentation]  Get filtered packet instances
    ...    *Author:* lingting.sun@nokia-sbell.com
    ...    *Change History*
    ...    | date | who | waht or how |
    ...    | 2022-3-03 | lingtsun | init create |
    ...    *Arguments Description*
    ...    | Input Parameters | Man. | Description |
    ...    | filter_expression | Yes | str, Wireshark filter expression |
    ...    | pcap_parser | No | str, pcap parser alias name |
    ...    *Example*
    ...    | ${pcap_parser} | Load Pcap File| log_file_path=/home/ute/SLT/pcap/F1_160.pcap | display_filter=f1ap |
    ...    | ${filtered_pkts} |  Filter Packets By Expression | filter_expression=f1ap.procedureCode == 5|
    ...    pcap_parser=${pcap_parser}|
    ...    *Return*
    ...    - filter packet instance list
    ${filtered_pkts}  pcap.get packets
    ...    filter=${filter_expression}   pcap_parser=${pcap_parser}
    [return]   ${filtered_pkts}
