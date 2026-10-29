*** Settings ***
Documentation
...              tingting.zhong@nokia-sbell.com

Library          taf.selenium.sbts   WITH NAME    selenium_coam
Library          ./sleepingcell_download_package.py
Library          ./sleepingcell_common.py
Resource         ./sleepingcell_check_status.robot
Resource         ./sleepingcell_ue.robot

*** Variables ***
${DU_OAM_IP}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_WEBUI_USER}         ${tl.gnbs[0].cu.oam_http_connection_details.username}
${DU_OAM_WEBUI_PASSWORD}     ${tl.gnbs[0].cu.oam_http_connection_details.password}
${ASIK_username}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_password}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${gnb_ID}                    ${tl.gnbs[0].global_bts_id}

*** Keywords ***
RMOD reset via WEBUI and L3 Call
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]    ${duration}=${60}   ${connection}=GNB_OAM    ${gnb_type}=${gNb_CuType}
    Log to console    \nRMOD reset via WEBUI and L3 Call
    ${before_active_fault_list}    Get Alarm Fault Id List   alarm_type=active    connection=${connection}
    ${before_history_fault_list}    Get Alarm Fault Id List   alarm_type=history    connection=${connection}
    ${ru_index_list}  Get All RU Index    connection=${connection}
    FOR  ${ru_index}  IN  @{ru_index_list}
        log to console    \n***RF ${ru_index} Reset from GUI***
        ${ru_index}  Convert To Integer    ${ru_index}
        selenium_coam.reset_ru  ru_index=${ru_index}
        Wait Until Keyword Succeeds    5min    5s    RU Should Be Offline    ru_index=${ru_index}    connection=${connection}
    END
    Check status after rmod reset
    ...    before_active_fault_list=${before_active_fault_list}    before_history_fault_list=${before_history_fault_list}
    ...    gnb_type=${gnb_type}    connection=${connection}
    Make L3 Call With RU List    ru_index_list=${ru_index_list}

RMOD Power Reset and L3 Call
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]    ${duration}=${60}    ${connection}=GNB_OAM    ${gnb_index}=0    ${gnb_type}=${gNb_CuType}
    Log to console    \nRMOD Power Reset and L3 Call
    ${before_active_fault_list}    Get Alarm Fault Id List   alarm_type=active    connection=${connection}
    ${before_history_fault_list}    Get Alarm Fault Id List   alarm_type=history    connection=${connection}
    ${init_ru_num}    get length    ${tl.gnbs[${gnb_index}].dus[0].rus}
    FOR    ${ru_index}    IN RANGE    1    ${init_ru_num}+1
        log to console    \n***RF Index ${ru_index-1} in Testline File Power OFF***
        Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        sleep    30
    END
    FOR    ${ru_index}    IN RANGE    1    ${init_ru_num}+1
        log to console    \n***RF Index ${ru_index-1} in Testline File Power ON***
        Perform RU Power on    ru_index=${ru_index}    model=${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
    END
    Check status after rmod power reset
    ...    before_active_fault_list=${before_active_fault_list}    before_history_fault_list=${before_history_fault_list}
    ...    gnb_type=${gnb_type}    connection=${connection}
    ${ru_index_list}  Get All RU Index    connection=${connection}
    Make L3 Call With RU List    ru_index_list=${ru_index_list}

BBMOD reset via WEBUI and L3 Call
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]    ${duration}=${60}    ${connection}=GNB_OAM    ${gnb_type}=${gNb_CuType}
    Log to console    \nBBMOD reset via WEBUI and L3 Call
    ${before_active_fault_list}    Get Alarm Fault Id List   alarm_type=active    connection=${connection}
    ${before_history_fault_list}    Get Alarm Fault Id List   alarm_type=history    connection=${connection}
    ${bbmod_index_list}    get all bbmod index    connection=${connection}
    FOR  ${bbmod_index}  IN  @{bbmod_index_list}
        log to console    \n***BBMOD ${bbmod_index} Reset from GUI***
        selenium_coam.reset_baseband    baseband_index=${bbmod_index}    timeout=30
        Wait Until Keyword Succeeds    5min    5s    bbmod Should Be Offline    bbmod_index=${bbmod_index}
    END
    Check status after bbmod reset
    ...    before_active_fault_list=${before_active_fault_list}    before_history_fault_list=${before_history_fault_list}
    ...    gnb_type=${gnb_type}    connection=${connection}
    ${ru_index_list}  Get All RU Index    connection=${connection}
    Make L3 Call With RU List    ru_index_list=${ru_index_list}

