*** Settings ***
Documentation    This is common keywords for siso related cases used in team
...              Please do not modify the file without notification to author

Resource   e2e_common_KW_l3call.robot

*** Variables ***
#${ui_version}           S21UI3.1

*** Keywords ***
E2E_gNB_SiSo_RU_lock_and_unlock_by_RadioIndex_l3call
    [Documentation]
    ...    *************************************************************
    ...    operate RU lock and unlock by RU index and check l3call
    ...    *************************************************************
    ...    ru_index:            #RU or RUs to be tested
    ...    with_call:           #l3call before & after RU lock/unlock; ignore following arguments if ${False}
#   ...    with_peak=${False}   #TBD
    ...    cell_id:             #str; cell to make l3call; start from 1
    ...    ue_index:            #str; ue to make l3call in one cell; start from 0
    ...    ue_number:           #str; ue number to make l3call in one cell; start from 1
    ...    ui_version:          #UI version for samsung; used to initialize pointer variable
    ...    iperf_type:          #start ul traffic via_app for commercial ue other than via_command
    ...    protocol:            #traffic type is upd other than tcp
    ...    call_duration:       #str; call duration; unit is second (s)
    ...    dl_tp:               #used for DL iperf command; can be larger than theory peak tput
    ...    ul_tp:               #used for UL iperf command; can be larger than theory peak tput
    ...    dl_exp:              #DL expect tput; dl_exp=peak_dl_tp=peak from NRDIM if ${with_peak}=${True}
    ...    ul_exp:              #UL expect tput; Ul_exp=peak_ul_tp=peak from NRDIM if ${with_peak}=${True}
    ...    target_avg_percent:  #used to check real UL/DL AVG tput; pass if UE tput >= dl_exp(and ul_exp)*target_avg_percent
    ...    min_percent:         #used to check real UL/DL min tput; pass if UE tput >= dl_exp(and ul_exp)*min_percent
    ...    cell_and_peak_info:  #self defined dl_exp;ul_exp;avg_expect_rate=target_avg_percent;min_expect_rate=min_percent
           #if ${True} from generated peak info (NRDIM): dl_exp;ul_exp; and dl_expavg_expect_rate=0.9, min_expect_rate=0.8 by default
    [Arguments]   ${ru_index}=${1}
    ...           ${with_call}=${True}
#   ...           ${with_peak}=${False}
    ...           ${cell_id}=${1}
    ...           ${ue_index}=${0}
    ...           ${ue_number}=${1}
    ...           ${ui_version}=default
    ...           ${iperf_type}=via_app
    ...           ${protocol}=udp
    ...           ${call_duration}=${60}
    ...           ${dl_tp}=1600M
    ...           ${ul_tp}=100M
    ...           ${dl_exp}=300
    ...           ${ul_exp}=20
    ...           ${target_avg_percent}=0.5
    ...           ${min_percent}=0.1
    ...           ${cell_and_peak_info}=${None}

    log to console    \nE2E_gNB_SiSo_RU_lock_and_unlock_by_RadioIndex: RU_${ru_index}
    Selenium Login And Disable Screen Lock
    ${ru_index_list}    get all ru index
    ${ru_num}    get length  ${ru_index_list}
    Get X2 link shutdown waiting time
    ${check_alarm}    set variable if    ${ru_num}==1    ${True}    ${False}
    ${cell_list}    get all cell id    ru_index=${ru_index}
#    run keyword if   ${with_call}   Get UE From Init File and Make call    cell_list=${cell_list}
#    ...    with_peak=${with_peak}    duration=${call_duration}

    ${result}   Run Keyword And Return Status    List Should Contain Value   ${cell_list}   ${cell_id}
    Run Keyword If   '${result}'=='True' and '${with_call}'=='True'    _e2e UE L3 Call And Throughput
    ...    cell_id=${cell_id}   ue_index=${ue_index}
    ...    ue_number=${ue_number}   ui_version=${ui_version}  duration=${call_duration}   iperf_type=${iperf_type}
    ...    protocol=${protocol}   dl_tp=${dl_tp}   ul_tp=${ul_tp}   dl_exp=${dl_exp}    ul_exp=${ul_exp}
    ...    cell_and_peak_info=${cell_and_peak_info}   target_avg_percent=${target_avg_percent}   min_percent=${min_percent}

    run keyword and continue on failure    Create file in RU    ru_index=${ru_index}
    ${ru_index_list_tmp}    create list    ${ru_index}
    Lock all RUs and check status    ru_index_list=${ru_index_list_tmp}    check_alarm=${check_alarm}
    ...    gnb_type='${gNb_CuType}'
    Unlock all RUs and check status    ru_index_list=${ru_index_list_tmp}    check_alarm=${check_alarm}
    ...    gnb_type='${gNb_CuType}'
    run keyword and continue on failure    Check file Exist in RU    ru_index=${ru_index}
