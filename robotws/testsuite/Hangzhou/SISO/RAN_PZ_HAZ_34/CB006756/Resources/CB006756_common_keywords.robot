*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_powersaving_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py
Variables    ./variables_CB006756.py

Documentation
...    author: lin jiangjing
...    contact: jiangjing.lin@nokia-sbell.com
...    Group: HGZ_SG8

*** Variables ***
${CB0010471_power}        -([1-9]\d*\.\d*|0\.\d*[1-9]\d*)
${CB0010471_power_inf}        -inf.*-inf.*-inf.*-inf.*-inf.*-inf.*-inf.*-inf.*\n-inf.*-inf.*-inf.*-inf.*-inf.*-inf.*-inf.*-inf.*
@{cell_list_10471}  ${1}
*** Keywords ***
Sigspark_L3call
      [Arguments]    ${ue_index_list}    ${tput_expect}    ${ue_type}=huawei_sigspark    ${duration}=300    ${protocol}=udp
      ...    ${attach_mode}=5G_NSA    ${gnb_index}=${0}    ${du_index}=0    ${iperf_type}=via_command
      ...    ${target_avg_percent}=0.98    ${min_percent}=0.85    ${ifcheck_energysaving}=${False}
      ...    ${power1}=${CB0010471_power}    ${energySavingState}=notEnergySaving    ${made69_power}=${False}
      ${ue_cell_mapping}    create dictionary
      ${ue_tput_mapping}    create dictionary
      FOR    ${ue_index}    IN    @{ue_index_list}
          log to console    \n***Prepare for UE_${ue_index}***
          Wait Until Keyword Succeeds    5min    30s    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
          Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
          Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
          Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2   log_name=5Grach.txt
          log to console    \n***Attach for UE_${ue_index}***
          power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=${attach_mode}
          Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
#          Connect to Common Unit Master
#          ${cell_id}    wait until keyword succeeds   1min    5s    get_ue_attached_cell_id_from_log    log_path=/tmp/5Grach.txt
#          ...    alias=ASIK Master
#          csn.Disconnect  connection=ASIK Master
          sleep  45
          ${cell_id}=   Evaluate    ${ue_index}+1
          log to console    UE_${ue_index} attached to cell ${cell_id}
          set to dictionary    ${ue_cell_mapping}    ${ue_index}    ${cell_id}
          ${ue_mode}    Replace String    ${attach_mode}    5G_    ${EMPTY}
          log to console    \n***Start traffic for UE_${ue_index}***
          ${duration_call}    Evaluate    ${duration}+${600}*2
          ${dl_tp}    set variable    ${tput_expect['${cell_id}']['dl_tp']}
          ${ul_tp}    set variable    ${tput_expect['${cell_id}']['ul_tp']}
          power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    throughput=${dl_tp}/sec
          ...    duration=${duration_call}    protocol=${protocol}    ue_mode=${ue_mode}
          power_ue.Start traffic    ue_type=Samsung    ue_index=${ue_index}    direction=ul    throughput=${ul_tp}
          ...    duration=${duration_call}    protocol=${protocol}    iperf_type=${iperf_type}
      END
      log to console    \n***Start Collect Throughput for UE***
      ${tput_log}    power_ue.Collect Tput    ue_type=Samsung    duration=${duration}
      FOR    ${ue_index}    IN    @{ue_index_list}
          ${cell_id}     Get From Dictionary    ${ue_cell_mapping}     ${ue_index}
          ${dl_exp}    set variable    ${tput_expect['${cell_id}']['dl_exp']}
          ${ul_exp}    set variable    ${tput_expect['${cell_id}']['ul_exp']}
          ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity
          ${cell_id}    Convert To String    ${cell_mapping[${cell_id}]['nrCellIdentity']}
          ${cell_id}    Create List    ${cell_id}
          log to console    \n***Check tput for UE_${ue_index}***
          power_ue.Check Bi Tput    ue_type=huawei    log=${tput_log}    cells=${cell_id}    ultarget_throughput=${ul_exp}
          ...    dltarget_throughput=${dl_exp}   target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
      END
      run keyword if     ${ifcheck_energysaving}==${True}
      ...    check energy saving    power1=${power1}    energySavingState=${energySavingState}    made69_power=${made69_power}
      [Teardown]    run keyword and ignore error    UE detach and stop traffic    ue_index_list=${ue_index_list}    ue_type=${ue_type}

Sigspark_L3call_from_tool
      [Arguments]    ${cell_list}    ${ue_index_list}    ${tput_expect}    ${ue_type}=huawei_sigspark    ${duration}=300    ${protocol}=udp
      ...    ${attach_mode}=5G_NSA    ${gnb_index}=${0}    ${du_index}=0    ${iperf_type}=via_command
      ...    ${target_avg_percent}=0.98    ${min_percent}=0.85    ${ifcheck_energysaving}=${False}
      ...    ${power1}=${CB0010471_power}    ${energySavingState}=notEnergySaving    ${made69_power}=${False}
      ...    ${tput_from}=tool    ${connection}=GNB_OAM
      ${ue_cell_mapping}    create dictionary
      ${ue_tput_mapping}    create dictionary
      ${tput_info_total}    create dictionary
      FOR  ${cell_index}  IN  @{cell_list}
          ${ue_index}    set variable    ${tput_expect[${cell_index}]['ue_index']}
          ${tput_cell}    run keyword if    '${tput_from}'=='tool'    get_tput_info_by_tool
          ...    cell_id=${cell_index}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
          ...    duration=${duration}    connection=${connection}
          log to console    tput info for cell ${cell_index} is: ${tput_cell}
          set to dictionary    ${tput_info_total}    ${cell_index}    ${tput_cell}
          log to console    \n***Prepare for UE_${ue_index}***
          Wait Until Keyword Succeeds    5min    30s    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
          Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
          Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
          Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2   log_name=5Grach.txt
          log to console    \n***Attach for UE_${ue_index}***
          power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=${attach_mode}
          Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
