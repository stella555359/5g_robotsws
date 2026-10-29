*** Settings ***
Documentation
...
...             Resources for CB010359

Library         BuiltIn
Library         XML  use_lxml=true
Library         OperatingSystem
Library         ute_ue
Library         taf/rfrl/ue/logs/tput_logs_collecting.py
Resource        taf/rfrl/bts/robot/gnb.robot
Resource        taf/rfrl/utilities/utf_lab/utf_lab.robot

*** Variables ***
${dist_name}=   MRBTS-{}/NRBTS-{}/NRCELL-2

*** Keywords ***
Activate feature CB010359
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name}
    ...                                                         param_name=actDlPaWarmUp
    ...                                                         operation=update
    ...                                                         param_value=${true}
    ...                                                         skip_parameter_relation_errors=${true}

Deactivate feature CB010359
    Perform Configuration Parameter Recommissioning On gNB      dist_name=${dist_name}
    ...                                                         param_name=actDlPaWarmUp
    ...                                                         operation=update
    ...                                                         param_value=false
    ...                                                         skip_parameter_relation_errors=${true}

Prepare UE
    [Arguments]     ${UE_alias}     ${capabilities}
    ute_ue.Require UE               ue_alias=${UE_alias}
    ...                             capabilities=${capabilities}

Attach ue and run throughput
    [Arguments]     ${UE_alias}    ${dt_name}  ${direction}  ${throughput}  ${duration}
    ...   ${protocol}    ${packet_size}     ${tput}    ${deviation}    ${buffer_client}     ${buffer_server}
#    Start UTF Lab on UTE VM
#    Wait Until UTF Lab Connection Is Established
    ute_ue.Detach UE                ue_alias=${UE_alias}
    Sleep     10
    ute_ue.Attach UE                ue_alias=${UE_alias}
    Sleep     10
    UTF Lab Start Tracing gNB
    ute_ue.start_data_transfer      dt_name=${dt_name}
    ...                             ue_alias=${UE_alias}
    ...                             direction=${direction}
    ...                             throughput=${throughput}
    ...                             duration=${duration}
    ...                             protocol=${protocol}
    ...                             packet_size=${packet_size}
    ...                             buffer_client=${buffer_client}
    ...                             buffer_server=${buffer_server}
    ute_ue.Check Data Transfer Is Alive                         dt_name=${dt_name}
    ute_ue.Await Data Transfer Finish                           dt_name=${dt_name}
    run keyword and continue on failure    ute_ue.Verify Average Throughput With Deviation            dt_name=${dt_name}
    ...                                                         tput=${tput}
    ...                                                         deviation=${deviation}
    [Teardown]  UTF Lab Stop Tracing and Collect Results

Set 5G Dummy Interface
    [Arguments]  ${scfc_file_path}
    ${nr_cells_count}=  SCFC Get Cells Count Based On Class
    ...  scfc_file_path=${scfc_file_path}  cell_class=com.nokia.srbts.nrbts:NRCELL
    Run Keyword If  ${nr_cells_count}>0
    ...  Add Dummy Interface  ip_addr=10.0.1.100

SCFC Get Cells Count Based On Class
    [Arguments]  ${scfc_file_path}  ${cell_class}
    ${cells_count}=  Evaluate Xpath  ${scfc_file_path}  count(//managedObject[@class='${cell_class}'])
    ${cells_count}=  Convert To Integer  item=${cells_count}
    [Return]  ${cells_count}

Add Dummy Interface
    [Arguments]  ${ip_addr}
    Run  sudo ip link add dummy0 type dummy
    Run  sudo ip addr add ${ip_addr}/24 dev dummy0
