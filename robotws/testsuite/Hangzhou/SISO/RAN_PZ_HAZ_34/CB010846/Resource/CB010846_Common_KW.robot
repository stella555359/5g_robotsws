*** Settings ***
Documentation     author: Zhang Xuewen
...               Group: HGZ_SG5
...               contact: xuewen.zhang@nokia-sbell.com

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource      ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG5/robot/optical_switch/optical_switch.robot
Resource      testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009333/resource/CB009333_Common_KW.robot
Resource      testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB006277/resource/resources_l3call.robot
Library       ../../CB011159/lib/CB011159_TTI_Analyzer.py

*** Variables ***
${connection}    sfp

*** Keywords ***
eCPRI_RU_resiliency_to_BTS_DU_L1Soc_reset_Controlled_case
    [Arguments]    ${ru_index}=${1}
    [Documentation]   A test scenario to check that the RU resiliency to BTS-DU L1Soc reset function on-line activation
    ...  works fine in test environment with interworkings (CB007447&CB007437)
    Step 1 gNB start up with CB010846-A is activated and CB005833 is not activated
    gNB up and running without unexpected alarm
    ${uptime1}   Get RU Uptime Result Frome WebEM   ru_index=${ru_index}
    Step 2 Hard RAT reset by WebEM to trigger L1Soc reset
    Step 3 Wait for a cntrldResetMplaneBreakTime duration
    ${uptime2}   Get RU Uptime Result Frome WebEM   ru_index=${ru_index}
    Check RU not reset by uptime   time_1=${uptime1}   time_2=${uptime2}
    Step 4 Ue attach and start both dl and ul traffic

Check RU not reset by uptime
    [Arguments]    ${time_1}=${0}    ${time_2}=${0}
    ${time_1_in_seconds}    Parse Time To Seconds    ${time_1}
    ${time_2_in_seconds}    Parse Time To Seconds   ${time_2}
    # Compare the two times
    should be true   ${time_2_in_seconds} > ${time_1_in_seconds}

Parse Time To Seconds
    [Arguments]    ${time_str}
    # uptime format on WebEM is 0d 3h 12m 4s
    ${days}        Set Variable    ${time_str.split("d")[0]}
    ${hours}       Set Variable    ${time_str.split("d")[-1].split("h")[0]}
    ${minutes}     Set Variable    ${time_str.split("h")[-1].split("m")[0]}
    ${seconds}     Set Variable    ${time_str.split("m")[-1].split("s")[0]}
    log to console   days=${days} hours=${hours} minutes=${minutes} seconds=${seconds}
    ${total_seconds}    Evaluate    int(${days}) * 86400 + int(${hours}) * 3600 + int(${minutes}) * 60 + int(${seconds})
    [Return]    ${total_seconds}

Get RU Uptime Result Frome WebEM
    [Arguments]    ${ru_index}=1
    log to console    Get RU${ru_index} Uptime Result Frome WebEM
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    ${ru_info}    selenium_coam.get_ru_info   ru_index=1
    [Return]    ${ru_info['Uptime']}
    [Teardown]    Run keywords    Selenium Logout And Close Browser

eCPRI_RU_resiliency_to_BTS_DU_L1Soc_reset_on_line_activation
    [Arguments]
    [Documentation]    A test scenario to check that the RU resiliency to BTS-DU L1Soc reset function on-line activation
    ...  works fine in test environment with interworkings (CB007447&CB007437)
    Set RU reset Resiliency and M-plane break time   actRuResetResiliency=true   uncntrldResetMplaneBreakTime=${300}
    ...  cntrldResetMplaneBreakTimeSite=${300}
    Check activation status: uncontrolled case=ON and controlled case=ON

    Set RU reset Resiliency and M-plane break time  actRuResetResiliency=false   uncntrldResetMplaneBreakTime=${300}
    ...   cntrldResetMplaneBreakTimeSite=${300}
    Check activation status: uncontrolled case=OFF and controlled case=OFF
    gNB up and running without unexpected alarm

Check activation status: uncontrolled case=ON and controlled case=ON
    ${uptime1}   Get RU Uptime Result Frome WebEM   ru_index=1
    NR RAT Reset
    Step 3 Wait for a cntrldResetMplaneBreakTime duration
    ${uptime2}   Get RU Uptime Result Frome WebEM   ru_index=1
    Check RU not reset by uptime   time_1=${uptime1}   time_2=${uptime2}

