*** Settings ***
Documentation
...   Test suite for regression testing of feature 5GC002056-BBAB
...   author: Radoslaw Serafin, Julia Luszcz
...   contact: radoslaw.serafin@nokia.com, julia.luszcz@nokia.com

Library     ute_ue

Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ../../../procedures/Power_Saving/Configure_Load-Based_Power_Saving_Controls/procedure.robot
Resource    ../../../procedures/Power_Saving/resources/Power_Saving_cmW.robot
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/bts/robot/logs_collecting.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/bts/robot/common/enb_cell.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Force Tags    STATE_SW_UPLOADED    RAN_5G    PY36       CRT
...  RAN_5G__WITH__SBTS22R1__WITH__CLOUD_5G_CLASSICAL_2xANDROID_ASIBL_ABIOB1_3xAZQP_ENB_SBTS
...  RAN_5G__WITH__SBTS00__WITH__CLOUD_5G_CLASSICAL_2xANDROID_ASIBL_ABIOB1_3xAZQP_ENB_SBTS
...  RAN_5G__WITH__SBTS22R2__WITH__CLOUD_5G_CLASSICAL_2xANDROID_ASIBL_ABIOB1_3xAZQP_ENB_SBTS


*** Variables ***
${throughput}=   250Mbits/sec
${dt_name}=   dt1
${deviation}  30%
${UE_alias}     ANDROID_UE_2
${capabilities}    NOKIA_1
${direction}=  dl
${protocol}=  udp
${packet_size}=  1400
${tput}=   250Mbits/sec
${dec_tput}=    70Mbits/sec
${buffer_server}=   4M
${buffer_client}=   4M
${dist_name_power_group}=       MRBTS-{}/NRBTS-{}/NRPGRP-0
${dist_name_power_group_2}=     MRBTS-{}/NRBTS-{}/NRPGRP-1
${dist_name_lncel}=     MRBTS-{}/LNBTS-{}/LNCEL-1
${expected_tput_for_tl}=    250 Mbits/sec
${COLLECT_LOGS_DURING_DATA_TRANSFER}        ${False}

*** Test Cases ***
[1][2.0] 5GC002056_BBAB_4_Feature_5GC000431_Configure_Load-Based_Power_Saving_Controls
    Configure_Load-Based_Power_Saving_Controls
    [Teardown]    interface.Common step trigger

[1][2.0] 5GC002056_BBAB_3_Feature_5GC000431_Deactivation_with_cell_in_energySaving_state
    Add new power group     power_group_id=0    cell_id=1
    Add new cell to power group       power_group_id=0    cell_id=2    cell_switch_off_order=90     node_index=1
    Set last cell switch off value    value=true    power_group_id=0
    Set test variable   ${default_nrcell_id}    1
    Perform Configuration Parameter Recommissioning On eNB    dist_name=${dist_name_lncel}
    ...    param_name=defaultLnRelGnbCellId    param_value=${default_nrcell_id}
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name_power_group}
    ...   param_name=lbpsLastCellSOEnabled    operation=update    param_value=true
    ...   skip_parameter_relation_errors=${true}
    Turn on lbps for specific time via GUI     how_many_mins_lbps_should_work=60     delay=0    node_index=0
    Activate feature 5GC000431
    Wait until cell will be in state energy saving    cell_id=2
    Wait until cell will be in state energy saving    cell_id=1
    Deactivate feature 5GC000431
    Wait until cell will be in state not energy saving    cell_id=2
    Wait until cell will be in state not energy saving    cell_id=1
    Prepare UE 2481    UE_alias=${UE_alias}     capabilities=${capabilities}    timeout=120
    Perform Attach and Verify UE Properly Attached      ${UE_alias}
    Start Data Transfer and Verify Troughput    direction=dl    duration=150s    tput=${expected_tput_for_tl}
    ...    protocol=tcp    deviation=25%    alias=${UE_alias}
    [Teardown]    Run Keywords
    ...             Deactivate feature 5GC000431
    ...             AND
    ...             Remove power group     power_group_id=0
    ...             AND
    ...             interface.Common step trigger


