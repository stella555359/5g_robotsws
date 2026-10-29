*** Settings ***
Documentation    ...
#Resource          ./../CUDU_L2_AIC/common_aic_setup_teardown.robot
#Suite Setup       Run Keywords    Common Suite Setup
#...               AND    Update Aic GNB    VCU_SCFC_PATH=${VCU_SCFC_PATH}    VDU_SCFC_PATH=${VDU_SCFC_PATH}
#...               AND    Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#...               AND    Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown    debug
#Test Setup        Create Test Directory
#Test Teardown     Common Test Teardown    debug
#Library           ./../CUDU_L2/scripts/python/streaming_ttitrace_analyzer.py
#Library           ./config/CB006112_A_PA2_13.py
#Force Tags        CRT    CLOUD_5GC_dR2.0_1vDU_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#
#
#*** Variables ***
#${VCU_SCFC_PATH}    ${CURDIR}/config/vcu_CB006112_A_PA2_13.xml
#${VDU_SCFC_PATH}    ${CURDIR}/config/vdu_CB006112_A_PA2_13.xml
#${GNB_INDEX}        0
#${LOCAL_WTS_DIR}    ${CURDIR}/config
#${WTS_CFG}          basic_setup_CB006112_A_PA2_13.cfg
#${ENB_ID}           1
#${GNB_ID}           2
#${UE1_ID}           1
#${UE2_ID}           2
#${UE3_ID}           3
#${DL_CSV1}           ${CURDIR}/ttiTrace_dl.csv
#${UL_CSV1}           ${CURDIR}/ttiTrace_ul.csv
#${DL_CSV2}           ${OUTPUT_DIR}/ttiTrace_dl.csv
#${UL_CSV2}           ${OUTPUT_DIR}/ttiTrace_ul.csv
#${ttitrace_log}      /tmp/ttitrace.pcap
#
#*** Test Cases ***
#CB006112-ET-A-PA2-13 voice package transfer successfully when SR period is 20ms.
#    SA GBR Call And Non GBR Call For Multi UE
#    Catch And Decode TTiTrace Log For PA Verify
#    Verify DLUL Traffic Transfered As Expected
#    Stop Non GBR Data Transfer
#    Catch And Decode TTiTrace Log For PA Disable Verify
#    Verify DLUL PA Timer Disable
#    Stop GBR Data Transfer
#
#
#
#*** Keywords ***
#SA GBR Call And Non GBR Call For Multi UE
#    SA Non GBR Call For Multi UE    ${UE1_ID}
#    SA Non GBR Call For Multi UE    ${UE2_ID}
#    SA GBR Call For Multi UE    ${UE3_ID}
#    SA Start UDP DL And UL Traffic For Multi UE
#
#SA Start UDP DL And UL Traffic For Multi UE
#    SA Start UDP DL Traffic For Multi UE    ${UE1_ID}    7070    1400    800M    360
#    SA Start UDP UL Traffic For Multi UE    ${UE1_ID}    7071    1400    400M    360
#    SA Start UDP DL Traffic For Multi UE    ${UE2_ID}    7072    1400    800M    360
#    SA Start UDP UL Traffic For Multi UE    ${UE2_ID}    7073    1400    400M    360
#    SA Start UDP DL Traffic For Multi UE    ${UE3_ID}    7074    40    16000    360
#    SA Start UDP UL Traffic For Multi UE    ${UE3_ID}    7075    40    16000    360
#    Sleep    5s
#
#Catch And Decode TTiTrace Log For PA Verify
#    ${trace_id}    Start TTiTrace Log
#    Sleep    5s
#    Stop TTiTrace Log    ${trace_id}
#    Decode TTiTrace Log    ${ttitrace_log}    ${CURDIR}
#    sleep   5s
#Catch And Decode TTiTrace Log For PA Disable Verify
#    ${trace_id}    Start TTiTrace Log
#    Sleep    5s
#    Stop TTiTrace Log    ${trace_id}
#    Decode TTiTrace Log    ${ttitrace_log}    ${OUTPUT_DIR}
#    sleep    5s
#
#Verify DLUL Traffic Transfered As Expected
#    Verify DL Traffic Transfered As Expected
#    Verify UL Traffic Transfered As Expected
#
#Verify DLUL PA Timer Disable
#    Verify DL PA Timer Disable
#    Verify UL PA Timer Disable
#
#SA Non GBR Call For Multi UE
#    [Arguments]    ${ue_id}
#    [Documentation]    This keyword is used to simulate Non GBR call for different UEs on 5GNR side.
#    ...    Expected output is: "UE1: Proxy (eNB 2 Cell 2 ) reported successful RA" on eGate.
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | Yes | ue id |
#    ...    Example:
#    ...    | SA Non GBR call for multi UE | 1 |
#    SA 5G Attach    ${ue_id}
#    SA 5G PDU Session Setup For Multi UE    ${ue_id}
#
#SA 5G PDU Session Setup For Multi UE
#    [Arguments]    ${ue_id}
#    [Documentation]    This keyword is used to simulate PDU session setup for different UEs on 5GNR side.
#    ...    Expected output is: " Initial Context Setup Successful " on eGate.
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | Yes | ue id |
#    ...    Example:
#    ...    | SA 5G PDU Session Setup for multi UE | 1 |
#    Log To Console    start 5G PDU Session Setup for UE${ue_id}..
#    ${command}    Set Variable    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    ${command}    pass_regexp=Initial Context Setup Successful    timeout=3minutes
#    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
#    Log To Console    ${output}
#
#SA GBR Call For Multi UE
#    [Arguments]    ${ue_id}
#    [Documentation]    This keyword is used to simulate Non GBR call for different UEs on 5GNR side.
#    ...    Expected output is: "UE1: Proxy (eNB 2 Cell 2 ) reported successful RA" on eGate.
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | Yes | ue id |
#    ...    Example:
#    ...    | SA Non GBR call for multi UE | 1 |
#    SA 5G Attach    ${ue_id}
#    SA 5G PDU Session Setup For Multi UE    ${ue_id}
#    Trigger 5QI 5 Setup    ${ue_id}
#    Trigger 5QI 1 Setup    ${ue_id}
#
#Trigger 5QI 5 Setup
#    [Arguments]    ${ue_id}
#    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
#    ...    Expected output is: " Initial Context Setup Successful " on eGate.
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | Yes | ue id |
#    ...    Example:
#    ...    | Trigger 5QI 5 Setup | 1 |
#    Log To Console    start 5QI-5 Setup for UE${ue_id}...
#    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    ${command}
#    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
#    ...    timeout=3minutes
#    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
#    Log To Console    ${output}
#
#Trigger 5QI 1 Setup
#    [Arguments]    ${ue_id}
#    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
#    ...    Expected output is: " Initial Context Setup Successful " on eGate.
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | Yes | ue id |
#    ...    Example:
#    ...    | Trigger 5QI 1 Setup | 1 |
#    Log To Console    start 5QI-1 Setup for UE${ue_id}...
#    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    ${command}
#    ...    pass_regexp=Received Uplink NAS Transport Message with RAN UE NGAP ID
#    ...    timeout=3minutes
#    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
#    Log To Console    ${output}
#
#SA Start UDP DL Traffic For Multi UE
#    [Arguments]    ${ue_id}   ${DL_PORT}=7070    ${len}=40    ${bps}=16000    ${duration}=3600
#    [Documentation]    This keyword is to start DL traffic by iperf.
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | Yes | ue id |
#    ...    | DL_PORT | Yes | DL PORT, default is 7070 |
#    ...    | len | Yes | traffic length, default is 40 |
#    ...    | bps | Yes | bps, default is 16000 |
#    ...    | duration | Yes | duration, default is 3s |
#    ...    Example:
#    ...    | SA Start UDP DL Traffic for multi UE | 1 | 7070 | 40 | 16000 | 3600 |
#    Log To Console                     start UDP DL traffic for UE${ue_id}...
#    Execute Iperf In Linux             args=-c 10.12.2.${${ue_id}+1} -u -p ${DL_PORT} -l ${len} -b ${bps} -i 1 -t ${duration}
#    Sleep                              3s
#    Execute Iperf In Linux             args=-s -u -p ${DL_PORT} -i 1 -B 10.0.2.1
#    ...                                pipe_args=| tee /tmp/iperf_dl_UE${ue_id}.txt
#    Log To Console                     Running DL Traffic ${bps} for ${duration}s
#    Sleep                              3s
#
#SA Start UDP UL Traffic For Multi UE
#    [Arguments]    ${ue_id}   ${UL_PORT}=7071    ${len}=40    ${bps}=16000    ${duration}=3600
#    [Documentation]    This keyword is to start UL traffic by iperf.
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | Yes | ue id |
#    ...    | UL_PORT | Yes | UL PORT, default is 7071 |
#    ...    | len | Yes | traffic length, default is 40 |
#    ...    | bps | Yes | bps, default is 16000 |
#    ...    | duration | Yes | duration, default is 3s |
#    ...    Example:
#    ...    | SA Start UDP UL Traffic for multi UE | 1 | 7071 | 40 | 16000 | 3600 |
#    Log To Console                     start UDP UL traffic for UE${ue_id}...
#    Execute Iperf In Linux             args=-c 72.23.${${ue_id}+1}.1 -u -p ${UL_PORT} -l ${len} -b ${bps} -i 1 -t ${duration}
#    Sleep                              3s
#    Execute Iperf In Linux             args=-s -u -p ${UL_PORT} -i 1 -B 10.0.2.1
#    ...                                pipe_args=| tee /tmp/iperf_ul_UE${ue_id}.txt
#    Log To Console                     Running UL Traffic ${bps}M for ${duration}s
#    Sleep                              3s
#
#SA Stop Traffic For Multi UE
#    [Arguments]    ${DL_PORT}=7070    ${UL_PORT}=7071
#    [Documentation]    This keyword is to stop traffic by iperf.
#    ...    | Input Parameters | Man. | Description |
#    ...    | DL_PORT | Yes | DL PORT |
#    ...    | UL_PORT | Yes | UL PORT |
#    ...    Example:
#    ...    | SA Stop Traffic for multi UE | 7070 | 7071 |
#    OperatingSystem.Run    ps -ef|grep iperf|grep -v grep|grep ${DL_PORT}| awk '{print $2}' |xargs sudo kill -9
#    OperatingSystem.Run    ps -ef|grep iperf|grep -v grep|grep ${UL_PORT}| awk '{print $2}' |xargs sudo kill -9
#
#Execute Iperf In Linux
#    [Arguments]    ${args}=${EMPTY}    ${pipe_args}=${EMPTY}
#    ${result}    Run Keyword    Process.Start Process    iperf ${args} ${pipe_args}    shell=${TRUE}
#    [Return]    ${result}
#
#Verify DL Traffic Transfered As Expected
#    ${prioriy_list}=    streaming_ttitrace_analyzer.FiLter Source Column Return Self    ${DL_CSV1}
#    ...    dlTdSchedSubcellData.resReqClassPrio
#    ${5qi_sfn_list}=    streaming_ttitrace_analyzer.FiLter Source Column Return Other    ${DL_CSV1}
#    ...    dlFdSchedData.numOf5qi1Prb    condition=["0","0.0",""]    operation=except    target_column_name=sfn
#    ${sfn_interval_lt}=    streaming_ttitrace_analyzer.count_interval    ${5qi_sfn_list}
#    Should Contain    ${prioriy_list}    25.0
#    Should Contain    ${sfn_interval_lt}     ${4}
#
#Verify UL Traffic Transfered As Expected
#    ${prioriy_list}=    streaming_ttitrace_analyzer.FiLter Source Column Return Self    ${UL_CSV1}
#    ...    ulTdSchedSubcellData.resReqClassPrio
#    ${5qi_sfn_list}=    streaming_ttitrace_analyzer.FiLter Source Column Return Other    ${UL_CSV1}
#    ...    ulFdSchedData.numOf5qi1Prb    condition=["0","0.0",""]    operation=except    target_column_name=sfn
#    ${sfn_interval_lt}=    streaming_ttitrace_analyzer.count_interval    ${5qi_sfn_list}
#    Should Contain    ${prioriy_list}    25.0
#    Should Contain    ${sfn_interval_lt}     ${4}
#
#Stop Non GBR Data Transfer
#    SA Stop Traffic For Multi UE    7070    7071
#    SA Stop Traffic For Multi UE    7072    7073
#
#Stop GBR Data Transfer
#    SA Stop Traffic For Multi UE    7074    7075
#
#Verify DL PA Timer Disable
#    ${5qi_sfn_list}=    streaming_ttitrace_analyzer.FiLter Source Column Return Other    ${DL_CSV2}
#    ...    dlFdSchedData.numOf5qi1Prb    condition=["0","0.0",""]    operation=except    target_column_name=sfn
#    ${sfn_interval_lt}=    streaming_ttitrace_analyzer.count_interval    ${5qi_sfn_list}    remove_duplicate=no
#    ${the_rate_bigger_than_4}    change_2D_list_to_1D_and_Cal_the_rate_bigger_than_4    ${sfn_interval_lt}
#    Run Keyword If    ${the_rate_bigger_than_4}>0.01    Fail    There is still PA
#
#Verify UL PA Timer Disable
#    ${5qi_sfn_list}=    streaming_ttitrace_analyzer.FiLter Source Column Return Other    ${UL_CSV2}
#    ...    ulFdSchedData.numOf5qi1Prb    condition=["0","0.0",""]    operation=except    target_column_name=sfn
#    ${sfn_interval_lt}=    streaming_ttitrace_analyzer.count_interval    ${5qi_sfn_list}    remove_duplicate=no
#    ${the_rate_bigger_than_4}    change_2D_list_to_1D_and_Cal_the_rate_bigger_than_4    ${sfn_interval_lt}
#    Run Keyword If    ${the_rate_bigger_than_4}>0.01    Fail    There is still PA
#
