*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Samik Sarkar
...              :contact: samik.sarkar@nokia.com
*** Keywords ***
Convert Pcap To Sherpa Csv
    [Arguments]    ${log_dir}=${TEST_LOG_DIRECTORY}
    [Documentation]    This Keyword Is To Convert Pcap Log To Sherpa Csv Log
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | No | the folder path to store log, the default value is ${TEST_LOG_DIRECTORY} |
    ...
    Makesure UTEVM Sherpa Tool Can Work
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
    [Arguments]    ${log_path}=${OUTPUT_DIR}    ${names}=l2stream3_ttitrace
    ${file_path}=    Set Variable    ${OUTPUTDIR}/${SUITE_NAME}/${TEST_NAME}/${names}/tcpdump_ttitrace/tcpdump_ttitrace.pcap
    OperatingSystem.Run    mkdir -p ${log_path}; cp -r "${file_path}" ${log_path}
    EVENTDECODER.Create Eventdecoder Converter
    ...  name=converter
    ...  input_file_path=${file_path}
    ...  output_file_format=excelCsv
    ...  excel_csv_options=-s 0
    EVENTDECODER.Convert
    ...  name=converter
    OperatingSystem.Run    mkdir -p ${log_path}
    OperatingSystem.Run    cd ${log_path}
    OperatingSystem.Run    ls -ltr
    OperatingSystem.Run    cp ${EXECDIR}/output_dl.csv ${log_path};cp ${EXECDIR}/output_ul.csv ${log_path}

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
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    find ${log_path} -maxdepth 1 -name Gnb*syslog.tar.gz
    Run Keyword If    "${output}"==""    Fail     msg=There is no Gnb*syslog.tar.gz caught!!!
    Run Keyword If    "${output}"!=""    Filter Gnb_syslog    ${output}    ${filter_message_file}    ${output_file_path}


Filter Gnb_syslog
    [Arguments]    ${output}    ${filter_message_file}    ${output_file_path}
    ${files_list}=    String.Split To Lines    ${output}
    FOR    ${file}    IN    @{files_list}
         ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    tar -xzvf ${file}
         Log    ${output}       INFO
         Filter ERR WRN Message From Syslog By One File    ${output}    ${filter_message_file}    ${output_file_path}
    END
    ${status}=    Run Keyword And Return Status    File Should Be Empty    ${output_file_path}
    Run Keyword If    "${status}"=="${False}"    Show Fatal Log    ${output_file_path}
    Run Keyword If    "${status}"=="${False}"    Fail     msg=There are fatal errors in Gnb syslog!!!

Show Fatal Log
    [Arguments]    ${output_file}
    ${output}=    TxtConfig.Get File
        Log    ---In ${output_file}:---${output}    WARN