[1][2.0] 5GC002056_BBAB_11_Handle_cell_outage_impact_on_capacity_cell_locking
    Add new power group     power_group_id=0    cell_id=1
    Add new cell to power group       power_group_id=0    cell_id=2    cell_switch_off_order=90     node_index=1
    Add new cell to power group       power_group_id=0    cell_id=3    cell_switch_off_order=40     node_index=2
    Add new cell to power group       power_group_id=0    cell_id=4    cell_switch_off_order=20     node_index=3
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name_power_group}
    ...   param_name=lbpsMaxLoad   operation=update    param_value=30
    ...   skip_parameter_relation_errors=${true}
    Prepare UE 2481          ${UE_alias}     capabilities=${capabilities}    timeout=120
    Turn on lbps for specific time via GUI     how_many_mins_lbps_should_work=40     delay=0    node_index=0
    Activate feature 5GC000431
    Attach UE and run high throughput    ${UE_alias}   capabilities=${capabilities}  dt_name=${dt_name}
    ...  direction=${direction}    throughput=150Mbits/sec    duration=300s    protocol=${protocol}
    ...  packet_size=${packet_size}   tput=150Mbits/sec    deviation=${deviation}     buffer_client=${buffer_client}
    ...    buffer_server=${buffer_server}
    Wait until cell will be in state not energy saving      cell_id=1
    Wait until cell will be in state not energy saving      cell_id=2
    Wait until cell will be in state energy saving      cell_id=4
    Wait until cell will be in state energy saving      cell_id=3
    Lock or block cell      gnb_id=0    cell_id=2   du_id=0
    Wait until cell will be in state not energy saving      cell_id=3
    [Teardown]    Run Keywords
    ...             Deactivate feature 5GC000431
    ...             AND
    ...             Unlock or unblock cell      gnb_id=0    cell_id=2   du_id=0
    ...             AND
    ...             Remove power group     power_group_id=0
    ...             AND
    ...             interface.Common step trigger

[1][2.0] 5GC002056_BBAB_8_Power_saving_condition(load)_met_outside_power_saving_time_period
    Add new power group     power_group_id=0    cell_id=1
    Add new cell to power group       power_group_id=0    cell_id=2    cell_switch_off_order=90     node_index=1
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name_power_group}
    ...   param_name=lbpsLastCellSOEnabled    operation=update    param_value=true
    ...   skip_parameter_relation_errors=${true}
    Activate feature 5GC000431
    Turn on lbps for specific time via GUI     how_many_mins_lbps_should_work=7     delay=0    node_index=0
    Verify Feature Activation Time has ended    power_group_id=0    node_index=0
    Prepare UE 2481          ${UE_alias}     capabilities=${capabilities}    timeout=120
    Attach UE and run high throughput    ${UE_alias}   capabilities=${capabilities}  dt_name=${dt_name}
    ...  direction=${direction}    throughput=75Mbits/sec     duration=300s    protocol=${protocol}
    ...  packet_size=${packet_size}   tput=75Mbits/sec    deviation=${deviation}     buffer_client=${buffer_client}
    ...    buffer_server=${buffer_server}
    Sleep   5m
    Wait until cell will be in state not energy saving      cell_id=2
    Attach UE and run high throughput    ${UE_alias}   capabilities=${capabilities}  dt_name=${dt_name}
    ...  direction=${direction}    throughput=250Mbits/sec     duration=300s    protocol=${protocol}
    ...  packet_size=${packet_size}   tput=250Mbits/sec    deviation=${deviation}      buffer_client=${buffer_client}
    ...    buffer_server=${buffer_server}
    [Teardown]    Run Keywords
    ...             Deactivate feature 5GC000431
    ...             AND
    ...             Remove power group     power_group_id=0
    ...             AND
    ...             interface.Common step trigger

