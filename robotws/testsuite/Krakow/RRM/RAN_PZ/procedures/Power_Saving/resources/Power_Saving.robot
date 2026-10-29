*** Settings ***
Library       ute_ue
Library       ./Power_Saving.py
Library       Power_Saving.GnbPowerSaving    WITH NAME      gnbps
Resource      taf/rfrl/bts/robot/gnb.robot

*** Variables ***
${dist_name}=       MRBTS-{}/NRBTS-{}

*** Keywords ***
Preconditions
    Start Collecting gNB Syslog

Postconditions
    Stop Collecting gNB Syslog
    Collect Snapshot From gNB

Activate feature 5GC000431
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name}
    ...   param_name=actNrLBPowerSaving    operation=update    param_value=${true}
    ...   skip_parameter_relation_errors=${true}
    Verify gNB is onAir

Deactivate feature 5GC000431
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name}
    ...   param_name=actNrLBPowerSaving    operation=update    param_value=${false}
    ...   skip_parameter_relation_errors=${true}
    Verify gNB is onAir

Wait until cell will be in state energy saving
    [Arguments]    ${cell_id}
    wait until keyword succeeds   600    5     Verify Cell Statuses    cell_id=${cell_id}    availability_status=Offline
    ...    operational_state=Disabled    procedural_status=configured     administrative_state=Unlocked
    Verify cell energy saving state     cell_id=${cell_id}    energy_saving_state=energySaving

Wait until cell will be in state not energy saving
    [Arguments]    ${cell_id}
    wait until keyword succeeds   60    5    Verify cell energy saving state     cell_id=${cell_id}
    ...     energy_saving_state=notEnergySaving

Wait until cell will be in state switchingOff
    [Arguments]    ${cell_id}
    wait until keyword succeeds   600    5    Verify cell energy saving state     cell_id=${cell_id}
    ...       energy_saving_state=switchingOff

Turn on lbps for specific time via GUI
    [Arguments]    ${how_many_mins_lbps_should_work}     ${delay}     ${node_index}    ${power_group_id}=1
    [Documentation]    turn on lbps for specific time via GUI
    ...     :param how_many_mins_lbps_should_work:   time in minutes how long lbps should work
    ...     :param delay:   how many mins lbps start should be delayed
    ...     :param node_index:     node index
    gnbps.turn_on_lbps_for_specific_time_selenium   how_many_mins_lbps_should_work=${how_many_mins_lbps_should_work}
    ...     delay=${delay}    node_index=${node_index}      power_group_id=${power_group_id}

Add new power group
    [Arguments]    ${power_group_id}   ${cell_id}    ${cell_switch_off_order}=100
    [Documentation]    Add new power group
    ...     :param power_group_id:    power group id
    ...     :param cell_id:     cell id
    ...     :param cell_switch_off_order:     cell_switch_off_order
    gnbps.add_new_power_group   power_group_id=${power_group_id}    cell_id=${cell_id}
    ...    cell_switch_off_order=${cell_switch_off_order}

Remove power group
    [Arguments]    ${power_group_id}
    [Documentation]    Remove power group
    ...     :param power_group_id:    power group id
    gnbps.remove_power_group   power_group_id=${power_group_id}

Add new power saving period
    [Arguments]    ${power_group_id}   ${node_index}     ${how_many_mins_lbps_should_work}     ${delay}
    [Documentation]  Add new power saving period
    ...     :param power_group_id:    power group id
    ...     :param how_many_mins_lbps_should_work:   time in minutes how long lbps should work
    ...     :param delay:   how many mins lbps start should be delayed
    ...     :param node_index:     node index
    gnbps.add_new_power_saving_period_list   power_group_id=${power_group_id}     node_index=${node_index}
    ...                                      how_many_mins_lbps_should_work=${how_many_mins_lbps_should_work}
    ...                                      delay=${delay}

Remove power saving period
    [Arguments]    ${power_group_id}   ${node_index}
    [Documentation]  Remove power saving period
    ...     :param power_group_id:    power group id
    ...     :param node_index:     node index
    gnbps.remove_power_saving_period_list   power_group_id=${power_group_id}     node_index=${node_index}

