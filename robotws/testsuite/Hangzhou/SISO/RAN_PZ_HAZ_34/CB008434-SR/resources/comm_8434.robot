*** Settings ***
Documentation
...   author: zheyuan.chen@nokia-sbell.com
...   contact: zheyuan.chen@nokia-sbell.com

Library    taf.transport.ssh            WITH NAME    ssh
Library    taf.collectors.core          WITH NAME    core
Library    taf.collectors.tcpdump       WITH NAME    tcpdump
Library    taf.analyzer.pdml            WITH NAME    cpdml
Library    taf.sbts.oam.coam.admin      WITH NAME    coam
Library    taf.collectors.btslog        WITH NAME    btslog
Library    String
Library    Collections
Library    OperatingSystem
Library    Process
Library    XML
Library    DateTime
Library    Telnet
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    ./variables_8434.robot

*** Keywords ***
SBTS Login
    [Arguments]    ${ip_address}=${DU_OAM_IP}    ${username}=${DU_OAM_WEBUI_USER}
    ...    ${password}=${DU_OAM_WEBUI_PASSWORD}    ${alias}=default
    [Documentation]   SBTS Login
    Connect to gnb coam via ssl    bts_host=${ip_address}    username=${username}    password=${password}    connection=${alias}
    ${connection}    set variable    ${alias}
    [Return]    ${connection}

SBTS Logout
    [Arguments]   ${alias}=default
    [Documentation]   SBTS Logout
    coam.Teardown    connection=${alias}

Get BTS release
    ${conn}    SBTS Login
    ${version}    coam.get_sw_version    connection=${conn}
    ${version_list}    split string    ${version}    separator=_
    ${bts_release}    set variable    ${version_list[0]}
    [Return]    ${bts_release}
    [Teardown]    SBTS Logout

WEBUI Login
    [Documentation]   WEBUI Login
    Log To Console  START:WEBUI Login
    Log To Console  Try to login...
    ${version}    Get BTS release
    selenium_coam.Enable_Virtual_Display
    selenium_coam.Login    url=${DU_OAM_WEBUI_URL}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
    ...     version=${version}
    Log To Console  Login successfully...
    Run Keyword And Ignore Error      selenium_coam.Disable_Message_Box
    Sleep    15s
    selenium_coam.disable_screen_lock
    Log To Console  END:WEBUI Login!

WEBUI Logout
    [Arguments]     ${virtual_disable}=${True}
    [Documentation]   WEBUI Logout
    Log To Console  Try to logout...
    Run Keyword If      ${virtual_disable}    Run Keyword And Ignore Error    selenium_coam.Enable_Virtual_Display
    Run Keyword And Ignore Error  selenium_coam.Logout
    Log To Console  Logout successfully...
    Run Keyword If      ${virtual_disable}    Run Keyword And Ignore Error    selenium_coam.Disable_Virtual_Display
    Sleep    3s
    Log To Console  END:WEBUI Logout!

Check BTS Should Be Normal
    Log To Console  Check BTS Should Be Normal
    SBTS Login
    Wait Until BTS Should Be Normal
    [Teardown]   Run Keyword And Ignore Error   SBTS Logout

