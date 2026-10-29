*** Settings ***
Documentation    This is common keywords for siso RRH related cases
...              Please do not modify the file without notification to author
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_log.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ./e2e_step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/snapshot_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/nr_feature_on.robot

*** Variables ***

*** Keywords ***
General_SiSo_Keep_Site_Status_Check
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify site status chould be OK while every time check
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 12.15.2021 - - Created
    ...    *******************
    ...    Owner_mengting.li@nokia-sbell.com
    ${gnb_len}    get length    ${tl.gnbs}
    ${result}    set variable    ${True}
    FOR    ${gnb_index}    IN RANGE    ${gnb_len}
        SISO Coam Test Setup   gnb_index=${gnb_index}
        ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
        ${status}    run keyword and return status    Keep Site Status And L3 Call   connection=${connection}    gnb_index=${gnb_index}
        Fail case Log collected    gnb_index=${gnb_index}    case_status=${status}
        ${result}    set variable if    ${status}==${False}    ${False}    ${result}
    END
    [Return]    ${result}

General_SiSo_Site_Reset_Check
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify site reset chould be OK while every time check
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.13.2022 - - Created
    ...    *******************
    ...    Owner_mengting.li@nokia-sbell.com
    ${gnb_len}    get length    ${tl.gnbs}
    ${result}    set variable    ${True}
    FOR    ${gnb_index}    IN RANGE    ${gnb_len}
        SISO Coam Test Setup   gnb_index=${gnb_index}
        ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
        ${status}    run keyword and return status    Perform Site Reset And L3 Call   connection=${connection}    gnb_index=${gnb_index}
        Fail case Log collected    gnb_index=${gnb_index}    case_status=${status}
        ${result}    set variable if    ${status}==${False}    ${False}    ${result}
    END
    [Return]    ${result}

General_SiSo_RU_lock_and_unlock_Check
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify ru lock unlock chould be OK while every time check
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.18.2022 - - Created
    ...    *******************
    ...    Owner_mengting.li@nokia-sbell.com
    ${gnb_len}    get length    ${tl.gnbs}
    ${result}    set variable    ${True}
    FOR    ${gnb_index}    IN RANGE    ${gnb_len}
        SISO Coam Test Setup   gnb_index=${gnb_index}
        ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
        ${status}    run keyword and return status    RU Lock Unlock And L3 Call   connection=${connection}    gnb_index=${gnb_index}
        Fail case Log collected    gnb_index=${gnb_index}    case_status=${status}
#        Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
#        ...    connection=${connection}    gnb_index=${gnb_index}
#        run keyword and ignore error   run keyword unless  ${status}   Save Coam Snapshot   target_dir=${SAVE LOG DIRECTORY}
#        ...    connection=${connection}
#        run keyword and ignore error   run keyword unless  ${status}   Capture RU logs    connection=${connection}   gnb_index=${gnb_index}
#        run keyword and ignore error   COAM Teardown gnb connections    connection=${connection}
        ${result}    set variable if    ${status}==${False}    ${False}    ${result}
    END
    [Return]    ${result}

General_SiSo_UE_L3call_peak_sometime
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to modify L3 call peak throughput stability
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 04.13.2022 - - Created
    ...    *******************
    ...    Owner_kaihui.fan@nokia-sbell.com
    [Arguments]  ${duration}=${1800}
    ${gnb_len}    get length    ${tl.gnbs}
    FOR    ${gnb_index}    IN RANGE    ${gnb_len}
        run keyword if    ${gnb_index}!=0    run keywords    SISO Coam Suite Setup    gnb_index=${gnb_index}    AND
        ...    SISO Coam Test Setup    gnb_index=${gnb_index}
        ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
        ${status}   run keyword and return status   Make Call with all ue attached RU    connection=${connection}  duration=${duration}
        run keyword if  '${status}'=='False'  Fatal Error
        run keyword if    ${gnb_index}!=0    run keywords    SISO Coam Test Teardown    gnb_index=${gnb_index}
        ...    is_case_teardown=${False}       is_check_historyalarm=${True}    AND
        ...    SISO Coam Suite Teardown    gnb_index=${gnb_index}
    END

