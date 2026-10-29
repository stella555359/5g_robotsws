*** Settings ***
Documentation     author: annie.hu
...               Group: HGZ_SG5
...               contact: annie.hu@nokia-sbell.com

Library     taf/rfrl/common_resources/python/SWConfig.py

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG5/robot/E2E/resources/e2e_common_cases_pcmd.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_calculation_common_keywords.robot

*** Variables ***

*** Keywords ***

Block unblock single cell and check L3 with PCMD
    [Arguments]  ${block_list}   ${check_alarm}=${True}   ${check_historyalarm}=${False}
    ...          ${technology}=NR   ${gnb_type}='NSA'   ${connection}=GNB_OAM
    ...          ${with_call}=${True}    ${with_pcmd}=${True}   ${Iface}=br1   ${cell_id}=1
    ...          ${ue_index}=0   ${ue_number}=1   ${duration}=${60}    ${iperf_type}=via_app   ${protocol}=udp
    ...          ${ui_version}=default  ${check_wait_time}=30   ${cell_and_peak_info}=${None}
    ...          ${dl_exp}=60    ${ul_exp}=20    ${dl_tp}=300M  ${ul_tp}=100M
    ...          ${target_avg_percent}=0.1    ${min_percent}=0.1

    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=X2 EN-DC ConfigUpdate neighbor info back-off timer
    ...    abbr=x2EnDcCfUpNbInfoBackOffTmr    new_value=${0}
    Block single cell and check    block_list=${block_list}    check_alarm=${True}    gnb_type=${gnb_type}
    Unblock single cell and check    block_list=${block_list}    check_alarm=${True}    gnb_type=${gnb_type}
    FOR  ${idx}   IN   @{block_list}
        Log To Console  \nStart check L3 call and PCDM for Global Cell ID : ${idx}
        ${iperf_type}    Get Iperf Type    iperf_type=${iperf_type}    protocol=${protocol}
        ${ui_version}    Get UE UI Version
        Run Keyword If  '${with_call}'=='True'   _e2e UE L3 Call And Pcmd
        ...    with_pcmd=${with_pcmd}   Iface=${Iface}   cell_id=${Cellid_l3call}   ue_index=${ue_index}
        ...    ui_version=${ui_version}   ue_number=${ue_number}  duration=${duration}   iperf_type=${iperf_type}
        ...    protocol=${protocol}   dl_tp=${dl_tp}   ul_tp=${ul_tp}   dl_exp=${dl_exp}    ul_exp=${ul_exp}
        ...    cell_and_peak_info=${cell_and_peak_info}   target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
    END

Block single cell and check
    [Arguments]  ${block_list}   ${check_alarm}=${True}   ${check_historyalarm}=${False}
    ...          ${technology}=NR   ${gnb_type}='NSA'   ${connection}=GNB_OAM_E2E
    Connect to gnb coam via ssl    connection=${connection}
    FOR   ${idx}   IN   @{block_list}
        Log To Console  \nBlock Global cell ID : ${idx} for ${technology} and check status & duration
        run keyword and ignore error    selenium_coam.refresh_page
        ${startTime}    BuiltIn.Get Time    epoch
        selenium_coam.unblock_cell   cell_idx=${idx}   technology=${technology}
        Wait Until Keyword Succeeds   1min  2sec   check single cell should be blocked
        ...                           cell_idx=${idx}   cell_type=${technology.lower()}   connection=${connection}
        ${endTime}    BuiltIn.Get Time    epoch
    END
    ${block_duration}    Evaluate    ${endTime}-${startTime}
    Run Keyword And Continue On Failure   Should Be True    ${block_duration} < ${nr_block_or_unblock_time}

    Wait For Expect Fault Present    faultId=${49}    timeout=180    connection=${connection}

    ${sleep_time}    Evaluate    ${X2_link_shutdown_time}-1
    Run Keyword If    ${check_alarm}==${True} and '${gNB_type}'!='SA'    Run Keywords
    ...    Sleep    ${sleep_time}min    AND
    ...    add fault to the allowed fault list   faultId=${49}    AND
    ...    add fault to the allowed fault list   faultId=${7300}    AND
    ...    add fault to the allowed fault list   faultId=${7319}    AND
    ...    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}   connection=${connection}   AND
    ...    Run Keyword If    ${check_historyalarm}    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=${connection}
    [Teardown]  COAM Teardown gnb connections  connection=${connection}

Unblock single cell and check
    [Arguments]  ${block_list}   ${check_alarm}=${True}   ${check_historyalarm}=${False}
    ...          ${technology}=NR   ${gnb_type}='NSA'   ${connection}=GNB_OAM_E2E
    Connect to gnb coam via ssl    connection=${connection}
    FOR   ${idx}   IN   @{block_list}
        Log To Console  \nUnblock Global cell ID : ${idx} for ${technology} and check status & duration
        run keyword and ignore error    selenium_coam.refresh_page
        ${startTime}    BuiltIn.Get Time    epoch
        selenium_coam.unblock_cell    cell_idx=${idx}    technology=${technology}
        Wait Until Keyword Succeeds   6min  10sec   check single cell should be unblocked
        ...                           cell_idx=${idx}   cell_type=${technology.lower()}   connection=${connection}
        ${endTime}    BuiltIn.Get Time    epoch
    END
    ${unblock_duration}    Evaluate    ${endTime}-${startTime}
    Run Keyword And Continue On Failure    Should Be True    ${unblock_duration} < ${nr_block_or_unblock_time}

    Wait For Expect Fault To Disappear    faultId=${49}   timeout=180   connection=${connection}
    #${sleep_time}    Evaluate    ${X2_link_shutdown_time}-1
    Run Keyword If    ${check_alarm}==${True} and '${gNB_type}'!='SA'    Run Keywords
    ...    Sleep    3min    AND
    ...    add fault to the allowed history fault list   faultId=${49}   AND
    ...    add fault to the allowed history fault list   faultId=${7300}   AND
    ...    add fault to the allowed history fault list   faultId=${7319}   AND
    ...    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}    connection=${connection}   AND
    ...    Run Keyword If    ${check_historyalarm}    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=${connection}
    [Teardown]  COAM Teardown gnb connections  connection=${connection}

