*** Settings ***
Documentation    These are common keywords for CB009936 related cases
...              Please do not modify the file without notification to author
...              Contact: shifu.lan@nokia-sbell.com
...              Squard: VRF4_SG4

Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_commssion.robot
Resource    taf/rfrl/common_resources/robot/coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot

Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/mcs_config.py
Library    String
Library    OperatingSystem

Variables   testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009936/Resource/CB009936_variables.py


*** Variables ***
${software_packet_path}


*** Keywords ***
Returning From Extreme DeepSleep Mode To Normal Via RU Operation
    [Arguments]    ${with_call}=${True}  ${with_peak}=${False}  ${call_duration}=${60}    ${upload_tp}=${True}
    ...    ${upload_duration}=${True}    ${suite_name}=default    ${test_name}=default
    ...    ${ue_num_each_call}=1    ${ru_index}=${1}    ${connection}=GNB_OAM
    ${ru_dist_name}    Set Variable    MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}
    Enable Extreme DeepSleep Mode For RU    dist_name=${ru_dist_name}    connection=${connection}

    # WESTLAKE-12502: CFAM/CUDO cannot support to trigger DSM/EDSM by locking RRU after PR841003.
    log to console    Block the all cells of RRU and check RRU if entering Extreme DeepSleep Mode
    Selenium Login And Disable Screen Lock
    Get X2 link shutdown waiting time
    ${cell_list}      Get All Cell Id    ru_index=${ru_index}
    ${cell_num}    get length  ${cell_list}
    ${check_alarm}  set variable if  ${cell_num}==1  ${True}  ${False}
    Block cells and check status   block_list=${cell_list}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
    Sleep    5min
    # Wait Until Keyword Succeeds    5min    5s    RU Status Info Should Be as Expect    ru_index=${ru_index}    powerState=SLEEP_EXTREME
    Wait Until Keyword Succeeds    5min    5s    RU Status Info Should Be as Expect    ru_index=${ru_index}
        ...    powerState=SLEEP_EXTREME    operationalState=enabled
    Keep Silent After RU In Extreme DeepSleep Mode    ru_index=${ru_index}    silent_time=${600}

    log to console    Unblock the all cells of RRU and check RRU if returning from Extreme DeepSleep Mode
    UnBlock Cells and check status   block_list=${cell_list}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'    skip_deepsleep=${True}
    # Wait Until Keyword Succeeds    5min    5s    RU Status Info Should Be as Expect    ru_index=${ru_index}    powerState=AWAKE
    Wait Until Keyword Succeeds    5min    5s    RU Status Info Should Be as Expect    ru_index=${ru_index}
        ...    powerState=AWAKE    operationalState=enabled
    COAM Wait gnb And Cells ready    timeout=15min    connection=${connection}

    log to console    Make call for nr cells and check tput
    run keyword if  ${with_call}    Get UE From Init File and Make call    cell_list=${cell_list}
    ...    with_peak=${with_peak}    duration=${call_duration}    upload_tp=${upload_tp}    upload_duration=${upload_duration}
    ...    suite_name=${suite_name}    test_name=${test_name}    ue_num_each_call=${ue_num_each_call}
    [Teardown]   Selenium Logout And Close Browser


Rollback Software During RU Entering Extreme DeepSleep Mode
    [Arguments]    ${ru_index}=${1}    ${connection}=GNB_OAM    ${rollback_times}=${2}
    ${ru_dist_name}    Set Variable    MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}
    Enable Extreme DeepSleep Mode For RU    dist_name=${ru_dist_name}    connection=${connection}

    # WESTLAKE-12502: CFAM/CUDO cannot support to trigger DSM/EDSM by locking RRU after PR841003.
    log to console    Block the all cells of RRU and check RRU if entering Extreme DeepSleep Mode
    Selenium Login And Disable Screen Lock
    Get X2 link shutdown waiting time
    ${cell_list}      Get All Cell Id    ru_index=${ru_index}
    ${cell_num}    get length  ${cell_list}
    ${check_alarm}  set variable if  ${cell_num}==1  ${True}  ${False}
    Block cells and check status   block_list=${cell_list}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
    Sleep    5min
    # Wait Until Keyword Succeeds    5min    5s    RU Status Info Should Be as Expect    ru_index=${ru_index}    powerState=SLEEP_EXTREME
    Wait Until Keyword Succeeds    5min    5s    RU Status Info Should Be as Expect    ru_index=${ru_index}
        ...    powerState=SLEEP_EXTREME    operationalState=enabled
    Keep Silent After RU In Extreme DeepSleep Mode    ru_index=${ru_index}    silent_time=${600}

    FOR  ${i}  IN RANGE  ${rollback_times}
        IF    ${i} == 0
            Log    Rollback software when RU in EDSM    console=yes
        ELSE
            Log    Rollback software for recover environment    console=yes
        END
        # https://jiradc.ext.net.nokia.com/browse/WESTLAKE-11681, Default timeout=300s is not enough, set to 600s
        ${rollback_status}    Run Keyword And Return Status    coam.rollback_software    timeout=${600}    connection=${connection}

        IF  not ${rollback_status}
            FAIL  Software rollback was not performed.
        END
        Sleep    5min  # Wait for software rollback success
        # Connection was invalid after software rollback, need to manually reconnect
        Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
        Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=${connection}
        Wait Until Keyword Succeeds    5min    5s    RU Status Info Should Be as Expect    ru_index=${ru_index}
        ...    powerState=AWAKE    operationalState=enabled
    END

    log to console    Unblock the all cells of RRU and check RRU if returning from Extreme DeepSleep Mode
    Run Keyword And Ignore Error    UnBlock Cells and check status   block_list=${cell_list}
    ...    check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'    skip_deepsleep=${True}
    COAM Wait gnb And Cells ready    timeout=15min    connection=${connection}
    [Teardown]   Selenium Logout And Close Browser

