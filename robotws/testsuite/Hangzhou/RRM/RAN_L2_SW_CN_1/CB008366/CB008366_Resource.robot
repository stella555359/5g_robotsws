*** Settings ***
Documentation    this resource is for CB006086
...              Author: qiqi.luo@nokia-sbell.com
...              Please do not edit the existing keywords in this file without testing.
Resource         ../CUDU_L2/common_setup_teardown.robot

*** Variables ***
${IPHY_FILE}                 ${CURDIR}/Resource/wts/ta_6cell_iphy_ute_dss.xml
${SCF_PATH}                  ${CURDIR}/Resource/Config
${LOCAL_WTS_DIR}             ${CURDIR}/Resource/wts
${WTS_AP_XML}                AirPhoneConfig_fs_fdd_sa_cmw_3CC.xml
${SIB_DECODE_TIMEOUT}        600
${REORDERING_WINDOW_SIZE}    500
${REORDERING_TIMER}          300
${UE_ID}                     1
${GNB_ID}                    1
${ENB_ID}                    2
${CELL1_ID}                  4
${CELL2_ID}                  5
${CELL3_ID}                  2
${ANTP_NUM}                  2
${PDU_ID}                    1
${TRF_ID}                    1
${EXPECTED_TPUT}             1
${TCPDUMP_NAME}              testVM_Tcpdump
${EXPECTED_TPUT_DL}          1
${EXPECTED_TPUT_UL}          1
${EGATE_PATH}                /opt/iphy/latest/egate_console.log
${ALLOC_SUBFRAME}            0011100010-0111101110-0011100110-0111101000-0011100010-0111101110-0011100110-0111101010
${ALLOC_SUBFRAME2}           0011101000-0111101110-0011101100-0111101010-0011101000-0111101110-0011101100-0111101010
${ALLOC_SUBFRAME3}           0011101010-0011101110-0011101110-0011101010-0011101010-0011101110-0011101110-0011101010
${PRB_LIST_10M_WITHOUT_BLANKING}    0,52

*** Keywords ***
Set Reordering Timer
    [Arguments]    ${ue_id}    ${reordering_window_size}    ${reordering_timer}
    ${cmd_reordering}    Catenate    SEPARATOR=${space}    uec_param id\=${ue_id}
    ...    reordering_window_size\=${reordering_window_size} reordering_timer\=${reordering_timer}
    ute_wtssim.Execute Egate Command    cmd=${cmd_reordering}

Set PDU
    [Arguments]    ${ue_id}    ${pdu_id}
    [Documentation]    Set PDU
    ute_wtssim.Execute Egate Command
    ...    cmd=set_pdu_param ue\=${ue_id} pdu\=${pdu_id} trf_type=internal

SA Start DL Traffic EGate
    [Arguments]    ${ue_id}    ${pdu_id}    ${mbps}    ${trf_id}=1
    [Documentation]    This keyword is to start traffic on eGate.
    ...    Expected output is: "UE IS ACTIVE" on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | pdu_id | Yes | pdu_id |
    ...    | mbps | Yes | mbps |
    ...    | trf_id | No | trf_id, default is 1 |
    ...    Example:
    ...    | SA Start DL Traffic EGate| 1 | 10 |
    Log To Console    start DL traffic...
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} dir=dl mbps\=${mbps} trf_id\=${trf_id}
    Sleep    5s    reason=wait DL traffic is stable

SA Start UL Traffic EGate
    [Arguments]    ${ue_id}    ${pdu_id}    ${mbps}    ${trf_id}=1
    [Documentation]    This keyword is to start traffic on eGate.
    ...    Expected output is: "UE IS ACTIVE" on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | pdu_id | Yes | pdu_id |
    ...    | mbps | Yes | mbps |
    ...    | trf_id | No | trf_id, default is 1 |
    ...    Example:
    ...    | SA Start UL Traffic EGate| 1 | 10 |
    Log To Console    start UL traffic...
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} dir=ul mbps\=${mbps} trf_id\=${trf_id}
    Sleep    5s    reason=wait UL traffic is stable

