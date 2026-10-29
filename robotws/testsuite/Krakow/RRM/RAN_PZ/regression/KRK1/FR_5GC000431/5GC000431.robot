*** Settings ***

Library         ute_ue
Library         DateTime
Library         ../../../procedures/Power_Saving/resources/Power_Saving.py
Resource        ../../../procedures/Power_Saving/resources/Power_Saving.robot
Resource        taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource        taf/rfrl/common_resources/common_step/interface.robot

Force Tags     STATE_SW_UPLOADED    CRT    PY36

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
Suite Teardown    Common Suite Teardown

*** Variables ***
${dist_name_power_group}=       MRBTS-{}/NRBTS-{}/NRPGRP-0
${dist_name_power_group_2}=     MRBTS-{}/NRBTS-{}/NRPGRP-1
${capabilities}    REAL_UE
${throughput}=   400Mbits/sec
${dt_name}=   dt1
${UE_alias}=  UE
${direction}=  dl
${duration}=  600s
${protocol}=  udp
${packet_size}=  1400
${tput}=   400Mbits/sec
${deviation}=  30%
${buffer_server}=   4M
${buffer_client}=   4M
${parameter_suspended}=  Load-Based Power Saving Suspended
${parameter_max_load}=   Load-based power saving maximum load
${parameter_start_minute}=  Load-based power saving start time minute

*** Test Cases ***
[1]5GC000431_A_4_Feature_5GC000431_Configure_Load-Based_Power_Saving_Controls
    Activate feature 5GC000431
    Add new power group     power_group_id=1    cell_id=2
    Add new cell to power group       power_group_id=1    cell_id=3    cell_switch_off_order=60     node_index=1
    Turn on lbps for specific time via GUI      how_many_mins_lbps_should_work=60     delay=10    node_index=0
    ...    power_group_id=0
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name_power_group_2}
    ...   param_name=lbpsMaxLoad    operation=update    param_value=${70}
    ...   skip_parameter_relation_errors=${true}
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name_power_group_2}
    ...   param_name=lbpsMinLoad    operation=update    param_value=${30}
    ...   skip_parameter_relation_errors=${true}
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name_power_group_2}
    ...   param_name=lbpsLastCellMinLoad    operation=update    param_value=${20}
    ...   skip_parameter_relation_errors=${true}
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name_power_group_2}
    ...   param_name=lbpsLastCellSOEnabled    operation=update    param_value=${false}
    ...   skip_parameter_relation_errors=${true}
    Verify if Parameter Changed to Incorrect Value via GUI     dist_name=${dist_name_power_group_2}
    ...     parameter=${parameter_max_load}     value=110    node_index=0
    Verify if Parameter Changed to Incorrect Value via GUI     dist_name=${dist_name_power_group_2}
    ...     parameter=${parameter_start_minute}     value=70    node_index=0
    Check if cell will not be added to two power groups via GUI     power_group_id=1    cell_id=1
    ...     cell_switch_off_order=60     node_index=1
    Check if last cell will not be removed from power group      power_group_id=0    node_index=0
    [Teardown]      Run Keywords
    ...             Remove power group     power_group_id=1
    ...             AND
    ...             interface.Common step trigger