#    run keyword if   ${with_call}   Get UE From Init File and Make call    cell_list=${cell_list}
#    ...    with_peak=${with_peak}    duration=${call_duration}

    ${result}   Run Keyword And Return Status    List Should Contain Value   ${cell_list}   ${cell_id}
    Run Keyword If   '${result}'=='True' and '${with_call}'=='True'    _e2e UE L3 Call And Throughput
    ...    cell_id=${cell_id}   ue_index=${ue_index}
    ...    ue_number=${ue_number}   ui_version=${ui_version}  duration=${call_duration}   iperf_type=${iperf_type}
    ...    protocol=${protocol}   dl_tp=${dl_tp}   ul_tp=${ul_tp}   dl_exp=${dl_exp}    ul_exp=${ul_exp}
    ...    cell_and_peak_info=${cell_and_peak_info}   target_avg_percent=${target_avg_percent}   min_percent=${min_percent}

    [Teardown]  Selenium Logout And Close Browser

E2E_gNB_SiSo_cell_block_and_unblock_by_RadioIndex_l3call
    [Documentation]
    ...    *************************************************************
    ...    operate cell block and unblock by RU index and check l3call
    ...    **************************************************************
    [Arguments]   ${ru_index}=${1}
    ...           ${with_call}=${True}
#   ...           ${with_peak}=${False}
    ...           ${cell_id}=${1}
    ...           ${ue_index}=${0}
    ...           ${ue_number}=${1}
    ...           ${ui_version}=default
    ...           ${iperf_type}=via_app
    ...           ${protocol}=udp
    ...           ${call_duration}=${60}
    ...           ${dl_tp}=1600M
    ...           ${ul_tp}=100M
    ...           ${dl_exp}=300
    ...           ${ul_exp}=20
    ...           ${target_avg_percent}=0.5
    ...           ${min_percent}=0.1
    ...           ${cell_and_peak_info}=${None}

    log to console    \nE2E_gNB_SiSo_cell_block_and_unblock_by_RadioIndex: RU_${ru_index}
    Selenium Login And Disable Screen Lock
    Get X2 link shutdown waiting time
    ${cell_id_list}    Get All Cell Id
    ${cell_num}    get length  ${cell_id_list}
    ${check_alarm}  set variable if  ${cell_num}==1  ${True}  ${False}
    ${cell_id_list_under_RU}    Get All Cell Id    ru_index=${ru_index}

    ${result}   Run Keyword And Return Status    List Should Contain Value   ${cell_id_list_under_RU}   ${cell_id}
    Run Keyword If   '${result}'=='True' and '${with_call}'=='True'    _e2e UE L3 Call And Throughput
    ...    cell_id=${cell_id}   ue_index=${ue_index}
    ...    ue_number=${ue_number}   ui_version=${ui_version}  duration=${call_duration}   iperf_type=${iperf_type}
    ...    protocol=${protocol}   dl_tp=${dl_tp}   ul_tp=${ul_tp}   dl_exp=${dl_exp}    ul_exp=${ul_exp}
    ...    cell_and_peak_info=${cell_and_peak_info}   target_avg_percent=${target_avg_percent}   min_percent=${min_percent}

    Cell block and unblock under specify RU    cell_list_under_RU=${cell_id_list_under_RU}   check_alarm=${check_alarm}
    #...    with_call=${with_call}    with_peak=${with_peak}    duration=${call_duration}

    Run Keyword If   '${result}'=='True' and '${with_call}'=='True'    _e2e UE L3 Call And Throughput
    ...    cell_id=${cell_id}   ue_index=${ue_index}
    ...    ue_number=${ue_number}   ui_version=${ui_version}  duration=${call_duration}   iperf_type=${iperf_type}
    ...    protocol=${protocol}   dl_tp=${dl_tp}   ul_tp=${ul_tp}   dl_exp=${dl_exp}    ul_exp=${ul_exp}
    ...    cell_and_peak_info=${cell_and_peak_info}   target_avg_percent=${target_avg_percent}   min_percent=${min_percent}

    [Teardown]   Selenium Logout And Close Browser