General_SiSo_PCI_value_from_WEBUI_with_L3call_Loop_Check
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to modify PCI value in first cell,and L3call success,RU not reset
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.17.2022 - - Created
    ...    *******************
    ...    Owner_kaihui.fan@nokia-sbell.com
    [Arguments]  ${with_call}=${True}   ${with_peak}=${False}    ${duration}=${60}    ${ru_index}=1
    ${gnb_len}    get length    ${tl.gnbs}
    FOR    ${gnb_index}    IN RANGE    ${gnb_len}
        run keyword if    ${gnb_index}!=0    run keywords    SISO Coam Suite Setup    gnb_index=${gnb_index}    AND
        ...    SISO Coam Test Setup    gnb_index=${gnb_index}
        ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
        ${asik_alias}    set variable if    ${gnb_index}==0    ASIK Master    ASIK Master_${gnb_index}
        ${status}   run keyword and return status   Modify_PCI_value_from_WEBUI_with_L3call_Check  connection=${connection}
        ...    with_call=${with_call}   with_peak=${with_peak}    duration=${duration}
        run keyword if  '${status}'=='False'  Fatal Error
        run keyword if    ${gnb_index}!=0    run keywords    SISO Coam Test Teardown    gnb_index=${gnb_index}
        ...    is_case_teardown=${False}       is_check_historyalarm=${True}    AND
        ...    SISO Coam Suite Teardown    gnb_index=${gnb_index}
    END

General_SiSo_Cell_block_and_unblock_Check
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify cell block unblock chould be OK.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 04.20.2022 - - Created
    ...    *******************
    ...    Owner_mengting.li@nokia-sbell.com
    ${gnb_len}    get length    ${tl.gnbs}
    ${result}    set variable    ${True}
    FOR    ${gnb_index}    IN RANGE    ${gnb_len}
        SISO Coam Test Setup   gnb_index=${gnb_index}
        ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
        ${status}    run keyword and return status    Cell Block Unblock And L3 Call   connection=${connection}    gnb_index=${gnb_index}
        Fail case Log collected    gnb_index=${gnb_index}    case_status=${status}
        ${result}    set variable if    ${status}==${False}    ${False}    ${result}
    END
    [Return]    ${result}

General_SiSo_Loop_Save_Snapshot_while_L3call
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this case is to verify that save snapshot while L3call
    ...    and test result can be gotten successfully in BTS,check gnb cells onair,L3call OK,snapshot collect OK.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 05.05.2022 - - Created
    ...    *******************
    ...    Owner_kaihui.fan@nokia-sbell.com
    [Arguments]  ${ue_index}=${0}   ${dl_tp}=100M    ${ul_tp}=20M
    ...    ${snapshot_path}=${SAVE LOG DIRECTORY}    ${dl_exp}=100    ${ul_exp}=20    ${actual_rate}=0.1
    ...    ${target_avg_percent}=0.1    ${min_percent}=0.05   ${total_times}=${10}
    ...    ${protocol}=udp    ${iperf_type}=${None}
    ${gnb_len}    get length    ${tl.gnbs}
    FOR    ${gnb_index}    IN RANGE    ${gnb_len}
        run keyword if    ${gnb_index}!=0    run keywords    SISO Coam Suite Setup    gnb_index=${gnb_index}    AND
        ...    SISO Coam Test Setup    gnb_index=${gnb_index}
        ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
        ${asik_alias}    set variable if    ${gnb_index}==0    ASIK Master    ASIK Master_${gnb_index}
        ${duration}   evaluate   15*60*${total_times}+3600
        log to console   L3call duration time is:${duration}\n---------------------\n
        ${status}   run keyword and return status   General_SiSo_Loop_Save_Snapshot_while_L3call_singleGnb  connection=${connection}
        ...    alias=${asik_alias}  ue_index=${ue_index}   dl_tp=${dl_tp}   ul_tp=${ul_tp}   snapshot_path=${snapshot_path}
        ...    dl_exp=${dl_exp}   ul_exp=${ul_exp}   actual_rate=${actual_rate}   target_avg_percent=${target_avg_percent}
        ...    min_percent=${min_percent}   duration=${duration}   total_times=${total_times}   protocol=${protocol}  iperf_type=${iperf_type}
        run keyword if  '${status}'=='False'  Fatal Error
    END

