*** Settings ***
Documentation    These are common keywords for CB009563 related cases
...              Please do not modify the file without notification to author
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/nr_feature_on.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_csn.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/loop_prach.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot


*** Keywords ***
General_SiSo_RF_alarms_with_autonomous_reset
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] To verify CB009563 Alarm FID2922 Antenna calibration error caused by reception path.
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 11.15.2023 - - Created
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    dapd: command update,https://jiradc.ext.net.nokia.com/browse/WESTLAKE-10642
    ...    *******************
    ...    Owner_mengting.li@nokia-sbell.com
    [Arguments]    ${gnb_index}=0   ${ru_index}=1   ${connection}=GNB_OAM    ${timeout}=300
    log to console   \n Perform site reset to clear history alarms which raised by previous cases
    Perform BTS Site Reset
    sleep    5m
    COAM Wait gnb And Cells ready    timeout=20 min    gnb_type='${gNb_CuType}'
    log to console   \n Connect to RU
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    log to console    \n Trigger Fault 2922 with "Minor"
    ${pipe_index_list}    create list    0    1    2    3
    FOR  ${pipe_index}  IN  @{pipe_index_list}
        ${output}    Execute Command With RU rfsw Account    ru_alias=RU_${ru_index}    cmd=dapd-app -dg ${pipe_index} 0 -100
        Should Match Regexp    ${output}    PostCombGain\\s+=\\s+\\-inf\\s+\\[dB\\]
    END
    sleep    3m
    log to console   \n Check Fault 2922 Appear On WebEM. Alarm Severity is "Minor"
    Wait until keyword succeeds    30min    60s    Expect Fault Should Present    faultId=2922    severity=Minor
    log to console    \n Trigger Fault 2922 with "Major"
    ${output}    Execute Command With RU rfsw Account    ru_alias=RU_${ru_index}    cmd=dapd-app -dg 4 0 -100
    Should Match Regexp    ${output}    PostCombGain\\s+=\\s+\\-inf\\s+\\[dB\\]
    sleep    3m
    log to console   \n Check Fault 2922 Appear On WebEM. Alarm Severity is "Major" and cell "degraded"
    Wait until keyword succeeds    30min    60s    Expect Fault Should Present    faultId=2922    severity=Major
    ${nr_cells_info}   coam.get_cells_info  cell_type=nr    timeout=${timeout}    connection=${connection}
    FOR    ${cell}    IN    @{nr_cells_info}
        Should Be Equal As Strings    ${cell['status']['operationalState'].lower()}   enabled
        Should Be Equal As Strings    ${cell['status']['administrativeState'].lower()}     unlocked
        Should Be Equal As Strings    ${cell['status']['blockingState'].lower()}   unblocked
        Should Be Equal As Strings    ${cell['status']['availabilityStatus'].lower()}   degraded
    END
    log to console    \n Recover Fault 2922 by RU reset
    Perform RU Reset    download_dir=${SAVE LOG DIRECTORY}
    sleep    5m
    log to console    \n Check Fault 2922 Disappear On WebEM and cell onair
    coam wait gnb and cells ready    timeout=10min    gnb_type='${gNb_CuType}'
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=2922
    log to console    \nCheck Unexpected Alarm
    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...    connection=${connection}
    should be true    ${alarm_status}
    &{fault_2922}     Create Dictionary     faultId=${2922}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_2922}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=${connection}
    should be true    ${history_alarm_status}
    [Teardown]    run keywords
    ...    Perform RU Reset    download_dir=${SAVE LOG DIRECTORY}    AND
    ...    COAM Wait gnb And Cells ready    timeout=20 min    gnb_type='${gNb_CuType}'

NR Feature CB007597 ON/OFF and Make Traffic
    [Arguments]  ${duration}=${300}
    Selenium Login And Disable Screen Lock
    ${cell_list}    get all cell id
    NR Feature CB007597 ON and Check    cell_id_list=${cell_list}    frameStartOffset=5000
    ${ue_num_each_call}    Get Tput ue Number    given_num=2
    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${True}
    ...    duration=${duration}    loop_times=${2}    ue_num_each_call=${ue_num_each_call}
    NR Feature CB007597 OFF and Check
    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${True}
    ...    duration=${duration}    loop_times=${2}    ue_num_each_call=${ue_num_each_call}
    [Teardown]    run keywords    NR Feature CB007597 OFF and Check    AND    selenium logout and close browser

NR Feature CB007597 ON/OFF and max frameStartOffset min sfnOffset
    # https://jiradc.ext.net.nokia.com/browse/LEOPARD-2463
    [Arguments]  ${duration}=${100}
    Selenium Login And Disable Screen Lock
    ${cell_list}    get all cell id
    NR Feature CB007597 ON and Check    cell_id_list=${cell_list}    frameStartOffset=5000
    ${ue_num_each_call}    Get Tput ue Number    given_num=2
    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${True}
    ...    duration=${duration}    loop_times=${2}    ue_num_each_call=${ue_num_each_call}
    NR Feature CB007597 ON and Check    cell_id_list=${cell_list}    frameStartOffset=9999.995    sfnOffset=32767
    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${True}
    ...    duration=${duration}    loop_times=${2}    ue_num_each_call=${ue_num_each_call}
    NR Feature CB007597 ON and Check    cell_id_list=${cell_list}    frameStartOffset=0    sfnOffset=32767
    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${True}
    ...    duration=${duration}    loop_times=${2}    ue_num_each_call=${ue_num_each_call}
    NR Feature CB007597 ON and Check    cell_id_list=${cell_list}    frameStartOffset=0    sfnOffset=-32768
    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${True}
    ...    duration=${duration}    loop_times=${2}    ue_num_each_call=${ue_num_each_call}
    NR Feature CB007597 ON and Check    cell_id_list=${cell_list}    frameStartOffset=9999.995    sfnOffset=-32768
    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${True}
    ...    duration=${duration}    loop_times=${2}    ue_num_each_call=${ue_num_each_call}
    NR Feature CB007597 OFF and Check
    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${True}
    ...    duration=${duration}    loop_times=${2}    ue_num_each_call=${ue_num_each_call}
    [Teardown]    run keywords    NR Feature CB007597 OFF and Check    AND    selenium logout and close browser

Modify Params before Test Mode
    log to console    \nModify Params before Test Mode
    selenium login and disable screen lock
    # Modify Parameter if Need Modify    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    # ...    filter_param=Activate baseband resource pooling FR1 TDD extension
    # ...    new_value=false
    # Modify Parameter if Need Modify    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    # ...    filter_param=Activate baseband resource pooling FR1 TDD
    # ...    new_value=false
    # Modify Parameter if Need Modify    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    # ...    filter_param=Activate large baseband resource pooling FR1 TDD
    # ...    new_value=false
    # Modify Parameter if Need Modify    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    # ...    filter_param=Activate enhanced algorithm of baseband resource pooling FR1 TDD
    # ...    new_value=false
    # Modify Parameter if Need Modify    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    # ...    filter_param=Activate disabling of NR remote interference management RS at gNB level
    # ...    new_value=false
    # Modify Parameter if Need Modify    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    # ...    filter_param=Allow slow static NDM-SRS PRB pooling
    # ...    new_value=false
    ${cell_list}    get all cell id
    FOR    ${cell_id}    IN    @{cell_list}
        ${dist_name}    set variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        Modify Parameter if Need Modify    dist_name=${dist_name}
        ...    filter_param=Downlink MIMO Mode
        ...    new_value=4x4 or 4x2 Closed Loop Spatial Multiplexing
        Delete Parameter if Need Delete    dist_name=${dist_name}
        ...    filter_param=Number of CSI-RS resource period in one CSI report period
        Delete Parameter if Need Delete    dist_name=${dist_name}
        ...    filter_param=CSI-RS power
        Delete Parameter if Need Delete    dist_name=${dist_name}
        ...    filter_param=Maximum CSI-RS number
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${False}    timeout=${300}
    [Teardown]  selenium logout and close browser