SITE reset via WEBUI and L3 Call
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]    ${duration}=${60}    ${connection}=GNB_OAM    ${gnb_index}=0    ${gnb_type}=${gNb_CuType}
    Log to console    \nSITE reset via WEBUI and L3 Call
    ${before_active_fault_list}    Get Alarm Fault Id List   alarm_type=active    connection=${connection}
    ${before_history_fault_list}    Get Alarm Fault Id List   alarm_type=history    connection=${connection}
    log to console    \n***SITE Reset from GUI***
    selenium_coam.reset_site
    Wait Until Keyword Succeeds    3min    5s    Check GNB Ping Disable    gnb_index=${gnb_index}
    Wait Until Keyword Succeeds    3min    5s    Check GNB Ping Enable    gnb_index=${gnb_index}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    Check status after site reset
    ...    before_active_fault_list=${before_active_fault_list}    before_history_fault_list=${before_history_fault_list}
    ...    gnb_type=${gnb_type}    connection=${connection}
    ${ru_index_list}  Get All RU Index    connection=${connection}
    Make L3 Call With RU List    ru_index_list=${ru_index_list}

Lock or Unlock Cell Action
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    ...    action=Locked/Unlocked
    ...    MRBTS/NRBTS/NRCELL.administrativeState=Locked/Unlocked
    [Arguments]     ${cell_list}    ${action}=Locked
    FOR     ${cell_id}    IN     @{cell_list}
        ${dist_name}     set variable     MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_id}
        ${filter_param}    set variable    Administrative state
        selenium_coam.set_parameter_value
        ...    dist_name=${dist_name}    filter_param=${filter_param}   new_value=${action}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}

All cells lock action from BTS WEBUI and L3 Call
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${duration}=${60}    ${connection}=GNB_OAM    ${gnb_type}=${gNb_CuType}
    Log to console    \nAll cells lock action from BTS WEBUI and L3 Call
    ${before_active_fault_list}    Get Alarm Fault Id List   alarm_type=active    connection=${connection}
    ${before_history_fault_list}    Get Alarm Fault Id List   alarm_type=history    connection=${connection}
    ${cell_list}     Get All Cell Id    connection=${connection}
    log to console    \n***Modify Cells Administrative from GUI***
    Lock or Unlock Cell Action    cell_list=${cell_list}    action=Locked
    FOR     ${cell_id}    IN     @{cell_list}
        Wait until keyword succeeds    1min   10s    Check Cell Administrative State    cell_id=${cell_id}    administrative_state=locked
        ...    connection=${connection}
    END
    Lock or Unlock Cell Action    cell_list=${cell_list}    action=Unlocked
    FOR     ${cell_id}    IN     @{cell_list}
        Wait until keyword succeeds    2min   10s    Check Cell Administrative State    cell_id=${cell_id}    administrative_state=unlocked
        ...    connection=${connection}
    END
    Check status after cell lock unlcok
    ...    before_active_fault_list=${before_active_fault_list}    before_history_fault_list=${before_history_fault_list}
    ...    gnb_type=${gnb_type}    connection=${connection}
    ${ru_index_list}     Get All RU Index    connection=${connection}
    Make L3 Call With RU List    ru_index_list=${ru_index_list}