[1][2.0] 5GC002056_BBAB_18_PM_counter_M55601C00501
    Add new power group     power_group_id=0    cell_id=1
    Add new cell to power group       power_group_id=0    cell_id=2    cell_switch_off_order=90     node_index=1
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name_power_group}
    ...   param_name=lbpsMaxLoad   operation=update    param_value=60
    ...   skip_parameter_relation_errors=${true}
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name_power_group}
    ...   param_name=lbpsMinLoad   operation=update    param_value=20
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name_power_group}
    ...   param_name=lbpsLastCellSOEnabled    operation=update    param_value=true
    ...   skip_parameter_relation_errors=${true}
    Turn on lbps for specific time via GUI     how_many_mins_lbps_should_work=60     delay=0    node_index=0
    Activate feature 5GC000431
    Prepare UE 2481          ${UE_alias}     capabilities=${capabilities}    timeout=120
    Attach UE and run high throughput    ${UE_alias}   capabilities=${capabilities}  dt_name=${dt_name}
    ...  direction=${direction}    throughput=50Mbits/sec    duration=300s    protocol=${protocol}
    ...  packet_size=${packet_size}   tput=50Mbits/sec    deviation=${deviation}     buffer_client=${buffer_client}
    ...    buffer_server=${buffer_server}
    Wait until cell will be in state not energy saving      cell_id=1
    Wait until cell will be in state energy saving      cell_id=2
    gnb_counter.Wait for PM measurements    interval=5      measurements=1
    Verify PM counter    counter_id=M55601C00501   target=300   cell_id=1
    Verify PM counter    counter_id=M55601C00501   target=300   cell_id=2
    [Teardown]    Run Keywords
    ...             Deactivate feature 5GC000431
    ...             AND
    ...             Remove power group     power_group_id=0
    ...             AND
    ...             interface.Common step trigger

[1][2.0] 5GC002056_BBAB_19_PM_counter_M55601C00502
    Add new power group     power_group_id=0    cell_id=1
    Add new cell to power group       power_group_id=0    cell_id=2    cell_switch_off_order=90     node_index=1
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name_power_group}
    ...   param_name=lbpsLastCellSOEnabled    operation=update    param_value=true
    ...   skip_parameter_relation_errors=${true}
    Turn on lbps for specific time via GUI     how_many_mins_lbps_should_work=60     delay=0    node_index=0
    Prepare UE 2481          ${UE_alias}     capabilities=${capabilities}    timeout=120
    Activate feature 5GC000431
    Attach UE and run high throughput    ${UE_alias}   capabilities=${capabilities}  dt_name=${dt_name}
    ...  direction=${direction}    throughput=250Mbits/sec    duration=100s    protocol=${protocol}
    ...  packet_size=${packet_size}   tput=250Mbits/sec    deviation=${deviation}     buffer_client=${buffer_client}
    ...    buffer_server=${buffer_server}
    Wait until cell will be in state not energy saving      cell_id=2
    Wait until cell will be in state not energy saving      cell_id=1
    Wait for measurements    interval=5      measurements=1
    Verify PM counter    counter_id=M55601C00502   target=0     cell_id=2
    Verify PM counter    counter_id=M55601C00502   target=0     cell_id=1
    Run throughput    ${UE_alias}   capabilities=${capabilities}  dt_name=${dt_name}
    ...  direction=${direction}    throughput=25Mbits/sec     duration=100s    protocol=${protocol}
    ...  packet_size=${packet_size}   tput=25Mbits/sec    deviation=${deviation}      buffer_client=${buffer_client}
    ...    buffer_server=${buffer_server}
    Wait until cell will be in state energy saving      cell_id=2
    Wait until cell will be in state energy saving      cell_id=1
    Verify PM counter    counter_id=M55601C00502   target=1     cell_id=2
    Wait Until Keyword Succeeds     10min   00s     Verify PM counter    counter_id=M55601C00502   target=1     cell_id=1
    [Teardown]    Run Keywords
    ...             Deactivate feature 5GC000431
    ...             AND
    ...             Remove power group     power_group_id=0
    ...             AND
    ...             interface.Common step trigger

