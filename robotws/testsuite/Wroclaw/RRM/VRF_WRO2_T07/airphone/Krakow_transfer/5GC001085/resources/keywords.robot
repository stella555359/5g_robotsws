*** Settings ***

Documentation    :copyright: Nokia

Library    ta5g_testline_management
Library    suite_specific_keywords.py
Library    wts/prep_wts_configs.py


*** Keywords ***
Set variables based on deployment and release in robot
    [Arguments]    ${feature}
    Set variables based on deployment and release    feature=${feature}
    Log to console    Unit type: ${UNIT_NAME}, Delta file: ${DELTA_FILE}, Release: ${RELEASE}


Delete XNLINK If Unit Is ASOE
    [Documentation]    Keyword implemented for ute-ca migration to new agent, where XNLINK object is present by default
    Run Keyword If    '${UNIT_NAME}' == 'ASOE'    Delete XNLINK object    id_=1


Collect additional logs
    [Arguments]    ${prefix}
    Collect gnb snapshot        output_filepath=${OUTPUT_DIR}/${prefix}/snapshot_gNB_${prefix}.zip
    Collect sos report log      prefix=${prefix}    log_output_dir=${OUTPUT_DIR}/${prefix}
    Collect airphone snapshot   output_filepath=${OUTPUT_DIR}/${prefix}/snapshot_AP_${prefix}.zip


Collect additional logs if test failed
    [Arguments]    ${prefix}
    Run Keyword If Test Failed    Collect additional logs    ${prefix}


Enforce gNB snapshot collection if requested
    [Arguments]    ${prefix}
    Run Keyword If  '${TEST_STATUS}' == 'PASS' and '${COLLECT_SNAPSHOT}' == 'True'   Collect gnb snapshot
    ...                             output_filepath=${OUTPUT_DIR}/${prefix}/snapshot_gNB_${prefix}.zip


Prepare environment
    [Arguments]    ${wts_config_filename}=${None}    ${sib1_reception_dict}=${None}    ${xnlink_check}=${False}
    ${test_prefix} =    suite_specific_keywords.get_test_prefix
    ${sib1_reception_dict} =    Run Keyword If   ${sib1_reception_dict}==${None}    Set Variable   ${CELLS_1XSIM_2XREAL}
    delete_localhost_ssh_key_from_known_hosts
    configure_ransim_vm_interfaces
    wait_for_testline_icmp_echo_replies_and_ssh_services
    ensure_gnb_files_flags_are_in_order
    log_gnb_build
    log_airphone_build
    add_info_logging_to_ap_swconfig

    ${wts_config_path} =   prepare_wts_config_file    wts_config_filename=${wts_config_filename}
    enable_debug_logging_in_wts_cfg    path_to_basic_cfg=${wts_config_path}    target_path=${wts_config_path}
    copy_wts_cfg_file_to_output_dir    ${wts_config_path}    ${test_prefix}

    setup_radiohead_and_wts_and_wait_for_mibsib_wrapper    wts_config_path=${wts_config_path}
    ...                                                    sib1_reception_dict=${sib1_reception_dict}
    Run keyword If  ${xnlink_check} == ${True}    wait_for_xnlink_status_available


Prepare env and start collecting logs
    [Arguments]    ${wts_config_filename}   ${sib1_reception_dict}=${None}
    Prepare environment    wts_config_filename=${wts_config_filename}   sib1_reception_dict=${sib1_reception_dict}
    start_collecting_logs


Teardown collecting logs in robot
    ${prefix} =   suite_specific_keywords.Get test prefix
    Teardown collecting logs
    Collect additional logs if test failed    ${prefix}
    Enforce gNB snapshot collection if requested    ${prefix}
    Collect admin api logs    dir_name=${prefix}


Teardown suite for 1085_C
    Run Keyword and Ignore Error    Change duration of periodic removal cycle via aashell
    Run Keyword And Ignore Error    Collect Admin Api Logs    subdir=${SUITE_NAME}
    ...                                                       dir_name=admin_api_logs


Teardown collecting logs and ensure there are none NRRELs
    Teardown collecting logs in robot
    Delete all nrrels


Teardown collecting logs and ensure feature flag is activated in the end
    Teardown collecting logs in robot
    Run Keyword If Test Failed    Activate feature flag


Delete objects if they exist after 7883 TC012
    ${list_of_objects} = 	Create List    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1
    ...                                    MRBTS-1/NRBTS-1/NRADJNRCELL-1
    ...                                    MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-2
    ...                                    MRBTS-1/NRBTS-1/NRADJNRCELL-1/ADJ_NRPLMNSET_SA-1
    ...                                    MRBTS-1/NRBTS-1/NRADJNRCELL-1/ADJ_NRPLMNSET_SA-2
    ...                                    ${FIRST_NRADJGNB_DIST_NAME}
    ...                                    ${FIRST_XNLINK_DIST_NAME}

    Delete objects if they exist    dist_name_list=${list_of_objects}