Check if cell will not be added to two power groups via GUI
    [Documentation]   Check if cell will not be added to two power groups via GUI
    ...   :param cell_id                            cell id value
    ...   :param power_group_id                     power group id value
    ...   :param cell_switch_off_order              cell switch off order
    ...   :param node_index                         node index value
    ...   :param gnb_id:                            gNB id - related to Test Line Configuration.
    ...   :param du_id:     DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    [Arguments]  ${power_group_id}    ${cell_id}    ${cell_switch_off_order}    ${node_index}
    ...     ${gnb_id}=0      ${du_id}=0
    gnbps.check_if_cell_will_not_be_added_to_two_power_groups     power_group_id=${power_group_id}   cell_id=${cell_id}
    ...   cell_switch_off_order=${cell_switch_off_order}   node_index=${node_index}   bts_id=${gnb_id}    du_id=${du_id}

Remove cell from power group
    [Arguments]    ${power_group_id}    ${node_index}
    [Documentation]    Remove cell from power group
    ...   :param power_group_id                     power group id value
    ...   :param node_index                         node index value
    gnbps.remove_cell_from_power_group   power_group_id=${power_group_id}     node_index=${node_index}

Check if last cell will not be removed from power group
    [Arguments]    ${power_group_id}    ${node_index}
    [Documentation]    Check if last cell will not be removed from power group
    ...    :param gnb_id:    GNB id - related to Test Line configuration.
    gnbps.check_if_last_cell_will_not_be_removed_from_power_group    power_group_id=${power_group_id}
    ...    node_index=${node_index}

Get power saving period time start
    [Arguments]    ${power_group_id}    ${node_index}
    [Documentation]    Get power saving period time start
    ...   :param power_group_id                     power group id value
    ...   :param node_index                         node index value
    ${hour}   ${minute}   gnbps.get_power_saving_period_time_start   power_group_id=${power_group_id}
    ...   node_index=${node_index}
    [return]   ${hour}    ${minute}

Get power saving period time end
    [Arguments]    ${power_group_id}    ${node_index}
    [Documentation]    Get power saving period time end
    ...   :param power_group_id                     power group id value
    ...   :param node_index                         node index value
    ${hour}   ${minute}   gnbps.get_power_saving_period_time_end   power_group_id=${power_group_id}
    ...   node_index=${node_index}
    [return]   ${hour}    ${minute}

Verify lbps time has started
    [Arguments]    ${hour}    ${minute}
    ${current_hour}  ${current_minute}       gnbps.get_formatted_date_from_bts
    Should be equal    ${hour}      ${current_hour}
    Should be equal    ${minute}    ${current_minute}

Prepare UE
    [Arguments]     ${UE_alias}     ${capabilities}    ${timeout}
    ute_ue.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    ute_ue.Reboot UE    ${UE_alias}    timeout=${timeout}

Attach ue and run throughput
    [Arguments]     ${UE_alias}   ${capabilities}    ${dt_name}  ${direction}  ${throughput}  ${duration}
    ...   ${protocol}    ${packet_size}     ${tput}    ${deviation}    ${buffer_client}     ${buffer_server}
    ute_ue.Detach UE     ue_alias=${UE_alias}
    Sleep     10
    ute_ue.Attach UE     ue_alias=${UE_alias}
    Sleep     10
    ute_ue.start_data_transfer     dt_name=${dt_name}    ue_alias=${UE_alias}    direction=${direction}
    ...    throughput=${throughput}    duration=${duration}    protocol=${protocol}    packet_size=${packet_size}
    ...    buffer_client=${buffer_client}       buffer_server=${buffer_server}
    ute_ue.Check Data Transfer Is Alive    dt_name=${dt_name}
    ute_ue.Await Data Transfer Finish     dt_name=${dt_name}
    ute_ue. Verify Average Throughput With Deviation     dt_name=${dt_name}    tput=${tput}    deviation=${deviation}

Run throughput
    [Arguments]     ${UE_alias}   ${capabilities}    ${dt_name}   ${throughput}    ${direction}    ${duration}
    ...   ${protocol}    ${packet_size}   ${tput}   ${deviation}      ${buffer_client}     ${buffer_server}
    ute_ue.start_data_transfer     dt_name=${dt_name}    ue_alias=${UE_alias}    direction=${direction}
    ...    throughput=${throughput}   duration=${duration}    protocol=${protocol}    packet_size=${packet_size}
    ...    buffer_client=${buffer_client}       buffer_server=${buffer_server}
    ute_ue.Check Data Transfer Is Alive    dt_name=${dt_name}
    ute_ue.Await Data Transfer Finish     dt_name=${dt_name}
    ute_ue.Verify Average Throughput With Deviation     dt_name=${dt_name}    tput=${tput}    deviation=${deviation}
