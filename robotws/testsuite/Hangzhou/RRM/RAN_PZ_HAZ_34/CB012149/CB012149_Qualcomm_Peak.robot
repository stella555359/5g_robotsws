*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    ./resource/common_log_capture.robot
Resource    ./resource/common_setup_teardown.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Library    taf.hw.rf_attenuator    WITH NAME    attenuator
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME    throughput_computation
Library    ./lib/streaming_ttitrace_analyzer.py    WITH NAME    TTITRACEANALYZER
Library    ./tak_files/

Suite Setup    Run Keywords    CI_interface.Common Suite Setup
...    AND    robot_common_operations.Common Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown

Documentation
...    Author:Anne Ying
...    contact:anne.ying@nokia-sbell.com
...    squad group:HAZ4_12

Force Tags            RAN_5G_TDD    RAN_5G

*** Variables ***
${SCF_PATH}          ${CURDIR}/config
${FDD_UNMUTE_SLOT}    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

*** Test Cases ***
CB012149ET-CA01_T-F_schedule_on_both_Pcell_and_scell
   [Documentation]
    ...    Precondition:
    ...      FDD 20M and pcell TDD with 1116 0ms frame structure.
    ...      :with beam=4 and refine beam is enable
    ...      NRBTS/NRCELL-maxNumOfUlCaUeParallelTx=2
    ...      A1 based scell added configured.
    ...    Test Steps:
    ...      Step1: Attach UE1 to TDD Pcell and make SA call.
    ...      Step2: Send A1 report, 1 scell is added
    ...      Step3: start big DL and UL traffic and capture logs.
    ...      Step4: start small UL traffic and capture logs.
    ...      Step5: start big UL traffic and capture logs.
    ...      Step6: UE released.

    ...    Check point：
    ...      1. GNB schedule UL data on both TDD pcell and FDD scell even slot overlap.
    ...      2. after step4, the slot of FDD overlap with TDD will not be scheduled.
    ...      3. After step5, GNB will schedule UL data on both TDD pcell and FDD scell at same overlap slot again.
    ...      4. No DTX/CRC NOK
    [Tags]    caseCA01    Manual_qianwu    TA_AnneYing
    [Setup]     Common Case Setup
    [Teardown]      Common Case Teardown

    #Step 1 & 2:
    Prepare and Attach UE

    #Step 3:
    Get Total Theoretical Tput    ue_dl_layer=2    ue_ul_layer=1
    Start Traffic and Collect Tput   duration=300
    #Step 4 ~ 6:
    Connect to gnb coam via ssl
    Capture And Decode Ttitrace    log_id=1    duration=3
    Capture BIP log
	Collect Snapshot Log Via WebUI

    # Check point 1:
    Check Throughput with Theoretical per Cell    ${list_of_cell_ids}[0]    ${cell_0_theoretical_dl}    ${cell_0_theoretical_ul}
    Check Throughput with Theoretical per Cell    ${list_of_cell_ids}[1]    ${cell_1_theoretical_dl}    ${cell_1_theoretical_ul}

    # Check point 2:
    Check AllowList In Tti    log_id=1

    # Check point 3:
    Check Slot For FDD    log_id=1    numOfPrb=ulFdSchedData.numOfPrb    pci=53    slotlist=${FDD_UNMUTE_SLOT}

    # Check point 4:
    Check Ttitrace DTXNACK Rate   log_id=1
    Check Ttitrace UL DTXCRC Rate    log_id=1


*** Keywords ***
Prepare and Attach UE
    [Arguments]    ${ue_index}=${0}
    # ***Prepare UE***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    # Here we use keyword from ue.py to get last value of TL ue capabilities.
    # It can also be hard coded with ue_type like ue_type=nokia_fastmile.
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    # ***UE Attach***
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}     log_type=aasyslog
    power_ue.Verify Attach    ue_type=${ue_type}    ue_index=${ue_index}
    Set Suite Variable    ${ue_type}
    Set Suite Variable    ${ue_index}
    Log to Console    \n UE Attach successfully

