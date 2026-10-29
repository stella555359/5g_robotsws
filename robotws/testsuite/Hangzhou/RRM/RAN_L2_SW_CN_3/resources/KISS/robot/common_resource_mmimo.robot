*** Settings ***
Library    ute_pdu
Library    taf.sbts.oam.coam.admin
Library    ute_syslog
Library    ute_fsmaccess
Library    ta_kiss_enb_ttitrace
Library    ta_a2a
Library    String
Library    ute_ue
Library    OperatingSystem
Library    ${CURDIR}/../python/ttitrace_control.py
Library    ${CURDIR}/../python/getcellmapping.py
Library    ${CURDIR}/../python/vendor_modify.py
Library    ${CURDIR}/../python/ue_interface.py
Library    ${CURDIR}/../python/scfc_for_zwc.py
Library    ${CURDIR}/../python/thoughput.py
Library    ${CURDIR}/../python/use_admin.py
Library    ${CURDIR}/../python/hzdu1_fv_get_env_info.py
Library    ${CURDIR}/../python/hbte.py
Library    ${CURDIR}/../python/tak_bts/
Library    ${CURDIR}/../python/tak_common/
Library    ${CURDIR}/../python/tak_xml/
Variables    ${CURDIR}/../python/tak_config/
Resource     ${CURDIR}/SCFC_Configure.robot


*** Variables ***
${bts_host}     192.168.255.1
${bts_port}     443
${sprint_conf}      ${CURDIR}/configuration_file/sprint_tm8.xml
${swconfig_configuration}       ${CURDIR}/configuration_file/swconfig.txt


*** Keywords ***
common suite setup
    clean_up_env
    ${timestamp}           Evaluate      time.strftime('%Y%m%d%H%M')        time
    Set Suite Variable    ${timestamp}
    ${FILE_NAME} =    Replace String Using Regexp    ${SUITE_NAME[:50]}    \\s+$    ${EMPTY}
    ${SUITE_LOG_DIRECTORY} =    Catenate    SEPARATOR=${/}    ${OUTPUT_DIR}    ev_logs    ${FILE_NAME}_${timestamp}
    ${SUITE_LOG_DIRECTORY}    Replace String    ${SUITE_LOG_DIRECTORY}    ${SPACE}    _
    Set Suite Variable    ${SUITE_LOG_DIRECTORY}
    Create Directory    ${SUITE_LOG_DIRECTORY}
    ${ue1_id}    get_env_variable     ue1_ip
    Set Suite Variable    ${ue1_id}
    ${ue2_id}    get_env_variable     ue2_ip
    Set Suite Variable    ${ue2_id}
    ${ue3_id}    get_env_variable     ue3_ip
    Set Suite Variable    ${ue3_id}
    ${ue4_id}    get_env_variable     ue4_ip
    Set Suite Variable    ${ue4_id}
    ${ue5_id}    get_env_variable     ue5_ip
    Set Suite Variable    ${ue5_id}
    ${ue6_id}    get_env_variable     ue6_ip
    Set Suite Variable    ${ue6_id}
    ${ue7_id}    get_env_variable     ue7_ip
    Set Suite Variable    ${ue7_id}
    ${ue8_id}    get_env_variable     ue8_ip
    Set Suite Variable    ${ue8_id}
    ${status}      ${ret}     run keyword and ignore error     Wait ENB Connection
    run keyword if           "${status}"=="FAIL"        bts_hardware_reset
    ${status}      ${ret}     run keyword and ignore error     Wait ENB Connection
    run keyword if           "${status}"=="PASS"      run keyword and ignore error     upload_swconfig_to_enb

common suite Teardown
    generate_output_file    ${SUITE_LOG_DIRECTORY}//version.txt
    clean_up_env
    run_keyword_and_ignore_error    run    zip -r ${SUITE_LOG_DIRECTORY}.zip ${SUITE_LOG_DIRECTORY}

Common Test Setup
    clean_up_env
    kill_iperf
    ${TEST_LOG_DIR}    Catenate    SEPARATOR=${/}    ${SUITE_LOG_DIRECTORY}    ${TEST_NAME[:50]}
    ${TEST_LOG_DIR}    Replace String    ${TEST_LOG_DIR}    ${SPACE}    _
    Set Suite Variable    ${TEST_LOG_DIR}
    Create Directory    ${TEST_LOG_DIR}
    ${scfc_configuration}     get_scfc_path
    Set Test Variable    ${scfc_configuration}

Common Test Teardown
    #Run Keyword If Test Failed      Get TTitrace Log
    Run Keyword If Test Failed      run_keyword_and_ignore_error     get_active_alarm_via_admin
    Run Keyword If Test Failed      run_keyword_and_ignore_error     collect_snapshot_and_im_via_admin    ${TEST_LOG_DIR}
    Run Keyword If Test Failed      run_keyword_and_ignore_error      Stop and collect enb syslog
    kill_iperf
    #find_err_and_wrn_print_from_syslog     ${TEST_LOG_DIR}     ${TEST_NAME[:60]}
    collect_enb_parameter_file
    run_keyword_and_ignore_error    run keyword if    '${Count_M8012C26}'!=''    upload_data_to_mysql     ${TEST_NAME[:60]}
    ...    ${Count_M8012C26}     ${Count_M8012C23}

