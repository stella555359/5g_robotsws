*** Settings ***
Documentation     author: Xu Echo, Jian.1.Chen
...               contact: echo.xu@nokia-sbell.com; jian.1.chen@nokia-sbell.com
...               squad group: mmW_05
...               feature : 5GC002033

Resource     taf/rfrl/bts/robot/common/gnb_cell.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ru_soap_log.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Keywords ***
Cloud SISO Coam Suite Setup
    [Documentation]    Auther: jian.1.chen@nokia-sbell.com
    log to console    \n***SISO Coam Suite Setup***
    run keyword if     ${if_commissioning}    CI_interface.Common Suite Setup
    Cloud DU connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    ${Golden_SCF_Path}    Get Golden SCF Path
    set suite variable      ${Golden_SCF_Path}
    ${gNb_CuType}   Get gNB CU type
    set suite variable      ${gNb_CuType}
    run keyword if     ${if_update_swconfig}    update swconfig for gNB
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Cloud DU connect to gnb coam via ssl
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${scf_path}    cell_id=${CELL_ID}
    log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
    set suite variable  ${mrbtsID}
    set suite variable  ${nrbtsID}
    run keyword if     '${ru_type_init}'=='AEQN'    remove fault 4687 from allowed fault list
    run keyword if     '${testline_name}' == 'null'    add fault to the allowed fault list    faultId=${4681}
    run keyword if     '${gNb_CuType}'=='NSA' or '${gNb_CuType}'=='SA+NSA'
    ...    Run Keyword And Ignore Error    get eNB active version

Cloud SISO Coam Suite Teardown
    log to console    \n***SISO Coam Suite Teardown***
    Wait Until Keyword Succeeds    5min    30s    Cloud DU connect to gnb coam via ssl
    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
    Run Keyword If    ${ru_status}==${False} or ${cell_status}==${False} and ${if_teardown_commissioning}
    ...    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
    COAM Teardown gnb connections
    Run Keyword And Ignore Error    process.Terminate All Processes    kill=True

Cloud SISO Coam Test Setup
    log to console    \n***SISO Coam Test Setup***
    log to console    gNB CU type:${gNb_CuType}
    log to console    Active_SW_version(gNB):${Active_SW_version}
    run keyword if    '${gNb_CuType}'=='NSA' or '${gNb_CuType}'=='SA+NSA'
    ...    Run Keyword And Ignore Error    Log to console    Active_SW_version(eNB):${enb_active_version}
    Generate test case log path
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Cloud DU connect to gnb coam via ssl
    ${ru_info}    COAM get all ru detail info
    &{ru_info}    Set variable    ${ru_info['1']}
    run keyword and ignore error  should contain  ${TEST_NAME}  ${ru_info}[productName]
    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
    ${Status}    ${key}   run keyword and ignore error   get specified scf
    ${SCF_Path}    set variable if      '${Status}'=='PASS'    ${key}[0]    ${Golden_SCF_Path}
    ${SCF_Status}    set variable if      '${Status}'=='PASS'    ${key}[1]    ${False}
    Set Test Variable    ${Case_SCF_Path}    ${SCF_Path}
    Run Keyword If    ${ru_status}==${False} or ${cell_status}==${False} or ${SCF_Status}==${True}
    ...    Commissioning SCF And Check On Air      scf_path=${SCF_Path}
    Start Btslog With Path Check
    Run Keyword And Ignore Error    selenium_coam.close_browser

Cloud SISO Coam Test Teardown
    log to console    \n***SISO Coam Test Teardown***
    Cloud DU connect to gnb coam via ssl
    ${ru_status}   run keyword and ignore error   COAM Check GNB RU status
    log to console  RU status: ${ru_status}
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
    should be true    ${cell_status}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=${ALLOWED_HISTORY_FAULT}
    ${rc}    ${output} =    Run and Return RC and Output    ps -ef | grep ${btslog_dir} | grep -v grep
    run keyword if    '${btslog_dir}'!='none' and ${rc}==${0}    Stop Btslog Collect    target_dir=${SAVE LOG DIRECTORY}
    run keyword if test failed     Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}
    COAM Teardown gnb connections
    CI_interface.Common Case Teardown

