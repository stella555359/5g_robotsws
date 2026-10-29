*** Settings ***
Documentation    this resource is for CB006086
...              Author: qiqi.luo@nokia-sbell.com
...              Please do not edit the existing keywords in this file without testing.
Resource         ../CUDU_L2/common_setup_teardown.robot
Library          ../python/ta_kiss_gnb/    WITH NAME    ta_kiss_gnb

*** Variables ***
${SIB_DECODE_TIMEOUT}        600
${REORDERING_WINDOW_SIZE}    500
${REORDERING_TIMER}          300
${UE_ID_1}                   1
${UE_ID_2}                   2
${UE_ID_3}                   3
${UE_ID_4}                   4
${UE_ID_5}                   5
${UE_ID_6}                   6
${UEC_ID}                    1
${GNB_ID}                    2
${CELL_ID}                   1
${PDU_ID}                    1
${TRF_ID}                    1
${EXPECTED_TPUT}             1
${TCPDUMP_NAME}              testVM_Tcpdump
${EXPECTED_TPUT_DL}          1
${EXPECTED_TPUT_UL}          1
${EGATE_PATH}                /opt/iphy/latest/egate_console.log

*** Keywords ***
Check Scell On EGate Console Log
    [Arguments]    ${egate_path}
    ${content}    OperatingSystem.Get File    ${egate_path}
    ${patt}    Set Variable    sCellIndex\\s+(?P<index>\\w+),
    ${matches}    String.Get Regexp Matches    ${content}    ${patt}
    ${index}    Create List    sCellIndex 1,    sCellIndex 2,
    Collections.Lists Should Be Equal    ${matches}    ${index}

Set Bler To UE
    [Arguments]    ${ue_id}    ${pro_id}    ${dlbler_rate}
    ${cmd_bler_mode}    Catenate    SEPARATOR=${space}    bler_testmode_nr profile_id=${pro_id}
    ...    dl_bler=${dlbler_rate}
    ${cmd_send_bler}    Catenate    SEPARATOR=${space}    ue_testmode_set_nr id=${ue_id}
    ...    testmode=bler action=activate profile_id=${pro_id} scell=0
    ${output}    ute_wtssim.Execute Egate Command    cmd=${cmd_bler_mode}
    ${output}    ute_wtssim.Execute Egate Command    cmd=${cmd_send_bler}
    ${output}    ute_wtssim.Execute Egate Command    cmd=bler_testmode_nr profile_id\=${pro_id}
    ...    pass_regexp=dl_bler    timeout=150

SA Check 3CC Traffic Bigger Than Target EGate
    [Arguments]    ${ue_id}    ${dir}    ${tp_rate}
    ${pcell_tput}    Get CA Cell Average Throughput    ${ue_id}    ${dir}    pcell    0
    ${scell1_tput}    Get CA Cell Average Throughput    ${ue_id}    ${dir}    scell    1
    ${scell2_tput}    Get CA Cell Average Throughput    ${ue_id}    ${dir}    scell    2
    Should Be True    ${pcell_tput}>=${tp_rate}    Throughtput is not in the accetable range
    Should Be True    ${scell1_tput}>=${tp_rate}    Throughtput is not in the accetable range
    Should Be True    ${scell2_tput}>=${tp_rate}    Throughtput is not in the accetable range
    Log To Console    The TPUT is bigger than target: ${tp_rate}M \n

Single 3CC UE Blind Scell Addition And Scell Activation For DL CA Should Succeed
    [Arguments]    ${ue_id}
    SA 5G CA Attach    ${ue_id}
    Sleep    2s    reason=Wait For Egate Print
    Save Egate Log    ${TEST_LOG_DIRECTORY}
    Check Scell On EGate Console Log    ${TEST_LOG_DIRECTORY}/egate_console.log

Check Configuration Of PUCCH Format 3 Resources In The TDD Pcell Should Be Correct
    ${content}    OperatingSystem.Get File    ${TEST_LOG_DIRECTORY}/egate_console.log
    ${patt}    Set Variable    maxPayloadSize\\s+12
    ${matches}    String.Get Regexp Matches    ${content}    ${patt}
    ${payloadsize}    Create List    maxPayloadSize 12
    Collections.Lists Should Be Equal    ${matches}    ${payloadsize}

SA Start DL And UL Traffic
    [Arguments]    ${ue_id}
    FOR    ${trf_id}    IN RANGE    1    5
    SA Start DL Traffic Internal    ${ue_id}    ${pdu_id}    175    ${trf_id}
    SA Start UL Traffic Internal    ${ue_id}    ${pdu_id}    10    ${trf_id}
    END
    Sleep    5s    reason=Wait For Data Transmission
    SA UE Check Throughput    ${ue_id}    ${expected_tput_dl}    ${expected_tput_dl}
    SA Check 3CC Traffic Bigger Than Target EGate    ${ue_id}    dl    ${expected_tput_dl}

SA Stop DL And UL Traffic
    [Arguments]    ${ue_id}
    SA Stop Data Traffic Internal    ${ue_id}    ${pdu_id}
    Sleep    5s    reason=Wait For Stopping Data Transmission

Check Scells Are Added
    [Arguments]    ${cellid1}    ${cellid2}    ${cellid3}
    Save Egate Log    ${TEST_LOG_DIRECTORY}
    ${CONTENT}    OperatingSystem.Get File    ${TEST_LOG_DIRECTORY}/egate_console.log
    ${PATT}    Set Variable    physCellId\\s+\\d\\d
    ${MATHCES}    String.Get Regexp Matches    ${CONTENT}    ${PATT}
    ${PHYSCELLIDLIST}    Create List    ${cellid1}    ${cellid2}    ${cellid3}
    Collections.Lists Should Be Equal    ${MATHCES}    ${PHYSCELLIDLIST}

Check Scell1 Is Released
    Save Egate Log    ${TEST_LOG_DIRECTORY}
    ${CONTENT}    OperatingSystem.Get File    ${TEST_LOG_DIRECTORY}/egate_console.log
    ${PATT}    Set Variable    sCellToReleaseList
    ${MATHCES}    String.Get Regexp Matches    ${CONTENT}    ${PATT}
    ${PHYSCELLIDLIST}    Create List    sCellToReleaseList
    Collections.Lists Should Be Equal    ${MATHCES}    ${PHYSCELLIDLIST}

Check Scell Active Status
    [Arguments]    ${scell_index}=1    ${scell_active_status}=activated    ${check_status}=pass
    ...    ${egate_file}=/opt/iphy/latest/egate_console.log
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${scell_activation}    Set Variable    SCellIndex ${scell_index} ${scell_active_status} successfully.
    ${content}    OperatingSystem.Get File    path=${egate_file}
    ${match_list}    Get Regexp Matches    ${content}    ${scell_activation}
    ${check_rst}    Get Length    ${match_list}
    ${scell_status}    Set Variable If    ${check_rst}>=1    pass    fail
    Should be True    '${scell_status}'=='${check_status}'