[1][2.0] 5GC002056_BBAB_21_Cell_Switch-off_Cell_level_measurement
    [Setup]     Prepare UE 2481     UE_alias=${UE_alias}     capabilities=${capabilities}    timeout=120
    Create and Prepare New Power Group
    Turn on lbps for specific time via GUI     how_many_mins_lbps_should_work=120     delay=0    node_index=0
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name_power_group}
    ...   param_name=lbpsMaxLoad   operation=update    param_value=30
    ...   skip_parameter_relation_errors=${true}
    Activate feature 5GC000431
    Perform Cell Level Measurement      min_load=30      offset=5    tput=${tput}    dec_tput=${dec_tput}
    Verify if Cell Has Recovered
    Perform Cell Level Measurement      min_load=50      offset=10    tput=${tput}    dec_tput=${dec_tput}
    [Teardown]    Run Keywords
    ...             Deactivate feature 5GC000431
    ...             AND
    ...             Remove power group     power_group_id=0
    ...             AND
    ...             interface.Common step trigger

[1][2.0] 5GC002056_BBAB_13_Suspend_Load-Based_Power_Saving
    Add new power group     power_group_id=0    cell_id=1
    Add new cell to power group       power_group_id=0    cell_id=2    cell_switch_off_order=90     node_index=1
    Turn on lbps for specific time via GUI     how_many_mins_lbps_should_work=45     delay=0    node_index=0
    Add new power saving period     power_group_id=0    node_index=1     how_many_mins_lbps_should_work=30     delay=50
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name_power_group}
    ...   param_name=lbpsLastCellSOEnabled    operation=update    param_value=true
    ...   skip_parameter_relation_errors=${true}
    Prepare UE 2481          ${UE_alias}     capabilities=${capabilities}    timeout=120
    Activate feature 5GC000431
    Attach UE and run high throughput    ${UE_alias}   capabilities=${capabilities}  dt_name=${dt_name}
    ...  direction=${direction}    throughput=75Mbits/sec     duration=300s    protocol=${protocol}
    ...  packet_size=${packet_size}   tput=75Mbits/sec    deviation=${deviation}      buffer_client=${buffer_client}
    ...    buffer_server=${buffer_server}
    Wait until cell will be in state not energy saving      cell_id=1
    Wait until cell will be in state energy saving      cell_id=2
    Verify if Parameter Changed to Correct Value via GUI     dist_name=${dist_name_power_group}
    ...    parameter=${parameter_suspended}     value=suspended    node_index=0
    Sleep   2m
    Wait until cell will be in state not energy saving      cell_id=2
    Verify Feature Activation Time has ended    power_group_id=0    node_index=0
    Verify Feature Activation Time has started    power_group_id=0    node_index=1
    Wait until cell will be in state energy saving      cell_id=2
    [Teardown]    Run Keywords
    ...             Deactivate feature 5GC000431
    ...             AND
    ...             Remove power group     power_group_id=0
    ...             AND
    ...             interface.Common step trigger