Wait Until BTS Should Be Normal
    [Arguments]    ${retry}=1000s    ${retry_interval}=10s    ${alias}=default
    [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Gnb Cell Should Be Onair    alias=${alias}

Gnb Cell Should Be Onair
    [Arguments]    ${alias}=default    ${cell_type }=nr
    [Documentation]  Gnb Cell Should Be Onair, check method is via REST
    ${status}      coam.Get_Bts_Statuses   connection=${alias}
    ${operationalState}    Get From Dictionary    ${status}    operationalState
    should be equal as strings    ${operationalState}    Enabled    ignore_case=${True}
    ${blockingState}   Get From Dictionary    ${status}    blockingState
    should be equal as strings    ${blockingState}    Unblocked    ignore_case=${True}
    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
    should be equal as strings    ${proceduralState}    OnAir    ignore_case=${True}
    #cell info
    ${cell_status}     coam.Get_Cells_Info   cell_type=${cell_type}    connection=${alias}
    FOR    ${item}    IN    @{cell_status}
        ${Status_cell}    Get From Dictionary    ${item}    status
        ${tmp}   Get From Dictionary    ${Status_cell}    operationalState
        should be equal as strings    ${tmp}    Enabled    ignore_case=${True}
        ${tmp}   Get From Dictionary    ${Status_cell}  administrativeState
        should be equal as strings    ${tmp}    Unlocked    ignore_case=${True}
        ${tmp}   Get From Dictionary    ${Status_cell}  blockingState
        should be equal as strings    ${tmp}    Unblocked    ignore_case=${True}
        ${tmp}   Get From Dictionary    ${Status_cell}  usageState
        should be equal as strings    ${tmp}    Active    ignore_case=${True}
    END

suite setup to prepare default scf
    Log To Console    Set Default Scf
    ${connection}    SBTS Login
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    ${if_common_load}     run keyword and return status    should contain    ${version_list[2]}    9999
    ${default_scf}    set variable if    ${if_common_load}    ${default_scf_path}SCF_SBTS00
    ...     ${default_scf_path}SCF_${version_list[0]}
#    ${if_branch_load}     run keyword and return status    should contain    ${version_list[0]}    ${branch_version}
#    ${default_scf}    set variable if    ${if_branch_load}    ${default_scf_path}${Branch_scf_name}
#    ...    ${default_scf_path}${SBTS_scf_name}
    log to console   ${default_scf}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${default_scf}

Commission Default SCF
    [Arguments]    ${default_scf}
    Log To Console    Commission Default SCF
    ${connection}    SBTS Login
    COAM Commission with scf file    scf_file_path=${default_scf}    connection=${connection}    is_pdl_checking_needed=${False}
    Wait Until BTS Should Be Normal
    sleep    20s
    Check if Unexpected History Alarm Exist
    [Teardown]    coam.Teardown   connection=${connection}

Check if Unexpected History Alarm Exist
    ${fault_id_list}    Get BTS History Alarm FaultID
    return from keyword if    '${fault_id_list}' == '[]'
    ${ignore_fault}    set variable    ${ignore_history_fault}
    FOR    ${item}    IN    @{fault_id_list}
        run keyword and continue on failure    list should contain value    ${ignore_fault}    ${item}
    END

Get BTS History Alarm FaultID
    [Arguments]    ${connection}=default
    Log To Console    get history alarm faultid
    ${alarm_info}    coam.get_historic_alarms    timeout=60    connection=${connection}
    ${fault_id_list}    create list
    FOR    ${item}    IN    @{alarm_info}
        ${fault_id_dic}    get from dictionary    ${item}    additionalFaultID
        append to list    ${fault_id_list}    ${fault_id_dic}
    END
    sort list    ${fault_id_list}
    [Return]    ${fault_id_list}

Lock RMOD
    [Arguments]    ${RMOD_idx}    ${connection}=default
    sleep    2s
    Log To Console    Lock RMOD
    coam.lock    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_idx}    timeout=${60}    connection=${connection}
    sleep    5s

Unlock RMOD
    [Arguments]    ${RMOD_idx}    ${connection}=default
    Log To Console    Unlock RMOD
    coam.unlock    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_idx}    timeout=${60}    connection=${connection}
    sleep    5s

block_cell
    [Arguments]    ${connection}=default   ${cell_idx}=${1}
    Log To Console    block cell
    coam.block_cell    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_idx}    connection=${connection}
    sleep    3s

unblock_cell
    [Arguments]    ${connection}=default    ${cell_idx}=${1}
    Log To Console    unblock cell
    coam.unblock_cell    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_idx}    connection=${connection}
    sleep    3s

Single UE Attach
    [Arguments]    ${ue_type}=${ue_type}    ${ue_index}=${0}    ${attach_mode}=5G_NSA
    Log To Console    Single UE Attach
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    Log To Console    UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_type=${ue_type}    attach_mode=${attach_mode}    ue_index=${ue_index}
    Log To Console    Verify attach
    power_ue.Verify attach    ue_type=${ue_type}    ue_index=${ue_index}    5Grach_ed=${5Grach_ed_0}    4G_check=False