E2E_gNB_SiSo_RF_module_power_reset_by_RadioIndex_l3call
    [Documentation]
    ...    *************************************************************
    ...    operate RF module power reset by RU index and check l3call
    ...    *************************************************************
    [Arguments]   ${ru_index}=${1}
    ...           ${with_call}=${True}
#   ...           ${with_peak}=${False}
    ...           ${cell_id}=${1}
    ...           ${ue_index}=${0}
    ...           ${ue_number}=${1}
    ...           ${ui_version}=default
    ...           ${iperf_type}=via_app
    ...           ${protocol}=udp
    ...           ${call_duration}=${60}
    ...           ${dl_tp}=1600M
    ...           ${ul_tp}=100M
    ...           ${dl_exp}=300
    ...           ${ul_exp}=20
    ...           ${target_avg_percent}=0.5
    ...           ${min_percent}=0.1
    ...           ${cell_and_peak_info}=${None}

    log to console    \nE2E_gNB_SiSo_RF_module_power_reset_by_RadioIndex: RU_${ru_index}
    ${ru_index_list}   create list   ${ru_index}
    Create file in RU    ru_index=${ru_index}
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        Wait Until Keyword Succeeds    10min    30s    RU Should Be Power Off    ru_index=${ru_index}
    END
    Power On RU And Check    ru_index_list=${ru_index_list}
    run keyword and continue on failure    Check file not Exist in RU    ru_index=${ru_index}
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${cell_list}    Get All Cell Id    ru_index=${ru_index}
        ${result}   Run Keyword And Return Status    List Should Contain Value   ${cell_list}   ${cell_id}
        Run Keyword If   '${result}'!='True'
        ...    log to console   \nSkipped l3call: cell_${cell_id} not allocated on RU_${ru_index}
        ...    ELSE    log to console    \nTested l3call in cell_${cell_id} on RU_${ru_index}
        Continue For Loop If   '${result}'!='True'
        run keyword if   ${with_call}   _e2e UE L3 Call And Throughput    cell_id=${cell_id}   ue_index=${ue_index}
        ...    ue_number=${ue_number}   ui_version=${ui_version}  duration=${call_duration}   iperf_type=${iperf_type}
        ...    protocol=${protocol}   dl_tp=${dl_tp}   ul_tp=${ul_tp}   dl_exp=${dl_exp}    ul_exp=${ul_exp}
        ...    cell_and_peak_info=${cell_and_peak_info}   target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
#        run keyword if   ${with_call}   Get UE From Init File and Make call    cell_list=${cell_list}
#        ...    with_peak=${with_peak}    duration=${call_duration}
    END
    [Teardown]  Run Keywords    Power On RU And Check    ru_index_list=${ru_index_list}    AND
                ...             Selenium Logout And Close Browser

E2E_gNB_SiSo_RF_module_reset_from_WebEM_by_RadioIndex_l3call
    [Documentation]
    ...    *************************************************************
    ...    operate RF module reset from WebEM by RU index and check l3all
    ...    *************************************************************
    [Arguments]   ${ru_index}=${1}
    ...           ${with_call}=${True}