[1][2.0] 5GC002056_BBAB_14_Suspend_Load-Based_Power_Saving_outside_of_suspended_time_period
    Add new power group     power_group_id=0    cell_id=1
    Add new cell to power group       power_group_id=0    cell_id=2    cell_switch_off_order=90     node_index=1
    Turn on lbps for specific time via GUI     how_many_mins_lbps_should_work=45     delay=0    node_index=0
    Add new power saving period     power_group_id=0    node_index=1     how_many_mins_lbps_should_work=30     delay=50
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name_power_group}
    ...   param_name=lbpsLastCellSOEnabled    operation=update    param_value=true
    ...   skip_parameter_relation_errors=${true}
    Prepare UE 2481          ${UE_alias}     capabilities=${capabilities}    timeout=120
    Activate feature 5GC000431
    Attach UE and run high throughput    ${UE_alias}   capabilities=${capabilities}  dt_name=${dt_name}
    ...  direction=${direction}    throughput=75Mbits/sec     duration=300s    protocol=${protocol}
    ...  packet_size=${packet_size}   tput=75Mbits/sec    deviation=${deviation}      buffer_client=${buffer_client}
    ...    buffer_server=${buffer_server}   #Generate tput so C1,C2 nonES, C3,C4 ES
    Wait until cell will be in state not energy saving      cell_id=1
    Wait until cell will be in state energy saving      cell_id=2
    Verify if Parameter Changed to Correct Value via GUI     dist_name=${dist_name_power_group}
    ...    parameter=${parameter_suspended}     value=suspended    node_index=1
    Wait until cell will be in state energy saving      cell_id=2
    Verify Feature Activation Time has ended    power_group_id=0    node_index=0
    Verify Feature Activation Time has started    power_group_id=0    node_index=1
    Attach UE and run high throughput    ${UE_alias}   capabilities=${capabilities}  dt_name=${dt_name}
    ...  direction=${direction}    throughput=75Mbits/sec     duration=300s    protocol=${protocol}
    ...  packet_size=${packet_size}   tput=75Mbits/sec    deviation=${deviation}      buffer_client=${buffer_client}
    ...    buffer_server=${buffer_server}
    Sleep   5m
    Wait until cell will be in state not energy saving      cell_id=2
    [Teardown]    Run Keywords
    ...             Deactivate feature 5GC000431
    ...             AND
    ...             Remove power group     power_group_id=0
    ...             AND
    ...             interface.Common step trigger

[1][2.0] 5GC002056_BBAB_15_Un-suspend_Load-Based_Power_Saving
    Add new power group     power_group_id=0    cell_id=1
    Add new cell to power group       power_group_id=0    cell_id=2    cell_switch_off_order=90     node_index=1
    Turn on lbps for specific time via GUI     how_many_mins_lbps_should_work=45     delay=0    node_index=0
    Add new power saving period     power_group_id=0    node_index=1     how_many_mins_lbps_should_work=30     delay=50
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name_power_group}
    ...   param_name=lbpsLastCellSOEnabled    operation=update    param_value=true
    ...   skip_parameter_relation_errors=${true}
    Verify if Parameter Changed to Correct Value via GUI     dist_name=${dist_name_power_group}
    ...    parameter=${parameter_suspended}     value=suspended    node_index=0
    Prepare UE 2481          ${UE_alias}     capabilities=${capabilities}    timeout=120
    Activate feature 5GC000431
    Attach UE and run high throughput    ${UE_alias}   capabilities=${capabilities}  dt_name=${dt_name}
    ...  direction=${direction}    throughput=75Mbits/sec     duration=300s    protocol=${protocol}
    ...  packet_size=${packet_size}   tput=75Mbits/sec    deviation=${deviation}      buffer_client=${buffer_client}
    ...    buffer_server=${buffer_server}
    Wait until cell will be in state not energy saving      cell_id=1
    Wait until cell will be in state not energy saving      cell_id=2
    Verify if Parameter Changed to Correct Value via GUI     dist_name=${dist_name_power_group}
    ...    parameter=${parameter_suspended}     value=notSuspended    node_index=0
    Wait until cell will be in state energy saving      cell_id=2
    Verify Feature Activation Time has ended    power_group_id=0    node_index=0
    Verify Feature Activation Time has started    power_group_id=0    node_index=1
    Attach UE and run high throughput    ${UE_alias}   capabilities=${capabilities}  dt_name=${dt_name}
    ...  direction=${direction}    throughput=75Mbits/sec     duration=300s    protocol=${protocol}
    ...  packet_size=${packet_size}   tput=75Mbits/sec    deviation=${deviation}      buffer_client=${buffer_client}
    ...    buffer_server=${buffer_server}
    Wait until cell will be in state energy saving      cell_id=2
    [Teardown]    Run Keywords
    ...             Deactivate feature 5GC000431
    ...             AND
    ...             Remove power saving period    power_group_id=0    node_index=1
    ...             AND
    ...             Remove power group     power_group_id=0
    ...             AND
    ...             interface.Common step trigger

