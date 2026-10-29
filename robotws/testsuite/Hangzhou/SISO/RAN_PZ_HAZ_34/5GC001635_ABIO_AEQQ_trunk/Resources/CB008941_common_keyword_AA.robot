*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py
Library    ../lib/CB008941_AA.py
Library     taf.rfrl.bts.commissioning

Documentation
...    author: Jiangjing Lin
...    contact: jiangjing.lin@nokia-sbell.com
...    Group: HGZ_SG8

*** Variables ***
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
@{cell_id_list}    ${1}
@{group2}    ${0}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}    ${9}    ${10}    ${11}
${CB0010471_power}        -([1-9]\d*\.\d*|0\.\d*[1-9]\d*)
${inf}    -inf.*-inf.*-inf.*-inf.*-inf.*-inf.*-inf.*-inf.*-inf.*-inf.*-inf.*-inf.*-inf.*-inf.*-inf.*-inf.*
${CB0010471_power_inf}        ${inf}\n${inf}
@{cell_list_10471}    ${1}
*** Keywords ***
AEQQ madeTx Power not include inf
    [Arguments]    ${power}    ${made_index1}    ${made_index2}    ${ru_index}=${1}    ${asik_alias}=ASIK Master
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

AEQQ made Tx Power only include inf
    [Arguments]    ${power}    ${made_index1}    ${made_index2}    ${ru_index}=${1}    ${asik_alias}=ASIK Master
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

CB0010471 call and check energy saving state
    [Arguments]    ${tput_expect}    ${duration}=${300}    ${tput_from}=tool    ${target_avg}=0.95    ${min_percent}=0.85    ${cell_id}=${1}
    ...    ${energySavingState}=notEnergySaving    ${made35_power}=${False}
    ${tput_expect}    get_self_define_tput_by_release    tput_info=${tput_expect}
    ${tput_info_total}    create dictionary
    ${tput_cell}    run keyword if    '${tput_from}'=='tool'    get_tput_info_by_tool    cell_id=${cell_id}    target_avg_percent=${target_avg}   
    ...    min_percent=${min_percent}    duration=${duration}    connection=GNB_OAM    ELSE    set variable    ${tput_expect[${cell_id}]}
    set to dictionary    ${tput_info_total}    ${cell_id}    ${tput_cell}
    log to console    tput info for cell ${cell_id} is: ${tput_cell}
    ${ue_index}    set variable    ${tput_expect[${cell_id}]['ue_index']}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    make_call    tput_info=${tput_cell}    ue_index=${ue_index}    process_num_ul=5
    sleep  10
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_info_total}    cell_id=${cell_id}    ue_index=${ue_index}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg}    min_percent=${min_percent}
    Check cell EnergySaving state via COAM    expect_energySavingState=${energySavingState}
    AEQQ madeTx Power not include inf    power=${CB0010471_power}    made_index1=2    made_index2=4
    run keyword if     ${made35_power}==${True}
    ...    AEQQ madeTx Power not include inf    power=${CB0010471_power}    made_index1=3    made_index2=5
#    ...    ELSE    AEQQ made Tx Power only include inf    power=${CB0010471_power_inf}    made_index1=3    made_index2=5
    [Teardown]    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}

CB010471_A_B12345_16TRX_Path_Switch_Off_On_Base_On_Pgload
    Change lbpsPeriodList by Coam
    online change actNrLBmMimoRTXPowerSaving
    Sleep    180s
    Check cell EnergySaving state via COAM
    online change actNrLBmMimoRTXPowerSaving    actNrLBmMimoRTXPowerSaving=true
    Sleep    300s
    Check cell EnergySaving state via COAM    expect_energySavingState=reducedEnergySaving
    AEQQ madeTx Power not include inf    power=${CB0010471_power}    made_index1=2    made_index2=4
#    AEQQ made Tx Power only include inf    power=${CB0010471_power_inf}    made_index1=3    made_index2=5
    CB0010471 call and check energy saving state    tput_expect=${peak_info_reduce}    tput_from=self_define
    ...    energySavingState=reducedEnergySaving    made35_power=${False}
    Sleep    10s
    CB0010471 call and check energy saving state    tput_expect=${peak_info}
    ...    energySavingState=notEnergySaving    made35_power=${True}
    Sleep    300s
    Check cell EnergySaving state via COAM    expect_energySavingState=reducedEnergySaving
    AEQQ madeTx Power not include inf    power=${CB0010471_power}    made_index1=2    made_index2=4
#    AEQQ made Tx Power only include inf    power=${CB0010471_power_inf}    made_index1=3    made_index2=5
    [Teardown]   Recovery actNrLBmMimoRTXPowerSaving due to IWK

