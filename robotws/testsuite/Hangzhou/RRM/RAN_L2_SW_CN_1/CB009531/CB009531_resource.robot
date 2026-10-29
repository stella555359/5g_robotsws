*** Settings ***
Documentation     CB009531 Resource
Resource          ./../CUDU_L2/common_setup_teardown.robot
Library           Resources/A002_check_drx.py
Library           Resources/check_ap_syslog.py


*** Keywords ***
Check Ap Syslog
    [Arguments]    ${id}    ${grep_value}    ${maxDlHarqTx}
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output
    ...    cd ${TEST_LOG_DIRECTORY}/${id};tar -xzvf ${TEST_LOG_DIRECTORY}/${id}/AP_syslog.tar.gz
    Log    ${output}
    ${syslog_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}/${id}    AP_syslog_*    ${True}
    ${content}    OperatingSystem.Run    cat ${TEST_LOG_DIRECTORY}/${id}/AP_syslog_*|grep -i ${grep_value} >text.txt
    ${a}    Check Sfn Slot In Ap Syslog    text.txt    ${CURDIR}/Resources/${BIP_CSV_NAME}    ${maxDlHarqTx}
    Should Be Equal    ${a[0]}    ${maxDlHarqTx}
    Should Be Equal    ${a[1]}    ${80000000000000}

Check Egate Log For DRX Configuration
    [Arguments]    ${onDuraTimer}=ms2    ${InacTimer}=ms2    ${RTTDL}=14    ${RTTUL}=28    ${RetrDL}=sl6    ${RetrUL}=sl4    ${LongCycle}=ms80
    Save Egate Log    ${OUTPUT_DIR}
    ${egate_console_file}=    Set Variable    ${OUTPUT_DIR}/egate_console.log
    ${content_1}=    Grep File    ${egate_console_file}    drx-onDurationTimer milliSeconds
    Should Contain    ${content_1}    drx-onDurationTimer milliSeconds : ${onDuraTimer}
    ${content_2}=    Grep File    ${egate_console_file}    drx-InactivityTimer ms
    Should Contain    ${content_2}    drx-InactivityTimer ${InacTimer}
    ${content_3}=    Grep File    ${egate_console_file}    drx-RetransmissionTimer
    Should Contain    ${content_3}    drx-RetransmissionTimerDL ${RetrDL}
    Should Contain    ${content_3}    drx-RetransmissionTimerUL ${RetrUL}
    ${content_4}=    Grep File    ${egate_console_file}    drx-HARQ-RTT-Timer
    Should Contain    ${content_4}    drx-HARQ-RTT-TimerDL ${RTTDL}
    Should Contain    ${content_4}    drx-HARQ-RTT-TimerUL ${RTTUL}
    ${content_5}=    Grep File    ${egate_console_file}    drx-LongCycleStartOffset
    Should Contain    ${content_5}    drx-LongCycleStartOffset ${LongCycle}

Set Value For BLER Testmode
    [Arguments]    ${profile_id}=31    ${dl_bler}=1000,1000,1000,1000,1000,1000,1000,0
    Log To Console    Set Value For BLER Testmode...
    ${cmd}    Set Variable    bler_testmode_nr profile_id=${profile_id} dl_bler=${dl_bler}
    ute_wtssim.Execute Egate Command    ${cmd}

SA Set Traffic Per XSFN Internal
    [Arguments]    ${ue_id}    ${pdu_id}=1    ${dir}=dl    ${period_ms}=160    ${burst}=1    ${trf_id}=1    ${size}=42
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} dir\=${dir} period_ms\=${period_ms} burst\=${burst} trf_id\=${trf_id} size\=${size}
    Sleep    2s

Covert BIP To Csv
    [Arguments]    ${preferences}
    Copy Preference For MCShark    ${CURDIR}/Resources/${preferences}
    ${bip_name}    Set Variable    ${TEST_LOG_DIRECTORY}/5GBipL2L1_filtering_off.pcap
    Convert BIP To CSV By MCShark    ${bip_name}    ${TEST_LOG_DIRECTORY}/${BIP_CSV_NAME}    filter=${FILTER_A002}    csv_title_list=${COLUMN_NAME}
    OperatingSystem.Copy File    ${TEST_LOG_DIRECTORY}/${BIP_CSV_NAME}    ${CURDIR}/Resources/
    Sleep    2s

Set AP L2rt Debug Level
    ${CMD_L2rt_Debug}    Set Variable    debug_sim_log app_type=l2rt level=2
    ute_wtssim.Execute Egate Command    cmd=${CMD_L2rt_Debug}
    Sleep    2s
    ${CMD_Reserved1}    Set Variable    bler_testmode_nr profile_id=10 Reserved-1=7
    ute_wtssim.Execute Egate Command    cmd=${CMD_Reserved1}
    Sleep    2s

