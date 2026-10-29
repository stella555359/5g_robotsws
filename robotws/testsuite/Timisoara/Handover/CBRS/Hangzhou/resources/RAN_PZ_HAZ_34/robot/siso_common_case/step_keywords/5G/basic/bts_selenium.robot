*** Settings ***
Documentation    This is common keywords for siso RRH related cases
...              Please do not modify the file without notification to author
...              Author: tingting.zhong
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

Resource   testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource   testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource   testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot

*** Keywords ***
Selenium Login And Disable Screen Lock
    [Arguments]    ${download_dir}=${TS_CASE_LOG_PATH}
    ...            ${timeout}=${120}
    ...            ${gnb_index}=${0}
    ...            ${url}=https://${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...            ${version}=SBTS23R4
    ...            ${browser}=Firefox
    ...            ${login_loop}=${3}
    ${status}    run keyword and return status    variable should exist    ${Active_SW_version}
    @{split_version}    run keyword if    ${status}    string.split string    ${Active_SW_version}    separator=_
    ${version}    set variable if    ${status}    ${split_version}[0]    ${version}
    selenium_coam.enable_virtual_display
    Wait Until Keyword Succeeds    ${login_loop}x    10s    selenium_coam.login    url=${url}
    ...                                                                            username=${username}
    ...                                                                            password=${password}
    ...                                                                            download_dir=${download_dir}
    ...                                                                            timeout=${timeout}
    ...                                                                            version=${version}
    ...                                                                            browser=${browser}
    selenium_coam.disable_message_box
    selenium_coam.disable_screen_lock

Selenium Logout And Close Browser
    Run Keyword And Ignore Error    Close Start Up View    timeout=5
    Run Keyword And Ignore Error    selenium_coam.logout
    Run Keyword And Ignore Error    selenium_coam.disable_virtual_display
    Run Keyword And Ignore Error    selenium_coam.close_browser

Close Start Up View
    [Documentation]  workarounds for PR530939, should change it back after PR closed
    [Arguments]   ${timeout}=300
    ${close_flag}    selenium_coam.start_up_view_window_exists    timeout=${timeout}
    run keyword if    ${close_flag}    selenium_coam.close_start_up_view_window

Selenium Login With Version
    [Arguments]  ${SW_version}=${Active_SW_version}    ${download_dir}=${TS_CASE_LOG_PATH}    ${timeout}=${60}
    ${stream}    get stream from version    ${SW_version}
    ${version}=    Set Variable If
    ...     '${stream}'=='SBTS21B'        SBTS21B
    ...     '${stream}'=='SBTS22R1'        SBTS22R1
    ...     '${stream}'=='SBTS22R2'        SBTS22R2
    ...     '${stream}'=='SBTS22R3'        SBTS22R3
    ...     SBTS22R4
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...                    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...                    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...                    download_dir=${download_dir}
    ...                    timeout=${timeout}
    ...                    version=${version}
    selenium_coam.disable_message_box
    selenium_coam.disable_screen_lock

Modify Parameters On Webem
    [Arguments]  ${modify_params}  ${is_activate}=${True}  ${despite_errors}=${False}    ${timeout}=360
    Run Keyword And Ignore Error    Close Start Up View    timeout=10
    ${activate_plan_despite_errors}    set variable if    not ${if_pdl_check}    ${True}    ${despite_errors}
    run keyword and ignore error    run keyword if  ${activate_plan_despite_errors}  run keywords    selenium_coam.refresh_page   AND
    ...    sleep    20s
    FOR  ${item}  IN  @{modify_params}
        Wait Until Keyword Succeeds  3x  30s  selenium_coam.set_parameter_value  dist_name=${item}[dist_name]
        ...    filter_param=${item}[filter_param]
        ...    abbr=${item}[p_name]    new_value=${item}[value]
    END
    Wait Until Keyword Succeeds  3x  20s    selenium_coam.validate_plan
    run keyword if  ${is_activate}==True  selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}
    ...    timeout=${timeout}