General_SiSo_Loop_Save_Snapshot_while_L3call_singleGnb
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this case is to verify that save snapshot while L3call
    ...    and test result can be gotten successfully in BTS,check gnb cells onair,L3call OK,snapshot collect OK.
    ...    this case will run  by default 10 times with collect snapshot and check Tput while the L3call ongoing with
    ...    10*390(the time every loop), so it will have the risk at the last loop
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 05.05.2022 - - Created
    ...    *******************
    ...    Owner_kaihui.fan@nokia-sbell.com
    [Arguments]  ${ue_index}=${0}     ${alias}=ASIK MASTER     ${connection}=GNB_OAM   ${dl_tp}=100M    ${ul_tp}=20M
    ...    ${snapshot_path}=${SAVE LOG DIRECTORY}    ${dl_exp}=100    ${ul_exp}=20    ${actual_rate}=0.1
    ...    ${target_avg_percent}=0.1    ${min_percent}=0.05   ${total_times}=${10}   ${duration}=${3900}
    ...    ${protocol}=udp    ${iperf_type}=${None}
    ${ue_index_list}  create list
    append to list  ${ue_index_list}   ${ue_index}
    ${ue_and_cell}   Start Attach And Call for UE With Try   ue_index_list=${ue_index_list}
    ...   iperf_type=${iperf_type}   protocol=${protocol}   connection=${connection}   alias=${alias}
    ...     dl_tp=${dl_tp}    ul_tp=${ul_tp}   duration=${duration}
    ${status_check_throught}   Set variable    ${True}
    ${check_throught_fail_times}   Set Variable   ${0}
    ${fail_throught_bip_tag}    Set Variable   ${False}

    ${ue_cell_id}=    Get Ues Attached Cell    ue_num_each_call=${1}
    ${bbmod_dist_list}=    Get Runtime FBB info
    ${bbmod_dist}    set variable    ${bbmod_dist_list[0]}
#    ${cell_dist_list}=    Get Runtime Subcell info
#    ${cell_dist}    set variable    ${cell_dist_list[0]}
    @{MO_list}    Split String    ${bbmod_dist}    /
    ${runtime_info}    set variable    /${MO_list}[1]/${MO_list}[2]/${MO_list}[3]/${MO_list}[4]
    ${cell_dist}    set variable    ${runtime_info}/NRBTS_R-${nrbtsID}/NRCELL_R-${ue_cell_id}