#          Connect to Common Unit Master
#          ${cell_id}    wait until keyword succeeds   1min    5s    get_ue_attached_cell_id_from_log    log_path=/tmp/5Grach.txt
#          ...    alias=ASIK Master
#          csn.Disconnect  connection=ASIK Master
          sleep  45
          ${cell_id}    set variable    ${cell_index}
          log to console    UE_${ue_index} attached to cell ${cell_id}
          set to dictionary    ${ue_cell_mapping}    ${ue_index}    ${cell_id}
          ${ue_mode}    Replace String    ${attach_mode}    5G_    ${EMPTY}
          log to console    \n***Start traffic for UE_${ue_index}***
          ${duration_call}    Evaluate    ${duration}+${600}*2
          ${dl_tp}    set variable    ${tput_expect[${cell_index}]['dl_tp']}
          ${ul_tp}    set variable    ${tput_cell['ul_tp']}
          power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    throughput=${dl_tp}/sec
          ...    duration=${duration_call}    protocol=${protocol}    ue_mode=${ue_mode}
          power_ue.Start traffic    ue_type=Samsung    ue_index=${ue_index}    direction=ul    throughput=${ul_tp}
          ...    duration=${duration_call}    protocol=${protocol}    iperf_type=${iperf_type}
      END
      log to console    \n***Start Collect Throughput for UE***
      ${tput_log}    power_ue.Collect Tput    ue_type=Samsung    duration=${duration}
      FOR    ${ue_index}    IN    @{ue_index_list}
          ${cell_id}     Get From Dictionary    ${ue_cell_mapping}     ${ue_index}
          ${dl_exp}    set variable    ${tput_cell['dl_exp']}
          ${ul_exp}    set variable    ${tput_cell['ul_exp']}
          ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity
          ${cell_id}    Convert To String    ${cell_mapping[${cell_id}]['nrCellIdentity']}
          ${cell_id}    Create List    ${cell_id}
          log to console    \n***Check tput for UE_${ue_index}***
          power_ue.Check Bi Tput    ue_type=huawei    log=${tput_log}    cells=${cell_id}    ultarget_throughput=${ul_exp}
          ...    dltarget_throughput=${dl_exp}   target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
      END
      run keyword if     ${ifcheck_energysaving}==${True}
      ...    check energy saving    power1=${power1}    energySavingState=${energySavingState}    made69_power=${made69_power}
      [Teardown]    run keyword and ignore error    UE detach and stop traffic    ue_index_list=${ue_index_list}    ue_type=${ue_type}



check energy saving
    [Arguments]    ${made69_power}    ${power1}    ${energySavingState}=notEnergySaving
    Check cell EnergySaving state via COAM    expect_energySavingState=${energySavingState}
#    Check cell EnergySaving state via COAM    expect_energySavingState=${energySavingState}    cellID=2
    CB0010471 2-5 made Tx Power not include inf    power=${power1}    idx=5
    run keyword if     ${made69_power}==${True}
    ...    CB0010471 6-9 made Tx Power not include inf    power=${power1}    idx=5
#    ...    ELSE    CB0010471 6-9 made Tx Power only include inf    power=${power2}    idx=5

UE detach and stop traffic
    [Arguments]    ${ue_index_list}    ${ue_type}
    FOR    ${ue_index}    IN    @{ue_index_list}
          log to console    \n***Stop traffic and Detach for UE_${ue_index}***
          run keyword and ignore error  power_ue.Stop traffic   ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
          run keyword and ignore error  power_ue.Stop traffic   ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
          run keyword and ignore error   power_ue.UE Detach   ue_type=${ue_type}    ue_index=${ue_index}
    END

RU_lock_unlock_for_spark
      [Arguments]    ${ue_index_list}    ${tput_expect}    ${ue_type}=huawei_sigspark    ${duration}=30    ${protocol}=udp
      ...    ${attach_mode}=5G_NSA    ${gnb_index}=${0}    ${du_index}=0    ${target_avg_percent}=0.5    ${min_percent}=0.2
      ...    ${connection}=GNB_OAM
      ${ru_index_list}    Get All RU Index
      log to console    *****begin to lock all rus*******
      FOR  ${ru_index}  IN  @{ru_index_list}
          ${cell_id_ru}    Get All Cell Id    ru_index=${ru_index}
          coam.lock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1    timeout=60    connection=${connection}
          sleep  15
          wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${ru_index}
          wait until keyword succeeds    5min    20sec    Cell status Should Be Disabled    cell_list=${cell_id_ru}
      END
      log to console    *****begin to unlock all rus*****
      FOR  ${ru_index}  IN  @{ru_index_list}
          ${cell_id_ru}    Get All Cell Id    ru_index=${ru_index}
          coam.unlock    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1    timeout=${300}    connection=${connection}
          sleep  15
          wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${ru_index}
          wait until keyword succeeds    5min    20sec    Cell status Should Be enabled    cell_list=${cell_id_ru}
      END
      log to console    *****begin to make call under all cells*****
      Sigspark_L3call_from_tool    ue_index_list=${ue_index_list}    tput_expect=${tput_expect}    ue_type=${ue_type}    duration=${duration}
      ...    protocol=${protocol}    attach_mode=${attach_mode}    gnb_index=${gnb_index}    du_index=${du_index}
      ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    cell_list=${cell_list_10471}