Block unblock cells and check L3 with PCMD
    [Arguments]  ${block_list}   ${check_alarm}=${True}   ${check_historyalarm}=${False}
    ...          ${technology}=NR   ${gnb_type}='NSA'   ${connection}=GNB_OAM_E2E
    ...          ${with_call}=${True}    ${with_pcmd}=${True}   ${Iface}=br1   ${cell_id}=1
    ...          ${ue_index}=0   ${ue_number}=1   ${duration}=${60}    ${iperf_type}=via_app   ${protocol}=udp
    ...          ${ui_version}=default   ${check_wait_time}=30   ${cell_and_peak_info}=${None}
    ...          ${dl_exp}=60    ${ul_exp}=20    ${dl_tp}=300M  ${ul_tp}=100M
    ...          ${target_avg_percent}=0.1    ${min_percent}=0.1

    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=X2 EN-DC ConfigUpdate neighbor info back-off timer
    ...    abbr=x2EnDcCfUpNbInfoBackOffTmr    new_value=${0}
    Connect to gnb coam via ssl    connection=${connection}
    Log To Console  \n***Block unblock cells one by one and check***
    FOR    ${idx}  IN  @{block_list}
        Log To Console  \nBlock Global cell ID : ${idx} for ${technology} and check status
        run keyword and ignore error    selenium_coam.refresh_page
        ${startTime}    BuiltIn.Get Time    epoch
        selenium_coam.block_cell    cell_idx=${idx}    technology=${technology}
        Wait Until Keyword Succeeds    1min    1sec    check single cell should be blocked
        ...    cell_idx=${idx}    cell_type=${technology.lower()}   connection=${connection}
        ${endTime}    BuiltIn.Get Time    epoch
        ${block_duration}    Evaluate    ${endTime}-${startTime}
        Run Keyword And Continue On Failure    Should Be True    ${block_duration} < ${nr_block_or_unblock_time}
        Wait For Expect Fault Present    faultId=${49}    timeout=180    connection=${connection}

        #################################  WA TL676 ###########################
        add fault to the allowed fault list    faultId=${7312}
        add fault to the allowed history fault list    faultId=${7312}
        ##############################################################

        ${sleep_time}    Evaluate    ${X2_link_shutdown_time}-1
        Run Keyword If    ${check_alarm} and '${gNB_type}'!='SA'    Run Keywords
        ...    Sleep   ${sleep_time}min    AND
        ...    add fault to the allowed fault list   faultId=${49}   AND
        ...    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}    connection=${connection}   AND
        ...    Run Keyword If    ${check_historyalarm}    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=${connection}
        Wait Until Keyword Succeeds    3min    5sec    Verify all other cells should be onair    cell_exclude=${idx}
        ...    connection=${connection}

        Log To Console  \nUnblock Global cell ID : ${idx} for ${technology} and check status
        run keyword and ignore error    selenium_coam.refresh_page
        ${startTime}    BuiltIn.Get Time    epoch
        selenium_coam.unblock_cell    cell_idx=${idx}    technology=${technology}
        Wait Until Keyword Succeeds    5min    5sec    check single cell should be unblocked
        ...    cell_idx=${idx}    cell_type=${technology.lower()}   connection=${connection}
        ${endTime}    BuiltIn.Get Time    epoch
        ${unblock_duration}    Evaluate    ${endTime}-${startTime}
        Run Keyword And Continue On Failure    Should Be True    ${unblock_duration} < ${nr_block_or_unblock_time}
        Wait For Expect Fault To Disappear    faultId=${49}   timeout=180   connection=${connection}

        ################################  WA  ############################
        add fault to the allowed fault list    faultId=${7312}
        add fault to the allowed history fault list    faultId=${7312}
        ##############################################################

        #${sleep_time}    Evaluate    ${X2_link_shutdown_time}-1
        Run Keyword If    ${check_alarm} and '${gNB_type}'!='SA'    Run Keywords
        ...    Sleep    5min    AND
        ...    add fault to the allowed history fault list    faultId=${49}   AND
        ...    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}    connection=${connection}    AND
        ...    Run Keyword If    ${check_historyalarm}    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=${connection}
        Wait Until Keyword Succeeds    5min    10sec    Check all cells info should be onair   connection=${connection}

        Log To Console  \nStart check L3 call and PCDM for Global Cell ID : ${idx}
        ${Stat}    Run Keyword And Return Status   List Should Contain Value   ${Cells_to_Test}   ${Cellid_l3call}
        ${iperf_type}    Get Iperf Type    iperf_type=${iperf_type}    protocol=${protocol}
        ${ui_version}    Get UE UI Version
        Run Keyword If   ${with_call} and ${Stat}   _e2e UE L3 Call And Pcmd
        ...    with_pcmd=${with_pcmd}   Iface=${Iface}   cell_id=${Cellid_l3call}   ue_index=${ue_index}
        ...    ue_number=${ue_number}   ui_version=${ui_version}  duration=${duration}   iperf_type=${iperf_type}
        ...    protocol=${protocol}   dl_tp=${dl_tp}   ul_tp=${ul_tp}   dl_exp=${dl_exp}    ul_exp=${ul_exp}
        ...    cell_and_peak_info=${cell_and_peak_info}   target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
        ...    ELSE   Log To Console   \nCell ID : ${idx} not doing l3call, perhaps no UE in this cell
    END
    [Teardown]  COAM Teardown gnb connections  connection=${connection}

Lock unlock single cell and check L3 with PCMD
    [Arguments]  ${lock_list}   ${check_alarm}=${True}   ${check_historyalarm}=${False}
    ...          ${technology}=NR   ${gnb_type}='NSA'   ${connection}=GNB_OAM_E2E
    ...          ${with_call}=${True}    ${with_pcmd}=${True}   ${Iface}=br1   ${cell_id}=1
    ...          ${ue_index}=0   ${ue_number}=1   ${duration}=${60}    ${iperf_type}=via_app   ${protocol}=udp
    ...          ${ui_version}=default   ${check_wait_time}=30   ${cell_and_peak_info}=${None}
    ...          ${dl_exp}=60    ${ul_exp}=20    ${dl_tp}=300M  ${ul_tp}=100M
    ...          ${target_avg_percent}=0.1    ${min_percent}=0.1

    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=X2 EN-DC ConfigUpdate neighbor info back-off timer
    ...    abbr=x2EnDcCfUpNbInfoBackOffTmr    new_value=${0}
    Lock single cell and check   lock_list=${lock_list}    check_alarm=${True}    gnb_type=${gnb_type}
    Unlock single cell and check   unlock_list=${lock_list}   check_alarm=${True}    gnb_type=${gnb_type}

    FOR  ${idx}   IN   @{lock_list}
        ${iperf_type}    Get Iperf Type    iperf_type=${iperf_type}    protocol=${protocol}
        ${ui_version}    Get UE UI Version
        Log To Console  \nCheck L3 call and PCDM for Global cell ID : ${Cellid_l3call}
        Run Keyword If  ${with_call} and '${idx}'=='${Cellid_l3call}'   _e2e UE L3 Call And Pcmd
        ...    with_pcmd=${with_pcmd}   Iface=${Iface}   cell_id=${Cellid_l3call}   ue_index=${ue_index}
        ...    ue_number=${ue_number}   ui_version=${ui_version}  duration=${duration}   iperf_type=${iperf_type}
        ...    protocol=${protocol}   dl_tp=${dl_tp}   ul_tp=${ul_tp}   dl_exp=${dl_exp}    ul_exp=${ul_exp}
        ...    cell_and_peak_info=${cell_and_peak_info}   target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
        ...    ELSE   Log To Console   \ncell ID : ${idx} not doing l3call, perhaps no UE in this cell
    END

