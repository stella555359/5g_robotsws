*** Settings ***
Documentation    This is for CB007326-A keywords
...              Author: Gao melinda
...              Contact: melinda.gao@nokia-sbell.com
...              squad: 5G_PZ_HZ_8_SG

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BW_common_case/lib/BW_step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/gnb_sync.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Variables   ../TestData/variables_7326.py
Library    ../lib/CB007326.py
*** Variables ***

*** Keywords ***
CB007326-A Activate feature 5GC000431
    [Documentation]    Author: Gao melinda
    Selenium Login And Disable Screen Lock
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate NR load-based power saving    p_name=actNrLBPowerSaving    value=true
    append to list  ${modify_params}  ${item}
    Modify Parameters On Webem    modify_params=${modify_params}    despite_errors=${True}
    verify all cells should be onair
    Close Start Up View    timeout=60
    Selenium Logout And Close Browser

CB007326-A Deativate feature 5GC000431
    [Documentation]    Author: Gao melinda
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate NR load-based power saving    p_name=actNrLBPowerSaving    value=false
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-1
    ...    filter_param=Load-based power saving duration    p_name=lbpsDuration    value=1
    append to list  ${modify_params}  ${item}
    Modify Parameters On Webem    modify_params=${modify_params}    despite_errors=${True}
    verify all cells should be onair

Power_saving_conditions_met_before_and_during_start_power_saving_time_period
    [Documentation]    Author: Gao melinda
    [Arguments]    ${cell_energy_check}=2    ${cellgroup_energy_check}=1    ${cell_call}=1