Generate Modify Parameters
    [Arguments]  ${modify_params}
    FOR  ${item}  IN  @{modify_params}
        ${dist_name}    get from dictionary  ${item}  dist_name
        ${dist_name}    Replace String    ${dist_name}     {mrbtsID}    ${mrbtsID}
        ${dist_name}    Replace String    ${dist_name}     {nrbtsID}    ${nrbtsID}
        set to dictionary    ${item}    dist_name=${dist_name}
    END
    [Return]  ${modify_params}

Generate Origion Parameters
    [Arguments]  ${modify_params}
    ${new_params}  create list
    FOR  ${item}  IN  @{modify_params}
        ${orig_value}    selenium_coam.get_parameter_value  dist_name=${item}[dist_name]
                    ...    filter_param=${item}[filter_param]
        ${new_item}  create dictionary  dist_name=${item}[dist_name]
                    ...    filter_param=${item}[filter_param]  p_name=${item}[p_name]  value=${orig_value}
        ${status}    run keyword and return status  get from dictionary    ${item}    list_name
        run keyword if  ${status}==${True}   set to dictionary  ${new_item}    list_name=${item}[list_name]
        append to list  ${new_params}  ${new_item}
    END
    [Return]  ${new_params}

Check Parameters Modified Successfully
    [Arguments]  ${modify_params}
    FOR  ${item}  IN  @{modify_params}
        ${new_value}    selenium_coam.get_parameter_value  dist_name=${item}[dist_name]
                    ...    filter_param=${item}[filter_param]
        should be equal as strings  ${item}[value]   ${new_value}
    END

Get Parameter Via Webem
    [Documentation]  Author: tingting.zhong@nokia-sbell.com
    [Arguments]  ${dist_name}  ${filter_param}
    ${value}    selenium_coam.get_parameter_value    dist_name=${dist_name}    filter_param=${filter_param}
    [Return]    ${value}

Get PM Counter content via Webem
    [Documentation]  Author: tingting.zhong@nokia-sbell.com
    [Arguments]    ${counter_id}    ${dist_name}=${None}  ${counter_type}=BTS     ${full_path}=${None}
    ${content}    run keyword if    '${counter_type}'=='BTS'    selenium_coam.get_bts_counters_info
    ...    counter_id=${counter_id}    dist_name=${dist_name}   timeout_for_loading_available_counters=15
    ...    full_path=${full_path}
    ...    ELSE    selenium_coam.get_transport_counters
    ...    counter_id=${counter_id}    timeout_for_loading_available_counters=15
    [Return]     ${content}

Modify Timing Shifter OFF via Webem on gNB
    [Documentation]  Auther: zhihao.shi@nokia-sbell.com
    log to console    \nModify Timing Shifter Off
    ${stream}    get stream from version  version=${Active_SW_version}
    ${filter_param}    set variable if    '${stream}'=='SBTS23R1' or '${stream}'=='SBTS23R2'    Activate cell timing offset
    ...    Activate eCPRI cell timing offset
    selenium_coam.set_parameter_value     dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1
    ...    filter_param=Manual frame timing adjustment
    ...    abbr=manualFrameTimingAdjustment
    ...    new_value=0
    selenium_coam.set_parameter_value     dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=${filter_param}
    ...    abbr=actCellTimingOffset
    ...    new_value=false

Modify Timing Shifter ON via Webem on gNB
    [Documentation]  Auther: zhihao.shi@nokia-sbell.com
    [Arguments]  ${lncel_id}=1
    log to console    \nModify Timing Shifter On
    ${stream}    get stream from version  version=${Active_SW_version}
    ${filter_param}    set variable if    '${stream}'=='SBTS23R1' or '${stream}'=='SBTS23R2'    Activate cell timing offset
    ...    Activate eCPRI cell timing offset
    selenium_coam.set_parameter_value     dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1
    ...    filter_param=Manual frame timing adjustment
    ...    abbr=manualFrameTimingAdjustment
    ...    new_value=0
    selenium_coam.set_parameter_value     dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=${filter_param}
    ...    abbr=actCellTimingOffset
    ...    new_value=true
    ${cell_dist_name}    set variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${lncel_id}
    selenium_coam.set_parameter_value     dist_name=${cell_dist_name}
    ...    filter_param=Frame start offset
    ...    abbr=frameStartOffset
    ...    new_value=3000
    selenium_coam.set_parameter_value     dist_name=${cell_dist_name}
    ...    filter_param=SFN offset
    ...    abbr=sfnOffset
    ...    new_value=0