General_SiSo_fault_trigge_4598_TiltOffset_out_of_Range
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to check If commissioned NRCELL.beamSet.tiltOffset exceeds the Radio’s
    ...    supported steering range, BTS raises alarm with fault 4598: EFaultId_TiltOffsetOutOfRangeAl;
    ...    basicBeamSet=beamSet_2 and tiltOffset = 7  trigger fault 4598, tiltoffset=6, fault 4598 clear
    ...    basicBeamSet=beamSet_5_3 and tiltOffset = 5  trigger fault 4598, tiltoffset=4, fault 4598 clear
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 12.19.2023 - - Created
    ...    ticket:https://jiradc.ext.net.nokia.com/browse/LEOPARD-1724
    ...    update ticket:https://jiradc.ext.net.nokia.com/browse/WESTLAKE-9445?filter=-1
    ...    *******************
    ...    Owner_kaihui.fan@nokia-sbell.com
    [Arguments]    ${ru_index}=1
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    Modify_BeamSet_And_TiltOffset_For_Fault4598   ru_index=${ru_index}   is_update_beamset=${True}   beamset=beamSet_2
    ...   tiltoffset=6    numberOfTransmittedSsBlocks=2 beams   beam_set_5_3=${True}
    log to console    check fault 4598 trigger after modify  beamset=beamSet_2  tiltoffset=6
    Wait until keyword succeeds    10min    30s    Expect Fault Should Present    faultId=4598
    Modify_BeamSet_And_TiltOffset_For_Fault4598   ru_index=${ru_index}   is_update_beamset=${False}
    ...   beamset=beamSet_2    tiltoffset=5    numberOfTransmittedSsBlocks=2 beams    beam_set_5_3=${True}
    log to console    check fault 4598 disappeared
    Wait Until Keyword Succeeds   10min   30s    Expect Fault Should Absent    faultId=4598
    Modify_BeamSet_And_TiltOffset_For_Fault4598   ru_index=${ru_index}   is_update_beamset=${True}
    ...   beamset=beamSet_6   tiltoffset=6   numberOfTransmittedSsBlocks=6 beams    beam_set_5_3=${True}
    log to console    check fault 4598 trigger after modify  beamset=beamSet_4_2  tiltoffset=5
    Wait until keyword succeeds    10min    30s    Expect Fault Should Present    faultId=4598
    Modify_BeamSet_And_TiltOffset_For_Fault4598   ru_index=${ru_index}   is_update_beamset=${False}
    ...   beamset=beamSet_6    tiltoffset=5    numberOfTransmittedSsBlocks=6 beams    beam_set_5_3=${True}
    log to console    check fault 4598 disappeared
    Wait Until Keyword Succeeds   10min   30s    Expect Fault Should Absent    faultId=4598
    [Teardown]  run keyword and ignore error   Selenium Logout And Close Browser

General_SiSo_Configuration_Management_l3call_traffic_By_Tiltoffset
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to verify L3call success when modify tiltOffset parameter
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.13.2021 - - Created
    ...    *******************
    ...    Owner_kaihui.fan@nokia-sbell.com
    [Arguments]    ${with_call}=${True}  ${with_peak}=${False}     ${ru_index}=1    ${tiltOffset}=5    ${ue_num_each_call}=${1}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    ${modify_params}  Get beamSet tiltoffset Parameters modify parameters list    ru_index=${ru_index}
    ...    tiltoffset=${tiltoffset}  is_update_beamset=${False}  beam_set_5_3=${False}
    Modify Parameters On Webem    modify_params=${modify_params}
    ${cell_list}    Get All Cell Id    ${ru_index}
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    run keyword if  ${with_call}  Get UE From Init File and Make call  cell_list=${cell_list}
    ...    with_peak=${with_peak}    ue_num_each_call=${ue_num_each_call}
    [Teardown]  run keyword and ignore error   Selenium Logout And Close Browser


