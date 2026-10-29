*** Settings ***
Documentation
...   author: Aiyang Zhang
...   squad group: HAZ3_SG3
...   contact: aiyang.zhang@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/Cloud_VRAN40/vCU.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/Cloud_VRAN40/vDU.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/Cloud_VRAN40/common_setup_teardown.robot



*** Variables ***
${du_scf_file_path}    ${commissionings_path}HGZ/7_5_UTE5G401T2079/SCF_vDU.xml
${cu_scf_file_path}    ${commissionings_path}HGZ/7_5_UTE5G401T2079/SCF_vCU.xml
${snapshot_file_dir}    /home/ute/Case_Logs/vdu_snapshot
${vcu_snapshot_file_dir}    /home/ute/Case_Logs/vcu_snapshot
${vDU_DN_MRBTS}    MRBTS-${tl.gnbs[0].dus[0].instance_id}
${rmods_list}    1,2
${ALLOWED_ALARMS_DU}    '4592', '61631', '4298', '4405', '16', '4681', '4675', '4785', '7504', '4261', '23', '1837'
${ALLOWED_ALARMS_CU}    '4592', '4681', '7107', '7104', '7304'
*** Keywords ***

####case setup/teatdowm##############
DU Scf commission and wait on-air
    Log to console    \nStart to commssion for vdu TL2079\n
    Connect to vdu via rest api
    Commission on vdu   du_scf_file_path=${du_scf_file_path}
    Log to console    \nwait cell on-air\n
    sleep    200s
    Wait for vdu ready and cells are on air    retry_interval=1min
    [teardown]    Run Keyword And Ignore error    Teardown vdu connection

Reset vDU
    [Arguments]  ${gnb_index}=0    ${du_index}=0    ${connection}=OAM_gnb${gnb_index}_du${du_index}
    Log to console    \n************ VDU reset*************************
    vdu.reset_vdu    vdu_connection=${connection}

Reset vDU and wait on-air
    Log to console    \nStart to reset vdu\n
    Connect to vdu via rest api
    Reset vDU
    Log to console    \nwait cell on-air\n
    sleep    200s
    Wait for vdu ready and cells are on air    retry_interval=1min
    [teardown]    Run Keyword And Ignore error    Teardown vdu connection


RANNIC reset and wait on-air
    Log to console    \nStart to rannic reset\n
    Connect to vdu via rest api
    ${list_rannic_r_dn}    Get RANNIC runtime DN    mrbts_dn=${vDU_DN_MRBTS}
    Perform RANNIC reset    mrbts_dn=${vDU_DN_MRBTS}    list_rannic_r_dn=${list_rannic_r_dn}
    Log to console    \nwait cell on-air\n
    sleep    40s
    Wait for vdu ready and cells are on air    retry_interval=1min
    [teardown]    Run Keyword And Ignore error    Teardown vdu connection

Collect vDU snapshot
    Log to console    \nStart to collect vdu snapshot\n
    Connect to vdu via rest api
    VDU Collect Snapshot To Local    snapshot_file_dir=${snapshot_file_dir}
    [teardown]    Run Keyword And Ignore error    Teardown vdu connection

Lock&Unlock RU
    Log to console    \nStart to Lock RU\n
    Connect to vdu via rest api
    Perform RMOD lock    timeout=3min    rmods_list=${rmods_list}
    Log to console    \nStart to Unlock RU\n
    Perform RMOD unlock    timeout=3min    rmods_list=${rmods_list}
    Log to console    \nwait cell on-air\n
    sleep    150s
    Wait for vdu ready and cells are on air    retry_interval=1min
    [teardown]    Run Keyword And Ignore error    Teardown vdu connection

Perform RMOD unlock for teardowm
    Log to console    \nStart to Unlock RU for teardown\n
    Connect to vdu via rest api
    Perform RMOD unlock    timeout=2min    rmods_list=${rmods_list}
    Log to console    \nwait cell on-air\n
    sleep    15s
    Wait for vdu ready and cells are on air    retry_interval=1min
    [teardown]    Run Keyword And Ignore error    Teardown vdu connection

RU reset
    Log to console    \nStart to RU reset\n
    Connect to vdu via rest api
    Perform reset RUs   rmods_list=${rmods_list}
    Log to console    \nwait cell on-air\n
    sleep    200s
    Wait for vdu ready and cells are on air    retry_interval=1min
    [teardown]    Run Keyword And Ignore error    Teardown vdu connection