Modify Timing Shifter via Webem on gNB
    [Documentation]  Auther: zhihao.shi@nokia-sbell.com
    [Arguments]  ${timing_shifter}=ON    ${lncel_id}=1
    run keyword if    '${timing_shifter}'=='ON'    Modify Timing Shifter ON via Webem on gNB    lncel_id=${lncel_id}
    ...    ELSE IF    '${timing_shifter}'=='OFF'    Modify Timing Shifter OFF via Webem on gNB

Site General Modify via Webem on gNB
    [Documentation]  Auther: zhihao.shi@nokia-sbell.com
    [Arguments]    ${ru_index}=${None}    ${timing_shifter}=${None}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    ${cell_id_list}    Get All Cell Id    ru_index=${ru_index}    cell_type=${cell_type}
    FOR    ${cell_id}    IN    @{cell_id_list}
        run keyword if    '${timing_shifter}'!='${None}'
        ...    Modify Timing Shifter via Webem on gNB    timing_shifter=${timing_shifter}    lncel_id=${cell_id}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}    timeout=${300}
    Wait Until Keyword Succeeds    10min    30s    verify all cells should be onair
    [Teardown]  selenium logout and close browser

get origin pmax
    [Arguments]    ${cell_id}=1
    ${orig_value_temp}    selenium_coam.get_parameter_value  dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_id}
    ...  filter_param=Maximum output power
    ${pattern}   Set Variable    (\\d*\.?\\d).*
    ${orig_value_list}    Get Regexp Matches     ${orig_value_temp}    ${pattern}    1
    ${orig_value}    set variable     ${orig_value_list}[0]
    [Return]  ${orig_value}

Check Given RU Led State
    [Arguments]    ${ru}
    ${RU_state}         selenium_coam.get_led_status_of_an_unit     unit=RMOD-${ru}
    Log to console      RU state: ${RU_state}
    [Return]            ${RU_state}

Check Given ASIK Led State
    [Arguments]    ${asik}
    ${ASIK_state}       selenium_coam.get_led_status_of_an_unit     unit=SMOD-${asik}
    Log to console      ASIK state: ${ASIK_state}
    [Return]            ${ASIK_state}

Check Given ABIL Led State
    [Arguments]    ${abil}
    ${ABIL_state}       selenium_coam.get_led_status_of_an_unit     unit=BBMOD-${abil}
    Log to console      ABIL state: ${ABIL_state}
    [Return]            ${ABIL_state}

Get Band SCS SSB
    [Arguments]  ${cell_id}=1
    ${chbw}    selenium_coam.Get Parameter Value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_id}
    ...    filter_param=Channel bandwidth
    ${chbw}    get regexp matches  ${chbw}  [0-9]+
    ${scs}     selenium_coam.Get Parameter Value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELLGRP-0
    ...    filter_param=SCS
    ${scs}    get regexp matches  ${scs}  [0-9]+
    ${ssb}     selenium_coam.Get Parameter Value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_id}
    ...    filter_param=SS Block Subcarrier Spacing
    ${ssb}    get regexp matches  ${ssb}  [0-9]+
    [Return]    ${chbw[0]}  ${scs[0]}  ${ssb[0]}

Change NrBeamforming PM Interval
    [Documentation]  Author: zhihao.shi@nokia-sbell.com
    [Arguments]  ${interval}
    log to console   \nChange NrBeamforming PM Interval to ${interval}
    ${dist_name}    set variable    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPMRNL-1
    ${filter_param}    set variable    Measurement Interval for NR Beamforming
    ${origin_value}  Get Parameter Via Webem    dist_name=${dist_name}    filter_param=${filter_param}
    run keyword if    '${interval}'!='${origin_value}'    selenium_coam.set_parameter_value  dist_name=${dist_name}
    ...    filter_param=${filter_param}
    ...    abbr=miNrBeamforming    new_value=${interval}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    [Return]    ${origin_value}