#    CB007326-A Activate feature 5GC000431
    Wait until keyword succeeds    5min    10s    Cell should Be not EnergySaving
    ...    cell_idx=${cell_energy_check}    cell_group_idx=${cellgroup_energy_check}
    ${curr_date}   DateTime.Get Current Date
    ${datetime}   DateTime.Convert Date   ${curr_date}   datetime
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-1
    ...    filter_param=Load-based power saving start time hour   p_name=lbpsStartTimeHour    value=${datetime.hour}
    append to list  ${modify_lbps_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-1
    ...    filter_param=Load-based power saving start time minute    p_name=lbpsStartTimeMinute    value=${datetime.minute}
    append to list  ${modify_lbps_params}  ${item}
    set suite variable    ${dist_name}    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-1
    modify_parameter_scf_dist_name    scf_parameter=${modify_lbps_params}    new_value=${dist_name}
    log to console    ${modify_lbps_params}
    Selenium Login And Disable Screen Lock
    Modify the lbps_Parameters On Webem    modify_params=${modify_lbps_params}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${true}    execute=${true}
    log to console    \n************ begin to check cell should be energysaving ***************
    Wait until keyword succeeds    10min    30s    Cell should Be EnergySaving
    ...    cell_idx=${cell_energy_check}    cell_group_idx=${cellgroup_energy_check}
    log to console    \n************ recovery Cell state by check L3 Call ***************
    ${tput_info1}    get_tput_info_by_tool    cell_id=1
    Recovery Cell State by Check L3 Call    cell_id=${cell_call}    dl_tp=${tput_info1['dl_tp']}
    ...    ul_tp=${tput_info1['ul_tp']}    dl_exp_tp=${tput_info1['dl_exp']}    ul_exp_tp=${tput_info1['ul_exp']}
    log to console    \n************ call finished ***************
    log to console    \n************ begin to check cell should be not energysaving ***************
    Wait until keyword succeeds    10min    30s    Cell should Be not EnergySaving
    ...    cell_idx=${cell_energy_check}    cell_group_idx=${cellgroup_energy_check}
#    [Teardown]    run keywords    CB007326-A Deativate feature 5GC000431    AND    Selenium Logout And Close Browser    AND
#    ...    run keyword and ignore error    Stop UE L3 Call
    [Teardown]    run keywords    Selenium Logout And Close Browser    AND
    ...    run keyword and ignore error    Stop UE L3 Call

CB007326-5G-A-SyVe_5GC000431 PM_counter
    [Documentation]    Author: Gao melinda
    [Arguments]    ${counter_id}    ${change_interval}=15min    ${cell_energy_check}=2    ${cellgroup_energy_check}=1
    ...            ${cell_call}=1
#    CB007326-A Activate feature 5GC000431
#    sleep    10s
    ${curr_date}   DateTime.Get Current Date
    ${datetime}   DateTime.Convert Date   ${curr_date}   datetime
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-1
    ...    filter_param=Load-based power saving start time hour    p_name=lbpsStartTimeHour    value=${datetime.hour}
    append to list  ${modify_lbps_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-1
    ...    filter_param=Load-based power saving start time minute    p_name=lbpsStartTimeMinute    value=${datetime.minute}
    append to list  ${modify_lbps_params}  ${item}
    set suite variable    ${dist_name}    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-1
    modify_parameter_scf_dist_name    scf_parameter=${modify_lbps_params}    new_value=${dist_name}
    log to console    ${modify_lbps_params}
    Selenium Login And Disable Screen Lock
    Modify the lbps_Parameters On Webem    modify_params=${modify_lbps_params}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${true}    execute=${true}
    log to console    *****start to sleep 8 min*****
    sleep     8m
    log to console    *****end to sleep 8 min*****
    connect to common unit master
    ${counter_value}    Get PM Counter via Webem    counter_id=${counter_id}    interval=${change_interval}
    ${counter_value}    convert to integer    ${counter_value}
    should Be True    ${counter_value} != '0'
#    [Teardown]    run keywords    CB007326-A Deativate feature 5GC000431    AND    Selenium Logout And Close Browser
    [Teardown]    Selenium Logout And Close Browser

Modify the lbps_Parameters On Webem
    [Documentation]    Author: Gao melinda
    [Arguments]  ${modify_params}  ${is_activate}=${True}  ${despite_errors}=${False}    ${bts_configuration}=Current
    FOR  ${item}  IN  @{modify_params}
        selenium_coam.set_parameter_value    dist_name=${item}[dist_name]    bts_configuration=${bts_configuration}
        ...    filter_param=${item}[filter_param]    abbr=${item}[p_name]    new_value=${item}[value]
    END

Setup Preconditions Phase
    [Documentation]    Author: lin jiangjing
    [Arguments]  ${phase}    ${cancel}=false    ${connection}=GNB_OAM
    ${Phase1Act}=    set variable if  '${phase}'=='1'    true
    ...                               '${phase}'=='all'  true     false
    ${Phase2Act}=    set variable if  '${phase}'=='2'    true
    ...                               '${phase}'=='all'  true     false
    ${Phase3Act}=    set variable if  '${phase}'=='3'    true
    ...                               '${phase}'=='all'  true     false
    ${Ph1Timer}=     set variable if  '${cancel}'=='Cancel' and '${phase}'=='1'   900     130
    ${Ph2Timer}=     set variable if  '${cancel}'=='Cancel' and '${phase}'=='2'   900     130
    ${Ph3Timer}=     set variable if  '${cancel}'=='Cancel' and '${phase}'=='3'   420     130
    Configure fault snapshot trigger    10.42.54.166
    ${parameters}  create list
    ${item}  create dictionary  parameterName=autRachBasedSlCellDetHCheckFreq
         ...    operation=update
         ...    value=120
    append to list    ${parameters}    ${item}
    ${item}  create dictionary  parameterName=autRachBasedSlCellRecPh1Timer
         ...    operation=update
         ...    value=${Ph1Timer}
    append to list    ${parameters}    ${item}
    ${item}  create dictionary  parameterName=autRachBasedSlCellRecPh2Timer
         ...    operation=update
         ...    value=${Ph2Timer}
    append to list    ${parameters}    ${item}
    ${item}  create dictionary  parameterName=autRachBasedSlCellRecPh3Timer
         ...    operation=update
         ...    value=${Ph3Timer}
    append to list    ${parameters}    ${item}
    ${item}  create dictionary  parameterName=autRachBasedSlCellRachAtmpThr
         ...    operation=update
         ...    value=1000
    append to list    ${parameters}    ${item}
    ${item}  create dictionary  parameterName=autRachBasedSlCellRachMsg3Thr
         ...    operation=update
         ...    value=0
    append to list    ${parameters}    ${item}
    ${item}  create dictionary  parameterName=autRachBasedSlCellRecPhase1Act
         ...    operation=update
         ...    value=${Phase1Act}
    append to list    ${parameters}    ${item}
    ${item}  create dictionary  parameterName=autRachBasedSlCellRecPhase2Act
         ...    operation=update
         ...    value=${Phase2Act}
    append to list    ${parameters}    ${item}
    ${item}  create dictionary  parameterName=autRachBasedSlCellRecPhase3Act
         ...    operation=update
         ...    value=${Phase3Act}
    append to list    ${parameters}    ${item}
    ${item}  create dictionary  parameterName=maxNumSlCellRecActForBbuPerDay
         ...    operation=update
         ...    value=3
    append to list    ${parameters}    ${item}
    ${item}  create dictionary  parameterName=maxNumSlCellRecActForBtsPerDay
         ...    operation=update
         ...    value=3
    append to list    ${parameters}    ${item}
    coam.perform_object_recommissioning        dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                        parameter=${parameters}
    ...                                        operation=update
    ...                                        skip_parameter_relation_errors=${True}
    ...                                        connection=${connection}
    coam.perform_parameter_recommissioning        dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                                            parameter=actAutRachBasedSlCellDetRec
    ...                                            value=true
    ...                                            operation=update
    ...                                            skip_parameter_relation_errors=${True}
    ...                                            connection=${connection}

Configure fault snapshot trigger
    [Documentation]    Author: lin jiangjing
    [Arguments]    ${lssIPaddress}=2.2.2.2    ${lssPortNo}=22    ${connection}=GNB_OAM
    coam.perform_parameter_recommissioning
        ...    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/TRBLCADM-1
        ...    parameter=diagSnapDestination
        ...    operation=update
        ...    value=lss
        ...    skip_parameter_relation_errors=${True}
        ...    connection=${connection}
    ${list_param_to_change}=    Create Dictionary
        ...     lssIPaddress=${lssIPaddress}
        ...     lssPortNo=${lssPortNo}
    @{list}=    create list    ${list_param_to_change}
    coam.perform_parameter_recommissioning
        ...    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/TRBLCADM-1
        ...    parameter=lssConfig
        ...    operation=update
        ...    value=@{list}
        ...    skip_parameter_relation_errors=${True}
        ...    connection=${connection}
    ${fault_4547}=    Create Dictionary
    ...     faultNumber=4547
    ...     triggerType=onFaultDetection
     @{list}=    create list    ${fault_4547}
    coam.perform_parameter_recommissioning        dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                            parameter=faultSnapshotTriggers
    ...                                            operation=update
    ...                                            value=@{list}
    ...                                            skip_parameter_relation_errors=${True}
    ...                                            connection=${connection}

Trigger Sleeping Cell
    [Arguments]    ${connection}=GNB_OAM
    coam.perform_parameter_recommissioning        dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                            parameter=autRachBasedSlCellRachAtmpThr
    ...                                            value=0
    ...                                            operation=update
    ...                                            skip_parameter_relation_errors=${True}
    ...                                            connection=${connection}

Check for sleeping cell alarm
    Wait until keyword succeeds    20min    5s    Expect Fault Should Present    faultId=4547
    log to console    fault 4547 appeared

Check counter increment
    [Documentation]    Author: lin jiangjing
    [Arguments]     ${counter_id}    ${connection}=GNB_OAM
    ${pm_counters}=    coam.get pm counters    ${counter_id}    connection=${connection}
    ${string_values}=   Convert To String   ${pm_counters}
    ${single_pm_counter}=    Get Regexp Matches    ${string_values}    \\d{10}.{3}\\d+
    ${single_pm_counter_string}=   Convert To String   ${single_pm_counter}
    ${single_pm_counters}=    Get Regexp Matches    ${single_pm_counter_string}    \\b\\d\\b
    ${pm_counters_length}=    get length    ${single_pm_counters}
    ${counter}=     set variable     0
    Should Match Regexp    ${single_pm_counters[0]}    \\d+     #this chekcs data
    FOR    ${INDEX}    IN RANGE    ${pm_counters_length}
         ${counter}=    evaluate   ${counter}+${single_pm_counters[${INDEX}]}
    END
    should be true    ${counter} > 0

Check snapshot collection on lss
    [Documentation]    Author: lin jiangjing
    sleep    1m
    ssh.connect to     10.42.54.166     ute    4Security!:)    alias=lssv4
    ${snapshot_list}=    ssh.execute     ls -l /home/coam | grep Snapshot_MRBTS-${mrbtsID}*    connection=lssv4
    should not be empty    ${snapshot_list}

Delete snapshot from lss
    [Documentation]    Author: lin jiangjing
    ssh.connect to     10.42.54.166     ute    4Security!:)    alias=lssv4
    ssh.execute     rm -rf /home/coam/Snapshot_MRBTS-${mrbtsID}*     connection=lssv4