[1]5GC000431_A_7_Determine_Cell_Power_Saving_Mode
    [Tags]
    ...     RAN_5G__WITH__SBTS00__WITH__CLOUD_5G_CLASSICAL_ASKEY_ASIBL_ABILB1_AWEUA
    ...     RAN_5G__WITH__SBTS22R3__WITH__CLOUD_5G_CLASSICAL_ASKEY_ASIBL_ABILB1_AWEUA
    Activate feature 5GC000431
    Add new cell to power group       power_group_id=0    cell_id=3    cell_switch_off_order=40     node_index=1
    Add new cell to power group       power_group_id=0    cell_id=4    cell_switch_off_order=20     node_index=2
    Turn on lbps for specific time via GUI     how_many_mins_lbps_should_work=120     delay=0    node_index=0
    Prepare UE        ${UE_alias}     capabilities=${capabilities}    timeout=60
    Wait until cell will be in state energy saving       cell_id=4
    Wait until cell will be in state energy saving          cell_id=3
    Attach UE and run throughput  ${UE_alias}   capabilities=${capabilities}  dt_name=${dt_name}
    ...  direction=${direction}   throughput=1200Mbits/sec    duration=400s    protocol=${protocol}
    ...  packet_size=${packet_size}      deviation=${deviation}    tput=1200Mbits/sec     buffer_client=${buffer_client}
    ...    buffer_server=${buffer_server}
    Wait until cell will be in state not energy saving     cell_id=3
    Attach UE and run throughput   ${UE_alias}   capabilities=${capabilities}  dt_name=${dt_name}
    ...  direction=${direction}    throughput=1600Mbits/sec    duration=400s    protocol=${protocol}
    ...  packet_size=${packet_size}   tput=1600Mbits/sec    deviation=${deviation}     buffer_client=${buffer_client}
    ...    buffer_server=${buffer_server}
    Wait until cell will be in state not energy saving     cell_id=4
    [Teardown]    Run Keywords
    ...             Deactivate feature 5GC000431
    ...             AND
    ...             Remove cell from power group       power_group_id=0    node_index=2
    ...             AND
    ...             Remove cell from power group       power_group_id=0    node_index=1
    ...             AND
    ...             interface.Common step trigger

[1]5GC000431_A_3_Feature_5GC000431_Deactivation_with_cell_in_energySaving_state
    [Tags]
    ...     RAN_5G__WITH__SBTS22R3__WITH__CLOUD_5G_CLASSICAL_ASKEY_ASIBL_ABILB1_AWEUA
    Activate feature 5GC000431
    Turn on lbps for specific time via GUI     how_many_mins_lbps_should_work=60     delay=0       node_index=0
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name_power_group}
    ...   param_name=lbpsLastCellSOEnabled    operation=update    param_value=${true}
    ...   skip_parameter_relation_errors=${true}
    Wait until cell will be in state switchingOff        cell_id=1
    Wait until cell will be in state energy saving      cell_id=1
    Deactivate feature 5GC000431
    Wait until cell will be in state not energy saving     cell_id=1
    Verify gNB is onAir
    Prepare UE        ${UE_alias}     capabilities=${capabilities}    timeout=60
    Attach UE and run throughput    ${UE_alias}   capabilities=${capabilities}  dt_name=${dt_name}
    ...  direction=${direction}    throughput=${throughput}    duration=${duration}    protocol=${protocol}
    ...  packet_size=${packet_size}   tput=${tput}    deviation=${deviation}    buffer_client=${buffer_client}
    ...    buffer_server=${buffer_server}
    [Teardown]  Run Keywords
    ...         Perform Configuration Parameter Recommissioning On gNB
    ...             dist_name=${dist_name_power_group}
    ...             param_name=lbpsLastCellSOEnabled
    ...             operation=update
    ...             param_value=${false}
    ...             skip_parameter_relation_errors=${true}
    ...         AND
    ...         interface.Common step trigger

[1]5GC000431_A_8_Power_saving_condition(load)_met_outside_power_saving_time_period
    Activate feature 5GC000431
    Add new cell to power group       power_group_id=0    cell_id=4    cell_switch_off_order=40     node_index=1
    Turn on lbps for specific time via GUI      how_many_mins_lbps_should_work=30     delay=59    node_index=0
    Prepare UE        ${UE_alias}     capabilities=${capabilities}    timeout=60
    Attach UE and run throughput  ${UE_alias}   capabilities=${capabilities}  dt_name=${dt_name}
    ...  direction=${direction}    throughput=400Mbits/sec    duration=300s    protocol=${protocol}
    ...  packet_size=${packet_size}   tput=400Mbits/sec     deviation=${deviation}    buffer_client=${buffer_client}
    ...    buffer_server=${buffer_server}
    Wait until cell will be in state not energy saving     cell_id=4
    [Teardown]      Run Keywords
    ...                 Deactivate feature 5GC000431
    ...                 AND
    ...                 Remove cell from power group       power_group_id=0    node_index=1
    ...                 AND
    ...                 interface.Common step trigger

