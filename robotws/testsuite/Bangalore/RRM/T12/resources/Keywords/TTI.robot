*** Settings ***
Documentation     TTI keyword
Library          taf.collectors.l2stream3     WITH NAME    L2STREAM3
Library          taf.converters.eventdecoder  WITH NAME    EVENTDECODER
Library          ../../../../resources/python/streaming_ttitrace_analyzer.py    WITH NAME  TTITRACEANALYZER
Library          ../../../../resources/python/tti_convert.py                  WITH NAME    TtiConvert
Library          ../../../../resources/python/tti_stream_mode_convert.py      WITH NAME    TtiSMConvert


*** Keywords ***
Common Start Ttitrace With Streaming Mode_3 Custom
    [Arguments]    ${physical_cell_ids}=50    ${names}=l2stream3_ttitrace
    [Documentation]    This keyword is used to start ttitrace with streaming mode.
    ...    examples 1: catch 1 cell
    ...    Start Ttitrace With Streaming Mode
    ...    examples 2: catch 2 cells
    ...    Start Ttitrace With Streaming Mode    50,51
    ${executor}=    Create Dictionary    host=192.168.255.129    user=Nemuadmin    password=nemuuser    port=443
    ${nr_phy_cell_ids}=    Create List    ${physical_cell_ids}
    ${nr_phy_cell_ids}=    Evaluate    map(int, ${nr_phy_cell_ids})
    ${localIpAddr}=    Set Variable    10.0.1.2
    ${web_card}    ${dest_ip}=    Common Get EIF Info Of Control PC
    ${l2_stream_config_1}=    Create Dictionary    nr_phy_cell_ids=${nr_phy_cell_ids}
    @{l2_stream_configuration}=    Create List    ${l2_stream_config_1}

    TCPDUMP.Create Tcpdump Collector
    ...    name=tcpdump_ttitrace
    ...    options=-i ${web_card} udp and dst ${dest_ip} and dst port 5678
    ...    sudo_password=ute

    L2STREAM3.Create Sbts L2stream Collector
    ...    name=${names}
    ...    destination_ip_addr=${dest_ip}
    ...    collector=tcpdump_ttitrace
    ...    l2_stream_configuration=${l2_stream_configuration}
    ...    webservice=${executor}

    L2STREAM3.Set Suite Alias    alias=${names}
    CORE.Setup Collectors    names=${names}
    CORE.Start Collectors    names=${names}


Common Start Ttitrace With Streaming Mode_3
    [Arguments]    ${pysical_cell_ids}=50    ${names}=l2stream3_ttitrace
    [Documentation]    This keyword is used to start ttitrace with streaming mode.
    ...    examples 1: catch 1 cell
    ...    Start Ttitrace With Streaming Mode
    ...    examples 2: catch 2 cells
    ...    Start Ttitrace With Streaming Mode    50,51
    ${executor}=    Create Dictionary    host=192.168.255.129    user=Nemuadmin    password=nemuuser    port=443
    ${nr_phy_cell_ids}=    Common Get PhysCellId Of GNB Runtime    user_pci=${pysical_cell_ids}
    Log Many    ${pysical_cell_ids}    ${nr_phy_cell_ids}
    ${localIpAddr}=    Set Variable    10.0.1.2
    ${web_card}    ${dest_ip}=    Common Get EIF Info Of Control PC
    ${l2_stream_config_1}=    Create Dictionary    nr_phy_cell_ids=${nr_phy_cell_ids}
    @{l2_stream_configuration}=    Create List    ${l2_stream_config_1}

    TCPDUMP.Create Tcpdump Collector
    ...    name=tcpdump_ttitrace
    ...    options=-i ${web_card} udp and dst ${dest_ip} and dst port 5678
    ...    sudo_password=ute

    L2STREAM3.Create Sbts L2stream Collector
    ...    name=${names}
    ...    destination_ip_addr=${dest_ip}
    ...    collector=tcpdump_ttitrace
    ...    l2_stream_configuration=${l2_stream_configuration}
    ...    webservice=${executor}

    L2STREAM3.Set Suite Alias    alias=${names}
    CORE.Setup Collectors    names=${names}
    CORE.Start Collectors    names=${names}


Common Get PhysCellId Of GNB Runtime
    [Arguments]    ${user_pci}=${EMPTY}
    [Documentation]    This keyword is used to get physCellId from current SCF file.
    Common Backup Scf    ${OUTPUT_DIR}    ttitrace
    ${pci}=    Common Get Values From XML File By Class
    ...    ${OUTPUT_DIR}/SCF_ttitrace.xml
    ...    com.nokia.srbts.nrbts:NRCELL
    ...    physCellId
    ${x}=    Get Length    ${pci}
    ${pci}=    Set Variable If    ${x} <= 8    ${pci}    ${user_pci}
    ${pci}=    Evaluate    map(int, ${pci})
    Log To Console    pci=${pci}
    [Return]    ${pci}


Common Get Values From XML File By Class
    [Documentation]    This keyword is used to get parameter values from XML file.
    [Arguments]    ${file_path}    ${class}    ${para}
    ${xml}=    XML.Parse Xml    ${file_path}
    ${text}=    XML.Get Elements Texts
    ...    ${xml}
    ...    .//managedObject[@class="${class}"]/p[@name="${para}"]
    [Return]    ${text}


Common Get EIF Info Of Control PC
    ${ret}=    Run    ip addr
    ${eth0_ip}=    Get Regexp Matches    ${ret}    inet (?P<eth0>[0-9.]+).*?brd.*?eth0    eth0
    ${eth3_ip}=    Get Regexp Matches    ${ret}    inet (?P<eth3>[0-9.]+).*?brd.*?eth3    eth3
    ${eth0_ip}=    Set Variable    ${eth0_ip}[0]
    ${eth3_ip}=    Set Variable If    "${eth3_ip}" == "[]"    none    ${eth3_ip}[0]
    Log To Console    eth0_ip=${eth0_ip}, eth3_ip=${eth3_ip}
    ${web_card}=    Set Variable If    "${eth3_ip}" == "none"    eth0    eth3
    ${dest_ip}=    Set Variable If    "${web_card}" == "eth0"    ${eth0_ip}    ${eth3_ip}
    Log To Console    web_card=${web_card}, dest_ip=${dest_ip}
    [Return]    ${web_card}    ${dest_ip}


Common Backup Scf
    [Arguments]    ${log_dir}    ${scf_backup_name}
    [Documentation]    This keyword is to back up SCF file.
    Log To Console    Backup Scf...
    Run Keyword And Ignore Error    admin.Setup Admin    bts_host=192.168.255.129
    admin.Get Current Scf File
    ...    local_dir_path=${log_dir}
    ...    file_name=SCF_${scf_backup_name}.xml
    ...    timeout=120
    [Teardown]    Run Keyword And Ignore Error    admin.Teardown Admin


Stop Ttitrace Collection
    [Arguments]    ${log_path}=log_path    ${names}=l2stream3_ttitrace
    CORE.Stop Collectors    names=${names}
    CORE.Collect Collectors    names=${names}    target_dir=${log_path}
    CORE.Teardown Collectors    names=${names}
    ${pcap_file}=    Set Variable    ${log_path}/${names}/tcpdump_ttitrace/tcpdump_ttitrace.pcap


Common Convert Ttitrace From Pcap To Excelcsv
    ${TEST_NAME}=    Replace String    ${TEST_NAME}    ${SPACE}    _
    Set Suite Variable    ${TEST_NAME}
    [Arguments]    ${log_path}=${OUTPUT_DIR}    ${names}=l2stream3_ttitrace    ${filename}=tcpdump_ttitrace.pcap
    Log    ${names}
    ${file_path}=    Set Variable    ${log_path}/${filename}

    EVENTDECODER.Create Eventdecoder Converter
    ...    name=converter
    ...    input_file_path=${file_path}
    ...    output_file_format=excelCsv

    EVENTDECODER.Convert    name=converter
    Run    cp ${EXECDIR}/output_dl.csv ${log_path}; cp ${EXECDIR}/output_ul.csv ${log_path}


Common Format Tti In Stream Mode
    [Arguments]    ${input_csv_name}    ${output_csv_name}    ${filters}=${EMPTY}
    [Documentation]    This keyword is used to convert TTI collected in stream mode.
    Run Keyword If    '${filters}' == '${EMPTY}'
    ...    TtiSMConvert.Format Tti Stream Mode No Filters    ${input_csv_name}    ${output_csv_name}
    ...    ELSE
    ...    TtiSMConvert.Format Tti Stream Mode With Filters
    ...    ${input_csv_name}
    ...    ${output_csv_name}
    ...    ${filters}