Turn off sleeping cell feature
    [Documentation]    Author: lin jiangjing
    [Arguments]    ${connection}=GNB_OAM
    coam.perform_parameter_recommissioning        dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                                            parameter=actAutRachBasedSlCellDetRec
    ...                                            value=false
    ...                                            operation=update
    ...                                            skip_parameter_relation_errors=${True}
    ...                                            connection=${connection}

Wait for health check to pass
    sleep    240s

Cancel Sleeping Cell
    [Documentation]    Author: lin jiangjing
    [Arguments]    ${connection}=GNB_OAM
    coam.perform_parameter_recommissioning        dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                            parameter=autRachBasedSlCellRachAtmpThr
    ...                                            value=1000
    ...                                            operation=update
    ...                                            skip_parameter_relation_errors=${True}
    ...                                            connection=${connection}

Check if alarm did not appear
    [Documentation]    Author: lin jiangjing
    ${status}=    run keyword and return status   Wait until keyword succeeds    15min    5s
    ...    Expect Fault Should Present    faultId=4547
    should not be true  ${status}

Check if BTS reset
    [Documentation]    Author: lin jiangjing
    Wait Until Keyword Succeeds  15min  5s  Check if server is not pingable
    Wait Until Keyword Succeeds  15min  5s  Check if server is pingable