Enable Extreme DeepSleep Mode For RU
    [Arguments]    ${dist_name}    ${parameter}=energySavingMode    ${new_value}=DEEPSLEEP_EXTREME_SFP    ${connection}=GNB_OAM
    Log    \nChange RRU ${parameter} to ${new_value}    console=yes
    coam.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=${parameter}
    ...    value=${new_value}    operation=update    connection=${connection}
    Connect to gnb coam via ssl    connection=${connection}
    ${dist_parameters}    coam.get_parameter_by_distname    dist_name=${dist_name}    connection=${connection}
    Should Be Equal As Strings   ${dist_parameters[0]['parameters']['energySavingMode']}     ${new_value}
    ...    msg=parameter ${parameter} value is not equal to ${new_value}

Keep Silent After RU In Extreme DeepSleep Mode
    [Documentation]    Improvement for PR807410([CB012091][AVQC][eCpri50] RU auto awake from EDSM after a few minutes)
    ...    Keep silent for a period of time after RU in Extreme DeepSleep Mode
    [Arguments]    ${ru_index}=${1}    ${silent_time}=${600}
    Log    \nRRU should keep silent for ${silent_time} seconds in EDSM
    ${start_time}    Set Variable    ${{time.time()}}
    ${end_time}    Set Variable    ${{$start_time + $silent_time}}
    WHILE    ${{time.time()}} < ${end_time}
        RU Status Info Should Be as Expect    ru_index=${ru_index}    operationalState=enabled    powerState=SLEEP_EXTREME
        Sleep    10s  # Check RU status every 10 seconds
    END
    log to console    \nRRU kept silent for ${silent_time} seconds in EDSM

SISO Coam Mcs Test Setup
    [Arguments]    ${fail_with_alarms}=${True}    ${is_ru_log_collecting_enable}=${True}
    SISO Coam Test Setup    fail_with_alarms=${fail_with_alarms}    is_ru_log_collecting_enable=${is_ru_log_collecting_enable}
    # check_mcs_by_csv    scf_path=${Case_SCF_Path}

RTWP_counters_reflects_high_interference_during_a_specific_period
    [Arguments]    ${with_call}=${True}    ${call_duration}=${60}    ${ue_num_each_call}=1    ${counter_wait_interval}=10min
    ...    ${suite_name}=default    ${test_name}=default    ${connection}=GNB_OAM
    Modify RTWP Measurement Parameters    connection=${connection}
    Sleep    ${counter_wait_interval}
    ${check_cell}    Get Ues Attached Cell    ue_num_each_call=${ue_num_each_call}
    Check RTWP Counters Via Cell    cell_id=${check_cell}    connection=${connection}

    log to console    Make call for UL and check counter value
    ${cell_list}    create list    ${check_cell}
    ${ue_index_list}    ${cell_list}    Get UE List for Given Cell List    cell_list=${cell_list}    ue_num_each_call=${ue_num_each_call}
    ${cell_and_peak_info}    generate peak information     cell_list=${cell_list}
    ...    suite_name=${suite_name}    test_name=${test_name}
    ${ue_and_cell}    Ue Attach and Start DL UL Traffic    ue_index_list=${ue_index_list}
    ...    cell_and_peak_info=${cell_and_peak_info}    direction=UL    duration=${call_duration}
    Sleep    ${counter_wait_interval}
    Check RTWP Counters Via Cell    cell_id=${check_cell}    with_call=${with_call}    connection=${connection}
    Ue Stop DL UL Traffic and Detach    ue_index_list=${ue_index_list}

    Sleep    ${counter_wait_interval}
    Check RTWP Counters Via Cell    cell_id=${check_cell}    connection=${connection}