Modify_BeamSet_And_TiltOffset_For_Fault4598
    [Arguments]    ${ru_index}=1   ${is_update_beamset}=${True}   ${beamset}=beamSet_2    ${tiltoffset}=7
    ...    ${numberOfTransmittedSsBlocks}=2 beams    ${beam_set_5_3}=${False}
    ${modify_params}  Get beamSet tiltoffset Parameters modify parameters list    ru_index=${ru_index}
    ...    basicBeamSet=${beamset}    tiltoffset=${tiltoffset}  is_update_beamset=${is_update_beamset}
    ...    numberOfTransmittedSsBlocks=${numberOfTransmittedSsBlocks}   beam_set_5_3=${beam_set_5_3}
    Modify Parameters On Webem    modify_params=${modify_params}

Get beamSet tiltoffset Parameters modify parameters list
    [Arguments]  ${ru_index}=1  ${basicBeamSet}=beamSet_2    ${tiltoffset}=7   ${is_update_beamset}=${True}
    ...    ${numberOfTransmittedSsBlocks}=2 beams  ${beam_set_5_3}=${False}
    log to console  Get beamSet tiltoffset Parameters modify parameters list
    ${modify_params}  create list
    ${cell_list}    Get All Cell Id    ${ru_index}
    FOR  ${cell_id}  IN  @{cell_list}
        ${group_index}=   Evaluate    int(${cell_id})-1
        ${item_tiltoffset}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
        ...    filter_param=Tilt Offset  p_name=tiltOffset  value=${tiltoffset}
        append to list  ${modify_params}  ${item_tiltoffset}
        ${item_beamset}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Basic Beam Set  p_name=basicBeamSet  value=${basicBeamSet}
        Run Keyword If   ${is_update_beamset}  append to list  ${modify_params}  ${item_beamset}
        ${item_transmit}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${group_index}
        ...    filter_param=Number of transmitted Synchronization Signal Blocks    p_name=numberOfTransmittedSsBlocks
        ...    value=${numberOfTransmittedSsBlocks}
        Run Keyword If   ${beam_set_5_3}  append to list  ${modify_params}  ${item_transmit}
    END
    [Return]  ${modify_params}

Snapshot_Full_level_showing_reason_for_a_failure_after_radio_has_been_re-started_AVQC
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to check Snapshot full level showing reason for a failure after
    ...     radio has been re-started.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.09.2024 - - Created
    ...    *******************
    ...    Owner_kaihui.fan@nokia-sbell.com
    [Arguments]  ${Tdanger_trriger}=20   ${Tprot_target}=20   ${ru_index}=1
    ...   ${fault_logger_json}=${CURDIR}/TestData/fault_logger.json
    Upload RU Fault Log Configuration  fault_logger_json=${fault_logger_json}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    ${boundary}  get the boundary of stream with 24R2   stream=${stream}
    ${tcs_parameter}    Set Variable If   '${boundary}'=='old_version'   tcs   tcs_parameters
    ${Tdanger_trriger}    Run Keyword If   '${boundary}'=='old_version'   Evaluate  float(${Tdanger_trriger})
    ...   ELSE IF   '${boundary}'=='new_version'   Evaluate  int(${Tdanger_trriger})
    ${Tprot_target}    Run Keyword If   '${boundary}'=='old_version'   Evaluate  float(${Tprot_target})
    ...   ELSE IF   '${boundary}'=='new_version'   Evaluate  int(${Tprot_target})