Check Cell Administrative State
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${cell_id}   ${administrative_state}=locked    ${connection}=GNB_OAM
    ${cellgrp_id}   Get Cell Group From Cell   cell_id=${cell_id}    connection=${connection}
    ${subcells_status}    coam.get_subcells_status   timeout=15    connection=${connection}
    ${administrative}    set variable    ${subcells_status["NRCELLGRP-${cellgrp_id}"]["NRCELL-${cell_id}"]["NRCELL_R"]["administrativeState"]}
    should be equal as strings    ${administrative.lower()}    ${administrative_state}

All rus lock action from BTS WEBUI and L3 Call
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${duration}=${60}    ${connection}=GNB_OAM    ${gnb_type}=${gNb_CuType}
    Log to console    \nAll rus lock action from BTS WEBUI and L3 Call
    ${before_active_fault_list}    Get Alarm Fault Id List   alarm_type=active    connection=${connection}
    ${before_history_fault_list}    Get Alarm Fault Id List   alarm_type=history    connection=${connection}
    ${ru_index_list}     Get All RU Index    connection=${connection}
    FOR    ${ru_index}    IN    @{ru_index_list}
        log to console    \n***RF ${ru_index} Lock from GUI***
        selenium_coam.lock_ru  ru_index=${ru_index}
        wait until keyword succeeds  5min  20sec  RU Should Be Locked  ru_index=${ru_index}    connection=${connection}
    END
    FOR    ${ru_index}    IN    @{ru_index_list}
        log to console    \n***RF ${ru_index} UnLock from GUI***
        selenium_coam.unlock_ru  ru_index=${ru_index}
    END
    FOR    ${ru_index}    IN    @{ru_index_list}
        wait until keyword succeeds  5min  20sec  RU Should Be UnLocked  ru_index=${ru_index}    connection=${connection}
    END
    Check status after rmod lock unlock
    ...    before_active_fault_list=${before_active_fault_list}    before_history_fault_list=${before_history_fault_list}
    ...    gnb_type=${gnb_type}    connection=${connection}
    Make L3 Call With RU List    ru_index_list=${ru_index_list}

BTS lock action from BTS WEBUI and L3 Call
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${duration}=${60}    ${connection}=GNB_OAM    ${gnb_type}=${gNb_CuType}
    Log to console    \nBTS lock action from BTS WEBUI and L3 Call
    ${before_active_fault_list}    Get Alarm Fault Id List   alarm_type=active    connection=${connection}
    ${before_history_fault_list}    Get Alarm Fault Id List   alarm_type=history    connection=${connection}
    ${dist_name}    Get NRDU distname    connection=${connection}
    log to console    \n***Admin API Lock BTS***
    coam.lock    dist_name=${dist_name}    timeout=120    connection=${connection}
    ${cell_list}    get all cell id    connection=${connection}
    FOR     ${cell_id}    IN     @{cell_list}
        Wait until keyword succeeds    1min   10s    Check cell should be disabled    cell_id=${cell_id}   connection=${connection}
    END
    coam.unlock    dist_name=${dist_name}    timeout=120    connection=${connection}
    Check status after bts lock unlock
    ...    before_active_fault_list=${before_active_fault_list}    before_history_fault_list=${before_history_fault_list}
    ...    gnb_type=${gnb_type}    connection=${connection}
    ${ru_index_list}     Get All RU Index    connection=${connection}
    Make L3 Call With RU List    ru_index_list=${ru_index_list}