Verify RU Online
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]  ${ru_index}=${1}    ${connection}=GNB_OAM
    &{ru_status}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    Should be equal as strings    ${ru_status['status']['operationalState']}    Enabled
    Should be equal as strings    ${ru_status['status']['availabilityStatus']}    Online
    Should be equal as strings    ${ru_status['status']['proceduralStatus']}    configured

Verify RU Offline
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]  ${ru_index}=${1}    ${connection}=GNB_OAM
    &{ru_status}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    Should be equal as strings    ${ru_status['status']['operationalState']}    Disabled
    Should be equal as strings    ${ru_status['status']['availabilityStatus']}    NotInstalled
    Should be equal as strings    ${ru_status['status']['proceduralStatus']}    not initialized

Download Soap Log From RU Reg
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Download soap log from ru with regular expression
    ...    Generally used after the ru restart
    [Arguments]    ${soap_log}=UnitOAM_SOAP_Log*.xml    ${log_path}=${TS_CASE_LOG_PATH}    ${ru_alias}=RU
    ${soap_log_fullpath}    csn.execute    command=ls -l /ram/${soap_log}    connection=${ru_alias}
    ${soap_log_fullpath}    Strip String    string=${soap_log_fullpath}
    ${soap_log_path}    ${soap_log_name}    split path    ${soap_log_fullpath}
    Wait Until Keyword Succeeds    5 min    5 sec    csn.Download File    remote_path=/ram/${soap_log_name}
    ...    local_path=${log_path}/${soap_log_name}    connection=${ru_alias}
    OperatingSystem.Run    mv '${log_path}/${soap_log_name}' '${log_path}/${ru_alias}_${soap_log_name}'
    [Return]    ${log_path}/${ru_alias}_${soap_log_name}
    [Teardown]    csn.disconnect    connection=${ru_alias}

Check Soap Log With Parameter
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Analysis soap log and check parameter value
    [Arguments]    ${soap_log_path}    ${parameter}    ${value}
    ${soap_info}    soap.get_soap_msg_module_ready_ind    ${soap_log_path}
    ${soap_parameter_value} =    Get From Dictionary    ${soap_info}    ${parameter}
    Should Be Equal As Strings    ${soap_parameter_value}    ${value}

Recommission Parameter On Enb
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Example params
    ...    dist_name : MRBTS-1837/LNBTS-3547/LNCEL-1
    ...    parameter_name : defaultLnRelGnbCellId
    ...    value : 5
    [Arguments]    ${dist_name}    ${parameter_name}    ${value}
    Connect to eNB via ssl
    Modify the parameter on enblte    dist_name=${dist_name}    parameter_name=${parameter_name}    value=${value}
    Enblte close down

UE Attach And Get Wireshark Log
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Example params
    ...    remote_pcap_path : /tmp/tmp.pcap
    ...    local_pcap_path : /home/ute/tmpcj/5GC002033/case11.pcap
    [Arguments]    ${remote_pcap_path}    ${local_pcap_path}    ${ue_index}=0    ${connection}=gnb    ${interface}=any
    ${ue_type}    translate power ue type from testline    ${ue_index}
    Start To Capture Wireshark Log From DU
    power_ue.Prepare UE    ue_type=${ue_type}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.UE Detach    ue_type=${ue_type}   ue_index=${ue_index}
    Stop To Capture Wireshark Log From DU    local_pcap_path=${local_pcap_path}

Verify No Reestablishment In Pdml
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${local_pdml_path}    ${field_name}=nr-rrc.reestablishmentCause
    ${values}    get_list_of_values    ${local_pdml_path}    ${field_name}
    Should Be Empty    ${values}

Verify UE Reachable Via Ping From Appserver
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=0    ${connection}=appserver
    ...    ${ping_success_flag}=, 0% packet loss
    ${ue_ip}    Get UE IP Address
    csn.Connect To    hostname=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.addr}
    ...               username=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.username}
    ...               password=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.password}
    ...               alias=${connection}
    csn.send_command   command=ping -c 10 ${ue_ip}    connection=${connection}
    ${ping_result}    csn.Read Output    connection=${connection}
    Builtin.Should Contain    ${ping_result}    ${ping_success_flag}
    [Teardown]    csn.disconnect    connection=${connection}