#    ${TPro_if}   Set Variable If   '${boundary}'=='old_version'   ${False}   ${True}
    ${Tdanger_init_before_modify}    Get Tdanger Value from Json File    ru_index=${ru_index}   tcs_parameter=${tcs_parameter}
    ${Tprot_init_before_modify}    Get Tdanger Value from Json File  ru_index=${ru_index}   tcs_parameter=${tcs_parameter}   get_parameter=Tprot
    Trigger Fault 1937    Tdanger_target=${Tdanger_trriger}  Tdanger_init=${Tdanger_init_before_modify}  ru_index=${ru_index}
    ...   tcs_parameter=${tcs_parameter}    TPro_if=${True}  Tprot_init=${Tprot_init_before_modify}   Tprot_target=${Tprot_target}
    ${Tdanger_init_after_modify}    Get Tdanger Value from Json File    ru_index=${ru_index}   tcs_parameter=${tcs_parameter}
    ${Tprot_init_after_modify}     Get Tdanger Value from Json File    ru_index=${ru_index}   tcs_parameter=${tcs_parameter}   get_parameter=Tprot
    sleep    5min
    Check fault Exist in RU and snapshot   ru_fault_log_path=/mnt/runtime/fault-log/snapshot_status.txt   RF7=${True}
    [Teardown]  recovery Fault 1937   Tdanger_target=${Tdanger_init_before_modify}   ru_index=${ru_index}
    ...   tcs_parameter=${tcs_parameter}   Tdanger_trriger=${Tdanger_init_after_modify}   TPro_if=${True}
    ...   Tprot_init=${Tprot_init_after_modify}   Tprot_target=${Tprot_init_before_modify}

Upload RU Fault Log Configuration
    [Arguments]  ${ru_index}=1  ${fault_logger_json}=${CURDIR}/TestData/fault_logger.json
    log to console   Upload RU Fault Log Configuration
    Connect to Common Unit Master    alias=ASIK Master
    Connect to RU With Allocated IP     ru_alias=RU_${ru_index}   asik_alias=ASIK Master   ru_index=${ru_index}
    csn.execute     sudo rm /ram/fault_logger.json    RU_${ru_index}
    csn.Upload file     ${fault_logger_json}    /ram/fault_logger.json     RU_${ru_index}
    sleep   20s
    csn.execute     sudo chown rfsw:rfsw /ram/fault_logger.json    RU_${ru_index}
    sleep   20s
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${cmd_temp}   Set Variable  echo "/ action create ConfigAccess /ca /module"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain Any   ${output}    done ok    Path already taken
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo '/ca action store PERMANENT DECODED "fault_logger.bin" "/ram/fault_logger.json"'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain   ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable  echo "/ca action update"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain   ${output}    done ok
    sleep    2s
    csn.disconnect    connection=RU_${ru_index}
    [Teardown]    csn.disconnect    connection=ASIK Master

General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot_AVQC
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to collect Snapshot logs in WebUI
    ...    and check if RFSW logs from Radio Unit are included in Snapshot.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.16.2020 - - Created
    ...    *******************
    ...    Owner_aaron.deng@nokia-sbell.com
    [Arguments]    ${is_get_snapshot_via_selenium}=${False}
    log to console    Wait 10 mins before Collect Snapshot
    sleep    600
    Connect to Common Unit Master
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}
        Verify RFSW Log Include In Snapshot  ru_index=${ru_index}  ru_alias=RU_${ru_index}  snapshot_path=${SAVE LOG DIRECTORY}
        ...    is_get_snapshot_via_selenium=${is_get_snapshot_via_selenium}
        Check startup runtime and soap file in ru log AVQC    ru_log=${rfsw_log_path_on_testPC}    ru_index=${ru_index}
        csn.Disconnect  connection=RU_${ru_index}
    END
    [Teardown]  csn.Disconnect  connection=ASIK Master