Lock single cell and check
    [Arguments]  ${lock_list}   ${check_alarm}=${True}   ${check_historyalarm}=${False}
    ...          ${technology}=NR   ${gnb_type}='NSA'   ${connection}=GNB_OAM_E2E
    Connect to gnb coam via ssl    connection=${connection}
    FOR   ${idx}   IN   @{lock_list}
        Log To Console  \nLock Global cell ID : ${idx} for ${technology} and check status & duration
        ${startTime}    BuiltIn.Get Time    epoch
        Perform cell lock via rest api    cell_idx=${idx}   connection=${connection}
        Log To Console    \nCheck cell: ${idx} should be locked
        Wait Until Keyword Succeeds   5min  10s   Check cell should be locked   cell_id=${idx}   connection=${connection}
        ${endTime}    BuiltIn.Get Time    epoch
    END
    ${lock_duration}    Evaluate    ${endTime}-${startTime}
    Run Keyword And Continue On Failure   Should Be True    ${lock_duration} < ${nr_lock_or_unlock_time}

    Run Keyword If    ${check_alarm}==${True} and '${gNB_type}'!='SA'    Run Keywords
    ...               add fault to the allowed fault list   faultId=${7300}    AND
    ...               add fault to the allowed fault list   faultId=${7319}
    ${sleep_time}    Evaluate    ${X2_link_shutdown_time}-1
    Run Keyword If    ${check_alarm}==${True} and '${gNB_type}'!='SA'    Run Keywords
    ...    Sleep    ${sleep_time}min    AND
    ...    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}   connection=${connection}   AND
    ...    Run Keyword If    ${check_historyalarm}    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=${connection}
    [Teardown]  COAM Teardown gnb connections  connection=${connection}

Unlock single cell and check
    [Arguments]  ${unlock_list}   ${check_alarm}=${True}   ${check_historyalarm}=${False}
    ...          ${technology}=NR   ${gnb_type}='NSA'   ${connection}=GNB_OAM_E2E
    Connect to gnb coam via ssl    connection=${connection}
    FOR   ${idx}   IN   @{unlock_list}
        Log To Console  \nUnlock Global cell ID : ${idx} for ${technology} and check status & duration
        ${startTime}    BuiltIn.Get Time    epoch
        Perform cell unlock via rest api   cell_idx=${idx}   connection=${connection}
        Log To Console    \nCheck cell: ${idx} should be unlocked
        Wait Until Keyword Succeeds   5min   10s   Check cell should be unlocked   cell_id=${idx}   connection=${connection}
        ${endTime}    BuiltIn.Get Time    epoch
    END
    ${unlock_duration}    Evaluate    ${endTime}-${startTime}
    Run Keyword And Continue On Failure    Should Be True    ${unlock_duration} < ${nr_lock_or_unlock_time}

    Run Keyword If    ${check_alarm}==${True} and '${gNB_type}'!='SA'    Run Keywords
    ...               add fault to the allowed fault list   faultId=${7300}    AND
    ...               add fault to the allowed fault list   faultId=${7319}
    #${sleep_time}    Evaluate    ${X2_link_shutdown_time}-1
    Run Keyword If    ${check_alarm}==${True} and '${gNB_type}'!='SA'    Run Keywords
    ...    Sleep   2min    AND
    ...    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}    connection=${connection}   AND
    ...    Run Keyword If    ${check_historyalarm}    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=${connection}
    [Teardown]  COAM Teardown gnb connections  connection=${connection}

Lock unlock cells and check L3 with PCMD
    [Arguments]  ${lock_list}   ${check_alarm}=${True}   ${check_historyalarm}=${False}
    ...          ${technology}=NR   ${gnb_type}='NSA'   ${connection}=GNB_OAM_E2E
    ...          ${with_call}=${True}    ${with_pcmd}=${True}   ${Iface}=br1   ${cell_id}=1
    ...          ${ue_index}=0   ${ue_number}=1   ${duration}=${60}    ${iperf_type}=via_app   ${protocol}=udp
    ...          ${ui_version}=default   ${check_wait_time}=30   ${cell_and_peak_info}=${None}
    ...          ${dl_exp}=60    ${ul_exp}=20    ${dl_tp}=300M  ${ul_tp}=100M
    ...          ${target_avg_percent}=0.1    ${min_percent}=0.1

    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=X2 EN-DC ConfigUpdate neighbor info back-off timer
    ...    abbr=x2EnDcCfUpNbInfoBackOffTmr    new_value=${0}
    Connect to gnb coam via ssl    connection=${connection}
    Log To Console  \n***lock unlock cells one by one and check***
    FOR    ${idx}  IN  @{lock_list}
        Log To Console  \nlock Global cell ID : ${idx} for ${technology} and check status
        ${startTime}    BuiltIn.Get Time    epoch
        Perform cell lock via rest api    cell_idx=${idx}   connection=${connection}
        Log To Console    \nCheck cell: ${idx} should be locked
        Wait Until Keyword Succeeds   5min  10s   Check cell should be locked   cell_id=${idx}   connection=${connection}
        ${endTime}    BuiltIn.Get Time    epoch
        ${lock_duration}    Evaluate    ${endTime}-${startTime}
        Run Keyword And Continue On Failure    Should Be True    ${lock_duration} < ${nr_lock_or_unlock_time}

        ###############################  WA TL676  #############################
        add fault to the allowed fault list    faultId=${7312}
        add fault to the allowed history fault list    faultId=${7312}
        ##############################################################

        Run Keyword If    ${check_alarm}==${True}   Run Keywords
        ...    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}    connection=${connection}   AND
        ...    Run Keyword If    ${check_historyalarm}    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=${connection}
        Wait Until Keyword Succeeds    3min    5sec    Verify all other cells should be onair    cell_exclude=${idx}
        ...    connection=${connection}

        Log To Console  \nUnlock Global cell ID : ${idx} for ${technology} and check status
        ${startTime}    BuiltIn.Get Time    epoch
        Perform cell unlock via rest api   cell_idx=${idx}   connection=${connection}
        Log To Console    \nCheck cell: ${idx} should be unlocked
        Wait Until Keyword Succeeds   5min   5s   Check cell should be unlocked   cell_id=${idx}   connection=${connection}
        ${endTime}    BuiltIn.Get Time    epoch
        ${unlock_duration}    Evaluate    ${endTime}-${startTime}
        Run Keyword And Continue On Failure    Should Be True    ${unlock_duration} < ${nr_lock_or_unlock_time}

        ###############################  WA TL676 #############################
        add fault to the allowed fault list    faultId=${7312}
        add fault to the allowed history fault list    faultId=${7312}
        ##############################################################

        Run Keyword If    ${check_alarm}    Run Keywords
        ...    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}    connection=${connection}    AND
        ...    Run Keyword If    ${check_historyalarm}    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=${connection}
        Wait Until Keyword Succeeds    5min    10sec    Check all cells info should be onair   connection=${connection}

        Log To Console  \nCheck L3 call and PCDM for Global cell ID : ${idx}
        ${iperf_type}    Get Iperf Type    iperf_type=${iperf_type}    protocol=${protocol}
        ${ui_version}    Get UE UI Version
        Run Keyword If  ${with_call} and '${idx}'=='${Cellid_l3call}'   _e2e UE L3 Call And Pcmd
        ...    with_pcmd=${with_pcmd}   Iface=${Iface}   cell_id=${Cellid_l3call}   ue_index=${ue_index}
        ...    ue_number=${ue_number}   ui_version=${ui_version}  duration=${duration}   iperf_type=${iperf_type}
        ...    protocol=${protocol}   dl_tp=${dl_tp}   ul_tp=${ul_tp}   dl_exp=${dl_exp}    ul_exp=${ul_exp}
        ...    cell_and_peak_info=${cell_and_peak_info}   target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
        ...    ELSE   Log To Console   \ncell ID : ${idx} not doing l3call, perhaps no UE in this cell
    END
    [Teardown]  COAM Teardown gnb connections  connection=${connection}