Verify Call Possible On Cell
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Example params
    ...    dist_name : MRBTS-1837/LNBTS-3547/LNCEL-1
    ...    parameter_name : defaultLnRelGnbCellId
    ...    value : 5
    ...    remote_pcap_path : /tmp/tmp.pcap
    ...    local_pcap_path : /home/ute/tmpcj/5GC002033/case11.pcap
    ...    field_name : nr-rrc.physCellId
    ...    field_value : 50
    [Arguments]    ${dist_name}    ${parameter_name}    ${value}
    ...    ${remote_pcap_path}    ${local_pcap_path}
    ...    ${field_name}    ${field_value}
    Recommission Parameter On Enb    dist_name=${dist_name}    parameter_name=${parameter_name}    value=${value}
    UE Attach And Get Wireshark Log    remote_pcap_path=${remote_pcap_path}    local_pcap_path=${local_pcap_path}
    ${local_pdml_path}    Convert Wireshark Log Pcap To Pdml    local_pcap_path=${local_pcap_path}
    Check Field Value In Pdml    field_name=${field_name}    field_value=${field_value}    local_pdml_path=${local_pdml_path}

Verify Call Possible On Cell List
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${dist_name}    ${parameter_name}
    ...    ${remote_pcap_path}    ${local_pcap_path}
    ...    ${field_name}    ${cell_dict}
    FOR    ${key}    IN    @{cell_dict}
        Wait Until Keyword Succeeds    3x    5s    Verify Call Possible On Cell
        ...    dist_name=${dist_name}    parameter_name=${parameter_name}    value=${key}
        ...    remote_pcap_path=${remote_pcap_path}    local_pcap_path=${local_pcap_path}
        ...    field_name=${field_name}    field_value=${cell_dict['${key}']}
    END

Verify Call Stability On Cell
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Require suite level variables
    ...    Example params
    ...    dist_name : MRBTS-1837/LNBTS-3547/LNCEL-1
    ...    parameter_name : defaultLnRelGnbCellId
    ...    value : 5
    ...    remote_pcap_path : /tmp/tmp.pcap
    ...    local_pcap_path : /home/ute/tmpcj/5GC002033/case7.pcap
    ...    field_name : nr-rrc.physCellId
    ...    field_value : 50
    ...    UE_INDEX : 0
    ...    DL_TIME : 10
    ...    DL_PORT : 3456
    ...    WINDOW : 100M
    [Arguments]    ${dist_name}    ${parameter_name}    ${value}
    ...    ${remote_pcap_path}    ${local_pcap_path}
    ...    ${field_name}    ${field_value}
    Recommission Parameter On Enb    dist_name=${dist_name}    parameter_name=${parameter_name}    value=${value}
    ${ue_type}    translate power ue type from testline    ${UE_INDEX}
    Start To Capture Wireshark Log From DU
    power_ue.Prepare UE    ue_type=${ue_type}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${UE_INDEX}
    Verify UE Reachable Via Ping From Appserver
    UE Start DL Traffic    throughput=100M
    power_ue.UE Detach    ue_type=${ue_type}   ue_index=${UE_INDEX}
    Stop To Capture Wireshark Log From DU    local_pcap_path=${local_pcap_path}
    ${local_pdml_path}    Convert Wireshark Log Pcap To Pdml    local_pcap_path=${local_pcap_path}
    Verify No Reestablishment In Pdml    local_pdml_path=${local_pdml_path}

Verify Call Stability On Cell List
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${dist_name}    ${parameter_name}
    ...    ${remote_pcap_path}    ${local_pcap_path}
    ...    ${field_name}    ${cell_dict}
    FOR    ${key}    IN    @{cell_dict}
        Wait Until Keyword Succeeds    3x    5s    Verify Call Stability On Cell
        ...    dist_name=${dist_name}    parameter_name=${parameter_name}    value=${key}
        ...    remote_pcap_path=${remote_pcap_path}    local_pcap_path=${local_pcap_path}
        ...    field_name=${field_name}    field_value=${cell_dict['${key}']}
    END

Perform RU Module Reset From GUI
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${ru_index}=${1}
    ${ru_index}  Convert To Integer    ${ru_index}
    COAM Navigate to login page via webUI   url=https://${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    selenium_coam.reset_ru  ru_index=${ru_index}
    [Teardown]  COAM selenium logout