CU Scf commission and wait on-air
    Log to console    \nStart to commssion for vdu\n
    Connect to vcu via rest api
    Commission on vcu   cu_scf_file_path=${cu_scf_file_path}
    Log to console    \nwait cell on-air\n
    sleep    400s
    Wait for vcu ready and cells are on air    retry_interval=1min
    [teardown]    Run Keyword And Ignore error    Teardown vcu connection

Reset vCU
    [Arguments]  ${connection}=OAM_CU0
    Log to console    \n************ VCU reset*************************
    cu.reset_cu    connection=${connection}

Reset vCU and wait on-air
    Log to console    \nStart to vCU reset\n
    Connect to vcu via rest api
    Reset vCU
    Log to console    \nwait cell on-air\n
    sleep    400s
    Wait for vcu ready and cells are on air    retry_interval=1min
    [teardown]    Run Keyword And Ignore error    Teardown vcu connection


Collect vCU snapshot
    Log to console    \nStart to collect vcu snapshot\n
    Connect to vcu via rest api
    VCU Collect Snapshot To Local    snapshot_file_dir=${vcu_snapshot_file_dir}
    [teardown]    Run Keyword And Ignore error    Teardown vcu connection


### Alarm check ####

Check No expected Active Alarm on DU
    log to console    Check No expected Active Alarm on DU
    @{alarm info}    Get fault list on DU from active alarm list
    should be empty    ${alarm info}


Get fault list on DU from active alarm list
    [Documentation]    Get fault id from all DUs and return with fault id listed for each vDU.
    ...    Example output: {'OAM_gnb0_du0': ['6450', '10'], 'OAM_gnb0_du1': ['6450', '10']}
    [Arguments]    ${gnb_index}=${0}    ${du_index_list}=${LIST_DU_INDEX_0}
    ${cu_connection}    ${du_connection_list}    Create CU And DU Connections    gnb_index=${gnb_index}    du_index_list=${du_index_list}
    &{dict_vdu_alarms}    Get active alarms on VDUs    du_connection_list=${du_connection_list}
    ${dict_fault_id_vdus}    Create dictionary
    FOR    ${du_connection}    IN    @{du_connection_list}
        &{vdu_active_alarms}    Set variable    ${dict_vdu_alarms['${du_connection}']}
        ${list_fault_id_vdu}    Get fault id from alarm list    active_alarms=${vdu_active_alarms}
    END
    [Return]    ${list_fault_id_vdu}
    [Teardown]  Aic Close all connection    gnb_index=${gnb_index}   du_index_list=${du_index_list}

Check No expected Historical Alarm on DU
    log to console    Check No expected Historical Alarm on DU
    @{alarm info}    Get fault list on DU from historical alarm list
    FOR    ${alarm}  IN      @{alarm info}
        Should contain    ${ALLOWED_ALARMS_DU}    '${alarm}'
    END


Get fault list on DU from historical alarm list
    [Documentation]    Get fault id from all DUs and return with fault id listed for each vDU.
    ...    Example output: ['6450', '10']
    [Arguments]    ${gnb_index}=${0}    ${du_index_list}=${LIST_DU_INDEX_0}
    ${cu_connection}    ${du_connection_list}    Create CU And DU Connections    gnb_index=${gnb_index}    du_index_list=${du_index_list}
    &{dict_vdu_alarms}    Get historical alarms on VDUs    du_connection_list=${du_connection_list}
    ${dict_fault_id_vdus}    Create dictionary
    FOR    ${du_connection}    IN    @{du_connection_list}
        &{vdu_active_alarms}    Set variable    ${dict_vdu_alarms['${du_connection}']}
        ${list_fault_id_vdu}    Get fault id from alarm list    active_alarms=${vdu_active_alarms}
    END
    [Return]    ${list_fault_id_vdu}
    [Teardown]  Aic Close all connection    gnb_index=${gnb_index}   du_index_list=${du_index_list}

Get historical alarms on VDUs
    [Documentation]  Author: Ding Binmei
    ...    du_connection_list: should be a list
    ...    return value with dict as bellow: {du_connection_alias:{alarms:[],total:XX}}
    [Arguments]    ${du_connection_list}
    ${dict_active_alarms}    Create dictionary
    FOR    ${vdu_connection}    IN    @{du_connection_list}
        ${active_alarms}    Run keyword and continue on failure    vdu.vdu_get_historical_alarms    vdu_connection=${vdu_connection}
        Set to dictionary    ${dict_active_alarms}    ${vdu_connection}    ${active_alarms}
    END
    [Return]  ${dict_active_alarms}