Reset single RU and check L3 with PCMD
    [Arguments]  ${ru_list}   ${check_alarm}=${True}   ${check_historyalarm}=${False}
    ...          ${technology}=NR   ${gnb_type}='NSA'   ${connection}=GNB_OAM_E2E
    ...          ${with_call}=${True}    ${with_pcmd}=${True}   ${Iface}=br1   ${cell_id}=1
    ...          ${ue_index}=0   ${ue_number}=1   ${duration}=${60}    ${iperf_type}=via_app   ${protocol}=udp
    ...          ${ui_version}=default   ${check_wait_time}=30   ${cell_and_peak_info}=${None}
    ...          ${dl_exp}=60    ${ul_exp}=20    ${dl_tp}=300M  ${ul_tp}=100M
    ...          ${target_avg_percent}=0.1    ${min_percent}=0.1
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=X2 EN-DC ConfigUpdate neighbor info back-off timer
    ...    abbr=x2EnDcCfUpNbInfoBackOffTmr    new_value=${0}
    Connect to gnb coam via ssl    connection=${connection}
    FOR   ${idx}   IN   @{ru_list}
        Log To Console    \n***RF Module index: ${idx} Reset via admin**
        ${startTime}    BuiltIn.Get Time    epoch
        ${idx}  Convert To Integer    ${idx}
        coam.reset_unit    dist_name=MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-${idx}
        ...    force_radio_reset=${True}    timeout=${300}    connection=${connection}
        Wait Until Keyword Succeeds    8min    10sec    Check all cells info should be onair   connection=${connection}
        ${endTime}    BuiltIn.Get Time    epoch
    END
    ${ruRest_duration}    Evaluate    ${endTime}-${startTime}
    Run Keyword And Continue On Failure   Should Be True    ${ruRest_duration} < ${RU_reset_downtime_duration}

    #${sleep_time}    Evaluate    ${X2_link_shutdown_time}-1
    Run Keyword If    ${check_alarm}==${True} and '${gNB_type}'!='SA'    Run Keywords
    ...    add fault to the allowed history fault list   faultId=${7300}    AND
    ...    add fault to the allowed history fault list   faultId=${7319}    AND
    ...    Sleep    5min    AND
    ...    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}   connection=${connection}   AND
    ...    Run Keyword If    ${check_historyalarm}    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=${connection}
    ...    ELSE IF    ${check_alarm}==${True} and '${gNB_type}'=='SA'    Run Keywords
    ...    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}   connection=${connection}   AND
    ...    Run Keyword If    ${check_historyalarm}    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=${connection}
    ...    ELSE    Log To Console   \nWarning: not check alarms/history alarms after ru resetting

    FOR  ${idx}   IN   @{ru_list}
        Log To Console    \nstart to check l3call after reset RU: ${idx}
        ${cells_in_RU}    Get All Cell Id    ru_index=${idx}
        ${Stat}    Run Keyword And Return Status   List Should Contain Value   ${cells_in_RU}   ${Cellid_l3call}
        ${iperf_type}    Get Iperf Type    iperf_type=${iperf_type}    protocol=${protocol}
        ${ui_version}    Get UE UI Version
        Run Keyword If  '${with_call}'=='True' and ${Stat}   _e2e UE L3 Call And Pcmd
        ...    with_pcmd=${with_pcmd}   Iface=${Iface}   cell_id=${Cellid_l3call}   ue_index=${ue_index}
        ...    ue_number=${ue_number}   ui_version=${ui_version}  duration=${duration}   iperf_type=${iperf_type}
        ...    protocol=${protocol}   dl_tp=${dl_tp}   ul_tp=${ul_tp}   dl_exp=${dl_exp}    ul_exp=${ul_exp}
        ...    cell_and_peak_info=${cell_and_peak_info}   target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
        ...    ELSE   Log To Console   \nRU ID : ${idx} not doing l3call, perhaps no UE in this RU (cells)
    END
    [Teardown]  COAM Teardown gnb connections  connection=${connection}