disable_security_port_and_enable_ssh_and_rd_port
    Setup Enb Fsm Access
    enable_enb_ssh
    enable_enb_rnd_ports
    Teardown Enb Fsm Access
    Setup btssm    alias=security
    Kill Sitemanager
    disable_bts_port_security    alias=security
    Teardown btssm    alias=security

Start enb syslog'${id}'
    #${stat}    ${ret}    run_keyword_and_ignore_error    stop_syslog    alias=enb
    Start syslog    log_dir=${TEST_LOG_DIR}    log_name=btslog_${id}.LOG    ip=192.168.255.126    alias=enb

Stop and collect enb syslog
    collect_syslog_results  alias=enb     destination=${TEST_LOG_DIR}${/}btslog

bts_hardware_reset
    setup_pdu         host=${tl.iphy[1].pdu.addr}    model=${tl.enb[1].pdu.device}
    ${outlet_status}=      get_pdu_outlet_status       outlet=${tl.enb[1].pdu.port}
    run keyword if           "${outlet_status}"=="on"     pdu_outlet_reset     outlet=${tl.enb[1].pdu.port}
    run keyword if           "${outlet_status}"=="off"    pdu_outlet_on        outlet=${tl.enb[1].pdu.port}
    teardown_pdu

bts_command_reboot
    setup_enb_fsm_access      alias=enb1
    ${status}     execute_command_on_enb     reboot       alias=enb1
    teardown_enb_fsm_access       alias=enb1

collect_enb_parameter_file
    setup admin     bts_host=${bts_host}      bts_port=${bts_port}      use_ssl=True      timeout=60      alias=collect
    collect_scf           target_file_name=${TEST_LOG_DIR}${/}configuration${/}scfc.xml     alias=collect
    teardown admin       alias=collect
    Setup Enb Fsm Access        alias=enb1
    get_enb_swconfig_file         destination=${TEST_LOG_DIR}${/}configuration${/}         alias=enb1
    get_enb_targetbd_file       destination=${TEST_LOG_DIR}${/}configuration${/}         alias=enb1
    ${VENDOR_path}              get_eNB_vendorfile_absolute_path
    get_enb_file     source=${VENDOR_path}     destination=${TEST_LOG_DIR}${/}configuration${/}     alias=enb1
    Teardown Enb Fsm Access  alias=enb1

modify_scfc_and_full_commission
    [Arguments]        ${scfc_path}      ${modify_list}
    setup admin     bts_host=${bts_host}      bts_port=${bts_port}      use_ssl=True     alias=commission
    modify_xml         ${scfc_path}            ${scfc_path}         ${modify_list}
    #migrate_scfc_using_sutool       ${scfc_path}       ${scfc_path}
    perform commissioning     bts_id=1      scf_file=${scfc_path}     skip_parameter_relation_errors=${True}     should_activate=${True}
    ...    timeout=900    alias=commission
    teardown admin       alias=commission

start_capture_ttitrace'${id}'
    setup enb ttitrace    log_path=${TEST_LOG_DIR}${/}ttitrace_${id}
    start enb ttitrace    node_type=ALL    cell_id=ALL    port=15003    filesize=200


Save_and_Decode_ttitrace_'${id}'
    @{dat_file}=    stop enb ttitrace
    FOR    ${item}    IN    @{dat_file}
        decode_enb_ttitrace    dat_file=${item}    nb=${False}
        Remove Files    ${item}    ${TEST_LOG_DIR}${/}ttitrace_${id}${/}*.harq
    END
    run_keyword_and_ignore_error    tract_key_value_from_ttitrace    ${TEST_LOG_DIR}${/}ttitrace_${id}
    teardown enb ttitrace

collect_RRM_requirement_log'${id}'
    [Documentation]     collect enbsyslog ttitracelog .
    Start enb syslog'${id}'
    start_capture_ttitrace'${id}'

save_RRM_requirement_log'${id}'
    Save_and_Decode_ttitrace_'${id}'
    Stop and collect enb syslog

Get TTitrace Log
    @{dat_file}=    stop enb ttitrace
    FOR    ${item}    IN    @{dat_file}
        decode_enb_ttitrace    dat_file=${item}    nb=${False}
    END
    teardown enb ttitrace

Reboot ENB And Wait Disconnection
    Setup admin     alias=reset_bts
    reset_site     timeout=25min       alias=reset_bts
    Teardown admin      alias=reset_bts

Wait ENB Connection
    Setup Enb Fsm Access
    Wait Until Host Is Available    192.168.255.1   timeout=120
    Teardown Enb Fsm Access

open debug log of log level'${parameter}'set'${value}'on'${direction}'for'${cell_id}'
    set_rad_parameter     setlog     ${direction}     ${cell_id}     ${parameter}     ${value}

open debug log of rd parameter'${parameter}'set'${value}'on'${direction}'for'${cell_id}'
    set_rad_parameter     setrd     ${direction}     ${cell_id}     ${parameter}     ${value}