Check activation status: uncontrolled case=OFF and controlled case=OFF
    ${uptime1}   Get RU Uptime Result Frome WebEM   ru_index=1
    NR RAT Reset
    Step 3 Wait for a cntrldResetMplaneBreakTime duration
    ${uptime2}   Get RU Uptime Result Frome WebEM   ru_index=1
    ${time_1_in_seconds}    Parse Time To Seconds    ${uptime1}
    ${time_2_in_seconds}    Parse Time To Seconds   ${uptime2}
    # Compare the two times
    should be true   ${time_2_in_seconds} < ${time_1_in_seconds}

eCPRI_RU_resiliency_to_BTS_DU_L1Soc_reset_uncontrolled_case
    [Arguments]    ${ru_index}=1
    [Documentation]
    add fault to the allowed fault list    faultId=${1868}
    add fault to the allowed fault list    faultId=${1815}
    add fault to allowed history fault list    faultId=${1868}
    add fault to allowed history fault list    faultId=${1815}

    #sync+config+data locked: 10+1815; sync+data locked: 16+1815
    ${fault_list}    Create List    10    16    1815    1868
    Allowed Watchdog additional alarms    fault_list=${fault_list}

    Step 1 gNB start up with CB010846-A is activated and CB005833 is not activated
    Set RU reset Resiliency and M-plane break time   actRuResetResiliency=true   uncntrldResetMplaneBreakTime=${900}
    ${uptime1}   Get RU Uptime Result Frome WebEM   ru_index=${ru_index}
    Step 2 lock primary link or unplug the canlink for 5mins
    ${uptime2}   Get RU Uptime Result Frome WebEM   ru_index=${ru_index}
    Check RU not reset by uptime   time_1=${uptime1}   time_2=${uptime2}
    Step 3 unlock primary link or plug the cablink
    gNB up and running without unexpected alarm

Step 2 lock primary link or unplug the canlink for 5mins
    [Arguments]
    log to console  Step 2 lock primary link or unplug the canlink for 5mins
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    Add LANE Object Via Webem
    log to console    \nLock LANE From SFP For Specific RMOD with Primary Link - Started
    ${bbmod_pName}    set variable    ABIP
    &{lock_info}    Lock LANE From SFP For Specific RMOD with Primary Link    bb_hw_name=${bbmod_pName}
    ...    LANE_Id=1    connection=${connection}
    Set Test Variable    ${physPort}    ${lock_info}[HW_port_Id]
    log to console    \nLock LANE From SFP For Specific RMOD with Primary Link - Completed

#    wait until keyword succeeds    10min    30s    optical_switch.Expect Fault Should Present In Active or History Alarms
#    ...    faultId=${10}
#    ...    source=${None}
#    ...    connection=${connection}
#    ...    du_index=${0}
#    ...    is_need_to_setup_gnb_connection=${True}
#    ...    timeout=${300}
#    ...    severity=${None}
#    optical_switch.Add Fault To The Allowed History Fault List    faultId=${10}

    Run Keyword If    ${if_sync_config_data}    Run Keywords
    ...    wait until keyword succeeds    10min    30s    optical_switch.Expect Fault Should Present In Active or History Alarms
    ...    faultId=${10}
    ...    source=${None}
    ...    connection=${connection}
    ...    du_index=${0}
    ...    is_need_to_setup_gnb_connection=${True}
    ...    timeout=${300}
    ...    severity=${None}    AND
    ...    optical_switch.Add Fault To The Allowed History Fault List    faultId=${10}
    ...    ELSE IF    ${if_sync_data}    Run Keywords
    ...    wait until keyword succeeds    10min    30s    optical_switch.Expect Fault Should Present In Active or History Alarms
    ...    faultId=${16}
    ...    source=${None}
    ...    connection=${connection}
    ...    du_index=${0}
    ...    is_need_to_setup_gnb_connection=${True}
    ...    timeout=${300}
    ...    severity=${None}    AND
    ...    optical_switch.Add Fault To The Allowed History Fault List    faultId=${16}
    ...    ELSE    log to console    \nERROR, please check cable info.
    Sleep  5min
    [Teardown]    Run keywords    Selenium Logout And Close Browser