Filter ERR WRN Message From Syslog By One File
    [Arguments]    ${log_file}    ${filter_message_file}    ${output_file}
    [Documentation]    This keyword is used to filter error and warnning message from one file.
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_file} | Yes | log file which needs to be filterred. |
    ...    | ${filter_message_file} | Yes | txt file which contains filterred message |
    ...    | ${output_file} | Yes | txt file which contains output message |
    ...    Examples:
    ...    | Filter ERR WRN Message From Syslog By One File | ${CURDIR}/syslog.txt    ${CURDIR}/filter_log.txt    ${CURDIR}/output_log.txt |
    OperatingSystem.File Should Exist    ${filter_message_file}
    ${content}=    TxtConfig.Get File
    ${content_list}=    String.Split To Lines    ${content}
    FOR    ${filter_item}    IN    @{content_list}
         OperatingSystem.Run And Return Rc And Output    grep ${filter_item} ${log_file}>>${output_file}
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
    @{column_name}    Create List    UlData_PucchReceiveRespHarqD.ackNack.ackNack_item_0
    ...    UlData_PucchReceiveRespHarqD.pucchResources_item_175.dtx
    ${bip_names}    OperatingSystem.List Files In Directory    ${bip_log_dir}    5GBipL2L1_filtering_off*.pcap*    ${True}
    FOR    ${index}    ${name}    IN ENUMERATE    @{bip_names}
         Convert BIP Log Pcap To Csv    ${name}    ${filter}    ${column_name}    dl_nack_${index}
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
    @{column_name}    Create List    UlData_PuschReceiveRespHarqU.grants_item_0.crc    UlData_PuschReceiveRespHarqU.grants_item_0.dtx
    ${bip_names}    OperatingSystem.List Files In Directory    ${bip_log_dir}    5GBipL2L1_filtering_off*.pcap*    ${True}
    FOR    ${index}    ${name}    IN ENUMERATE    @{bip_names}
         Convert BIP Log Pcap To Csv    ${name}    ${filter}    ${column_name}    ul_nack_${index}
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
    ${total_reg}    Set Variable    UlData_PuschReceiveRespHarqU\\",+\\"(?P<CRC>\\d+)\\",+\\"(?P<DTX>\\d+)\\"
    ${matches}    String.Get Regexp Matches    ${content}    ${total_reg}    CRC    DTX
    ${count}    Get Length    ${matches}
    [Return]    ${count}