[1][2.0] 5GC002056_BBAB_22_Reset_site_with_power_saving_on
    Add new power group     power_group_id=0    cell_id=1
    Add new cell to power group       power_group_id=0    cell_id=2    cell_switch_off_order=90     node_index=1
    Turn on lbps for specific time via GUI     how_many_mins_lbps_should_work=75     delay=0    node_index=0
    Activate feature 5GC000431
    Wait until cell will be in state energy saving      cell_id=2
    Reset gNB via GUI
    Sleep   30s
    Verify gNB Responds     timeout=180
    Wait for site to be OnAir
    Wait for cell to be OnAir   cell_id=1    timeout=600
    Wait for cell to be OnAir   cell_id=2    timeout=600
    Wait until cell will be in state energy saving      cell_id=2
    [Teardown]    Run Keywords
    ...             Deactivate feature 5GC000431
    ...             AND
    ...             Remove power group     power_group_id=0
    ...             AND
    ...             interface.Common step trigger

[1][2.0] 5GC002056_BBAB_7_Determine_Cell_Power_Saving_Mode
    Set test variable   ${default_nrcell_id}    3
    Perform Configuration Parameter Recommissioning On eNB    dist_name=${dist_name_lncel}
    ...    param_name=defaultLnRelGnbCellId    param_value=${default_nrcell_id}
    Add new power group     power_group_id=0    cell_id=1
    Add new cell to power group       power_group_id=0    cell_id=2    cell_switch_off_order=80     node_index=1
    Add new cell to power group       power_group_id=0    cell_id=3    cell_switch_off_order=70     node_index=2
    Add new cell to power group       power_group_id=0    cell_id=4    cell_switch_off_order=60     node_index=3
    Prepare UE 2481          ${UE_alias}     capabilities=${capabilities}    timeout=120
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name_power_group}
    ...   param_name=lbpsMaxLoad   operation=update    param_value=30
    ...   skip_parameter_relation_errors=${true}
    Turn on lbps for specific time via GUI     how_many_mins_lbps_should_work=120     delay=0    node_index=0
    Activate feature 5GC000431
    Attach UE and run low throughput    ${UE_alias}   capabilities=${capabilities}  dt_name=${dt_name}
    ...  direction=${direction}    throughput=50Mbits/sec    duration=50s    protocol=${protocol}
    ...  packet_size=${packet_size}   tput=50Mbits/sec    deviation=${deviation}     buffer_client=${buffer_client}
    ...    buffer_server=${buffer_server}
    Wait until cell will be in state energy saving       cell_id=4
    Wait until cell will be in state energy saving       cell_id=3
    Attach UE and run high throughput    ${UE_alias}   capabilities=${capabilities}  dt_name=${dt_name}
    ...  direction=${direction}    throughput=250Mbits/sec    duration=300s    protocol=${protocol}
    ...  packet_size=${packet_size}   tput=250Mbits/sec    deviation=${deviation}     buffer_client=${buffer_client}
    ...    buffer_server=${buffer_server}
    Wait until cell will be in state not energy saving          cell_id=3
    Attach UE and run high throughput   ${UE_alias}   capabilities=${capabilities}  dt_name=${dt_name}
    ...  direction=${direction}    throughput=250Mbits/sec    duration=300s    protocol=${protocol}
    ...  packet_size=${packet_size}   tput=250Mbits/sec    deviation=${deviation}     buffer_client=${buffer_client}
    ...    buffer_server=${buffer_server}
    Wait until cell will be in state not energy saving     cell_id=4
    [Teardown]    Run Keywords
    ...             Deactivate feature 5GC000431
    ...             AND
    ...             Remove power group     power_group_id=0
    ...             AND
    ...             interface.Common step trigger