Step 3 unlock primary link or plug the cablink
    [Arguments]
    log to console  Step 3 unlock primary link or plug the cablink
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    log to console    \nUnlock LANE From SFP For Specific RMOD with Primary Link - Started
    optical_switch.Unlock LANE From SFP    bb_hw_name=${bbmod_pName}    object_name=${physPort}    LANE_Id=1
    log to console    \nUnlock LANE From SFP By Random: ${physPort}_LANE-1 - Completed
    Wait until Keyword Succeeds    10min  30s    Check all cells info should be onair    connection=${connection}
    [Teardown]    Run keywords    Selenium Logout And Close Browser

Add LANE Object Via Webem
    [Arguments]
    log to console  \n***Add LANE Object Via Webem***
    coam_gnb_classical.Connect to gnb coam via ssl    connection=${connection}
    &{Board_pName}    optical_switch.Get Board Product Name
    Set Test Variable    ${smod_pName}    ${Board_pName['smod_pName']}
    Set Test Variable    ${bbmod_pName}    ${Board_pName['bbmod_pName']}
    ${is_ASOx}    Run Keyword And Return Status    should contain    ${smod_pName}    ASO
    log to console    \nSMOD: ${smod_pName}, BBMOD: ${bbmod_pName}
    Return From Keyword If   '${is_ASOx}' == '${True}'    WRN: Skip checking with ASOx serial, TBD.

    bts_selenium.Selenium Login And Disable Screen Lock
    log to console    \nRemove all SFP objects for specific BBMOD - Started
    run keyword and continue on failure    Online Remove All Object SFP For Specific BBMOD    bbmode_id=1
    log to console    \nRemove all SFP objects for specific BBMOD - Completed
    Sleep    5s
    log to console    \nAdd all SFP and LANE objects for specific BBMOD - Started
    run keyword and continue on failure    Online Add All Object SFP and LANE For Specific BBMOD    bbmode_id=1
    ...    connection=${connection}
    log to console    \nAdd all SFP and LANE objects for specific BBMOD - Completed

Step 1 gNB start up with CB010846-A is activated and CB005833 is not activated
    [Arguments]     ${actRuResetResiliency}=true    ${actEcpriMPlaneResilience}=false
    log to console   Step1: Enable CB010846-A
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate RU reset resiliency   abbr=actRuResetResiliency
    ...    new_value=${actRuResetResiliency}    node_index=${0}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate eCPRI M-Plane Resilience   abbr=actEcpriMPlaneResilience
    ...    new_value=${actEcpriMPlaneResilience}    node_index=${0}
    ${result}     Run Keyword And Ignore Error    selenium_coam.validate_plan
    ${result}     Run Keyword If   '${result[0]}'=='PASS'   Check Validate Errors

    Run Keyword If   "${result}"=="None"   log to console  no parameter change!
    ...   ELSE IF   "${result[0]}"=="${0}"   selenium_coam.activate_plan
    ...   ELSE IF   ${result[0]}>0  Run Keywords
    ...   selenium_coam.save_screenshot   filename=Screen_relation_errors.png    screenshot_dir=${TS_CASE_LOG_PATH}  AND
    ...   selenium_coam.save_bts_configuration    save_configuration_type=${1}   AND
    ...   selenium_coam.undo_changes
    Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    [Teardown]    Run keywords    Selenium Logout And Close Browser

Check Validate Errors
    [Documentation]   Validate Plan and Report Error
    ${defination_errors}    selenium_coam.get_definition_errors
    ${relation_errors}      selenium_coam.get_relation_errors
    #${hardware_errors}      selenium_coam.get_hardware_errors
    #${errors}    combine lists    ${defination_errors}   ${relation_errors}    ${hardware_errors}
    ${errors}    combine lists    ${defination_errors}   ${relation_errors}
    ${errNum}    Get Length   ${errors}
    Run Keyword If    ${errNum} != 0    Run Keywords
    ...    Log to console    The current BTS exist ${errNum} errors.    AND
    ...    Log to console    defination_errors: ${defination_errors}    AND
    ...    Log to console    relation_errors: ${relation_errors}
    #...    Log to console    relation_errors: ${relation_errors}        AND
    #...    Log to console    hardware_errors: ${hardware_errors}
    #[Return]    ${errNum}   ${defination_errors}   ${relation_errors}   ${hardware_errors}
    [Return]    ${errNum}   ${defination_errors}   ${relation_errors}

