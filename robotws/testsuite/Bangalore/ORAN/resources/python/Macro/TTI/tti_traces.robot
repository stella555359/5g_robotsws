*** Settings ***
Documentation    Keywords for TTI Trace collection
Library    taf.collectors.tcpdump    WITH NAME    TCPDUMP
Library    taf.collectors.l2stream3    WITH NAME    L2STREAM3
Library    taf.collectors.core    WITH NAME    CORE
Library    taf.converters.eventdecoder  WITH NAME  EVENTDECODER
Library    OperatingSystem
Library    ./streaming_ttitrace_analyzer.py    WITH NAME    TTITRACEANALYZER

*** Keywords ***
Start Ttirace With Streaming Mode
    ${executor}=  Create Dictionary
    ...  host=192.168.255.1
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    @{nr_phy_cell_ids}=  Create List  ${50}
    ${l2_stream_config_1}=  Create Dictionary
    ...  nr_phy_cell_ids=${nr_phy_cell_ids}
    @{l2_stream_configuration}=  Create List  ${l2_stream_config_1}
    TCPDUMP.create tcpdump collector
    ...  name=tcpdump
    ...  options=-i eth3 udp and dst 10.0.1.1 and dst port 5678
    ...  sudo_password=ute
    L2STREAM3.create sbts l2stream collector
    ...  name=l2stream3
    ...  destination_ip_addr=10.0.1.1
    ...  collector=tcpdump
    ...  l2_stream_configuration=${l2_stream_configuration}
    ...  webservice=${executor}
    L2STREAM3.Set Suite Alias
    ...  alias=l2stream3
    CORE.setup_collectors
    ...  names=l2stream3
    CORE.start_collectors
    ...  names=l2stream3

Stop Ttirace
    CORE.stop_collectors
    ...  names=l2stream3
    CORE.collect_collectors
    ...  names=l2stream3
    CORE.teardown_collectors
    ...  names=l2stream3

Convert Tttirace From Pcap To Excelcsv
    [Arguments]    ${log_path}=${OUTPUT_DIR}
    ${file_path}=    Set Variable    ${OUTPUTDIR}/${SUITE_NAME}/${TEST_NAME}/l2stream3/tcpdump/tcpdump.pcap
    EVENTDECODER.Create Eventdecoder Converter
    ...  name=converter
    ...  input_file_path=${file_path}
    ...  output_file_format=excelCsv
    EVENTDECODER.Convert
    ...  name=converter
    OperatingSystem.Run    mkdir -p ${log_path}
    OperatingSystem.Run    cp ${EXECDIR}/output_dl.csv ${log_path};cp ${EXECDIR}/output_ul.csv ${log_path}

Ttitrace Filter Source Column Return Self Column
    [Arguments]    ${file_name}    ${source_column_name}    ${condition}=["0", ""]
    ...    ${operation}="except"    ${remove_duplicate}="no"
    [Documentation]    This keyword is used to filter ttitrace table, input one column, filter data, return result of itself.
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_name} | Yes | ttitrace file name with absolute path |
    ...    | ${source_column_name} | Yes | filterred column name |
    ...    | ${condition} | No | filterred value |
    ...    | ${operation} | No | make filterred value except or include, "except","include" |
    ...    | ${target_column_name} | No | return column name|
    ...    | ${remove_duplicate} | No | whether remove duplicated data in returned list,"yes", "no" |
    ...    Examples:
    ...    | ${5qi1Prb_list}| Ttitrace Fiter Source Column Return Self Column | ./streaming_test_data/output_ul.csv | ulFdSchedData.numOf5qi1Prb |
    ...    | ["0", "", "0.0"] | except | yes |
    ${data_list}    TTITRACEANALYZER.Filter Source Column Return Self    ${file_name}    ${source_column_name}
    ...    ${condition}    ${operation}    ${remove_duplicate}
    [Return]    ${data_list}

Ttitrace Filter Source Column Return Other Column
    [Arguments]    ${file_name}    ${source_column_name}    ${condition}=["0", ""]
    ...    ${operation}="except"    ${target_column_name}=""    ${remove_duplicate}="no"
    [Documentation]    This keyword is used to filter ttitrace table, input one column, filter data, return filterred other column.
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_name} | Yes | ttitrace file name with absolute path |
    ...    | ${source_column_name} | Yes | filterred column name |
    ...    | ${condition} | No | filterred value |
    ...    | ${operation} | No | make filterred value except or include, "except","include" |
    ...    | ${target_column_name} | No | return column name|
    ...    | ${remove_duplicate} | No | whether remove duplicated data in returned list,"yes", "no" |
    ...    Examples:
    ...    | ${rnti_list}| Ttitrace Fiter Source Column Return Other Column | ./streaming_test_data/output_ul.csv | ulFdSchedData.numOf5qi1Prb |
    ...    | ["0", "", "0.0"] | except | rnti | yes |
    ${data_list}    TTITRACEANALYZER.Filter Source Column Return Other    ${file_name}    ${source_column_name}
    ...    ${condition}    ${operation}    ${target_column_name}    ${remove_duplicate}
    [Return]    ${data_list}

Ttitrace Count Interval
    [Arguments]    ${source_column_list}    ${remove_duplicate}="yes"
    [Documentation]    This keyword is used to count source_column_list[i+1]-source_column_list[i]
    ...    | Input Parameters | Man. | Description |
    ...    | ${source_column_list} | Yes | a list to count |
    ...    | ${remove_duplicate} | No | "yes", "no" |
    ...    Examples:
    ...    | Ttitrace Count Interval | ${column list} | yes |
    ${data_list}   TTITRACEANALYZER.Count Interval    ${source_column_list}    ${remove_duplicate}
    [Return]    ${data_list}