SA Stop DL Traffic EGate
    [Arguments]    ${ue_id}    ${pdu_id}    ${trf_id}=1
    [Documentation]    This keyword is to stop traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | bearer_id | Yes | bearer_id |
    ...    | dir | Yes | ul or dl |
    ...    | trf_id | No | trf_id, default is 1 |
    ...    Example:
    ...    | SA Stop DL Traffic EGate| 1 | 2 |
    Log To Console    stop DL traffic...\n
    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${ue_id} pdu\=${pdu_id} dir=dl trf_id\=${trf_id}

SA Stop UL Traffic EGate
    [Arguments]    ${ue_id}    ${pdu_id}    ${trf_id}=1
    [Documentation]    This keyword is to stop traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | bearer_id | Yes | bearer_id |
    ...    | dir | Yes | ul or dl |
    ...    | trf_id | No | trf_id, default is 1 |
    ...    Example:
    ...    | SA Stop UL Traffic EGate| 1 | 2 |
    Log To Console    stop UL traffic...\n
    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${ue_id} pdu\=${pdu_id} dir=ul trf_id\=${trf_id}

SA Check Average Traffic Bigger Than Target EGate
    [Arguments]    ${ue_id}    ${pdu_id}    ${dir}    ${tp_rate}
    [Documentation]    This keyword is to Check traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | dir | Yes | Direction of Traffic |
    ...    | tp_rate | Yes | Throughput Rate for traffic |
    ...    Example:
    ...    | SA Check Average Traffic bigger than target eGate| 1 | 2 | ul | 10 |
    ...    | SA Check Average Traffic bigger than target eGate| 1 | 2 | dl | 10 |
    ${output}    ute_wtssim.Execute Egate Command    cmd=bearer_stats ue\=${ue_id} pdu\=${pdu_id} qfi=1 dir\=${dir}
    ...    pass_regexp=Average packet interval    timeout=150
    OperatingSystem.Create File    /tmp/${dir}.txt    ${output}
    ${avg}    OperatingSystem.Run    cat /tmp/${dir}.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${mavg}    Evaluate    ${avg}*0.000001
    Log To Console    \n The average ${dir} tput is: ${mavg}M \n
    ${tp_delta}    Evaluate    ${avg}*0.000001-${tp_rate}
    Should Be True    ${tp_delta}>=0    Throughtput is not in the accetable range
    Log To Console    The TPUT is bigger than target: ${tp_rate}M \n

Check Scell On EGate Console Log
    [Arguments]    ${egate_path}
    ${content}    OperatingSystem.Get File    ${egate_path}
    ${patt}    Set Variable    sCellIndex\\s+(?P<index>\\w+),
    ${matches}    String.Get Regexp Matches    ${content}    ${patt}
    ${index}    Create List    sCellIndex 1,    sCellIndex 2,
    Collections.Lists Should Be Equal    ${matches}    ${index}

Check 2CC Scell On EGate Console Log
    [Arguments]    ${egate_path}
    ${content}    OperatingSystem.Get File    ${egate_path}
    ${patt}    Set Variable    sCellIndex\\s+(?P<index>\\w+),
    ${matches}    String.Get Regexp Matches    ${content}    ${patt}
    ${index}    Create List    sCellIndex 1,
    Collections.Lists Should Be Equal    ${matches}    ${index}

SA UE Register
    [Arguments]    ${ue_id}
    Set Reordering Timer    ${ue_id}    ${reordering_window_size}    ${reordering_timer}
    Set PDU    ${ue_id}    ${pdu_id}
    SA 5G Attach    ${ue_id}
    SA 5G PDU Session Setup    ${ue_id}