Cloud SiSo RF Module Reset From GUI
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${gnb_index}=0    ${du_index}=0
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Module Reset From GUI    ru_index=${ru_index}
        Wait Until Keyword Succeeds    5min    5s    Verify RU Offline    ru_index=${ru_index}
    END
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    COAM Navigate to login page via webUI   url=https://${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    selenium_coam.disable_screen_lock
    Check RF Startup and Gnb Status From DU    ${ru_index_list}
    verify all cells should be onair
    [Teardown]  Selenium Logout And Close Browser

Check RF Startup and Gnb Status From DU
    [Arguments]  ${ru_index_list}    ${connection}=GNB_OAM    ${gnb_index}=0    ${du_index}=0
    log to console    \n***Check RF Startup and Gnb Status***
    connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    connection=${connection}
    ${fsm_status}  ${fsm_name}    Coam Get FSM operationalState and Name
    ${result}    get release flag    connection=${connection}
    ${led_status}       set variable if      ${result}    Online    Enabled
    ${fsm_num}   get length  ${fsm_name}
    FOR  ${index}  IN RANGE  1  ${fsm_num}+${1}
        ${led_ASIK}    run keyword and ignore error       Check Given ASIK Led State    asik=${index}
        should be equal   ${led_ASIK[1]}   ${led_status}
    END
    ${fbb_status}  ${fbb_name}    Coam Get FBB operationalState and Name
    ${fbb_num}   get length  ${fbb_name}
    FOR  ${index}  IN RANGE  1  ${fbb_num}+${1}
        ${led_ABIL}    run keyword and ignore error       Check Given ABIL Led State    abil=${index}
        should be equal   ${led_ABIL[1]}   ${led_status}
    END
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${led_RU}    run keyword and ignore error       Check Given RU Led State    ru=${ru_index}
        should be equal   ${led_RU[1]}   ${led_status}
    END

Online Delete Cell
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${cell_id}    ${mrbts_id}    ${nrbts_id}
    ...    ${cell_group_id}=0    ${gnb_index}=0    ${du_index}=0
    Cloud DU connect to gnb coam via ssl
    ${cell_ids}    Get All Cell Id
    ${cell_id_int}    Convert To Integer    ${cell_id}
    ${node_index}    Get Index From List    ${cell_ids}    ${cell_id_int}
    ${dist_name}    Set Variable    MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
    ${cell_dist_name}    Set Variable    ${dist_name}/NRCELL-${cell_id}
    ${cell_group_dist_name}    Set Variable    ${dist_name}/NRCELLGRP-${cell_group_id}
    COAM Navigate to login page via webUI   url=https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
    selenium_coam.disable_screen_lock
    selenium_coam.remove_object    object_name=${cell_dist_name}
    selenium_coam.remove_object    object_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}
    selenium_coam.remove_element    dist_name=${cell_group_dist_name}
    ...    filter_param=List of NR cells assigned to cell group
    ...    node_index=${node_index}
    selenium_coam.validate_plan
    selenium_coam.activate_plan   activate_plan_despite_errors=True    timeout=300