Reset RUs and check L3 with PCMD
    [Arguments]  ${ru_list}   ${check_alarm}=${True}   ${check_historyalarm}=${False}
    ...          ${technology}=NR   ${gnb_type}='NSA'   ${connection}=GNB_OAM_E2E
    ...          ${with_call}=${True}    ${with_pcmd}=${True}   ${Iface}=br1   ${cell_id}=1
    ...          ${ue_index}=0   ${ue_number}=1   ${duration}=${60}    ${iperf_type}=via_app   ${protocol}=udp
    ...          ${ui_version}=default   ${check_wait_time}=30   ${cell_and_peak_info}=${None}
    ...          ${dl_exp}=60    ${ul_exp}=20    ${dl_tp}=300M  ${ul_tp}=100M
    ...          ${target_avg_percent}=0.1    ${min_percent}=0.1
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=X2 EN-DC ConfigUpdate neighbor info back-off timer
    ...    abbr=x2EnDcCfUpNbInfoBackOffTmr    new_value=${0}
    Connect to gnb coam via ssl    connection=${connection}
    Log To Console  \n***Reset RUs one by one and check***
    FOR   ${ru_index}   IN   @{ru_list}
        Log To Console    \n***RF Module index: ${ru_index} Reset via admin**
        ${startTime}    BuiltIn.Get Time    epoch
        ${ru_index}   Convert To Integer    ${ru_index}
        coam.reset_unit    dist_name=MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-${ru_index}
        ...    force_radio_reset=${True}    timeout=${300}    connection=${connection}
        Wait Until Keyword Succeeds    6min    5sec    Check all cells info should be onair   connection=${connection}
        ${endTime}    BuiltIn.Get Time    epoch
        ${ruRest_duration}    Evaluate    ${endTime}-${startTime}
        Run Keyword And Continue On Failure   Should Be True    ${ruRest_duration} < ${RU_reset_downtime_duration}

        ################################  WA TL676 ############################
        add fault to the allowed fault list    faultId=${7312}
        add fault to the allowed history fault list    faultId=${7312}
        ##############################################################

        Run Keyword If    ${check_alarm}   Run Keywords
        ...    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}    connection=${connection}   AND
        ...    Run Keyword If    ${check_historyalarm}    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=${connection}

        Log To Console    \nstart to check l3call after reset RU: ${ru_index}
        ${cells_in_RU}    Get All Cell Id    ru_index=${ru_index}
        ${Stat}    Run Keyword And Return Status   List Should Contain Value   ${cells_in_RU}   ${Cellid_l3call}
        ${iperf_type}    Get Iperf Type    iperf_type=${iperf_type}    protocol=${protocol}
        ${ui_version}    Get UE UI Version
        Run Keyword If   ${with_call} and ${Stat}   _e2e UE L3 Call And Pcmd
        ...    with_pcmd=${with_pcmd}   Iface=${Iface}   cell_id=${Cellid_l3call}   ue_index=${ue_index}
        ...    ue_number=${ue_number}   ui_version=${ui_version}  duration=${duration}   iperf_type=${iperf_type}
        ...    protocol=${protocol}   dl_tp=${dl_tp}   ul_tp=${ul_tp}   dl_exp=${dl_exp}    ul_exp=${ul_exp}
        ...    cell_and_peak_info=${cell_and_peak_info}   target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
        ...    ELSE   Log To Console   \nRU ID : ${ru_index} not doing l3call, perhaps no UE in this RU (cells)
    END
    [Teardown]  COAM Teardown gnb connections  connection=${connection}

Reset single BBU and check L3 with PCMD
    [Arguments]  ${bbu_list}   ${check_alarm}=${True}   ${check_historyalarm}=${False}   ${timeout}=600
    ...          ${technology}=NR   ${gnb_type}='NSA'   ${connection}=GNB_OAM_E2E
    ...          ${with_call}=${True}    ${with_pcmd}=${True}   ${Iface}=br1   ${cell_id}=1
    ...          ${ue_index}=0   ${ue_number}=1   ${duration}=${60}    ${iperf_type}=via_app   ${protocol}=udp
    ...          ${ui_version}=default   ${check_wait_time}=30   ${cell_and_peak_info}=${None}
    ...          ${dl_exp}=60    ${ul_exp}=20    ${dl_tp}=300M  ${ul_tp}=100M
    ...          ${target_avg_percent}=0.1    ${min_percent}=0.1
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=X2 EN-DC ConfigUpdate neighbor info back-off timer
    ...    abbr=x2EnDcCfUpNbInfoBackOffTmr    new_value=${0}
    Connect to gnb coam via ssl    connection=${connection}
    FOR   ${idx}   IN   @{bbu_list}
        Log To Console    \n***BB Module index: ${idx} Reset via admin**
        ${idx}  Convert To Integer    ${idx}
        ${startTime}    BuiltIn.Get Time    epoch
        ${output}    coam.reset_unit    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${idx}
        ...    force_radio_reset=${True}    reset_type=Warm    timeout=${timeout}    connection=${connection}
        ${result}    Set Variable    ${output[1]['resultNode']['parameters']['status']}
        Run Keyword And Continue On Failure    Should Be Equal As Strings  ${result}    Succeeded
        Wait Until Keyword Succeeds    10min    10sec    Check all cells info should be onair   connection=${connection}
        ${endTime}    BuiltIn.Get Time    epoch
    END
    ${bbRest_duration}    Evaluate    ${endTime}-${startTime}
    Run Keyword And Continue On Failure   Should Be True    ${bbRest_duration} < ${BBU_reset_downtime_duration}

    #${sleep_time}    Evaluate    ${X2_link_shutdown_time}-1
    Run Keyword If    ${check_alarm}    Run Keywords
    ...    Sleep    5min    AND
    ...    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}   connection=${connection}   AND
    ...    Run Keyword If    ${check_historyalarm}    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=${connection}
    ...    ELSE    Log To Console   \nWarning: not check alarms/history alarms after BBU resetting

    Log To Console    \nstart to check l3call after BBU reset
    ${iperf_type}    Get Iperf Type    iperf_type=${iperf_type}    protocol=${protocol}
    ${ui_version}    Get UE UI Version
    Run Keyword If   ${with_call}   _e2e UE L3 Call And Pcmd
        ...    with_pcmd=${with_pcmd}   Iface=${Iface}   cell_id=${Cellid_l3call}   ue_index=${ue_index}
        ...    ue_number=${ue_number}   ui_version=${ui_version}  duration=${duration}   iperf_type=${iperf_type}
        ...    protocol=${protocol}   dl_tp=${dl_tp}   ul_tp=${ul_tp}   dl_exp=${dl_exp}    ul_exp=${ul_exp}
        ...    cell_and_peak_info=${cell_and_peak_info}   target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
    [Teardown]  COAM Teardown gnb connections  connection=${connection}