#    ${cell_dist}    set variable    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-${nrbtsID}/NRCELL_R-${ue_cell_id}
#    ${bbmod_dist}    set variable    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1
    ${subcell_dict}=  Create dictionary  nrcellDN  ${cell_dist}
    ...                                  subcellId  ${0}
    ${nr_ul_subcell_list}    Create List    ${subcell_dict}
    ${nr_dl_subcell_list}    Create List    ${subcell_dict}

    FOR    ${itime}    IN RANGE    1    ${total_times}+1
        log to console    \nthe ${itime} time collect snapshot and check info while L3call
        run keyword if  not ${status_check_throught}  log to console    check throughput fail, restart attach and call
        ${ue_and_cell_retry}   run keyword if  not ${status_check_throught}     Start Attach And Call for UE With Try
        ...    ue_index_list=${ue_index_list}    iperf_type=${iperf_type}   protocol=${protocol}   connection=${connection}
        ...    alias=${alias}    dl_tp=${dl_tp}    ul_tp=${ul_tp}   duration=${duration}   bip_force_tag=${fail_throught_bip_tag}
        run keyword and ignore error  Run   killall firefox

        Collect_IQ_Data_on_WebEM
        ...    target_module=${bbmod_dist}
        ...    target_output_file_path=test_iq_file.tgz
        ...    nr_ul_subcell_list=${nr_ul_subcell_list}    nr_dl_subcell_list=${nr_dl_subcell_list}

        ${snapshot_zip_file_path}    wait until keyword succeeds   3x  30s   COAM Save snapshot via webUI
        ...    download_dir=${snapshot_path}
        Check Log File From Snapshot File List   snapshot_zip_file_path=${snapshot_zip_file_path}
        Connect to Common Unit Master  alias=${alias}
        connect to gnb coam via ssl    connection=${connection}
        ${status_check_throught}  run keyword and return status  UE Verify Peak Throughput    ue_index_list=${ue_index_list}
        ...    ue_and_cell=${ue_and_cell}    dl_exp=${dl_exp}    ul_exp=${ul_exp}
        ...     duration=${30}    actual_rate=${actual_rate}
        ...    gnb_ssl_connection=${connection}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
        ${check_throught_fail_times}   Run Keyword If    ${status_check_throught}    Set Variable    ${check_throught_fail_times}
        ...     ELSE    Evaluate   ${check_throught_fail_times}+1
        ${fail_throught_bip_tag}    Set Variable If   ${check_throught_fail_times}==1   ${True}   ${False}
        Run Keyword If    ${check_throught_fail_times}>1     Fail
        run keyword if  not ${status_check_throught}   Run Keyword And Ignore Error   Ue Stop DL UL Traffic and Detach
        ...    ue_index_list=${ue_index_list}    iperf_type=${iperf_type}    protocol=${protocol}
        gnb should be onair with cell up    connection=${connection}
        Run keyword and ignore error    coam.teardown      connection=${connection}
        run keyword and ignore error  csn.disconnect    connection=${alias}
        run keyword and ignore error  OperatingSystem.run    rm -rf ${snapshot_zip_file_path}
    END
    [Teardown]  run keywords  run keyword and ignore error  csn.disconnect   connection=ASIK Master  AND  Ue Stop DL UL Traffic and Detach
    ...    ue_index_list=${ue_index_list}    iperf_type=${iperf_type}    protocol=${protocol}    AND   selenium logout and close browser

General_SiSo_Loop_Collect_Sanpshot_E2E
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case to check ue attach
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 19.07.2022 - - Created
    ...    *******************
    ...    Owner_kaihui.fan@nokia-sbell.com
    [Arguments]  ${total_times}=${20}    ${connection}=GNB_OAM    ${with_call}=${True}    ${with_peak}=${False}
    ...    ${snapshot_path}=${SAVE LOG DIRECTORY}    ${duration}=${60}
    ${cell_list}    get all cell id    connection=${connection}
    FOR    ${itime}    IN RANGE    1    ${total_times}+1
        Log to console    \n---------------------\nstability run: ${itime}/${total_times}
        run keyword and ignore error  Run   killall firefox
        log to console   begain collect snapshot
        ${snapshot_zip_file_path}    wait until keyword succeeds   3x  30s   COAM Save snapshot via webUI   download_dir=${snapshot_path}
        log to console   collect snapshot finish
        sleep  30s
        Check Log File From Snapshot File List    snapshot_zip_file_path=${snapshot_zip_file_path}
        OperatingSystem.run    rm -rf ${snapshot_zip_file_path}
        gnb should be onair with cell up    connection=${connection}
        run keyword if  ${with_call}  Get UE From Init File and Make call  cell_list=${cell_list}
        ...    with_peak=${with_peak}  duration=${duration}    connection=${connection}
    END