Trigger VONR Establishment And Traffic
    [Arguments]    ${ue_id}
    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_modify ue\=${ue_id} pdu\=1 qosflows_to_add\=2 by\=amf
    Sleep    1s    reason=wait PDU session modify success
    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_modify ue\=${ue_id} pdu\=1 qosflows_to_add\=3 by\=amf
    Sleep    1s    reason=wait PDU session modify success
    Log To Console    Start VONR UL/DL UDP Traffic
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ue_id} pdu\=1 qfi=3 trf_id=1 dir=ul protocol=udp rtp_codec=amr_wb_15_85
    Sleep    5s    reason=wait DL/UL traffic is stable
    Log To Console    Start nonGBR UL/DL TCP Traffic
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ue_id} pdu\=1 qfi=2 trf_id=1 dir=dl protocol=tcp period_ms=20 size=54
    Sleep    5s    reason=wait DL/UL traffic is stable
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ue_id} pdu\=1 qfi=2 trf_id=1 dir=ul protocol=tcp period_ms=20 size=54
    Sleep    5s    reason=wait DL/UL traffic is stable

Online Modify NIDD
    [Arguments]    ${json_path}
    Log To Console    Online Modify NIDD
    ${json_file}=    Change Delta XML File To Delta Json File    ${json_path}
    Delta Commission With SCF File    ${json_file}
    Sleep    5s

Check EXITULACKRETXTIMER in TTI
    [Arguments]    ${log_id}
    Log To Console    Check EXITULACKRETXTIMER
    ${data_list_1}=    filter_source_column_return_self    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}/output_ul.csv
    ...    source_column_name=ulPreSchedData.csListEvent    condition=["EXITULACKRETXTIMER"]    operation=include
    ${count1}    Get Length    ${data_list_1}
    Should Be True    ${count1}!=0

Check Ulretrans And Uldata During RetransTimer
    Log To Console    Check Ulretrans And Newul during RetransTimer
    ${result1}    Check TTI ulretrans    ${TEST_LOG_DIRECTORY}/ttitrace/1/output_ul.csv
    Should Be True    ${result1}
    ${result2}    Check TTI Uldata During RetransTimer    ${TEST_LOG_DIRECTORY}/ttitrace/1/output_ul.csv
    Should Be True    ${result2}

Case Teardown
    [Arguments]    ${ue_id}
    Run Keyword And Ignore Error    SA 5G Detach    ${ue_id}
    Common Test Teardown    2    check_tl=False

Check RetxTimerStatus In TTitrace
    Log To Console    drxRetransmissionTimer.retxTimerStatus
   @{retxTimerStatus}=    filter_2source_column_return_other    ${TEST_LOG_DIRECTORY}/ttitrace/1/output_ul.csv
    ...    drxRetransmissionTimer.retxTimerStatus    physCellId    ["0", "", "0.0"]
    ...    except    50    include    drxRetransmissionTimer.retxTimerStatus    no
    Should Be True    ${retxTimerStatus}[0]==1

Check HO To Target Cell Success
    Log To Console    drxRetransmissionTimer.retxTimerStatus
   @{numOfPrb}=    filter_2source_column_return_other    ${TEST_LOG_DIRECTORY}/ttitrace/1/output_ul.csv
    ...    ulFdSchedData.numOfPrb    physCellId    ["0", "", "0.0"]
    ...    except    51    include    ulFdSchedData.numOfPrb    no
    Should Be True    ${numOfPrb}[0]!=0


Configure UTE ETH3 For A18
    OperatingSystem.Run    sudo ifconfig eth3:gNB2_X2 10.0.1.3/24 up
    OperatingSystem.Run    sudo ifconfig eth3:gNB3_X2 10.0.1.4/24 up
    OperatingSystem.Run    sudo ifconfig eth3:gNB_S1U 10.0.1.112/24 up

Set CG2 DRX BLER Testmode
    Log To Console    Set Value For DRX CG2 BLER Testmode...
    ${cmd}    Set Variable    cg_testmode_nr profile_id=1 CgDrxErrorType=1 CgDrxOnErrorPercent=10 CgDrxOffErrorPercent=10
    ute_wtssim.Execute Egate Command    ${cmd}

Check RetxTimerStatus For B014 in TTI
   @{retxTimerStatus}=    FiLter Source Column Return Self    ${TEST_LOG_DIRECTORY}/ttitrace/1/output_ul.csv
    ...    drxRetransmissionTimer.retxTimerStatus    condition=["0","0.0",""]    operation=except
    Should Be True    ${retxTimerStatus}[0]==1

Check CSRNTI in ulConfiguredGrantType2Data
   @{CSRNTI}=    FiLter Source Column Return Self    ${TEST_LOG_DIRECTORY}/ttitrace/1/output_ul.csv
    ...    ulConfiguredGrantType2Data.csRnti    condition=["0","0.0",""]    operation=except
    Should Be True    ${CSRNTI}[0]!=0

