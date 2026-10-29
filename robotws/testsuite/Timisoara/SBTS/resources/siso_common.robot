*** Settings ***
Documentation
    ...    Author: ruiyu.han@nokia-sbell.com
    ...    to define SG07 COMMON SISO keywords

Library   taf.sbts.oam.coam.admin    WITH NAME    coam
Library   taf.selenium.sbts    WITH NAME      selenium_coam
Library   Collections
Library   OperatingSystem
Library   DateTime

Library   String
Library   XML   True
#Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Library           taf.hw.rf_attenuator    WITH NAME    att
Library   taf.pdu   WITH NAME   pdu
#Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/rrm_common.robot
Resource   taf_log.robot
#Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot
#Variables    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot

*** Variables ***
${rulog_exist}    ${False}
${egen_exist}    ${False}

*** Keywords ***
Siso Common Suite Setup
    ${SUITE_SETUP_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   SUITE_SETUP_START: ${SUITE_SETUP_START}
    Set Suite Variable   ${SUITE_SETUP_START}
    Wait Until Keyword Succeeds    2m   30s   COAM Login
    # Wait Until Keyword Succeeds    9m   3m   COAM WEBUI Login
    COAM Backup Full SCF   file_name=siso_scf.xml
    Wait Until Keyword Succeeds    3m   30s   COAM Check All Cells Onair
    ${siso_scf_xml}   XML.Parse XML   ${OUTPUT_DIR}/siso_scf.xml
    ${rmod_cell_mapping}    ${cell_num}    UUF Get RMOD SN Cell Mapping From Full SCF    source=${siso_scf_xml}
    ${rmod_serial_mapping}    UUF Get RMOD SerialNumber Mapping    source=${siso_scf_xml}
    set suite variable    ${siso_scf_xml}
    set suite variable    ${rmod_cell_mapping}
    set suite variable    ${rmod_serial_mapping}
    [Teardown]    run keywords    Run Keyword If    "${KEYWORD_STATUS}" == "FAIL"
    ...    Run Keyword And Ignore Error   Catch Snapshot COAM
    ...   AND   Run Keyword And Ignore Error   COAM Logout

Siso Common Suite Setup for UTE
    log to console  \n***CI_interface.Common Suite Setup for COAM on UTE***
    CI_interface.Common Suite Setup
    ${SUITE_SETUP_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   SUITE_SETUP_START: ${SUITE_SETUP_START}
    Set Suite Variable   ${SUITE_SETUP_START}
    Wait Until Keyword Succeeds    2m   30s   COAM Login
    # Wait Until Keyword Succeeds    9m   3m   COAM WEBUI Login
    COAM Backup Full SCF   file_name=siso_scf.xml
    Wait Until Keyword Succeeds    3m   30s   COAM Check All Cells Onair
    ${siso_scf_xml}   XML.Parse XML   ${OUTPUT_DIR}/siso_scf.xml
    ${rmod_cell_mapping}    ${cell_num}    UUF Get RMOD SN Cell Mapping From Full SCF    source=${siso_scf_xml}
    ${rmod_serial_mapping}    UUF Get RMOD SerialNumber Mapping    source=${siso_scf_xml}
    set suite variable    ${siso_scf_xml}
    set suite variable    ${rmod_cell_mapping}
    set suite variable    ${rmod_serial_mapping}
    [Teardown]    run keywords    Run Keyword If    "${KEYWORD_STATUS}" == "FAIL"
    ...    Run Keyword And Ignore Error   Catch Snapshot COAM
    ...   AND   Run Keyword And Ignore Error   COAM Logout

Siso Common Suite Teardown
    Wait Until Keyword Succeeds    2m   30s   COAM Login
    Recovery At Case Setup if Fault Occurs
    Run Keyword And Ignore Error    COAM Logout
    Run Keyword And Ignore Error    run keyword if  ${egen_exist}   Stop Egen Log
    ...    egen_server=${tl.test_pcs[0].default_ssh_connection_details.addr}
    ...    egen_username=${tl.test_pcs[0].default_ssh_connection_details.username}
    ...    egen_password=${tl.test_pcs[0].default_ssh_connection_details.password}
    # Run Keyword And Ignore Error   COAM WEBUI Logout


Siso Common Save Logs
    ${log_status}   Get Variable Value   ${TEST_STATUS}   ${KEYWORD_STATUS}
    ${Siso_Common_LOG_PATH}    Get Variable Value    ${Siso_Common_LOG_PATH}    ${OUTPUT_DIR}/${TEST NAME}
    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    Run Keyword If    "${log_status}" == "FAIL"    Create Directory   ${Siso_Common_LOG_PATH}
#    Run Keyword If    "${log_status}" == "FAIL"        run keyword and ignore error    Capature Sreenshot COAM
    Run Keyword If    "${log_status}" == "FAIL"        run keyword and ignore error    Catch Snapshot COAM
    ...    local_file_path=${Siso_Common_LOG_PATH}/snapshot_${curr_data}.zip
    Run Keyword If    "${log_status}" == "FAIL"
    ...   run keyword if  ${rulog_exist}   RU Log Operation Teardown if keyword failed    logpath=${Siso_Common_LOG_PATH}
    Run Keyword If    "${log_status}" == "FAIL"
    ...   run keyword if  ${egen_exist}   Stop Egen Log and Save to VM
    ...    egen_server=${tl.test_pcs[0].default_ssh_connection_details.addr}
    ...    egen_username=${tl.test_pcs[0].default_ssh_connection_details.username}
    ...    egen_password=${tl.test_pcs[0].default_ssh_connection_details.password}
    ...    logpath=${Siso_Common_LOG_PATH}
    Run Keyword If    "${log_status}" == "FAIL"        run keyword and ignore error    Stop and Save Syslog Collection
    ...   logpath=${Siso_Common_LOG_PATH}
    Run Keyword If    "${log_status}" != "FAIL"        run keyword and ignore error    Stop and Delete Syslog Collection

Siso Common Each Time Teardown
     [Arguments]    ${keycheck}=${False}   ${ratreset}=${False}
     run keyword if    ${keycheck}     Siso Common Each Time Teardown without other check
     ...     ELSE     Siso Common Each Time Teardown with other check    ratreset=${ratreset}

Siso Common Each Time Teardown without other check
    run keyword if     ${KEYWORD STATUS.count('PASS')}>0
    ...     Stop and Delete Syslog Collection
    ...     ELSE     FAIL
    ...     msg=Opration status:${KEYWORD STATUS}!

Siso Common Each Time Teardown with other check
    [Arguments]    ${ratreset}=${False}
    ${SISO_FAULT_allowed_ratreset}    Copy List    ${SISO_FAULT_allowed}
    run keyword if  ${ratreset}    append to list    ${SISO_FAULT_allowed_ratreset}    16
    ${final_FAULT_allowed}    set variable if  ${ratreset}     ${SISO_FAULT_allowed_ratreset}
    ...   ${SISO_FAULT_allowed}
#   ${status_fault}     run keyword and return status     Wait Until Keyword Succeeds    5min    30s
#    ...    check Faults for siso common    allowedfault_list=${final_FAULT_allowed}
    ${status_activefault}     run keyword and return status     Wait Until Keyword Succeeds    5min    30s
    ...    check Active Faults for siso common    allowedfault_list=${final_FAULT_allowed}
    ${status_historyfault}     run keyword and return status
    ...    check History Faults for siso common    allowedfault_list=${final_FAULT_allowed}
    ${status_blackbox}   run keyword and return status    Siso Common Check Blackbox
    ${status_syslog}   run keyword and return status    Siso Common Check Syslog Error
    ${status_list}   Create List   ${status_activefault}   ${status_historyfault}    ${status_blackbox}   ${status_syslog}
    ${status_check}     run keyword and return status    List Should Not Contain Value   ${status_list}   ${False}
    ${loginfo}      Catenate    [FAIL]blacboxcheck status:${status_blackbox};syslog error check status:${status_syslog};
    ...    Opration status:${KEYWORD STATUS};Active Fault status:${status_activefault};History Fault status:${status_historyfault}!
    run keyword if     ${KEYWORD STATUS.count('PASS')}>0 and ${status_check}    run keywords
    ...     Stop and Delete Syslog Collection
    ...     AND    run keyword if  ${egen_exist}    Stop Egen Log
    ...    egen_server=${tl.test_pcs[0].default_ssh_connection_details.addr}
    ...    egen_username=${tl.test_pcs[0].default_ssh_connection_details.username}
    ...    egen_password=${tl.test_pcs[0].default_ssh_connection_details.password}
    ...     AND    run keyword if  ${rulog_exist}    RU Log Operation Teardown if keyword passed
    ...     ELSE     FAIL     msg=${loginfo}

RU Log Operation Setup in Siso Common
    run keyword and ignore error    Enable LMI RU at ControlPC
    run keyword and ignore error    Check and Upload RU btslog Flag in Swconfig File
    run keyword and ignore error    Clear ALL RUs Serial Log
    run keyword and ignore error    Clear ALL RUs BTSLOG
    Run Keyword and Ignore Error    Start ALL RUs BTSLOG at RU PC
    run keyword and ignore error    Send Special CMD to RU at ControlPC    cmd_list=${RU_CMD_LIST}
#    run keyword and ignore error    ALL RUs Switch to other node and Send CMD to RU    node_ip=192.168.101.17
#    ...    cmd_list_1=${RU_CMD_LIST}    cmd_list_2=${RU_THOR_CMD_LIST}

RU Log Operation Teardown if keyword failed
    [Arguments]    ${logpath}=${OUTPUT_DIR}
#    run keyword and ignore error    Stop and Save ALL RUs tcpdumps    node_ip=192.168.101.17    logpath=${logpath}
#    ...    cmd_list_1=${RU_CMD_LIST}    cmd_list_2=${RU_THOR_CMD_LIST}
    run keyword and ignore error    Save ALL RUs Snapshot    logpath=${logpath}
    run keyword and ignore error    Stop ALL RUs BTSLOG at RU PC
    run keyword and ignore error    Save ALL RUs Serial Log    logpath=${logpath}
    run keyword and ignore error    Save ALL RUs BTSLOG    logpath=${logpath}


RU Log Operation Teardown if keyword passed
#    run keyword and ignore error    Stop ALL RUs tcpdumps    node_ip=192.168.101.17
    run keyword and ignore error    Stop ALL RUs BTSLOG at RU PC
    #######for debug############
#    run keyword and ignore error    Save ALL RUs Serial Log
#    run keyword and ignore error    Save ALL RUs BTSLOG
#    run keyword and ignore error    Save ALL RUs Snapshot
    #######for debug############

All Site Commissioning
    [Arguments]    ${keycheck}=${False}
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Start Syslog Collection
    COAM SCF Commission     filepath=${OUTPUT_DIR}/siso_scf.xml
    Wait Until Keyword Succeeds   15m   1m   COAM Check all cells should be onair
    [Teardown]    Siso Common Each Time Teardown     keycheck=${keycheck}

All Site Power Reset
    [Arguments]    ${keycheck}=${False}
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Start Syslog Collection
    ${status}    run keyword and return status    coam.Power_Reset    connection=COAM
    Should Be Equal    ${status}    ${true}
    Wait Until Keyword Succeeds   15m   1m   COAM Check all cells should be onair
    [Teardown]    Siso Common Each Time Teardown     keycheck=${keycheck}

All Site RUs Power Reset
    [Arguments]    ${keycheck}=${False}
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Start Syslog Collection
    ${rus}   Set Variable   ${tl.gnbs[0].dus[0].rus}
    set test variable     ${rus}
    FOR     ${RU}     IN     @{rmod_serial_mapping}
        Single RU Power Reset     rus=${rus}   sn_value=${RU}
    END
    [Teardown]     Siso Common Each Time Teardown     keycheck=${keycheck}

Single RU Power Reset
    [Arguments]   ${rus}   ${sn_value}
    ${ru_index}     fetch from right     ${rmod_serial_mapping['${sn_value}']['configDN']}    -
    ${pb_host}   Set Variable   ${rus[${${ru_index}-1}].pdu_port.pdu.addr}
    ${pb_port}   Set Variable   ${rus[${${ru_index}-1}].pdu_port.port_no}
    pdu.setup_pdu   model=${tl.gnbs[0].dus[0].rus[${${ru_index}-1}].pdu_port.pdu}
    ...  host=${pb_host}   alias=ru_${ru_index}
    log to console    RF POWER OFF RU${ru_index}!
    PDU power operation   pb_port=${pb_port}   alias=ru_${ru_index}   operation=off
    log to console      CHECK RU${ru_index} should be off!
    Wait Until Keyword Succeeds   5m   30s   RU and corresponding Cell Status should Disabled   sn_value=${sn_value}
    Check Other RU and Cell Status except one    dist_name=${rmod_serial_mapping['${sn_value}']['configDN']}
    log to console      RF POWER ON RU${ru_index}!
    PDU power operation   pb_port=${pb_port}   alias=ru_${ru_index}
    log to console      CHECK RU${ru_index} status should be normal!
    run keyword if  ${rulog_exist}
    ...   run keyword and ignore error    run keywords
    ...   Wait Until Keyword Succeeds    5min    1min   Validate RU IP Reachability from Control PC by SN
    ...   ru_sn=${sn_value}  exp_status=${False}
    ...   AND   wait until keyword succeeds    5min    1min   Enable Single LMI RU at ControlPC by SN    ru_sn=${sn_value}
    Wait Until Keyword Succeeds   10m   1m   RU and corresponding Cell Status should Enabled  sn_value=${sn_value}
    Check Other RU and Cell Status except one    dist_name=${rmod_serial_mapping['${sn_value}']['configDN']}
    [Teardown]   run keywords   PDU power operation   pb_port=${pb_port}   alias=ru_${ru_index}
    ...   AND   pdu.teardown_pdu    pdu_device=ru_${ru_index}

Power Check RU Status Siso Common
    [Arguments]    ${rmod_index}=1
    ${ru_status}=    selenium_coam.get_ru_info    ru_index=${rmod_index}
    ${operational_state}=  set variable  ${ru_status["Status"]["Operational state"]}
    ${availability_status}=  set variable   ${ru_status["Status"]["Availability status"]}
    ${administrative_state}=  set variable  ${ru_status["Status"]["Administrative state"]}
    Should Be Equal   ${administrative_state.lower()}   unlocked
#    Should Be Equal   ${availability_status.lower()}   online
    Should Be Equal   ${operational_state.lower()}   enabled

RU Status abnormal Siso Common
    [Arguments]   ${index}
    ${ru_normal}   Run Keyword and Return Status   Power Check RU Status Siso Common    rmod_index=${index}
    Should Not Be True   ${ru_normal}

PDU power operation
    [Arguments]   ${pb_port}   ${alias}   ${operation}=on
    run keyword    pdu.power_${operation}   port=${pb_port}   pdu_device=${alias}
    Sleep   5s
    ${pb_status}   pdu.get_port_status   port=${pb_port}   pdu_device=${alias}
    Should Be Equal   ${pb_status.lower()}   ${operation}

All Cells Reset
    [Arguments]    ${keycheck}=${False}
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Start Syslog Collection
     FOR    ${cell}     IN     @{nr_cell_list}
         log to console    | cellid:${cell['globalCellId']} start reset...
         coam.reset_cell   cell_id=${cell['id']['internal']}    timeout=120
         ...    connection=COAM
#         wait until keyword succeeds    2min    30s
#         ...  ADMIN check NR cell status    cell_index=${cell['globalCellId']}
#         ...    expected_status='availabilitystatus': 'off line'
         Check other Cells Status except One      cellid=${cell['globalCellId']}
         sleep    30s
         wait until keyword succeeds   2min    30s
         ...   ADMIN check NR cell status    cell_index=${cell['globalCellId']}
         ...    expected_status='operationalstate': 'enabled'
         Check other Cells Status except One      cellid=${cell['globalCellId']}
      END
     FOR    ${cell}     IN     @{lte_cell_list}
         log to console    | cellid:${cell['globalCellId']} start reset...
         coam.reset_cell   cell_id=${cell['id']['internal']}    timeout=120
         ...   connection=COAM
#         wait until keyword succeeds    1min    1s
#         ...  ADMIN check LTE cell status    cell_index=${cell['globalCellId']}
#         ...    expected_status='operationalstate': 'disabled'
         Check other Cells Status except One      cellid=${cell['globalCellId']}
         sleep     30s
         wait until keyword succeeds   2min    30s
         ...   ADMIN check LTE cell status    cell_index=${cell['globalCellId']}
         ...    expected_status='operationalstate': 'enabled'
         Check other Cells Status except One      cellid=${cell['globalCellId']}
      END
      Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
      [Teardown]     Siso Common Each Time Teardown     keycheck=${keycheck}

All Cells lock unlock cells
     [Arguments]    ${keycheck}=${False}
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Start Syslog Collection
     FOR    ${cell}     IN     @{nr_cell_list}
        log to console    | cellid:${cell['globalCellId']} start lock...
        COAM Lock unclock Cell via Change Parameter    celltype=nr    cellid=${cell['globalCellId']}    operation=Locked
        wait until keyword succeeds   3min    30s
        ...   ADMIN check NR cell status    cell_index=${cell['globalCellId']}
        ...    expected_status='availabilitystatus': 'off line'
        wait until keyword succeeds   3min    30s
        ...   ADMIN check NR cell status    cell_index=${cell['globalCellId']}
        ...    expected_status='operationalstate': 'disabled'
#        wait until keyword succeeds   3min    20s
#        ...   ADMIN check NR cell availability Status    cell_index=${cell['globalCellId']}
#        ...    expected_status='administrativestate': 'loced'
        Check other Cells Status except One      cellid=${cell['globalCellId']}

        log to console    | cellid:${cell['globalCellId']} start unlock...
        COAM Lock unclock Cell via Change Parameter    celltype=nr    cellid=${cell['globalCellId']}    operation=Unlocked
        wait until keyword succeeds   10m    1m
        ...   ADMIN check NR cell status    cell_index=${cell['globalCellId']}
        ...    expected_status='operationalstate': 'enabled'
        Check other Cells Status except One      cellid=${cell['globalCellId']}
      END
     FOR    ${cell}     IN     @{lte_cell_list}
         log to console    | cellid:${cell['globalCellId']} start lock...
         COAM Lock unclock Cell via Change Parameter    celltype=lte    cellid=${cell['globalCellId']}    operation=Locked
         wait until keyword succeeds   3m    30s
        ...   ADMIN check LTE cell status     cell_index=${cell['globalCellId']}
        ...    expected_status='availabilitystatus': 'off line'
        wait until keyword succeeds   3m    30s
        ...   ADMIN check LTE cell status     cell_index=${cell['globalCellId']}
        ...    expected_status='operationalstate': 'disabled'
#        wait until keyword succeeds   3min    20s
#        ...   ADMIN check LTE cell status     cell_index=${cell['globalCellId']}
#        ...    expected_status='administrativestate': 'loced'
         Check other Cells Status except One      cellid=${cell['globalCellId']}

         log to console    | cellid:${cell['globalCellId']} start unlock...
         COAM Lock unclock Cell via Change Parameter    celltype=lte    cellid=${cell['globalCellId']}    operation=Unlocked
         wait until keyword succeeds   10m    1m
         ...   ADMIN check LTE cell status    cell_index=${cell['globalCellId']}
         ...    expected_status='operationalstate': 'enabled'
         wait until keyword succeeds   10m    1m
         ...  ADMIN check LTE cell status    cell_index=${cell['globalCellId']}
         ...    expected_status='administrativestate': 'unlocked'
         Check other Cells Status except One      cellid=${cell['globalCellId']}
      END
      Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
      [Teardown]     Siso Common Each Time Teardown     keycheck=${keycheck}

All Cells block unblock cells
     [Arguments]    ${keycheck}=${False}
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Start Syslog Collection
    ${nr_cell_list}     ${lte_cell_list}    COAM Get 4G 5G Cell List
     FOR    ${cell}     IN     @{nr_cell_list}
        log to console    | cellid:${cell['globalCellId']} start block...
        ADMIN Block NR cell and check status      cell_index=${cell['globalCellId']}
        Check other Cells Status except One      cellid=${cell['globalCellId']}

        log to console    | cellid:${cell['globalCellId']} start unblock...
        ADMIN UnBlock NR cell and check status      cell_index=${cell['globalCellId']}
        Check other Cells Status except One      cellid=${cell['globalCellId']}
      END
     FOR    ${cell}     IN     @{lte_cell_list}
         log to console    | cellid:${cell['globalCellId']} start block...
         ADMIN Block LTE cell and check status     cell_index=${cell['globalCellId']}
         Check other Cells Status except One      cellid=${cell['globalCellId']}

         log to console    | cellid:${cell['globalCellId']} start unblock...
         ADMIN UnBlock LTE cell and check status     cell_index=${cell['globalCellId']}
         Check other Cells Status except One      cellid=${cell['globalCellId']}
      END
      Wait Until Keyword Succeeds   20m   30s   COAM Check all cells should be onair
      [Teardown]     Siso Common Each Time Teardown     keycheck=${keycheck}

All RUs Reset
     [Arguments]    ${keycheck}=${False}
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Start Syslog Collection
    FOR     ${RU}     IN     @{rmod_serial_mapping}
#        ${ru_index}     fetch from right     ${rmod_serial_mapping['${RU}']['configDN']}    -
#        selenium_coam.reset_ru_from_site_view    ru_index=${ru_index}
        run keyword and ignore error    COAM Reset RMOD    dist_name=${rmod_serial_mapping['${RU}']['configDN']}    timeout=${20}
        Wait Until Keyword Succeeds   5m   10s   RU and corresponding Cell Status should Disabled   sn_value=${RU}
        Check Other RU and Cell Status except one    dist_name=${rmod_serial_mapping['${RU}']['configDN']}
        run keyword if  ${rulog_exist}
        ...   run keyword and ignore error    run keywords
        ...   Wait Until Keyword Succeeds    5m    1m   Validate RU IP Reachability from Control PC by SN
        ...   ru_sn=${RU}  exp_status=${False}
        ...   AND   wait until keyword succeeds    5m    1m   Enable Single LMI RU at ControlPC by SN    ru_sn=${RU}
        Wait Until Keyword Succeeds   15m   30s   RU and corresponding Cell Status should Enabled   sn_value=${RU}
        Check Other RU and Cell Status except one    dist_name=${rmod_serial_mapping['${RU}']['configDN']}
     END
     Wait Until Keyword Succeeds    20m    1m   COAM Check all cells should be onair
     [Teardown]     Siso Common Each Time Teardown     keycheck=${keycheck}

ALL RUs Lock Unlock
     [Arguments]    ${keycheck}=${False}
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Start Syslog Collection
    FOR     ${RU}     IN     @{rmod_serial_mapping}
        log to console     | start lock RU index:${rmod_serial_mapping['${RU}']['configDN']} ...
        COAM Lock RU     dist_name=${rmod_serial_mapping['${RU}']['configDN']}
        Wait Until Keyword Succeeds   5m   10s   RU and corresponding Cell Status should Disabled   sn_value=${RU}
        Check Other RU and Cell Status except one    dist_name=${rmod_serial_mapping['${RU}']['configDN']}
        log to console     | start UNLock RU index:${rmod_serial_mapping['${RU}']['configDN']} ...
        COAM Unlock RU    dist_name=${rmod_serial_mapping['${RU}']['configDN']}
        Wait Until Keyword Succeeds   10m   30s   RU and corresponding Cell Status should Enabled   sn_value=${RU}
        Check Other RU and Cell Status except one    dist_name=${rmod_serial_mapping['${RU}']['configDN']}
     END
     Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
     [Teardown]     Siso Common Each Time Teardown     keycheck=${keycheck}

All BBMODs Reset
     [Arguments]    ${reset_type}=Warm    ${graceful_cell_shutdown}=${False}    #${keycheck}=${False}
    return from keyword if    len(${bbmod_cell_mapping})==${0}
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Start Syslog Collection
    ${w_g_rat_bbmods}     Check If WCDMA Or GSM Deployed On BBMOD    source=${BTS Files path}
    FOR     ${bbmod}     IN     @{bbmods_info}
        ${bbmod_r}      fetch from right     ${bbmod['internal']}     /
        continue for loop if   '${bbmod_r}' not in ${bbmod_cell_mapping}
        continue for loop if     '${bbmod['product_name']}' == 'ABIA' and '${bbmod_r}' in ${w_g_rat_bbmods}
        run keyword and ignore error    COAM Reset BBMOD      dist_name=${bbmod['internal']}     timeout=${20}
        ...   graceful_cell_shutdown=${graceful_cell_shutdown}    reset_type=${reset_type}
#        Wait Until Keyword Succeeds   5m   30s   BBMOD RU Cell Status should Disabled   dist_name=${bbmod['configuration']}
        Wait Until Keyword Succeeds   10m   30s   Check All Modules And All Cells Working States
        run keyword if   ${egen_exist}    Start Egen Log
        ...   egen_server=${tl.test_pcs[0].default_ssh_connection_details.addr}
        ...   egen_username=${tl.test_pcs[0].default_ssh_connection_details.username}
        ...   egen_password=${tl.test_pcs[0].default_ssh_connection_details.password}
        sleep    30s
#        Check Other BBMOD RU Cell Status except one    dist_name=${bbmod['configuration']}
        Wait Until Keyword Succeeds   20m   30s   Check All Modules And All Cells Working States
#        Check Other BBMOD RU Cell Status except one    dist_name=${bbmod['configuration']}
     END
     Wait Until Keyword Succeeds   20m   1m   Check All Modules And All Cells Working States
#     [Teardown]     Siso Common Each Time Teardown     keycheck=${keycheck}


Reset Defined BBMODs
    [Arguments]    ${bbmod_index_list}    ${keycheck}=${False}
    return from keyword if    len(${bbmod_cell_mapping})==${0}
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Wait Until Keyword Succeeds   3x   30s  Start Syslog Collection
    ${w_g_rat_bbmods}     Check If WCDMA Or GSM Deployed On BBMOD    source=${BTS Files path}
    FOR    ${bb_index}   IN    @{bbmod_index_list}
        FOR     ${bbmod}    IN     @{bbmods_info}
            ${bbmod_r}      fetch from right     ${bbmod['internal']}     /
            continue for loop if   '${bbmod_r}' not in ${bbmod_cell_mapping}
            continue for loop if     '${bbmod['product_name']}' == 'ABIA' and '${bbmod_r}' in ${w_g_rat_bbmods}
            ${bbmod_idx}    fetch from right    ${bbmod['configuration']}    -
            Continue For Loop If    ${bb_index}!=${bbmod_idx}
            run keyword and ignore error    COAM Reset BBMOD      dist_name=${bbmod['internal']}     timeout=${20}
            Wait Until Keyword Succeeds   5m   30s   BBMOD RU Cell Status should Disabled   dist_name=${bbmod['configuration']}
            run keyword if   ${egen_exist}    Start Egen Log
            ...   egen_server=${tl.test_pcs[0].default_ssh_connection_details.addr}
            ...   egen_username=${tl.test_pcs[0].default_ssh_connection_details.username}
            ...   egen_password=${tl.test_pcs[0].default_ssh_connection_details.password}
            sleep    30s
    #        Check Other BBMOD RU Cell Status except one    dist_name=${bbmod['configuration']}
            Wait Until Keyword Succeeds   20m   1m   BBMOD RU Cell Status should Enabled   dist_name=${bbmod['configuration']}
            Check Other BBMOD RU Cell Status except one    dist_name=${bbmod['configuration']}
         END
     END
     Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
     [Teardown]     Siso Common Each Time Teardown     keycheck=${keycheck}


All BBMODs Lock UnLock
     [Arguments]    ${keycheck}=${False}
    return from keyword if    len(${bbmod_cell_mapping})==${0}
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Start Syslog Collection
    FOR     ${bbmod}     IN     @{bbmods_info}
        ${bbmod_r}      fetch from right     ${bbmod['internal']}     /
        continue for loop if   '${bbmod_r}' not in ${bbmod_cell_mapping}
        COAM Lock BBMOD      dist_name=${bbmod['internal']}
        Wait Until Keyword Succeeds   5m   15s   BBMOD RU Cell Status should Disabled
        ...   bbmod_operation=lock     dist_name=${bbmod['configuration']}
        sleep    30s
#        Check Other BBMOD RU Cell Status except one    dist_name=${bbmod['configuration']}
        COAM Unlock BBMOD      dist_name=${bbmod['internal']}
        Wait Until Keyword Succeeds   15m   30s   BBMOD RU Cell Status should Enabled   dist_name=${bbmod['configuration']}
        Check Other BBMOD RU Cell Status except one    dist_name=${bbmod['configuration']}
     END
     Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
     [Teardown]     Siso Common Each Time Teardown     keycheck=${keycheck}


All RAT Block Unblock
     [Arguments]    ${keycheck}=${False}
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Start Syslog Collection
    FOR     ${rat}     IN     @{rat_list}
        continue for loop if    ${rat.count('lte')}<=0 and ${rat.count('nr')}<=0
        COAM Block Rat      rat_name=${rat}    timeout=${180}
        Wait Until Keyword Succeeds   5m   15s   Rat Cell should Disabled and Mplane Check     rat=${rat}
        Check Other RAT Cell Status except one     rat=${rat}
        COAM Unlock Rat      rat_name=${rat}    timeout=${180}
        Wait Until Keyword Succeeds   15m   30s   Rat Cell should Enabled and Mplane Check     rat=${rat}
        Check Other RAT Cell Status except one     rat=${rat}
     END
     Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
     [Teardown]     Siso Common Each Time Teardown     keycheck=${keycheck}


All RAT Reset
     [Arguments]    ${keycheck}=${False}
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Start Syslog Collection
    FOR     ${rat}     IN     @{rat_list}
        continue for loop if    ${rat.count('lte')}<=0 and ${rat.count('nr')}<=0
        run keyword and ignore error    COAM Reset RAT      rat_type=${rat.upper()}    timeout=${20}
        Wait Until Keyword Succeeds   5m   15s   Rat Cell should Disabled and Mplane Check     rat=${rat}
        Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
         #not check middele status as logic complex
#        Check Other RAT Cell Status except one     rat=${rat}
#        Wait Until Keyword Succeeds   20m   10s   Rat Cell should Enabled and Mplane Check     rat=${rat}
#        Check Other RAT Cell Status except one     rat=${rat}
     END
     Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
     [Teardown]     Siso Common Each Time Teardown     keycheck=${keycheck}    ratreset=${True}


All Soft RAT Reset with actRATResetEnhancement True
     [Arguments]    ${keycheck}=${False}
    Recovery At Case Setup if Fault Occurs
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Start Syslog Collection
    FOR     ${rat}     IN     @{rat_list}
        continue for loop if    ${rat.count('lte')}<=0 and ${rat.count('nr')}<=0
        COAM Reset RAT      rat_type=${rat.upper()}    reset_type=Soft
#        Wait Until Keyword Succeeds   5m   10s   Rat Cell should Disabled and Mplane Check     rat=${rat}
         #not check middele status as logic complex
#        Check Other RAT Cell Status except one     rat=${rat}
        Wait Until Keyword Succeeds   20m   1m   Rat Cell should Enabled and Mplane Check     rat=${rat}
        Check Other RAT Cell Status except one     rat=${rat}
     END
     Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
     [Teardown]     Siso Common Each Time Teardown     keycheck=${keycheck}    ratreset=${True}


All Hard RAT Reset with actRATResetEnhancement True
     [Arguments]    ${keycheck}=${False}
    Recovery At Case Setup if Fault Occurs
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Start Syslog Collection
    FOR     ${rat}     IN     @{rat_list}
        continue for loop if    ${rat.count('lte')}<=0 and ${rat.count('nr')}<=0
        COAM Reset RAT      rat_type=${rat.upper()}    reset_type=Hard
        Wait Until Keyword Succeeds   5m   15s   Rat Cell should Disabled and Mplane Check     rat=${rat}
         #not check middele status as logic complex
#        Check Other RAT Cell Status except one     rat=${rat}
        Wait Until Keyword Succeeds   20m   1m   Rat Cell should Enabled and Mplane Check     rat=${rat}
        Check Other RAT Cell Status except one     rat=${rat}
     END
     Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
     [Teardown]     Siso Common Each Time Teardown     keycheck=${keycheck}    ratreset=${True}


All NRDU Lock Unlock
     [Arguments]    ${keycheck}=${False}
     ${nrdu_objlist}   XML.Get Elements   ${BTS Files path}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRDU"]
     Start Syslog Collection
     FOR    ${nrdu}    IN    @{nrdu_objlist}
         ${nrdu_dn}   XML.Get Element Attribute   ${nrdu}   distName
         COAM Lock NRDU     distname=${nrdu_dn}
      END
         Wait Until Keyword Succeeds   5m   15s   Rat Cell should Disabled and Mplane Check     rat=nr
     FOR    ${nrdu}    IN    @{nrdu_objlist}
         ${nrdu_dn}   XML.Get Element Attribute   ${nrdu}   distName
         COAM Unlock NRDU     distname=${nrdu_dn}
      END
      Wait Until Keyword Succeeds   3m   1m   Rat Cell should Enabled and Mplane Check     rat=nr
      [Teardown]     Siso Common Each Time Teardown     keycheck=${keycheck}


Check Other RU and Cell Status except one
      [Arguments]    ${dist_name}
      FOR     ${RU}     IN     @{rmod_serial_mapping}
           continue for loop if     '${dist_name}'=='${rmod_serial_mapping['${RU}']['configDN']}'
           RU and corresponding Cell Status should Enabled    sn_value=${RU}
      END

Check Other BBMOD RU Cell Status except one
      [Arguments]    ${dist_name}
      FOR     ${bbmod}     IN     @{bbmods_info}
           continue for loop if     '${bbmod['configuration']}'=='${dist_name}'
           BBMOD RU Cell Status should Enabled   dist_name=${bbmod['configuration']}
      END



Check Other RAT Cell Status except one
      [Arguments]    ${rat}
      ${celltype}      set variable if    ${rat.count('nr')}>0     NRCELL     LNCEL
      FOR    ${cell}     IN     @{nr_cell_list}
            continue for loop if    ${cell['id']['configuration'].count('${celltype}')}>0
            log to console    | nr cellid:${cell['globalCellId']} should be enabled
            ADMIN check NR cell status    cell_index=${cell['globalCellId']}
            ...     expected_status='operationalstate': 'enabled'
      END
      FOR    ${cell}     IN     @{lte_cell_list}
            continue for loop if    ${cell['id']['configuration'].count('${celltype}')}>0
            log to console    | lte cellid:${cell['globalCellId']} should be disabled..
            ADMIN check LTE cell status     cell_index=${cell['globalCellId']}
            ...    expected_status='operationalstate': 'enabled'
      END

Exclude NSA cells and related RU NR Cells
      [Arguments]    ${ltecell}
      #exclue related RU NR Cells
      create list    ${exclude_cellist}
      FOR    ${sn}   IN    @{rmod_cell_mapping}
            ${exclude_cellist}    run keyword if    ${ltecell['id']['configuration']} in @{rmod_cell_mapping['${sn}']}
            ...    combine lists    ${exclude_cellist}    ${rmod_cell_mapping['${sn}']}
      END
      ${exclude_cellist}    Remove Duplicates    ${exclude_cellist}

      #exclude nsa cells
      create dictionary    ${nrcell_mapping}
      FOR    ${nrcell}    IN    @{nr_cell_list}
          ${nr_global_cell_list}     create list    ${nrcell['globalCellId']}
          ${nrcellindex_list}    Get nrcellindex List    global_cell_list=${nr_global_cell_list}
          set to dictionary     ${nrcell_mapping}    ${nrcellindex_list[0]}=${nrcell['globalCellId']}
      END

      ${LNRELGNBCELL_list}    XML.Get Elements   ${BTS Files path}   class=cmData/managedObject[@class="NOKLTE:LNRELGNBCELL"]
      return from keyword if   '${LNRELGNBCELL_list}'=='${empty}'
      FOR   ${LNRELGNBCELL}   IN   @{LNRELGNBCELL_list}
          ${cell_dn}   XML.Get Element Attribute   ${LNRELGNBCELL}   distName   xpath=..
          ${cell_dn}    Fetch from left    ${cell_dn}    /LNRELGNBCELL
          Continue For Loop If    '${cell_dn}'!='${ltecell['id']['configuration']}'
          ${lnrel_nrcell}    XML.Get Element   ${LNRELGNBCELL}      xpath=p[@name="nrCellId"]
          run keyword if    ${lnrel_nrcell} in @{nrcell_mapping}
          ...     append to list    ${exclude_cellist}
          ...    MRBTS-${GLOBAL_BTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-${nrcell_mapping['${lnrel_nrcell}']}
      END

      ${exclude_cellist}    Remove Duplicates    ${exclude_cellist}
      [Return]     ${exclude_cellist}




Rat Cell should Disabled and Mplane Check
      [Arguments]    ${rat}
      ${celltype}      set variable if    ${rat.count('nr')}>0     NRCELL     LNCEL
      Validate IP Reachability from Test PC    ip_addr=${asik_addr}  exp_status=${True}
      FOR    ${cell}     IN     @{nr_cell_list}
            continue for loop if    ${cell['id']['configuration'].count('${celltype}')}<=0
            log to console    | nr cellid:${cell['globalCellId']} should be disabled..
            ADMIN check NR cell status    cell_index=${cell['globalCellId']}
            ...     expected_status='operationalstate': 'disabled'
      END
      FOR    ${cell}     IN     @{lte_cell_list}
            continue for loop if    ${cell['id']['configuration'].count('${celltype}')}<=0
            log to console    | lte cellid:${cell['globalCellId']} should be disabled..
            ADMIN check LTE cell status     cell_index=${cell['globalCellId']}
            ...    expected_status='operationalstate': 'disabled'
      END

Rat Cell should Enabled and Mplane Check
      [Arguments]    ${rat}
      ${celltype}      set variable if    ${rat.count('nr')}>0     NRCELL     LNCEL
      Validate IP Reachability from Test PC    ip_addr=${asik_addr}  exp_status=${True}
      FOR    ${cell}     IN     @{nr_cell_list}
            continue for loop if    ${cell['id']['configuration'].count('${celltype}')}<=0
            log to console    | nr cellid:${cell['globalCellId']} should be enabled..
            ADMIN check NR cell status    cell_index=${cell['globalCellId']}
            ...     expected_status='operationalstate': 'enabled'
      END
      FOR    ${cell}     IN     @{lte_cell_list}
            continue for loop if    ${cell['id']['configuration'].count('${celltype}')}<=0
            log to console    | lte cellid:${cell['globalCellId']} should be enabled..
            ADMIN check LTE cell status     cell_index=${cell['globalCellId']}
            ...    expected_status='operationalstate': 'enabled'
      END

BBMOD Lock RU Cell Status
     [Arguments]     ${dist_name}
     ${bbmod_index}     fetch from right     ${dist_name}     -
     &{bbmod_status}    Get bbmod info by bbmod index     bbmod_index=${bbmod_index}   connection=COAM
     Should be equal as strings    ${bbmod_status['status']['administrativeState']}       Locked
                                  ...  msg=Current bbmod operationalState is not in Enabled status    ignore_case=${True}
     ${corresponding_RMODS}     Create List
     FOR     ${RMOD}     IN    @{bbmod_mapping}
          run keyword if     '${dist_name}'=='${bbmod_mapping['${RMOD}']}'
          ...     append to list     ${corresponding_RMODS}      ${RMOD}
     END
     FOR    ${RMOD_SN}    IN      @{rmod_serial_mapping}
          run keyword if    '${rmod_serial_mapping['${RMOD_SN}']['configDN']}' in ${corresponding_RMODS}
          ...    RU Enabled corresponding Cell Status should Disabled     sn_value=${RMOD_SN}
      END


BBMOD RU Cell Status should Disabled
     [Arguments]     ${dist_name}     ${bbmod_operation}=reset
     ${bbmod_index}     fetch from right     ${dist_name}     -
     &{bbmod_status}    Get bbmod info by bbmod index     bbmod_index=${bbmod_index}   connection=COAM
     run keyword if    ${bbmod_operation.count('reset')}>0
     ...     should be equal as strings    ${bbmod_status['status']['operationalState']}       disabled
     ...     msg=Current bbmod operationalState is not in Enabled status    ignore_case=${True}
     ...     ELSE    should be equal as strings    ${bbmod_status['status']['administrativeState'].lower()}       locked
     ...     msg=Current bbmod operationalState is not in Enabled status    ignore_case=${True}

#     ${corresponding_RMODS}     Create List
#     :FOR     ${RMOD}     IN    @{bbmod_mapping}
#          run keyword if     '${dist_name}' in @{bbmod_mapping['${RMOD}']}
#          ...     append to list     ${corresponding_RMODS}      ${RMOD}
#     END
#     :FOR    ${RMOD_SN}    IN      @{rmod_serial_mapping}
#          run keyword if    '${rmod_serial_mapping['${RMOD_SN}']['configDN']}' in ${corresponding_RMODS}
#          ...    BBMOD RU Status should Disabled     sn_value=${RMOD_SN}
#      END
#      :For    ${bbmod}     IN    @{bbmods_info}
#          ${bbmod_r}    run keyword if     '${bbmod['configuration']}'=='${dist_name}'
#          ...    Get Regexp Matches    ${bbmod['internal']}     (BBMOD_R-\\d)    1
#          ${bbmod_r}     run keyword if     '${bbmod['configuration']}'=='${dist_name}'    Set Variable   ${bbmod_r[0]}
#          Exit for loop if    '${bbmod['configuration']}'=='${dist_name}'
#       END
#       return from keyword if    '${bbmod_r}' not in ${bbmod_cell_mapping}
#      :For    ${cell}    IN    @{bbmod_cell_mapping['${bbmod_r}']}
#          ${cell_id}     fetch from right    ${cell}   -
#          run keyword if    ${cell.count('NRCELL')}>0
#          ...   ADMIN check NR cell status    cell_index=${cell_id}
#          ...   expected_status='operationalstate': 'disabled'
#          ...   ELSE IF    ${cell.count('LNCEL')}>0
#          ...   ADMIN check LTE cell status     cell_index=${cell_id}
#          ...    expected_status='operationalstate': 'disabled'
#      END


BBMOD RU Cell Status should Enabled
     [Arguments]     ${dist_name}
     ${bbmod_index}     fetch from right     ${dist_name}     -
     &{bbmod_status}    Get bbmod info by bbmod index     bbmod_index=${bbmod_index}   connection=COAM
     Should be equal as strings    ${bbmod_status['status']['operationalState'].lower()}       enabled
                                  ...  msg=Current bbmod operationalState is not in Enabled status    ignore_case=${True}
#     ${corresponding_RMODS}     Create List
#     :FOR     ${RMOD}     IN    @{bbmod_mapping}
#          run keyword if     '${dist_name}'=='${bbmod_mapping['${RMOD}']}'
#          ...     append to list     ${corresponding_RMODS}      ${RMOD}
#     END
#     :FOR    ${RMOD_SN}    IN      @{rmod_serial_mapping}
#          run keyword if    '${rmod_serial_mapping['${RMOD_SN}']['configDN']}' in ${corresponding_RMODS}
#          ...    BBMOD RU Status should Enabled    sn_value=${RMOD_SN}
#      END
      FOR    ${bbmod}     IN    @{bbmods_info}
          ${bbmod_r}    run keyword if     '${bbmod['configuration']}'=='${dist_name}'
          ...    Get Regexp Matches    ${bbmod['internal']}     (BBMOD_R-\\d)    1
          ${bbmod_r}     run keyword if     '${bbmod['configuration']}'=='${dist_name}'    Set Variable    ${bbmod_r[0]}
          Exit for loop if    '${bbmod['configuration']}'=='${dist_name}'
       END
       return from keyword if    '${bbmod_r}' not in ${bbmod_cell_mapping}
      FOR    ${cell}    IN    @{bbmod_cell_mapping['${bbmod_r}']}
          ${cell_id}     fetch from right    ${cell}   -
          run keyword if    ${cell.count('NRCELL')}>0
          ...   ADMIN check NR cell status    cell_index=${cell_id}
          ...   expected_status='operationalstate': 'enabled'
          ...   ELSE IF    ${cell.count('LNCEL')}>0
          ...   ADMIN check LTE cell status     cell_index=${cell_id}
          ...    expected_status='operationalstate': 'enabled'
      END

RU Enabled corresponding Cell Status should Disabled
      [Arguments]    ${sn_value}
      # ${ru_index}     fetch from right     ${rmod_serial_mapping['${sn_value}']['configDN']}    -
      # Power Check RU Status    rmod_index=${ru_index}
      ${rmod_configDN}   Get Variable Value   ${rmod_serial_mapping['${sn_value}']['configDN']}
      Power Check RU Status COAM   rmod_configDN=${rmod_configDN}

      FOR    ${cell}     IN    @{rmod_cell_mapping['${sn_value}']}
          ${cell_id}     fetch from right    ${cell}   -
          run keyword if    ${cell.count('NRCELL')}>0
          ...   ADMIN check NR cell status    cell_index=${cell_id}
          ...   expected_status='operationalstate': 'disabled'
          ...   ELSE IF    ${cell.count('LNCEL')}>0
          ...   ADMIN check LTE cell status     cell_index=${cell_id}
          ...    expected_status='operationalstate': 'disabled'
      END

RU and corresponding Cell Status should Disabled
      [Arguments]    ${sn_value}
      # ${ru_index}     fetch from right     ${rmod_serial_mapping['${sn_value}']['configDN']}    -
      # RU Status abnormal   index=${ru_index}
      ${rmod_configDN}   Get Variable Value   ${rmod_serial_mapping['${sn_value}']['configDN']}
      ${status}   Run Keyword And Return Status   Power Check RU Status COAM   rmod_configDN=${rmod_configDN}
      Should Not Be True   ${status}

      FOR    ${cell}     IN    @{rmod_cell_mapping['${sn_value}']}
          ${cell_id}     fetch from right    ${cell}   -
          run keyword if    ${cell.count('NRCELL')}>0
          ...   ADMIN check NR cell status    cell_index=${cell_id}
          ...   expected_status='operationalstate': 'disabled'
          ...   ELSE IF    ${cell.count('LNCEL')}>0
          ...   ADMIN check LTE cell status     cell_index=${cell_id}
          ...    expected_status='operationalstate': 'disabled'
      END

RU and corresponding Cell Status should Enabled
      [Arguments]    ${sn_value}
      # ${ru_index}     fetch from right     ${rmod_serial_mapping['${sn_value}']['configDN']}    -
      # Power Check RU Status    rmod_index=${ru_index}

      ${rmod_configDN}   Get Variable Value   ${rmod_serial_mapping['${sn_value}']['configDN']}
      Power Check RU Status COAM   rmod_configDN=${rmod_configDN}

      FOR    ${cell}     IN    @{rmod_cell_mapping['${sn_value}']}
          ${cell_id}     fetch from right    ${cell}   -
          run keyword if    ${cell.count('NRCELL')}>0
          ...   ADMIN check NR cell status    cell_index=${cell_id}
          ...   expected_status='operationalstate': 'enabled'
          ...   ELSE IF    ${cell.count('LNCEL')}>0
          ...   ADMIN check LTE cell status     cell_index=${cell_id}
          ...    expected_status='operationalstate': 'enabled'
      END

BBMOD RU Status should Disabled
      [Arguments]    ${sn_value}
      # ${ru_index}     fetch from right     ${rmod_serial_mapping['${sn_value}']['configDN']}    -
      # RU Status abnormal   index=${ru_index}
      ${rmod_configDN}   Get Variable Value   ${rmod_serial_mapping['${sn_value}']['configDN']}
      ${status}   Run Keyword And Return Status   Power Check RU Status COAM   rmod_configDN=${rmod_configDN}
      Should Not Be True   ${status}


BBMOD RU Status should Enabled
      [Arguments]    ${sn_value}
      # ${ru_index}     fetch from right     ${rmod_serial_mapping['${sn_value}']['configDN']}    -
      # Power Check RU Status    rmod_index=${ru_index}
      ${rmod_configDN}   Get Variable Value   ${rmod_serial_mapping['${sn_value}']['configDN']}
      Power Check RU Status COAM   rmod_configDN=${rmod_configDN}


Check other Cells Status except One
     [Arguments]    ${cellid}
     ${nr_cell_list}     ${lte_cell_list}   COAM Get 4G 5G Cell List
     FOR    ${cell}     IN     @{nr_cell_list}
         continue for loop if   '${cell['globalCellId']}'=='${cellid}'
         wait until keyword succeeds   10min    20s
         ...   ADMIN check NR cell availability Status    cell_index=${cell['globalCellId']}
         ...    expected_status='availabilitystatus': '-'
         wait until keyword succeeds   10min    20s
         ...   ADMIN check NR cell availability Status    cell_index=${cell['globalCellId']}
         ...    expected_status='operationalstate': 'enabled'
     END
     FOR    ${cell}     IN     @{lte_cell_list}
         continue for loop if   '${cell['globalCellId']}'=='${cellid}'
         wait until keyword succeeds   10min    20s
         ...   ADMIN check LTE cell status    cell_index=${cell['globalCellId']}
         ...    expected_status='operationalstate': 'enabled'
     END

COAM Get 4G 5G Cell List
    [Arguments]   ${connection}=COAM
    ${bts_info}   coam.get_bts_info   connection=${connection}   timeout=10
    ${nr_cell_list}   Run Keyword If   'requestMessage' in @{bts_info.keys()}
    ...   Set Variable   ${bts_info['requestMessage']['cells']['nr']}
    ...   ELSE   Set Variable   ${bts_info['cells']['nr']}
    ${lte_cell_list}   Run Keyword If   'requestMessage' in @{bts_info.keys()}
    ...   Set Variable   ${bts_info['requestMessage']['cells']['lte']}
    ...   ELSE   Set Variable   ${bts_info['cells']['lte']}

    FOR   ${ltecell}    IN    @{lte_cell_list}
        run keyword if    '${ltecell['technology']}'=='NB-IoT-FDD'
        ...   Remove Values From List    ${lte_cell_list}    ${ltecell}
     END
    [Return]   ${nr_cell_list}     ${lte_cell_list}

Add HWF Flag at swconfig
    Log To Console   //TODO: Add HWF Flag at swconfig
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}  alias=${GLOBAL_BTS_ID}
    csn.Download File
    ...   remote_path=/ffs/run/swconfig.txt
    ...   local_path=${OUTPUT_DIR}/swconfig.txt
    ...   connection=${GLOBAL_BTS_ID}
    ...   timeout=${300}
    ${swconfig_content}   OperatingSystem.Get File   path=${OUTPUT_DIR}/swconfig.txt
    ${reset_swconfig_content}   Catenate   SEPARATOR=
    ...   ${swconfig_content}\n
    ...   \# HWF reset flag for releases before 15 December 2021\n
    ...   0x190030=0\n
    ...   \# HWF reset flag for releases after 15 December 2021\n
    ...   0x4F0214=0\n
    ${reset_swconfig_file_not_exist}   Run Keyword And Return Status   File Should Not Exist   path=${OUTPUT_DIR}/swconfig_reset.txt
    Run Keyword If   ${reset_swconfig_file_not_exist}
    ...   OperatingSystem.Create File   path=${OUTPUT_DIR}/swconfig_reset.txt   content=${reset_swconfig_content}
    ...   ELSE    run keywords    OperatingSystem.RUN    rm ${OUTPUT_DIR}/swconfig_reset.txt
    ...   AND     OperatingSystem.Create File   path=${OUTPUT_DIR}/swconfig_reset.txt   content=${reset_swconfig_content}
    csn.Upload File
    ...   local_path=${OUTPUT_DIR}/swconfig_reset.txt
    ...   remote_path=/ffs/run/swconfig.txt
    ...   connection=${GLOBAL_BTS_ID}
    csn.Execute
    ...   command=crasign /ffs/run/swconfig.txt
    ...   connection=${GLOBAL_BTS_ID}

    # DualCore swconfig.txt
    ${output}   csn.Execute   command=hostname   connection=${GLOBAL_BTS_ID}
    ${output}   Strip String   ${output}
    ${dual_core_host}   Set Variable If
    ...   '${output}'=='fct-0a'   fct-4a
    ...   '${output}'=='fct-4a'   fct-0a

    ${dualcore_exist}    run keyword and return status
    ...   csn.Connect to  hostname=${dual_core_host}  username=${asik_username}  password=${asik_password}
    ...   proxy=${GLOBAL_BTS_ID}  alias=${GLOBAL_BTS_ID}_dual
    ${secondary_swconfig_exist}    run keyword if   ${dualcore_exist}
     ...   csn.File Exists   remote_path=/ffs/run/swconfig.txt   connection=${GLOBAL_BTS_ID}_dual

    Run Keyword If   ${secondary_swconfig_exist}
    ...   csn.Download File
    ...   remote_path=/ffs/run/swconfig.txt
    ...   local_path=${OUTPUT_DIR}/swconfig_dual.txt
    ...   connection=${GLOBAL_BTS_ID}_dual
    ...   timeout=${300}

    ${swconfig_content_dual}   Run Keyword If   ${secondary_swconfig_exist}    OperatingSystem.Get File   path=${OUTPUT_DIR}/swconfig_dual.txt
    ${reset_swconfig_content_dual}     Run Keyword If   ${secondary_swconfig_exist}      Catenate   SEPARATOR=
    ...   ${swconfig_content_dual}\n
    ...   \# HWF reset flag for releases before 15 December 2021\n
    ...   0x190030=0\n
    ...   \# HWF reset flag for releases after 15 December 2021\n
    ...   0x4F0214=0\n
    ...   ELSE    Catenate   SEPARATOR=
    ...   0x1A0020=1 \#Enabled SSH even with TRS\n
    ...   0x10041=5 \#Enabled UDP log\n
    ...   \# HWF reset flag for releases before 15 December 2021\n
    ...   0x190030=0\n
    ...   \# HWF reset flag for releases after 15 December 2021\n
    ...   0x4F0214=0\n

    ${dual_reset_swconfig_file_not_exist}   Run Keyword And Return Status   File Should Not Exist   path=${OUTPUT_DIR}/dual_swconfig_reset.txt
    Run Keyword If   ${dual_reset_swconfig_file_not_exist}
    ...   OperatingSystem.Create File   path=${OUTPUT_DIR}/dual_swconfig_reset.txt   content=${reset_swconfig_content_dual}
    ...   ELSE    run keywords    OperatingSystem.RUN    rm ${OUTPUT_DIR}/dual_swconfig_reset.txt
    ...   AND     OperatingSystem.Create File   path=${OUTPUT_DIR}/dual_swconfig_reset.txt   content=${reset_swconfig_content_dual}
    run keyword if   ${dualcore_exist}      csn.Upload File
    ...   local_path=${OUTPUT_DIR}/dual_swconfig_reset.txt
    ...   remote_path=/ffs/run/swconfig.txt
    ...   connection=${GLOBAL_BTS_ID}_dual
    run keyword if   ${dualcore_exist}      csn.Execute
    ...   command=crasign /ffs/run/swconfig.txt
    ...   connection=${GLOBAL_BTS_ID}_dual

    [Teardown]   csn.Disconnect   connection=${GLOBAL_BTS_ID}

Remove HWF Flag at swconfig
    Log To Console   //TODO: Remove HWF Flag at swconfig
    ${hwf_flag}    set variable
    ...    \# HWF reset flag for releases before 15 December 2021\n0x190030=0\n\# HWF reset flag for releases after 15 December 2021\n0x4F0214=0\n
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}  alias=${GLOBAL_BTS_ID}
    csn.Download File
    ...   remote_path=/ffs/run/swconfig.txt
    ...   local_path=${OUTPUT_DIR}/swconfig.txt
    ...   connection=${GLOBAL_BTS_ID}
    ...   timeout=${300}
    ${swconfig_content}   OperatingSystem.Get File   path=${OUTPUT_DIR}/swconfig.txt
    ${hwf_exist}    run keyword and return status    Should Contain Any    ${swconfig_content}     190030   4F0214
    ${removehwf_swconfig_content}     run keyword if   ${hwf_exist}    Remove String    ${swconfig_content}    ${hwf_flag}
    ...    ELSE     set variable     None
#    ${removehwf_swconfig_content}    run keyword if   ${hwf_exist}     Catenate   SEPARATOR=${swconfig_content}\n
#    ...    ELSE     Catenate   SEPARATOR=NONE
    ${removehwf_swconfig_file_not_exist}   Run Keyword And Return Status   File Should Not Exist   path=${OUTPUT_DIR}/swconfig_removehwf.txt
    Run Keyword If   ${removehwf_swconfig_file_not_exist}
    ...   OperatingSystem.Create File   path=${OUTPUT_DIR}/swconfig_removehwf.txt   content=${removehwf_swconfig_content}
    ...   ELSE    run keywords    OperatingSystem.RUN    rm ${OUTPUT_DIR}/swconfig_removehwf.txt
    ...   AND     OperatingSystem.Create File   path=${OUTPUT_DIR}/swconfig_removehwf.txt   content=${removehwf_swconfig_content}
    run keyword if   ${hwf_exist}    csn.Upload File
    ...   local_path=${OUTPUT_DIR}/swconfig_removehwf.txt
    ...   remote_path=/ffs/run/swconfig.txt
    ...   connection=${GLOBAL_BTS_ID}
    run keyword if   ${hwf_exist}     csn.Execute
    ...   command=crasign /ffs/run/swconfig.txt
    ...   connection=${GLOBAL_BTS_ID}

    # DualCore swconfig.txt
    ${output}   csn.Execute   command=hostname   connection=${GLOBAL_BTS_ID}
    ${output}   Strip String   ${output}
    ${dual_core_host}   Set Variable If
    ...   '${output}'=='fct-0a'   fct-4a
    ...   '${output}'=='fct-4a'   fct-0a


    ${dualcore_exist}    run keyword and return status
    ...   csn.Connect to  hostname=${dual_core_host}  username=${asik_username}  password=${asik_password}
    ...   proxy=${GLOBAL_BTS_ID}  alias=${GLOBAL_BTS_ID}_dual

    run keyword if   ${dualcore_exist}      csn.Download File
    ...   remote_path=/ffs/run/swconfig.txt
    ...   local_path=${OUTPUT_DIR}/swconfig_dual.txt
    ...   connection=${GLOBAL_BTS_ID}_dual
    ...   timeout=${300}
    ${dual_swconfig_content}   run keyword if   ${dualcore_exist}      OperatingSystem.Get File   path=${OUTPUT_DIR}/swconfig_dual.txt
    ${hwf_exist}    run keyword if   ${dualcore_exist}
    ...     run keyword and return status    Should Contain Any    ${dual_swconfig_content}     190030    4F0214
    ${removehwf_swconfig_content}      run keyword if   ${hwf_exist}    Remove String    ${dual_swconfig_content}    ${hwf_flag}
    ...     ELSE     set variable     None
#    ${removehwf_swconfig_content}    run keyword if   ${hwf_exist}     Catenate   SEPARATOR=${dual_swconfig_content}\n
#    ...    ELSE     Catenate   SEPARATOR=NONE
    ${removehwf_swconfig_file_not_exist}   Run Keyword And Return Status   File Should Not Exist   path=${OUTPUT_DIR}/swconfig_removehwf.txt
    Run Keyword If   ${removehwf_swconfig_file_not_exist}
    ...   OperatingSystem.Create File   path=${OUTPUT_DIR}/swconfig_removehwf_dual.txt   content=${removehwf_swconfig_content}
    ...   ELSE    run keywords    OperatingSystem.RUN    rm ${OUTPUT_DIR}/swconfig_removehwf_dual.txt
    ...   AND     OperatingSystem.Create File   path=${OUTPUT_DIR}/swconfig_removehwf_dual.txt   content=${removehwf_swconfig_content}
    run keyword if   ${hwf_exist}    csn.Upload File
    ...   local_path=${OUTPUT_DIR}/swconfig_removehwf_dual.txt
    ...   remote_path=/ffs/run/swconfig.txt
    ...   connection=${GLOBAL_BTS_ID}_dual
    run keyword if   ${hwf_exist}   csn.Execute
    ...   command=crasign /ffs/run/swconfig.txt
    ...   connection=${GLOBAL_BTS_ID}_dual
    [Teardown]   csn.Disconnect   connection=${GLOBAL_BTS_ID}

Siso Common Check Blackbox
    Log To Console   //TODO: Siso Common Check Blackbox
    ${CASE_START_TIMESTAMP}   Get Variable Value   ${CASE_PROCESS_START}   ${SUITE_SETUP_START}
    # ssh-keygen -f "/home/ute/.ssh/known_hosts" -R "10.71.211.166"
    Run Process    ssh-keygen    -f    /home/ute/.ssh/known_hosts    -R     ${asik_addr}
    Wait Until Keyword Succeeds   1m   15s   csn.Connect to
    ...   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=${GLOBAL_BTS_ID}
    ${blackbox}   csn.Execute   command=cd /ffs/run/config/lifedata;cat blackbox   timeout=${300}   connection=${GLOBAL_BTS_ID}
    @{blackbox_split}   Split String   ${blackbox}   \r\n

    @{blackbox_info_list}   Create List
    FOR   ${blackbox_line}   IN   @{blackbox_split}
        ${isoutctime}   Set Variable   ${blackbox_line[:24]}
        ${status}   Run Keyword And Return Status
        ...   Should Match Regexp   ${isoutctime}   \\d{4}-[01]\\d-[0-3]\\dT[0-2]\\d:[0-5]\\d:[0-5]\\d\.\\d+([+-][0-2]\\d:[0-5]\\d|Z)
        Continue For Loop If   not ${status}
        ${datetime}   DateTime.Convert Date   date=${isoutctime}+0000   result_format=datetime   date_format=%Y-%m-%dT%H:%M:%S.%fZ%z
        ${timestamp}   Evaluate   dateutil.parser.parse("${datetime.isoformat()}").timestamp()   dateutil.parser,dateutil
        Run Keyword If   ${timestamp} > ${CASE_START_TIMESTAMP}   Append To List   ${blackbox_info_list}   ${blackbox_line}
    END

    @{Extra_Reset}   Create List
    ...   System module site reset : Recovery (Execute reset.)
    ...   probably SW crash
    ...   Recovery (Execute reset.)
    ...   Watchdog reset
    FOR   ${blackbox_info}   IN   @{blackbox_info_list}
        ${is_Extra_Reset}   Evaluate   any(s in "${blackbox_info}" for s in ${Extra_Reset})
        Run Keyword If   ${is_Extra_Reset}   Fail   msg=BlackBox Unexpected Reset Happen: ${blackbox_info}
    END
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${GLOBAL_BTS_ID}

Siso Common Check Syslog Error
    Log To Console   //TODO: Siso Common Check Syslog Error
#    ${test_pc_addr}   Get Variable Value   ${TESTPC_ADDR}   ${EMPTY}
#    ${test_pc_username}   Get Variable Value   ${TESTPC_user}   ${EMPTY}
#    ${test_pc_password}   Get Variable Value   ${TESTPC_pwd}   ${EMPTY}
#
#    Return From Keyword If   "${test_pc_addr}"=="" or "${test_pc_addr}"=="${None}" or "${test_pc_addr}"=="1.1.1.1"
#
#    ${connection_status}   Run Keyword And Return Status   csn.Connect to
#    ...   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${test_pc_addr}   timeout=${10}
#    Run Keyword If   not ${connection_status}   Log To Console   Test PC Can Not Connect: ${test_pc_addr}
#    Return From Keyword If   not ${connection_status}

#    ${output}   csn.Execute   command=ls -al /tmp/btslog2/SYSLOG*.LOG   connection=${test_pc_addr}
    ${output}   RUN   command=ls -al /tmp/btslog2/SYSLOG*.LOG
    ${syslog_exist}   Run Keyword And Return Status   Should Not Contain   ${output}   No such file or directory
    Return From Keyword If   not ${syslog_exist}

#    Log To Console   Check Syslog Error On TestPC: ${test_pc_addr}
#    Log To Console   Syslog File List:
#    Log To Console   ${output}

    ${offline_output}   RUN
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep 'CELL NOTIFICATION 4329 Radio memory consumption exceeds abnormal threshold'
    ${status1}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${offline_output}   RUN
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep 'FaultId: 4329'
    ${status2}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${offline_output}   RUN
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep 'FaultId: 4330'
    ${status3}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${offline_output}   RUN
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep 'Detector 4329'
    ${status4}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${offline_output}   RUN
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep 'Detector 4330'
    ${status5}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${offline_output}   RUN
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep 'active 4329'
    ${status6}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${offline_output}   RUN
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep 'active 4330'
    ${status7}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${offline_output}   RUN
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep '4230 Radio memory consumption exceeds critical threshold'
    ${status8}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${offline_output}   RUN
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep '\\-\\=\\-\\='
    ${status9}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${command}   Catenate   SEPARATOR=
    ...   cat /tmp/btslog2/SYSLOG*.LOG
    ...   | grep 'Pleasecontact the owner'
    ...   | grep -v '/ffs/run/logs'
    ...   | grep -v 'is not defined in SysinfoQuota.xml'
    ${offline_output}   RUN   command=${command}
    ${status10}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${command}   Catenate   SEPARATOR=
    ...   cat /tmp/btslog2/SYSLOG*.LOG
    ...   | grep 'ERR'
    ...   | grep '/ffs/run/logs'
    ...   | grep 'is not defined in SysinfoQuota.xml'
    ...   | grep 'Pleasecontact the owner'
    ${offline_output}   RUN   command=${command}
    ${status11}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${cmd_errorallowed}     Evaluate     '| '.join(@{SYSLOG_ERROR_allowed})
    ${command}   Catenate   SEPARATOR=
    ...   cat /tmp/btslog2/SYSLOG*.LOG
    ...   | grep -iE 'ERR/CP|ERR/L2'
#    ...   | grep -iE 'ERR/L2'
    ...   | ${cmd_errorallowed}
    ${offline_output}   RUN    command=${command}
    ${status12}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   L2 or CP has error LOG!


    ${status_list}   Create List   ${status1}   ${status2}   ${status3}   ${status4}   ${status5}   ${status6}
    ...   ${status7}   ${status8}   ${status9}   ${status10}   ${status11}    ${status12}
    Run Keyword And Continue On Failure   List Should Not Contain Value   ${status_list}   ${False}

#    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${test_pc_addr}


Siso Common Syslog Should Contain
    [Arguments]    ${filter}    ${shouldcontain_str}
    Log To Console   //TODO: Siso Common Syslog Should Contain
    ${test_pc_addr}   Get Variable Value   ${TESTPC_ADDR}   ${EMPTY}
    ${test_pc_username}   Get Variable Value   ${TESTPC_user}   ${EMPTY}
    ${test_pc_password}   Get Variable Value   ${TESTPC_pwd}   ${EMPTY}

    Return From Keyword If   "${test_pc_addr}"=="" or "${test_pc_addr}"=="${None}" or "${test_pc_addr}"=="1.1.1.1"

    ${connection_status}   Run Keyword And Return Status   csn.Connect to
    ...   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${test_pc_addr}   timeout=${10}
    Run Keyword If   not ${connection_status}   Log To Console   Test PC Can Not Connect: ${test_pc_addr}
    Return From Keyword If   not ${connection_status}

    ${output}   csn.Execute   command=ls -al /tmp/btslog2/SYSLOG*.LOG   connection=${test_pc_addr}
    ${syslog_exist}   Run Keyword And Return Status   Should Not Contain   ${output}   No such file or directory
    Return From Keyword If   not ${syslog_exist}

    Log To Console   Check Syslog Error On TestPC: ${test_pc_addr}
    Log To Console   Syslog File List:
    Log To Console   ${output}

    ${command}   Catenate   SEPARATOR=
    ...   cat /tmp/btslog2/SYSLOG*.LOG
    ...   | grep ${filter}

    ${output}   csn.Execute   connection=${test_pc_addr}   command=${command}
    Should Not Be Empty   ${output}    ${filter} not in syslog!

    ${command}   Catenate   SEPARATOR=
    ...   cat /tmp/btslog2/SYSLOG*.LOG
    ...   | grep ${filter}
    ...   | grep ${shouldcontain_str}

    ${output}   csn.Execute   connection=${test_pc_addr}   command=${command}
    Should Not Be Empty   ${output}    ${shouldcontain_str} not happened in ${filter} syslog!

    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${test_pc_addr}


Siso Common Syslog Should Not Contain
    [Arguments]    ${filter}    ${shouldnotcontain_str}
    Log To Console   //TODO: Siso Common Syslog Should Not Contain
    ${test_pc_addr}   Get Variable Value   ${TESTPC_ADDR}   ${EMPTY}
    ${test_pc_username}   Get Variable Value   ${TESTPC_user}   ${EMPTY}
    ${test_pc_password}   Get Variable Value   ${TESTPC_pwd}   ${EMPTY}

    Return From Keyword If   "${test_pc_addr}"=="" or "${test_pc_addr}"=="${None}" or "${test_pc_addr}"=="1.1.1.1"

    ${connection_status}   Run Keyword And Return Status   csn.Connect to
    ...   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${test_pc_addr}   timeout=${10}
    Run Keyword If   not ${connection_status}   Log To Console   Test PC Can Not Connect: ${test_pc_addr}
    Return From Keyword If   not ${connection_status}

    ${output}   csn.Execute   command=ls -al /tmp/btslog2/SYSLOG*.LOG   connection=${test_pc_addr}
    ${syslog_exist}   Run Keyword And Return Status   Should Not Contain   ${output}   No such file or directory
    Return From Keyword If   not ${syslog_exist}

    Log To Console   Check Syslog Error On TestPC: ${test_pc_addr}
    Log To Console   Syslog File List:
    Log To Console   ${output}

    ${command}   Catenate   SEPARATOR=
    ...   cat /tmp/btslog2/SYSLOG*.LOG
    ...   | grep ${filter}

    ${output}   csn.Execute   connection=${test_pc_addr}   command=${command}
    Should Not Be Empty   ${output}    ${filter} not in syslog!

    ${command}   Catenate   SEPARATOR=
    ...   cat /tmp/btslog2/SYSLOG*.LOG
    ...   | grep ${filter}
    ...   | grep ${shouldnotcontain_str}

    ${output}   csn.Execute   connection=${test_pc_addr}   command=${command}
    Should Be Empty   ${output}    ${shouldnotcontain_str} happened in ${filter} syslog!

    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${test_pc_addr}


Siso Common Get BBMOD Mapping RMOD
    [Arguments]   ${source}
    ${cablink_list}   XML.Get Elements   ${source}   xpath=cmData/managedObject[@class="com.nokia.srbts.eqm:CABLINK"]
    # @{rmod_detail_list}   Create List
    &{bbmod_ru_mapping}   Create Dictionary
    FOR   ${cablink}   IN   @{cablink_list}
        ${firstEndpointDN}    XML.Get Element Text   ${cablink}   p[@name="firstEndpointDN"]
        ${secondEndpointDN}   XML.Get Element Text   ${cablink}   p[@name="secondEndpointDN"]
        continue for loop if    ${firstEndpointDN.count('SMOD')}>0 or ${secondEndpointDN.count('SMOD')}>0
        ${bbmodru_list}    create list     default
        run keyword if    '${secondEndpointDN}' in @{bbmod_ru_mapping}
        ...    Append to list    ${bbmod_ru_mapping['${secondEndpointDN}']}   ${firstEndpointDN}
        ...   ELSE    run keywords
        ...    Set List Value     ${bbmodru_list}    0    ${firstEndpointDN}
        ...    AND    Set To Dictionary   ${bbmod_ru_mapping}   ${secondEndpointDN}=${bbmodru_list}
        Remove Duplicates    ${bbmod_ru_mapping['${secondEndpointDN}']}
    END
    [Return]   ${bbmod_ru_mapping}

Siso Common Get BBMOD Mapping Cell
    [Arguments]   ${source}
    ${bbpool_list}   XML.Get Elements   ${source}   xpath=cmData/managedObject[@class="com.nokia.srbts.mnl:BBPOOL"]
    # @{rmod_detail_list}   Create List
    &{bbmod_cell_mapping}   Create Dictionary
    FOR   ${bbpool}   IN   @{bbpool_list}
        ${bbmoddn}    XML.Get Elements Texts  ${bbpool}   list[@name="bbPwrGroupDNList"]/p
        ${bbmoddn}    Get Regexp Matches     ${bbmoddn[0]}     (BBMOD_R-\\d)    1
        continue for loop if    len(${bbmoddn})==${0}
        ${bbmoddn}    set variable    ${bbmoddn[0]}
        ${status}     ${cells}   run keyword and ignore error     XML.Get Elements Texts   ${bbpool}   list[@name="bbPoolCellsList"]/p
        continue for loop if    ${status.count('FAIL')}>0
        ${celltype}    XML.Get Element Text   ${bbpool}   p[@name="bbPoolTech"]
        continue for loop if    ${celltype.count('5G')}<=0 and ${celltype.count('LTE')}<=0
        ${globle_cells}     Mapping Lcrid with global id List    source=${source}     cells=${cells}   celltype=${celltype}
        ${bbmod_cell_mapping}     _handle cell in loop
        ...    cells=${globle_cells}     bbmod_cell_mapping=${bbmod_cell_mapping}    celltype=${celltype}    bbmoddn=${bbmoddn}
        run keyword if   '${bbmoddn}' in @{bbmod_cell_mapping}     Remove Duplicates    ${bbmod_cell_mapping['${bbmoddn}']}
    END
    [Return]   ${bbmod_cell_mapping}

_handle cell in loop
    [Arguments]     ${cells}      ${bbmod_cell_mapping}    ${celltype}    ${bbmoddn}
    FOR    ${cell}    IN    @{cells}
        ${celldn}     set variable if   ${celltype.count('5G')}>0    NRCELL-${cell}    LNCEL-${cell}
        ${bbmod_exist}   Get Variable Value   ${bbmod_cell_mapping['${bbmoddn}'}   ${EMPTY}
        run keyword if    '${bbmod_exist}'!='${EMPTY}'
        ...    continue for loop if    '${celldn}' in @{bbmod_cell_mapping['${bbmoddn}']}
        ${bbmodcell_list}    create list     default
        run keyword if    '${bbmoddn}' in @{bbmod_cell_mapping}
        ...    append to list    ${bbmod_cell_mapping['${bbmoddn}']}   ${celldn}
        ...    ELSE    run keywords
        ...    Set List Value    ${bbmodcell_list}    0    ${celldn}
        ...    AND    Set To Dictionary   ${bbmod_cell_mapping}   ${bbmoddn}=${bbmodcell_list}
     END
     [Return]    ${bbmod_cell_mapping}

Mapping Lcrid with global id List
    [Arguments]   ${source}     ${cells}     ${celltype}
    ${globle_cells}    create list
    FOR    ${cell}     IN    @{cells}
        ${globle_cellid}     Mapping Lcrid with global id    source=${source}    lcrid=${cell}    celltype=${celltype}
        append to list    ${globle_cells}     ${globle_cellid}
     END
     [Return]    ${globle_cells}

Mapping Lcrid with global id
    [Arguments]    ${source}     ${lcrid}    ${celltype}
    ${nrcell_list}   XML.Get Elements   ${source}   xpath=cmData/managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    ${ltecell_list}   XML.Get Elements   ${source}   xpath=cmData/managedObject[@class="NOKLTE:LNCEL"]
    FOR    ${nrcell}    IN    @{nrcell_list}
        exit for loop if     ${celltype.count('5G')}<=0
        ${lcrid_nrcell}    XML.Get Element Text   ${nrcell}   p[@name="lcrId"]
        continue for loop if     '${lcrid_nrcell}'!='${lcrid}'
        ${distname}     XML.Get Element Attribute   ${nrcell}   distName
        ${gloabal_cellid}    fetch from right    ${distname}     NRCELL-
    END

    FOR    ${ltecell}    IN    @{ltecell_list}
        exit for loop if     ${celltype.count('LTE')}<=0
        ${lcrid_ltecell}    XML.Get Element Text   ${ltecell}   p[@name="lcrId"]
        continue for loop if     '${lcrid_ltecell}'!='${lcrid}'
        ${distname}     XML.Get Element Attribute   ${ltecell}   distName
        ${gloabal_cellid}    fetch from right    ${distname}     LNCEL-
    END
    [Return]    ${gloabal_cellid}



Block other cells except L3CALL
    [Arguments]    ${l3call_cell_list}
    ${nr_cell_list}     ${lte_cell_list}    COAM Get 4G 5G Cell List
    FOR  ${nrcell}  IN  @{nr_cell_list}
        run keyword if    '${nrcell['globalCellId']}' not in @{l3call_cell_list}
        ...    ADMIN Block NR cell and check status      cell_index=${nrcell['globalCellId']}
    END
    FOR  ${ltecell}  IN  @{lte_cell_list}
        run keyword if    '${ltecell['globalCellId']}' not in @{l3call_cell_list}
        ...    ADMIN Block LTE cell and check status     cell_index=${ltecell['globalCellId']}
    END

UnBlock other cells except L3CALL
    [Arguments]    ${l3call_cell_list}
    ${nr_cell_list}     ${lte_cell_list}    COAM Get 4G 5G Cell List
    FOR  ${nrcell}  IN  @{nr_cell_list}
        run keyword if    '${nrcell['globalCellId']}' not in @{l3call_cell_list}
        ...    ADMIN UnBlock NR cell and check status      cell_index=${nrcell['globalCellId']}
    END
    FOR  ${ltecell}  IN  @{lte_cell_list}
        run keyword if    '${ltecell['globalCellId']}' not in @{l3call_cell_list}
        ...    ADMIN UnBlock LTE cell and check status     cell_index=${ltecell['globalCellId']}
    END

Validate BTS Reachability from VM
    [Arguments]  ${ip_addr}  ${exp_status}
    ${ipv6}  run keyword and return status   should contain   ${ip_addr}  :
    ${output}   run keyword if  '${ipv6}' == 'True'
    ...    RUN    sudo ping6 ${asik_addr} -c 3
    ...    ELSE   RUN    sudo ping ${ip_addr} -c 3
    ${output}    Get Regexp Matches    ${output}    \\d{0,3}% packet loss
    ${output}    Fetch From Left    ${output[0]}    %
    ${status}  set variable if   '${output}'== '0'   ${True}   ${False}
    should be equal   ${exp_status}   ${status}

Check Truck Roll Process
    [Arguments]  ${connection}=COAM
    Log To Console   Checking if truck roll occurred
    ${mplane_connectivity}   Run Keyword And Return Status    Validate BTS Reachability from VM
    ...   ip_addr=${asik_addr}  exp_status=${True}
    Run Keyword If   not ${mplane_connectivity}
    ...   Fatal Error   msg=Truck Roll Detect, BTS is not reachable (WebEM connection cannot be established) via M-Plane
    @{truck_roll_fault}   Create List   ${10}    ${16}    ${1806}    ${1868}    ${4341}    ${4352}    ${4383}
    ${active_alarms}   coam.get_active_alarms    connection=${connection}
    FOR   ${active_alarm}    IN   @{active_alarms}
        ${faultId}   Get Variable Value   ${active_alarm['faultId']}
        ${truck_roll_detect}   Run Keyword And Return Status    List Should Contain Value    ${truck_roll_fault}    ${faultId}
        Run Keyword If   ${truck_roll_detect}
        ...   Fatal Error   msg=Potential Truck Roll Detect, Fault ID: ${faultId}
    END


Recovery At Case Setup if Fault Occurs
    ${status_fault}     run keyword and return status     Wait Until Keyword Succeeds    5min    30s
    ...    check Faults for siso common    allowedfault_list=${SISO_FAULT_allowed}
    run keyword if  not ${status_fault}    COAM SCF Commission     filepath=${OUTPUT_DIR}/siso_scf.xml
    Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair


Power Check RU Status COAM
    [Arguments]   ${rmod_configDN}   ${connection}=COAM
    ${hw_info}   coam.get_detected_hw_info   connection=${connection}
    @{rmod_info}   Get Variable Value   ${hw_info['radioModules']['rmod']}
    FOR   ${rmod}   IN   @{rmod_info}
        ${configDN}   Get Variable Value   ${rmod["id"]["configuration"]}
        Continue For Loop If   "${configDN}"!="${rmod_configDN}"

        ${administrative_state}   Get Variable Value   ${rmod["status"]["administrativeState"]}
        ${operational_state}   Get Variable Value   ${rmod["status"]["operationalState"]}

        Should Be Equal   ${administrative_state.lower()}   unlocked
        Should Be Equal   ${operational_state.lower()}   enabled

    END


Active or Disable Rat Hard Reset by Param
    [Arguments]    ${option}
    ${value}    COAM Get Parameter Value    dist_name=MRBTS-${GLOBAL_BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...   parameter=actRatResetEnhancement
    run keyword if  '${value}'!='${option}' and '${option.lower()}'=='false'
    ...    COAM Commission Prameters Operation    param_dic_to_change=${PARAMS_TO_actRATResetEnhancement_false}
    ...    ELSE IF    '${value}'!='${option}' and '${option.lower()}'=='true'
    ...    COAM Commission Prameters Operation    param_dic_to_change=${PARAMS_TO_actRATResetEnhancement_true}


Check If WCDMA Or GSM Deployed On BBMOD
    [Arguments]   ${source}
    ${bbpool_list}   XML.Get Elements   ${source}   xpath=cmData/managedObject[@class="com.nokia.srbts.mnl:BBPOOL"]
    # @{rmod_detail_list}   Create List
    ${wcdma_or_gsm_deployed}   Create List
    FOR   ${bbpool}   IN   @{bbpool_list}
        ${bbmoddn}    XML.Get Elements Texts  ${bbpool}   list[@name="bbPwrGroupDNList"]/p
        ${bbmoddn}    Get Regexp Matches     ${bbmoddn[0]}     (BBMOD_R-\\d)    1
        continue for loop if    len(${bbmoddn})==${0}
        ${bbmoddn}    set variable    ${bbmoddn[0]}
        ${status}     ${cells}   run keyword and ignore error     XML.Get Elements Texts   ${bbpool}   list[@name="bbPoolCellsList"]/p
        continue for loop if    ${status.count('FAIL')}>0
        ${celltype}    XML.Get Element Text   ${bbpool}   p[@name="bbPoolTech"]
        continue for loop if    ${celltype.count('5G')}>0
        continue for loop if    ${celltype.count('LTE')}>0
        run keyword if   ${celltype.count('WCDMA')}>0
        ...   Append to list     ${wcdma_or_gsm_deployed}    ${bbmoddn}
        run keyword if    ${celltype.count('GSM')}>0
        ...   Append to list     ${wcdma_or_gsm_deployed}    ${bbmoddn}
        ${if_empty}   run keyword and return status    should not be empty    ${wcdma_or_gsm_deployed}
        run keyword if   ${if_empty}     Remove Duplicates    ${wcdma_or_gsm_deployed}
    END
    [Return]   ${wcdma_or_gsm_deployed}


Validate IP Reachability from Control PC
    [Arguments]  ${ip_addr}   ${ctrl_addr}    ${ctrl_username}    ${ctrl_password}    ${exp_status}
    csn.connect to   hostname=${ctrl_addr}   username=${ctrl_username}   password=${ctrl_password}   alias=ctrl_pc
    ${ipv6}  run keyword and return status   should contain   ${ip_addr}  :
    ${output}   run keyword if  '${ipv6}' == 'True'
    ...     csn.execute    sudo ping6 ${asik_addr} -c 3   connection=ctrl_pc
    ...    ELSE   csn.execute    sudo ping ${ip_addr} -c 3    connection=ctrl_pc
    ${output}    Get Regexp Matches    ${output}    \\d{0,3}% packet loss
    ${output}    Fetch From Left    ${output[0]}    %
    ${status}  set variable if   '${output}'== '0'   ${True}   ${False}
    should be equal   ${exp_status}   ${status}
    [Teardown]    csn.disconnect    connection=ctrl_pc

Collect FPGA Blackbox File
    #.py file get from https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=FPGA511&title=Blackbox
    Wait Until Keyword Succeeds    5 min    1 min
    ...   csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    csn.Upload File    local_path=/home/ute/bbox_functionality_script_0xA000.py
    ...     remote_path=/tmp/bbox_functionality_script_0xA000.py    connection=gnb
    Wait Until Keyword Succeeds   3x   15s   csn.File Exists   remote_path=/tmp/bbox_functionality_script_0xA000.py   connection=gnb
    log to console    Upload SPGA Blackbox File finished!
    csn.Execute    command=cd /tmp;python3 bbox_functionality_script_0xA000.py rc   connection=gnb
    csn.Execute    command=tar -cvf /tmp/sw_bram_data.tar /tmp/sw_bram_data*    connection=gnb
    csn.Download File   remote_path=/tmp/sw_bram_data.tar   local_path=${OUTPUT_DIR}/sw_bram_data.tar   connection=gnb
    [Teardown]    run keyword and ignore error    csn.Disconnect   connection=gnb

Check reset loop counter
    Wait Until Keyword Succeeds    5 min    1 min
    ...   csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    ${reset_count}     csn.Execute    command=ddal -s ddal_boot_get_reset_loop_count   connection=gnb
    should not contain    ${reset_count}    val=2
    should not contain    ${reset_count}    val=3
    [Teardown]    run keyword and ignore error    csn.Disconnect   connection=gnb
