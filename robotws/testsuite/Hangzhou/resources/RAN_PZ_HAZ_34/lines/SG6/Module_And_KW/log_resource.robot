*** Settings ***
Library           ../../../../../resources/RAN_PZ_HAZ_1/Module/library/log_worker/common/tti_analysis.py    WITH NAME    module_tti
Library     taf.converters.eventdecoder    WITH NAME    EVENTDECODER
Library     taf.collectors.l2stream3    WITH NAME    L2STREAM3
Library           python/csv_analysis.py    WITH NAME    csv_analysis

Library   XML   use_lxml=True
Documentation    Author: winnie
...              Contact: winnie@nokia-sbell.com

*** Variables ***
&{dcap_info}    host=127.0.0.1    port=9443    username=${None}    password=${None}
&{team_dcap_info}    host=10.56.218.4    port=443    username=utfuser    password=utfadmin!
*** Keywords ***
Start Capture Emil Log By VM dcap
    [Arguments]    ${bts_index}=${0}    ${product_type}=gnb
    Run Keyword And Ignore Error    start_dcap_controller_common
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start    emil
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    ...    dict_argument=${dict_argument}

Stop Emil Log Collection
    [Arguments]    ${bts_index}=${0}    ${product_type}=gnb
    ${local_file_path}    Log Collection    stop_and_download    emil
    ...    product_type=${product_type}
    ...    bts_index=${bts_index}
    Log To Console    \nTTI log: ${local_file_path}
    [Return]    ${local_file_path}

Analysis Emil Log
    [Arguments]    ${local_file_path}    ${filter}
    ${result_paths}=    Log Analysis   check   emil   ${local_file_path}   filter_emil=${filter}    convert_type=csv
    Log To Console    \nAnalyze log: ${result_paths}
    # ${context_dicts}    Create Dictionary
    # FOR    ${result}    IN    @{result_paths}
    #     ${context}    OperatingSystem.Get File    ${result}
    #     &{context_dict}    json.Loads    ${context}
    #     FOR    ${k}    ${v}    IN    &{context_dict}
    #         Set To Dictionary    ${context_dicts}    ${k}=${v}
    #     END
    # END
    # [Return]    ${context_dicts}

Start Capture Tti Log By VM dcap
    [Arguments]    ${bts_index}=${0}    ${cell_index}=${None}
    Run Keyword And Ignore Error    start_dcap_controller_common
    ${nrcell_lst}    Create List
    ${cell_index_list}    Split String    ${cell_index}    ,
    FOR    ${cell_id}    IN    @{cell_index_list}
        Append To List    ${nrcell_lst}    NRCELL_R-${cell_id}
    END
    ${tti_argument}   Run Keyword If    '${cell_index}'!='${None}'
    ...    Create Dictionary   nrCells=${nrcell_lst}
    ${dict_argument}   Run Keyword If    '${cell_index}'!='${None}'
    ...    Create Dictionary   dcap_server=${dcap_info}
    ...    argument=${tti_argument}
    ...    ELSE
    ...    Create Dictionary   dcap_server=${dcap_info}
    ${result}    Log Collection    start    tti+bip
    ...    product_type=gnb
    ...    bts_index=${bts_index}
    ...    dict_argument=${dict_argument}
    Set Suite Variable    ${trace_id}    ${result}

Stop Tti Log Collection
    [Arguments]    ${bts_index}=${0}
    ${local_file_path}    Log Collection    stop_and_download    tti
    ...    product_type=gnb
    ...    bts_index=${bts_index}
    Log To Console    \nTTI log: ${local_file_path}
    ${all_tti_csv_logs}    module_tti.convert_tti
#    ...    vdu_version=${ACTIVE_SW_VERSION}
    ...    tti_trace_dir=${TEST_LOG_DIRECTORY}    tti_archive=${local_file_path}
    ...    is_combine_dl_ul=${False}
#    ...    product_type=gnb
    [Return]    ${all_tti_csv_logs}