Reset BBUs and check L3 with PCMD
    [Arguments]  ${bbu_list}   ${check_alarm}=${True}   ${check_historyalarm}=${False}   ${timeout}=600
    ...          ${technology}=NR   ${gnb_type}='NSA'   ${connection}=GNB_OAM_E2E
    ...          ${with_call}=${True}    ${with_pcmd}=${True}   ${Iface}=br1   ${cell_id}=1
    ...          ${ue_index}=0   ${ue_number}=1   ${duration}=${60}    ${iperf_type}=via_app   ${protocol}=udp
    ...          ${ui_version}=default   ${check_wait_time}=30   ${cell_and_peak_info}=${None}
    ...          ${dl_exp}=60    ${ul_exp}=20    ${dl_tp}=300M  ${ul_tp}=100M
    ...          ${target_avg_percent}=0.1    ${min_percent}=0.1
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=X2 EN-DC ConfigUpdate neighbor info back-off timer
    ...    abbr=x2EnDcCfUpNbInfoBackOffTmr    new_value=${0}
    Connect to gnb coam via ssl    connection=${connection}
    FOR   ${idx}   IN   @{bbu_list}
        Log To Console    \n***BB Module index: ${idx} Reset via admin**
        ${idx}  Convert To Integer    ${idx}
        ${startTime}    BuiltIn.Get Time    epoch
        ${output}    coam.reset_unit    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${idx}
        ...    force_radio_reset=${True}    reset_type=Warm    timeout=${timeout}    connection=${connection}
        ${result}    Set Variable    ${output[1]['resultNode']['parameters']['status']}
        Run Keyword And Continue On Failure    Should Be Equal As Strings  ${result}    Succeeded
        Wait Until Keyword Succeeds    10min    10sec    Check all cells info should be onair   connection=${connection}
        ${endTime}    BuiltIn.Get Time    epoch
        ${bbRest_duration}    Evaluate    ${endTime}-${startTime}
        Run Keyword And Continue On Failure   Should Be True    ${bbRest_duration} < ${BBU_reset_downtime_duration}

        #${sleep_time}    Evaluate    ${X2_link_shutdown_time}-1
        Run Keyword If    ${check_alarm}    Run Keywords
        ...    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}   connection=${connection}   AND
        ...    Run Keyword If    ${check_historyalarm}    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=${connection}
        ...    ELSE    Log To Console   \nWarning: not check alarms/history alarms after BBU resetting

        Log To Console    \nstart to check l3call after BBU reset
        ${iperf_type}    Get Iperf Type    iperf_type=${iperf_type}    protocol=${protocol}
        ${ui_version}    Get UE UI Version
        Run Keyword If   ${with_call}   _e2e UE L3 Call And Pcmd
        ...    with_pcmd=${with_pcmd}   Iface=${Iface}   cell_id=${Cellid_l3call}   ue_index=${ue_index}
        ...    ue_number=${ue_number}   ui_version=${ui_version}  duration=${duration}   iperf_type=${iperf_type}
        ...    protocol=${protocol}   dl_tp=${dl_tp}   ul_tp=${ul_tp}   dl_exp=${dl_exp}    ul_exp=${ul_exp}
        ...    cell_and_peak_info=${cell_and_peak_info}   target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
    END
    [Teardown]  COAM Teardown gnb connections  connection=${connection}

Change parameters on webEM and check status
    [Arguments]  ${dist_name}    ${filter_param}    ${abbr}    ${new_value}
    ...          ${despite_ERR}=${False}    ${connection}=GNB_OAM_E2E
    ...          ${check_alarm}=${True}   ${check_historyalarm}=${False}
    ...          ${technology}=NR   ${gnb_type}='NSA'   ${connection}=GNB_OAM_E2E
    ...          ${with_call}=${True}    ${with_pcmd}=${True}   ${Iface}=br1   ${cell_id}=1
    ...          ${ue_index}=0   ${ue_number}=1   ${duration}=${60}    ${iperf_type}=via_app   ${protocol}=udp
    ...          ${ui_version}=default   ${check_wait_time}=30   ${cell_and_peak_info}=${None}
    ...          ${dl_exp}=60    ${ul_exp}=20    ${dl_tp}=300M  ${ul_tp}=100M
    ...          ${target_avg_percent}=0.1    ${min_percent}=0.1
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=X2 EN-DC ConfigUpdate neighbor info back-off timer
    ...    abbr=x2EnDcCfUpNbInfoBackOffTmr    new_value=${0}
    Connect to gnb coam via ssl    connection=${connection}
    ${current_value}    selenium_coam.Get Parameter Value    dist_name=${dist_name}    filter_param=${filter_param}
    Log To Console  \n Modify ${abbr} from ${current_value} to ${new_value}
    Run Keyword If   '${current_value}'!='${new_value}'   selenium_coam.set_parameter_value  dist_name=${dist_name}
    ...    filter_param=${filter_param}    abbr=${abbr}    new_value=${new_value}
    selenium_coam.validate_plan
    ${defErrs_dic}    selenium_coam.get_definition_errors
    ${relErrs_dic}    selenium_coam.get_relation_errors
    ${hdwErrs_dic}    selenium_coam.get_hardware_errors
    ${defErrs_num}   Get Length   ${defErrs_dic}
    ${relErrs_num}   Get Length   ${relErrs_dic}
    ${hdwErrs_num}   Get Length   ${hdwErrs_dic}
    ${statu}  Run Keyword And Return Status  Should be true  ${defErrs_num}==0 and ${relErrs_num}==0 and ${hdwErrs_num}==0
    Run Keyword If   not ${statu}    Log To Console    \nPDL validate fail, please check

    ${startTime}    BuiltIn.Get Time    epoch
    selenium_coam.activate_plan    activate_plan_despite_errors=${despite_ERR}
    Wait Until Keyword Succeeds    10min    10sec    Check all cells info should be onair   connection=${connection}
    ${endTime}    BuiltIn.Get Time    epoch
    ${siteRest_duration}    Evaluate    ${endTime}-${startTime}
    Run Keyword And Continue On Failure   Should Be True    ${siteRest_duration} < ${Site_reset_downtime_duration}

    ${sleep_time}    Evaluate    ${X2_link_shutdown_time}-1
    Run Keyword If    ${check_alarm}    Run Keywords
    ...    Sleep    5min    AND
    ...    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}   connection=${connection}   AND
    ...    Run Keyword If    ${check_historyalarm}    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=${connection}
    ...    ELSE    Log To Console   \nWarning: not check alarms/history alarms after paramter modify (site reset required)

    Log To Console    \nstart to check l3call after paramter modify (site reset required)
    ${iperf_type}    Get Iperf Type    iperf_type=${iperf_type}    protocol=${protocol}
    ${ui_version}    Get UE UI Version
    Run Keyword If   ${with_call}   _e2e UE L3 Call And Pcmd
    ...    with_pcmd=${with_pcmd}   Iface=${Iface}   cell_id=${Cellid_l3call}   ue_index=${ue_index}
    ...    ue_number=${ue_number}   ui_version=${ui_version}  duration=${duration}   iperf_type=${iperf_type}
    ...    protocol=${protocol}   dl_tp=${dl_tp}   ul_tp=${ul_tp}   dl_exp=${dl_exp}    ul_exp=${ul_exp}
    ...    cell_and_peak_info=${cell_and_peak_info}   target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
    [Teardown]  COAM Teardown gnb connections  connection=${connection}

