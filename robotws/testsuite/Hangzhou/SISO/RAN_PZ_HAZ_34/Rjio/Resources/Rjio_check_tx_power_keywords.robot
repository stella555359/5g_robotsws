*** Settings ***
Documentation    This is for RJIO E2E Keywords
...              Author: Gao melinda
...              Contact: melinda.gao@nokia-sbell.com
...              squad: 5G_PZ_HZ_8_SG


*** Variables ***
${power}        -([1-9]\d*\.\d*|0\.\d*[1-9]\d*)
${AQQJ_power_inf}        -inf.*-inf.*-inf.*-inf.*-inf.*-inf.*-inf.*-inf.*\n-inf.*-inf.*-inf.*-inf.*-inf.*-inf.*-inf.*-inf.*
${inf}    -inf.*-inf.*-inf.*-inf.*-inf.*-inf.*-inf.*-inf.*-inf.*-inf.*-inf.*-inf.*-inf.*-inf.*-inf.*-inf.*
${AEQZ_power_inf}        ${inf}\n${inf}
*** Keywords ***
AEQZ madeTx Power not include inf
    [Arguments]    ${power}    ${made_index1}    ${made_index2}    ${ru_index}=${2}    ${asik_alias}=ASIK Master
    ${RU_Type}   Get RU type
    connect to common unit master    alias=${asik_alias}
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
    log to console    connect ${RU_type} RU successful
    csn.Send Command    command=which sudo    connection=RU_${ru_index}
    Sleep    10s
    ${sudo}  csn.Read Output    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \n    ${EMPTY}
    csn.Send Command    command=ssh 192.168.101.${made_index1} ${sudo} dapd -sq | tail -n 5 | head -n 2
    ...    connection=RU_${ru_index}
    Sleep    90s
    ${RU_object2}  csn.Read Output    connection=RU_${ru_index}
    csn.Send Command    command=ssh 192.168.101.${made_index2} ${sudo} dapd -sq | tail -n 5 | head -n 2
    ...    connection=RU_${ru_index}
    Sleep    90s
    ${RU_object4}  csn.Read Output    connection=RU_${ru_index}
    Should Match Regexp     ${RU_object2}     ${power}    msg=${RU_type} Tx power value verify failed, please check
    Should Not Contain Any    ${RU_object2}    -inf    ignore_case=True
    Should Match Regexp     ${RU_object4}     ${power}    msg=${RU_type} Tx power value verify failed, please check
    Should Not Contain Any    ${RU_object4}    -inf    ignore_case=True
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    csn.Disconnect   connection=RU_${ru_index}
    ...    AND    Run Keyword And Ignore Error     csn.Disconnect   connection=${asik_alias}

AEQZ made Tx Power only include inf
    [Arguments]    ${power}    ${made_index1}    ${made_index2}    ${ru_index}=${2}    ${asik_alias}=ASIK Master
    ${RU_Type}   Get RU type
    ${cmd}    Set variable    dapd -sq | tail -n 5 | head -n 2 | awk '{print $3,$4,$6,$7,$9,$10,$12,$13,$15,$16,$18,$19,$21,$22,$24,$25}'
    connect to common unit master    alias=${asik_alias}
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
    log to console    connect ${RU_type} RU successful
    csn.Send Command    command=which sudo    connection=RU_${ru_index}
    Sleep    10s
    ${sudo}  csn.Read Output    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \n    ${EMPTY}
    csn.Send Command    command=ssh 192.168.101.${made_index1} ${sudo} ${cmd}
    ...    connection=RU_${ru_index}
    Sleep    90s
    ${RU_object3}  csn.Read Output    connection=RU_${ru_index}
    csn.Send Command    command=ssh 192.168.101.${made_index2} ${sudo} ${cmd}
    ...    connection=RU_${ru_index}
    Sleep    90s
    ${RU_object5}  csn.Read Output    connection=RU_${ru_index}
    Should Match Regexp     ${RU_object3}     ${power}    msg=${RU_type} Tx power value verify failed, please check
    Should Match Regexp     ${RU_object5}     ${power}    msg=${RU_type} Tx power value verify failed, please check
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    csn.Disconnect   connection=RU_${ru_index}
    ...    AND    Run Keyword And Ignore Error     csn.Disconnect   connection=${asik_alias}

call_RJIO_AEQZ_and_check_energysaving_status
    [Arguments]    ${tput_info}    ${made35_power}    ${target_avg_percent}=${0.5}    ${min_percent}=${0.4}    ${CRT_flag}=${False}
    [Documentation]    PA1: 10.71.204.123
    ...                PA2: 10.71.204.118
    Run Keyword And Ignore Error    Precondition for MTK    ue_index=${2}    reboot_ue=${True}
    log to console    +++ set PA2 port13-14 to 10,port 8/11/12 to 127 and call for AEQZ TDD cell62 +++
    Set PA Value For Pointed Port    PA_Port_List=${PA2_Port_list_13_14}    attenuator_index=${3}    value=${10}
    Set PA Value For Pointed Port    PA_Port_List=${PA_Port_list_8_11_12}    attenuator_index=${3}    value=${127}
    log to console    +++ set PA 10.71.204.118 port 1/3/4/7 to 30, for call TDD cell61 +++
    Set PA Value For Pointed Port    PA_Port_List=${PA2_Port_list_1_3_4_7}    attenuator_index=${3}    value=${30}
    log to console    start traffic...
    ${cell_list}    Set Variable If    ${CRT_flag}==${True}    ${cell_id62}    ${cell_id61_62}
	FOR  ${cell_id}  IN  @{cell_list}
        ${ui_version}    Set Variable    ${tput_info[${cell_id}]['ui_version']}
        ${ue_index}    Set Variable    ${tput_info[${cell_id}]['ue_index']}
        data_transfer_KPI    tput_info=${tput_info}    cell_id=${cell_id}     duration_call=${1800}    ue_index=${ue_index}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    duration=${120}    tput_from=self_define
        ...    ui_version=${ui_version}
        collect_check_tput    duration=${60}    cell_id=${cell_id}    target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
        AEQZ madeTx Power not include inf    power=${power}    made_index1=2    made_index2=4
        run keyword if     ${made35_power}==${True}
        ...    AEQZ madeTx Power not include inf    power=${power}    made_index1=3    made_index2=5
#        ...    ELSE    AEQZ made Tx Power only include inf    power=${AEQZ_power_inf}    made_index1=3    made_index2=5
        detach_UE_stop_traffic    ue_index=${ue_index}
    END

AQQJ 2-5 made Tx Power not include inf
    [Arguments]    ${power}    ${idx}=5   ${ru_index}=${2}    ${asik_alias}=ASIK Master
    ${RU_Type}   Get RU type
    connect to common unit master    alias=${asik_alias}
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
    log to console    connect ${RU_type} RU successful
    csn.Send Command    command=which sudo    connection=RU_${ru_index}
    Sleep    10s
    ${sudo}  csn.Read Output    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \n    ${EMPTY}
    csn.Send Command    command=ssh 192.168.101.2 ${sudo} dapd -sq | tail -n ${idx} | head -n 2
    ...    connection=RU_${ru_index}
    Sleep    100s
    ${RU_object2}  csn.Read Output    connection=RU_${ru_index}
    csn.Send Command    command=ssh 192.168.101.3 ${sudo} dapd -sq | tail -n ${idx} | head -n 2
    ...    connection=RU_${ru_index}
    Sleep    100s
    ${RU_object3}  csn.Read Output    connection=RU_${ru_index}
    csn.Send Command    command=ssh 192.168.101.4 ${sudo} dapd -sq | tail -n ${idx} | head -n 2
    ...    connection=RU_${ru_index}
    Sleep    100s
    ${RU_object4}  csn.Read Output    connection=RU_${ru_index}
    csn.Send Command    command=ssh 192.168.101.5 ${sudo} dapd -sq | tail -n ${idx} | head -n 2
    ...    connection=RU_${ru_index}
    Sleep    100s
    ${RU_object5}  csn.Read Output    connection=RU_${ru_index}
    Should Match Regexp     ${RU_object2}     ${power}    msg=${RU_type} Tx power value verify failed, please check
    Should Not Contain Any    ${RU_object2}    -inf    ignore_case=True
    Should Match Regexp     ${RU_object3}     ${power}    msg=${RU_type} Tx power value verify failed, please check
    Should Not Contain Any    ${RU_object3}    -inf    ignore_case=True
    Should Match Regexp     ${RU_object4}     ${power}    msg=${RU_type} Tx power value verify failed, please check
    Should Not Contain Any    ${RU_object4}    -inf    ignore_case=True
    Should Match Regexp     ${RU_object5}     ${power}    msg=${RU_type} Tx power value verify failed, please check
    Should Not Contain Any    ${RU_object5}    -inf    ignore_case=True
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    csn.Disconnect   connection=RU_${ru_index}
    ...    AND    Run Keyword And Ignore Error     csn.Disconnect   connection=${asik_alias}

AQQJ 6-9 made Tx Power not include inf
    [Arguments]    ${power}    ${idx}=5    ${ru_index}=${2}    ${asik_alias}=ASIK Master
    ${RU_Type}   Get RU type
    connect to common unit master    alias=${asik_alias}
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
    log to console    connect ${RU_type} RU successful
    csn.Send Command    command=which sudo    connection=RU_${ru_index}
    Sleep    10s
    ${sudo}  csn.Read Output    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \n    ${EMPTY}
    csn.Send Command    command=ssh 192.168.101.6 ${sudo} dapd -sq | tail -n ${idx} | head -n 2
    ...    connection=RU_${ru_index}
    Sleep    100s
    ${RU_object6}  csn.Read Output    connection=RU_${ru_index}
    csn.Send Command    command=ssh 192.168.101.7 ${sudo} dapd -sq | tail -n ${idx} | head -n 2
    ...    connection=RU_${ru_index}
    Sleep    100s
    ${RU_object7}  csn.Read Output    connection=RU_${ru_index}
    csn.Send Command    command=ssh 192.168.101.8 ${sudo} dapd -sq | tail -n ${idx} | head -n 2
    ...    connection=RU_${ru_index}
    Sleep    100s
    ${RU_object8}  csn.Read Output    connection=RU_${ru_index}
    csn.Send Command    command=ssh 192.168.101.9 ${sudo} dapd -sq | tail -n ${idx} | head -n 2
    ...    connection=RU_${ru_index}
    Sleep    100s
    ${RU_object9}  csn.Read Output    connection=RU_${ru_index}
    Should Match Regexp     ${RU_object6}     ${power}    msg=${RU_type} Tx power value verify failed, please check
    Should Not Contain Any    ${RU_object6}    -inf    ignore_case=True
    Should Match Regexp     ${RU_object7}     ${power}    msg=${RU_type} Tx power value verify failed, please check
    Should Not Contain Any    ${RU_object7}    -inf    ignore_case=True
    Should Match Regexp     ${RU_object8}     ${power}    msg=${RU_type} Tx power value verify failed, please check
    Should Not Contain Any    ${RU_object8}    -inf    ignore_case=True
    Should Match Regexp     ${RU_object9}     ${power}    msg=${RU_type} Tx power value verify failed, please check
    Should Not Contain Any    ${RU_object9}    -inf    ignore_case=True
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    csn.Disconnect   connection=RU_${ru_index}
    ...    AND    Run Keyword And Ignore Error     csn.Disconnect   connection=${asik_alias}

AQQJ 6-9 made Tx Power only include inf
    [Arguments]    ${power}    ${idx}=5    ${ru_index}=${2}    ${asik_alias}=ASIK Master
    ${RU_Type}   Get RU type
    connect to common unit master    alias=${asik_alias}
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
    log to console    connect ${RU_type} RU successful
    csn.Send Command    command=which sudo    connection=RU_${ru_index}
    Sleep    10s
    ${sudo}  csn.Read Output    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \n    ${EMPTY}
    csn.Send Command    command=ssh 192.168.101.6 ${sudo} dapd -sq | tail -n ${idx} | head -n 2 | awk '{print $3,$4,$6,$7,$9,$10,$12,$13}'
    ...    connection=RU_${ru_index}
    Sleep    100s
    ${RU_object6}  csn.Read Output    connection=RU_${ru_index}
    csn.Send Command    command=ssh 192.168.101.7 ${sudo} dapd -sq | tail -n ${idx} | head -n 2 | awk '{print $3,$4,$6,$7,$9,$10,$12,$13}'
    ...    connection=RU_${ru_index}
    Sleep    100s
    ${RU_object7}  csn.Read Output    connection=RU_${ru_index}
    csn.Send Command    command=ssh 192.168.101.8 ${sudo} dapd -sq | tail -n ${idx} | head -n 2 | awk '{print $3,$4,$6,$7,$9,$10,$12,$13}'
    ...    connection=RU_${ru_index}
    Sleep    100s
    ${RU_object8}  csn.Read Output    connection=RU_${ru_index}
    csn.Send Command    command=ssh 192.168.101.9 ${sudo} dapd -sq | tail -n ${idx} | head -n 2 | awk '{print $3,$4,$6,$7,$9,$10,$12,$13}'
    ...    connection=RU_${ru_index}
    Sleep    100s
    ${RU_object9}  csn.Read Output    connection=RU_${ru_index}
    Should Match Regexp     ${RU_object6}     ${power}    msg=${RU_type} Tx power value verify failed, please check
    Should Match Regexp     ${RU_object7}     ${power}    msg=${RU_type} Tx power value verify failed, please check
    Should Match Regexp     ${RU_object8}     ${power}    msg=${RU_type} Tx power value verify failed, please check
    Should Match Regexp     ${RU_object9}     ${power}    msg=${RU_type} Tx power value verify failed, please check
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    csn.Disconnect   connection=RU_${ru_index}
    ...    AND    Run Keyword And Ignore Error     csn.Disconnect   connection=${asik_alias}

call_RJIO_AQQJ_and_check_energysaving_status
    [Arguments]    ${tput_info}    ${made69_power}    ${idx}=5    ${target_avg_percent}=${0.3}    ${min_percent}=${0.3}
    ...    ${cell_id_list}=${cell_id62}
    set matrix PA for TDD cell
    log to console    start traffic on ${cell_id_list}...
    FOR  ${cell_id}  IN  @{cell_id_list}
        ${ui_version}    Set Variable    ${tput_info[${cell_id}]['ui_version']}
        ${ue_index}    Set Variable    ${tput_info[${cell_id}]['ue_index']}
        data_transfer_KPI    tput_info=${tput_info}    cell_id=${cell_id}     duration_call=${1800}    ue_index=${ue_index}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    duration=${120}    tput_from=self_define
        ...    ui_version=${ui_version}
        collect_check_tput    duration=${120}    cell_id=${cell_id}    target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
        AQQJ 2-5 made Tx Power not include inf    power=${power}    idx=${idx}
        run keyword if     ${made69_power}==${True}
        ...    AQQJ 6-9 made Tx Power not include inf    power=${power}    idx=${idx}
        ...    ELSE    AQQJ 6-9 made Tx Power only include inf    power=${AQQJ_power_inf}    idx=${idx}
        detach_UE_stop_traffic    ue_index=${ue_index}
    END