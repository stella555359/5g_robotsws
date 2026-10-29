*** Settings ***
Documentation
...    to make TA work, actInternalTrace=true, actCli=true
Resource    ./../common_setup_teardown.robot
#Library    ./../scripts/python/format_ttitrace_table.py
#Library    ./../../../../../resources/sites/Hangzhou/KISS/python/ta_kiss_files/    WITH NAME    TA_KISS_FILES
#Library    ./../../../../../resources/sites/Hangzhou/KISS/python/ta_kiss_iperf/    WITH NAME    TA_KISS_IPERF
#Variables    ./../../../../../resources/sites/Hangzhou/KISS/python/ta_kiss_log/
*** Variables ***
${LOG}    syslog,tti,sherpa,bip,sosreport,apbip,
${TIME}    5s
${LOG_PATH}    ${OUTPUT_DIR}/mylog/
*** Test Cases ***
Download MCShark Case
    Get Software Version
    Download MCShark To UTE

*** Keywords ***

Print Time
    [Arguments]    ${info}
    ${time}    Get Current Date    result_format=timestamp
    Log To Console    \n${time}:${info}

Test Start Log
#    Start Sherpa L2stream Log    ${L2STREAM_CONFIG}
#    Start Ttitrace With Streaming Mode
    Start Gnb BIP Log

Test Stop Log
#    Stop Sherpa L2stream Log     ${OUTPUT_DIR}/sherpa_tmp/
#    Stop Ttitrace
    Stop Gnb BIP Log    ${LOG_PATH}/bip/

Test Convert Log
    Log To Console    Start to Convert Sherpa log...
    Convert Pcap To Sherpa Csv     ${OUTPUT_DIR}/sherpa_tmp/
    Run    mkdir -p ${LOG_PATH}/sherpa_log/; cp -r ${OUTPUT_DIR}/sherpa_tmp/l2stream3_sherpa/tcpdump_sherpa/tcpdump_sherpa/ ${LOG_PATH}/sherpa_log/
    Log To Console    Start to Convert ttitrace log...
    Convert Ttitrace From Pcap To Excelcsv    ${LOG_PATH}/ttitrace_streaming/
    Format Tti In Stream Mode    ${LOG_PATH}/ttitrace_streaming/output_dl.csv    ${LOG_PATH}/ttitrace_streaming/output_dl_combine.csv
    Format Tti In Stream Mode    ${LOG_PATH}/ttitrace_streaming/output_ul.csv    ${LOG_PATH}/ttitrace_streaming/output_ul_combine.csv

#Download MCShark To UTE
#    [Arguments]    ${sw_version}=${SW_VERSION_TOTAL}    #SBTS00_ENB_9999_210615_000005
#    Run    wget -r -np -nH https://artifactory-hz1.int.net.nokia.com/artifactory/mcshark-local/${sw_version}/
#    ${MCShark}=    Run    ls ${EXECDIR}/artifactory/mcshark-local/${sw_version}/mcshark-*buster.so
#    Run    sudo cp ${MCShark} ${MCSHARK_PLUGIN}/3.4/epan/
#
#Copy Preference For MCShark
#    [Arguments]    ${preference_file}
#    Run    sudo cp ${preference_file} /home/ute/.config/wireshark/
#    Run    sudo cp ${preference_file} /usr/share/wireshark
#
#Convert BIP To CSV By MCShark
#    [Arguments]    ${bip_file}    ${output_file}    ${filter}    ${csv_title_list}
#    ${csv_title}=    Set Variable    None
#    FOR    ${column}   IN    ${csv_title_list}
#        ${csv_title}=    Set Varible    -e ${column}
#    END
#    ${cmd}=    Catenate    tshark -r ${bip_file} -Y '${filter}' -T fields -e _ws.col.No. -e _ws.col.Info
#    ...    ${csv_title} -E header=y -E separator=, -E quote=d -E occurrence=a > ${output_file}
#    OperatingSystem.Run    ${cmd}

Convert BIP To CSV By MCShark For 5GC001817
    ${filter}=    Set Variable    dci.dci01.CSIrequest == 1||UlData_puschReceiveReqGrant_t.numOfUciCsiPart1Bits != 0x00
    @{csv_title_list}=    Create List    DlData_PdcchSendReq_t.sfn    UlData_PuschReceiveReq_t.sfn
    ...    dci.dci01.CSIrequest    dci.dci01.BetaOffsetInd    UlData_puschReceiveReqGrant_t.numOfUciAckBits

    ${csv_title}=    Catenate    -e DlData_PdcchSendReq_t.sfn -e UlData_PuschReceiveReq_t.sfn  -e dci.dci01.CSIrequest
    ...    -e dci.dci01.BetaOffsetInd  -e UlData_puschReceiveReqGrant_t.numOfUciAckBits
    Convert BIP To CSV By MCShark    bip_C018.pcap    test0629_1.csv    ${filter}    ${csv_title_list}

Get PhysCellId Of GNB 2
    COAM.Setup Admin
    ${cell_ids}=    COAM.get_cell_list
    COAM.get_cell_mapping_by_module_id
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