Start Traffic And Check Throughput
    [Arguments]    ${tp_ul}    ${tp_dl}    ${target_tp_ul}    ${target_tp_dl}    ${nrcell_id}    ${duration}=600    ${ue_mode}=NSA
    ...    ${ue_index}=${0}    ${gnb_index}=${0}    ${port}=${0}    ${iperf_type_ul}=via_command    ${iperf_type_dl}=via_command
    ...    ${target_avg_percent}=0.95
    Log To Console    Start Traffic And Check Throughput
    Single UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    Log To Console    start traffic
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul   throughput=${tp_ul}   ue_index=${ue_index}
    ...    duration=${duration}    ue_mode=${ue_mode}    iperf_port=${IPERF_portlist}[${port}]    iperf_type=${iperf_type_ul}    process_num=${3}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl   throughput=${tp_dl}    ue_index=${ue_index}
    ...    duration=${duration}    ue_mode=${ue_mode}    iperf_port=${IPERF_portlist}[${port}]    iperf_type=${iperf_type_dl}    process_num=${3}
    sleep    30s
    Log To Console    check throughput
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    gnb_index=${gnb_index}    duration=60s    ignore_time=5s
    ${cell_list}    create list    ${nrcell_id}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=ul    log=${log_path}
    ...    cells=${cell_list}    target_throughput=${target_tp_ul}    target_avg_percent=${target_avg_percent}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    log=${log_path}
    ...    cells=${cell_list}    target_throughput=${target_tp_dl}    target_avg_percent=${target_avg_percent}

Stop Traffic And UE Detach
    [Arguments]    ${ue_index}=${0}    ${port}=${0}    ${ue_mode}=NSA
    Log To Console    stop traffic
    run keyword and continue on failure    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    ...    iperf_port=${IPERF_portlist}[${port}]    ue_mode=${ue_mode}
    run keyword and continue on failure    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    ...    iperf_port=${IPERF_portlist}[${port}]    ue_mode=${ue_mode}
    Log To Console    UE Detach
    [Teardown]   run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

_lock_other_ru
    [Arguments]    ${RU_list}    ${RU_dic}
    ${RU_index_list}    create list    ${0}    ${1}    ${2}
    ${ru_i}     get index from list    ${RU_list}    ${RU_dic}
    remove from list    ${RU_index_list}    ${ru_i}
    log    ${RU_index_list}
    Log To Console    lock other ru
    FOR    ${item}    IN    @{RU_index_list}
        ${RMOD_idx}    evaluate    ${item} + 1
        Lock RMOD    RMOD_idx=${RMOD_idx}
        sleep    5s
    END

_unlock_other_ru
    [Arguments]    ${RU_list}    ${RU_dic}
    ${RU_index_list}    create list    ${0}    ${1}    ${2}
    ${ru_i}     get index from list    ${RU_list}    ${RU_dic}
    remove from list    ${RU_index_list}    ${ru_i}
    log    ${RU_index_list}
    Log To Console    unlock other ru
    FOR    ${item}    IN    @{RU_index_list}
        ${RMOD_idx}    evaluate    ${item} + 1
        Unlock RMOD    RMOD_idx=${RMOD_idx}
        sleep    5s
    END

Delete TL5 Nrcells Data
    Log To Console    delete nrcell
    selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-0
    selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-1
    selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
    selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2
    selenium_coam.remove_element   dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group    node_index=${0}    abbr=refNrCellGroup
    selenium_coam.remove_element   dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group    node_index=${1}    abbr=refNrCellGroup

Activate TL5 Supercell And Add Channelgroup
    Log To Console    activate supercell parameter
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    ...    filter_param=Activate super cell   new_value=true    abbr=actSuperCell
    Log To Console    add channelgroup
    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3    object_class_name=CHANNELGROUP
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1
    ...    include_subobject=${TRUE}    id_value=1
    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3    object_class_name=CHANNELGROUP
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2
    ...    include_subobject=${TRUE}    id_value=2