BTS Block action from BTS WEBUI and L3 Call
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    [Arguments]  ${duration}=${60}    ${connection}=GNB_OAM    ${gnb_type}=${gNb_CuType}
    Log to console    \nBTS lock action from BTS WEBUI and L3 Call
    ${before_active_fault_list}    Get Alarm Fault Id List   alarm_type=active    connection=${connection}
    ${before_history_fault_list}    Get Alarm Fault Id List   alarm_type=history    connection=${connection}
    log to console    \n***Admin API BLock BTS***
    coam.block         timeout=120    connection=${connection}
    ${cell_list}    get all cell id    connection=${connection}
    FOR     ${cell_id}    IN     @{cell_list}
        Wait until keyword succeeds    1min   10s    Check cell should be disabled    cell_id=${cell_id}   connection=${connection}
    END
    coam.unblock       timeout=240    connection=${connection}
    Check status after bts block unblock
    ...    before_active_fault_list=${before_active_fault_list}    before_history_fault_list=${before_history_fault_list}
    ...    gnb_type=${gnb_type}    connection=${connection}
    ${ru_index_list}     Get All RU Index    connection=${connection}
    Make L3 Call With RU List    ru_index_list=${ru_index_list}

Get NRDU distname
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM
    ${bts_info}    coam.get_bts_info    connection=${connection}
    ${nrdu}    set variable     ${bts_info['nrDU'][0]}
    ${dist_name}    set variable    ${nrdu['id']['configuration']}
    [Return]  ${dist_name}

rollback or upgrade and L3 Call
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]    ${package}    ${package_path}   ${any_value}=${800}   ${connection}=GNB_OAM
    log to console  \nupgrade_target_package:${package} 
    Connect to gnb coam via ssl    connection=${connection}	
    ${status}    rollback_if_needed    connection=${connection}		
	run keyword if    not ${status}    
	...    coam.update_software     sw_package=${package_path}     should_activate=True    timeout=900   connection=${connection}     
    sleep    5min
    COAM Teardown gnb connections    connection=${connection}
    wait until keyword succeeds    5min    10sec    Connect to gnb coam via ssl    connection=${connection}
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'    connection=${connection}
	Check SW version with external package value    package_target_version=${package}
	${operation}    set variable if    ${status}    rollback    upgrade  
    log to console    \n${operation} to ${package} finished and onair!!!
#    ${ru_index_list}  Get All RU Index    connection=${connection}
    Change physCellId parameter value    physCellId_value=${any_value}    globalCellId=${modify_cell_id}
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${cell_list}    Get All Cell Id    ru_index=${ru_index}    connection=${connection}
        Make L3 Call   cell_list=${cell_list}
    END
    [Teardown]      Change physCellId parameter value    physCellId_value=${modify_physicalCellId}    globalCellId=${modify_cell_id}

Check SW version with external package value
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    ...    this KW is to check the SW version when the download version is from the external value
    [Arguments]     ${package_target_version}    ${connection}=GNB_OAM
    ${version}    wait until keyword succeeds    2min   15s    coam.get_sw_version    connection=${connection}
    should be equal as strings    ${package_target_version}    ${version}
    [Return]    ${version}

Calculate Loop Time
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    ...    total_time:  h/m/s
    [Arguments]     ${total_time}
    ${unit}    Get Substring    ${total_time}    -1
    ${value}    Get Substring    ${total_time}    0    -1
    ${value}    convert to integer    ${value}
    ${times}    run keyword if    '${unit}'=='h'    set variable    ${3600}
    ...    ELSE IF    '${unit}'=='m'    set variable    ${60}
    ${total_time}    evaluate    ${value}*${times}
    log to console    get seconds time: ${total_time}s
    [Return]  ${total_time}

Change physCellId parameter value
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    [Arguments]    ${physCellId_value}    ${globalCellId}    ${connection}=GNB_connection
    log to console    Modify parameter
    Connect to gnb coam via ssl     bts_host=${DU_OAM_IP}      connection=${connection}
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${gnb_ID}/NRBTS-${gnb_ID}/NRCELL-${globalCellId}   parameter=physCellId   value=${physCellId_value}
    ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
    log to console  COAM Wait gnb And Cells ready
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'    connection=${connection}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Collect Snapshot
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    [Arguments]  ${log_number}=10
    ${rm_active_package}    Catenate    python ${CURDIR}/snapshot.py ${DU_OAM_IP} ${log_number} ${OUTPUT_DIR} &
    Start Process     ${rm_active_package}     shell=True
    sleep    10s

