*** Keywords ***
Convert Pcap To Sherpa Csv
    [Arguments]    ${log_dir}=${TEST_LOG_DIRECTORY}
    [Documentation]    This Keyword Is To Convert Pcap Log To Sherpa Csv Log
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | No | the folder path to store log, the default value is ${TEST_LOG_DIRECTORY} |
    ...
    Makesure UTEVM Sherpa Tool Can Work
    ${tlpc_ip}=    Get Host IP
    ${tlpc_ssh_ue}=    Set Variable    ute
    ${tlpc_ssh_pwd}=    Set Variable    ute
    ${executor}=    Create Dictionary
    ...    host=${tlpc_ip}
    ...    user=${tlpc_ssh_ue}
    ...    password=${tlpc_ssh_pwd}
    SHERPA.Create Sherpa Converter
    ...    name=sherpa
    ...    executor=${executor}
    ...    sudo_password=ute
    ...    file_path_pattern=${log_dir}/l2stream3_sherpa/tcpdump_sherpa/*.pcap
    ...    output_path=${log_dir}/l2stream3_sherpa/tcpdump_sherpa
    SHERPA.Setup    sherpa
    SHERPA.Convert    sherpa
    SHERPA.Teardown    sherpa
    Set Suite Variable    ${SHERPA_CSV_DIRECTORY}    ${log_dir}/l2stream3_sherpa/tcpdump_sherpa/tcpdump_sherpa/
    [Return]    ${log_dir}/l2stream3_sherpa/tcpdump_sherpa/tcpdump_sherpa/

Makesure UTEVM Sherpa Tool Can Work
    OperatingSystem.Run    sudo usermod -a -G sherpa ute
    OperatingSystem.Run    sudo setcap cap_net_raw,cap_net_admin=eip /opt/Nokia/Sherpa_5G_18/Sherpa

Convert Ttitrace From Pcap To Excelcsv
    [Arguments]    ${log_path}=${OUTPUT_DIR}/ttitrace_streaming/    ${names}=l2stream3_ttitrace
    [Timeout]    30min
    ${file_path}=    Set Variable    ${log_path}/${names}/tcpdump_ttitrace/tcpdump_ttitrace.pcap
    OperatingSystem.Run    mkdir -p ${log_path}; cp -r "${file_path}" ${log_path}
    EVENTDECODER.Create Eventdecoder Converter
    ...    name=converter
    ...    input_file_path=${file_path}
    ...    output_file_format=excelCsv
    ...    excel_csv_options=-w
    EVENTDECODER.Convert
    ...    name=converter
    OperatingSystem.Run    mkdir -p ${log_path}
    OperatingSystem.Run    cp ${EXECDIR}/output_dl*.csv ${log_path};cp ${EXECDIR}/output_ul*.csv ${log_path}
    List Files In Directory    ${log_path}

Convert Ttitrace From Pcap To Legacycsv
    [Arguments]    ${log_dir}=${TEST_LOG_DIRECTORY}/ttitrace_streaming/    ${names}=l2stream3_ttitrace
    [Timeout]    30min
    ${file_path}=    Set Variable    ${log_dir}/${names}/tcpdump_ttitrace/tcpdump_ttitrace.pcap
    OperatingSystem.Run    mkdir -p ${log_dir}; cp -r "${file_path}" ${log_dir}
    EVENTDECODER.Create Eventdecoder Converter
    ...    name=converter
    ...    input_file_path=${file_path}
    ...    output_file_path=${log_dir}/${names}/
    ...    output_file_format=legacyCsv
    EVENTDECODER.Convert
    ...    name=converter
    OperatingSystem.Run    mkdir -p ${log_dir}
    OperatingSystem.Run    mv ${log_dir}/${names}/tcpdump_ttit/* ${log_dir}
    OperatingSystem.Run    rm -rf ${log_dir}/${names}

Decode Ttitrace Log
    [Arguments]    ${log_dir}=${OUTPUT_DIR}/ttitrace_streaming/
    log to console    Start to decode ttitrace...
    Convert Ttitrace From Pcap To Excelcsv    ${log_dir}
    log to console    Start to format ttitrace...
    Format Ttitrace CSV If Exist    ${log_dir}    output_dl.csv
    Format Ttitrace CSV If Exist    ${log_dir}    output_ul.csv
    log to console    decode ttitrace finished.

Format Ttitrace CSV If Exist
    [Arguments]    ${log_dir}    ${file}
    ${ret}=    Run Keyword And Return Status    File Should Exist    ${log_dir}/${file}
    Run Keyword If    "${ret}"=="${True}"    Format Tti In Stream Mode    ${log_dir}/${file}    ${log_dir}/format_${file}

Sherpa Analyzer Check Values Is True
    [Arguments]    ${file_path}    ${column_name}    ${check_value_regex}
    [Documentation]    This Keyword Is To Verify The Presence Of A Given Set Of Values In A Csv File Issued From Sherpa Traces
    ...    Return True If All Of Them Are Found, False If Not
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | Yes | the file need to check |
    ...    | ${column_name} | Yes | the name of column in file need to check |
    ...    | ${check_value_regex} | Yes | the value of column should be,it is a regexfilter |
    ...
    ...    Examples:
    ...    | ${file_path} | Set Variable | ${TEST_LOG_DIRECTORY}/l2stream3/tcpdump/tcpdump/micro__l1l2Trace.csv |
    ...    | Sherpa Anylyzer Check Values Is True | ${file_path} | TEXT | .*(ulRank=2).* |
    Log To Console    Sherpa Anylyzer Check Values Is True
    SHERPAREADER.Setup Reader    ${file_path}
    ${result}    SHERPAREADER.Get Values For Column    ${column_name}    ${check_value_regex}
    Should Not Be Empty    ${result}
    [Return]    ${result}

Sherpa Analyzer Check Values List Exist
    [Arguments]    ${file_path}    ${column_name}    @{check_value_list}
    [Documentation]    This Keyword Is To Verify The Presence Of A Given Set Of Values In A Csv File Issued From Sherpa Traces
    ...    Return True If All Of Them Are Found, False If Not
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | Yes | the file need to check |
    ...    | ${column_name} | Yes | the name of column in file need to check |
    ...    | @{check_value_list} | Yes | the checked value in column |
    ...
    ...    Examples:
    ...    | ${file_path} | Set Variable | ${TEST_LOG_DIRECTORY}/l2stream3/tcpdump/tcpdump/micro__l1l2Trace.csv |
    ...    | Sherpa Anylyzer Check Values Is True | ${file_path} | TEXT | .*(ulRank=2).* |
    Log To Console    Sherpa Anylyzer Check Values Is True
    SHERPAREADER.Setup Reader    ${file_path}
    ${result}=    SHERPAREADER.Check All Values For Column    ${column_name}    @{check_value_list}
    Should Be True    ${result}    @{check_value_list} not exist in ${column_name}
    [Return]    ${result}

Sherpa Analyzer Check Values List Exist In Column2 When Filtering Column1
    [Arguments]    ${file_path}    ${req_column}    ${req_column_value}    ${check_list_column}    ${check_list}
    [Documentation]    Check that a list of values is present in all the rows matching the required value for a given column
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | Yes | the file need to check |
    ...    | ${req_column} | Yes | the column for which the required value has to be checked |
    ...    | ${req_column_value} | Yes | the value to be checked to filter the rows |
    ...    | ${check_list_column} | Yes | the column in which the list of values have to be checked |
    ...    | ${check_list} | Yes | list of values to be checked in the column for the filtered rows |
    ...    Examples:
    ...    | ${file_path} | Set Variable | ${TEST_LOG_DIRECTORY}/l2stream3/tcpdump/tcpdump/micro__l1l2Trace.csv |
    ...    | Sherpa Analyzer Check Values List Exist in Column2 When Filtering Column1 | ${file_path} |
    ...    | MSGID | Ul PucchReceiveReq | TEXT | nANPucch |
    SHERPAREADER.Setup Reader    ${file_path}
    ${result}=    SHERPAREADER.Check Value List Column When Value    ${req_column}    ${req_column_value}
    ...    ${check_list_column}    ${check_list}
    Should Not Be Equal    ${result}    False    Checked value is not founded.
    [Return]    @{result}[1]

Sherpa Analyzer Check Value In One Column With Regex1 Firstly Regex2 Sencondly
    [Arguments]    ${file_path}    ${column_name}    ${check_value_regex1}    ${check_value_regex2}
    [Documentation]    Check that all the filtered values of a column match a regex
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | Yes | the file need to check |
    ...    | ${column_name} | Yes | the column for which the values have to be checked |
    ...    | ${check_value_regex1} | Yes | a regex to check on all the column values for which filter is matched |
    ...    | ${check_value_regex2} | Yes | a condition filter on all the column values |
    ...    Examples:
    ...    | ${file_path} | Set Variable | ${TEST_LOG_DIRECTORY}/l2stream3/tcpdump/tcpdump/micro__l1l2Trace.csv |
    ...    | Sherpa Analyzer Check Value In One Column With Regex1 Firstly Regex2 Sencondly | ${file_path} | MSGID | TEXT |  |
    SHERPAREADER.Setup Reader    ${file_path}
    ${result}=    SHERPAREADER.Check Values Column Matching Regex Match Another    ${column_name}    ${check_value_regex2}
    ...    ${check_value_regex1}
    [Return]    @{result}[1]

Sherpa Get Aimlist According To Keyword From Aimcolumn
    [Arguments]    ${keyword}    ${aim_column}
    [Documentation]    This keyword is used to get parameter value from Sherpa TEXT column.
    ...    | Input Parameters | Man. | Description |
    ...    | ${keyword} | Yes | the keyword need to check |
    ...    | ${aim_column} | Yes | the name of column in file need to check |
    ...    Examples:
    ...    ${aim_column}=    Sherpa Analyzer Check Values List Exist in Column2 When Filtering Column1    ${CSV_file}
    ...    MSGID    Ul SrsReceiveRespPsEvent\\(2\\)    TEXT    None
    ...    ${aim_ulPmiRank1Sinr}    Sherpa Get Aimlist According To Keyword From Aimcolumn    ulPmiRank1Sinr=\(\\d*.\\d*\)dB    ${aim_column}
    ${aim_list}=    Filter Substring From List    ${keyword}    ${aim_column}
    [Return]    ${aim_list}

Filter Value In List
    [Arguments]    ${value_regrex}    ${aim_list}
    [Documentation]    This keyword is used to filter value with regrex from each element in a list.
    ...    | Input Parameters | Man. | Description |
    ...    | ${value_regrex} | Yes | the keyword need to filter |
    ...    | ${aim_list} | Yes | the name of list need to filter |
    ...    Examples:
    ...    Filter Value in List    nANPucch    ${aim_column}
    FOR    ${item}    IN    @{aim_list}
         ${ret}=    Run Keyword And Return Status    Should Match Regexp    ${item}    ${value_regrex}
         Run Keyword If    "${ret}"=="False"    Remove Values From List    ${aim_list}    ${item}
    END
    [Return]    ${aim_list}

Filter Substring From List
    [Arguments]    ${keyword}    ${source_list}
    [Documentation]    This keyword is used to filter substring with regrex from each element in a list.
    ...    | Input Parameters | Man. | Description |
    ...    | ${keyword} | Yes | the keyword need to filter |
    ...    | ${source_list} | Yes | the name of list need to filter |
    ...    Examples:
    ...    ${aim_list}=    Filter Substring From List    ${keyword}    ${aim_column}
    ${aim_list}    Create List
    FOR    ${item}    IN    @{source_list}
         ${result_1}    ${result_2}    Should Match Regexp    ${item}    ${keyword}
         Append To List    ${aim_list}    ${result_2}
    END
    [Return]    ${aim_list}

Filter ERR WRN Message From Syslog By Log Path
    [Arguments]    ${log_path}    ${filter_message_file}    ${output_file_path}
    [Documentation]    This keyword is used to filter error and warnning message from syslog path.
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_path} | Yes | absolute log path, for example: ${SUITE_LOG_DIRECTORY} |
    ...    | ${filter_message_file} | Yes | txt file which contains filterred message |
    ...    | ${output_file} | Yes | txt file which contains output message |
    ...    Examples:
    ...    | Filter ERR WRN Message From Syslog By Log Path | ${SUITE_LOG_DIRECTORY}    ${CURDIR}/filter_msg.txt    ${CURDIR}/output_log.txt |
    OperatingSystem.Run And Return Rc And Output    rm -f ${output_file_path}
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    find ${log_path} -maxdepth 1 -name Gnb_syslog.tar.gz
    Set Suite Variable    ${FILTER_SYSLOG_STATUS}    ${FALSE}
    Run Keyword If    """${output}"""!=""    Unzip And Filter Gnb_syslog    ${output}    ${filter_message_file}    ${output_file_path}

Unzip And Filter Gnb_syslog
    [Arguments]    ${output}    ${filter_message_file}    ${output_file_path}
    ${files_list}=    String.Split To Lines    ${output}
    OperatingSystem.Run    rm -rf Gnb_syslog_*
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    tar -xzvf ${files_list}[0]
    Log    ${output}
    ${files_list_1}=    String.Split To Lines    ${output}
    Run Keyword If    """${output}"""!=""    Filter ERR WRN Message From Syslog    Gnb_syslog_*
    ...    ${filter_message_file}    ${output_file_path}
    ${status}=    Run Keyword And Return Status    File Should Not Be Empty    ${output_file_path}
    Set Suite Variable    ${FILTER_SYSLOG_STATUS}    ${status}

Show Fatal Log
    [Arguments]    ${output_file}
    ${output}=    Get File    ${output_file}
        Log    ---In ${output_file}:---${output}    WARN

Filter ERR WRN Message From Syslog
    [Arguments]    ${log_file}    ${filter_message_file}    ${output_file}
    [Documentation]    This keyword is used to filter error and warnning message from one file.
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_file} | Yes | log file which needs to be filterred. |
    ...    | ${filter_message_file} | Yes | txt file which contains filterred message |
    ...    | ${output_file} | Yes | txt file which contains output message |
    ...    Examples:
    ...    | Filter ERR WRN Message From Syslog By One File | ${CURDIR}/syslog.txt    ${CURDIR}/filter_log.txt    ${CURDIR}/output_log.txt |
    OperatingSystem.File Should Exist    ${filter_message_file}
    ${content}=    Get File    ${filter_message_file}
    ${content_list}=    String.Split To Lines    ${content}
    FOR    ${filter_item}    IN    @{content_list}
         OperatingSystem.Run And Return Rc And Output    egrep "${filter_item}" ${log_file}>>${output_file}
    END

Get GNB DRX Parameter For Example
    Backup Scf    ${TEST_LOG_DIRECTORY}    gnb_para
    ${SCF_file}=    Set Variable    ${TEST_LOG_DIRECTORY}/SCF_gnb_para.xml
    ${actCDrx}=    Get Value From XML File By DistName    ${SCF_file}
    ...    MRBTS-1/NRBTS-1/NRCELL-1    actCDrx    #Activate connected DRX
    ${drxOnDurationTimer}=    Get Value From XML File By List and DistName    ${SCF_file}
    ...    MRBTS-1/NRBTS-1/NRCELL-1    drxProfile1    drxOnDurationTimer    #DRX On Duration Timer
    ${csiReportPeriodicity}=    Get Value From XML File By List and DistName    ${SCF_file}
    ...    MRBTS-1/NRBTS-1/NRCELL-1    periodicCsiAcquisition    csiReportPeriodicity    #CSI Reporting Periodicity

Convert BIP Log Pcap To Csv
    [Arguments]    ${bip_log}    ${filter}    ${column_name}    ${csv_name_tag}
    [Documentation]    This keyword is to convert BIP log from pcap to csv
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${bip_log} | Yes | pcap bip log incloude bip log folder and bip log name |
    ...    | ${filter} | yes | the filter to filter the massage need to check |
    ...    | ${column_name} | yes | the column whose value need to check |
    ...    | ${csv_name_tag} | yes | the tag for BIP csv log name |
    ...
    ...    Examples:
    ...    | *** Variables *** |
    ...    | ${bip_log} |    | /home/ute/5GBipL2L1_filtering_off.pcap |
    ...    | ${filter} |    | /home/ute/generated_luashark/luashark.lua |
    ...    | @{column_name} |    | DlData_PdschSendReq.PdschSendReq.slot | DlData_PdschSendReq.PdschSendReq.sfn |
    ...    | ... |    | DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.slot | DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.sfn |
    ...    | ... |    | DlData_PdschSendReq.PdschSendReq.slot | DlData_SsBlockSendReq.SsBlockSendReq.sfn |
    ...
    ...    | ${bip_csv_log} | Convert BIP Log Pcap To Csv | ${bip_log} | ${filter} | ${column_name} | pdsch |
    ...
    ${lua_script_path}    check_pcap_file.Get Luashark File
    Log To Console    \nConvert BIP Log from Pcap to csv...
    ${column_name_str}    Catenate    SEPARATOR=${SPACE}-e${SPACE}    @{column_name}
    ${csv_log_name}    String.Replace String Using Regexp    ${bip_log}    \\.pcap.*    _${csv_name_tag}.csv
    ${cmd}    Catenate    SEPARATOR=${SPACE}    tshark -r ${bip_log} -X lua_script:${lua_script_path} -Y '${filter}'
    ...    -T fields -e _ws.col.No. -e _ws.col.Protocol -e _ws.col.Info
    ...    -e ${column_name_str} -E header=y -E separator=, -E quote=d -E occurrence=a > ${csv_log_name}
    ${rc}    OperatingSystem.Run And Return RC    ${cmd}
    [Return]    ${csv_log_name}

Get Match Regexp Status For Single BIP Csv Files
    [Arguments]    ${bip_log}    ${filter}    ${column_name}    ${csv_name_tag}    ${check_point_regexp}
    [Documentation]    This keyword is to Check BIP Csv File With Regexp
    ...    | Input Parameters | Man. | Description |
    ...    | ${bip_log} | Yes | pcap bip log incloude bip log folder and bip log name |
    ...    | ${filter} | yes | the filter to filter the massage need to check |
    ...    | ${column_name} | yes | the column whose value need to check |
    ...    | ${csv_name_tag} | yes | the tag for BIP csv log name |
    ...
    ...    Examples:
    ...    | *** Variables *** |
    ...    | ${bip_log} |    | /home/ute/5GBipL2L1_filtering_off |
    ...    | ${filter} |    | /home/ute/generated_luashark/luashark.lua |
    ...    | @{column_name} |    | DlData_PdschSendReq.PdschSendReq.slot | DlData_PdschSendReq.PdschSendReq.sfn |
    ...    | ... |    | DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.slot | DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.sfn |
    ...    | ... |    | DlData_PdschSendReq.PdschSendReq.slot | DlData_SsBlockSendReq.SsBlockSendReq.sfn |
    ...    | ${check_point_regexp} |    |SEPARATOR=    DlData_SsBlockSendReq, MIB\\",+\\"(?P<slot>0x\\d+)\\",\\"(?P<sfn>0x\\d+)\\".*\\s\\S
    ...    .*DlData_PdschSendReq\\",+\\"(?P=slot)\\",+\\"(?P=sfn)\\".*\\s\\S.*DlData_PdschPayloadTbSendReq\\",+\\"(?P=slot)\\",+\\"(?P=sfn)\\"
    ...
    ...    | Verify Single BIP Csv File Match Regexp | ${bip_log} | ${filter} | ${column_name} | ${csv_name_tag} | ${check_point_regexp} |
    ...
    ${bip_csv_log}    Convert BIP Log Pcap To Csv    ${bip_log}    ${filter}    ${column_name}    ${csv_name_tag}
    Log To Console    \nCheck BIP Csv File Match Regexp...
    ${csv_content}    OperatingSystem.Get File    ${bip_csv_log}
    ${check_status}    Run Keyword And Return Status    Should Match Regexp    ${csv_content}    ${check_point_regexp}
    [Return]    ${check_status}

Get Match Regexp Status For All BIP Csv Files
    [Arguments]    ${log_dir}    ${filter}    ${column_name}    ${csv_name_tag}    ${check_point_regexp}
    @{status_list}    Create List
    ${count}    OperatingSystem.Count Items In Directory    ${log_dir}    pattern=5GBipL2L1_filtering_off.pcap*
    FOR    ${index}    IN RANGE    ${count}
         Log To Console    \nDeal with BIP_LOG:5GBipL2L1_filtering_off.pcap${index}...
         ${bip_log}    Catenate    SEPARATOR=//    ${log_dir}    5GBipL2L1_filtering_off.pcap${index}
         ${check_status}    Get Match Regexp Status For Single BIP Csv Files    ${bip_log}    ${filter}
    ...    ${column_name}    ${csv_name_tag}${index}    ${check_point_regexp}
         Append To List    ${status_list}    ${check_status}
         Log    ${status_list}
    END
    [Return]    ${status_list}

Verify BIP Csv File Match Regexp
    [Arguments]    ${log_dir}    ${filter}    ${column_name}    ${csv_name_tag}    ${check_point_regexp}
    [Documentation]    This keyword is to Check BIP Csv File With Regexp
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | Yes | the log folder where BIP log existed, e.g.${TEST_LOG_DIRECTORY} |
    ...    | ${filter} | yes | the filter to filter the massage need to check |
    ...    | ${column_name} | yes | the column whose value need to check |
    ...    | ${csv_name_tag} | yes | the tag for BIP csv log name |
    ...
    ...    Examples:
    ...    | *** Variables *** |
    ...    | ${log_dir} |    | /home/ute/ |
    ...    | ${filter} |    | /home/ute/generated_luashark/luashark.lua |
    ...    | @{column_name} |    | DlData_PdschSendReq.PdschSendReq.slot | DlData_PdschSendReq.PdschSendReq.sfn |
    ...    | ... |    | DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.slot | DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.sfn |
    ...    | ... |    | DlData_PdschSendReq.PdschSendReq.slot | DlData_SsBlockSendReq.SsBlockSendReq.sfn |
    ...    | ${check_point_regexp} |    |SEPARATOR=    DlData_SsBlockSendReq, MIB\\",+\\"(?P<slot>0x\\d+)\\",\\"(?P<sfn>0x\\d+)\\".*\\s\\S
    ...    .*DlData_PdschSendReq\\",+\\"(?P=slot)\\",+\\"(?P=sfn)\\".*\\s\\S.*DlData_PdschPayloadTbSendReq\\",+\\"(?P=slot)\\",+\\"(?P=sfn)\\"
    ...    | Verify BIP Csv File Match Regexp | ${log_dir} | ${filter} | ${column_name} | ${csv_name_tag} | ${check_point_regexp} |
    ...
    ${status_list}    Get Match Regexp Status For All BIP Csv Files
    ...    ${log_dir}    ${filter}    ${column_name}    ${csv_name_tag}    ${check_point_regexp}
    Collections.List Should Contain Value    ${status_list}    ${true}    Check Failed as check_point doesn't exist in the BIP log.

Verify BIP Csv File Not Match Regexp
    [Arguments]    ${log_dir}    ${filter}    ${column_name}    ${csv_name_tag}    ${check_point_regexp}
    [Documentation]    This keyword is to Check BIP Csv File With Regexp
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | Yes | the log folder where BIP log existed, e.g.${TEST_LOG_DIRECTORY} |
    ...    | ${filter} | yes | the filter to filter the massage need to check |
    ...    | ${column_name} | yes | the column whose value need to check |
    ...    | ${csv_name_tag} | yes | the tag for BIP csv log name |
    ...
    ...    Examples:
    ...    | *** Variables *** |
    ...    | ${log_dir} |    | /home/ute/ |
    ...    | ${filter} |    | /home/ute/generated_luashark/luashark.lua |
    ...    | @{column_name} |    | DlData_PdschSendReq.PdschSendReq.slot | DlData_PdschSendReq.PdschSendReq.sfn |
    ...    | ... |    | DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.slot | DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.sfn |
    ...    | ... |    | DlData_PdschSendReq.PdschSendReq.slot | DlData_SsBlockSendReq.SsBlockSendReq.sfn |
    ...    | ${check_point_regexp} |    |SEPARATOR=    DlData_SsBlockSendReq, MIB\\",+\\"(?P<slot>0x\\d+)\\",\\"(?P<sfn>0x\\d+)\\".*\\s\\S
    ...    .*DlData_PdschSendReq\\",+\\"(?P=slot)\\",+\\"(?P=sfn)\\".*\\s\\S.*DlData_PdschPayloadTbSendReq\\",+\\"(?P=slot)\\",+\\"(?P=sfn)\\"
    ...    | Verify BIP Csv File Match Regexp | ${log_dir} | ${filter} | ${column_name} | ${csv_name_tag} | ${check_point_regexp} |
    ...
    ${status_list}    Get Match Regexp Status For All BIP Csv Files
    ...    ${log_dir}    ${filter}    ${column_name}    ${csv_name_tag}    ${check_point_regexp}
    Collections.List Should Not Contain Value    ${status_list}    ${true}    Check Failed as check_point exist in the BIP log.

Get Match List From BIP Csv File
    [Arguments]    ${bip_csv_log}    ${check_point_regexp}
    [Documentation]    This keyword is to get match list from bip csv log with the specified regexp.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${bip_csv_log} | Yes | the file path for bip csv log |
    ...    | ${check_point_regexp} | Yes | the regexp for the check point |
    ...
    ...    Examples:
    ...    | ${dl_check_point_regexp} | Set Variable | UlData_PucchReceiveRespHarqD\\",+\\"(?P<NACK>0x\\d+)\\" |
    ...    | Get Match List From BIP Csv File | /home/ute/tcpdumpL2L1_filtering_off_dl_nack.csv | ${dl_check_point_regexp} |
    ...
    Log To Console    \nGet Match List From BIP Csv File...
    ${csv_content}    OperatingSystem.Get File    ${bip_csv_log}
    @{group_list}    Get Regexp Group List    ${check_point_regexp}
    @{match_list}    String.Get Regexp Matches    ${csv_content}    ${check_point_regexp}    @{group_list}
    [Return]    @{match_list}

Get Regexp Group List
    [Arguments]    ${check_point_regexp}
    [Documentation]    This keyword is to get group name form the specified regexp
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${check_point_regexp} | Yes | the regexp for the check point |
    ...
    ...    Examples:
    ...    | @{group_list} | Get Regexp Group List | UlData_PucchReceiveRespHarqD\\",+\\"(?P<NACK>0x\\d+)\\" |
    ...
    # @{group_list}    String.Get Regexp Matches    ${check_point_regexp}    \\(\\?P\\<(\\w+)\\>
    # ${group_count}    Get Length    ${group_list}
    # ${group_count_list}    Evaluate    range(1,${group_count}+1)
    @{group_list}    String.Get Regexp Matches    ${check_point_regexp}    \\(\\?P\\<(\\w+)\\>    1
    [Return]    @{group_list}

Verify DL Not ACK Rate Less Than Target
    [Arguments]    ${bip_log_dir}    ${target_value}
    [Documentation]    This keyword is to verify DL Not ACK less than the target value
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${bip_log_dir} | Yes | the directory for bip pcap log |
    ...    | ${target_value} | Yes | the value DL NACK should be less than |
    ...
    ...    Examples:
    ...    | Verify DL NACK Less Than Target | /home/ute/results/ | 0.1 |
    ...
    ${filter}    Set Variable    uldata_pucchreceiverespharqd
    # @{column_name}    Create List    UlData_PucchReceiveRespHarqD.ackNack.ackNack_item_0
    # ...    UlData_PucchReceiveRespHarqD.pucchResources_item_175.dtx
    @{column_name}    Create List    data.data    UlData_pucchReceiveRespHarqDPucchResource_t.dtx
    ${bip_names}    OperatingSystem.List Files In Directory    ${bip_log_dir}    5GBipL2L1_filtering_off*.pcap*    ${True}
    FOR    ${index}    ${name}    IN ENUMERATE    @{bip_names}
         Convert BIP To CSV By MCShark    ${name}    ${bip_log_dir}/5GBipL2L1_filtering_off_dl_nack_${index}.csv    ${filter}    ${column_name}
    END
    ${bip_csv_names}    OperatingSystem.List Files In Directory    ${bip_log_dir}    5GBipL2L1_filtering_off_dl_nack*.csv    ${True}
    ${totals}    Create List
    ${fails}    Create List
    FOR    ${name}    IN    @{bip_csv_names}
         ${content}    OperatingSystem.Get File    ${name}
         ${total_number}    Get Total UlDataPucchReceiveRespHarqD Message Number    ${content}
         ${failed_number}    Get Total Failed UlDataPucchReceiveRespHarqD Message Number    ${content}
         Collections.Append To List    ${totals}    ${total_number}
         Collections.Append To List    ${fails}    ${failed_number}
    END
    ${rate}    Evaluate    float(sum(${fails}))/sum(${totals})
    Should Be True    ${rate}<${target_value}

Verify UL Not ACK Rate Less Than Target
    [Arguments]    ${bip_log_dir}    ${target_value}
    [Documentation]    This keyword is to verify UL Not ACK less than the target value
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${bip_log_dir} | Yes | the directory for bip pcap log |
    ...    | ${target_value} | Yes | the value UL NACK should be less than |
    ...
    ...    Examples:
    ...    | Verify UL NACK Less Than Target | /home/ute/results | 0.1 |
    ...
    ${filter}    Set Variable    uldata_puschreceiverespharqu
    # @{column_name}    Create List    UlData_PuschReceiveRespHarqU.grants_item_0.crc    UlData_PuschReceiveRespHarqU.grants_item_0.dtx
    @{column_name}    Create List    UlData_UePuschReceiveRespHarqU_t.crc    UlData_UePuschReceiveRespHarqU_t.dtx
    ${bip_names}    OperatingSystem.List Files In Directory    ${bip_log_dir}    5GBipL2L1_filtering_off*.pcap*    ${True}
    FOR    ${index}    ${name}    IN ENUMERATE    @{bip_names}
         Convert BIP To CSV By MCShark    ${name}    ${bip_log_dir}/5GBipL2L1_filtering_off_ul_nack_${index}.csv    ${filter}    ${column_name}
    END
    ${bip_csv_names}    OperatingSystem.List Files In Directory    ${bip_log_dir}    5GBipL2L1_filtering_off_ul_nack*.csv    ${True}
    ${totals}    Create List
    ${fails}    Create List
    FOR    ${name}    IN    @{bip_csv_names}
         ${content}    OperatingSystem.Get File    ${name}
         ${total_number}    Get Total UlDataPuschReceiveRespHarqU Message Number    ${content}
         ${failed_number}    Get Total Failed UlDataPuschReceiveRespHarqU Message Number    ${content}
         Collections.Append To List    ${totals}    ${total_number}
         Collections.Append To List    ${fails}    ${failed_number}
    END
    ${rate}    Evaluate    float(sum(${fails}))/sum(${totals})
    Should Be True    ${rate}<${target_value}

Get Total UlDataPuschReceiveRespHarqU Message Number
    [Arguments]    ${content}
    ${total_reg}    Set Variable    UlData_PuschReceiveRespHarqU \\",\\"(?P<CRC>\\d+)\\",\\"(?P<DTX>\\d+)\\"
    ${matches}    String.Get Regexp Matches    ${content}    ${total_reg}    CRC    DTX
    ${count}    Get Length    ${matches}
    [Return]    ${count}

Get Total Failed UlDataPuschReceiveRespHarqU Message Number
    [Arguments]    ${content}
    ${failed_reg}    Set Variable    UlData_PuschReceiveRespHarqU \\",\\"([1-9]+|0\\",\\"[1-9]+\\")
    ${matches}    String.Get Regexp Matches    ${content}    ${failed_reg}
    ${count}    Get Length    ${matches}
    [Return]    ${count}

Get Total UlDataPucchReceiveRespHarqD Message Number
    [Arguments]    ${content}
    ${total_reg}    Set Variable    UlData_PucchReceiveRespHarqD
    ${matches}    String.Get Regexp Matches    ${content}    ${total_reg}
    ${count}    Get Length     ${matches}
    [Return]    ${count}

Get Total Failed UlDataPucchReceiveRespHarqD Message Number
    [Arguments]    ${content}
    ${fail_reg}    Set Variable    UlData_PucchReceiveRespHarqD\\s+\\",\\"(?:0+\\"|\\d+\\",\\"[1-9]\\")
    ${matches}    String.Get Regexp Matches    ${content}    ${fail_reg}
    ${count}    Get Length     ${matches}
    [Return]    ${count}

Check Slot Type
    [Arguments]    ${file_tag}    @{slottype_list}
    ${filepath}=    Get L2PS Startup Log from ABIL Board to Local Control PC    ${file_tag}
    ${rc}    ${line}    OperatingSystem.Run And Return Rc And Output
    ...    awk '/SLOT_TYPE_SSBURST/{print NR;exit}' ${filepath}
    ${rc}    ${content}    OperatingSystem.Run And Return Rc And Output    sed -n '${line.strip()},+40p' ${filepath}
    Should be true    ${line.strip()}!=""
    ${line_num}    set variable    ${line.strip()}-1
    FOR    ${sub}    IN    @{slottype_list}
         ${line_num}    Evaluate    ${line_num}+1
         ${rc}    ${content}    OperatingSystem.Run And Return Rc And Output    sed -n '${line_num}p' ${filepath}
         Should contain    ${content.replace(" ","").replace("(dl)","").replace("(bi)","").replace("(ul)","")}    ${sub.replace(" ","")}
    END

Get L2PS Startup Log from ABIL Board to Local Control PC
    [Arguments]    ${file_prefix}=${EMPTY}    ${file_directory}=${OUTPUT_DIR}
    ${L2RT_node_1}=    Set Variable If    "${ASP_BOARD_TYPE}"=="ABIO"    0    1
    Set Suite Variable    ${L2RT_NODE}    ${L2RT_node_1}
    ${file_path_on_ABIL}=    Get Startup Log Path On ASP
    ${file_path_on_ASIX}=    Copy File From ASP To FCT    ${file_path_on_ABIL}
    ${file_path_on_Control_PC}=    Copy File From FCT To Control PC    ${file_path_on_ASIX}    ${OUTPUT_DIR}
    ${file_path_unzip}=    Unzip Log If Log Suffix Is zip    ${file_path_on_Control_PC}
    ${output_file_path}=    Add Prefix For File If Prefix Exist    ${file_path_unzip}    ${file_prefix}
    [Return]    ${output_file_path}

Unzip Log If Log Suffix Is zip
    [Arguments]    ${file_path}
    ${file_directory}    ${file_name}=    String.Split String From Right    ${file_path}    /    1
    ${file_name_without_suffix}    ${file_suffix}=    String.Split String From Right    ${file_name}    .    1
    Run Keyword If    "${file_suffix}"=="zip"    OperatingSystem.Run And Return Rc And Output    echo yes|unzip ${file_path} -d ${file_directory}
    ${output_file_path}=    Set Variable    ${file_directory}/${file_name_without_suffix}.log
    OperatingSystem.File Should Exist    ${output_file_path}
    [Return]    ${output_file_path}

Get Startup Log Path On ASP
    ${cmd}=    Catenate    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1
    ...    bsh 1:${L2RT_NODE} find /tmp/ -name 'ASP-*7*0_startup.*'|awk -F '\n' '{print $1}'
    ${rc}    ${file_path}=    OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${startup_log}=    String.Get Line    ${file_path}    0
    Should Be True    "${rc}"=="0"
    [Return]    ${startup_log}

Copy File From ASP To FCT
    [Arguments]    ${file_path}
    ${cmd}=    Catenate    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1
    ...    rm /tmp/ASP-*_startup.*
    ${rc}    ${file_path_on_FCT}=    OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${file_directory}    ${file_name}=    String.Split String From Right    ${file_path}    /    1
    ${pure_file_name}    ${file_postfix}=    String.Split String From Right    ${file_name}    .    1
    ${file_path_zip}=     Set Variable    ${file_directory}/${pure_file_name}.zip
    ${cmd_unzip}=    Set Variable    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 bget 1:${L2RT_NODE} ${file_path} /tmp/
    ${cmd_zip}=    Set Variable    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 bget 1:${L2RT_NODE} ${file_path_zip} /tmp/
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${cmd_unzip}
    Run Keyword If    "${rc}"=="1"    OperatingSystem.Run And Return Rc And Output    ${cmd_zip}
    ${cmd}=    Catenate    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1
    ...    find /tmp/ -name 'ASP-*_startup.*'|awk -F '\n' '{print $1}'
    ${rc}    ${file_path_on_FCT}=    OperatingSystem.Run And Return Rc And Output    ${cmd}
    Should Be True    "${rc}"=="0"
    [Return]    ${file_path_on_FCT}

Copy File From FCT To Control PC
    [Arguments]    ${source_path}    ${destination_directory}
    ${cmd}=    Set Variable    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:${source_path} ${destination_directory}
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${cmd}
    Should Be True    "${rc}"=="0"
    ${file_directory}    ${file_name}=    String.Split String From Right    ${source_path}    /    1
    [Return]    ${destination_directory}/${file_name}

Add Prefix For File If Prefix Exist
    [Arguments]    ${file_path}    ${file_prefix}
    ${file_directory}    ${file_name}=    String.Split String From Right    ${file_path}    /    1
    ${output_file_path}=    Set Variable If    "${file_prefix}"!="${EMPTY}"
    ...    ${file_directory}/${file_prefix}_${file_name}    ${file_path}
    Run Keyword If    "${file_prefix}"!="${EMPTY}"    OperatingSystem.Move File    ${file_path}    ${output_file_path}
    OperatingSystem.File Should Exist    ${output_file_path}
    [Return]    ${output_file_path}

Ttitrace Filter Source Column Return Self Column
    [Arguments]    ${file_name}    ${source_column_name}    ${condition}=["0", ""]
    ...    ${operation}=except    ${remove_duplicate}=no
    [Documentation]    This keyword is used to filter ttitrace table, input one column, filter data, return result of itself.
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_name} | Yes | ttitrace file name with absolute path |
    ...    | ${source_column_name} | Yes | filterred column name |
    ...    | ${condition} | No | filterred value |
    ...    | ${operation} | No | make filterred value except or include, except,include |
    ...    | ${target_column_name} | No | return column name|
    ...    | ${remove_duplicate} | No | whether remove duplicated data in returned list,yes, no |
    ...    Examples:
    ...    | ${5qi1Prb_list}| Ttitrace Fiter Source Column Return Self Column | ./streaming_test_data/output_ul.csv | ulFdSchedData.numOf5qi1Prb |
    ...    | ["0", "", "0.0"] | except | yes |
    ${data_list}    TTITRACEANALYZER.Filter Source Column Return Self    ${file_name}    ${source_column_name}
    ...    ${condition}    ${operation}    ${remove_duplicate}
    [Return]    ${data_list}

Ttitrace Filter Source Column Return Other Column
    [Arguments]    ${file_name}    ${source_column_name}    ${condition}=["0", ""]
    ...    ${operation}=except    ${target_column_name}=""    ${remove_duplicate}=no
    [Documentation]    This keyword is used to filter ttitrace table, input one column, filter data, return filterred other column.
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_name} | Yes | ttitrace file name with absolute path |
    ...    | ${source_column_name} | Yes | filterred column name |
    ...    | ${condition} | No | filterred value |
    ...    | ${operation} | No | make filterred value except or include, except,include |
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

Format Tti In Snapshot Mode
    [Arguments]    ${input_csv_name}    ${output_csv_name}    ${filters}=${EMPTY}
    [Documentation]    This keyword is to convert tti collected by eventsCollect.sh(snapshot mode)
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${input_csv_name} | Yes | str, ${CURDIR}/TtiFiles/L2TtiTrace_EventsSnapshot.bin.01.dl.csv |
    ...    | ${output_csv_name} | Yes | str, ${CURDIR}/TtiFiles/tti_snapshot.csv |
    ...    | ${filters} | No | str with separator ;, dlFdSchedData;dlFlowControlData |
    ...
    ...    Examples:
    ...    | Format Tti In Snapshot Mode | ${input_csv_name} | ${output_csv_name} |
    ...    | Format Tti In Snapshot Mode | ${input_csv_name} | ${output_csv_name} | ${filters} |
    ...
    Run Keyword If    '${filters}'=='${EMPTY}'    TtiConvert.Format Tti No Filters    ${input_csv_name}    ${output_csv_name}
    ...    ELSE    TtiConvert.Format Tti With Filters    ${input_csv_name}    ${output_csv_name}    ${filters}

Format Tti In Stream Mode
    [Arguments]    ${input_csv_name}    ${output_csv_name}    ${filters}=${EMPTY}
    [Documentation]    This keyword is to convert tti collected by stream mode.
    ...    Parameters same as keyword: Format Tti In Snapshot Mode
    Run Keyword If    '${filters}'=='${EMPTY}'    TtiSMConvert.Format Tti Stream Mode No Filters    ${input_csv_name}    ${output_csv_name}
    ...    ELSE    TtiSMConvert.Format Tti Stream Mode With Filters    ${input_csv_name}    ${output_csv_name}    ${filters}

Check MCShark Version
    [Arguments]    ${sw_version}=${SW_VERSION_TOTAL}
    ${list_version}=    Split String    ${sw_version}    _
    ${rest}    ${last}=    Split String From Right    ${sw_version}    _    1
    ${new_version}=    Set Variable If    "${list_version}[0]"!="SBTS00" and "${list_version}[-1]"!="000000"
    ...    ${rest}_000000      ${sw_version}
    [Return]    ${new_version}

Get Tshark Version
    ${version}=    Run    tshark -v|grep TShark|grep -P v[0-9]+.[0-9]+ -o|cut -d "v" -f 2
    [Return]    ${version}

Download MCShark To UTE
    [Arguments]    ${sw_version}=${SW_VERSION_TOTAL}
    ${sw_version}=    Check MCShark Version    ${sw_version}
    ${cmd}=    Set Variable    wget -r -np -nH ${MCSHARK_URL}/${sw_version}/
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${cmd}
    Should Be True    "${rc}"=="0"    There is no MCShark downloaded! Please contact MCshark team!
    ${tashark_version}=    Get Tshark Version
    ${MCShark}=    Run    ls -1t ${EXECDIR}/artifactory/wslte5g_plugins-local/MCShark/${sw_version}/mcshark-${tashark_version}*bookworm.so
    ${MCShark_list}=    String.Split To Lines    ${MCShark}
    ${MCShark_newest}=    Set Variable    @{MCShark_list}[0]
    OperatingSystem.Run    sudo rm -f ${MCSHARK_PLUGIN}/${tashark_version}/epan/mcshark-*bookworm.so
    ${rc}=    OperatingSystem.Run And Return Rc    sudo cp ${MCShark_newest} ${MCSHARK_PLUGIN}/${tashark_version}/epan/
    Should Be True    "${rc}"=="0"    No MCSHark file is copied to the wireshark plugin folder

Copy Preference For MCShark
    [Arguments]    ${preference_file}
    #${preference_file}=    Set Variable    /home/ute/Downloads/preferences
    Run    sudo cp ${preference_file} /home/ute/.config/wireshark/preferences
    Run    sudo cp ${preference_file} /usr/share/wireshark/preferences

Convert BIP To CSV By MCShark
    [Arguments]    ${bip_file}    ${output_file}    ${filter}    ${csv_title_list}
    ${tashark_version}=    Get Tshark Version
    ${mcshark_file}    Set Variable    ${MCSHARK_PLUGIN}/${tashark_version}/epan/mcshark-*buster.so
    ${rc}    ${output}=    Run And Return Rc And Output    lsb_release -cs|grep bookworm
    Run Keyword If    '${output}'=='bookworm'    Set Suite Variable    ${mcshark_file}
    ...    ${MCSHARK_PLUGIN}/${tashark_version}/epan/mcshark-*bookworm.so
    ${res}    Run Keyword And Return Status    OperatingSystem.Should Exist    ${mcshark_file}
    Run Keyword If    '${res}'=='False'    Download MCShark To UTE
    ${csv_title}=    Set Variable
    FOR    ${column}   IN    @{csv_title_list}
        ${csv_title}=    Set Variable    ${csv_title} -e ${column}
    END
    ${cmd}=    Catenate    tshark -r ${bip_file} -Y '${filter}' -T fields -e _ws.col.No. -e _ws.col.Info
    ...    ${csv_title} -E header=y -E separator=, -E quote=d -E occurrence=a > ${output_file}
    OperatingSystem.Run    ${cmd}
    OperatingSystem.File Should Not Be Empty    ${output_file}    msg=No CSV file is converted! Please check whether filter message name is changed!

Convert Multi BIP Logs To Csv By MCShark
    [Arguments]    ${log_dir}    ${output_name_tag}    ${filter}    ${csv_title_list}    ${preference_file}=${EMPTY}
    [Documentation]    This keyword is to convert multi bip log to csv with preference
    ...
    ...    Examples:
    ...    | ${preference_file}    ${CURDIR}/temp/preferences_T_F_CA
    ...    | ${FILTER}             dci.dci01.CSIrequest == 1||uldata_puschreceivereq||uldata_puschreceiverespps
    ...    | @{csv_title_list}     3gpp.sfn    3gpp.slot    dci.dci01.CSIrequest    UlData_puschReceiveReqGrant_t.numOfUciCsiPart1Bits
    ...    |                UlData_puschReceiveReqGrant_t.uciOnly    UlData_UePuschReceiveRespPs_t.dtx
    ...    |                UlData_UePuschReceiveRespPs_t.csiPart1CrcCheck    UlData_UePuschReceiveRespPs_t.csiPart2CrcCheck
    ...    |                UlData_UePuschReceiveRespPs_t.dtxCsiPart1    UlData_UePuschReceiveRespPs_t.dtxCsiPart2
    ...    | Convert Multi BIP Logs To Csv By MCShark | ${preference_file} | ${CURDIR}/temp | bip_log_test | ${filter} | ${csv_title_list} |
    Run Keyword If    '${preference_file}'!='${EMPTY}'    Copy Preference For MCShark    ${preference_file}
    ${bip_names}    OperatingSystem.List Files In Directory    ${log_dir}   5GBipL2L1_filtering_off*.pcap*    ${True}
    FOR    ${index}    ${name}    IN ENUMERATE    @{bip_names}
        Convert BIP To CSV By MCShark    ${name}    ${log_dir}/${output_name_tag}_${index}.csv    ${filter}    ${csv_title_list}
        ${content}    Get File    ${log_dir}/${output_name_tag}_${index}.csv
        Append To File    ${log_dir}/${output_name_tag}.csv    ${content}
    END
    [Return]    ${log_dir}/${output_name_tag}.csv

A2A_Check_CSV_Table
    [Arguments]    ${ini_file}    ${check_csv_file}    ${log_path}=${OUTPUT_DIR}
    [Documentation]    This keyword is used to check ttitrace csv log, or bip csv log.
    ...    | Input Parameters | Man. | Description |
    ...    | ${ini_file} | Yes | The A2A's ini file. It is related with A2A csv file that shows the checkpoints.|
    ...    | ${check_csv_file} | Yes | In fact ,this keyword don't need this parameter,but it still needed fo the cases based on previous usage.|
    ...    | ${log_path} | Yes | Directory where to put the generated csv logs.|
    ...
    ...    Examples:
    ...    | A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_sinr.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/0/ |
    ${path_name}	${file_name}=    OperatingSystem.Split Path    ${check_csv_file}
    ${backup_file}=    OperatingSystem.Join Path    ${path_name}    backup_${file_name}
    OperatingSystem.Copy File    ${check_csv_file}    ${backup_file}
    CSV_PRE_DEAL.Delete Blank Space For Mcshark Sencond Column    ${backup_file}
    ...    ${check_csv_file}
    ta_a2a.Check Log With Au2anlysis    ${ini_file}    i    save_log_directory=${log_path}

A2A_Check_RRC_Log
    [Arguments]    ${ini_file}    ${check_egate_file}    ${log_path}=${OUTPUT_DIR}
    ta_a2a.Check Log With Au2anlysis    ${ini_file}    p    ${check_egate_file}
    ...    save_log_directory=${log_path}

Convert BIP To Json By MCShark
    [Arguments]    ${bip_file}    ${output_file}    ${filter}
    ${tashark_version}=    Get Tshark Version
    ${mcshark_file}    Set Variable    ${MCSHARK_PLUGIN}/${tashark_version}/epan/mcshark-*buster.so
    ${rc}    ${output}=    Run And Return Rc And Output    lsb_release -cs|grep bookworm
    Run Keyword If    '${output}'=='bookworm'    Set Suite Variable    ${mcshark_file}
    ...    ${MCSHARK_PLUGIN}/${tashark_version}/epan/mcshark-*bookworm.so
    ${res}    Run Keyword And Return Status    OperatingSystem.Should Exist    ${mcshark_file}
    Run Keyword If    '${res}'=='False'    Download MCShark To UTE
    ${cmd}=    Catenate    tshark -r ${bip_file} -Y '${filter}' -T > ${output_file}
    OperatingSystem.Run    ${cmd}
    OperatingSystem.File Should Not Be Empty    ${output_file}    msg=No json file is converted! Please check whether filter message name is changed!

Check Latest Egate Log With Message
    [Arguments]    ${msg_regexp}    ${times}=1    ${egate_file}=/opt/iphy/latest/egate_console.log
    [Documentation]    This keyword is to check special message in egate log.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | egate_file | Yes | the path of egate log |
    ...    | msg_regexp | Yes | the check point, message or regexp both ok |
    ...    | times | No | the times of check point repeat  |
    ...
    ...    | Examples: |
    ...    | Check Egate Log With Message | ${egate_file} | SystemInformationBlockType1 | 4 |
    ...
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${content}    OperatingSystem.Get File    path=${egate_file}
    @{content_split}    Split String    ${content}    sim_log_set flush
    ${length_1}    Get Length    ${content_split}
    FOR    ${index}    IN RANGE    ${length_1}    0    -1
        Log    ${content_split[${index}-1]}
        ${passed}    Run Keyword And Return Status    Should Be Equal As Strings    ${content_split[${index}-1]}    \n
        Continue For Loop If    ${passed}
        # @{split_content}    Split String    ${content_split[${index}-1]}    \n
        # ${line}    Get Match Count    ${split_content}    regexp=\\n
        # ${latest_content}    Set Variable If    ${line}>${3}    ${content_split[${index}-1]}    ${content}
        ${match_list}     Get Lines Containing String    ${content_split[${index}-1]}    ${msg_regexp}
        Log    ${match_list}
        ${repert_times}    Get Count    ${match_list}    ${msg_regexp}
        ${passed}    Run Keyword And Return Status    Should Be True    ${repert_times}>=${times}
        Exit For Loop If    ${passed}
    END
    
Check Egate Log With Message
    [Arguments]    ${egate_file}     ${msg_regexp}    ${times}=1
    [Documentation]    This keyword is to check special message in egate log.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | egate_file | Yes | the path of egate log |
    ...    | msg_regexp | Yes | the check point, message or regexp both ok |
    ...    | times | No | the times of check point repeat  |
    ...
    ...    | Examples: |
    ...    | Check Egate Log With Message | ${egate_file} | SystemInformationBlockType1 | 4 |
    ...
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${content}    OperatingSystem.Get File    path=${egate_file}
    ${match_list}     Get Lines Matching Regexp    ${content}    ${msg_regexp}    partial_match=true
    Log    ${match_list}
    ${repert_times}    Get Count    ${match_list}    ${msg_regexp}
    Should Be True    ${repert_times}>=${times}

Check Message For Egate Output
    [Arguments]    ${egate_output}    ${msg_regexp}    ${times}=1
    ${match_list}     Get Regexp Matches    ${egate_output}    ${msg_regexp}
    Log    ${match_list}
    ${repert_times}    Get Count    ${match_list}    ${msg_regexp}
    Should Be True    ${repert_times}>=${times}

Decode Timemarker Log To Csv
    [Arguments]    ${snapshot_log}    ${l2rt_instance_nodeid}    ${log_dir}=${TEST_LOG_DIRECTORY}
    [Documentation]    This keyword is to decode timemarker Lot To Csv
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${snapshot_log} | yes | the log saved by AAShell |
    ...    | ${l2rt_instance_nodeid} | yes | l2rt_instance_nodeID, such as 0x2732 |
    ...    | ${log_dir} | NO | the log directory for decodeed log , the default value is ${TEST_LOG_DIRECTORY} |
    ...    Examples:
    ...    | ${timemarker2_csv} | Decode Timemarker Log To Csv | ${CURDIR}/snapShot_gnb_aashell.zip | 0x2730 |
    ...    | ${fullpdumux_avg_task_duration} | Read Csv Columns | ${timemarker2_csv} | task duration (on exit) |
    ...    | ... | filter=(core=Core2)&(task=EO_L2_LO_ADD_GENERIC_DATA_TO_TB) | calculator=avg |
    ...
    Log To Console    \n*****Start to Decode Timemarker Log To Csv*****
    ${decode_tool_dir}    Set Variable    ~/Timeline_analyzer_V5.1/Tool/
    OperatingSystem.File Should Exist    ${snapshot_log}    msg=${snapshot_log} doesn't existed
    Run Keyword And Ignore Error    OperatingSystem.Run And Return Rc    rm -rf ${log_dir}/snapshot_log
    ${rc}    OperatingSystem.Run And Return Rc    unzip -o ${snapshot_log} -d ${log_dir}/snapshot_log
    Should Be Equal As Integers    ${rc}    0
    ${l2rt_instance_nodeid}    Remove String Using Regexp    ${l2rt_instance_nodeid}    0x
    ${time_string}    DateTime.Get Current Date    result_format=timestamp
    ${timestamp}    String.Replace String Using Regexp    ${time_string}    (-|:|\\.|\\s)    ${EMPTY}
    ${timemarker_file_path}    Set Variable    ${log_dir}/timemarker_log_${l2rt_instance_nodeid}_${timestamp}
    Create Directory    ${timemarker_file_path}
    ${passed}    Run Keyword And Return Status    Should Exist    ${log_dir}/snapshot_log/snapshot_file_list.txt
    ${timemarker_file}    Run Keyword If    '${passed}'=='True'    Get Timemarker File From Snapshot With Admin
    ...    ${log_dir}/snapshot_log    ${l2rt_instance_nodeid}    ${timemarker_file_path}
    ...    ELSE    Get Timemarker File From Snapshot With AAShell
    ...    ${log_dir}/snapshot_log    ${l2rt_instance_nodeid}    ${timemarker_file_path}
    ${decode_cmd}    Set Variable    ./run_L2_timeline_analyzer_linux_stats_only.sh ${timemarker_file_path}
    ${rc}    OperatingSystem.Run And Return Rc    cd ${decode_tool_dir};${decode_cmd}
    Should Be Equal As Integers    ${rc}    0
    ${csv_file}    Replace String    ${timemarker_file}    .txt    _L2STATS.csv
    [Return]    ${timemarker_file_path}/${csv_file}

Get Timemarker File From Snapshot With AAShell
    [Arguments]    ${snapshot_log_path}    ${l2rt_instance_nodeid}    ${timemarker_file_path}
    Log To Console    \n*****Get Timemarker File From Snapshot With AAShell*****
    OperatingSystem.Run    mv ${snapshot_log_path} ${snapshot_log_path}_aashell
    ${snapshot_log_path}    Set Variable    ${snapshot_log_path}_aashell
    ${rc}    ${timemarker_file}=    OperatingSystem.Run And Return Rc And Output
    ...    ls -lrt ${snapshot_log_path} |grep -i "timemarker" | grep -i "${l2rt_instance_nodeid}"|awk '{print $NF}'
    Should Be Equal As Integers    ${rc}    0
    ${rc}    OperatingSystem.Run And Return Rc
    ...    cp ${snapshot_log_path}/${timemarker_file} ${timemarker_file_path}
    Should Be Equal As Integers    ${rc}    0
    Log To Console    TimeMarkerSnapshot File Name: ${timemarker_file}
    [Return]    ${timemarker_file}

Get Timemarker File From Snapshot With Admin
    [Arguments]    ${snapshot_log_path}    ${l2rt_instance_nodeid}    ${timemarker_file_path}
    Log To Console    \n*****Get Timemarker File From Snapshot With Admin*****
    OperatingSystem.Run    mv ${snapshot_log_path} ${snapshot_log_path}_admin
    ${snapshot_log_path}    Set Variable    ${snapshot_log_path}_admin
    ${content}    Get File    ${snapshot_log_path}/snapshot_file_list.txt
    ${con_list}    Split String    ${content}    \n\n
    ${regexp_cmd}    Set Variable    (BTS.*.zip):.*${l2rt_instance_nodeid}\[\\S\]+TimeMarkerSnapshot
    FOR    ${con}    IN    @{con_list}
    ${new}    Replace String    ${con}    \n    ${EMPTY}
    ${ret}    Run Keyword And Ignore Error    Should Match Regexp    ${new}    ${regexp_cmd}
    Exit For Loop If    '${ret[0]}'=='PASS'
    END
    ${regexp_cmd}    Set Variable    (.*).zip:.*[\\s](.*${l2rt_instance_nodeid}\[\\S\]+TimeMarkerSnapshot).txt.xz
    ${match_list}    Get Regexp Matches    ${new}    ${regexp_cmd}    1
    ${zip_file}    Set Variable    ${match_list[0]}
    ${match_list}    Get Regexp Matches    ${new}    ${regexp_cmd}    2
    ${timemarker_file}    Set Variable    ${match_list[0]}
    ${rc}    OperatingSystem.Run And Return Rc    unzip -o ${snapshot_log_path}/${zip_file}.zip -d ${snapshot_log_path}/${zip_file}
    Should Be Equal As Integers    ${rc}    0
    ${rc}    OperatingSystem.Run And Return Rc    xz -d ${snapshot_log_path}/${zip_file}/${timemarker_file}.txt.xz
    Should Be Equal As Integers    ${rc}    0
    ${rc}    OperatingSystem.Run And Return Rc
    ...    cp ${snapshot_log_path}/${zip_file}/${timemarker_file}.txt ${timemarker_file_path}
    Should Be Equal As Integers    ${rc}    0
    Log To Console    TimeMarkerSnapshot File Name: ${timemarker_file}.txt
    [Return]    ${timemarker_file}.txt

Get Crnti From Egate Log
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is to check special message in egate log.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | egate_file | Yes | the path of egate log |
    ...    | msg_regexp | Yes | the check point, message or regexp both ok |
    ...    | times | No | the times of check point repeat  |
    ...
    ...    | Examples: |
    ...    | Check Egate Log With Message | ${egate_file} | SystemInformationBlockType1 | 4 |
    ...
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${content}    OperatingSystem.Get File    path=${WTS_DIR}/egate_console.log
    ${regexp_cmd}    Set Variable    UE${ue_id}:\\sUE performed\\s(?:UNKNOWN_ATTACH_TYPE)?(?:EPS_ATTACH)?\\s\\(crnti:\\s(?P<CRNTI>\\d+)
    ${crnti_list}    Get Regexp Matches    ${content}    ${regexp_cmd}    CRNTI
    [Return]    ${crnti_list[-1]}

Delete RD BTS Counter xml
    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}
    SSH.Send Command    rm /tmp/RD.BTS*
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect

Save RD BTS Counter xml And Gunzip
    [Arguments]    ${log_dir}    ${counter_refresh_period}=5min
    Create Directory    ${log_dir}
    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=${counter_refresh_period}
    Log To Console    to reach next pm counter update time, need to wait ${time}...
    Sleep    ${time}    wait for pm counter file updated.
    Sleep    2s    wait pm counter file generated stable.
    OperatingSystem.Run    sshpass -p ${GNB_ASIK.password} scp ${GNB_ASIK.username}@${GNB_ASIK.ip}:/tmp/RD.BTS* ${log_dir}/
    OperatingSystem.Run And Return Rc And Output    gunzip ${log_dir}/RD.BTS*.gz

Get RD Counter Value From RD BTS xml
    [Arguments]    ${log_dir}    ${counter_name}    ${counter_path}    ${measurementType}
    [Documentation]    This keyword is to
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | YES | the path for log files existed |
    ...    | ${counter_name} | YES | the counter name in RD BTS xml, such as SCELL_UL_SUSPEND_RLQ |
    ...    | ${counter_path} | YES | the path for counter, such as PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1 |
    ...    | ${measurementType} | YES | measurementType for this counter, such as NCADU |
    ...
    ${file_list}    List Files In Directory    ${log_dir}    pattern=RD.BTS*.xml
    ${counter_value_list}    Create List
    :FOR    ${file}    IN    @{file_list}
        ${counter_value}    tak_xml.Read Xml    ${log_dir}/${file}
        ...    text|//DN[text()\='${counter_path}']/../..//*[@measurementType\='${measurementType}']/${counter_name}
        ${status}    Run Keyword And Return Status    Should Not Be Empty    ${counter_value}
        Run Keyword If    "${status}"=="${True}"    Append To List    ${counter_value_list}    ${counter_value}
    END
    [Return]    ${counter_value_list}

Check RD Counter Max Value From RD BTS xml
    [Arguments]    ${counter_name}    ${counter_path}    ${measurementType}    ${min_value}=${empty}    ${max_value}=${empty}
    ...    ${log_dir}=${TEST_LOG_Directory}
    [Documentation]    This keyword is to check single RD pm counter value with counter path from RD BTS xml
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_name} | Yes | counter name which want to get the value |
    ...    | ${counter_path} | Yes | counter path which display in admin but not includ counter name |
    ...    | ${measurementType} | Yes | measurementType for this counter |
    ...    | ${min_value} | No | the expected min value, the default value is ${empty}, if not empty, counter value should bigger than this value |
    ...    | ${max_value} | No | the expected max value, the default value is ${empty}, if not empty, counter value should smaller than this value |
    ...
    ...    Examples:
    ...    | Check RD Counter Max Value From RD BTS xml | SCELL_UL_SUSPEND_RLQ | PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1 | NCADU | max_value=350 |
    ...    | Check RD Counter Max Value From RD BTS xml | SCH_SUBCELL_PUCCH_NRT | PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1 | NCELA | min_value=-1 |
    ...    | Check RD Counter Max Value From RD BTS xml | DL_NUM_ROHC_CONTEXTS_REUSED | PLMN-PLMN/MRBTS-1/NRBTS-1 | PDCP2 | min_value=20 |
    ...    | ... |  max_value=1000 |
    ${value_list}    Get RD Counter Value From RD BTS xml    ${log_dir}    ${counter_name}    ${counter_path}    ${measurementType}
    ${counter_value}    Evaluate    max(map(int,${value_list}))
    Run Keyword If    '${min_value}'!='${empty}' and '${max_value}'!='${empty}'    Should be True    ${min_value}<=${counter_value}<=${max_value}
    Run Keyword If    '${min_value}'=='${empty}' and '${max_value}'!='${empty}'    Should be True    ${counter_value}<=${max_value}
    Run Keyword If    '${min_value}'!='${empty}' and '${max_value}'=='${empty}'    Should be True    ${min_value}<=${counter_value}
    ute_reporting_portal.Report Pm Counter      ${counter_name}    ${counter_value}    Passed

Check Multi RD Counters Max Value From RD BTS xml
    [Arguments]    ${counter_info_list}    ${log_dir}=${TEST_LOG_Directory}
    [Documentation]    This keyword is to check multi RD pm counters with counter path from RD BTS xml
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_info_list} | Yes | the item is a dictionary, include keys:counter_name,counter_path,measurementType,min_value/max_value |
    ...    | ${log_dir} | No | the directory to save RD BTS xml, the default value is ${TEST_LOG_Directory} |
    ...
    ...    Examples:
    ...    *** Variables ***
    ...    &{counter1_info}    counter_name=SCELL_UL_SUSPEND_RLQ    counter_path=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...     ...    measurementType=NCADU    max_value=5
    ...    &{counter2_info}    counter_name=SCH_SUBCELL_PUCCH_NRT    counter_path=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...     ...    measurementType=NCELA    min_value=0
    ...    &{counter3_info}    counter_name=DL_NUM_ROHC_CONTEXTS_REUSED    counter_path=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    ...    measurementType=PDCP2    min_value=0    max_value=10
    ...    @{counter_list}    ${counter1_info}    ${counter2_info}    ${counter3_info}
    ...    Check Multi RD Counters Max Value From RD BTS xml    ${counter_list}
    FOR    ${counter_info}    IN    @{counter_info_list}
        ${min_value_status}    Run Keyword And Return Status    Dictionary Should Contain Key    ${counter_info}    min_value
        Run Keyword If    '${min_value_status}'=='False'    Set To Dictionary    ${counter_info}    min_value    ${empty}
        ${max_value_status}    Run Keyword And Return Status    Dictionary Should Contain Key    ${counter_info}    max_value
        Run Keyword If    '${max_value_status}'=='False'    Set To Dictionary    ${counter_info}    max_value    ${empty}
        Check RD Counter Max Value From RD BTS xml    ${counter_info.counter_name}    ${counter_info.counter_path}
        ...    ${counter_info.measurementType}    ${counter_info.min_value}    ${counter_info.max_value}    ${log_dir}
    END