Check if server is not pingable
    [Documentation]    Author: lin jiangjing
    [Arguments]    ${gnb_index}=0    ${IP}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ${output}   Run       sudo ping -c 1 -W 10 ${IP}
    Should contain      ${output}   1 packets transmitted, 0 received

Check if server is pingable
    [Documentation]    Author: lin jiangjing
    [Arguments]    ${gnb_index}=0    ${IP}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ${output}   Run       sudo ping -c 1 -W 10 ${IP}
    Should contain      ${output}   1 packets transmitted, 1 received

Check if BTS did not reset
    [Documentation]    Author: lin jiangjing
    ${status}=    run keyword and return status   wait until keyword succeeds    8min  5s  Check if server is not pingable
    should not be true  ${status}

#update_parameter_related_time_via_WEBUI
#    [Documentation]    Author: melinda.gao@nokia-sbell.com
#    ...                Description: Set parameter lbpsDayOfWeek, lbpsStartTimeHour, lbpsStartTimeMinute for changing
#    ...                validation and activation
#    [Arguments]    ${modify_scf_parameters}    ${gnb_type}='NSA'
#    log to console    \n****** modify scf lbps parameters ******
#    set suite variable    ${dist_name}    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-1
#    modify_parameter_scf_dist_name    ${modify_scf_parameters}    ${dist_name}
#    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_scf_parameters}    timeout=15min
#    COAM Wait for gnb ready and cell setup    timeout=15min    gnb_type=${gnb_type}