Kill Snapshot Process
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    OperatingSystem.Run    ps -ef | grep snap | grep -v grep | awk '{print $2}' | xargs kill -9

Check Snapshot is not Empty
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    ${snapshot_name}    sleepingcell_common.get_snapshot_filename    filepath=${OUTPUT_DIR}
    ${empty_num}      set variable      ${0}
    FOR   ${snapshot}    IN   @{snapshot_name}
        ${empty_status}    Run Keyword And Return Status    File Should Not Be Empty    ${OUTPUT_DIR}/${snapshot}
        ${empty_num}    Run Keyword If     not ${empty_status}     Evaluate    ${empty_num}+1
        ...    ELSE    set variable    ${empty_num}
    END
    Run Keyword And Continue On Failure    should be true      ${empty_num}<=1

Get RAT Cell Id
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    ...         ru_index=None: get all gnb cells, ru_index=ru_index: get all cells under RU
    ...         param str cell_type: Cell type of given RAT: "lte", "nr".
    [Arguments]  ${cell_type}    ${ru_index}=${None}  ${connection}=GNB_OAM
    ${output}    coam.get_cells_info    cell_type=${cell_type}    connection=${connection}
    ${cell_list}      create list
    FOR  ${cell}  IN  @{output}
        run keyword if  ${ru_index}==${None}    append to list  ${cell_list}  ${cell['globalCellId']}
        ${carrier}    set variable  ${cell['carrierList'][0]}
        ${status}  run keyword if  ${ru_index}!=${None}    run keyword and return status
                   ...    should contain  ${carrier['antennaLineId']['configuration']}    RMOD-${ru_index}
        run keyword if    ${status}    append to list  ${cell_list}  ${cell['globalCellId']}
    END
    Sort List   ${cell_list}
    [Return]  ${cell_list}

Verify Enb Type Cells Status
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    ...                :param str cell_type: Cell type of given RAT: "lte", "wcdma", "gsm".
    [Arguments]    ${connection}    ${cell_type}=lte    ${timeout}=120    ${if_enable}=${True}
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${disabled}    Set Variable If    ${result}    Disabled    disabled
    ${operationalState}    Set Variable If    ${if_enable}    ${enabled}    ${disabled}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    FOR    ${cell}    IN    @{cell_list}
        Run Keyword And Continue On Failure
        ...    Should Be Equal As Strings    ${cell_list_info['${cell}']['operationalState']}    ${operationalState}
    END

Verify Gnb Type Cells Status should be disabled
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    [Arguments]   ${connection}     ${cell_type}=nr
    ${cell_list}    Get RAT Cell Id     cell_type=${cell_type}    connection=${connection}
    FOR     ${cell_id}    IN     @{cell_list}
        Wait until keyword succeeds    1min   10s    Check cell should be disabled    cell_id=${cell_id}   connection=${connection}
    END

Check SRAN GNB and ENB cell onair
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM
    COAM Wait gnb And Cells ready    connection=${connection}
    Wait until keyword succeeds    10min   10s    Verify Enb Type Cells Status    connection=${connection}   if_enable=${True}

Check fault id should be appear
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    [Arguments]   ${connection}    ${check_fault_id}
    ${active_fault_list}    Get Alarm Fault Id List   alarm_type=active    connection=${connection}
    run keyword and continue on failure    list should contain value      ${active_fault_list}     ${check_fault_id}