Get Total Failed UlDataPuschReceiveRespHarqU Message Number
    [Arguments]    ${content}
    ${failed_reg}    Set Variable    UlData_PuschReceiveRespHarqU\\",\\"([1-9]+|0\\",\\"[1-9]+\\")
    ${matches}    String.Get Regexp Matches    ${content}    ${failed_reg}
    ${count}    Get Length    ${matches}
    [Return]    ${count}

Get Total UlDataPucchReceiveRespHarqD Message Number
    [Arguments]    ${content}
    ${one_msg_reg}    Set Variable    UlData_PucchReceiveRespHarqD\\",+\\"0x\\d+\\"
    ${multi_msg_reg}    Set Variable    UlData_PucchReceiveRespHarqD.*0x\\d+,0x\\d+.*[01],[01]\\"
    ${matches1}    String.Get Regexp Matches    ${content}    ${one_msg_reg}
    ${count1}    Get Length     ${matches1}
    ${matches2}    String.Get Regexp Matches    ${content}    ${multi_msg_reg}
    ${count2}    Get Length     ${matches2}
    ${total}    Evaluate    ${count1} + ${count2 * 2}
    [Return]    ${total}

Get Total Failed UlDataPucchReceiveRespHarqD Message Number
    [Arguments]    ${content}
    ${one_msg_fail_reg}    Set Variable    lData_PucchReceiveRespHarqD\\",+\\"(?:0x0+\\"|0x\\d+\\",\\"[1-9])
    ${multi_msg_fail_reg}    Set Variable    UlData_PucchReceiveRespHarqD.*(?P<Nack1>0x\\d+),(?P<Nack2>0x\\d+).*(?P<dtx1>[01]),(?P<dtx2>[01])\\"
    ${matches1}    String.Get Regexp Matches    ${content}    ${one_msg_fail_reg}
    ${count1}    Get Length     ${matches1}
    ${matches2}    String.Get Regexp Matches    ${content}    ${multi_msg_fail_reg}    Nack1    dtx1
    ${matches3}    String.Get Regexp Matches    ${content}    ${multi_msg_fail_reg}    Nack2    dtx2
    ${count2}    Set Variable    0
    FOR    ${values}    IN    @{matches2}    @{matches3}
         ${nack_val}    Convert To Integer    ${values[0]}
         ${dtx_val}    Convert To Integer    ${values[1]}
         ${res1}    Run Keyword And Return Status    Should Be Equal As Integers    ${nack_val}    0
         ${res2}    Run Keyword And Return Status    Should Be Equal As Integers    ${dtx_val}    1
         ${count2}    Run Keyword If    ${res1}==${True} or ${res2}==${True}    Evaluate    ${count2}+1    ELSE    Evaluate    ${count2}+0
    END
    ${total}    Evaluate    ${count1}+${count2}
    [Return]    ${total}

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
    log to console      ${file_directory}

Unzip Log If Log Suffix Is zip
    [Arguments]    ${file_path}
    ${file_directory}    ${file_name}=    String.Split String From Right    ${file_path}    /    1
    ${file_name_without_suffix}    ${file_suffix}=    String.Split String From Right    ${file_name}    .    1
    Run Keyword If    "${file_suffix}"=="zip"    OperatingSystem.Run And Return Rc And Output    echo yes|unzip ${file_path} -d ${file_directory}
    ${output_file_path}=    Set Variable    ${file_directory}/${file_name_without_suffix}.log
    OperatingSystem.File Should Exist    ${output_file_path}
    [Return]    ${output_file_path}
    log to console      ${file_directory}

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
    log to console      ${file_directory}

Copy File From FCT To Control PC
    [Arguments]    ${source_path}    ${destination_directory}
    ${cmd}=    Set Variable    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:${source_path} ${destination_directory}
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${cmd}
    Should Be True    "${rc}"=="0"
    ${file_directory}    ${file_name}=    String.Split String From Right    ${source_path}    /    1
    [Return]    ${destination_directory}/${file_name}
    log to console      ${file_directory}

Add Prefix For File If Prefix Exist
    [Arguments]    ${file_path}    ${file_prefix}
    ${file_directory}    ${file_name}=    String.Split String From Right    ${file_path}    /    1
    ${output_file_path}=    Set Variable If    "${file_prefix}"!="${EMPTY}"
    ...    ${file_directory}/${file_prefix}_${file_name}    ${file_path}
    Run Keyword If    "${file_prefix}"!="${EMPTY}"    OperatingSystem.Move File    ${file_path}    ${output_file_path}
    OperatingSystem.File Should Exist    ${output_file_path}
    [Return]    ${output_file_path}
    log to console      ${file_directory}

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

Download MCShark To UTE
    [Arguments]    ${sw_version}=${SW_VERSION_TOTAL}
#    ${sw_version}=    Set Variable     SBTS21B_ENB_0000_000404_000000
    ${sw_version}=    Check MCShark Version    ${sw_version}
    ${cmd}=    Set Variable    wget -r -np -nH https://artifactory-hz1.int.net.nokia.com/artifactory/mcshark-local/${sw_version}/
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${MCShark}=    Run    ls ${EXECDIR}/artifactory/mcshark-local/${sw_version}/mcshark-*buster.so
    Run    sudo cp ${MCShark} /usr/lib/x86_64-linux-gnu/wireshark/plugins/3.4/epan/

Copy Preference For MCShark
    [Arguments]    ${preference_file}
    #${preference_file}=    Set Variable    /home/ute/Downloads/preferences
    Run    sudo cp ${preference_file} /home/ute/.config/wireshark/preferences
    Run    sudo cp ${preference_file} /usr/share/wireshark/preferences

Convert BIP To CSV By MCShark
    [Arguments]    ${bip_file}    ${output_file}    ${filter}    ${csv_title_list}
    Download MCShark To UTE
    ${csv_title}=    Set Variable
    FOR    ${column}   IN    @{csv_title_list}
        ${csv_title}=    Set Variable    ${csv_title} -e ${column}
    END
    ${cmd}=    Catenate    tshark -r ${bip_file} -Y '${filter}' -T fields -e _ws.col.No. -e _ws.col.Info
    ...    ${csv_title} -E header=y -E separator=, -E quote=d -E occurrence=a > ${output_file}
    OperatingSystem.Run    ${cmd}

A2A_Check_CSV_Table
    [Arguments]    ${ini_file}    ${check_csv_file}    ${log_path}=${OUTPUT_DIR}
    ta_a2a.Check Log With Au2anlysis    ${ini_file}    i    ${check_csv_file}
    ...    save_log_directory=${log_path}
