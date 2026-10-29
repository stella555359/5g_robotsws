*** Settings ***
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource          taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/viavi_common_keyword.robot
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/Analysis_Viavi_Log.py
Library           ../../CB007608_B-573/Resources/5GC000573_common.py
Library           ./5GC002199_common.py
Library           ute_syslog
Library           Analysis_Viavi_Log.Viavi_Log_analysis     WITH NAME    Viavi_Log_analysis

*** Keywords ***
Trigger A2 measurement report
    [Arguments]    ${a2_meas_id}=1    ${report_interval}=0    ${serving_cell_pci}=50    ${serving_cell_rsrp}=75
    ...    ${serving_cell_rsrq}=53    ${serving_cell_sinr}=35    ${neigh_cell_pci}=51    ${neigh_cell_rsrp}=66    ${neigh_cell_rsrq}=57
    ...    ${neigh_cell_sinr}=44    ${tm500_alias}=e500
    log to console  Start to trigger A2 measurement report
    ${cmd_a3_mr}    catenate
    ...    forw mte NrRrcAptTriggerMeasReport ${a2_meas_id} 0 0 ${report_interval} 1
    ...    {8 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{0[[75] [53] []]}] []] [] []}
    ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{0[[66] [57] []]}] [] ] })]
    ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
    ${response}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
    sleep    5s

Trigger A5 measurement report
    [Arguments]    ${a2_meas_id}=3    ${report_interval}=0    ${serving_cell_pci}=50    ${serving_cell_rsrp}=50
    ...    ${serving_cell_rsrq}=55    ${serving_cell_sinr}=30    ${neigh_cell_pci}=52    ${neigh_cell_rsrp}=71    ${neigh_cell_rsrq}=77
    ...    ${neigh_cell_sinr}=30    ${tm500_alias}=e500
    log to console  Start to trigger A5 measurement report
    ${cmd_a3_mr}    catenate
    ...    forw mte NrRrcAptTriggerMeasReport ${a2_meas_id} 0 0 ${report_interval} 1
    ...    {8 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{0[[50] [55] [30]]}] []] [] []}
    ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{0[[71] [77] [30]]}] [] ] })]
    ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
    ${response}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
    sleep    5s
    Wait until keyword succeeds    10s    200ms    match pattern in response    response=${response}
    ...    e500_alias=${tm500_alias}    pattern=Random Access Complete

Trigger A1 measurement report
    [Arguments]    ${a2_meas_id}=2    ${report_interval}=0    ${serving_cell_pci}=50    ${serving_cell_rsrp}=107
    ...    ${serving_cell_rsrq}=53    ${serving_cell_sinr}=53    ${neigh_cell_pci}=52    ${neigh_cell_rsrp}=66    ${neigh_cell_rsrq}=57
    ...    ${neigh_cell_sinr}=44    ${tm500_alias}=e500
    log to console  Start to trigger A5 measurement report
    ${cmd_a3_mr}    catenate
    ...    forw mte NrRrcAptTriggerMeasReport ${a2_meas_id} 0 0 ${report_interval} 1
    ...    {8 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [35]] [] [[1{0[[107] [${serving_cell_sinr}] []]}] []] [] []}
    ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{0[[66] [] []]}] [] ] })]
    ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
    ${response}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
    sleep    5s
    Run Keyword And Expect Error    *String "Random Access Complete" is not found*       match pattern in response    response=${response}
    ...    e500_alias=${tm500_alias}    pattern=Random Access Complete

Get measId from wireshark log due to Event
    [Arguments]      ${pacp_filename}   ${txt_filename}    ${filter}   ${Event}   ${connection}=ute
    5GC000573_common_keyword.Connect to ENB with ssh    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}
    ...     password=${TEST_PC_PASSWORD}    alias=${connection}
    sleep    1s
    5GC000573_common_keyword.Convert pcap to text   source=${LOG_PATH}/${pacp_filename}
    ...  target=${LOG_PATH}/${txt_filename}   connection=${connection}    filter=${filter}
    ${meas_event_list}      return_add_measId_and_Event_map      file_name=${LOG_PATH}/${txt_filename}
    ${measid}      get from Dictionary   ${meas_event_list}    ${Event}
    [Return]   ${measid}
    [Teardown]    csn.Disconnect	connection=${connection}

Get measId from wireshark log due to Event due to rsrp
    [Arguments]      ${pacp_filename}   ${txt_filename}    ${filter}   ${Event}    ${RsrporRsrq}   ${isrsrp}=${True}   ${connection}=ute
    5GC000573_common_keyword.Connect to ENB with ssh    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}
    ...     password=${TEST_PC_PASSWORD}    alias=${connection}
    sleep    1s
    5GC000573_common_keyword.Convert pcap to text   source=${LOG_PATH}/${pacp_filename}
    ...  target=${LOG_PATH}/${txt_filename}   connection=${connection}    filter=${filter}
    ${meas_event_list}      return_rsrp_or_rsrq_Event_map      file_name=${LOG_PATH}/${txt_filename}   event=${Event}
    ${measid}      get from Dictionary   ${meas_event_list}    ${RsrporRsrq}
    [Return]   ${measid}
    [Teardown]    csn.Disconnect	connection=${connection}

Check Add Event A1 and A3 event And Remove A2
    [Arguments]      ${pacp_filename}   ${txt_filename}    ${filter}     ${check_measid}
    ...    ${Check_eventA1}=eventA1     ${Check_eventA3}=eventA3     ${connection}=ute
    5GC000573_common_keyword.Connect to ENB with ssh    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}
    ...     password=${TEST_PC_PASSWORD}    alias=${connection}
    sleep    1s
    5GC000573_common_keyword.Convert pcap to text   source=${LOG_PATH}/${pacp_filename}
    ...  target=${LOG_PATH}/${txt_filename}   connection=${connection}    filter=${filter}
    ${remove_measid}    return_remove_measId_and_Event_map   file_name=${LOG_PATH}/${txt_filename}
    ${meas_event_list}      return_add_measId_and_Event_map      file_name=${LOG_PATH}/${txt_filename}
    ${A1_event}     get from dictionary     ${meas_event_list}     eventA1
    ${A3_event}     get from dictionary     ${meas_event_list}      ${Check_eventA3}
    run keyword and continue on failure      list should contain value    ${remove_measid}    ${check_measid}
    run keyword and continue on failure      should not be empty     ${A1_event}
    should not be empty     ${A3_event}
    [Teardown]    csn.Disconnect	connection=${connection}

Check Add Event A2 And Remove A1 and A3
    [Arguments]      ${pacp_filename}   ${txt_filename}    ${filter}   ${check_measid_A1}   ${check_measid_A3}    ${connection}=ute
    5GC000573_common_keyword.Connect to ENB with ssh    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}
    ...     password=${TEST_PC_PASSWORD}    alias=${connection}
    sleep    1s
    5GC000573_common_keyword.Convert pcap to text   source=${LOG_PATH}/${pacp_filename}
    ...  target=${LOG_PATH}/${txt_filename}   connection=${connection}    filter=${filter}
    ${remove_measid}    return_remove_measId_and_Event_map   file_name=${LOG_PATH}/${txt_filename}
    ${meas_event_list}      return_add_measId_and_Event_map      file_name=${LOG_PATH}/${txt_filename}
    ${A2_event}     get from dictionary     ${meas_event_list}     eventA2
    run keyword and continue on failure      list should contain value    ${remove_measid}    ${check_measid_A1}
    run keyword and continue on failure      list should contain value    ${remove_measid}    ${check_measid_A3}
    should not be empty     ${A2_event}
    [Teardown]    csn.Disconnect	connection=${connection}