Online Add Cell Based On Existing Cell
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${cell_info}    ${mrbts_id}    ${nrbts_id}
    ...    ${cell_group_id}=0    ${nrcell_include_subobject}=False
    ...    ${gnb_index}=0    ${du_index}=0
    Cloud DU connect to gnb coam via ssl
    ${cell_ids}    Get All Cell Id
    ${cell_count}    Get Length    ${cell_ids}
    ${cell_id}    Get From Dictionary    ${cell_info}    cell_id
    ${cell_id_to_copy_from}    Get From Dictionary    ${cell_info}    cell_id_to_copy_from
    ${dist_name}    Set Variable    MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
    ${cell_dist_name}    Set Variable    ${dist_name}/NRCELL-${cell_id}
    ${cell_group_dist_name}    Set Variable    ${dist_name}/NRCELLGRP-${cell_group_id}
    COAM Navigate to login page via webUI   url=https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
    selenium_coam.disable_screen_lock
    selenium_coam.add_object    object_name=${dist_name}
    ...    object_class_name=NRCELL    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=${dist_name}/NRCELL-${cell_id_to_copy_from}    include_subobject=${nrcell_include_subobject}
    ...    id_value=${cell_id}
    ${physCellId}    Get From Dictionary    ${cell_info}    physCellId
    selenium_coam.set_parameter_value    dist_name=${cell_dist_name}
    ...    filter_param=Physical cell identifier   new_value=${physCellId}    abbr=physCellId
    ${nrarfcn}    Get From Dictionary    ${cell_info}    nrarfcn
    selenium_coam.set_parameter_value    dist_name=${cell_dist_name}
    ...    filter_param=NR Absolute radio frequency channel number   new_value=${nrarfcn}    abbr=nrarfcn
    ${gscnOrSsPbchArfcn}    Get From Dictionary    ${cell_info}    gscnOrSsPbchArfcn
    selenium_coam.set_parameter_value    dist_name=${cell_dist_name}
    ...    filter_param=Synchronization channel number   new_value=${gscnOrSsPbchArfcn}    abbr=gscnOrSsPbchArfcn
    ${lcrId}    Get From Dictionary    ${cell_info}    lcrId
    selenium_coam.set_parameter_value    dist_name=${cell_dist_name}
    ...    filter_param=Local cell resource ID    new_value=${lcrId}    abbr=lcrId
    ${type0CoresetConfigurationIndex}    Get From Dictionary    ${cell_info}    type0CoresetConfigurationIndex
    selenium_coam.set_parameter_value    dist_name=${cell_dist_name}
    ...    filter_param=Coreset configuration Index   new_value=${type0CoresetConfigurationIndex}    abbr=type0CoresetConfigurationIndex
    selenium_coam.add_element    dist_name=${cell_group_dist_name}
    ...    filter_param=List of NR cells assigned to cell group    abbr=nrCellList
    selenium_coam.set_parameter_value    dist_name=${cell_group_dist_name}
    ...    filter_param=List of NR cells assigned to cell group  node_index=${cell_count}  new_value=${cell_id}    abbr=nrCellList
    selenium_coam.add_object    object_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/CELLMAPPING-1
    ...    object_class_name=LCELNR    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id_to_copy_from}    include_subobject=True
    ...    id_value=${cell_id}
    selenium_coam.validate_plan
    selenium_coam.activate_plan   activate_plan_despite_errors=True    timeout=300

Recommission Parameter On gNB
    [Documentation]    Author: echo.xu@nokia-sbell.com
    ...    Example params
    ...    dist_name : MRBTS-1839/NRBTS-10341
    ...    parameter_name : actCarrierAggregation
    ...    value : true
    [Arguments]    ${dist_name}    ${parameter_name}    ${value}
    Cloud DU connect to gnb coam via ssl
    Modify the parameter on gNB    dist_name=${dist_name}    parameter_name=${parameter_name}    value=${value}
    #COAM Teardown gnb connections

Modify the parameter on gNB
    [Arguments]    ${dist_name}    ${parameter_name}    ${value}
    enblte.perform_parameter_recommissioning       dist_name=${dist_name}
    ...                                            parameter=${parameter_name}
    ...                                            operation=update
    ...                                            value=${value}
    ...                                            connection=GNB_OAM

Cloud SiSo BTS site reset
    [Documentation]   Auther: echo.xu@nokia-sbell.com
    [Arguments]    ${cell_idx}=0     ${locked_cell_idx}=0    ${gnb_index}=0    ${du_index}=0
    COAM Navigate to login page via webUI    url=https://${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    #selenium_coam.reset_site
    coam.Reset Site   connection=${coam_alias}   wait_for_reconnection=${true}
    selenium_coam.disable_screen_lock
    COAM Wait gnb And expect Cells ready    locked_cell_idx=${locked_cell_idx}    timeout=15 min
    Wait Until Keyword Succeeds    3min    20 sec    Cell Should Be Locked    cell_idx=${cell_idx}
    ...   cell_group_idx=0
    [Teardown]  Selenium Logout And Close Browser