Check No expected Active Alarm on CU
    log to console    Check No expected Active Alarm on DU
    @{alarm info}    Get fault id list on CU from active alarm list
    should be empty    ${alarm info}

Check No expected Historical Alarm on CU
    log to console    Check No expected Historical Alarm on DU
    @{alarm info}    Get fault id list on CU from historical alarm list
    FOR    ${alarm}  IN      @{alarm info}
        Should contain    ${ALLOWED_ALARMS_CU}    '${alarm}'
    END

Get fault id list on CU from historical alarm list
    [Documentation]  Author: Ding Binmei
    ...    Get fault id from CU.
    ...    Return as a list like: ['6450', '10']
    [Arguments]    ${gnb_index}=${0}    ${du_index_list}=${LIST_DU_INDEX_0}
    ${cu_connection}    ${du_connection_list}    Create CU And DU Connections    gnb_index=${gnb_index}    du_index_list=${du_index_list}
    ${cu_active_alarms}    cu.get_historical_alarms    connection=${cu_connection}
    ${list_fault_id_cu}    Get fault id from alarm list    active_alarms=${cu_active_alarms}
    [Return]    ${list_fault_id_cu}
    [Teardown]  Aic Close all connection    gnb_index=${gnb_index}   du_index_list=${du_index_list}

### check update fault ####
check update fault
    log to console    check update fault
    Connect to vdu via rest api
    ${run_status}    run keyword and return status    Wait Until Keyword Succeeds   10m   1m
    ...    Check all cells are on cell on air status on vdu
    sleep    30s
    Teardown vdu connection
    ${alarm_status_du}    run keyword and return status    Check No expected Active Alarm on DU
    ${alarm_status_cu}    run keyword and return status    Check No expected Active Alarm on CU
    ${historical_alarm_status_du}    run keyword and return status    Check No expected Historical Alarm on DU
    ${historical_alarm_status_cu}    run keyword and return status    Check No expected Historical Alarm on CU
    ${alarm_status_active}    Evaluate  ${alarm_status_du} and ${alarm_status_cu}
    ${alarm_status_historical}    Evaluate  ${historical_alarm_status_du} and ${historical_alarm_status_cu}
    ${alarm_status}    Evaluate  ${alarm_status_active} and ${alarm_status_historical}
    ${status}	   Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
    RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
    ${snapshot_file_du}    Run Keyword If    '${status}'=='fail'
    ...    Run Keyword And Ignore error    Collect vDU snapshot
    ${snapshot_file_cu}    Run Keyword If    '${status}'=='fail'
    ...    Run Keyword And Ignore error    Collect vCU snapshot
    Run Keyword And Ignore error    Teardown vdu connection
    [teardown]    Run Keyword And Ignore error    Teardown vdu connection


###Rannic Reset ####
RANNIC reset ${num} times
    log to console    RANNIC reset ${num} times
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    RANNIC reset ${i}
        Connect to vdu via rest api
        ${list_rannic_r_dn}    Get RANNIC runtime DN    mrbts_dn=${vDU_DN_MRBTS}
        Perform RANNIC reset    mrbts_dn=${vDU_DN_MRBTS}    list_rannic_r_dn=${list_rannic_r_dn}
        sleep    180s
        ${run_status}    run keyword and return status    Wait Until Keyword Succeeds   16m   1m
        ...    Check all cells are on cell on air status on vdu
        sleep    30s
        Teardown vdu connection
        ${alarm_status_du}    run keyword and return status    Check No expected Active Alarm on DU
        ${alarm_status_cu}    run keyword and return status    Check No expected Active Alarm on CU
        ${historical_alarm_status_du}    run keyword and return status    Check No expected Historical Alarm on DU
        ${historical_alarm_status_cu}    run keyword and return status    Check No expected Historical Alarm on CU
        ${alarm_status_active}    Evaluate  ${alarm_status_du} and ${alarm_status_cu}
        ${alarm_status_historical}    Evaluate  ${historical_alarm_status_du} and ${historical_alarm_status_cu}
        ${alarm_status}    Evaluate  ${alarm_status_active} and ${alarm_status_historical}
        ${status}	   Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        ${snapshot_file_du}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect vDU snapshot
        ${snapshot_file_cu}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect vCU snapshot
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=3
        Run Keyword And Ignore error    Teardown vdu connection
    END
    [teardown]    Run Keyword And Ignore error    Teardown vdu connection


###Lock&Unlock RU ####
Lock&Unlock RU ${num} times
    log to console    Lock&Unlock RU ${num} times
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    Lock&Unlock RU ${i}
        Connect to vdu via rest api
        Log to console    \nStart to Lock RU\n
        Perform RMOD lock    timeout=3min    rmods_list=${rmods_list}
        sleep    100s
        Log to console    \nStart to Unlock RU\n
        Perform RMOD unlock    timeout=3min    rmods_list=${rmods_list}
        sleep    300s
        ${run_status}    run keyword and return status    Wait Until Keyword Succeeds   16m   1m
        ...    Check all cells are on cell on air status on vdu
        Teardown vdu connection
        ${alarm_status_du}    run keyword and return status    Check No expected Active Alarm on DU
        ${alarm_status_cu}    run keyword and return status    Check No expected Active Alarm on CU
        ${historical_alarm_status_du}    run keyword and return status    Check No expected Historical Alarm on DU
        ${historical_alarm_status_cu}    run keyword and return status    Check No expected Historical Alarm on CU
        ${alarm_status_active}    Evaluate  ${alarm_status_du} and ${alarm_status_cu}
        ${alarm_status_historical}    Evaluate  ${historical_alarm_status_du} and ${historical_alarm_status_cu}
        ${alarm_status}    Evaluate  ${alarm_status_active} and ${alarm_status_historical}
        ${status}	   Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        ${snapshot_file_du}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect vDU snapshot
        ${snapshot_file_cu}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect vCU snapshot
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=3
        Run Keyword And Ignore error    Teardown vdu connection
    END
    [teardown]    Run Keyword And Ignore error    Teardown vdu connection


###RU reset####
RU reset ${num} times
    log to console    RU reset ${num} times
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    RU reset ${i}
        Connect to vdu via rest api
        Perform reset RUs   rmods_list=${rmods_list}
        sleep    300s
        ${run_status}    run keyword and return status    Wait Until Keyword Succeeds   16m   1m
        ...    Check all cells are on cell on air status on vdu
        Teardown vdu connection
        ${alarm_status_du}    run keyword and return status    Check No expected Active Alarm on DU
        ${alarm_status_cu}    run keyword and return status    Check No expected Active Alarm on CU
        ${historical_alarm_status_du}    run keyword and return status    Check No expected Historical Alarm on DU
        ${historical_alarm_status_cu}    run keyword and return status    Check No expected Historical Alarm on CU
        ${alarm_status_active}    Evaluate  ${alarm_status_du} and ${alarm_status_cu}
        ${alarm_status_historical}    Evaluate  ${historical_alarm_status_du} and ${historical_alarm_status_cu}
        ${alarm_status}    Evaluate  ${alarm_status_active} and ${alarm_status_historical}
        ${status}	   Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        ${snapshot_file_du}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect vDU snapshot
        ${snapshot_file_cu}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect vCU snapshot
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=3
        Run Keyword And Ignore error    Teardown vdu connection
    END
    [teardown]    Run Keyword And Ignore error    Teardown vdu connection


### DU Commission ####
DU Commission ${num} times
    log to console    DU Commission ${num} times
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    DU Commission ${i}
        Connect to vdu via rest api
        Commission on vdu   du_scf_file_path=${du_scf_file_path}
        sleep    300s
        ${run_status}    run keyword and return status    Wait Until Keyword Succeeds   16m   1m
        ...    Check all cells are on cell on air status on vdu
        Teardown vdu connection
        sleep    30s
        ${alarm_status_du}    run keyword and return status    Check No expected Active Alarm on DU
        ${alarm_status_cu}    run keyword and return status    Check No expected Active Alarm on CU
        ${historical_alarm_status_du}    run keyword and return status    Check No expected Historical Alarm on DU
        ${historical_alarm_status_cu}    run keyword and return status    Check No expected Historical Alarm on CU
        ${alarm_status_active}    Evaluate  ${alarm_status_du} and ${alarm_status_cu}
        ${alarm_status_historical}    Evaluate  ${historical_alarm_status_du} and ${historical_alarm_status_cu}
        ${alarm_status}    Evaluate  ${alarm_status_active} and ${alarm_status_historical}
        ${status}	   Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        ${snapshot_file_du}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect vDU snapshot
        ${snapshot_file_cu}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect vCU snapshot
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=3
        Run Keyword And Ignore error    Teardown vdu connection
    END
    [teardown]    Run Keyword And Ignore error    Teardown vdu connection