Start Traffic and Collect Tput
    [Arguments]    ${duration}     ${ue_index}=${0}
    # ***start traffic***
    ${start_traffic_duration}    evaluate    ${duration}+${240}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${total_theoretical_dl}
    ...    duration=${start_traffic_duration}    ue_index=${ue_index}    #apn=dxdata4
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${total_theoretical_ul}
    ...    duration=${start_traffic_duration}    ue_index=${ue_index}    #apn=dxdata4
    Log to Console  \n Start Traffic

    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration}    filter=L2Lo    check_source=aasyslog
    Log to Console  \n Start to collect Tput

Capture BIP log
    [Arguments]    ${duration}=1
    Start GNB BIP By Admin Method
    Sleep    ${duration}    reason=Wait for log
    Stop Gnb BIP By Admin Method    ${TEST_LOG_DIRECTORY}/BIP/


Get Theoretical Throughput per Cell
    [Arguments]     ${cellid}=1  ${ue_dl_layer}=4   ${ue_ul_layer}=2    &{modified_parameters}
    ${ue_dl_layer}   Convert To Integer    ${ue_dl_layer}
    ${ue_ul_layer}   Convert To Integer    ${ue_ul_layer}
    ${theoretical_dl}    ${theoretical_ul}     throughput_computation.Get Theoretical Throughput    scf_path=${SCF_PATH}/SCF_1.xml
	...    cell_id=${cellid}    ue_dl_layer=${ue_dl_layer}    ue_ul_layer=${ue_ul_layer}    mod_params=${modified_parameters}
    Log To Console    \n Theoretical DL TP is ${theoretical_dl} for ${cellid}
    Log To Console    \n Theoretical UL TP is ${theoretical_ul} for ${cellid}
    [Return]  ${theoretical_dl}    ${theoretical_ul}

Get Total Theoretical Tput
    [Arguments]    ${ue_dl_layer}=4    ${ue_ul_layer}=2
    Log to Console    \n Start to calculate Theoritical TPUT
    Connect to gnb coam via ssl
    ${list_of_cell_ids}    Get List of NR Cell ID
	&{cell_0_modified_parameters}    Create Dictionary    DLnumberOfLayersForSSB=${1}    dlLayers=${1}    ulLayers=${0}
    ...    DLnumberOfLayersForTRS=${0}    actSlowPrbPooling=${1}    maxCsiRsPoolingGrp=${1}
    ${cell_0_theoretical_dl}    ${cell_0_theoretical_ul}    Get Theoretical Throughput per Cell    1    ${ue_dl_layer}    ${ue_ul_layer}
    ...    &{cell_0_modified_parameters}
	&{cell_1_modified_parameters}    Create Dictionary    DLnumberOfLayersForSSB=${1}    dlLayers=${1}    ulLayers=${0}
    ...    DLnumberOfLayersForTRS=${0}    actSlowPrbPooling=${1}    maxCsiRsPoolingGrp=${0}
    ${cell_1_theoretical_dl}    ${cell_1_theoretical_ul}    Get Theoretical Throughput per Cell    6    ${ue_dl_layer}    ${ue_ul_layer}
    ...    &{cell_1_modified_parameters}
    ${total_theoretical_dl}   Evaluate    ${cell_0_theoretical_dl}+${cell_1_theoretical_dl}
    ${total_theoretical_ul}   Evaluate    ${cell_0_theoretical_ul}+${cell_1_theoretical_ul}
    # ${cell_0_theoretical_dl}    Set Variable    841.788825
    # ${cell_0_theoretical_ul}    Set Variable    104.7222
    # ${cell_1_theoretical_dl}    Set Variable    203.21975
    # ${cell_1_theoretical_ul}    Set Variable    109.868
    # ${total_theoretical_dl}    Set Variable    1045.008575
    # ${total_theoretical_ul}    Set Variable    214.59

    Log To Console    \n Total Theoretical DL TP is ${total_theoretical_dl}
    Log To Console    \n Total Theoretical UL TP is ${total_theoretical_ul}
    Set Suite Variable    ${list_of_cell_ids}
    Set Suite Variable    ${cell_0_theoretical_dl}
    Set Suite Variable    ${cell_0_theoretical_ul}
    Set Suite Variable    ${cell_1_theoretical_dl}
    Set Suite Variable    ${cell_1_theoretical_ul}
    Set Suite variable    ${total_theoretical_dl}
    Set Suite Variable    ${total_theoretical_ul}