Cell_lock_and_unlock_for_spark
      [Arguments]    ${ue_index_list}    ${tput_expect}    ${ue_type}=huawei_sigspark    ${duration}=30    ${protocol}=udp
      ...    ${attach_mode}=5G_NSA    ${gnb_index}=${0}    ${du_index}=0    ${connection}=GNB_OAM
      ...    ${target_avg_percent}=0.5    ${min_percent}=0.2
      ${cell_id_list}  Get All Cell Id
      log to console    *****begin to lock all cells*******
      FOR  ${cell_id}  IN  @{cell_id_list}
          coam.lock    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}    timeout=60    connection=${connection}
          sleep  15
          Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be locked   cell_id=${cell_id}
      END
      log to console    *****begin to unlock all cells*****
      FOR  ${cell_id}  IN  @{cell_id_list}
          coam.unlock    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}    timeout=60    connection=${connection}
          sleep  15
          Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be unlocked   cell_id=${cell_id}
      END
      log to console    *****begin to make call under all cells*****
#      Sigspark_L3call    ue_index_list=${ue_index_list}    tput_expect=${tput_expect}    ue_type=${ue_type}    duration=${duration}
#      ...    protocol=${protocol}    attach_mode=${attach_mode}    gnb_index=${gnb_index}    du_index=${du_index}
#      ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
      Sigspark_L3call_from_tool    ue_index_list=${ue_index_list}    tput_expect=${tput_expect}    ue_type=${ue_type}    duration=${duration}
      ...    protocol=${protocol}    attach_mode=${attach_mode}    gnb_index=${gnb_index}    du_index=${du_index}
      ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    cell_list=${cell_list}


Cell_block_and_unblock_for_spark
     [Arguments]  ${tput_expect}
    Get X2 link shutdown waiting time
    Selenium Login And Disable Screen Lock
    ${cell_id_list}  Get All Cell Id
    ${cell_num}    get length  ${cell_id_list}
    Block and UnBlock Cells and sparkL3call    block_list=${cell_id_list}    tput_expect=${tput_expect}
    run keyword if  ${cell_num}>1  Block and UnBlock Cells  block_list=${cell_id_list}
    [Teardown]    Run keywords    Run Keyword And Ignore Error    UnBlock Cells and check status   block_list=${cell_id_list}
    ...    check_alarm=${True}  gnb_type='${gNb_CuType}'    AND   Selenium Logout And Close Browser


Block and UnBlock Cells and sparkL3call
    [Arguments]  ${tput_expect}    ${block_list}   ${ue_type}=huawei_sigspark    ${duration}=30    ${protocol}=udp
    ...    ${attach_mode}=NSA    ${gnb_index}=${0}    ${du_index}=0
    ...    ${target_avg_percent}=0.95    ${min_percent}=0.85
    ${block_num}    get length  ${block_list}
    FOR  ${block_id}  IN  @{block_list}
        ${check_alarm}  set variable if  ${block_num}==1  ${True}  ${False}
        ${other_cells}  Get Other Ids    id_list=${block_list}    given_id=${block_id}
        ${check_cell}  create list  ${block_id}
        ${operate_list}    set variable if  ${block_num}==1  ${check_cell}  ${other_cells}
        Block cells and check status   block_list=${operate_list}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
        ${ue_index_list}    ${cell_list}    Get UE List for Given Cell List    cell_list=${check_cell}
        Sigspark_L3call    ue_index_list=${ue_index_list}    tput_expect=${tput_expect}    ue_type=${ue_type}    duration=${duration}
        ...    protocol=${protocol}    attach_mode=${attach_mode}    gnb_index=${gnb_index}    du_index=${du_index}
        ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
        UnBlock Cells and check status   block_list=${operate_list}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
    END

CB0010471 2-5 made Tx Power not include inf
    [Arguments]    ${power}    ${idx}=5   ${ru_index}=${1}    ${asik_alias}=ASIK Master
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
    Sleep    60s
    ${RU_object2}  csn.Read Output    connection=RU_${ru_index}
    csn.Send Command    command=ssh 192.168.101.3 ${sudo} dapd -sq | tail -n ${idx} | head -n 2
    ...    connection=RU_${ru_index}
    Sleep    60s
    ${RU_object3}  csn.Read Output    connection=RU_${ru_index}
    csn.Send Command    command=ssh 192.168.101.4 ${sudo} dapd -sq | tail -n ${idx} | head -n 2
    ...    connection=RU_${ru_index}
    Sleep    60s
    ${RU_object4}  csn.Read Output    connection=RU_${ru_index}
    csn.Send Command    command=ssh 192.168.101.5 ${sudo} dapd -sq | tail -n ${idx} | head -n 2
    ...    connection=RU_${ru_index}
    Sleep    60s
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