COAM Wait gnb And expect Cells ready
    [Arguments]     ${locked_cell_idx}=0   ${timeout}=10 min    ${connection}=GNB_OAM    ${gnb_type}='NSA'
    coam wait for gnb ready and cell setup    timeout=${timeout}    connection=${connection}     gnb_type=${gnb_type}
    Wait until keyword succeeds    20 min    20 sec   verify expected cells should be onair    connection=${connection}
    ...   locked_cell_idx=${locked_cell_idx}

Verify expected cells should be onair
    [Documentation]    Author: echo.xu@nokia-sbell.com
    ...                Description: verify all the cells status should be correct.
    [Arguments]    ${connection}=GNB_OAM    ${locked_cell_idx}=0
    Log to console    Verify expected cells should be onair
    ${cell_info}   coam.get_subcells_status   timeout=20    connection=${connection}
    ${cell_group_list}    get dictionary keys    ${cell_info}
    FOR    ${cell_group}    IN    @{cell_group_list}
        ${cell_from_cellgrp}    Get from Dictionary    ${cell_info}    ${cell_group}
        remove from dictionary    ${cell_from_cellgrp}    ${locked_cell_idx}
        All expected cells in cell group should be onair    ${cell_from_cellgrp}
    END

All expected cells in cell group should be onair
    [Documentation]    Author: echo.xu@nokia-sbell.com
    [Arguments]   ${cell_from_cellgrp}
    ${cell_list}    Get Dictionary Keys    ${cell_from_cellgrp}
    FOR  ${cell}  IN   @{cell_list}
        ${eachcell}    Get from Dictionary    ${cell_from_cellgrp}    ${cell}
        Run keyword and continue on failure    Should Be Equal As Strings    ${eachcell['NRCELL_R']['administrativeState']}     Unlocked
        Run keyword and continue on failure    Should Be Equal As Strings    ${eachcell['NRCELL_R']['availabilityStatus']}   Online
        Run keyword and continue on failure    Should Be Equal As Strings    ${eachcell['NRCELL_R']['operationalState']}   Enabled
    END

Cloud SiSo Lock one cell and check status
    [Documentation]   Auther: echo.xu@nokia-sbell.com
    [Arguments]    ${dist_name}    ${parameter_name}    ${value}    ${cell_idx}    ${allowed_faults}
    ...    ${gnb_index}=0    ${du_index}=0
    Recommission Parameter On gNB    dist_name=${dist_name}    parameter_name=${parameter_name}    value=${value}
    Cloud DU connect to gnb coam via ssl
    Wait Until Keyword Succeeds    3min    20 sec    Cell Should Be Locked    cell_idx=${cell_idx}
    ...   cell_group_idx=0
    Wait until keyword succeeds    3min    20 sec    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}

Cloud SiSo Unlock one cell and check status
    [Documentation]   Auther: echo.xu@nokia-sbell.com
    [Arguments]    ${dist_name}    ${parameter_name}    ${value}    ${cell_idx}    ${allowed_faults}
    ...    ${gnb_index}=0    ${du_index}=0
    Recommission Parameter On gNB    dist_name=${dist_name}    parameter_name=${parameter_name}    value=${value}
    Cloud DU connect to gnb coam via ssl
    Wait Until Keyword Succeeds    10min    20 sec    Cell Should Be Unlocked    cell_idx=${cell_idx}
    ...   cell_group_idx=0
    Wait until keyword succeeds    3min    20 sec    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}

Site Reset With One Cell Locked Repetition
    [Arguments]    ${dist_name}    ${parameter_name}    ${value}    ${cell_idx}    ${allowed_faults}    ${locked_cell_idx}
    FOR    ${index}    IN RANGE    20
        Cloud SiSo Lock one cell and check status    dist_name=${DIST_NAME2}    parameter_name=${parameter_name2}
        ...    value=${value_3}    cell_idx=${CELL_ID}    allowed_faults=${exist_fault}
        Cloud SiSo BTS site reset    cell_idx=${CELL_ID}    locked_cell_idx=${locked_cell_idx}
        Cloud SiSo Unlock one cell and check status    dist_name=${DIST_NAME2}    parameter_name=${parameter_name2}
        ...    value=${value_4}    cell_idx=${CELL_ID}    allowed_faults=${exist_fault}
    END