Get Cell Status Info
    [Documentation]   Author: Gao melinda
    [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=10   ${connection}=GNB_OAM
    ${cell_idx}   Convert To Integer   ${cell_idx}
    ${cell_group_idx}  Convert To Integer    ${cell_group_idx}
    ${subcells_status}    coam.get_subcells_status   timeout=${timeout}    connection=${connection}
    ${result}    get release flag    connection=${connection}
    ${status_dict}   Catenate   'operationalState':
    ...                         '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["operationalState"]}',
    ...                         'availabilityStatus':
    ...                         '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["availabilityStatus"]}',
    ...                         'administrativeState':
    ...                         '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["administrativeState"]}',
    ...                         'proceduralStatus':
    ...                         '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["proceduralStatus"]}',
    ...                         'energySavingState':
    ${energySavingState_path}    run keyword if    ${result}
    ...    set variable    '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_L"]["energySavingState"]}'    ELSE
    ...    set variable    '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_L"]["stateInfo"]["energySavingState"]}'
    ${status_dict}    Catenate    ${status_dict}    ${energySavingState_path}
    ${subcell_status}    Evaluate   {${status_dict}}
    [Return]   ${subcell_status}

Cell should Be not EnergySaving
    [Documentation]    Author: Gao melinda
    [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=10   ${connection}=GNB_OAM
    ${subcell_status}=  Get Cell Status Info     cell_idx=${cell_idx}
    ...    cell_group_idx=${cell_group_idx}    timeout=${timeout}    connection=${connection}
    log to console    ${subcell_status}
    ${result}    get release flag    connection=${connection}
    ${operationalState}       set variable if      ${result}    Enabled    enabled
    Should Be Equal As Strings    ${subcell_status["operationalState"]}   ${operationalState}
    Should Be Equal As Strings    ${subcell_status["administrativeState"]}  Unlocked
    Should Be Equal As Strings    ${subcell_status["proceduralStatus"]}   configured
    Should Be Equal As Strings    ${subcell_status["energySavingState"]}   notEnergySaving
    run keyword if    ${result}    Should Be Equal As Strings    ${subcell_status["availabilityStatus"]}  Online

Cell should Be EnergySaving
    [Documentation]    Author: Gao melinda
    [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=10   ${connection}=GNB_OAM
    ${subcell_status}=  Get Cell Status Info     cell_idx=${cell_idx}
    ...                                      cell_group_idx=${cell_group_idx}
    ...                                      timeout=${timeout}
    ...                                      connection=${connection}
    ${result}    get release flag    connection=${connection}
    ${operationalState}    set variable if    ${result}    Disabled    disabled
    ${availabilityStatus}    set variable if    ${result}    Offline    off line
    Should Be Equal As Strings  ${subcell_status["operationalState"]}   ${operationalState}
    Should Be Equal As Strings  ${subcell_status["availabilityStatus"]}  ${availabilityStatus}
    Should Be Equal As Strings  ${subcell_status["administrativeState"]}  Unlocked
    Should Be Equal As Strings   ${subcell_status["proceduralStatus"]}   configured
    Should Be Equal As Strings   ${subcell_status["energySavingState"]}   energySaving

Recovery Cell State by Check L3 Call
    [Documentation]
    ...    ******************
    ...    TEST PURPOSE: Recovery Cell state by L3 Call
    ...    Owner: Gao Melinda
    ...    ******************
    [Arguments]    ${cell_id}=1   ${protocal}=udp    ${iperf_type}=via_command    ${gnb_type}=NSA   ${dl_tp}=300M    ${ul_tp}=50M
    ...    ${dl_exp_tp}=260    ${ul_exp_tp}=14     ${duration}=600    ${target_avg_percent}=0.15    ${min_percent}=0.05
    ${ue_type}    translate power ue type from testline  ue_index=${0}
    power_ue.Prepare UE    ue_type=${ue_type}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}
    log to console    \n******** start traffic ********
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}    protocol=${protocal}    duration=${duration}
    ...    iperf_type=${iperf_type}
    log to console    \n******* check throughput ********
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=60
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=GNB_OAM
    ${cell_id}    set variable    ${cell_mapping[${cell_id}]['nrCellIdentity']}
    ${cell_id}    Convert To String    ${cell_id}
    ${cell_id}    Create List    ${cell_id}
    power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${tput_log}    cells=${cell_id}
    ...   target_throughput=${dl_exp_tp}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    [Teardown]    run keyword and ignore error    csn.disconnect    connection=ASIK Master

CB007326-5G-A-SyVe_ 5GC002083 Phase1_Detection
    [Documentation]    Author: lin jiangjing
    Setup Preconditions Phase    phase=1
    Trigger Sleeping Cell
    Check for sleeping cell alarm
#    log to console    begin to wait counter M55601C00006
#    sleep     16min
#    Wait until keyword succeeds    30min    1min    Check counter increment    counter_id=M55601C00006
#    Check snapshot collection on lss
#    Delete snapshot from lss
    [Teardown]   Turn off sleeping cell feature

CB007326-5G-A-SyVe_ 5GC002083 Phase1_Cancel
   [Documentation]    Author: lin jiangjing
    Setup Preconditions Phase    phase=1    cancel=Cancel
    Trigger Sleeping Cell
    Wait for health check to pass
    Cancel Sleeping Cell
    Check if alarm did not appear
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    [Teardown]   Turn off sleeping cell feature

CB007326-5G-A-SyVe_ 5GC002083 Phase3_Detection
    [Documentation]    Author: lin jiangjing
    Setup Preconditions Phase    phase=3
    Trigger Sleeping Cell
    Check for sleeping cell alarm
    Check if BTS reset
    log to console    bts reseted
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
#    Turn off sleeping cell feature
#    log to console    begin to wait counter M55601C00008
#    sleep     16min
#    Wait until keyword succeeds    30min    1min    Check counter increment    counter_id=M55601C00008
#    Check snapshot collection on lss
#    Delete snapshot from lss
    [Teardown]   run keyword and ignore error    Turn off sleeping cell feature

CB007326-5G-A-SyVe_ 5GC002083 Phase3_Cancel
    [Documentation]    Author: lin jiangjing
    Setup Preconditions Phase    phase=3    cancel=Cancel
    Trigger Sleeping Cell
    Wait for health check to pass
    Cancel Sleeping Cell
    Check if BTS did not reset
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    [Teardown]   Turn off sleeping cell feature