CB0010471 6-9 made Tx Power not include inf
    [Arguments]    ${power}    ${idx}=5    ${ru_index}=${1}    ${asik_alias}=ASIK Master
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
    Sleep    60s
    ${RU_object6}  csn.Read Output    connection=RU_${ru_index}
    csn.Send Command    command=ssh 192.168.101.7 ${sudo} dapd -sq | tail -n ${idx} | head -n 2
    ...    connection=RU_${ru_index}
    Sleep    60s
    ${RU_object7}  csn.Read Output    connection=RU_${ru_index}
    csn.Send Command    command=ssh 192.168.101.8 ${sudo} dapd -sq | tail -n ${idx} | head -n 2
    ...    connection=RU_${ru_index}
    Sleep    60s
    ${RU_object8}  csn.Read Output    connection=RU_${ru_index}
    csn.Send Command    command=ssh 192.168.101.9 ${sudo} dapd -sq | tail -n ${idx} | head -n 2
    ...    connection=RU_${ru_index}
    Sleep    60s
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

CB0010471 6-9 made Tx Power only include inf
    [Arguments]    ${power}    ${idx}=5    ${ru_index}=${1}    ${asik_alias}=ASIK Master
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
    Sleep    60s
    ${RU_object6}  csn.Read Output    connection=RU_${ru_index}
    csn.Send Command    command=ssh 192.168.101.7 ${sudo} dapd -sq | tail -n ${idx} | head -n 2 | awk '{print $3,$4,$6,$7,$9,$10,$12,$13}'
    ...    connection=RU_${ru_index}
    Sleep    60s
    ${RU_object7}  csn.Read Output    connection=RU_${ru_index}
    csn.Send Command    command=ssh 192.168.101.8 ${sudo} dapd -sq | tail -n ${idx} | head -n 2 | awk '{print $3,$4,$6,$7,$9,$10,$12,$13}'
    ...    connection=RU_${ru_index}
    Sleep    60s
    ${RU_object8}  csn.Read Output    connection=RU_${ru_index}
    csn.Send Command    command=ssh 192.168.101.9 ${sudo} dapd -sq | tail -n ${idx} | head -n 2 | awk '{print $3,$4,$6,$7,$9,$10,$12,$13}'
    ...    connection=RU_${ru_index}
    Sleep    60s
    ${RU_object9}  csn.Read Output    connection=RU_${ru_index}
    Should Match Regexp     ${RU_object6}     ${power}    msg=${RU_type} Tx power value verify failed, please check
    Should Match Regexp     ${RU_object7}     ${power}    msg=${RU_type} Tx power value verify failed, please check
    Should Match Regexp     ${RU_object8}     ${power}    msg=${RU_type} Tx power value verify failed, please check
    Should Match Regexp     ${RU_object9}     ${power}    msg=${RU_type} Tx power value verify failed, please check
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    csn.Disconnect   connection=RU_${ru_index}
    ...    AND    Run Keyword And Ignore Error     csn.Disconnect   connection=${asik_alias}

CB006756 modify the parameter
    [Arguments]    ${dist_name}    ${parameter_name}    ${value}
    coam.perform_parameter_recommissioning        dist_name=${dist_name}
    ...                                            parameter=${parameter_name}
    ...                                            value=${value}
    ...                                            operation=update
    ...                                            connection=GNB_OAM

CB006756 create deepSleepTimeSchedule list
    [Arguments]    ${dayOfWeek}=Sun    ${startTime}=00:00    ${windowDuration}=35
    ${tmp}    create dictionary
    ...    dayOfWeek    ${dayOfWeek}
    ...    startTime    ${startTime}
    ...    windowDuration    ${windowDuration}
    ${tmp}     Create List    ${tmp}
    [Return]    ${tmp}

CB006756 modify deepSleepTimeSchedule
    [Arguments]    ${dist_name}    ${dayOfWeek}=Sun    ${startTime}=00:00    ${windowDuration}=35    ${connection}=GNB_OAM
    ${tmp}    CB006756 create deepSleepTimeSchedule list    dayOfWeek=${dayOfWeek}    startTime=${startTime}    windowDuration=${windowDuration}
    ${deepSleepTimeSchedule}      create dictionary
    ...    dist_name    ${dist_name}
    ...    parameter    deepSleepTimeSchedule
    ...    value        ${tmp}
    ${parameters}    Create List    ${deepSleepTimeSchedule}
    ${delta_file}=   coam_parameter.create_update_parameters_delta  parameters=${parameters}  connection=${connection}
    coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}    connection=${connection}
    sleep    20s

CB006756 Open and Config 10766 feature
    [Arguments]    ${dayOfWeek}=Sun    ${startTime}=00:00    ${windowDuration}=35    ${connection}=GNB_OAM
    CB006756 modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter_name=actRadioDeepSleepTimeSchedule    value=true
    CB006756 modify deepSleepTimeSchedule    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1    dayOfWeek=${dayOfWeek}
    ...    startTime=${startTime}    windowDuration=${windowDuration}    connection=${connection}

CB006756 Change lbpsPeriodList by Coam
    [Arguments]    ${dist_name}    ${lbpsDayOfWeek}=Fri    ${lbpsDuration}=1440    ${lbpsStartTimeHour}=0    ${lbpsStartTimeMinute}=0
    ...    ${connection}=GNB_OAM
    ${tmp}    create lbpsPeriodList list    lbpsDayOfWeek=${lbpsDayOfWeek}    lbpsDuration=${lbpsDuration}    lbpsStartTimeHour=${lbpsStartTimeHour}
    ...    lbpsStartTimeMinute=${lbpsStartTimeMinute}
    ${lbpsPeriodList}      create dictionary
    ...    dist_name    ${dist_name}
    ...    parameter    lbpsPeriodList
    ...    value        ${tmp}
    ${parameters}    Create List    ${lbpsPeriodList}
    ${delta_file}=   coam_parameter.create_update_parameters_delta  parameters=${parameters}  connection=${connection}
    coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}    connection=${connection}
    sleep    20s