#   ...           ${with_peak}=${False}
    ...           ${cell_id}=${1}
    ...           ${ue_index}=${0}
    ...           ${ue_number}=${1}
    ...           ${ui_version}=default
    ...           ${iperf_type}=via_app
    ...           ${protocol}=udp
    ...           ${call_duration}=${60}
    ...           ${dl_tp}=1600M
    ...           ${ul_tp}=100M
    ...           ${dl_exp}=300
    ...           ${ul_exp}=20
    ...           ${target_avg_percent}=0.5
    ...           ${min_percent}=0.1
    ...           ${cell_and_peak_info}=${None}

    log to console    \nE2E_gNB_SiSo_RF_module_reset_from_WebEM_by_RadioIndex: RU_${ru_index}
    ${ru_index_list}   create list   ${ru_index}
    FOR  ${ru_index}  IN  @{ru_index_list}
        Create file in RU    ru_index=${ru_index}
        Perform RF Module Reset from GUI    ru_index=${ru_index}
        coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
        run keyword and continue on failure    Check file not Exist in RU    ru_index=${ru_index}
        ${cell_list}    Get All Cell Id    ru_index=${ru_index}
        ${result}   Run Keyword And Return Status    List Should Contain Value   ${cell_list}   ${cell_id}
        Run Keyword If   '${result}'!='True'
        ...    log to console   \nSkipped l3call: cell_${cell_id} not allocated on RU_${ru_index}
        ...    ELSE    log to console    \nTested l3call in cell_${cell_id} on RU_${ru_index}
        Continue For Loop If   '${result}'!='True'
        run keyword if   ${with_call}   _e2e UE L3 Call And Throughput    cell_id=${cell_id}   ue_index=${ue_index}
        ...    ue_number=${ue_number}   ui_version=${ui_version}  duration=${call_duration}   iperf_type=${iperf_type}
        ...    protocol=${protocol}   dl_tp=${dl_tp}   ul_tp=${ul_tp}   dl_exp=${dl_exp}    ul_exp=${ul_exp}
        ...    cell_and_peak_info=${cell_and_peak_info}   target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
    END
    [Teardown]  Selenium Logout And Close Browser

E2E_gNB_SiSo_RU_lock_and_unlock_by_RadioType_l3call
    [Documentation]
    ...    *************************************************************
    ...    operate RU lock and unlock by Radio Type and check l3call
    ...    *************************************************************
    [Arguments]   ${RU_type}=${tl.gnbs[0].dus[0].rus[0].radio_type.value}
    ...           ${with_call}=${True}
#   ...           ${with_peak}=${False}
    ...           ${cell_id}=${1}
    ...           ${ue_index}=${0}
    ...           ${ue_number}=${1}
    ...           ${ui_version}=default
    ...           ${iperf_type}=via_app
    ...           ${protocol}=udp
    ...           ${call_duration}=${60}
    ...           ${dl_tp}=1600M
    ...           ${ul_tp}=100M
    ...           ${dl_exp}=300
    ...           ${ul_exp}=20
    ...           ${target_avg_percent}=0.5
    ...           ${min_percent}=0.1
    ...           ${cell_and_peak_info}=${None}

    log to console    \nE2E_gNB_SiSo_RU_lock_and_unlock_by_RadioType: ${RU_type}
    Selenium Login And Disable Screen Lock
    ${ru_index_list}    get all ru index
    ${ru_num}    get length  ${ru_index_list}
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${radio_type}    get ru type   ru_index=${ru_index}
        Run Keyword If   '${radio_type}'!='${RU_type}'
        ...    log to console   \nSkipped: RU_${ru_index}(${radio_type}) not mataches ${RU_type}
        ...    ELSE    log to console    \nTested: RU_${ru_index}(${radio_type}) mataches ${RU_type}
        Continue For Loop If   '${radio_type}'!='${RU_type}'
        Get X2 link shutdown waiting time
        ${check_alarm}    set variable if    ${ru_num}==1    ${True}    ${False}
        ${cell_list}    get all cell id    ru_index=${ru_index}
#        run keyword if   ${with_call}   Get UE From Init File and Make call
#        ...    cell_list=${cell_list}   with_peak=${with_peak}    duration=${call_duration}
        Create file in RU    ru_index=${ru_index}
        ${ru_index_list_tmp}    create list    ${ru_index}
        Lock all RUs and check status    ru_index_list=${ru_index_list_tmp}    check_alarm=${check_alarm}
        ...    gnb_type='${gNb_CuType}'
        run keyword and continue on failure   Unlock all RUs and check status    ru_index_list=${ru_index_list_tmp}
        ...    check_alarm=${check_alarm}   gnb_type='${gNb_CuType}'
#        run keyword if   ${with_call}   Get UE From Init File and Make call    cell_list=${cell_list}
#        ...    with_peak=${with_peak}    duration=${call_duration}
        run keyword and continue on failure   Check file Exist in RU    ru_index=${ru_index}
    END

    run keyword if   ${with_call}   _e2e UE L3 Call And Throughput    cell_id=${cell_id}   ue_index=${ue_index}
    ...    ue_number=${ue_number}   ui_version=${ui_version}  duration=${call_duration}   iperf_type=${iperf_type}
    ...    protocol=${protocol}   dl_tp=${dl_tp}   ul_tp=${ul_tp}   dl_exp=${dl_exp}    ul_exp=${ul_exp}
    ...    cell_and_peak_info=${cell_and_peak_info}   target_avg_percent=${target_avg_percent}   min_percent=${min_percent}

    [Teardown]  Selenium Logout And Close Browser