[1]5GC000431_A_9_Power_saving_conditions(load)_met_before_and_during_start_power_saving_time_period
    Activate feature 5GC000431
    Add new cell to power group       power_group_id=0    cell_id=4    cell_switch_off_order=60     node_index=1
    Turn on lbps for specific time via GUI      how_many_mins_lbps_should_work=60     delay=12     node_index=0
    ${hour}    ${minute}   Get power saving period time start  power_group_id=0      node_index=0
    Wait until cell will be in state not energy saving     cell_id=4
    Wait until keyword succeeds   600    5    Verify lbps time has started    ${hour}   ${minute}
    Wait until cell will be in state energy saving       cell_id=4
    [Teardown]   Run Keywords
    ...             Deactivate feature 5GC000431
    ...             AND
    ...             Remove cell from power group       power_group_id=0    node_index=1
    ...             AND
    ...             interface.Common step trigger

[1]5GC000431_A_10_Power_saving_conditions(load)_met_during_and_after_power_saving_time_period
    Activate feature 5GC000431
    Add new cell to power group       power_group_id=0    cell_id=4    cell_switch_off_order=60     node_index=1
    Turn on lbps for specific time via GUI      how_many_mins_lbps_should_work=15    delay=0     node_index=0
    ${hour}    ${minute}   Get power saving period time end  power_group_id=0      node_index=0
    Prepare UE        ${UE_alias}     capabilities=${capabilities}    timeout=60
    Attach UE and run throughput  ${UE_alias}   capabilities=${capabilities}  dt_name=${dt_name}
    ...  direction=${direction}    throughput=100Mbits/sec    duration=300s    protocol=${protocol}
    ...  packet_size=${packet_size}   tput=100Mbits/sec    deviation=${deviation}     buffer_client=${buffer_client}
    ...    buffer_server=${buffer_server}
    Wait until cell will be in state energy saving       cell_id=4
    Wait until keyword succeeds   600    5    Verify lbps time has started    ${hour}   ${minute}
    Wait until cell will be in state not energy saving     cell_id=4
    [Teardown]   Run Keywords
    ...             Deactivate feature 5GC000431
    ...             AND
    ...             Remove cell from power group       power_group_id=0    node_index=1
    ...             AND
    ...             interface.Common step trigger

[1]5GC000431_A_11_Handle_cell_outage_impact_on_capacity
    [Tags]
    ...     RAN_5G__WITH__SBTS00__WITH__CLOUD_5G_CLASSICAL_ASKEY_ASIBL_ABILB1_AWEUA
    ...     RAN_5G__WITH__SBTS22R3__WITH__CLOUD_5G_CLASSICAL_ASKEY_ASIBL_ABILB1_AWEUA
    Activate feature 5GC000431
    Add new cell to power group       power_group_id=0    cell_id=2    cell_switch_off_order=60     node_index=1
    Add new cell to power group       power_group_id=0    cell_id=3    cell_switch_off_order=40     node_index=2
    Add new cell to power group       power_group_id=0    cell_id=4    cell_switch_off_order=20     node_index=3
    Turn on lbps for specific time via GUI       how_many_mins_lbps_should_work=60     delay=0     node_index=0
    Prepare UE        ${UE_alias}     capabilities=${capabilities}    timeout=60
    Attach UE and run throughput  ${UE_alias}   capabilities=${capabilities}  dt_name=${dt_name}
    ...  direction=${direction}    throughput=400Mbits/sec     duration=300s    protocol=${protocol}
    ...  packet_size=${packet_size}   tput=400Mbits/sec    deviation=${deviation}      buffer_client=${buffer_client}
    ...    buffer_server=${buffer_server}
    Wait until cell will be in state energy saving       cell_id=4
    Wait until cell will be in state energy saving       cell_id=3
    Run throughput    ${UE_alias}   capabilities=${capabilities}  dt_name=${dt_name}
    ...  direction=${direction}    throughput=1000Mbits/sec     duration=100s    protocol=${protocol}
    ...  packet_size=${packet_size}   tput=1000Mbits/sec    deviation=${deviation}      buffer_client=${buffer_client}
    ...    buffer_server=${buffer_server}
    Lock gNB Cell     cell_id=2
    Wait until cell will be in state not energy saving     cell_id=3
    Unlock gNB Cell    cell_id=2
    [Teardown]   Run Keywords
    ...             Deactivate feature 5GC000431
    ...             AND
    ...             Remove cell from power group       power_group_id=0    node_index=3
    ...             AND
    ...             Remove cell from power group       power_group_id=0    node_index=2
    ...             AND
    ...             Remove cell from power group       power_group_id=0    node_index=1
    ...             AND
    ...             interface.Common step trigger