Reset with HWF deletion for e2e
    [Arguments]  ${check_alarm}=${True}   ${check_historyalarm}=${False}   ${timeout}=600
    ...          ${technology}=NR   ${gnb_type}='NSA'   ${connection}=GNB_OAM_E2E   ${alias}=ASIK Master
    ...          ${with_call}=${True}    ${with_pcmd}=${True}   ${Iface}=br1   ${cell_id}=1
    ...          ${ue_index}=0   ${ue_number}=1   ${duration}=${60}    ${iperf_type}=via_app   ${protocol}=udp
    ...          ${ui_version}=default   ${check_wait_time}=30   ${cell_and_peak_info}=${None}
    ...          ${dl_exp}=60    ${ul_exp}=20    ${dl_tp}=300M  ${ul_tp}=100M
    ...          ${target_avg_percent}=0.1    ${min_percent}=0.1
    Log To Console    \nUpdate swconfig with 0x190030=0 and 0x4F0214=0
#    ${SBTS_verion}    gnb_classical_hangzhou.Get sw build version
#    #Selenium Login And Disable Screen Lock    version=${SBTS_verion}
#    ${ActVersion}   ${CurVersions}   Wait Until Keyword Succeeds   1min   10s   check SW version for e2e   version_type=Active
#    @{Split}    string.Split String    string=${ActVersion}    separator=_
#    ${Split0}     Convert To String    @{Split}[0]
#    ${Split2_Trunk}     Convert To String    @{Split}[2]
#    ${SBTS_release}    Set Variable If   "${Split2_Trunk}"=="9999"   TRUNK   BRANCH
#    Run Keyword If   '${SBTS_release}'=='TRUNK'   Run Keywords
#    ...    Append To List   ${swconfig_list_HWF}   0x4F0214=0   AND
#    ...    Log To Console   \nCurrent program 'TRUNK', add new flag: 0x4F0214=0
#    ...    ELSE   Run Keywords   Append To List   ${swconfig_list_HWF}   0x190030=0   AND
#    ...    Log To Console   \nCurrent program 'BRANCH', add new flag: 0x190030=0
    Modify Swconfig File for e2e    para_update=${swconfig_list_HWF}    alias=${alias}
    #Run Keyword And Ignore Error    COAM Teardown gnb connections
    Connect to gnb coam via ssl    connection=${connection}
    ${startTime}    BuiltIn.Get Time    epoch
    ${result}    coam.reset_site    wait_for_reconnection=True    timeout=${timeout}    connection=${connection}
    #Run Keyword And Continue On Failure    Should Be Equal As Strings    ${result}    ${EMPTY}
    Sleep   5min
    Wait Until Keyword Succeeds    5min    10sec    Check all cells info should be onair   connection=${connection}
    ${endTime}    BuiltIn.Get Time    epoch
    ${siteRest_duration}    Evaluate    ${endTime}-${startTime}
    Run Keyword And Continue On Failure   Should Be True    ${siteRest_duration} < ${Site_reset_downtime_duration}

    Log To Console    \ncheck HWF is disabled by grep "startService loading from hwf is disabled"
    Check gNB Startup log for e2e    connection=${connection}

    #${sleep_time}    Evaluate    ${X2_link_shutdown_time}-1
    Log To Console    \ncheck no fault 4329, 4330, 4230 after cells normal
    #Run Keyword If    ${check_alarm}    Run Keywords
    #...    Sleep    3min    AND
    #...    Unexpect Alarm Should Not Exist   allowed_faults=@{ALLOWED_FAULT}   connection=${connection}   AND
    #...    Run Keyword If    ${check_historyalarm}    Unexpect History Alarm Should Not Exist
    #...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=${connection}
    #...    ELSE    Log To Console   \nWarning: not check alarms/history alarms after HWF reset

    Log To Console    \nstart to check l3call after HWF reset
    ${iperf_type}    Get Iperf Type    iperf_type=${iperf_type}    protocol=${protocol}
    ${ui_version}    Get UE UI Version
    Run Keyword If   ${with_call}   _e2e UE L3 Call And Pcmd    with_pcmd=${with_pcmd}
    ...    Iface=${Iface}   cell_id=${Cellid_l3call}   ue_index=${ue_index}
    ...    ue_number=${ue_number}   ui_version=${ui_version}  duration=${duration}   iperf_type=${iperf_type}
    ...    protocol=${protocol}   dl_tp=${dl_tp}   ul_tp=${ul_tp}   dl_exp=${dl_exp}    ul_exp=${ul_exp}
    ...    cell_and_peak_info=${cell_and_peak_info}   target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
    [Teardown]   Run Keyword And Ignore Error   COAM Teardown gnb connections   connection=${connection}

Verify all other cells should be onair
    [Arguments]    ${cell_exclude}  ${cell_type}=nr  ${connection}=GNB_OAM_E2E
    Log To Console    \nVerify all other cells are on air excluding Cell: ${cell_exclude}
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    Run Keyword And Return Status    should contain any    ${sw_version}   12.400    14.400    22R1    22R2    21B
    ${unlocked}    Set Variable If    ${result}    unlocked    Unlocked
    ${unlocked}    Set Variable If    ${result}==${False} and '${cell_type}'=='lte'    unlocked    ${unlocked}
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        Continue For Loop If    '${cell['globalCellId']}'=='${cell_exclude}'
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell['status']['administrativeState']}     ${unlocked}
        Run Keyword And Continue On Failure    Should be equal as strings    ${cell['status']['operationalState']}    ${enabled}
        Run Keyword If  ${result}    Run Keyword And Continue On Failure
        ...    Should Be Equal As Strings    ${cell['status']['availabilityStatus']}   Online
    END