Modify RTWP Measurement Parameters
    [Arguments]   ${counter_duration}=5min   ${connection}=GNB_OAM   ${delta_json}=delta_rtwp.json
    ${delta_id}    Set Variable    Online_modify_RTWP_measurement_parameters
    ${delta_json_path}    Set Variable    ${SAVE LOG DIRECTORY}/${delta_json}
    coam.Create Delta    delta_id=${delta_id}
    Log To Console    \nModify RTWP Measurement Parameters
    ${nrpmrnl_dist_name}    Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPMRNL-1
    coam.Append Parameter Update To Delta  dist_name=${nrpmrnl_dist_name}  parameter=miNrRtwp  value=${counter_duration}  delta_id=${delta_id}
    ${bts_dist_name}    Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    coam.Append Parameter Update To Delta  dist_name=${bts_dist_name}  parameter=actRtwpMeasurement  value=true  delta_id=${delta_id}
    coam.Get Delta    delta_id=${delta_id}
    coam.Save Delta    target_file_name=${delta_json_path}    delta_id=${delta_id}
    coam.Perform delta recommissioning    delta_file=${delta_json_path}    skip_parameter_relation_errors=${False}    connection=${connection}
    coam.Remove Delta    delta_id=${delta_id}
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    Should Be True    ${alarm_status}

Check RTWP Counters Via Cell
    [Arguments]   ${cell_id}   ${with_call}=${False}   ${counter_type}=NRRTP    ${connection}=GNB_OAM
    IF    ${with_call}
        ${min_counter_value}    Set Variable    -80
        ${max_counter_value}    Set Variable    -60
    ELSE
        ${min_counter_value}    Set Variable    -95
        ${max_counter_value}    Set Variable    -80
    END
    Wait Until Keyword Succeeds   3x   10s   Connect to gnb coam via ssl    connection=${connection}
    ${timestamp}    DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Log    \nRecord the timestamp for checking counter data: ${timestamp}
    ${counter_info}    coam.get_pm_counters    counter_ids=${counter_ids_rtp_avg_str}    connection=${connection}
    FOR    ${counter_id}    IN    @{counter_ids_rtp_avg_list}
        ${cell_counter_value}    Set Variable
        ...    ${counter_info['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-${cell_id}']['${counter_type}']}
        ${latest_counter_value}    Get Latest RTWP Counter    ${cell_counter_value}[${counter_id}]
        Should Be True     ${min_counter_value} < ${latest_counter_value} < ${max_counter_value}
    END

Get Latest RTWP Counter
    [Arguments]    ${input_dict}
    ${output_dict}    Create Dictionary
    FOR    ${key}    IN    @{input_dict.keys()}
        ${new_key}    Set Variable    ${{datetime.datetime.fromtimestamp(int($key)).strftime("%Y-%m-%d %H:%M:%S")}}
        Set To Dictionary    ${output_dict}    ${new_key}    ${input_dict['${key}']}
    END
    Log    \nLatest RTWP Counters data: ${output_dict}
    ${counter_value}    Get Dictionary Values    ${output_dict}
    [Return]    ${counter_value}[-1]

# common keyword used for RF sharing
RF sharing Test Setup
    Run Keyword And Ignore Error    SISO Coam Test Setup
    Power On Second Gnb
    Sleep   180s
    Wait Until Keyword Succeeds   5min   30s   Connect to gnb coam via ssl   connection=GNB_OAM   gnb_index=0
    Wait Until Keyword Succeeds   5min   30s   Connect to gnb coam via ssl   connection=GNB_OAM_1   gnb_index=1

    Upgrade Second Gnb Software If Needed
    # "Sleep 600s" for making sure the SECONDARY BTS is stable, and commission scf can be successfully.
    Sleep    600
    Wait Until Keyword Succeeds   5min   30s   Connect to gnb coam via ssl   connection=GNB_OAM_1   gnb_index=1

RF sharing Test Teardown
    ${is_file_existed} =    Run Keyword And Return Status    File Should Exist    ${software_packet_path}
    Run Keyword If   ${is_file_existed}     Remove File    ${software_packet_path}

    Wait Until Keyword Succeeds   5min   30s   Connect to gnb coam via ssl   connection=GNB_OAM_1   gnb_index=1
    Save Coam Snapshot    target_dir=${SUITE_LOG_PATH}    connection=GNB_OAM_1

    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM_1

    Power Off Second Gnb
    SISO Coam Test Teardown    perform_case_scf=${True}

Power On Second Gnb
    Perform Site Power On    gnb_index=${1}
    ...   model=${tl.gnbs[1].dus[0].airscale.common_units[0].pdu_port.pdu.vendor}

Power Off Second Gnb
    Perform Site Power Off    gnb_index=${1}
    ...   model=${tl.gnbs[1].dus[0].airscale.common_units[0].pdu_port.pdu.vendor}