[1]5GC000431_A_12_Suspend_Load-Based_Power_Saving
    Activate feature 5GC000431
    Add new cell to power group       power_group_id=0    cell_id=3    cell_switch_off_order=60     node_index=1
    Add new cell to power group       power_group_id=0    cell_id=4    cell_switch_off_order=40     node_index=2
    Turn on lbps for specific time via GUI      how_many_mins_lbps_should_work=60     delay=0    node_index=0
    Add new power saving period     power_group_id=0    node_index=1     how_many_mins_lbps_should_work=30     delay=15
    Wait until cell will be in state energy saving       cell_id=4
    Wait until cell will be in state energy saving          cell_id=3
    Verify if Parameter Changed to Correct Value via GUI     dist_name=${dist_name_power_group}
    ...    parameter=${parameter_suspended}     value=suspended    node_index=0
    Wait until cell will be in state not energy saving     cell_id=4
    Wait until cell will be in state not energy saving     cell_id=3
    Prepare UE        ${UE_alias}     capabilities=${capabilities}    timeout=60
    Attach UE and run throughput     ${UE_alias}   capabilities=${capabilities}  dt_name=${dt_name}
    ...  direction=${direction}    throughput=${throughput}    duration=${duration}    protocol=${protocol}
    ...  packet_size=${packet_size}   tput=${tput}    deviation=${deviation}     buffer_client=${buffer_client}
    ...    buffer_server=${buffer_server}
    [Teardown]   Run Keywords
    ...             Deactivate feature 5GC000431
    ...             AND
    ...             Remove power saving period         power_group_id=0    node_index=1
    ...             AND
    ...             Remove cell from power group       power_group_id=0    node_index=2
    ...             AND
    ...             Remove cell from power group       power_group_id=0    node_index=1
    ...             AND
    ...             interface.Common step trigger

[1]5GC000431_A_13_Un-suspend_Load-Based_Power_Saving
    Activate feature 5GC000431
    Add new cell to power group       power_group_id=0    cell_id=3    cell_switch_off_order=60     node_index=1
    Add new cell to power group       power_group_id=0    cell_id=4    cell_switch_off_order=40     node_index=2
    Turn on lbps for specific time via GUI      how_many_mins_lbps_should_work=60     delay=0    node_index=0
    Add new power saving period     power_group_id=0    node_index=1     how_many_mins_lbps_should_work=60     delay=15
    Wait until cell will be in state energy saving       cell_id=4
    Wait until cell will be in state energy saving          cell_id=3
    Verify if Parameter Changed to Correct Value via GUI     dist_name=${dist_name_power_group}
    ...    parameter=${parameter_suspended}     value=suspended    node_index=0
    Wait until cell will be in state not energy saving     cell_id=4
    Wait until cell will be in state not energy saving     cell_id=3
    Verify if Parameter Changed to Correct Value via GUI     dist_name=${dist_name_power_group}
    ...    parameter=${parameter_suspended}     value=notSuspended    node_index=0
    Wait until cell will be in state energy saving       cell_id=4
    Wait until cell will be in state energy saving          cell_id=3
    [Teardown]   Run Keywords
    ...             Deactivate feature 5GC000431
    ...             AND
    ...             Remove power saving period         power_group_id=0    node_index=1
    ...             AND
    ...             Remove cell from power group       power_group_id=0    node_index=2
    ...             AND
    ...             Remove cell from power group       power_group_id=0    node_index=1
    ...             AND
    ...             interface.Common step trigger