E2E_gNB_SiSo_cell_block_and_unblock_by_RadioType_l3call
    [Documentation]
    ...    *************************************************************
    ...    operate cell block and unblock by Radio Type and check l3call
    ...    *************************************************************
    [Arguments]   ${RU_type}=${tl.gnbs[0].dus[0].rus[0].radio_type.value}
    ...           ${with_call}=${True}
#   ...           ${with_peak}=${False}
    ...           ${cell_id}=${1}
    ...           ${ue_index}=${0}
    ...           ${ue_number}=${1}
    ...           ${ui_version}=default
    ...           ${iperf_type}=via_app
    ...           ${protocol}=udp
    ...           ${call_duration}=${60}
    ...           ${dl_tp}=1600M
    ...           ${ul_tp}=100M
    ...           ${dl_exp}=300
    ...           ${ul_exp}=20
    ...           ${target_avg_percent}=0.5
    ...           ${min_percent}=0.1
    ...           ${cell_and_peak_info}=${None}

    log to console    \nE2E_gNB_SiSo_cell_block_and_unblock_by_RadioType: ${RU_type}
    Selenium Login And Disable Screen Lock
    Get X2 link shutdown waiting time
    ${cell_id_list}    Get All Cell Id
    ${cell_num}    get length  ${cell_id_list}
    ${check_alarm}    set variable if  ${cell_num}==1  ${True}  ${False}
    Set Test Variable    ${check_alarm}
    ${ru_index_list}    get all ru index
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${radio_type}    get ru type   ru_index=${ru_index}
        Run Keyword If   '${radio_type}'!='${RU_type}'
        ...    log to console   \nSkipped: RU_${ru_index}(${radio_type}) not mataches ${RU_type}
        ...    ELSE    log to console    \nTested: RU_${ru_index}(${radio_type}) mataches ${RU_type}
        Continue For Loop If   '${radio_type}'!='${RU_type}'
        ${cell_id_list_under_RU}    Get All Cell Id    ru_index=${ru_index}
        Cell block and unblock under specify RU    cell_list_under_RU=${cell_id_list_under_RU}   check_alarm=${check_alarm}
        #...    with_call=${with_call}    with_peak=${with_peak}    duration=${call_duration}
    END

    run keyword if   ${with_call}   _e2e UE L3 Call And Throughput    cell_id=${cell_id}   ue_index=${ue_index}
    ...    ue_number=${ue_number}   ui_version=${ui_version}  duration=${call_duration}   iperf_type=${iperf_type}
    ...    protocol=${protocol}   dl_tp=${dl_tp}   ul_tp=${ul_tp}   dl_exp=${dl_exp}    ul_exp=${ul_exp}
    ...    cell_and_peak_info=${cell_and_peak_info}   target_avg_percent=${target_avg_percent}   min_percent=${min_percent}

    [Teardown]   Selenium Logout And Close Browser

E2E_gNB_SiSo_RF_module_power_reset_by_RadioType_l3call
    [Documentation]
    ...    *************************************************************
    ...    operate RF module power reset by Radio Type and check l3call
    ...    *************************************************************
    [Arguments]   ${RU_type}=${tl.gnbs[0].dus[0].rus[0].radio_type.value}
    ...           ${with_call}=${True}