Check startup runtime and soap file in ru log AVQC
    [Arguments]    ${ru_log}    ${ru_index}=1
    ${ru_info}   COAM get ru detial info by ru index  ru_index=${ru_index}
    ${ru_type}   set variable  ${ru_info}[productName]
    ${ru_unit_num}    Set Variable If
    ...     '${ru_type}'=='AQQA'       8
    ...     '${ru_type}'=='AQQY'       8
    ...     '${ru_type}'=='AQQC'       8
    ...     '${ru_type}'=='AQQN'       8
    ...     '${ru_type}'=='AQQL'       8
    ...     '${ru_type}'=='AQQJ'       8
    ...     '${ru_type}'=='AQQQ'       8
    ...     '${ru_type}'=='AQQS'       8
    ...     '${ru_type}'=='AQQK'       8
    ...     '${ru_type}'=='AQHB'       8
    ...     '${ru_type}'=='AZNA'       0
    ...     '${ru_type}'=='AZHA'       0
    ...     '${ru_type}'=='AHPB'       0
    ...     '${ru_type}'=='AZQF'       0
    ...     '${ru_type}'=='AZQD'       0
    ...     '${ru_type}'=='AZQO'       0
    ...     '${ru_type}'=='AZQJ'       0
    ...     '${ru_type}'=='AHLOA'      0
    ...     '${ru_type}'=='AWHKB'      0
    ...     '${ru_type}'=='AWHQX'      0
    ...     '${ru_type}'=='AWHQN'      0
    ...     '${ru_type}'=='AWHQ2'      0
    ...     '${ru_type}'=='AWHHD'      0
    ...     '${ru_type}'=='AWHHF'      0
    ...     '${ru_type}'=='AHPF'       0
    ...     '${ru_type}'=='AHPH'       0
    ...     '${ru_type}'=='AHPJ'       0
    ...     '${ru_type}'=='AWHQU'      0
    ...     '${ru_type}'=='AWPTD'      0
    ...     '${ru_type}'=='AVQA'       1
    ...     '${ru_type}'=='AVQC'       1
    ...     4
    ${ru_log_path}   Get Substring  ${ru_log}  0  -4
    Extract Zip File    ${ru_log_path}.zip    ${ru_log_path}
    ${soap_info}    Run    command=ls '${ru_log_path}' | grep "1011_UnitOAM_SOAP_Log.zip"
    ${startup_info}    Run    command=ls '${ru_log_path}' | grep "11_ccsrt-startup"
    ${runtime_info}    Run    command=ls '${ru_log_path}' | grep "11_ccsrt-runtime"
    Should Contain    ${soap_info}    1011_UnitOAM_SOAP_Log
    FOR    ${index}    IN RANGE    ${ru_unit_num}+1
        Should Contain    ${startup_info}    1${index}11_ccsrt-startup
        Should Contain    ${runtime_info}    1${index}11_ccsrt-runtime
    END
    Run Keyword If    '${ru_type}'=='AVQC' or '${ru_type}'=='AVQA'   Should Contain    ${startup_info}    2011_ccsrt-startup
    Run Keyword If    '${ru_type}'=='AVQC' or '${ru_type}'=='AVQA'   Should Contain    ${runtime_info}    2011_ccsrt-runtime

General_SiSo_Modify_Prach_Online_with_Frame_Structure_Without_Call
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to check if calibration of beamforming can be activated
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 15.11.2022 - - Created
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell
    [Arguments]  ${prach_index_list}    ${band}=${None}    ${frame_structure}=${None}    ${ue_num_each_call}=1    ${times}=1
    ${commission_prach}     Evaluate   random.choice(${prach_index_list})    modules=random
    Modify Frame Structure via recommission    band=${band}    frame_structure=${frame_structure}    prach_index=${commission_prach}
    UE attach detach with cell list    times=int(${times})    ue_num_each_call=${ue_num_each_call}

UE attach detach with cell list
    [Arguments]  ${ue_num_each_call}=1    ${times}=1    ${connection}=GNB_OAM
    ${cell_list}    get all cell id    connection=${connection}
    ${ue_index_list}    ${get_cell_list}    Get UE List for Given Cell List    cell_list=${cell_list}    ue_num_each_call=${ue_num_each_call}
    ...    scf_path=${scf_path}
    FOR  ${i}  IN RANGE    ${times}
        log to console    \nue attach times: ${i}
        UE Attach And Detach For All Cells    cell_list=${cell_list}    ue_num_each_call=${ue_num_each_call}
    END