gNB up and running without unexpected alarm
    [Arguments]    ${gnb_index}=0
    ${connection}  Set Variable If  ${gnb_index}==0   GNB_OAM   GNB_OAM_${gnb_index}
    Wait Until Keyword Succeeds   5min   30s   Connect to gnb coam via ssl   connection=${connection}   gnb_index=${gnb_index}
    Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}   connection=${connection}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist
    ...    file_path=${TS_CASE_LOG_PATH}   allowed_faults=@{ALLOWED_FAULT}    connection=${connection}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    file_path=${TS_CASE_LOG_PATH}    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Step 2 Hard RAT reset by WebEM to trigger L1Soc reset
    [Arguments]
    log to console  Step 2 Hard RAT reset by WebEM to trigger L1Soc reset
    NR RAT Reset

NR RAT Reset
    [Arguments]    ${with_hard}=${True}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    selenium_coam.reset_nr    with_hard=${with_hard}
    [Teardown]    Run keywords    Selenium Logout And Close Browser


Step 3 Wait for a cntrldResetMplaneBreakTime duration
    [Arguments]   ${gnb_index}=0
    log to console    Step3: Wait for a cntrldResetMplaneBreakTime duration
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    ${cntrldResetMplaneBreakTime}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...   filter_param=Controlled reset M-plane break time for baseband HW reset
    ...   abbr=cntrldResetMplaneBreakTime
    ${seconds}    Get Regexp Matches    ${cntrldResetMplaneBreakTime}   \\d+
    Sleep   ${seconds[0]}s
    ${connection}  Set Variable If  ${gnb_index}==0   GNB_OAM   GNB_OAM_${gnb_index}
    Wait Until Keyword Succeeds   5min   30s   Connect to gnb coam via ssl   connection=${connection}   gnb_index=${gnb_index}
    Wait Until Keyword Succeeds    20 min    10 sec    Verify all cells should be onair   cell_type=nr
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    [Teardown]    Run keywords    Selenium Logout And Close Browser

Step 4 Wait for a uncntrldResetMplaneBreakTime duration
    [Arguments]
    log to console    Step3: Wait for a cntrldResetMplaneBreakTime duration
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    ${uncntrldResetMplaneBreakTime}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...   filter_param=Uncontrolled reset M-plane break time
    ...   abbr=uncntrldResetMplaneBreakTime
    ${seconds}    Get Regexp Matches    ${uncntrldResetMplaneBreakTime}    \\d+
    Sleep   ${seconds[0]}s
    ${connection}  Set Variable If  ${gnb_index}==0   GNB_OAM   GNB_OAM_${gnb_index}
    Wait Until Keyword Succeeds   5min   30s   Connect to gnb coam via ssl   connection=${connection}   gnb_index=${gnb_index}
    Wait Until Keyword Succeeds    20 min    10 sec    Verify all cells should be onair   cell_type=nr
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    [Teardown]    Run keywords    Selenium Logout And Close Browser

Step ${step_id} Ue attach and start both dl and ul traffic
    [Arguments]
    log to console    Step${step_id}: Ue attach and start both dl and ul traffic
    ${gnb_index}   set variable    ${0}
    #${connection}  Set Variable If  ${gnb_index}==0   GNB_OAM   GNB_OAM_${gnb_index}
    Run Keyword If    ${gnb_index}==0    Set Test Variable    ${connection}    GNB_OAM
    ...    ELSE    Set Test Variable    ${connection}    GNB_OAM_${gnb_index}
    Wait Until Keyword Succeeds   5min   30s   Connect to gnb coam via ssl   connection=${connection}   gnb_index=${gnb_index}
    Start L3Call And Send DL UL Packet    dl_throughput=1000M   ul_throughput=100M   ue_index=0
    ...   buffer_size=1400
    [Teardown]   Stop L3Call And DL UL Traffic   ue_index=0