Parse Pcap To Get The Lcid
    [Arguments]    ${input_file}=${capture_file_path}    ${filter}='nr-rrc.drb_Identity == 4'
    ...            ${xpath_drb_Identity}=4
    [Documentation]    this kw is used to  analysis pcap with xpath
    ...    Author: He winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  input_file| the path of capurtured log |
    ...    |  filter | the output can add filter to aviod too large |
    ...    |  filter_expression | filter expression  |
    ...    |  xpath | the path of x2ap |

    ...
    ...    | Return Value | value_list| return value list |
    ...
    ...    Example
    ...    | ${lcid_list}   Parse Pcap To Get The Lcid |
    ...
    ${command_template}    set variable    {tshark_path} -r {input_file} -Y ${filter} -T pdml > {output_file}
    ${all_packets}=    wireshark.load_pcap_file    pcap_file=${input_file}    tshark_path=${tshark_path}
    ...    command_template=${command_template}
    ${xml_path}    Replace String    ${input_file}     .pcap    .pdml
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${values}    L_XML.get_element_all_attributes    source_xml=${xml_path}
    ...    element_xpath=//field[@name="nr-rrc.drb_Identity" and @show="${xpath_drb_Identity}"]/../../*[@name="nr-rrc.logicalChannelIdentity"]
    ...    attrib_name=show
    Should Not Be Empty    ${values}
    ${values}    Evaluate    list(set(${values}))
    ${value_list}    Create List
    FOR    ${value}    IN    @{values}
        ${tmp}    Convert To Integer    ${value}    16
        Append to list    ${value_list}    ${tmp}
    END
    [Return]    ${value_list}[0]


Start Capture Default Log By VM dcap
    [Arguments]    ${nrcell_list}    ${bts_index}=${0}
    ${profile_argument}     Create Dictionary    gnb_trace_profile=Default tracing profile
    ...    bts_trace_profile=Default tracing profile
    ${dcap_argument}   Create Dictionary    nrCells=${nrcell_list}
    ${dict_argument}   Create Dictionary   dcap_server=${team_dcap_info}
    ...    argument=${dcap_argument}
    ...    profile_argument=${profile_argument}
    Log Collection    start    collection_profile
    ...    product_type=gnb
    ...    bts_index=${bts_index}
    ...    dict_argument=${dict_argument}

Stop Capture Default Log By VM dcap
    [Arguments]    ${bts_index}=${0}
    ${local_file_path}    Log Collection    stop_and_download    collection_profile
    ...    product_type=gnb
    ...    bts_index=${bts_index}

######## capture tti by taf L2STREAM3

_Get All PhysCellId In GNB
    [Arguments]    ${scfc}
    [Documentation]    This keyword to get all physcellid in gnb.
    ...    Examples:
    ...    | ${RF_TYPE}= | Get PhysCellId Of GNB |   |
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${xml}=    L_XML.Parse Xml    ${scfc}
    ${phycellids}=   L_XML.Get Elements Texts    ${xml}    .//managedObject[@class\="com.nokia.srbts.nrbts:NRCELL"]/p[@name\="physCellId"]
    Log    all phycellid:${phycellids}
    [Return]    ${phycellids}