Check Throughput with Theoretical per Cell
    [Arguments]    ${cell_id}    ${theoretical_dl}    ${theoretical_ul}    ${target_avg_percent}=0.98    ${ue_index}=${0}
    # *** Get Cell List ***
    ${cell}    Create List    ${cell_id}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    target_throughput=${theoretical_dl}
    ...    target_avg_percent=${target_avg_percent}    ue_index=${ue_index}    check_source=aasyslog    cells=${cell}

    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=ul    target_throughput=${theoretical_ul}
    ...    target_avg_percent=${target_avg_percent}    ue_index=${ue_index}    check_source=aasyslog    cells=${cell}


Common Case Setup
    Create Test Directory
    CI_interface.Common Case Setup
    robot_common_operations.Common Case Setup
    # Wait for Cell onair

Common Case Teardown
    UE Stop Traffic and Detach    ue_type=${ue_type}    ue_index=${ue_index}
    robot_common_operations.Common Case Teardown
    CI_interface.Common Case Teardown

UE Stop Traffic and Detach
    [Arguments]     ${ue_type}    ${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    Log to Console    \n Stop Traffic
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    Log to Console    \n UE detached successfully

Check Slot For FDD
    [Arguments]    ${log_id}    ${numOfPrb}    ${pci}    ${slotlist}
    ${value}    Read Csv Columns    ${TEST_LOG_DIRECTORY}/tcpdump_ttitrace/${log_id}/output_ul.csv    slot
	...    filter=((${numOfPrb}!=EMPTY)&(physCellId=${pci}))
    ${list}     Evaluate      list(set(${value}))
    Log     ${list}
    Should Be True    ${list} == ${slotlist}
    Log to Console    \n Check Slot For FDD OK

Check AllowList In TTI
    [Arguments]    ${log_id}
    ${list}=    TTITRACEANALYZER.FiLter Source Column Return Self    ${TEST_LOG_DIRECTORY}/tcpdump_ttitrace/${log_id}/output_ul.csv
	...    ulCaAllowList.allowList
    Should Be True    len(${list})>0
    Log To Console    \n Check Allowlist in TTI OK

Collect Snapshot Log
    [Arguments]    ${gnb_index}=${0}    ${connection}=GNB_OAM    ${log_path}=${TEST_LOG_DIRECTORY}     ${timeout}=${1200}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}
    ...                                                                             gnb_index=${gnb_index}
    ${snapshot_file_path}    COAM Save snapshot via rest api    connection=${connection}
    ...                                                         log_path=${log_path}
    ...                                                         timeout=${timeout}
    [Return]    ${snapshot_file_path}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Collect Snapshot Log Via WebUI
    [Arguments]    ${download_dir}=${TEST_LOG_DIRECTORY}
    ...            ${log_timeout}=${60}
    ...            ${gnb_index}=${0}
    ...            ${url}=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...            ${username}=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...            ${snapshot_timeout}=${1800}
    ...            ${coverage}=All log files
    ...            ${save_location}=Local
    ${temp_dir_for_save_snapshot}    Set Variable    /tmp/snapshot_ta
    Create Directory    ${temp_dir_for_save_snapshot}
    Wait Until Keyword Succeeds    2min    20sec    COAM Navigate to login page via webUI    download_dir=${temp_dir_for_save_snapshot}
    ...    timeout=${log_timeout}    gnb_index=${gnb_index}    url=${url}    username=${username}    password=${password}
    ${is_startup_window_exist}    selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.snapshot_collection_settings    coverage=${coverage}    save_location=${save_location}
    ${temp_snapshot_file_path}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=${snapshot_timeout}

    Wait Until Keyword Succeeds    2min    2sec    File should not be empty    ${temp_snapshot_file_path}
    ${final_snapshot_file_path}    Wait Until Keyword Succeeds    3x    200ms    Copy file and verify file exists
    ...    source_file_path=${temp_snapshot_file_path}    dest_file_folder=${download_dir}
    [Return]    ${final_snapshot_file_path}
    [Teardown]    Run keywords    Run Keyword And Ignore Error    COAM selenium logout    AND
    ...                           Run Keyword And Ignore Error    Empty Directory    path=${temp_dir_for_save_snapshot}