Download and update BSR package
    [Arguments]    ${BSR_path}    ${BSR_package}
    log to console    \nDownload and update BSR package
    ${BSR_package_path}    set variable     ${BSR_path}${BSR_package}.zip
    selenium_coam.load_software_package_from_local_drive    file_path=${BSR_package_path}
    sleep    15s
    selenium_coam.software_update    is_activate=${True}
    sleep    15s
    ${beam_set_realization_software}    selenium_coam.get_beam_set_realization_software_info    timeout=${120}
    Should Be Equal    ${beam_set_realization_software[0]['BSR package']}    ${BSR_package}

Remove not used beam set realization software
    log to console    \nRemove not used beam set realization software
    ${beam_set_realization_software}    selenium_coam.get_beam_set_realization_software_info    timeout=${120}
    FOR    ${beam_set_info}    IN    @{beam_set_realization_software}
        Run Keyword If    '${beam_set_info['Status']}'=='In use'    Continue For Loop
        @{bsr_package_list}    Create List    ${beam_set_info['BSR package']}
        selenium_coam.delete_beam_set_realization_software_item    bsr_package_list=@{bsr_package_list}
        sleep    5s
    END

Modify actForceUnitAutoReset Parameter
    [Arguments]    ${actForceUnitAutoReset}=true
    ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
    ...    filter_param=Activate Force Unit Autonomous Reset
    ...    abbr=actForceUnitAutoReset
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
    ...    filter_param=Activate Force Unit Autonomous Reset  p_name=actForceUnitAutoReset  value=${actForceUnitAutoReset}
    append to list  ${modify_params}  ${item}
    Run Keyword If    '${currect_status}'!='${actForceUnitAutoReset}'    Modify Parameters On Webem    modify_params=${modify_params}

add new cell via webUI
    [Arguments]  ${physCellId}  ${cell_id}=1  ${cellgrp_id}=0
    log to console  add cell-${cell_id}
    close Start Up View    timeout=60
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1
    ...    object_class_name=LCELNR    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${1}
    ...    include_subobject=${True}   id_value=${cell_id}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELL    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${1}
    ...    include_subobject=${True}   id_value=${cell_id}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELLGRP    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${0}
    ...    id_value=${cellgrp_id}    timeout=15
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${cell_id}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
    ...    filter_param=Physical cell identifier    abbr=physCellId    new_value=${physCellId}
    selenium_coam.add_element    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
    ...    abbr=refNrCellGroup    filter_param=Reference to cell group
    ...    timeout=15
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
    ...    filter_param=Reference to cell group     new_value=${cellgrp_id}
    ...    node_index=${cellgrp_id}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${cellgrp_id}
    ...    filter_param=List of NR cells assigned to cell group     abbr=nrCellList     new_value=${cell_id}
    ...    node_index=${0}

delete cell via webUI
    [Arguments]  ${cell_id}=1  ${cellgrp_id}=0
    log to console  delete cell-${cell_id}
    close Start Up View    timeout=60
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${cellgrp_id}    timeout=15
    selenium_coam.remove_element
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${cellgrp_id}

Check Protocol Change Result Via Webem
    log to console  \n***Check Protocol Change Result Via Webem***
    [Documentation]    Auther: tingting.zhong@nokia-sbell.com
    Run Keyword And Ignore Error    Close Start Up View    timeout=120
    ${result}    Get Parameter Via Webem    dist_name=MRBTS-${mrbtsID}/MNL-1/CMD-1/PRTCLCHGREQ-1/PRTCLCHGRES-1
    ...    filter_param=Protocol change result
    should be equal as strings    ${result}    success

Delete CMD Object If Exist
    log to console  \n***Delete CMD Object If Exist***
    Run Keyword And Ignore Error    Close Start Up View    timeout=120
    ${object_list}    selenium_coam.get_object_name_list    object_name=CMD
    ${test_num}   Get Length   ${object_list}
    Run Keyword If  ${test_num}!=${0}    selenium_coam.remove_object    object_name=CMD-1    timeout=15
    Run Keyword If  ${test_num}!=${0}    selenium_coam.validate_plan
    Run Keyword If  ${test_num}!=${0}    selenium_coam.activate_plan    activate_plan_despite_errors=${True}