Stop L3Call And DL UL Traffic
    [Arguments]    ${ue_index}=0
    Log to console    Stop L3Call Traffic ue_index=${ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    #power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    Run Keyword And Ignore Error    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    Run Keyword And Ignore Error    ute_ue.stop_using_ue   UE_${ue_index}

Start L3Call And Send DL UL Packet
    [Arguments]    ${dl_throughput}=1000M    ${ul_throughput}=100M    ${ue_index}=0   ${buffer_size}=1400B
    ...   ${gnb_index}=0
    Log to console    Start L3Call And Send DL UL Packet: ue_index=${ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${path}   ${scf_name}   Split Path   ${Case_SCF_Path}
    ${ui_version}   Get UE UI Version    scf_name=${scf_name}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}      ui_version=${ui_version}
    #power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    ui_version=${ui_version}
    wait until keyword succeeds   1x   1min    UE start dl and ul traffic with retry   ue_type=${ue_type}    ue_index=${ue_index}
    ...    dl_throughput=${dl_throughput}   ul_throughput=${ul_throughput}    buffer_size=${buffer_size}   gnb_index=${gnb_index}

UE start dl and ul traffic with retry
    [Arguments]    ${ue_type}=huawei   ${dl_throughput}=1000M    ${ul_throughput}=100M    ${ue_index}=0
    ...   ${buffer_size}=1400B   ${duration}=900
    ...   ${cell_index}=1   ${gnb_index}=0
    Log to console    UE start traffic with retry: ue_index=${ue_index}
    ${has_pdns}  has_attribute   ${tl.ues[${ue_index}]}   pdns
    Run Keyword If    ${has_pdns}    set test variable   ${pdns}    ${tl.ues[${ue_index}].pdns}
    ...    ELSE    set test variable   ${pdns}    None
    ${apn}   set variable if    '''${pdns}''' != 'None'     ${pdns[0].apnName}    dxdata2
    log to console   set apn to:${apn}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}   gnb_index=${gnb_index}
#    power_ue.Verify attach    ue_type=${ue_type}   ue_index=${ue_index}   5Grach_ed=${5Grach_ed}
#    ...   4G_check=${False}   gnb_index=${gnb_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}
    ...    protocol=udp    duration=${duration}    ue_index=${ue_index}    buffer_size=${buffer_size}
    ...    apn=${apn}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}
    ...    protocol=udp    duration=${duration}    ue_index=${ue_index}    buffer_size=${buffer_size}
    ...    apn=${apn}
    ${cell_list}   Create List   ${${cell_index}}
    ${ue_index_list}   Create List   ${${ue_index}}
    ${ue_and_cell}   Create Dictionary   ${${ue_index}}   ${${cell_index}}
    ${res}     Run Keyword And Return Status    ue.UE Verify Peak Throughput   ue_index_list=${ue_index_list}   ue_and_cell=${ue_and_cell}
    ...   dl_exp=${0}   ul_exp=${1}   interval=10s   duration=${30}
    ...   actual_rate=0.1   du_index=0   gnb_ssl_connection=${connection}
    ...   is_need_to_capture_log=${False}   cell_and_peak_info=None
    ...   target_avg_percent=${0.001}   min_percent=${0.0}
    Run Keyword If    '${res}'=='False'     Stop L3Call And DL UL Traffic  ue_index=${ue_index}

Set RU reset Resiliency and M-plane break time
    [Arguments]   ${actRuResetResiliency}=true   ${uncntrldResetMplaneBreakTime}=${300}   ${cntrldResetMplaneBreakTimeSite}=${300}
    log to console   Set actRuResetResiliency=${actRuResetResiliency} and uncntrldResetMplaneBreakTime=${uncntrldResetMplaneBreakTime}
    ...  and cntrldResetMplaneBreakTimeSite=${cntrldResetMplaneBreakTimeSite}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate RU reset resiliency   abbr=actRuResetResiliency
    ...    new_value=${actRuResetResiliency}    node_index=${0}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Uncontrolled reset M-plane break time   abbr=uncntrldResetMplaneBreakTime
    ...    new_value=${uncntrldResetMplaneBreakTime}    node_index=${0}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Controlled reset M-plane break time for site reset without RU reset
    ...    abbr=cntrldResetMplaneBreakTimeSite
    ...    new_value=${cntrldResetMplaneBreakTimeSite}    node_index=${0}
    ${result}     Run Keyword And Ignore Error    selenium_coam.validate_plan
    ${result}     Run Keyword If   '${result[0]}'=='PASS'   Check Validate Errors

    Run Keyword If   "${result}"=="None"   log to console  no parameter change!
    ...   ELSE IF   "${result[0]}"=="${0}"   selenium_coam.activate_plan
    ...   ELSE IF   ${result[0]}>0  Run Keywords
    ...   selenium_coam.save_screenshot   filename=Screen_relation_errors.png    screenshot_dir=${TS_CASE_LOG_PATH}  AND
    ...   selenium_coam.save_bts_configuration    save_configuration_type=${1}   AND
    ...   selenium_coam.undo_changes
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    Wait Until Keyword Succeeds   5min   30s   Connect to gnb coam via ssl   connection=${connection}
    Wait Until Keyword Succeeds   20 min   10 sec   Verify all cells should be onair   cell_type=nr   connection=${connection}
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    [Teardown]    Run keywords    Selenium Logout And Close Browser