Cell_onair_Loki_based_DU_with_UL_PRB_muting_active_FDBF-AA-1
    [Arguments]    ${ru_index}=${1}    ${asik_alias}=ASIK Master
    #Modify Swconfig File    swconfig_path=${CURDIR}/swconfig_new.txt
    # run on 1131
    Connect to gnb coam via ssl
    coam.reset_site    connection=GNB_OAM
    sleep    120s
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    connect to common unit master    alias=${asik_alias}
    Connect to RU With Allocated IP    ru_index=${1}    ru_alias=RU_1
    ${release}    Get program version based on gNB active version
    ${sub_dir}   Run Keyword If   "${release}"=="SBTS23R2" or "${release}"=="SBTS23R3"    set variable    *
    ...    ELSE    set variable    UnitOAM_SOAP_Startup_LBTS_*
    ${soap_log_path}    Download soap Log from RU    ru_alias=RU_${ru_index}    sub_dir=${sub_dir}
    log to console    check endpointCapacitySharingGroup have 0-11
    ${group_list}    get_group_ids_from_soap    filepath=${soap_log_path}
    Should Be Equal    ${group_list}    ${group2}
    log to console    check group 0
    ${status}    check_group_info    filepath=${soap_log_path}    group_id=${1}    maxUplaneSectionHeadersPerSymbol=${18}
    ...    maxUplaneSectionHeadersPerSlot=${252}    Endpoints=${16}
    Should Be Equal    ${status}    ${True}
    log to console    check group 2
    ${status}    check_group_info    filepath=${soap_log_path}    group_id=${3}    maxUplaneSectionHeadersPerSymbol=${26}
    ...    maxUplaneSectionHeadersPerSlot=${78}    Endpoints=${8}
    Should Be Equal    ${status}    ${True}
    log to console    L3 call
    make_call_and_check_tput_for_all_cells    tput_info=${peak_info}    cell_list=${cell_list_10471}
    ...    target_avg_percent=${0.5}    min_percent=${0.2}
#    Get UE From Init File and Make call    cell_list=${cell_id_list}    duration=100    4G_check=True
#    [Teardown]  run keywords    Modify Swconfig File    swconfig_path=${CURDIR}/swconfig_old.txt    AND
#    ...    run keyword and ignore error    csn.disconnect   connection=RU_${ru_index}    AND
#    ...    run keyword and ignore error    csn.Disconnect   connection=${asik_alias}
     [Teardown]  run keywords    run keyword and ignore error    csn.disconnect   connection=RU_${ru_index}    AND
     ...    run keyword and ignore error    csn.Disconnect   connection=${asik_alias}

L3call_Loki_based_DU_with_short_PUCCH_FDBF-AA-8
    #Modify Swconfig File    swconfig_path=${CURDIR}/swconfig_new.txt
    # run on 1131
    log to console    import scf
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _shortpucch.xml
    Selenium Login And Disable Screen Lock
    Commissioning SCF And Check On Air    scf_path=${SCF_upload}
    ${is_startup_window_exist}    selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    log to console    L3 call
    Get UE From Init File and Make call    cell_list=${cell_id_list}    duration=100    4G_check=True
#    [Teardown]    run keywords    Modify Swconfig File    swconfig_path=${CURDIR}/swconfig_old.txt    AND
#    ...    run keyword and ignore error    Selenium Logout And Close Browser    AND
#    ...    run keyword and ignore error    recovery by upload pointed scf_AA
    [Teardown]    run keywords    run keyword and ignore error    Selenium Logout And Close Browser    AND
    ...    run keyword and ignore error    recovery by upload pointed scf_AA

recovery by upload pointed scf_AA
    ${SCF_50M_40M}    Replace String    ${Golden_SCF_Path}    .xml    _50M_40M.xml
    run keyword and ignore error    COAM Teardown gnb connections
    Connect to gnb coam via ssl
    Commissioning SCF And Check On Air   scf_path=${SCF_50M_40M}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Modify Swconfig File
    [Arguments]    ${swconfig_path}    ${asik_alias}=ASIK Master
    Connect to Common Unit Master    alias=${asik_alias}
    Upload Swconfig File    swconfig_path=${swconfig_path}
    run keyword and ignore error    COAM Teardown gnb connections
    Connect to gnb coam via ssl
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    [Teardown]    run keyword and ignore error    csn.Disconnect   connection=${asik_alias}

Upload Swconfig File
    [Arguments]    ${swconfig_path}    ${asik_alias}=ASIK Master
    ${swconfig_file_name}    Fetch from right    ${swconfig_path}    /
    log to console    upload swconfig file
    csn.Upload File    local_path=${swconfig_path}    remote_path=/ffs/run/swconfig.txt    connection=${asik_alias}
    sleep    1s
    log to console    rename uploaded new swconfig file
    csn.execute    mv /ffs/run/${swconfig_file_name} /ffs/run/swconfig.txt    connection=${asik_alias}
    sleep    1s
    log to console    crasign...
    csn.execute    crasign /ffs/run/swconfig.txt    connection=${asik_alias}
    sleep    1s
    log to console    craverify...
    csn.execute    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7    connection=${asik_alias}
    sleep    1s
    log to console    reboot testline...
    Connect to gnb coam via ssl
    coam.reset_site    connection=GNB_OAM
    sleep    120s
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections
