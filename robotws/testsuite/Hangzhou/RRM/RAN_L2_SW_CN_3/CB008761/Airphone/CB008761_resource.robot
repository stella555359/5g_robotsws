*** Settings ***
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot


Documentation
...     CB008761 resource

*** Keywords ***
Check Training Status
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
    ${Train_Status_Res}=     TAF_ADMIN.Get Parameter By Distname     dist_name=MRBTS-1/NRBTS-1/NRDU-1    parameter_list=@{parameter_list}
    ...    connection=${alias}    timeout=30
    ${Train_Status}    Evaluate    ${Train_Status_Res}[0].get('parameters').get('mlScellActParamSet1')[0].get('mlTrainingState')
    Should Be True    "${Train_Status}"=="Training"
    Log To Console    ${Train_Status}
    TAF_ADMIN.teardown    connection=${alias}

Check Trained Status
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
    ${Train_Status_Res}=     TAF_ADMIN.Get Parameter By Distname     dist_name=MRBTS-1/NRBTS-1/NRDU-1    parameter_list=@{parameter_list}
    ...    connection=${alias}    timeout=30
    ${Train_Status}    Evaluate    ${Train_Status_Res}[0].get('parameters').get('mlScellActParamSet1')[0].get('mlTrainingState')
    Should Be True    "${Train_Status}"=="Trained"
    Log To Console    ${Train_Status}
    TAF_ADMIN.teardown    connection=${alias}

Check Idle Status
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
    ${Train_Status_Res}=     TAF_ADMIN.Get Parameter By Distname     dist_name=MRBTS-1/NRBTS-1/NRDU-1    parameter_list=@{parameter_list}
    ...    connection=${alias}    timeout=30
    ${Train_Status}    Evaluate    ${Train_Status_Res}[0].get('parameters').get('mlScellActParamSet1')[0].get('mlTrainingState')
    Should Be True    "${Train_Status}"=="Idle"
    Log To Console    ${Train_Status}
    TAF_ADMIN.teardown    connection=${alias}

Modify Training Period
    [Arguments]     ${gnb_ip}=192.168.255.1
    ${path}    Get Training Config File From GNB    ${TEST_LOG_DIRECTORY()}   ${gnb_ip}
    Modify Training Config Json File    ${path}    ${PERIOD_LIST}
    Send Training Conifg File To GNB    ${path}    ${gnb_ip}

Modify actMLScellAct false
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    Perform online change value    MRBTS-1/NRBTS-1/NRDU-1   actMLScellAct    false    online
    TAF_ADMIN.teardown admin    connection=online

Modify actMLScellAct true
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    Perform online change value    MRBTS-1/NRBTS-1/NRDU-1   actMLScellAct    true    online
    TAF_ADMIN.teardown admin    connection=online

Get Training Config File From GNB
    [Arguments]    ${save_dir}    ${gnb_ip}=192.168.255.1
    OperatingSystem.Run
    ...    sshpass -p oZPS0POrRieRtu scp toor4nsn@${gnb_ip}:/${PERIOD_CONFIG_FOLDER}/SCellActivationTrainingConfiguration.json ${save_dir}
    OperatingSystem.Should Exist    ${save_dir}/SCellActivationTrainingConfiguration.json
    ${path}    Set Variable    ${save_dir}/SCellActivationTrainingConfiguration.json
    [Return]    ${path}

Send Training Conifg File To GNB
    [Arguments]    ${path}    ${gnb_ip}=192.168.255.1
    ${floder}=    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'cd ${PERIOD_CONFIG_FOLDER} && pwd' 2>/dev/null
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p oZPS0POrRieRtu scp ${path} 'toor4nsn@${gnb_ip}:/${floder}'
    Should Be Equal As Integers    ${rc}    0