Upgrade Second Gnb Software If Needed
    ${second_gnb_sw_version} =    Get Active SW Version    connection=GNB_OAM_1
    IF  "${Active_SW_version}" != "${second_gnb_sw_version}"
        ${stream} =   Get Stream from Version    ${Active_SW_version}
        # https://jiradc.ext.net.nokia.com/browse/WESTLAKE-12473, If the stream is SBTS00, it needs to be converted to SBTS00 build format.
        # Other streams don't need conversion, directly use the main BTS version for upgrade
        IF  "${stream}" == "SBTS00"
            ${Build_stream}    Fetch From Left    ${Active_SW_version}    _
            ${build}=    Replace String    ${Active_SW_version}      ${Build_stream}     SBTS00
        ELSE
            ${build}=    Set Variable    ${Active_SW_version}
        END
        Log     upgrade second Gnb software to ${build}
        # https://jiradc.ext.net.nokia.com/browse/WESTLAKE-12521 Add 300s to make sure RU was detected.
        Sleep   300
        ${sw_file_path} =    CI_commssion.Get SW file Path     build=${build}    stream=${stream}
        Set Suite Variable      ${software_packet_path}     ${sw_file_path}
        CI_commssion.Upgrade RU    build=${build}    stream=${stream}    connection=GNB_OAM_1     timeout=${3600}
    END

Commissioning SCF And Check On Air For RF Sharing
    [Arguments]   ${first_scf_path}=${Golden_SCF_Path}  ${second_scf_path}=${Golden_SCF_Path}
    ${scf_path} =    Commissioning SCF For RF Sharing   scf_path=${first_scf_path}    gnb_index=0    pdl_checking=${True}
    Log    commissioning ${scf_path} on primary gnb
    Sleep   300s
    # skip PDL validate when recommission on second gnb. https://jiradc.ext.net.nokia.com/browse/WESTLAKE-12543
    ${scf_path} =    Commissioning SCF For RF Sharing   scf_path=${second_scf_path}    gnb_index=1    pdl_checking=${False}
    Log    commissioning ${scf_path} on second gnb
    Sleep   180s

    Check On Air For RF Sharing    gnb_index=0
    Check On Air For RF Sharing    gnb_index=1

Commissioning SCF For RF Sharing
    [Arguments]    ${scf_path}=${Golden_SCF_Path}    ${gnb_index}=1    ${pdl_checking}=${True}
    ${connection}  Set Variable If  ${gnb_index}==0   GNB_OAM   GNB_OAM_${gnb_index}
    COAM Commission with scf file    scf_file_path=${scf_path}  timeout=600   is_pdl_checking_needed=${pdl_checking}   connection=${connection}
    [Return]    ${scf_path}

Check On Air For RF Sharing
    [Arguments]    ${gnb_index}=1
    ${connection}  Set Variable If  ${gnb_index}==0   GNB_OAM   GNB_OAM_${gnb_index}
    Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}   connection=${connection}

RF_Sharing_Configuration_to_Validate_the_Backward_Compatibility_72a
    # Step 1: Commisioning SCF on 2 Gnbs, and check on air
    ${primary_gnb_scf_path}    Replace String    ${Golden_SCF_Path}    .xml    _1S-2CC-72E-RFS-PRIMARY.xml
    ${second_gnb_scf_path}    Replace String    ${Golden_SCF_Path}    .xml    _1S-2CC-72E-RFS-SECONDARY.xml

    Commissioning SCF And Check On Air For RF Sharing  first_scf_path=${primary_gnb_scf_path}     second_scf_path=${second_gnb_scf_path}

    # Step 2: Check alarm status to make sure no alarm
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}    connection=GNB_OAM
    Should Be True    ${alarm_status}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}    connection=GNB_OAM_1
    Should Be True    ${alarm_status}

    # Step 3: make call and Check traffic
    ${ue_reboot_dict}    create dictionary
    set test variable    ${ue_reboot_dict}
    ${cell_list}    get all cell id    connection=GNB_OAM
    Get UE From Init File and Make call    cell_list=${cell_list}
    ...    with_peak=${True}    duration=${60}    upload_tp=${True}    upload_duration=${True}
    ...    suite_name=default    test_name=default    ue_num_each_call=${1}  scf_path=${primary_gnb_scf_path}
    ...    connection=GNB_OAM    gnb_index=${0}

    ${ue_reboot_dict}    create dictionary
    set test variable    ${ue_reboot_dict}
    ${cell_list}    get all cell id    connection=GNB_OAM_1
    Get UE From Init File and Make call    cell_list=${cell_list}
    ...    with_peak=${True}    duration=${60}    upload_tp=${True}    upload_duration=${True}
    ...    suite_name=default    test_name=default    ue_num_each_call=${1}  scf_path=${second_gnb_scf_path}
    ...    connection=GNB_OAM_1    gnb_index=${1}