UE Attach And Detach For All Cells
    [Arguments]  ${cell_list}  ${ue_num_each_call}=1
    ${ue_index_list}    ${get_cell_list}    Get UE List for Given Cell List    cell_list=${cell_list}    ue_num_each_call=${ue_num_each_call}
    ...    scf_path=${scf_path}
    FOR  ${ue_index}  IN  @{ue_index_list}
        CB009563_common_keyword.UE Attach And Detach    ue_index=${ue_index}
    END

CB009563_common_keyword.UE Attach And Detach
    [Arguments]  ${ue_index}=${0}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${pci}    Get Ue should attached pci    ue_index=${ue_index}    scf_path=${scf_path}    mobile_network_system=NR
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    pci=${pci}
    power_ue.Verify attach    ue_type=${ue_type}    ue_index=${ue_index}    5Grach_ed=${5Grach_ed}
    [Teardown]    run keyword and ignore error    UE Teardown    ue_index=${ue_index}

UE Teardown
    [Arguments]  ${ue_index}=${0}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    [Teardown]    run keyword and ignore error    power_ue.Teardown UE  ue_type=${ue_type}    ue_index=${ue_index}

Trigger Enter And Exit Deepsleep Mode Repetitively
    [Arguments]    ${duration}=${3600}
    Get X2 link shutdown waiting time
    ${cell_id_list}  Get All Cell Id
    ${cell_num}    get length  ${cell_id_list}
    ${check_alarm}    set variable if    ${cell_num}==1    ${True}    ${False}

    ${start_time}    robot.libraries.DateTime.Get Current Date
    ${start_time_secs}    robot.libraries.DateTime.Convert Date    ${start_time}    result_format=epoch
    Log To Console    \nThe start time for deepsleep mode repetitively: ${start_time}
    FOR    ${time}    IN RANGE    ${100}
        Lock cells or groups and check status  lock_list=${cell_id_list}  is_group=${False}
        ...    check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
        sleep    300s
        Unlock cells or groups and check status  lock_list=${cell_id_list}  is_group=${False}
        ...    check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'

        ${end_time}    robot.libraries.DateTime.Get Current Date
        Log To Console    \nThe ${time}th end time for deepsleep mode repetitively: ${end_time}
        ${end_time_secs}    robot.libraries.DateTime.Convert Date    ${end_time}    result_format=epoch
        ${time_interval}    Evaluate    abs(float(${end_time_secs}) - float(${start_time_secs}))
        ${status}    Evaluate    ${time_interval} > ${duration}
        Exit For Loop If    "${status}"=="True"
    END

Get Extra Time For KPI51
    [Arguments]    ${ru_index}=${1}    ${cell_list}=${None}    ${default_extra_time}=${20}    ${connection}=GNB_OAM
    ${productName}    get_ru_product_name_via_admin    ru_index=${ru_index}    connection=${connection}
    IF    '${cell_list}'=='None'
        ${cell_list}    Get All Cell Id    ru_index=${ru_index}
    END
    # https://jiradc.ext.net.nokia.com/browse/WESTLAKE-12286
    ${cell_count}    Evaluate    len(${cell_list})
    IF    ${cell_count} == 4
        ${extra_time}    Evaluate    ${default_extra_time} + 60
    ELSE IF    ${cell_count} == 3
        ${extra_time}    Evaluate    ${default_extra_time} + 30
    ELSE
        ${extra_time}    Set Variable    ${default_extra_time}
    END
    [Return]    ${extra_time}

L3Call_setup_with_data_transfer_conducted
    [Arguments]  ${with_call}=${True}  ${with_peak}=${False}  ${duration}=${60}  ${ue_num_each_call}=1
    ...   ${ru_index}=${1}   ${suite_name}=default   ${test_name}=default
    ${cell_list}    Get All Cell Id    ru_index=${ru_index}
    Run Keyword If    ${with_call}    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${with_peak}
    ...   duration=${duration}   ue_num_each_call=${ue_num_each_call}   suite_name=${suite_name}   test_name=${test_name}