Add TL5 Nrcells Data
    Log To Console    add nrcell
    #add nrcell
    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}    object_class_name=NRCELL
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    ...    include_subobject=${TRUE}    id_value=1
    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}    object_class_name=NRCELL
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    ...    include_subobject=${TRUE}    id_value=2
    #set nrcell parameter
    Log To Console    set nrcell parameter
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Local cell resource ID   new_value=1    abbr=lcrId
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Physical cell identifier   new_value=168    abbr=physCellId
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...    filter_param=Local cell resource ID   new_value=2    abbr=lcrId
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...    filter_param=Physical cell identifier   new_value=169    abbr=physCellId
    #add nrcellgroup
    Log To Console    add nrcellgroup
    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}    object_class_name=NRCELLGRP
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-2
    ...    include_subobject=${TRUE}    id_value=0
    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}    object_class_name=NRCELLGRP
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-2
    ...    include_subobject=${TRUE}    id_value=1
    #set nrcellgrp parameter
    Log To Console    set nrcellgrp parameter
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-0
    ...    filter_param=List of NR cells assigned to cell group   node_index=${0}    new_value=1    abbr=nrCellList
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-1
    ...    filter_param=List of NR cells assigned to cell group   node_index=${0}    new_value=2    abbr=nrCellList
    selenium_coam.add_element    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group    abbr=refNrCellGroup
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group    new_value=0    node_index=${1}    abbr=refNrCellGroup
    selenium_coam.add_element    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group    abbr=refNrCellGroup
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group    new_value=1    node_index=${2}    abbr=refNrCellGroup
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-0
    ...    filter_param=Number of transmitted Synchronization Signal Blocks
    ...    node_index=${0}    new_value=1 beam    abbr=numberOfTransmittedSsBlocks
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-1
    ...    filter_param=Number of transmitted Synchronization Signal Blocks
    ...    node_index=${0}    new_value=1 beam    abbr=numberOfTransmittedSsBlocks
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-2
    ...    filter_param=Number of transmitted Synchronization Signal Blocks
    ...    node_index=${0}    new_value=1 beam    abbr=numberOfTransmittedSsBlocks
    #add channelgrp
    Log To Console    add channelgrp
    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1    object_class_name=LCELNR
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3    id_value=1
    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1    object_class_name=CHANNELGROUP
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1
    ...    include_subobject=${TRUE}    id_value=1
    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1    object_class_name=LCELNR
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3    id_value=2
    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2    object_class_name=CHANNELGROUP
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-2
    ...    include_subobject=${TRUE}    id_value=2
    sleep    3s

Delete Supercell Configuration
    Log To Console    delete supercell channelgroup
    selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1
    selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-2
    Log To Console    set actsupercell value
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Activate super cell   new_value=false    abbr=actSuperCell
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...    filter_param=Activate super cell   new_value=false    abbr=actSuperCell
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    ...    filter_param=Activate super cell   new_value=false    abbr=actSuperCell

Delete TL5 Channelgroup
    WEBUI Login
    Log To Console    delete channelgroup
    selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    Log To Console    Activate plan
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    [Teardown]    WEBUI Logout

Add TL5 Channelgroup
    WEBUI Login
    Log To Console    add channelgroup
    Wait Until Keyword Succeeds    3x    2min
    ...    selenium_coam.add_object
    ...    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3    object_class_name=CHANNELGROUP
    ...    id_value=1    is_load_default_values=${TRUE}
    _set_channelgroup_parameter
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    Log To Console    Activate plan
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    [Teardown]    WEBUI Logout