CB006756 create lbpsCellPeriodList list
    [Arguments]    ${lbpsCellDayOfWeek}=Fri    ${lbpsCellDuration}=1440    ${lbpsCellSOMethod}=mixed switch off    ${lbpsCellStartTimeHour}=0
    ...    ${lbpsCellStartTimeMinute}=0    ${nrCellId}=1
    ${tmp}    create dictionary
    ...    lbpsCellDayOfWeek    ${lbpsCellDayOfWeek}
    ...    lbpsCellDuration    ${lbpsCellDuration}
    ...    lbpsCellSOMethod    ${lbpsCellSOMethod}
    ...    lbpsCellStartTimeHour    ${lbpsCellStartTimeHour}
    ...    lbpsCellStartTimeMinute    ${lbpsCellStartTimeMinute}
    ...    nrCellId    ${nrCellId}
    [Return]    ${tmp}

CB006756 Change lbpsCellPeriodList by Coam
    [Arguments]    ${NRPGRP_index}=1    ${connection}=GNB_OAM
    ${lbpsCellDayOfWeek}    ${lbpsCellStartTimeHour}    ${lbpsCellStartTimeMinute}    get_lbps_current_week_and_time
    ${tmp1}    CB006756 create lbpsCellPeriodList list    lbpsCellDayOfWeek=${lbpsCellDayOfWeek}    lbpsCellDuration=1440
    ...    lbpsCellSOMethod=mixed switch off    lbpsCellStartTimeHour=${lbpsCellStartTimeHour}    lbpsCellStartTimeMinute=${lbpsCellStartTimeMinute}
    ...    nrCellId=1
    ${tmp2}    CB006756 create lbpsCellPeriodList list    lbpsCellDayOfWeek=${lbpsCellDayOfWeek}    lbpsCellDuration=1440
    ...    lbpsCellSOMethod=mixed switch off    lbpsCellStartTimeHour=${lbpsCellStartTimeHour}    lbpsCellStartTimeMinute=${lbpsCellStartTimeMinute}
    ...    nrCellId=2
    ${tmp}    Create List    ${tmp1}    ${tmp2}
    ${lbpsCellPeriodList}      create dictionary
    ...    dist_name    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_index}
    ...    parameter    lbpsCellPeriodList
    ...    value        ${tmp}
    ${parameters}    Create List    ${lbpsCellPeriodList}
    ${delta_file}=   coam_parameter.create_update_parameters_delta  parameters=${parameters}  connection=${connection}
    coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}    connection=${connection}

CB006756 get RU Power State
    [Arguments]     ${ru_index}=1   ${connection}=GNB_OAM
    &{ru_status}    COAM get ru detial info by ru index     ru_index=${ru_index}    connection=${connection}
	[Return]    ${ru_status['status']['powerState']}

CB006756 Check RU Power State
    [Arguments]     ${expect_state}=SLEEP    ${ru_index}=1
    ${powerState}    CB006756 get RU Power State    ru_index=${ru_index}
	Should Be Equal As Strings  ${powerState}  ${expect_state}