#   ...           ${with_peak}=${False}
    ...           ${cell_id}=${1}
    ...           ${ue_index}=${0}
    ...           ${ue_number}=${1}
    ...           ${ui_version}=default
    ...           ${iperf_type}=via_app
    ...           ${protocol}=udp
    ...           ${call_duration}=${60}
    ...           ${dl_tp}=1600M
    ...           ${ul_tp}=100M
    ...           ${dl_exp}=300
    ...           ${ul_exp}=20
    ...           ${target_avg_percent}=0.5
    ...           ${min_percent}=0.1
    ...           ${cell_and_peak_info}=${None}

    log to console    \nE2E_gNB_SiSo_RF_module_power_reset_by_RadioType: ${RU_type}
    Selenium Login And Disable Screen Lock
    ${ru_index_list}    get all ru index
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${radio_type}    get ru type   ru_index=${ru_index}
        Run Keyword If   '${radio_type}'!='${RU_type}'
        ...    log to console   \nSkipped: RU_${ru_index}(${radio_type}) not mataches ${RU_type}
        ...    ELSE    log to console    \nTested: RU_${ru_index}(${radio_type}) mataches ${RU_type}
        Continue For Loop If   '${radio_type}'!='${RU_type}'
        run keyword and continue on failure    Create file in RU    ru_index=${ru_index}
        Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        Wait Until Keyword Succeeds    10min    30s    RU Should Be Power Off    ru_index=${ru_index}
        ${ru_list_tmp}   create list   ${ru_index}
        Power On RU And Check    ru_index_list=${ru_list_tmp}
        run keyword and continue on failure   Check file not Exist in RU    ru_index=${ru_index}
        ${cell_list}    Get All Cell Id    ru_index=${ru_index}
#        run keyword if   ${with_call}   Get UE From Init File and Make call    cell_list=${cell_list}
#        ...    with_peak=${with_peak}    duration=${call_duration}
        ${result}   Run Keyword And Return Status    List Should Contain Value   ${cell_list}   ${cell_id}
        Run Keyword If   '${result}'=='True' and '${with_call}'=='True'    _e2e UE L3 Call And Throughput
        ...    cell_id=${cell_id}   ue_index=${ue_index}
        ...    ue_number=${ue_number}   ui_version=${ui_version}  duration=${call_duration}   iperf_type=${iperf_type}
        ...    protocol=${protocol}   dl_tp=${dl_tp}   ul_tp=${ul_tp}   dl_exp=${dl_exp}    ul_exp=${ul_exp}
        ...    cell_and_peak_info=${cell_and_peak_info}   target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
    END

    [Teardown]  Selenium Logout And Close Browser

E2E_gNB_SiSo_RF_module_reset_from_WebEM_by_RadioType_l3call
    [Documentation]
    ...    *************************************************************
    ...    operate RF module reset from WebEM by RU type and check l3call
    ...    *************************************************************
    [Arguments]   ${RU_type}=${tl.gnbs[0].dus[0].rus[0].radio_type.value}
    ...           ${with_call}=${True}
#   ...           ${with_peak}=${False}
    ...           ${cell_id}=${1}
    ...           ${ue_index}=${0}
    ...           ${ue_number}=${1}
    ...           ${ui_version}=default
    ...           ${iperf_type}=via_app
    ...           ${protocol}=udp
    ...           ${call_duration}=${60}
    ...           ${dl_tp}=1600M
    ...           ${ul_tp}=100M
    ...           ${dl_exp}=300
    ...           ${ul_exp}=20
    ...           ${target_avg_percent}=0.5
    ...           ${min_percent}=0.1
    ...           ${cell_and_peak_info}=${None}

    log to console    \nE2E_gNB_SiSo_RF_module_reset_from_WebEM_by_RadioType: ${RU_type}
    Selenium Login And Disable Screen Lock
    ${ru_index_list}    get all ru index
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${radio_type}    get ru type   ru_index=${ru_index}
        Run Keyword If   '${radio_type}'!='${RU_type}'
        ...    log to console   \nSkipped: RU_${ru_index}(${radio_type}) not mataches ${RU_type}
        ...    ELSE    log to console    \nTested: RU_${ru_index}(${radio_type}) mataches ${RU_type}
        Continue For Loop If   '${radio_type}'!='${RU_type}'
        run keyword and continue on failure    Create file in RU    ru_index=${ru_index}
        Perform RF Module Reset from GUI    ru_index=${ru_index}
        coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
        run keyword and continue on failure    Check file not Exist in RU    ru_index=${ru_index}
        ${cell_list}    Get All Cell Id    ru_index=${ru_index}