_set_channelgroup_parameter
    Log To Console    set channelgrp parameter
    @{antl_value_list}    create list    ${1}    ${1}    ${2}    ${2}    ${3}    ${3}    ${4}    ${4}
    FOR    ${item}    IN RANGE    ${8}
        ${result}    evaluate    ${item} % ${2}
        ${direction}     set variable if    ${result} == ${0}    TX    RX
        ${index}    evaluate    ${item} + 1
        ${antlDN_value}    set variable    MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-1/ANTL-${antl_value_list}[${item}]
        Wait Until Keyword Succeeds    3x    2min
        ...    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1
        ...    object_class_name=CHANNEL    id_value=${index}    is_load_default_values=${TRUE}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-${index}
        ...    filter_param=Distinguished Name of antenna line   new_value=${antlDN_value}    abbr=antlDN
        selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-${index}
        ...    filter_param=Direction of the channel   new_value=${direction}    abbr=direction
    END

Modify Default gNBCellid
    [Arguments]    ${Actual_value}    ${LNCEL_idx}=${54726}    ${connection}=default
    Log To Console     Modify Default gNBCellid
    SBTS Login    ip_address=${eNB_OAM_IP}    alias=${connection}
    ${dict}    create dictionary    parameterName=defaultLnRelGnbCellId    operation=update    value=${Actual_value}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${eNB_BTS_ID}/LNBTS-${eNB_NRBTS_ID}/LNCEL-${LNCEL_idx}    parameter=${list}
    ...    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
    sleep    3s
    Wait Until BTS Should Be Normal    alias=${connection}
    [Teardown]    SBTS Logout    alias=${connection}

Get Active Alarm List
    [Arguments]    ${connection}=default
    Log To Console    Get Active Alarm List
    ${alarm_info}    coam.get_active_alarms    timeout=60    connection=${connection}
    ${faultid_list}    create list
    FOR    ${item}    IN    @{alarm_info}
        ${fault_id_dic}    get from dictionary    ${item}    additionalFaultID
        append to list    ${faultid_list}    ${fault_id_dic}
    END
    sort list    ${faultid_list}
    [Return]    ${faultid_list}

Check RMOD Status
    [Arguments]    ${expected_RU}    ${connection}=default    ${number}=${3}    ${expect_admin_status}=Unlocked
    ...    ${expect_operate_status}=enabled    ${expect_usage_status}=Active    ${expect_procedure_status}=configured
    Log To Console    Check RMOD Status
    ${rf_list}    coam.get_frm    connection=${connection}
    FOR    ${item}    IN RANGE     ${number}
        ${serial_number}    get from dictionary    ${rf_list[${item}]}    serialNumber
        ${Fiber_status}    run keyword if    '${serial_number}' == '${expected_RU}'
        ...    get from dictionary    ${rf_list[${item}]}    status
        exit for loop if    '${serial_number}' == '${expected_RU}'
    END
    ${admin_status}    get from dictionary    ${Fiber_status}    administrativeState
    should be equal as strings   ${admin_status}    ${expect_admin_status}
    ${operate_status}    get from dictionary    ${Fiber_status}    operationalState
    should be equal as strings    ${operate_status}    ${expect_operate_status}
    ${usage_status}    get from dictionary    ${Fiber_status}    usageState
    should be equal as strings    ${usage_status}    ${expect_usage_status}
    ${procedure_status}    get from dictionary    ${Fiber_status}    proceduralStatus
    should be equal as strings    ${procedure_status}    ${expect_procedure_status}

Check Cells Status
    [Arguments]    ${cell_info}    ${all_cell_info}=${all_cell_info}    ${connection}=default    ${operational_status}=enabled
    ...    ${usage_status}=Active    ${block_status}=Unblocked    ${lock_status}=Unlocked
    Log To Console    Check Cells Status
    ${cell_status}     coam.Get_Cells_Info   cell_type=nr    connection=${connection}
    FOR    ${item}    IN    @{all_cell_info}
        ${gcellid}    Get From Dictionary    ${cell_status[${item}]}    globalCellId
        ${gcellid_status}    run keyword and return status    list should contain value    ${cell_info}    ${gcellid}
        run keyword if    ${gcellid_status}    _check_cell_status    cells_status=${cell_status[${item}]}
        ...    operational_status=${operational_status}    usage_status=${usage_status}
        ...    block_status=${block_status}    lock_status=${lock_status}
    END