Validate Check on WebUI
    Run Keyword And Ignore Error    Close Start Up View    timeout=120
    selenium_coam.validate_plan
    ${relation_errors}    wait until keyword succeeds    1min    5s   selenium_coam.get_relation_errors
    ${list_num}   Get Length   ${relation_errors}
    Should be True    ${list_num}==${0}

Get SFP Monitoring Parameters value
    [Arguments]    ${link_info}    ${status}=connected
    ${linkPorts}    set variable    ${link_info['data']['linkPorts']}
    ${status_link_type}    run keyword and return status     Dictionary Should Contain Key     ${link_info['data']}    linkType
    ${linkType}    Run keyword if    ${status_link_type}==True    set variable    ${link_info['data']['linkType']}    ELSE
    ...    set variable    None
    ${directions}    Get Dictionary keys    ${linkPorts}
    FOR    ${direction}    IN    @{directions}
        ${linkport}    Get From Dictionary    ${linkPorts}    ${direction}
        ${filter_dict}    Run keyword If    '${status}'=='connected'    Create Dictionary    Link ports    ${linkport}    ELSE
        ...    Create Dictionary    Ports    ${linkport}
        ${sfp_table_title}    Run keyword If    '${status}'=='connected'    set variable    SFPs applied to both near and far end in current BTS
        ...   ELSE    set variable    SFPs applied to only one end in current BTS
        ${info}    selenium_coam.get_applied_sfps_info    filter_dict=${filter_dict}    sfp_table_title=${sfp_table_title}
        ${Temperature}    set variable    ${info[0]['Temperature']}
        Should Not Be Equal    ${Temperature}    -    AND    Should not be empty    ${Temperature}
        ${TX_supply_voltage}    set variable    ${info[0]['TX supply voltage']}
        Should Not Be Equal    ${Tx_supply_voltage}    -    AND    Should not be empty    ${Tx_supply_voltage}
        ${TX_bias_current}    set variable    ${info[0]['TX bias current']}
        Should Not Be Equal    ${Tx_bias_current}    -    AND    Should not be empty    ${Tx_bias_current}
        ${TX_optical_power}    set variable    ${info[0]['TX optical power(uW)']}
        Should Not Be Equal    ${TX_optical_power}    -    AND    Should not be empty    ${TX_optical_power}
        ${RX_optical_power}    set variable    ${info[0]['RX optical power(uW)']}
        Should Not Be Equal    ${RX_optical_power}    -    AND    Should not be empty    ${RX_optical_power}
        ${BER}    set variable    ${info[0]['BER']}
        Run keyword if    '${linkType}'=='CPRILink'    Should Not Be Equal    ${BER}    -    AND    Should not be empty    ${BER}    ELSE
        ...    Should Be Equal    '${BER}'    '-'
        ${LCV}    set variable    ${info[0]['LCV']}
        Run keyword if    '${linkType}'=='CPRILink'    Should Not Be Equal    ${LCV}    -    AND    Should not be empty    ${LCV}    ELSE
        ...    Should Be Equal    '${LCV}'    '-'
    END

change nr cell type under ru
    [Arguments]  ${cell_id_list}    ${nrCellType}=8DL4UL
    log to console  update nrCellType to ${nrCellType}
    FOR  ${cell_id}  IN  @{cell_id_list}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=NR Cell type    abbr=nrCellType    new_value=${nrCellType}
        selenium_coam.remove_object
        ...    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-2/CHANNEL-5
        ...    timeout=15
        selenium_coam.remove_object
        ...    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-2/CHANNEL-6
        ...    timeout=15
        selenium_coam.remove_object
        ...    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-2/CHANNEL-7
        ...    timeout=15
        selenium_coam.remove_object
        ...    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-2/CHANNEL-8
        ...    timeout=15
    END
    selenium_coam.validate_plan
    ${defErrs_dic}    selenium_coam.get_definition_errors
    ${list_num}   Get Length   ${defErrs_dic}
    Should be true    ${list_num}==${0}
    selenium_coam.activate_plan    timeout=120
    sleep    60