CB010471_B_TX_Switch_Off_IWK
    ${SCF_50_50}    Replace String    ${Golden_SCF_Path}    .xml    _50M_50M.xml
    set suite variable  ${SCF_50_50}
    Commissioning SCF And Check On Air   scf_path=${SCF_50_50}
    log to console    ------------------------------------------------------------------------------------------
    log to console    Step 1 update 10471 431 time as current hour, minute and 1440,cell 1 2 reduceenergysaving
    log to console    ------------------------------------------------------------------------------------------
    ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_week_and_time
    ${Week}    ${startTime}    get_deepsleep_start_time    hour=${lbpsStartTimeHour}    minute=${lbpsStartTimeMinute}
    ${release}    Get program version based on gNB active version
    Run Keyword If   "${release}"!="SBTS23R4"
    ...     CB006756 Open and Config 10766 feature    dayOfWeek=${lbpsDayOfWeek}    startTime=${startTime}    windowDuration=1440
    CB006756 Change lbpsPeriodList by Coam    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-1    lbpsDayOfWeek=${lbpsDayOfWeek}
    ...    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}
    CB006756 Change lbpsCellPeriodList by Coam
    Wait Until Keyword Succeeds    8min    10s    Check cell EnergySaving state via COAM    expect_energySavingState=reducedEnergySaving
    Wait Until Keyword Succeeds    8min    5s    Check cell EnergySaving state via COAM    expect_energySavingState=reducedEnergySaving    cellID=2
    log to console    ------------------------------------------------------------------------------------------
    log to console    Step 2 send small data in cell 1, cell 1 reduceenergysaving
    log to console    ------------------------------------------------------------------------------------------
    Sigspark_L3call    ue_index_list=${ue_list_1}    tput_expect=${peak_info_reduce}    ifcheck_energysaving=${True}    power1=${CB0010471_power}
    ...    energySavingState=reducedEnergySaving    made69_power=${False}    target_avg_percent=0.6
    ...    min_percent=0.2
    log to console    ------------------------------------------------------------------------------------------
    log to console    Step 3 stop traffic in cell 1, cell 1 energySaving, cell2 energySaving
    log to console    ------------------------------------------------------------------------------------------
    Wait Until Keyword Succeeds    10min    30s    Check cell EnergySaving state via COAM    expect_energySavingState=energySaving
    Wait Until Keyword Succeeds    8min    30s    Check cell EnergySaving state via COAM    expect_energySavingState=energySaving    cellID=2
    Wait Until Keyword Succeeds    10min    30s    CB006756 Check RU Power State
    Sleep    30s
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 4 Change 10766 period to an expired time and check RU awake
    log to console    ---------------------------------------------------------------------------------------
    ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_week_and_time
    ${Week}    ${startTime}    get_deepsleep_start_time    hour=${lbpsStartTimeHour}    minute=${lbpsStartTimeMinute}    addonehour=True
    CB006756 modify deepSleepTimeSchedule    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1    dayOfWeek=${Week}
    ...    startTime=${startTime}    windowDuration=1440
    sleep    60s
    FOR    ${TEST_LOOP}    IN RANGE    0    50
        Check cell EnergySaving state via COAM    expect_energySavingState=energySaving    cellID=1
        Check cell EnergySaving state via COAM    expect_energySavingState=energySaving    cellID=2
        sleep    5s
    END
    Wait Until Keyword Succeeds    4min    5s    CB006756 Check RU Power State    expect_state=AWAKE
    FOR    ${TEST_LOOP}    IN RANGE    0    25
        Check cell EnergySaving state via COAM    expect_energySavingState=energySaving    cellID=1
        Check cell EnergySaving state via COAM    expect_energySavingState=energySaving    cellID=2
        sleep    5s
    END
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 4 Change 431 period to an expired time and cell on air
    log to console    ---------------------------------------------------------------------------------------
    CB006756 Change lbpsPeriodList by Coam    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-1    lbpsDayOfWeek=${lbpsDayOfWeek}
    ...    lbpsDuration=1    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}
    Wait Until Keyword Succeeds    8min    30s    Check cell EnergySaving state via COAM
    Wait Until Keyword Succeeds    8min    30s    Check cell EnergySaving state via COAM    cellID=2
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Sigspark_L3call_from_tool    ue_index_list=${ue_list_1}    tput_expect=${peak_info_recovery}    ifcheck_energysaving=${True}
    ...    power1=${CB0010471_power}    made69_power=${True}    cell_list=${cell_list_10471}
    ...    target_avg_percent=0.5    min_percent=0.2

Entering_Exiting_Deep_Sleep_Mode_IWK_With_5GC000431
    FOR    ${TEST_LOOP}    IN RANGE    0    1
        log to console    ++++++++++++++++++++++++++++++++++++ Loop ${TEST_LOOP} ++++++++++++++++++++++++++++++++++++
        Connect to gnb coam via ssl
        ${SCF_9925}    Replace String    ${Golden_SCF_Path}    .xml    _50M_50M_10766_431.xml
        set suite variable  ${SCF_9925}
        Commissioning SCF And Check On Air   scf_path=${SCF_9925}
        Wait until keyword succeeds    10min    30s    verify all cells should be onair
        Wait Until Keyword Succeeds    5min    30s    CB006756 Check RU Power State    expect_state=AWAKE
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 1 enable 431 10766 and check RU enter deep sleep
        log to console    ---------------------------------------------------------------------------------------
        ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_week_and_time
        ${Week}    ${startTime}    get_deepsleep_start_time    hour=${lbpsStartTimeHour}    minute=${lbpsStartTimeMinute}
        CB006756 modify deepSleepTimeSchedule    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1    dayOfWeek=${lbpsDayOfWeek}
        ...    startTime=${startTime}    windowDuration=1440
        CB006756 Change lbpsPeriodList by Coam    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-1    lbpsDayOfWeek=${lbpsDayOfWeek}
        ...    lbpsStartTimeHour=${lbpsStartTimeHour}    lbpsStartTimeMinute=${lbpsStartTimeMinute}
        sleep    60s
#        check power saving counters after cell enter energysaving
        Wait Until Keyword Succeeds    12min    30s    Check cell EnergySaving state via COAM    expect_energySavingState=energySaving    cellID=1
        Wait Until Keyword Succeeds    10min    30s    Check cell EnergySaving state via COAM    expect_energySavingState=energySaving    cellID=2
        Wait Until Keyword Succeeds    10min    30s    CB006756 Check RU Power State
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 2 Change 10766 period to an expired time and check RU awake
        log to console    ---------------------------------------------------------------------------------------
        ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_week_and_time
        ${Week}    ${startTime}    get_deepsleep_start_time    hour=${lbpsStartTimeHour}    minute=${lbpsStartTimeMinute}    addonehour=True
        CB006756 modify deepSleepTimeSchedule    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1    dayOfWeek=${Week}
        ...    startTime=${startTime}    windowDuration=1440
        sleep    60s
        Check cell EnergySaving state via COAM    expect_energySavingState=energySaving    cellID=1
        Check cell EnergySaving state via COAM    expect_energySavingState=energySaving    cellID=2
        Wait Until Keyword Succeeds    10min    30s    CB006756 Check RU Power State    expect_state=AWAKE
        Check cell EnergySaving state via COAM    expect_energySavingState=energySaving    cellID=1
        Check cell EnergySaving state via COAM    expect_energySavingState=energySaving    cellID=2
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 3 disable actRadioDeepSleepTimeSchedule and RU enter deep sleep
        log to console    ---------------------------------------------------------------------------------------
        CB006756 modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
        ...    parameter_name=actRadioDeepSleepTimeSchedule    value=false
        Wait Until Keyword Succeeds    10min    30s    CB006756 Check RU Power State
        log to console    ---------------------------------------------------------------------------------------
        log to console    Step 4 enable 10766 and disable 431
        log to console    ---------------------------------------------------------------------------------------
        CB006756 modify the parameter    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
        ...    parameter_name=actRadioDeepSleepTimeSchedule    value=true
        ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_lbps_current_week_and_time
        ${Week}    ${startTime}    get_deepsleep_start_time    hour=${lbpsStartTimeHour}    minute=${lbpsStartTimeMinute}
        CB006756 modify deepSleepTimeSchedule    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-1    dayOfWeek=${lbpsDayOfWeek}
        ...    startTime=${startTime}    windowDuration=1440
        CB006756 modify the parameter    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}     parameter_name=actNrLBPowerSaving    value=false
#        check power saving counters after cell exit energysaving
        Wait Until Keyword Succeeds    10min    30s    CB006756 Check RU Power State    expect_state=AWAKE
        Wait until keyword succeeds    10min    30s    verify all cells should be onair
        sleep    10s
        csn.reset_cache
    END
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 5 peak call
    log to console    ---------------------------------------------------------------------------------------
    Sigspark_L3call_from_tool    ue_index_list=${ue_list_2}    tput_expect=${tput_peak}    cell_list=${cell_list}
    ...    target_avg_percent=0.5    min_percent=0.2
    [Teardown]    Run keyword and ignore error     Check ERR Or WRN From Syslog    sys_logs_path=/tmp/btslog2/      UTE_logs_path=${UTE_logs_path}
    ...    base_file=${Base_ERR_WRN_csv_path}    Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15    Fail_Case=${False}
    ...    Clear_log=${False}    FilesSystem=/dev/vda2      Max_used_space_ratio=0.85

remove DVM method
    [Arguments]    ${ru_index}=1
    Connect to Common Unit Master
    log to console    login RU
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${enter_shell_client}    set variable    ${sudo} frmonShellClient localhost 2000
    log to console    operate under shell client...
    log to console    send / action create ConfigAccess /cofi /module
    ${cmd}   Set Variable    echo "/ action create ConfigAccess /cofi /module"|${enter_shell_client}
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    sleep    2s
    log to console    send /cofi action fetch DECODED "psudvm_dlpath1.bin" "/var/tmp/psudvm_dlpath1.json"
    ${cmd}   Set Variable    echo '/cofi action fetch DECODED "psudvm_dlpath1.bin" "/var/tmp/psudvm_dlpath1.json"'|${enter_shell_client}
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    sleep    2s
    Should Contain    ${output}    done ok
    log to console    operate under RU...
    log to console    copy psudvm_dlpath1.json from /var/tmp to /ram
    csn.execute    ${sudo} mv /var/tmp/psudvm_dlpath1.json /ram/psudvm_dlpath1.json    connection=RU_${ru_index}
    log to console    remove pointed lines from /ram/psudvm_dlpath1.json
    ${cmd}    set variable    cat /ram/psudvm_dlpath1.json -n |grep powerOffsets|awk '{print $1}'
    ${output}    csn.execute    command=${sudo} ${cmd}    connection=RU_${ru_index}
    ${output}    Replace String    ${output}    \r\n    ${EMPTY}
    ${output}    Convert To Integer    ${output}
    ${start_line}    Evaluate    ${output}+1
    ${end_line}    Evaluate    ${start_line}+15
    ${cmd}    set variable    sed -e '${start_line},${end_line}d' /ram/psudvm_dlpath1.json
    ${output}    csn.execute    command=${sudo} ${cmd}    connection=RU_${ru_index}
    ${cmd}    set variable    echo '${output}' > /ram/psudvm_dlpath1.json
    log to console    chmod 777 /ram/psudvm_dlpath1.json
    csn.execute    ${sudo} chmod 777 /ram/psudvm_dlpath1.json    connection=RU_${ru_index}
    log to console    operate under shell client...
    log to console    send /cofi action store PERMANENT DECODED "psudvm_dlpath1.bin" "/ram/psudvm_dlpath1.json"
    ${cmd}   Set Variable    echo '/cofi action store PERMANENT DECODED "psudvm_dlpath1.bin" "/ram/psudvm_dlpath1.json"'|${enter_shell_client}
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    sleep    2s
    Should Contain    ${output}    done ok
    log to console    send /cofi action update
    ${cmd}   Set Variable    echo "/cofi action update"|${enter_shell_client}
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    sleep    2s
    log to console    reboot RU by power off
    power off and on rus
    [Teardown]       run keywords    run keyword and ignore error    csn.Disconnect  connection=ASIK Master    AND
    ...    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair

recovery after remove DVM
    [Arguments]    ${ru_index}=1
    Connect to Common Unit Master
    log to console   login RU
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    log to console    operate under shell client...
    log to console    send / action create ConfigAccess /cofi /module
    ${cmd}   Set Variable    echo "/ action create ConfigAccess /cofi /module"|${sudo} frmonShellClient localhost 2000
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    sleep    2s
    log to console    send /cofi action delete "psudvm_dlpath1.bin"
    ${cmd}   Set Variable    echo '/cofi action delete "psudvm_dlpath1.bin"'|${sudo} frmonShellClient localhost 2000
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    sleep    2s
    log to console    send /cofi action update
    ${cmd}   Set Variable    echo "/cofi action update"|${sudo} frmonShellClient localhost 2000
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    sleep    2s
    log to console    reboot RU by power off
    power off and on rus
    [Teardown]       run keywords    run keyword and ignore error    csn.Disconnect  connection=ASIK Master    AND
    ...    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair

PAPSU check with SDVM
    log to console    online change PMAX to 38.7, and check cell onair
    online change pMax    pMax=38.7    cell_id=3
    log to console    check all status are corrected: SM/BB/RU/CELL
    log to console    Check papsu, should be about 51V. 50v<PAPSU <52v
    Check papsu    expect_value_left=50    expect_value_right=52
    log to console    online change PMAX to 36.9, and check cell onair
    online change pMax    pMax=36.9    cell_id=3
    log to console    check all status are corrected: SM/BB/RU/CELL
    log to console    Check papsu,  should be about 49V. 48v<PAPSU <50v
    Check papsu    expect_value_left=48    expect_value_right=50
    log to console    online change PMAX to 33.9, and check cell onair
    online change pMax    pMax=33.9    cell_id=3
    log to console    check all status are corrected: SM/BB/RU/CELL
    log to console    Check papsu,  should be about 47V. 46v<PAPSU <48v
    Check papsu    expect_value_left=46    expect_value_right=48
    log to console    online change PMAX to 30, and check cell onair
    online change pMax    pMax=30    cell_id=3
    log to console    check all status are corrected: SM/BB/RU/CELL
    log to console    Check papsu, should be about 42V. 41v<PAPSU <43v
    Check papsu    expect_value_left=41    expect_value_right=43

PAPSU check with SDVM for AQQQ
    log to console    online change PMAX to 33.9, and check cell onair
    online change pMax    pMax=33.9    cell_id=1
    log to console    check all status are corrected: SM/BB/RU/CELL
    log to console    Check papsu, should be about 42V. 41v<PAPSU <43v
    Check papsu    expect_value_left=41    expect_value_right=43    ru_index=1
    log to console    online change PMAX to 30, and check cell onair
    online change pMax    pMax=30    cell_id=1
    log to console    check all status are corrected: SM/BB/RU/CELL
    log to console    Check papsu,  should be about 40V. 39v<PAPSU <41v
    Check papsu    expect_value_left=39    expect_value_right=41    ru_index=1
    log to console    online change PMAX to 26.9, and check cell onair
    online change pMax    pMax=38.8    cell_id=1
    log to console    check all status are corrected: SM/BB/RU/CELL
    log to console    Check papsu,  should be about 47V. 46v<PAPSU <48v
    Check papsu    expect_value_left=46    expect_value_right=48    ru_index=1
    [Teardown]    Run keyword and ignore error     Check ERR Or WRN From Syslog    sys_logs_path=/tmp/btslog2/      UTE_logs_path=${UTE_logs_path}
    ...    base_file=${Base_ERR_WRN_csv_path}    Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15    Fail_Case=${False}
    ...    Clear_log=${False}    FilesSystem=/dev/vda2      Max_used_space_ratio=0.85

online change pMax
    [Arguments]    ${pMax}    ${cell_id}
    selenium login and disable screen lock
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
    ...    filter_param=Maximum output power    abbr=pMax    new_value=${pMax}
    selenium_coam.validate_plan
    Wait Until Keyword Succeeds    5x     20s    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=${300}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    [Teardown]    selenium logout and close browser

Check papsu
    [Arguments]    ${expect_value_left}    ${expect_value_right}    ${ru_index}=3
    Connect to Common Unit Master
    log to console    login RU
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${enter_shell_client}    set variable    ${sudo} frmonShellClient localhost 2000
    log to console    operate under shell client...
    log to console    send / action create ConfigAccess /ca /module
    ${cmd}   Set Variable    echo "/ action create ConfigAccess /ca /module"|${enter_shell_client}
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    sleep    2s
    log to console    send / action create Psu /papsu1 /rf/papsu1
    ${cmd}   Set Variable    echo "/ action create Psu /papsu1 /rf/papsu1"|${enter_shell_client}
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    sleep    2s
    log to console    send /papsu1 action measure
    ${cmd}   Set Variable    echo "/papsu1 action measure"|${enter_shell_client}
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    sleep    2s
    log to console    ${output}
    ${papsu1}    Set Variable    ${output.split('\r\n')[0].split(' ')[-1]}
    ${papsu1}    Evaluate    float(${papsu1})
    Run Keywords    Should Be True    ${papsu1}>${expect_value_left}    AND     Should Be True    ${papsu1}<${expect_value_right}
    log to console    send  / action create Psu /papsu2 /rf/papsu2
    ${cmd}   Set Variable    echo "/ action create Psu /papsu2 /rf/papsu2"|${enter_shell_client}
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    sleep    2s
    log to console    send /papsu2 action measure
    ${cmd}   Set Variable    echo "/papsu2 action measure"|${enter_shell_client}
    ${output}  csn.execute  command=${sudo} ${cmd}    connection=RU_${ru_index}
    sleep    2s
    log to console    ${output}
    ${papsu2}    Set Variable    ${output.split('\r\n')[0].split(' ')[-1]}
    ${papsu2}    Evaluate    float(${papsu2})
    Run Keywords    Should Be True    ${papsu2}>${expect_value_left}    AND     Should Be True    ${papsu2}<${expect_value_right}
    [Teardown]       run keywords    run keyword and ignore error    csn.Disconnect  connection=ASIK Master    AND
    ...    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair

