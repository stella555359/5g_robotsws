*** Settings ***
Documentation    This case is a tool for capture logs automatically
...    support log type: btslog,sherpa,ttitrace,bip,snapshot,egate,startup,wireshark
...    usage: mybot -v log_type:btslog,ttitrace,bip,emil manual_collect_log_all.robot
...    detailed cmd: pybot -L trace -V /home/ute/testline_configuration/6137TL253/ -d /home/ute/test_logs//test_logs202208040744AM/
...    -v log_type:btslog /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1//CUDU_L2/small_case/manual_collect_log_all.robot

Resource         ./../common_setup_teardown.robot
#Suite Setup      Run    sh /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/tools/local_testline/update_ttitrace.sh
#Test Teardown    Zip Log

*** Variables ***
${log_type}      btslog,sherpa,ttitrace,bip,emil,snapshot,egate,startup,wireshark,pmcounter,resource
@{LOG_NAME_LIST}    btslog
${STOP_CASE_FILE}    /home/ute/delete_me_to_stop_case.txt
${decode}    False
*** Test Cases ***
Auto_Caputure_Logs
    [Tags]    case2
    Split User Log Type Para
    Log To Console    \n Begin to start logs
    common_log_capture.Start Logs    ${LOG_NAME_LIST}    ${OUTPUT_DIR}
    Log To Console    \n Start Logs done.
    Wait Until User Manually Delete Stop Case File
    common_log_capture.Stop Logs    ${LOG_NAME_LIST}    ${OUTPUT_DIR}
    Run Keyword If    "${decode}"=="True"    common_log_capture.Decode Logs    ${LOG_NAME_LIST}    ${OUTPUT_DIR}
    Log To Console    \n get log done.
    Log To Console    \n log_path:${OUTPUT_DIR}

*** Keywords ***
Suite Prepare
    Run And Return Rc And Output    rm -rf ${FILE_PATH}
    ${status}    Run Keyword And Ignore Error    Check OnAir And Cell Setup
    Run Keyword If    '${status[0]}'=='PASS'    Create Log Directory And Get Version
    Run Keyword If    '${status[0]}'=='FAIL'    Make Gnb OnAir With QT Config

Check OnAir And Cell Setup
    Verify BTS Is OnAir
    Verify Cell Setup

Create Log Directory And Get Version
    Create Suite Directory
    Log To Console    \n ##################################
    Get Software Version
    Get WTS Version
    Log To Console    \n ##################################

Make Gnb OnAir With QT Config
    Suite Setup Update GNB
    Suite Setup Copy WTS Config Files From QT
    ${status}    Run Keyword And Ignore Error    Suite Setup Start WTS And Check OnAir
    Run Keyword If    '${status[0]}'=='FAIL'    Run Keywords    Reboot TL And Check Configured
    ...    AND    Suite Setup Start WTS And Check OnAir

Wait For Manual Case Step Done
    Log To Console    \n ###########################################
    Log To Console    Please execute "touch ${FILE_PATH}" command in another windows after finish your case to capture logs.
    Wait Until Created    path=${FILE_PATH}    timeout=60m
    Log To Console    \n ###########################################
    Log To Console    \n start to getting logs

Zip Log
    Log To Console    \n ###########################################
    Remove File    path=${FILE_PATH}
    @{log_dir_split}    Split String    ${suite_log_directory}    /
    ${zip_dir}    Evaluate    "/".join(${log_dir_split[:-1]})
    Run Keyword And Ignore Error    Process.Run Process    zip -q -r ${suite_log_directory}.zip ${log_dir_split[-1]}
    ...    shell=True    cwd=${zip_dir}
    Log To Console    \n ###########################################
    Log To Console    \n All logs: ${suite_log_directory}.zip

Capture And Format TTiTrace Log 2s
    Backup Scf    ${output_dir}    before_suite
    Start Ttitrace With Streaming Mode
    Sleep    2s
    Stop Ttitrace
    Convert Ttitrace From Pcap To Excelcsv    ${output_dir}/ttitrace_streaming/
    Format Tti In Stream Mode    ${output_dir}/ttitrace_streaming/output_dl.csv    ${output_dir}/ttitrace_streaming/output_dl_formated.csv
    Process.Run Process    cp ${output_dir}/ttitrace_streaming/ ${suite_log_directory}/ttitrace_streaming

Capture BIP Log 2s
    Start Gnb BIP Log
    Sleep    2s    reason=Capture BIP Log
    Stop Gnb BIP Log    ${suite_log_directory}

Split User Log Type Para
    [Documentation]    btslog,sherpa,ttitrace,bip,snapshot,egate,startup,wireshark
    #${log_type}=    set variable    btslog,sherpa,ttitrace,bip,snapshot,egate,startup,wireshark
    ${log_list}=    split string    ${log_type}    ,
    set suite variable    ${LOG_NAME_LIST}    ${log_list}
    log to console    ${\n}catch log list: ${LOG_NAME_LIST}