Modify Training Config Json File
    [Arguments]    ${path}    ${periods}=${PERIOD_LIST}
    ${content}    OperatingSystem.Get File    ${path}
    FOR    ${period_item}    IN    @{periods}
       ${patt}    Set Variable     "${period_item.name}":\\s*\\{\\s*"hours":\\s*(\\d+),\\s*"minutes":\\s*(\\d+)\\s*\\}
       ${value}=    Set Variable    "${period_item.name}": {\n"hours":${period_item.hours},\n"minutes": ${period_item.minutes}\n}
       ${matches}    String.Get Regexp Matches    ${content}    ${patt}
       ${content}=    String.Replace String Using Regexp
       ...    string=${content}
       ...    pattern=${patt}
       ...    replace_with=${value}
    END
    OperatingSystem.Create File    path=${path}    content=${content}

Get GNB Time And Get Hours
    ${gnb_date}=    Get BTS Date Using Cmd
    ${time}    String.Get Regexp Matches    ${gnb_date}    (?P<hours>\\d{2}):(?P<minutes>\\d{2}):(\\d{2})\.(\\d{3})    hours    minutes
    ${hours}    Set Variable    ${time}[0][0]
    ${minutes}    Set Variable    ${time}[0][1]
    Log To Console    Hour: ${hours} minutes: ${minutes}
    ${minutes}=    Convert To Integer     ${minutes}
    ${hours}=    Convert To Integer     ${hours}
    ${hours1}=    Evaluate    ${hours}+1
    ${hours2}=    Evaluate    ${hours}+2
    ${hours}    Set Variable If    ${minutes}>=40    ${hours2}    ${hours1}
    Log To Console    Hours: ${hours}
    [Return]    ${hours}

Get BTS Date Using Cmd
    ${get_time_cmd}=    Set Variable    echo $(date "+%Y-%m-%d %H:%M:%S").$((`date "+%N"`/1000000))
    ${gnb_date1}=    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 '${get_time_cmd}' 2>/dev/null
    ${gnb_date2}=    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 '${get_time_cmd}' 2>/dev/null
    ${gnb_date}=    Set Variable If    "${gnb_date1}"==""    ${gnb_date2}    ${gnb_date1}
    [Return]       ${gnb_date}

Reboot And Check Onair Again
    Run Keyword And Ignore Error    tak_airphone.Airphone Teardown
    Stop Edaemon Egate
    Reboot Testline Via SSH
    tak_airphone.Airphone Setup
    Wait Until Keyword Succeeds    15min    30s    Verify BTS Is Configured
    ${cfg_path}    Set variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/${WTS_NAME}
    Start Wts And Wait Bts Until Onair    ${cfg_path}

Start SA UE Big DL Traffic Internal
    [Arguments]    ${ue_id}    ${mbps}    ${pdu_id}=1    ${trf_id}=1
    [Documentation]    This keyword is to start single UE big dl udp traffic which more than 175.
    ${dl_times}    Evaluate    int(${mbps}/${175})
    FOR    ${t_time}    IN RANGE    1    ${dl_times}+1
        ${tmp_trf_id}    Evaluate    ${trf_id}+${t_time}-1
        Airphone SA Start Data Traffic    ${ue_id}   DL   175M   pdu_id=${pdu_id}   duration=3600   trf_id=${tmp_trf_id}
        Log To Console    \nUE${ue_id} Start DL 175M Traffic for trf_id=${tmp_trf_id}
    END
    ${last_mbps}    Evaluate    ${mbps}-${175}*${dl_times}
    ${last_trf_id}    Evaluate    ${trf_id}+${dl_times}
    Run Keyword If    '${last_mbps}'!='0'    Airphone SA Start Data Traffic
    ...    ${ue_id}   DL   ${last_mbps}M   pdu_id=1   duration=3600   trf_id=${last_trf_id}
    Run Keyword If    '${last_mbps}'!='0'    Log To Console    \nUE${ue_id} Start DL ${last_mbps}M Traffic for trf_id=${last_trf_id}

Send A1 report
    [Arguments]    ${ue_id}    ${srsrp_nr}=70    ${phycell_id}=50    ${meas_id}=1
    [Documentation]    This keyword is to trigger A1 scell added.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | the id of ue |
    ...    | srsrp_nr | Yes | the value of srsrp_nr |
    ...    | phycell_id | Yes | phycell id of the cell |
    ...
    ...    Examples:
    ...    | Send A1 report | 1 | 70 | 50 |
    Airphone Execute Egate Command
    ...    ue_measurement_send_nr id\=${ue_id} meas_id\=${meas_id} event\=A1 srsrp_nr\=${srsrp_nr} phycell_id\=${phycell_id}

