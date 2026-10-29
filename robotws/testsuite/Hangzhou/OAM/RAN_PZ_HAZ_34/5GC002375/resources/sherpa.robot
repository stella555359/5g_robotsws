*** Settings ***
Documentation   This is common keyword for 5GC001681 cases coam parts.
...              Author: Han Ruiyu
...              Contact: ruiyu.han@nokia-sbell.com
...              Squard: HZ SG7
Library    OperatingSystem
Library   Collections
Library   String
Library    taf.transport.ssh   WITH NAME   csn
Variables   ../libraries/sherpa_server_1.py
Library     ../libraries/snapshot_files.py
Resource   decode.robot



*** Keywords ***
Download Earlist CSV File in TAF
     [Arguments]    ${pcap_ip}
    ${file_list}    Get and Upload Files Needs Decode    ip=${pcap_ip}
    should not be empty  ${file_list}
    ${earlist_file}    Get Earlist Pcap File in Directory   ${file_list}
    Log to console   Start decode files
    Csn.Connect to   hostname=${sherpa_server_ip}    username=${sherpa_server_username}    password=${sherpa_server_password}
    ...    alias=sherpa_decode
    csn.Execute   command=ps -ef | grep csv | awk '{print $2}' | xargs kill -9   connection=sherpa_decode
    csn.Execute    command=${Sherpa_decode}${earlist_file}   connection=sherpa_decode
    Sleep   1min
#    csn.Download File   remote_path=${sherpa_server_local}/Sherpa_${csvname}.csv   local_path=${OUTPUT_DIR}/Sherpa_${csvname}.csv
#    ...   connection=sherpa_decode
#    RUN    rm `ls ${asik_addr}_*.pcap|egrep -v ${earlist_file}`
    Log to console   sherpa can be decoded
    [Teardown]   csn.Disconnect   connection=sherpa_decode

Copy CSV File To TAF
     [Arguments]    ${csvname}    ${file}
    Log to console   Start decode files
    Csn.Connect to   hostname=${sherpa_server_ip}    username=${sherpa_server_username}    password=${sherpa_server_password}
    ...    alias=sherpa_decode
    csn.Execute   command=ps -ef | grep csv | awk '{print $2}' | xargs kill -9   connection=sherpa_decode
    csn.Execute    command=${Sherpa_decode}${file}   connection=sherpa_decode
    Sleep   1min
    csn.Download File   remote_path=${sherpa_server_local}/Sherpa_${csvname}.csv   local_path=${OUTPUT_DIR}/Sherpa_${csvname}.csv
    ...   connection=sherpa_decode
    Log to console   Sherpa_${csvname}.csv donwloaded for ${file}
    [Teardown]   csn.Disconnect   connection=sherpa_decode

Convert Complement of sherpa value
    [Arguments]    ${sherpa_value}    ${defined_info}    ${bitlenth}
    ${convert_tshark_value}    run keyword if  "-" in '${sherpa_value}'   evaluate    int(2**${bitlenth}-abs(${sherpa_value}*10))
    ...   ELSE     _Tbsize_Log_Enhance    ${sherpa_value}    ${defined_info}
     ${convert_tshark_value}    convert to string    ${convert_tshark_value}
    [Return]    ${convert_tshark_value}

_Tbsize_Log_Enhance
    [Arguments]    ${sherpa_value}    ${defined_info}
    ${convert_value}   run keyword if   '${defined_info}'=='tbSize'    evaluate    int(${sherpa_value})
    ...   ELSE    evaluate    int(${sherpa_value}*10)
    [Return]    ${convert_value}

Check Defined Trace Value Correct in Sherpa log
    [Arguments]    ${csvname}    ${defined_event}    ${defined_info}    ${bitlenth}    ${tshark_value}
    Download Earlist CSV File in TAF    ${csvname}
    ${row}    wait until keyword succeeds   1m    20s     get_one_row_as_defined_str
    ...    csv_filename=${OUTPUT_DIR}/Sherpa_${csvname}.csv    str=${defined_event}
    ${value}    Fetch From Right    ${info}    ${defined_info}=
    ${value}    run keyword if  ";" in "${value}"     Fetch From Left    ${value}    ;
    ...   ELSE IF  "," in "${value}"    Fetch From Left    ${value}    ,
    ...   ELSE     Fetch From Left    ${value}    ${SPACE}
    ${value}    Remove String Using Regexp    ${value}    \\D*\\Z
    ${convert_tshark_value}    Convert Complement of sherpa value    ${value}    ${defined_info}    ${bitlenth}
    should be equal    ${convert_tshark_value}    ${tshark_value}

Check Defined Trace Included in Sherpa log
    [Arguments]    ${csvname}    ${defined_event}    ${defined_info}
    Download Earlist CSV File in TAF    csvname=${csvname}
    ${row}    wait until keyword succeeds   1m    20s     get_one_row_as_defined_str
    ...    csv_filename=${OUTPUT_DIR}/Sherpa_${csvname}.csv    str=${defined_event}
    ${find_flag}    set variable    ${False}
    ${find_flag}   run keyword if   '${defined_info}' in '${row}'    set variable    ${True}
    run keyword if    '${find_flag}' =='${False}'    FAIL    [ERROR]cannot find defined trace in ${defined_event} at ${csvname}!

Check Defined Msg Included in Sherpa log
    [Arguments]    ${csvname}    ${defined_event}
    Download Earlist CSV File in TAF    csvname=${csvname}
    ${row}    wait until keyword succeeds   1m    20s     get_one_row_as_defined_str
    ...    csv_filename=${OUTPUT_DIR}/Sherpa_${csvname}.csv    str=${defined_event}

Get Tshark Filter from Sherpa Log
    [Arguments]     ${csvname}    ${defined_event}
    Download Earlist CSV File in TAF    csvname=${csvname}
    ${row}    wait until keyword succeeds   1m    20s     get_one_row_as_defined_str
    ...    csv_filename=${OUTPUT_DIR}/Sherpa_${csvname}.csv    str=${defined_event}
    ${row_0_split}    Split String    ${row}    ;
    ${traceSeqNum}    set variable    ${row_0_split[3]}
    ${utcTimeStampMicro}    Fetch From Right    ${row_0_split[2]}    .
    [Return]    ${traceSeqNum}    ${utcTimeStampMicro}

Clean Pcap Log in Sherpa Server
    Csn.Connect to   hostname=${sherpa_server_ip}    username=${sherpa_server_username}    password=${sherpa_server_password}
    ...    alias=sherpa_decode
    ${search_regex}   Join Path   ${sherpa_server_local}   ${source_ip}
    csn.Execute   command=rm -f ${search_regex}*   connection=sherpa_decode
    sleep   5s
    ${file_clear}   csn.Execute   command=ls ${search_regex}*   connection=sherpa_decode
    ${cp1}   Run Keyword and Return Status   should be empty    ${file_clear}
    ${cp2}   Run Keyword and Return Status   should contain    ${file_clear}   No such file or directory
    Should Be True   ${cp1} or ${cp2}
    [Teardown]   csn.Disconnect   connection=sherpa_decode

