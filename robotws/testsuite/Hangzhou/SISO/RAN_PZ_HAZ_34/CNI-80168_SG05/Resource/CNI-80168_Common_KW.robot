*** Settings ***
Documentation
...    Author:liu yue
...    contact:yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CNI-80168 in SBTS23R1 program

*** Keywords ***
Mute pipe on RU to trigger fault 2292
    [Arguments]   ${ru_index}=1    ${asik_alias}=ASIK Master
    Connect to Common Unit Master    alias=${asik_alias}
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=${asik_alias}
    Connect To Node Via RU Connection    node_id=1    ru_index=${ru_index}
    execute command on specified Node    node_id=1
    csn.Disconnect   connection=node_1
    Connect To Node Via RU Connection    node_id=2    ru_index=${ru_index}
    execute command on specified Node    node_id=2
    csn.Disconnect   connection=node_2
    Connect To Node Via RU Connection    node_id=3    ru_index=${ru_index}
    execute command on specified Node    node_id=3
    csn.Disconnect   connection=node_3
    Connect To Node Via RU Connection    node_id=4    ru_index=${ru_index}
    execute command on specified Node    node_id=4
    csn.Disconnect   connection=node_4
    Connect To Node Via RU Connection    node_id=5    ru_index=${ru_index}
    execute command on specified Node    node_id=5
    csn.Disconnect   connection=node_5
    Connect To Node Via RU Connection    node_id=6    ru_index=${ru_index}
    execute command on specified Node    node_id=6
    csn.Disconnect   connection=node_6
    Connect To Node Via RU Connection    node_id=7    ru_index=${ru_index}
    execute command on specified Node    node_id=7
    csn.Disconnect   connection=node_7
    Connect To Node Via RU Connection    node_id=8    ru_index=${ru_index}
    execute command on specified Node    node_id=8
    csn.Disconnect   connection=node_8
    Connect To Node Via RU Connection    node_id=9    ru_index=${ru_index}
    execute command on specified Node    node_id=9
    csn.Disconnect   connection=node_9
    Connect To Node Via RU Connection    node_id=10    ru_index=${ru_index}
    execute command on specified Node    node_id=10
    csn.Disconnect   connection=node_10
    Connect To Node Via RU Connection    node_id=11    ru_index=${ru_index}
    execute command on specified Node    node_id=11
    csn.Disconnect   connection=node_11
    Connect To Node Via RU Connection    node_id=12    ru_index=${ru_index}
    execute command on specified Node    node_id=12
    csn.Disconnect   connection=node_12
    Connect To Node Via RU Connection    node_id=13    ru_index=${ru_index}
    execute command on specified Node    node_id=13
    csn.Disconnect   connection=node_13
    Connect To Node Via RU Connection    node_id=14    ru_index=${ru_index}
    execute command on specified Node    node_id=14
    csn.Disconnect   connection=node_14
    Connect To Node Via RU Connection    node_id=15    ru_index=${ru_index}
    execute command on specified Node    node_id=15
    csn.Disconnect   connection=node_15
    Connect To Node Via RU Connection    node_id=16    ru_index=${ru_index}
    execute command on specified Node    node_id=16
    csn.Disconnect   connection=node_16
    csn.Disconnect   connection=RU_${ru_index}
    csn.Disconnect   connection=${asik_alias}
    [Teardown]    csn.Reset Cache

Mute pipe on RU to trigger fault 2292 minor
    [Arguments]   ${ru_index}=1    ${asik_alias}=ASIK Master
    Connect to Common Unit Master    alias=${asik_alias}
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=${asik_alias}
    Connect To Node Via RU Connection    node_id=1    ru_index=${ru_index}
    execute command on specified Node    node_id=1
    csn.Disconnect   connection=node_1
    Connect To Node Via RU Connection    node_id=2    ru_index=${ru_index}
    execute command on specified Node    node_id=2
    csn.Disconnect   connection=node_2
    Connect To Node Via RU Connection    node_id=3    ru_index=${ru_index}
    execute command on specified Node    node_id=3
    csn.Disconnect   connection=node_3
    Connect To Node Via RU Connection    node_id=4    ru_index=${ru_index}
    execute command on specified Node    node_id=4
    csn.Disconnect   connection=node_4
    csn.Disconnect   connection=RU_${ru_index}
    csn.Disconnect   connection=${asik_alias}
    [Teardown]    csn.Reset Cache
Get alarm severity
    [Arguments]   ${ru_index}=1
    log to console    Get alarm severity
    connect to common unit master
    sleep   1s
    Connect to RU With Allocated IP    ru_index=${ru_index}
    ${output}    csn.execute    command=ls /run -ll | grep fault_history_log_temp.txt    connection=RU    timeout=60s
    ${file_status}    run keyword and return status    should not be empty    ${output}
    ${filename}    set variable if      ${file_status}    fault_history_log_temp.txt    fault_history_log.txt
    set test variable    ${cmd_active}
    ...    cat /run/${filename} | grep EFaultId_TxBeamformingCalibrationFailed | grep active | wc -l
    set test variable    ${cmd_clear}
    ...    cat /run/${filename} | grep EFaultId_TxBeamformingCalibrationFailed | grep clear | wc -l
    ${output_active_num}    csn.execute    command=${cmd_active}    connection=RU    timeout=60s
    sleep    2s
    ${output_clear_num}    csn.execute    command=${cmd_clear}    connection=RU    timeout=60s
    sleep   1s
    ${output_active_num}    Convert To Integer    ${output_active_num}
    ${output_clear_num}    Convert To Integer    ${output_clear_num}
    ${mute_pipe_num}    evaluate    ${output_active_num}-${output_clear_num}
    ${severity}=    Set Variable If
    ...     4<${mute_pipe_num}<=8    Minor
    ...     ${mute_pipe_num}>=9        Major
    ...    None
    csn.Disconnect   connection=RU
    csn.Disconnect   connection=ASIK Master
    log to console    ${mute_pipe_num}
    [Return]    ${severity}
    [Teardown]    csn.Reset Cache
Connect To Node Via RU Connection
    [Arguments]    ${node_id}    ${node_alias}=node_${node_id}    ${nodes}=${Node}    ${ru_index}=1
    ${nodes_length}    Get Length    ${nodes}
    FOR    ${i}    IN RANGE    0    ${nodes_length}
        ${node_ip}    run keyword if    ${Node[${i}]}[id]==${node_id}    set variable    ${Node[${i}]}[ip]
        Exit For Loop If    '${node_ip}'!='${None}'
    END
    csn.connect to    hostname=${node_ip}
    ...               username=serviceuser
    ...               password=v160rWp/6qpX/RQjmnaupqP+FBV2/f7bgiwMI8+cpEY=
    ...               alias=${node_alias}
    ...               proxy=RU_${ru_index}
execute command on specified Node
    [Arguments]    ${node_id}
    ${sudo}    csn.execute    command=which sudo    connection=node_${node_id}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${cmd_temp}   Set Variable
    ...    ${sudo} /sbin/devmem 0xFB1902FC 32 0
    ${output}  csn.execute  command=${cmd_temp}    connection=node_${node_id}
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    ${sudo} /sbin/devmem 0xFB19037c 32 0x1
    ${output}  csn.execute  command=${cmd_temp}    connection=node_${node_id}
    sleep    3s
    ${cmd_temp}   Set Variable
    ...    ${sudo} /sbin/devmem 0xFB190300 32 0
    ${output}  csn.execute  command=${cmd_temp}    connection=node_${node_id}
    ${cmd_temp}   Set Variable
    ...    ${sudo} /sbin/devmem 0xFB19037c 32 0x2
    ${output}  csn.execute  command=${cmd_temp}    connection=node_${node_id}
    ${cmd_temp}   Set Variable
    ...    ${sudo} /sbin/devmem 0xFB190304 32 0
    ${output}  csn.execute  command=${cmd_temp}    connection=node_${node_id}
    ${cmd_temp}   Set Variable
    ...    ${sudo} /sbin/devmem 0xFB19037c 32 0x4
    ${output}  csn.execute  command=${cmd_temp}    connection=node_${node_id}
    ${cmd_temp}   Set Variable
    ...    ${sudo} /sbin/devmem 0xFB190308 32 0
    ${output}  csn.execute  command=${cmd_temp}    connection=node_${node_id}
    ${cmd_temp}   Set Variable
    ...    ${sudo} /sbin/devmem 0xFB19037c 32 0x8
    ${output}  csn.execute  command=${cmd_temp}    connection=node_${node_id}
    sleep    2s