#        run keyword if   ${with_call}   Get UE From Init File and Make call   cell_list=${cell_list}
#        ...    with_peak=${with_peak}    duration=${duration}
        ${result}   Run Keyword And Return Status    List Should Contain Value   ${cell_list}   ${cell_id}
        Run Keyword If   '${result}'=='True' and '${with_call}'=='True'    _e2e UE L3 Call And Throughput
        ...    cell_id=${cell_id}   ue_index=${ue_index}
        ...    ue_number=${ue_number}   ui_version=${ui_version}  duration=${call_duration}   iperf_type=${iperf_type}
        ...    protocol=${protocol}   dl_tp=${dl_tp}   ul_tp=${ul_tp}   dl_exp=${dl_exp}    ul_exp=${ul_exp}
        ...    cell_and_peak_info=${cell_and_peak_info}   target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
    END
    [Teardown]  Selenium Logout And Close Browser

E2E_gNB_SiSo_site_power_reset_l3call
    [Documentation]
    ...    *************************************************************
    ...    operate Site reset by power off and power on and check l3call
    ...    *************************************************************
    [Arguments]   ${ru_index}=${1}
    ...           ${with_call}=${True}
#   ...           ${with_peak}=${False}
    ...           ${cell_id}=${1}
    ...           ${ue_index}=${0}
    ...           ${ue_number}=${1}
    ...           ${ui_version}=default
    ...           ${iperf_type}=via_app
    ...           ${protocol}=udp
    ...           ${call_duration}=${60}
    ...           ${dl_tp}=1600M
    ...           ${ul_tp}=100M
    ...           ${dl_exp}=300
    ...           ${ul_exp}=20
    ...           ${target_avg_percent}=0.5
    ...           ${min_percent}=0.1
    ...           ${cell_and_peak_info}=${None}

    log to console    \nE2E_gNB_SiSo_site_power_reset
    Perform Site Power reset
    COAM Wait gnb And Cells ready    timeout=20 min    gnb_type='${gNb_CuType}'

    ${cell_list}    get all cell id    ru_index=${ru_index}
    ${result}   Run Keyword And Return Status    List Should Contain Value   ${cell_list}   ${cell_id}
    Run Keyword If   '${result}'=='True' and '${with_call}'=='True'    _e2e UE L3 Call And Throughput
    ...    cell_id=${cell_id}   ue_index=${ue_index}
    ...    ue_number=${ue_number}   ui_version=${ui_version}  duration=${call_duration}   iperf_type=${iperf_type}
    ...    protocol=${protocol}   dl_tp=${dl_tp}   ul_tp=${ul_tp}   dl_exp=${dl_exp}    ul_exp=${ul_exp}
    ...    cell_and_peak_info=${cell_and_peak_info}   target_avg_percent=${target_avg_percent}   min_percent=${min_percent}


E2E_gNB_SiSo_site_software_reset_l3call
    [Documentation]
    ...    *************************************************************
    ...    operate Site reset from WebEM and check l3call
    ...    *************************************************************
    [Arguments]   ${ru_index}=${1}
    ...           ${with_call}=${True}
#   ...           ${with_peak}=${False}
    ...           ${cell_id}=${1}
    ...           ${ue_index}=${0}
    ...           ${ue_number}=${1}
    ...           ${ui_version}=default
    ...           ${iperf_type}=via_app
    ...           ${protocol}=udp
    ...           ${call_duration}=${60}
    ...           ${dl_tp}=1600M
    ...           ${ul_tp}=100M
    ...           ${dl_exp}=300
    ...           ${ul_exp}=20
    ...           ${target_avg_percent}=0.5
    ...           ${min_percent}=0.1
    ...           ${cell_and_peak_info}=${None}

    log to console    \nE2E_gNB_SiSo_site_software_reset
    Perform BTS Site Reset
    COAM Wait gnb And Cells ready    timeout=20 min    gnb_type='${gNb_CuType}'

    ${cell_list}    get all cell id    ru_index=${ru_index}
    ${result}   Run Keyword And Return Status    List Should Contain Value   ${cell_list}   ${cell_id}
    Run Keyword If   '${result}'=='True' and '${with_call}'=='True'    _e2e UE L3 Call And Throughput
    ...    cell_id=${cell_id}   ue_index=${ue_index}
    ...    ue_number=${ue_number}   ui_version=${ui_version}  duration=${call_duration}   iperf_type=${iperf_type}
    ...    protocol=${protocol}   dl_tp=${dl_tp}   ul_tp=${ul_tp}   dl_exp=${dl_exp}    ul_exp=${ul_exp}
    ...    cell_and_peak_info=${cell_and_peak_info}   target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