Download ml_data
    TAF_SSH.connect to    192.168.255.1   ${GNB_USERNAME}    ${GNB_PASSWORD}   alias=gnb
    ${vpath}    Set Variable    /ffs/run/ml_data/*
    ${vpath1}    Set Variable    /ffs/run/ml_data/ml_data.tgz
    ${ret}    TAF_SSH.execute    ls /ffs/run/ml_data    connection=gnb
    ${ret}    TAF_SSH.execute    tar zcvf /ffs/run/ml_data/ml_data.tgz ${vpath}    connection=gnb
    ${cmd}=    Set Variable    sshpass -p ${GNB_PASSWORD} scp ${GNB_USERNAME}@${GNB_IP}:${vpath1} ${test_log_directory()}${/}All${/}
    OperatingSystem.Run    ${cmd}

Get cell${cell_id} inference status available
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=oam
    ${dist_parameters}    TAF_ADMIN.Get Parameter By Distname     dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}
    ...    connection=oam    timeout=30
    ${InferenceState}    Set Variable    ${dist_parameters[0]['parameters']['mlScellActParamSet2']}
    ${State}    Set Variable    ${InferenceState[0]['mlInferenceState']}
    Should Be True    "${State}"=="available"
    Log To Console    NRCELL-${cell_id} ${State}
    [Teardown]    TAF_ADMIN.teardown    connection=oam

Get cell${cell_id} inference status unavailable
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=oam
    ${dist_parameters}    TAF_ADMIN.Get Parameter By Distname     dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}
    ...    connection=oam    timeout=30
    ${InferenceState}    Set Variable    ${dist_parameters[0]['parameters']['mlScellActParamSet2']}
    ${State}    Set Variable    ${InferenceState[0]['mlInferenceState']}
    Should Be True    "${State}"=="unavailable"
    Log To Console    NRCELL-${cell_id} ${State}
    [Teardown]    TAF_ADMIN.teardown    connection=oam

Get Cell PM Counters Latest Values With Admin
    [Arguments]    ${cell_id}    ${MO_name}    ${counter_ids_list}    ${bts_id}=1
    [Documentation]    This keyword is to get the latest counter value for multi cell pm counter.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${cell_id} | YES | cell_id, such as 1,2,3... |
    ...    | ${MO_name} | Yes | the mo name for the pm counters, such as NLRLC, LTEMG, NRPMQAP-1/HRLCQ  |
    ...    | ${counter_ids_list} | yes | a list for pm counter id in same MO |
    ...
    ...    | Return | a dict with counter_id and the latest value |
    ...
    ...    Examples:
    ...    | ${cell_id} |  | 2 |
    ...    | ${MO_name} |  | LTEMG |
    ...    | @{test_counter_list} |  | M55136C00001 | M55136C00002 | M55136C00003 | M55136C00004 | M55136C00005 |
    ...    | ${counter_value_dict} | Get Cell PM Counters Latest Values With Admin | ${cell_id} |
    ...    | ... |  | ${MO_name} | ${counter_ids_list} |
    ...    | ${MO_name_2} |  | NRPMQAP-1/HRLCQ |
    ...    | @{test_counter_list_2} |  | M55353C00001 |
    ...    | ${counter_value_dict} | Get Cell PM Counters Latest Values With Admin | ${cell_id} |
    ...    | ... |  | ${MO_name_2} | ${test_counter_list_2} |
    ...
    ${counter_ids}    Evaluate    ','.join(${counter_ids_list})
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=oam
    ${counter_dict}    TAF_ADMIN.Get Pm Counters    ${counter_ids}    timeout=2min    connection=oam
    ${counter_id_value_dict}    _Get Counter From Counter Dictionary    ${counter_dict}    ${cell_id}
    ...    ${MO_name}    ${counter_ids_list}   ${bts_id}
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
    [Return]    ${counter_id_value_dict}

_Get Counter From Counter Dictionary
    [Arguments]    ${counter_dict}    ${cell_id}    ${MO_name}    ${counter_ids_list}    ${bts_id}=1
    ${counter_id_value_dict}    Create Dictionary
    ${mo_list}    Split String    ${MO_name}    /
    ${status}    ${value}    Run Keyword And Ignore Error    Evaluate    &{counter_dict}['BTS']['CELLS']['NRCELL-${cell_id}']
    ${counter_dict}    Run Keyword If    '${status}'=='PASS'
    ...    Set Variable    ${counter_dict['BTS']['CELLS']['NRCELL-${cell_id}']}
    ...    ELSE IF    '${status}'=='FAIL'    Set Variable    ${counter_dict['BTS']['MRBTS-1']['NRBTS-${bts_id}']['NRCELL-${cell_id}']}
    ${type}    Evaluate    type(${counter_dict})
    FOR    ${node}    IN    @{mo_list}
        ${counter_dict}    Get From Dictionary    ${counter_dict}    ${node}
    END
    FOR    ${counter_id}    IN    @{counter_ids_list}
        ${counter_value_dict}    Get From Dictionary    ${counter_dict}    ${counter_id}
        ${counter_value_list}    Get Dictionary Values    ${counter_value_dict}
        Set To Dictionary    ${counter_id_value_dict}    ${counter_id}    ${counter_value_list[-1]}
    END
    [Return]    ${counter_id_value_dict}

Get Multi Cells Multi PM Counters Latest Values With Admin
    [Arguments]    ${counter_info_list}    ${bts_id}=1
    [Documentation]    This keyword is to get the latest counter value for multi cell multi same pm counters.
    ...                    Setup admin once in this keyword.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_info_list} | YES | a list for counter info, the element should be include cell_id, MO_name and counter_ids_list |
    ...
    ...    | Return | a dict with counter_id and the latest value |
    ...
    ...    Examples:
    ...    | @{test_counter_list} |  | M55136C00001 | M55136C00002 | M55136C00003 | M55136C00004 | M55136C00005 |
    ...    | &{counter_info_1} |  | cell_id=1 | MO_name=LTEMG | counter_ids_list=${test_counter_list} |
    ...    | &{counter_info_2} |  | cell_id=2 | MO_name=LTEMG | counter_ids_list=${test_counter_list} |
    ...    | &{counter_info_3} |  | cell_id=3 | MO_name=LTEMG | counter_ids_list=${test_counter_list} |
    ...    | @{counter_info_list} |  | ${counter_info_1} | ${counter_info_2} | ${counter_info_3} |
    ...    | ${counter_value_dict} | Get Multi Cells Same Mo Multi PM Counters Latest Values With Admin | ${counter_info_list} |
    ...    | Should be True | ${counter_value_dict.Cell1.M55136C00001}>1
    Sleep    20s
    ${counter_value_dict}    Create Dictionary
    ${counter_ids}    Evaluate    ','.join(${counter_info_list[0].counter_ids_list})
    ${counter_id_value_dict}    Create Dictionary
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=oam
    ${counter_dict}    TAF_ADMIN.Get Pm Counters    ${counter_ids}    timeout=5min    connection=oam
    FOR    ${counter_info}    IN    @{counter_info_list}
        ${counter_id_value_dict}    _Get Counter From Counter Dictionary    ${counter_dict}    ${counter_info.cell_id}
        ...    ${counter_info.MO_name}    ${counter_info.counter_ids_list}    ${bts_id}
        Set To Dictionary    ${counter_value_dict}    cell${counter_info.cell_id}    ${counter_id_value_dict}
    END
    [Return]    ${counter_value_dict}

Get Multi Cells Multi PM Counters Max Values With Admin
    [Arguments]    ${counter_info_list}    ${bts_id}=1
    [Documentation]    This keyword is to get the latest counter value for multi cell multi same pm counters.
    ...                    Setup admin once in this keyword.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_info_list} | YES | a list for counter info, the element should be include cell_id, MO_name and counter_ids_list |
    ...
    ...    | Return | a dict with counter_id and the latest value |
    ...
    ...    Examples:
    ...    | @{test_counter_list} |  | M55136C00001 | M55136C00002 | M55136C00003 | M55136C00004 | M55136C00005 |
    ...    | &{counter_info_1} |  | cell_id=1 | MO_name=LTEMG | counter_ids_list=${test_counter_list} |
    ...    | &{counter_info_2} |  | cell_id=2 | MO_name=LTEMG | counter_ids_list=${test_counter_list} |
    ...    | &{counter_info_3} |  | cell_id=3 | MO_name=LTEMG | counter_ids_list=${test_counter_list} |
    ...    | @{counter_info_list} |  | ${counter_info_1} | ${counter_info_2} | ${counter_info_3} |
    ...    | ${counter_value_dict} | Get Multi Cells Same Mo Multi PM Counters Latest Values With Admin | ${counter_info_list} |
    ...    | Should be True | ${counter_value_dict.Cell1.M55136C00001}>1
    Sleep    20s
    ${counter_value_dict}    Create Dictionary
    ${counter_ids}    Evaluate    ','.join(${counter_info_list[0].counter_ids_list})
    ${counter_id_value_dict}    Create Dictionary
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=oam
    ${counter_dict}    TAF_ADMIN.Get Pm Counters    ${counter_ids}    timeout=5min    connection=oam
    FOR    ${counter_info}    IN    @{counter_info_list}
        ${counter_id_value_dict}    _Get Max Counter From Counter Dictionary    ${counter_dict}    ${counter_info.cell_id}
        ...    ${counter_info.MO_name}    ${counter_info.counter_ids_list}    ${bts_id}
        Set To Dictionary    ${counter_value_dict}    cell${counter_info.cell_id}    ${counter_id_value_dict}
    END
    [Return]    ${counter_value_dict}

_Get Max Counter From Counter Dictionary
    [Arguments]    ${counter_dict}    ${cell_id}    ${MO_name}    ${counter_ids_list}    ${bts_id}=1
    ${counter_id_value_dict}    Create Dictionary
    ${mo_list}    Split String    ${MO_name}    /
    ${status}    ${value}    Run Keyword And Ignore Error    Evaluate    &{counter_dict}['BTS']['CELLS']['NRCELL-${cell_id}']
    ${counter_dict}    Run Keyword If    '${status}'=='PASS'
    ...    Set Variable    ${counter_dict['BTS']['CELLS']['NRCELL-${cell_id}']}
    ...    ELSE IF    '${status}'=='FAIL'    Set Variable    ${counter_dict['BTS']['MRBTS-1']['NRBTS-${bts_id}']['NRCELL-${cell_id}']}
    ${type}    Evaluate    type(${counter_dict})
    FOR    ${node}    IN    @{mo_list}
        ${counter_dict}    Get From Dictionary    ${counter_dict}    ${node}
    END
    FOR    ${counter_id}    IN    @{counter_ids_list}
        ${counter_value_dict}    Get From Dictionary    ${counter_dict}    ${counter_id}
        ${counter_value_list}    Get Dictionary Values    ${counter_value_dict}
        ${max_counter_value}    Evaluate    max(${counter_value_list})
        Set To Dictionary    ${counter_id_value_dict}    ${counter_id}    ${max_counter_value}
    END
    [Return]    ${counter_id_value_dict}


Wait Until PM Counter Update
    [Arguments]    ${counter_refresh_period}=5min    ${period_times}=0
    [Documentation]    This keyword is to calcute the wait time to get needed pm counter
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_refresh_period} | No | refresh period time for counter. the default value is 5min |
    ...    | ${period_times} | No | the number which counter need to get. the default value is 0 to get current counter |
    ...                          | 1 means to get next counter , and so on |
    ...
    ...    Examples:
    ...    | Wait PM Counter display | 5min | 1 |
    ${time}=    tak_gnb.Get Counter File Remaining Time    counter_refresh_period=${counter_refresh_period}
    ${time_to_sec}    Convert Time    ${counter_refresh_period}
    ${wait_time}    Evaluate   ${time}+${period_times}*int(${time_to_sec})
    Sleep    ${wait_time}    reason=wait until PM counter update

Stop Edaemon Egate
    OperatingSystem.Run    sudo pkill edaemon
    OperatingSystem.Run    sudo pkill egate
    OperatingSystem.Run    sudo pkill 22222
    OperatingSystem.Run    sudo pkill 20000
