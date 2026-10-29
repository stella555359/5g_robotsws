*** Settings ***
Documentation    This is common keywords for tti log related cases
...              Please do not modify the file without notification to author
...              Author: zhihao.shi
...              Contact: zhihao.shi@nokia-sbell.com
...              Squard: HZ SG4

Library     OperatingSystem
Library     String
Library     BuiltIn
Library     taf.transport.ssh    WITH NAME    csn
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/check_csv_log.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot

*** Variables ***
${WFT_PATH}           https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build

*** Keywords ***
download and unzip pstools
    [Documentation]
    ...    *****************
    ...    update 200 OK to 200, check updated ticket: https://jiradc.ext.net.nokia.com/browse/WESTLAKE-10409
    [Arguments]    ${SW}    ${tool_path}=/home/ute/tti_tool
    log to console    download and unzip pstools
    @{split_version}    string.split string    ${SW}    separator=_
    ${stream}    set variable     ${split_version}[0]
    ${status}    run keyword and return status     Should contain    ${SW}    ENB_9999
    ${sw_version}   run keyword if    '${status}' == 'True'    Replace String    ${SW}    ${stream}    SBTS00
    ...           ELSE    set variable     ${SW}
    ${stream_version}   set variable if      '${status}' == 'True'    SBTS00    ${stream}
    ${output}=   OperatingSystem.Run   command=rm -rf ${tool_path}
	${len}    get length    ${output}
    should be equal as numbers    ${len}    ${0}
    ${output}=   OperatingSystem.Run
    ...    command=mkdir ${tool_path};cd ${tool_path};wget ${WFT_PATH}/${stream_version}/${sw_version}/${sw_version}_pstools.zip
    should contain    ${output}   200    msg=Download ${sw_version}_pstools.zip failed
    Sleep  2
    OperatingSystem.Run   command=cd ${tool_path};unzip ${sw_version}_pstools.zip
    directory should exist    path=${tool_path}/pscli
    directory should exist    path=${tool_path}/TtiTracer

start to captured tti log
    [Arguments]    ${eNB_IP_Addr}    ${captured_time}=30    ${tool_path}=/home/ute/tti_tool
    log to console    \n start to captured tti log
    ${file_path}    set variable    ${tool_path}/TtiTracer/onlineTtiStream
    ${tti_cmd}    set variable  ./onlineTtiStream -i 10.68.89.34 -p toor4nsn@oZPS0POrRieRtu -c 0x1238 -m 5 -o ../
    ${cmd}    set variable
    ...    cd ${file_path};nohup ${tti_cmd} > output.log 2>&1 &
    OperatingSystem.Run    command=${cmd}
    sleep    ${captured_time}
    OperatingSystem.Run    command=ps -ef | grep -v grep | grep onlineTtiStream|awk '{print $2}'|xargs kill -2
    OperatingSystem.Run    command=cd ${tool_path}/TtiTracer/;./ParseTtitraceAuto.py

check dl column values in tti csv file
    [Arguments]    ${column_index}=${252}    ${column_value}=Pair    ${tool_path}=/home/ute/tti_tool
    log to console   \n check DL column(IR:ETtiTraceDlParUe_muStatus) values in tti csv file
    ${csv_file_list}    get tti csv file list    grep=dl
    FOR    ${file_name}    IN    @{csv_file_list}
        ${file_path}    set variable    ${tool_path}/TtiTracer/${file_name}
        ${matrix}    check_csv_log.read_csv_file_into_matrix    file_path=${file_path}
        ${column_list}    check_csv_log.get_column_from_matrix    matrix=${matrix}[2:]    column_nubmer=${column_index}
        ${Len}    Get Length    ${column_list}
        ${pari_num}    Count Values In List    ${column_list}    ${column_value}
        ${p_value}    Evaluate    "%.4f" % (${pari_num}/${Len})
        ${per_value}    Evaluate    ${p_value}*100
        log to console   \n DL Pari Percent:${per_value}%
        should be true      ${p_value} > 0.99
    END

check ul column values in tti csv file
    [Arguments]    ${column_index}=${275}    ${column_value}=0    ${tool_path}=/home/ute/tti_tool
    log to console   \n check UL column(JO:ETtiTraceUlParUe_virtualUeIndex) values in tti csv file
    ${csv_file_list}    get tti csv file list    grep=ul
    Run Keyword If  '${csv_file_list}[0]' == ''   log to console   \n no UL CSV LOG Generation
    return from keyword if     '${csv_file_list}[0]' == ''
    FOR    ${file_name}    IN    @{csv_file_list}
        ${file_path}    set variable    ${tool_path}/TtiTracer/${file_name}
        ${matrix}    check_csv_log.read_csv_file_into_matrix    file_path=${file_path}
        ${column_list}    check_csv_log.get_column_from_matrix    matrix=${matrix}[2:]    column_nubmer=${column_index}
        ${column_list}    Remove Duplicates    ${column_list}
        Remove values from list  ${column_list}  -
        ${Len}    Get Length    ${column_list}
        log to console   \n UL Pari :list Length:${Len} and list[0] value:${column_list}[0]
        should be true      ${Len} == 1
        Should be equal as strings    ${column_list}[0]    ${column_value}
    END

get tti csv file list
    [Arguments]  ${grep}=${dl}    ${tool_path}=/home/ute/tti_tool
    ${file_info}   Run    command=ls ${tool_path}/TtiTracer | grep csv | grep -v harq | grep _${grep}_
    ${file_List}   Split String  ${file_info}   \n
    [Return]  ${file_List}