Start Logs
    [Arguments]    ${log_name_list}    ${log_dir}=${TEST_LOG_DIRECTORY}
    [Documentation]    This keyword is to start to capture logs.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_name_list} | Yes | log type list, right now  |
    ...
    ...    | *** Variables *** |
    ...    | @{LOG_NAME_LIST} | btslog | snapshot | tcpdump | tshark | pmcounter |
    ...    Examples:
    ...    | Start Logs | ${log_name_list} |
    Setup Connections
    Set Suite Variable    ${FLAG_CATCH_SUITE_LOG}    ${True}
    FOR    ${log}    IN    @{log_name_list}
        ${log}    String.Convert To Lowercase    ${log}
        Run Keyword If    '${log}'=='btslog'    Start GNB AP Syslog    ${log_dir}
        #Run Keyword If    '${log}'=='tcpdump'    Start Tcpdump
        #Run Keyword If    '${log}'=='tshark'    Start TSharklog
        #Run Keyword If    '${log}'=='x2pcap'    Start X2 Pcap Log
        #Run Keyword If    '${log}'=='apl3l1'    Start AP L3L1 Pcap Log
        #Run Keyword If    '${log}'=='cellsetup'    Start Gnb Cell Setup Log
        Run Keyword If    '${log}'=='bip'    Start Gnb BIP Log
        #Run Keyword If    '${log}'=='apbip'    Start AP Bip Log
        Run Keyword If    '${log}'=='ttitrace'    Start GNB TTI Trace
        Run Keyword If    '${log}'=='sherpa'    Start Sherpa L2stream Log    ${L2STREAM_CONFIG}
    END

Stop Logs
    [Arguments]    ${log_name_list}    ${log_dir}=${TEST_LOG_DIRECTORY}
    [Documentation]    This keyword is to stop logs.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | @{log_name_list} | Yes | log type list, right now  |
    ...
    ...    | *** Variables *** |
    ...    | @{LOG_NAME_LIST} | btslog | snapshot | tcpdump | tshark | pmcounter |
    ...    Examples:
    ...    | Stop Logs | @{log_name_list} |
    Setup Connections
    Set Suite Variable    ${FLAG_CATCH_SUITE_LOG}    ${False}
    FOR    ${log}    IN    @{log_name_list}
        ${log}    String.Convert To Lowercase    ${log}
        Run Keyword If    '${log}'=='btslog'    Run Keyword And Ignore Error    Stop And Collect Syslog    log_dir=${log_dir}
        #Run Keyword If    '${log}'=='tcpdump'    Run Keyword And Ignore Error    Stop Tcpdump    log_dir=${log_dir}
        #Run Keyword If    '${log}'=='tshark'    Run Keyword And Ignore Error    Stop TSharklog    log_dir=${log_dir}
        Run Keyword If    '${log}'=='snapshot'    Run Keyword And Ignore Error    Collect GNB SnapShot Via AaShell    log_dir=${log_dir}
        Run Keyword If    '${log}'=='pmcounter'    Run Keyword And Ignore Error    Collect PM Counters    log_dir=${log_dir}
        #Run Keyword If    '${log}'=='x2pcap'    Run Keyword And Ignore Error    Stop X2 Pcap Log    log_dir=${log_dir}
        #Run Keyword If    '${log}'=='apl3l1'    Run Keyword And Ignore Error    Stop AP L3L1 Pcap Log    log_dir=${log_dir}
        Run Keyword If    '${log}'=='sosreport'    Run Keyword And Ignore Error    Collect UTE SosReport    log_dir=${log_dir}
        #Run Keyword If    '${log}'=='cellsetup'    Run Keyword And Ignore Error    Stop Gnb Cell Setup Log    log_dir=${log_dir}
        Run Keyword If    '${log}'=='bip'    Run Keyword And Ignore Error    Stop Gnb BIP Log    log_dir=${log_dir}
        #Run Keyword If    '${log}'=='apbip'    Run Keyword And Ignore Error    Stop AP Bip Log    log_dir=${log_dir}
        Run Keyword If    '${log}'=='ttitrace'    Run Keyword And Ignore Error    Stop And Decode GNB TTI Trace    log_dir=${log_dir}
        Run Keyword If    '${log}'=='sherpa'    Run Keyword And Ignore Error    Stop Sherpa L2stream Log    ${log_dir}
        #Run Keyword If    '${log}'=='utefiles'    Run Keyword And Ignore Error    Collect UTE Files    log_dir=${log_dir}
        Run Keyword If    '${log}'=='egatelog'    Run Keyword And Ignore Error    Save Egate Log
    END