SA Check 3CC Traffic Bigger Than Target EGate
    [Arguments]    ${ue_id}    ${dir}    ${tp_rate}
    ${pcell_tput}    Get CA Cell Average Throughput    ${ue_id}    ${dir}    pcell    0
    ${scell1_tput}    Get CA Cell Average Throughput    ${ue_id}    ${dir}    scell    1
    ${scell2_tput}    Get CA Cell Average Throughput    ${ue_id}    ${dir}    scell    2
    Should Be True    ${pcell_tput}>=${tp_rate}    Throughtput is not in the accetable range
    Should Be True    ${scell1_tput}>=${tp_rate}    Throughtput is not in the accetable range
    Should Be True    ${scell2_tput}>=${tp_rate}    Throughtput is not in the accetable range
    Log To Console    The TPUT is bigger than target: ${tp_rate}M \n

SA Check 2CC Traffic Bigger Than Target EGate
    [Arguments]    ${ue_id}    ${dir}    ${tp_rate}
    ${pcell_tput}    Get CA Cell Average Throughput    ${ue_id}    ${dir}    pcell    0
    ${scell1_tput}    Get CA Cell Average Throughput    ${ue_id}    ${dir}    scell    1
    Should Be True    ${pcell_tput}>=${tp_rate}    Throughtput is not in the accetable range
    Should Be True    ${scell1_tput}>=${tp_rate}    Throughtput is not in the accetable range
    Log To Console    The TPUT is bigger than target: ${tp_rate}M \n

Check DL Per Slot Ue Numbers
    [Arguments]    ${tti_csv_dir}    ${number}
    ${filters}    Set Variable    dlFdSchedData
    ${out_file_name}    Set Variable    ${tti_csv_dir}/dlFdSchedData.csv
    ${result}    Set Variable    ${False}
    ${tti_csv_files}    OperatingSystem.List Files In Directory    ${tti_csv_dir}    *L2TtiTrace_EventsSnapshot.bin.*dl.csv    ${True}
    FOR    ${file}    IN    @{tti_csv_files}
    Format Tti In Snapshot Mode    ${file}    ${out_file_name}    ${filters}
    ${result}    Verify DL Per Slot Ue Numbers In Target File    ${out_file_name}    ${number}
    Exit For Loop If    ${result}==${True}
    END
    Should Be True    ${result}==${True}

Multi UE Register
    [Arguments]    ${start_ue_num}    ${stop_ue_num}
    FOR    ${ue_id}    IN RANGE    ${start_ue_num}    ${stop_ue_num}+1
    Log To Console    ===============UE${ue_id} Register:==============
    SA UE Register     ${ue_id}
    Sleep    1s    reason=Wait For ue attach
    END

Verify DL Per Slot Ue Numbers In Target File
    [Arguments]    ${tti_csv_name}    ${number}
    [Documentation]    tti csv file contains only dlFdSchedData msg, please refer to tti_convert.py for more infos
    ${times}    Evaluate    ${number}-1
    ${full_patt}    Set Variable    dlFdSchedData,(?P<sfn>\\d+),(?P<slot>\\d+).+\\n(?:dlFdSchedData,(?P=sfn),(?P=slot).+\\n){${times}}
    ${rnti_patt}    Set Variable    dlFdSchedData,\\d+,\\d+,(?P<rnti>\\d+)
    ${content}    OperatingSystem.Get File    ${tti_csv_name}
    ${matches}    String.Get Regexp Matches    ${content}    ${full_patt}
    ${check_result}    Set Variable    ${False}
    FOR    ${item}    IN    @{matches}
    ${rnti_vals}    String.Get Regexp Matches    ${item}    ${rnti_patt}    rnti
    ${count}    Evaluate    len(set(${rnti_vals}))
    ${check_result}    Run Keyword And Return Status    Should Be Equal As Integers    ${count}    ${number}
    Exit For Loop If    ${check_result}==${True}
    END
    [Return]    ${check_result}