Cloude_SiSo_RU_lock_unlock
    [Documentation]    Author: echo.xu@nokia-sbell.com
    [Arguments]    ${gnb_index}=0    ${du_index}=0
    ${start_time}    robot.libraries.DateTime.get current date
    Selenium Login And Disable Screen Lock DU
    Get X2 link shutdown waiting time
    ${ru_index_list}    Get All RU Index
    ${cell_list}    Get All Cell Id
    sort list    ${cell_list}
    run keyword and continue on failure    Lock all RUs and check all status with no call
    ...    ru_index_list=${ru_index_list}    cell_list=${cell_list}    gnb_type='${gNb_CuType}'
    Close Start Up View    timeout=60
    UnLock all RUs and check all status with no call    ru_index_list=${ru_index_list}    cell_list=${cell_list}
    ...   gnb_type='${gNb_CuType}'    start_time=${start_time}
    [Teardown]    Run Keywords    5GC002033_keywords.excute ru unlock    ru_index_list=${ru_index_list}    AND
    ...    Selenium Logout And Close Browser

excute ru unlock
    [Documentation]
    ...    *****************
    ...    Owner_Echo.xu@nokia-sbell.com
    ...    ******************
    [Arguments]    ${ru_index_list}
    log to console    \n***excute ru unlock***
    FOR  ${ru_index}  IN  @{ru_index_list}
        Cloud DU connect to gnb coam via ssl
        selenium_coam.unlock_ru    ru_index=${ru_index}
    END

Selenium Login And Disable Screen Lock DU
    [Arguments]    ${gnb_index}=0    ${du_index}=0
    coam navigate to login page via webui   url=https://${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    selenium_coam.disable_screen_lock

Lock all RUs and check all status with no call
    [Documentation]
    ...    - [TEST PURPOSE] Lock all RUs and check all status with no call
    ...    Author: echo.xu@nokia-sbell.com
    [Arguments]  ${ru_index_list}    ${cell_list}    ${gnb_type}='${gNb_CuType}'    ${check_alarm}=${True}
    log to console  \n**Lock all RUs and check all status***
    ${led_status_list_lock}    create list    YELLOW YELLOW
    ${cell_list_new}    samelist    ${cell_list}
    FOR  ${ru_index}  IN  @{ru_index_list}
        Create file in RU    ru_index=${ru_index}
        Collect RF Logs To TestPC    log_name=before_ru_lock    ru_index=${ru_index}
        ${mathes}    ${new_timestamp}    Get Last LED Timestamp and Status    log_name=before_ru_lock
        selenium_coam.lock_ru    ru_index=${ru_index}
        sleep  15
        Check LED Status In RU Log    led_status_list=${led_status_list_lock}    log_name=after_ru_lock
        ...    ru_index=${ru_index}    timestamp=${new_timestamp}    exclude_led_status=GREEN GREEN
        5GC002033_keywords.Download Soap and Check Ru Lock Unlock Message    type=lock    ru_index=${ru_index}
        ${cell_id_ru}    Get All Cell Id    ru_index=${ru_index}
        wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${ru_index}
        wait until keyword succeeds    5min    20sec    Cell status Should Be Disabled    cell_list=${cell_id_ru}
        ${flag}    ${cell_list_new}    getusefulid    ${cell_id_ru}    ${cell_list_new}
        sort list    ${cell_list_new}
    END
    Cloud DU connect to gnb coam via ssl
    FOR  ${ru_index}  IN  @{ru_index_list}
        wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${ru_index}
    END
    wait until keyword succeeds    5min    20sec    Cell status Should Be Disabled    cell_list=${cell_list}
    run keyword if    ${check_alarm}==${True} and ${gnb_type}=='NSA'
    ...  Wait until keyword succeeds  5min  20sec  Expect Fault Should Absent    faultId=7300

UnLock all RUs and check all status with no call
    [Documentation]
    ...    - [TEST PURPOSE] UnLock all RUs and check all status
    ...    Author: echo.xu@nokia-sbell.com
    [Arguments]  ${start_time}    ${ru_index_list}    ${cell_list}    ${gnb_type}='${gNb_CuType}'
    ...    ${check_alarm}=${True}
    log to console  \n**UnLock all RUs and check all status***
    ${led_status_list}    create list   GREEN GREEN
    FOR  ${ru_index}  IN  @{ru_index_list}
        Collect RF Logs To TestPC    log_name=before_ru_unlock    ru_index=${ru_index}
        ${mathes}    ${new_timestamp}    Get Last LED Timestamp and Status    log_name=before_ru_unlock
        ${status}    run keyword and return status  Expect Fault Should Present    faultId=4687
        selenium_coam.unlock_ru    ru_index=${ru_index}
        sleep  15
        Run Keyword If  ${status}==${True}    wait until keyword succeeds    10min    20sec    RU Should Be Offline
        ...    ru_index=${ru_index}
        wait until keyword succeeds    10min    20sec    RU Should Be Online    ru_index=${ru_index}
        Run Keyword If  ${status}==${False}    Check LED Status In RU Log    led_status_list=${led_status_list}
        ...    log_name=after_ru_unlock
        ...    ru_index=${ru_index}    timestamp=${new_timestamp}    exclude_led_status=YELLOW YELLOW
        5GC002033_keywords.Download Soap and Check Ru Lock Unlock Message    type=unlock    ru_index=${ru_index}
        Run Keyword If  ${status}==${False}    Check file Exist in RU    ru_index=${ru_index}
        ${cell_id_ru}    Get All Cell Id    ru_index=${ru_index}
        sort list    ${cell_id_ru}
        wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${ru_index}
        wait until keyword succeeds    5min    20sec    Cell status Should Be enabled    cell_list=${cell_id_ru}
    END
    Cloud DU connect to gnb coam via ssl
    FOR  ${ru_index}  IN  @{ru_index_list}
        wait until keyword succeeds    5min    20sec    RU Should Be Unlocked    ru_index=${ru_index}
    END
    wait until keyword succeeds    5min    20sec    Cell status Should Be enabled    cell_list=${cell_list}
    run keyword if    ${check_alarm}==${True} and ${gnb_type}=='NSA'
    ...  Wait until keyword succeeds  5min  20sec  Expect Fault Should Absent    faultId=7300

Download Soap and Check Ru Lock Unlock Message
    [Documentation]
    ...    Author: echo.xu@nokia-sbell.com
    [Arguments]  ${type}=lock    ${ru_index}=1
    connect to common unit master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
    Connect to Common Unit Master
    ${ru_type}    get ru type    ru_index=${ru_index}
    ${PC_soap_path} =    Download Soap Log From RU Reg    ru_alias=RU_${ru_index}
#    ${PC_soap_path}    Download soap Log from RU    ru_alias=RU_${ru_index}
    run keyword if    '${type}'=='lock'    Check SOAP message_RU_lock    PC_soap_path=${PC_soap_path}
    ...       ELSE    Check SOAP message_RU_unlock    PC_soap_path=${PC_soap_path}
    [Return]  run keywords  csn.disconnect   connection=RU_${ru_index}    AND
    ...    csn.Disconnect   connection=ASIK Master

Commissioning with case Commission
    [Arguments]    ${scf_file}
    Cloud DU connect to gnb coam via ssl
    Run keyword and ignore error    COAM Commission with scf file    scf_file_path=${scf_file}    timeout=600    is_pdl_checking_needed=False
    sleep    300s
    COAM Wait for gnb ready and cell setup    timeout=15min

Lock Cell and Check Status
    [Arguments]    ${allowed_faults}    ${cell_list}
    FOR    ${c_list}    IN    @{cell_list}
         Perform cell lock via rest api    cell_idx=${c_list}
    END
    FOR    ${c_list}    IN    @{cell_list}
         Wait until keyword succeeds    3min    20 sec    Cell Should Be Locked    cell_idx=${c_list}
    ...   cell_group_idx=0
    END
    Wait until keyword succeeds    3min    20 sec    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}

Unlock Cell and Check Status
    [Arguments]    ${allowed_faults}    ${cell_list}
    FOR    ${c_list}    IN    @{cell_list}
         Perform cell unlock via rest api    cell_idx=${c_list}
    END
    sleep    60s
    COAM Wait for gnb ready and cell setup
    FOR    ${c_list}    IN    @{cell_list}
         Wait until keyword succeeds    5min    20 sec    Cell Should Be Unlocked    cell_idx=${c_list}    cell_group_idx=0
    END
    Wait until keyword succeeds    3min    20 sec    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}