_Get PhysCellId In GNB By LcrdId
    [Arguments]    ${scfc}    ${lcr_ids}
    @{lcr_id_list}    Split String    ${lcr_ids}    ,
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
	${xml}=    L_XML.Parse Xml    ${scfc}
    @{phycellids}=    Create List
    FOR    ${lcr_id}    IN    @{lcr_id_list}
        ${phycellid}=   L_XML.Evaluate Xpath    ${xml}
	...    string(.//managedObject[(@class\='com.nokia.srbts.nrbts:NRCELL') and (contains(@distName, "NRCELL-${lcr_id}"))]/p[@name="physCellId"])
        Append To List     ${phycellids}     ${phycellid}
    END
    Log    all phycellid:@{phycellids}
    [Return]    @{phycellids}

_Get localIpAddr Of GNB
    [Arguments]    ${scfc}
    ${str}=    OperatingSystem.Get File    ${scfc}
    ${localIpAddr}=    String.Get Regexp Matches    ${str}    <p name=\"localIpAddr\">(?P<localIpAddr>.*?)</p>    localIpAddr
    Log     localIpAddr=${localIpAddr}
    [Return]    ${localIpAddr}[0]

_Get EIF Info From Control PC
    ${ret}=    Run    ip addr
    ${eth0_ip}=    String.Get Regexp Matches    ${ret}    inet (?P<eth0>[0-9]*.[0-9]*.[0-9]*.[0-9]*).*?brd.*?eth0    eth0
    ${eth3_ip}=    String.Get Regexp Matches    ${ret}    inet (?P<eth3>[0-9]*.[0-9]*.[0-9]*.[0-9]*).*?brd.*?eth3    eth3
    ${eth0_ip}=    Set Variable    ${eth0_ip}[0]
    ${eth3_ip}=    Set Variable If    "${eth3_ip}"=="[]"    none    ${eth3_ip}[0]
    Log    eth0_ip=${eth0_ip},eth3_ip=${eth3_ip}
    ${web_card}=    Set Variable If    "${eth3_ip}"=="none"    eth0    eth3
    ${dest_ip}=    Set Variable If    "${web_card}"=="eth0"    ${eth0_ip}    ${eth3_ip}
    Log    web_card=${web_card},dest_ip=${dest_ip}
    [Return]    ${web_card}    ${dest_ip}

Start GNB Ttitrace With Streaming Mode
    [Arguments]     ${bts_index}=${0}    ${lcr_cell_id}=All    ${up_sw}=L2Ps     ${name}=l2stream3
    [Documentation]    This keyword will collect gnb ttitrace log.
    ...    | Input Parameters | Man. | Description |
    ...    | ${lcr_cell_id} | No | lcr cell id, it can be like 1 or 1,2 or ALL. The default value is ALL. |
    ...    | ${up_sw}       | No | option for capture. Default value is "L2Ps". It can be "L2Ps", "L2Lo", "L2iPdcp", "L2HiRlc"  |
    ...    | ${name}        | No | It can be the same as alias. The default value is l2stream3 |
    ...    Examples(BTS should be Onair and UE attach and data transfer is started. ):
    ...    | Start GNB Ttitrace With Streaming Mode | lcr_cell_id=1,2  | name=myttitrace |
    ...    | ${pacp}=  |  Stop GNB Ttitrace With Streaming Mode  |  save_path=${TEST_LOG_DIRECTORY} | name=myttitrace |
    ...    or
    ...    | Start GNB Ttitrace With Streaming Mode | | |
    ...    | ${pacp}=  |  Stop GNB Ttitrace With Streaming Mode  |  save_path=${TEST_LOG_DIRECTORY} |
    ...    | Download Ttitrace Decode Tool  | | |
    ...    | Decoder Tttirace From Pcap To Csv  | pcap_path=${pacp} | output_path_with_tag=${TEST_LOG_DIRECTORY}nsa_tti |
    @{sw_list}    String.Split String    ${ACTIVE_SW_VERSION}    _
	&{asik_vm}=         Create Dictionary
	...    host=${BTS${bts_index}_INFO.IP}
	...    user=Nemuadmin
	...    password=nemuuser
	...    port=443
	...    release=${sw_list[0]}
	${scfc_on_gnb_now}=    COAM_Admin.BackupSCF     ${TEST_LOG_DIRECTORY}      scfc_for_tti.xml    connection=COAM_${bts_index}
	${lcr_cell_id}=     String.Convert To Upper Case       ${lcr_cell_id}
	${nr_phy_cell_ids}=    Run Keyword If     '${lcr_cell_id}'=='ALL'    _Get All PhysCellId In GNB    ${scfc_on_gnb_now}
	...    ELSE    _Get PhysCellId In GNB By LcrdId    ${scfc_on_gnb_now}    ${lcr_cell_id}
	${local_ip_addr}=    _Get localIpAddr Of GNB      ${scfc_on_gnb_now}
	${eth_port}    ${eth_ip}=      _Get EIF Info From Control PC
    ${l2_stream_config_1}=    Create Dictionary       nr_phy_cell_ids=${nr_phy_cell_ids}     up_sw=${up_sw}
    @{l2_stream_configuration}=    Create List    ${l2_stream_config_1}
	tcpdump.Create Tcpdump Collector
	...  name=tcpdump
	...  options=-i ${eth_port} udp and dst ${eth_ip} and dst port 5678
	...  sudo_password=ute
	L2STREAM3.Create Sbts L2stream Collector
	...  name=${name}
	...  destination_ip_addr=${eth_ip}
	...  collector=tcpdump
	...  l2_stream_configuration=${l2_stream_configuration}
	...  webservice=${asik_vm}
    ...  dscp=15
    L2STREAM3.Set Suite Alias    alias=${name}
    CORE.setup_collectors    names=${name}
    CORE.start_collectors    names=${name}
    [Teardown]    Run Keyword And Ignore Error    Run    rm ${scfc_on_gnb_now}

Stop GNB Ttitrace With Streaming Mode
    [Arguments]    ${save_path}=${TEST_LOG_DIRECTORY}    ${name}=l2stream3
    [Documentation]    This keyword will stop collect gnb ttitrace log.
    ...    | Input Parameters | Man. | Description |
    ...    | ${save_path}   | No | ttitrace save path. The default value is ${TEST_LOG_DIRECTORY()}. |
    ...    | ${name}        | No | It should be the same as it set in 'Start GNB Ttitrace With Streaming Mode'. The default value is l2stream3 |
    ...    Example:
    ...    | Start GNB Ttitrace With Streaming Mode | | |
    ...    | some action | | |
    ...    | ${pacp}=  |  Stop GNB Ttitrace With Streaming Mode  |  save_path=${TEST_LOG_DIRECTORY()} |
    ...    | Download Ttitrace Decode Tool  | | |
    ...    | Decoder Tttirace From Pcap To Csv  | pcap_path=${pacp} | output_path_with_tag=${TEST_LOG_DIRECTORY()}nsa_tti |
    CORE.stop_collectors    names=${name}
    CORE.collect_collectors    names=${name}     target_dir=${save_path}
    CORE.teardown_collectors    names=${name}
	[Return]    ${save_path}/${name}/tcpdump/tcpdump.pcap


_Download Ttitrace Decode Tool From WFT
    #${base_url}    Set Variable    https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build
    ${base_url}    Set Variable    https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/
    ${release}    Get Release By Sw Version    ${ACTIVE_SW_VERSION}
    ${fixed_active_sw_version}    Fix SBTS Trunk Sw Version    sw=${ACTIVE_SW_VERSION}
    OperatingSystem.Run
    ...    wget -P ${TEST_LOG_DIRECTORY} -q "${base_url}/${release}/${fixed_active_sw_version}/${fixed_active_sw_version}_tti-dec.deb"
    [Return]    ${TEST_LOG_DIRECTORY}/${fixed_active_sw_version}_tti-dec.deb

_Prepare Ttitrace Decode Tool
    ${fixed_active_sw_version}    Fix SBTS Trunk Sw Version    sw=${ACTIVE_SW_VERSION}
    ${decode_tool}    Set Variable    ${TEST_LOG_DIRECTORY}/${fixed_active_sw_version}_tti-dec.deb
    ${ret}    Run Keyword And Return Status    File Should Exist    ${decode_tool}
    Run Keyword If    '${ret}'=='False'    _Download Ttitrace Decode Tool From WFT
    OperatingSystem.File Should Exist    ${decode_tool}
    ${rc}     ${output}=     OperatingSystem.Run and Return RC and Output     sudo dpkg -i ${decode_tool}
    Run Keyword If        '${rc}'!= '0'       Log      ${output}      	WARN

Decoder Tttirace From Pcap To Csv
    [Arguments]    ${pcap_path}      ${output_path_with_tag}       ${decode_format}=excelCsv
    [Documentation]    This keyword will decode pcap file to csv.
    ...    | Input Parameters          | Man. | Description |
    ...    | ${pcap_path}              | Yes  | pcap file path. |
    ...    | ${output_path_with_tag}   | Yes  | Decode output file save path. |
    ...    | ${output_file_format}     |  No  | output file format can be "json", "legacyCsv" or "excelCsv", default is "excelCsv" |
    ...   Example:
    ...    | Download Ttitrace Decode Tool  | | |
    ...    | Decoder Tttirace From Pcap To Csv  | pcap_path=${pacp} | output_path_with_tag=${TEST_LOG_DIRECTORY()}nsa_tti |
    _Prepare Ttitrace Decode Tool
    EVENTDECODER.Create Eventdecoder Converter    name=converter    input_file_path=${pcap_path}    output_file_format=${decode_format}
    ...    output_file_path=${output_path_with_tag}    excel_csv_options=-w
    EVENTDECODER.Convert    name=converter