### reset DU ####
DU reset ${num} times
    log to console    DU reset ${num} times
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    DU reset ${i}
        Connect to vdu via rest api
        Reset vDU
        sleep    300s
        ${run_status}    run keyword and return status    Wait Until Keyword Succeeds   16m   1m
        ...    Check all cells are on cell on air status on vdu
        Teardown vdu connection
        sleep    30s
        ${alarm_status_du}    run keyword and return status    Check No expected Active Alarm on DU
        ${alarm_status_cu}    run keyword and return status    Check No expected Active Alarm on CU
        ${historical_alarm_status_du}    run keyword and return status    Check No expected Historical Alarm on DU
        ${historical_alarm_status_cu}    run keyword and return status    Check No expected Historical Alarm on CU
        ${alarm_status_active}    Evaluate  ${alarm_status_du} and ${alarm_status_cu}
        ${alarm_status_historical}    Evaluate  ${historical_alarm_status_du} and ${historical_alarm_status_cu}
        ${alarm_status}    Evaluate  ${alarm_status_active} and ${alarm_status_historical}
        ${status}	   Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        ${snapshot_file_du}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect vDU snapshot
        ${snapshot_file_cu}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect vCU snapshot
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=3
        Run Keyword And Ignore error    Teardown vdu connection
    END
    [teardown]    Run Keyword And Ignore error    Teardown vdu connection



### CU Commission ####
CU Commission ${num} times
    log to console    CU Commission ${num} times
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    CU Commission ${i}
        Connect to vcu via rest api
        Commission on vcu   cu_scf_file_path=${cu_scf_file_path}
        sleep    60s
        ${run_status}    run keyword and return status    Wait Until Keyword Succeeds   16m   1m
        ...    Check all cells are on cell on air status on vcu
        Teardown vcu connection
        sleep    300s
        ${alarm_status_du}    run keyword and return status    Check No expected Active Alarm on DU
        ${alarm_status_cu}    run keyword and return status    Check No expected Active Alarm on CU
        ${historical_alarm_status_du}    run keyword and return status    Check No expected Historical Alarm on DU
        ${historical_alarm_status_cu}    run keyword and return status    Check No expected Historical Alarm on CU
        ${alarm_status_active}    Evaluate  ${alarm_status_du} and ${alarm_status_cu}
        ${alarm_status_historical}    Evaluate  ${historical_alarm_status_du} and ${historical_alarm_status_cu}
        ${alarm_status}    Evaluate  ${alarm_status_active} and ${alarm_status_historical}
        ${status}	   Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        ${snapshot_file_du}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect vDU snapshot
        ${snapshot_file_cu}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect vCU snapshot
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=3
        Run Keyword And Ignore error    Teardown vcu connection
    END
    [teardown]    Run Keyword And Ignore error    Teardown vcu connection

### CU reset ####
CU reset ${num} times
    log to console    CU reset ${num} times
    @{result_list}    create list
    FOR   ${i}   IN RANGE   ${num}
        log to console    CU reset ${i}
        Connect to vcu via rest api
        Reset vCU
        sleep    60s
        ${run_status}    run keyword and return status    Wait Until Keyword Succeeds   16m   1m
        ...    Check all cells are on cell on air status on vcu
        Teardown vcu connection
        sleep    300s
        ${alarm_status_du}    run keyword and return status    Check No expected Active Alarm on DU
        ${alarm_status_cu}    run keyword and return status    Check No expected Active Alarm on CU
        ${historical_alarm_status_du}    run keyword and return status    Check No expected Historical Alarm on DU
        ${historical_alarm_status_cu}    run keyword and return status    Check No expected Historical Alarm on CU
        ${alarm_status_active}    Evaluate  ${alarm_status_du} and ${alarm_status_cu}
        ${alarm_status_historical}    Evaluate  ${historical_alarm_status_du} and ${historical_alarm_status_cu}
        ${alarm_status}    Evaluate  ${alarm_status_active} and ${alarm_status_historical}
        ${status}	   Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
        RUN KEYWORD AND CONTINUE ON FAILURE     Should Be Equal    ${status}    pass
        ${snapshot_file_du}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect vDU snapshot
        ${snapshot_file_cu}    Run Keyword If    '${status}'=='fail'
        ...    Run Keyword And Ignore error    Collect vCU snapshot
        Append To List    ${result_list}    ${status}
        ${fail_num}     Collections.Count Values In List   ${result_list}     fail
        BuiltIn.Exit For Loop If     ${fail_num}>=3
        Run Keyword And Ignore error    Teardown vcu connection
    END
    [teardown]    Run Keyword And Ignore error    Teardown vcu connection