add fault to the allowed history fault list
    [Arguments]    ${faultId}
    ${ALLOWED_HISTORY_FAULT_TEMP}    Copy List    ${ALLOWED_HISTORY_FAULT}
    ${fault_dic}    Create Dictionary    faultId=${faultId}
    Append To List     ${ALLOWED_HISTORY_FAULT_TEMP}    ${fault_dic}
    Set suite Variable    ${ALLOWED_HISTORY_FAULT}    ${ALLOWED_HISTORY_FAULT_TEMP}

Modify Swconfig File for e2e
    [Arguments]    ${para_update}    ${local_path}=${TS_LOG_PATH_BASE}    ${alias}=ASIK Master
    Run    rm ${local_path}/swconfig*
    csn.Connect to     hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...                alias=${alias}
    #Connect to Common Unit Master    alias=${alias}
    csn.Send Command    command=cp /ffs/run/swconfig.txt /ffs/run/swconfig.txt.bak   connection=${alias}
    #${output}    csn.Read Output    connection=${alias}
    ${error out}    csn.Read Error    connection=${alias}
    Run Keyword If    '${error out}'!='${EMPTY}'    Log To Console  \nErrors from the last command: ${error out}
    swconf.Download swConfig file from asik to test pc    localFilePath=${local_path}/swconfig.txt
    ...                                                   remoteFilePath=/ffs/run/swconfig.txt
    ...                                                   asik_alias=${alias}
    FOR   ${flag}   IN   @{para_update}
        ${config_id}     Should Match Regexp     ${flag}    .*?(?==)
        Run   sed -i -e '/${config_id}.*=.*/'d ${local_path}/swconfig.txt
    END
    swconf.Modify swConfig file    parametersList=${para_update}    filePath=${local_path}/swconfig.txt
    swconf.Upload swConfig file to asik and crasign    localFilePath=${local_path}/swconfig.txt
    ...                                                asik_alias=${alias}
    [Teardown]   Run Keyword And Ignore Error  csn.disconnect    connection=${alias}

Recovery ENV after HWF reset
    [Arguments]   ${timeout}=600    ${connection}=GNB_OAM_E2E
    Rstore Swconfig File for e2e    alias=ASIK Master
    Connect to gnb coam via ssl     connection=${connection}
    ${result}    coam.reset_site    wait_for_reconnection=True    timeout=${timeout}    connection=${connection}
    #Run Keyword And Continue On Failure    Should Be Equal As Strings    ${result}    ${EMPTY}
    Sleep   5min
    Wait Until Keyword Succeeds    5min    10sec    Check all cells info should be onair   connection=${connection}
    [Teardown]   Run Keyword And Ignore Error   COAM Teardown gnb connections   connection=${connection}

Rstore Swconfig File for e2e
    [Arguments]    ${alias}=ASIK Master
    csn.Connect to     hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...                alias=${alias}
    swconf.restore_swConfig_file_on_asik_and_crasign    asik_alias=${alias}
    [Teardown]   Run Keyword And Ignore Error  csn.disconnect    connection=${alias}

Check gNB Startup log for e2e
    [Arguments]  ${connection}=GNB_OAM
    Connect to Common Unit Master    alias=ASIK Master
    ${startup_command} =    Set Variable    cat /tmp/startup_BTSOM.log |grep -i 'startService loading from hwf is disabled'
    ${startup_xz_command} =  Set Variable
    ...       xzcat /ffs/run/logs/fct-0a_aasyslog/startup_BTSOM.log.xz |grep -i 'startService loading from hwf is disabled'
    ${startup_log} =    Check Startup Defualt Log On ASIK
    ...    startup_cmd=${startup_command}    startup_xz_cmd=${startup_xz_command}    info=startService loading from hwf is disabled
    [Teardown]   Run Keyword And Ignore Error  csn.disconnect    connection=ASIK Master

check SW version for e2e
    [Documentation]     output planned/active/passive version
    [Arguments]      ${version_type}
    ${versions}    selenium_coam.check_current_software_version
    ${output}    Set Variable    ${versions}[${version_type}]
    [Return]      ${output}    ${versions}

Get Download Link From Target Version
    [Arguments]    ${InputVersion}=${target_version}
    @{Split}    string.Split String    string=${InputVersion}    separator=_
    ${Split0}     Convert To String    ${Split}[0]
    ${Split2_Trunk}     Convert To String    ${Split}[2]
    ${SBTS_Stream}    Set Variable If   "${Split2_Trunk}"=="9999"   SBTS00   ${Split0}
    ${full_link}=   Catenate    SEPARATOR=/    ${package_link}    ${SBTS_Stream}    ${InputVersion}
    ...    ${InputVersion}_release_BTSSM_downloadable_A54.zip
    Set Test Variable   ${full_link}
    [Return]    ${full_link}

Download SW Build to UTE VM
    [Arguments]    ${package_full_link}
    ${rc}    OperatingSystem.Run And Return Rc    wget -nc --no-proxy ${package_full_link}.sha256 -P ${SW_build_path}
    Should Be Equal As Integers     ${rc}    0
    @{Split}    string.Split String    string=${package_full_link}    separator=/
    ${PackageName_zip}     Convert To String    ${Split}[-1]
    ${md5_file}=    Catenate    SEPARATOR=/    ${SW_build_path}    ${PackageName_zip}.sha256
    ${md5_value}    OperatingSystem.get file    ${md5_file}
    ${rc}    OperatingSystem.Run And Return Rc    wget -nc --no-proxy ${package_full_link} -P ${SW_build_path}
    Should Be Equal As Integers     ${rc}    0
    ${upgrade_package_path}=   Catenate    SEPARATOR=/    ${SW_build_path}    ${PackageName_zip}
    Wait Until Keyword Succeeds   10min   30s   Verify Download to Test PC Completed    FilePath=${upgrade_package_path}
    ...    md5_value=${md5_value}
    [Return]    ${upgrade_package_path}

Verify Download to Test PC Completed
    [Arguments]    ${FilePath}    ${md5_value}
    ${sum}=        Set Variable     sha256sum ${FilePath}
    ${res}    ${output}    Run And Return Rc And Output    ${sum}
    ${res}    string.Split String    ${output}
    should be equal    ${md5_value}    ${res}[0]

Align SBTS stream for Trunk Build
    [Arguments]    ${InputPackage}
    @{Split}    string.Split String    string=${InputPackage}    separator=_
    ${Split0}     Convert To String    ${Split}[0]
    ${Split2_Trunk}     Convert To String    ${Split}[2]
    ${SBTS_Stream}    Set Variable If   "${Split2_Trunk}"=="9999"   SBTS00   ${Split0}
    ${aligned_version}=   String.Replace String   string=${InputPackage}   search_for=${Split0}   replace_with=${SBTS_Stream}
    [Return]    ${aligned_version}