_check_cell_status
    [Arguments]    ${cells_status}    ${operational_status}    ${usage_status}    ${block_status}    ${lock_status}
    ${Status}    Get From Dictionary    ${cells_status}    status
    ${tmp}   Get From Dictionary    ${status}    operationalState
    should be equal as strings    ${tmp}    ${operational_status}    ignore_case=${True}
    ${tmp}   Get From Dictionary    ${status}   usageState
    should be equal as strings    ${tmp}    ${usage_status}
    ${tmp}   Get From Dictionary    ${status}   blockingState
    should be equal as strings    ${tmp}    ${block_status}
    ${tmp}   Get From Dictionary    ${status}   administrativeState
    should be equal as strings    ${tmp}    ${lock_status}

Check Expected Alarm
    [Arguments]    ${faultID}    ${expected_alarmid}    ${expected_objectname}    ${connection}=default
    Log To Console    Check FaultID
    ${alarm_info}    coam.get_active_alarms    timeout=60    connection=${connection}
    ${dic_attribute}    set variable    ${None}
    FOR    ${item}    IN    @{alarm_info}
        ${fault_id_dic}    get from dictionary    ${item}    additionalFaultID
        ${alarm_id}    run keyword if    '${fault_id_dic}' == '${faultID}'
        ...    get from dictionary    ${item}    alarmId
        ${dic_objiectname}    run keyword if    '${fault_id_dic}' == '${faultID}'
        ...    get from dictionary    ${item}    configObjectName
        ${objectname_status}    run keyword and return status    should contain    ${dic_objiectname}    ${expected_objectname}
        exit for loop if    '${objectname_status}' == 'True'
    END
    should be true    '${alarm_id}' == '${expected_alarmid}'

Check No Expected Alarm
    [Arguments]    ${connection}=default    ${fault_id}=${10}
    Log To Console    Check No Expected Alarm
    ${alarm_info}    coam.get_active_alarms    timeout=60    connection=${connection}
    ${fault_id_list}    create list
    FOR    ${item}    IN    @{alarm_info}
        ${fault_id_dic}    get from dictionary    ${item}    additionalFaultID
        append to list    ${fault_id_list}    ${fault_id_dic}
    END
    sort list    ${fault_id_list}
    list should not contain value    ${fault_id_list}    ${fault_id}

Check Subcell Status
    [Arguments]    ${expected_list_length}    ${alias}=default    ${cell_type }=nr
    Log To Console    Check Subcell Status
    SBTS Login
    ${cell_status}     coam.Get_Cells_Info   cell_type=${cell_type}    connection=${alias}
    ${subcelllist}    Get From Dictionary    ${cell_status}[0]    subCellList
    ${list_length}    get length    ${subcelllist}
    should be equal as numbers    ${list_length}    ${expected_list_length}
    [Teardown]    SBTS Logout

Adapt to ute cloud commission scf
    ${TL_NAME}   set variable if      '${testline_name}' == '${EMPTY}'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME_1}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${TLNAME_name}   Set Variable    7_5${TLNAME_1}[0]
    Set Suite Variable    ${default_scf_path}    ${CURDIR}/../../../../../../commissionings/HGZ/${TLNAME_name}/

Adapt to ute cloud enb info
    ${is_ute_cloud}   set variable if     '${testline_name}' == '${EMPTY}'    ${True}    ${False}
    ${eNB_IP_tmp}    set variable if    ${is_ute_cloud}    10.101.49.54    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
    ${eNB_BTS_ID_tmp}    set variable if    ${is_ute_cloud}    10842    ${tl.enbs[0].instance_id}
    ${eNB_NRBTS_ID_tmp}    set variable if    ${is_ute_cloud}    10842    ${tl.enbs[0].global_bts_id}
    Set Suite Variable    ${eNB_OAM_IP}    ${eNB_IP_tmp}
    Set Suite Variable    ${eNB_BTS_ID}    ${eNB_BTS_ID_tmp}
    Set Suite Variable    ${eNB_NRBTS_ID}    ${eNB_NRBTS_ID_tmp}