Modify RMOD Power Parameter
    [Arguments]    ${power_status}=true
    Selenium Login And Disable Screen Lock
    ${currect_status}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate micro discontinued transmission
    ...    abbr=actMicroDTX
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate micro discontinued transmission  p_name=actMicroDTX  value=${power_status}
    append to list  ${modify_params}  ${item}
    Run Keyword If    '${currect_status}'!='${power_status}'    Modify Parameters On Webem    modify_params=${modify_params}
    [Teardown]  Selenium Logout And Close Browser

excute ru unlock
    [Documentation]
    ...    *****************
    ...    Owner_zhenzhen.ren@nokia-sbell.com
    ...    ******************
    [Arguments]    ${ru_index_list}
    log to console    \n***excute ru unlock***
    FOR  ${ru_index}  IN  @{ru_index_list}
        run keyword and ignore error    selenium_coam.unlock_ru    ru_index=${ru_index}
    END

Perform RF Module Reset from GUI
    [Arguments]  ${ru_index}=1    ${gnb_index}=${0}     ${connection}=GNB_OAM
    log to console    \n***Perform RF Module Reset from GUI***
    ${ru_index}  Convert To Integer    ${ru_index}
    Selenium Login And Disable Screen Lock   gnb_index=${gnb_index}
    selenium_coam.reset_ru  ru_index=${ru_index}
    Wait Until Keyword Succeeds    5min    5s    RU Should Be Offline    ru_index=${ru_index}    connection=${connection}
    [Teardown]  Selenium Logout And Close Browser