RAT Block and UnBlock then L3 Call
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    ...                param str rat: rat of given RAT: "LTE", "NR".
    [Arguments]    ${rat}   ${dl_nrcell_id}   ${ul_nrcell_id}   ${connection}=GNB_OAM    ${gnb_type}=${gNb_CuType}    ${timeout}=600
    Log to console    \nRAT Block and UnBlock then L3 Call
    Connect to gnb coam via ssl    connection=${connection}
    Check SRAN GNB and ENB cell onair     connection=${connection}
    ${before_active_fault_list}    Get Alarm Fault Id List   alarm_type=active    connection=${connection}
    ${before_history_fault_list}    Get Alarm Fault Id List   alarm_type=history    connection=${connection}
    log to console    \n***Admin API BLock RAT***
    coam.block_rat       rat=${rat}     timeout=${timeout}    connection=${connection}
    run keyword if    '${rat}'=='LTE'
    ...    Wait until keyword succeeds    2min   10s    Verify Enb Type Cells Status   if_enable=${False}    connection=${connection}
    ...    ELSE      Verify Gnb Type Cells Status should be disabled     connection=${connection}
    Wait until keyword succeeds    3min   20s     Check fault id should be appear    connection=${connection}    check_fault_id=${4614}
    coam.unblock_rat     rat=${rat}       timeout=${timeout}    connection=${connection}
    Check SRAN GNB and ENB cell onair     connection=${connection}
    Check status after RAT block unblock and RAT Reset
    ...    before_active_fault_list=${before_active_fault_list}    before_history_fault_list=${before_history_fault_list}
    ...    gnb_type=${gnb_type}    connection=${connection}
    Attach power ue
    Start power ue traffic ul and dl
    sleep    3s
    Check throughput power ue    dl_nrcell_id=${dl_nrcell_id}    ul_nrcell_id=${ul_nrcell_id}
    Stop power ue traffic ul and dl
    [Teardown]    run keywords
    ...    run keyword and ignore error     coam.unblock_rat     rat=${rat}       timeout=${timeout}    connection=${connection}
    ...    AND    Detach power ue     AND    COAM Teardown gnb connections

RAT Reset then L3 Call
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    ...                :param str rat_type: RAT name - NR, LTE, WCDMA or GSM
    [Arguments]    ${rat_type}    ${dl_nrcell_id}   ${ul_nrcell_id}    ${connection}=GNB_OAM    ${gnb_type}=${gNb_CuType}   ${timeout}=600
    Log to console    \nRAT Reset then L3 Call
    Connect to gnb coam via ssl    connection=${connection}
    Check SRAN GNB and ENB cell onair    connection=${connection}
    ${before_active_fault_list}    Get Alarm Fault Id List   alarm_type=active    connection=${connection}
    ${before_history_fault_list}    Get Alarm Fault Id List   alarm_type=history    connection=${connection}
    log to console    \n***Admin API RAT Reset***
    coam.rat_reset       rat_type=${rat_type}     timeout=${timeout}    connection=${connection}
    Check SRAN GNB and ENB cell onair     connection=${connection}
    Check status after RAT block unblock and RAT Reset
    ...    before_active_fault_list=${before_active_fault_list}    before_history_fault_list=${before_history_fault_list}
    ...    gnb_type=${gnb_type}    connection=${connection}
    Attach power ue
    Start power ue traffic ul and dl
    sleep    3s
    Check throughput power ue    dl_nrcell_id=${dl_nrcell_id}    ul_nrcell_id=${ul_nrcell_id}
    Stop power ue traffic ul and dl
    [Teardown]    run keywords     Detach power ue     AND    COAM Teardown gnb connections

Connect to SMOD with ssh From main board to auxiliary board
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    [Arguments]     ${timeout}=240s    ${alias_gnb}=gnb_connect    ${connection_bbmod}=bbmod_connect
    csn.Connect to    hostname=${DU_OAM_IP}    username=${ASIK_username}    password=${ASIK_password}
    ...    alias=${alias_gnb}    timeout=${timeout}
    csn.Connect to    hostname=fct4s0icom.local    username=${ASIK_username}    password=${ASIK_password}
    ...    proxy=${alias_gnb}    alias=${connection_bbmod}    timeout=${timeout}

Disconnect SMOD with ssh
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    [Arguments]      ${alias_gnb}=gnb_connect    ${connection_bbmod}=bbmod_connect
    csn.disconnect    connection=${connection_bbmod}
    csn.disconnect    connection=${alias_gnb}

Get SFPD ID
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    [Arguments]     ${timeout}=240s    ${connection_bbmod}=bbmod_connect
    ${sfpd}    csn.Execute    command=bsh 1:2 syscomctl stats list client | grep sfpd | cut -d " " -f 1
    ...    connection=${connection_bbmod}    timeout=${timeout}
    ${sfpd}    Strip String    ${sfpd}
    ${sub_sfpd}    Get Substring    ${sfpd}    0    4
    [Return]     ${sub_sfpd}

Get TransceiverTXBiasCurrent value
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    ...                :param switch: 1: turn off,  0: turn on
    ...                :param S_RF: 3: S_RF1,  4: S_RF2
    [Arguments]     ${sfpd}    ${S_RF}    ${connection_bbmod}=bbmod_connect    ${timeout}=240s
    ${Transceiver}    csn.Execute    command=bsh 1:2 sfp_tester get_pti ${S_RF} ${sfpd} | grep Bias | grep TransceiverTXBiasCurrent |cut -d " " -f 2
    ...    connection=${connection_bbmod}    timeout=${timeout}
    ${Transceiver}    Strip String    ${Transceiver}
    [Return]   ${Transceiver}

Change two optical transmission by command
    [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
    ...                :param switch: 1: turn off,  0: turn on
    ...                :param S_RF: 3: S_RF1,  4: S_RF2
    [Arguments]     ${sfpd}    ${alias_gnb}=gnb_connect    ${connection_bbmod}=bbmod_connect
    ...    ${S_RF1}=3   ${S_RF2}=4   ${switch}=1     ${timeout}=240s
    csn.Execute    command=bsh 1:2 sfp_tester set_tx ${S_RF1} 1 ${switch} ${sfpd}    connection=${connection_bbmod}    timeout=${timeout}
    csn.Execute    command=bsh 1:2 sfp_tester set_tx ${S_RF2} 1 ${switch} ${sfpd}    connection=${connection_bbmod}    timeout=${timeout}
    sleep   3s
    ${Transceiver1}    Get TransceiverTXBiasCurrent value    sfpd=${sfpd}   S_RF=${S_RF1}
    ${Transceiver2}    Get TransceiverTXBiasCurrent value    sfpd=${sfpd}   S_RF=${S_RF2}
    run keyword if   '${switch}'=='0'    should be true    ${Transceiver1}>0    ELSE    should be true    ${Transceiver1}==0
    run keyword if   '${switch}'=='0'    should be true    ${Transceiver2}>0    ELSE    should be true    ${Transceiver2}==0

Get All Cell physicalCellId
    [Documentation]  ru_index=None: get all cell physicalCellId, ru_index=ru_index: get all physicalCellId under RU
    [Arguments]  ${ru_index}=${None}  ${connection}=GNB_OAM
    ${output}=    coam.get_cells_info    connection=${connection}
    Log Many      ${output}    level=DEBUG
    ${physicalCellId_list}  create list
    FOR  ${cell}  IN  @{output}
        run keyword if  ${ru_index}==${None}    append to list  ${cell_list}  ${cell['physicalCellId']}
        ${carrier}    set variable  ${cell['carrierList'][0]}
        ${status}  run keyword if  ${ru_index}!=${None}    run keyword and return status
                   ...    should contain  ${carrier['antennaLineId']['configuration']}    RMOD-${ru_index}
        run keyword if    ${status}    append to list  ${physicalCellId_list}  ${cell['physicalCellId']}
    END
    Sort List   ${physicalCellId_list}
    [Return]  ${physicalCellId_list}
