*** Settings ***
Documentation     TTI keyword
Library          taf.converters.eventdecoder  WITH NAME  EVENTDECODER
Library          ../python/streaming_ttitrace_analyzer.py    WITH NAME    TTITRACEANALYZER
Library          ../python/tti_convert.py    WITH NAME    TtiConvert
Library          ../python/tti_stream_mode_convert.py    WITH NAME    TtiSMConvert

*** Keywords ***
Common Start Ttitrace With Streaming Mode_3
    [Arguments]    ${pysical_cell_ids}=50    ${names}=l2stream3_ttitrace
    [Documentation]    This keyword is used to start ttitrace with streaming mode.
    ...    examples 1: catch 1 cell
    ...    Start Ttitrace With Streaming Mode
    ...    examples 2: catch 2 cells
    ...    Start Ttitrace With Streaming Mode    50,51
    Log To Console   ${pysical_cell_ids}
    ${executor}=  Create Dictionary
    ...  host=192.168.255.129
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    ${nr_phy_cell_ids}=    Common Get PhysCellId Of GNB Runtime
#    ${localIpAddr}=    Get localIpAddr Of GNB
#10.0.1.2 for ute
    ${localIpAddr}=    set variable    10.0.1.2
#    ${web_card}    ${dest_ip}=    Get EIF Info Of Control PC
    ${web_card}    ${dest_ip}=    Common Get EIF Info Of Control PC
    ${l2_stream_config_1}=  Create Dictionary
    ...  nr_phy_cell_ids=${nr_phy_cell_ids}
    @{l2_stream_configuration}=  Create List  ${l2_stream_config_1}
    TCPDUMP.create tcpdump collector
    ...  name=tcpdump_ttitrace
    ...  options=-i ${web_card} udp and dst ${dest_ip} and dst port 5678
    ...  sudo_password=ute
    L2STREAM3.Create Sbts L2stream Collector
    ...  name=${names}
    ...  destination_ip_addr=${dest_ip}
    ...  collector=tcpdump_ttitrace
    ...  l2_stream_configuration=${l2_stream_configuration}
    ...  webservice=${executor}
    L2STREAM3.Set Suite Alias
    ...  alias=${names}
    CORE.setup_collectors
    ...  names=${names}
    CORE.start_collectors
    ...  names=${names}

Common Get PhysCellId Of GNB Runtime
    [Arguments]    ${scfc_file}=${OUTPUT_DIR}/SCF_before_suite.xml
    Log To Console   ${scfc_file}
    [Documentation]    This keyword to get radio protocol type from current scfc file
    ...    Examples:
    ...    | ${RF_TYPE}= | Get PhysCellId Of GNB | /tmp/SCF.xml |
    Common Backup Scf    ${OUTPUT_DIR}    ttitrace
    ${pci}=    Common Get Values From XML File By Class    ${OUTPUT_DIR}/SCF_ttitrace.xml    com.nokia.srbts.nrbts:NRCELL    physCellId
    ${pci}=    Evaluate  map(int, $pci)
    Log To Console    pci=${pci}
    [Return]    ${pci}

Common Get Values From XML File By Class
    [Documentation]    this keyword is used to get para from XML file
    ...    for example:
    ...    distName=com.nokia.srbts.nrbts:NRCELL
    ...    para=actCDrx
    [Arguments]    ${file_path}    ${class}    ${para}
    ${xml}=    XML.Parse Xml    ${file_path}
    ${text}=   XML.Get Elements Texts    ${xml}    .//managedObject[@class\="${class}"]/p[@name\="${para}"]
    [Return]    ${text}

Common Get EIF Info Of Control PC
    ${ret}=    Run    ip addr
    ${eth0_ip}=    get_regexp_matches    ${ret}    inet (?P<eth0>[0-9]*.[0-9]*.[0-9]*.[0-9]*).*?brd.*?eth0    eth0
    ${eth3_ip}=    get_regexp_matches    ${ret}    inet (?P<eth3>[0-9]*.[0-9]*.[0-9]*.[0-9]*).*?brd.*?eth3    eth3
    ${eth0_ip}=    Set Variable    ${eth0_ip}[0]
    ${eth3_ip}=    Set Variable If    "${eth3_ip}"=="[]"    none    ${eth3_ip}[0]
    Log To Console    eth0_ip=${eth0_ip},eth3_ip=${eth3_ip}
    ${web_card}=    Set Variable If    "${eth3_ip}"=="none"    eth0    eth3
    ${dest_ip}=    Set Variable If    "${web_card}"=="eth0"    ${eth0_ip}    ${eth3_ip}
    Log To Console    web_card=${web_card},dest_ip=${dest_ip}
    [Return]    ${web_card}    ${dest_ip}

Common Backup Scf
    [Arguments]    ${log_dir}    ${scf_backup_name}
    [Documentation]    This keyword is to back up SCF file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | Yes | the folder directory to store the scf file |
    ...    | ${scf_backup_name} | Yes | the saved SCF file name. it like SCF_${scf_backup_name}.xml |
    ...
    ...    Examples:
    ...    | Backup Scf | ${SUITE_LOG_DIRECTORY} | before_suite |
    ...    | Backup Scf | ${TEST_LOG_DIRECTORY} | after_suite |
    Log To Console    Backup Scf...
    Run Keyword And Ignore Error    coam.Setup Admin    bts_host=192.168.255.129
    coam.Get Current Scf File    local_dir_path=${log_dir}    file_name=SCF_${scf_backup_name}.xml   timeout=20
    [Teardown]    Run Keyword And Ignore Error    coam.Teardown Admin

Stop ttitrace Collection
    [Arguments]    ${log_path}=${OUTPUT_DIR}        ${names}=l2stream3_ttitrace
    CORE.stop_collectors
    ...  names=${names}
    CORE.collect_collectors
    ...  names=${names}
    CORE.teardown_collectors
    ...  names=${names}
    ${pcap_file}=    Set Variable    ${OUTPUTDIR}/${SUITE_NAME}/${TEST_NAME}/${names}/tcpdump_ttitrace/tcpdump_ttitrace.pcap
    OperatingSystem.Run    mkdir -p ${log_path}; cp -r "${pcap_file}" ${log_path}

Common Convert Ttitrace From Pcap To Excelcsv
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    set suite variable     ${TEST_NAME}
    [Arguments]    ${log_path}=${OUTPUT_DIR}    ${names}=l2stream3_ttitrace    ${filename}=tcpdump_ttitrace.pcap
    Log To Console  ${names}
    ${file_path}=    Set Variable    ${log_path}/${filename}
    EVENTDECODER.Create Eventdecoder Converter
    ...  name=converter
    ...  input_file_path=${file_path}
    ...  output_file_format=excelCsv
    EVENTDECODER.Convert
    ...  name=converter
    OperatingSystem.Run    cp ${EXECDIR}/output_dl.csv ${log_path};cp ${EXECDIR}/output_ul.csv ${log_path}

Common Format Tti In Stream Mode
    [Arguments]    ${input_csv_name}    ${output_csv_name}    ${filters}=${EMPTY}
    [Documentation]    This keyword is to convert tti collected by stream mode.
    ...    Parameters same as keyword: Format Tti In Snapshot Mode
    Run Keyword If    '${filters}'=='${EMPTY}'    TtiSMConvert.Format Tti Stream Mode No Filters    ${input_csv_name}    ${output_csv_name}
    ...    ELSE    TtiSMConvert.Format Tti Stream Mode With Filters    ${input_csv_name}    ${output_csv_name}    ${filters}