Modify TimeZone In Scf And Commissioning
    log to console    \n***Modify TimeZone In Scf And Commissioning***
	@{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    ${version}=    Set Variable If
    ...     '${stream}'=='SBTS24R1'        SBTS24R1
    ...     '${stream}'=='SBTS24R3'        SBTS24R3
    ...     '${stream}'=='SBTS24R2'        SBTS24R2
    ...     '${stream}'=='SBTS23R4'        SBTS23R4
    ...     SBTS25R1
    ${modify_params}  create list
	${timezone}    run keyword if    '${version}'=='SBTS25R1'    selenium_coam.Get Parameter Value    dist_name=MRBTS-${mrbtsID}/MNL-1
    ...    filter_param=Time zone
    ...    ELSE    selenium_coam.Get Parameter Value    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/SYNC-1/TIME-1
	...    filter_param=Time zone

    run keyword and ignore error  Remove Values From List    ${timezone_list}    ${timezone}
    ${change_timezone}  evaluate  random.choice(${timezone_list})    modules=random
    ${object_list}    selenium_coam.get_object_name_list    object_name=SYNC-
    log to console    ${object_list}
    FOR  ${object}  IN  @{object_list}
        ${item}    run keyword if    '${version}'=='SBTS25R1'    create dictionary    dist_name=MRBTS-${mrbtsId}/MNL-1    filter_param=Time zone
        ...    p_name=timeZone    value=${change_timezone}
		...    ELSE    create dictionary    dist_name=MRBTS-${mrbtsId}/MNL-1/MNLENT-1/${object}/TIME-1    filter_param=Time zone
        ...    p_name=timeZone    value=${change_timezone}
        append to list    ${modify_params}    ${item}
    END
    ${origin_params}  generate origion parameters  ${modify_params}
    [Return]  ${modify_params}  ${origin_params}

Add PRTCLCHGRES Object Via Webem
    [Arguments]   ${ru_index_list}   ${link_speed}   ${radio_protocol_type}
    log to console  \n***Add PRTCLCHGRES Object Via Webem***
    Run Keyword And Ignore Error    Close Start Up View    timeout=120
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1
    ...    object_class_name=CMD    id_value=1    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/CMD-1
    ...    object_class_name=PRTCLCHGREQ    id_value=1    timeout=15
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${dist_name}    set variable    MRBTS-${mrbtsID}/MNL-1/CMD-1/PRTCLCHGREQ-1
        ${ru_index_temp}    convert to number  ${ru_index}
        ${node_index_temp}    Evaluate  ${ru_index_temp}-1
        selenium_coam.add_element    dist_name=${dist_name}
        ...    filter_param=Radio modules upgrade    abbr=rModUpgrade    timeout=15
        selenium_coam.set_parameter_value  dist_name=${dist_name}    filter_param=Link speed
        ...    abbr=linkSpeed    new_value=${link_speed}    node_index=${node_index_temp}
        selenium_coam.set_parameter_value  dist_name=${dist_name}    filter_param=Radio protocol type
        ...    abbr=radioProtocolType    new_value=${radio_protocol_type}    node_index=${node_index_temp}
        selenium_coam.set_parameter_value  dist_name=${dist_name}    filter_param=Radio module distinguished name
        ...    abbr=rModDN    new_value=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    node_index=${node_index_temp}
    END
    selenium_coam.validate_plan
    run keyword and ignore error    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=15

update pMAX Via Webem
    [Arguments]  ${cell_id_list}  ${max_pmax}=36.9  ${min_pmax}=33.9
    Selenium Login And Disable Screen Lock
    log to console  \n set pMAX to ${max_pmax} for cell_1 and set pMAX to ${min_pmax} for cell_2
    FOR  ${cell_id}  IN  @{cell_id_list}
        ${pmax_temp}    Set Variable If   ${cell_id} == ${1}    ${max_pmax}     ${min_pmax}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Maximum output power    abbr=pMax    new_value=${pmax_temp}
    END
    selenium_coam.validate_plan
    ${defErrs_dic}    selenium_coam.get_definition_errors
    ${list_num}   Get Length   ${defErrs_dic}
    Should be true    ${list_num}==${0}
    selenium_coam.activate_plan    timeout=120
    sleep    60
    [Teardown]  Selenium Logout And Close Browser

Modify Parameter if Need Modify
    [Arguments]    ${dist_name}    ${filter_param}    ${new_value}
    ${status}    ${value}    run keyword and ignore error    selenium_coam.get_parameter_value    dist_name=${dist_name}
    ...    filter_param=${filter_param}
    return from keyword if    '${status}'=='FAIL'
    run keyword if    '${value}'!='${new_value}'    Wait Until Keyword Succeeds    3x   10s    selenium_coam.set_parameter_value
    ...    dist_name=${dist_name}    filter_param=${filter_param}    new_value=${new_value}

Delete Parameter if Need Delete
    [Arguments]    ${dist_name}    ${filter_param}
    ${status}    ${value}    run keyword and ignore error    selenium_coam.get_parameter_value    dist_name=${dist_name}
    ...    filter_param=${filter_param}
    run keyword if    '${status}'=='PASS' and '${value}'!=''    selenium_coam.delete_parameter    dist_name=${dist_name}
    ...    filter_param=${filter_param}      timeout=${60}

Prepare for delete NRPGRP
    Modify Parameter if Need Modify    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Power saving avoidance options for priority access calls    new_value=PA avoidance disabled
    Modify Parameter if Need Modify    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR load-based mMIMO TX power saving    new_value=false
    Modify Parameter if Need Modify    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate coordinated 4G-5G power saving, 5G    new_value=disabled
    Modify Parameter if Need Modify    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate load-based PS control logic enhancement    new_value=false
    Modify Parameter if Need Modify    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR cell-level extended configurations for MIMO muting and cell switch off
    ...    new_value=false
    Modify Parameter if Need Modify    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR load-based power saving    new_value=false
    Modify Parameter if Need Modify    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate mixed mode load-based power saving    new_value=false

Get Mapping Between Cell Index And NrCellIdentity Via WebEM
    [Arguments]  ${cell_id}    ${technology}=NR    ${gnb_index}=${0}
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    Selenium Login And Disable Screen Lock    gnb_index=${gnb_index}
    ${cell_info}    selenium_coam.get_cell_info    cell_idx=${cell_id}    technology=${technology}
    ${cell_index}    Convert To Integer    ${cell_info}[Global cell ID]
    @{split_cell_group}    string.split string    ${cell_info}[Cell group]    separator=-
    ${cell_group_index}    Convert To Integer    ${split_cell_group}[-1]
    ${nr_cell_identity}    Convert To Integer    ${cell_info}[NR cell ID]
    ${cell_id_mapping_info}    Create Dictionary    cell_group_id=${cell_group_index}    nrCellIdentity=${nr_cell_identity}
    ${cell_mapping_info}    Create Dictionary    ${cell_index}=${cell_id_mapping_info}
    [Return]    ${cell_mapping_info}