General_SiSo_fiber_flash_off_and_recovery_gNB
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] To verify  alarm disappear, cell onair , L3call after fiber flash off and recovery
    ...      during normal operation (OnAir state).
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 16.09.2022 - - Created
    ...    *******************
    ...    Owner_kaihui.fan@nokia-sbell.com
    [Arguments]   ${alias}=ASIK MASTER     ${connection}=GNB_OAM   ${with_call}=${True}    ${with_peak}=${False}
    ...    ${duration}=${30}
    ${gnb_len}    get length    ${tl.gnbs}
    FOR    ${gnb_index}    IN RANGE    ${gnb_len}
        run keyword if    ${gnb_index}!=0    run keywords    SISO Coam Suite Setup    gnb_index=${gnb_index}    AND
        ...    SISO Coam Test Setup    gnb_index=${gnb_index}
        ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
        ${alias}    set variable if    ${gnb_index}==0    ASIK Master    ASIK Master_${gnb_index}
        connect to gnb coam via ssl    connection=${connection}
        ${cell_list}    get all cell id    connection=${connection}
        Connect to Common Unit Master  alias=${alias}
        ${modules}   csn.Execute   command=bmutool -I   connection=${alias}
        ${ABIO_exist}   Evaluate   ${modules.count('ABINO')}>0
        ${ABIL_exist}   Evaluate   ${modules.count('ABIL')}>0
        log to console  break off fiber after 3s recovery fiber and check cell onair and L3call
        Run Keyword If   ${ABIL_exist}   Disconnect And Recovery Fiber Via BBMOD Type   bbmod_type=ABIL   recovery_duration=3s
        ...   ELSE IF   ${ABIO_exist}   Disconnect And Recovery Fiber Via BBMOD Type   bbmod_type=ABIO   recovery_duration=3s
        ...   ELSE    log to console   BBMOD not ABIL OR ABIO, not support other BBMOD type fiber break off
    #    Wait until keyword succeeds    1min    20 sec    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}
        Wait until keyword succeeds    1min    20 sec    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}   connection=${connection}
        Unexpect History Alarm Should Not Exist  allowed_faults=${ALLOWED_HISTORY_FAULT}    connection=${connection}
        gnb should be onair with cell up    connection=${connection}
        run keyword if  ${with_call}  Get UE From Init File and Make call  cell_list=${cell_list}
        ...    with_peak=${with_peak}  duration=${duration}    connection=${connection}
        log to console  break off fiber after 3s recovery fiber and check cell onair and L3call
        Run Keyword If   ${ABIL_exist}   Disconnect And Recovery Fiber Via BBMOD Type   bbmod_type=ABIL   recovery_duration=15s
        ...   ELSE IF   ${ABIO_exist}   Disconnect And Recovery Fiber Via BBMOD Type   bbmod_type=ABIO   recovery_duration=15s
        ...   ELSE    log to console   BBMOD not ABIL OR ABIO, not support other BBMOD type fiber break off
        Log To Console    Wait For Fault 10 Appear
        ${result1}    Run Keyword And Return Status    Wait For Expect Fault Present  faultId=10   timeout=60
        Log To Console    Wait For Fault 10 Disappear
        ${result2}    Run Keyword And Return Status    Wait For Expect Fault To Disappear  faultId=10   timeout=300
        Wait until keyword succeeds    5min    20 sec    gnb should be onair with cell up    connection=${connection}
        run keyword if  ${with_call}  Get UE From Init File and Make call  cell_list=${cell_list}
        ...    with_peak=${with_peak}  duration=${duration}    connection=${connection}
        run keyword if    ${gnb_index}!=0    run keywords    SISO Coam Test Teardown    gnb_index=${gnb_index}
        ...     AND   SISO Coam Suite Teardown    gnb_index=${gnb_index}
    END
    [Teardown]  run keyword and ignore error   csn.disconnect   connection=ASIK Master

Delta_Commissioning_With_Given_Parameter
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.17.2022 - - Created
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${with_peak}=${False}
    Make Call with all ue attached RU    with_peak=${with_peak}
    Delta_Commissioning_With_actPdschAtSsbSlots_Change
    Make Call with all ue attached RU    with_peak=${with_peak}
    Delta_Commissioning_With_actPdschAtSsbSlots_Change

Timing_offset_online_activation_and_modification_L3call
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 14.08.2023 - - Created
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    Selenium Login And Disable Screen Lock
    ${cell_list}    Get TDD cell list
    NR Feature CB007597 OFF and Check
    NR Feature CB007597 ON and Check    cell_id_list=${cell_list}    frameStartOffset=3000    sfnOffset=0
    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${True}
    ...    duration=${300}    loop_times=${2}
    NR Feature CB007597 ON and Check    cell_id_list=${cell_list}    frameStartOffset=4000    sfnOffset=1
    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${True}
    ...    duration=${300}    loop_times=${2}
    [Teardown]  selenium logout and close browser
